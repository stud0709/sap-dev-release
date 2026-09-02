# GuiConnection (Class)

> **Official SAP GUI Scripting API Reference** (Pages 85–87)

1.2.17  GuiConnection Object
Description
A GuiConnection represents the connection between SAP GUI and an application server. Connections can be 
opened from SAP Logon or from GuiApplication’s openConnection and openConnectionByConnectionString 
methods. GuiConnection extends the GuiContainer Object [page 87]. The type prefix for GuiConnection is 
con, the name is con plus the connection number in square brackets.
Remarks
It is possible to connect to an application server from ABAP using the following command:
CALL FUNCTION func DESTINATION dest.
However, this connection is implemented as a re-direction between the two application servers involved. There 
will therefore be no new GuiConnection object available and the existing object will not reflect the server 
switch.
Methods
Method
Syntax Description
All methods of the GuiContainer Object [page 87]:
• FindById
CloseConnection
Public Sub CloseConnection()
This method closes a connection along with all its sessions.
CloseSession
Public Sub CloseSession( _     ByVal Id As String _  )
A session can be closed by calling this method of the con­
nection. Closing the last session of a connection will close 
the connection, too.
The parameter "Id" must contain the id of the session to 
close (like "/app/con[0]/ses[0]").
SAP GUI Scripting API

Properties
Property
Syntax Description
All properties of the GuiComponent Object [page 82]:
• ContainerType
• Id
• Name
• Parent
• Type
• TypeAsNumber
Children (Read-only)
Public Property Children As 
GuiComponentCollection
This collection contains all direct children of the object.
ConnectionString (Read-only)
Public Property ConnectionString As 
String
This property contains the connection string defining the 
backend connection. It is more difficult to read, but it doesn’t 
rely on the SAP Logon entries.
More information on connection strings can be found in 
chapter Method OpenConnectionByConnectionString [page 
45].
Description (Read-only)
Public Property Description As String
This description is only available if the connection was 
started either from SAP Logon or using GuiApplica­
tion.OpenConnection. In both cases the description can then 
be used when calling the OpenConnection method to 
play back a script on the same system.
DisabledByServer (Read-only)
Public Property DisabledByServer As 
Byte
This property is set to T rue if the scripting support has not 
been enabled for the application server.
Sessions (Read-only)
Public Property Sessions As 
GuiComponentCollection
This property is another name for the Children property. 
It was added for better readability as all the children of 
GuiConnection are sessions. Accessing either the children 
property or the Sessions property can cause the excep­
tion Gui_Err_Scripting_Disabled_Srv (624) to be raised if the 
respective application server has not enabled the scripting 
support.
86 PUBLIC
SAP GUI Scripting API
SAP GUI Scripting API
