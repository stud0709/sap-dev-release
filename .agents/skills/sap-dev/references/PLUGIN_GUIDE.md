<!-- AUTO-GENERATED FILE - DO NOT EDIT MANUALLY. Source: agents-docs/skill-source/templates -->

# Workspace Plugins Guide (`sap_execute_plugin`)

---

## 1. System Integration: How it Works

Unlike built-in MCP tools, plugins execute in their own isolated OS child processes. The `sap-bridge` daemon manages their execution life cycle and exposes secure loopback endpoints that the plugin script can use to call back into the active SAP connection.

### Directory Structure
Plugins live under the `.agents/skills/` directory in your active workspace:
```text
your-workspace/
├── .sap_credentials.json     <-- Secured project vault
└── .agents/
    └── skills/
        └── sap-echo/         <-- Plugin directory
            ├── sap-dev-plugin.json  <-- Metadata & description
            ├── SKILL.md             <-- End-agent execution instructions
            ├── echo_call.js         <-- Script entrypoint
            └── .sap-dev.sig         <-- Cryptographic verification signature
```

### Secured Loopback Mechanism
1. **Runner Invocation:** The AI Agent invokes the plugin script using the `sap_execute_plugin` MCP tool.
2. **Ephemeral Context Injection:** The daemon generates a short-lived execution token (`SAP_BRIDGE_TOKEN`) and injects it (along with the daemon base URL and System ID) into the script's environment.
3. **Loopback Requests:** The script uses standard HTTP calls to query the daemon's loopback endpoints (`/api/guarded/rpc`, `/api/guarded/request`, `/api/guarded/sql`, or `/api/guarded/settings`), authenticating requests using the Bearer token.
4. **Guard Evaluation:** The daemon validates the Bearer token, automatically resolves the associated workspace/system connection context, and enforces security policies (API/Object Guards) before forwarding requests to the SAP backend or vault.

---

## 2. Manifest Schema (`sap-dev-plugin.json`)

```json
{
  "name": "sap-echo",
  "description": "Executes standard RFC STFC_CONNECTION test module.",
  "required_permissions": ["STFC_CONNECTION"]
}
```

---

## 3. Execution via `sap_execute_plugin`

```json
sap_execute_plugin(
  workspace_dir: "<workspace_dir>",
  script_path: ".agents/skills/sap-echo/echo_call.js",
  payload: { "requtext": "Hello SAP" }
)
```
