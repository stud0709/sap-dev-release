# GuiContainer (Class)

> **Official SAP GUI Scripting API Reference** (Pages 87–88)

1.2.18  GuiContainer Object 
Description
This interface resembles GuiVContainer. The only difference is that it is not intended for visual objects but 
rather administrative objects such as connections or sessions. Objects exposing this interface will therefore 
support GuiComponent but not GuiVComponent. GuiContainer extends the GuiComponent Object [page 82].
Methods
Method
Syntax Description
FindById
Public Function FindById( _    ByVal Id As String, _
   Optional ByVal Raise As Variant _ ) As GuiComponent
Search through the object's descendants for a given id. If the 
parameter is a fully qualified id, the function will first check if 
the container object's id is a prefix of the id parameter. If that 
is the case, this prefix is truncated. If no descendant with the 
given id can be found the function raises an exception unless 
the optional parameter raise is set to False.
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
