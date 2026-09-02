# GuiFrameWindow

> **Type**: `Class` | **Section**: `1.2.27`
> **Inherits from**: [`GuiVContainer`](GuiVContainer.md)

---

## 📖 Description

A GuiFrameWindow is a high level visual object in the runtime hierarchy. It can be either the main window or a  modal popup window. See the GuiMainWindow and GuiModalWindow sections for examples. GuiFrameWindow  itself is an abstract interface. GuiFrameWindow extends the GuiVContainer Object [page 286]. The type prefix  is wnd, the name is wnd plus the window number in square brackets.

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
| **`ElementVisualizationMode`** | `Read-write` | `Boolean` | When elementVisualizationMode is enabled, a hit test can be  performed on SAP GUI by moving the cursor over the win­ dow. The hit event of the session is fired when a component  was found at the mouse position. |
| **`GuiFocus`** | `Read-only` | `Public Property GuiFocus() As` | GuiVComponent The SystemFocus only supports dynpro elements. T o receive  information about the currently focused ActiveX control you  can access the GuiFocus property. |
| **`Handle`** | `Read-only` | `Long` | The window handle of the control that is connected to the  GuiShell. This is the handle of the underlying window in Mi­ crosoft Windows. |
| **`Iconic`** | `Read-only` | `Boolean` | This property is T rue if the window is iconified. It is possible  to execute script commands on an iconified window , but  there may be undefined results, especially when controls are  involved, as these may have invalid size settings. |
| **`SystemFocus`** | `Read-only` | `Public Property SystemFocus() As` | GuiVComponent The systemFocus specifies the component that the SAP sys­ tem is currently seeing as being focused. This value is only  valid for dynpro elements and might therefore differ from the  focus as seen on the frontend. |
| **`WorkingPaneHeight`** | `Read-only` | `Public Property WorkingPaneHeight()` | As Long This is the height of the working pane in character metric. |
| **`WorkingPaneWidth`** | `Read-only` | `Public Property WorkingPaneWidth() As` | Long This is the width of the working pane in character metric.  The working pane is the area between the toolbars in the  upper area of the window and the status bar at the bottom of  the window. |

---

## ⚙️ Methods

### `Close`

```vb
Public Sub Close()
```

The function attempts to close the window. T rying to close  the last main window of a session will not succeed imme­ diately; the dialog ‘Do you really want to log off?’ will be  displayed first.

### `CompBitmap`

```vb
Public Function CompBitmap( _    ByVal Filename1 As String, _
```

ByVal Filename2 As String _ ) As Long This method compares two bitmap files pixel by pixel. Return Type The method returns one of the following values: • 0: The files do not differ • 1: The files differ in size • 2: The files have different content • 3: There was an error

### `HardCopy`

```vb
Public Function HardCopy( _    ByVal Filename As String, _
```

Optional ByVal ImageType As  Variant, _    Optional ByVal xPos As Variant, _    Optional ByVal yPos As Variant, _    Optional ByVal nWidth As Variant, _    Optional ByVal nHeight As Variant _ ) As String This function dumps a hardcopy of the window as a bitmap  file to disk. The parameter is the name of the file. If the func­ tion succeeds, then the return value will be the fully qualified  path of the file. If no path information is given, then the file  will be written to the SAP GUI Documents Folder. Filename ImageType The following values are  valid: • 0: BMP • 1: JPG • 2: PNG • 3: GIF • 4: TIFF BMP is the default format. xPos If the optional parameters  xPos, yPos, nWidth and  nHeight are set, only the  specified rectangle of the  main window will be cap­ tured. yPos If the optional parameters  xPos, yPos, nWidth and  nHeight are set, only the  specified rectangle of the  main window will be cap­ tured. nWidth If the optional parameters  xPos, yPos, nWidth and  nHeight are set, only the  specified rectangle of the  main window will be cap­ tured. nHeight If the optional parameters  xPos, yPos, nWidth and  nHeight are set, only the  specified rectangle of the  main window will be cap­ tured.

### `HardCopyToMemory`

```vb
Public Function HardCopyToMemory( _    Optional ByVal ImageType As
```

Variant _ ) As Variant This function returns a hardcopy of the window as a safe  array of bytes. The following values are valid: • 0: BMP • 1: JPG • 2: PNG • 3: GIF BMP is the default format.  Sample Code The following example shows the hardcopy of an SAP  GUI main window ("wnd[0]"). If Not IsObject(application) Then    Set SapGuiAuto  =  GetObject("SAPGUI")    Set application =  SapGuiAuto.GetScriptingEngine End If If Not IsObject(connection) Then    Set connection =  application.Children(0) End If If Not IsObject(session) Then    Set session    =  connection.Children(0) End If Image =  session.findById("wnd[0]").HardCopy ToMemory() Const adTypeBinary          = 1 Const adSaveCreateOverWrite = 2    Dim BinaryStream Set BinaryStream =  CreateObject("ADODB.Stream")    BinaryStream.Type = adTypeBinary   BinaryStream.Open BinaryStream.Write Image BinaryStream.SaveToFile  "C:\screenshot.bmp",  adSaveCreateOverWrite MsgBox "Done"

### `Iconify`

```vb
Public Sub Iconify()
```

This will set a window to the iconified state. It is not possible  to iconify a specific window of a session; both the main win­ dow and all existing modals will be iconfied.

### `IsVKeyAllowed`

```vb
Public Function IsVKeyAllowed( _    ByVal VKey As Integer _ ) As Byte
```

This function returns T rue if the virtual key VKey is currently  available. The VKeys are defined in the menu painter.

### `JumpBackward`

```vb
Public Sub JumpBackward()
```

Execute the Ctrl+Shift+Tab key on the window to jump back­ ward one block.

### `JumpForward`

```vb
Public Sub JumpForward()
```

Execute the Ctrl+Tab key on the window to jump forward one  block.

### `Maximize`

```vb
Public Sub Maximize()
```

This will maximize a window. It is not possible to maximize  a modal window; it is always the main window which will be  maximized.

### `Restore`

```vb
Public Sub Restore()
```

This will restore a window from its iconified state. It is not  possible to restore a specific window of a session; both the  main window and all existing modals will be restored.

### `SendVKey`

```vb
Public Sub SendVKey( _     ByVal VKey As Integer _  )
```

The virtual key VKey is executed on the window. The VKeys  are defined in the menu painter.

### `ShowMessageBox`

```vb
Public Function ShowMessageBox( _    ByVal Title As String, _
```

ByVal Text As String, _    ByVal MsgIcon As Long, _    ByVal MsgType As Long _ ) As Long This method shows the message box modal to the GuiFra­ meWindow. The title and text parameters set the title and  text of the message box. The return value will be one of the  MESSAGE_RESULT_* values. Title Text MsgIcon The msgIcon parameter  sets the icon to be used for  the message box and should  be set to one of the MES­ SAGE_TYPE_* constants. MsgType msgType sets the buttons  available on the message  box and should be set to one  of the MESSAGE_OPTION*  constants.

### `TabBackward`

```vb
Public Sub TabBackward()
```

Execute the Shift+Tab key on the window to jump backward  one element.

### `TabForward`

```vb
Public Sub TabForward()
```

Execute the Tab key on the window to jump forward one  element.

