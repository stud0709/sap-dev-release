---
name: Source Push Guide
description: Agent reference for the SAP source push/lock/version lifecycle
---

# Source Push Guide

This document covers the workflow for safely modifying SAP ABAP source code and metadata via the unified `sap-bridge` MCP tools.

## 1. Fetch for Editing

Use `sap_fetch` with `aspect="source"` and `for_editing=true` to stage source code for modification:

```json
sap_fetch(
  workspace_dir: "c:/Users/YuriyDzhenyeyev/git/sap-dev2",
  object_name: "Z_TEST",
  object_type: "PROG",
  aspect: "source",
  for_editing: true
)
```

This will:
- Write the source to `./src/<system_alias>/<object_name>.<type_extension>`
- Record a **baseline version** (e.g. version 0) with the backend ETag in SQLite.
- Return the resolved local `file_path` for immediate editing.
- Strip any backend line numbers (clean ABAP syntax).

> [!TIP]
> **Draft Protection:** If you already have an unpushed local draft (a modified file in `./src/`) and you run `sap_fetch(for_editing=true)` again, the tool will automatically archive your local draft as a `LOCAL_DRAFT` version in SQLite before overwriting the file with the fresh backend code. You can then use `sap_diff_versions` to recover your work.

Without `for_editing`, source goes to `./tmp/` via spillover (read-only inspection).

## 2. Push Workflow

After editing the local file, push it back to the SAP backend. **You do not need to specify the file path**—the daemon dynamically maps the object parameters to the correct local staging path:

```json
sap_push(
  workspace_dir: "c:/Users/YuriyDzhenyeyev/git/sap-dev2",
  object_name: "Z_TEST",
  object_type: "PROG",
  aspect: "source"
)
```

The tool executes this pipeline atomically:
1. **Permission check** — verifies the object matches the active Object Guard whitelist.
2. **ETag pre-flight** — compares local baseline ETag against live backend. Fails if stale.
3. **LOCK** — acquires an enqueue lock (`_action=LOCK&accessMode=MODIFY`).
4. **Transport check** — see Section 3.
5. **PUT** — writes source as inactive version.
6. **Version capture** — stores pushed source + new ETag in SQLite as a `PUSH` event.

### Class Include Scanner (Multi-File Objects)
If you push a Class (`object_type="CLAS"`) without passing a file path, the daemon automatically:
- Scans the workspace directory for the 4 standard includes (`.clas.abap`, `.clas.locals_def.abap`, `.clas.locals_imp.abap`, `.clas.testclasses.abap`).
- Compares each local include file against the latest version in the database.
- **Pushes only the modified includes sequentially in a single tool call.**

## 3. Transport Escalation

When the lock response is processed:

| Condition | Action |
|---|---|
| `IS_LOCAL = X` | Object is in `$TMP` — no transport needed, proceed |
| `CORRNR` populated | Transport already assigned — use it automatically |
| `CORRNR` empty | **STOP and ask the user** for a transport task number |

If no transport is available, the tool fails with `TRANSPORT_REQUIRED`. Ask the user:
> "This object requires a transport request. Please provide a task number."

Then retry the `sap_push` call with the `transport_request` parameter.

## 4. Diff Versions

Compare your local working draft against the live SAP backend, or compare historical versions:

```json
sap_diff_versions(
  workspace_dir: "c:/Users/YuriyDzhenyeyev/git/sap-dev2",
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

## 5. Auto-Unlock

The `sap_push` tool natively implements the full LOCK → PUT → UNLOCK lifecycle automatically upon success. You do not need to manually call any unlock tool after a successful push.

## 6. Creating New Objects (Lifecycle & Sequence)

When creating new dictionary objects (e.g. `DTEL`, `TABL`) or repository objects (e.g. `CLAS`, `PROG`, `DDLS`), follow this exact sequence to ensure permissions are whitelisted and templates stage correctly:

1. **Retrieve and Stage the Creation Template**:
   Call `sap_get_creation_template`. The tool auto-discovers a reference entity from TADIR, generates the XML creation template, and **automatically writes it** to the local metadata path `./src/<system_id>/metadata/<object_name>.<type>.xml`:
   ```json
   sap_get_creation_template(
     workspace_dir: "c:/Users/YuriyDzhenyeyev/git/sap-dev2",
     object_name: "ZBUI_MSB_APPL",
     object_type: "DTEL",
     package: "$MSB_COMPAT",
     system_alias: "TD1"
   )
   ```

2. **Customize the Metadata Locally**:
   Open the staged XML file under `./src/<system_id>/metadata/` and modify any descriptive texts or properties.

3. **Request Whitelist Permission**:
   Call `sap_request_object_permissions` to prompt the user for whitelist approval. Pass the target package explicitly in the request item:
   ```json
   sap_request_object_permissions(
     workspace_dir: "c:/Users/YuriyDzhenyeyev/git/sap-dev2",
     system_alias: "TD1",
     requests: [
       { "object_name": "ZBUI_MSB_APPL", "object_type": "DTEL", "package": "$MSB_COMPAT" }
     ]
   )
   ```

4. **Push Metadata Shell (Instantiate)**:
   Call `sap_push` with `aspect="metadata"`. The daemon resolves the staged XML and sends it to the ADT collection to instantiate the empty shell on the SAP backend:
   ```json
   sap_push(
     workspace_dir: "c:/Users/YuriyDzhenyeyev/git/sap-dev2",
     object_name: "ZBUI_MSB_APPL",
     object_type: "DTEL",
     aspect: "metadata"
   )
   ```

5. **Fetch Source (Retrieve Backend Skeleton)**:
   For objects that contain source code (e.g., `CLAS`, `PROG`, `DDLS`), call `sap_fetch` with `aspect="source"` and `for_editing=true`. The SAP backend automatically generates the skeleton (e.g., class structures or function wrappers) when the shell is created. Fetching it stages this clean skeleton locally (e.g., to `./src/TD1/zcl_my_class.clas.abap`):
   ```json
   sap_fetch(
     workspace_dir: "c:/Users/YuriyDzhenyeyev/git/sap-dev2",
     object_name: "ZCL_MY_CLASS",
     object_type: "CLAS",
     aspect: "source",
     for_editing: true
   )
   ```

6. **Write Source & Push**:
   Edit the staged local source file(s) to add methods or logic, then call:
   ```json
   sap_push(
     workspace_dir: "c:/Users/YuriyDzhenyeyev/git/sap-dev2",
     object_name: "ZCL_MY_CLASS",
     object_type: "CLAS",
     aspect: "source"
   )
   ```

7. **Activate**:
   Call `sap_activate_object` to compile the active code on the backend:
   ```json
   sap_activate_object(
     workspace_dir: "c:/Users/YuriyDzhenyeyev/git/sap-dev2",
     object_name: "ZCL_MY_CLASS",
     object_type: "CLAS"
   )
   ```

## 7. File Layout

Staged objects are organized under the following standard filesystem layout:

```
./src/<system_alias>/
  ├── <object_name>.<type_extension>           # Staged active source files (e.g., .clas.abap, .asddls)
  ├── translations/
  │     └── <object_name>.json                 # Staged translations JSON
  └── metadata/
        └── <object_name>.<object_type>.xml    # Staged XML creation metadata templates/shells
```
