<!-- AUTO-GENERATED FILE - DO NOT EDIT MANUALLY. Source: agents-docs/skill-source/templates -->

# SAP-Bridge Extensibility & Customization Portal

The `sap-dev` AI Skill can be dynamically extended to handle new backend object types, custom aspect extractions, or automated routines. This guide serves as the high-level entry point for extensibility options in the `sap-bridge` daemon.

---

## 1. Extensibility Paradigms: Plugins vs. Hooks

The daemon supports two different paradigms for executing custom code, depending on whether you want to trigger the action explicitly or hook into standard workflows:

| Paradigm | On-Demand Plugins | Aspect Hooks |
| :--- | :--- | :--- |
| **Trigger** | Explicit agent execution via `sap_execute_plugin` | Implicit intercept during `sap_fetch` or `sap_push` |
| **Primary Purpose** | Run custom, on-demand scripts or automations with secure SAP backend access | Customize how specific object types and aspects are fetched/pushed |
| **Directory** | `.agents/skills/<plugin-id>/` | `hooks/<hook-id>/` |
| **Inputs** | Stdin payload, environment variables | Stdin JSON containing workspace metadata and active credentials |
| **Guide** | 👉 **[Plugin Development Guide](./PLUGIN_GUIDE.md)** | 👉 **[Hook Development Guide](./HOOK_GUIDE.md)** |

> [!NOTE]
> The default target paths (`.agents/skills/` and `hooks/`) are fully customizable in your workspace via the `plugin_directory` and `hooks_directory` settings. These can be adjusted under the Extensibility settings in the Web Dashboard.

---

## 2. Injected Environment Variables

Both plugins and hooks are executed as child processes with the following environment variables injected by the daemon:

```typescript
interface ScriptEnvironment {
  SAP_BRIDGE_URL: string;       // Base URL of the bridge server (e.g., http://127.0.0.1:62144)
  SAP_BRIDGE_TOKEN: string;     // Short-lived Bearer token authorizing loopback requests
  SAP_SYSTEM_ID: string;        // Target SAP system ID (e.g., NPL)
  SAP_WORKSPACE_DIR: string;    // Absolute path of the active workspace directory
}
```

---

## 3. Guarded Loopback APIs

To securely interact with the SAP backend, custom scripts send HTTP requests back to the local daemon using `SAP_BRIDGE_URL` and `SAP_BRIDGE_TOKEN`. Every loopback HTTP request must include the header:
* `Authorization: Bearer <SAP_BRIDGE_TOKEN>`

### Endpoint 1: `POST /api/guarded/rpc`
Executes an registered MCP tool in the context of the active SAP system.
```typescript
interface GuardedRPCRequest {
  rpc_tool: string;             // Target MCP tool to run (e.g., "sap_execute_rfc")
  payload: {
    tool: string;               // Must match rpc_tool
    payload: Record<string, any>; // Arguments passed to the target MCP tool
  };
  required_permissions?: Array<{ // Optional permissions whitelisting list
    object_name: string;
    object_type: string;
    package: string;
  }>;
}
```

### Endpoint 2: `POST /api/guarded/request`
Performs a direct HTTP or OData request to the SAP backend.
```typescript
interface GuardedHTTPRequest {
  method: "GET" | "POST" | "PUT" | "DELETE";
  uri: string;                  // Target endpoint URI path (e.g., /sap/bc/adt/...)
  body?: string;                // Raw request body
  headers?: Record<string, string>; // Custom request headers
  required_permissions?: Array<{
    object_name: string;
    object_type: string;
    package: string;
  }>;
  bypass_api_guard?: boolean;   // Set to true to bypass standard URL API Guard checks
}
```

### Endpoint 3: `POST /api/guarded/sql`
Performs a direct OpenSQL query against the SAP database.
```typescript
interface GuardedSQLRequest {
  anchor_table: string;         // Baseline database table to resolve schema/context
  query: string;                // OpenSQL query statement
}
```

### Endpoint 4: `GET /api/guarded/settings` and `POST /api/guarded/settings`
Retrieves or updates the workspace settings map stored in the encrypted credentials vault (`.sap_credentials.json`).

#### GET Request
Retrieves the decrypted in-memory workspace settings.
* **Headers**: `Authorization: Bearer <SAP_BRIDGE_TOKEN>`
* **Response**: A JSON map of active settings (returns `{}` if empty).

#### POST/PUT Request
Encrypts and saves the settings payload on disk.
* **Headers**: `Authorization: Bearer <SAP_BRIDGE_TOKEN>`, `Content-Type: application/json`
* **Request Body**: A JSON map of settings (e.g., `{"me_sap_cookies": {...}}`).
* **Response**: `{"status": "saved"}` (HTTP 200).
* **Requires**: Master credentials vault must be unlocked via the Web Dashboard.

---

## 4. Security & Cryptographic Validation

To prevent unauthorized file alterations or malicious script modifications from running against your SAP backend, `sap-bridge` enforces a cryptographic signature check:

1.  **HMAC-SHA256 Signatures**: In production, every extension folder must be signed. The daemon calculates a folder checksum and writes a `.sap-dev.sig` file signed with your workspace vault's unique, encrypted signing key.
2.  **Developer Mode**: During development, you can toggle Developer Mode on for specific plugins or hook packages via the **Extensibility** tab on the Web Dashboard. This temporarily bypasses signature validation while you write and test your scripts.

---

## 5. Developer Tooling: Extensibility SDK

To reduce boilerplate code and ensure autonomous agents build stable, compliant extensions, the `sap-dev` skill packages a zero-dependency **Extensibility SDK** within the references folder:
*   👉 **[sap-dev-sdk.js](./sap-dev-sdk.js)**: The JavaScript helper module.
*   👉 **[sap-dev-sdk.d.ts](./sap-dev-sdk.d.ts)**: TypeScript declaration file containing all type definitions.

### How to Use the SDK in JavaScript:
```javascript
const sdk = require('./sap-dev-sdk');

async function run() {
    // 1. Read stdin input passed by the daemon
    const input = await sdk.parseInput();
    const text = input.text || "Hello World";

    try {
        // 2. Call standard loopback RPC tools
        const result = await sdk.callRpc('sap_execute_rfc', {
            requtext: text
        }, [
            { object_name: 'STFC_CONNECTION', object_type: 'FUNC', package: 'SRFC' }
        ]);

        // 3. Complete successfully and return JSON output to the daemon
        sdk.success(result);

    } catch (err) {
        // 4. Terminate process with error logging and code 1
        sdk.fail(`Failed to execute loopback RPC: ${err.message}`);
    }
}

run();
```

