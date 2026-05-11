# ATC Remediation Protocol

This document formalizes the autonomous workflow for resolving ABAP Test Cockpit (ATC) queue findings.

When an AI Agent is tasked with an ATC Remediation run, it MUST strictly adhere to the following deterministic lock-and-resolve workflow:

## 1. Sandbox Initialization
Constrain your edits exclusively to the local workspace to draft and test your code refactoring. Always verify if the system has write-authorization enabled via the backend system settings before assuming deployment mechanics are available.

- **Unified Staging**: All structural checkouts are staged exactly at: `./src/<system_id>/`.
- **CRITICAL DISTINCTION**: Treat this specific folder as a formal deployment staging area that must be permanently preserved within `./src/`. Exempt this directory from all general "Workspace Sanitization" routines.
- **Draft Staleness Pre-Flight**: If you pause and resume work on an existing file inside `./src/` at a later time, you MUST execute `sap_diff_versions` with `to_version=-1` before editing it. If the backend has changed, the file is stale and you must fetch the latest version to merge your drafted fixes.

## 2. Queue Checkout & Collision Locks
The ATC dashboard engine supports an active, live swarm of multiple LLM agents mutating different source files parallelly. 
- You MUST fetch finding batches exclusively via `sap_fetch_atc_queue` using your randomly generated UUID `agent_id` with `checkout` set to true.
- Operating strictly on grouped batched finding checks prevents asynchronous network thrashing; the proxy automatically locks all associated file errors into `IN_PROGRESS` simultaneously.
- **Iterative Refactoring**: The payload returned from a checkout automatically overrides tool limits to yield the *entirety* of that specific file's structural errors. You MUST aggressively tackle findings iteratively (method-by-method or finding-by-finding). You do not need to formulate a single, unified architectural patch for the entire file at once if it overwhelms your reasoning. Solve the problems step-by-step.
- Your tooling anchors around the precise internal integer `id` for each finding. Do not rely exclusively on string URIs.
- **Locating Findings**: Because the local staging environment deliberately flattens all internal method includes into a single massive `source/main` file, you MUST NOT rely on line numbers to navigate to findings. Instead, use full-text searches for the injected `* @ATC[ID]` comments to resolve boundaries.
- **Pre-Assigned Findings**: If a human user explicitly assigns an `id` that fails the queue checkout, explicitly pull a fresh copy of the live source code by re-running `sap_fetch_atc_queue` for that specific object. This dynamic fetch ensures the `@ATC[ID]` integer markers are accurately woven so you operate strictly upon valid diagnostic anchors.

## 3. The Universal 5-Step Batched Remediation Heuristic
To guarantee structurally sound codebase patches for the batch, you MUST strictly enforce this inescapable discovery loop:

1. **Quick Fix First**: Always poll `sap_atc_quick_fix` (for ATC findings) or `sap_syntax_quick_fix` (for syntax errors) against the underlying `finding_uri`. These tools return evaluations. If SAP provides an explicit system rewrite suggestion, aggressively use it to guide your local refactoring or apply it if write permissions are enabled.
2. **Documentation Fetch**: Read SAP's official documentation via `sap_atc_documentation` using the numeric `finding_id` for explicit root-cause context.
3. **DDIC & Where-Used Check**: If the finding implies dealing with database tables, key maps, or missing architectures, strictly rely on backend metadata verification. Explicitly poll `sap_fetch_ddic` or `sap_where_used` to extract the required structure dynamically.
4. **Syntax Verification**: Make your file modification resolving the batch. Then, you MUST pipe the resulting block through `sap_check_syntax` (offline engine valid) to structurally guarantee it compiles.
5. **The Remediation Priority Hierarchy**: You must resolve findings by strictly descending through this decision tree. You are expected to be transparent about the final status. Do not misrepresent the resolution method:
   - **Priority 1: SAP Quick-Fix (`REFACTORED`)**: If `sap_atc_quick_fix` provides an explicit native rewrite, apply it.
   - **Priority 2: Structural Refactoring (`REFACTORED`)**: If the root cause is clear and can be resolved by rewriting the logic, do so.
   - **Priority 3: Suppression (`PRAGMA`)**: If refactoring is illogical, too invasive, or SAP documentation explicitly recommends a pseudo-comment (e.g., `#EC CI_SORTSEQ` for an already sorted table), inject the pragma and use this status.
   - **Priority 4: Escalation (`REVIEW_REQUIRED`)**: If the finding involves high-risk complex logic changes (e.g. method signature changes with many dependencies, large refactoring, etc.), use this status.

## 4. Deployment Handoff & Matrix Closure
Depending on the system settings, write operations onto SAP may be disabled. In those cases, your official task ends with preparing the deployment package for the human owner. If writes are enabled, use `sap_push_source` to update the backend directly.
- Explicitly execute `sap_update_atc_status` locally over `sap-bridge`. Mark the successfully parsed finding metrics as `REFACTORED` internally inside the SQLite Vault.
- Instruct the Human user formally indicating your local scripts within the `./src/<system_id>/` folder are structurally compliant, signed-off offline, and ready for a physical manual push out to their proprietary SAP deployment pipelines.
