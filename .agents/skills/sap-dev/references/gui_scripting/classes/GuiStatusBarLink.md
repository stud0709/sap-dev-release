# GuiStatusBarLink (Class)

> **Official SAP GUI Scripting API Reference** (Pages 227–228)

1.2.57  GuiStatusBarLink
GuiStatusbarLink represents a so-called service request link that can optionally be displayed in the 
GuiStatusBar by an application. Clicking such a link executes an application specific action, like launching 
a transaction for reporting a functional issue.
If present, the parent of the GuiStatusbarLink object is the first pane (pane[0]) of the status bar (see also 
GuiStatusbar Object [page 222] and GuiStatusPane Object [page 228]).
Methods
Method
Syntax Description
All methods of the GuiVComponent Object [page 281]:
• DumpState
• SetFocus
• Visualize
Press This emulates manually clicking the Service Request Link 
which triggers the application specific action and causes 
server communication to occur.
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
