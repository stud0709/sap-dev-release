# GuiVComponent

> **Type**: `Class` | **Section**: `1.2.72`
> **Inherits from**: [`GuiComponent`](GuiComponent.md)

---

## 📖 Description

An object exposes the GuiVContainer interface if it is both visible and can have children. It will then also  expose GuiComponent and GuiVComponent. Examples of this interface are windows and subscreens, toolbars  or controls having children, such as the splitter control. GuiVContainer extends the GuiContainer Object [page  87] and the GuiVComponent Object [page 281].

---

## 🧬 Inherited Members

**All methods of the GuiVComponent Object [page 281]:**:
* `DumpState`
* `SetFocus`
* `Visualize`
* `All methods of the GuiContainer Object [page 87]:`
* `FindById`

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
* `All properties of the GuiContainer Object [page 87]:`
* `Children`

---

## 📋 Properties

| Property | Access | Signature / Type | Description |
|:---|:---|:---|:---|
| **`AccText`** | `Read-only` | `String` | An additional text for accessibility support. |
| **`AccTextOnRequest`** | `Read-only` | `Public Property AccTextOnRequest As` | String An additional text for accessibility support. |
| **`AccTooltip`** | `Read-only` | `String` | An additional tooltip text for accessibility support. |
| **`Changeable`** | `Read-only` | `Byte` | An object is changeable if it is neither disabled nor read-only. |
| **`DefaultTooltip`** | `Read-only` | `Public Property DefaultTooltip As` | String T ooltip text generated from the short text defined in the data  dictionary for the given screen element type. |
| **`Height`** | `Read-only` | `Long` | Height of the component in pixels. |
| **`IconName`** | `Read-only` | `String` | If the object has been assigned an icon, then this property is  the name of the icon, otherwise it is an empty string. |
| **`IsSymbolFont`** | `Read-only` | `Byte` | The property is TRUE if the component's text is visualized in  the SAP symbol font. |
| **`Left`** | `Read-only` | `Long` | Left position of the element in screen coordinates Modified Public Property Modified As Byte An object is modified if its state has been changed by the  user and this change has not yet been sent to the SAP sys­ tem. |
| **`ParentFrame`** | `Read-only` | `Public Property ParentFrame As` | GuiComponent If the control is hosted by the Frame object, the value of the  property is this frame. Overwise NULL. |
| **`ScreenLeft`** | `Read-only` | `Long` | The y position of the component in screen coordinates. |
| **`ScreenTop`** | `Read-only` | `Long` | The x position of the component in screen coordinates. |
| **`Text`** | `Read-write` | `String` | The value of this property very much depends on the type of  the object on which it is called. This is obvious for text fields  or menu items. On the other hand this property is empty for  toolbar buttons and is the class id for shells. Y ou can read  the text property of a label, but you can’t change it, whereas  you can only set the text property of a password field, but  not read it. |
| **`Tooltip`** | `Read-only` | `String` | The tooltip contains a text which is designed to help a user  understand the meaning of a given text field or button. Top Public Property Top As Long Top coordinate of the element in screen coordinates. |
| **`Width`** | `Read-only` | `Long` | Width of the component in pixels. .2.73  GuiVContainer Object  Description An object exposes the GuiVContainer interface if it is both visible and can have children. It will then also  expose GuiComponent and GuiVComponent. Examples of this interface are windows and subscreens, toolbars  or controls having children, such as the splitter control. GuiVContainer extends the GuiContainer Object [page  87] and the GuiVComponent Object [page 281]. |

---

## ⚙️ Methods

### `DumpState`

```vb
Public Function DumpState( _    ByVal InnerObject As String _ ) As GuiCollection
```

This function dumps the state of the object. The parameter  innerObject may be used to specify for which internal object  the data should be dumped. Only the most complex compo­ nents, such as the GuiCtrlGridView, support this parameter.  All other components always dump their full state. All com­ ponents that support this parameter have in common that  they return general information about the control’s state if  the parameter “innerObject” contains an empty string. The  available values for the innerObject parameter are specified  as part of the class description for those components that  support it.  Note The DumpState method returns a hierarchy of collec­ tions of type GuiCollection, which is three levels deep. • The top (first) level collection contains a second  level collection for every property that is to be  dumped. • The second level collection contains the complete  information for one property. There is a third level  collection for every sub-expression that might be  required to access inner objects. • Finally, the third level collection contains the Op­ Code, the property or method name, the parameter  values and depending on the OpCode the return  value to be checked. The following OpCodes are used: • GPR: Get property and compare return value. • MR: Execute method and compare return value. • GP: Get property and execute the next entry in the  second level collection on the result. • M: Execute the method and then execute the next  entry in the second level collection on the result. For example the calls control.ItemCount = 42 control.GetItemValue(3, 2) =  'MyText' control.GetItem('2','3').Property1. MethodY('XYZ').Text = 'ABC'  result in three entries of the top level collection: • First entry: • OpCode Name Parameter1/ • Property-Value • Parameter2 Parameter3 • GPR ItemCount 42 • Second entry: • OpCode Name Parameter1 Parameter2 Pa­ rameter3/ • Property-Value • MR GetItemValue 3 2 MyText • Third entry: • OpCode Name Parameter1 Parameter2 Pa­ rameter3 • M GetItem 2 3 • GP Property1 • M MethodY XYZ • GPR Text ABC As you can see in this example, for calls that contain  return values (MR, GPR) the last value in the third level  collection is the return value.

### `SetFocus`

```vb
Public Sub SetFocus()
```

This function can be used to set the focus onto an object.  If a user interacts with SAP GUI, it moves the focus when­ ever the interaction is with a new object. Interacting with  an object through the scripting component does not change  the focus. There are some cases in which the SAP applica­ tion explicitly checks for the focus and behaves differently  depending on the focused object.

### `Visualize`

```vb
Public Function Visualize( _    ByVal On As Boolean, _
```

Optional ByVal InnerObject As  Variant _ ) As Byte Calling this method of a component will display a red frame  around the specified component if the parameter on is  true. The frame will be removed if on is false. Some compo­ nents such as GuiCtrlGridView support displaying the frame  around inner objects, such as cells. The format of the inner­ Object string is the same as for the dumpState method.

