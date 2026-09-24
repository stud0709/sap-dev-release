<!-- AUTO-GENERATED FILE - DO NOT EDIT MANUALLY. Source: agents-docs/skill-source/templates -->

# MCP Tool JSON Schemas

This document contains the structural JSON schemas for complex MCP tools. When invoking these tools, expect the returned string payload to strictly adhere to these shapes.

## sap_explore_object
This is the Omni-Tool for semantic extraction. The returned JSON structure mutates depending on the target object.

### Class/Interface/Program
Used to extract the semantic breakdown of an ABAP object (attributes, methods, types) without reading the full source code.

```json
{
  "name": "ZCL_EXAMPLE",
  "type": "CLAS/OC",
  "visibility": "public",
  "attributes": [
    {
      "name": "MV_COUNT",
      "visibility": "private",
      "type": "I",
      "is_constant": false,
      "is_static": false,
      "description": "Counter value"
    }
  ],
  "methods": [
    {
      "name": "EXECUTE",
      "visibility": "public",
      "is_static": false,
      "parameters": [
        {
          "name": "IV_INPUT",
          "direction": "importing",
          "type": "STRING",
          "description": "Input payload"
        }
      ],
      "exceptions": [],
      "description": "Executes the main routine"
    }
  ],
  "type_hierarchy": {
    "Entries": [
      {
        "Name": "ZCL_EXAMPLE",
        "Type": "CLAS/OC",
        "HasDefOrImpl": true,
        "IsFinal": true,
        "IsAbstract": false
      }
    ]
  }
}
```

### BAdIs / Enhancement Spots
Returns the BAdI ecosystem chain mapping when passing `object_type` as `SXSD` or `ENSC`.

```json
[
  {
    "type": "ENSC",
    "name": "/SCWM/ESI",
    "description": "BAdI Expressdienstabwicklung",
    "interface": "/SCWM/IF_EX_ESI",
    "fallback_class": "/SCWM/CL_DEF_IM_ESI",
    "badi_definitions": [
      {
        "name": "BADI_DEF",
        "interface": "/SCWM/IF_EX_ESI"
      }
    ]
  }
]
```

### DDIC / Tables
Used to extract flat metadata representations of Database Tables, Structures, and Views.

```json
{
  "fields": [
    {
      "FIELDNAME": "MATNR",
      "POSITION": "0001",
      "KEYFLAG": "X",
      "MANDATORY": "",
      "ROLLNAME": "MATNR",
      "CHECKTABLE": "",
      "INTTYPE": "C",
      "INTLEN": "000036",
      "DATATYPE": "CHAR",
      "PRECFIELD": ""
    }
  ],
  "attributes": [
    {
      "TABCLASS": "TRANSP",
      "CONTFLAG": "A",
      "MAINFLAG": "X"
    }
  ],
  "indexes": [],
  "foreign_keys": []
}
```

### Search Fallback
Executes wildcard lookups and returns an array of object references.

```json
[
  {
    "uri": "/sap/bc/adt/programs/programs/ztest_report",
    "type": "PROG/P",
    "name": "ZTEST_REPORT",
    "package_name": "Z_LOCAL",
    "description": "My Test Report"
  }
]
```

## sap_bridge_status
Retrieves the active proxy diagnostic state, binary build metadata, dashboard URL, and a list of active SAP system connections with their real-time ABAP release versions.

```json
{
  "binary_build_time": "built just now",
  "connections": [
    {
      "abap_release": "v752",
      "auth_type": "Basic Auth",
      "default": false,
      "description": "NPL Sandbox",
      "role": "sandbox",
      "sap_client": "001",
      "system_id": "NPL",
      "writable": true
    }
  ],
  "ide_id": "A1B2C3D4E5F678901234567890ABCDE1",
  "sap_dashboard_url": "http://127.0.0.1:64160?workspace_dir=%2Fabsolute%2Fpath%2Fto%2Fworkspace",
  "terminal_id": "F1E2D3C4B5A678901234567890ABCDE1"
}
```

