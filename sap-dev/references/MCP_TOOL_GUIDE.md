# MCP Tool Abstraction Guide

Because the backend toolkit is dynamically aggregated through a proxy, use this guide to map standard SAP contexts into explicit tool parameters. As the proxy layer is shipped as a closed-source compiled binary, you cannot inspect the go routines. 

## 🎯 AST Node Mapping (`sap_ast_query`)

When extracting context boundaries (whether via ATC URIs, manual documentation, or general refactoring requests), you must map the target SAP object construct into the strict `target_node_type` parameter required by our offline parser:

| Conceptual Object Construct | ADT URI String Fragment | `target_node_type` |
| :--- | :--- | :--- |
| **Object Method** | `type=CLAS/OM` | `MethodImplementation` |
| **Form Routine** | `type=PROG/FO` | `FormRoutine` |
| **Function Module** | `type=FUGR/FF` | `FunctionModule` |
| **Interface Definition** | `type=CLAS/I` | `Interface` |
| **Class Definition** | `type=CLAS/OC` / `type=CLAS/CC` | `ClassDefinition` |
| **Single ABAP Statement** | N/A | `Statement` |

*Example ATC Workflow:* You pull an ATC finding with the signature `"file": "...#type=CLAS/OM;name=BUILD_MLV"`. You execute `sap_ast_query(workspace_dir="c:/Users/YuriyDzhenyeyev/git/sap-dev2", target_node_type="MethodImplementation", target_identifier="BUILD_MLV")` to fetch its boundary lines.
*Example Refactoring Workflow:* A user commands: "Refactor the Form Routine `CALCULATE_DISCOUNT` in program `ZTEST`." You execute `sap_ast_query(workspace_dir="c:/Users/YuriyDzhenyeyev/git/sap-dev2", target_node_type="FormRoutine", target_identifier="CALCULATE_DISCOUNT")` to locate exactly which lines the form spans before editing.

> [!NOTE]
> **Advanced Node Targeting**
> The `target_node_type` parameter is not restricted to a hardcoded enum. The `sap-bridge` passes this string directly into the open-source `@abaplint/core` parser (with minor alias conversions like `MethodImplementation` -> `Method`). If you need to target a highly specific or obscure ABAP structural block not listed above, you can pass any valid AST Node structure name defined by the `abaplint` taxonomy.

## ⚙️ General Tool Invocation Mechanics

