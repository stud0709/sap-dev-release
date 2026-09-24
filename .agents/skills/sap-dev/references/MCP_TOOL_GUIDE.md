<!-- AUTO-GENERATED FILE - DO NOT EDIT MANUALLY. Source: agents-docs/skill-source/templates -->

# MCP Tool Master Catalog & Quick Navigation Index

This index acts as the central router for the 76 Model Context Protocol (MCP) tools provided by `sap-bridge`. For comprehensive workflow walkthroughs, refer to the specialized domain manuals linked below.

---

## 🗺️ Master Tool Navigation Matrix

| Domain Guide | Included Tools | Key Capabilities |
| :--- | :--- | :--- |
| [**DEVELOPER_GUIDE.md**](./DEVELOPER_GUIDE.md) | `sap_debug_trace`<br>`sap_debug_breakpoint`<br>`sap_debug_attach`<br>`sap_debug_step`<br>`sap_debug_evaluate`<br>`sap_debug_context`<br>`sap_debug_cleanup`<br>`sap_execute_ext_method`<br>`sap_run_tests` | Interactive ABAP debugging, one-shot trace (`sap_debug_trace`), breakpoint management, variable inspection, remote method execution, AUnit unit testing, and AST parity auditing. |
| [**REPOSITORY_LIFECYCLE_GUIDE.md**](./REPOSITORY_LIFECYCLE_GUIDE.md) | `sap_fetch`<br>`sap_push`<br>`sap_get_creation_template`<br>`sap_check_syntax`<br>`sap_syntax_quick_fix`<br>`sap_get_element_info`<br>`sap_activate_object`<br>`sap_fetch_inactive_objects`<br>`sap_explore_object`<br>`sap_explore_domain`<br>`sap_explore_enhancements`<br>`sap_search_source_code`<br>`sap_where_used`<br>`sap_resolve_frontend_target`<br>`sap_lookup_object_types` | Dynamic template shell creation, aspect-based source fetching/pushing (`source`, `definitions`, `implementations`, `testclasses`, `macros`, `metadata`, `translations`, `dynpro`, `textelements`, `all`), mass activation, syntax checking & quick fixes, Omni-tool exploration, and where-used queries. |
| [**CUSTOMIZING_GUIDE.md**](./CUSTOMIZING_GUIDE.md) | `sap_search_customizing`<br>`sap_explore_customizing`<br>`sap_request_customizing_permissions`<br>`sap_maintain_customizing` | SPRO activity discovery, DDIC schema inspection, Customizing Guard approval queues, CTS Transport Request binding, and declarative record maintenance (`INSERT_UPDATE` / `DELETE`) in SM30/SM34. |
| [**GUI_AUTOMATION_GUIDE.md**](./GUI_AUTOMATION_GUIDE.md) | `sap_gui_status`<br>`sap_gui_inspect`<br>`sap_gui_action`<br>`sap_gui_read_table`<br>`sap_gui_execute_sequence`<br>`sap_gui_manage_sequence`<br>`sap_gui_eval` | SAP GUI for Java automation, Nostr encrypted tunnel mode, EnjoySAP Tree navigation, ALV Grid row selection, TableControl pagination, modal popup handling, Virtual Keys (`vkey`), and macro sequences. |
| [**DATA_AND_ODATA_GUIDE.md**](./DATA_AND_ODATA_GUIDE.md) | `sap_execute_sql`<br>`sap_select_data`<br>`sap_odata_call`<br>`sap_explore_odata_service`<br>`sap_maintain_odata_service` | Freestyle OpenSQL queries, Fast Data Preview, OData `$metadata` schema extraction, token-optimized CRUD operations (`READ`, `CREATE`, `UPDATE`, `DELETE`), and Gateway cache clearing. |
| [**ECOSYSTEM_AND_NOTES_GUIDE.md**](./ECOSYSTEM_AND_NOTES_GUIDE.md) | `sap_notes_search`<br>`sap_note_fetch`<br>`sap_portal_login`<br>`sap_api_hub_search`<br>`sap_api_hub_fetch`<br>`sap_fiori_app_search`<br>`sap_fiori_app_fetch` | SAP Support Notes/KBAs with `CVERS` component release compatibility filtering, S-User interactive authentication, SAP Business Accelerator Hub APIs, and Fiori Apps Reference Library metadata. |
| [**VERSIONING_AND_DIFF_GUIDE.md**](./VERSIONING_AND_DIFF_GUIDE.md) | `sap_diff_versions`<br>`sap_list_versions`<br>`sap_list_remote_versions`<br>`sap_fetch_remote_version` | 3-way structural diffing (`draft`, `active`, `inactive`, `-1`), offline SQLite version timelines, remote SAP database revision history (`E070`), and pristine historical code staging. |
| [**DIAGNOSTICS_AND_CONFIG_GUIDE.md**](./DIAGNOSTICS_AND_CONFIG_GUIDE.md) | `sap_bridge_status`<br>`sap_ping`<br>`sap_export_diagnostics`<br>`sap_execute_local_sqlite`<br>`sap_query_json`<br>`sap_query_xml`<br>`sap_manage_gui_template`<br>`sap_manage_interpreter_configs`<br>`sap_fetch_application_log`<br>`sap_fetch_spool`<br>`sap_fetch_runtime_errors`<br>`sap_verify_transport`<br>`sap_execute_request`<br>`sap_explore_api_registry`<br>`sap_request_object_permissions`<br>`sap_request_api_permissions`<br>`sap_request_gui_permissions`<br>`sap_file_report` | Daemon telemetry, Zero-Trust sanitized diagnostic package exports, local SQLite audit tables (`sap_mcp_logs`, `sap_adt_logs`), GJSON & XPath querying on spilled files, WebGUI templates, custom object type extensions, file type registry, and CTS transport checks. |
| [**EXTENSIBILITY_GUIDE.md**](./EXTENSIBILITY_GUIDE.md) | `sap_get_supported_capabilities`<br>`sap_register_file_extension`<br>`sap_manage_object_type_config`<br>`sap_execute_plugin` | 4-pillar extensibility architecture, dynamic ADT object type definitions, backend ABAP handlers, workspace plugins, aspect hooks, and the Extensibility SDK. |
| [**ATC_REMEDIATION.md**](./ATC_REMEDIATION.md) | `sap_fetch_atc_queue`<br>`sap_update_atc_status`<br>`sap_atc_documentation`<br>`sap_atc_quick_fix` | Dedicated automated ATC quality finding checkout, investigation, remediation, and status sync. |
| [**DYNPRO_AUTHORING_GUIDE.md**](./DYNPRO_AUTHORING_GUIDE.md) | `sap_fetch`<br>`sap_push` *(aspect: "dynpro")* | Classic ABAP Screen (Dynpro) layout authoring, flow logic (`PROCESS BEFORE OUTPUT` / `PROCESS AFTER INPUT`), TableControls, Tabstrips, Subscreens, and CUA GUI status provisioning. |

