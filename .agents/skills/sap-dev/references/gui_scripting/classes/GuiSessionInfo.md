# GuiSessionInfo

> **Type**: `Class` | **Section**: `1.2.50`
> **Inherits from**: [`GuiVContainer`](GuiVContainer.md) | **ID Prefix**: `shell`

---

## 📖 Description

GuiSessionInfo is a member of all GuiSession objects. It makes available technical information about the  session. Some of its properties are displayed in the system information area (either in the status bar or the title  area depending on the SAP GUI theme used).

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
* `All additional properties of the GuiContainer Object [page 87]:`
* `Children`

---

## 📋 Properties

| Property | Access | Signature / Type | Description |
|:---|:---|:---|:---|
| **`ApplicationServer`** | `Read-only` | `Public Property ApplicationServer As` | String The name of the application server is set only if the session  belongs to a connection that was started without load bal­ ancing, by specifying an application server. |
| **`Client`** | `Read-only` | `String` | The client selected on the login screen. |
| **`Codepage`** | `Read-only` | `Long` | The codepage specified in SAP Logon in the properties of the  connection. |
| **`Flushes`** | `Read-only` | `Long` | The property flushes counts the number of flushes in the  automation queue during server communication. |
| **`Group`** | `Read-only` | `String` | The login group information is available only if the session  belongs to a connection which was started using load bal­ ancing. |
| **`GuiCodepage`** | `Read-only` | `Long` | A list of codepages is available in table TCP00A of the SAP  system. On a client running Microsoft Windows with code­ page 1252 (Latin I) the property guiCodepage is 1160. |
| **`I18NMode`** | `Read-only` | `Byte` | The I18N mode of SAP GUI is required for multi-byte charac­ ter sets. |
| **`InterpretationTime`** | `Read-only` | `Public Property InterpretationTime As` | Long The interpretation time begins after the data have arrived  from the server. It comprises the parsing of the data and dis­ tribution to the SAP GUI elements. The unit is milliseconds. |
| **`IsLowSpeedConnection`** | `Read-only` | `Public Property IsLowSpeedConnection` | As Byte The property is T rue if the connection to which the session  belongs runs with the low speed connection flag. This flag  can be set on the advanced connection properties page of  the SAPLogon dialog. The SAP GUI Scripting support is very  limited for low speed connections, because information re­ quired to identify SAP GUI objects is not being sent. |
| **`Language`** | `Read-only` | `String` | The language specified on the login screen. |
| **`MessageServer`** | `Read-only` | `Public Property MessageServer As` | String The message server information is available only if the ses­ sion belongs to a connection which was started using load  balancing. |
| **`Program`** | `Read-only` | `String` | The name of the source program that is currently being exe­ cuted. |
| **`ResponseTime`** | `Read-only` | `Long` | This is the time that is spent on network communication  from the moment data are sent to the server to the moment  the server response arrives. The unit is milliseconds. |
| **`RoundTrips`** | `Read-only` | `Long` | Before SAP GUI sends data to the server it locks the user  interface. In many cases it will not unlock the interface once  data arrive from the server, but instead will send a new re­ quest to the server immediately. Controls in particular use  this technology to load the data they need for visualization.  The count of these token switches between SAP GUI and the  server is the roundT rips property. |
| **`ScreenNumber`** | `Read-only` | `Long` | The number of the screen currently displayed. |
| **`ScriptingModeReadOnly`** | `Read-only` | `Public Property ScriptingModeReadOnly` | As Byte The read-only mode can be enabled using an application  server profile parameter. In this mode, the state of SAP  applications cannot be changed through the Scripting API,  which means: • Properties can only be read, but not set. • Functions can only be called if they do not change the  control’s state. Remarks In this mode, scripts can be recorded and information about  the application can be read from SAP GUI. However a trans­ action cannot be run from a script. Additional documenta­ tion is available in note 692245   and in the SAP GUI  Scripting security documentation on the Help Portal. |
| **`ScriptingModeRecordingDisabled`** | `Read-only` | `Byte` | The recording disabled mode can be enabled using an ap­ plication server profile parameter. In this mode SAP GUI  Scripting does not fire any events. This implies that user  interaction cannot be recorded. However data can be read  from SAP GUI and scripts can be used to run transactions. |
| **`SessionNumber`** | `Read-only` | `Long` | The number of the session is also displayed in SAP GUI on  the status bar. |
| **`SystemName`** | `Read-only` | `String` | This is the name of the SAP system. |
| **`SystemNumber`** | `Read-only` | `Long` | The system number is set only if the session belongs to a  connection that was started without load balancing, by spec­ ifying an application server. |
| **`SystemSessionId`** | `Read-only` | `Public Property SystemSessionId As` | String All SAP GUI sessions of the same connection are repre­ sented on the server with the same SystemSessionId. Using  SystemSessionId and SessionNumber, it is possible to find a  matching SAP GUI session from an ABAP application. |
| **`Transaction`** | `Read-only` | `String` | The transaction that is currently being executed. |
| **`UI_GUIDELINE`** | `Read-only` | `String` | This property can be used to identify whether the SAP GUI  session is running with enabled SAP Fiori features or not. The return value is • 1 if the session is running with deactivated SAP Fiori  features (SAP Fiori features off) • 2 if the session is running with activated SAP Fiori fea­ tures (SAP Fiori features on)  Note • SAP Fiori features are only available as of  theme Belize. This means that for all previous  themes you always get 1 as the value of this  property. • Y ou can activate and deactivate the SAP Fiori  features in the SAP GUI options dialog. |
| **`User`** | `Read-only` | `String` | The SAP name of the user logged into the system. .2.51  GuiShell Object Description GuiShell is an abstract object whose interface is supported by all the controls. GuiShell extends the  GuiVContainer Object [page 286]. The type prefix is shell, the name is the last part of the id, shell[n]. |

---

## ⚙️ Methods

### `SelectContextMenuItem`

```vb
Public Sub SelectContextMenuItem( _     ByVal FunctionCode As String _     )
```

Select an item from the control’s context menu.

### `SelectContextMenuItemByPosition`

```vb
Public Sub 
SelectContextMenuItemByPosition( _     ByVal PositionDesc As String _ )
```

This method allows you to select a context menu item using  the position of the item. It is therefore independent of the  menu item text.

### `SelectContextMenuItemByText`

```vb
Public Sub 
SelectContextMenuItemByText( _     ByVal Text As String _  )
```

Select a menu item of a context menu using the text of the  item and possible higher level menus.

