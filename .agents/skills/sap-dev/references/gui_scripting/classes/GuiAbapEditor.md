# GuiAbapEditor

> **Type**: `Class` | **Section**: `1.2.1`
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
* `All properties of the GuiContainer Object [page 87]:`
* `Children`
* `All properties of the GuiShell Object [page 207]:`
* `AccDescription`
* `DragDropSupported`
* `Handle`
* `OcxEvents`
* `SubType`

---

## ⚙️ Methods

### `AutoBraceEnabled`

```vb
Public Function AutoBraceEnabled() As
```

Byte Returns T rue if the auto brace facility is currently switched  on.

### `AutoComplete`

```vb
Public Sub AutoComplete()
```

Invokes the auto complete list box.

### `AutoCorrectEnabled`

```vb
Public Function AutoCorrectEnabled()
```

As Byte Returns T rue if the auto correct facility is currently switched  on.

### `AutoExpand`

```vb
Public Sub AutoExpand()
```

Invokes the auto expand code template mechanism.

### `AutoIndentEnabled`

```vb
Public Function AutoIndentEnabled()
```

As Byte Returns T rue if the auto indent facility is currently switched  on.

### `Capitalize`

```vb
Public Sub Capitalize()
```

Makes the first alphabetic character of each word in the  selected text uppercase. All other characters are made lower  case.

### `ClipboardCopy`

```vb
Public Sub ClipboardCopy()
```

Performs a clipboard copy operation on the currently se­ lected text.

### `ClipboardCut`

```vb
Public Sub ClipboardCut()
```

Performs a clipboard cut operation on the currently selected  text.

### `ClipboardPaste`

```vb
Public Sub ClipboardPaste()
```

Pastes the current contents of the clipboard beginning from  the current cursor position.

### `ClipboardRingPaste`

```vb
Public Sub ClipboardRingPaste( _  ByVal Index As Long _  )
```

Pastes an entry from the editor's clipboard ring to the editor.  Index : One-based index of the clipboard entry as it appears  in the ABAP editor context menu.

### `CodeHintsEnabled`

```vb
Public Function CodeHintsEnabled() As
```

Byte Returns T rue if code hints are currently enabled.

### `CommentSelectedLines`

```vb
Public Sub CommentSelectedLines()
```

Encloses the selected lines in comments.

### `CorrectCapsEnabled`

```vb
Public Function CorrectCapsEnabled()
```

As Byte Returns T rue if the correct caps function is currently  switched on.

### `Delete`

```vb
Public Sub Delete()
```

Deletes the character, which proceeds the current cursor  position. Equivalent to pressing the <DEL> key.

### `DeleteBack`

```vb
Public Sub DeleteBack()
```

Moves the cursor to the previous column, deleting the char­ acter currently residing there. Equivalent to pressing the  backspace key.

### `DeleteRange`

```vb
Public Sub DeleteRange( _     ByVal LineStart As Long, _
```

ByVal ColumnStart As Long, _    ByVal LineEnd As Long, _    ByVal ColumnEnd As Long _  ) Defines a region of text for deletion. • LineStart specifies the line number from where deletion  is to begin. • ColumnStart (p2) specifies the number of the column  from where deletion is to begin. • LineEnd (p3) specifies the number of the line where  deletion will end. • ColumnEnd (p4) specifies the number of the column  where deletion will end.

### `DeleteSelection`

```vb
Public Sub DeleteSelection()
```

Deletes the currently selected text.

### `DeleteWord`

```vb
Public Sub DeleteWord()
```

Deletes the word, which proceeds the current character po­ sition.

### `DeleteWordBack`

```vb
Public Sub DeleteWordBack()
```

Deletes the word, which precedes the current cursor posi­ tion.

### `DuplicateLine`

```vb
Public Sub DuplicateLine()
```

T akes the contents of the line upon which the cursor cur­ rently resides and inserts a copy of the line contents on the  line below the cursor.

### `FormatSelectedLines`

```vb
Public Sub FormatSelectedLines()
```

Formats the selected lines according to "Pretty Printer" and  "Formatting" settings e.g. Auto Indent, Smart Tab.

### `GetAutoCompleteEntryCount`

```vb
Public Function 
GetAutoCompleteEntryCount() As Long
```

Returns the number of available entries displayed in the auto  completion list box.

