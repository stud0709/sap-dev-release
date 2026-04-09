CLASS zcl_webrtc_tunnel DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_http_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_webrtc_tunnel IMPLEMENTATION.
  METHOD if_http_extension~handle_request.
    " Serve the Single-Page WebRTC Proxy Application
    server->response->set_header_field( name = 'Content-Type' value = 'text/html' ).

    DATA lt_html TYPE string_table.

    APPEND `<!DOCTYPE html>` TO lt_html.
    APPEND `<html>` TO lt_html.
    APPEND `<head>` TO lt_html.
    APPEND `    <meta charset="utf-8">` TO lt_html.
    APPEND `    <title>SAP P2P ADT Tunnel</title>` TO lt_html.
    APPEND `    <style>` TO lt_html.
    APPEND `        body { font-family: ui-sans-serif, system-ui, sans-serif; max-width: 800px; margin: 40px auto; padding: 20px; background: #f9fafb; }` TO lt_html.
    APPEND `        .card { background: white; padding: 24px; border-radius: 8px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }` TO lt_html.
    APPEND `        h2 { margin-top: 0; color: #111827; }` TO lt_html.
    APPEND `        textarea { width: 100%; height: 120px; margin: 10px 0; font-family: monospace; padding: 10px; border: 1px solid #d1d5db; border-radius: 4px; }` TO lt_html.
    APPEND `        button { background: #2563eb; color: white; border: none; padding: 10px 20px; border-radius: 4px; font-weight: bold; cursor: pointer; }` TO lt_html.
    APPEND `        button:hover { background: #1d4ed8; }` TO lt_html.
    APPEND `        .status { margin-top: 15px; padding: 10px; border-radius: 4px; font-weight: bold; }` TO lt_html.
    APPEND `        .offline { background: #fee2e2; color: #991b1b; }` TO lt_html.
    APPEND `        .online { background: #dcfce3; color: #166534; }` TO lt_html.
    APPEND `    </style>` TO lt_html.
    APPEND `</head>` TO lt_html.
    APPEND `<body>` TO lt_html.
    APPEND `    <div class="card">` TO lt_html.
    APPEND |        <h2>SAP ADT P2P Tunnel to { sy-sysid } (Client { sy-mandt })</h2>| TO lt_html.
    APPEND `        <p>1. Paste the Offer SDP from your local sap-bridge instance:</p>` TO lt_html.
    APPEND `        <textarea id="offerInput" placeholder="Paste Base64 Offer here..."></textarea>` TO lt_html.
    APPEND `        <button onclick="startConnection()">Generate Answer</button>` TO lt_html.
    APPEND `        ` TO lt_html.
    APPEND `        <p style="margin-top:20px;">2. Copy this Answer SDP back to your local sap-bridge:</p>` TO lt_html.
    APPEND `        <textarea id="answerOutput" readonly placeholder="Waiting for connection..."></textarea>` TO lt_html.
    APPEND `        <button onclick="copyAnswer()">Copy Answer</button>` TO lt_html.
    APPEND `        ` TO lt_html.
    APPEND `        <div id="statusUI" class="status offline">Status: Disconnected</div>` TO lt_html.
    APPEND `        <p style="margin-top:15px; background-color:#fffbeb; padding:10px; border-left:4px solid ` TO lt_html.
    APPEND `#f59e0b; color:#b45309; font-size:14px; border-radius:4px;"><strong>⚠️ Important:</strong> ` TO lt_html.
    APPEND `Please keep this window open in the background! Refreshing or closing this tab will permanently ` TO lt_html.
    APPEND `destroy the active WebRTC tunnel connection and instantly disconnect your AI IDE from the SAP backend.</p>` TO lt_html.
    APPEND `    </div>` TO lt_html.
    APPEND `` TO lt_html.
    APPEND `    <script>` TO lt_html.
    APPEND |        const sapSystem = '{ sy-sysid }';| TO lt_html.
    APPEND |        const sapClient = '{ sy-mandt }';| TO lt_html.
    APPEND `        const pc = new RTCPeerConnection({ iceServers: [{ urls: 'stun:stun.l.google.com:19302' }] });` TO lt_html.
    APPEND `        let dataChannel = null;` TO lt_html.
    APPEND `` TO lt_html.
    APPEND `        pc.ondatachannel = (event) => {` TO lt_html.
    APPEND `            dataChannel = event.channel;` TO lt_html.
    APPEND `            dataChannel.onopen = () => {` TO lt_html.
    APPEND `                dataChannel.send(JSON.stringify({ type: 'handshake', systemId: sapSystem, client: sapClient }));` TO lt_html.
    APPEND `            };` TO lt_html.
    APPEND `            setupChannel(dataChannel);` TO lt_html.
    APPEND `        };` TO lt_html.
    APPEND `` TO lt_html.
    APPEND `        pc.oniceconnectionstatechange = () => {` TO lt_html.
    APPEND `            const ui = document.getElementById('statusUI');` TO lt_html.
    APPEND `            if (pc.iceConnectionState === 'connected' || pc.iceConnectionState === 'completed') {` TO lt_html.
    APPEND `                ui.className = 'status online';` TO lt_html.
    APPEND `                ui.innerText = 'Status: Connected! Tunnel is active.';` TO lt_html.
    APPEND `            } else if (pc.iceConnectionState === 'disconnected' || pc.iceConnectionState === 'failed') {` TO lt_html.
    APPEND `                ui.className = 'status offline';` TO lt_html.
    APPEND `                ui.innerText = 'Status: Disconnected';` TO lt_html.
    APPEND `            }` TO lt_html.
    APPEND `        };` TO lt_html.
    APPEND `` TO lt_html.
    APPEND `        pc.onicecandidate = (event) => {` TO lt_html.
    APPEND `            if (event.candidate === null) {` TO lt_html.
    APPEND `                const answerStr = btoa(JSON.stringify(pc.localDescription));` TO lt_html.
    APPEND `                document.getElementById('answerOutput').value = answerStr;` TO lt_html.
    APPEND `            }` TO lt_html.
    APPEND `        };` TO lt_html.
    APPEND `` TO lt_html.
    APPEND `        async function startConnection() {` TO lt_html.
    APPEND `            try {` TO lt_html.
    APPEND `                const b64Offer = document.getElementById('offerInput').value.trim();` TO lt_html.
    APPEND `                if (!b64Offer) return alert("Please paste an offer first.");` TO lt_html.
    APPEND `                ` TO lt_html.
    APPEND `                const wrapper = JSON.parse(atob(b64Offer));` TO lt_html.
    APPEND `                ` TO lt_html.
    APPEND `                if (wrapper.systemId !== sapSystem || wrapper.client !== sapClient) {` TO lt_html.
    APPEND `                    alert("SECURITY BLOCK: This Offer is bound to " + wrapper.systemId + "-" + wrapper.client + ". You are currently connected to " + sapSystem + "-" + sapClient + ". Channel request aborted!");` TO lt_html.
    APPEND `                    return;` TO lt_html.
    APPEND `                }` TO lt_html.
    APPEND `                ` TO lt_html.
    APPEND `                await pc.setRemoteDescription(new RTCSessionDescription(wrapper.wrtc_desc));` TO lt_html.
    APPEND `                ` TO lt_html.
    APPEND `                const answer = await pc.createAnswer();` TO lt_html.
    APPEND `                await pc.setLocalDescription(answer);` TO lt_html.
    APPEND `                ` TO lt_html.
    APPEND `            } catch (err) {` TO lt_html.
    APPEND `                alert("Error starting connection: " + err.message);` TO lt_html.
    APPEND `            }` TO lt_html.
    APPEND `        }` TO lt_html.
    APPEND `` TO lt_html.
    APPEND `        function setupChannel(channel) {` TO lt_html.
    APPEND `            channel.onmessage = async (e) => {` TO lt_html.
    APPEND `                try {` TO lt_html.
    APPEND `                    const req = JSON.parse(e.data);` TO lt_html.
    APPEND `                    ` TO lt_html.
    APPEND `                    const safeHeaders = {};` TO lt_html.
    APPEND `                    const forbidden = ['host', 'connection', 'content-length', 'user-agent', 'origin', 'referer', 'accept-encoding', 'cookie'];` TO lt_html.
    APPEND `                    if (req.headers) {` TO lt_html.
    APPEND `                        for (const [k, v] of Object.entries(req.headers)) {` TO lt_html.
    APPEND `                            if (!forbidden.includes(k.toLowerCase())) safeHeaders[k] = v;` TO lt_html.
    APPEND `                        }` TO lt_html.
    APPEND `                    }` TO lt_html.
    APPEND `                    const fetchOpts = {` TO lt_html.
    APPEND `                        method: req.method,` TO lt_html.
    APPEND `                        headers: safeHeaders` TO lt_html.
    APPEND `                    };` TO lt_html.
    APPEND `                    if (req.body && req.method !== 'GET' && req.method !== 'HEAD') {` TO lt_html.
    APPEND `                        const bin = atob(req.body);` TO lt_html.
    APPEND `                        const len = bin.length;` TO lt_html.
    APPEND `                        const bytes = new Uint8Array(len);` TO lt_html.
    APPEND `                        for (let i = 0; i < len; i++) bytes[i] = bin.charCodeAt(i);` TO lt_html.
    APPEND `                        fetchOpts.body = bytes;` TO lt_html.
    APPEND `                    }` TO lt_html.
    APPEND `` TO lt_html.
    APPEND `                    const targetUrl = new URL(req.url).pathname + new URL(req.url).search;` TO lt_html.
    APPEND `                    const res = await fetch(targetUrl, fetchOpts);` TO lt_html.
    APPEND `                    const outHeaders = {};` TO lt_html.
    APPEND `                    res.headers.forEach((v, k) => outHeaders[k] = v);` TO lt_html.
    APPEND `                    ` TO lt_html.
    APPEND `                    const buffer = await res.arrayBuffer();` TO lt_html.
    APPEND `                    let binary = '';` TO lt_html.
    APPEND `                    const bytes = new Uint8Array(buffer);` TO lt_html.
    APPEND `                    for (let i = 0; i < bytes.byteLength; i++) {` TO lt_html.
    APPEND `                        binary += String.fromCharCode(bytes[i]);` TO lt_html.
    APPEND `                    }` TO lt_html.
    APPEND `                    const b64Body = btoa(binary);` TO lt_html.
    APPEND `` TO lt_html.
    APPEND `                    channel.send(JSON.stringify({` TO lt_html.
    APPEND `                        id: req.id,` TO lt_html.
    APPEND `                        status: res.status,` TO lt_html.
    APPEND `                        headers: outHeaders,` TO lt_html.
    APPEND `                        body: b64Body` TO lt_html.
    APPEND `                    }));` TO lt_html.
    APPEND `` TO lt_html.
    APPEND `                } catch(err) {` TO lt_html.
    APPEND `                    console.error("Fetch proxy error:", err);` TO lt_html.
    APPEND `                    let reqId = "";` TO lt_html.
    APPEND `                    try { reqId = JSON.parse(e.data).id; } catch(e2) {}` TO lt_html.
    APPEND `                    if (reqId) {` TO lt_html.
    APPEND `                        channel.send(JSON.stringify({` TO lt_html.
    APPEND `                            id: reqId,` TO lt_html.
    APPEND `                            status: 500,` TO lt_html.
    APPEND `                            headers: {},` TO lt_html.
    APPEND `                            body: btoa("Proxy Error: " + err.message)` TO lt_html.
    APPEND `                        }));` TO lt_html.
    APPEND `                    }` TO lt_html.
    APPEND `                }` TO lt_html.
    APPEND `            };` TO lt_html.
    APPEND `        }` TO lt_html.
    APPEND `` TO lt_html.
    APPEND `        function copyAnswer() {` TO lt_html.
    APPEND `            const el = document.getElementById('answerOutput');` TO lt_html.
    APPEND `            el.select();` TO lt_html.
    APPEND `            document.execCommand('copy');` TO lt_html.
    APPEND `        }` TO lt_html.
    APPEND `    </script>` TO lt_html.
    APPEND `</body>` TO lt_html.
    APPEND `</html>` TO lt_html.

    DATA(lv_html) = concat_lines_of( table = lt_html sep = cl_abap_char_utilities=>newline ).
    server->response->set_cdata( lv_html ).
  ENDMETHOD.
ENDCLASS.
