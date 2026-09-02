# GuiApoGrid

> **Type**: `Class` | **Section**: `1.2.2`
> **Inherits from**: [`GuiShell`](GuiShell.md)

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
* `All properties of the GuiShell Object [page 207]:`
* `AccDescription`
* `DragDropSupported`
* `Handle`
* `OcxEvents`
* `SubType`
* `All properties of the GuiContainer Object [page 87]:`
* `Children`

**All methods of the GuiContainer Object [page 87]:**:
* `FindById`

**All properties of the GuiComponent Object [page 82]:**:
* `ContainerType`
* `Id`
* `Name`
* `Parent`
* `Type`
* `TypeAsNumber`

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

---

## 📋 Properties

| Property | Access | Signature / Type | Description |
|:---|:---|:---|:---|
| **`ColumnCount`** | `Read-only` | `Long` | This property represents the number of columns in the con­ trol. |
| **`CurrentCellColumn`** | `Read-only` | `Public Property CurrentCellColumn As` | Long The index of the column that contains the current cell. |
| **`CurrentCellRow`** | `Read-only` | `Long` | The row index of the current cell ranges from 0 to the num­ ber of rows less 1, with -1 being the index of the title row. |
| **`FirstVisibleColumn`** | `Read-only` | `Public Property FirstVisibleColumn As` | Long This property represents the first visible column of the scrol­ lable area of the APOGrid control. |
| **`FirstVisibleRow`** | `Read-only` | `Public Property FirstVisibleRow As` | Long This is the index of the first visible row in the grid. Setting  this property to an invalid row index will raise an exception. |
| **`FixedColumnsLeft`** | `Read-only` | `Public Property FixedColumnsLeft As` | Long The number of fixed columns at the left side of the grid. |
| **`FixedColumnsRight`** | `Read-only` | `Public Property FixedColumnsRight As` | Long The number of fixed columns at the right side of the grid. |
| **`FixedRowsBottom`** | `Read-only` | `Public Property FixedRowsBottom As` | Long The number of fixed rows at the bottom of the grid. |
| **`FixedRowsTop`** | `Read-only` | `Long` | The number of fixed rows at the top of the grid. |
| **`RowCount`** | `Read-only` | `Long` | This property represents the number of rows in the control. |
| **`SelectedCells`** | `Read-only` | `Public Property SelectedCells As` | Object The collection of selected cells. T rying to set this property to  an invalid value will raise an exception. |
| **`SelectedColumns`** | `Read-only` | `Public Property SelectedColumns As` | String The selected columns are available as a collection. Setting  this property can raise an exception, if the new collection  contains an invalid column. |
| **`SelectedColumnsObject`** | `Read-only` | `Public Property SelectedColumnsObject` | As Object |
| **`SelectedRows`** | `Read-only` | `String` | The selected rows are available as a collection. Setting this  property can raise an exception, if the new collection con­ tains an invalid row. |
| **`SelectedRowsObject`** | `Read-only` | `Public Property SelectedRowsObject As` | Object |
| **`VisibleColumnCount`** | `Read-only` | `Public Property VisibleColumnCount As` | Long Retrieves the number of visible columns of the grid. |
| **`VisibleRowCount`** | `Read-only` | `Public Property VisibleRowCount As` | Long Retrieves the number of visible rows of the grid. |

---

## ⚙️ Methods

### `CancelCut`

```vb
Public Sub CancelCut()
```

Abort the cut operation.

### `ClearSelection`

```vb
Public Sub ClearSelection()
```

Calling clearSelection removes all row, column and cell se­ lections.

### `ContextMenu`

```vb
Public Sub ContextMenu( _     ByVal Column As Long, _
```

ByVal Row As     Long _  ) Calling contextMenu emulates the context menu request.

### `Cut`

```vb
Public Sub Cut()
```

Cut the selected cells.

### `DeselectCell`

```vb
Public Sub DeselectCell( _     ByVal Column As Long, _
```

ByVal Row As Long _  ) Deselect the specified cells. This function removes the  specified cells from the collection of selected cells.

### `DeselectColumn`

```vb
Public Sub DeselectColumn( _     ByVal Column As Long _  )
```

This function removes the specified column from the collec­ tion of the selected columns.

### `DeselectRow`

```vb
Public Sub DeselectRow( _     ByVal Row As Long _  )
```

This function removes the specified row from the collection  of the selected rows.

### `DoubleClickCell`

```vb
Public Sub DoubleClickCell( _     ByVal Column As Long, _
```

ByVal Row As     Long _  ) This function emulates a mouse double-click on a given cell  if the parameters are valid and raises an exception other­ wise.

### `GetBgdColorInfo`

```vb
Public Function GetBgdColorInfo( _    ByVal Row As Long, _
```

ByVal Column As Long _ ) As String This function returns the background color of the specified  cell.

