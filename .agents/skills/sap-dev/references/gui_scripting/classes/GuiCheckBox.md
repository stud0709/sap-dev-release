# GuiCheckBox

> **Type**: `Class` | **Section**: `1.2.9`
> **Inherits from**: [`GuiVComponent`](GuiVComponent.md) | **ID Prefix**: `chk`

---

## 📖 Description

GuiCheckBox extends the GuiVComponent Object [page 281]. The type prefix is chk, the name is the fieldname  taken from the SAP data dictionary.

---

## 🧬 Inherited Members

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
| **`ColorIndex`** | `Read-only` | `Long` | This number defines the index of the list color of this ele­ ment. |
| **`ColorIntensified`** | `Read-only` | `Public Property ColorIntensified As` | Byte This property is T rue if the Intensified flag is set in Screen  Painter for this dynpro element. |
| **`ColorInverse`** | `Read-only` | `Byte` | This property is T rue if the inverse color style is set in Screen  Painter for the element. |
| **`Flushing`** | `Read-only` | `Byte` | Some components such as radio buttons or checkboxes  may cause a round trip when their value is changed. If this is  the case, the Flushing property is T rue. |
| **`IsLeftLabel`** | `Read-only` | `Byte` | This property is T rue if the component has the 'assign left'  flag. |
| **`IsListElement`** | `Read-only` | `Byte` | This property is T rue if the element is on an ABAP list, not a  dynpro screen. |
| **`IsRightLabel`** | `Read-only` | `Byte` | This property is T rue if the component has the 'assign right'  flag. |
| **`LeftLabel`** | `Read-only` | `Public Property LeftLabel As` | GuiVComponent Left label of the component. The label is assigned in the  Screen Painter, using the flag 'assign left'. |
| **`RightLabel`** | `Read-only` | `Public Property RightLabel As` | GuiVComponent Right label of the component. This property is set in Screen  Painter using the 'assign right' flag. |
| **`RowText`** | `Read-only` | `String` | This property is only available in ABAP list screens. It returns  the text of the while line containing the current component.  Note This property can only provide useful data when Acces­ sibility mode is activated and the respective ABAP list  has been properly enabled for accessibility. In this case  the ABAP list contains substructures of type GuiSimple­ Container which, for example, model the rows of the list. |
| **`Selected`** | `Read-write` | `Byte` | Like radio buttons, checking a checkbox can cause server  communication, depending on the ABAP Screen Painter def­ inition. |

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

This method returns information that is compiled on the  server to enhance the ABAP lists with accessibility informa­ tion. See GuiLabel Object [page 140] -> GetListProperty  for a description of available attributes. In contrast to the  method GetListProperty, GetListPropertyNonRec will only  return information that is set for the specific element and  ignore list properties set for parent elements.For more infor­ mation, refer to the documentation about method GetList­ PropertyNonRec within GuiLabel Object [page 140].

