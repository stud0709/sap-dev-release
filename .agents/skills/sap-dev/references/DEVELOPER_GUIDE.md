<!-- AUTO-GENERATED FILE - DO NOT EDIT MANUALLY. Source: agents-docs/skill-source/templates -->

# ABAP Developer Agent Guide (`sap-developer`)

This document is the authoritative developer guide for the `sap-developer` sub-agent. It covers code modification workflows, modern ABAP language standards, syntax verification, refactoring parity audits, and debugging protocols. For broader architectural context, setup guides, and user documentation, refer to the [sap-dev Release Wiki](https://github.com/stud0709/sap-dev-release/wiki).

---

## 1. 🛡️ Role & Execution Boundaries

As the **ABAP Developer Agent**, you are responsible for drafting, modifying, validating, and pushing ABAP code.
*   **Workspace Isolation**: Always pass the `workspace_dir` parameter containing the absolute path of your current project workspace folder to every `sap-bridge` MCP tool call to ensure strict tenant segregation.
*   **Spec-Grounded Implementation**: Rely on the verified schemas and database tables provided in the architect's brief to eliminate redundant system exploration steps.
*   **Syntax Verification**: Ensure every code change passes syntax verification using `sap_check_syntax` before pushing or declaring the task done, ensuring no broken code reaches the backend.
*   **Administrative & OData Boundaries**: Delegate administrative, configuration, customizing, or wizard-driven activities that are natively performed via SAP GUI transactions to the user, particularly when direct MCP API capabilities are not exposed. This includes activities like OData service creation and base class generation (`SEGW`), service registration and ICF activation (`/IWFND/MAINT_SERVICE`), metadata cache refreshes (`/IWFND/CACHE_CLEANUP`, `/IWBEP/CACHE_CLEANUP`), structural customizing/SPRO path setup, database index creation, and number range configuration. Focus agent efforts on reading database tables, writing ABAP source code, editing custom extension classes (`_EXT`), and resolving logical bugs, rather than programmatically simulating complex administrative wizards or writing utility classes/raw database updates to bypass standard GUI configurations.
*   **Verbatim Source Preservation & Semantic Integrity**: When copying, cloning, or modifying existing SAP objects (CDS Views, ABAP Classes, Programs, or Function Modules), fetch the raw baseline file using `sap_fetch` (with `aspect: "source"`) and apply localized diffs (`multi_replace_file_content` or AST tools) specifically targeting the delta lines to preserve surrounding string literals, domain values, and comments verbatim without silent generation mutations. Treat syntax check results (`sap_check_syntax`) as confirmation of structural and grammatical validity, while explicitly verifying that string literals, domain fixed values (`DD07L`), and ISO constants match exact domain specifications.
*   **Safety Warning**: Keep debugging operations inline and clean up immediately to release backend developer work processes.

---

## 2. 💻 Code Editing & Push Lifecycle

### Step 1: Draft Staleness Pre-Flight & Inspection (Fetch)
Before making *any* local code edits, establish an ETag baseline and establish file context:
- **Read-Only Inspection**: Call `sap_fetch(aspect: "source", object_name: "...", object_type: "...", system_alias: "<target_sys>", for_editing: false)`. The tool stages the clean ABAP file to `./tmp/<system_alias>/peek_<object>.abap` and returns `file_path`. Open `file_path` using your IDE's native file viewer tool (e.g. `view_file` or `read_file`) to inspect line numbers and line ranges dynamically. Within the same investigation turn, reuse this freshly staged peek file rather than re-fetching over the network.
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
  aspect: "source",
  object_uri: "/sap/bc/adt/programs/programs/z_my_object",
  source_file_path: "<absolute_path_to_local_file>",
  comment: "Refactored SELECT statement to use inline data declarations"
)
```
The tool executes this pipeline atomically:
1.  **Explicit Aspect Validation**: The `aspect` parameter is strictly required (`"source"`, `"definitions"`, `"implementations"`, `"testclasses"`, `"macros"`, `"metadata"`, `"translations"`, `"dynpro"`, `"textelements"`, or `"all"`).
2.  **Hash-Aware ETag Check**: Compares baseline ETag against live backend. If ETag drifted due to metadata or text element modifications while source code remains identical to baseline, the bridge transparently updates the baseline ETag and proceeds. Real concurrent modifications by other users remain strictly guarded.
3.  **LOCK**: Acquires an enqueue lock (`_action=LOCK&accessMode=MODIFY`).
4.  **PUT**: Writes source as inactive version.
5.  **Auto-Unlock**: The tool automatically unlocks the object upon success. You do not need to call any unlock tool.
6.  **Multi-Artifact Coordination**: When pushing with `aspect: "all"`, the bridge automatically scans and pushes all modified staged artifacts (metadata, source code, text elements) in consistent dependency order.
7.  **Targeted Class Pool Includes**: For ABAP classes (`CLAS`), you can fetch or push individual class pool components directly using dedicated aspects (`"definitions"`, `"implementations"`, `"testclasses"`, `"macros"`). Pushing a targeted component updates only that include on the SAP backend and records a discrete version with its specific aspect type in SQLite, enabling focused filtering and token efficiency.

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

#### Post-Activation ETag Refresh Protocol
When `sap_activate_object` succeeds, the backend generates a new active ETag for the compiled object. If further modifications are planned:
*   **Refresh Active State**: Capture the new active ETag or re-fetch the source via `sap_fetch(aspect: "source", for_editing: true)` to update the local baseline before pushing subsequent changes.
*   **Avoid HTTP 412 Precondition Failed**: Pushing modifications using the pre-activation ETag baseline will be rejected by the backend with HTTP `412 Precondition Failed` (concurrent modification). Always refresh the ETag baseline between iterative activation cycles.

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

## 4. 🔍 Syntax Validation & Dynamic Method Execution

A task is **not done** until the code passes syntax validation.

### A. Syntax Validation (`sap_check_syntax`)
Use `sap_check_syntax` to validate complete classes, programs, dynpros, or dictionary (DDIC) objects directly against the live SAP backend compiler without saving:
```json
sap_check_syntax(
  workspace_dir: "<workspace_dir>",
  source_file_path: "src/DEV1-100/zcl_my_class.clas.abap"
)
```
* **Zero-Config Validation**: Automatically infers the SAP system alias, object name, and object type directly from `source_file_path`.
* **Dynpro Support**: Supports both Flow Logic (`.flow.abap`) and Screen Schemas (`.screen.json`).
* **Governance & Linter**: Enforces structural validations and promotes strict warnings to errors when Strict Governance is active.

### B. Dynamic Method Execution & ABAP Unit Testing (`sap_execute_ext_method`, `sap_run_tests`)

All dynamic backend code executions are governed by the zero-trust **Execution Guard**:

#### 1. Dual-Purpose Scratchpad & Extension Methods (`sap_execute_ext_method`)
To execute exploratory logic, inspect live runtime structures, or perform transportable operational data repairs inside `ZCL_SAP_DEV_RPC_EXT` with structured JSON input/output:
```json
sap_execute_ext_method(
  workspace_dir: "<workspace_dir>",
  method_name: "EXECUTE_SCRATCHPAD",
  params: {
    "action": "ANALYZE_STOCK",
    "matnr": "MAT-100-01"
  },
  system_alias: "TD1-100"
)
```

*   **Dual-Purpose Scratchpad Pattern (`EXECUTE_SCRATCHPAD`)**:
    To eliminate public class signature churn and provide a single, friction-free canvas for both ad-hoc exploratory code and operational data repair scripts:
    1. `ZCL_SAP_DEV_RPC_EXT` exposes a permanent, stable dispatcher `execute_scratchpad( iv_params )` in its public section.
    2. The actual business logic is implemented inside the local class `lcl_scratchpad=>run( iv_params )` within `zcl_sap_dev_rpc_ext.clas.locals_imp.abap`.
    3. Modify `lcl_scratchpad=>run` with your exploratory or data correction logic, push and activate `ZCL_SAP_DEV_RPC_EXT`, and invoke `sap_execute_ext_method(method_name="EXECUTE_SCRATCHPAD", params={...})`.
    4. To fetch a boilerplate skeleton anytime, call `sap_get_creation_template(object_name="EXECUTE_SCRATCHPAD", object_type="SCRATCHPAD")`.

*   **Transportable Operations Lifecycle (`DEV` → `QAS` → `PRD`)**:
    In enterprise landscapes, operational data repairs, reconciliation routines, or cleanup tasks frequently **must execute in Quality (QAS) or Production (PRD)** where corrupted or inconsistent transactional data resides.
    - `ZCL_SAP_DEV_RPC_EXT` is architected as the **transportable extension class** (`DEV` → `QAS` → `PRD`).
    - Staging data repair scripts in `lcl_scratchpad` allows them to be captured in CTS transport requests, code-reviewed, and transported cleanly through the landscape.
    - When executed in QAS or PRD, `sap_execute_ext_method` is strictly governed by the zero-trust **Execution Guard**, generating an auditable method fingerprint, capturing diffs, and requiring explicit dashboard sign-off.

*   **Custom Public Extension Methods**:
    For permanent reusable helper functions, declare new public methods in `ZCL_SAP_DEV_RPC_EXT` following the standard signature:
    ```abap
    METHODS custom_action
      IMPORTING
        iv_params TYPE string OPTIONAL
      RETURNING
        VALUE(rv_result) TYPE string.
    ```
    Generate boilerplates via `sap_get_creation_template(object_name="MY_ACTION", object_type="RPC_METHOD")`.

*   **Method-Level AST Guarding**: The Go Bridge extracts *only* the specific `METHOD <name> ... ENDMETHOD` block, generates localized method diffs and SHA-256 fingerprints, and requires user approval in the Web UI **Execution Guard** before dispatch.
*   **Structured JSON Processing**: Input `params` are automatically serialized to JSON before dispatch; the method's `rv_result` JSON string is parsed directly into structured output for the agent.

#### 2. Prohibited Anti-Patterns & Operational Boundaries
*   **NEVER Create Standalone `IF_OO_ADT_CLASSRUN` Classes**: Do not create temporary or standalone ABAP classes implementing `IF_OO_ADT_CLASSRUN` (e.g., `ZCL_RUN_TEST`, `ZCL_EXPLORE_DATA`, `ZCL_TMP_SCRIPT`). These classes create dictionary clutter, bypass method-level AST guarding, and cannot be governed or transported across environments. Always route exploratory execution and data repairs through `ZCL_SAP_DEV_RPC_EXT` (`EXECUTE_SCRATCHPAD`).
*   **NEVER Bypass Customizing Tools with Direct SQL `MODIFY`**: When configuring customizing tables or views (SPRO, SM30, SM34), always use `sap_maintain_customizing` (driving SAP GUI for Java). Never use code execution (`sap_execute_ext_method` or ad-hoc scripts) to perform raw table `MODIFY` or manual `E071`/`E071K` CTS transport insertion. If a customizing activity involves proprietary dynpros outside standard SM30/SM34 table maintenance, escalate to the user with actionable instructions rather than attempting database-level workarounds.

#### 3. Running Automated ABAP Unit Tests (`sap_run_tests`)
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
*   **Required Parameters**: `object_name` and `object_type` are required. `object_type` must be one of the canonical SAP object types: `'CLAS'`, `'PROG'`, `'FUGR'`, or `'DEVC'` (use `'DEVC'` for packages; informal aliases like `'PACKAGE'` are rejected).
*   **Executable Reports (`PROG`) Local Test Class Rule**: When running unit tests for executable reports (`object_type = "PROG"`), local test classes must be declared directly within the main report source file (`<program>.prog.abap`). Test classes declared inside external includes (`INCLUDE ...`) are not automatically discovered by standard ADT test runs unless directly targeted.
*   **Structured Test Findings**: Returns pass/fail breakdown, execution times, assert messages, expectation mismatches, and stack traces with line numbers.
*   **Execution Guard & AUnit Wizard**: If unauthorized, returns an `UNAUTHORIZED_EXECUTION` payload detailing the declared risk level. Ask the user to open the Web UI **Execution Guard** tab. The user can set a Maximum Allowed Risk Level policy (`Harmless Only`, `Up to Dangerous`, `Allow Critical`) and select specific test classes/methods in the AUnit Permission Wizard. Live backend ETag locking auto-revokes grants if source or test code is altered in SAP.

---

## 5. 📐 Refactoring Verification & AST Parity Auditing (`audit_abap_parity.mjs`)

When refactoring large ABAP classes (such as decomposing monolithic 3,000+ line classes into `definitions`, `implementations`, and `source/main` includes, or splitting monster methods into focused private subroutines), line-based text diffs create massive noise and easily miss subtle drops (like missing `IF sy-subrc <> 0` checks or dropped bitmasks).

The skill provides an automated, offline AST Parity Auditor script: `.agents/skills/sap-dev/scripts/audit_abap_parity.mjs` (powered by `@abaplint/core`).

> [!NOTE]
> While this offline refactoring auditor script utilizes `@abaplint/core` for offline AST diffing, the runtime daemon (`sap-bridge`) has zero abaplint dependencies and validates syntax directly against the authoritative SAP ADT kernel compiler and ATC.

### A. Running the AST Parity Auditor

```bash
# Compare a refactored class pool against a Git baseline
node .agents/skills/sap-dev/scripts/audit_abap_parity.mjs \
  --git-baseline HEAD~1:./src/zcl_my_class.clas.abap \
  --target ./src/zcl_my_class.clas.abap \
           ./src/zcl_my_class.clas.locals_def.abap \
           ./src/zcl_my_class.clas.locals_imp.abap

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

