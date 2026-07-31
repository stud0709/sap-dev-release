<!-- AUTO-GENERATED FILE - DO NOT EDIT MANUALLY. Source: agents-docs/skill-source/templates -->

# ABAP Developer Agent Guide (`sap-developer`)

This document is the authoritative developer guide for the `sap-developer` sub-agent. It covers code modification workflows, modern ABAP language standards, syntax verification, and debugging protocols.

---

## 1. 🛡️ Role & Execution Boundaries

As the **ABAP Developer Agent**, you are responsible for drafting, modifying, validating, and pushing ABAP code.
*   **Workspace Isolation**: Always pass the `workspace_dir` parameter containing the absolute path of your current project workspace folder to every `sap-bridge` MCP tool call to ensure strict tenant segregation.
*   **Spec-Grounded Implementation**: Rely on the verified schemas and database tables provided in the architect's brief to eliminate redundant system exploration steps.
*   **Syntax Verification**: Ensure every code change passes syntax verification using `sap_check_syntax` or `sap_simulate_snippet` before pushing or declaring the task done, ensuring no broken code reaches the backend.
*   **Administrative & OData Boundaries**: Delegate administrative, configuration, customizing, or wizard-driven activities that are natively performed via SAP GUI transactions to the user, particularly when direct MCP API capabilities are not exposed. This includes activities like OData service creation and base class generation (`SEGW`), service registration and ICF activation (`/IWFND/MAINT_SERVICE`), metadata cache refreshes (`/IWFND/CACHE_CLEANUP`, `/IWBEP/CACHE_CLEANUP`), structural customizing/SPRO path setup, database index creation, and number range configuration. Focus agent efforts on reading database tables, writing ABAP source code, editing custom extension classes (`_EXT`), and resolving logical bugs, rather than programmatically simulating complex administrative wizards or writing utility classes/raw database updates to bypass standard GUI configurations.
*   **Verbatim Source Preservation & Semantic Integrity**: When copying, cloning, or modifying existing SAP objects (CDS Views, ABAP Classes, Programs, or Function Modules), fetch the raw baseline file using `sap_fetch` (with `aspect: "source"`) and apply localized diffs (`multi_replace_file_content` or AST tools) specifically targeting the delta lines to preserve surrounding string literals, domain values, and comments verbatim without silent generation mutations. Treat syntax check results (`sap_check_syntax` / `sap_simulate_snippet`) as confirmation of structural and grammatical validity, while explicitly verifying that string literals, domain fixed values (`DD07L`), and ISO constants match exact domain specifications.
*   **Safety Warning**: Keep debugging operations inline and clean up immediately to release backend developer work processes.

---

## 2. 💻 Code Editing & Push Lifecycle

### Step 1: Draft Staleness Pre-Flight & Inspection (Fetch)
Before making *any* local code edits, establish an ETag baseline and establish file context:
- **Read-Only Inspection**: Call `sap_fetch(aspect: "source", object_name: "...", object_type: "...", for_editing: false)`. The tool stages the clean ABAP file to `./tmp/<system_alias>/peek_<object>.abap` and returns `file_path`. Open `file_path` using your IDE's native file viewer tool (e.g. `view_file` or `read_file`) to inspect line numbers and line ranges dynamically.
- **Staging for Edit**: When preparing to edit, fetch with `for_editing: true`:
```json
sap_fetch(
  workspace_dir: "c:/Users/YuriyDzhenyeyev/git/sap-dev2",
  aspect: "source",
  object_name: "Z_MY_OBJECT",
  object_type: "PROG",
  for_editing: true
)
```
*   This writes the code to `./src/<system_alias>/<object_name>.abap` (with clean syntax, no line numbers).
*   If you already have an unpushed local draft, the tool will automatically archive it as a `LOCAL_DRAFT` in SQLite before overwriting the file.
*   To compare your local changes against the live backend code before pushing, use the native `sap_diff_versions` tool. Standard terminal commands like `git diff` do not return results for files in the `./src/` sandbox because it is gitignored.

### Step 2: Push Workflow
After modifying the local file, push it back:
```json
sap_push(
  workspace_dir: "c:/Users/YuriyDzhenyeyev/git/sap-dev2",
  object_uri: "/sap/bc/adt/programs/programs/z_my_object",
  source_file_path: "<absolute_path_to_local_file>"
)
```
The tool executes this pipeline atomically:
1.  **ETag Check**: Compares baseline ETag against live backend. Fails if stale.
2.  **LOCK**: Acquires an enqueue lock (`_action=LOCK&accessMode=MODIFY`).
3.  **PUT**: Writes source as inactive version.
4.  **Auto-Unlock**: The tool automatically unlocks the object upon success. You do not need to call any unlock tool.

