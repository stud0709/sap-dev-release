# GuiCTextField (Class)

> **Official SAP GUI Scripting API Reference** (Pages 90–92)

1.2.20  GuiCTextField Object
Description
If the cursor is set into a text field of type GuiCTextField a combo box button is displayed to the right of the text 
field. Pressing this button is equivalent to pressing the F4 key. The button is not represented in the scripting 
object model as a separate object; it is considered to be part of the text field.
There are no other differences between GuiTextField and GuiCTextField. GuiCTextField extends the GuiTextField 
[page 250]. The type prefix is ctxt, the name is the Fieldname taken from the SAP data dictionary.
Example
This is an example of GuiCTextField type text field, where the upper field has the focus. Please note that the 
button is only displayed when the corresponding input field has the focus unless the ABAP application has 
defined the button to be shown permanently.
Methods
Method
Syntax Description
All methods of the GuiVComponent Object [page 281]:
• DumpState
• SetFocus
• Visualize
90 PUBLIC
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
SAP GUI Scripting API