## sap_where_used
Executes a native SAP Where-Used query to resolve backward-link dependencies.

```json
{
  "results": [
    {
      "name": "ZCL_MY_CLASS",
      "type": "CLAS/OC",
      "package": "Z_MY_PACK",
      "responsible": "DEVELOPER1",
      "uri": "/sap/bc/adt/programs/..."
    }
  ],
  "total_count": 1,
  "max_results": 50,
  "is_capped": false,
  "object_uri": "/sap/bc/adt/..."
}
```

## sap_fetch_atc_queue
Allows the agent to poll OPEN warnings/errors from the offline database cache dynamically joining the extracted remediation texts.

```json
[
  {
    "finding_id": 1024,
    "system_id": "NPL",
    "job_id": "0000000000000000",
    "finding_uri": "/sap/bc/adt/atc/runs/.../findings/...",
    "object_name": "ZCL_TEST",
    "object_type": "CLAS",
    "priority": 1,
    "check_title": "Syntax warning",
    "message_title": "Field is never used",
    "status": "OPEN",
    "source_code_path": "C:\\...\\src\\NPL\\zcl_test.clas.abap",
    "line": 45,
    "documentation": "HTML remediation text...",
    "automated_quick_fixes": false
  }
]
```

## sap_debug_trace
Recommended one-shot debugger trace tool. Sets a breakpoint, fires an asynchronous HTTP trigger, steps, evaluates SY & variables, and auto-detaches cleanly in a single call. Accepts exactly one breakpoint target (`line`, `statement`, `exception`, or `message`).

```json
{
  "line": {
    "class": "CL_ADT_MESSAGE_CLASS_API",
    "line": 225
  },
  "trigger_request": {
    "uri": "/sap/bc/adt/messageclass?corrNr=A4HK900151",
    "method": "POST",
    "body": "<?xml version=\"1.0\"...?>"
  },
  "watch_variables": ["LV_SUBRC"],
  "auto_step_count": 2
}
```

Or breaking on statement without line numbers:
```json
{
  "statement": {
    "statement": "AUTHORITY-CHECK"
  },
  "trigger_request": {
    "uri": "/sap/bc/adt/messageclass?corrNr=A4HK900151"
  }
}
```

Response:
```json
{
  "status": "breakpoint_hit",
  "session_id": "82B9E1FA1E8A1FE1AB8C2CA3E456A069",
  "breakpoint_kind": "line",
  "breakpoint_uri": "/sap/bc/adt/oo/classes/cl_adt_message_class_api/source/main#start=225,0",
  "cleanup_applied": true,
  "context": {
    "session_id": "82B9E1FA1E8A1FE1AB8C2CA3E456A069",
    "stack": [
      { "level": 0, "program": "CL_ADT_MESSAGE_CLASS_API======CP", "line": 225, "event": "CREATE" }
    ],
    "variables": { "LV_SUBRC": { "value": "1" } },
    "sy": {
      "subrc": 1,
      "msgid": "PAK",
      "msgno": "149",
      "msgty": "E",
      "msgv1": "ZTEST",
      "message_text": "Structure packages cannot contain development objects"
    }
  }
}
```

## sap_debug_breakpoint
Unified breakpoint manager to set, list, or clear external or session-scoped breakpoints across Line, Statement, Exception, and Message targets. Exactly one target block must be provided for `set`.

