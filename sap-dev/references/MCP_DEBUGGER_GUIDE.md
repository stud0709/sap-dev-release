# 🐞 Autonomous Debugging Protocol

The `sap-bridge` provides a programmatic SAP ABAP debugger capable of deep backend memory expansion. However, because standard SAP ADT breakpoints globally lock work processes, the agent MUST strictly follow the 3-Stage Autonomous Lifecycle.


## Stage 1: Setup (`sap_debug_sync_external_breakpoints`)
You must begin any debugging session by initializing physical external breakpoints on the backend before execution occurs.
- First, use `sap_debug_sync_external_breakpoints` to inject external breakpoints. You must provide a JSON array: `line_breakpoints`.

## Stage 2: Anchor (`sap_debug_attach`)
- Next, use `sap_debug_attach` to start the listener and wait for the debug session to be hit. The tool will block until the session is caught.
- You can either manually trigger the application logic in the background *before* calling `sap_debug_attach` (e.g. using `run_command` with a delay), OR pass a `trigger_request` JSON payload directly into `sap_debug_attach` to have the tool automatically ping the SAP backend.
- Once caught, `sap_debug_attach` attaches the session, binds the variables, and returns the session context directly.

## Stage 3: Interact (`sap_debug_debugger_breakpoint`, `sap_debug_step`, & `sap_debug_list_breakpoints`)
Once you have the `session_id` from Stage 1:
- You may safely inject volatile, session-scoped breakpoints in bulk using `sap_debug_debugger_breakpoint`. You must provide at least one typed JSON array: `line_breakpoints`, `statement_breakpoints`, `exception_breakpoints`, or `message_breakpoints`. These disappear the moment the session ends.
- **List Breakpoints**: At any time, you can invoke `sap_debug_list_breakpoints` (optionally passing your `session_id`) to retrieve the absolute, live source-of-truth from the SAP backend regarding which breakpoints are active.
- Navigate the call stack using `sap_debug_step` with native ADT actions: `stepInto`, `stepOver`, `stepReturn`, `stepContinue`, `detachDebugger`, or `terminateDebuggee`.
- The `sap_debug_step` command will automatically evaluate the updated variable context and return it when execution pauses, eliminating the need to call `sap_debug_context` repeatedly.
- When retrieving context via `sap_debug_context`, you may optionally provide a `stack_position` (default `0`) to retrieve variables explicitly bound to a higher call stack frame.
- For deep internal tables or nested object inspection, use `sap_debug_evaluate` and provide the `parent_id` found in the context variables payload.

## Stage 4: Cleanup (`sap_debug_cleanup`)
**CRITICAL:** When you are done debugging, you MUST explicitly invoke `sap_debug_cleanup`.
- This tool safely disconnects the active `session_id`.
- You may pass a specific `breakpoint_uri` to surgically drop a single breakpoint. If omitted, the tool executes a global wipe of all external breakpoints anchored to you.
- Failure to run this cleanup will lock the ABAP source code for other users and break subsequent execution flows.

> [!WARNING]  
> If the debugging session falls completely out of control, or the agent hangs mid-execution resulting in a locked backend state, instruct the Human User to log into the SAP GUI and run the **`RSBREAKPOINTS`** report to globally wipe all orphaned external breakpoints from the database.
