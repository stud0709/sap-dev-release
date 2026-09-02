# GuiSession

> **Type**: `Class` | **Section**: `1.2.49`
> **Inherits from**: [`GuiContainer`](GuiContainer.md) | **ID Prefix**: `ses`

---

## 📖 Description

The GuiSession provides the context in which a user performs a certain task such as working with a  transaction. It is therefore the access point for applications, which record a user’s actions regarding a specific  task or play back those actions. GuiSession extends GuiContainer. The type prefix is ses, the name is ses plus  the session number in square brackets. Remarks GuiSession is self-contained in that ids within the context of a session remain valid independently of other  connections or sessions being open at the same time. Usually an external application will first determine with  which session to interact. Once that is clear, the application will work more or less exclusively on that session.  T raversing the object hierarchy from the GuiApplication to the user interface elements, it is the session among  whose children the highest level visible objects can be found. In contrast to objects like buttons or text fields,  the session remains valid until the corresponding main window has been closed, whereas buttons, for example,  are destroyed during each server communication.

---

## 🧬 Inherited Members

**All methods of the GuiContainer Object [page 87]:**:
* `FindById`

**All properties of the GuiComponent Object [page 82]:**:
* `ContainerType`
* `Id`
* `Name`
* `Parent`
* `Type`
* `TypeAsNumber`
* `All properties of the GuiContainer Object [page 87]:`
* `Children`

---

## 📋 Properties

