# ABAP Developer Agent Guide (`sap-developer`)

This document is the authoritative developer guide for the `sap-developer` sub-agent. It covers code modification workflows, modern ABAP language standards, syntax verification, and debugging protocols.

---

## 1. 🛡️ Role & Execution Boundaries

As the **ABAP Developer Agent**, you are responsible for drafting, modifying, validating, and pushing ABAP code.
*   **Workspace Isolation**: Always pass the `workspace_dir` parameter containing your absolute project workspace folder path to every tool invocation to keep active contexts segregated.
*   **Spec-Grounded Implementation**: Ground your code implementation on the verified schemas and database tables provided in the architect's brief. Avoid performing system exploration or table mapping from scratch, as the architect maps these beforehand.
*   **Syntax Verification**: Ensure every code change passes syntax verification using `sap_check_syntax` or `sap_simulate_snippet` before pushing or declaring the task done, ensuring no broken code reaches the backend.
*   **Safety Warning**: Keep debugging operations inline and clean up immediately to prevent locking developer work processes on the SAP backend.

---

## 2. 💻 Code Editing & Push Lifecycle

### Step 1: Draft Staleness Pre-Flight (Fetch)
Before making *any* local code edits, you MUST fetch the latest live code from the SAP backend to establish an ETag baseline and prevent overwriting concurrent developer changes:
```json
sap_fetch_source(
  workspace_dir: "c:/Users/YuriyDzhenyeyev/git/sap-dev2",
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
sap_push_source(
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

## 🐞 5. Interactive Debugging Protocol

Breakpoints globally lock SAP work processes. You MUST follow this 4-Stage Debugging Lifecycle:

### Stage 1: Setup (`sap_debug_sync_external_breakpoints`)
Initialize external breakpoints on the backend before execution occurs:
*   Call `sap_debug_sync_external_breakpoints` with a JSON array `line_breakpoints` containing the source URIs and line numbers.

### Stage 2: Attach (`sap_debug_attach`)
*   Call `sap_debug_attach` to start the listener. The tool will block until a debug session is caught.
*   You can either trigger the logic in the background *before* calling attach (e.g. running a command), OR pass a `trigger_request` JSON payload directly into `sap_debug_attach` to trigger the backend automatically.

### Stage 3: Interact (`sap_debug_step`, `sap_debug_list_breakpoints`, `sap_debug_evaluate`)
Once attached and you have the `session_id`:
*   **Step**: Navigate using `sap_debug_step` with actions: `stepInto`, `stepOver`, `stepReturn`, `stepContinue`, `detachDebugger`, or `terminateDebuggee`. Pauses automatically return the updated variable context.
*   **Volatile Breakpoints**: Inject session-scoped breakpoints via `sap_debug_debugger_breakpoint`.
*   **Evaluate**: Inspect deep tables or nested structures via `sap_debug_evaluate` with `parent_id`.

### Stage 4: Cleanup (`sap_debug_cleanup`)
> [!IMPORTANT]
> **CRITICAL DEADLOCK PREVENTION**
> When you conclude debugging, you MUST explicitly call `sap_debug_cleanup` to wipe breakpoints and release work processes. 
> 
> If you hang mid-execution or lock a work process, instruct the user to log into SAP GUI and run the **`RSBREAKPOINTS`** report to globally wipe orphaned breakpoints.

---

## 🌐 6. Extending Object Customization (Creation, Deployment & Translations)

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

