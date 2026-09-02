# SAP GUI Scripting API — Cheat Sheet & Common Idioms

## 🗺️ Core Object Model Hierarchy

```
GuiApplication
  └── Children (GuiConnection)
        └── Children (GuiSession)
              ├── ActiveWindow (GuiMainWindow / GuiModalWindow)
              ├── Info (GuiSessionInfo)
              └── FindById(id) / FindByName(name)
```

## ⌨️ Virtual Key (VKey) Reference Table

| VKey | Key | Typical SAP Action |
|:---:|:---|:---|
| **`0`** | `Enter` | Confirm / Refresh / Step |
| **`2`** | `F2` / `Double-Click` | Choose / Open Sub-Screen / Drill Down |
| **`3`** | `F3` | Back |
| **`5`** | `F5` | New Entries / Display / Select |
| **`6`** | `F6` | Maintain / Change Mode |
| **`11`** | `Ctrl+S` / `Shift+F11` | Save |
| **`12`** | `F12` / `Cancel` | Cancel / Exit |
| **`14`** | `Shift+F2` | Delete Row / Entry |
| **`42`** | `Shift+F6` | Translation |
| **`82`** | `Page Down` | Scroll Down Table |
| **`83`** | `Page Up` | Scroll Up Table |

## 🗄️ Essential Control Types & Quick Snippets

### 1. `GuiTableControl` (Dynpro Tables) -> [`GuiTableControl.md`](classes/GuiTableControl.md)
* **Accessing Cells**: `tbl.getId() + "/txt<NAME>[col,row]"` (e.g. `tblSAPLBUS4TCTRL_TB035/txtTB035-CCLOCK[0,0]`)
* **Select Row**: `tbl.getAbsoluteRow(r).selected = true;`
* **Row Counts**: `tbl.getRowCount()`, `tbl.getVisibleRowCount()`
* **Position Row**: `tbl.setCurrentCellRow(r)`

### 2. `GuiGridView` (ALV Grid Controls) -> [`GuiGridView.md`](classes/GuiGridView.md)
* **Select Row**: `grid.selectedRows = "0";`
* **Click Cell**: `grid.click(row, colName);`
* **Double Click**: `grid.doubleClick(row, colName);`
* **Trigger Toolbar Button**: `grid.pressToolbarButton(fcode);`

### 3. `GuiTree` (Hierarchy Trees) -> [`GuiTree.md`](classes/GuiTree.md)
* **Select Node**: `tree.selectedNode = nodeKey;`
* **Double Click Node**: `tree.doubleClickNode(nodeKey);`
* **Expand Node**: `tree.expandNode(nodeKey);`

### 4. `GuiStatusbar` (System Messages) -> [`GuiStatusbar.md`](classes/GuiStatusbar.md)
* **Message Type**: `sbar.getMessageType()` (`"S"`=Success, `"W"`=Warning, `"E"`=Error, `"I"`=Info, `"A"`=Abort)
* **Text**: `sbar.getText()`

### 5. `GuiModalWindow` (Dialog Popups) -> [`GuiModalWindow.md`](classes/GuiModalWindow.md)
* **Modal Index**: `wnd[1]`, `wnd[2]`
* **Confirm Button**: `wnd1.findById("tbar[0]/btn[0]").press();`
* **Cancel**: `wnd1.sendVKey(12);`
