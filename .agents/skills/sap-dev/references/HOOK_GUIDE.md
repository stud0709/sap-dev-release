<!-- AUTO-GENERATED FILE - DO NOT EDIT MANUALLY. Source: agents-docs/skill-source/templates -->

# Aspect Hooks Guide (`sap_fetch` & `sap_push` Interceptors)

---

## 1. How Aspect Hooks Work

Aspect Hooks are workspace-local scripts triggered implicitly when `sap-bridge` fetches or pushes SAP objects. They allow you to process custom aspects (such as object translations, short texts, or metadata extensions).

### Directory Structure
Hooks live under the `hooks/` directory in your active workspace:
```text
your-workspace/
└── hooks/
    └── my-custom-hook/
        ├── hook.json   <-- Hook metadata & intercept rules
        └── hook.js     <-- Interceptor script
```

---

## 2. Manifest Schema (`hook.json`)

```json
{
  "id": "my-custom-hook",
  "name": "My Custom Aspect Hook",
  "aspect": "translations",
  "object_types": ["PROG", "CLAS"],
  "handler": "./hook.js"
}
```