## 6. 🐞 Debugging Protocol & Root Cause Analysis

When investigating unexpected API behavior, deceptive HTTP status codes (such as `201 Created` with missing TADIR records), or runtime logic failures, do NOT guess from decompiled source code alone—use the debugger to inspect live backend state directly.

### Track A: One-Shot Request Debugging (`sap_debug_trace`) [RECOMMENDED]
For 95% of debugging needs, use `sap_debug_trace`. It automates the entire lifecycle—setting the breakpoint, dispatching an asynchronous HTTP trigger, catching the session, stepping, evaluating `SY` system fields & watch variables, and tearing down cleanly in **a single tool call**:

```json
{
  "line": {
    "class": "CL_ADT_MESSAGE_CLASS_API",
    "line": 225
  },
  "trigger_request": {
    "uri": "/sap/bc/adt/messageclass?corrNr=A4HK900151",
    "method": "POST",
    "body": "<?xml version=\"1.0\"...?>"
  },
  "watch_variables": ["LV_SUBRC", "LV_OBJECT_NAME"],
  "auto_step_count": 2
}
```

Or trace by statement or message directly:
```json
{
  "message": {
    "message_id": "PAK",
    "message_number": "149"
  },
  "trigger_request": {
    "uri": "/sap/bc/adt/messageclass?corrNr=A4HK900151",
    "method": "POST",
    "body": "<?xml version=\"1.0\"...?>"
  }
}
```

