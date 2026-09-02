# GuiToolbarControl

> **Type**: `Class` | **Section**: `1.2.68`
> **Inherits from**: [`GuiShell`](GuiShell.md)

---

## 📖 Description

Methods

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

## ⚙️ Methods

### `GetButtonChecked`

```vb
Public Function GetButtonChecked( _    ByVal ButtonPos As Long _ ) As Byte
```

Returns if the button is currently checked (pressed).

### `GetButtonEnabled`

```vb
Public Function GetButtonEnabled( _    ByVal ButtonPos As Long _ ) As Byte
```

Indicates if the button can be pressed.

### `GetButtonIcon`

```vb
Public Function GetButtonIcon( _    ByVal ButtonPos As Long _ ) As String
```

Returns the name of the icon of the specified toolbar button.

### `GetButtonId`

```vb
Public Function GetButtonId( _    ByVal ButtonPos As Long _ ) As String
```

Returns the ID of the specified toolbar button.

### `GetButtonText`

```vb
Public Function GetButtonText( _    ByVal ButtonPos As Long _ ) As String
```

Returns the text of the specified toolbar button.

### `GetButtonTooltip`

```vb
Public Function GetButtonTooltip( _    ByVal ButtonPos As Long _ ) As String
```

Returns the tooltip of the specified toolbar button.

### `GetButtonType`

```vb
Public Function GetButtonType( _    ByVal ButtonPos As Long _ ) As String
```

Returns the type of the specified toolbar button. Possi­ ble values are:"Button", "ButtonAndMenu", "Menu", "Sepa­ rator", "Group", "CheckBox"

### `GetMenuItemIdFromPosition`

```vb
Public Function 
GetMenuItemIdFromPosition( _    ByVal Pos As Long _ ) As String
```

This function returns the identifier of the menu item with  index Position.

### `PressButton`

```vb
Public Sub PressButton( _     ByVal Id As String _  )
```

This function emulates pressing the button with the given id.

### `PressContextButton`

```vb
Public Sub PressContextButton( _     ByVal Id As String _  )
```

This function emulates pressing the context button with the  given id.

### `SelectMenuItem`

```vb
Public Sub SelectMenuItem( _     ByVal Id As String _  )
```

This function emulates selecting the menu item with the  given id.

### `SelectMenuItemByText`

```vb
Public Sub SelectMenuItemByText( _     ByVal strText As String _  )
```

This function emulates selecting the menu item by menu  item text.

