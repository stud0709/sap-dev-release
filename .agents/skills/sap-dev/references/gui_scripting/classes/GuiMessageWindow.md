# GuiMessageWindow

> **Type**: `Class` | **Section**: `1.2.38`
> **Inherits from**: [`GuiVComponent`](GuiVComponent.md)

---

## 📖 Description

A GuiModalWindow is a dialog pop-up. GuiModalWindow extends the GuiFrameWindow Object [page 105].

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
* `The following properties of the GuiVComponent Object [page 281]:`
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
* `Text`
* `T ooltip`
* `Top`
* `Width`

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
* `All methods of the GuiFrameWindow Object [page 105]:`
* `Close`
* `CompBitmap`
* `HardCopy`
* `HardCopyT oMemory`
* `Iconify`
* `IsVKeyAllowed`
* `JumpBackward`
* `JumpForward`
* `Maximize`
* `Restore`
* `SendVKey`
* `ShowMessageBox`
* `TabBackward`
* `TabForward`

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
* `All properties of the GuiFrameWindow Object [page 105]:`
* `ElementVisualizationMode`
* `GuiFocus`
* `Handle`
* `Iconic`
* `SystemFocus`
* `WorkingPaneHeight`
* `WorkingPaneWidth`

---

## 📋 Properties

| Property | Access | Signature / Type | Description |
|:---|:---|:---|:---|
| **`FocusedButton`** | `Read-only` | `Long` | This property contains the value 1 if the OK button is fo­ cused. |
| **`HelpButtonHelpText`** | `Read-only` | `Public Property HelpButtonHelpText As` | String This property contains the tooltip (help text) of the help  button (if any). |
| **`HelpButtonText`** | `Read-only` | `Public Property HelpButtonText As` | String This property contains the text of the help button. |
| **`MessageText`** | `Read-only` | `String` | This property contains the text of the message displayed in  the message box. |
| **`MessageType`** | `Read-only` | `Long` | This property contains the type of the message displayed.  The following values are possible: • 2: Warning message • 3: Error message • 5: Success message |
| **`OKButtonHelpText`** | `Read-only` | `Public Property OKButtonHelpText As` | String This property contains the tooltip (help text) of the OK but­ ton (if any). |
| **`OKButtonText`** | `Read-only` | `String` | This property contains the text of the OK button. |
| **`ScreenLeft`** | `Read-write` | `Long` | The y position of the component in screen coordinates. For GuiMessageWindow, this property can be written to  move the message window to the desired coordinates. |
| **`ScreenTop`** | `Read-write` | `Long` | The x position of the component in screen coordinates. For GuiMessageWindow, this property can be written to  move the message window to the desired coordinates. |
| **`Visible`** | `Read-only` | `Byte` | This property is True if a GuiMessageWindow is presently  displayed. .2.39  GuiModalWindow Object Description A GuiModalWindow is a dialog pop-up. GuiModalWindow extends the GuiFrameWindow Object [page 105]. |

---

