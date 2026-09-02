# GuiGridView

> **Type**: `Class` | **Section**: `1.2.30`
> **Inherits from**: [`GuiShell`](GuiShell.md)

---

## 📖 Description

The grid view is similar to the dynpro table control, but significantly more powerful. GuiGridView extends the  GuiShell Object [page 207]. Example

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
* `All additional properties of the GuiShell Object [page 207]:`
* `AccDescription`
* `DragDropSupported`
* `Handle`
* `OcxEvents`
* `SubType`

---

## 📋 Properties

| Property | Access | Signature / Type | Description |
|:---|:---|:---|:---|
| **`ColumnCount`** | `Read-only` | `Long` | This property represents the number of columns in the con­ trol. |
| **`ColumnOrder`** | `Read-write` | `Object` | This collection contains all the column identifiers in the or­ der in which they are currently displayed. Passing an invalid  column identifier to this property will raise an exception. |
| **`CurrentCellColumn`** | `Read-write` | `Public Property CurrentCellColumn As` | String The string identifying a column is the field name defined in  the SAP data dictionary. In the example above the identifiers  are named CARRID, CONNID, FLDATE, PRICE etc. |
| **`CurrentCellRow`** | `Read-write` | `Long` | The row index of the current cell ranges from 0 to the num­ ber of rows less 1, with -1 being the index of the title row. |
| **`FirstVisibleColumn`** | `Read-write` | `Public Property FirstVisibleColumn As` | String This property represents the first visible column of the scrol­ lable area of the grid view. Fixed columns are ignored. Set­ ting the property to an invalid column identifier will raise an  exception. |
| **`FirstVisibleRow`** | `Read-write` | `Public Property FirstVisibleRow As` | Long This is the index of the first visible row in the grid. Setting  this property to an invalid row index will raise an exception. |
| **`FrozenColumnCount`** | `Read-only` | `Public Property FrozenColumnCount As` | Long This property represents the number of columns that are  excluded from horizontal scrolling. |
| **`RowCount`** | `Read-only` | `Long` | This property represents the number of rows in the control. |
| **`SelectedCells`** | `Read-write` | `Public Property SelectedCells As` | Object The collection of selected cells contains strings, each of  which has the format “<index of the row>,<column identi­ fier>” , such as “0,CARRID” . T rying to set this property to an  invalid value will raise an exception. |
| **`SelectedColumns`** | `Read-write` | `Public Property SelectedColumns As` | Object The selected columns are available as a collection of strings  like the currentCellColumn string. Setting this property can  raise an exception, if the new collection contains an invalid  column identifier. |
| **`SelectedRows`** | `Read-write` | `String` | The string is a comma separated list of row index numbers  or index ranges, such as “1,2,4-8,10” .Setting this property to  an invalid string or a string containing invalid row indices will  raise an exception. |
| **`SelectionMode`** | `Read-only` | `Public Property SelectionMode As` | String Possible values are • RowsAndColumns: Only rows and columns can be se­ lected. Individual rectangular areas of cells are not al­ lowed. • ListboxSingle: Only one single row can be selected. • ListboxMultiple: One or more rows can be selected. • Free: Any kind of selection can be made. |
| **`Title`** | `Read-only` | `String` | This property represents title of the grid control. |
| **`ToolbarButtonCount`** | `Read-only` | `Public Property ToolbarButtonCount As` | Long The number of toolbar buttons including separators. |
| **`VisibleRowCount`** | `Read-only` | `Public Property VisibleRowCount As` | Long Retrieves the number of visible rows of the grid. |

---

## ⚙️ Methods

### `ClearSelection`

```vb
Public Sub ClearSelection()
```

Calling clearSelection removes all row, column and cell se­ lections.

### `Click`

```vb
Public Sub Click( _     ByVal Row As Long, _
```

ByVal Column As String _  ) This function emulates a mouse click on a given cell if the  parameters are valid and raises an exception otherwise.

### `ClickCurrentCell`

```vb
Public Sub ClickCurrentCell()
```

This function emulates a mouse click on the current cell.

### `ContextMenu`

```vb
Public Sub ContextMenu()
```

Calling contextMenu emulates the context menu request.

### `CurrentCellMoved`

```vb
Public Sub CurrentCellMoved()
```

This function notifies the server that a different cell has been  made the current cell. It must be called whenever the cur­ rent cell is changed.

### `DeleteRows`

```vb
Public Sub DeleteRows( _     ByVal Rows As String _  )
```

