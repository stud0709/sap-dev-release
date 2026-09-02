<!-- AUTO-GENERATED FILE - DO NOT EDIT MANUALLY. Source: agents-docs/skill-source/templates -->

# Dynpro & Screen Authoring Reference Guide

This document is the authoritative specification for authoring classic SAP Dynpros (Screen Painter screens) via the `sap-dev` AI skill and Model Context Protocol (MCP).

---

## 1. Overview & Architecture

Classic SAP screens (Dynpros) consist of three tightly integrated artifacts:
1. **Screen Header (`D020S` / `RPY_DYHEAD`)**: Defines screen geometry (lines, columns), screen type (Normal, Subscreen, Modal Dialog), and navigation.
2. **Screen Elements List (`D021S` / `RPY_DYFATC` / `EUDB`)**: Declarative element array defining all interactive widgets, labels, dropdowns, buttons, frames, containers, and table controls.
3. **Screen Flow Logic (`dyn_flowlist`)**: ABAP procedural screen code structured across the 4 standard dynpro events:
   - `PROCESS BEFORE OUTPUT` (PBO)
   - `PROCESS AFTER INPUT` (PAI)
   - `PROCESS ON VALUE-REQUEST` (POV / F4)
   - `PROCESS ON HELP-REQUEST` (POH / F1)

When staged locally in `./src/<system_id>/dynpros/`, dynpros are represented as twin files:
- **`<program>.<dynnr>.screen.json`** (Header + Elements)
- **`<program>.<dynnr>.flow.abap`** (ABAP Flow Logic)

---

## 2. Universal Screen JSON Schema (`.screen.json`)

```json
{
  "header": {
    "prog": "ZMY_PROGRAM",
    "dnum": "0100",
    "type": " ",
    "linc": 27,
    "colc": 120,
    "next": "0100",
    "spra": "D",
    "dtxt": "Dynpro Showcase Window"
  },
  "elements": [
    {
      "name": "OK_CODE",
      "type": "OKCODE",
      "line": 255,
      "colm": 1,
      "leng": 20
    }
  ]
}
```

### Screen Header Attributes (`header`)

| Property | Type | Description | Allowed Values | Default |
|---|---|---|---|---|
| `prog` | string | Main program / Function pool name | e.g. `ZSAP_DEV_DYNPRO_SHOWCASE`, `SAPLZ_EWM_RF` | Required |
| `dnum` | string | 4-digit dynpro number | e.g. `"0100"`, `"0200"`, `"0210"` | Required |
| `type` | string | Dynpro type | `' '` / `"S"` (Normal), `"I"` (Subscreen), `"M"` (Modal Dialog), `"N"` (Subscreen in Tabstrip) | `' '` |
| `linc` | number | Screen height (lines) | 1–200 | `27` |
| `colc` | number | Screen width (columns) | 1–255 | `120` |
| `next` | string | Default next screen number | e.g. `"0100"`, `"0"` (leave screen) | Same as `dnum` |
| `dtxt` | string | Short description / Title | Text | `""` |
| `cursor` | string | Field to receive cursor focus initially | Field name | `""` |

---

## 3. Supported Widget Types & Attribute Matrix

The dynpro engine natively models all SAP Screen Painter element types:

