# GuiDialogShell (Class)

> **Official SAP GUI Scripting API Reference** (Pages 95–97)

1.2.22  GuiDialogShell Object
Description
The GuiDialogShell is an external window that is used as a container for other shells, for example a toolbar. 
GuiDialogShell extends the GuiVContainer Object [page 286]. The type prefix is shellcont, the name is the last 
part of the id, shellcont[n].
Example
Methods
Method
Syntax Description
All methods of the GuiVComponent Object [page 281]:
• DumpState
• SetFocus
• Visualize
All methods of the GuiContainer Object [page 87]:
• FindById
All additional methods of the GuiVContainer Object [page 286]:
• FindAllByName
• FindAllByNameEx
• FindByName
• FindByNameEx
SAP GUI Scripting API

Method
Syntax Description
Close
Public Sub Close()
This method closes the external window.
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
96 PUBLIC
SAP GUI Scripting API
SAP GUI Scripting API
