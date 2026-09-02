# GuiDockShell

> **Type**: `Class` | **Section**: `1.2.23`
> **Inherits from**: [`GuiVContainer`](GuiVContainer.md) | **ID Prefix**: `shellcont`

---

## 📖 Description

A GuiDockShell is a special kind of GuiContainerShell Object [page 88], which represents a docking container.  GuiDockShell extends the GuiVContainer Object [page 286]. The type prefix is shellcont, the name is the last  part of the id, shellcont[n].

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
* `annotationTextRequest`
* `Public Sub annotationTextRequest( _     ByVal strText As String _  )`

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
* `All additional properties of the GuiShell Object [page 207]:`
* `AccDescription`
* `DragDropSupported`
* `Handle`
* `OcxEvents`
* `SubType`

---

## 📋 Properties

| Property | Access | Signature / Type | Description |
|:---|:---|:---|:---|
| **`AccDescription`** | `Read-only` | `Public Property AccDescription As` | String Accessibility description of the shell. This description can be  used for shells that do not have a title element. |
| **`DockerIsVertical`** | `Read-only` | `Public Property DockerIsVertical As` | Byte Is TRUE if the container is a vertical docker control. |
| **`DockerPixelSize`** | `Read-write` | `Public Property DockerPixelSize As` | Long Returns the size of the docker control in pixels. .2.24  GuiEAIViewer2D Object Description The GuiEAIViewer2D control is used to view 2-dimensional graphic images in the SAP system. The user can  carry out redlining over the loaded image. The scripting wrapper for this control records all user actions during  the redlining process and reproduces the same actions when the recorded script is replayed. GuiEAIViewer2D extends the GuiShell Object [page 207]. |

---

