# GuiSimpleContainer

> **Type**: `Class` | **Section**: `1.2.52`
> **Inherits from**: [`GuiVContainer`](GuiVContainer.md) | **ID Prefix**: `sub`

---

## 📖 Description

This container represents non-scrollable subscreens. It does not have any functionality apart from to the  inherited interfaces. GuiSimpleContainer extends the GuiVContainer Object [page 286]. The type prefix is sub,  the name is is generated from the data dictionary settings.

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
| **`IsListElement`** | `Read-only` | `Byte` | This property is T rue if the element is on an ABAP list, not a  dynpro screen. |
| **`IsStepLoop`** | `Read-only` | `Byte` | This property is T rue if the container is a step loop container. |
| **`LoopColCount`** | `Read-only` | `Long` | If the container is a step loop container, then this property  contains the number of columns in the step loop. |
| **`LoopCurrentCol`** | `Read-only` | `Long` | If the container is a step loop container, then this property  contains the current row number in the step loop. |
| **`LoopCurrentColCount`** | `Read-only` | `Public Property LoopCurrentColCount` | As Long If the container is a step loop container, then this property  contains the number of columns in the current row of the  step loop. Please note that depending on the type of steploop the num­ ber of columns per row may be different per row.  Note This property is available as of SAP GUI for Windows  7 .50 patchlevel 9 and SAP GUI for Windows 7 .60. |
| **`LoopCurrentRow`** | `Read-only` | `Long` | If the container is a step loop container, then this property  contains the current column number in the step loop. |
| **`LoopRowCount`** | `Read-only` | `Long` | If the container is a step loop container, then this property  contains the number of rows in the step loop. |

---

## ⚙️ Methods

### `GetListProperty`

```vb
Public Function GetListProperty( _    ByVal Property As String _ ) As String
```

For more information refer to the documentation about  method GetListProperty within GuiLabel Object [page  140].

### `GetListPropertyNonRec`

```vb
Public Function 
GetListPropertyNonRec( _    ByVal Property As String _ ) As String
```

For more information, refer to the documentation about  method GetListPropertyNonRec within GuiLabel Object  [page 140].

