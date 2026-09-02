*"* use this source file for any type of declarations (class
*"* definitions, interfaces or type declarations) you need for
*"* components in the private section

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

CLASS lcl_prog_handler DEFINITION INHERITING FROM zcl_sap_dev_object_hdlr.
  PUBLIC SECTION.
    METHODS read_translations REDEFINITION.
    METHODS push_translations REDEFINITION.
ENDCLASS.

CLASS lcl_dtel_handler DEFINITION INHERITING FROM zcl_sap_dev_object_hdlr.
  PUBLIC SECTION.
    METHODS read_translations REDEFINITION.
    METHODS push_translations REDEFINITION.
ENDCLASS.

CLASS lcl_doma_handler DEFINITION INHERITING FROM zcl_sap_dev_object_hdlr.
  PUBLIC SECTION.
    METHODS read_translations REDEFINITION.
    METHODS push_translations REDEFINITION.
ENDCLASS.

CLASS lcl_clas_handler DEFINITION INHERITING FROM zcl_sap_dev_object_hdlr.
  PUBLIC SECTION.
    METHODS read_translations REDEFINITION.
    METHODS push_translations REDEFINITION.
ENDCLASS.

CLASS lcl_msag_handler DEFINITION INHERITING FROM zcl_sap_dev_object_hdlr.
  PUBLIC SECTION.
    METHODS read_translations REDEFINITION.
    METHODS push_translations REDEFINITION.
ENDCLASS.

CLASS lcl_ttyp_handler DEFINITION INHERITING FROM zcl_sap_dev_object_hdlr.
  PUBLIC SECTION.
    METHODS read_translations REDEFINITION.
    METHODS push_translations REDEFINITION.
ENDCLASS.

CLASS lcl_tabl_handler DEFINITION INHERITING FROM zcl_sap_dev_object_hdlr.
  PUBLIC SECTION.
    METHODS read_translations REDEFINITION.
    METHODS push_translations REDEFINITION.
ENDCLASS.

CLASS lcl_tran_handler DEFINITION INHERITING FROM zcl_sap_dev_object_hdlr.
  PUBLIC SECTION.
    METHODS fetch_metadata REDEFINITION.
    METHODS push_metadata REDEFINITION.
ENDCLASS.

CLASS lcl_handler_factory DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS get
      IMPORTING
        iv_type_key       TYPE string
      RETURNING
        VALUE(ro_handler) TYPE REF TO zcl_sap_dev_object_hdlr.
ENDCLASS.
