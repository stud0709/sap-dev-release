# SAP-Bridge Hook Development Guide

This document is the authoritative specification for developers and autonomous agents to build, configure, and integrate custom aspect hooks within the `sap-bridge` ecosystem.

---

## 1. What is an "Aspect"?

An **Aspect** is a specific metadata perspective, sub-component, or textual representation of an SAP development object that is retrieved, edited, and deployed independently of the core object source code.

Instead of downloading a massive, complex monolithic object structure, aspects allow agents to interact with cleanly scoped subsets of data:
*   **Examples of Aspects**:
    *   `descriptions`: Short text descriptions for all function modules in a Function Group (`FUGR`).
    *   `translations`: Localized language text keys for elements of a Message Class (`MSAG`).
    *   `source`: The primary executable code or script content of the object.
    *   `metadata`: The administrative and configuration properties of the object.
*   **Showcase / Reference Hook**:
    *   Our working showcase is the **`fugr-descriptions`** hook, which handles module descriptions for Function Groups.
    *   It is available in the GitHub repository [stud0709/sap-dev-release](https://github.com/stud0709/sap-dev-release) under the [./hooks](https://github.com/stud0709/sap-dev-release/tree/main/hooks) folder.

---

## 2. Directory Layout Specifications

Aspect hooks reside directly under the `hooks/` folder at the root of the workspace directory. Maintain this structure exactly for the bridge daemon to discover them:

> [!TIP]
> The hooks folder location is fully configurable via the `hooks_directory` workspace setting, which can be modified directly under the Extensibility tab of the Web Dashboard.

```text
hooks/<hook-package-name>/
├── sap-dev-plugin.json   # JSON Descriptor containing hook metadata
├── fetch.py              # Script executed during sap_fetch (aspect extraction)
├── push.py               # Script executed during sap_push (aspect deployment)
└── .sap-dev.sig          # Cryptographic signature file (managed by daemon)
```

> [!NOTE]
> Scripts can be written in any scripting language (Python, Node.js, PowerShell, Bash). The daemon determines how to run them based on the file extension and the configured plugin interpreters in SQLite.

---

## 3. Descriptor JSON Schema

Every hook package must contain a `sap-dev-plugin.json` file defining its matching filters:

### Type Definition (TypeScript)
```typescript
interface HookDescriptor {
  name: string;             // Human-readable title of the hook package
  description: string;      // Description of the hook's capabilities
  can_handle: string[];     // List of target SAP object types (e.g., ["FUGR", "MSAG"])
  aspects: string[];        // List of custom aspect names (e.g., ["descriptions"])
}
```

### Example Descriptor
```json
{
  "name": "fugr-descriptions",
  "description": "Function Group Module Descriptions Hook",
  "can_handle": ["FUGR"],
  "aspects": ["descriptions"]
}
```

---

## 4. Script Execution Contracts

Hooks communicate strictly via `stdin` (for input parameters) and `stdout` (for JSON output results).

### Fetch Script Contract (`fetch` action)

#### Input (Received on `stdin` as JSON)
```json
{
  "object_name": "Z_MY_OBJECT",
  "object_type": "FUGR",
  "aspect": "descriptions",
  "active_dashboard_url": "http://127.0.0.1:56871",
  "execution_token": "...",
  "workspace_dir": "c:\\Users\\..."
}
```

#### Output (Expected on `stdout` as JSON)
```json
{
  "success": true,
  "content": "staged text content (e.g. JSON string, source, or XML)",
  "error_message": "Optional error string if success is false"
}
```

---

### Push Script Contract (`push` action)

#### Input (Received on `stdin` as JSON)
```json
{
  "object_name": "Z_MY_OBJECT",
  "object_type": "FUGR",
  "aspect": "descriptions",
  "content": "edited content from staged file",
  "transport_request": "S4HK900123",
  "active_dashboard_url": "http://127.0.0.1:56871",
  "execution_token": "...",
  "workspace_dir": "c:\\Users\\..."
}
```

#### Output (Expected on `stdout` as JSON)
```json
{
  "success": true,
  "version_signature": "etag_or_hash_returned_by_backend",
  "error_message": "Optional error string if success is false"
}
```

---

## 5. Hook Events & Lifecycle

The bridge daemon invokes hooks at specific lifecycle intervals during fetch and push operations. The hook script or package directory is named after the target event:

| Event Name | Invocation Point / Trigger | Expected Behavior / Purpose |
| :--- | :--- | :--- |
| `fetch` | Standard `sap_fetch` (aspect extraction) | Intercept fetch to return staged file content. |
| `push` | Standard `sap_push` (aspect deployment) | Intercept push to deploy edited files to SAP. |
| `pre_fetch` | Before daemon fetches raw object from SAP | Perform pre-fetch tasks (e.g. status checks, environment preparation). |
| `post_fetch` | After daemon successfully fetches raw object | Modify, format, or process fetched data before storing it. |
| `check_permission` | Before write operations start | Execute custom backend security or authorization rules. |
| `pre_push` | Before data is sent to the SAP backend | Validate, lint, or run static checks (e.g., abaplint). |
| `custom_transport` | During transport request selection | Resolve or generate transport request numbers dynamically. |
| `resolve-object` | Inside Object Guard evaluation | Rewrite/map custom sub-objects to their parent container objects. |

---

## 6. Sequential Step Chaining (Script Pipelines)

If your hook requires multiple steps (e.g., linting, then static validation, then pre-push compilation), you can organize it as a **script pipeline chain** instead of a single script:

1.  **Chaining Directory Structure**:
    Instead of creating a file named `<event_name>.<ext>` (like `pre_push.py`), create a **directory** named after the event:
    ```text
    hooks/my-hook-package/
    └── pre_push/
        ├── 01_lint.py
        └── 02_check_style.js
    ```
2.  **Sequential Execution**:
    The daemon automatically scans all files in the subdirectory, sorts them alphanumerically, and executes them in sequence.
3.  **Pipeline Data Flow**:
    ```mermaid
    graph LR
        input["Initial Input JSON"] --> s1["01_lint.py"]
        s1 -->|"stdout"| pipe["(Piped in memory)"]
        pipe -->|"stdin"| s2["02_check_style.js"]
        s2 --> output["Final Output JSON"]
    ```
    The final script in the chain must print the expected JSON result block matching the execution contract.

---

## 7. Execution Environment & Loopback APIs

Aspect Hooks run as background child processes under the bridge daemon and communicate via standard loopback HTTP endpoints.

For details on the injected environment variables, loopback API endpoints (`/api/guarded/rpc`, `/api/guarded/request`, `/api/guarded/sql`), and the HMAC-SHA256 signature verification mechanism, please refer to the high-level **[Extensibility Portal](./EXTENSIBILITY.md)**.


---

## 8. Reference Hook Implementation (Python)

Below is a standard template for writing a Python push hook:

```python
#!/usr/bin/env python3
import sys
import json
import urllib.request

def log(msg):
    sys.stderr.write(f"[MY-HOOK-PUSH] {msg}\n")
    sys.stderr.flush()

def main():
    # 1. Parse stdin
    try:
        input_data = json.load(sys.stdin)
    except Exception as e:
        print(json.dumps({"success": False, "error_message": f"Parse error: {str(e)}"}))
        return

    obj_name = input_data.get("object_name", "").upper()
    dashboard_url = input_data.get("active_dashboard_url")
    token = input_data.get("execution_token")
    content = input_data.get("content", "")
    transport = input_data.get("transport_request", "")

    # 2. Invoke backend custom RPC
    loopback_url = f"{dashboard_url.rstrip('/')}/api/guarded/rpc"
    req_body = json.dumps({
        "rpc_tool": "save_custom_aspect",
        "payload": {
            "object_name": obj_name,
            "content": content,
            "transport": transport
        }
    }).encode("utf-8")

    req = urllib.request.Request(
        loopback_url,
        data=req_body,
        headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"},
        method="POST"
    )

    try:
        with urllib.request.urlopen(req) as resp:
            resp_data = json.loads(resp.read().decode("utf-8"))
    except Exception as e:
        print(json.dumps({"success": False, "error_message": f"Network error: {str(e)}"}))
        return

    # 3. Handle response
    success = resp_data.get("success") or resp_data.get("SUCCESS")
    if success in (True, "X", "x", "true"):
        print(json.dumps({
            "success": True,
            "version_signature": "CUSTOM_ETAG"
        }))
    else:
        err = resp_data.get("error_message") or "Operation failed"
        print(json.dumps({"success": False, "error_message": err}))

if __name__ == "__main__":
    main()
```

---

## 9. Security & Activation Controls

To activate your hook package, sign it, or enable Developer Mode, please follow the guidelines in the high-level **[Extensibility Portal](./EXTENSIBILITY.md)**.