### `GetAutoCompleteEntryText`

```vb
Public Function 
GetAutoCompleteEntryText( _    ByVal Index As Long _ ) As String
```

Returns a string representing the auto completion list box  entry corresponding to the index supplied as a parameter.

### `GetAutoCompleteIconType`

```vb
Public Function 
GetAutoCompleteIconType( _    ByVal Index As Long _ ) As String
```

Returns the index of the image associated with the auto  complete entry specified in Index. Returns -1 if no image is  associated.

### `GetAutoCompleteSubIconType`

```vb
Public Function 
GetAutoCompleteSubIconType( _    ByVal Index As Long _ ) As String
```

Returns the index of the sub image associated with the auto  complete entry specified in Index. Returns -1 if no sub image  is associated.

### `GetAutoCompleteToolbarButtonToolTip`

```vb
Public Function 
GetAutoCompleteToolbarButtonToolTip( _    ByVal Index As Long _ ) As String
```

Returns the tooltip text, which is displayed by the autocom­ plete toolbar button specified in Index.

### `GetAutoCompleteToolTipDelay`

```vb
Public Function 
GetAutoCompleteToolTipDelay() As Long
```

Returns the number of milliseconds, which elapse between  highlighting an entry in the autocomplete listbox and the  appearance of the corresponding tooltip window.

### `GetCurrentToolTipText`

```vb
Public Function 
GetCurrentToolTipText() As String
```

Retrieves the text in the currently displayed code hint or  autocomplete listbox tooltip window. Multiple lines are sepa­ rated with \n characters.

### `GetCursorColumnPosition`

```vb
Public Function 
GetCursorColumnPosition() As Long
```

Returns the column number in which the cursor currently  resides.

### `GetCursorLinePosition`

```vb
Public Function 
GetCursorLinePosition() As Long
```

Returns the number of the line upon which the cursor cur­ rently resides.

### `GetFirstVisibleLine`

```vb
Public Function GetFirstVisibleLine()
```

As Long Returns the line number of the top-most visible line in the  current editor session.

### `GetHTMLClipboardContents`

```vb
Public Function 
GetHTMLClipboardContents() As String
```

Returns a string containing the current contents of the clip­ board in HTML format. Returns an empty string if the clip­ board does not contain anything in HTML format.

### `GetLastVisibleLine`

```vb
Public Function GetLastVisibleLine()
```

As Long Returns the line number of the bottom-most visible line in  the current editor session.

### `GetLineCount`

```vb
Public Function GetLineCount() As Long
```

Returns the total number of lines contained in the document  in the current session.

### `GetLineText`

```vb
Public Function GetLineText( _    ByVal Line As Long _ ) As String
```

Returns a string containing the contents of the line number  specified as a parameter.

### `GetNumberedBookmarks`

```vb
Public Function 
GetNumberedBookmarks( _    ByVal Line As Long _ ) As Object
```

Returns a collection of bookmark numbers assigned to the  line number passed as a parameter. The number of the  bookmark can range from 0 to 9. If no numbered bookmark  is assigned then the collection is empty.

### `GetRTFClipboardContents`

```vb
Public Function 
GetRTFClipboardContents() As String
```

Returns a string containing the current contents of the clip­ board in Rich Text format. Returns an empty string if the  clipboard does not contain anything in Rich Text format.

### `GetSelectedAutoComplete`

```vb
Public Function 
GetSelectedAutoComplete() As Long
```

Returns the zero based index of the currently selected entry  in the auto completion list box. The method will return -1 if no  entry is selected.

### `GetSelectedText`

```vb
Public Function GetSelectedText() As
```

String Returns a string containing the text currently highlighted  or selected in the editor session. If the selected text spans  more than one line then any line terminator characters will  be included in the string returned by this method.

### `GetStructureBlockEndLine`

```vb
Public Function 
GetStructureBlockEndLine( _    ByVal Line As Long _ ) As Long
```

Returns the end line of the structure block relevant to the  line number passed to the method. If the line does not reside  within a structure block at all then the method returns -1.

### `GetStructureBlockStartLine`

```vb
Public Function 
GetStructureBlockStartLine( _    ByVal Line As Long _ ) As Long
```

Returns the start line of the structure block relevant to the  line number passed to the method. If the line resides within a  nested block then the start line of the innermost block will be  returned. If the line does not reside within a structure block  at all then the method returns -1.

