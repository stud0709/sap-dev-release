# GuiEAIViewer2D (Class)

> **Official SAP GUI Scripting API Reference** (Pages 100–102)

1.2.24  GuiEAIViewer2D Object
Description
The GuiEAIViewer2D control is used to view 2-dimensional graphic images in the SAP system. The user can 
carry out redlining over the loaded image. The scripting wrapper for this control records all user actions during 
the redlining process and reproduces the same actions when the recorded script is replayed.
GuiEAIViewer2D extends the GuiShell Object [page 207].
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
annotationTextRequest
Public Sub annotationTextRequest( _     ByVal strText As String _  )
100 PUBLIC
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
