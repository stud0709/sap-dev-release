# GuiContainerShell

> **Type**: `Class` | **Section**: `1.2.19`
> **Inherits from**: [`GuiVContainer`](GuiVContainer.md) | **ID Prefix**: `shellcont`

---

## 📖 Description

A GuiContainerShell is a wrapper for a set of the GuiShell Object [page 207]. GuiContainerShell extends the  GuiVContainer Object [page 286]. The type prefix is shellcont, the name is the last part of the id, shellcont[n].

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
* `All properties of the GuiTextField [page 250] with one exception: Property IsListElement in not available for this object`
* `since F4 help is not available for input fields within ABAP lists!`
* `CaretPosition`
* `DisplayedText`
* `Highlighted`
* `HistoryCurEntry`
* `HistoryCurIndex`
* `HistoryIsActive`
* `HistoryList`
* `IsHotspot`
* `IsLeftLabel`
* `IsOField`
* `IsRightLabel`
* `LeftLabel`
* `MaxLength`
* `Numerical`
* `Required`
* `RightLabel`
* `1.2.21  GuiCustomControl Object`
* `Description`
* `The GuiCustomControl is a wrapper object that is used to place ActiveX controls onto dynpro screens. While`
* `GuiCustomControl is a dynpro element itself, its children are of GuiContainerShell type, which is a container for`
* `controls. GuiCustomControl extends the GuiVContainer Object [page 286]. The type prefix is cntl, the name is`
* `the fieldname taken from the SAP data dictionary.`

**All methods of the GuiVComponent Object [page 281]:**:
* `DumpState`
* `SetFocus`
* `Visualize`
* `All methods of the GuiContainer Object [page 87]:`
* `FindById`
* `All additional methods of the GuiVContainer Object [page 286]:`
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

**All methods of the GuiVComponent Object [page 281]:**:
* `DumpState`
* `SetFocus`
* `Visualize`
* `All methods of the GuiContainer Object [page 87]:`
* `FindById`
* `All additional methods of the GuiVContainer Object [page 286]:`
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
| **`AccDescription`** | `Read-only` | `Public Property AccDescription As` | String Accessibility description of the shell. This description can be  used for shells that do not have a title element. .2.20  GuiCTextField Object Description If the cursor is set into a text field of type GuiCTextField a combo box button is displayed to the right of the text  field. Pressing this button is equivalent to pressing the F4 key. The button is not represented in the scripting  object model as a separate object; it is considered to be part of the text field. There are no other differences between GuiTextField and GuiCTextField. GuiCTextField extends the GuiTextField  [page 250]. The type prefix is ctxt, the name is the Fieldname taken from the SAP data dictionary. Example This is an example of GuiCTextField type text field, where the upper field has the focus. Please note that the  button is only displayed when the corresponding input field has the focus unless the ABAP application has  defined the button to be shown permanently. |

---