| Property | Access | Signature / Type | Description |
|:---|:---|:---|:---|
| **`AccEnhancedTabChain`** | `Read-write` | `Public Property AccEnhancedTabChain` | As Byte This property is T rue if the respective option "Include read- only and disabled elements in tab chain" has been set in the  SAP GUI options dialog. |
| **`AccSymbolReplacement`** | `Read-write` | `Public Property AccSymbolReplacement` | As Byte This property is T rue if the respective option "Display sym­ bols in lists as letters" has been set in the SAP GUI options  dialog. |
| **`ActiveWindow`** | `Read-only` | `Public Property ActiveWindow As` | GuiFrameWindow All windows can be found in the children collection of Gui­ Session. However, most of the time an application will ac­ cess the currently activated window of the session, as that  is the window with which a user will probably interact. This  property is intended as a shortcut to this window. |
| **`Busy`** | `Read-write` | `Byte` | While SAP GUI is waiting for data from the server, any Script­ ing call will not return, which blocks the executing thread.  This may not be acceptable for advanced applications. A way to prevent this is to check the busy property of the  session. If this property is T rue, then a subsequent Scripting  call will wait for the server communication to be finished. |
| **`ErrorList`** | `Read-write` | `Public Property ErrorList As` | GuiCollection |
| **`Info`** | `Read-only` | `GuiSessionInfo` | Info is of type GuiSessionInfo. It contains technical informa­ tion about the current connection, the login data, the run­ ning SAP application and more. |
| **`IsActive`** | `Read-write` | `Byte` | TRUE if the session window is active. FALSE overwise. |
| **`IsListBoxActive`** | `Read-only` | `Public Property IsListBoxActive As` | Byte This property is T rue if a listbox is currently open (for a  GuiComboBox). |
| **`ListBoxCurrEntry`** | `Read-only` | `Public Property ListBoxCurrEntry As` | Long The index of the currently selected listbox entry. |
| **`ListBoxCurrEntryHeight`** | `Read-only` | `Long` | The height of the current entry of the listbox in pixels. |
| **`ListBoxCurrEntryLeft`** | `Read-only` | `Public Property ListBoxCurrEntryLeft` | As Long The left position of the current entry of the listbox in pixels. |
| **`ListBoxCurrEntryTop`** | `Read-only` | `Public Property ListBoxCurrEntryTop` | As Long The top position of the current entry of the listbox in pixels. |
| **`ListBoxCurrEntryWidth`** | `Read-only` | `Public Property ListBoxCurrEntryWidth` | As Long The width of the current entry of the listbox in pixels. |
| **`ListBoxHeight`** | `Read-only` | `Long` | The height of the open listbox in pixels. |
| **`ListBoxLeft`** | `Read-only` | `Long` | The left position of the open listbox in pixels. |
| **`ListBoxTop`** | `Read-only` | `Long` | The top position of the open listbox in pixels. |
| **`ListBoxWidth`** | `Read-only` | `Long` | The width of the open listbox in pixels. |
| **`PassportPreSystemId`** | `Read-write` | `Public Property PassportPreSystemId` | As String The pre-system ID. Part of the passport information. |
| **`PassportSystemId`** | `Read-write` | `Public Property PassportSystemId As` | String The system ID. Part of the passport information. |
| **`PassportTransactionId`** | `Read-write` | `Public Property PassportTransactionId` | As String The unique ID of the transaction. Part of the passport infor­ mation. |
| **`ProgressPercent`** | `Read-only` | `Public Property ProgressPercent As` | LongPublic  The percentage displayed by the SAP GUI progress indicator. |
| **`ProgressText`** | `Read-only` | `String` | The text displayed by the progress indicator. |
| **`Record`** | `Read-write` | `Byte` | Setting this property to T rue enables the recording mode of  the session. In this mode changes to elements of the user in­ terface are recorded within SAP GUI and sent to a recording  application using the Change event described later. Remarks Some elements of the user interface may behave differently  in record mode than during playback or manual interaction. • The F4 help dialog is always displayed as a modal win­ dow. • Drag & Drop is disabled. |
| **`RecordFile`** | `Read-write` | `String` | A simple way to record a script it to set the recordFile prop­ erty to a valid filename and then enable the record property.  A Visual Basic Script file of the given name will be created in  the SAP GUI Scripts Folder on the client PC. Remarks This property only accepts simple filenames without path  information. |
| **`SaveAsUnicode`** | `Read-write` | `Byte` | If this property is set to TRUE, the recorded scripts will be  saved in UNICODE encoding. Overwise is the current system  codepage. |
| **`ShowDropdownKeys`** | `Read-write` | `Public Property ShowDropdownKeys As` | Byte If this property is TRUE, the dropdowns show not only the  text of dropdown entries, but also the keys. |
| **`SuppressBackendPopups`** | `Read-write` | `Public Property SuppressBackendPopups` | As Byte |
| **`TestToolMode`** | `Read-write` | `Long` | During internal tests some aspects of the user interface  proved to be difficult to handle with test tools using the  Scripting API to automate SAP GUI. For this reason a special  mode has been added in which the following changes are  administered. • While success (S), warning (W) and error (E) messages  are always displayed in the status bar, information (I)  and abort (A) messages are displayed as pop-up win­ dows unless testT oolMode is set. • The update mode of the application server is changed  to immediate mode for the connection. • System messages are ignored so that they do not inter­ rupt the recording or playback of scripts. Remarks The test tool mode requires one of the following versions of  the SAP kernel: • 6.20 Patch level 29 and all following kernel versions • 4.6D Patch level 1208, see note 511310. Currently only the following values are allowed for this prop­ erty: • 0: Disable testT oolMode • 1: Enable testT oolMode |

---

## ⚙️ Methods

### `AsStdNumberFormat`

```vb
Public Function AsStdNumberFormat( _    ByVal Number As String _ ) As String
```

Depending on the system's number format the minus sign  of numbers may be placed to the right of the number. Using  this function the minus sign is moved to the left.

### `ClearErrorList`

```vb
Public Sub ClearErrorList()
```

This method clears the list of errors that may be created  when ActiveX controls are found on a screen that do not  support SAP GUI Scripting. Otherwise the list is cleared after  an error event was raised. This happens at the end of a  round trip.

### `CreateSession`

```vb
Public Sub CreateSession()
```

This function opens a new session, which is then visualized  by a new main window. This resembles the “/o” command  that can be executed from the command field.

