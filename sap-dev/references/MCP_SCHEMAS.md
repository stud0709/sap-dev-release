# MCP Tool JSON Schemas

This document contains the structural JSON schemas for complex MCP tools. When invoking these tools, expect the returned string payload to strictly adhere to these shapes.

## sap_get_object_outline
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
  ]
}
```

## sap_fetch_ddic
Used to extract flat metadata representations of Database Tables, Structures, and Views.

```json
{
  "name": "MARA",
  "type": "TABL/DT",
  "description": "General Material Data",
  "fields": [
    {
      "name": "MATNR",
      "key": true,
      "type": "CHAR",
      "length": 18,
      "decimals": 0,
      "rollname": "MATNR",
      "description": "Material Number"
    },
    {
      "name": "ERSDA",
      "key": false,
      "type": "DATS",
      "length": 8,
      "decimals": 0,
      "rollname": "ERSDA",
      "description": "Created On"
    }
  ]
}
```

## sap_map_dependencies
Maps internal structure dependencies inside an ABAP object via offline AST traversal.

```json
{
  "object_name": "ZCL_ROUTER",
  "object_type": "CLAS",
  "dependencies": {
    "tables": ["ZTB_CONFIG", "MARA"],
    "classes": ["ZCL_LOGGER", "CL_SALV_TABLE"],
    "interfaces": ["ZIF_ROUTABLE"],
    "function_modules": ["BAPI_MATERIAL_GET_DETAIL"]
  }
}
```

## sap_search_objects
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
  "sap_dashboard_url": "http://127.0.0.1:64160",
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

## sap_debug_context
Retrieves variables and stack frame arrays from an active debug session.

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
  ]
}
```

## sap_fetch_runtime_errors
Retrieves and parses ABAP Short Dumps (ST22). Below is the detailed mode (extracted crash context).

```json
{
  "error_uri": "/sap/bc/adt/runtimeerrors/...",
  "title": "TIME_OUT",
  "user_name": "DEVELOPER1",
  "client": "001",
  "timestamp": "2026-05-10T09:00:00Z",
  "chapters": [
    {
      "name": "What happened?",
      "content": "The program has exceeded the maximum uninterrupted runtime."
    }
  ],
  "stack_frames": [
    {
      "program": "ZCL_EXAMPLE=================CP",
      "include": "ZCL_EXAMPLE=================CM001",
      "line": 45
    }
  ]
}
```
