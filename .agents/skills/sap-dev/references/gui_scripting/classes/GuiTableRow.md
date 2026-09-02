# GuiTableRow

> **Type**: `Class` | **Section**: `1.2.62`
> **Inherits from**: [`GuiComponentCollection`](GuiComponentCollection.md)

---

## 📖 Description

GuiTableRow extends the GuiComponentCollection Collection [page 83].

---

## 📋 Properties

| Property | Access | Signature / Type | Description |
|:---|:---|:---|:---|
| **`Count`** | `Read-only` | `Long` | Number of cells in the row. |
| **`Length`** | `Read-only` | `Long` | Number of cells in the row. |
| **`NewEnum`** | `Read-only` | `Unknown` | Property for VB collection handling. |
| **`Selectable`** | `Read-only` | `Byte` | This property is T rue if the row can be selected. |
| **`Selected`** | `Read-write` | `Byte` | This property is true if the row is selected. |
| **`Type`** | `Read-only` | `String` | The type information of GuiComponent can be used to de­ termine which properties and methods an object supports.  The value of the type string is the name of the type taken  from this documentation. |
| **`TypeAsNumber`** | `Read-only` | `Long` | While the type property is a string value, the typeAsNumber  property is a long value that can alternatively be used for this  property are taken from the GuiComponentType enumera­ tion. |

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

