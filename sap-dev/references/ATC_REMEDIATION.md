# ATC Remediation Protocol

This document formalizes the autonomous workflow for resolving ABAP Test Cockpit (ATC) queue findings.

## 🧠 Cognitive Directives (Forced Reflection)
If you are operating under this ATC Remediation workflow, you MUST begin your internal `<thought>` block before any tool call by explicitly answering:
1. **Delegation Check**: "Am I about to invoke a Snippet Worker? If yes, I MUST pass the absolute file path and NEVER paste raw source code into the prompt."
2. **Quick Fix Check**: "Am I about to manually rewrite code to fix a finding? If yes, have I explicitly checked `sap_atc_quick_fix` or `sap_syntax_quick_fix` first?"


When an AI Agent is tasked with an ATC Remediation run, it MUST strictly adhere to the following deterministic hierarchical workflow. To prevent context exhaustion when a file has hundreds of findings, we explicitly define three distinct AI roles:

### Defined AI Roles
1. **The File Owner**: The primary, long-running agent instance that starts the workflow. It checks out the file, holds the lock, groups the findings, and orchestrates the other sub-agents.
2. **The Snippet Worker**: An ephemeral, short-lived sub-agent instance spawned by the File Owner. It receives a tiny, isolated code snippet (e.g., one method) and its specific findings, fixes them, returns the code, and is instantly terminated to clear memory.
3. **The Reviewer**: A separate sub-agent instance invoked at the very end to holistically audit the re-assembled file.

## 1. The Remediation Workflow

### Phase 1: Checkout & Triage (The File Owner)
- The **File Owner** wakes up and fetches finding batches exclusively via `sap_fetch_atc_queue` using its randomly generated UUID `agent_id` with `checkout` set to true.
- The proxy guarantees the File Owner locks **one specific file** exclusively, switching its findings to `IN_PROGRESS`.
- **Context Sandboxing**: The File Owner MUST NOT attempt to resolve the findings itself. Instead, it analyzes the findings manifest and relies on the injected `* @ATC[ID]` comments to group the findings by spatial locality (e.g., grouping findings by `METHOD` using `sap_ast_query`).

### Phase 2: Sequential Delegation (The Snippet Workers)
- For each spatial group (e.g., a specific method), the File Owner invokes a dedicated **Snippet Worker** sub-agent synchronously.
- **No Prompt Stuffing**: The File Owner DOES NOT extract and pass the raw code in the prompt. Instead, it passes the Snippet Worker the **absolute path to the locally staged file** (e.g., `./src/<system_id>/...`), the exact spatial boundary it is responsible for (e.g., `METHOD calculate_taxes`), and its subset of finding IDs.
- The Snippet Worker natively uses its file-reading tools (`view_file`, `sap_ast_query`) to inspect the file directly on the filesystem. It runs the iterative refactoring loops in its own pristine context window, applying patches directly to the file on disk.
- Because the File Owner starts exactly one Snippet Worker at a time synchronously, there are no file contention issues. Once the logic is refactored and saved to disk, the Snippet Worker terminates, dumping its messy conversational history.
- The File Owner simply loops and spawns a fresh Snippet Worker for the next spatial group.

## 2. The Universal 5-Step Batched Remediation Heuristic
When a **Snippet Worker** is invoked for its isolated chunk, it MUST strictly enforce this inescapable discovery loop:

1. **Quick Fix First**: Always poll `sap_atc_quick_fix` (for ATC findings) or `sap_syntax_quick_fix` (for syntax errors) against the underlying `finding_uri`. If SAP provides an explicit system rewrite suggestion, aggressively use it.
2. **Documentation Fetch**: Read SAP's official documentation via `sap_atc_documentation` using the numeric `finding_id` for explicit root-cause context.
3. **DDIC & Where-Used Check**: If the finding implies dealing with database tables, key maps, or missing architectures, strictly rely on backend metadata verification via `sap_fetch_ddic` or `sap_where_used`.
4. **Syntax Verification**: Make your file modification. Then, pipe the resulting block through `sap_check_syntax` to structurally guarantee it compiles.
5. **The Remediation Priority Hierarchy**: You must resolve findings by strictly descending through this decision tree:
   - **Priority 1: SAP Quick-Fix (`LOGIC_REWRITTEN`)**
   - **Priority 2: Structural Refactoring (`LOGIC_REWRITTEN`)**
   - **Priority 3: Suppression (`SUPPRESSED`)**: If refactoring is illogical, or SAP documentation explicitly recommends a pseudo-comment (e.g., `#EC CI_SORTSEQ`), inject the pragma.
   - **Priority 4: Escalation (`REVIEW_REQUIRED`)**: If the finding involves high-risk complex logic changes.

## 3. Holistic Source Review (The Reviewer)
Once all findings for a file are processed by the Snippet Workers, the File Owner MUST perform or delegate a final source review to a **Reviewer**:
- The Reviewer evaluates the entirely re-assembled file for architectural coherence and syntax compliance.
- **Pragma Auditing**: The Reviewer specifically audits suppression pragmas (`#EC ...`). If a pragma seems unjustified, it can reject/reopen the finding, add an explanatory comment, and force a proper structural fix.

## 4. Deployment Handoff & Matrix Closure
Depending on the active Object Guard whitelist, direct write operations onto SAP may be denied.
- Explicitly execute `sap_update_atc_status` locally over `sap-bridge`. Mark the successfully parsed finding metrics as `LOGIC_REWRITTEN` or `SUPPRESSED` internally inside the SQLite Vault.
- If `sap_push_source` throws an `UNAUTHORIZED` lock, your task ends with preparing the deployment package for the human owner. If writes are permitted, use `sap_push_source` to update the backend directly.
- Instruct the Human user formally indicating your local scripts within the `./src/<system_id>/` folder are structurally compliant and ready for push.
