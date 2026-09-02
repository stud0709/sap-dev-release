# GuiPicture

> **Type**: `Class` | **Section**: `1.2.44`
> **Inherits from**: [`GuiShell`](GuiShell.md)

---

## 📖 Description

The picture control displays a picture on an SAP GUI screen. GuiPicture extends the GuiShell Object [page  207].

---

## 🧬 Inherited Members

**All methods of the GuiVComponent Object [page 281]:**:
* `DumpState`
* `SetFocus`
* `Visualize`
* `Method Description`
* `All methods of the GuiContainer Object [page 87]:`
* `FindById`
* `All methods of the GuiVContainer Object [page 286]:`
* `FindAllByName`
* `FindAllByNameEx`
* `FindByName`
* `FindByNameEx`

**All properties of the GuiComponent Object [page 82]**:
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
* `All properties of the GuiShell Object [page 207]:`
* `AccDescription`
* `DragDropSupported`
* `Handle`
* `OcxEvents`
* `SubType`

---

## 📋 Properties

| Property | Access | Signature / Type | Description |
|:---|:---|:---|:---|
| **`AltText`** | `Read-only` | `String` | This property contains the alternative text that can be as­ signed to an image (for example used for visually impaired  people when a screenreader is used). |
| **`DisplayMode`** | `Read-only` | `Public Property DisplayMode() As` | String Possible values of this property are: • ”Normal”: This value indicated that the picture is shown  in its original size. If the picture’s size is larger than the  size of the control, the control provides scrollbars. If the  picture’s size is smaller than the size of the control, the  picture is shown in the upper left corner of the control. • “Stretch”: The picture is resized in a way that it always  occupies the complete area of the control. • “Fit”: The picture is resized on way that it fits into the  control area without having the need to show scrollbars.  In contrast to “Strech” the mode “Fit” preserves the  ratio of width and height of the picture. • “NormalCenter”: Like “Normal” except that the picture  is not shown in the upper left corner but in the center of  the control. • “FitCenter”: Like “Fit” except that the picture is not  shown in the upper left corner but in the center of the  control. |
| **`Icon`** | `Read-only` | `String` | Returns the SAPGUI icon code (e.g. “@01@”) of the dis­ played icon. If no icon is displayed, the property contains  an empty string. |
| **`Url`** | `Read-only` | `String` | Returns the URL of the displayed picture. If an icon is  displayed (see property “icon”), the property contains an  empty string. Depending in the application that used the  control the URL may contain temporary URL parts (e.g.  UUIDs). |

---

## ⚙️ Methods

### `Click`

```vb
Public Sub Click()
```

This function emulates a single mouse click on a picture.

### `ClickControlArea`

```vb
Public Sub ClickControlArea( _     ByVal x As Long, _
```

ByVal y As     Long _  ) The function emulates a click on a given position. The coor­ dinates should be given in pixels with respect to the picture  control as it is displayed on the screen.

### `ClickPictureArea`

```vb
Public Sub ClickPictureArea( _     ByVal x As Long, _
```

ByVal y As     Long _  ) The function emulates a click on a given position. The coor­ dinates should be given in pixels with respect to the original  picture file. They may differ from the pixel coordinates of the  displayed picture because of scaling.

### `ContextMenu`

```vb
Public Sub ContextMenu( _     ByVal x As Long, _
```

ByVal y As     Long _  ) The function opens a context menu on the given position.  The coordinates should be given in pixels with respect to the  picture control as it is displayed on the screen.

### `DoubleClick`

```vb
Public Sub DoubleClick()
```

This function emulates a double-click on a picture.

### `DoubleClickControlArea`

```vb
Public Sub DoubleClickControlArea( _     ByVal x As Long, _
```

ByVal y As     Long _  ) The function emulates a double-click on a given position.  The coordinates should be given in pixels with respect to the  picture control as it is displayed on the screen. Method Description

### `DoubleClickPictureArea`

```vb
Public Sub DoubleClickPictureArea( _     ByVal x As Long, _
```

ByVal y As     Long _  ) The function emulates a double-click on a given position.  The coordinates should be given in pixels with respect to  the original picture file. They may differ from the pixel coor­ dinates of the displayed picture because of scaling.

