---
description: SAP ABAP Developer Agent
name: sap-dev
---

# SAP Development Skill

This skill grants you the ability to interact with the SAP backend using standard MCP tools exposed by the local `sap-bridge` daemon.

## 🛡️ Core System Constraints

0. **Workspace Initialization**: If any SAP MCP tool returns a `WORKSPACE_UNINITIALIZED` error, you MUST immediately call `sap_set_workspace` and provide the absolute path to your active workspace folder. This establishes your execution context and unlocks all other tools.
1. **Live Object Verification**: Always validate the exact name and interface of any SAP object (BAdI, Class, Function Module, Table) by querying the live SAP backend using `sap_search_objects` or `sap_fetch_source`. Base your architectural proposals strictly on the objects and structures you have actively retrieved and confirmed during the current session.
2. **Workspace Hygiene**: Always redirect generated assets to their correct structured endpoints. Place generated documentation into `./docs/` and generated ABAP files into `./src/`. For general temporary files, strictly use the `scratch/` directory provided by your AI environment. As a fallback, use the `./tmp/` directory at the project root.
4. **Tool Execution Limitations**: Rely exclusively on your built-in MCP tool capabilities to interact with the backend, as the IDE manages the `sap-bridge` Stdio connection automatically in the background.

## 💻 ABAP Development Standards
1. **Draft Staleness Pre-Flight**: On write-enabled systems, every new editing iteration should begin with a fetch of the latest version. You MUST execute `sap_fetch_source` (with `for_editing=true`) to pull the latest live code and establish a fresh ETag baseline *before* making any local modifications. If you edit a pre-existing local source file first, you risk losing your changes when a stale ETag collision forces a re-fetch at push time.
2. **Definition of Done**: When instructed to modify or generate ABAP code, you must first validate the proposed code's syntactical correctness via the native ADT pre-flight syntax check. A task is NOT done until the modified code cleanly passes all syntax checks.
3. **Missing SAP Objects**: If `sap_check_syntax` returns `ADT System refused to process syntax check: Ressource does not exist` or `invalid URI`, the foundational Repository Object does not exist in the target system. Rely exclusively on exporting the generated code to `./src/`, strictly instruct the User to physically initialize the empty Repository Object in SAP GUI/Eclipse, and await their confirmation before re-evaluating.
4. **Modern ABAP Language**: Always utilize modern ABAP backend features appropriately (e.g., inline declarations `DATA(...)`, constructor operators `VALUE #()`, `REDUCE`, functional table expressions `itab[ ... ]`, and string templates `|...|`) rather than falling back on legacy NetWeaver procedural constructs.
5. **ABAP Coding Standards**: Strictly prioritize: (1) ABAP Classes and BAdIs, (2) Function Modules / BAPIs, (3) Direct Table Access. 
6. **Pay Attention To Return Codes and Exceptions**: You must address return codes, exceptions, `BAPIRET` messages and the like returned by subroutines.
7. **Function Module Signatures**: When editing or creating Function Modules, Eclipse ADT might generate comments like `" You can use the template 'functionModuleParameter' to add here the signature!"`, you MUST define the parameters explicitly via a plain inline signature within the `FUNCTION` statement (e.g., `FUNCTION Z_MY_FUNC IMPORTING VALUE(IV_PARAM) TYPE STRING.`).
8. **Autonomous Code Review Pipeline**: Whenever you generate an execution plan or task list for a coding assignment, you MUST append a dedicated final task: `[ ] Run code review with sub-agent (Iteration: 0/3)`. Once you have fully drafted your code and it passes the syntax validation, you must autonomously trigger a specialized Code Review Sub-Agent (or explicitly request the IDE orchestrator to spawn one) and pass it your drafted code and context. You must halt and wait for its critique. If the sub-agent rejects the code, you must refactor your local draft, increment the iteration counter in your task list (e.g., `Iteration: 1/3`), and resubmit. **Escalation Clause**: If the sub-agent rejects your code 3 times, or you reach a fundamental architectural deadlock, you must immediately halt and escalate the conflict to the User for a final executive decision. You may only check off the final code review task and conclude the assignment once the sub-agent formally approves the architecture, or the User explicitly overrides the sub-agent.

