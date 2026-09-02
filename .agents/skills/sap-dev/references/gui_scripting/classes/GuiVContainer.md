# GuiVContainer (Class)

> **Official SAP GUI Scripting API Reference** (Pages 286–288)

1.2.73  GuiVContainer Object 
Description
An object exposes the GuiVContainer interface if it is both visible and can have children. It will then also 
expose GuiComponent and GuiVComponent. Examples of this interface are windows and subscreens, toolbars 
or controls having children, such as the splitter control. GuiVContainer extends the GuiContainer Object [page 
87] and the GuiVComponent Object [page 281].
Methods
Method
Syntax Description
All methods of the GuiVComponent Object [page 281]:
• DumpState
• SetFocus
• Visualize
All methods of the GuiContainer Object [page 87]:
• FindById
FindAllByName
Public Function FindAllByName( _    ByVal Name As String, _
   ByVal Type As String _ ) As GuiComponentCollection
The methods FindByName and FindByNameEx return 
only the first object with matching name and type. There 
may however be several matching objects, which will be re­
turned as members of a collection when FindAllByName 
or FindAllByNameEx are used.
FindAllByNameEx
Public Function FindAllByNameEx( _    ByVal Name As String, _
   ByVal Type As Long _ ) As GuiComponentCollection
The methods FindByName and FindByNameEx return 
only the first object with matching name and type. There 
may however be several matching objects, which will be re­
turned as members of a collection when FindAllByName 
or FindAllByNameEx are used.
This method works exactly like FindAllByName, but 
takes the type parameter with data type long coming from 
the GuiComponentType enumeration. See also GuiCompo­
nentType [page 297].
286 PUBLIC
SAP GUI Scripting API
SAP GUI Scripting API

Method
Syntax Description
FindByName
Public Function FindByName( _    ByVal Name As String, _
   ByVal Type As String _ ) As GuiComponent
Unlike FindById, this function does not guarantee a 
unique result. It will simply return the first descendant 
matching both the name and type parameters. This is a 
more natural description of the object than the complex id, 
but it only makes sense on dynpro objects as most other 
objects do not have a meaningful name. If no descendant 
with matching name and type can be found, the function 
raises an exception.
FindByNameEx
Public Function FindByNameEx( _    ByVal Name As String, _
   ByVal Type As Long _ ) As GuiComponent
This method works exactly like FindByName, but takes 
the type parameter with data type long coming from the Gui­
ComponentType enumeration. See also GuiComponentType 
[page 297].
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