```json
// Line Breakpoint (optionally for a specific user)
{
  "action": "set",
  "user": "JDOE",
  "line": {
    "class": "CL_ADT_MC_RES_CONTROLLER",
    "line": 352,
    "condition": "sy-subrc <> 0"
  }
}

// Statement Breakpoint
{
  "action": "set",
  "statement": {
    "statement": "AUTHORITY-CHECK"
  }
}

// Exception Breakpoint
{
  "action": "set",
  "exception": {
    "exception_class": "CX_ROOT"
  }
}

// Message Breakpoint
{
  "action": "set",
  "message": {
    "message_id": "PAK",
    "message_number": "149",
    "message_type": "E"
  }
}

// Clear all: { "action": "clear" } (or { "action": "clear", "user": "JDOE" })
// Clear specific: { "action": "clear", "statement": { "statement": "AUTHORITY-CHECK" } }
```

## sap_debug_context
Retrieves variables, SY fields, and stack frame arrays from an active debug session.

```json
{
  "session_id": "session_12345",
  "variables": [
    {
      "id": "VAR1",
      "name": "LT_MARA",
      "type": "ITAB",
      "value": "2 Rows",
      "is_table": true,
      "is_structure": false
    }
  ],
  "stack": [
    {
      "id": "STACK1",
      "name": "METHOD_EXECUTE",
      "uri": "/sap/bc/adt/...#start=10",
      "line": 10
    }
  ],
  "sy": {
    "subrc": 0,
    "msgid": "",
    "msgno": ""
  }
}
```

## sap_fetch_runtime_errors
Retrieves and parses ABAP Short Dumps (ST22). Supports three modes:

### 1. Single-Turn Deep Diagnostic Mode (`topmost: 1` or `error_uri`)
Returns deep crash context directly in a single turn with enriched chapters and call frames:

```json
{
  "short_text": "This line is not contained in the table.",
  "what_happened": "The current ABAP program had to be terminated...",
  "error_analysis": "Access failed for table LS_PDI_DATA-ITEMS...",
  "how_to_correct": "If the exception cannot be prevented, CX_SY_ITAB_LINE_NOT_FOUND must be caught...",
  "chain_of_exception_objects": "Level: 1 | Class: CX_SY_ITAB_LINE_NOT_FOUND | KEY_NAME: <free key>",
  "user_and_transaction": "Transaction: /SCWM/RFUI | Program: SAPLZGT_RF_PTWY | User: DEVELOPER1",
  "termination_point": "Line 91 of include LZGT_RF_PTWYU05",
  "source_code_extract": "   89 | IF lv_assign_qty IS INITIAL.\n   90 | lo_helper->set_step2( ).\n>>>>> | lo_helper->set_lgbkz_fields( ls_pdi_data-items[ product_no = zptgtl-matnr ]-lgbkz ).\n   92 | ELSE.",
  "system_fields": {
    "SY-SUBRC": "0",
    "SY-TABIX": "1"
  },
  "active_calls": [
    {
      "level": 4,
      "event_type": "FUNCTION",
      "program": "SAPLZGT_RF_PTWY",
      "include": "LZGT_RF_PTWYU05",
      "line": 91,
      "name": "Z_GT_RF_ZPTGT2"
    }
  ],
  "variables": "RESOURCE = {100;MP;UIA45621...}\nLV_ASSIGN_QTY = 0\nZPTGTL-MATNR = PT382837-1"
}
```
*Note: The complete raw ST22 text dump (400+ KB) is automatically persisted to `./tmp/<system>/st22_<id>_full.txt` and its path is returned in `full_text_path` for offline inspection.*

### 2. Raw Full Dump Mode (`full: true`)
When `full: true` is passed with `topmost: 1` or `error_uri`, returns the complete unformatted ST22 text dump directly (evaluated via spillover if larger than 2 KB).

### 3. Grouped Feed List Mode
When querying multiple crashes with server-side filters (`user_name`, `runtime_error`, `exception`, `program_name`, `topmost`, `date_from`/`date_to`, `time_from`/`time_to`), returns grouped crash clusters sorted by latest occurrence:

