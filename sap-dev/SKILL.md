---
description: SAP Backend Development Agent (Relay Protocol)
name: sap-dev
---

# SAP Development Skill

This skill grants you the ability to interact with the SAP backend using standard MCP tools exposed by the local `sap-bridge` daemon.

## Workflow Rules

1. **Investigate via Tools**: Do not guess SAP structures. Always natively use the MCP tools provided by the `sap-bridge` server to query the live backend for context.
2. **Local Source of Truth**: You generate and edit ABAP code exclusively in the local `./src/` directory. Do not try to permanently write objects remotely to SAP. 
3. **Tool Execution**: Do not attempt to use `run_command` with temporary `.json` files. The IDE manages the `sap-bridge` Stdio connection automatically in the background. Simply use your built-in tool capabilities to execute endpoints (like `echo` or `sap_start_atc_check`).
4. **Definition of Done**: When instructed to modify or generate ABAP code, you must first validate the proposed code's syntactical correctness via the native ADT pre-flight syntax check. A task is NOT done until the modified structured code cleanly passes all syntax checks and is successfully saved to the `./src/` folder for the user.
5. **Conceptual Validation**: When working on a conceptual task, do not hallucinate ABAP logic. You must explicitly confirm your reasoning by cross-referencing source code and data natively in the live SAP system using your tool suite.
6. **Workspace Hygiene**: Always redirect generated assets to their correct structured endpoints: generated documentation into `./docs/`, and any generated ABAP files into `./src/`.
7. **ABAP Structural Refactoring**: Never use raw string replacements for complex structural logic chunks. Always employ a **Discover-then-Edit** flow locally: first use `sap_ast_inspect` to discover the exact structural layout and line bounds of the source, then use `sap_ast_editor` to safely parse and reconstruct the AST. Always ensure the output of your AST editing operations is written out to the `./src/` directory via the `output_path` parameter, as you **DO NOT** have direct write access to the SAP backend.
8. **Handling Dead Ends**: If you are stuck during research or unable to resolve an architectural mapping dynamically, stop immediately. Ask the user for a hint (e.g., a transaction code, a class, a package, or an index table) on where to begin researching the issue.
9. **ABAP Coding Standards**: When determining how to interact with SAP data or logic, strictly prioritize standard module-specific interfaces. Your order of preference must always be: (1) New API Classes / BAdIs, (2) Function Modules / BAPIs, (3) Direct Table Access. **Avoid write-access to tables entirely**, unless the table belongs to the customer namespace (`Z*` or `Y*`) and there is absolutely no API available.
10. **SQL Performance**: When writing OpenSQL statements, always prefer table `JOIN`s over cascaded single table access (e.g., executing `SELECT` from Table A, then using the result set to execute a subsequent `SELECT` from Table B via `FOR ALL ENTRIES` or sequential reads).
11. **Modern ABAP Language**: Be highly aware of the ABAP backend version you are connected to. Always utilize the most modern, elegant ABAP language features natively supported by that version (e.g., inline declarations `DATA(...)`, constructor operators `VALUE #()`, `REDUCE`, functional table expressions `itab[ ... ]`, and string templates `|...|`) rather than falling back on legacy procedural constructs.
12. **Naming Conventions**: Adhere strictly to any project-specific ABAP style guides provided by the customer within the workspace. If no explicit guide exists, default to clean, globally standard ABAP prefixing (e.g., `lv_`, `ls_`, `lt_` for locals, and `iv_`, `et_`, `cv_` for method parameters).
13. **Connection Failures**: In case SAP communication fails, do not switch to another system. Stop immediately and inform the user.
14. **Temporary Files**: When creating temporary files or performing intermediate file-based scratchpad work, strictly prefer using the local `./tmp/` folder. Do not pollute the root workspace with temporary artifacts.
