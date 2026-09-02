# GuiOkCodeField

> **Type**: `Class` | **Section**: `1.2.42`
> **Inherits from**: [`GuiVComponent`](GuiVComponent.md) | **ID Prefix**: `okcd`

---

## 📖 Description

The GuiOkCodeField is placed on the upper toolbar of the main window. It is a combo box into which  commands can be entered. Setting the text of GuiOkCodeField will not execute the command until server  communication is started, for example by emulating the Enter key (VKey 0). GuiOkCodeField extends the  GuiVComponent Object [page 281]. The type prefix is okcd, the name is empty. Example

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
* `The following properties of the GuiVComponent Object [page 281] (some properties are not supported, because the`
* `GuiOkCodeField is not an object that can be influenced by the ABAP application):`
* `Changeable`
* `Height`
* `IconName`
* `Left`
* `Modified`
* `ScreenLeft`
* `ScreenTop`
* `Text`
* `Top`
* `Width`

---

## 📋 Properties

| Property | Access | Signature / Type | Description |
|:---|:---|:---|:---|
| **`Opened`** | `Read-only` | `Byte` | In SAP GUI designs newer than Classic design the GuiOkCo­ deField can be collapsed using the arrow button to the right  of it. In SAP GUI for Windows the GuiOkCodeField may also  be collapsed via a setting in the Windows registry. This property contains False is the GuiOkCodeField is col­ lapsed. |

---

## ⚙️ Methods

### `PressF1`

```vb
Public Sub PressF1()
```

Emulate pressing the F1 key while the focus is on the GuiOk­ CodeField.

