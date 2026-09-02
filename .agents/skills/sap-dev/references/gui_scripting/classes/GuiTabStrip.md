# GuiTabStrip

> **Type**: `Class` | **Section**: `1.2.63`
> **Inherits from**: [`GuiVContainer`](GuiVContainer.md) | **ID Prefix**: `tabs`

---

## 📖 Description

A tab strip is a container whose children are of type GuiTab. GuiTabStrip extends the GuiVContainer Object  [page 286]. The type prefix is tabs, the name is the fieldname taken from the SAP data dictionary. Example The children of the tab strip are the tabs. While all tabs are available at any given time, only the children of the  selected tab exist in the object hierarchy for server driven tab strips. So in this example, the text field labeled  ‘Results analysis keys:’ can only be found if the tab labeled ‘Period Closing’ has been selected. In some transactions there are local tabs strips where all tabs are available without further server access being  required.

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

**All properties of the GuiComponent Object [page 82]:**:
* `ContainerType`
* `Id`
* `Name`
* `Parent`
* `Type`
* `TypeAsNumber`
* `All properties of the GuiVComponent Object [page 281]:`
* `AccText`
* `AccTextOnRequest`
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

---

## 📋 Properties

| Property | Access | Signature / Type | Description |
|:---|:---|:---|:---|
| **`CharHeight`** | `Read-only` | `Long` | Height of the GuiTabStrip in character metric. |
| **`CharLeft`** | `Read-only` | `Long` | Left coordinate of the GuiTabStrip in character metric. |
| **`CharTop`** | `Read-only` | `Long` | Top coordinate of the GuiTabStrip in character metric. |
| **`CharWidth`** | `Read-only` | `Long` | Width of the GuiTabStrip in character metric. |
| **`LeftTab`** | `Read-only` | `GuiTab` | This is the left most tab whose caption is visible. In the  example above it is the one with text ‘Period closing’ . The  leftTab property can be changed by calling the ScrollT oLeft  method of a different GuiTab, as described in section GuiTab  Object [page 230]. |
| **`SelectedTab`** | `Read-only` | `GuiTab` | The selected tab is the one whose descendants are currently  visualized, in the example above it is the ‘General data’ tab.  The selected tab has exactly one child, which is a GuiScroll­ Container. T o select a tab, you call method Select of the  respective tab page. See also section GuiTab Object [page  230]. |

---