| Element Type | Description | Required Attributes | Key Optional Attributes |
|---|---|---|---|
| `TEXT` / `LABEL` | Static label text | `name`, `line`, `colm`, `leng`, `stxt` | `icon` |
| `ENTRYFIELD` | Single-line input / output field | `name`, `line`, `colm`, `leng` | `format`, `input`, `output`, `required`, `lowercase`, `intensified`, `invisible`, `right_justified`, `grp1`..`grp4`, `search_help`, `poss_entry`, `context_menu` |
| `DROPDOWN` / `LISTBOX` | Dropdown listbox (VRM / Search Help) | `name`, `line`, `colm`, `leng` | `fcod`, `dropdown: "LISTBOX"`, `search_help` |
| `PUSHBUTTON` / `PUSH` | Interactive pushbutton | `name`, `line`, `colm`, `leng`, `stxt`, `fcod` | `functype` (`' '` normal, `'E'` exit command) |
| `CHECKBOX` | 1-character checkbox field | `name`, `line`, `colm`, `leng: 1`, `stxt` | `fcod`, `group1` |
| `RADIOBUTTON` | Radio button with group exclusivity | `name`, `line`, `colm`, `leng: 1`, `stxt`, `radio_group` | `fcod`, `group1` |
| `FRAME` / `BOX` | Visual grouping box | `name`, `line`, `colm`, `width`, `height`, `stxt` | `group1` |
| `SUBSCREEN` | Subscreen container area | `name`, `line`, `colm`, `width`, `height` | `min_lines`, `min_cols` |
| `CUSTOMCONTROL` | Container for GUI Controls (`CL_GUI_ALV_GRID`, TextEdit, HTML) | `name`, `line`, `colm`, `width`, `height` | `min_lines`, `min_cols` |
| `TABSTRIP` | Tabstrip control container | `name`, `line`, `colm`, `width`, `height` | `min_lines`, `min_cols` |
| `TABLECONTROL` | Table control grid | `name`, `line`, `colm`, `width`, `height` | `min_lines`, `min_cols` |
| `STATUSICON` | Graphical status icon with hover tooltip | `name`, `line`, `colm`, `leng: 4` | `context_menu` |
| `OKCODE` | Internal OK_CODE command field | `name: "OK_CODE"`, `line: 255`, `colm: 1`, `leng: 20` | — |

---

## 4. Deep-Dive: Controls, Features & Runtime Nuances

### 4.1 Status Icons (`STATUSICON`)
For an output field to render as a graphical colored light/icon in SAP GUI:
1. **Screen JSON**: Set `"type": "STATUSICON"`, `"leng": 4`, `"line": ...`, `"colm": ...`.
2. **Buffer Sizing**: In the ABAP program, declare the variable as **`TYPE c LENGTH 132`** (not `4`), because `ICON_CREATE` includes escape sequences and tooltip tokens (e.g. `@01\QTooltip Text@`).
3. **PBO Initialization**:
   ```abap
   CALL FUNCTION 'ICON_CREATE'
     EXPORTING
       name   = 'ICON_GREEN_LIGHT'  " or 'ICON_YELLOW_LIGHT', 'ICON_RED_LIGHT'
       text   = ' '
       info   = 'Live Status Tooltip'
     IMPORTING
       result = gv_status_icon
     EXCEPTIONS
       OTHERS = 1.
   ```

---

### 4.2 Dynamic F4 Search Help (`PROCESS ON VALUE-REQUEST`)
To bind custom F4 help with a selection dialog to an input field:
1. **Flow Logic**:
   ```abap
   PROCESS ON VALUE-REQUEST.
     FIELD GV_INPUT_TEXT MODULE F4_INPUT_TEXT.
   ```
   > [!IMPORTANT]
   > Flow logic `FIELD` names must be **strictly UPPERCASE** to match the dynpro field catalog (`GV_INPUT_TEXT`). Lowercase `gv_input_text` will fail to bind.

