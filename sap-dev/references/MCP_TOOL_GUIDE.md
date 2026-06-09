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

*Example ATC Workflow:* You pull an ATC finding with the signature `"file": "...#type=CLAS/OM;name=BUILD_MLV"`. You execute `sap_ast_query(target_node_type="MethodImplementation", target_identifier="BUILD_MLV")` to fetch its boundary lines.
*Example Refactoring Workflow:* A user commands: "Refactor the Form Routine `CALCULATE_DISCOUNT` in program `ZTEST`." You execute `sap_ast_query(target_node_type="FormRoutine", target_identifier="CALCULATE_DISCOUNT")` to locate exactly which lines the form spans before editing.

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
   - **Packages (`DEVC`)**: Passing a package name returns a recursive tree of all objects inside the package.
   - **BAdIs (`SXSD` / `ENSC`)**: Passing a Classic BAdI or Enhancement Spot maps its entire ecosystem chain (Spot -> Definition -> Interface).
   - **Classes/Interfaces (`CLAS` / `INTF`)**: Returns the method/attribute structure *and* automatically embeds the inheritance hierarchy (superclasses, implemented interfaces).
   - **Standard Objects**: Returns the JSON structural tree of methods, includes, or DDIC fields.
   - **Supported Objects**: `sap_explore_object` supports querying both complex structural containers (e.g., `CLAS`, `PROG`, `FUGR`) and atomic dictionary objects (e.g., `DTEL`, `DOMA`, `TABL`).
   - **CDS Views (`DDLS`)**: `sap_explore_object` supports architectural dependency graphing for CDS objects. It will return a highly detailed forward dependency tree mapping the underlying SQL abstractions, relationships, and functions built into the view.

5. **Handling Massive Payloads (Spillover)**: If an MCP tool returns a payload exceeding safe token limits (40KB), it will automatically write the full raw payload to `./tmp` and return a lightweight `skeleton_preview` in the same response. This proactive JSON skeleton aggressively optimizes the payload for your context window:
   - **Horizontal Deduplication**: If an array contains many structurally identical objects, the skeleton keeps only the first example. It extracts the identifiers (e.g., `name`, `object_name`, `log_number`) of all the deleted objects and appends them to the array inside an `{"_omitted_identifiers": [...]}` object so you maintain full horizontal visibility of what was dropped.
   - **Vertical Depth Limits**: If the JSON tree exceeds 4 levels of depth, the skeleton stops recurring and replaces the nested child with `<depth limit reached: use sap_query_json to explore deeper>`.
   - **Drilling Down**: Use the `sap_query_json` tool with GJSON paths against the exact dumped file in `./tmp` if you need to extract the raw, un-collapsed data that the skeleton truncated.

### Editing Massive Source Files
If `sap_fetch_source` spills a massive ABAP file into `./tmp/`, strictly use the offline AST workflow:
1. Find the target method using `sap_explore_object`.
2. Extract the exact method lines from the spilled `.abap` file using `sap_ast_query` (with `target_node_type="MethodImplementation"`).
3. Mutate the method locally, then inject the updated code back into the spilled file using `sap_ast_replace`.
4. Push the mutated massive file back to SAP by calling `sap_push_source` with `source_file_path` pointing to the spilled `./tmp/` file.

### System & Version Targeting
- Before invoking tools that require `system_id` and `sap_client`, you should call `sap_bridge_status` to safely discover the correct connected backend targets. This prevents cross-system pollution.
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
- *Example*: `sap_execute_request(uri="/sap/bc/adt/discovery", accept="application/atomsvc+xml")`

## 🛡️ Zero-Trust Permissions & Sandbox Handshakes

To guarantee structural safety, all structural execution pathways (pushing code, activating objects, calling APIs) are gated behind explicit UI approval mechanisms in the SAP-Bridge Web Dashboard. If a tool fails because of permission locks (`UNAUTHORIZED`), a request is added to the user's dashboard queue. Stop and instruct the user to approve the pending items in their SAP-Bridge Dashboard:
- **API Guard** section: governs `sap_execute_request`. You can proactively request multiple permissions with `sap_request_api_permissions`.
- **Object Guard** section: governs `sap_push_source` and `sap_activate_object`. Multiple requests can be made with `sap_request_object_permissions`.

