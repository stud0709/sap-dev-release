# GuiMenu (Class)

> **Official SAP GUI Scripting API Reference** (Pages 157–158)

1.2.36  GuiMenu Object
Description
A GuiMenu may have other GuiMenu objects as children. GuiMenu extends the GuiVContainer Object [page 
286]. The type prefix is menu, the name is the text of the menu item. If the item does not have a text, which is 
the case for separators, then the name is the last part of the id, menu[n].
Methods
Method
Syntax Description
The following methods of the GuiVComponent Object [page 281] (SetFocus is not supported):
• DumpState
• Visualize
All methods of the GuiContainer Object [page 87]:
• FindById
All methods of the GuiVContainer Object [page 286]:
• FindAllByName
• FindAllByNameEx
• FindByName
• FindByNameEx
Select
Public Sub Select() 
Select the menu.
SAP GUI Scripting API
