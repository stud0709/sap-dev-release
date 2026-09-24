<!-- AUTO-GENERATED FILE - DO NOT EDIT MANUALLY. Source: agents-docs/skill-source/templates -->

# Diagnostics, Configuration & Extensibility Guide

This manual covers runtime telemetry, SQLite auditing, spillover drilling, zero-trust permission requests, CTS transport verification, and custom workspace extensions.

---

## 🔍 Runtime Telemetry & System Health

### 1. Bridge Status & System Topology (`sap_bridge_status`)
Returns active daemon version, connected SAP systems, client configurations, landscape groupings, and the authenticated Web Dashboard URL (`sap_dashboard_url`).

### 2. Connection Ping & CSRF Handshake (`sap_ping`)
Pings the backend to verify network connectivity, basic/token credentials, and active CSRF session tokens.

### 3. Diagnostic Package Export & Zero-Trust Bundles (`sap_export_diagnostics`)
Exports a comprehensive, Zero-Trust sanitized diagnostic package in JSON or Markdown format saved directly to `<workspace>/tmp/diagnostics_<system_or_all>_<timestamp>.<json|md>`.
- **Zero-Trust Redaction**: Automatically sanitizes developer user profile paths (`C:\Users\[DEVELOPER]`, `/home/[DEVELOPER]`), private RFC1918 IPv4 addresses (`[REDACTED_IP]`), Bearer/Basic authorization tokens, GitHub PATs, Nostr private keys & PSKs, passwords, client secrets, session cookies (`MYSAPSSO2`, `SAP_SESSIONID`), and authorization headers.
- **Configurable Scope**: Supports filtering by `system_alias`, capping recent log/mutation entries with `limit` (default 50, max 200), and selectively toggling `include_logs`, `include_mutations`, and `include_capabilities`.
- **Offline Troubleshooting & Support**: Ideal for capturing complete execution context before filing an incident report (`sap_file_report`) or safely collaborating with developers without leaking confidential infrastructure or credentials.

---

## 🛡️ Zero-Trust Permission Requests

Submit pending requests to the user's Web UI dashboard queue for approval:

| Tool | Guard Domain | Scope & Targets |
| :--- | :--- | :--- |
| **`sap_request_object_permissions`** | Object Guard | ABAP TADIR objects (`CLAS`, `PROG`, `FUGR`, `TABL`, `MSAG`, `DDLS`) or Packages (`DEVCLASS`). |
| **`sap_request_api_permissions`** | API Guard | Raw REST endpoints and specific OData CRUD entity sets. |
| **`sap_request_gui_permissions`** | SAP GUI Guard | Transactions (`TRANSACTION`), local tables (`TABLE_MAINT`), or customizing views (`CUSTOMIZING`). |

---

## 📋 System Logs, Dumps, Spools & Transports

### 1. Application Logs / BAL (`sap_fetch_application_log`)
Extracts structured SAP Application Log messages from database tables (`BALHDR`, `BALDAT`) using Object, Subobject, or External ID filters.

### 2. Runtime Errors & ABAP Dumps (`sap_fetch_runtime_errors`)
Extracts ST22 short dump tracebacks, offending source line numbers, and system call stacks directly from backend tables (`SNAP`).

### 3. Spool Requests (`sap_fetch_spool`)
Extracts formatted output lines and metadata from SAP spool requests (`TSP01`, `TSP02`). Supports windowed reading via `line_offset` (0-based starting index) and `max_lines` (default 500, max 2000) to prevent prompt context bloat on large reports, with automatic disk spillover evaluation for oversized payloads.

### 4. Transport Verification (`sap_verify_transport`)
Inspects CTS transport requests and tasks (`E070`, `E071`, `E071K`) to verify modifiable status (`D` vs `R`), owner, object locks, and table keys without requiring raw SQL.

### 5. Automated ABAP Unit Tests (`sap_run_tests`)
Executes automated AUnit test suites across classes, function groups, programs, or packages with structured pass/fail assertion reporting.

### 6. Incident & Handover Reporting (`sap_file_report`)
Dispatches an anonymized developer handover or tooling incident report directly to GitHub issues on `stud0709/sap-dev-release`. Strictly reserved for `sap-dev` tooling/bridge defects (timeouts, crashes, ADT protocol failures), NOT for customer SAP business logic or ABAP consulting. The agent drafts and anonymizes the report, presents it to the human developer for explicit review and approval in chat, and calls `sap_file_report` with optional `attachment_paths` only upon confirmation.

---

## 📡 Disconnected System Diagnostics & Large Trace Ingestion

When troubleshooting systems that are not directly connected to the workspace (such as Production or external landscapes where live debugging or ADT access is unavailable), diagnostic traces can be collected manually and provided to the agent for root-cause analysis:

### Large Output & Ingestion Guardrails (ST05 / SAT / ST12 / Spools / Logs)
When handling multi-megabyte traces, spools, or offline log extracts:
1. **Windowed Slicing**: Use `line_offset` and `max_lines` (e.g. in `sap_fetch_spool`) to inspect pages sequentially rather than loading entire multi-thousand line files into memory.
2. **Disk Spillover Drill-Down**: When large tool responses spill over to `./tmp/`:
   - For JSON files: query specific subtrees with `sap_query_json(file_path: "...", query: "...")`.
   - For XML / Atom feeds: query XPath nodes with `sap_query_xml(file_path: "...", xpath: "...")`.
   - For raw text / ABAP logs: inspect focused line ranges with `view_file(StartLine: ..., EndLine: ...)` rather than dumping full files.