### `GetUndoPosition`

```vb
Public Function GetUndoPosition() As
```

Long Returns the current position of the document in the undo/ redo buffer.

### `GetWordWrapMode`

```vb
Public Function GetWordWrapMode() As
```

Long Returns an integer corresponding to the currently set Word  wrap mode: • 0 - Word wrap disabled. • 1 - Wrap at edge of window. • 2 - Wrap by page width. • 3 - Wrap by page width inserting hard break.

### `GetWordWrapPosition`

```vb
Public Function GetWordWrapPosition()
```

As Long Returns the current page width assigned to word wrap. The  number returned is the number of columns after which word  wrap will be applied.

### `GoNextBookMark`

```vb
Public Sub GoNextBookMark()
```

Navigates to the line where the next none numbered book­ mark is set.

### `GoNumberedBookmark`

```vb
Public Sub GoNumberedBookmark( _     ByVal Mark As Long _  )
```

Navigates to the line where the bookmark numbered Mark  resides.

### `GoPreviousBookMark`

```vb
Public Sub GoPreviousBookMark()
```

Navigates to the line where the previous none numbered  bookmark is set.

### `InsertTab`

```vb
Public Sub InsertTab()
```

Inserts a TAB at the current cursor position. Equivalent to  pressing the TAB key.

### `InsertText`

```vb
Public Sub InsertText( _     ByVal Text As String, _
```

ByVal Line As Long, _     ByVal Column As Long _  ) Places the text specified in Text at the position specified in  Line and Column as if the text had been typed into the editor  from the keyboard.

### `IsAutoCompleteEntryBold`

```vb
Public Function 
IsAutoCompleteEntryBold( _    ByVal Index As Long _ ) As Byte
```

Returns T rue if the auto complete entry specified in Index is  bold.

### `IsAutoCompleteOpen`

```vb
Public Function IsAutoCompleteOpen()
```

As Byte Returns T rue if the auto completion list box is currently open.

### `IsAutoCompleteToolbarButtonPressed`

```vb
Public Function 
IsAutoCompleteToolbarButtonPressed( _    ByVal Index As Long _ ) As Byte
```

Returns T rue if the autocomplete toolbar button specified in  Index is currently pressed. Otherwise False is returned.

### `IsAutoCompleteToolTipVisible`

```vb
Public Function 
IsAutoCompleteToolTipVisible() As Byte
```

Returns T rue if the tooltip corresponding to an entry in the  auto complete listbox is currently visible.

### `IsBookmark`

```vb
Public Function IsBookmark( _    ByVal Line As Long _ ) As Byte
```

Returns T rue if the line is bookmarked with a standard book­ mark which is not numbered. The method does not provide  information about whether the line is marked using a num­ bered bookmark.

### `IsBreakpointSet`

```vb
Public Function IsBreakpointSet( _    ByVal Line As Long _ ) As Byte
```

Returns T rue if a breakpoint is set on the line number passed  in as a parameter.

### `IsLineCollapsed`

```vb
Public Function IsLineCollapsed( _    ByVal Line As Long _ ) As Byte
```

Returns T rue if the line number passed to it corresponds to  a line, which signifies the beginning of a collapsible block,  which is currently in the collapsed state.

### `IsLineComment`

```vb
Public Function IsLineComment( _    ByVal Line As Long _ ) As Byte
```

Returns T rue if the line number specified in Line contains  comments. Otherwise False is returned.

### `IsLineModified`

```vb
Public Function IsLineModified( _    ByVal Line As Long _ ) As Byte
```

Returns T rue if the line has been modified during the course  of the current editor session.

### `IsModified`

```vb
Public Function IsModified() As Byte
```

Returns T rue if any part of the current document has been  modified during \ the course of the current editor session.

### `JoinSelectedLines`

```vb
Public Sub JoinSelectedLines()
```

Merges currently selected lines of text into a single line of  text.

### `LowerCase`

```vb
Public Sub LowerCase()
```

Forces selected text into lower case.

### `MoveCursorDocumentEnd`

```vb
Public Sub MoveCursorDocumentEnd()
```

Positions the cursor in the last column of the very last line of  the document.

### `MoveCursorLineDown`

