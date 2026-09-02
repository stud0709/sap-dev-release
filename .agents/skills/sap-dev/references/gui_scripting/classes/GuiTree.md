# GuiTree (Class)

> **Official SAP GUI Scripting API Reference** (Pages 263–276)

1.2.69  GuiTree Object
Example
The Tree Control supports three tree types:
• Simple Tree
• List Tree
• without header
• with header
• Column Tree
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
All methods of the GuiVContainer Object [page 286]:
• FindAllByName
• FindAllByNameEx
• FindByName
• FindByNameEx
All methods of the GuiShell Object [page 207]:
• SelectContextMenuItem
• SelectContextMenuItemByPosition
• SelectContextMenuItemByText
ChangeCheckbox
Public Sub ChangeCheckbox( _     ByVal NodeKey As String, _
    ByVal ItemName As String, _
    ByVal Checked As Boolean _  )
This method emulates changing a checkbox state.
264 PUBLIC
SAP GUI Scripting API
SAP GUI Scripting API

Method
Syntax Description
ClickLink
Public Sub ClickLink( _     ByVal NodeKey As String, _
    ByVal ItemName As String _  )
This function emulates triggering a link.
CollapseNode
Public Sub CollapseNode( _     ByVal NodeKey As String _  )
This function closes the node with the key nodeKey.
DefaultContextMenu
Public Sub DefaultContextMenu()
This method requests a context menu for the whole Tree 
Control.
DoubleClickItem
Public Sub DoubleClickItem( _     ByVal NodeKey As String, _
    ByVal ItemName As String _  )
This function emulates double-clicking on a text item.
DoubleClickNode
Public Sub DoubleClickNode( _      ByVal NodeKey As String _ )
This function emulates double-clicking a node.
EnsureVisibleHorizontalItem
Public Sub 
EnsureVisibleHorizontalItem( _     ByVal NodeKey As String, _
    ByVal ItemName As String _  )
This function scrolls the Tree horizontally until the Item is 
visible.
ExpandNode
Public Sub ExpandNode( _     ByVal NodeKey As String _  )
This function expands the node with the key nodeKey.
FindNodeKeyByPath
Public Function FindNodeKeyByPath( _    ByVal Path As String _ ) As String
SAP GUI Scripting API

Method
Syntax Description
GetAbapImage
Public Function GetAbapImage( _    ByVal Key As String, _
   ByVal Name As String _ ) As String
Retrieves the icon code of an image displayed in the speci­
fied item (for example “01”).
GetAllNodeKeys
Public Function GetAllNodeKeys() As 
Object
Returns a GuiCollection that contains all node keys present 
in the Tree Control.
GetCheckBoxState
Public Function GetCheckBoxState( _    ByVal NodeKey As String, _
   ByVal ItemName As String _ ) As Byte
Retrieves the CheckBox state (1 = Checked, 0 = Unchecked).
GetColumnCol
Public Function GetColumnCol( _    ByVal colName As String _ ) As Object
The keys of all the items in the given column.
GetColumnHeaders
Public Function GetColumnHeaders() As 
Object
Collection of the titles of the columns.
GetColumnIndexFromName
Public Function 
GetColumnIndexFromName( _    ByVal Key As String _ ) As Long
Returns the column index (starting with 1) of the column 
specified by the parameter.
GetColumnNames
Public Function GetColumnNames() As 
Object
Returns a collection of the column names.
GetColumnTitleFromName
Public Function 
GetColumnTitleFromName( _    ByVal Key As String _ ) As String
Returns the column title of the column specified by the pa­
rameter.
266 PUBLIC
SAP GUI Scripting API
SAP GUI Scripting API

Method
Syntax Description
GetColumnTitles
Public Function GetColumnTitles() As 
Object
Returns a GuiCollection that contains the column titles of all 
columns present in the Tree Control in their respective order.
Prerequisite: The Tree Control is a Column Tree Control.
GetFocusedNodeKey
Public Function GetFocusedNodeKey() 
As String
Returns the key of the node that has focus.
GetHierarchyLevel
Public Function GetHierarchyLevel( _    ByVal Key As String _ ) As Long
Returns the hierarchy level of the specified key starting on 
level 0.
GetHierarchyTitle
Public Function GetHierarchyTitle() 
As String
GetIsDisabled
Public Function GetIsDisabled( _    ByVal NodeKey As String, _
   ByVal ItemName As String _ ) As Byte
GetIsEditable
Public Function GetIsEditable( _    ByVal NodeKey As String, _
   ByVal ItemName As String _
) As Byte 
Retrieves the status of the element in the cell (for example a 
checkbox) as a boolean value.
GetIsHighLighted
Public Function GetIsHighLighted( _    ByVal NodeKey As String, _
   ByVal ItemName As String _ ) As Byte
If the respective item in a List Tree is displayed highlighted 
(intensified), this method returns true, else false.
GetItemHeight
Public Function GetItemHeight( _    ByVal NodeKey As String, _
   ByVal ItemName As String _ ) As Long
