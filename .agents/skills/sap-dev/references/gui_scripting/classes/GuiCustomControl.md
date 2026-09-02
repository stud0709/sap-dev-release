# GuiCustomControl (Class)

> **Official SAP GUI Scripting API Reference** (Pages 92–95)

Property
Syntax Description
All properties of the GuiTextField [page 250] with one exception: Property IsListElement in not available for this object 
since F4 help is not available for input fields within ABAP lists!
• CaretPosition
• DisplayedText
• Highlighted
• HistoryCurEntry
• HistoryCurIndex
• HistoryIsActive
• HistoryList
• IsHotspot
• IsLeftLabel
• IsOField
• IsRightLabel
• LeftLabel
• MaxLength
• Numerical
• Required
• RightLabel
1.2.21  GuiCustomControl Object 
Description
The GuiCustomControl is a wrapper object that is used to place ActiveX controls onto dynpro screens. While 
GuiCustomControl is a dynpro element itself, its children are of GuiContainerShell type, which is a container for 
controls. GuiCustomControl extends the GuiVContainer Object [page 286]. The type prefix is cntl, the name is 
the fieldname taken from the SAP data dictionary.
92 PUBLIC
SAP GUI Scripting API
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
CharHeight (Read-only)
Public Property CharHeight As Long
Height of the GuiCustomControl in character metric.
CharLeft (Read-only)
Public Property CharLeft As Long
Left coordinate of the GuiCustomControl in character met­
ric.
CharTop (Read-only)
Public Property CharTop As Long
T op coordinate of the GuiCustomControl in character metric.
CharWidth (Read-only)
Public Property CharWidth As Long
Width of the GuiCustomControl in character metric.
94 PUBLIC
SAP GUI Scripting API
SAP GUI Scripting API