**Key Advantages**:
* **Zero Work-Process Lock Risk**: The daemon guarantees automated cleanup and detachment via `defer`, completely preventing hung work processes.
* **Turnkey System Diagnostics (`SY`)**: Automatically returns `sy-subrc`, `sy-msgid`, `sy-msgno`, and resolved message text from `T100`.
* **Instant Step Timeline**: Loops steps in Go to generate an aggregated execution timeline of variable changes without multi-turn latency.

---

### Track B: Interactive Stepping & Inspection
When deep exploratory step-by-step navigation is required:

#### 1. Set Breakpoints (`sap_debug_breakpoint`)
Set external or session-scoped breakpoints across Line, Statement, Exception, or Message targets (exactly one target block must be specified). Pass optional `"user": "<USERNAME>"` to debug a specific SAP GUI user, RFC service user, or batch user:
* **By Line (Class)**: `{"action": "set", "line": {"class": "CL_ADT_MC_RES_CONTROLLER", "line": 352}}`
* **By Line for Another User**: `{"action": "set", "line": {"class": "CL_ADT_MC_RES_CONTROLLER", "line": 352}, "user": "JDOE"}`
* **By Line (Program)**: `{"action": "set", "line": {"program": "ZDEMO_REPORT", "line": 42}}`
* **By Statement**: `{"action": "set", "statement": {"statement": "AUTHORITY-CHECK"}}`
* **By Exception**: `{"action": "set", "exception": {"exception_class": "CX_ROOT"}}`
* **By Message**: `{"action": "set", "message": {"message_id": "PAK", "message_number": "149"}}`
* **List Active**: `{"action": "list"}` (or `{"action": "list", "user": "JDOE"}`)
* **Clear Specific**: `{"action": "clear", "statement": {"statement": "AUTHORITY-CHECK"}}`
* **Clear All**: `{"action": "clear"}` (or `{"action": "clear", "user": "JDOE"}`)