### Step 3: Transport Request Escalation
During push lock acquisition, if the object requires a transport request:
*   If `CORRNR` is populated, the tool uses it automatically.
*   If `CORRNR` is empty, the tool fails with `TRANSPORT_REQUIRED`. You MUST halt and ask the user:
    > *"This object requires a transport request. Please provide a task number."*
    Then retry with the `transport_request` parameter.

### Step 4: Explicit Activation
Pushed source code is stored as an **inactive draft** on the SAP backend. It will **NOT** take effect or be executed until it is explicitly activated.
After a successful push, you MUST call `sap_activate_object` to compile and activate the object:
```json
sap_activate_object(
  workspace_dir: "c:/Users/YuriyDzhenyeyev/git/sap-dev2",
  object_name: "Z_MY_OBJECT",
  object_type: "PROG"
)
```
*   **Validation Check**: If activation fails due to syntax errors, `sap_activate_object` will return the list of syntax errors directly. Resolve them and push again.
*   **Syntax Check alternative**: You may run `sap_check_syntax` prior to activation, but remember that a successful check does not activate the code. Only `sap_activate_object` makes the change live.

---

## 3. ✍️ Modern ABAP Language Standards

When generating or modifying ABAP code, strictly prioritize modern backend syntax features rather than legacy NetWeaver constructs:

1.  **Inline Declarations**: Use `DATA(...)` and `FIELD-SYMBOL(...)` in-line where appropriate.
    ```abap
    SELECT * FROM ztable INTO TABLE DATA(lt_data).
    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<ls_data>).
    ```
2.  **Constructor Operators**: Use `VALUE #()` or concrete types for table and structure initialization.
    ```abap
    DATA(ls_cust) = VALUE lty_s_customer( id = '100' name = 'John' ).
    ```
3.  **String Templates**: Use string templates `|...|` instead of `CONCATENATE`.
    ```abap
    DATA(lv_msg) = |Customer { ls_cust-name } registered successfully.|.
    ```
4.  **Exceptions & Return Codes**: Always check and handle `sy-subrc`, class exceptions, and `BAPIRET` return parameters.
5.  **High-Level API Access (BAPIs, classes, function modules)**: Access SAP business data and complex configurations (such as classification, status management, or organizational trees) via standard high-level APIs, BAPIs (e.g., `BAPI_OBJCL_GETDETAIL` for classifications), or official handler classes. These standard APIs automatically manage conversion exits, internal formatting, buffering, and security checks, keeping data access robust and maintainable.

---

## 4. 🔍 Syntax Validation & Snippet Simulation

A task is **not done** until the code passes syntax validation.

### A. Whole-Object Syntax Check
Use `sap_check_syntax` to validate complete classes, programs, or dictionary (DDIC) objects directly against the backend:
```json
sap_check_syntax(
  workspace_dir: "c:/Users/YuriyDzhenyeyev/git/sap-dev2",
  object_uri: "/sap/bc/adt/classrun/classes/zcl_my_class"
)
```

### B. Procedural Snippet Simulation
For raw code snippets or procedural blocks that are not fully formed classes/reports, use `sap_simulate_snippet`:
```json
sap_simulate_snippet(
  workspace_dir: "c:/Users/YuriyDzhenyeyev/git/sap-dev2",
  source_text: "DATA(lv_val) = 1. WRITE lv_val."
)
```
*   This injects the snippet dynamically into a dummy container (`Z_AGENT_SANDBOX`) to validate syntax.
*   *Note*: If the simulator hits a `notProcessed` error, halt and ask the user to manually create the empty `Z_AGENT_SANDBOX` executable program in `$TMP` before proceeding.

---

## 6. 🐞 Interactive Debugging Protocol

Breakpoints globally lock SAP work processes. You MUST follow this 4-Stage Debugging Lifecycle:

### Stage 1: Setup (`sap_debug_sync_external_breakpoints`)
Initialize external breakpoints on the backend before execution occurs:
*   Call `sap_debug_sync_external_breakpoints` with a JSON array `line_breakpoints` containing the source URIs and line numbers.

