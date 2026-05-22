---
name: Source Push Guide
description: Agent reference for the SAP source push/lock/version lifecycle
---

# Source Push Guide

This document covers the workflow for safely modifying SAP ABAP source code via the sap-bridge MCP tools.

## 1. Fetch for Editing

Use `sap_fetch_source` with `for_editing=true` to stage source code for modification:

```
sap_fetch_source(
  object_name: "Z_TEST",
  object_type: "PROG",
  for_editing: true
)
```

This will:
- Write the source to `./src/<system_id>/<object_name>.abap`
- Record a **baseline version** (e.g. version 0) with the backend ETag in SQLite
- Return the `file_path` for immediate editing
- **No line numbers** are injected (clean ABAP syntax)

> [!TIP]
> **Draft Protection:** If you already have an unpushed local draft (a modified file in `./src/`) and you run `sap_fetch_source(for_editing=true)` again, the tool will automatically archive your local draft as a `LOCAL_DRAFT` version in SQLite before overwriting the file with the fresh backend code. You can then use `sap_diff_versions` to recover your work. (Note: Diff metrics are fully normalized, so whitespace/CRLF formatting variations are ignored).

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
1. **Permission check** — verifies the object matches the active Object Guard whitelist
2. **ETag pre-flight** — compares baseline ETag against live backend. Fails if stale.
3. **LOCK** — acquires an enqueue lock (`_action=LOCK&accessMode=MODIFY`)
4. **Transport check** — see Section 3
5. **PUT** — writes source as inactive version
6. **Version capture** — stores pushed source + new ETag in SQLite as a `PUSH` event. *(Note: Upon successful `sap_activate_object`, this event string is mutated to `ACTIVATION` in the timeline)*

The response contains:
- `etag` — the new backend ETag after the push
- `version` — the version number recorded
- `lock_handle` — returned for diagnostic/logging purposes, but the object is automatically unlocked.

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

Compare your local working draft against the live SAP backend, or compare historical versions:

```
sap_diff_versions(
  object_uri: "/sap/bc/adt/programs/programs/zydzh_test",
  from_version: "draft",     # Reads local physical file
  to_version: "active"       # Fetches live backend code
)
```

**Semantic Targets:**
- `"draft"`: The local file in `./src/...` (Default for `from_version`)
- `"active"`: Live SAP active code (Default for `to_version`)
- `"inactive"`: Live SAP inactive code
- `"-1"`, `"-2"`, etc.: Relative recent SQLite versions (e.g., `-1` is the absolute latest recorded SQLite version).
- `"1"`, `"2"`, etc.: Exact SQLite version numbers.

Returns a unified diff with line counts.

## 5. Auto-Unlock

The `sap_push_source` tool natively implements the full LOCK → PUT → UNLOCK lifecycle automatically upon success. You do not need to manually call any unlock tool after a successful push. 

## 6. Dictionary Objects (DDIC)

Standard "source-based" tools (`sap_fetch_source`, `sap_push_source`, `sap_check_syntax`, `sap_activate_object`) seamlessly support dictionary objects such as Database Tables (`TABL` / `TABL/DT`).
- **Unified Pipeline:** They share the exact same version control, ETag staleness, and auto-unlock behaviors as `CLAS` or `PROG`.
- **Syntax Check:** Running `sap_check_syntax` against a `TABL` will natively trigger ADT syntax validations (skipping the ABAP linter), correctly surfacing standard DDIC configuration warnings/errors (e.g., missing technical settings).

## 6. Zero-Trust Object Guard

Write access is governed by the SAP-Bridge **Object Guard**. Rather than a global enable/disable toggle, the user configures an explicit whitelist array of packages and prefixes (e.g. `Z*`, `Y*`) per connection. 

If an object does not match the active whitelist, `sap_push_source` will fail with an `UNAUTHORIZED` permission lock before making any backend calls. You can use the `sap_request_object_permissions` tool to ask the user to temporarily or permanently approve access to the blocked object.

## 7. File Layout

```
./src/<system_id>/
  ├── <object_name>.abap          # Active editing file (for_editing=true)
```


