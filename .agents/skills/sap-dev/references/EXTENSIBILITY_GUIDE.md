<!-- AUTO-GENERATED FILE - DO NOT EDIT MANUALLY. Source: agents-docs/skill-source/templates -->

# SAP-Bridge Extensibility Selection Guide

`sap-bridge` provides two distinct extensibility paradigms to allow developers and autonomous AI agents to extend system capabilities: **Workspace Plugins** and **Aspect Hooks**.

---

## 🎯 Quick Selection Matrix ("When to Choose What")

* **Choose Workspace Plugins** when you want to run custom, on-demand scripts or automations with secure SAP backend access (invoked via `sap_execute_plugin`).
* **Choose Aspect Hooks** when you want to automatically intercept, validate, or transform SAP source code and metadata artifacts during `sap_fetch` or `sap_push`.

---

## 📊 Extensibility Paradigm Comparison

| Feature | 🧩 Workspace Plugins | 🪝 Aspect Hooks |
| :--- | :--- | :--- |
| **Primary Purpose** | Run custom, on-demand scripts or automations with secure SAP backend access | Intercept & transform SAP object aspects during `sap_fetch` / `sap_push` |
| **Storage Location** | `.agents/skills/<plugin-id>/` (workspace) | `hooks/<hook-id>/` (workspace) |
| **Manifest File** | `sap-dev-plugin.json` | `hook.json` |
| **Tool Visibility** | Invoked indirectly via `sap_execute_plugin` | Invoked implicitly during `sap_fetch` / `sap_push` |
| **Handler Module** | Custom executable script (Node/Python/Bash) | Custom executable script (Node/Python/Bash) |
| **Dedicated Guide** | [PLUGIN_GUIDE.md](./PLUGIN_GUIDE.md) | [HOOK_GUIDE.md](./HOOK_GUIDE.md) |

---

## 📖 Detailed Guides

1. **[Workspace Plugins Guide](./PLUGIN_GUIDE.md)**  
   Learn how to write project-local automation scripts executed on-demand via `sap_execute_plugin`.

2. **[Aspect Hooks Guide](./HOOK_GUIDE.md)**  
   Learn how to build object aspect interceptors that run implicitly when objects are fetched or pushed to SAP.