2. **ABAP Module Implementation (`F4IF_INT_TABLE_VALUE_REQUEST`)**:
   The internal table passed to `value_tab` **must** be typed with standard DDIC data elements (e.g. `mara-matnr`, `makt-maktx`) so the function module can construct column headers:
   ```abap
   MODULE f4_input_text INPUT.
     TYPES: BEGIN OF ty_mat_f4,
              matnr TYPE mara-matnr,
              maktx TYPE makt-maktx,
              meins TYPE mara-meins,
            END OF ty_mat_f4.
     DATA: lt_matches TYPE TABLE OF ty_mat_f4,
           lt_ret_f4  TYPE TABLE OF ddshretval.

     SELECT a~matnr, b~maktx, a~meins
       FROM mara AS a
       LEFT OUTER JOIN makt AS b ON a~matnr = b~matnr AND b~spras = @sy-langu
       INTO CORRESPONDING FIELDS OF TABLE @lt_matches
       UP TO 20 ROWS.

     CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
         retfield    = 'MATNR'
         dynpprog    = sy-repid
         dynpnr      = sy-dynnr
         dynprofield = 'GV_INPUT_TEXT'
         value_org   = 'S'
       TABLES
         value_tab   = lt_matches
         return_tab  = lt_ret_f4
       EXCEPTIONS
         OTHERS      = 1.

     IF sy-subrc = 0.
       READ TABLE lt_ret_f4 INDEX 1 INTO DATA(ls_ret).
       IF sy-subrc = 0.
         gv_input_text = ls_ret-fieldval.
       ENDIF.
     ENDIF.
   ENDMODULE.
   ```

---

### 4.3 Tabstrip Controls (`TABSTRIP` / `STRIP_CTRL`)
To build a multi-tab interface with server-side subscreen swapping:
1. **Screen JSON**:
   - Define the Tabstrip container: `{"name": "TS_MAIN", "type": "TABSTRIP", "line": 2, "colm": 64, "width": 54, "height": 18}`
   - Define the Subscreen area inside the Tabstrip: `{"name": "SUB_MAIN", "type": "SUBSCREEN", "line": 4, "colm": 65, "width": 52, "height": 15}`
   - Define Tab Pushbuttons:
     - `{"name": "TAB_BTN_1", "type": "PUSH", "line": 3, "colm": 65, "leng": 15, "stxt": "Overview", "fcod": "TAB_OVERVIEW"}`
     - `{"name": "TAB_BTN_2", "type": "PUSH", "line": 3, "colm": 81, "leng": 15, "stxt": "Statistics", "fcod": "TAB_STATS"}`
2. **Flow Logic (PBO & PAI)**:
   ```abap
   PROCESS BEFORE OUTPUT.
     MODULE status_0200.
     CALL SUBSCREEN SUB_MAIN INCLUDING sy-repid gv_subscreen.

   PROCESS AFTER INPUT.
     MODULE exit_0200 AT EXIT-COMMAND.
     CALL SUBSCREEN SUB_MAIN.
     MODULE user_command_0200.
   ```
3. **ABAP Program Code**:
   ```abap
   CONTROLS ts_main TYPE TABSTRIP.
   DATA: gv_subscreen TYPE dynnr VALUE '0210'.

   " In PBO:
   IF ts_main-activetab IS INITIAL.
     ts_main-activetab = 'TAB_OVERVIEW'.
     gv_subscreen      = '0210'.
   ENDIF.

   " In PAI (USER_COMMAND_0200):
   CASE sy-ucomm.
     WHEN 'TAB_OVERVIEW'.
       ts_main-activetab = 'TAB_OVERVIEW'.
       gv_subscreen      = '0210'.
     WHEN 'TAB_STATS'.
       ts_main-activetab = 'TAB_STATS'.
       gv_subscreen      = '0220'.
   ENDCASE.
   ```
   > [!IMPORTANT]
   > `ts_main-activetab` must receive the **Function Code** (`'TAB_OVERVIEW'`), not the element name (`'TAB_BTN_1'`).

---

### 4.4 Table Controls (`TABLECONTROL` / `TABLE_CTRL`)
To build an editable or read-only tabular grid:
1. **Screen JSON**:
   - Container: `{"name": "TC_ITEMS", "type": "TABLECONTROL", "line": 2, "colm": 3, "width": 58, "height": 10}`
   - Columns: Place `TEXT` headers on line 2, and `ENTRYFIELD` cell elements on line 3 within the Table Control column bounds.
2. **Flow Logic**:
   ```abap
   PROCESS BEFORE OUTPUT.
     LOOP WITH CONTROL tc_items.
       MODULE pbo_tc_items.
     ENDLOOP.

   PROCESS AFTER INPUT.
     LOOP WITH CONTROL tc_items.
       MODULE pai_tc_items.
     ENDLOOP.
   ```