#### 2. Attach to Session (`sap_debug_attach`)
Initialize the background listener and optionally trigger the execution. When waiting for another user or a GUI session to hit the breakpoint, specify `"user": "JDOE"` and omit `trigger_uri`:
```json
{
  "user": "JDOE",
  "timeout_seconds": 60
}
```
Or for automated HTTP triggers:
```json
{
  "trigger_uri": "/sap/bc/adt/messageclass",
  "trigger_method": "POST",
  "trigger_body": "<...xml payload...>",
  "timeout_seconds": 30
}
```
*Note: The daemon automatically saves the caught session ID as the active session.*

#### 3. Step & Inspect (`sap_debug_step`, `sap_debug_evaluate`)
* **Step Navigation**: Call `sap_debug_step` with `action`: `stepInto`, `stepOver`, `stepReturn`, `stepContinue`, or `detachDebugger`. If `session_id` is omitted, it auto-binds to the active session.
* **Automatic System Fields**: Every step response automatically includes the `sy` object (`subrc`, `msgid`, `msgno`, `message_text`).
* **Deep Table Evaluation**: Call `sap_debug_evaluate` with `parent_id` (e.g. `LT_DATA` or `SY`) to drill into nested structures.

#### 4. Conclude Session (`sap_debug_cleanup`)
Call `sap_debug_cleanup` to detach the active session and wipe external breakpoints:
```json
{}
```

