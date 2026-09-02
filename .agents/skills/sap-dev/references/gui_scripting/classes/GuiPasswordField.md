# GuiPasswordField

> **Type**: `Class` | **Section**: `1.2.43`
> **Inherits from**: [`GuiTextField`](GuiTextField.md) | **ID Prefix**: `pwd`

---

## 📖 Description

There are some differences between GuiTextField and GuiPasswordField: • The Text and DisplayedText properties cannot be read for a password field. The returned text is always  empty. During recording the password is also not saved in the recorded script. • The properties HistoryCurEntry, HistoryCurIndex, HistoryIsActive and HistoryList are not supported,  because password fields do not offer an input history • The property IsListElement is not supported, because password fields cannot be placed on ABAP lists GuiPasswordField extends the GuiTextField [page 250]. The type prefix is pwd, the name is the fieldname taken  from the SAP data dictionary.

---

## 🧬 Inherited Members

**All methods of the GuiVComponent Object [page 281]:**:
* `DumpState`
* `SetFocus`
* `Visualize`

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
* `All properties of the GuiTextField [page 250]:`
* `CaretPosition`
* `DisplayedText`
* `Highlighted`
* `IsHotspot`
* `sLeftLabel`
* `IsOField`
* `IsRightLabel`
* `LeftLabel`
* `MaxLength`
* `Numerical`
* `Required`
* `RightLabel`

---