The parameter rows is a comma separated string of indices  or index ranges, for example “3,5-8,14,15” . The entries must  be ordered and not overlap, otherwise an exception is raised.

### `DeselectColumn`

```vb
Public Sub DeselectColumn( _     ByVal Column As String _  )
```

This function removes the specified column from the collec­ tion of the selected columns.

### `DoubleClick`

```vb
Public Sub DoubleClick( _     ByVal Row As Long, _
```

ByVal Column As String _  ) This function emulates a mouse double click on a given cell if  the parameters are valid and raises an exception otherwise.

### `DoubleClickCurrentCell`

```vb
Public Sub DoubleClickCurrentCell()
```

This function emulates a mouse double click on the current  cell.

### `DuplicateRows`

```vb
Public Sub DuplicateRows( _     ByVal Rows As String _  )
```

The parameter rows is a comma separated string of indices  or index ranges, for example “3,5-8,14,15” . For any single  index a copy of the row will be inserted at the given index.  If a range of indexes is duplicated then all the new lines are  inserted as one block, before the old lines. The entries must  be ordered and not overlap, otherwise an exception is raised. Example 0 Value A 1 Value B If rows is “0,1” then the resulting table would be: 0 Value A 1 Value A 2 Value B 3 Value B If on the other hand rows is “0-1” then the resulting table is: 0 Value A 1 Value B 2 Value A 3 Value B

### `GetCellChangeable`

```vb
Public Function GetCellChangeable( _    ByVal Row As Long, _
```

ByVal Column As String _ ) As Byte This function returns T rue if the specified cell is changeable.

### `GetCellCheckBoxChecked`

```vb
Public Function 
GetCellCheckBoxChecked( _    ByVal Row As Long, _
```

ByVal Column As String _ ) As Byte Returns T rue if the checkbox at the specified position is  checked. Throws an exception if there is no checkbox in the  specified cell.

### `GetCellColor`

```vb
Public Function GetCellColor( _    ByVal Row As Long, _
```

ByVal Column As String _ ) As Long Returns an identifier for the color of the cell. This can be  used to retrieve the color information using GetColorInfo.

### `GetCellHeight`

```vb
Public Function GetCellHeight( _    ByVal Row As Long, _
```

ByVal Column As String _ ) As Long Returns the height of the cell in pixels.

### `GetCellHotspotType`

```vb
Public Function GetCellHotspotType( _    ByVal Row As Long, _
```

ByVal Column As String _ ) As String  Returns information on whether the cell is a hotspot or a  link. Method isCellHotspot cannot distinguish hotspots  and links, so this method can be used if you need to know  what the exact type is. Possible values are: • None (the cell does not have a hotspot nor a link) • Hotspot (the cell has a hotspot or a hotspot AND a link) • Link (the cell has a link)

### `GetCellIcon`

```vb
Public Function GetCellIcon( _    ByVal Row As Long, _
```

ByVal Column As String _ ) As String Return the icon string of the cell, if the cell contains an icon.  The string has the ABAP icon format '@xy@', where xy is a  number or character.

### `GetCellLeft`

```vb
Public Function GetCellLeft( _    ByVal Row As Long, _
```

ByVal Column As String _ ) As Long Returns the left position of the cell in client coordinates.

### `GetCellListBoxCount`

```vb
Public Function GetCellListBoxCount( _    ByVal Row As Long, _
```

ByVal Column As String _      ) As Long Returns the number of entries in the listbox of the cell.  Throws an exception if there is no listbox (valuelist / drop­ down) in the specified cell. Also throws an exception if an  invalid row or column is specified.

### `GetCellListBoxCurIndex`

```vb
Public Function 
GetCellListBoxCurIndex( _    ByVal Row As Long, _
```

ByVal Column As String _      ) As String Returns the index (0-based) of the currently selected listbox  entry. Throws an exception if there is no listbox (valuelist /  dropdown) in the specified cell. Also throws an exception  if an invalid row or column is specified. Default value (no  selection) is -1.

### `GetCellMaxLength`

```vb
Public Function GetCellMaxLength( _    ByVal Row As Long, _
```

ByVal Column As String _ ) As Long Returns the maximum length of the cell in number of bytes.

### `GetCellState`

```vb
Public Function GetCellState( _    ByVal Row As Long, _
```

ByVal Column As String _ ) As String Returns the state of the cell. Possible values are: • Normal • Error • Warning • Info