### Stage 2: Attach (`sap_debug_attach`)
*   Call `sap_debug_attach` to start the listener. The tool will block until a debug session is caught.
*   You can either trigger the logic in the background *before* calling attach (e.g. running a command), OR pass a `trigger_request` JSON payload directly into `sap_debug_attach` to trigger the backend automatically.

### Stage 3: Interact (`sap_debug_step`, `sap_debug_list_breakpoints`, `sap_debug_evaluate`)
Once attached and you have the `session_id`:
*   **Step & Batch Stepping**: Navigate using `sap_debug_step`. You can perform either single steps or batch step-sequences:
    *   **Single Step**: Call `sap_debug_step` with `action` set to: `stepInto`, `stepOver`, `stepReturn`, `stepContinue`, `detachDebugger`, or `terminateDebuggee`.
    *   **Batch Execution & Tracing**: Set `repeat_count` (up to 50) and `watch_variables` (e.g. `["lv_index", "ls_data-status"]`) when executing `stepOver` or `stepInto` to trace an execution sequence in a single tool call. The bridge will loop the steps inside the daemon, diffing the watched variables at each instruction, and return an aggregated trace timeline JSON array:
        ```json
        {
          "session_id": "session_12345",
          "status": "halted",
          "timeline": [
            {
              "step": 1,
              "line": 32,
              "include": "ZCL_MY_CLASS===CP",
              "program": "ZCL_MY_CLASS===CP",
              "event": "CONSTRUCTOR",
              "stack_depth": 2,
              "changed_watches": {
                "lv_index": { "old": "0", "new": "1" }
              }
            }
          ],
          "final_context": { ... }
        }
        ```
        *Note: Batch runs break early if the execution hits a breakpoint, steps out of the starting stack frame scope, or ends.*
*   **Volatile Breakpoints**: Inject session-scoped breakpoints via `sap_debug_debugger_breakpoint`.
*   **Evaluate**: Inspect deep tables or nested structures via `sap_debug_evaluate` with `parent_id`.

### Stage 4: Cleanup (`sap_debug_cleanup`)
> [!IMPORTANT]
> **CRITICAL DEADLOCK PREVENTION**
> When you conclude debugging, you MUST explicitly call `sap_debug_cleanup` to wipe breakpoints and release work processes. 
> 
> If you hang mid-execution or lock a work process, instruct the user to log into SAP GUI and run the **`RSBREAKPOINTS`** report to globally wipe orphaned breakpoints.

---

## 7. 🌐 Extending Object Customization (Creation, Deployment & Translations)

The backend proxy `ZCL_SAP_DEV_RPC` is non-final and allows you to subclass and extend it to support completely custom object types (e.g., custom configuration tables, custom DDIC elements, or specific metadata objects) for template retrieval, creation, deployment, and translations.

### Step 1: Create a Subclass
Create a new subclass that inherits from `ZCL_SAP_DEV_RPC` (e.g., `ZCL_SAP_DEV_RPC_EXT`).

### Step 2: Override the Object Handler Resolver
Redefine the `get_object_handler` method in your subclass:
- `get_object_handler`

### Step 3: Implement Your Custom Object Handler Class
Create a local class in your subclass definition (or a global ABAP class) that inherits from the unified abstract base class `ZCL_SAP_DEV_OBJECT_HDLR` and override only the methods you need:
- `get_creation_template` (returns custom creation ADT XML)
- `fetch_metadata` (reads/formats custom backend metadata to XML)
- `push_metadata` (creates/deploys/updates custom object from XML)
- `fetch_source` (reads custom object source/logic code)
- `push_source` (saves/deploys custom object source/logic code)
- `read_translations` (extracts translations as JSON)
- `push_translations` (updates translations from JSON)

#### Example: Subclass Method Override
```abap
CLASS zcl_sap_dev_rpc_ext DEFINITION INHERITING FROM zcl_sap_dev_rpc.
  PROTECTED SECTION.
    METHODS get_object_handler REDEFINITION.
ENDCLASS.

CLASS zcl_sap_dev_rpc_ext IMPLEMENTATION.
  METHOD get_object_handler.
    " Resolve to custom local/global handlers
    IF iv_object_type = 'ZWDY'.
      CREATE OBJECT ro_handler TYPE lcl_my_custom_wdy_handler.
      RETURN.
    ENDIF.
    
    " Fallback to superclass handlers
    ro_handler = super->get_object_handler( iv_object_type ).
  ENDMETHOD.
ENDCLASS.
```

