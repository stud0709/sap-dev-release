# GuiTextedit

> **Type**: `Class` | **Section**: `1.2.64`
> **Inherits from**: [`GuiShell`](GuiShell.md)

---

## 📖 Description

The TextEdit control is a multiline edit control offering a number of possible benefits. With regard to scripting,  the possibility of protecting text parts against editing by the user is especially useful. GuiTextedit extends the  GuiShell Object [page 207].

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
* `All properties of the GuiShell Object [page 207]:`
* `AccDescription`
* `DragDropSupported`
* `Handle`
* `OcxEvents`
* `SubType`

---

## 📋 Properties

| Property | Access | Signature / Type | Description |
|:---|:---|:---|:---|
| **`CurrentColumn`** | `Read-only` | `Long` | The number of the column in which the text caret is cur­ rently positioned. |
| **`CurrentLine`** | `Read-only` | `Long` | The number of the line in which the text caret is currently  positioned. |
| **`FirstVisibleLine`** | `Read-write` | `Public Property FirstVisibleLine As` | Long The first visible line is visualized at the top border of the  control. |
| **`LastVisibleLine`** | `Read-only` | `Public Property LastVisibleLine As` | Long The number of the last line that is currently visible. |
| **`LineCount`** | `Read-only` | `Long` | The number of all lines in the current document. |
| **`NumberOfUnprotectedTextParts`** | `Read-only` | `Long` | The number of unprotected text parts, which are contained. |
| **`SelectedText`** | `Read-only` | `String` | The currently selected text. |
| **`SelectionEndColumn`** | `Read-only` | `Public Property SelectionEndColumn As` | Long The number of the column in which the current selection  ends. |
| **`SelectionEndLine`** | `Read-only` | `Public Property SelectionEndLine As` | Long The number of the line in which the current selection ends. |
| **`SelectionIndexEnd`** | `Read-only` | `Public Property SelectionIndexEnd As` | Long Retrieves the absolute, zero based character index of the  ending point from the visually selected text range, i.e. the  position where the selection ends. Note that a selection can  be degenerated, i.e. selectionIndexStart is equal to selectio­ nIndexEnd. |
| **`SelectionIndexStart`** | `Read-only` | `Public Property SelectionIndexStart` | As Long Retrieves the absolute, zero based character index of the  starting point from the visually selected text range, i.e. the  position, where the selection begins. Note that a selection  can be degenerated, i.e. selectionIndexStart is equal to se­ lectionIndexEnd. |
| **`SelectionStartColumn`** | `Read-only` | `Public Property SelectionStartColumn` | As Long The number of the column in which the current selection  starts. |
| **`SelectionStartLine`** | `Read-only` | `Public Property SelectionStartLine As` | Long The number of the line in which the current selection starts. |

---

## ⚙️ Methods

### `ContextMenu`

```vb
Public Sub ContextMenu()
```

Calling ContextMenu emulates the context menu request.

### `DoubleClick`

```vb
Public Sub DoubleClick()
```

This function emulates a mouse double-click. For setting the  selection, the function setSelectionIndexes can be called in  advance.

### `GetLineText`

```vb
Public Function GetLineText( _    ByVal nLine As Long _ ) As String
```

Returns the text of the specified line.

### `GetUnprotectedTextPart`

```vb
Public Function 
GetUnprotectedTextPart( _    ByVal Part As Long _ ) As String
```

This function retrieves the content of an unprotected text  part using the zero based index part.

### `IsBreakpointLine`

```vb
Public Function IsBreakpointLine( _    ByVal nLine As Long _ ) As Byte
```

Returns TRUE if the specified line contains a breakpoint.

### `IsCommentLine`

```vb
Public Function IsCommentLine( _    ByVal nLine As Long _ ) As Byte
```

Returns TRUE if the specified line is a comment line.

### `IsHighlightedLine`

```vb
Public Function IsHighlightedLine( _    ByVal nLine As Long _ ) As Byte
```

Returns TRUE if the specified line is highlighted.

### `IsProtectedLine`

```vb
Public Function IsProtectedLine( _    ByVal nLine As Long _ ) As Byte
```

Returns TRUE if the specified line is protected.

### `IsSelectedLine`

```vb
Public Function IsSelectedLine( _    ByVal nLine As Long _ ) As Byte
```

Returns TRUE if the specified line is selected.

### `ModifiedStatusChanged`

```vb
Public Sub ModifiedStatusChanged( _     ByVal Status As Boolean _  )
```

This function emulates the change of the modified status.

### `MultipleFilesDropped`

```vb
Public Sub MultipleFilesDropped()
```

Emulate a Drag&Drop operation, in which several files are  dropped on the textedit control. The collection contains for  each file the fully qualified file name as a string.

### `PressF1`

```vb
Public Sub PressF1()
```

This function emulates pressing the F1 key on the keyboard.

### `PressF4`

```vb
Public Sub PressF4()
```

This function emulates pressing the F4 key on the keyboard.

### `SetSelectionIndexes`

```vb
Public Sub SetSelectionIndexes( _     ByVal Start As Long, _
```

ByVal End As     Long _  ) This function sets the visually selected text range. start and  end are absolute, zero based character indexes. start corre­ sponds to the position where the selection begins and end  is the position of the first character following the selection.  Note that setting start equal to end results in setting the  cursor on this position.

### `SetUnprotectedTextPart`

```vb
Public Function 
SetUnprotectedTextPart( _    ByVal Part As Long, _
```

ByVal Text As String _ ) As Byte This function assigns the content of text to the unprotected  text part with zero based index part. The function returns  T rue if it was possible to perform the assignment. Otherwise,  False is returned.

### `SingleFileDropped`

```vb
Public Sub SingleFileDropped( _     ByVal Filename As String _  )
```

This function emulates the drop of a single file with the di­ rectory path fileName.

