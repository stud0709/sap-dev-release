# GuiOfficeIntegration (Class)

> **Official SAP GUI Scripting API Reference** (Pages 169–172)

1.2.41  GuiOfficeIntegration Object
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
All additional methods of the GuiShell Object [page 207]:
• SelectContextMenuItem
• SelectContextMenuItemByPosition
• SelectContextMenuItemByText
AppendRow
Public Sub AppendRow( _     ByVal Name As String, _
    ByVal Row As
    String _  )
This function appends a new row to a table specified by the 
parameter name in the table collection. The parameter row 
is the base64 representation of the binary row.
CloseDocument
Public Sub CloseDocument( _     ByVal Cookie As Long, _
    ByVal EverChanged As Byte, _
    ByVal ChangedAfterSave As
    Byte _  )
This function sends the close event of the document speci­
fied by the parameter cookie to the server.
SAP GUI Scripting API

Method
Syntax Description
CustomEvent
Public Sub CustomEvent( _     ByVal Cookie As Long, _
    ByVal EventName As String, _
    ByVal ParamCount As Long, _
    Optional ByVal Par1 As Variant, _
    Optional ByVal Par2 As Variant, _
    Optional ByVal Par3 As Variant, _
    Optional ByVal Par4 As Variant, _
    Optional ByVal Par5 As Variant, _
    Optional ByVal Par6 As Variant, _
    Optional ByVal Par7 As Variant, _
    Optional ByVal Par8 As Variant, _
    Optional ByVal Par9 As Variant, _
    Optional ByVal Par10 As Variant, _
    Optional ByVal Par11 As Variant, _
    Optional ByVal Par12 As Variant _  )
This function sends the custom event eventName to the 
server. The document specified by the parameter cookie is 
the source.
RemoveContent
Public Sub RemoveContent( _     ByVal Name As String _  )
This function removes the content of a table in the table 
collection. The parameter name is the name of the table.
SaveDocument
Public Sub SaveDocument( _     ByVal Cookie As Long, _
    ByVal Changed As Byte _  )
This function sends the save event of the document speci­
fied by the parameter cookie to the server.
SetDocument
Public Sub SetDocument( _     ByVal Index As Long, _
    ByVal Document As String _  )
This function replaces or adds a new document with the 
specified index. The parameter document is the base64-rep­
resentation of the binary document.
170 PUBLIC
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
