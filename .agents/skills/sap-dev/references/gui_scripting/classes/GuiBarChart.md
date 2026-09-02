# GuiBarChart (Class)

> **Official SAP GUI Scripting API Reference** (Pages 48–53)

Symbolic System Names
The most user-friendly form of connection string addresses an SAP system only by its symbolic name (per 
convention, the system id) and the logon group name. This information is marked with the prefixes '/R/' (for 
the symbolic SAP system name) and '/G/' (for the logon group name).
 Example
Example with SAP system (ALR) and logon group (SPACE):
/R/ALR/G/SPACE
Connection strings with symbolic system names are resolved by SAP GUI by looking up the symbolic SAP 
system name in the Message Server List (a text file containing a mapping between symbolic system names 
and message server addresses) and replacing the /R/ part of the connection string with the resulting 
message server address.
The result is a complete message server connection string, which is then further resolved as explained 
above.
Formal Syntax
For the technically interested reader, the following BNF grammar formally describes the syntax of connection 
strings:
 Sample Code
<connection string> := [<router prefix>]<local> <local> := <simple>|<message server>|<symbolic>
<simple> := "/H/"<host>"/S/"<service>
<host> := <hostname>|<ipaddr>
<hostname> := (any DNS hostname)
<ipaddr> := (any IP address, in dotted decimal form)
<service> := <servicename>|<port number>
<servicename> := (any IP service name)
<port number> := (any decimal number)
<messageserver> := "/M/"<host>"/S/"<service>"/G/"<group>
<group> := (any ASCII string not containing '/')
<symbolic> := "/R/"<system>"/G/"<group>
<system> := (any ASCII string not containing '/')
<router prefix> := <router>*
<router> := "/H/"<host>"/S/"<service>["/P/"<password>]
<password> := (any ASCII string not containing '/') 
1.2.4  GuiBarChart Object 
48 PUBLIC
SAP GUI Scripting API
SAP GUI Scripting API

Description
The GuiBarChart is a powerful tool to display and modify time scale diagrams.
The object is of a very technical nature. It should only be used for recording and playback, as most of the 
parameters cannot be determined in any other way. GuiBarChart extends the GuiShell Object [page 207].
Example
Methods
Method
Syntax Description
All methods of the GuiVComponent Object [page 281]:
• DumpState
• SetFocus
• Visualize
SAP GUI Scripting API

Method
Syntax Description
All methods of the GuiContainer Object [page 87]:
• FindById
All methods of the GuiVContainer Object [page 286]:
• FindAllByName
• FindAllByNameEx
• FindByName
• FindByNameEx
All methods of the GuiShell Object [page 207]:
• SelectContextMenuItem
• SelectContextMenuItemByPosition
• SelectContextMenuItemByText
BarCount
Public Function BarCount( _    ByVal chartId As Long _ ) As Long
Returns the number of bars in the given chart.
GetBarContent
Public Function GetBarContent( _    ByVal chartId As Long, _
   ByVal barId As Long, _
   ByVal textId As Long _ ) As String
Returns the content of the bar.
GetGridLineContent
Public Function GetGridLineContent( _    ByVal chartId As Long, _
   ByVal gridlineId As Long, _
   ByVal textId As Long _ ) As String
Returns the content of the grid line.
GridCount
Public Function GridCount( _    ByVal chartId As Long _ ) As Long
Returns the number of grids within the chart.
LinkCount
Public Function LinkCount( _    ByVal chartId As Long _ ) As Long
Returns the number of links within the given chart.
50 PUBLIC
SAP GUI Scripting API
SAP GUI Scripting API

Method
Syntax Description
SendData
Public Sub SendData( _     ByVal Data As String _  )
Send data to the server.
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
SAP GUI Scripting API

Property
Syntax Description
All properties of the GuiVComponent Object [page 281]:
• AccLabelCollection
• AccText
• AccTextOnRequest
• AccT ooltip
• Changeable
• DefaultT ooltip
• Height
• IconName
• IsSymbolFont
• Left
• Modified
• ParentFrame
• ScreenLeft
• ScreenT op
• Text
• T ooltip
• T op
• Width
All properties of the GuiContainer Object [page 87]:
• Children
All properties of the GuiShell Object [page 207]:
• AccDescription
• DragDropSupported
• Handle
• OcxEvents
• SubType
ChartCount (Read-only)
Public Property ChartCount As Long
Number of charts.
52 PUBLIC
SAP GUI Scripting API
SAP GUI Scripting API
