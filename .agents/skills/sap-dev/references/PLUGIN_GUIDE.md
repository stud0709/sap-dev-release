# SAP-Bridge Plugin Development Guide

This document is the authoritative specification for developers and autonomous agents to build, configure, and execute custom plugins (On-Demand Plugins) within the `sap-bridge` ecosystem.

---

## 1. What is an "On-Demand Plugin"?

Standalone On-Demand Plugins are separate executable scripts (Node.js, Python, PowerShell, Bash) triggered explicitly by an agent or CLI to run custom diagnostics, validation routines, or batch integrations.

Unlike event-driven aspect hooks, plugins do not intercept standard ADT pipeline fetches/pushes. Instead, they are executed on-demand and perform targeted tasks.

* **Showcase / Reference Plugin**:
  * Our working showcase is the **`sap-echo`** plugin, which performs standard RFC connection tests.
  * It is available in the GitHub repository [stud0709/sap-dev-release](https://github.com/stud0709/sap-dev-release) under the [./sap-echo](https://github.com/stud0709/sap-dev-release/tree/main/sap-echo) folder (local layout: `.agents/skills/sap-echo/`).

---

## 2. Directory Layout Specifications

On-Demand Plugins reside under the `.agents/skills/` folder at the root of the workspace directory. Maintain this structure exactly for the bridge daemon to discover them:

> [!TIP]
> The plugins folder location is fully configurable via the `plugin_directory` workspace setting, which can be modified directly under the Extensibility tab of the Web Dashboard.

```text
.agents/skills/<plugin-id>/
├── sap-dev-plugin.json   # JSON Descriptor containing plugin metadata
├── SKILL.md              # Instruction manual describing usage parameters
├── <script-file>         # Executable script (e.g., .js, .py, .ps1, .sh)
└── .sap-dev.sig          # Cryptographic signature file (managed by daemon)
```

> [!NOTE]
> Scripts can be written in any scripting language. The daemon determines how to run them based on the file extension and the configured interpreters.

---

## 3. Descriptor JSON Schema

Every plugin package must contain a `sap-dev-plugin.json` file defining its metadata:

### Type Definition (TypeScript)
```typescript
interface PluginDescriptor {
  name: string;             // Human-readable title of the plugin
  description: string;      // Description of the plugin's capabilities and usage triggers
}
```

### Example Descriptor
```json
{
  "name": "sap-echo",
  "description": "SAP Echo RFC Connection Test Plugin"
}
```

---

## 4. Script Execution Contract

On-Demand Plugins communicate strictly via `stdin` (for input parameters), environment variables, and `stdout` (for output results).

### Input
* **Environment Variables**: Dynamically injected by the daemon (see the high-level portal).
* **Stdin Payload**: Receives a JSON payload string containing execution arguments passed via the `payload` parameter of `sap_execute_plugin`.

### Output (Expected on `stdout` as JSON)
The script must output a valid JSON string representing its execution results, and exit with code `0`. Any execution errors should be written to `stderr` or formatted inside the JSON output with a non-zero exit code.

---

## 5. Execution Environment & Loopback APIs

On-Demand Plugins run as child processes under the bridge daemon and communicate via standard loopback HTTP endpoints.

For details on the injected environment variables, loopback API endpoints (`/api/guarded/rpc`, `/api/guarded/request`, `/api/guarded/sql`), and the HMAC-SHA256 signature verification mechanism, please refer to the high-level **[Extensibility Portal](./EXTENSIBILITY.md)**.

---

## 6. Reference Plugin Implementation (Node.js)

Below is a complete, production-grade script (`echo_call.js`) that illustrates reading input from `stdin`, performing a loopback request, declaring required permissions, and handling errors:

```javascript
const fs = require('fs');

async function run() {
    // 1. Resolve environment variables
    const bridgeUrl = process.env.SAP_BRIDGE_URL;
    const token = process.env.SAP_BRIDGE_TOKEN;
    const workspaceDir = process.env.SAP_WORKSPACE_DIR;
    const systemID = process.env.SAP_SYSTEM_ID;

    if (!bridgeUrl || !token || !workspaceDir || !systemID) {
        console.error(JSON.stringify({
            isError: true,
            message: "Missing active session tokens from bridge environment."
        }));
        process.exit(1);
    }

    // 2. Read stdin payload (JSON)
    let payloadStr = "";
    try {
        payloadStr = fs.readFileSync(0, 'utf-8');
    } catch (e) {
        // Fall back if stdin is empty
        payloadStr = "{}";
    }

    let payload = {};
    if (payloadStr.trim()) {
        try {
            payload = JSON.parse(payloadStr);
        } catch (e) {
            console.error(JSON.stringify({
                isError: true,
                message: "Failed to parse JSON payload from stdin: " + e.message
            }));
            process.exit(1);
        }
    }

    const requtext = payload.text || "Default test string";

    // 3. Dispatch loopback request
    try {
        const response = await fetch(`${bridgeUrl}/api/guarded/rpc`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${token}`
            },
            body: JSON.stringify({
                rpc_tool: 'sap_execute_rfc',
                required_permissions: [
                    { object_name: 'STFC_CONNECTION', object_type: 'FUNC', package: 'SRFC' }
                ],
                payload: {
                    tool: 'sap_execute_rfc',
                    payload: {
                        requtext: requtext
                    }
                }
            })
        });

        // 4. Handle HTTP responses
        if (!response.ok) {
            const errBody = await response.text();
            
            // Check for Object Guard authorization blocks
            if (response.status === 403) {
                console.error(JSON.stringify({
                    isError: true,
                    status: 403,
                    message: "Execution blocked by Object Guard. Please approve STFC_CONNECTION on the dashboard."
                }));
                process.exit(1);
            }
            
            throw new Error(`HTTP ${response.status}: ${errBody}`);
        }

        const data = await response.json();
        
        // Output successful result to stdout
        console.log(JSON.stringify(data));
        process.exit(0);

    } catch (error) {
        console.error(JSON.stringify({
            isError: true,
            message: error.message
        }));
        process.exit(1);
    }
}

