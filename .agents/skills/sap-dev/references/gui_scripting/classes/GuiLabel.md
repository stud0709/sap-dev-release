# GuiLabel

> **Type**: `Class` | **Section**: `1.2.33`
> **Inherits from**: [`GuiVComponent`](GuiVComponent.md) | **ID Prefix**: `lbl`

---

## 📖 Description

GuiLabel extends the GuiVComponent Object [page 281]. The type prefix is lbl, the name is the fieldname  taken from the SAP data dictionary.

---

## 🧬 Inherited Members

**All methods of the GuiVComponent Object [page 281]:**:
* `DumpState`
* `SetFocus`
* `Visualize`

**All properties of the GuiComponent Object [page 82]:**:
* `ContainerType`
* `Id`
* `Name`
* `Parent`
* `Type`
* `TypeAsNumber`
* `All properties of the GuiVComponent Object [page 281]:`
* `AccLabelCollection`
* `AccText`
* `AccTextOnRequest`
* `AccT ooltip`
* `Changeable`
* `DefaultT ooltip`
* `Height`
* `IconName`
* `IsSymbolFont`
* `Left`
* `Modified`
* `ParentFrame`
* `ScreenLeft`
* `ScreenTop`
* `Text`
* `T ooltip`
* `Top`
* `Width`

---

## 📋 Properties

| Property | Access | Signature / Type | Description |
|:---|:---|:---|:---|
| **`CaretPosition`** | `Read-write` | `Long` | Setting the caret position within a label is possible even  though it is not visualized as a caret by SAP GUI. However,  the position is transmitted to the server, so ABAP application  logic may depend on this position. |
| **`CharHeight`** | `Read-only` | `Long` | Height of the GuiLabel in character metric. |
| **`CharLeft`** | `Read-only` | `Long` | Left coordinate of the GuiLabel in character metric. |
| **`CharTop`** | `Read-only` | `Long` | Top coordinate of the GuiLabel in character metric. |
| **`CharWidth`** | `Read-only` | `Long` | Width of the GuiLabel in character metric. |
| **`ColorIndex`** | `Read-only` | `Long` | This number defines the index of the list color of this ele­ ment. |
| **`ColorIntensified`** | `Read-only` | `Public Property ColorIntensified As` | Byte This property is T rue if the Intensified flag is set in screen  painter for this dynpro element. |
| **`ColorInverse`** | `Read-only` | `Byte` | This property is T rue if the inverse color style is set in screen  painter for the element. |
| **`DisplayedText`** | `Read-only` | `Public Property DisplayedText As` | String This property contains the text as it is displayed on the  screen, including preceding or trailing blanks. These blanks  are stripped from the text property. |
| **`Highlighted`** | `Read-only` | `Byte` | This property is T rue if the Highlighted flag is set in the  screen painter for the dynpro element. |
| **`IsHotspot`** | `Read-only` | `Byte` | Dynpro elements such as labels may be configured to cause  a round trip when they are clicked. In that case the mouse  cursor changes to the hand shape. This is called a hot spot. |
| **`IsLeftLabel`** | `Read-only` | `Byte` | This property is set if the label has been assigned as the left  label of another control. |
| **`IsListElement`** | `Read-only` | `Byte` | This property is T rue if the element is on an ABAP list, not a  dynpro screen. |
| **`IsRightLabel`** | `Read-only` | `Byte` | This property is set if the label has been assigned as the  right label of another control. |
| **`MaxLength`** | `Read-only` | `Long` | The maximum text length of a label is counted in code units.  On non-Unicode clients these are equivalent to bytes. |
| **`Numerical`** | `Read-only` | `Byte` | This flag is T rue if the label may only contain numbers. |
| **`RowText`** | `Read-only` | `String` | This property is only available in ABAP list screens. It returns  the text of the while line containing the current component.  Note This property can only provide useful data when Acces­ sibility mode is activated and the respective ABAP list  has been properly enabled for accessibility. In this case,  the ABAP list contains substructures of type GuiSimple­ Container which, for example, model the rows of the list. |

---

## ⚙️ Methods

### `GetListProperty`

```vb
Public Function GetListProperty( _    ByVal Property As String _ ) As String
```