---

### Track C: Agent-Assisted SAP GUI Debugging (Interactive Dialog Sessions)
When debugging interactive dialog transactions, standard reports (SE38/SA38), or screen flows executed directly inside **SAP GUI for Windows** or **SAP GUI for Java**:

#### 1. One-Time SAP GUI User Settings
Ensure external debugging is enabled for your SAP user in SAP GUI:
1. In transaction `SE38` or `SE80`, navigate to **Utilities** $\rightarrow$ **Settings** $\rightarrow$ **ABAP Editor** $\rightarrow$ **Debugging**.
2. Under **Debug External Requests (e.g. RFC, HTTP)**:
   * Select the **User** radio button and set it to your target username (e.g. `YDZHENYEYEV`).
   * Keep **Current application server only** unchecked to allow debugging across load-balanced application server instances.
3. Save by confirming with the green checkmark ($\checkmark$).

#### 2. Synchronize External Breakpoints in SAP GUI
Whenever new external breakpoints are set by the agent via `sap_debug_breakpoint`, load them into the active GUI session:
* Enter `/H_REFRESH_EXT_BPS` in the SAP GUI transaction/command field (top-left) and press **Enter**.
* The SAP GUI status bar confirms: *"External breakpoints loaded, debugging activated"*.
* To explicitly re-bind your user session: `/H_REACTIVATE_EXTD_DBG KIND=USER USER=<SY-UNAME>`.

#### 3. Automated Agent Execution Workflow
The agent can automate the entire listen $\rightarrow$ resynchronize $\rightarrow$ execute sequence:
```json
{
  "system_alias": "TD1-100",
  "trigger_program": "ZPUZZLE_1X",
  "timeout_seconds": 60
}
```
* **What happens**: `sap_debug_attach` initializes the backend long-poll listener, triggers GUI resynchronization (`/H_REACTIVATE_EXTD_DBG` & `/H_REFRESH_EXT_BPS`), and executes the report (`SE38` $\rightarrow$ `F8`) in a single roundtrip.

#### 4. Interactive Human-Assisted Debugging Workflow
When the human developer executes transactions manually or clicks specific UI buttons:
1. **Set Breakpoint**: `sap_debug_breakpoint(action: "set", line: {program: "ZMY_PROG", line: 42})`
2. **Start Attach Listener**: `sap_debug_attach(timeout_seconds: 120)`
3. **Execute in GUI**: In SAP GUI, ensure `/H_REFRESH_EXT_BPS` was run, then press **F8** (or trigger your transaction/dynpro).
4. **Halt & Inspect**: The SAP work process pauses at the breakpoint; `sap_debug_attach` intercepts the session and returns the callstack and initial variables.
5. **Step & Navigate**:
   * Step over statements: `sap_debug_step(action: "stepOver")`
   * Step into methods: `sap_debug_step(action: "stepInto")`
   * Evaluate complex tables: `sap_debug_evaluate(parent_id: "LT_DATA")`
6. **Resume / Detach**:
   * `sap_debug_step(action: "stepContinue")` continues execution to the next breakpoint or completion.
   * `sap_debug_step(action: "detachDebugger")` releases control back to the SAP GUI session so the user can continue working interactively.
7. **Cleanup**: Always run `sap_debug_cleanup()` when finished to release backend locks.

---

## 7. 🔍 Troubleshooting & Diagnostic Telemetry