```vb
Public Sub MoveCursorLineDown()
```

Moves the cursor down one line from its current position.

### `MoveCursorLineEnd`

```vb
Public Sub MoveCursorLineEnd()
```

Positions the cursor in the last column of the current line.

### `MoveCursorLineHome`

```vb
Public Sub MoveCursorLineHome()
```

Positions the cursor in the first column of the current line.

### `MoveCursorLineUp`

```vb
Public Sub MoveCursorLineUp()
```

Moves the cursor up one line from its current position.

### `MoveLineDown`

```vb
Public Sub MoveLineDown()
```

Moves the contents of the line where the cursor resides to  the line below and moves the contents of the line below the  cursor up one line.

### `MoveLineUp`

```vb
Public Sub MoveLineUp()
```

Moves the contents of the line where the cursor resides to  the line above and moves the contents of the line above the  cursor down one line.

### `MoveWordLeft`

```vb
Public Sub MoveWordLeft()
```

Moves the cursor to the column preceding the next word  found to the left of the cursor's current position.

### `MoveWordRight`

```vb
Public Sub MoveWordRight()
```

Moves the cursor to the column preceding the next word  found to the right of the cursor's current position.

### `OverwriteModeEnabled`

```vb
Public Function 
OverwriteModeEnabled() As Byte
```

Returns T rue if Overwrite mode is enabled, False if in Insert  mode.

### `RemoveAllBookmarks`

```vb
Public Sub RemoveAllBookmarks()
```

Removes all types of bookmarks from the document. Both  numbered and none numbered bookmarks are removed.

### `RemoveAllBreakpoints`

```vb
Public Sub RemoveAllBreakpoints()
```

Removes all breakpoints from the current document.

### `RemoveBookmarks`

```vb
Public Sub RemoveBookmarks( _     ByVal Bookmarks As String _ )
```

Removes all bookmarks specified in the supplied string.

### `RemoveBreakpoint`

```vb
Public Sub RemoveBreakpoint( _     ByVal Line As Long _ )
```

Removes the breakpoint on line number Line.

### `ReplaceSelection`

```vb
Public Sub ReplaceSelection( _     ByVal Text As String _ )
```

Replaces the currently selected text with the text contained  in the Text parameter.

### `SaveToFile`

```vb
Public Sub SaveToFile( _     ByVal p1 As String _ )
```

ScrollToLine Public Sub ScrollToLine( _     ByVal Line As Long _ ) Scrolls to the line number specified in Line if not already  visible on the screen.

### `SelectAll`

```vb
Public Sub SelectAll()
```

Highlights all text in the current document for selection.

### `SelectBlockRange`

```vb
Public Sub SelectBlockRange( _     ByVal LineStart As Long, _
```

ByVal ColumnStart As Long, _     ByVal LineEnd As Long, _     ByVal ColumnEnd As     Long _  ) Highlights a region of text in block mode for selection. Equiv­ alent to holding down the ALT key while dragging the mouse  over the text. • LineStart specifies the line number from where selec­ tion is to begin. • ColumnStart specifies the number of the column from  where selection is to begin. • LineEnd specifies the number of the line where selec­ tion will end. • ColumnEnd specifies the number of the column where  selection will end.

### `SelectRange`

```vb
Public Sub SelectRange( _     ByVal LineStart As Long, _
```

ByVal ColumnStart As Long, _     ByVal LineEnd As Long, _     ByVal ColumnEnd As     Long _  ) Highlights a region of text for selection. • LineStart specifies the line number from where selec­ tion is to begin. • ColumnStart specifies the number of the column from  where selection is to begin. • LineEnd specifies the number of the line where selec­ tion will end. • ColumnEnd specifies the number of the column where  selection will end.

### `SelectWordLeft`

```vb
Public Sub SelectWordLeft()
```

Selects the word to the left of the current cursor position.

### `SelectWordRight`

```vb
Public Sub SelectWordRight()
```

Selects the word to the right of the current cursor position.

### `Sentencize`

```vb
Public Sub Sentencize()
```

Makes the first character of each sentence upper case. Sen­ tences are delimited by "." characters. All other characters  are made lower case.

### `SetAutoBrace`

```vb
Public Sub SetAutoBrace( _     ByVal Status As Byte _ )
```

Switches the auto brace facility on or off.

### `SetAutoCorrect`

