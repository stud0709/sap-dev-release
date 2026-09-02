<!-- AUTO-GENERATED FILE - DO NOT EDIT MANUALLY. Source: agents-docs/skill-source/templates -->

# MCP Tool Abstraction Guide

Because the backend toolkit is dynamically aggregated through a proxy, use this guide to map standard SAP contexts into explicit tool parameters. As the proxy layer is shipped as a closed-source compiled binary, you cannot inspect the go routines. 

## ⚙️ General Tool Invocation Mechanics

1. **ABAP Node Targeting**: Always resolve string offset locations dynamically. For code modifications, find the target program structure or method signature, open the file using `view_file` to locate the exact boundaries `StartLine` and `EndLine`, and then execute standard `multi_replace_file_content` or `replace_file_content` logic targeting those isolated lines.
2. **Fail-Fast Interception**: The `sap-bridge` operates on dynamic Atom Discovery. If an MCP tool returns a `failfast:` error (saying an advanced parameter isn't supported on the connected backend), actively re-evaluate the parameter payload, omit the unsupported advanced filters from the tool call, and execute generalized JSON response filtering locally instead.
3. **Universal URI Fallback**: Many tools (`sap_check_syntax`, `sap_syntax_quick_fix`, `sap_push`, `sap_get_element_info`, `sap_diff_versions`) natively support Universal URI Fallback. If you do not have the explicit `object_uri` (e.g., `/sap/bc/adt/programs/programs/ztest`), you can instead provide the `object_name` (e.g., `ZTEST`) and `object_type` (e.g., `PROG`) directly in the tool parameters. The bridge will automatically discover, cache, and resolve the correct backend URI for you. If a tool absolutely requires an explicit URI and does not support the fallback (e.g. Debugger tools), you can discover it by:
   - **Inspecting ATC Findings**: When resolving ATC queue findings using `sap_fetch_atc_queue`, the `object_uri` is provided in the payload representing the offending file.
   - **The Omni-Tool (`sap_explore_object`)**: If you only have the name of an object (e.g., `ZCL_MY_CLASS`), you can use `sap_explore_object` to search for it or retrieve its structural JSON outline, which maps every child component to its respective ADT Object URI.
   - **Dynamic Object Types**: The proxy caches valid object types in the background. Use the `sap_lookup_object_types` as a reference when you are unsure what `object_types` to use.

4. **The Omni-Tool (`sap_explore_object`)**: The proxy consolidates discovery into a single entry point using "Opinionated Smart Defaults". Based on what you pass, the tool dynamically alters its return payload:
   - **Fallback (Search)**: If you omit `object_types` or pass a wildcard (`*ESI*`) or natural language text (`sales order`), the tool executes a wildcard/description search (hardcapped at 50 results) across all ABAP objects. If exactly 1 match is found, it automatically resolves its type and outlines it instead.
   - **Type Array Filtering**: You can pass an array of `object_types` (e.g., `["CLAS", "FUGR/FF"]`) alongside a semantic search to easily find multiple types of objects dealing with the same business concept.
   - **OData Services (`ODAT`)**: Passing an OData Service maps its `$metadata` schema (EntitySets, Properties) into a JSON outline, and automatically embeds `IMPLEMENTATION_CLASS` nodes pointing to the underlying ABAP DPC/MPC or CDS views.
   - **Packages (`DEVC`)**: Passing a package name returns a recursive tree of all objects inside the package. *Tip: To query massive package containers efficiently without causing backend timeouts, restrict search scope by passing a type filter (e.g. `object_types=["CLAS"]`).*
   - **BAdIs (`SXSD` / `ENSC`)**: Passing a Classic BAdI or Enhancement Spot maps its entire ecosystem chain (Spot -> Definition -> Interface).
   - **Classes/Interfaces (`CLAS` / `INTF`)**: Returns the method/attribute structure *and* automatically embeds the inheritance hierarchy (superclasses, implemented interfaces).
   - **Standard Objects**: Returns the JSON structural tree of methods, includes, or DDIC fields.
   - **Supported Objects**: `sap_explore_object` supports querying both complex structural containers (e.g., `CLAS`, `PROG`, `FUGR`) and atomic dictionary objects (e.g., `DTEL`, `DOMA`, `TABL`).
   - **CDS Views (`DDLS`)**: `sap_explore_object` supports architectural dependency graphing for CDS objects. It will return a highly detailed forward dependency tree mapping the underlying SQL abstractions, relationships, and functions built into the view.

5. **Handling Massive Payloads (Spillover)**: If an MCP tool returns a payload exceeding safe token limits (40KB), it will automatically write the full raw payload to `./tmp` and return a lightweight `skeleton_preview` in the same response. This proactive JSON skeleton aggressively optimizes the payload for your context window:
   - **Horizontal Deduplication**: If an array contains many structurally identical objects, the skeleton keeps only the first example. It extracts the identifiers (e.g., `name`, `object_name`, `log_number`) of all the deleted objects and appends them to the array inside an `{"_omitted_identifiers": [...]}` object so you maintain full horizontal visibility of what was dropped.
   - **Vertical Depth Limits**: If the JSON tree exceeds 4 levels of depth, the skeleton stops recurring and replaces the nested child with `<depth limit reached: use sap_query_json to explore deeper>`.
   - **Drilling Down (JSON)**: Use the `sap_query_json` tool with GJSON paths against the exact dumped file in `./tmp` if you need to extract the raw, un-collapsed JSON data that the skeleton truncated.
     *   *Example JSON Query*: `sap_query_json(file_path="./tmp/spill.json", path="nodes.#(name==\"BUILD_MLV\")")`
   - **Drilling Down (XML)**: If the dumped file contains XML (even if it's wrapped in a JSON `{"body": "..."}`), use the `sap_query_xml` tool with standard XPath expressions (e.g., `//FunctionImport`) to cleanly extract specific XML nodes, attributes, and inner text without manually parsing the massive string!
     *   *Example XML Query*: `sap_query_xml(file_path="./tmp/spill.xml", xpath="//atom:entry/atom:link[@rel='http://www.sap.com/adt/relations/source']/@href")`

### Editing Massive Source Files
If `sap_fetch` spills a massive ABAP file into `./tmp/`, strictly use local file operations:
1. Find the target method or structure using `sap_explore_object`.
2. Open the spilled file in `./tmp/` using `view_file` and inspect the target lines.
3. Mutate the file locally using `replace_file_content` or `multi_replace_file_content`.
4. Push the mutated massive file back to SAP by calling `sap_push` with `source_file_path` pointing to the spilled `./tmp/` file and aspect `"source"`.

### System & Version Targeting
- Before invoking tools that require `system_alias`, you should call `sap_bridge_status` to safely discover the correct connected backend targets. This prevents cross-system pollution.
- Before writing custom hooks or running scripts, call **`sap_get_supported_capabilities`** to dynamically retrieve the active workspace's supported object types, extensions, enabled aspect hooks, and registered standalone plugins. 
- `sap_fetch` with `for_editing=true` is purely a local staging mechanism that writes to `./src/` and safely archives unpushed drafts. It does **not** check for write permissions; write permissions are only enforced when attempting to push.
- When using `sap_diff_versions`, prefer semantic string targets: `"draft"` (local physical file), `"active"` / `"inactive"` (live backend states), or `"-1"` (latest recorded SQLite version).

### XML Discovery & Navigation
- **Navigating XML Structures**: If you call `sap_fetch` using a base URI and receive XML metadata instead of ABAP code, read the XML to locate the specific sub-link you need (e.g., `href="source/main"` for code, or `href=".../textelements"` for text symbols), and make a second `sap_fetch` call using that precise URI.

### Handling Function Modules (FUGR/FUNC)
- **Function Groups (FUGR)**: Function Groups are containers. You cannot use `sap_fetch` directly on a Function Group's base URI because it doesn't represent a linear source file. You MUST use `sap_explore_object` on the Function Group to discover its specific Include files and Function Modules, and then call `sap_fetch` on those specific child URIs.
- **Function Modules (FUNC / FUGR/FF)**: Unlike GUI-based transactions (SE37), you can programmatically edit a Function Module's signature (Parameters, Exceptions) via text. Use `sap_fetch` to retrieve the module's source. If the module is newly created, it may contain a comment hinting at a template. You must replace this comment with the actual pseudo-ABAP signature block injected directly below the `FUNCTION <NAME>.` statement, using this exact syntax:
  ```abap
  IMPORTING
    VALUE(IM_P1) TYPE type1 OPTIONAL
    VALUE(IM_P2) TYPE type2 DEFAULT def_value
  EXPORTING
    EX_P1        TYPE REF TO STRING
  CHANGING
    CH_1         TYPE ANY
  TABLES
    TAB_P1       LIKE structure_name
    TAB_P2       TYPE tab_type
  RAISING
    CX_SY_ZERODIVIDE 
    RESUMABLE(CX_SY_ASSIGN_CAST_ERROR)
  ```
  You can structurally mutate these blocks and execute `sap_push` with `object_type="FUGR/FF"` to permanently alter the backend signature. Note: Activating an altered Function Module often requires mass-activating its parent Function Group to regenerate the global interfaces.

### Raw HTTP Requests
*   The `sap_execute_request` tool provides a raw sandbox for probing ADT endpoints. 
*   **ADT Headers Configuration**: The ADT backend is strict about HTTP Headers (e.g. `Accept: application/atomsvc+xml` or `Content-Type`). When using `sap_execute_request`, pass headers like `Accept` and `Content-Type` using the **top-level string parameters** (`accept` and `content_type`), keeping them distinct from nested JSON array or dictionary parameters. 
*   *Example*: `sap_execute_request(workspace_dir="<workspace_dir>", uri="/sap/bc/adt/discovery", accept="application/atomsvc+xml")`
*   **Whitelist Authorization Recovery Flow**: When calling `sap_execute_request`, if the response indicates an `UNAUTHORIZED_ENDPOINT` error, immediately invoke the `sap_request_api_permissions` tool to queue the required REST endpoint and HTTP method in the user's Pending Intercepts queue. Direct the user to the Web UI dashboard to approve this pending request, and pause execution until they confirm the authorization.

## 🛠️ Object Creation Templates (`sap_get_creation_template`)

To safely instantiate new objects on the SAP backend (whether they are DDIC tables/data elements or repository classes/programs), you must obtain and stage their XML creation templates first. 

Use `sap_get_creation_template` to fetch a clean, patch-compatible template:
```json
sap_get_creation_template(
  workspace_dir: "<workspace_dir>",
  object_name: "ZBUI_MSB_APPL",
  object_type: "DTEL",
  package: "$MSB_COMPAT",
  system_alias: "TD1"
)
```
*   **Universal Dynamic Resolution**: The tool works for **any** object type supported by the target SAP system. It auto-discovers a standard reference object from TADIR, fetches its XML from the backend, and customizes it with the target name, package, and inactive version state.
*   **Optional `reference_entity`**: You may explicitly specify a `reference_entity` (e.g., `MANDT` for data elements) to use as the template source. If omitted, the tool auto-discovers one from TADIR.
*   **Content-Type Discovery**: The correct HTTP Content-Type for creating the object shell is resolved dynamically from the cached ADT Discovery payload, ensuring cross-system compatibility.
*   **Safety Rewrite**: All templates have their version state set to `inactive` (`core:version="inactive"`), preventing backend assertion dumps when initially pushing the shell.


## 📂 ADT Object Metadata (`sap_fetch_metadata` / `sap_push_metadata`)

When you need to read or modify non-code structural properties of SAP objects (such as RFC/Remote-Enabled properties, table/structure technical settings, domain/data element labels, class properties), use the metadata tools.

### 1. Fetching Metadata
Use `sap_fetch_metadata` to retrieve raw XML metadata:
```json
sap_fetch_metadata(
  workspace_dir: "<workspace_dir>",
  object_name: "Z_MY_OBJECT",
  object_type: "FUNC",
  for_editing: true
)
```
*   If `for_editing` is `true`, the XML is staged to `./src/<system_id>/metadata/<object_name>.<type>.xml` and its ETag is baselined in the local SQLite database.
*   If `for_editing` is `false` (default), the XML is returned directly or spilled to `./tmp` if it exceeds the token size limit.

### 2. Pushing Metadata
After editing the local XML file under `./src/.../metadata/`, push it back using `sap_push_metadata`:
```json
sap_push_metadata(
  workspace_dir: "<workspace_dir>",
  object_name: "Z_MY_OBJECT",
  object_type: "FUNC",
  metadata_file_path: "<workspace_dir>/src/<system_alias>/metadata/z_my_object.func.xml"
)
```
The tool operates atomically:
1.  **Staleness Pre-Flight**: Compares baseline ETag against live backend.
2.  **LOCK**: Enqueues the ADT session lock.
3.  **Dynamic Content-Type Discovery**: Queries the backend to find the exact ADT MIME type expected for this object category.
4.  **PUT**: Pushes the modified XML.
5.  **Auto-Unlock**: Releases the backend session lock.

### 3. Segregation in SQLite and Dashboard
*   All metadata records are logged in SQLite with the `is_metadata` flag set to `1` (true).
*   In the Versioning Dashboard, metadata changes are visually marked with a light blue **file-code** icon, while source code changes use a pinkish-red **square-chart-gantt** icon (both are equipped with hover tooltips).

## 📋 SAP Notes Integration (sap_notes_search / sap_note_fetch)

To query and inspect SAP Support Portal notes, use the dedicated note tools.

### 1. Searching Notes
Use `sap_notes_search` to query me.sap.com for notes and KBAs. 
*   **Relevance Filtering**: By default, the tool automatically evaluates note applicability on the fly against the connected system's component releases (queried from `CVERS`). It fetches the note's metadata in the background and filters out search results that are not valid or are already resolved by the system's Support Package level.
*   **Including Irrelevant Notes**: If you deliberately want to include irrelevant/incompatible notes in the search results (e.g. for cross-landscape analysis, backporting workarounds, or reference), pass `include_irrelevant = true`.

```json
sap_notes_search(
  workspace_dir: "<workspace_dir>",
  query: "WDYA",
  system_alias: "TD1",
  include_irrelevant: true
)
```

### 2. Fetching Note Details
Use `sap_note_fetch` to retrieve the complete text, description, component validity, and resolving Support Package details for an SAP Note by ID:

```json
sap_note_fetch(
  workspace_dir: "<workspace_dir>",
  note_id: "3386534",
  system_alias: "TD1"
)
```

## 🛡️ Zero-Trust Permissions & Sandbox Handshakes

To guarantee structural safety, all structural execution pathways (pushing code, activating objects, calling APIs) are gated behind explicit UI approval mechanisms in the SAP-Bridge Web Dashboard. If a tool fails because of permission locks (`UNAUTHORIZED`), a request is added to the user's dashboard queue. Stop and instruct the user to approve the pending items in their SAP-Bridge Dashboard:
- **API Guard** section: governs `sap_execute_request`, `sap_odata_call`, and `sap_explore_odata_service`. You can proactively request multiple permissions with `sap_request_api_permissions`.
  - **Strict Routing Rules (Fast-Fail)**: Maintain architectural separation between raw endpoint calls and OData calls:
    - Route OData endpoint paths (URIs containing `/odata/` or `/sap/opu/odata/`) exclusively through `sap_odata_call` and `sap_explore_odata_service` to allow structured schema parsing and automatic token-saving optimizations.
    - Raw HTTP requests via `sap_execute_request` reject OData paths to prevent token exhaustion and ensure security schema consistency.
- **Object Guard** section: governs `sap_push` and `sap_activate_object`. Multiple requests can be made with `sap_request_object_permissions`.

## 🌐 OData Client Operations (`sap_odata_call` / `sap_explore_odata_service`)

To interact with business data exposed via OData services (like S/4HANA Cloud Key User APIs or custom SAP Gateway services), utilize the dedicated OData tools. These tools are optimized to prevent context bloat by stripping metadata wrappers and parsing large XML schema documents into light JSON.

### 1. Service Schema Discovery
Before querying or mutating an OData service, execute `sap_explore_odata_service` to retrieve its metadata schema. This returns a compact JSON summary of the service's EntitySets, key properties, and field types, helping you build accurate payloads.

```json
sap_explore_odata_service(
  workspace_dir: "<workspace_dir>",
  service_path: "/sap/opu/odata/SAP/APS_OM_FORM_TMPL_SRV"
)
```

### 2. Executing CRUD Requests
Use `sap_odata_call` to query, create, update, or delete entity instances. 

*   **Reading Multiple Entities**: Specify the `READ` action. Use `filter` and `select` parameters to restrict data and avoid context limits.
*   **Reading a Single Entity**: Specify the `READ` action and provide a JSON-encoded object in the `keys` parameter (e.g., `{"FormTemplateName": "ZZ1_PO", "Language": "EN"}`). The tool automatically handles OData key formatting (e.g., `FormTemplateCollection(FormTemplateName='ZZ1_PO',Language='EN')`).
*   **Creating or Updating**: Specify `CREATE` or `UPDATE` and pass a JSON request body in the `payload` parameter. For single-entity updates, provide the `keys` parameter.
*   **Deleting**: Specify `DELETE` and provide the target `keys`.

```json
sap_odata_call(
  workspace_dir: "<workspace_dir>",
  service_path: "/sap/opu/odata/SAP/APS_OM_FORM_TMPL_SRV",
  entity_set: "FormTemplateCollection",
  action: "READ",
  keys: "{\"FormTemplateName\": \"ZZ1_PO\", \"Language\": \"EN\"}"
)
```

### 3. Automatic Response Optimization
The `sap_odata_call` tool automatically parses the JSON response and strips out internal metadata wrappers (`__metadata`, `__deferred`, `@odata.*` annotations) and unrolls simplified wrapper objects (`d`, `results`, `value`). This significantly reduces token consumption and provides a clean, native JSON representation of the business data.

## 📦 Universal Pipeline Plugins (Cloud Artifacts)

When dealing with non-ABAP files or Cloud endpoints (like S4 Cloud Form Templates or CPI artifacts), the proxy daemon routes binary blobs through a Universal Pipeline. You can configure and manage custom plugin rules by inserting them into the `sap_custom_pipeline_plugins` SQLite table.

Example SQL mapping script to register a pipeline plugin rule:
```sql
INSERT INTO sap_custom_pipeline_plugins (uri_pattern, unpack_plugin, package_plugin, push_plugin)
VALUES ('/api/v1/CloudArtifacts/*', 'builtin:zip', 'builtin:zip', 'builtin:none')
ON CONFLICT(uri_pattern) DO UPDATE SET
    unpack_plugin = excluded.unpack_plugin,
    package_plugin = excluded.package_plugin,
    push_plugin = excluded.push_plugin;
```
*(Note: You can execute this query using the `sap_execute_local_sqlite` tool or standard SQL management tools).*

### Implemented Built-In Plugins
The following are the currently supported strings for `unpack_plugin` / `package_plugin` / `push_plugin` values:
- **`builtin:zip`**: In-memory generic `.zip` extraction and packaging. (Valid for Unpack & Package stages).
- **`builtin:none`**: Fallthrough/No-Op. Acts as a raw pass-through returning the exact binary blob without modification. (Valid for Unpack, Package, and Push stages. For Push, it is equivalent to the legacy `raw_binary` value).
- **`json_base64:<key>`**: Takes the raw packaged binary, Base64 encodes it, and wraps it in a JSON payload where the provided `<key>` stores the string. (Valid ONLY for Push stage).
- **`cmd:<shell_command>`**: Spawns an external OS process to perform unpacking/packaging. The proxy automatically appends standard arguments to the command at execution time:
  - **For `unpack_plugin`**: Executes `<shell_command> <input_file_path> <output_dir_path>`. Your script MUST read the raw binary from `input_file_path`, extract its contents, and save the individual files into `output_dir_path`.
  - **For `package_plugin`**: Executes `<shell_command> <input_dir_path> <output_file_path>`. Your script MUST read the folder structure at `input_dir_path`, bundle them into a payload, and write the final compiled blob to `output_file_path`.

## 🛠️ Managing Custom Object Types (SQLite-backed)

To register or modify custom/Z-object type mappings and file extension rules dynamically in the workspace SQLite database, use the `sap_manage_object_type_config` tool.

### Action Types
- **`create`**: Add a new mapping (requires `object_type` and `extension`).
- **`read`**: Retrieve the details of an existing mapping.
- **`update`**: Modify specific fields of an existing mapping.
- **`delete`**: Remove a mapping.
- **`list`**: View all custom configurations.

### Advanced Mapping Patterns
When calling the tool with `action = "create"` or `update`, you can supply patterns for path matching and URI building:

1. **`uri_patterns`**: An array of regex strings matched against the incoming ADT URI to identify the object type (e.g. `["(?i)/zfoo/sources"]`).
2. **`adt_templates`**: An array of `AdtTemplateRule` structures mapping object names to URI templates.
   - **Regex Captures**: Match patterns can use capture groups, and templates can reference them using `$1`, `$2`, etc. (e.g. pattern `^(\d{3})\(([^()]+)\)$` with template `/sap/bc/adt/messages/$2/$1`). The tool automatically URL-escapes dynamic replacements. Use `$0` for the entire matched string.
   - **Discovery Resolution**: Templates can trigger standard dynamic discovery categories by prefixing with `discovery:<category>:<term>:<fallback_template>`. E.g., `discovery:http://www.sap.com/adt/categories/oo:classes:/sap/bc/adt/oo/classes/$0` resolves the URI dynamically via ADT discovery if supported by the system, falling back to the path if unavailable.

*Note: The tool pre-compiles all regular expressions and validates that extensions start with a dot (`.`) before committing, rejecting corrupt payloads immediately.*

### Example Tool Call payload
To register a new custom object type `ZMSB` that represents XML files, matches the path `/zmsb/sources`, and resolves URIs using a regex-capture message mapping:

```json
{
  "workspace_dir": "<workspace_dir>",
  "action": "create",
  "object_type": "ZMSB",
  "extension": ".xml",
  "uri_patterns": ["(?i)/zmsb/sources"],
  "adt_templates": [
    {
      "pattern": "^(?i)(\\\\d{3})\\\\(([^()]+)\\\\)$",
      "template": "/sap/bc/adt/messageclass/$2/messages/$1"
    }
  ]
}
```

## 🌐 Managing WebGUI Deep-Link Templates (SQLite-backed)

To register, modify, or delete WebGUI deep-link mappings dynamically in the workspace SQLite database, use the `sap_manage_gui_template` tool. This tool updates the `sap_custom_gui_templates` configuration table and reloads the workspace cache automatically.

### Action Types
- **`create` / `update`**: Add or update a template mapping. Requires `object_type`, `transaction_code`, and `template_string`.
- **`read`**: Retrieve the details of a single template mapping. Requires `object_type`.
- **`delete`**: Remove a template mapping. Requires `object_type`.
- **`list`**: View all registered WebGUI templates.

### Dynamic Replacements in `template_string`
The `template_string` parameter defines the transaction call command sent to SAP WebGUI. You can include dynamic placeholders that are replaced at runtime when resolving the frontend target:
- **`{object_name}`**: Replaced by the name of the SAP object.
- **`{object_type}`**: Replaced by the type of the SAP object.

### Example Tool Call payload
To register a WebGUI deep-link template for Classes (`CLAS`) invoking transaction `SE24` with the target class name pre-populated:

```json
{
  "workspace_dir": "<workspace_dir>",
  "action": "create",
  "object_type": "CLAS",
  "transaction_code": "SE24",
  "template_string": "*SE24 SEOCLASS-CLSNAME={object_name};DYNP_OKCODE=SHOW"
}
```

## 🔍 SQLite Database Schema & Troubleshooting Logs

The local SQLite database file `.sap_dev.db` is created automatically at the root of the workspace directory. Since the `sap-bridge` daemon is shipped as a compiled binary, inspecting the database tables directly using the `sap_execute_local_sqlite` tool is the recommended method to diagnose connection issues, tool failures, and inspect raw payloads.

### Key Diagnostic Tables

1. **`sap_mcp_logs`**: Tracks every MCP tool invocation executed by the daemon. Use this table to inspect what parameters were passed and what responses or errors were returned.
   * **Columns**:
     * `id` (INTEGER PRIMARY KEY AUTOINCREMENT)
     * `tool_name` (TEXT) - Name of the invoked MCP tool.
     * `parameters` (TEXT) - JSON string of parameters passed to the tool.
     * `response` (TEXT) - JSON string of the returned tool response.
     * `error_message` (TEXT) - The error message if the tool failed.
     * `is_error` (BOOLEAN) - `1` if the tool execution encountered an error, otherwise `0`.
     * `created_at` (TIMESTAMP) - Timestamp of execution.

2. **`sap_adt_logs`**: Logs raw HTTP traffic between the daemon and the SAP ADT backend. Use this table when debugging network-level or authorization errors (such as HTTP 403, 404, or 500).
   * **Columns**:
     * `id` (INTEGER PRIMARY KEY AUTOINCREMENT)
     * `system_id` (TEXT) - Target SAP system ID (e.g. `TD1`).
     * `method` (TEXT) - HTTP method (e.g. `GET`, `POST`, `PUT`, `DELETE`).
     * `url` (TEXT) - ADT endpoint path.
     * `status_code` (INTEGER) - HTTP response status code.
     * `request_body` (TEXT) - Raw HTTP request body.
     * `response_body` (TEXT) - Raw HTTP response body.
     * `created_at` (TIMESTAMP) - Timestamp of request.

3. **`sap_source_versions`**: Records local staging version history, ETags, and code events (e.g. PUSH, FETCH, ACTIVATION).
   * **Columns**:
     * `id` (INTEGER PRIMARY KEY AUTOINCREMENT)
     * `system_id` (TEXT)
     * `object_uri` (TEXT)
     * `object_type` (TEXT)
     * `version` (INTEGER)
     * `source_text` (TEXT) - The source code contents.
     * `source_hash` (TEXT) - MD5 hash of the source code.
     * `etag` (TEXT) - The backend ETag value.
     * `event` (TEXT) - Action type (e.g. `FETCH`, `PUSH`, `ACTIVATION`, `LOCAL_DRAFT`).
     * `transport` (TEXT) - Transport request number.
     * `file_path` (TEXT) - Path to the local file.
     * `is_active` (BOOLEAN)
     * `created_at` (DATETIME)

### Example Diagnostic Queries

Run these queries using `sap_execute_local_sqlite` with the `query` and `workspace_dir` parameters:

* **Query the latest MCP tool failures**:
  ```sql
  SELECT id, tool_name, parameters, error_message, created_at 
  FROM sap_mcp_logs 
  WHERE is_error = 1 
  ORDER BY id DESC 
  LIMIT 5;
  ```

* **Query the latest ADT communication errors**:
  ```sql
  SELECT id, system_id, method, url, status_code, response_body, created_at 
  FROM sap_adt_logs 
  WHERE status_code >= 400 
  ORDER BY id DESC 
  LIMIT 5;
  ```

* **Inspect the version timeline for a specific SAP object**:
  ```sql
  SELECT version, event, transport, comment, created_at 
  FROM sap_source_versions 
  WHERE object_uri = '/sap/bc/adt/programs/programs/ztest' 
  ORDER BY version DESC;
  ```

## 🛠️ Customizing CRUD Operations (SPRO / SM30 / SM34)

When maintaining customizing tables, views, or view clusters, follow this dynamic step-by-step workflow:

### 1. Schema Discovery & Context Exploration
Before performing modifications, discover the target activity, structure, check tables, and domain constraints:

*   **SPRO Node Search (`sap_search_customizing_node`)**: Search the SPRO hierarchy by business term or description to resolve the navigation path, maintenance objects, and technical activity details (`activity`, `transaction`, `object_name`, `object_type`, `maint_transact`):
    ```json
    sap_search_customizing_node(
      workspace_dir: "<workspace_dir>",
      query: "Payment Card",
      max_results: 10
    )
    ```
*   **Structural Schema Discovery (`sap_get_customizing_schema`)**: Retrieve key fields, maintenance type (`1` for 1-step, `2` for 2-step), screen numbers (`OVERVIEW_SCREEN`, `DETAIL_SCREEN`), check tables, and domain value lists:
    ```json
    sap_get_customizing_schema(
      workspace_dir: "<workspace_dir>",
      customizing_target: "TB034"
    )
    ```
*   **Documentation & Field Definitions (`sap_explore_customizing`)**: Review official SAP customizing documentation, underlying table structures, and sample records:
    ```json
    sap_explore_customizing(
      workspace_dir: "<workspace_dir>",
      customizing_target: "TB034"
    )
    ```

### 2. Permissions & Object Guard Pre-Flight
Mutating customizing operations require prior authorization in the SAP-Bridge Web UI:
*   **Bulk Permission Request (`sap_request_customizing_permissions`)**: Submit pending requests for required customizing tables or views. This registers the target in the user's **Customizing** tab in the Web UI:
    ```json
    sap_request_customizing_permissions(
      workspace_dir: "<workspace_dir>",
      requests: [
        {
          "object_name": "TB034",
          "object_type": "VIEW",
          "description": "Maintain Payment Card Categories"
        }
      ]
    )
    ```
*   **CTS Transport Request Binding**: Once the user selects and approves an open Transport Request for the object in the Web UI, all subsequent execution tools automatically bind that approved Transport Request.

### 3. Declarative Data Maintenance Execution

#### A. Declarative Table Maintenance (`sap_gui_maintain_table`)
For standard single-step and two-step maintenance views (`SM30`), maintain entries declaratively:
```json
sap_gui_maintain_table(
  workspace_dir: "<workspace_dir>",
  table_name: "TB034",
  action: "INSERT",
  fields: {
    "CCINS": "ZVISA",
    "CCTYP": "01",
    "XCHECK": "X"
  }
)
```
*   **Supported Actions**: `INSERT`, `UPDATE`, `DELETE`, `TRANSLATE`, `READ`.
*   **Pre-Selection & Positioning**: Pass `position_key` (e.g., `{"CCINS": "ZVISA"}`) to scroll directly to a specific row, or `pre_selection` for views requiring initial filter criteria.

#### B. View Cluster Maintenance (`sap_gui_maintain_cluster`)
For hierarchical multi-level view clusters (`SM34`), specify the parent key, target sub-object, and child fields:
```json
sap_gui_maintain_cluster(
  workspace_dir: "<workspace_dir>",
  cluster_name: "VC_T005",
  sub_object: "V_T005S",
  parent_key: {
    "LAND1": "DE"
  },
  action: "INSERT",
  fields: {
    "BLAND": "99",
    "BEZEI": "Custom Region"
  }
)
```

#### C. Smart Sequence Engine (`sap_gui_execute_sequence`)
For multi-step flows, work-area subsets, batch operations, or specialized customizing transactions, execute declarative sequence templates with JSON parameter hydration:
```json
sap_gui_execute_sequence(
  workspace_dir: "<workspace_dir>",
  sequence_name: "SM30_NEW_ENTRIES",
  parameters: {
    "VIEWNAME": "TB034",
    "ROWS": [
      { "CCINS": "ZMC", "CCTYP": "01" },
      { "CCINS": "ZAMEX", "CCTYP": "02" }
    ]
  },
  system: "NPL",
  client: "001"
)
```

##### Pre-Seeded Canonical Sequence Catalog (SQLite)
The daemon comes pre-seeded with 12 canonical sequences (`category = 'CUSTOMIZING'`, `is_system = 1`):
1.  **`SM30_DISPLAY_VIEW`**: Opens an SM30 table/view in display mode. Requires `VIEWNAME`.
2.  **`SM30_NEW_ENTRIES`**: Enters single-step new entries screen, fills rows, and saves. Requires `VIEWNAME`, `ROWS`.
3.  **`SM30_UPDATE_ROW`**: Positions to existing row, updates field values, and saves. Requires `VIEWNAME`, `POSITION_FIELDS`, `FIELDS`.
4.  **`SM30_DELETE_ROW`**: Positions to existing row, selects row, deletes, and saves. Requires `VIEWNAME`, `POSITION_FIELDS`.
5.  **`SM30_TWOSTEP_NEW_ENTRY`**: Enters two-step overview, switches to detail subscreen, fills fields, and saves. Requires `VIEWNAME`, `FIELDS`.
6.  **`SM30_TWOSTEP_UPDATE_ROW`**: Positions to existing row in overview, navigates into detail view, modifies fields, and saves. Requires `VIEWNAME`, `POSITION_FIELDS`, `FIELDS`.
7.  **`SM30_TWOSTEP_DISPLAY_DETAIL`**: Positions and displays detail view for a specific row. Requires `VIEWNAME`, `POSITION_FIELDS`.
8.  **`SM34_MAINTAIN_CLUSTER`**: Opens SM34 cluster, navigates sub-object tree, and displays data. Requires `CLUSTERNAME`, `SUBOBJECT`.
9.  **`SM34_NAVIGATE_SUBVIEW`**: Selects parent row in primary view, navigates object hierarchy to child subview. Requires `CLUSTERNAME`, `POSITION_FIELDS`, `SUBOBJECT`.
10. **`SM30_WORK_AREA_MAINTAIN`**: Handles views requiring initial work area popups (`wnd[1]`), fills work area keys, and displays overview. Requires `VIEWNAME`, `WORK_AREA_FIELDS`.
11. **`SM30_TRANSLATE_TEXT`**: Selects existing row, triggers Translation menu, fills language texts, and saves. Requires `VIEWNAME`, `POSITION_FIELDS`, `FIELDS`.
12. **`OS55_REVISION_LEVELS`**: Maintains material revision levels via direct transaction OS55. Requires `MATNR`, `ROWS`.

##### Sequence Template Management
*   **Inspect Sequence Manual**: Call `sap_gui_get_sequence(name: "SM30_NEW_ENTRIES")` to view step blueprints, dynpro transitions, and parameter usage documentation.
*   **Register Custom Sequences**: Call `sap_gui_save_sequence(name: "...", description: "...", category: "CUSTOMIZING", sequence_json: "...")` to store project-specific workflows.

#### D. Direct Backend RPC Maintenance (`sap_maintain_customizing`)
When GUI automation is not required and direct backend RFC execution (`VIEW_MAINTENANCE_GIVEREC_RFC`) is preferred:
```json
sap_maintain_customizing(
  workspace_dir: "<workspace_dir>",
  customizing_target: "TB034",
  action: "INSERT_UPDATE",
  entries: [
    { "CCINS": "ZVISA", "CCTYP": "01", "XCHECK": "X" }
  ]
)
```

### 4. Interactive Diagnostics & Scripting Reference
*   **Prerequisites & Troubleshooting**:
    *   **SAP GUI for Java**: An active instance of SAP GUI for Java must be running on the host workstation with an open session logged into the target system and client.
    *   **Java Runtime / JDK (Java 17+)**: A Java runtime (version 17 or higher) with diagnostic tools (`jps`, `jcmd`) must be available in system `PATH` or configured via `JAVA_HOME`.
    *   **Recovery Flow**: If `sap_gui_status` reports `OFFLINE` or returns `no running SAP GUI for Java process found`, instruct the user to verify Java 17+ in `PATH`/`JAVA_HOME` and start SAP GUI for Java with an active connection to the target system.
*   **Bridge Status & Active Sessions**: Use `sap_gui_status` to monitor connection state, open session IDs, and active programs.
*   **Inspect Dynpro Component Tree**: Use `sap_gui_inspect(capture_screenshot: true)` to inspect UI elements, technical control IDs (`/app/con[0]/ses[0]/wnd[0]/usr/...`), and visual layouts.
*   **Read Table Data**: Use `sap_gui_read_table(table_id: "...", max_rows: 50)` to extract tabular records directly from Dynpro table controls or ALV grids.
*   **Single-Step Actions**: Use `sap_gui_action(action_type: "click" | "press_vkey" | "set_text")` to test individual UI operations.
*   **Scripting Manuals**: For low-level control contracts, refer to [references/gui_scripting/INDEX.md](./gui_scripting/INDEX.md) and [references/gui_scripting/CHEAT_SHEET.md](./gui_scripting/CHEAT_SHEET.md) for official control types, method contracts (`GuiTableControl`, `GuiGridView`, `GuiTree`), and Virtual Key (`VKey`) mappings.

### 5. Transport Request & Client Settings Routing
Customizing changes must be locked in a transport request of the correct category:
*   **Client-Specific Customizing**: Target a **Customizing Request** (type `W` in this system's translation) for client-dependent views or tables.
*   **Cross-Client Customizing**: Target a **Workbench Request** (type `K` in this system's translation) for cross-client objects.
*   **Translation Mismatch Check**: Verify domain values for `TRFUNCTION` in domain `TRFUNCTION` via `sap_select_data` if the transport organizer rejects the request category.
*   **Virtual Systems**: Map transportable requests to the target systems configured in TMS (e.g., active consolidation paths or virtual targets).

### 6. Key Constraints & Allowed Namespaces
*   **Cardinality Rules**: Verify the primary keys of the underlying base table. When a duplicate key error is thrown, it indicates that the base table key (e.g., `CCINS` in `TB033`) is already registered in the database.
*   **Allowed Namespaces**: When adding test keys, prefix them using customer namespaces (e.g. keys starting with `Y` or `Z`) to bypass namespace validation warnings.

