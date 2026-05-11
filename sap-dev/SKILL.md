---
description: SAP ABAP Developer Agent
name: sap-dev
---

# SAP Development Skill

This skill grants you the ability to interact with the SAP backend using standard MCP tools exposed by the local `sap-bridge` daemon.

## 🛡️ Core System Constraints

0. **Workspace Initialization**: If any SAP MCP tool returns a `WORKSPACE_UNINITIALIZED` error, you MUST immediately call `sap_set_workspace` and provide the absolute path to your active workspace folder. This establishes your execution context and unlocks all other tools.
1. **Local Source of Truth**: You generate and edit ABAP code exclusively in the local `./src/` directory. Constrain your edits explicitly to the local workspace; because the `sap-bridge` enforces a strict Read-Only boundary, you rely exclusively on the offline synchronization model without autonomously generating SAP database objects.
2. **Missing SAP Objects**: If `sap_check_syntax` returns `ADT System refused to process syntax check: Ressource does not exist` or `invalid URI`, the foundational Repository Object does not exist in the target system. Rely exclusively on exporting the generated code to `./src/`, strictly instruct the User to physically initialize the empty Repository Object in SAP GUI/Eclipse, and await their confirmation before re-evaluating.
3. **Workspace Hygiene**: Always redirect generated assets to their correct structured endpoints. Place generated documentation into `./docs/` and generated ABAP files into `./src/`. For general temporary files, strictly use the `scratch/` directory provided by your AI environment. As a fallback, use the `./tmp/` directory at the project root.
4. **Draft Staleness Pre-Flight**: On write-enabled systems, every new editing iteration should begin with a fetch of the latest version. You MUST execute `sap_fetch_source` (with `for_editing=true`) to pull the latest live code and establish a fresh ETag baseline *before* making any local modifications. If you edit a pre-existing local source file first, you risk losing your changes when a stale ETag collision forces a re-fetch at push time.
5. **Tool Execution Limitations**: Rely exclusively on your built-in MCP tool capabilities (like `sap_start_atc_check`) to interact with the backend, as the IDE manages the `sap-bridge` Stdio connection automatically in the background.

## 💻 ABAP Development Standards

1. **Definition of Done**: When instructed to modify or generate ABAP code, you must first validate the proposed code's syntactical correctness via the native ADT pre-flight syntax check. A task is NOT done until the modified code cleanly passes all syntax checks and is successfully saved to the `./src/` folder.
2. **Conceptual Validation**: When working on abstract logic, systematically confirm your reasoning by cross-referencing source code and data dependencies in the live SAP system using your tool suite to guarantee structural accuracy.
3. **ABAP Coding Standards**: Strictly prioritize standard module-specific interfaces. Your interaction priority must always be: (1) New API Classes / BAdIs, (2) Function Modules / BAPIs, (3) Direct Table Access. **Avoid write-access to tables directly unless specifically permitted**, preferring standard APIs or customer namespace (`Z*` or `Y*`) operations if writes are enabled on the backend.
4. **SQL Performance**: When writing OpenSQL, always prefer table `JOIN`s over cascaded single table access loops (e.g., executing `SELECT` from Table A, then looping to execute subsequent `SELECT`s from Table B avoiding `FOR ALL ENTRIES` when joins suffice).
5. **Modern ABAP Language**: Always utilize modern ABAP backend features appropriately (e.g., inline declarations `DATA(...)`, constructor operators `VALUE #()`, `REDUCE`, functional table expressions `itab[ ... ]`, and string templates `|...|`) rather than falling back on legacy NetWeaver procedural constructs.

## ⚙️ Tool Invocation Mechanics

For detailed parameter values, structural node mappings, and payload handling (including Spillover/JSON Skeletons and Object URI discovery), you MUST strictly adhere to the designated procedural matrix outlined in the sub-document: `[MCP_TOOL_GUIDE.md](./references/MCP_TOOL_GUIDE.md)`.

For exact JSON return schemas of complex tools (like `sap_get_object_outline` or `sap_fetch_ddic`), read `[MCP_SCHEMAS.md](./references/MCP_SCHEMAS.md)`.

## ATC Auto-Remediation Workflow

When tasked with pulling diagnostics from the Autonomous Test Cockpit (`sap_fetch_atc_queue`), you MUST strictly adhere to the designated procedural matrix outlined in the sub-document: `[ATC_REMEDIATION.md](./references/ATC_REMEDIATION.md)`.

## 🐞 Autonomous Debugging Protocol

When tasked with debugging ABAP source code using the SAP Bridge, you MUST strictly adhere to the designated procedural matrix outlined in the sub-document: `[MCP_DEBUGGER_GUIDE.md](./references/MCP_DEBUGGER_GUIDE.md)`. This guide outlines the mandatory 3-stage lifecycle to prevent global backend deadlocks.

## 🚨 Error Handling & Workarounds

1. **Handling Tool Errors**: Treat every MCP tool response containing `"is_error": true` as an active failure requiring your direct intervention. Read the error diagnostic carefully to determine the root cause. If the error identifies invalid arguments, missing parameters, or incorrect usage, correct your payload and execute the tool again. If the tool indicates a persistent systemic fault, halt your execution chain immediately and report the failure diagnostic locally or to the user.
2. **Handling Dead Ends**: If you are stuck during research or unable to resolve an architectural mapping dynamically, stop immediately. Ask the user for a hint (e.g., a transaction code, a class, a package, or an index table) to kickstart your research.
3. **Parsing Spilled Code**: You MUST strictly use the `sap_ast_query` tool to locate structural coordinates (Methods, Forms) in spilled ABAP files located in `./tmp`. This avoids regex and formatting failures inherent to generic CLI text-search tools like `grep_search`.
4. **Connection Failures**: In case SAP communication drops or fails completely, halt operations immediately and strictly inform the user waiting for manual network intervention.
5. **Agent Feedback & Bug Reporting**: If you encounter a systemic limitation, missing capability, or structural bug that blocks your progress, execute bug reporting exclusively by writing the detailed JSON failure trace and context to `./tmp/agent_feedback.md`. Instruct the User to review it and manually submit it as an issue to `https://github.com/stud0709/sap-dev-release`.
6. **Agent Sandbox Block (`z_agent_sandbox`)**: The `sap_simulate_snippet` tool requires a physically active executable program named `Z_AGENT_SANDBOX` stored in `$TMP`. If the simulator hits a `notProcessed` error, halt the workflow and explicitly instruct the human to physically create the empty `Z_AGENT_SANDBOX` program in SAP GUI/Eclipse before continuing.
