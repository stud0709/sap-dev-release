# GuiChart

> **Type**: `Class` | **Section**: `1.2.8`

---

## 📖 Description

The GuiChart object is of a very technical nature. It should only be used for recording and playback, as most of  the parameters cannot be determined in any other way. Example

---

## 🧬 Inherited Members

**All methods of the GuiVComponent Object [page 281]:**:
* `DumpState`
* `SetFocus`
* `Visualize`
* `All methods of the GuiContainer Object [page 87]:`
* `FindById`
* `All methods of the GuiVContainer Object [page 286]:`
* `FindAllByName`
* `FindAllByNameEx`
* `FindByName`
* `FindByNameEx`
* `All methods of the GuiShell Object [page 207]:`
* `SelectContextMenuItem`
* `SelectContextMenuItemByPosition`
* `SelectContextMenuItemByText`

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
* `All additional properties of the GuiContainer Object [page 87]:`
* `Children`
* `All additional properties of the GuiShell Object [page 207]:`
* `AccDescription`
* `DragDropSupported`
* `Handle`
* `OcxEvents`
* `SubType`

---

## ⚙️ Methods

### `ValueChange`

```vb
Public Sub ValueChange( _     ByVal Series As Long, _
```

ByVal Point As Long, _     ByVal XValue As String, _     ByVal YValue As String, _     ByVal DataChange As Byte, _     ByVal Id As String, _     ByVal ZValue As String, _     ByVal ChangeFlag As Long _  ) Series: Number of the data set within the row that should  be changed. Point: Number of the data point within the row that should  be changed. XValue: New x value. YValue: New y value. DataChange: Setting this parameter to T rue means the  value was not changed interactively within the graphic but  rather by entering the new value on the DataPoint property  page. Id: GFW data container id of the changed point. May be  used instead of the pair series/point. ZValue: New z value. ChangeFlag: Notify which value was changed or if it was a  time value. The value is set as a bit array, using the lower 5  bits. 1 x 2 y 4 x is time value 8 y is time value 16 z If the new value is a point in time, it should be set using a  string of the format mm/dd/yyyy hh:mm:ss.

