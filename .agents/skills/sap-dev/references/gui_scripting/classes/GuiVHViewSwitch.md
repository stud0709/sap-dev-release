# GuiVHViewSwitch

> **Type**: `Class` | **Section**: `1.2.74`
> **Inherits from**: [`GuiVComponent`](GuiVComponent.md)

---

## 📖 Description

GuiVHViewSwitch represents the “View Switch” object that was introduced with the Belize theme in SAP GUI.  The View Switch is placed in the header area of the SAP GUI main window and can be used to select different  views within an application. Many screens can be displayed in different ways (for example, as a tree or list). T o  switch from one view to another in a comfortable way, these screens may make use of the View Switch: GuiVHViewSwitch is very similar to GuiOkCodeField Object [page 172] and extends the GuiVComponent Object  [page 281]. The name of the GuiVHViewSwitch object is always vhviewswitch and only one object of this type  can exist at the same time.  Note • GuiVHViewSwitch exists as of SAP GUI for Windows 7 .60 (the UI object itself was introduced in SAP  GUI for Windows 7 .50, but the extension of the Scripting API is done for SAP GUI for Windows 7 .60 and  newer SAP GUI versions, only) • Objects of type GuiVHViewSwitch can only exist when SAP GUI is running with a Fiori theme like Belize • GuiVHViewSwitch does not offer an entry collection. For compatibility reasons the entries of a  GuiVHViewSwitch are still GuiButtons which belong to the application toolbar (tbar1).

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
* `.3 Events`

---

