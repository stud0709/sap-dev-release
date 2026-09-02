<!-- AUTO-GENERATED FILE - DO NOT EDIT MANUALLY. Source: agents-docs/skill-source/templates -->

# ABAP Developer Agent Guide (`sap-developer`)

This document is the authoritative developer guide for the `sap-developer` sub-agent. It covers code modification workflows, modern ABAP language standards, syntax verification, refactoring parity audits, and debugging protocols.

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
  workspace_dir: "<workspace_dir>",
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
After modifying the local file, push it back (optionally providing a `comment` to document the change in the local SQLite version history):
```json
sap_push(
  workspace_dir: "<workspace_dir>",
  object_uri: "/sap/bc/adt/programs/programs/z_my_object",
  source_file_path: "<absolute_path_to_local_file>",
  comment: "Refactored SELECT statement to use inline data declarations"
)
```
The tool executes this pipeline atomically:
1.  **ETag Check**: Compares baseline ETag against live backend. Fails if stale.
2.  **LOCK**: Acquires an enqueue lock (`_action=LOCK&accessMode=MODIFY`).
3.  **PUT**: Writes source as inactive version.
4.  **Auto-Unlock**: The tool automatically unlocks the object upon success. You do not need to call any unlock tool.

### Step 3: Transport Request Governance
During push operations on transportable objects (non-`$TMP`):
*   **Active Backend Lock**: If the object is already locked in a transport request (`CORRNR`), the tool reuses that active lock task automatically.
*   **Object Guard Approved Transport**: If `CORRNR` is empty, the tool retrieves the Transport Request approved by the user in the SAP-Bridge Web UI Object Guard.
*   **Transport Escalation Block**: If no Transport Request is approved and the object is unassigned, the push tool halts immediately with a structured JSON error (`TRANSPORT_REQUIRED`) and logs a pending request in the Object Guard. Autonomous agents MUST NOT query `E070`/`E071` or guess transport tasks. Direct the user to open the Web UI Object Guard tab, select an open Transport Request for this object, and approve it before retrying.

### Step 4: Explicit Activation
Pushed source code is stored as an **inactive draft** on the SAP backend. It will **NOT** take effect or be executed until it is explicitly activated.
After a successful push, you MUST call `sap_activate_object` to compile and activate the object:
```json
sap_activate_object(
  workspace_dir: "<workspace_dir>",
  object_name: "Z_MY_OBJECT",
  object_type: "PROG"
)
```
*   **Validation Check**: If activation fails due to syntax errors, `sap_activate_object` will return the list of syntax errors directly. Resolve them and push again.
*   **Syntax Check alternative**: You may run `sap_check_syntax` prior to activation, but remember that a successful check does not activate the code. Only `sap_activate_object` makes the change live.

### 🖥️ Classic Dynpro & Screen Authoring (`aspect: "dynpro"`)

When developing classic SAP GUI dialogs, custom containers (`CL_GUI_CUSTOM_CONTAINER` / ALV Grids), Table Controls, Tabstrips, or EWM RF subscreens:
- **Local Staging Model**: Stage the screen as twin files in `./src/<system_id>/dynpros/`:
  - `<program>.<dynnr>.flow.abap` (Pure ABAP flow logic: PBO, PAI, POV, POH)
  - `<program>.<dynnr>.screen.json` (Declarative header & element layout schema)
  Existing screens can be fetched for editing via `sap_fetch(aspect: "dynpro", object_name: "<program>:<dynnr>", for_editing: true)`.
