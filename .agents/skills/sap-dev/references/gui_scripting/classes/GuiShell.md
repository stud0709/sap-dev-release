# GuiShell (Class)

> **Official SAP GUI Scripting API Reference** (Pages 207–210)

1.2.51  GuiShell Object
Description
GuiShell is an abstract object whose interface is supported by all the controls. GuiShell extends the 
GuiVContainer Object [page 286]. The type prefix is shell, the name is the last part of the id, shell[n].
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
SelectContextMenuItem
Public Sub SelectContextMenuItem( _     ByVal FunctionCode As String _     )
Select an item from the control’s context menu.
SelectContextMenuItemByPosition
Public Sub 
SelectContextMenuItemByPosition( _     ByVal PositionDesc As String _ )
This method allows you to select a context menu item using 
the position of the item. It is therefore independent of the 
menu item text.
SAP GUI Scripting API

Method
Syntax Description
SelectContextMenuItemByText
Public Sub 
SelectContextMenuItemByText( _     ByVal Text As String _  )
Select a menu item of a context menu using the text of the 
item and possible higher level menus.
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
208 PUBLIC
SAP GUI Scripting API
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
All additional properties of the GuiContainer Object [page 87]:
• Children
AccDescription (Read-only)
Public Property AccDescription As 
String
Accessibility description of the shell. This description can be 
used for shells that do not have a title element.
DragDropSupported (Read-only)
Public Property DragDropSupported As 
Byte
This property is T rue if the shell allows drag and drop opera­
tions.
Handle (Read-only)
Public Property Handle As Long
The window handle of the control that is connected to the 
GuiShell.
OcxEvents (Read-only)
Public Property OcxEvents As 
GuiCollection
Returns a collection containing the event ids of the ActiveX 
control. These are the events that the control may send to 
the server.
SAP GUI Scripting API
