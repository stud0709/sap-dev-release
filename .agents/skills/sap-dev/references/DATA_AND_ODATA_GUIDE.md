<!-- AUTO-GENERATED FILE - DO NOT EDIT MANUALLY. Source: agents-docs/skill-source/templates -->

# Data Access & OData Gateway Operations Guide

This manual covers database queries (OpenSQL, Data Preview), OData REST service interactions, and SAP Gateway cache/metadata maintenance.

---

## 📊 Database Queries: OpenSQL & Data Preview

```mermaid
flowchart LR
    A["Database Query Needs"] --> B{"Complex Joins or Aggregations?"}
    B -->|Yes| C["<code>sap_execute_sql</code><br>(Freestyle OpenSQL)"]
    B -->|No (Flat Table Filter)| D["<code>sap_select_data</code><br>(Native ADT Data Preview)"]
```

### 1. Complex Queries with OpenSQL (`sap_execute_sql`)
Executes arbitrary freestyle OpenSQL `SELECT` queries across tables, joins, aggregations (`COUNT`, `SUM`), and subqueries:
```json
sap_execute_sql(
  query: "SELECT DISTINCT A~MATNR, B~MAKTX FROM MARA AS A INNER JOIN MAKT AS B ON A~MATNR = B~MATNR WHERE B~SPRAS = 'E'",
  max_rows: 50,
  system_alias: "TD1"
)
```

### 2. Fast Flat Table Extraction (`sap_select_data`)
Performs fast single-table extraction against the native ADT Data Preview endpoint:
```json
sap_select_data(
  table: "T000",
  fields: "MANDT,MTEXT,CCCATEGORY",
  where: "MANDT = '100'",
  max_rows: 50,
  system_alias: "TD1"
)
```

---

## 🌐 OData Client Operations (`sap_odata_call` / `sap_explore_odata_service`)

Interact with SAP Gateway, S/4HANA Cloud Key User APIs, or custom OData services with automated token optimization.

### 1. Service Schema Discovery (`sap_explore_odata_service`)
Extracts a compact JSON outline of EntitySets, key properties, and field types from `$metadata`:
```json
sap_explore_odata_service(
  service_path: "/sap/opu/odata/SAP/APS_OM_FORM_TMPL_SRV",
  system_alias: "TD1"
)
```

### 2. Executing CRUD Requests (`sap_odata_call`)
- **Read Collection**: `action: "READ"`, with optional `filter` and `select`.
- **Read Single Entity**: `action: "READ"`, `keys: {"FormTemplateName": "ZZ1_PO", "Language": "EN"}`.
- **Create Entity**: `action: "CREATE"`, with JSON `payload`.
- **Update Entity**: `action: "UPDATE"`, with target `keys` and JSON `payload`.
- **Delete Entity**: `action: "DELETE"`, with target `keys`.

```json
sap_odata_call(
  service_path: "/sap/opu/odata/SAP/APS_OM_FORM_TMPL_SRV",
  entity_set: "FormTemplateCollection",
  action: "READ",
  keys: {
    "FormTemplateName": "ZZ1_PO",
    "Language": "EN"
  },
  system_alias: "TD1"
)
```
- **Automatic Optimization**: Automatically strips verbose metadata wrappers (`__metadata`, `__deferred`, `@odata.*`) and unrolls single-key objects (`d`, `results`, `value`) to preserve token budget.

---

## ⚙️ OData Service & Gateway Cache Maintenance (`sap_maintain_odata_service`)

Perform administrative Gateway operations without launching GUI transactions:

| Action | Description |
| :--- | :--- |
| **`clear_cache`** | Clears Gateway Hub (`/IWFND/CACHE_CLEANUP`) & Backend Provider (`/IWBEP/CACHE_CLEANUP`) caches. |
| **`reload_metadata`** | Forces immediate `$metadata` compilation bypassing server caching layers. |
| **`check_status`** | Verifies ICF node activation and metadata endpoint availability. |
| **`fetch_error_log`** | Retrieves recent Gateway error tracebacks from `/IWFND/SU_ERRLOG`. |
| **`check_routing`** | Inspects service registration and system aliases in `/IWFND/I_MED_SRG`. |

```json
sap_maintain_odata_service(
  service_path: "/sap/opu/odata/SAP/ZCUSTOM_SRV",
  action: "clear_cache",
  system_alias: "TD1"
)
```