- **Reference Templates**: Use `sap_get_creation_template(object_type: "DYNP", object_name: "<prog>:<dynnr>", reference_entity: "<ref_prog>:<ref_dynnr>")` to generate starter layouts based on standard SAP reference screens (e.g. from package `SABAPDEMOS` or `/SCWM/RF_UI`).
- **Push & Creation / Compilation**: Calling `sap_push(aspect: "dynpro", object_name: "<program>:<dynnr>", activate: true)` directly creates or updates the screen definitions and flow logic on the SAP backend, compiles bytecode, and automatically provisions standard GUI status / titlebars in the CUA interface table (`EUDB`).
- **Authoritative Specification & Reference Guide**: For the complete widget type matrix, element attributes, status icons, VRM dropdowns, F4 Search Help DDIC signatures, Table Controls, Tabstrips, Context Menus, and standard SAP reference programs in `SABAPDEMOS` and `SLIS`, consult:
  - **[DYNPRO_AUTHORING_GUIDE.md](references/DYNPRO_AUTHORING_GUIDE.md)**

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
  workspace_dir: "<workspace_dir>",
  object_uri: "/sap/bc/adt/classrun/classes/zcl_my_class"
)
```

### B. Procedural Snippet Simulation
For raw code snippets or procedural blocks that are not fully formed classes/reports, use `sap_simulate_snippet`:
```json
sap_simulate_snippet(
  workspace_dir: "<workspace_dir>",
  source_text: "DATA(lv_val) = 1. WRITE lv_val."
)
```
*   This injects the snippet dynamically into a dummy container (`Z_AGENT_SANDBOX`) to validate syntax.
*   *Note*: If the simulator hits a `notProcessed` error, halt and ask the user to manually create the empty `Z_AGENT_SANDBOX` executable program in `$TMP` before proceeding.

### C. Dynamic Method Execution & ABAP Unit Testing (`sap_execute_ext_method`, `sap_run_tests`)

All dynamic backend code executions are governed by the zero-trust **Execution Guard**:

#### 1. Executing Extension Methods on `ZCL_SAP_DEV_RPC_EXT` (`sap_execute_ext_method`)
To execute a custom exploratory or scratchpad method inside `ZCL_SAP_DEV_RPC_EXT` with structured JSON input/output:
```json
sap_execute_ext_method(
  workspace_dir: "<workspace_dir>",
  method_name: "HELLO_WORLD",
  params: {
    "name": "Developer"
  },
  system_alias: "NPL-001"
)
```
*   **Method Signature Convention**: Target extension methods in `ZCL_SAP_DEV_RPC_EXT` must follow the clean standard signature:
    ```abap
    METHODS hello_world
      IMPORTING
        iv_params TYPE string OPTIONAL
      RETURNING
        VALUE(rv_result) TYPE string.
    ```
*   **Canonical Reference Implementation**: See [zcl_sap_dev_rpc_ext.clas.abap](./abap/zcl_sap_dev_rpc_ext.clas.abap) for complete ABAP implementations with parameter deserialization (`/ui2/cl_json=>deserialize`), system context retrieval, and structured JSON output templates.
*   **Method-Level AST Guarding**: The Go Bridge extracts *only* the specific `METHOD <name> ... ENDMETHOD` block, generates localized method diffs and SHA-256 fingerprints, and requires user approval in the Web UI **Execution Guard** before dispatch.
*   **Structured JSON Processing**: Input `params` are automatically serialized to JSON before dispatch; the method's `rv_result` JSON string is parsed directly into structured output for the agent.
*   **Boilerplate Generator**: You can generate a ready-to-paste ABAP method skeleton and sample JSON payload anytime via `sap_get_creation_template(object_name="MY_METHOD", object_type="RPC_METHOD")`.

#### 2. Running Automated ABAP Unit Tests (`sap_run_tests`)
To execute ABAP Unit test suites (equivalent to `Ctrl+Shift+F10` in Eclipse ADT) with structured assertion reporting:
```json
sap_run_tests(
  workspace_dir: "<workspace_dir>",
  object_name: "ZCL_ORDER_PROCESSOR",
  object_type: "CLAS",
  test_class: "LTCL_UNIT_TESTS",
  risk_level_ceiling: "HARMLESS",
  system_alias: "TD1-100"
)
```
*   **Structured Test Findings**: Returns pass/fail breakdown, execution times, assert messages, expectation mismatches, and stack traces with line numbers.
*   **Execution Guard & AUnit Wizard**: If unauthorized, returns an `UNAUTHORIZED_EXECUTION` payload detailing the declared risk level. Ask the user to open the Web UI **Execution Guard** tab. The user can set a Maximum Allowed Risk Level policy (`Harmless Only`, `Up to Dangerous`, `Allow Critical`) and select specific test classes/methods in the AUnit Permission Wizard. Live backend ETag locking auto-revokes grants if source or test code is altered in SAP.

---

## 5. 📐 Refactoring Verification & AST Parity Auditing (`audit_abap_parity.mjs`)

When refactoring large ABAP classes (such as decomposing monolithic 3,000+ line classes into `definitions`, `implementations`, and `source/main` includes, or splitting monster methods into focused private subroutines), line-based text diffs create massive noise and easily miss subtle drops (like missing `IF sy-subrc <> 0` checks or dropped bitmasks).

The skill provides an automated, offline AST Parity Auditor script: `.agents/skills/sap-dev/scripts/audit_abap_parity.mjs` (powered by `@abaplint/core`).

### A. Running the AST Parity Auditor

```bash
# Compare a refactored class pool against a Git baseline
node .agents/skills/sap-dev/scripts/audit_abap_parity.mjs \
  --git-baseline HEAD~1:.agents/skills/sap-dev/references/abap/zcl_sap_dev_dev_helper.clas.abap \
  --target .agents/skills/sap-dev/references/abap/zcl_sap_dev_dev_helper.clas.abap \
           .agents/skills/sap-dev/references/abap/zcl_sap_dev_dev_helper.clas.locals_def.abap \
           .agents/skills/sap-dev/references/abap/zcl_sap_dev_dev_helper.clas.locals_imp.abap