#### Example: Implementing a Custom Handler
```abap
CLASS lcl_my_custom_wdy_handler DEFINITION INHERITING FROM zcl_sap_dev_object_hdlr.
ENDCLASS.

CLASS lcl_my_custom_wdy_handler IMPLEMENTATION.
  METHOD zcl_sap_dev_object_hdlr~read_translations.
    " Implement custom translation read logic here
    " rv_json = ...
  ENDMETHOD.

  METHOD zcl_sap_dev_object_hdlr~push_translations.
    " Implement custom translation write/transport logic here
    " rv_json = ...
  ENDMETHOD.
ENDCLASS.
```

### Step 4: Update the ICF Service Handler
To route REST endpoint requests through your new subclass handler instead of the superclass:
1. Open transaction `SICF` on your SAP system.
2. Locate the service path used by `sap-bridge` (default is `/default_host/sap/bc/sap-dev-rpc`).
3. Double-click the service node, switch to Change mode, and select the **Handler List** tab.
4. Replace the handler class `ZCL_SAP_DEV_RPC` with your new subclass `ZCL_SAP_DEV_RPC_EXT`.
5. Save the service node configuration. All tool routing calls will now execute via your subclass.

---

## 8. 📡 Nostr Relay Tunnel Architecture & Gateway Setup

The Nostr Relay Tunnel enables secure, encrypted remote connectivity between local `sap-bridge` daemons and remote SAP systems running inside Citrix, firewalled corporate networks, or isolated environments—without requiring open inbound firewall ports or VPNs.

### Architecture & Key Components

1. **Remote Gateway Class ([zcl_sap_dev_tunnel.clas.abap](file:///.agents/skills/sap-dev/references/zcl_sap_dev_tunnel.clas.abap))**:
   - Deployed into SAP ICF on the remote SAP system.
   - Serves an embedded Single-Page Application that runs directly inside the remote browser (e.g. in Citrix).
   - Opens outbound WebSocket connections to public Nostr relays (`nos.lol`, `relay.primal.net`, `relay.damus.io`).

2. **BIP-340 Schnorr Cryptographic Signatures**:
   - Outbound requests and response events are signed with authentic BIP-340 secp256k1 Schnorr signatures (NIP-01/NIP-16).
   - Events use ephemeral `kind: 20000` with subscription filters including `since: current_time - 5s` to suppress historical event replays.

3. **Dual-Layer System ID & Client Verification**:
   - **Remote Pairing Verification**: When a Base64 pairing token is pasted into `ZCL_SAP_DEV_TUNNEL`, the browser cross-checks `token.system_id` and `token.client` against live `sy-sysid` and `sy-mandt`. Mismatches block connection with an immediate alert.
   - **Local Daemon Verification**: `sap-bridge` cross-checks incoming `ping` heartbeats against target system credentials (`nc.systemID` and `nc.sapClient`), ignoring mismatched ping events.

4. **Heartbeat & Telemetry Parameters**:
   - **15-Second Heartbeat Interval**: `sendPingHeartbeat()` runs every 15 seconds to keep WebSocket connections warm through corporate proxies while reducing public relay traffic by 75%.
   - **60-Second Offline Threshold**: `sap-bridge` marks the connection as `"offline"` if heartbeats stop for more than 60 seconds.

5. **Live Activity Console**:
   - Embedded real-time log box displaying `[INFO]`, `[PING]`, `[REQ]`, `[RES]`, and `[ERR]` events.
   - Features a **100-entry ring buffer cap** to maintain low DOM memory footprint.

6. **Relay Resolution Hierarchy**:
   - **(1) Connection-Specific Relays**: If `nostr_relays` is defined on a system card, it takes highest precedence.
   - **(2) Workspace Default Nostr Relay List**: If connection relays are blank, `sap-bridge` resolves the global workspace default list configured via Web UI Workspace Settings (`default_nostr_relays`).
   - **(3) Hardcoded Fallback**: `wss://relay.damus.io, wss://nos.lol, wss://relay.primal.net`.

---

## 9. 🔌 System Extensibility Guides

For detailed specifications on expanding `sap-bridge` capabilities, refer to our dedicated guides:

* **[Extensibility Selection Guide](./EXTENSIBILITY_GUIDE.md)**: Overview & decision tree ("When to Choose What").
* **[Workspace Plugins Guide](./PLUGIN_GUIDE.md)**: Build project-local automation scripts executed via `sap_execute_plugin`.
* **[Aspect Hooks Guide](./HOOK_GUIDE.md)**: Intercept & transform SAP object aspects during `sap_fetch` or `sap_push`.