### `GetCellTooltip`

```vb
Public Function GetCellTooltip( _    ByVal Row As Long, _
```

ByVal Column As String _ ) As String Returns the tooltip of the cell.

### `GetCellTop`

```vb
Public Function GetCellTop( _    ByVal Row As Long, _
```

ByVal Column As String _ ) As Long Returns the top position of the cell in client coordinates.

### `GetCellType`

```vb
Public Function GetCellType( _    ByVal Row As Long, _
```

ByVal Column As String _ ) As String This function returns the type of the specified cell. Possible  values are: • Normal • Button • Checkbox • ValueList • RadioButton

### `GetCellValue`

```vb
Public Function GetCellValue( _    ByVal Row As Long, _
```

ByVal Column As String _ ) As String Returns the value of the cell as a string.

### `GetCellWidth`

```vb
Public Function GetCellWidth( _    ByVal Row As Long, _
```

ByVal Column As String _ ) As Long Returns the width of the cell in pixels.

### `GetColorInfo`

```vb
Public Function GetColorInfo( _    ByVal Color As Long _ ) As String
```

Returns the description for the color of the cell.

### `GetColumnDataType`

```vb
Public Function GetColumnDataType( _    ByVal Column As String _ ) As String
```

Returns the data type of the column according to the 'built-in  datatypes' of the XML schema standard.

### `GetColumnOperationType`

```vb
Public Function 
GetColumnOperationType ( _    ByVal Column As String _
```

) As String  Returns the type of mathematical operation applied to the  column. Possible values are: • None • Mean • Minimum • Maximum This method as available as of SAP GUI for Windows 7 .70  Patchlevel 1.

### `GetColumnPosition`

```vb
Public Function GetColumnPosition( _    ByVal Column As String _ ) As Long
```

Returns the position of the column as shown on the screen,  starting from 1.

### `GetColumnSortType`

```vb
Public Function GetColumnSortType( _    ByVal Column As String _ ) As String
```

Returns the sort type of the column. Possible values are: • None • Ascending • Descending

### `GetColumnTitles`

```vb
Public Function GetColumnTitles( _    ByVal Column As String _ ) As Object
```

This function returns a collection of strings that are used  to display the title of a column. The control chooses the  appropriate title according to the width of the column.

### `GetColumnTooltip`

```vb
Public Function GetColumnTooltip( _    ByVal Column As String _ ) As String
```

The tooltip of a column contains a text which is designed to  help the user understands the meaning of the column.

### `GetColumnTotalType`

```vb
Public Function GetColumnTotalType( _    ByVal Column As String _ ) As String
```

Returns the total type of the column. Possible values are: • None • T otal • Subtotal

### `GetDisplayedColumnTitle`

```vb
Public Function 
GetDisplayedColumnTitle( _    ByVal Column As String _ ) As String
```

This function returns the title of the column that is currently  displayed. This text is one of the values of the collection  returned from the function “getColumnTitles” .

### `GetRowTotalLevel`

```vb
Public Function GetRowTotalLevel( _    ByVal Row As Long _ ) As Long
```

Returns the level of the row.

### `GetSymbolInfo`

```vb
Public Function GetSymbolInfo( _    ByVal Symbol As String _ ) As String
```

Returns the description for the symbol in the cell.

### `GetToolbarButtonChecked`

```vb
Public Function 
GetToolbarButtonChecked( _    ByVal ButtonPos As Long _ ) As Byte
```

Returns T rue if the button is currently checked (pressed).

### `GetToolbarButtonEnabled`

```vb
Public Function 
GetToolbarButtonEnabled( _    ByVal ButtonPos As Long _ ) As Byte
```

Indicates if the button can be pressed.

### `GetToolbarButtonIcon`

```vb
Public Function 
GetToolbarButtonIcon( _    ByVal ButtonPos As Long _ ) As String
```

Returns the name of the icon of the specified toolbar button.

### `GetToolbarButtonId`

```vb
Public Function GetToolbarButtonId( _    ByVal ButtonPos As Long _ ) As String
```

Returns the ID of the specified toolbar button, as defined in  the ABAP data dictionary.

### `GetToolbarButtonText`

```vb
Public Function 
GetToolbarButtonText( _    ByVal ButtonPos As Long _ ) As String
```

Returns the text of the specified toolbar button.

### `GetToolbarButtonTooltip`

```vb
Public Function 
GetToolbarButtonTooltip( _    ByVal ButtonPos As Long _ ) As String
```