### `EnableJawsEvents`

```vb
Public Sub EnableJawsEvents()
```

Enable the sending of events to the screenreader Freedom  Scientific JAWS, which communicates with SAP GUI for Win­ dows via the Scripting API. By default the sending of events  is activated.

### `EndTransaction`

```vb
Public Sub EndTransaction()
```

Calling this function has the same effect as SendCom­ mand("/n").

### `FindByPosition`

```vb
Public Function FindByPosition( _    ByVal x As Long, _
```

ByVal y As Long, _    Optional ByVal Raise As Variant _ ) As GuiCollection This method can be used to do a hittest on an SAP GUI  session. The parameters x and y should be given in screen  coordinates. If no component is found an exception is raised  unless raise is set to False. In that case a Null/Nothing object  is returned.

### `GetIconResourceName`

```vb
Public Function GetIconResourceName( _    ByVal Text As String _ ) As String
```

In SAP GUI icons are often described as text in the format  @nn@ where nn is a number. The function getIconResource­ Name translates the @nn@ notation into the name of the  resource in sapbtmp.dll.

### `GetObjectTree`

```vb
Public Function GetObjectTree ( _    ByVal Id As String, _
```

Optional ByVal props As Variant _ ) As String  This method was introduced in SAP GUI for Windows 7 .70  patchlevel 3. GetObjectTree returns the object tree of the current SAP GUI  tree as a JSON string. Y ou can use this JSON to determine  the information on the SAP GUI UI elements you need. Some SAP GUI Scripting based applications need to parse  the SAP GUI Object tree to get the values of certain prop­ erties for all objects on a screen. This could be achieved  via individual COM calls to the elements, but this approach  is very time consuming due to a large overhead in COM  itself. Therefore, the performance may not be good enough  in many cases. Via parameter Id you can limit the output to a subnode of the  object tree and all its children (for example for a dialog win­ dow). If this parameter is supplied as an empty string, the  complete object tree of the respective session is exported  along with Screen Number, Program and T ransaction code. The parameter props can be used to specify which proper­ ties of all elements are required. If this parameter is not  supplied, only the id property of each object is put into the  output. The parameter needs to contain an array with names  or GuiDispIds of the properties to be exported, see also Gui­ MagicDispIDs [page 301].  Note The properties can only be of simple types: String,  Integer, Bool. Exceptions are LetfLabel and RightLabel.  Even though these properties return objects they can be  gathered, but instead of an object the id of the respec­ tive GuiLabel will be retrieved.  Example The following is a vbs example  Sample Code arrayOfStrings = Array() arrayOfStrings =  AddItem(arrayOfStrings, "Id") arrayOfStrings =  AddItem(arrayOfStrings, "Text") arrayOfStrings =  AddItem(arrayOfStrings, "Type") arrayOfStrings =  AddItem(arrayOfStrings,  "IconName") or arrayOfDispIds = Array() arrayOfDispIds =  AddItem(arrayOfDispIds, 32025) arrayOfDispIds =  AddItem(arrayOfDispIds, 32000) arrayOfDispIds =  AddItem(arrayOfDispIds, 32015) arrayOfDispIds =  AddItem(arrayOfDispIds, 32037) Both lead to the same output. Overall example:  arrayOfStrings = Array() arrayOfStrings =  AddItem(arrayOfStrings, "Id") arrayOfStrings =  AddItem(arrayOfStrings, "Text") arrayOfStrings =  AddItem(arrayOfStrings, "Type") arrayOfStrings =  AddItem(arrayOfStrings,  "IconName") session.GetObjectTree  ("wnd[1]", arrayOfStrings) exports all elements of a  dialog window and the values  of the properties “Id”, “Text”,  “Type” and “IconName”. ' add item to array Function AddItem(arr, val)     ReDim Preserve  arr(UBound(arr) + 1)     arr(UBound(arr)) = val     AddItem = arr End Function  This can look like this:  Sample Code The following is a c# example With names: string[] strArr = new string[] {"Id", "Text", "Type", "IconName",  "Tooltip"}; With Magic DispIDs: int[] intArr = new int[] { 32025,  32000,  32015, 32037}; Execution restricted to wnd[1]: string json; json = ses.GetObjectTree("wnd[1]",  strArr);