When investigating tool failures, ADT network errors, or unexpected responses:
- **Short Dump Crash Investigation (`sap_fetch_runtime_errors`)**: When encountering backend short dumps or unexpected terminations, use `sap_fetch_runtime_errors(topmost: 1)` to retrieve deep crash analysis (including "What happened?", "Error analysis", source code excerpt, and stack frames) in a single turn. Filter by `user_name`, dump ID (`runtime_error`), exception class (`exception`), or program name (`program_name`) to isolate recurring crashes.
- **Application Log Queries (`sap_fetch_application_log`)**: To inspect business process or background execution logs, query `BALHDR` and decompressed `BALDAT` message clusters using `user_name`, `object`, `subobject`, `extnumber` (supports wildcards `*`), or date/time windows.
- **Spool Output Inspection (`sap_fetch_spool`)**: When validating background job or report execution outputs, retrieve formatted text lines directly using `sap_fetch_spool(spool_id: ...)` without manual hex decoding.
- **CTS Transport Verification (`sap_verify_transport`)**: Prior to staging or releasing changes, verify transport request/task status (`D` modifiable, `R` released), active child tasks, object locks (`E071-LOCKFLAG`), and recorded table keys (`E071K`) using `sap_verify_transport`.
- **Search Diagnostic Logs**: When debug file logging is enabled in the Web Dashboard, use `grep_search` on `<workspace>/tmp/sap-bridge.log` (e.g. `\"level\":\"ERROR\"` or `\"comp\":\"ADT\"`) to inspect raw HTTP payloads and tool inputs.
- **Query SQLite Audit Tables**: Use `sap_execute_local_sqlite` to query `sap_mcp_logs` and `sap_adt_logs` for historical execution parameters.
- **Backend Compatibility Warnings & Reference Classes**: If `sap_bridge_status` returns `update_backend`, or if a tool operation fails due to missing methods or schema divergence in an outdated backend class, pause execution and notify the user to update the backend proxy classes (`ZCL_SAP_DEV_RPC`, `ZCL_SAP_DEV_DEV_HELPER`, `ZCL_SAP_DEV_TUNNEL`) via the Web Dashboard Upgrade tab (`/upgrade`) or manual deployment. Avoid authoring workarounds or compensating logic to accommodate legacy versions of backend ABAP reference files.

---

## 8. 🔌 Reference & Domain Manuals

For detailed specifications on specialized subsystems, consult the dedicated manuals:

* **[Repository Lifecycle Guide](./REPOSITORY_LIFECYCLE_GUIDE.md)**: Dynamic template shell creation, aspect-based source fetching/pushing (`source`, `definitions`, `implementations`, `testclasses`, `macros`, `metadata`, `translations`, `dynpro`, `textelements`, `all`), message classes (`MSAG`), syntax quick-fixes, and mass activation.
* **[Dynpro & Screen Authoring Guide](./DYNPRO_AUTHORING_GUIDE.md)**: Universal screen JSON schemas, widget attributes, Table Controls, Tabstrips, F4 Search Help, and the working showcase codebase.
* **[Extensibility Guide](./EXTENSIBILITY_GUIDE.md)**: Dynamic ADT object types, backend ABAP handlers, Workspace Plugins, Aspect Hooks, and the Extensibility SDK.
* **[Diagnostics & Configuration Guide](./DIAGNOSTICS_AND_CONFIG_GUIDE.md)**: Telemetry, short dumps (ST22), application logs (`BALHDR`), spool inspection, CTS transport verification, WebGUI templates, and custom object configs.
* **[Versioning & Diffing Guide](./VERSIONING_AND_DIFF_GUIDE.md)**: 3-way structural diffing (`draft`, `active`, `inactive`, `-1`), offline SQLite version timelines, and remote server revision history.
* **[ATC Remediation Guide](./ATC_REMEDIATION.md)**: Static quality and security finding checkout, automated quick fixes, and ATC queue synchronization.
* **[Customizing & SPRO Guide](./CUSTOMIZING_GUIDE.md)**: SPRO discovery, DDIC schema exploration, Customizing Guard permissions, and SM30/SM34 declarative maintenance.
* **[Data & OData Guide](./DATA_AND_ODATA_GUIDE.md)**: OpenSQL queries, fast data preview, OData CRUD operations, and Gateway metadata cache maintenance.
* **[Ecosystem & Support Notes Guide](./ECOSYSTEM_AND_NOTES_GUIDE.md)**: SAP Notes / KBAs, S-User authentication, SAP Business Accelerator Hub, and Fiori Apps Reference Library.
* **[GUI Automation Guide](./GUI_AUTOMATION_GUIDE.md)**: SAP GUI for Java automation, Nostr encrypted tunnel mode, EnjoySAP Trees, ALV Grids, TableControls, modal dialogs, and macro sequences.
* **[MCP Tool Master Catalog](./MCP_TOOL_GUIDE.md)**: Master catalog and 74-tool quick navigation index.

