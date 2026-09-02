# GuiUtils (Class)

> **Official SAP GUI Scripting API Reference** (Pages 279–281)

1.2.71  GuiUtils Object 
Methods
Method
Syntax Description
CloseFile
Public Sub CloseFile( _     ByVal File As Long _  )
This function closes a file that was opened using OpenFile.
OpenFile
Public Function OpenFile( _    ByVal Name As String _ ) As Long
The file will be created in the SAP GUI Documents Folder.
Return Type
The return value is a handle to the file.
Name: Name of the text file to be created. For security rea­
sons this name must not contain any path information.
ShowMessageBox
Public Function ShowMessageBox( _    ByVal Title As String, _
   ByVal Text As String, _
   ByVal MsgIcon As Long, _
   ByVal MsgType As Long _ ) As Long
Shows a message box.
Return Type
The return value will be one of the GuiMessageBoxResult 
constants.
Title: Title of the message box
Text: Text of the message box.
MsgIcon: MsgIcon sets the icon to be used for the mes­
sage box and should be set to one of the GuiMessageBox­
Type constants.
MsgType: MsgType sets the buttons available on the mes­
sage box and should be set to one of the GuiMessageBoxOp­
tion constants.
Write
Public Sub Write( _     ByVal File As Long, _
    ByVal Text
    As String _  )
Write text to an open file without a new line at the end.
SAP GUI Scripting API

Method
Syntax Description
WriteLine
Public Sub WriteLine( _     ByVal File As Long, _
    ByVal Text
    As String _  )
Write text to an open file with a new line at the end.
Properties
Property
Syntax Description
MESSAGE_OPTION_OK (Read-only)
Public Property MESSAGE_OPTION_OK As 
Long
Belongs to GuiMessageBoxOption: The message box will 
show an "OK" button.
MESSAGE_OPTION_OKCANCEL (Read-only)
Public Property 
MESSAGE_OPTION_OKCANCEL As Long
Belongs to GuiMessageBoxOption: The message box will 
show an "OK" and a "Cancel" button.
MESSAGE_OPTION_YESNO (Read-only)
Public Property MESSAGE_OPTION_YESNO 
As Long
Belongs to GuiMessageBoxOption: The message box will 
show a "Y es" and a "No" button.
MESSAGE_RESULT_CANCEL (Read-only)
Public Property MESSAGE_RESULT_CANCEL 
As Long
Belongs to GuiMessageBoxResult: The message box was 
closed via the "Cancel" button.
MESSAGE_RESULT_NO (Read-only)
Public Property MESSAGE_RESULT_NO As 
Long
Belongs to GuiMessageBoxResult: The message box was 
closed via the "No" button.
MESSAGE_RESULT_OK (Read-only)
Public Property MESSAGE_RESULT_OK As 
Long
Belongs to GuiMessageBoxResult: The message box was 
closed via the "OK" button.
280 PUBLIC
SAP GUI Scripting API
SAP GUI Scripting API
