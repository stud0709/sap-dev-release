# GuiScrollContainer

> **Type**: `Class` | **Section**: `1.2.48`
> **ID Prefix**: `ssub`

---

## 📖 Description

This container represents scrollable subscreens. A subscreen may be scrollable without actually having a  scrollbar, because the existence of a scrollbar depends on the amount of data displayed and the size of the  GuiUserArea. GuiScrollContainer extend sthe GuiVContainer Object [page 286]. The type prefix is ssub, the  name is generated from the data dictionary settings.

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

---

## 📋 Properties

| Property | Access | Signature / Type | Description |
|:---|:---|:---|:---|
| **`HorizontalScrollbar`** | `Read-write` | `Public Property HorizontalScrollbar` | As GuiScrollbar The horizontal scrollbar of the scroll container. |
| **`VerticalScrollbar`** | `Read-write` | `Public Property VerticalScrollbar As` | GuiScrollbar The vertical scrollbar of the scroll container. |

---