---

## ⚙️ General Tool Invocation Mechanics

### 1. Zero-Config Parameter Inference & URI Fallback
Core code modification and validation tools (`sap_check_syntax`, `sap_syntax_quick_fix`, `sap_push`, `sap_fetch`) automatically deduce the system alias, object name, object type, and ADT URI directly from `source_file_path` (e.g. `src/DEV1-100/zcl_demo.clas.abap`).
- If you do not have an explicit `object_uri`, supply `object_name` and `object_type`. The bridge will automatically discover and cache the backend URI.
- To inspect supported object types and extensions in the active workspace, call `sap_get_supported_capabilities`.

### 2. Handling Massive Payloads (Spillover)
If an MCP tool returns a payload exceeding safe token thresholds (40KB for bulk exploration/source, or 2KB default), it automatically stages the full, untouched payload to disk in `./tmp` (or `./tmp/<system_id>/`) and returns a structured `spillover` metadata object (`file_path`, `spillover_path`, `summary`).
- **Drill Down JSON**: Use `sap_query_json` with GJSON paths against the staged file without loading the entire payload into context.
- **Drill Down XML**: Use `sap_query_xml` with standard XPath expressions (e.g. `//atom:entry/atom:link/@href`).
- **Slice Inspection**: Inspect exact line ranges using `view_file` with `StartLine`/`EndLine`.

### 3. Raw HTTP Sandbox (`sap_execute_request`)
For read-only ADT endpoint API exploration:
- Pass `accept` and `content_type` as top-level string parameters (e.g. `accept: "application/atomsvc+xml"`).
- If the response returns `UNAUTHORIZED_ENDPOINT`, invoke `sap_request_api_permissions` to queue the endpoint in the user's Pending Intercepts queue.