### `GetCellChangeable`

```vb
Public Function GetCellChangeable( _    ByVal Column As Long, _
```

ByVal Row As Long _ ) As Byte This function returns T rue if the specified cell is editable.

### `GetCellFormat`

```vb
Public Function GetCellFormat( _    ByVal Column As Long, _
```

ByVal Row As Long _ ) As String

### `GetCellTooltip`

```vb
Public Function GetCellTooltip( _    ByVal Column As Long, _
```

ByVal Row As Long _ ) As String This function returns the tooltip of the specified cell.

### `GetCellValue`

```vb
Public Function GetCellValue( _    ByVal Column As Long, _
```

ByVal Row As Long _ ) As String This function returns the value of the specified cell as a  string.

### `GetFgdColorInfo`

```vb
Public Function GetFgdColorInfo( _    ByVal Row As Long, _
```

ByVal Column As Long _ ) As String This function returns the font color of the specified cell.

### `GetIconInfo`

```vb
Public Function GetIconInfo( _    ByVal Row As Long, _
```

ByVal Column As Long _ ) As String

### `IsCellSelected`

```vb
Public Function IsCellSelected( _    ByVal Column As Long, _
```

ByVal Row As Long _ ) As Byte Returns T rue if the specified cell is selected.

### `IsColSelected`

```vb
Public Function IsColSelected( _    ByVal col As Long _ ) As Byte
```

Returns T rue if the specified column is selected.

### `IsRowSelected`

```vb
Public Function IsRowSelected( _    ByVal Row As Long _ ) As Byte
```

Returns T rue if the specified row is selected.

### `Paste`

```vb
Public Function Paste( _    ByVal CellValues As Object, _
```

ByVal ColumnCount As Long _ ) As Long T riggers a paste operation.

### `PressEnter`

```vb
Public Sub PressEnter()
```

This emulates pressing the Enter key.

### `SelectAll`

```vb
Public Sub SelectAll()
```

This function selects the whole grid content (i.e. all rows and  all columns).

### `SelectCell`

```vb
Public Sub SelectCell( _     ByVal Column As Long, _
```

ByVal Row As     Long _ ) Select the specified cell.

### `SelectColumn`

```vb
Public Sub SelectColumn( _     ByVal Column As Long _  )
```

Select the specified column.

### `SelectRow`

```vb
Public Sub SelectRow( _     ByVal Row As Long _  )
```

Select the specified row.

### `SetCellValue`

```vb
Public Function SetCellValue( _    ByVal Column As Long, _
```

ByVal Row As Long, _    ByVal Value As String _ ) As String This function enters the specified value in the specified cell.

## ⚡ Events

### `CreateSession`

```vb
Public Event CreateSession( _    ByVal Session As GuiSession _ )
```

This event is raised whenever a new session is created, irre­ spective of whether of the session being created manually,  from ABAP or by a script. The event is only raised for a  session if the scripting support has been enabled for the  corresponding backend.  Example The following script attaches itself to the SAPlogon  process and displays a pop-up whenever a new session  is created.  Dim objSapGui Set objSapGui = GetObject("SAPGUI") Dim objScriptingEngine Set objScriptingEngine =  objSapGui.GetScriptingEngine WScript.ConnectObject  objScriptingEngine,  "Engine_" Dim Waiting Waiting = 1 Do While (Waiting = 1)  WScript.Sleep(100) Loop Set objScriptingEngine = Nothing Set objSapGui = Nothing Sub Engine_CreateSession(ByVal  Session)  Dim result  result = MsgBox("Session  created", vbOKCancel)  If result = vbCancel then    Waiting = 0  End If End Sub

### `DestroySession`

```vb
Public Event DestroySession( _    ByVal Session As GuiSession _ )
```

This event is raised before a session is destroyed . This can  be done either by closing the main window manually, or by  calling the closeSession method of GuiConnection.  Example Y ou can handle this event from VBScript by adding the  following procedure to the sample script on previous  page:  Sub Engine_DestroySession(ByVal  Session)  Dim result  result = MsgBox("Session  destroyed",vbOKCancel)  If result = vbCancel then    Waiting = 0  End If End Sub

### `Error`

```vb
Public Event Error( _    ByVal ErrorId As Long, _
```

ByVal Desc1 As String, _    ByVal Desc2 As String, _    ByVal Desc3 As String, _    ByVal Desc4 As String _ ) An error event is currently only raised, if the wrapper library  required to access a SAP GUI ActiveX control from a script is  not available. This event is also available on the GuiSession  in which the error occurred.

### `IgnoreSession`

```vb
Public Event IgnoreSession( _    ByVal SessionMainWindowHandle As
```

Integer _ ) The event is fired when a session is set to ‘Ignored’ using  IgnoreSession function. This event is only fired when using  SAP GUI Scripting while running eCATT in parallel.

