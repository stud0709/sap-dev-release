*"* use this source file for any type of declarations (class
*"* definitions, interfaces or type declarations) you need for
*"* components in the private section

"----------------------------------------------------------------------
" 1. Translation Writer Types & Definition
"----------------------------------------------------------------------
TYPES ty_langs TYPE TABLE OF sy-langu WITH DEFAULT KEY.

TYPES: BEGIN OF ty_dtel_texts,
         description  TYPE string,
         heading      TYPE string,
         label_short  TYPE string,
         label_medium TYPE string,
         label_long   TYPE string,
       END OF ty_dtel_texts.

TYPES: BEGIN OF ty_doma_val,
         val TYPE string,
         txt TYPE string,
       END OF ty_doma_val.
TYPES: BEGIN OF ty_doma_texts,
         description  TYPE string,
         fixed_values TYPE TABLE OF ty_doma_val WITH DEFAULT KEY,
       END OF ty_doma_texts.

TYPES: BEGIN OF ty_clas_meth,
         name TYPE string,
         txt  TYPE string,
       END OF ty_clas_meth.
TYPES: BEGIN OF ty_clas_texts,
         description TYPE string,
         methods     TYPE TABLE OF ty_clas_meth WITH DEFAULT KEY,
       END OF ty_clas_texts.

TYPES: BEGIN OF ty_msag_msg,
         msgnr TYPE string,
         text  TYPE string,
       END OF ty_msag_msg.
TYPES: BEGIN OF ty_msag_texts,
         description TYPE string,
         messages    TYPE TABLE OF ty_msag_msg WITH DEFAULT KEY,
       END OF ty_msag_texts.

TYPES: BEGIN OF ty_ttyp_texts,
         description TYPE string,
       END OF ty_ttyp_texts.

TYPES: BEGIN OF ty_tabl_field,
         fieldname TYPE string,
         txt       TYPE string,
       END OF ty_tabl_field.
TYPES: BEGIN OF ty_tabl_texts,
         description TYPE string,
         fields      TYPE TABLE OF ty_tabl_field WITH DEFAULT KEY,
       END OF ty_tabl_texts.

CLASS lcl_translation_writer DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS handle_sap_push_translations
      IMPORTING
        !iv_payload TYPE string
        !io_rpc     TYPE REF TO zcl_sap_dev_rpc
      RETURNING
        VALUE(rv_json) TYPE string.

    CLASS-METHODS push_prog_translations
      IMPORTING
        !iv_object_name TYPE string
        !iv_payload     TYPE string
      RETURNING
        VALUE(rv_json)  TYPE string.

    CLASS-METHODS push_dtel_translations
      IMPORTING
        !iv_object_name TYPE string
        !iv_payload     TYPE string
      RETURNING
        VALUE(rv_json)  TYPE string.

    CLASS-METHODS push_doma_translations
      IMPORTING
        !iv_object_name TYPE string
        !iv_payload     TYPE string
      RETURNING
        VALUE(rv_json)  TYPE string.

    CLASS-METHODS push_clas_translations
      IMPORTING
        !iv_object_name TYPE string
        !iv_payload     TYPE string
      RETURNING
        VALUE(rv_json)  TYPE string.

    CLASS-METHODS push_msag_translations
      IMPORTING
        !iv_object_name TYPE string
        !iv_payload     TYPE string
      RETURNING
        VALUE(rv_json)  TYPE string.

    CLASS-METHODS push_ttyp_translations
      IMPORTING
        !iv_object_name TYPE string
        !iv_payload     TYPE string
      RETURNING
        VALUE(rv_json)  TYPE string.

    CLASS-METHODS push_tabl_translations
      IMPORTING
        !iv_object_name TYPE string
        !iv_payload     TYPE string
      RETURNING
        VALUE(rv_json)  TYPE string.
ENDCLASS.

"----------------------------------------------------------------------
" 2. Customizing Runner Definition
"----------------------------------------------------------------------
CLASS lcl_customizing_runner DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS handle_maintain_custom
      IMPORTING
        !iv_payload TYPE string
        !io_rpc     TYPE REF TO zcl_sap_dev_rpc
      RETURNING
        VALUE(rv_json) TYPE string.

    CLASS-METHODS run_direct_api
      IMPORTING
        !iv_viewname     TYPE tabname
        !iv_action       TYPE string
        !iv_entries_json TYPE string
        !iv_trkorr       TYPE trkorr
        !io_rpc          TYPE REF TO zcl_sap_dev_rpc
      RETURNING
        VALUE(rv_json)   TYPE string.
ENDCLASS.

"----------------------------------------------------------------------
" 3. Dynpro Engine Types & Definition
"----------------------------------------------------------------------
TYPES: BEGIN OF ty_dynpro_field_in,
         name              TYPE string,
         type              TYPE string,
         format            TYPE string,
         line              TYPE i,
         colm              TYPE i,
         leng              TYPE i,
         height            TYPE i,
         width             TYPE i,
         vis_leng          TYPE i,
         stxt              TYPE string,
         text              TYPE string,
         value             TYPE string,
         valu              TYPE string,
         fcod              TYPE string,
         functype          TYPE string,
         input             TYPE string,
         output            TYPE string,
         required          TYPE string,
         dropdown          TYPE string,
         radio_group       TYPE string,
         control_id        TYPE string,
         subscreen_area    TYPE string,
         search_help       TYPE string,
         poss_entry        TYPE string,
         param_id          TYPE string,
         conv_exit         TYPE string,
         context_menu      TYPE string,
         context_menu_prog TYPE string,
         intensified       TYPE string,
         invisible         TYPE string,
         lowercase         TYPE string,
         right_justified   TYPE string,
         leading_zeros     TYPE string,
         scrollable        TYPE string,
         scroll            TYPE string,
         icon              TYPE string,
         double_click      TYPE string,
         recommended       TYPE string,
         min_lines         TYPE i,
         min_cols          TYPE i,
         grp1              TYPE string,
         grp2              TYPE string,
         grp3              TYPE string,
         grp4              TYPE string,
         group1            TYPE string,
         group2            TYPE string,
         group3            TYPE string,
         group4            TYPE string,
         ltyp              TYPE string,
         flg1              TYPE string,
         flg2              TYPE string,
         flg3              TYPE string,
         fmb1              TYPE string,
         fmb2              TYPE string,
         fill              TYPE string,
         auth              TYPE string,
         ref_field         TYPE string,
         res1              TYPE string,
         res2              TYPE string,
       END OF ty_dynpro_field_in.