3. **Diagnostic Sanitization**: Use `sap_export_diagnostics` to bundle and redact SQLite telemetry before sharing trace data across external boundaries.

### 1. SAT Runtime Analysis (Primary for Functional Logic & BAdIs)
Use SAT to investigate functional bugs, unexpected branching, early exits, or skipped logic:
- **Measurement Variant Setup (`SAT` -> Measurement Settings)**:
  - **Aggregation**: Set to **`None`** to preserve the chronological call tree. Aggregated views group executions and hide the sequential flow.
  - **Size Limits**: Increase `Maximum Size of File` (e.g. `50 000 KB` or `100 000 KB`) to accommodate unaggregated statements.
  - **Options**: Select **`Measure RFC calls and update calls`** so background RFC and `IN UPDATE TASK` logic are captured.
  - **Statements**: Keep `Processing Blocks` (Methods, Functions, Subroutines) and `Open SQL`. Deselect `LOAD`, `GENERATE`, and `C calls` to eliminate kernel noise.
- **Export Method**:
  - Open the measurement and navigate to the **`Call Hierarchy`** tab (`F5`).
  - Right-click any row in the ALV tree $\rightarrow$ **`Spreadsheet...`** (or **`Export` $\rightarrow$ `Local File`** $\rightarrow$ *Text with Tabs*).
  - Save as a text file into `<workspace>/tmp/` (e.g. `tmp/sat_trace.txt`) or share the file path with the agent.
- **Agent Analysis**: The agent reads the method call tree, nesting levels, and execution sequence to locate the divergence point, then inspects the corresponding source in the connected DEV/QA system.

### 2. ST05 Performance Trace (Secondary for Data Values & Return Codes)
Use ST05 to inspect actual SQL filter values, table access keys, lock contentions, or DB return codes:
- **Recording**: Activate SQL, Enqueue, or RFC trace scoped by User ID or Transaction Code to maintain focused log sizes.
- **Export Method**:
  - Use **`Summarized SQL Statements`** (`F8`) for performance bottlenecks.
  - For functional analysis, export the detailed trace (`Trace List` $\rightarrow$ `Save` / `Export` $\rightarrow$ *Text with Tabs*).
- **Agent Analysis**: Provides runtime literal values (`WHERE "FIELD" = 'VAL'`), record counts, and database return codes (`0` vs `4` / `64`) that complement the SAT call structure.

### 3. Application Log Technical Extraction (`SLG1` / `BALM`)
Use Application Logs to capture complete diagnostic messages without localized text ambiguity:
- **ALV Layout Customization (`SLG1`)**:
  - In the message list, click **Change Layout** (`Ctrl + F8`).
  - Move technical fields (`MSGID` / Message Class, `MSGNO` / Number, `MSGTY` / Type, `MSGV1`–`MSGV4` / Variables) to displayed columns.
  - Export the customized grid to a text file.
- **Direct Table Query (`SE16N`)**:
  - Table `BALHDR`: Query by `OBJECT`, `SUBOBJECT`, date, and user to obtain the `LOGNUMBER`.
  - Table `BALM`: Filter by `LOGNUMBER` to extract raw message parameters (`MSGID`, `MSGNO`, `MSGV1`–`MSGV4`).
- **Agent Analysis**: The agent searches connected DEV source code for `MESSAGE ... <MSGNO>(<MSGID>)` to locate the exact statement and condition that triggered the log.

---

## 🔍 Local SQLite Database Auditing (`sap_execute_local_sqlite`)

The local `.sap_dev.db` database stores audit telemetry and configurations:

### Key Audit Tables:
- **`sap_mcp_logs`**: Logs every MCP tool call, input JSON, output, error message, and duration.
- **`sap_adt_logs`**: Logs raw HTTP status codes, ADT URLs, and network request/response bodies.
- **`sap_source_versions`**: Records local staging version history, ETags, and code events.

```sql
-- Query recent tool failures
SELECT id, tool_name, error_message, created_at 
FROM sap_mcp_logs 
WHERE is_error = 1 
ORDER BY id DESC LIMIT 5;
```

---

## 📦 Drilling Spilled Payloads (`sap_query_json` / `sap_query_xml`)

When large tool responses spill over to disk in `./tmp`:
- **JSON Files**: Use `sap_query_json(file_path: "./tmp/spill.json", query: "nodes.#(name==\"BUILD_MLV\")")` using GJSON paths.
- **XML Files**: Use `sap_query_xml(file_path: "./tmp/spill.xml", xpath: "//atom:entry/atom:link/@href")` using XPath queries.

---

## 🔌 Extensibility & Configuration Management

### 1. WebGUI Deep-Link Templates (`sap_manage_gui_template`)
Manage mappings in `sap_custom_gui_templates` (`action: "create" | "read" | "list" | "delete"`, e.g. mapping `CLAS` to `SE24`).

### 2. Custom Object Types & URI Templates (`sap_manage_object_type_config`)
Manage custom object extensions and regex-based ADT URI templates in `sap_custom_object_types`.

### 3. Register File Extensions (`sap_register_file_extension`)
Registers custom file extensions in the SQLite registry as either `"text"` or `"binary"`.

### 4. Manage Interpreter Prefixes (`sap_manage_interpreter_configs`)
Configures interpreter binaries (e.g. Python venv path) for custom hook scripts.

### 5. Execute Workspace Plugins (`sap_execute_plugin`)
Executes standalone, registered custom workspace automation plugins.
