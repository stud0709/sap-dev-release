# GuiTextField

> **Type**: `Class` | **Section**: `1.2.65`
> **Inherits from**: [`GuiVComponent`](GuiVComponent.md) | **ID Prefix**: `txt`

---

## 📖 Description

GuiTextField extends the GuiVComponent Object [page 281]. The type prefix is txt, the name is the fieldname  taken from the SAP data dictionary.

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
* `The following properties of the GuiVComponent Object [page 281] (some properties are not supported, because most of`
* `the properties of GuiTitlebar cannot be influenced by ABAP applications):`
* `DefaultT ooltip`
* `Height`
* `Left`
* `ScreenLeft`
* `ScreenTop`
* `Text`
* `T ooltip`
* `Top`
* `Width`
* `All properties of the GuiContainer Object [page 87]:`
* `Children`
* `.2.67  GuiToolbar Object`
* `Description`
* `Every GuiFrameWindow has a GuiToolbar. The GuiMainWindow has two toolbars unless the second has been`
* `turned off by the ABAP application. In classical SAP GUI themes, the upper toolbar is called “system toolbar”`
* `or “GUI toolbar” , while the second toolbar is called “application toolbar” . In SAP GUI themes as of Belize and`
* `in integration scenarios (like embedded into SAP Business Client), only a single toolbar (“merged toolbar")`
* `is displayed. Additionally, a footer also containing buttons originally coming from the system or application`
* `toolbar may be displayed.`
* `The merged toolbar contains elements from both the system and the application toolbar. However, the`
* `scripting IDs of all objects in the merged toolbar remain the same in order to ensure downwards compatibility`
* `of scripts. This means that in Belize theme there are children of both tbar[0] (system toolbar) and tbar[1] even`
* `though only a single toolbar is displayed. The buttons in the footer area of Belize and newer themes are also`
* `still children of the application toolbar and retain their scripting ids containing tbar[1].`
* `The children of a GuiToolbar are buttons (GuiButton Object [page 54]) and the OKCode field (GuiOkCodeField`
* `Object [page 172]) unless it is hidden. When SAP Fiori features are turned on in Belize and newer themes,`
* `the application toolbar may also contain a ViewSwitch (GuiVHViewSwitch Object [page 288]). The indexes for`
* `toolbar buttons defined by the application are determined by the virtual key values defined for the button.`
* `The indexes / names of specific buttons and elements are fixed:`
* `Button/Element Index/Name`
* `OKCode field okcd`
* `Generates shortcut button 418`
* `New GUI Window button 419`
* `Button for collapsing the OKCode field 423`
* `SAP GUI Options button 446`
* `“More” button`
* `(only available in Belize and newer SAP GUI themes)`
* `btnvhmore`
* `View Switch`
* `(only available in Belize and newer SAP GUI themes when`
* `Fiori features are activated and the ABAP application has`
* `implemented a View Switch)`
* `vhviewswitch`
* `GuiToolbar extends the GuiVContainer Object [page 286].`
* `The type prefix and name are tbar. tbar[0] is the system toolbar, while tbar[1] is the application toolbar.`
* `The GuiToolbars can also be influenced by properties ButtonbarVisible and ToolbarVisible of the GuiApplication`
* `object.`
* `Buttons hidden in an overflow menu`
* `When the SAP GUI window is not wide enough to display all buttons in a GuiToolbar or the application has`
* `decided that a button shall not be displayed by default, some buttons are moved into an overflow menu`
* `(depending on the theme this can also be a More button). For themes older than Belize, the SAP GUI Scripting`
* `object hierarchy always contained visible buttons and buttons in overflow menus. For themes as of Belize, the`
* `hidden buttons where originally not part of the object hierarchy. This changed as of SAP GUI for Windows 8.00`
* `patchlevel 2. Now these objects are part of the object hierarchy for all themes.`
* `Since there is no “visible” property in the , you can use the dimensions and positions to`
* `check whether a button is part of an overflow or not. If the button is not displayed on the screen, but is part of`
* `an overflow, the properties ScreenLeft, ScreenTop, Left, Top, Width and Height all have value 0.`

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
* `AccText`
* `AccTextOnRequest`
* `AccT ooltip`
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
| **`CaretPosition`** | `Read-write` | `Long` | The position of the caret within a text field may be checked  by the ABAP application to determine which word the caret  is in. Among other things this is useful for context sensitive  help. |
| **`DisplayedText`** | `Read-only` | `Public Property DisplayedText As` | String This property contains the text as it is displayed on the  screen, including preceding or trailing blanks. These blanks  are stripped from the text property. |
| **`Highlighted`** | `Read-only` | `Byte` | This property is T rue if the Highlighted flag is set in the  screen painter for the dynpro element. See GuiLabel for an  example. |
| **`HistoryCurEntry`** | `Read-only` | `Public Property HistoryCurEntry As` | String Text of the currently focused entry in the history list box. |
| **`HistoryCurIndex`** | `Read-only` | `Public Property HistoryCurIndex As` | Long Currently focused index in the history dropdown list box. |
| **`HistoryIsActive`** | `Read-only` | `Public Property HistoryIsActive As` | Byte This property is T rue if the local input field history drop down  is currently open. |
| **`HistoryList`** | `Read-only` | `Public Property HistoryList As` | GuiCollection List of entries in the local history list box. |
| **`IsHotspot`** | `Read-only` | `Byte` | Dynpro elements such as labels may be configured to cause  a round trip when they are clicked. In that case the mouse  cursor changes to the hand shape. This is called a hot spot. |
| **`IsLeftLabel`** | `Read-only` | `Byte` | This property is T rue if the component has the 'assign left'  flag. |
| **`IsListElement`** | `Read-only` | `Byte` | This property is T rue if the element is on an ABAP list, not a  dynpro screen. |
| **`IsOField`** | `Read-only` | `Byte` | OField is a special ABAP dynpro element, the Output Field.  These fields can be set programmatically to a value at run­ time. In this respect they differ from labels. However they  cannot be used to enter data, so they are not input fields. |
| **`IsRightLabel`** | `Read-only` | `Byte` | This property is T rue if the component has the 'assign right'  flag. |
| **`LeftLabel`** | `Read-only` | `Public Property LeftLabel As` | GuiVComponent This label has been defined in ABAP Screen Painter to be the  left label of the control. |
| **`MaxLength`** | `Read-only` | `Long` | The maximum length of text that can be written in a text field  is counted in code units. On non-Unicode clients these are  equivalent to bytes. |
| **`Numerical`** | `Read-only` | `Byte` | If this flag is set only numbers and special characters may be  written into the text field. |
| **`Required`** | `Read-only` | `Byte` | This property is T rue if the component is a required value for  the screen. |
| **`RightLabel`** | `Read-only` | `Public Property RightLabel As` | GuiVComponent This label has been defined in ABAP Screen Painter to be the  right label of the control. |

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

This method returns information that is compiled on the  server to enhance the ABAP lists with accessibility informa­ tion. See GuiLabel Object [page 140] → GetListProperty  for a description of available attributes. In contrast to the  method GetListProperty, GetListPropertyNonRec will only  return information that is set for the specific element and  ignore list properties set for parent elements. For more infor­ mation, refer to the documentation about method GetList­ PropertyNonRec within GuiLabel Object [page 140].