run();
```

---

## 7. Backend Integration (ABAP Extensions)

To handle custom logic or execute RFCs directly inside the SAP ABAP backend, redefine the standard ADT HTTP handler extension `ZCL_SAP_DEV_RPC_EXT`:

### ABAP Redefinition Implementation
```abap
  METHOD if_http_extension~handle_request.
    DATA: lv_body TYPE string.
    lv_body = server->request->get_cdata( ).

    TYPES: BEGIN OF ty_req,
             tool TYPE string,
           END OF ty_req.
    DATA: ls_req TYPE ty_req.

    " Deserialize request to inspect the tool name
    /ui2/cl_json=>deserialize( EXPORTING json = lv_body CHANGING data = ls_req ).

    IF ls_req-tool = 'sap_execute_rfc'.
      " Parse RFC payload details using precise type matching
      TYPES: BEGIN OF ty_rfc_payload,
               requtext TYPE sy-lisel, " Target formal type (CHAR 255)
             END OF ty_rfc_payload.
      TYPES: BEGIN OF ty_rfc_req,
               payload TYPE ty_rfc_payload,
             END OF ty_rfc_req.
      DATA: ls_rfc_req TYPE ty_rfc_req.

      /ui2/cl_json=>deserialize( EXPORTING json = lv_body CHANGING data = ls_rfc_req ).

      DATA: lv_echotext TYPE sy-lisel,
            lv_resptext TYPE sy-lisel.

      " Invoke target Function Module
      CALL FUNCTION 'STFC_CONNECTION'
        EXPORTING
          requtext = ls_rfc_req-payload-requtext
        IMPORTING
          echotext = lv_echotext
          resptext = lv_resptext.

      " Format output matching JavaScript expected schema
      TYPES: BEGIN OF ty_response,
               echotext TYPE string,
               resptext TYPE string,
             END OF ty_response.
      DATA: ls_resp TYPE ty_response.
      ls_resp-echotext = lv_echotext.
      ls_resp-resptext = lv_resptext.

      DATA(lv_json_out) = /ui2/cl_json=>serialize( data = ls_resp ).

      server->response->set_status( code = 200 reason = 'OK' ).
      server->response->set_content_type( 'application/json' ).
      server->response->set_cdata( lv_json_out ).
      RETURN.
    ELSE.
      " Forward standard ADT requests to the parent class handler
      super->if_http_extension~handle_request( server ).
    ENDIF.
  ENDMETHOD.
```

---

## 8. Troubleshooting and Error Recovery

Analyze response payloads and exit codes to classify issues:

### 1. HTTP 403 Forbidden
* **Cause:** The request's `required_permissions` array contains an object that has not been whitelisted by the user.
* **Resolution:** Report the blocked object to the user and prompt them to click **Approve** in the Object Guard tab of the Web Dashboard.

### 2. HTTP 400 Session Timed Out
* **Cause:** The underlying ADT session in SAP expired.
* **Resolution:** The daemon implements automatic self-healing. Retrying the request immediately will prompt the daemon to establish a fresh stateful session automatically.

### 3. HTTP 500 Backend / RPC Error
* **Cause:** Typically caused by an ABAP runtime dump (e.g. type conflict or program error) or an invalid RPC tool name.
* **Resolution:** Query the `sap_fetch_runtime_errors` tool to examine `ST22` dump details, inspect variable types, and verify parameter alignments.

---

## 9. Security & Activation Controls

To activate your plugin package, sign it, or enable Developer Mode, please follow the guidelines in the high-level **[Extensibility Portal](./EXTENSIBILITY.md)**.