```json
[
  {
    "title": "GETWA_NOT_ASSIGNED",
    "crash_id": "GETWA_NOT_ASSIGNED",
    "program": "ZCL_TEST",
    "include": "ZCL_TEST===============CCIMP",
    "line": 42,
    "occurrences": 3,
    "latest_published": "2026-09-10T12:00:00Z",
    "latest_error_uri": "/sap/bc/adt/runtime/dumps/202609101200000001",
    "author": "DEVELOPER"
  }
]
```

## sap_fetch_application_log
Queries SAP Application Log headers (`BALHDR`) and decompresses cluster message blocks (`BALDAT`).

```json
{
  "logs": [
    {
      "log_handle": "00000000000000000001",
      "log_number": "000000000001",
      "object": "CIF",
      "subobject": "ORDER",
      "extnumber": "SO_100234",
      "aluser": "DEVELOPER",
      "aldate": "20260910",
      "altime": "143000",
      "alprog": "Z_PROCESS_ORDERS",
      "messages": [
        {
          "msgty": "E",
          "msgid": "ZSALES",
          "msgno": "042",
          "message_text": "Sales order 100234 could not be posted: missing customer 5001",
          "msgv1": "100234",
          "msgv2": "5001"
        }
      ]
    }
  ]
}
```

## sap_verify_transport
Inspects and verifies CTS transport requests and tasks across `E070`, `E071`, and `E071K` without requiring raw SQL.

```json
{
  "transport_request": "TR1K900123",
  "type": "workbench request",
  "status": "D",
  "status_text": "modifiable",
  "owner": "DEVELOPER",
  "is_task": false,
  "tasks": [
    {
      "task": "TR1K900124",
      "type": "development/correction",
      "status": "D",
      "status_text": "modifiable",
      "owner": "DEVELOPER"
    }
  ],
  "target_found": true,
  "target_locked": true,
  "objects_count": 1,
  "objects": [
    {
      "transport_request": "TR1K900124",
      "pgmid": "R3TR",
      "object": "CLAS",
      "obj_name": "ZCL_MY_CLASS",
      "lockflag": "X"
    }
  ],
  "keys_count": 0,
  "keys": []
}
```

## sap_fetch_spool
Retrieves decoded report and background job spool output lines directly via `RSPO_RETURN_SPOOLJOB`:

```json
{
  "status": "success",
  "metadata": {
    "rqident": "12345",
    "rq2name": "ZREPORT",
    "rqowner": "DEVELOPER",
    "rqclient": "100",
    "rqcretime": "20260910120000",
    "rqlines": 150
  },
  "total_lines": 150,
  "lines": [
    "--------------------------------------------------------------------------------",
    "| Material | Description                   | Plant | Unrestricted Stock | Unit |",
    "--------------------------------------------------------------------------------",
    "| MAT001   | Bearing Assembly              | 1000  |                250 | PC   |"
  ]
}
```


## sap_explore_odata_service
Fetches a parsed representation of the OData metadata schema, organizing entity sets by name with their defined key fields and properties.

```json
{
  "FormTemplateCollection": {
    "keys": ["FormTemplateName", "Language"],
    "properties": {
      "FormTemplateName": "Edm.String (max: 30) [Required]",
      "Language": "Edm.String (max: 2) [Required]",
      "Description": "Edm.String (max: 80)"
    }
  }
}
```

## sap_odata_call
Executes structured OData operations. The returned output matches the stripped JSON representation of the target OData resource (without standard OData metadata/deferred wrappers or deep results envelopes).

### Single Entity / Creation / Update Result
```json
{
  "FormTemplateName": "ZZ1_PO",
  "Language": "EN",
  "Description": "Purchase Order Template"
}
```

### Collection Query Result
```json
[
  {
    "FormTemplateName": "ZZ1_PO",
    "Language": "EN",
    "Description": "Purchase Order Template"
  }
]
```

---

## sap_get_supported_capabilities
Returns all supported capabilities of the active workspace, detailing embedded object types/aspects, active external hooks, and registered standalone plugins.