Returns the tooltip of the specified toolbar button.

### `GetToolbarButtonType`

```vb
Public Function 
GetToolbarButtonType( _    ByVal ButtonPos As Long _ ) As String
```

Returns the type of the specified toolbar button. Possible  values are • Button • ButtonAndMenu • Menu • Separator • Group • CheckBox

### `GetToolbarFocusButton`

```vb
Public Function 
GetToolbarFocusButton() As Long
```

Returns the position of the toolbar button that has the focus.  If no button in the toolbar has the focus, the method returns  -1.

### `HasCellF4Help`

```vb
Public Function HasCellF4Help( _    ByVal Row As Long, _
```

ByVal Column As String _ ) As Byte Returns T rue if the cell has a value help.

### `HistoryCurEntry`

```vb
Public Function HistoryCurEntry( _    ByVal Row As Long, _
```

ByVal Column As String _ ) As String Returns the text of the presently selected entry of the his­ tory list in the specified cell.  Note • Y ou can only use this method from an external pro­ gram (like Freedom Scientific JAWS), because the  history list is collapsed when a script accesses SAP  GUI • If an invalid row index or column  name is specified, the method raises  an exception (RowIndexOutOfRange /  WrongColumnName) • This method is available as of SAP GUI for Windows  7 .60

### `HistoryCurIndex`

```vb
Public Function HistoryCurIndex( _    ByVal Row As Long, _
```

ByVal Column As String _ ) As Long Returns the index (0-based) of the presently selected entry  of the history list in the specified cell.  Note • Y ou can only use this method from an external pro­ gram (like Freedom Scientific JAWS), because the  history list is collapsed when a script accesses SAP  GUI • If an invalid row index or column  name is specified, the method raises  an exception (RowIndexOutOfRange /  WrongColumnName) • This method is available as of SAP GUI for Windows  7 .60

### `HistoryIsActive`

```vb
Public Function HistoryIsActive( _    ByVal Row As Long, _
```

ByVal Column As String _ ) As Byte This method returns true if the input history list is open for  the specified cell  Note • Y ou can only use this method from an external pro­ gram (like Freedom Scientific JAWS), because the  history list is collapsed when a script accesses SAP  GUI • If an invalid row index or column  name is specified, the method raises  an exception (RowIndexOutOfRange /  WrongColumnName) • This method is available as of SAP GUI for Windows  7 .60

### `HistoryList`

```vb
Public Function HistoryList( _    ByVal Row As Long, _
```

ByVal Column As String _ ) As GuiCollection This method retrieves the list of input history entries of the  specified GuiGridView cell as a GuiCollection.  Note • The values of the history list depend on the current  value contained in the cell • If an invalid row index or column  name is specified, the method raises  an exception (RowIndexOutOfRange /  WrongColumnName) • This method is available as of SAP GUI for Windows  7 .60

### `InsertRows`

```vb
Public Sub InsertRows( _     ByVal Rows As String _  )
```

The parameter rows is a comma separated text of indices or  index ranges, for example “3,5-8,14,15” . For any single index,  a new row will be added at the given index, moving the old  row one line down. If a range of indexes is inserted then  all the new lines are inserted as one block, before any of  the old lines. The entries must be ordered and not overlap,  otherwise, an exception is raised. Example 0 Value A 1 Value B If rows is “0,1” , then the resulting table would be: 0 1 Value A 2 3 Value B If, on the other hand, rows is “0-1” , then the resulting table is: 0 1 2 Value A 3 Value B

### `IsCellHotspot`

```vb
Public Function IsCellHotspot( _    ByVal Row As Long, _
```

ByVal Column As String _ ) As Byte Returns T rue if the cell is a link.

### `IsCellSymbol`

```vb
Public Function IsCellSymbol( _    ByVal Row As Long, _
```

ByVal Column As String _ ) As Byte Returns T rue if the text in the cell is displayed in the SAP  symbol font.

### `IsCellTotalExpander`

```vb
Public Function IsCellTotalExpander( _    ByVal Row As Long, _
```

ByVal Column As String _ ) As Byte Returns T rue if the cell contains a total expander button.

### `IsColumnFiltered`

```vb
Public Function IsColumnFiltered( _    ByVal Column As String _ ) As Byte
```

Returns T rue if a filter was applied to the column.

### `IsColumnKey`

```vb
Public Function IsColumnKey( _    ByVal Column As String _ ) As Byte
```

