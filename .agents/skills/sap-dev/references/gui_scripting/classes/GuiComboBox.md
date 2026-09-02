# GuiComboBox (Class)

> **Official SAP GUI Scripting API Reference** (Pages 75–79)

Property
Syntax Description
All additional properties of the GuiShell Object [page 207]:
• AccDescription
• DragDropSupported
• Handle
• OcxEvents
• SubType
1.2.12  GuiComboBox Object 
Description
The GuiComboBox looks somewhat similar to GuiCTextField, but has a completely different implementation. 
While pressing the combo box button of a GuiCTextField will open a new dynpro or control in which a selection 
can be made, GuiComboBox retrieves all possible choices on initialization from the server, so the selection 
is done solely on the client. GuiComboBox extends the GuiVComponent Object [page 281]. The type prefix 
is cmb, the name is the fieldname taken from the SAP data dictionary. GuiComboBox inherits from the 
GuiVComponent Object [page 281].
Methods
Method
Syntax Description
All methods of the GuiVComponent Object [page 281]:
• DumpState
• SetFocus
• Visualize
SetKeySpace
Public Sub SetKeySpace()
This function sets the key property of the combo box to the 
space character. It was introduced for eCATT .
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
• T ooltip
• T op
• Width
CharHeight (Read-only)
Public Property CharHeight As Long
Height of the GuiComboBox in character metric.
CharLeft (Read-only)
Public Property CharLeft As Long
Left coordinate of the GuiComboBox in character metric.
CharTop (Read-only)
Public Property CharTop As Long
T op coordinate of the GuiComboBox in character metric.
76 PUBLIC
SAP GUI Scripting API
SAP GUI Scripting API

Property
Syntax Description
CharWidth (Read-only)
Public Property CharWidth As Long
Width of the GuiComboBox in character metric.
CurListBoxEntry (Read-only)
Public Property CurListBoxEntry As 
GuiComboBoxEntry
The currently focused entry of the dropdown list.
Entries (Read-only)
Public Property Entries() As 
GuiCollection
All members of this collection are of GuiComboBoxEntry 
type and have just the three properties, key and value, both 
of type String, and pos of type Long, see also GuiComboBox­
Entry Object [page 81]. The key data can be displayed in 
SAP GUI by setting the ‘Show keys… ’ options in SAP GUI 
options dialog.
In this example the first column contains the key property 
and the second column contains the value property.
Flushing (Read-only)
Public Property Flushing As Byte
Some components such as radio buttons, checkboxes or 
combo boxes may cause a round trip when their value is 
changed. If this is the case, the Flushing property is T rue.
Highlighted (Read-only)
Public Property Highlighted As Byte
This property is T rue if the Highlighted flag is set in the 
Screen Painter for the combo box.
IsLeftLabel (Read-only)
Public Property IsLeftLabel As Byte
This property is T rue if the combo box has the 'assign left' 
flag.
IsListBoxActive (Read-only)
Public Property IsListBoxActive As 
Byte
This property is T rue if the list box of the combo box is 
currently open.
SAP GUI Scripting API

Property
Syntax Description
IsRightLabel (Read-only)
Public Property IsRightLabel As Byte
This property is T rue if the combo box has the 'assign right' 
flag.
Key (Read-write)
Public Property Key As String
This is the key of the currently selected item. Y ou can change 
this item by setting the Key property to a new value.
LeftLabel (Read-only)
Public Property Modified As Byte
This label has been defined in ABAP Screen Painter to be the 
left label of the combo box.
Required (Read-only)
Public Property Required As Byte
If the required flag is set for a combo box then the empty 
entry is not selectable from the list.
RightLabel (Read-only)
Public Property RightLabel As 
GuiVComponent
This label has been defined in ABAP Screen Painter to be the 
right label of the combo box.
ShowKey (Read-only)
Public Property ShowKey As Byte
This property is True, if the ABAP application configured 
the combo box to always show both keys and values via 
setting the property Dropdown to Listbox with key in the 
screenpainter. This has nothing to do with the setting Show 
keys… in SAP GUI options dialog.
Text (Read-only)
Public Property Text As String
The value of this property contains the current text of the 
combobox.
 Note
As opposed to other UI elements, you cannot write this 
property, because the texts in the dropdown list are typ­
ically language-dependent. Therefore, you need to use 
the Key Property to change the selected item and with 
this the text of the combobox.
Value (Read-write)
Public Property Value As String
This is the value of the currently selected item. Y ou can 
change this item by setting the value property to a new 
value.
78 PUBLIC
SAP GUI Scripting API
SAP GUI Scripting API
