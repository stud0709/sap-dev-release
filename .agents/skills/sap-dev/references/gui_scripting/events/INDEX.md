# SAP GUI Scripting — Events Reference

> **Source**: Official SAP GUI Scripting API Developer Guide (Section 1.3, Pages 291–297)

Events are outgoing notifications raised by the SAP GUI Scripting engine during user interaction or server communication.

---

## ⚡ Event Catalog

### `AbapScriptingEvent`

```vb
Public Event AbapScriptingEvent( ByVal param As String )
```

---

### `Activated`

```vb
Public Event Activated( ByVal Session As GuiSession )
```

---

### `AutomationFCode`

```vb
Public Event AutomationFCode( ByVal Session As GuiSession, ByVal FunctionCode As String )
```

The event is only fired when using the SAP Workplace. It notifies the listener that SAP GUI executes a function code that was set by the Workplace framework.

---

### `Change`

```vb
Public Event Change( ByVal Session As GuiSession, ByVal Component As GuiComponent, ByVal CommandArray As Variant )
```

In record mode, the session collects changes to elements of the user interface and sends these changes to a listening application whenever server communication is about to start or if the record mode is turned off. The Change events are raised immediately before the StartRequest event. There is at least one event for every modified element in the recorded session. see also: Change Event - Additional Remarks [page 294]

---

### `ContextMenu`

```vb
Public Event ContextMenu( ByVal Session As GuiSession, ByVal Component As GuiVComponent )
```

The ContextMenu event is fired when SAP GUI is about to display a context menu. There are currently the following limitations: • Only context menus of controls of type GuiShell are supported. • The event is not fired for “cached” context menus, which are not retrieved from the server when being opened.

---

### `CreateSession`

```vb
Public Event CreateSession( ByVal Session As GuiSession )
```

This event is raised whenever a new session is created, irre­ spective of whether of the session being created manually, from ABAP or by a script. The event is only raised for a session if the scripting support has been enabled for the corresponding backend. Example  Sample Code Dim objSapGui Set objSapGui = GetObject("SAPGUI") Dim objScriptingEngine Set objScriptingEngine = objSapGui.GetScriptingEngine WScript.ConnectObject objScriptingEngine, "Engine_" Dim Waiting Waiting = 1 Do While (Waiting = 1) WScript.Sleep(100) Loop Set objScriptingEngine = Nothing Set objSapGui = Nothing Sub Engine_CreateSession(ByVal Session) Dim result result = MsgBox("Session created", vbOKCancel) If result = vbCancel then Waiting = 0 End If End Sub

---

### `Destroy`

```vb
Public Event Destroy( ByVal Session As GuiSession )
```

This event is raised before a session is destroyed.

---

### `DestroySession`

```vb
Public Event DestroySession( ByVal Session As GuiSession )
```

This event is raised before a session is destroyed . This can be done either by closing the main window manually, or by calling the closeSession method of GuiConnection.

---

### `EndRequest`

```vb
Public Event EndRequest( ByVal SessionSession As GuiSession )
```

endRequest is called immediately after the session is un­ locked after server communication.

---

### `Error (GuiSession Object [page 189])`

```vb
Public Event Error( ByVal Session As GuiSession, ByVal ErrorId As Long, ByVal Desc1 As String, ByVal Desc2 As String, ByVal Desc3 As String, ByVal Desc4 As String )
```

An Error event is currently only raised, if the wrapper li­ brary required to access a SAP GUI ActiveX control from a script is not available. error events from all sessions are also available at the GuiApplication.

---

### `Error (GuiApplication Object [page 38])`

```vb
Public Event Error( ByVal ErrorId As Long, ByVal Desc1 As String, ByVal Desc2 As String, ByVal Desc3 As String, ByVal Desc4 As String )
```

An Error event is currently only raised, if the wrapper library required to access a SAP GUI ActiveX control from a script is not available. This event is also available on the GuiSession in which the error occurred.

---

### `FocusChanged`

```vb
Public Event FocusChanged( ByVal Session As GuiSession, ByVal NewFocusedControl As GuiVComponent )
```

---

### `HistoryOpened`

```vb
Public Event HistoryOpened( ByVal Session As GuiSession, ByVal NewFocusedControl As GuiVComponent )
```

---

### `Hit`

```vb
Public Event Hit( ByVal SessionSession As GuiSession, ByVal Component As GuiComponent, ByVal InnerObject As String )
```

The Hit event is only raised when elementVisualization­ Mode is set to T rue, which turns on the hit test mode of SAP GUI. If in this mode a SAP GUI component is identified, the Hit event is raised. The parameters of this event are • The session on which the component was hit • The component that was hit • A description of an inner object of the component if an inner object was hit

---

### `IgnoreSession`

```vb
Public Event IgnoreSession( ByVal SessionMainWindowHandle As Integer )
```

The event is fired when a session is set to ‘Ignored’ using IgnoreSession function. This event is only fired when using SAP GUI Scripting while running eCATT in parallel.

---

### `ProgressIndicator`

```vb
Public Event ProgressIndicator( ByVal percentage As Long, ByVal Text As String )
```

---

### `StartRequest`

```vb
Public Event StartRequest( ByVal Session As GuiSession )
```

The startRequest event is raised before the session is locked during server communication. At this point user input can be checked before it is sent to the server. It is not possi­ ble to prevent server communication from this event. 1.3.1 Change Event - Additional Remarks Only changes made at the SAP GUI level are recorded. T ransactions may preset some of the entry fields with values from parameters stored in the SAP system. If these data are not changed in SAP GUI, they will not be recorded. This may cause problems during playback of scripts, if the entry fields are preset with different values. If any of the following techniques is used in a transaction, the user should manually modify all the entries he wants to see recorded: • Usage of SAP parameters • Variants • Hold Data, from the menu System -> User Profile Playback of the changes will only work, if the order of the calls is the same as during recording. Each event represents one line of script code. The Component parameter specifies the object on which to invoke a method or property. Therefore the first thing to record is Component.id for later use with FindById. The recorder may however also decide to record other properties of Component. If, for example, a line in a table control or list is selected, it may be prudent not to record the position of the line, but rather the values in it. That way, a script can be generated that is more robust with respect to changes in the number, and therefore in the position, of lines. If new function modules have been added, selecting a line from the list might return the wrong function module. Type Method/Property name Parameters "SP" Text "Hello World" This sets the parameter Text to value “Hello World” . Type Method/Property name Parameters "SP" RecordMode T rue This sets the parameter RecordMode to the Boolean value T rue. It is up to the recorder to generate a script line with a valid textual representation of Boolean values, such as “true” , “T rue” or “TRUE” for example. Type Method/Property name Parameters "SP" TestToolMode 0 This sets the parameter T estT oolMode to value 0. Type Method/Property name Parameters "M" Resize 96 32 False The method Resize is called with three parameters. In this case the third member of the CommandArray is an array with 3 elements. There are cases in which the CommandArray contains more than one line. If a row is selected in this table control, two entries are added to the generated Change event’s CommandArray parameter. Type Method/Property name Parameters "M" getAbsoluteRow 1 "SP" selected T rue The script code required to select this line should then look like this:  Sample Code Session. findById("wnd[0]/usr/tblSAPMBIBSTC537"). getAbsoluteRow("1").

---

