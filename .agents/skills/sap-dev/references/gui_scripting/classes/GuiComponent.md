# GuiComponent

> **Type**: `Class` | **Section**: `1.2.15`

---

## 📖 Description

GuiComponent is the base class for most classes in the Scripting API. It was designed to allow generic  programming, meaning you can work with objects without knowing their exact type.

---

## 📋 Properties

| Property | Access | Signature / Type | Description |
|:---|:---|:---|:---|
| **`ContainerType`** | `Read-only` | `Byte` | This property is TRUE, if the object is a container and there­ fore has the Children property. |
| **`Id`** | `Read-only` | `String` | An object id is a unique textual identifier for the object. It is  built in a URLlike formatting, starting at the GuiApplication  object and drilling down to the respective object. |
| **`Name`** | `Read-only` | `String` | The name property is especially useful when working with  simple scripts that only access dynpro fields. In that case  a field can be found using its name and type information,  which is easier to read than a possibly very long id. However,  there is no guarantee that there are no two objects with the  same name and type in a given dynpro. |
| **`Parent`** | `Read-only` | `Object` | The parent of an object is one level higher in the runtime  hierarchy. An object is always in the children collection of its  parent. |
| **`Type`** | `Read-only` | `String` | The type information of GuiComponent can be used to de­ termine which properties and methods an object supports.  The value of the type string is the name of the type taken  from this documentation. |
| **`TypeAsNumber`** | `Read-only` | `Long` | While the Type property is a string value, the  TypeAsNumber property is a long value that can alterna­ tively be used to identify an object's type . It was added  for better performance in methods such as FindByIdEx.  Possible values for this property are taken from the GuiCom­ ponentType [page 297]enumeration. |

---