## ⚙️ Tool Invocation Mechanics

For detailed parameter values, structural node mappings, and payload handling (including Spillover/JSON Skeletons and Object URI discovery), you MUST strictly adhere to the designated procedural matrix outlined in the sub-document: `[MCP_TOOL_GUIDE.md](./references/MCP_TOOL_GUIDE.md)`.

For exact JSON return schemas of complex tools (like `sap_get_object_outline` or `sap_fetch_ddic`), read `[MCP_SCHEMAS.md](./references/MCP_SCHEMAS.md)`.

When tasked with pulling diagnostics from the Autonomous Test Cockpit (`sap_fetch_atc_queue`), you MUST strictly adhere to the designated procedural matrix outlined in the sub-document: `[ATC_REMEDIATION.md](./references/ATC_REMEDIATION.md)`.

For debugging ABAP source code using the SAP Bridge, you MUST strictly adhere to the designated procedural matrix outlined in the sub-document: `[MCP_DEBUGGER_GUIDE.md](./references/MCP_DEBUGGER_GUIDE.md)`. This guide outlines the mandatory 3-stage lifecycle to prevent global backend deadlocks.

## 🚨 Error Handling & Workarounds

1. **Handling Tool Errors**: Treat every MCP tool response containing `"is_error": true` as an active failure requiring your direct intervention. Read the error diagnostic carefully to determine the root cause. If the error identifies invalid arguments, missing parameters, or incorrect usage, correct your payload and execute the tool again. If the tool indicates a persistent systemic fault, halt your execution chain immediately and report the failure diagnostic locally or to the user.
2. **Handling Dead Ends**: If you are stuck during research or unable to resolve an architectural mapping dynamically, stop immediately. Ask the user for a hint (e.g., a transaction code, a class, a package, or an index table) to kickstart your research.
3. **Parsing Spilled Code**: You MUST strictly use the `sap_ast_query` tool to locate structural coordinates (Methods, Forms) in spilled ABAP files located in `./tmp`. This avoids regex and formatting failures inherent to generic CLI text-search tools like `grep_search`.
4. **Connection Failures**: In case SAP communication drops or fails completely, halt operations immediately and strictly inform the user waiting for manual network intervention.
5. **Agent Feedback & Bug Reporting**: If you encounter a systemic limitation, missing capability, or structural bug that blocks your progress, execute bug reporting exclusively by writing the detailed JSON failure trace and context to `./tmp/agent_feedback.md`. Instruct the User to review it and manually submit it as an issue to `https://github.com/stud0709/sap-dev-release`.
4. **Agent Sandboxes**: The `sap_simulate_snippet` tool utilizes backend sandbox containers to safely validate logic offline. 
   - **Report Sandbox**: For standard procedural snippets and classes, it relies on the `Z_AGENT_SANDBOX` executable program. If the simulator hits a `notProcessed` error or fails to resolve the URI for the `Z_AGENT_SANDBOX` report, halt the workflow and explicitly instruct the human to physically create the missing `Z_AGENT_SANDBOX` executable program in `$TMP` before continuing.
   - **Important Distinction**: `sap_simulate_snippet` is strictly designed for raw procedural blocks. If you have generated a fully formed, complete object (like a `FUNCTION`, `CLASS`, or `PROGRAM`), do **not** use `sap_simulate_snippet`. You must natively use `sap_check_syntax` to validate it directly against its existing shell in the backend.

## 🧠 Cognitive Directives (Forced Reflection)
Before making any tool calls, you MUST begin your internal `<thought>` block by explicitly categorizing your current operational mode (e.g., "Mode: Research", "Mode: Code Editing", "Mode: Debugging"). 

Based on your mode, you MUST explicitly type out the answer to its corresponding safety check:
- **Live Object Verification Rule**: "Have I validated the exact name and interface of any SAP object (BAdI, Class, Function Module, Table) by querying the live SAP backend using `sap_search_objects` or `sap_fetch_source`?"
- **If Editing/Modifying ABAP**: You must recall the [ABAP Development Standards](./SKILL.md#abap-development-standards)
- **If executing tasks covered by sub-documents**: You must recall the specific Cognitive Directives defined within those respective guides.