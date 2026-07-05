const fs = require('fs');

(async () => {
    // 1. Read input payload from stdin
    let inputPayload = {};
    try {
        const raw = fs.readFileSync(0, 'utf-8');
        if (raw) {
            inputPayload = JSON.parse(raw);
        }
    } catch (e) {
        // Fallback to empty if stdin is empty or unparsable
    }

    const requtext = inputPayload.text || "Hello from Antigravity!";
    const bridgeUrl = process.env.SAP_BRIDGE_URL;
    const token = process.env.SAP_BRIDGE_TOKEN;

    if (!bridgeUrl || !token) {
        console.error(JSON.stringify({ isError: true, message: "Missing active session tokens from bridge." }));
        process.exit(1);
    }

    try {
        // 2. Dispatch call to loopback guarded RPC endpoint
        const response = await fetch(`${bridgeUrl}/api/guarded/rpc`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${token}`
            },
            body: JSON.stringify({
                rpc_tool: 'sap_execute_rfc',
                required_permissions: [
                    { "object_name": "STFC_CONNECTION", "object_type": "FUNC", "package": "SRFC" }
                ],
                payload: {
                    tool: 'sap_execute_rfc',
                    payload: {
                        requtext: requtext
                    }
                }
            })
        });

        if (!response.ok) {
            const errBody = await response.text();
            throw new Error(`HTTP ${response.status}: ${errBody}`);
        }

        const data = await response.json();
        console.log(JSON.stringify(data)); // output result to stdout
    } catch (e) {
        console.error(JSON.stringify({ isError: true, message: e.message }));
        process.exit(1);
    }
})();
