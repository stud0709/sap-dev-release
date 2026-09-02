# GuiModalWindow (Class)

> **Official SAP GUI Scripting API Reference** (Pages 163–166)

1.2.39  GuiModalWindow Object
Description
A GuiModalWindow is a dialog pop-up.
GuiModalWindow extends the GuiFrameWindow Object [page 105].
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
SAP GUI Scripting API

Method
Syntax Description
All methods of the GuiFrameWindow Object [page 105]:
• Close
• CompBitmap
• HardCopy
• HardCopyT oMemory
• Iconify
• IsVKeyAllowed
• JumpBackward
• JumpForward
• Maximize
• Restore
• SendVKey
• ShowMessageBox
• TabBackward
• TabForward
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
164 PUBLIC
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
All properties of the GuiContainer Object [page 87]:
• Children
All properties of the GuiFrameWindow Object [page 105]:
• ElementVisualizationMode
• GuiFocus
• Handle
• Iconic
• SystemFocus
• WorkingPaneHeight
• WorkingPaneWidth
IsPopupDialog (Read-write)
Public Property IsPopupDialog() As 
Boolean
Some modal windows represent popup dialogs. In this case 
the IsPopupDialog property is T rue. Popup dialogs are identi­
fied by checking the ABAP source name and dynpro number. 
Currently the following are supported:
• SAPLSPO1 / 500 (Function module Popup_T o_Confirm)
SAP GUI Scripting API
