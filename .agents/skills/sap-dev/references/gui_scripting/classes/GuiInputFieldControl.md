# GuiInputFieldControl

> **Type**: `Class` | **Section**: `1.2.32`

---

## 📖 Description

• DragDropSupported • Handle • OcxEvents • SubType

---

## 🧬 Inherited Members

**All methods of the GuiVComponent Object [page 281]:**:
* `DumpState`
* `SetFocus`
* `Visualize`
* `All methods of the GuiContainer Object [page 87]:`
* `FindById`
* `All methods of the GuiVContainer Object [page 286]:`
* `FindAllByName`
* `FindAllByNameEx`
* `FindByName`
* `FindByNameEx`
* `All methods of the GuiShell Object [page 207]:`
* `SelectContextMenuItem`
* `SelectContextMenuItemByPosition`
* `SelectContextMenuItemByText`

**All properties of the GuiComponent Object [page 82]:**:
* `ContainerType`
* `Id`
* `Name`
* `Parent`
* `Type`
* `TypeAsNumber`
* `All properties of the GuiVComponent Object [page 281]:`
* `AccLabelCollection`
* `AccText`
* `AccTextOnRequest`
* `AccT ooltip`
* `Changeable`
* `DefaultT ooltip`
* `Height`
* `IconName`
* `IsSymbolFont`
* `Left`
* `Modified`
* `ParentFrame`
* `ScreenLeft`
* `ScreenTop`
* `Text`
* `T ooltip`
* `Top`
* `Width`
* `All properties of the GuiContainer Object [page 87]:`
* `Children`
* `All properties of the GuiShell Object [page 207]:`
* `AccDescription`
* `DragDropSupported`
* `Handle`
* `OcxEvents`
* `SubType`

---

## 📋 Properties

| Property | Access | Signature / Type | Description |
|:---|:---|:---|:---|
| **`ButtonTooltip`** | `Read-only` | `Public Property ButtonTooltip As` | String T ooltip of the submit / find button. |
| **`FindButtonActivated`** | `Read-only` | `Public Property FindButtonActivated` | As Boolean This property is T rue when the current focus is on the Find  button. |
| **`HistoryCurEntry`** | `Read-only` | `Public Property HistoryCurEntry As` | String Text of the currently focused entry in the history list box.  This property is empty, if the history list box is closed. |
| **`HistoryCurIndex`** | `Read-only` | `Public Property HistoryCurIndex As` | Long Currently focused index in the history dropdown list box.  This property contains -1, if the history list box is closed. |
| **`HistoryIsActive`** | `Read-only` | `Public Property HistoryIsActive As` | Byte This property is T rue when the input history list box is cur­ rently opened. |
| **`HistoryList`** | `Read-only` | `Public Property HistoryList As` | GuiCollection List of entries (strings) in the local history list box. |
| **`LabelText`** | `Read-only` | `String` | The text of the label belonging to the input field. |
| **`PromptText`** | `Read-only` | `String` | The prompt text that is displayed in an empty input field, if  assigned by the application. |
| **`Text`** | `Read-write` | `String` | Text content of the input field itself. |

---

## ⚙️ Methods

### `Submit`

```vb
Public Sub Submit()
```

Submits the input to the application.