Returns T rue if the column is marked as a key column.

### `IsTotalRowExpanded`

```vb
Public Function IsTotalRowExpanded( _    ByVal Row As Long _ ) As Byte
```

Returns true if the row containing an expander is currently  expanded.

### `ModifyCell`

```vb
Public Sub ModifyCell( _     ByVal Row As Long, _
```

ByVal Column As String, _     ByVal Value As String _  ) If row and column identify a valid editable cell and value has  a valid type for this cell, then the value of the cell is changed.  Otherwise, an exception is raised.

### `ModifyCheckBox`

```vb
Public Sub ModifyCheckBox( _     ByVal Row As Long, _
```

ByVal Column As String, _     ByVal Checked As Boolean _  ) If row and column identify a valid editable cell containing a  checkbox, then the value of the cell is changed. Otherwise,  an exception is raised.

### `MoveRows`

```vb
Public Sub MoveRows( _     ByVal FromRow As Long, _
```

ByVal ToRow As Long, _     ByVal DestRow As Long _  ) The rows with an index greater than or equal to fromRow up  to an index less than or equal to toRow are moved to the  position of destRow. Passing invalid index values as parameters raises an excep­ tion.

### `PressButton`

```vb
Public Sub PressButton( _     ByVal Row As Long, _
```

ByVal Column As String _  ) This function emulates pressing a button placed in a given  cell. It will raise an exception if the cell does not contain a  button, or does not even exist.

### `PressButtonCurrentCell`

```vb
Public Sub PressButtonCurrentCell()
```

This function emulates pressing a button placed in the cur­ rent cell. It will raise an exception if the cell does not contain  a button.

### `PressColumnHeader`

```vb
Public Sub PressColumnHeader( _     ByVal Column As String _  )
```

This function emulates a mouse click on the header of the  column if the parameter identifies a valid column and raises  an exception otherwise.

### `PressEnter`

```vb
Public Sub PressEnter()
```

This emulates pressing the Enter key.

### `PressF1`

```vb
Public Sub PressF1()
```

This emulates pressing the F1 key while the focus is on the  grid view.

### `PressF4`

```vb
Public Sub PressF4()
```

This emulates pressing the F4 key.

### `PressToolbarButton`

```vb
Public Sub PressToolbarButton( _     ByVal Id As String _  )
```

This function emulates clicking a button in the grid view’s  toolbar.

### `PressToolbarContextButton`

```vb
Public Sub 
PressToolbarContextButton( _     ByVal Id As String _  )
```

This emulates opening the context menu of the grid view’s  toolbar.

### `PressTotalRow`

```vb
Public Sub PressTotalRow( _     ByVal Row As Long, _
```

ByVal Column As String _  ) Pressing the total row button expands or condenses the  grouped rows. If the selected cell is not a total row cell an  exception is raised.

### `PressTotalRowCurrentCell`

```vb
Public Sub PressTotalRowCurrentCell()
```

This function differs from pressT otalRow only in that it tries  to press the expansion button on the current cell.

### `SelectAll`

```vb
Public Sub SelectAll()
```

This function selects the whole grid content (i.e. all rows and  all columns).

### `SelectColumn`

```vb
Public Sub SelectColumn( _     ByVal Column As String _  )
```

This function adds the specified column to the collection of  the selected columns.

### `SelectionChanged`

```vb
Public Sub SelectionChanged()
```

This function notifies the server that the selection has  changed.

### `SelectToolbarMenuItem`

```vb
Public Sub SelectToolbarMenuItem( _     ByVal Id As String _  )
```

This function emulates the selection of an item from the  context menu of the grid view’s toolbar. The parameter  should be the function code of the item.

### `SetColumnWidth`

```vb
Public Sub SetColumnWidth( _     ByVal Column As String, _
```

ByVal Width As Long _  ) The width of a column can be set using this function. The  width is given in characters. For proportional fonts this re­ fers to the width of an average character. Depending on the  contents of the cell more or less characters may fit in the  column. If the parameter is invalid an exception is raised.

### `SetCurrentCell`

```vb
Public Sub SetCurrentCell( _     ByVal Row As Long, _
```

ByVal Column As String _  ) If row and column identify a valid cell, this cell becomes the  current cell. Otherwise, an exception is raised.

### `TriggerModified`

```vb
Public Sub TriggerModified()
```

Notifies the server of multiple changes in cells. T ypically this  method should be called after multiple calls to ModifyCell.