### `GetVKeyDescription`

```vb
Public Function GetVKeyDescription( _    ByVal VKey As Long _ ) As String
```

When a script is recorded, it will often contain sendVKey(n)  calls, where n is a number. The method getVKeyDescription  translates these numbers into a readable text. For example  the number 0 is translated into the text “Enter” .

### `LockSessionUI`

```vb
Public Sub LockSessionUI()
```

This method locks the session so that no user interaction  is possible until the session is unlocked using UnlockSessio­ nUI.

### `SendCommand`

```vb
Public Sub SendCommand( _     ByVal Command As String _  )
```

Using this function you can execute any command string,  which could otherwise be entered in the command field  combo box. SendCommandAsync  SendCommandAsync Public Sub SendCommandAsync( _     ByVal Command As String _  )  Using this function, you can execute any command string,  which could otherwise be entered in the command field  combo box. The difference to the method SendCommand  is that SAP GUI does not wait for the response of the server  before continuing.  Note When creating a script using this command, you need  to make sure to find out if scripting is possible when  running the next command. This can be achieved  by checking the Busy property of listening to the  SapSessionEndRequest event.

### `StartTransaction`

```vb
Public Sub StartTransaction( _     ByVal Transaction As String _  )
```

Calling this function with parameter "xyz" has the same ef­ fect as SendCommand("/nxyz").

### `UnlockSessionUI`

```vb
Public Sub UnlockSessionUI()
```

This method unlocks the session after it was locked using  LockSessionUI.

## ⚡ Events

### `AbapScriptingEvent`

```vb
Public Event AbapScriptingEvent( _    ByVal param As String _ )
```

Activated Public Event Activated( _    ByVal Session As GuiSession _ )

### `AutomationFCode`

```vb
Public Event AutomationFCode( _    ByVal Session As GuiSession, _
```

ByVal FunctionCode As String _ ) The event is only fired when using the SAP Workplace. It  notifies the listener that SAP GUI executes a function code  that was set by the Workplace framework.

### `Change`

```vb
Public Event Change( _    ByVal Session As GuiSession, _
```

ByVal Component As GuiComponent, _    ByVal CommandArray As Variant _ ) In record mode, the session collects changes to elements  of the user interface and sends these changes to a listening  application whenever server communication is about to start  or if the record mode is turned off. The change events are  raised immediately before the startRequest event. There is  at least one event for every modified element in the recorded  session. Remarks  Note When developing a handler for this event, you must  not include any action that may trigger the same event  again, because this will lead to an infinite loop. For  example, you must not call the press() function of a  button, because this would cause another roundtrip to  the server and would thus raise another Change/EndRe­ quest/StartRequest event. Only changes made at the SAP GUI level are recorded. T rans­ actions may preset some of the entry fields with values from  parameters stored in the SAP system. If these data are not  changed in SAP GUI, they will not be recorded. This may  cause problems during playback of scripts, if the entry fields  are preset with different values. If any of the following techniques is used in a transaction, the  user should manually modify all the entries he wants to see  recorded: • Usage of SAP parameters • Variants • Hold Data, from the menu System -> User Profile Playback of the changes will only work, if the order of the  calls is the same as during recording. Each event represents one line of script code. The Compo­ nent parameter specifies the object on which to invoke a  method or property. Therefore the first thing to record is  Component.id for later use with findById. The recorder may  however also decide to record other properties of Compo­ nent. If, for example, a line in a table control or list is se­ lected, it may be prudent not to record the position of the  line, but rather the values in it. That way, a script can be  generated that is more robust with respect to changes in the  number, and therefore in the position, of lines. If new function modules have been added, selecting a line  from the list might return the wrong function module. Type Method/Property  name Parameters "SP" "Text" "Hello World" This sets the parameter Text to value “Hello World” . Type Method/Property  name Parameters "SP" "RecordMode" T rue This sets the parameter RecordMode to the Boolean value  T rue. It is up to the recorder to generate a script line with  a valid textual representation of Boolean values, such as  “true” , “T rue” or “TRUE” for example. Type Method/Property  name Parameters "SP" "T estT oolMode" 0 This sets the parameter T estT oolMode to value 0. Type Method/Property  name Parameters "M" "Resize" 96 32 False The method Resize is called with three parameters. In this  case the third member of the CommandArray is an array  with 3 elements.

