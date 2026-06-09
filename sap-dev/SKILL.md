---
description: SAP ABAP Developer Agent
name: sap-dev
---

# SAP Development Skill

This skill grants you the ability to interact with the SAP backend using standard MCP tools exposed by the local `sap-bridge` daemon.

## 🛡️ Core System Constraints

1. **Workspace Initialization**: If any SAP MCP tool returns a `WORKSPACE_UNINITIALIZED` error, you MUST immediately call `sap_set_workspace` and provide the absolute path to your active workspace folder. This establishes your execution context and unlocks all other tools.
2. **Live Object Verification**: Always validate the exact name, interface, and existence of any SAP object (BAdI, Class, Function Module, Table) by querying the live SAP backend using `sap_explore_object` (for structural outlines), `sap_get_element_info`, or `sap_fetch_source`. Base your architectural proposals and code strictly on the objects and structures you have actively retrieved and confirmed during the current session.
3. **Workspace Hygiene**: Always redirect generated assets to their correct structured endpoints. Place generated documentation into `./docs/` and generated ABAP files into `./src/`. For general temporary files, strictly use the `scratch/` directory provided by your AI environment. As a fallback, use the `./tmp/` directory at the project root.
4. **Tool Execution Limitations**: Rely exclusively on your built-in MCP tool capabilities to interact with the backend, as the IDE manages the `sap-bridge` Stdio connection automatically in the background.

## 💻 ABAP Development Standards

1. **Draft Staleness Pre-Flight**: On write-enabled systems, every new editing iteration should begin with a fetch of the latest version. You MUST execute `sap_fetch_source` (with `for_editing=true`) to pull the latest live code and establish a fresh ETag baseline *before* making any local modifications. If you edit a pre-existing local source file first, you risk losing your changes when a stale ETag collision forces a re-fetch at push time.
2. **Definition of Done**: When instructed to modify or generate ABAP code, you must first validate the proposed code's syntactical correctness via the native ADT pre-flight syntax check. A task is NOT done until the modified code cleanly passes all syntax checks.
3. **Missing SAP Objects**: If `sap_check_syntax` returns `ADT System refused to process syntax check: Ressource does not exist` or `invalid URI`, the foundational Repository Object does not exist in the target system. Rely exclusively on exporting the generated code to `./src/`, strictly instruct the User to physically initialize the empty Repository Object in SAP GUI/Eclipse, and await their confirmation before re-evaluating.
4. **Modern ABAP Language**: Always utilize modern ABAP backend features appropriately (e.g., inline declarations `DATA(...)`, constructor operators `VALUE #()`, `REDUCE`, functional table expressions `itab[ ... ]`, and string templates `|...|`) rather than falling back on legacy NetWeaver procedural constructs.
5. **ABAP Coding Standards**: Strictly prioritize: (1) ABAP Classes and BAdIs, (2) Function Modules / BAPIs, (3) Direct Table Access. 
6. **Pay Attention To Return Codes and Exceptions**: You must address return codes, exceptions, `BAPIRET` messages and the like returned by subroutines.
7. **Autonomous Code Review Pipeline**: Once you have fully drafted your code and it passes syntax validation, you MUST execute a formal code review cycle. Strictly adhere to the procedural loop defined in the sub-document: `[CODE_REVIEW_PROTOCOL.md](./references/CODE_REVIEW_PROTOCOL.md)`.

## ⚙️ Tool Invocation Mechanics

For detailed parameter values, structural node mappings, and payload handling (including Spillover/JSON Skeletons and Object URI discovery), you MUST strictly adhere to the designated procedural matrix outlined in the sub-document: `[MCP_TOOL_GUIDE.md](./references/MCP_TOOL_GUIDE.md)`.

For exact JSON return schemas of complex tools (like `sap_explore_object` or `sap_fetch_atc_queue`), read `[MCP_SCHEMAS.md](./references/MCP_SCHEMAS.md)`.

When tasked with pulling diagnostics from the Autonomous Test Cockpit (`sap_fetch_atc_queue`), you MUST strictly adhere to the designated procedural matrix outlined in the sub-document: `[ATC_REMEDIATION.md](./references/ATC_REMEDIATION.md)`.

For debugging ABAP source code using the SAP Bridge, you MUST strictly adhere to the designated procedural matrix outlined in the sub-document: `[MCP_DEBUGGER_GUIDE.md](./references/MCP_DEBUGGER_GUIDE.md)`. This guide outlines the mandatory 3-stage lifecycle to prevent global backend deadlocks.

**Agent Sandboxes**: The `sap_simulate_snippet` tool utilizes backend sandbox containers to safely validate logic offline. 
- **Report Sandbox**: For standard procedural snippets and classes, it relies on the `Z_AGENT_SANDBOX` executable program. If the simulator hits a `notProcessed` error or fails to resolve the URI for the `Z_AGENT_SANDBOX` report, halt the workflow and explicitly instruct the human to physically create the missing `Z_AGENT_SANDBOX` executable program in `$TMP` before continuing.
- **Important Distinction**: `sap_simulate_snippet` is strictly designed for raw procedural blocks. If you have generated a fully formed, complete object (like a `FUNCTION`, `CLASS`, or `PROGRAM`), do **not** use `sap_simulate_snippet`. You must natively use `sap_check_syntax` to validate it directly against its existing shell in the backend.

## 🚨 Error Handling & Workarounds

1. **Handling Tool Errors**: Treat every MCP tool response containing `"is_error": true` as an active failure requiring your direct intervention. Read the error diagnostic carefully to determine the root cause. If the error identifies invalid arguments, missing parameters, or incorrect usage, correct your payload and execute the tool again. If the tool indicates a persistent systemic fault, halt your execution chain immediately and report the failure diagnostic locally or to the user.
2. **Handling Dead Ends**: If you are stuck during research or unable to resolve an architectural mapping dynamically, stop immediately. Ask the user for a hint (e.g., a transaction code, a class, a package, or an index table) to kickstart your research.
3. **Connection Failures**: In case SAP communication drops or fails completely, halt operations immediately and strictly inform the user waiting for manual network intervention.
4. **Agent Feedback & Bug Reporting**: If you encounter a systemic limitation, missing capability, or structural bug that blocks your progress, execute bug reporting exclusively by writing the detailed JSON failure trace and context to `./tmp/agent_feedback.md`. Instruct the User to review it and manually submit it as an issue to `https://github.com/stud0709/sap-dev-release`.
5. **Backend Endpoint Verification**: If you run into unexpected issues when interacting with the bridge's internally authored ABAP endpoints (like `ZCL_SAP_DEV_RPC`), fetch the backend source and compare it against the local reference copy in `.agents/skills/sap-dev/references/` (or compute a SHA256 checksum on the fly) to ensure the backend is running the correct version.

## 🧠 Cognitive Directives (Forced Reflection)

Before making any tool calls, you MUST begin your internal `<thought>` block by explicitly categorizing your current operational mode (e.g., "Mode: Research", "Mode: Code Editing", "Mode: Debugging"). 

Based on your mode, you MUST explicitly type out the answer to its corresponding safety check:
- **Live Object Verification Rule**: "Have I validated the exact name, interface, and existence of any SAP object (BAdI, Class, Function Module, Table) by querying the live SAP backend using `sap_explore_object` or `sap_fetch_source` instead of assuming its structure?"
- **If Editing/Modifying ABAP**: You must recall the [ABAP Development Standards](./SKILL.md#abap-development-standards)
- **If executing tasks covered by sub-documents**: You must recall the specific Cognitive Directives defined within those respective guides.