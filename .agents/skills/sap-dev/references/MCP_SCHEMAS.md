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

