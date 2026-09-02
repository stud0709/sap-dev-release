# GuiSplit

> **Type**: `Class` | **Section**: `1.2.53`
> **Inherits from**: [`GuiShell`](GuiShell.md)

---

## 📖 Description

GuiSplit extends the GuiShell Object [page 207].

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

---

## 📋 Properties

| Property | Access | Signature / Type | Description |
|:---|:---|:---|:---|
| **`FocusedHorizontalSash`** | `Read-only` | `Public Property FocusedHorizontalSash` | As Long This property contains the index (starting with 1) of the fo­ cused horizontal sash belonging to the splitter. If the splitter  container has just one row or no horizontal sash has focus,  this property contains “-1” . |
| **`FocusedVerticalSash`** | `Read-only` | `Public Property FocusedVerticalSash` | As Long This property contains the index (starting with 1) of the fo­ cused vertical sash belonging to the splitter. If the splitter  container has just one column or no vertical sash has focus,  this property contains “-1” . |
| **`IsVertical`** | `Read-only` | `Long` | This property contains: • 0 if the splitter cells of the GuiSplit are horizontally  aligned • 1 if the splitter cells of the GuiSplit are vertically aligned • 2 if the splitter cells of the GuiSplit are both horizontally  and vertically aligned |

---

## ⚙️ Methods

### `GetColSize`

```vb
Public Function GetColSize( _    ByVal Id As Long _ ) As Long
```

This method returns the size of the splitter column specified  by the parameter Id (starting with index 1) in percent.

### `GetRowSize`

```vb
Public Function GetRowSize( _    ByVal Id As Long _ ) As Long
```

This method returns the size of the splitter row specified by  the parameter Id (starting with index 1) in percent. Method Description

### `SetColSize`

```vb
Public Sub SetColSize( _     ByVal Id As Long, _
```

ByVal Size     As Long _  ) This method sets the size of the splitter column specified by  the parameter Id (starting with index 1) to the percentage  specified by parameter Size.  Note The splitter columns need to be set in sequence if multi­ ple columns are used. This means you first set the size  of the first column, then of the second column and so  forth until all columns have the desired size. Incorrectly  assigning sizes may lead to overall sizes of more than  100%. Therefore, the user of this method needs to make  sure not to exceed 100% percent adding the size of all  columns.

### `SetRowSize`

```vb
Public Sub SetRowSize( _     ByVal Id As Long, _
```

ByVal Size     As Long _  ) This method sets the size of the splitter row specified by  the parameter Id (starting with index 1) to the percentage  specified by parameter Size.  Note The splitter rows need to be set in sequence if multiple  columns are used. This means you first set the size of  the first row, then of the second row and so forth until  all rows have the desired size. Incorrectly assigning sizes  may lead to overall sizes of more than 100%. Therefore,  the user of this method needs to make sure not to ex­ ceed 100% percent adding the size of all rows.

