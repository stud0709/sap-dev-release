*"* use this source file for the definition and implementation of
*"* local helper classes, interface implementations and type
*"* declarations

CLASS lcl_handler_factory IMPLEMENTATION.
  METHOD get.
    CASE iv_type_key.
      WHEN 'PROG' OR 'REPT'.
        CREATE OBJECT ro_handler TYPE lcl_prog_handler.
      WHEN 'DTEL'.
        CREATE OBJECT ro_handler TYPE lcl_dtel_handler.
      WHEN 'DOMA'.
        CREATE OBJECT ro_handler TYPE lcl_doma_handler.
      WHEN 'CLAS'.
        CREATE OBJECT ro_handler TYPE lcl_clas_handler.
      WHEN 'MSAG'.
        CREATE OBJECT ro_handler TYPE lcl_msag_handler.
      WHEN 'TTYP'.
        CREATE OBJECT ro_handler TYPE lcl_ttyp_handler.
      WHEN 'TABL'.
        CREATE OBJECT ro_handler TYPE lcl_tabl_handler.
      WHEN 'TRAN'.
        CREATE OBJECT ro_handler TYPE lcl_tran_handler.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_prog_handler IMPLEMENTATION.
  METHOD read_translations.
    DATA: lt_components TYPE cl_abap_structdescr=>component_table,
          ls_comp       TYPE cl_abap_structdescr=>component,
          lo_struct     TYPE REF TO cl_abap_structdescr,
          lo_data       TYPE REF TO data.
    FIELD-SYMBOLS: <ls_trans_map> TYPE any.

    DATA: lt_textpool_dummy TYPE textpool_table,
          lo_type           TYPE REF TO cl_abap_datadescr.
    lo_type = CAST cl_abap_datadescr( cl_abap_typedescr=>describe_by_data( lt_textpool_dummy ) ).

    LOOP AT it_langs INTO DATA(lv_langu).
      ls_comp-name = |{ lv_langu }|.
      ls_comp-type = lo_type.
      APPEND ls_comp TO lt_components.
    ENDLOOP.
    lo_struct = cl_abap_structdescr=>create( lt_components ).
    CREATE DATA lo_data TYPE HANDLE lo_struct.
    ASSIGN lo_data->* TO <ls_trans_map>.

    LOOP AT it_langs INTO lv_langu.
      ASSIGN COMPONENT |{ lv_langu }| OF STRUCTURE <ls_trans_map> TO FIELD-SYMBOL(<lv_lang_struct>).
      IF sy-subrc = 0.
        DATA: lt_textpool TYPE textpool_table,
              lv_progname TYPE program.
        lv_progname = iv_object_name.
        READ TEXTPOOL lv_progname INTO lt_textpool LANGUAGE lv_langu.
        IF lt_textpool IS NOT INITIAL.
          <lv_lang_struct> = lt_textpool.
        ENDIF.
      ENDIF.
    ENDLOOP.

    TYPES: BEGIN OF ty_envelope,
             object_name     TYPE string,
             object_type     TYPE string,
             master_language TYPE string,
             translations    TYPE REF TO data,
           END OF ty_envelope.
    DATA: ls_env TYPE ty_envelope.
    ls_env-object_name     = iv_object_name.
    ls_env-object_type     = 'PROG'.
    ls_env-master_language = iv_masterlang.
    ls_env-translations    = lo_data.
    rv_json = /ui2/cl_json=>serialize( data = ls_env ).
  ENDMETHOD.

  METHOD push_translations.
    DATA: lv_class  TYPE string VALUE 'ZCL_SAP_DEV_DEV_HELPER',
          lv_method TYPE string VALUE 'DISPATCH'.
    cl_abap_typedescr=>describe_by_name(
      EXPORTING  p_name         = lv_class
      RECEIVING  p_descr_ref    = DATA(lo_descr)
      EXCEPTIONS type_not_found = 1 ).
    IF sy-subrc = 0.
      TRY.
          CALL METHOD (lv_class)=>(lv_method)
            EXPORTING
              iv_action      = 'PUSH_PROG_TRANSLATIONS'
              iv_object_name = iv_object_name
              iv_payload     = iv_payload
            RECEIVING
              rv_json        = rv_json.
        CATCH cx_root INTO DATA(lx_root).
          rv_json = |\{"error": "Failed to execute dev helper: { escape( val = lx_root->get_text( ) format = cl_abap_format=>e_json_string ) }"\}|.
      ENDTRY.
    ELSE.
      rv_json = '{"error": "Write operations are disabled on this system."}'.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_dtel_handler IMPLEMENTATION.
  METHOD read_translations.
    DATA: lt_components TYPE cl_abap_structdescr=>component_table,
          ls_comp       TYPE cl_abap_structdescr=>component,
          lo_struct     TYPE REF TO cl_abap_structdescr,
          lo_data       TYPE REF TO data.
    FIELD-SYMBOLS: <ls_trans_map> TYPE any.

    DATA: ls_dtel_dummy TYPE ty_dtel_texts,
          lo_type       TYPE REF TO cl_abap_datadescr.
    lo_type = CAST cl_abap_datadescr( cl_abap_typedescr=>describe_by_data( ls_dtel_dummy ) ).

    LOOP AT it_langs INTO DATA(lv_langu).
      ls_comp-name = |{ lv_langu }|.
      ls_comp-type = lo_type.
      APPEND ls_comp TO lt_components.
    ENDLOOP.
    lo_struct = cl_abap_structdescr=>create( lt_components ).
    CREATE DATA lo_data TYPE HANDLE lo_struct.
    ASSIGN lo_data->* TO <ls_trans_map>.

    DATA: lv_ddobjname TYPE ddobjname.
    lv_ddobjname = iv_object_name.

    LOOP AT it_langs INTO lv_langu.
      ASSIGN COMPONENT |{ lv_langu }| OF STRUCTURE <ls_trans_map> TO FIELD-SYMBOL(<lv_lang_struct>).
      IF sy-subrc = 0.
        DATA: ls_dd04v TYPE dd04v.
        CALL FUNCTION 'DDIF_DTEL_GET'
          EXPORTING
            name     = lv_ddobjname
            langu    = lv_langu
          IMPORTING
            dd04v_wa = ls_dd04v
          EXCEPTIONS
            OTHERS   = 1.
        IF sy-subrc = 0.
          DATA: ls_dtel_texts TYPE ty_dtel_texts.
          ls_dtel_texts-description  = ls_dd04v-ddtext.
          ls_dtel_texts-heading      = ls_dd04v-reptext.
          ls_dtel_texts-label_short  = ls_dd04v-scrtext_s.
          ls_dtel_texts-label_medium = ls_dd04v-scrtext_m.
          ls_dtel_texts-label_long   = ls_dd04v-scrtext_l.
          <lv_lang_struct> = ls_dtel_texts.
        ENDIF.
      ENDIF.
    ENDLOOP.

    TYPES: BEGIN OF ty_envelope,
             object_name     TYPE string,
             object_type     TYPE string,
             master_language TYPE string,
             translations    TYPE REF TO data,
           END OF ty_envelope.
    DATA: ls_env TYPE ty_envelope.
    ls_env-object_name     = iv_object_name.
    ls_env-object_type     = 'DTEL'.
    ls_env-master_language = iv_masterlang.
    ls_env-translations    = lo_data.
    rv_json = /ui2/cl_json=>serialize( data = ls_env ).
  ENDMETHOD.

  METHOD push_translations.
    DATA: lv_class  TYPE string VALUE 'ZCL_SAP_DEV_DEV_HELPER',
          lv_method TYPE string VALUE 'DISPATCH'.
    cl_abap_typedescr=>describe_by_name(
      EXPORTING  p_name         = lv_class
      RECEIVING  p_descr_ref    = DATA(lo_descr)
      EXCEPTIONS type_not_found = 1 ).
    IF sy-subrc = 0.
      TRY.
          CALL METHOD (lv_class)=>(lv_method)
            EXPORTING
              iv_action      = 'PUSH_DTEL_TRANSLATIONS'
              iv_object_name = iv_object_name
              iv_payload     = iv_payload
            RECEIVING
              rv_json        = rv_json.
        CATCH cx_root INTO DATA(lx_root).
          rv_json = |\{"error": "Failed to execute dev helper: { escape( val = lx_root->get_text( ) format = cl_abap_format=>e_json_string ) }"\}|.
      ENDTRY.
    ELSE.
      rv_json = '{"error": "Write operations are disabled on this system."}'.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_doma_handler IMPLEMENTATION.
  METHOD read_translations.
    DATA: lt_components TYPE cl_abap_structdescr=>component_table,
          ls_comp       TYPE cl_abap_structdescr=>component,
          lo_struct     TYPE REF TO cl_abap_structdescr,
          lo_data       TYPE REF TO data.
    FIELD-SYMBOLS: <ls_trans_map> TYPE any.

    DATA: ls_doma_dummy TYPE ty_doma_texts,
          lo_type       TYPE REF TO cl_abap_datadescr.
    lo_type = CAST cl_abap_datadescr( cl_abap_typedescr=>describe_by_data( ls_doma_dummy ) ).

    LOOP AT it_langs INTO DATA(lv_langu).
      ls_comp-name = |{ lv_langu }|.
      ls_comp-type = lo_type.
      APPEND ls_comp TO lt_components.
    ENDLOOP.
    lo_struct = cl_abap_structdescr=>create( lt_components ).
    CREATE DATA lo_data TYPE HANDLE lo_struct.
    ASSIGN lo_data->* TO <ls_trans_map>.

    DATA: lv_ddobjname TYPE ddobjname.
    lv_ddobjname = iv_object_name.

    LOOP AT it_langs INTO lv_langu.
      ASSIGN COMPONENT |{ lv_langu }| OF STRUCTURE <ls_trans_map> TO FIELD-SYMBOL(<lv_lang_struct>).
      IF sy-subrc = 0.
        DATA: ls_dd01v     TYPE dd01v,
              lt_dd07v_tab TYPE TABLE OF dd07v.
        CLEAR lt_dd07v_tab.
        CALL FUNCTION 'DDIF_DOMA_GET'
          EXPORTING
            name      = lv_ddobjname
            langu     = lv_langu
          IMPORTING
            dd01v_wa  = ls_dd01v
          TABLES
            dd07v_tab = lt_dd07v_tab
          EXCEPTIONS
            OTHERS    = 1.
        IF sy-subrc = 0.
          DATA: ls_doma_texts TYPE ty_doma_texts.
          CLEAR ls_doma_texts.
          ls_doma_texts-description = ls_dd01v-ddtext.
          LOOP AT lt_dd07v_tab INTO DATA(ls_dd07v).
            APPEND VALUE ty_doma_val( val = ls_dd07v-domval_ld txt = ls_dd07v-ddtext ) TO ls_doma_texts-fixed_values.
          ENDLOOP.
          <lv_lang_struct> = ls_doma_texts.
        ENDIF.
      ENDIF.
    ENDLOOP.

    TYPES: BEGIN OF ty_envelope,
             object_name     TYPE string,
             object_type     TYPE string,
             master_language TYPE string,
             translations    TYPE REF TO data,
           END OF ty_envelope.
    DATA: ls_env TYPE ty_envelope.
    ls_env-object_name     = iv_object_name.
    ls_env-object_type     = 'DOMA'.
    ls_env-master_language = iv_masterlang.
    ls_env-translations    = lo_data.
    rv_json = /ui2/cl_json=>serialize( data = ls_env ).
  ENDMETHOD.

  METHOD push_translations.
    DATA: lv_class  TYPE string VALUE 'ZCL_SAP_DEV_DEV_HELPER',
          lv_method TYPE string VALUE 'DISPATCH'.
    cl_abap_typedescr=>describe_by_name(
      EXPORTING  p_name         = lv_class
      RECEIVING  p_descr_ref    = DATA(lo_descr)
      EXCEPTIONS type_not_found = 1 ).
    IF sy-subrc = 0.
      TRY.
          CALL METHOD (lv_class)=>(lv_method)
            EXPORTING
              iv_action      = 'PUSH_DOMA_TRANSLATIONS'
              iv_object_name = iv_object_name
              iv_payload     = iv_payload
            RECEIVING
              rv_json        = rv_json.
        CATCH cx_root INTO DATA(lx_root).
          rv_json = |\{"error": "Failed to execute dev helper: { escape( val = lx_root->get_text( ) format = cl_abap_format=>e_json_string ) }"\}|.
      ENDTRY.
    ELSE.
      rv_json = '{"error": "Write operations are disabled on this system."}'.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_clas_handler IMPLEMENTATION.
  METHOD read_translations.
    DATA: lt_components TYPE cl_abap_structdescr=>component_table,
          ls_comp       TYPE cl_abap_structdescr=>component,
          lo_struct     TYPE REF TO cl_abap_structdescr,
          lo_data       TYPE REF TO data.
    FIELD-SYMBOLS: <ls_trans_map> TYPE any.

    DATA: ls_clas_dummy TYPE ty_clas_texts,
          lo_type       TYPE REF TO cl_abap_datadescr.
    lo_type = CAST cl_abap_datadescr( cl_abap_typedescr=>describe_by_data( ls_clas_dummy ) ).

    LOOP AT it_langs INTO DATA(lv_langu).
      ls_comp-name = |{ lv_langu }|.
      ls_comp-type = lo_type.
      APPEND ls_comp TO lt_components.
    ENDLOOP.
    lo_struct = cl_abap_structdescr=>create( lt_components ).
    CREATE DATA lo_data TYPE HANDLE lo_struct.
    ASSIGN lo_data->* TO <ls_trans_map>.

    LOOP AT it_langs INTO lv_langu.
      ASSIGN COMPONENT |{ lv_langu }| OF STRUCTURE <ls_trans_map> TO FIELD-SYMBOL(<lv_lang_struct>).
      IF sy-subrc = 0.
        DATA: ls_clas_texts TYPE ty_clas_texts.
        CLEAR ls_clas_texts.
        SELECT SINGLE descript FROM seoclasstx INTO @ls_clas_texts-description
          WHERE clsname = @iv_object_name AND langu = @lv_langu.

        SELECT cmpname AS name, descript AS txt FROM seocompotx
          INTO CORRESPONDING FIELDS OF TABLE @ls_clas_texts-methods
          WHERE clsname = @iv_object_name AND langu = @lv_langu.
        <lv_lang_struct> = ls_clas_texts.
      ENDIF.
    ENDLOOP.

    TYPES: BEGIN OF ty_envelope,
             object_name     TYPE string,
             object_type     TYPE string,
             master_language TYPE string,
             translations    TYPE REF TO data,
           END OF ty_envelope.
    DATA: ls_env TYPE ty_envelope.
    ls_env-object_name     = iv_object_name.
    ls_env-object_type     = 'CLAS'.
    ls_env-master_language = iv_masterlang.
    ls_env-translations    = lo_data.
    rv_json = /ui2/cl_json=>serialize( data = ls_env ).
  ENDMETHOD.

  METHOD push_translations.
    DATA: lv_class  TYPE string VALUE 'ZCL_SAP_DEV_DEV_HELPER',
          lv_method TYPE string VALUE 'DISPATCH'.
    cl_abap_typedescr=>describe_by_name(
      EXPORTING  p_name         = lv_class
      RECEIVING  p_descr_ref    = DATA(lo_descr)
      EXCEPTIONS type_not_found = 1 ).
    IF sy-subrc = 0.
      TRY.
          CALL METHOD (lv_class)=>(lv_method)
            EXPORTING
              iv_action      = 'PUSH_CLAS_TRANSLATIONS'
              iv_object_name = iv_object_name
              iv_payload     = iv_payload
            RECEIVING
              rv_json        = rv_json.
        CATCH cx_root INTO DATA(lx_root).
          rv_json = |\{"error": "Failed to execute dev helper: { escape( val = lx_root->get_text( ) format = cl_abap_format=>e_json_string ) }"\}|.
      ENDTRY.
    ELSE.
      rv_json = '{"error": "Write operations are disabled on this system."}'.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_msag_handler IMPLEMENTATION.
  METHOD read_translations.
    DATA: lt_components TYPE cl_abap_structdescr=>component_table,
          ls_comp       TYPE cl_abap_structdescr=>component,
          lo_struct     TYPE REF TO cl_abap_structdescr,
          lo_data       TYPE REF TO data.
    FIELD-SYMBOLS: <ls_trans_map> TYPE any.

    DATA: ls_msag_dummy TYPE ty_msag_texts,
          lo_type       TYPE REF TO cl_abap_datadescr.
    lo_type = CAST cl_abap_datadescr( cl_abap_typedescr=>describe_by_data( ls_msag_dummy ) ).

    LOOP AT it_langs INTO DATA(lv_langu).
      ls_comp-name = |{ lv_langu }|.
      ls_comp-type = lo_type.
      APPEND ls_comp TO lt_components.
    ENDLOOP.
    lo_struct = cl_abap_structdescr=>create( lt_components ).
    CREATE DATA lo_data TYPE HANDLE lo_struct.
    ASSIGN lo_data->* TO <ls_trans_map>.

    LOOP AT it_langs INTO lv_langu.
      ASSIGN COMPONENT |{ lv_langu }| OF STRUCTURE <ls_trans_map> TO FIELD-SYMBOL(<lv_lang_struct>).
      IF sy-subrc = 0.
        DATA: ls_msag_texts TYPE ty_msag_texts.
        CLEAR ls_msag_texts.
        SELECT SINGLE stext FROM t100t INTO @ls_msag_texts-description
          WHERE arbgb = @iv_object_name AND sprsl = @lv_langu.

        SELECT msgnr, text FROM t100
          INTO CORRESPONDING FIELDS OF TABLE @ls_msag_texts-messages
          WHERE arbgb = @iv_object_name AND sprsl = @lv_langu.
        <lv_lang_struct> = ls_msag_texts.
      ENDIF.
    ENDLOOP.

    TYPES: BEGIN OF ty_envelope,
             object_name     TYPE string,
             object_type     TYPE string,
             master_language TYPE string,
             translations    TYPE REF TO data,
           END OF ty_envelope.
    DATA: ls_env TYPE ty_envelope.
    ls_env-object_name     = iv_object_name.
    ls_env-object_type     = 'MSAG'.
    ls_env-master_language = iv_masterlang.
    ls_env-translations    = lo_data.
    rv_json = /ui2/cl_json=>serialize( data = ls_env ).
  ENDMETHOD.

  METHOD push_translations.
    DATA: lv_class  TYPE string VALUE 'ZCL_SAP_DEV_DEV_HELPER',
          lv_method TYPE string VALUE 'DISPATCH'.
    cl_abap_typedescr=>describe_by_name(
      EXPORTING  p_name         = lv_class
      RECEIVING  p_descr_ref    = DATA(lo_descr)
      EXCEPTIONS type_not_found = 1 ).
    IF sy-subrc = 0.
      TRY.
          CALL METHOD (lv_class)=>(lv_method)
            EXPORTING
              iv_action      = 'PUSH_MSAG_TRANSLATIONS'
              iv_object_name = iv_object_name
              iv_payload     = iv_payload
            RECEIVING
              rv_json        = rv_json.
        CATCH cx_root INTO DATA(lx_root).
          rv_json = |\{"error": "Failed to execute dev helper: { escape( val = lx_root->get_text( ) format = cl_abap_format=>e_json_string ) }"\}|.
      ENDTRY.
    ELSE.
      rv_json = '{"error": "Write operations are disabled on this system."}'.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_ttyp_handler IMPLEMENTATION.
  METHOD read_translations.
    DATA: lt_components TYPE cl_abap_structdescr=>component_table,
          ls_comp       TYPE cl_abap_structdescr=>component,
          lo_struct     TYPE REF TO cl_abap_structdescr,
          lo_data       TYPE REF TO data.
    FIELD-SYMBOLS: <ls_trans_map> TYPE any.

    DATA: ls_ttyp_dummy TYPE ty_ttyp_texts,
          lo_type       TYPE REF TO cl_abap_datadescr.
    lo_type = CAST cl_abap_datadescr( cl_abap_typedescr=>describe_by_data( ls_ttyp_dummy ) ).

    LOOP AT it_langs INTO DATA(lv_langu).
      ls_comp-name = |{ lv_langu }|.
      ls_comp-type = lo_type.
      APPEND ls_comp TO lt_components.
    ENDLOOP.
    lo_struct = cl_abap_structdescr=>create( lt_components ).
    CREATE DATA lo_data TYPE HANDLE lo_struct.
    ASSIGN lo_data->* TO <ls_trans_map>.

    DATA: lv_ddobjname TYPE ddobjname.
    lv_ddobjname = iv_object_name.

    LOOP AT it_langs INTO lv_langu.
      ASSIGN COMPONENT |{ lv_langu }| OF STRUCTURE <ls_trans_map> TO FIELD-SYMBOL(<lv_lang_struct>).
      IF sy-subrc = 0.
        DATA: ls_dd40v TYPE dd40v.
        CALL FUNCTION 'DDIF_TTYP_GET'
          EXPORTING
            name     = lv_ddobjname
            langu    = lv_langu
          IMPORTING
            dd40v_wa = ls_dd40v
          EXCEPTIONS
            OTHERS   = 1.
        IF sy-subrc = 0.
          DATA: ls_ttyp_texts TYPE ty_ttyp_texts.
          CLEAR ls_ttyp_texts.
          ls_ttyp_texts-description = ls_dd40v-ddtext.
          <lv_lang_struct> = ls_ttyp_texts.
        ENDIF.
      ENDIF.
    ENDLOOP.

    TYPES: BEGIN OF ty_envelope,
             object_name     TYPE string,
             object_type     TYPE string,
             master_language TYPE string,
             translations    TYPE REF TO data,
           END OF ty_envelope.
    DATA: ls_env TYPE ty_envelope.
    ls_env-object_name     = iv_object_name.
    ls_env-object_type     = 'TTYP'.
    ls_env-master_language = iv_masterlang.
    ls_env-translations    = lo_data.
    rv_json = /ui2/cl_json=>serialize( data = ls_env ).
  ENDMETHOD.

  METHOD push_translations.
    DATA: lv_class  TYPE string VALUE 'ZCL_SAP_DEV_DEV_HELPER',
          lv_method TYPE string VALUE 'DISPATCH'.
    cl_abap_typedescr=>describe_by_name(
      EXPORTING  p_name         = lv_class
      RECEIVING  p_descr_ref    = DATA(lo_descr)
      EXCEPTIONS type_not_found = 1 ).
    IF sy-subrc = 0.
      TRY.
          CALL METHOD (lv_class)=>(lv_method)
            EXPORTING
              iv_action      = 'PUSH_TTYP_TRANSLATIONS'
              iv_object_name = iv_object_name
              iv_payload     = iv_payload
            RECEIVING
              rv_json        = rv_json.
        CATCH cx_root INTO DATA(lx_root).
          rv_json = |\{"error": "Failed to execute dev helper: { escape( val = lx_root->get_text( ) format = cl_abap_format=>e_json_string ) }"\}|.
      ENDTRY.
    ELSE.
      rv_json = '{"error": "Write operations are disabled on this system."}'.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_tabl_handler IMPLEMENTATION.
  METHOD read_translations.
    DATA: lt_components TYPE cl_abap_structdescr=>component_table,
          ls_comp       TYPE cl_abap_structdescr=>component,
          lo_struct     TYPE REF TO cl_abap_structdescr,
          lo_data       TYPE REF TO data.
    FIELD-SYMBOLS: <ls_trans_map> TYPE any.

    DATA: ls_tabl_dummy TYPE ty_tabl_texts,
          lo_type       TYPE REF TO cl_abap_datadescr.
    lo_type = CAST cl_abap_datadescr( cl_abap_typedescr=>describe_by_data( ls_tabl_dummy ) ).

    LOOP AT it_langs INTO DATA(lv_langu).
      ls_comp-name = |{ lv_langu }|.
      ls_comp-type = lo_type.
      APPEND ls_comp TO lt_components.
    ENDLOOP.
    lo_struct = cl_abap_structdescr=>create( lt_components ).
    CREATE DATA lo_data TYPE HANDLE lo_struct.
    ASSIGN lo_data->* TO <ls_trans_map>.

    DATA: lv_ddobjname TYPE ddobjname.
    lv_ddobjname = iv_object_name.

    LOOP AT it_langs INTO lv_langu.
      ASSIGN COMPONENT |{ lv_langu }| OF STRUCTURE <ls_trans_map> TO FIELD-SYMBOL(<lv_lang_struct>).
      IF sy-subrc = 0.
        DATA: ls_dd02v     TYPE dd02v,
              lt_dd03p_tab TYPE TABLE OF dd03p.
        CLEAR lt_dd03p_tab.
        CALL FUNCTION 'DDIF_TABL_GET'
          EXPORTING
            name      = lv_ddobjname
            langu     = lv_langu
          IMPORTING
            dd02v_wa  = ls_dd02v
          TABLES
            dd03p_tab = lt_dd03p_tab
          EXCEPTIONS
            OTHERS    = 1.
        IF sy-subrc = 0.
          DATA: ls_tabl_texts TYPE ty_tabl_texts.
          CLEAR ls_tabl_texts.
          ls_tabl_texts-description = ls_dd02v-ddtext.
          LOOP AT lt_dd03p_tab INTO DATA(ls_dd03p).
            APPEND VALUE ty_tabl_field( fieldname = ls_dd03p-fieldname txt = ls_dd03p-ddtext ) TO ls_tabl_texts-fields.
          ENDLOOP.
          <lv_lang_struct> = ls_tabl_texts.
        ENDIF.
      ENDIF.
    ENDLOOP.

    TYPES: BEGIN OF ty_envelope,
             object_name     TYPE string,
             object_type     TYPE string,
             master_language TYPE string,
             translations    TYPE REF TO data,
           END OF ty_envelope.
    DATA: ls_env TYPE ty_envelope.
    ls_env-object_name     = iv_object_name.
    ls_env-object_type     = 'TABL'.
    ls_env-master_language = iv_masterlang.
    ls_env-translations    = lo_data.
    rv_json = /ui2/cl_json=>serialize( data = ls_env ).
  ENDMETHOD.

  METHOD push_translations.
    DATA: lv_class  TYPE string VALUE 'ZCL_SAP_DEV_DEV_HELPER',
          lv_method TYPE string VALUE 'DISPATCH'.
    cl_abap_typedescr=>describe_by_name(
      EXPORTING  p_name         = lv_class
      RECEIVING  p_descr_ref    = DATA(lo_descr)
      EXCEPTIONS type_not_found = 1 ).
    IF sy-subrc = 0.
      TRY.
          CALL METHOD (lv_class)=>(lv_method)
            EXPORTING
              iv_action      = 'PUSH_TABL_TRANSLATIONS'
              iv_object_name = iv_object_name
              iv_payload     = iv_payload
            RECEIVING
              rv_json        = rv_json.
        CATCH cx_root INTO DATA(lx_root).
          rv_json = |\{"error": "Failed to execute dev helper: { escape( val = lx_root->get_text( ) format = cl_abap_format=>e_json_string ) }"\}|.
      ENDTRY.
    ELSE.
      rv_json = '{"error": "Write operations are disabled on this system."}'.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_tran_handler IMPLEMENTATION.
  METHOD fetch_metadata.
    DATA: ls_tstc  TYPE tstc,
          ls_tstct TYPE tstct,
          lv_devclass TYPE devclass.

    DATA(lv_tcode) = CONV tstc-tcode( iv_object_name ).

    SELECT SINGLE * FROM tstc INTO @ls_tstc WHERE tcode = @lv_tcode.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    SELECT SINGLE * FROM tstct INTO @ls_tstct WHERE tcode = @lv_tcode AND sprsl = @sy-langu.
    IF sy-subrc <> 0.
      SELECT SINGLE * FROM tstct INTO @ls_tstct WHERE tcode = @lv_tcode.
    ENDIF.

    SELECT SINGLE devclass FROM tadir INTO @lv_devclass
      WHERE pgmid = 'R3TR' AND object = 'TRAN' AND obj_name = @lv_tcode.
    IF sy-subrc <> 0.
      lv_devclass = '$TMP'.
    ENDIF.

    DATA: lv_type TYPE string VALUE 'R'.
    IF ls_tstc-dypno <> '1000' OR ls_tstc-pgmna IS INITIAL.
      lv_type = 'D'.
    ENDIF.

    rv_xml = |<?xml version="1.0" encoding="UTF-8"?>\n| &&
             |<transaction:abapTransaction xmlns:transaction="http://www.sap.com/adt/transactions" xmlns:adtcore="http://www.sap.com/adt/core" adtcore:name="{ ls_tstc-tcode }" adtcore:type="TRAN" adtcore:description="{ ls_tstct-ttext }">\n| &&
             |  <adtcore:packageRef adtcore:name="{ lv_devclass }"/>\n| &&
             |  <programName>{ ls_tstc-pgmna }</programName>\n| &&
             |  <screenNumber>{ ls_tstc-dypno }</screenNumber>\n| &&
             |  <transactionType>{ lv_type }</transactionType>\n| &&
             |</transaction:abapTransaction>|.
  ENDMETHOD.

  METHOD push_metadata.
    DATA: lv_tcode    TYPE string,
          lv_program  TYPE string,
          lv_screen   TYPE string,
          lv_text     TYPE string,
          lv_type     TYPE string,
          lv_package  TYPE string.

    FIND REGEX 'adtcore:name="([^"]*)"' IN iv_xml IGNORING CASE SUBMATCHES lv_tcode.
    FIND REGEX 'adtcore:description="([^"]*)"' IN iv_xml IGNORING CASE SUBMATCHES lv_text.
    FIND REGEX 'packageRef adtcore:name="([^"]*)"' IN iv_xml IGNORING CASE SUBMATCHES lv_package.
    FIND REGEX '<programName[^>]*>([^<]*)</programName>' IN iv_xml IGNORING CASE SUBMATCHES lv_program.
    FIND REGEX '<screenNumber[^>]*>([^<]*)</screenNumber>' IN iv_xml IGNORING CASE SUBMATCHES lv_screen.
    FIND REGEX '<transactionType[^>]*>([^<]*)</transactionType>' IN iv_xml IGNORING CASE SUBMATCHES lv_type.

    CONDENSE lv_tcode NO-GAPS.
    CONDENSE lv_program NO-GAPS.
    CONDENSE lv_screen NO-GAPS.
    CONDENSE lv_type NO-GAPS.
    CONDENSE lv_package NO-GAPS.
    CONDENSE lv_text.

    TYPES: BEGIN OF ty_create_payload,
             tcode     TYPE string,
             program   TYPE string,
             screen    TYPE string,
             text      TYPE string,
             type      TYPE string,
             package   TYPE string,
             transport TYPE string,
           END OF ty_create_payload.
    DATA: ls_create TYPE ty_create_payload.

    ls_create-tcode     = lv_tcode.
    ls_create-program   = lv_program.
    ls_create-screen    = lv_screen.
    ls_create-text      = lv_text.
    ls_create-type      = lv_type.
    ls_create-package   = lv_package.
    ls_create-transport = iv_corrnr.

    DATA: lv_create_json TYPE string.
    lv_create_json = /ui2/cl_json=>serialize( data = ls_create ).

    DATA: lv_res TYPE string.
    lv_res = zcl_sap_dev_rpc=>handle_sap_create_transaction( lv_create_json ).

    TYPES: BEGIN OF ty_res,
             success TYPE abap_bool,
             error   TYPE string,
           END OF ty_res.
    DATA: ls_res TYPE ty_res.
    /ui2/cl_json=>deserialize( EXPORTING json = lv_res CHANGING data = ls_res ).

    IF ls_res-success = abap_true.
      rv_etag = 'TRANSACTION_ETAG'.
    ELSE.
      CLEAR rv_etag.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