3. **ABAP Program Code**:
   ```abap
   CONTROLS tc_items TYPE TABLEVIEW USING SCREEN '0200'.

   MODULE pbo_tc_items OUTPUT.
     READ TABLE gt_items INTO gs_item INDEX tc_items-current_line.
   ENDMODULE.

   MODULE pai_tc_items INPUT.
     MODIFY gt_items FROM gs_item INDEX tc_items-current_line.
   ENDMODULE.
   ```

---

### 4.5 Custom Context Menus (`ON_CTMENU_<name>`)
To bind a custom context menu (right-click) to screen elements:
1. **Screen JSON**: Assign `"context_menu": "CTMENU_OUTPUT"` to display fields, frames, or Table Control cells.
2. **ABAP Form Routine**:
   ```abap
   FORM on_ctmenu_ctmenu_output USING p_menu TYPE REF TO cl_ctmenu.
     p_menu->clear( ). " Clears default GUI status function keys
     p_menu->add_function( fcode = 'APPLY' text = 'Execute Apply Values' ).
     p_menu->add_function( fcode = 'REST'  text = 'Reset Showcase Values' ).
   ENDFORM.
   ```
   > [!NOTE]
   > For editable input fields (`input: true`), SAP GUI's Windows edit control handles right-clicks by displaying standard clipboard options (Cut, Copy, Paste). Custom `ON_CTMENU` handlers operate cleanly on display fields, frames, ALV grids, and Table Controls.

---

### 4.6 Dynamic Screen Modification (`LOOP AT SCREEN`)
To dynamically enable, disable, hide, or protect fields at runtime:
1. **Screen JSON**: Assign modification groups (`"group1": "MOD"`).
2. **PBO Module**:
   ```abap
   MODULE pbo_0100 OUTPUT.
     LOOP AT SCREEN.
       IF screen-group1 = 'MOD'.
         IF gv_chk_active = 'X'.
           screen-input = 1.
         ELSE.
           screen-input = 0.
         ENDIF.
         MODIFY SCREEN.
       ENDIF.
     ENDLOOP.
   ENDMODULE.
   ```

---

### 4.7 Field Validation Chains (`CHAIN ... ENDCHAIN`)
To validate groups of fields and lock invalid fields on error:
```abap
PROCESS AFTER INPUT.
  CHAIN.
    FIELD: GV_INPUT_REQ, GV_INPUT_NUM.
    MODULE check_mandatory_fields ON CHAIN-INPUT.
  ENDCHAIN.
```
If `check_mandatory_fields` executes `MESSAGE ... TYPE 'E'`, SAP GUI locks all other fields and highlights only the chain fields with a red border.

---

### 4.8 GUI Status (`PF-STATUS`) & Titlebar (`TITLEBAR`) Binding

#### A. Automatic CUA Status & Titlebar Provisioning
When any dynpro is pushed via `sap_push(aspect="dynpro", ...)`, `sap-bridge` automatically provisions and activates a clean standard GUI status (`STATUS_<dynnr>`) and titlebar (`TITLE_<dynnr>`) for the target program in the SAP CUA interface table (`EUDB` / `RSMPE`).

Standard function keys pre-configured in `STATUS_<dynnr>`:
- **`BACK`** (`F3`, Normal function)
- **`EXIT`** (`Shift+F3`, Exit-command type `'E'`)
- **`CANC`** (`F12`, Exit-command type `'E'`)
- **`SAVE`** (`Ctrl+S`, Normal function)
- **`EXEC`** (`F8`, Normal function)
- **`REST`** / **`APPLY`** (Reset & Apply functions)

#### B. PBO Module Activation
In the screen's PBO module, activate the status and titlebar:
```abap
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'STATUS_0100'.
  SET TITLEBAR 'TITLE_0100' WITH 'Falken Lagertool - MM Lagerort-Umbuchung (311)'.
ENDMODULE.
```

