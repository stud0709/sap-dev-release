# GuiRadioButton

> **Type**: `Class` | **Section**: `1.2.45`
> **Inherits from**: [`GuiVComponent`](GuiVComponent.md) | **ID Prefix**: `rad`

---

## 📖 Description

GuiRadioButton extends the GuiVComponent Object [page 281]. The type prefix is rad, the name is the  fieldname taken from the SAP data dictionary.

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
| **`CharHeight`** | `Read-only` | `Long` | Height of the GuiRadioButton in character metric. |
| **`CharLeft`** | `Read-only` | `Long` | Left coordinate of the GuiRadioButton in character metric. |
| **`CharTop`** | `Read-only` | `Long` | Top coordinate of the GuiRadioButton in character metric. |
| **`CharWidth`** | `Read-only` | `Long` | Width of the GuiRadioButton in character metric. |
| **`Flushing`** | `Read-only` | `Byte` | Some components such as radio buttons or checkboxes  may cause a round trip when their value is changed. If this is  the case, the Flushing property is T rue. |
| **`GroupCount`** | `Read-only` | `Long` | The number of radio buttons in the same group the current  object belongs to. |
| **`GroupMembers`** | `Read-only` | `Public Property GroupMembers As` | GuiComponentCollection  Example The collection of GuiRadioButton objects belonging to  the same radio button group. Example: Set GroupMembers  = session.findById("wnd[0]/usr/ radRB2").GroupMembers For  Each GroupMember In  GroupMembers      MsgBox GroupMember.Text Next |
| **`GroupPos`** | `Read-only` | `Long` | The position of the radio button in the respective radio but­ ton group (ranging from 1 to GroupCount). |
| **`IsLeftLabel`** | `Read-only` | `Byte` | This property is T rue if the component has the 'assign left'  flag. |
| **`IsRightLabel`** | `Read-only` | `Byte` | This property is T rue if the component has the 'assign right'  flag. LeftLabel Public Property LeftLabel As  GuiVComponent Left label of the GuiRadioButton. The label is assigned in the  Screen Painter, using the flag 'assign left'. RightLabel Public Property RightLabel As  uiVComponent Right label of the GuiRadioButton. This property is set in  Screen Painter using the 'assign right' flag. Selected (read-only) Public Property Selected As Byte This property is T rue if the GuiRadioButton is selected. In a  group of radiobuttons, only a single button can be selected.  This means, when selecting a radiobutton via this property,  the previously selected radiobutton in the same group be­ comes deselected. As an alternative to this property, you can  also use method Select to select a radiobutton. .2.46  GuiSapChart Object Description For the SAP chart control only basic members from GuiShell are available. Recording and playback is not  possible. |

---

## ⚙️ Methods

### `Select`

```vb
Public Sub Select()
```

Selecting a radio button automatically deselects all the other  buttons within that group. This may cause a server round­ trip, depending on the definition of the button in the screen  painter.

