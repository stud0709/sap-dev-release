CLASS zcl_sap_dev_tunnel DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_http_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ZCL_SAP_DEV_TUNNEL IMPLEMENTATION.
  METHOD if_http_extension~handle_request.
    " Serve the Single-Page Nostr WebSocket Proxy Application
    server->response->set_header_field( name = 'Content-Type' value = 'text/html' ).

    DATA lt_html TYPE string_table.

    APPEND `<!DOCTYPE html>` TO lt_html.
    APPEND `<html>` TO lt_html.
    APPEND `<head>` TO lt_html.
    APPEND `    <meta charset="utf-8">` TO lt_html.
    APPEND `    <title>SAP ADT Tunnel</title>` TO lt_html.
    APPEND `    <style>` TO lt_html.
    APPEND `        body { font-family: ui-sans-serif, system-ui, sans-serif; max-width: 800px; margin: 40px auto; padding: 20px; background: #f9fafb; color: #111827; }` TO lt_html.
    APPEND `        .card { background: white; padding: 24px; border-radius: 8px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }` TO lt_html.
    APPEND `        h2 { margin-top: 0; color: #111827; }` TO lt_html.
    APPEND `        textarea, input[type="text"] { width: 100%; margin: 8px 0 16px 0; font-family: monospace;` TO lt_html.
    APPEND `            padding: 10px; border: 1px solid #d1d5db; border-radius: 4px; box-sizing: border-box; }` TO lt_html.
    APPEND `        textarea { height: 70px; }` TO lt_html.
    APPEND `        button { background: #2563eb; color: white; border: none; padding: 10px 20px; border-radius: 4px; font-weight: bold; cursor: pointer; }` TO lt_html.
    APPEND `        button:hover { background: #1d4ed8; }` TO lt_html.
    APPEND `        .status { margin-top: 15px; padding: 10px; border-radius: 4px; font-weight: bold; }` TO lt_html.
    APPEND `        .offline { background: #fee2e2; color: #991b1b; }` TO lt_html.
    APPEND `        .online { background: #dcfce3; color: #166534; }` TO lt_html.
    APPEND `        label { font-size: 14px; font-weight: 600; color: #374151; }` TO lt_html.
    APPEND `    </style>` TO lt_html.
    APPEND `    <script src="https://cdn.jsdelivr.net/npm/nostr-tools@1.17.0/lib/nostr.bundle.js"></script>` TO lt_html.
    APPEND `</head>` TO lt_html.
    APPEND `<body>` TO lt_html.
    APPEND `    <div class="card">` TO lt_html.
    APPEND |        <h2>SAP ADT Tunnel to { sy-sysid } (Client { sy-mandt })</h2>| TO lt_html.
    APPEND `        <p>Paste the <strong>Tunnel Pairing Token</strong> from your local sap-bridge dashboard:</p>` TO lt_html.
    APPEND `        <textarea id="tokenInput" placeholder="Paste Base64 Tunnel Pairing Token here..."></textarea>` TO lt_html.
    APPEND `        <button id="connectBtn" onclick="applyTokenAndConnect()">Connect Tunnel</button>` TO lt_html.
    APPEND `        ` TO lt_html.
    APPEND `        <div id="statusUI" class="status offline">Status: Disconnected</div>` TO lt_html.
    APPEND `        <p style="margin-top:15px; background-color:#fffbeb; padding:10px; border-left:4px solid #f59e0b; color:#b45309; font-size:14px; border-radius:4px;">` TO lt_html.
    APPEND `        <strong>&#9888; Note:</strong> Keep this tab open in the background. The tunnel proxies local SAP ADT calls to your AI IDE over encrypted Nostr WebSockets.</p>` TO lt_html.
    APPEND `        <div style="margin-top:20px; border-top:1px solid #e5e7eb; padding-top:20px; margin-bottom:20px;">` TO lt_html.
    APPEND `            <label style="font-size:14px; font-weight:600; color:#374151;">Transfer File to Local IDE:</label>` TO lt_html.
    APPEND `            <div style="display:flex; gap:10px; margin-top:8px;">` TO lt_html.
    APPEND `                <input type="file" id="fileSelector" style="font-size:13px; flex-grow:1;">` TO lt_html.
    APPEND `                <button id="uploadBtn" onclick="uploadSelectedFile()" style="padding:6px 12px; font-size:13px;">Send File</button>` TO lt_html.
    APPEND `            </div>` TO lt_html.
    APPEND `            <div id="uploadProgress" style="margin-top:8px; font-size:12px; color:#4b5563; display:none;">Preparing...</div>` TO lt_html.
    APPEND `        </div>` TO lt_html.
    APPEND `        ` TO lt_html.
    APPEND `        <div style="margin-top:20px;">` TO lt_html.
    APPEND `            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:6px;">` TO lt_html.
    APPEND `                <label style="font-size:14px; font-weight:600; color:#374151;">Live Activity Log:</label>` TO lt_html.
    APPEND `                <button type="button" onclick="clearLogs()"` TO lt_html.
    APPEND `                    style="background:#e5e7eb; color:#374151; border:none; padding:4px 10px; font-size:12px; border-radius:4px; cursor:pointer;">Clear</button>` TO lt_html.
    APPEND `            </div>` TO lt_html.
    APPEND `            <div id="logBox" style="background:#1e293b; color:#e2e8f0; font-family:monospace; font-size:12px; padding:12px;` TO lt_html.
    APPEND `                height:200px; overflow-y:auto; border-radius:6px; border:1px solid #334155; white-space:pre-wrap; word-break:break-all;">Ready.</div>` TO lt_html.
    APPEND `        </div>` TO lt_html.
    APPEND `    </div>` TO lt_html.
    APPEND `` TO lt_html.
    APPEND `    <script>` TO lt_html.
    APPEND |        const sapSystem = '{ sy-sysid }';| TO lt_html.
    APPEND |        const sapClient = '{ sy-mandt }';| TO lt_html.
    APPEND `        ` TO lt_html.
    APPEND `        let socketMap = new Map(); // relayUrl -> WebSocket` TO lt_html.
    APPEND `        let reconnectTimeouts = new Map(); // relayUrl -> timeout ID` TO lt_html.
    APPEND `        let responseCache = new Map(); // reqId -> array of chunk objects (30s TTL)` TO lt_html.
    APPEND `        let processedRequestIds = new Set();` TO lt_html.
    APPEND `        let activeTopic = '';` TO lt_html.
    APPEND `        let activeRelays = [];` TO lt_html.
    APPEND `        let pingInterval = null;` TO lt_html.
    APPEND `        let connectionTime = Math.floor(Date.now() / 1000);` TO lt_html.
    APPEND `        let incomingChunks = new Map();` TO lt_html.
    APPEND `        let incomingReceived = new Map();` TO lt_html.
    APPEND `        let incomingHashes = new Map();` TO lt_html.
    APPEND `        ` TO lt_html.
    APPEND `        function updateUIStatus() {` TO lt_html.
    APPEND `            const ui = document.getElementById('statusUI');` TO lt_html.
    APPEND `            if (!ui) return;` TO lt_html.
    APPEND `            let connectedCount = 0;` TO lt_html.
    APPEND `            socketMap.forEach(ws => {` TO lt_html.
    APPEND `                if (ws.readyState === 1) { // WebSocket.OPEN` TO lt_html.
    APPEND `                    connectedCount++;` TO lt_html.
    APPEND `                }` TO lt_html.
    APPEND `            });` TO lt_html.
    APPEND `            if (connectedCount > 0) {` TO lt_html.
    APPEND `                ui.className = 'status online';` TO lt_html.
    APPEND `                ui.innerText = 'Status: Connected to ' + connectedCount + ' Nostr Relay(s)!';` TO lt_html.
    APPEND `            } else {` TO lt_html.
    APPEND `                ui.className = 'status offline';` TO lt_html.
    APPEND `                ui.innerText = 'Status: Disconnected from Nostr Relays';` TO lt_html.
    APPEND `            }` TO lt_html.
    APPEND `        }` TO lt_html.
    APPEND `` TO lt_html.
    APPEND `        function logUI(type, msg) {` TO lt_html.
    APPEND `            const box = document.getElementById('logBox');` TO lt_html.
    APPEND `            if (!box) return;` TO lt_html.
    APPEND `            const timeStr = new Date().toLocaleTimeString();` TO lt_html.
    APPEND `            const colors = { 'INFO': '#60a5fa', 'PING': '#34d399', 'REQ': '#f59e0b', 'RES': '#a78bfa', 'ERR': '#f87171' };` TO lt_html.
    APPEND `            const color = colors[type] || '#e2e8f0';` TO lt_html.
    APPEND `            const tag = '<strong style="color:' + color + ';">[' + type + ']</strong> ';` TO lt_html.
    APPEND `            const line = '<div style="margin-bottom:3px;"><span style="color:#94a3b8;">[' + timeStr + ']</span> ' + tag + msg + '</div>';` TO lt_html.
    APPEND `            box.innerHTML += line;` TO lt_html.
    APPEND `            while (box.children.length > 100) box.removeChild(box.firstChild);` TO lt_html.
    APPEND `            box.scrollTop = box.scrollHeight;` TO lt_html.
    APPEND `        }` TO lt_html.
    APPEND `        function clearLogs() {` TO lt_html.
    APPEND `            const box = document.getElementById('logBox');` TO lt_html.
    APPEND `            if (box) box.innerHTML = '';` TO lt_html.
    APPEND `        }` TO lt_html.
    APPEND `` TO lt_html.
    APPEND `        function sendPingHeartbeat() {` TO lt_html.
    APPEND `            if (!activeTopic) return;` TO lt_html.
    APPEND `            publishNostrEvent(JSON.stringify({ type: 'ping', systemId: sapSystem, client: sapClient }));` TO lt_html.
    APPEND `        }` TO lt_html.
    APPEND `` TO lt_html.
    APPEND `        window.addEventListener('DOMContentLoaded', () => {` TO lt_html.
    APPEND `            const urlParams = new URLSearchParams(window.location.search);` TO lt_html.
    APPEND `            const urlToken = urlParams.get('token');` TO lt_html.
    APPEND `            if (urlToken) {` TO lt_html.
    APPEND `                document.getElementById('tokenInput').value = urlToken;` TO lt_html.
    APPEND `                applyTokenAndConnect();` TO lt_html.
    APPEND `            }` TO lt_html.
    APPEND `        });` TO lt_html.
    APPEND `` TO lt_html.
    APPEND `        function applyTokenAndConnect() {` TO lt_html.
    APPEND `            const tokenStr = document.getElementById('tokenInput').value.trim();` TO lt_html.
    APPEND `            if (!tokenStr) return alert("Please paste the Tunnel Pairing Token.");` TO lt_html.
    APPEND `            try {` TO lt_html.
    APPEND `                const parsed = JSON.parse(atob(tokenStr));` TO lt_html.
    APPEND `                if (!parsed.topic) return alert("Invalid Tunnel Pairing Token: missing topic.");` TO lt_html.
    APPEND `                ` TO lt_html.
    APPEND `                const tokSys = (parsed.system_id || parsed.systemId || '').toUpperCase();` TO lt_html.
    APPEND `                const tokCli = (parsed.client || '').trim();` TO lt_html.
    APPEND `                if (tokSys && tokSys !== sapSystem.toUpperCase()) {` TO lt_html.
    APPEND `                    return alert('System Mismatch! Token is for ' + tokSys + ', but this SAP system is ' + sapSystem + '.');` TO lt_html.
    APPEND `                }` TO lt_html.
    APPEND `                if (tokCli && tokCli !== sapClient) {` TO lt_html.
    APPEND `                    return alert('Client Mismatch! Token is for Client ' + tokCli + ', but this SAP client is ' + sapClient + '.');` TO lt_html.
    APPEND `                }` TO lt_html.
    APPEND `` TO lt_html.
    APPEND `                const topic = parsed.topic;` TO lt_html.
    APPEND `                const relays = Array.isArray(parsed.relays) ? parsed.relays.join(', ') : (parsed.relays || 'wss://relay.damus.io, wss://nos.lol, wss://relay.primal.net');` TO lt_html.
    APPEND `                startTunnelConnection(topic, relays);` TO lt_html.
    APPEND `            } catch (e) {` TO lt_html.
    APPEND `                alert("Could not parse Tunnel Pairing Token as Base64 JSON: " + e.message);` TO lt_html.
    APPEND `            }` TO lt_html.
    APPEND `        }` TO lt_html.
    APPEND `` TO lt_html.
    APPEND `        function startTunnelConnection(topic, relaysStr) {` TO lt_html.
    APPEND `            closeSockets();` TO lt_html.
    APPEND `            activeTopic = topic;` TO lt_html.
    APPEND `            activeRelays = relaysStr.split(',').map(s => s.trim()).filter(Boolean);` TO lt_html.
    APPEND `            ` TO lt_html.
    APPEND `            const ui = document.getElementById('statusUI');` TO lt_html.
    APPEND `            ui.className = 'status offline';` TO lt_html.
    APPEND `            ui.innerText = 'Status: Connecting to Nostr Relays...';` TO lt_html.
    APPEND `            logUI('INFO', 'Connecting to Nostr Topic: ' + topic);` TO lt_html.
    APPEND `            ` TO lt_html.
    APPEND `            activeRelays.forEach(relayUrl => {` TO lt_html.
    APPEND `                connectRelay(relayUrl, 0);` TO lt_html.
    APPEND `            });` TO lt_html.
    APPEND `        }` TO lt_html.
    APPEND `        ` TO lt_html.
    APPEND `        function connectRelay(relayUrl, retryCount) {` TO lt_html.
    APPEND `            if (!activeTopic) return;` TO lt_html.
    APPEND `            ` TO lt_html.
    APPEND `            let oldWs = socketMap.get(relayUrl);` TO lt_html.
    APPEND `            if (oldWs) {` TO lt_html.
    APPEND `                try { oldWs.onclose = null; oldWs.close(); } catch(e) {}` TO lt_html.
    APPEND `                socketMap.delete(relayUrl);` TO lt_html.
    APPEND `            }` TO lt_html.
    APPEND `            ` TO lt_html.
    APPEND `            let oldTimeout = reconnectTimeouts.get(relayUrl);` TO lt_html.
    APPEND `            if (oldTimeout) {` TO lt_html.
    APPEND `                clearTimeout(oldTimeout);` TO lt_html.
    APPEND `                reconnectTimeouts.delete(relayUrl);` TO lt_html.
    APPEND `            }` TO lt_html.
    APPEND `            ` TO lt_html.
    APPEND `            try {` TO lt_html.
    APPEND `                const ws = new WebSocket(relayUrl);` TO lt_html.
    APPEND `                socketMap.set(relayUrl, ws);` TO lt_html.
    APPEND `                ` TO lt_html.
    APPEND `                ws.onopen = () => {` TO lt_html.
    APPEND `                    logUI('INFO', 'WebSocket connected to relay: ' + relayUrl);` TO lt_html.
    APPEND `                    let currentlyConnected = false;` TO lt_html.
    APPEND `                    socketMap.forEach((s) => {` TO lt_html.
    APPEND `                        if (s !== ws && s.readyState === 1) currentlyConnected = true;` TO lt_html.
    APPEND `                    });` TO lt_html.
    APPEND `                    if (!currentlyConnected) {` TO lt_html.
    APPEND `                        connectionTime = Math.floor(Date.now() / 1000);` TO lt_html.
    APPEND `                        logUI('INFO', 'Tunnel established. Discarding stale events.');` TO lt_html.
    APPEND `                    }` TO lt_html.
    APPEND `                    updateUIStatus();` TO lt_html.
    APPEND `                    ` TO lt_html.
    APPEND `                    const subFilter = { kinds: [20000], '#t': [activeTopic], since: Math.floor(Date.now() / 1000) - 5 };` TO lt_html.
    APPEND `                    ws.send(JSON.stringify(['REQ', 'sub_browser_' + Date.now(), subFilter]));` TO lt_html.
    APPEND `                    sendPingHeartbeat();` TO lt_html.
    APPEND `                    if (!pingInterval) pingInterval = setInterval(sendPingHeartbeat, 15000);` TO lt_html.
    APPEND `                };` TO lt_html.
    APPEND `                ` TO lt_html.
    APPEND `                ws.onmessage = (event) => handleRelayMessage(event.data);` TO lt_html.
    APPEND `                ` TO lt_html.
    APPEND `                ws.onclose = (event) => {` TO lt_html.
    APPEND `                    socketMap.delete(relayUrl);` TO lt_html.
    APPEND `                    logUI('ERR', 'WebSocket disconnected: ' + relayUrl + ' (code: ' + event.code + ')');` TO lt_html.
    APPEND `                    updateUIStatus();` TO lt_html.
    APPEND `                    ` TO lt_html.
    APPEND `                    if (activeTopic) {` TO lt_html.
    APPEND `                        const nextDelay = Math.min(1000 * Math.pow(2, retryCount) + (Math.random() * 1000), 30000);` TO lt_html.
    APPEND `                        logUI('INFO', 'Reconnecting to ' + relayUrl + ' in ' + Math.round(nextDelay/1000) + 's...');` TO lt_html.
    APPEND `                        const t = setTimeout(() => {` TO lt_html.
    APPEND `                            connectRelay(relayUrl, retryCount + 1);` TO lt_html.
    APPEND `                        }, nextDelay);` TO lt_html.
    APPEND `                        reconnectTimeouts.set(relayUrl, t);` TO lt_html.
    APPEND `                    }` TO lt_html.
    APPEND `                };` TO lt_html.
    APPEND `                ` TO lt_html.
    APPEND `                ws.onerror = (err) => {` TO lt_html.
    APPEND `                    console.error("Relay connection error:", relayUrl, err);` TO lt_html.
    APPEND `                };` TO lt_html.
    APPEND `            } catch (err) {` TO lt_html.
    APPEND `                console.error("Relay connection error:", relayUrl, err);` TO lt_html.
    APPEND `                logUI('ERR', 'Relay connection error: ' + relayUrl);` TO lt_html.
    APPEND `                if (activeTopic) {` TO lt_html.
    APPEND `                    const nextDelay = Math.min(1000 * Math.pow(2, retryCount) + (Math.random() * 1000), 30000);` TO lt_html.
    APPEND `                    const t = setTimeout(() => {` TO lt_html.
    APPEND `                        connectRelay(relayUrl, retryCount + 1);` TO lt_html.
    APPEND `                    }, nextDelay);` TO lt_html.
    APPEND `                    reconnectTimeouts.set(relayUrl, t);` TO lt_html.
    APPEND `                }` TO lt_html.
    APPEND `            }` TO lt_html.
    APPEND `        }` TO lt_html.
    APPEND `        ` TO lt_html.
    APPEND `        function closeSockets() {` TO lt_html.
    APPEND `            if (pingInterval) { clearInterval(pingInterval); pingInterval = null; }` TO lt_html.
    APPEND `            reconnectTimeouts.forEach(t => clearTimeout(t));` TO lt_html.
    APPEND `            reconnectTimeouts.clear();` TO lt_html.
    APPEND `            socketMap.forEach(ws => {` TO lt_html.
    APPEND `                try {` TO lt_html.
    APPEND `                    ws.onclose = null;` TO lt_html.
    APPEND `                    ws.close();` TO lt_html.
    APPEND `                } catch(e) {}` TO lt_html.
    APPEND `            });` TO lt_html.
    APPEND `            socketMap.clear();` TO lt_html.
    APPEND `            updateUIStatus();` TO lt_html.
    APPEND `        }` TO lt_html.
    APPEND `` TO lt_html.
    APPEND `        async function uploadSelectedFile() {` TO lt_html.
    APPEND `            const selector = document.getElementById('fileSelector');` TO lt_html.
    APPEND `            if (!selector.files || !selector.files.length) return alert("Please select a file first.");` TO lt_html.
    APPEND `            const file = selector.files[0];` TO lt_html.
    APPEND `            const reader = new FileReader();` TO lt_html.
    APPEND `            const progress = document.getElementById('uploadProgress');` TO lt_html.
    APPEND `            progress.style.display = 'block';` TO lt_html.
    APPEND `            progress.style.color = '';` TO lt_html.
    APPEND `            progress.innerText = 'Reading file...';` TO lt_html.
    APPEND `            reader.onload = async (e) => {` TO lt_html.
    APPEND `                const base64Data = e.target.result.split(',')[1];` TO lt_html.
    APPEND `                const fileEnvelope = {` TO lt_html.
    APPEND `                    type: 'file_upload',` TO lt_html.
    APPEND `                    id: 'file_' + Math.random().toString(36).substring(2, 15),` TO lt_html.
    APPEND `                    filename: file.name,` TO lt_html.
    APPEND `                    body: base64Data` TO lt_html.
    APPEND `                };` TO lt_html.
    APPEND `                const fullJson = JSON.stringify(fileEnvelope);` TO lt_html.
    APPEND `                const chunkSize = 32768;` TO lt_html.
    APPEND `                const totalChunks = Math.ceil(fullJson.length / chunkSize);` TO lt_html.
    APPEND `                const encoder = new TextEncoder();` TO lt_html.
    APPEND `                const dataBuffer = encoder.encode(fullJson);` TO lt_html.
    APPEND `                const hashBuffer = await crypto.subtle.digest('SHA-256', dataBuffer);` TO lt_html.
    APPEND `                const hashArray = Array.from(new Uint8Array(hashBuffer));` TO lt_html.
    APPEND `                const hashHex = hashArray.map(b => b.toString(16).padStart(2, '0')).join('');` TO lt_html.
    APPEND `                const chunkEvents = [];` TO lt_html.
    APPEND `                for (let i = 0; i < totalChunks; i++) {` TO lt_html.
    APPEND `                    const slice = fullJson.substr(i * chunkSize, chunkSize);` TO lt_html.
    APPEND `                    const chunkPayload = JSON.stringify({` TO lt_html.
    APPEND `                        type: 'chunk',` TO lt_html.
    APPEND `                        id: fileEnvelope.id,` TO lt_html.
    APPEND `                        index: i,` TO lt_html.
    APPEND `                        total: totalChunks,` TO lt_html.
    APPEND `                        hash: hashHex,` TO lt_html.
    APPEND `                        chunk: slice` TO lt_html.
    APPEND `                    });` TO lt_html.
    APPEND `                    chunkEvents.push(chunkPayload);` TO lt_html.
    APPEND `                    publishNostrEvent(chunkPayload);` TO lt_html.
    APPEND `                }` TO lt_html.
    APPEND `                responseCache.set(fileEnvelope.id, chunkEvents);` TO lt_html.
    APPEND `                progress.innerText = 'Sent ' + totalChunks + ' chunk(s). Waiting for local daemon...';` TO lt_html.
    APPEND `                logUI('INFO', 'Started file transfer: ' + file.name + ' (' + totalChunks + ' chunks)');` TO lt_html.
    APPEND `            };` TO lt_html.
    APPEND `            reader.readAsDataURL(file);` TO lt_html.
    APPEND `        }` TO lt_html.
    APPEND `        ` TO lt_html.
    APPEND `        function processIncomingChunk(msg) {` TO lt_html.
    APPEND `            const reqId = msg.id;` TO lt_html.
    APPEND `            if (!incomingChunks.has(reqId)) {` TO lt_html.
    APPEND `                incomingChunks.set(reqId, new Array(msg.total));` TO lt_html.
    APPEND `                incomingReceived.set(reqId, 0);` TO lt_html.
    APPEND `                if (msg.hash) incomingHashes.set(reqId, msg.hash);` TO lt_html.
    APPEND `            }` TO lt_html.
    APPEND `            const chunks = incomingChunks.get(reqId);` TO lt_html.
    APPEND `            if (msg.index < 0 || msg.index >= msg.total) return;` TO lt_html.
    APPEND `            if (!chunks[msg.index]) {` TO lt_html.
    APPEND `                chunks[msg.index] = msg.chunk;` TO lt_html.
    APPEND `                incomingReceived.set(reqId, incomingReceived.get(reqId) + 1);` TO lt_html.
    APPEND `            }` TO lt_html.
    APPEND `            if (incomingReceived.get(reqId) === msg.total) {` TO lt_html.
    APPEND `                const fullJson = chunks.join('');` TO lt_html.
    APPEND `                incomingChunks.delete(reqId);` TO lt_html.
    APPEND `                incomingReceived.delete(reqId);` TO lt_html.
    APPEND `                incomingHashes.delete(reqId);` TO lt_html.
    APPEND `                finalizeIncomingPayload(fullJson);` TO lt_html.
    APPEND `            }` TO lt_html.
    APPEND `        }` TO lt_html.
    APPEND `        ` TO lt_html.
    APPEND `        function finalizeIncomingPayload(fullJson) {` TO lt_html.
    APPEND `            try {` TO lt_html.
    APPEND `                const parsed = JSON.parse(fullJson);` TO lt_html.
    APPEND `                if (parsed.type === 'file_upload_ack' && parsed.id) {` TO lt_html.
    APPEND `                    const progress = document.getElementById('uploadProgress');` TO lt_html.
    APPEND `                    if (progress) {` TO lt_html.
    APPEND `                        progress.style.color = '#166534';` TO lt_html.
    APPEND `                        progress.innerText = 'Upload complete: ' + parsed.filename + '!';` TO lt_html.
    APPEND `                    }` TO lt_html.
    APPEND `                    logUI('RES', 'File transfer acknowledged by local daemon: ' + parsed.filename);` TO lt_html.
    APPEND `                } else if (parsed.type === 'file_download' && parsed.filename && parsed.body) {` TO lt_html.
    APPEND `                    handleFileDownloadEnvelope(parsed);` TO lt_html.
    APPEND `                } else if (parsed.id && parsed.method && parsed.url) {` TO lt_html.
    APPEND `                    if (processedRequestIds.has(parsed.id)) return;` TO lt_html.
    APPEND `                    processedRequestIds.add(parsed.id);` TO lt_html.
    APPEND `                    if (processedRequestIds.size > 200) {` TO lt_html.
    APPEND `                        const firstVal = processedRequestIds.values().next().value;` TO lt_html.
    APPEND `                        processedRequestIds.delete(firstVal);` TO lt_html.
    APPEND `                    }` TO lt_html.
    APPEND `                    logUI('REQ', parsed.method + ' ' + parsed.url);` TO lt_html.
    APPEND `                    executeProxyFetch(parsed);` TO lt_html.
    APPEND `                }` TO lt_html.
    APPEND `            } catch (err) {` TO lt_html.
    APPEND `                console.error('Failed to parse reassembled payload:', err);` TO lt_html.
    APPEND `            }` TO lt_html.
    APPEND `        }` TO lt_html.
    APPEND `        ` TO lt_html.
    APPEND `        function handleFileDownloadEnvelope(envelope) {` TO lt_html.
    APPEND `            try {` TO lt_html.
    APPEND `                logUI('INFO', 'Received file from local daemon: ' + envelope.filename + '. Triggering download...');` TO lt_html.
    APPEND `                const binaryString = atob(envelope.body);` TO lt_html.
    APPEND `                const len = binaryString.length;` TO lt_html.
    APPEND `                const bytes = new Uint8Array(len);` TO lt_html.
    APPEND `                for (let i = 0; i < len; i++) {` TO lt_html.
    APPEND `                    bytes[i] = binaryString.charCodeAt(i);` TO lt_html.
    APPEND `                }` TO lt_html.
    APPEND `                const blob = new Blob([bytes], { type: 'application/octet-stream' });` TO lt_html.
    APPEND `                const url = URL.createObjectURL(blob);` TO lt_html.
    APPEND `                const a = document.createElement('a');` TO lt_html.
    APPEND `                a.href = url;` TO lt_html.
    APPEND `                a.download = envelope.filename;` TO lt_html.
    APPEND `                document.body.appendChild(a);` TO lt_html.
    APPEND `                a.click();` TO lt_html.
    APPEND `                document.body.removeChild(a);` TO lt_html.
    APPEND `                URL.revokeObjectURL(url);` TO lt_html.
    APPEND `                logUI('RES', 'Successfully downloaded: ' + envelope.filename);` TO lt_html.
    APPEND `            } catch (err) {` TO lt_html.
    APPEND `                logUI('ERR', 'Failed to process file download: ' + err.message);` TO lt_html.
    APPEND `            }` TO lt_html.
    APPEND `        }` TO lt_html.
    APPEND `` TO lt_html.
    APPEND `        async function handleRelayMessage(rawStr) {` TO lt_html.
    APPEND `            try {` TO lt_html.
    APPEND `                const msg = JSON.parse(rawStr);` TO lt_html.
    APPEND `                if (msg[0] !== 'EVENT' || !msg[2]) return;` TO lt_html.
    APPEND `                const evt = msg[2];` TO lt_html.
    APPEND `                if (evt.created_at) {` TO lt_html.
    APPEND `                    if (evt.created_at < connectionTime - 5) {` TO lt_html.
    APPEND `                        logUI('INFO', 'Discarded stale request ' + evt.id.substring(0,8) + ' (created ' + (connectionTime - evt.created_at) + 's before connection)');` TO lt_html.
    APPEND `                        return;` TO lt_html.
    APPEND `                    }` TO lt_html.
    APPEND `                    if (evt.created_at < Math.floor(Date.now() / 1000) - 15) return;` TO lt_html.
    APPEND `                }` TO lt_html.
    APPEND `                const content = evt.content;` TO lt_html.
    APPEND `                ` TO lt_html.
    APPEND `                let parsed = null;` TO lt_html.
    APPEND `                try { parsed = JSON.parse(content); } catch(e) {}` TO lt_html.
    APPEND `                if (!parsed) return;` TO lt_html.
    APPEND `                ` TO lt_html.
    APPEND `                if (parsed.type === 'nack' && parsed.id && parsed.missing_indices) {` TO lt_html.
    APPEND `                    handleNack(parsed.id, parsed.missing_indices);` TO lt_html.
    APPEND `                    return;` TO lt_html.
    APPEND `                }` TO lt_html.
    APPEND `                ` TO lt_html.
    APPEND `                if (parsed.type === 'chunk' && parsed.id && parsed.total) {` TO lt_html.
    APPEND `                    processIncomingChunk(parsed);` TO lt_html.
    APPEND `                } else {` TO lt_html.
    APPEND `                    finalizeIncomingPayload(content);` TO lt_html.
    APPEND `                }` TO lt_html.
    APPEND `            } catch (err) {` TO lt_html.
    APPEND `                console.error("Error handling relay message:", err);` TO lt_html.
    APPEND `            }` TO lt_html.
    APPEND `        }` TO lt_html.
    APPEND `` TO lt_html.
    APPEND `        function handleNack(reqId, missingIndices) {` TO lt_html.
    APPEND `            const chunks = responseCache.get(reqId);` TO lt_html.
    APPEND `            if (!chunks) return;` TO lt_html.
    APPEND `            missingIndices.forEach(idx => {` TO lt_html.
    APPEND `                if (chunks[idx]) publishNostrEvent(chunks[idx]);` TO lt_html.
    APPEND `            });` TO lt_html.
    APPEND `        }` TO lt_html.
    APPEND `` TO lt_html.
    APPEND `        async function executeProxyFetch(req) {` TO lt_html.
    APPEND `            try {` TO lt_html.
    APPEND `                const safeHeaders = {};` TO lt_html.
    APPEND `                const forbidden = ['host', 'connection', 'content-length', 'user-agent', 'origin', 'referer', 'accept-encoding', 'cookie'];` TO lt_html.
    APPEND `                if (req.headers) {` TO lt_html.
    APPEND `                    for (const [k, v] of Object.entries(req.headers)) {` TO lt_html.
    APPEND `                        const kLower = k.toLowerCase();` TO lt_html.
    APPEND `                        if (kLower === 'authorization') {` TO lt_html.
    APPEND `                            if (v && v.trim() !== '' && !v.includes('Basic Og==') && !v.includes('Basic :')) safeHeaders[k] = v;` TO lt_html.
    APPEND `                        } else if (!forbidden.includes(kLower)) {` TO lt_html.
    APPEND `                            safeHeaders[k] = v;` TO lt_html.
    APPEND `                        }` TO lt_html.
    APPEND `                    }` TO lt_html.
    APPEND `                }` TO lt_html.
    APPEND `                const fetchOpts = { method: req.method, headers: safeHeaders, credentials: 'include', cache: 'no-cache' };` TO lt_html.
    APPEND `                if (req.body && req.method !== 'GET' && req.method !== 'HEAD') {` TO lt_html.
    APPEND `                    const bin = atob(req.body);` TO lt_html.
    APPEND `                    const bytes = new Uint8Array(bin.length);` TO lt_html.
    APPEND `                    for (let i = 0; i < bin.length; i++) bytes[i] = bin.charCodeAt(i);` TO lt_html.
    APPEND `                    fetchOpts.body = bytes;` TO lt_html.
    APPEND `                }` TO lt_html.
    APPEND `                ` TO lt_html.
    APPEND `                const targetUrl = new URL(req.url).pathname + new URL(req.url).search;` TO lt_html.
    APPEND `                const res = await fetch(targetUrl, fetchOpts);` TO lt_html.
    APPEND `                const outHeaders = {};` TO lt_html.
    APPEND `                res.headers.forEach((v, k) => outHeaders[k] = v);` TO lt_html.
    APPEND `                ` TO lt_html.
    APPEND `                const buffer = await res.arrayBuffer();` TO lt_html.
    APPEND `                ` TO lt_html.
    APPEND `                let compressedData = null;` TO lt_html.
    APPEND `                if (typeof CompressionStream !== 'undefined') {` TO lt_html.
    APPEND `                    try {` TO lt_html.
    APPEND `                        const cs = new CompressionStream('gzip');` TO lt_html.
    APPEND `                        const writer = cs.writable.getWriter();` TO lt_html.
    APPEND `                        writer.write(new Uint8Array(buffer));` TO lt_html.
    APPEND `                        writer.close();` TO lt_html.
    APPEND `                        const compBuf = await new Response(cs.readable).arrayBuffer();` TO lt_html.
    APPEND `                        compressedData = new Uint8Array(compBuf);` TO lt_html.
    APPEND `                    } catch (e) {}` TO lt_html.
    APPEND `                }` TO lt_html.
    APPEND `                ` TO lt_html.
    APPEND `                const dataToEncode = compressedData || new Uint8Array(buffer);` TO lt_html.
    APPEND `                const b64Payload = await arrayBufferToBase64(dataToEncode);` TO lt_html.
    APPEND `                ` TO lt_html.
    APPEND `                const hashBuffer = await crypto.subtle.digest('SHA-256', dataToEncode);` TO lt_html.
    APPEND `                const hashArray = Array.from(new Uint8Array(hashBuffer));` TO lt_html.
    APPEND `                const hashHex = hashArray.map(b => b.toString(16).padStart(2, '0')).join('');` TO lt_html.
    APPEND `                ` TO lt_html.
    APPEND `                const respObj = { id: req.id, status: res.status, headers: outHeaders, body: b64Payload };` TO lt_html.
    APPEND `                const fullJson = JSON.stringify(respObj);` TO lt_html.
    APPEND `                ` TO lt_html.
    APPEND `                const chunkSize = 32768; // 32 KB chunk size` TO lt_html.
    APPEND `                const totalChunks = Math.ceil(fullJson.length / chunkSize);` TO lt_html.
    APPEND `                const chunkEvents = [];` TO lt_html.
    APPEND `                ` TO lt_html.
    APPEND `                for (let i = 0; i < totalChunks; i++) {` TO lt_html.
    APPEND `                    const slice = fullJson.substr(i * chunkSize, chunkSize);` TO lt_html.
    APPEND `                    const chunkPayload = JSON.stringify({` TO lt_html.
    APPEND `                        type: 'chunk',` TO lt_html.
    APPEND `                        id: req.id,` TO lt_html.
    APPEND `                        index: i,` TO lt_html.
    APPEND `                        total: totalChunks,` TO lt_html.
    APPEND `                        hash: hashHex,` TO lt_html.
    APPEND `                        chunk: slice` TO lt_html.
    APPEND `                    });` TO lt_html.
    APPEND `                    chunkEvents.push(chunkPayload);` TO lt_html.
    APPEND `                    publishNostrEvent(chunkPayload);` TO lt_html.
    APPEND `                }` TO lt_html.
    APPEND `                ` TO lt_html.
    APPEND `                responseCache.set(req.id, chunkEvents);` TO lt_html.
    APPEND `                setTimeout(() => responseCache.delete(req.id), 30000);` TO lt_html.
    APPEND `                const statusHighlight = res.status === 200 ? '200' : '<span style="color:#f87171; font-weight:bold; background:rgba(248,113,113,0.15); padding:2px 6px; border-radius:3px;">' + res.status + '</span>';` TO lt_html.
    APPEND `                logUI('RES', req.method + ' ' + targetUrl + ' -> ' + statusHighlight + ' (' + totalChunks + ' chunk(s))');` TO lt_html.
    APPEND `                ` TO lt_html.
    APPEND `            } catch (err) {` TO lt_html.
    APPEND `                console.error("Proxy fetch error:", err);` TO lt_html.
    APPEND `                const errPayload = JSON.stringify({ id: req.id, status: 500, body: btoa("Proxy Error: " + err.message) });` TO lt_html.
    APPEND `                const errObj = JSON.stringify({ type: 'chunk', id: req.id, index: 0, total: 1, chunk: btoa(errPayload) });` TO lt_html.
    APPEND `                publishNostrEvent(errObj);` TO lt_html.
    APPEND `                logUI('ERR', 'Proxy fetch error: ' + err.message);` TO lt_html.
    APPEND `            }` TO lt_html.
    APPEND `        }` TO lt_html.
    APPEND `` TO lt_html.
    APPEND `        function arrayBufferToBase64(buffer) {` TO lt_html.
    APPEND `            return new Promise((resolve) => {` TO lt_html.
    APPEND `                const blob = new Blob([buffer]);` TO lt_html.
    APPEND `                const reader = new FileReader();` TO lt_html.
    APPEND `                reader.onloadend = () => resolve(reader.result.split(',')[1]);` TO lt_html.
    APPEND `                reader.readAsDataURL(blob);` TO lt_html.
    APPEND `            });` TO lt_html.
    APPEND `        }` TO lt_html.
    APPEND `` TO lt_html.
    APPEND `        const P_secp = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2Fn;` TO lt_html.
    APPEND `        const N_secp = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2E3Fn;` TO lt_html.
    APPEND `        const Gx_secp = 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798n;` TO lt_html.
    APPEND `        const Gy_secp = 0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8n;` TO lt_html.
    APPEND `` TO lt_html.
    APPEND `        function modP(a) { let r = a % P_secp; return r < 0n ? r + P_secp : r; }` TO lt_html.
    APPEND `        function modN(a) { let r = a % N_secp; return r < 0n ? r + N_secp : r; }` TO lt_html.
    APPEND `        function powP(base, exp) {` TO lt_html.
    APPEND `            let res = 1n; base = modP(base);` TO lt_html.
    APPEND `            while (exp > 0n) {` TO lt_html.
    APPEND `                if (exp % 2n === 1n) res = modP(res * base);` TO lt_html.
    APPEND `                base = modP(base * base); exp /= 2n;` TO lt_html.
    APPEND `            }` TO lt_html.
    APPEND `            return res;` TO lt_html.
    APPEND `        }` TO lt_html.
    APPEND `        function invP(a) { return powP(a, P_secp - 2n); }` TO lt_html.
    APPEND `` TO lt_html.
    APPEND `        class SecpPoint {` TO lt_html.
    APPEND `            constructor(x, y) { this.x = x; this.y = y; }` TO lt_html.
    APPEND `            static get BASE() { return new SecpPoint(Gx_secp, Gy_secp); }` TO lt_html.
    APPEND `            static get ZERO() { return new SecpPoint(0n, 0n); }` TO lt_html.
    APPEND `            isZero() { return this.x === 0n && this.y === 0n; }` TO lt_html.
    APPEND `            add(p) {` TO lt_html.
    APPEND `                if (this.isZero()) return p;` TO lt_html.
    APPEND `                if (p.isZero()) return this;` TO lt_html.
    APPEND `                if (this.x === p.x && this.y !== p.y) return SecpPoint.ZERO;` TO lt_html.
    APPEND `                let m = (this.x === p.x) ? modP(3n * this.x * this.x * invP(2n * this.y)) : modP((p.y - this.y) * invP(p.x - this.x));` TO lt_html.
    APPEND `                let x3 = modP(m * m - this.x - p.x);` TO lt_html.
    APPEND `                let y3 = modP(m * (this.x - x3) - this.y);` TO lt_html.
    APPEND `                return new SecpPoint(x3, y3);` TO lt_html.
    APPEND `            }` TO lt_html.
    APPEND `            mul(sc) {` TO lt_html.
    APPEND `                let n = modN(sc), res = SecpPoint.ZERO, curr = this;` TO lt_html.
    APPEND `                while (n > 0n) {` TO lt_html.
    APPEND `                    if (n % 2n === 1n) res = res.add(curr);` TO lt_html.
    APPEND `                    curr = curr.add(curr); n /= 2n;` TO lt_html.
    APPEND `                }` TO lt_html.
    APPEND `                return res;` TO lt_html.
    APPEND `            }` TO lt_html.
    APPEND `        }` TO lt_html.
    APPEND `` TO lt_html.
    APPEND `        let clientPrivKeyHex = null;` TO lt_html.
    APPEND `        function getClientPrivKey() {` TO lt_html.
    APPEND `            if (!clientPrivKeyHex) {` TO lt_html.
    APPEND `                const bytes = crypto.getRandomValues(new Uint8Array(32));` TO lt_html.