```vb
Public Sub SetAutoCorrect( _     ByVal Status As Byte _ )
```

Switches the auto complete facility on or off.

### `SetAutoIndent`

```vb
Public Sub SetAutoIndent( _     ByVal Status As Byte _  )
```

Switches the auto indent facility on or off.

### `SetBookmarks`

```vb
Public Sub SetBookmarks( _     ByVal Bookmarks As String _  )
```

Set bookmarks. T akes a string of the following format: <line>[(<no>)][,<line>] e.g. "10(1),22(2),33,42",  <line>={1,...,n}, <no>={1,...

### `SetBreakpoint`

```vb
Public Sub SetBreakpoint( _     ByVal Line As Long _  )
```

Sets a breakpoint on line number Line.

### `SetCodeHints`

```vb
Public Sub SetCodeHints( _      ByVal Status As Byte _ )
```

Switches code hints on or off.

### `SetCorrectCaps`

```vb
Public Sub SetCorrectCaps( _     ByVal Status As Byte _  )
```

Switches the caps correction feature on or off.

### `SetLineFeedStyle`

```vb
Public Sub SetLineFeedStyle( _     ByVal p1 As Long _  )
```

SetOverwriteMode Public Sub SetOverwriteMode( _     ByVal Status As Byte _  ) Switches between Insert and Overwrite modes. If called with  T rue then Overwrite mode is enabled. Otherwise the editor is  in Insert mode.

### `SetSelectionPosInLine`

```vb
Public Sub SetSelectionPosInLine( _     ByVal Line As Long, _
```

ByVal Column As     Long _  ) Places the cursor on line <Line> and column <Column>.

### `SetSmartTab`

```vb
Public Sub SetSmartTab( _     ByVal Status As Byte _  )
```

Switches the smart tab facility on or off.

### `SetWordWrapMode`

```vb
Public Sub SetWordWrapMode( _     ByVal Mode As Long _  )
```

Sets the word wrap mode according to the number supplied  in Mode: • 0 - Word wrap disabled. • 1 - Wrap at edge of window. • 2 - Wrap by page width. • 3 - Wrap by page width inserting hard break.

### `SetWordWrapPosition`

```vb
Public Sub SetWordWrapPosition( _     ByVal Pos As Long _  )
```

Pos specifies the number of columns to be displayed before  word wrap is applied.

### `SmartTabEnabled`

```vb
Public Function SmartTabEnabled() As
```

Byte Switches the smart tab facility on or off.

### `SortSelectedLines`

```vb
Public Sub SortSelectedLines()
```

Rearranges the selected lines in alphanumeric order.

### `SwapCase`

```vb
Public Sub SwapCase()
```

Inverts the case setting for the selected text. Upper case  characters are switched to lower case and vice versa.

### `ToggleCapsLock`

```vb
Public Sub ToggleCapsLock()
```

Switches caps lock on or off.

### `ToggleNumberedBookmark`

```vb
Public Sub ToggleNumberedBookmark( _     ByVal Mark As Long, _
```

ByVal Line As     Long _  ) T oggles the state of the numbered bookmark Mark on line  Line. If a book mark with the number Mark already exists on  Line then it will be removed. Otherwise it will be added.

### `ToggleStructureBlock`

```vb
Public Sub ToggleStructureBlock( _     ByVal Line As Long _  )
```

If the line number specified in Line is the first line of a  collapsible block of code then this method will toggle the  expanded/collapsed status of the block.

### `TransposeLine`

```vb
Public Sub TransposeLine()
```

Swaps the contents of the line where the cursor currently  resides with the contents of the line above the current cursor  position.

### `UncommentSelectedLines`

```vb
Public Sub UncommentSelectedLines()
```

Removes comments from the selected lines.

### `Undo`

```vb
Public Sub Undo( _     ByVal UndoPosition As Long _  )
```

Performs either an undo or a redo depending on UndoPo­ sition. UndoPosition specifies a zero based position in the  undo/redo buffer. If -1 is passed then a single step undo is  preformed.

### `UnTab`

```vb
Public Sub UnTab()
```

Removes a TAB at the current cursor position. Equivalent to  pressing <SHIFT> + <TAB>.

### `UpperCase`

```vb
Public Sub UpperCase()
```

Forces selected text into upper case.

