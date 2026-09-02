# GuiTab

> **Type**: `Class` | **Section**: `1.2.59`
> **Inherits from**: [`GuiVContainer`](GuiVContainer.md) | **ID Prefix**: `tabp`

---

## 📖 Description

The GuiTab objects are the children of a GuiTabStrip object. GuiTab extends the GuiVContainer Object [page  286]. The type prefix is tabp, the name is the id of the tab’s button taken from SAP data dictionary.

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

## ⚙️ Methods

### `ScrollToLeft`

```vb
Public Sub ScrollToLeft()
```

ScrollT oLeft shifts the tabs so that a certain tab becomes the  leftTab of the tab strip.

### `Select`

```vb
Public Sub Select()
```

This function sets the tab to be the tab strip’s selected tab.  Changing the selected tab of a tab strip may cause server  communication.

