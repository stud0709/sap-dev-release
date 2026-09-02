# GuiToolbar (Class)

> **Official SAP GUI Scripting API Reference** (Pages 256–258)

1.2.67  GuiToolbar Object
Description
Every GuiFrameWindow has a GuiToolbar. The GuiMainWindow has two toolbars unless the second has been 
turned off by the ABAP application. In classical SAP GUI themes, the upper toolbar is called “system toolbar” 
or “GUI toolbar” , while the second toolbar is called “application toolbar” . In SAP GUI themes as of Belize and 
in integration scenarios (like embedded into SAP Business Client), only a single toolbar (“merged toolbar") 
is displayed. Additionally, a footer also containing buttons originally coming from the system or application 
toolbar may be displayed.
The merged toolbar contains elements from both the system and the application toolbar. However, the 
scripting IDs of all objects in the merged toolbar remain the same in order to ensure downwards compatibility 
of scripts. This means that in Belize theme there are children of both tbar[0] (system toolbar) and tbar[1] even 
though only a single toolbar is displayed. The buttons in the footer area of Belize and newer themes are also 
still children of the application toolbar and retain their scripting ids containing tbar[1].
The children of a GuiToolbar are buttons (GuiButton Object [page 54]) and the OKCode field (GuiOkCodeField 
Object [page 172]) unless it is hidden. When SAP Fiori features are turned on in Belize and newer themes, 
the application toolbar may also contain a ViewSwitch (GuiVHViewSwitch Object [page 288]). The indexes for 
toolbar buttons defined by the application are determined by the virtual key values defined for the button.
The indexes / names of specific buttons and elements are fixed:
Button/Element Index/Name
OKCode field okcd
Generates shortcut button 418
New GUI Window button 419
Button for collapsing the OKCode field 423
SAP GUI Options button 446
“More” button
(only available in Belize and newer SAP GUI themes)
btnvhmore
View Switch
(only available in Belize and newer SAP GUI themes when 
Fiori features are activated and the ABAP application has 
implemented a View Switch)
vhviewswitch
GuiToolbar extends the GuiVContainer Object [page 286].
The type prefix and name are tbar. tbar[0] is the system toolbar, while tbar[1] is the application toolbar.
The GuiToolbars can also be influenced by properties ButtonbarVisible and ToolbarVisible of the GuiApplication 
object.
256 PUBLIC
SAP GUI Scripting API
SAP GUI Scripting API

Buttons hidden in an overflow menu
When the SAP GUI window is not wide enough to display all buttons in a GuiToolbar or the application has 
decided that a button shall not be displayed by default, some buttons are moved into an overflow menu 
(depending on the theme this can also be a More button). For themes older than Belize, the SAP GUI Scripting 
object hierarchy always contained visible buttons and buttons in overflow menus. For themes as of Belize, the 
hidden buttons where originally not part of the object hierarchy. This changed as of SAP GUI for Windows 8.00 
patchlevel 2. Now these objects are part of the object hierarchy for all themes.
Since there is no “visible” property in the SAP GUI Scripting API, you can use the dimensions and positions to 
check whether a button is part of an overflow or not. If the button is not displayed on the screen, but is part of 
an overflow, the properties ScreenLeft, ScreenT op, Left, T op, Width and Height all have value 0.
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