```json
{
  "embedded_hooks": {
    "CLAS": {
      "extension": ".abap",
      "supported_aspects": ["source", "metadata", "translations"]
    }
  },
  "external_hooks": [
    {
      "package_name": "fugr-descriptions",
      "name": "fugr-descriptions",
      "description": "Function Group Module Descriptions Hook",
      "enabled": true,
      "can_handle": ["FUGR"],
      "aspects": ["descriptions"],
      "scripts": ["fetch.py", "push.py"]
    }
  ],
  "standalone_plugins": [
    {
      "plugin_id": "sap-echo",
      "name": "SAP Echo",
      "description": "Echos back RFC inputs using the guarded bridge.",
      "enabled": true,
      "scripts": ["echo_call.js"]
    }
  ]
}
```

---

## sap_search_customizing
Returns matched SPRO customizing activities with navigation paths, maintenance targets, and technical attributes:

```json
[
  {
    "node_id": "SIMG_CFMENUOLSDOVK1",
    "text": "Define Tax Determination Rules",
    "path": "Sales and Distribution > Basic Functions > Taxes > Define Tax Determination Rules",
    "activity": "SD_TAX_RULES",
    "transaction": "OVK1",
    "object_name": "V_TTXD",
    "object_type": "V",
    "maint_transact": "SM30"
  }
]
```

Or reverse SPRO paths when `object_name` is provided:

```json
{
  "object_name": "TB034",
  "spro_paths": [
    ["Cross-Application Components", "Payment Cards", "Basic Settings", "Maintain Payment Card Categories"]
  ]
}
```

---

## sap_explore_customizing
Returns complete unified context for a customizing view/table: DDIC schema, key flags, check tables, domain fixed values, SPRO breadcrumbs, official IMG documentation, and sample records:

```json
{
  "target": "TB034",
  "resolved_view": "TB034",
  "schema": {
    "target": "TB034",
    "object_type": "VIEW",
    "maintenance_type": "1",
    "overview_screen": "0420",
    "detail_screen": "0000",
    "header_text": "Payment Card Categories",
    "fields": [
      {
        "fieldname": "CCINS",
        "key": true,
        "datatype": "CHAR",
        "leng": 4,
        "checktable": "TB033",
        "fieldtext": "Payment Card Category"
      },
      {
        "fieldname": "CCTYP",
        "key": false,
        "datatype": "CHAR",
        "leng": 2,
        "domain_values": [
          { "domvalue_l": "01", "ddtext": "Credit Card" },
          { "domvalue_l": "02", "ddtext": "Procurement Card" }
        ],
        "fieldtext": "Payment Card Type"
      }
    ]
  },
  "spro_paths": [
    ["Cross-Application Components", "Payment Cards", "Basic Settings", "Maintain Payment Card Categories"]
  ],
  "documentation": "In this IMG activity, you define payment card categories...",
  "existing_data": [
    { "CCINS": "AMEX", "CCTYP": "01" },
    { "CCINS": "VISA", "CCTYP": "01" }
  ]
}
```

---

## sap_gui_execute_sequence
Returns the final step execution status, window title, dynpro coordinates, and status message:

```json
{
  "status": "COMPLETED",
  "message": "All 3 steps executed successfully.",
  "sequence_name": "DISPLAY_COUNTRY_TABLE",
  "total_steps": 3,
  "step_index": 3,
  "system": "TD1",
  "client": "300",
  "transaction": "SM30",
  "program": "SAPMSVMA",
  "dynpro": "100",
  "window_title": "Tabellensicht-Pflege: Einstieg"
}
```

---

## sap_gui_inspect
Returns the visual window state, classified semantic controls, and smart `@`-aliases:

```json
{
  "system": "TD1",
  "client": "300",
  "session": 1,
  "modal_index": 0,
  "window_title": "Warehouse Management Monitor SAP - Whse. 0001 (Time Zone )",
  "program": "/SCWM/R_WME_MONITOR",
  "dynpro": "1",
  "transaction": "/SCWM/MON",
  "aliases": {
    "@tree": "wnd[0]/usr/shell/splitterContainer[0]/shellcont[0]/shell",
    "@grid": "wnd[0]/usr/shell/splitterContainer[1]/shellcont[1]/shell/splitterContainer[1]/shellcont[1]/shell",
    "@alv": "wnd[0]/usr/shell/splitterContainer[1]/shellcont[1]/shell/splitterContainer[1]/shellcont[1]/shell",
    "@grid:HUIDENT": "wnd[0]/usr/shell/splitterContainer[1]/shellcont[1]/shell/splitterContainer[1]/shellcont[1]/shell"
  },
  "controls": [
    {
      "alias": "@tree",
      "type": "GuiTree",
      "subtype": "Tree",
      "role": "Navigation Tree",
      "id": "wnd[0]/usr/shell/splitterContainer[0]/shellcont[0]/shell",
      "sample_nodes": ["Outbound", "Documents", "Handling Unit", "Physical Stock"]
    },
    {
      "alias": "@grid",
      "type": "GuiGridView",
      "subtype": "GridView",
      "role": "ALV Grid",
      "id": "wnd[0]/usr/shell/splitterContainer[1]/shellcont[1]/shell/splitterContainer[1]/shellcont[1]/shell",
      "columns": ["HUIDENT", "LGNUM", "VGBEL", "CREATED_BY"],
      "row_count": 24,
      "selected_rows": [0],
      "toolbar_buttons": ["&MB_OTHER", "&FIND", "&SORT_ASC", "&FILTER"]
    }
  ]
}
```

---

## sap_maintain_customizing
Executes declarative record maintenance (`INSERT_UPDATE` / `DELETE`) on SAP customizing tables/views (SM30/SM34):

```json
{
  "result": {
    "status": "SUCCESS",
    "customizing_target": "TB034",
    "action": "INSERT_UPDATE",
    "processed_rows": 2,
    "inserted": 1,
    "updated": 1,
    "deleted": 0,
    "transport_request": "DEVK900123",
    "message": "Customizing entries saved successfully"
  }
}
```

---

## sap_fetch (aspects: "definitions", "implementations", "testclasses", "macros")
Fetches a specific class pool component directly into `./src/` (or `./tmp/` if `for_editing: false`):

```json
{
  "file_path": "src/DEV/zcl_my_class.clas.locals_def.abap",
  "object_uri": "/sap/bc/adt/oo/classes/zcl_my_class/includes/definitions",
  "version": 0,
  "lines_count": 42,
  "etag": "20260911140000"
}
```

---

## sap_push (aspects: "definitions", "implementations", "testclasses", "macros")
Pushes a targeted class pool component and records an aspect-specific version record in SQLite:

```json
{
  "success": true,
  "object_uri": "/sap/bc/adt/oo/classes/zcl_my_class/includes/definitions",
  "version": 1,
  "lines_added": 12,
  "lines_removed": 2,
  "etag": "20260911141000",
  "transport": "DEVK900123"
}
```

---

## sap_export_diagnostics
Exports a Zero-Trust sanitized diagnostic package containing environment metadata, recent ADT/MCP logs, source mutations, and pipeline capabilities:

```json
{
  "status": "success",
  "file_path": "tmp/diagnostics_all_20260923_140524.json",
  "file_size": 45120,
  "format": "json",
  "system_alias": "DEV1",
  "summary": "Exported 45 ADT logs, 50 MCP logs, 12 mutation records, and 18 capabilities to tmp/diagnostics_all_20260923_140524.json (45120 bytes, 14 sensitive redactions applied).",
  "entry_counts": {
    "adt_logs": 45,
    "mcp_logs": 50,
    "mutations": 12,
    "capabilities": 18
  },
  "created_at": "2026-09-23T14:05:24Z"
}
```
