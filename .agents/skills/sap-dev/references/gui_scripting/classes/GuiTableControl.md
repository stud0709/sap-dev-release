# GuiTableControl

> **Type**: `Class` | **Section**: `1.2.61`
> **Inherits from**: [`GuiVContainer`](GuiVContainer.md) | **ID Prefix**: `tbl`

---

## 📖 Description

The table control is a standard dynpro element, in contrast to the GuiCtrlGridView, which looks similar.  GuiTableControl extends the GuiVContainer Object [page 286]. The type prefix is tbl, the name is the fieldname  taken from the SAP data dictionary.

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
| **`CharHeight`** | `Read-only` | `Long` | Height of the GuiTableControl in character metric. |
| **`CharLeft`** | `Read-only` | `Long` | Left coordinate of the GuiTableControl in character metric. |
| **`CharTop`** | `Read-only` | `Long` | Top coordinate of the GuiTableControl in character metric. |
| **`CharWidth`** | `Read-only` | `Long` | Width of the GuiTableControl in character metric. |
| **`ColSelectMode`** | `Read-only` | `Public Property ColSelectMode As` | GuiTableSelectionType There are three different modes for selecting columns or  rows, which are defined in the enumeration type GuiTableSe­ lectionType. |
| **`Columns`** | `Read-only` | `Public Property Columns As` | GuiCollection The members of this collection are of GuiTableColumn type.  Therefore they do not support properties like id or name. |
| **`CurrentCol`** | `Read-only` | `Long` | Zero-based index of the current column. |
| **`CurrentRow`** | `Read-only` | `Long` | Zero-based index of the current row. |
| **`HorizontalScrollbar`** | `Read-only` | `Public Property HorizontalScrollbar` | As GuiScrollbar The horizontal scrollbar of the table control. |
| **`RowCount`** | `Read-only` | `Long` | Number of rows in the table. This includes invisible rows. For  the number of visible rows the property VisibleRowCount is  available. |
| **`Rows`** | `Read-only` | `GuiCollection` | The members of this collection are of GuiTableRow type.  Indexing starts with 0 for the first visible row, independent of  the current position of the horizontal scrollbar. After scroll­ ing, a different row will have the index 0. |
| **`RowSelectMode`** | `Read-only` | `Public Property RowSelectMode As` | GuiTableSelectionType There are three different modes for selecting columns or  rows, which are defined in the enumeration type GuiTableSe­ lectionType. |
| **`TableFieldName`** | `Read-only` | `Public Property TableFieldName As` | String The name property of the table control contains the ABAP  program name in addition to the plain field name. This prop­ erty contains just the field name. |
| **`VerticalScrollbar`** | `Read-only` | `Public Property VerticalScrollbar As` | GuiScrollbar The vertical scrollbar of the table control. |
| **`VisibleRowCount`** | `Read-only` | `Public Property VisibleRowCount As` | Long Number of visible rows in the table. For the number of all  rows the property RowCount is available. |

---

## ⚙️ Methods

### `ConfigureLayout`

```vb
Public Sub ConfigureLayout()
```

In the configuration dialog the layout of the table can be  changed. This dialog is a GuiModalWindow.

### `DeselectAllColumns`

```vb
Public Sub DeselectAllColumns()
```

This function can be used for table controls with a button  that allows, to deselect all columns in one step.

### `GetAbsoluteRow`

```vb
Public Function GetAbsoluteRow( _    ByVal Index As Long _ ) As GuiTableRow
```

Unlike the rows collection, the indexing supported by this  function does not reset the index after scrolling, but counts  the rows starting with the first row with respect to the first  scroll position. If the selected row is not currently visible  then an exception is raised.

### `GetCell`

```vb
Public Function GetCell( _    ByVal Row As Long, _
```

ByVal Column As Long _ ) As GuiVComponent This method returns a given table cell. It is more efficient  than accessing a single cell using the rows or columns col­ lections. Syntax Row: Zero-based index of the row. Column: Zero-based index of the column.

### `ReorderTable`

```vb
Public Sub ReorderTable( _     ByVal Permutation As String _  )
```

The parameter permutation describes a new ordering of the  columns. For example “0 2 1” will move the third column to  second position.  Note • Columns start at index 0 • Fixed columns cannot be reordered

### `SelectAllColumns`

```vb
Public Sub SelectAllColumns()
```

This function can be used for table controls with a button  that allows, to select all columns in one step.

