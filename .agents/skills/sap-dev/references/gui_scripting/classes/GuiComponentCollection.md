# GuiComponentCollection

> **Type**: `Class` | **Section**: `1.2.16`
> **Inherits from**: [`GuiContainer`](GuiContainer.md)

---

## 📖 Description

The GuiComponentCollection is used for collections elements such as the Children property of containers.  Each element of the collection is an extension of GuiComponent.

---

## 🧬 Inherited Members

**All methods of the GuiContainer Object [page 87]:**:
* `FindById`

**All properties of the GuiComponent Object [page 82]:**:
* `ContainerType`
* `Id`
* `Name`
* `Parent`
* `Type`
* `TypeAsNumber`

**All properties of the GuiComponent Object [page 82]:**:
* `ContainerType`
* `Id`
* `Name`
* `Parent`
* `Type`
* `TypeAsNumber`

---

## 📋 Properties

| Property | Access | Signature / Type | Description |
|:---|:---|:---|:---|
| **`Count`** | `Read-only` | `Long` | The number of elements in the collection. This property is  used implicitly from Visual Basic applications. |
| **`Length`** | `Read-only` | `Long` | The number of elements in the collection. |
| **`NewEnum`** | `Read-only` | `Unknown` | This property is used implicitly from Visual Basic applica­ tions. |
| **`Type`** | `Read-only` | `String` | The type information can be used to determine which prop­ erties and methods an object supports. The value of the type  string is the name of the type taken from this documenta­ tion. The value is ‘GuiComponentCollection’ . |
| **`TypeAsNumber`** | `Read-only` | `Long` | While the Type property is a string value, the  TypeAsNumber property is a long value that can alterna­ tively be used to identify an object's type . It was added  for better performance in methods such as FindByIdEx.  Possible values for this property are taken from the GuiCom­ ponentType [page 297]enumeration. .2.17  GuiConnection Object Description A GuiConnection represents the connection between SAP GUI and an application server. Connections can be  opened from SAP Logon or from GuiApplication’s openConnection and openConnectionByConnectionString  methods. GuiConnection extends the GuiContainer Object [page 87]. The type prefix for GuiConnection is  con, the name is con plus the connection number in square brackets. Remarks It is possible to connect to an application server from ABAP using the following command: CALL FUNCTION func DESTINATION dest. However, this connection is implemented as a re-direction between the two application servers involved. There  will therefore be no new GuiConnection object available and the existing object will not reflect the server  switch. |

---

## ⚙️ Methods

### `ElementAt`

```vb
Public Function ElementAt( _    ByVal Index As Long _ ) As GuiComponent
```

This function returns the member in the collection at posi­ tion index, where index may range from 0 to count-1. If no  member can be found for the given index, the exception  Gui_Err_Enumerator_Index (614) is raised.

### `Item`

```vb
Public Function Item( _    ByVal Index As Variant _ ) As GuiComponent
```

This function returns the member in the collection at posi­ tion index, where index may range from 0 to count-1. It has  been added for compatibility with Microsoft Visual Basic col­ lections. If no member can be found for the given index the  exception Gui_Err_Enumerator_Index (614) is raised.