Retrieves the height of the specified item in pixels.
SAP GUI Scripting API

Method
Syntax Description
GetItemLeft
Public Function GetItemLeft( _    ByVal NodeKey As String, _
   ByVal ItemName As String _ ) As Long
Retrieves the left position of the specified item in pixels.
GetItemStyle
Public Function GetItemStyle( _    ByVal NodeKey As String, _
   ByVal ItemName As String _ ) As Long
Retrieves the index of the style assigned to the specified 
item.
GetItemText
Public Function GetItemText( _    ByVal Key As String, _
   ByVal Name As String _ ) As String
This function returns the text of the item specified by the key 
and name parameters.
GetItemTextColor
Public Function GetItemTextColor( _    ByVal Key As String, _
   ByVal Name As String _ ) As ULong
Retrieves the font color of the specified item.
GetItemToolTip
Public Function GetItemToolTip( _    ByVal Key As String, _
   ByVal Name As String _ ) As String
Retrieves the tooltip of the specified item.
GetItemTop
Public Function GetItemTop( _    ByVal NodeKey As String, _
   ByVal ItemName As String _ ) As Long
Retrieves the top position of the specified item in pixels.
GetItemType
Public Function GetItemType( _    ByVal Key As String, _
   ByVal Name As String _ ) As Long
Retrieves the column tree item type:
• trvTreeStructureHierarchy = 0
• trvTreeStructureImage = 1
• trvTreeStructureText = 2
• trvTreeStructureBool = 3
• trvTreeStructureButton = 4
• trvTreeStructureLink = 5
268 PUBLIC
SAP GUI Scripting API
SAP GUI Scripting API

Method
Syntax Description
GetItemWidth
Public Function GetItemWidth( _    ByVal NodeKey As String, _
   ByVal ItemName As String _ ) As Long
Retrieves the width of the specified item in pixels.
GetListTreeNodeItemCount
Public Function 
GetListTreeNodeItemCount( _    ByVal NodeKey As String _ ) As Long
Returns the number of visible items of the specified node for 
a list tree.
GetNextNodeKey
Public Function GetNextNodeKey( _    ByVal NodeKey As String _ ) As String
Returns the key of the next node belonging to the same node 
one level above.
GetNodeAbapImage
Public Function GetNodeAbapImage( _    ByVal Key As String _ ) As String
Retrieves the icon code of an image displayed in the speci­
fied node (for example “01”).
 Note
The default folder icon is returned as the blank value.
GetNodeChildrenCount
Public Function 
GetNodeChildrenCount( _    ByVal Key As String _ ) As Long
Returns the number of visible direct children of the specified 
node.
GetNodeChildrenCountByPath
Public Function 
GetNodeChildrenCountByPath( _    ByVal Path As String _ ) As Long
This function returns the number of visible children of the 
node given by the path parameter.
GetNodeHeight
Public Function GetNodeHeight( _    ByVal Key As String _ ) As Long
Returns the height of the specified node in pixels.
GetNodeIndex
Public Function GetNodeIndex( _    ByVal Key As String _ ) As Long
Returns the index of the specified key within its node.
SAP GUI Scripting API

Method
Syntax Description
GetNodeItemHeaders
Public Function GetNodeItemHeaders( _    ByVal NodeKey As String _ ) As Object
This method can only be used on trees of type 2 (Column 
Tree).
It returns a collection of the texts belonging to the subnodes 
of the specified node in the hierarchy header column.
GetNodeKeyByPath
Public Function GetNodeKeyByPath( _    ByVal Path As String _ ) As String
Key of the node specified by the given path description.
GetNodeLeft
Public Function GetNodeLeft( _    ByVal Key As String _ ) As Long
Returns the left position of the specified node in pixels.
GetNodePathByKey
Public Function GetNodePathByKey( _    ByVal Key As String _ ) As String
Given a node key, the path is retrieved (e.g. 2\1\2).
GetNodesCol
Public Function GetNodesCol() As 
Object
The collection contains the node keys of all the nodes in the 
tree.
GetNodeStyle
Public Function GetNodeStyle( _    ByVal NodeKey As String _ ) As Long
Retrieves the index of the style assigned to the specified 
node.
GetNodeTextByKey
Public Function GetNodeTextByKey( _    ByVal Path As String _ ) As String
This function returns the text of the node specified by the 
given key.
GetNodeTextByPath
Public Function GetNodeTextByPath( _    ByVal Path As String _ ) As String
The text of a node defined by the given path is returned.
GetNodeTextColor
Public Function GetNodeTextColor( _    ByVal Key As String _ ) As ULong
Returns the font color of the specified node.
270 PUBLIC
SAP GUI Scripting API
SAP GUI Scripting API

