# GuiButton

> **Type**: `Class` | **Section**: `1.2.6`
> **Inherits from**: [`GuiVComponent`](GuiVComponent.md) | **ID Prefix**: `btn`

---

## 📖 Description

GuiButton represents all push buttons that are on dynpros, the toolbar or in table controls. GuiButton extends  the GuiVComponent Object [page 281]. The type prefix is btn, the name property is the fieldname taken from  the SAP data dictionary There is one exception: For tabstrip buttons, it is the button id set in screen painter that  is taken from the SAP data dictionary.

---

## 🧬 Inherited Members

**All methods of the GuiVComponent Object [page 281]:**:
* `DumpState`
* `SetFocus`
* `Visualize`
* `Press This emulates manually pressing a button. Pressing a button`
* `will always cause server communication to occur, rendering`
* `all references to elements below the window level invalid.`
* `The following code will therefore fail:`
* `Set TextField = session.findById(".../`
* `txtF1")`
* `session.findById(".../btnPB5").press TextField.text = "Hello"`

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
* `endSelection (Read-only)`
* `Public Property endSelection As String`
* `The last day of the selected date range (in format`
* `“YYYYMMDD”).`

---

## 📋 Properties

| Property | Access | Signature / Type | Description |
|:---|:---|:---|:---|
| **`Emphasized`** | `Read-only` | `Byte` | This property is T rue if the button is displayed empha­ sized (in Fiori Visual Themes: The leftmost button in the  footer and buttons configured as "Fiori Usage D Display<- >Change").  Note • If SAP GUI is running without a Fiori Visual Theme  (like Belize) this property is always False. • This property is available as of SAP GUI for Win­ dows 7 .60. LeftLabel Public Property LeftLabel As  GuiVComponent Left label of the GuiButton. The label is assigned in the  Screen Painter, using the flag 'assign left'. RightLabel Public Property RightLabel As  GuiVComponent Right label of the GuiButton. This property is set in Screen  Painter using the 'assign right' flag. .2.7  GuiCalendar Object  Description The calendar control can be used to select single dates or periods of time. GuiCalendar extends the GuiShell  Object [page 207]. Example |

---

