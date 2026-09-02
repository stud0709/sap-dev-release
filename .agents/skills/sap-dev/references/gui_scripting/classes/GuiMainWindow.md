# GuiMainWindow

> **Type**: `Class` | **Section**: `1.2.34`
> **Inherits from**: [`GuiFrameWindow`](GuiFrameWindow.md)

---

## 📖 Description

This window represents the main window of an SAP GUI session. GuiMainWindow extends the GuiFrameWindow Object [page 105].

---

## 🧬 Inherited Members

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
* `All additional methods of the GuiFrameWindow Object [page 105]:`
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
| **`ButtonbarVisible`** | `Read-write` | `Public Property ButtonbarVisible As` | Byte This property it T rue if the application toolbar, the lower tool­ bar within SAP GUI, is visible. Setting this property to False  will hide the application toolbar. |
| **`StatusbarVisible`** | `Read-write` | `Public Property StatusbarVisible As` | Byte This property it T rue if the status bar at the bottom of the  SAP GUI window is visible. Setting this property to False will  hide the status bar. When the status bar is hidden, messages  will be displayed in a popup instead. |
| **`TitlebarVisible`** | `Read-write` | `Public Property TitlebarVisible As` | Byte This property it T rue if the title bar is visible. Setting this  property to False will hide the title bar. Remarks The title bar is only available in New Visual Design, not in  Classic Design. |
| **`ToolbarVisible`** | `Read-write` | `Byte` | This property it T rue if the system toolbar, the upper toolbar  within SAP GUI, is visible. Setting this property to False will  hide the system toolbar. |

---

## ⚙️ Methods

### `ResizeWorkingPane`

```vb
Public Sub ResizeWorkingPane( _     ByVal Width As Long, _
```

ByVal Height As Long, _     ByVal ThrowOnFail As Boolean _  ) The ResizeWorkingPane function will resize the window so  that the available working area has the given width and  height in character metric. ThrowOnFail: The throwOnFail parameter has been  added for use in the SAP GUI for Java because some window  managers may not support a program driven resize of a  window.

### `ResizeWorkingPaneEx`

```vb
Public Sub ResizeWorkingPaneEx( _     ByVal Width As Long, _
```

ByVal Height As Long, _     ByVal ThrowOnFail As Boolean _  ) The ResizeWorkingPaneEx function will resize the window  so that the available working area has the given width and  height in pixels. Remarks This method is only used during recording if the DWORD  registry key ResizeWorkingPaneEx in patch HKCU\Soft­ ware\SAP\SAPGUI Front\SAP Frontend Server\Scripting ex­ ists and has the value 1. Table GUI_FKEY Refer to Table GUI_FKEY [page 152]

