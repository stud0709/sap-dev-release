# GuiCalendar (Class)

> **Official SAP GUI Scripting API Reference** (Pages 57–63)

1.2.7  GuiCalendar Object 
Description
The calendar control can be used to select single dates or periods of time. GuiCalendar extends the GuiShell 
Object [page 207].
Example
SAP GUI Scripting API

Methods
Method
Syntax Description
All methods of the GuiVComponent Object [page 281]:
• DumpState
• SetFocus
• Visualize
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
ContextMenu
Public Sub ContextMenu( _     ByVal CtxMenuId As Long, _
    ByVal CtxMenuCellRow As Long, _
    ByVal CtxMenuCellCol As Long, _
    ByVal DateBegin As String, _
    ByVal DateEnd As String _  )
Calling this function opens a context menu.
Parameter CtxMenuId indicates the cell type of the cell in 
which the context menu was opened:
Value Cell Type Description
0 Date Invocation on a 
cell with a single 
date
1 Weekday Weekday Invoca­
tion on a button 
for a certain day 
of the week
2 Week Invocation on a 
button for a spe­
cific week
58 PUBLIC
SAP GUI Scripting API
SAP GUI Scripting API

Method
Syntax Description
CreateDate
Public Function CreateDate( _    ByVal day As Long, _
   ByVal month As Long, _
   ByVal year As Long _ ) As String
Creates a date string in format “YYYYMMDD” out of the pa­
rameters. This is the format expected by a number of other 
methods available in GuiCalendar.
GetColor
Public Function GetColor( _    ByVal from As String _ ) As Long
Returns the color code (from 0-9) of the date cell specified 
as parameter (in format “YYYYMMDD”) as Integer. If no 
semantic colors are used in the concrete cell, the method 
returns “0” .
GetColorInfo
Public Function GetColorInfo( _    ByVal Color As Long _ ) As String
Returns the explanation defined by the application for se­
mantic colors used in the GuiCalendar (starting with index 
0).
GetDateTooltip
Public Function GetDateTooltip( _    ByVal date As String _ ) As String
Returns the tooltip text of the date specified as parameter 
(in format “YYYYMMDD”).
GetDay
Public Function GetDay( _    ByVal date As String _ ) As Long
Returns the day of the date specified as parameter (in for­
mat “YYYYMMDD”).
GetMonth
Public Function GetMonth( _    ByVal date As String _ ) As Long
Returns the month of the date specified as parameter (in 
format “YYYYMMDD”).
GetWeekday
Public Function GetWeekday( _    ByVal date As String _ ) As String
Returns the week day of the date specified as parameter (in 
format “YYYYMMDD”).
GetWeekNumber
Public Function GetWeekNumber( _    ByVal date As String _ ) As Long
Returns the week number of the date specified as parameter 
(in format “YYYYMMDD”).
SAP GUI Scripting API

Method
Syntax Description
GetYear
Public Function GetYear( _    ByVal date As String _ ) As Long
Returns the year of the date specified as parameter (in for­
mat “YYYYMMDD”).
IsWeekend
Public Function IsWeekend( _    ByVal date As String _ ) As Long
Returns T rue if the date specified by the parameter is at a 
weekend.
SelectMonth
Public Sub SelectMonth( _     ByVal month As Long, _
    ByVal year     As Long _ )
Selects the month specified by the parameters (starting with 
index 1).
SelectRange
Public Sub SelectRange( _     ByVal from As String, _
    ByVal to As
    String _  )
Selects the range specified by the parameters (in format 
“YYYYMMDD”).
SelectWeek
Public Sub SelectWeek( _     ByVal week As Long, _
    ByVal year
    As Long _  )
Selects the week specified by the parameters (starting with 
index 0).
60 PUBLIC
SAP GUI Scripting API
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
SAP GUI Scripting API

Property
Syntax Description
All properties of the GuiShell Object [page 207]:
• AccDescription
• DragDropSupported
• Handle
• OcxEvents
• SubType
endSelection (Read-only)
Public Property endSelection As String
The last day of the selected date range (in format 
“YYYYMMDD”).
FirstVisibleDate (Read-write)
Public Property FirstVisibleDate As 
String
This is the earliest date visible in the calendar control. In the 
example above the value would be “20171225” .
FocusDate (Read-write)
Public Property FocusDate As String
The currently focused date (identified by the focus border; 
see picture above) in the calendar control is available in the 
format “YYYYMMDD” . In this example it is “20180130” .
FocusedElement (Read-only)
Public Property FocusedElement As Long
This property indicates which part of a composite GuiCalen­
dar control currently has focus. The following values are pos­
sible:
• 0 - "InputField": The input field (picker) to manually 
enter a date currently has focus
• 1 - "Button": The push button to open the navigator 
pane currently has focus
• 2 - "Navigator": The popup navigator pane is open and 
currently has focus
 Note
This property is available as of SAP GUI for Windows 
7 .50 patchlevel 8 and SAP GUI for Windows 7 .60.
horizontal (Read-only)
Public Property horizontal As Long
This property contains T rue if the GuiCalendar has a horizon­
tal orientation, else it contains False.
LastVisibleDate (Read-write)
Public Property LastVisibleDate As 
String
The last date that is currently displayed by the GuiCalendar 
(in format “YYYYMMDD”).
62 PUBLIC
SAP GUI Scripting API
SAP GUI Scripting API