#### C. PAI Flow Logic & Exit-Command Handling
Always pair `EXIT` and `CANC` with an `AT EXIT-COMMAND` module so users can navigate away even if mandatory fields are empty:

1. **Screen Flow Logic (`.flow.abap`)**:
   ```abap
   PROCESS BEFORE OUTPUT.
     MODULE status_0100.

   PROCESS AFTER INPUT.
     MODULE exit_0100 AT EXIT-COMMAND.
     MODULE user_command_0100.
   ```

2. **ABAP Module Implementation**:
   ```abap
   MODULE exit_0100 INPUT.
     save_ok = ok_code.
     CLEAR ok_code.

     CASE save_ok.
       WHEN 'CANC' OR 'EXIT'.
         LEAVE TO SCREEN 0.
     ENDCASE.
   ENDMODULE.

   MODULE user_command_0100 INPUT.
     save_ok = ok_code.
     CLEAR ok_code.

     CASE save_ok.
       WHEN 'BACK'.
         LEAVE TO SCREEN 0.
       WHEN 'EXEC'.
         " perform execution logic...
     ENDCASE.
   ENDMODULE.
   ```

---

### 4.9 The OK_CODE Command Lifecycle & Screen Painter (`SE51`) Mapping

#### A. Mandatory `OKCODE` Element Binding in Element List
In classic SAP Dynpro architecture (e.g. standard demo `DEMO_DYNPRO` Screen `100`), the Screen Painter element catalog contains a special bottom row of type **`OK`** (line 255).

Every main screen (`type: " "` / `"S"`) and modal dialog (`type: "M"`) **MUST explicitly define an `OKCODE` element** in its `elements` array specifying the exact name of the global ABAP command variable (`sy-ucomm`):

```json
{
  "name": "OK_CODE",
  "type": "OKCODE",
  "line": 255,
  "colm": 1,
  "leng": 20
}
```

If using a custom command variable name in ABAP (e.g. `DATA: gv_ucomm TYPE sy-ucomm.`):
```json
{
  "name": "GV_UCOMM",
  "type": "OKCODE",
  "line": 255,
  "colm": 1,
  "leng": 20
}
```

> [!IMPORTANT]
> **Fail-Fast Validation**:
> - If a main/modal screen definition omits the `OKCODE` element or provides an empty `name`, `sap-bridge` will fail-fast and reject the push with an explicit error directive.
> - Subscreens (`type: "I"` / `"N"`) do **not** have an OK code field in Dynpro architecture and must not include an `OKCODE` element.
> - The variable name declared in `name` is bound directly into `D021S-FNAM`. Ensure this variable is declared in your ABAP program as `DATA: <name> TYPE sy-ucomm.`.

#### B. Canonical PAI OK_CODE Buffer Lifecycle
To prevent residual function codes from re-triggering on subsequent screen events (such as pressing ENTER), always copy and clear `ok_code` immediately at the entry of every PAI module:

```abap
DATA: ok_code TYPE sy-ucomm,
      save_ok TYPE sy-ucomm.

MODULE user_command_0100 INPUT.
  save_ok = ok_code.
  CLEAR ok_code.

  CASE save_ok.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'EXEC'.
      PERFORM execute_business_logic.
  ENDCASE.
ENDMODULE.
```

---

## 5. Standard SAP Reference Programs (`SABAPDEMOS` & `SLIS`)

Rather than copying artificial mock templates, developers should inspect SAP's standard reference implementations shipped in every SAP NetWeaver and S/4HANA system under packages `SABAPDEMOS` and `SLIS`.

You can inspect the exact `.screen.json` element attributes and `.flow.abap` logic of any standard SAP screen on-demand using:
`sap_fetch(aspect="dynpro", object_name="<PROGRAM>:<DYNNR>")`

### A. Standard Dynpro Demos (Package `SABAPDEMOS`)