Method
Syntax Description
GetNodeToolTip
Public Function GetNodeToolTip( _    ByVal NodeKey As String _ ) As String
Returns the tooltip of the specified node.
GetNodeTop
Public Function GetNodeTop( _    ByVal Key As String _ ) As Long
Returns the top position of the specified node in pixels.
GetNodeWidth
Public Function GetNodeWidth( _    ByVal Key As String _ ) As Long
Returns the width of the specified node in pixels.
GetParent
Public Function GetParent( _    ByVal CKey As String _ ) As String
Key of the parent node of the node specified by the given 
key.
GetPreviousNodeKey
Public Function GetPreviousNodeKey( _    ByVal NodeKey As String _ ) As String
Returns the key of the previous node belonging to the same 
node one level above.
GetSelectedNodes
Public Function GetSelectedNodes() As 
Object
Returns a GuiCollection that contains the node keys of all 
selected nodes.
GetSelectionMode
Public Function GetSelectionMode() As 
Integer
The selection behaviour of a Tree Control instance is set 
once at the time of creation.
Return Type
• 0: Single Node
• 1: Multiple Node
• 2: Single Item
• 3: Multiple Item
GetStyleDescription
Public Function GetStyleDescription( _    ByVal nStyle As Long _ ) As String
Retrieves the description of the style specified by parameter 
as a string.
SAP GUI Scripting API

Method
Syntax Description
GetSubNodesCol
Public Function GetSubNodesCol( _    ByVal NodeKey As String _ ) As Object
Collection of the keys of all subnodes of the node specified 
by the given key.
GetTreeType
Public Function GetTreeType() As Long
The returned number has the following meaning:
• 0 : Simple tree
• 1 : List tree
• 2 : Column tree
HeaderContextMenu
Public Sub HeaderContextMenu( _      ByVal HeaderName As String _ )
This method requests a context menu for a header.
IsFolder
Public Function IsFolder( _    ByVal NodeKey As String _ ) As Byte 
Returns T rue if the specified object is a node and not a leaf.
IsFolderExpandable
Public Function IsFolderExpandable( _    ByVal NodeKey As String _ ) As Byte
Returns T rue if
• the node has children OR
• the tree control is using load on de­
mand AND the ABAP application has de­
fined the NODE_SET_EXPANDER flag (method 
CL_TREE_CONTROL_BASE=>NODE_SET_EXPANDER)
See also SAP Note 3321283
 .
IsFolderExpanded
Public Function IsFolderExpanded( _    ByVal NodeKey As String _ ) As Byte
Returns T rue if the folder belonging to the specified node is 
expanded.
ItemContextMenu
Public Sub ItemContextMenu( _     ByVal NodeKey As String, _
    ByVal ItemName As String _  )
This method requests a context menu for an item.
NodeContextMenu
Public Sub NodeContextMenu( _     ByVal NodeKey As String _  )
This method requests a context menu for a node.
272 PUBLIC
SAP GUI Scripting API
SAP GUI Scripting API

Method
Syntax Description
PressButton
Public Sub PressButton( _     ByVal NodeKey As String, _
    ByVal ItemName As String _  )
This method emulates pressing a button.
PressHeader
Public Sub PressHeader( _     ByVal HeaderName As String _  )
This method emulates clicking a header.
PressKey
Public Sub PressKey( _     ByVal Key As String _  )
This method emulates pressing a key.
SelectColumn
Public Sub SelectColumn( _     ByVal ColumnName As String _  )
This function adds a column to the column selection. A node 
or item selection is removed.
SelectedItemColumn
Public Function SelectedItemColumn() 
As String
The name of the column of the selected item.
SelectedItemNode
Public Function SelectedItemNode() As 
String
The node key of the selected item.
SelectItem
Public Sub SelectItem( _     ByVal NodeKey As String, _
    ByVal ItemName As String _  )
This function emulates the selection of an item. This selec­
tion removes all other selections.
SelectNode
Public Sub SelectNode( _     ByVal NodeKey As String _  )
The node with the key nodeKey is added to the Node Selec­
tion.
SAP GUI Scripting API

Method
Syntax Description
SetCheckBoxState
Public Sub SetCheckBoxState( _     ByVal NodeKey As String, _
    ByVal ItemName As String, _
    ByVal state As Long _  )
This method checks or unchecks the checkbox in the speci­
fied cell of the tree control (if parameter "state" equals 0 
the checkbox is unchecked, if the parameter equals 1 the 
checkbox is checked.
SetColumnWidth
Public Sub SetColumnWidth( _    ByVal ColumnName As String, _
   ByVal Width As Long _ ) 
This function sets the width of a column in pixels.
UnselectAll
Public Sub UnselectAll()
All selections are removed.
UnselectColumn
Public Sub UnselectColumn( _     ByVal ColumnName As String _  )
This function removes a column from the column selection.
UnselectNode
Public Sub UnselectNode( _     ByVal NodeKey As String _  )
The node with the key nodeKey is removed from the Node 
Selection.
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
274 PUBLIC
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
All additional properties of the GuiShell Object [page 207]:
• AccDescription
• DragDropSupported
• Handle
• OcxEvents
• SubType
SAP GUI Scripting API