TYPES ty_dynpro_fields_in TYPE STANDARD TABLE OF ty_dynpro_field_in WITH DEFAULT KEY.
TYPES ty_d021s_tab TYPE STANDARD TABLE OF d021s WITH DEFAULT KEY.

TYPES: BEGIN OF ty_dynpro_header_in,
         prog   TYPE string,
         dnum   TYPE string,
         type   TYPE string,
         linc   TYPE i,
         colc   TYPE i,
         next   TYPE string,
         spra   TYPE string,
         dtxt   TYPE string,
         cursor TYPE string,
         dgrp   TYPE string,
       END OF ty_dynpro_header_in.

TYPES: BEGIN OF ty_dynpro_payload,
         program           TYPE program,
         screen            TYPE d020s-dnum,
         transport_request TYPE trkorr,
         header            TYPE ty_dynpro_header_in,
         fields            TYPE STANDARD TABLE OF ty_dynpro_field_in WITH DEFAULT KEY,
         elements          TYPE STANDARD TABLE OF ty_dynpro_field_in WITH DEFAULT KEY,
         flow_logic        TYPE dyn_flowlist,
       END OF ty_dynpro_payload.

CLASS lcl_dynpro_engine DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS push_dynpro
      IMPORTING
        !iv_payload    TYPE string
      RETURNING
        VALUE(rv_json) TYPE string.

    CLASS-METHODS check_dynpro_syntax
      IMPORTING
        !iv_payload    TYPE string
      RETURNING
        VALUE(rv_json) TYPE string.

    CLASS-METHODS build_dynpro_fields
      IMPORTING
        it_fields        TYPE ty_dynpro_fields_in
      EXPORTING
        et_diag          TYPE string_table
      RETURNING
        VALUE(rt_fields) TYPE ty_d021s_tab.

    CLASS-METHODS analyze_dynpro
      IMPORTING
        !iv_payload    TYPE string
      RETURNING
        VALUE(rv_json) TYPE string.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_elem_meta,
             name TYPE d021s-fnam,
             line TYPE i,
             coln TYPE i,
             res1 TYPE d021s-res1,
             fld  TYPE ty_dynpro_field_in,
           END OF ty_elem_meta.
    TYPES ty_elem_meta_tab TYPE STANDARD TABLE OF ty_elem_meta WITH DEFAULT KEY.

    CLASS-METHODS build_field_text
      IMPORTING
        !is_inp   TYPE ty_dynpro_field_in
      CHANGING
        !cs_chfld TYPE scr_chfld
        !cs_res1  TYPE d021s_res1.

    CLASS-METHODS build_field_pushbutton
      IMPORTING
        !is_inp   TYPE ty_dynpro_field_in
        !iv_tabix TYPE i
      CHANGING
        !cs_chfld TYPE scr_chfld
        !cs_res1  TYPE d021s_res1.

    CLASS-METHODS build_field_choice
      IMPORTING
        !is_inp      TYPE ty_dynpro_field_in
        !iv_type     TYPE string
        !iv_format   TYPE string
        !lv_is_input TYPE abap_bool
        !iv_tabix    TYPE i
      CHANGING
        !cs_chfld    TYPE scr_chfld
        !cs_res1     TYPE d021s_res1.

    CLASS-METHODS build_field_container
      IMPORTING
        !is_inp   TYPE ty_dynpro_field_in
        !iv_type  TYPE string
      CHANGING
        !cs_chfld TYPE scr_chfld
        !cs_res1  TYPE d021s_res1.

    CLASS-METHODS build_field_entry
      IMPORTING
        !is_inp       TYPE ty_dynpro_field_in
        !iv_type      TYPE string
        !iv_format    TYPE string
        !lv_is_intens TYPE abap_bool
        !lv_is_input  TYPE abap_bool
        !lv_is_lower  TYPE abap_bool
        !lv_is_req    TYPE abap_bool
        !lv_is_invis  TYPE abap_bool
        !lv_is_right  TYPE abap_bool
        !lv_is_zeros  TYPE abap_bool
      CHANGING
        !cs_chfld     TYPE scr_chfld
        !cs_res1      TYPE d021s_res1.

    CLASS-METHODS apply_raw_bitmasks
      IMPORTING
        !it_meta   TYPE ty_elem_meta_tab
      CHANGING
        !ct_fields TYPE ty_d021s_tab.
ENDCLASS.

"----------------------------------------------------------------------
" 4. CUA Engine Definition
"----------------------------------------------------------------------
CLASS lcl_cua_engine DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS generate_cua_status
      IMPORTING
        !iv_payload    TYPE string
      RETURNING
        VALUE(rv_json) TYPE string.
ENDCLASS.
