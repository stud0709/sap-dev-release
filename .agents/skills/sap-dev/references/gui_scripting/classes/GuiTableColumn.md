# GuiTableColumn

> **Type**: `Class` | **Section**: `1.2.60`
> **Inherits from**: [`GuiComponentCollection`](GuiComponentCollection.md)

---

## 📖 Description

GuiTableColumn extends the GuiComponentCollection Collection [page 83].

---

## 📋 Properties

| Property | Access | Signature / Type | Description |
|:---|:---|:---|:---|
| **`Count`** | `Read-only` | `Long` | Number of cells in the column. |
| **`DefaultTooltip`** | `Read-only` | `Public Property DefaultTooltip As` | String T ooltip text generated from the short text defined in the data  dictionary for the given screen element type. |
| **`Fixed`** | `Read-only` | `Byte` | Some columns may be fixed, which means that they will not  be scrolled with the rest of the columns. |
| **`IconName`** | `Read-only` | `String` | If the object has been assigned an icon, then this property is  the name of the icon, otherwise it is an empty string. |
| **`Length`** | `Read-only` | `Long` | Number of cells in the column. |
| **`NewEnum`** | `Read-only` | `Unknown` | Property for VB collection handling. |
| **`Selected`** | `Read-write` | `Byte` | This property is true if the column is selected. |
| **`Title`** | `Read-only` | `String` | This is the caption of the column. |
| **`Tooltip`** | `Read-only` | `String` | The tooltip contains a text, which is designed to help a user  understand the meaning of a given text field or button. |
| **`Type`** | `Read-only` | `String` | The type information of GuiComponent can be used to de­ termine which properties and methods an object supports.  The value of the type string is the name of the type taken  from this documentation. |
| **`TypeAsNumber`** | `Read-only` | `Long` | While the type property is a string value, the typeAsNumber  property is a long value that can alternatively be used to  identify an object's type . It was added for better perform­ ance in methods such as FindByIdEx. Possible values for this  property are taken from the GuiComponentType enumera­ tion. |

---

## ⚙️ Methods

### `ElementAt`

```vb
Public Function ElementAt( _    ByVal Index As Long _ ) As GuiComponent
```

This function returns the member in the collection at posi­ tion index, where index may range from 0 to count-1. If no  member can be found for the given index, an exception is  raised.

### `Item`

```vb
Public Function Item( _    ByVal Index As Variant _ ) As GuiComponent
```

This function returns the member in the collection at posi­ tion index, where index may range from 0 to count-1. It has  been added for compatibility with Microsoft Visual Basic col­ lections. If no member can be found for the given index, an  exception is raised.

