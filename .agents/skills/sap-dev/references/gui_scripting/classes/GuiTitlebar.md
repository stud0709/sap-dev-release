# GuiTitlebar (Class)

> **Official SAP GUI Scripting API Reference** (Pages 254–256)

Property
Syntax Description
RightLabel (Read-only)
Public Property RightLabel As 
GuiVComponent
This label has been defined in ABAP Screen Painter to be the 
right label of the control.
1.2.66  GuiTitlebar Object 
Description
The titlebar is only displayed and exposed as a separate object in New Visual Design mode. GuiTitlebar extends 
the GuiVContainer Object [page 286]. The type prefix and name of GuiTitlebar are titl.
Remarks
In some transactions the titlebar may contain objects of GuiGosShell type.
Methods
Method
Syntax Description
All methods of the GuiVComponent Object [page 281]:
• DumpState
• SetFocus
• Visualize
All methods of the GuiContainer Object [page 87]:
• FindById
254 PUBLIC
SAP GUI Scripting API
SAP GUI Scripting API

Method
Syntax Description
All additional methods of the GuiVContainer Object [page 286]:
• FindAllByName
• FindAllByNameEx
• FindByName
• FindByNameEx
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
The following properties of the GuiVComponent Object [page 281] (some properties are not supported, because most of 
the properties of GuiTitlebar cannot be influenced by ABAP applications):
• DefaultT ooltip
• Height
• Left
• ScreenLeft
• ScreenT op
• Text
• T ooltip
• T op
• Width
All properties of the GuiContainer Object [page 87]:
• Children
SAP GUI Scripting API