APPEND `                        clientPrivKeyHex = Array.from(bytes).map(b => b.toString(16).padStart(2, '0')).join('');` TO lt_html.
    APPEND `            }` TO lt_html.
    APPEND `            return clientPrivKeyHex;` TO lt_html.
    APPEND `        }` TO lt_html.
    APPEND `` TO lt_html.
    APPEND `        async function createSignedNostrEvent(payloadStr) {` TO lt_html.
    APPEND `            const skHex = getClientPrivKey();` TO lt_html.
    APPEND `            if (window.NostrTools && window.NostrTools.finishEvent) {` TO lt_html.
    APPEND `                const evtTpl = { kind: 20000, created_at: Math.floor(Date.now() / 1000), tags: [['t', activeTopic], ['d', 'sap-bridge-res']], content: payloadStr };` TO lt_html.
    APPEND `                const signedEvt = window.NostrTools.finishEvent(evtTpl, skHex);` TO lt_html.
    APPEND `                return ['EVENT', signedEvt];` TO lt_html.
    APPEND `            }` TO lt_html.
    APPEND `` TO lt_html.
    APPEND `            let d = BigInt('0x' + skHex) % N_secp;` TO lt_html.
    APPEND `            if (d === 0n) d = 1n;` TO lt_html.
    APPEND `            let P = SecpPoint.BASE.mul(d);` TO lt_html.
    APPEND `            if (P.y % 2n !== 0n) { d = N_secp - d; P = SecpPoint.BASE.mul(d); }` TO lt_html.
    APPEND `            const pubHex = P.x.toString(16).padStart(64, '0');` TO lt_html.
    APPEND `` TO lt_html.
    APPEND `            const created_at = Math.floor(Date.now() / 1000);` TO lt_html.
    APPEND `            const kind = 20000;` TO lt_html.
    APPEND `            const tags = [['t', activeTopic], ['d', 'sap-bridge-res']];` TO lt_html.
    APPEND `` TO lt_html.
    APPEND `            const serialized = JSON.stringify([0, pubHex, created_at, kind, tags, payloadStr]);` TO lt_html.
    APPEND `            const enc = new TextEncoder();` TO lt_html.
    APPEND `            const hashBuf = await crypto.subtle.digest('SHA-256', enc.encode(serialized));` TO lt_html.
    APPEND `            const eventIdHex = Array.from(new Uint8Array(hashBuf)).map(b => b.toString(16).padStart(2, '0')).join('');` TO lt_html.
    APPEND `` TO lt_html.
    APPEND `            const kBytes = crypto.getRandomValues(new Uint8Array(32));` TO lt_html.
    APPEND `            let k0 = BigInt('0x' + Array.from(kBytes).map(b => b.toString(16).padStart(2, '0')).join('')) % N_secp;` TO lt_html.
    APPEND `            if (k0 === 0n) k0 = 1n;` TO lt_html.
    APPEND `            let R = SecpPoint.BASE.mul(k0);` TO lt_html.
    APPEND `            if (R.y % 2n !== 0n) { k0 = N_secp - k0; R = SecpPoint.BASE.mul(k0); }` TO lt_html.
    APPEND `            const rxHex = R.x.toString(16).padStart(64, '0');` TO lt_html.
    APPEND `` TO lt_html.
    APPEND `            const eBuf = new Uint8Array(96);` TO lt_html.
    APPEND `            const hex2bytes = h => new Uint8Array(h.match(/.{1,2}/g).map(b => parseInt(b, 16)));` TO lt_html.
    APPEND `            eBuf.set(hex2bytes(rxHex), 0);` TO lt_html.
    APPEND `            eBuf.set(hex2bytes(pubHex), 32);` TO lt_html.
    APPEND `            eBuf.set(hex2bytes(eventIdHex), 64);` TO lt_html.
    APPEND `            const eHash = await crypto.subtle.digest('SHA-256', eBuf);` TO lt_html.
    APPEND `            const eHex = Array.from(new Uint8Array(eHash)).map(b => b.toString(16).padStart(2, '0')).join('');` TO lt_html.
    APPEND `            let e = BigInt('0x' + eHex) % N_secp;` TO lt_html.
    APPEND `            let s = modN(k0 + e * d);` TO lt_html.
    APPEND `            const sigHex = rxHex + s.toString(16).padStart(64, '0');` TO lt_html.
    APPEND `` TO lt_html.
    APPEND `            return ['EVENT', { id: eventIdHex, pubkey: pubHex, created_at: created_at, kind: kind, tags: tags, content: payloadStr, sig: sigHex }];` TO lt_html.
    APPEND `        }` TO lt_html.
    APPEND `` TO lt_html.
    APPEND `        async function publishNostrEvent(payloadStr) {` TO lt_html.
    APPEND `            if (!activeTopic) return;` TO lt_html.
    APPEND `            const evtMsg = await createSignedNostrEvent(payloadStr);` TO lt_html.
    APPEND `            const jsonStr = JSON.stringify(evtMsg);` TO lt_html.
    APPEND `            socketMap.forEach(ws => {` TO lt_html.
    APPEND `                if (ws.readyState === 1) { // WebSocket.OPEN` TO lt_html.
    APPEND `                    ws.send(jsonStr);` TO lt_html.
    APPEND `                }` TO lt_html.
    APPEND `            });` TO lt_html.
    APPEND `        }` TO lt_html.
    APPEND `    </script>` TO lt_html.
    APPEND `</body>` TO lt_html.
    APPEND `</html>` TO lt_html.

    DATA(lv_html) = concat_lines_of( table = lt_html sep = cl_abap_char_utilities=>newline ).
    server->response->set_cdata( lv_html ).
  ENDMETHOD.
ENDCLASS.
