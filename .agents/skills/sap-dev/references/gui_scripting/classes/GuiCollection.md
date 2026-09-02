# GuiCollection

> **Type**: `Class` | **Section**: `1.2.10`

---

## 📖 Description

GuiCollection is similar to the GuiComponentCollection Collection [page 83], but its members are not  necessarily extensions of the GuiComponent Object [page 82]. It can be used to pass a collection  as a parameter to functions of scriptable objects. An object of this class is created by calling the  CreateGuiCollection function of the GuiApplication Object [page 38].

---

## 📋 Properties

| Property | Access | Signature / Type | Description |
|:---|:---|:---|:---|
| **`Count`** | `Read-only` | `Long` | The number of elements in the collection. This property has  been added for compatibility with Microsoft Visual Basic col­ lections. |
| **`Length`** | `Read-only` | `Long` | The number of elements in the collection. |
| **`NewEnum`** | `Read-only` | `Unknown` | This property has been added for compatibility with Micro­ soft Visual Basic collections. |
| **`Type`** | `Read-only` | `String` | The type information can be used to determine which prop­ erties and methods an object supports. The value is the  name of the type taken from this documentation. The value for GuiCollection is ‘GuiCollection’ . |
| **`TypeAsNumber`** | `Read-only` | `Long` | While the Type property is a string value, the  TypeAsNumber property is a long value that can alterna­ tively be used to identify an object's type . It was added  for better performance in methods such as FindByIdEx.  Possible values for this property are taken from the GuiCom­ ponentType [page 297]enumeration. |

---

## ⚙️ Methods

### `Add`

```vb
Public Sub Add( _     ByVal Item As Variant _  )
```

After a GuiCollection has been created, items can be added  by calling the add function.

### `ElementAt`

```vb
Public Function ElementAt( _    ByVal Index As Long _ ) As Variant
```

This function returns the member in the collection at posi­ tion index, where index may range from 0 to count-1. If no  member can be found for the given index, an exception is  raised.

### `Item`

```vb
Public Function Item( _    ByVal Index As Variant _ ) As Variant
```

This function returns the member in the collection at posi­ tion index, where index may range from 0 to count-1. It has  been added for compatibility with Microsoft Visual Basic col­ lections. If no member can be found for the given index, an  exception is raised.

