---
name: Source Push Guide
description: Agent reference for the SAP source push/lock/version lifecycle
---

# Source Push Guide

This document covers the workflow for safely modifying SAP ABAP source code via the sap-bridge MCP tools.

## Key Constraint

> The agent **cannot activate** objects. All pushes create **inactive versions** only. The user controls activation externally via SE80/Eclipse.

## 1. Fetch for Editing

> [!WARNING]
> On write-enabled systems, every new editing iteration should begin with a fetch of the latest version. If you edit a pre-existing local source file first, and the live code has changed, you will hit a `STALE_BASELINE` ETag collision at push time, which forces you to re-fetch and potentially lose your local edits.

Use `sap_fetch_source` with `for_editing=true` to stage source code for modification:

```
sap_fetch_source(
  object_name: "Z_TEST",
  object_type: "PROG",
  for_editing: true
)
```

This will:
- **Check write permission** — fails immediately with `WRITE_DISABLED` if writes are not enabled
- Write the source to `./src/<system_id>/<object_name>.abap`
- Record a **baseline version** (version 0) with the backend ETag in SQLite
- Return the `file_path` for immediate editing
- **No line numbers** are injected (clean ABAP syntax)

Without `for_editing`, source goes to `./tmp/` via spillover (read-only inspection).

## 2. Push Workflow

After editing the local file, push it back:

```
sap_push_source(
  object_uri: "/sap/bc/adt/programs/programs/z_test",
  source_file_path: "<absolute_path_to_edited_file>"
)
```

The tool executes this pipeline atomically:
1. **Permission check** — verifies writes are enabled for this system (Web Dashboard toggle)
2. **ETag pre-flight** — compares baseline ETag against live backend. Fails if stale.
3. **LOCK** — acquires an enqueue lock (`_action=LOCK&accessMode=MODIFY`)
4. **Transport check** — see Section 3
5. **PUT** — writes source as inactive version
6. **Version capture** — stores pushed source + new ETag in SQLite

The response contains:
- `lock_handle` — **you must pass this to `sap_unlock_source`**
- `etag` — the new backend ETag after the push
- `version` — the version number recorded

## 3. Transport Escalation

When the lock response is processed:

| Condition | Action |
|---|---|
| `IS_LOCAL = X` | Object is in `$TMP` — no transport needed, proceed |
| `CORRNR` populated | Transport already assigned — use it automatically |
| `CORRNR` empty | **STOP and ask the user** for a transport task number |

If no transport is available, the tool fails with `TRANSPORT_REQUIRED`. Ask the user:
> "This object requires a transport request. Please provide a task number."

Then retry with `transport_request` parameter.

## 4. Diff Versions

Compare any two stored versions, or compare local state against the live backend:

```
sap_diff_versions(
  object_uri: "/sap/bc/adt/programs/programs/zydzh_test",
  from_version: 0,     # baseline
  to_version: -1        # -1 = live backend
)
```

Returns a unified diff with line counts.

## 5. Unlock

After completing all edits and pushes, release the lock:

```
sap_unlock_source(
  object_uri: "/sap/bc/adt/programs/programs/zydzh_test",
  lock_handle: "<from sap_push_source response>"
)
```

The `lock_handle` is **mandatory** — it comes from the `sap_push_source` response. Do not lose it.

## 6. Write Permission

The user controls write access per-system via the SAP-Bridge Web Dashboard. If writes are disabled, `sap_push_source` will fail with `WRITE_DISABLED` before making any backend calls.

**Default: writes are disabled.** The user must explicitly enable them.

## 7. File Layout

```
./src/<system_id>/
  ├── <object_name>.abap          # Active editing file (for_editing=true)
  ├── <object_name>_v0.abap       # Version 0: baseline (FETCH)
  ├── <object_name>_v1.abap       # Version 1: first push
  └── <object_name>_v2.abap       # Version 2: second push
```

## Constraints

- **No activation** — the agent cannot activate objects
- **No transport creation** — the agent cannot create transport requests
- **Inactive saves only** — all pushes create inactive versions
- **Sequential locking** — lock one object at a time, push, then proceed to next