# Compare against a local file baseline
node .agents/skills/sap-dev/scripts/audit_abap_parity.mjs \
  --baseline ./tmp/monolith_backup.abap \
  --target ./src/zcl_my_class.clas.abap ./src/zcl_my_class.clas.locals_def.abap ./src/zcl_my_class.clas.locals_imp.abap

# Pass an ephemeral whitelist file for intentional refactoring drops
node .agents/skills/sap-dev/scripts/audit_abap_parity.mjs \
  --git-baseline HEAD~1:<ref> \
  --target <includes...> \
  --whitelist ./tmp/audit_intent.json

# JSON mode for automated subagent evaluation
node .agents/skills/sap-dev/scripts/audit_abap_parity.mjs --git-baseline HEAD~1:<ref> --target <includes...> --json
```

### B. What the Auditor Verifies
1. **Symbol Table Parity**: Ensures 100% preservation of all public/protected methods, interfaces, types, and constants.
2. **Decomposition Mapping**: Automatically recognizes private helper subroutines created during method decomposition.
3. **In-Method Statement Sinks**:
   - `CALL FUNCTION`: Confirms every function module called in baseline is preserved in target.
   - Database Operations: Verifies `SELECT`, `UPDATE`, `INSERT`, `DELETE`, and `COMMIT WORK` statements.
   - Low-Level Bitwise Operations: Verifies Dynpro bitmask operators (`BIT-OR`, `BIT-AND`, `c_x80`, `D021S_RES1`, `FMB1`).
   - Messages: Verifies `MESSAGE` statements in error handling routines.
4. **Decision Path & Branch Tracking**: Flags severe branch collapse to catch accidentally deleted error branches.
5. **Syntax & Unknown Tokens**: Intercepts unclosed blocks, missing periods, and syntax anomalies prior to backend push.

### C. Declaring Intentional Changes via Whitelist File
To avoid polluting ABAP backend source code with comments or pragmas, intentional changes are passed via an ephemeral JSON file (`--whitelist <file>`):
```json
{
  "allowed_function_calls": ["RFC_READ_TABLE"],
  "allowed_db_drops": 10,
  "reason": "RFC_READ_TABLE replaced with direct SQL projection"
}
```
The auditor registers the whitelist entries and outputs them under `Approved Whitelisted Intents` rather than failing the audit.

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

## 7. 🔍 Troubleshooting & Diagnostic Telemetry

When investigating tool failures, ADT network errors, or unexpected responses:
- **Search Diagnostic Logs**: When debug file logging is enabled in the Web Dashboard, use `grep_search` on `<workspace>/tmp/sap-bridge.log` (e.g. `\"level\":\"ERROR\"` or `\"comp\":\"ADT\"`) to inspect raw HTTP payloads and tool inputs.
- **Query SQLite Audit Tables**: Use `sap_execute_local_sqlite` to query `sap_mcp_logs` and `sap_adt_logs` for historical execution parameters.
- **Backend Compatibility Warnings**: If `sap_bridge_status` returns `update_backend`, notify the user to update the backend proxy classes (`ZCL_SAP_DEV_RPC` / `ZCL_SAP_DEV_TUNNEL`) via the Web Dashboard Upgrade tab (`/upgrade`).

---

## 8. 🔌 Reference & Extensibility Guides

For detailed specifications on specialized subsystems, consult the dedicated manuals:

* **[Dynpro & Screen Authoring Guide](./DYNPRO_AUTHORING_GUIDE.md)**: Universal screen JSON schemas, widget attributes, Table Controls, Tabstrips, F4 Search Help, and the working showcase codebase.
* **[Extensibility Selection Guide](./EXTENSIBILITY_GUIDE.md)**: Architecture & decision tree for Workspace Plugins and Aspect Hooks.
* **[Workspace Plugins Guide](./PLUGIN_GUIDE.md)**: Build project-local automation scripts executed via `sap_execute_plugin`.
* **[Aspect Hooks Guide](./HOOK_GUIDE.md)**: Intercept & transform SAP object aspects during `sap_fetch` or `sap_push`.