| Program Name | Screen | Core Features Demonstrated | Inspection Command |
|---|---|---|---|
| **`DEMO_DYNPRO`** | `0100` | Classic screen flow, `OK_CODE` handling, GUI Status, Exit Commands | `sap_fetch(aspect="dynpro", object_name="DEMO_DYNPRO:0100")` |
| **`DEMO_DYNPRO_PUSH_BUTTON`** | `0100` | Pushbuttons, Function codes, dynamic field modifications | `sap_fetch(aspect="dynpro", object_name="DEMO_DYNPRO_PUSH_BUTTON:0100")` |
| **`DEMO_DYNPRO_DROPDOWN_LISTBOX`** | `0100` | Dropdown listbox binding with VRM (`VRM_SET_VALUES`) | `sap_fetch(aspect="dynpro", object_name="DEMO_DYNPRO_DROPDOWN_LISTBOX:0100")` |
| **`DEMO_DYNPRO_STATUS_ICONS`** | `0100` | Dynamic status icons (`ICON_CREATE`) & status fields | `sap_fetch(aspect="dynpro", object_name="DEMO_DYNPRO_STATUS_ICONS:0100")` |
| **`DEMO_DYNPRO_TABLE_CONTROL_1`** | `0100` | Table Control with ABAP flow logic (`LOOP ... WITH CONTROL`) | `sap_fetch(aspect="dynpro", object_name="DEMO_DYNPRO_TABLE_CONTROL_1:0100")` |
| **`DEMO_DYNPRO_TABLE_CONTROL_2`** | `0100` | Editable Table Control with line insertion and deletion | `sap_fetch(aspect="dynpro", object_name="DEMO_DYNPRO_TABLE_CONTROL_2:0100")` |
| **`DEMO_DYNPRO_TABSTRIP_LOCAL`** | `0100` | Tabstrip Control with local subscreen areas and paging | `sap_fetch(aspect="dynpro", object_name="DEMO_DYNPRO_TABSTRIP_LOCAL:0100")` |
| **`DEMO_DYNPRO_SUBSCREENS`** | `0100` | Dynamic subscreen inclusion (`CALL SUBSCREEN`) | `sap_fetch(aspect="dynpro", object_name="DEMO_DYNPRO_SUBSCREENS:0100")` |
| **`DEMO_DYNPRO_CUSTOM_CONTAINER`**| `0100` | Custom Container embedding `CL_GUI_ALV_GRID` / HTML viewer | `sap_fetch(aspect="dynpro", object_name="DEMO_DYNPRO_CUSTOM_CONTAINER:0100")` |

### B. Standard ALV Grid & List Demos (Package `SLIS`)

| Program Name | Core Features Demonstrated | Inspection Notes |
|---|---|---|
| **`BCALV_GRID_01`** | Basic ALV Grid display with standard toolbar and field catalog | Full container-based ALV |
| **`BCALV_GRID_EDIT`** | Editable ALV Grid with cell event handlers and change logs | Interactive data editing |
| **`BCALV_TEST_FULLSCREEN`** | Fullscreen ALV report (`REUSE_ALV_GRID_DISPLAY`) | High-density operational lists |

### C. Authentic SAP GUI Screen Design Best Practices

1. **Match Real Business Ergonomics**: Design screens strictly around the operational workflow (e.g. Header + Item grid for documents, Input parameter fields with F4 helps for transactions). Avoid creating artificial multi-box layout frames unless logically grouping distinct entities.
2. **Standard PF-STATUS Function Keys**:
   - `F3` (`BACK`): Navigate back to the previous screen or selection screen.
   - `Shift+F3` (`EXIT`): Exit the program completely.
   - `F12` (`CANC`): Cancel active transaction and leave screen.
   - `Ctrl+S` (`SAVE`): Save or post database changes.
   - `F8` (`EXEC` / `EXECUTE`): Execute selection or calculation.
3. **Clean Flow Logic**: Keep dynpro flow logic minimal (`MODULE status_xxxx OUTPUT`, `MODULE exit_xxxx AT EXIT-COMMAND`, `MODULE user_command_xxxx INPUT`), delegating all business logic to clean modular local classes or form routines.