### `ContextMenu`

```vb
Public Event ContextMenu( _    ByVal Session As GuiSession, _
```

ByVal Component As GuiVComponent _ ) The contextMenu event is fired when SAP GUI is about to  display a context menu. There are currently the following  limitations: • Only context menus of controls of type GuiShell are  supported. • The event is not fired for “cached” context menus,  which are not retrieved from the server when being  opened.

### `Destroy`

```vb
Public Event Destroy( _    ByVal Session As GuiSession _ )
```

This event is raised before a session is destroyed.

### `EndRequest`

```vb
Public Event EndRequest( _    ByVal Session As GuiSession _ )
```

endRequest is called immediately after the session is un­ locked after server communication.  Note When developing a handler for this event, you must  not include any action that may trigger the same event  again, because this will lead to an infinite loop. For  example, you must not call the press() function of a  button, because this would cause another roundtrip to  the server and would thus raise another Change/EndRe­ quest/StartRequest event.

### `Error`

```vb
Public Event Error( _    ByVal Session As GuiSession, _
```

ByVal ErrorId As Long, _    ByVal Desc1 As String, _    ByVal Desc2 As String, _    ByVal Desc3 As String, _    ByVal Desc4 As String _ ) An error event is currently only raised, if the wrapper library  required to access an SAP GUI ActiveX control from a script  is not available. error events from all sessions are also availa­ ble at the GuiApplication.

### `FocusChanged`

```vb
Public Event FocusChanged( _    ByVal Session As GuiSession, _
```

ByVal NewFocusedControl As  GuiVComponent _ ) This event is triggered when the focus in SAP GUI is moved  to a new item. Using the parameters one can identify which  item in which session received focus.

### `HistoryOpened`

```vb
Public Event HistoryOpened( _    ByVal Session As GuiSession, _
```

ByVal NewFocusedControl As  GuiVComponent _ ) This event is triggered when the SAP GUI input history is  opened. Using the parameters one can identify the session  and the object for which the history was opened.

### `Hit`

```vb
Public Event Hit( _    ByVal Session As GuiSession, _
```

ByVal Component As GuiComponent, _    ByVal InnerObject As String _ ) The hit event is only raised when elementVisualizationMode  is set to T rue, which turns on the hit test mode of SAP GUI. If  in this mode a SAP GUI component is identified, the hit event  is raised. The parameters of this event are • The session on which the component was hit • The component that was hit • A description of an inner object of the component if an  inner object was hit

### `ProgressIndicator`

```vb
Public Event ProgressIndicator( _    ByVal percentage As Long, _
```

ByVal Text As String _ ) This event is triggered when the SAP GUI progress indicator  is displayed. The properties contain the current percentage  and the text of the progress indicator.

### `StartRequest`

```vb
Public Event StartRequest( _    ByVal Session As GuiSession _ )
```

The startRequest event is raised before the session is locked  during server communication. At this point user input can be  checked before it is sent to the server. It is not possible to  prevent server communication from this event.  Note When developing a handler for this event, you must  not include any action that may trigger the same event  again, because this will lead to an infinite loop. For  example, you must not call the press() function of a  button, because this would cause another roundtrip to  the server and would thus raise another Change/EndRe­ quest/StartRequest event.

