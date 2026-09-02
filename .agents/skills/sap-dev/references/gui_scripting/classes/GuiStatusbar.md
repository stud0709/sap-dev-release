# GuiStatusbar

> **Type**: `Class` | **Section**: `1.2.56`
> **Inherits from**: [`GuiVComponent`](GuiVComponent.md) | **ID Prefix**: `sbar`

---

## 📖 Description

GuiStatusbar represents the message displaying part of the status bar on the bottom of the SAP GUI window. It  does not include the system and login information displayed in the rightmost area of the status bar as these are  available from the GuiSessionInfo object. GuiStatusbar extends the GuiVComponent Object [page 281]. The  type prefix is sbar.

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

**All methods of the GuiVComponent Object [page 281]:**:
* `DumpState`
* `SetFocus`
* `Visualize`
* `Press This emulates manually clicking the Service Request Link`
* `which triggers the application specific action and causes`
* `server communication to occur.`

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
| **`Handle`** | `Read-only` | `Long` | The window handle of the control that is connected to the  GuiShell. |
| **`MessageAsPopup`** | `Read-only` | `Byte` | Some messages may be displayed not only on the status bar  but also as a pop-up window. In such cases, this property is  set to T rue so that a script knows it has to close a pop-up to  continue. |
| **`MessageHasLongText`** | `Read-only` | `Public Property MessageHasLongText As` | Long This property can be used to determine whether the cur­ rently displayed message has a long text or not (in Belize  theme or newer themes this means that the View Details link  is displayed for this message). Possible return values • -1: Presently no message is displayed in the statusbar • 0: The message which is displayed does not have a long  text • 1: The message which is displayed has a long text This property is available as of patchlevel 2 of SAP GUI for  Windows 7 .60. |
| **`MessageId`** | `Read-only` | `String` | This is the name of the message class used in the ABAP  message call. |
| **`MessageNumber`** | `Read-only` | `Public Property MessageNumber As` | String This is the name of the message number used in the ABAP  message call. It will usually be a number, but this is not  enforced by the system. |
| **`MessageParameter`** | `Read-only` | `Public Property MessageParameter As` | String These are the values of the parameters used to expand  the placeholders in the message text definition in the data  dictionary. The text property of the GuiStatusbar already  contains the expanded text of the message. A maximum of  8 parameter values can be provided in the ABAP coding, so  index should be in the range from 0 to 7 . Example The ABAP language line  Sample Code message e319(01) with 'test1'  'test2' 'test3' 'test4'. will result in the following property values:  Sample Code Text = E:  test1 test2 test3 test4 Type         = E Id           = 01  Number       = 319 Parameter 0  = test1 Parameter 1  = test2 Parameter 2  = test3 Parameter 3  = test4 Parameter 4  = Parameter 5  = Parameter 6  = Parameter 7  = as Popup     = False The message 319 in message class 01 is defined as ‘ & & &  &’ , with ‘&’ being a placeholder. |
| **`MessageType`** | `Read-only` | `String` | This property may have any of the following values: Value Description S Success W Warning E Error A Abort I Information .2.57  GuiStatusBarLink GuiStatusbarLink represents a so-called service request link that can optionally be displayed in the  GuiStatusBar by an application. Clicking such a link executes an application specific action, like launching  a transaction for reporting a functional issue. If present, the parent of the GuiStatusbarLink object is the first pane (pane[0]) of the status bar (see also  GuiStatusbar Object [page 222] and GuiStatusPane Object [page 228]). |

---

## ⚙️ Methods

### `CreateSupportMessageClick`

```vb
Public Sub CreateSupportMessageClick
```

() This method sends the OKCode ?SMSG to the server. This  OKCode in many cases triggers a dialog for creating a sup­ port incident (the concrete functionality depends on the im­ plementation on the server side). This is the same as dou­ ble-clicking the SAP Logo in the SAP GUI main window.

### `DoubleClick`

```vb
Public Sub DoubleClick()
```

When a message is displayed in the GuiStatusbar, this mes­ sage can be double clicked. This will usually open the SAP  performance assistant.

### `ServiceRequestClick`

```vb
Public Sub ServiceRequestClick ()
```

A message displayed in the SAP GUI main window can  have a so-called “Service Request link” . This is a link  that takes the user to some related functionality. Method  ServiceRequestClick triggers the activation of this function­ ality as if the user clicked the Service Request link.

