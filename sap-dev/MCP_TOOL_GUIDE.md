# MCP Tool Abstraction Guide

Because the backend toolkit is dynamically aggregated through a proxy, use this guide to map standard SAP contexts into explicit tool parameters safely. As the proxy layer is shipped as a closed-source compiled binary, you cannot inspect the go routines. 

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

## ⚙️ General Tool Invocation Mechanics

1. **ABAP Node Targeting**: Always explicitly resolve string offset locations dynamically. When replacing or investigating code blocks, locate their exact boundaries `StartLine` and `EndLine` first by using `sap_ast_query`. Extract the structural boundaries from the tool, and then execute standard `multi_replace_file_content` logic exactly targeting those isolated lines. Alternatively, for surgical, single-statement changes, use `sap_ast_replace` with `target_node_type="Statement"` to cleanly mutate without complex line-boundary calculations.
2. **Fail-Fast Interception**: The `sap-bridge` operates on dynamic Atom Discovery. If an MCP tool returns a `failfast:` error (saying an advanced parameter isn't supported on the connected backend), actively re-evaluate the parameter payload, omit the unsupported advanced filters from the tool call, and execute generalized JSON response filtering locally instead.
3. **Discovering Object URIs**: Multiple tools (Syntax, Quick Fix, Debugger, Element Info) require a valid ADT Object URI (e.g., `/sap/bc/adt/programs/programs/ztest/source/main`). You can dynamically discover these by:
   - **Inspecting ATC Findings**: When resolving ATC queue findings using `sap_fetch_atc_queue`, the `object_uri` is provided in the payload representing the offending file.
   - **Structural Outlines**: If you only have the name of an object (e.g., `ZCL_MY_CLASS`), you can use `sap_get_object_outline` to retrieve the JSON outline, which maps every method and include to its respective ADT Object URI.
   - **Search Tooling**: You can use `sap_search_objects` to find the object and its root URI, then drill down.
4. **Syntax Validation**: When running `sap_check_syntax`, aggressively utilize the `no_warnings=true` parameter. This filters out legacy warnings ('W' and 'I' severity) and strictly isolates critical syntax errors ('E' and 'A'), allowing you to remain focused on relevant remediation blockers.
5. **Handling Massive Payloads (Spillover)**: If an MCP tool returns a payload exceeding safe token limits (40KB), it will automatically write the full raw payload to `./tmp` and return a lightweight `skeleton_preview` in the same response. This proactive JSON skeleton aggressively optimizes the payload for your context window:
   - **Horizontal Deduplication**: If an array contains many structurally identical objects, the skeleton keeps only the first example. It extracts the identifiers (e.g., `name`, `object_name`, `log_number`) of all the deleted objects and appends them to the array inside an `{"_omitted_identifiers": [...]}` object so you maintain full horizontal visibility of what was dropped.
   - **Vertical Depth Limits**: If the JSON tree exceeds 4 levels of depth, the skeleton stops recurring and replaces the nested child with `<depth limit reached: use sap_query_json to explore deeper>`.
   - **Drilling Down**: Use the `sap_query_json` tool with GJSON paths against the exact dumped file in `./tmp` if you need to extract the raw, un-collapsed data that the skeleton truncated.
6. **ADT Object Structure & Source Fetching Mechanics**:
   - **Atomic vs Structured Objects**: `sap_get_object_outline` works exclusively for complex structured objects like Classes (`CLAS`), Programs (`PROG`), and Function Groups (`FUGR`). It will fail with an `HTTP 404 Not Found` for atomic objects like Data Elements (`DTEL`), Domains (`DOMA`), or specific Function Modules (`FUNC`). For atomic dictionary objects or specific Function Modules, you MUST use `sap_fetch_source` (or `sap_fetch_ddic` for tables) directly.
   - **Function Groups (FUGR)**: Function Groups are containers. You cannot use `sap_fetch_source` directly on a Function Group's `source/main` URI because it doesn't represent a linear source file. You MUST use `sap_get_object_outline` on the Function Group to discover its specific Include files and Function Modules, and then call `sap_fetch_source` on those specific child URIs.
