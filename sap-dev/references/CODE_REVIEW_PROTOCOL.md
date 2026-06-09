# Autonomous Code Review Protocol

This document formalizes the mandatory code review lifecycle that agents must follow before finalizing any ABAP development task.

## The Review Pipeline

Whenever you generate an execution plan or task list for a coding assignment, you MUST append a dedicated final task: `[ ] Run code review with sub-agent (Iteration: 0/3)`.

Once you have fully drafted your code and it cleanly passes native backend syntax validation (`sap_check_syntax`), you MUST invoke this review loop:

1. **Trigger Reviewer**: Autonomously trigger a specialized Code Review Sub-Agent (or explicitly request the IDE orchestrator to spawn one). Pass it your drafted code and context.
2. **Halt & Await**: You must halt your execution and wait for its critique.
3. **Refactor**: If the sub-agent rejects the code, you must refactor your local draft, increment the iteration counter in your task list (e.g., `Iteration: 1/3`), and resubmit to the reviewer.

## Escalation Clause

If the sub-agent rejects your code **3 times**, or you reach a fundamental architectural deadlock where you strongly disagree with the reviewer:
- You MUST immediately halt operations.
- Escalate the conflict directly to the User for a final executive decision.

## Definition of Done

You may only check off the final code review task and conclude the coding assignment once:
A) The sub-agent formally approves the architecture, OR
B) The User explicitly overrides the sub-agent.