Remarks  Note This method can only provide useful data when Accessi­ bility mode is activated and the respective ABAP list has  been properly enabled for accessibility. In this case, the  ABAP list contains substructures of type GuiSimpleCon­ tainer which, for example, model the rows of the list. Attributes of containers in general • ContainerType • L: Entire list • T: A table • G: A group inside a table • S: A subgroup (inside a group) • R: A line in the body of a table • B: A text box • E: A tree • F: Simple "free" text outside any box • ContainerTitle: Title of a table (if provided) or of a text  box • ContainerInputFields: Number of input fields, used if a  table or a tree has input fields (incl. checkboxes) Attributes of containers of type L (Entire list) • ListTablesT otal: Number of tables on the list • ListTextBoxesT otal: Number of text boxes on the list • ListTreesT otal: Number of trees on the list • ListErrorMessage: Used if the structure recognition de­ tected a (severe) error. • ListInputType • N: list contains no input fields • C: list contains check boxes • E: list contains edit fields • A: list contains edit fields and check boxes Attributes of containers of type T (Table), G (Group) and S  (Subgroup) • RowsT otal: Number of logical rows in the table body. If  this is an attribute of a (sub-)group, number of logical  rows until the next (sub-)group starts. The numbers do  NOT include summation lines and inserted lines. • RowsSummation: Number of rows with color  COL_SUMMING INTENSIFIED ON (if there are any). • RowsSubSummation: Number of rows with color  COL_SUMMING INTENSIFIED OFF (if there are any). • RowsInserted: Number of inserted rows (if there are  any). Attributes of containers of type T (Table) • TableNo: Number of the table if there is more than one  table on the list • ColumnsT otal: Number of logical columns • SuperColumnsT otal: Used if the table has a hierarchical  header • TableHierarchical: Used if the table is hierarchical-se­ quential • A: ALV-like 2-level hierarchical-seq. • 2: 2-level hierarchical-seq. • 3: 3-level hierarchical-seq. • TableGroupsT otal: Used if the table is hierarchical-seq.:  Number of groups (not counting subgroups) • Columns2LevelALV: Used if TableHierarchical is "A":  Number of columns in the group header • HeaderRows2LevelALV: Used if TableHierarchical is "A":  Number of lines in the group header • TableHierarchicalHeader: Used if the table has a hier­ archical header • TableMultipleRows: Used if the table is a multiple-line  table: Number of physical lines per logical line Attributes of containers of type G (Group) and S (Subgroup) • GroupNo: Number of current group if container is of  type G. • SubGroupNo: Number of current subgroup if container  is of type S • SubgroupsT otal: Number of subgroups if table is 3-level  hierarchical-sequential and container is of type G • GroupHeaderRows: Number of physical lines in the  group header • GroupHeaderValues: Number of label-value pairs in the  group header if the table is 2- or 3- level hierarchical-se­ quential Attributes of containers of type R (Row) • RowType: Used if the row has a special type • S: Color COL_SUMMING INTENSIFIED ON • U: Color COL_SUMMING INTENSIFIED OFF • I: Inserted line • RowNo: Number of current (logical) row, relative to the  beginning of the (sub-)group if the table is 3- or 2-level  hierarchical-seq. • RowMultipleRows: Number of physical lines for current  logical line; used if > 1 (multiple-line tables). Lines with  totals may or may not be multiple lines • RowInputFields: Number of input fields in the current  line (if any) Attributes of fields in tables • FieldHeader: The text of the column header (unavailable  if the field itself is in the header, or the field is the label  of a label-value pair in a hierarchical-sequential table, or  the field is in an inserted line and does not belong to any  column). • FieldSuperHeader: Text of the supercolumn if the field is  in the lower line of a hierarchical header or in the table  body (and belongs to a column). • ColumnNo: The number of the logical column (if the  field belongs to a column). • LabelType: Used if the field is in the header or is a label  of a label-value pair in a hierarchical-seq. table. • N: normal header field (lowest level in hierar.-seq.  tables) • H: header field in a supercolumn (upper line of a  hierarchical header) • A: group header field (COL_GROUPING INTENSI­ FIED ON) in table whereTableHierarchical is A • G: group header field (COL_GROUPING INTENSI­ FIED ON) in 2-level hierarchical-sequential table • S: subgroup header field (COL_HEADING INTENSI­ FIED ON) in 3-level hierarchical-sequential table • T: title-field COL_NORMAL INTENSIFIED ON • ColumnType: Used if the field is a column header of a  special column. • C: column contains checkboxes • S: column contains symbols and/or icons • SubordinateColumns: Number of subordinate columns  if the field is in the upper line of a hierarchical header. • FieldMultipleRows: Used if the field is in a table header  and word wrapping was done: Number of physical lines  of the "logical field". • FieldWithEllipsis: The field is directly followed by  SYM_ELLIPSIS, i.e. "...". Attributes of fields in tables, trees or title lines of text boxes • FieldPhysRowNo: If we are in the body of a multiple-line  table or in a multiple-line node of a tree or word wrap­ ping is used in the table header: Current physical line  number within the logical line. Attributes of text boxes • TextBoxNo: Number of the text box if there is more than  one text box on the list Attributes of containers in an SEUT tree • TreeNo: Number of the tree if there is more than one  tree on the list and the current container is the root  node • NodeName: Text of the first field of the node (STREE­ NODE-NAME) • NodeLevelNo: The current level number; the root has  level 0 • NodeNo: The current node number; the "oldest brother"  has number 1. • NodeExpandable: Used if the current node can be ex­ panded (folder with "+"). • NodeMarked: Node has been marked (yellow in SEUT). • NodeChildrenT otal: Used if the current node is ex­ panded (folder with "-"): Number of children. (Grand  children are not counted.) • NodeMultipleRows: Used if the current node has more  than one physical line: Number of physical lines

### `GetListPropertyNonRec`

```vb
Public Function 
GetListPropertyNonRec( _    ByVal Property As String _ ) As String
```

 Note This method can only provide useful data when Accessi­ bility mode is activated and the respective ABAP list has  been properly enabled for accessibility. In this case, the  ABAP list contains substructures of type GuiSimpleCon­ tainer which, for example, model the rows of the list. This method returns information that is compiled on the  server to enhance the ABAP lists with accessibility informa­ tion. See GuiLabel Object [page 140] → GetListProperty  for a description of available attributes. In contrast to the  method GetListProperty, GetListPropertyNonRec will only  return information that is set for the specific element and  ignore list properties set for parent elements.