1. **ABAP Node Targeting**: Always explicitly resolve string offset locations dynamically. When replacing or investigating code blocks, locate their exact boundaries `StartLine` and `EndLine` first by using `sap_ast_query`. Extract the structural boundaries from the tool, and then execute standard `multi_replace_file_content` logic exactly targeting those isolated lines. Alternatively, for surgical, single-statement changes, use `sap_ast_replace` with `target_node_type="Statement"` to cleanly mutate without complex line-boundary calculations.
2. **Fail-Fast Interception**: The `sap-bridge` operates on dynamic Atom Discovery. If an MCP tool returns a `failfast:` error (saying an advanced parameter isn't supported on the connected backend), actively re-evaluate the parameter payload, omit the unsupported advanced filters from the tool call, and execute generalized JSON response filtering locally instead.
3. **Universal URI Fallback**: Many tools (`sap_check_syntax`, `sap_syntax_quick_fix`, `sap_push_source`, `sap_get_element_info`, `sap_diff_versions`) natively support Universal URI Fallback. If you do not have the explicit `object_uri` (e.g., `/sap/bc/adt/programs/programs/ztest`), you can instead provide the `object_name` (e.g., `ZTEST`) and `object_type` (e.g., `PROG`) directly in the tool parameters. The bridge will automatically discover, cache, and resolve the correct backend URI for you. If a tool absolutely requires an explicit URI and does not support the fallback (e.g. Debugger tools), you can discover it by:
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
If `sap_fetch_source` spills a massive ABAP file into `./tmp/`, strictly use the offline AST workflow:
1. Find the target method using `sap_explore_object`.
2. Extract the exact method lines from the spilled `.abap` file using `sap_ast_query` (with `target_node_type="MethodImplementation"`).
3. Mutate the method locally, then inject the updated code back into the spilled file using `sap_ast_replace`.
4. Push the mutated massive file back to SAP by calling `sap_push_source` with `source_file_path` pointing to the spilled `./tmp/` file.

### System & Version Targeting
- Before invoking tools that require `system_alias`, you should call `sap_bridge_status` to safely discover the correct connected backend targets. This prevents cross-system pollution.
- `sap_fetch_source` with `for_editing=true` is purely a local staging mechanism that writes to `./src/` and safely archives unpushed drafts. It does **not** check for write permissions; write permissions are only enforced when attempting to push.
- When using `sap_diff_versions`, prefer semantic string targets: `"draft"` (local physical file), `"active"` / `"inactive"` (live backend states), or `"-1"` (latest recorded SQLite version).

### XML Discovery & Navigation
- **Navigating XML Structures**: If you call `sap_fetch_source` using a base URI and receive XML metadata instead of ABAP code, read the XML to locate the specific sub-link you need (e.g., `href="source/main"` for code, or `href=".../textelements"` for text symbols), and make a second `sap_fetch_source` call using that precise URI.

### Handling Function Modules (FUGR/FUNC)
- **Function Groups (FUGR)**: Function Groups are containers. You cannot use `sap_fetch_source` directly on a Function Group's base URI because it doesn't represent a linear source file. You MUST use `sap_explore_object` on the Function Group to discover its specific Include files and Function Modules, and then call `sap_fetch_source` on those specific child URIs.
- **Function Modules (FUNC / FUGR/FF)**: Unlike GUI-based transactions (SE37), you can programmatically edit a Function Module's signature (Parameters, Exceptions) via text. Use `sap_fetch_source` to retrieve the module's source. If the module is newly created, it may contain a comment hinting at a template. You must replace this comment with the actual pseudo-ABAP signature block injected directly below the `FUNCTION <NAME>.` statement, using this exact syntax:
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
  You can structurally mutate these blocks and execute `sap_push_source` with `object_type="FUGR/FF"` to permanently alter the backend signature. Note: Activating an altered Function Module often requires mass-activating its parent Function Group to regenerate the global interfaces.

### Raw HTTP Requests
- The `sap_execute_request` tool provides a raw sandbox for probing ADT endpoints. 
- **CRITICAL**: The ADT backend is notoriously strict about HTTP Headers (e.g. `Accept: application/atomsvc+xml` or `Content-Type`). When using `sap_execute_request`, you MUST pass headers like `Accept` and `Content-Type` using the **top-level string parameters** (`accept` and `content_type`), NOT nested inside a JSON array or dictionary parameter. 
- *Example*: `sap_execute_request(workspace_dir="c:/Users/YuriyDzhenyeyev/git/sap-dev2", uri="/sap/bc/adt/discovery", accept="application/atomsvc+xml")`


## 🛠️ Object Creation Templates (`sap_get_creation_template`)

To safely instantiate new objects on the SAP backend (whether they are DDIC tables/data elements or repository classes/programs), you must obtain and stage their XML creation templates first. 

Use `sap_get_creation_template` to fetch a clean, patch-compatible template:
```json
sap_get_creation_template(
  workspace_dir: "c:/Users/YuriyDzhenyeyev/git/sap-dev2",
  object_name: "ZBUI_MSB_APPL",
  object_type: "DTEL",
  package: "$MSB_COMPAT",
  reference_entity: "MANDT",
  system_alias: "TD1"
)
```
*   **Offline Fallback**: For standard code objects (`CLAS`, `INTF`, `PROG`, `FUGR`), the tool generates the minimal XML template completely offline, replacing the package reference inline.
*   **Dynamic Backend Copies**: For DDIC objects (`DTEL`, `TABL`, `TTYP`, `DOMA`), the tool queries the live backend using a whitelisted read-only request of the `reference_entity` (e.g. `MANDT` for data elements or `BAPIRET2` for tables) to ensure the returned template matches the exact patch level of the target system. It automatically customizes the root name and target package reference, and strips administrative tracking attributes.
*   **Safety Rewrite**: All templates generated via this tool have their version state set to `inactive` (`core:version="inactive"`), preventing backend assertion dumps (such as `ASSERTION_FAILED` in `CL_SBD_DATAELEMENT_PERSIST`) when initially pushing the shell.


## 📂 ADT Object Metadata (`sap_fetch_metadata` / `sap_push_metadata`)

When you need to read or modify non-code structural properties of SAP objects (such as RFC/Remote-Enabled properties, table/structure technical settings, domain/data element labels, class properties), use the metadata tools.

### 1. Fetching Metadata
Use `sap_fetch_metadata` to retrieve raw XML metadata:
```json
sap_fetch_metadata(
  workspace_dir: "c:/Users/YuriyDzhenyeyev/git/sap-dev2",
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
  workspace_dir: "c:/Users/YuriyDzhenyeyev/git/sap-dev2",
  object_name: "Z_MY_OBJECT",
  object_type: "FUNC",
  metadata_file_path: "c:/.../metadata/z_my_object.func.xml"
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

## 🛡️ Zero-Trust Permissions & Sandbox Handshakes

To guarantee structural safety, all structural execution pathways (pushing code, activating objects, calling APIs) are gated behind explicit UI approval mechanisms in the SAP-Bridge Web Dashboard. If a tool fails because of permission locks (`UNAUTHORIZED`), a request is added to the user's dashboard queue. Stop and instruct the user to approve the pending items in their SAP-Bridge Dashboard:
- **API Guard** section: governs `sap_execute_request`, `sap_odata_call`, and `sap_explore_odata_service`. You can proactively request multiple permissions with `sap_request_api_permissions`.
  - **Strict Routing Rules (Fast-Fail)**: Maintain architectural separation between raw endpoint calls and OData calls:
    - Route OData endpoint paths (URIs containing `/odata/` or `/sap/opu/odata/`) exclusively through `sap_odata_call` and `sap_explore_odata_service` to allow structured schema parsing and automatic token-saving optimizations.
    - Raw HTTP requests via `sap_execute_request` reject OData paths to prevent token exhaustion and ensure security schema consistency.
- **Object Guard** section: governs `sap_push_source` and `sap_activate_object`. Multiple requests can be made with `sap_request_object_permissions`.

## 🌐 OData Client Operations (`sap_odata_call` / `sap_explore_odata_service`)

To interact with business data exposed via OData services (like S/4HANA Cloud Key User APIs or custom SAP Gateway services), utilize the dedicated OData tools. These tools are optimized to prevent context bloat by stripping metadata wrappers and parsing large XML schema documents into light JSON.

### 1. Service Schema Discovery
Before querying or mutating an OData service, execute `sap_explore_odata_service` to retrieve its metadata schema. This returns a compact JSON summary of the service's EntitySets, key properties, and field types, helping you build accurate payloads.

```json
sap_explore_odata_service(
  workspace_dir: "c:/Users/YuriyDzhenyeyev/git/sap-dev2",
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
  workspace_dir: "c:/Users/YuriyDzhenyeyev/git/sap-dev2",
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
  "workspace_dir": "c:/Users/YuriyDzhenyeyev/git/sap-dev2",
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
