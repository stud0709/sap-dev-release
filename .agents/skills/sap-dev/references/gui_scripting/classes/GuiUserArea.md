# GuiUserArea

> **Type**: `Class` | **Section**: `1.2.70`
> **Inherits from**: [`GuiVContainer`](GuiVContainer.md)

---

## 📖 Description

The GuiUserArea comprises the area between the toolbar and status bar for windows of GuiMainWindow type  and the area between the titlebar and toolbar for modal windows, and may also be limited by docker controls.  The standard dynpro elements can be found only in this area, with the exception of buttons, which are also  found in the toolbars. GuiUserArea extends the GuiVContainer Object [page 286]. The type prefix and name are usr.

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
* `The following properties of the GuiVComponent Object [page 281] (some properties like the Accessibility properties are not`
* `supported, because they are not needed):`
* `Changeable`
* `DefaultT ooltip`
* `Height`
* `IconName`
* `Left`
* `Modified`
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
| **`HorizontalScrollbar`** | `Read-only` | `Public Property HorizontalScrollbar` | As GuiScrollbar The user area is defined to be scrollable even if the scrollbars  are not always visible. |
| **`IsOTFPreview`** | `Read-only` | `Byte` | This property is TRUE, if a SAPScript Preview Control is dis­ played on the user area. |
| **`VerticalScrollbar`** | `Read-only` | `Public Property VerticalScrollbar As` | GuiScrollbar The user area is defined to be scrollable even if the scrollbars  are not always visible. .2.71  GuiUtils Object |

---

## ⚙️ Methods

### `FindByLabel`

```vb
Public Function FindByLabel( _    ByVal Text As String, _
```

ByVal Type As String _ ) As GuiComponent A very simple method for finding an object is to search by  specifying the text of the respective label and the type of the  component by type name.

### `ListNavigate`

```vb
Public Sub ListNavigate( _     ByVal NavType As String _
```

)  This method sends a navigation command within ABAP Lists  to the SAP system, if the respective ABAP List and the cur­ rently focused element in the ABAP list support the specified  type of navigation. If the navigation is not supported, no  command is send to the server. Possible values for the parameter NavType which specifies  the type of navigation are (all case-sensitive): TAB, TAB_BACK, JUMP_OVER, JUMP_OVER_BACK,  JUMP_OUT , JUMP_OUT_BACK, JUMP_SECTION,  JUMP_SECTION_BACK Y ou find information on the navigation within ABAP Lists here.

