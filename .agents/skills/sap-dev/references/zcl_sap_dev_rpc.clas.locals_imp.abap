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
    TYPES: BEGIN OF ty_push_payload,
             object_name  TYPE string,
             object_type  TYPE string,
             translations TYPE REF TO data,
             corrnr       TYPE trkorr,
           END OF ty_push_payload.
    DATA: ls_payload TYPE ty_push_payload.
    /ui2/cl_json=>deserialize( EXPORTING json = iv_payload CHANGING data = ls_payload ).

    ASSIGN ls_payload-translations->* TO FIELD-SYMBOL(<ls_trans>).
    DATA: lo_trans_descr TYPE REF TO cl_abap_structdescr.
    lo_trans_descr = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data( <ls_trans> ) ).
    DATA: lt_comps TYPE cl_abap_structdescr=>component_table.
    lt_comps = lo_trans_descr->get_components( ).

    DATA: lv_langu TYPE sy-langu,
          ls_c     TYPE cl_abap_structdescr=>component.

    LOOP AT lt_comps INTO ls_c.
      lv_langu = ls_c-name.
      ASSIGN COMPONENT ls_c-name OF STRUCTURE <ls_trans> TO FIELD-SYMBOL(<lv_lang_data>).
      IF sy-subrc = 0.
        DATA: lt_tp TYPE STANDARD TABLE OF textpool,
              lv_p  TYPE program.
        lv_p = iv_object_name.
        /ui2/cl_json=>deserialize( EXPORTING json = /ui2/cl_json=>serialize( data = <lv_lang_data> ) CHANGING data = lt_tp ).
        INSERT TEXTPOOL lv_p FROM lt_tp LANGUAGE lv_langu.

        IF ls_payload-corrnr IS NOT INITIAL.
          DATA: ls_ko200 TYPE ko200.
          ls_ko200-pgmid    = 'LIMU'.
          ls_ko200-object   = 'REPT'.
          ls_ko200-obj_name = iv_object_name.
          CALL FUNCTION 'TR_OBJECT_INSERT'
            EXPORTING
              wi_ko200          = ls_ko200
              wi_order          = ls_payload-corrnr
              iv_no_show_option = 'X'
            EXCEPTIONS
              OTHERS            = 1.
        ENDIF.
      ENDIF.
    ENDLOOP.

    TYPES: BEGIN OF ty_ok,
             status TYPE string,
           END OF ty_ok.
    DATA: ls_ok TYPE ty_ok.
    ls_ok-status = 'saved_active'.
    rv_json = /ui2/cl_json=>serialize( data = ls_ok ).
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
    TYPES: BEGIN OF ty_push_payload,
             object_name  TYPE string,
             object_type  TYPE string,
             translations TYPE REF TO data,
             corrnr       TYPE trkorr,
           END OF ty_push_payload.
    DATA: ls_payload TYPE ty_push_payload.
    /ui2/cl_json=>deserialize( EXPORTING json = iv_payload CHANGING data = ls_payload ).

    ASSIGN ls_payload-translations->* TO FIELD-SYMBOL(<ls_trans>).
    DATA: lo_trans_descr TYPE REF TO cl_abap_structdescr.
    lo_trans_descr = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data( <ls_trans> ) ).
    DATA: lt_comps TYPE cl_abap_structdescr=>component_table.
    lt_comps = lo_trans_descr->get_components( ).

    DATA: lv_langu     TYPE sy-langu,
          lv_ddobjname TYPE ddobjname,
          ls_c         TYPE cl_abap_structdescr=>component.
    lv_ddobjname = iv_object_name.

    LOOP AT lt_comps INTO ls_c.
      lv_langu = ls_c-name.
      ASSIGN COMPONENT ls_c-name OF STRUCTURE <ls_trans> TO FIELD-SYMBOL(<lv_lang_data>).
      IF sy-subrc = 0.
        DATA: ls_dd04v_put TYPE dd04v.
        CALL FUNCTION 'DDIF_DTEL_GET'
          EXPORTING
            name     = lv_ddobjname
            state    = 'A'
          IMPORTING
            dd04v_wa = ls_dd04v_put
          EXCEPTIONS
            OTHERS   = 1.

        DATA: ls_dtel_in TYPE ty_dtel_texts.
        /ui2/cl_json=>deserialize( EXPORTING json = /ui2/cl_json=>serialize( data = <lv_lang_data> ) CHANGING data = ls_dtel_in ).

        ls_dd04v_put-ddtext = ls_dtel_in-description.
        ls_dd04v_put-reptext = ls_dtel_in-heading.
        ls_dd04v_put-scrtext_s = ls_dtel_in-label_short.
        ls_dd04v_put-scrtext_m = ls_dtel_in-label_medium.
        ls_dd04v_put-scrtext_l = ls_dtel_in-label_long.
        ls_dd04v_put-ddlanguage = lv_langu.

        CALL FUNCTION 'DDIF_DTEL_PUT'
          EXPORTING
            name     = lv_ddobjname
            dd04v_wa = ls_dd04v_put
          EXCEPTIONS
            OTHERS   = 1.

        CALL FUNCTION 'DDIF_DTEL_ACTIVATE'
          EXPORTING
            name     = lv_ddobjname
            auth_chk = ' '
          EXCEPTIONS
            OTHERS   = 1.

        IF ls_payload-corrnr IS NOT INITIAL.
          DATA: ls_ko200_dtel TYPE ko200.
          ls_ko200_dtel-pgmid    = 'R3TR'.
          ls_ko200_dtel-object   = 'DTEL'.
          ls_ko200_dtel-obj_name = iv_object_name.
          CALL FUNCTION 'TR_OBJECT_INSERT'
            EXPORTING
              wi_ko200          = ls_ko200_dtel
              wi_order          = ls_payload-corrnr
              iv_no_show_option = 'X'
            EXCEPTIONS
              OTHERS            = 1.
        ENDIF.
      ENDIF.
    ENDLOOP.

    TYPES: BEGIN OF ty_ok,
             status TYPE string,
           END OF ty_ok.
    DATA: ls_ok TYPE ty_ok.
    ls_ok-status = 'saved_active'.
    rv_json = /ui2/cl_json=>serialize( data = ls_ok ).
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
    TYPES: BEGIN OF ty_push_payload,
             object_name  TYPE string,
             object_type  TYPE string,
             translations TYPE REF TO data,
             corrnr       TYPE trkorr,
           END OF ty_push_payload.
    DATA: ls_payload TYPE ty_push_payload.
    /ui2/cl_json=>deserialize( EXPORTING json = iv_payload CHANGING data = ls_payload ).

    ASSIGN ls_payload-translations->* TO FIELD-SYMBOL(<ls_trans>).
    DATA: lo_trans_descr TYPE REF TO cl_abap_structdescr.
    lo_trans_descr = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data( <ls_trans> ) ).
    DATA: lt_comps TYPE cl_abap_structdescr=>component_table.
    lt_comps = lo_trans_descr->get_components( ).

    DATA: lv_langu     TYPE sy-langu,
          lv_ddobjname TYPE ddobjname,
          ls_c         TYPE cl_abap_structdescr=>component.
    lv_ddobjname = iv_object_name.

    LOOP AT lt_comps INTO ls_c.
      lv_langu = ls_c-name.
      ASSIGN COMPONENT ls_c-name OF STRUCTURE <ls_trans> TO FIELD-SYMBOL(<lv_lang_data>).
      IF sy-subrc = 0.
        DATA: ls_dd01v_put     TYPE dd01v,
              lt_dd07v_put_tab TYPE TABLE OF dd07v.
        CALL FUNCTION 'DDIF_DOMA_GET'
          EXPORTING
            name      = lv_ddobjname
            state     = 'A'
          IMPORTING
            dd01v_wa  = ls_dd01v_put
          TABLES
            dd07v_tab = lt_dd07v_put_tab
          EXCEPTIONS
            OTHERS    = 1.

        DATA: ls_doma_in TYPE ty_doma_texts.
        /ui2/cl_json=>deserialize( EXPORTING json = /ui2/cl_json=>serialize( data = <lv_lang_data> ) CHANGING data = ls_doma_in ).

        ls_dd01v_put-ddtext = ls_doma_in-description.
        ls_dd01v_put-ddlanguage = lv_langu.

        DATA: ls_fv_in TYPE ty_doma_val.
        LOOP AT lt_dd07v_put_tab ASSIGNING FIELD-SYMBOL(<ls_dd07v_p>).
          <ls_dd07v_p>-ddlanguage = lv_langu.
          READ TABLE ls_doma_in-fixed_values INTO ls_fv_in WITH KEY val = <ls_dd07v_p>-domval_ld.
          IF sy-subrc = 0.
            <ls_dd07v_p>-ddtext = ls_fv_in-txt.
          ELSE.
            CLEAR <ls_dd07v_p>-ddtext.
          ENDIF.
        ENDLOOP.

        CALL FUNCTION 'DDIF_DOMA_PUT'
          EXPORTING
            name      = lv_ddobjname
            dd01v_wa  = ls_dd01v_put
          TABLES
            dd07v_tab = lt_dd07v_put_tab
          EXCEPTIONS
            OTHERS    = 1.

        CALL FUNCTION 'DDIF_DOMA_ACTIVATE'
          EXPORTING
            name     = lv_ddobjname
            auth_chk = ' '
          EXCEPTIONS
            OTHERS   = 1.

        IF ls_payload-corrnr IS NOT INITIAL.
          DATA: ls_ko200_doma TYPE ko200.
          ls_ko200_doma-pgmid    = 'R3TR'.
          ls_ko200_doma-object   = 'DOMA'.
          ls_ko200_doma-obj_name = iv_object_name.
          CALL FUNCTION 'TR_OBJECT_INSERT'
            EXPORTING
              wi_ko200          = ls_ko200_doma
              wi_order          = ls_payload-corrnr
              iv_no_show_option = 'X'
            EXCEPTIONS
              OTHERS            = 1.
        ENDIF.
      ENDIF.
    ENDLOOP.

    TYPES: BEGIN OF ty_ok,
             status TYPE string,
           END OF ty_ok.
    DATA: ls_ok TYPE ty_ok.
    ls_ok-status = 'saved_active'.
    rv_json = /ui2/cl_json=>serialize( data = ls_ok ).
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
    TYPES: BEGIN OF ty_push_payload,
             object_name  TYPE string,
             object_type  TYPE string,
             translations TYPE REF TO data,
             corrnr       TYPE trkorr,
           END OF ty_push_payload.
    DATA: ls_payload TYPE ty_push_payload.
    /ui2/cl_json=>deserialize( EXPORTING json = iv_payload CHANGING data = ls_payload ).

    ASSIGN ls_payload-translations->* TO FIELD-SYMBOL(<ls_trans>).
    DATA: lo_trans_descr TYPE REF TO cl_abap_structdescr.
    lo_trans_descr = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data( <ls_trans> ) ).
    DATA: lt_comps TYPE cl_abap_structdescr=>component_table.
    lt_comps = lo_trans_descr->get_components( ).

    DATA: lv_langu     TYPE sy-langu,
          lv_meth_name TYPE seocmpname,
          ls_c         TYPE cl_abap_structdescr=>component.

    LOOP AT lt_comps INTO ls_c.
      lv_langu = ls_c-name.
      ASSIGN COMPONENT ls_c-name OF STRUCTURE <ls_trans> TO FIELD-SYMBOL(<lv_lang_data>).
      IF sy-subrc = 0.
        DATA: ls_clas_in TYPE ty_clas_texts.
        /ui2/cl_json=>deserialize( EXPORTING json = /ui2/cl_json=>serialize( data = <lv_lang_data> ) CHANGING data = ls_clas_in ).

        IF ls_clas_in-description IS NOT INITIAL.
          DATA: lv_cls_desc TYPE string,
                lv_cls_name TYPE seoclsname.
          lv_cls_desc = ls_clas_in-description.
          lv_cls_name = iv_object_name.
          UPDATE seoclasstx SET descript = @lv_cls_desc
            WHERE clsname = @lv_cls_name AND langu = @lv_langu.
          IF sy-subrc <> 0.
            DATA: ls_seoclasstx TYPE seoclasstx.
            ls_seoclasstx-clsname = lv_cls_name.
            ls_seoclasstx-langu = lv_langu.
            ls_seoclasstx-descript = lv_cls_desc.
            INSERT seoclasstx FROM ls_seoclasstx.
          ENDIF.
        ENDIF.

        DATA: ls_m_in TYPE ty_clas_meth.
        LOOP AT ls_clas_in-methods INTO ls_m_in.
          lv_meth_name = ls_m_in-name.
          DATA: lv_m_desc TYPE string,
                lv_c_name TYPE seoclsname.
          lv_m_desc = ls_m_in-txt.
          lv_c_name = iv_object_name.
          UPDATE seocompotx SET descript = @lv_m_desc
            WHERE clsname = @lv_c_name AND cmpname = @lv_meth_name AND langu = @lv_langu.
          IF sy-subrc <> 0.
            DATA: ls_seocompotx TYPE seocompotx.
            ls_seocompotx-clsname = lv_c_name.
            ls_seocompotx-cmpname = lv_meth_name.
            ls_seocompotx-langu = lv_langu.
            ls_seocompotx-descript = lv_m_desc.
            INSERT seocompotx FROM ls_seocompotx.
          ENDIF.
        ENDLOOP.

        IF ls_payload-corrnr IS NOT INITIAL.
          DATA: ls_ko200_clas TYPE ko200.
          ls_ko200_clas-pgmid    = 'R3TR'.
          ls_ko200_clas-object   = 'CLAS'.
          ls_ko200_clas-obj_name = iv_object_name.
          CALL FUNCTION 'TR_OBJECT_INSERT'
            EXPORTING
              wi_ko200          = ls_ko200_clas
              wi_order          = ls_payload-corrnr
              iv_no_show_option = 'X'
            EXCEPTIONS
              OTHERS            = 1.
        ENDIF.
      ENDIF.
    ENDLOOP.

    TYPES: BEGIN OF ty_ok,
             status TYPE string,
           END OF ty_ok.
    DATA: ls_ok TYPE ty_ok.
    ls_ok-status = 'saved_active'.
    rv_json = /ui2/cl_json=>serialize( data = ls_ok ).
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
    TYPES: BEGIN OF ty_push_payload,
             object_name  TYPE string,
             object_type  TYPE string,
             translations TYPE REF TO data,
             corrnr       TYPE trkorr,
           END OF ty_push_payload.
    DATA: ls_payload TYPE ty_push_payload.
    /ui2/cl_json=>deserialize( EXPORTING json = iv_payload CHANGING data = ls_payload ).

    ASSIGN ls_payload-translations->* TO FIELD-SYMBOL(<ls_trans>).
    DATA: lo_trans_descr TYPE REF TO cl_abap_structdescr.
    lo_trans_descr = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data( <ls_trans> ) ).
    DATA: lt_comps TYPE cl_abap_structdescr=>component_table.
    lt_comps = lo_trans_descr->get_components( ).

    DATA: lv_langu     TYPE sy-langu,
          lv_msgnr     TYPE msgnr,
          ls_c         TYPE cl_abap_structdescr=>component.

    LOOP AT lt_comps INTO ls_c.
      lv_langu = ls_c-name.
      ASSIGN COMPONENT ls_c-name OF STRUCTURE <ls_trans> TO FIELD-SYMBOL(<lv_lang_data>).
      IF sy-subrc = 0.
        DATA: ls_msag_in TYPE ty_msag_texts.
        /ui2/cl_json=>deserialize( EXPORTING json = /ui2/cl_json=>serialize( data = <lv_lang_data> ) CHANGING data = ls_msag_in ).

        IF ls_msag_in-description IS NOT INITIAL.
          DATA: lv_msag_desc TYPE string,
                lv_arbgb     TYPE arbgb.
          lv_msag_desc = ls_msag_in-description.
          lv_arbgb = iv_object_name.
          UPDATE t100t SET stext = @lv_msag_desc
            WHERE arbgb = @lv_arbgb AND sprsl = @lv_langu.
          IF sy-subrc <> 0.
            DATA: ls_t100t TYPE t100t.
            ls_t100t-sprsl = lv_langu.
            ls_t100t-arbgb = lv_arbgb.
            ls_t100t-stext = lv_msag_desc.
            INSERT t100t FROM ls_t100t.
          ENDIF.
        ENDIF.

        DATA: ls_msg_in TYPE ty_msag_msg.
        LOOP AT ls_msag_in-messages INTO ls_msg_in.
          lv_msgnr = ls_msg_in-msgnr.
          DATA: lv_msg_txt TYPE string,
                lv_arbgb_m TYPE arbgb.
          lv_msg_txt = ls_msg_in-text.
          lv_arbgb_m = iv_object_name.
          UPDATE t100 SET text = @lv_msg_txt
            WHERE sprsl = @lv_langu AND arbgb = @lv_arbgb_m AND msgnr = @lv_msgnr.
          IF sy-subrc <> 0.
            DATA: ls_t100 TYPE t100.
            ls_t100-sprsl = lv_langu.
            ls_t100-arbgb = lv_arbgb_m.
            ls_t100-msgnr = lv_msgnr.
            ls_t100-text = lv_msg_txt.
            INSERT t100 FROM ls_t100.
          ENDIF.
        ENDLOOP.

        IF ls_payload-corrnr IS NOT INITIAL.
          DATA: ls_ko200_msag TYPE ko200.
          ls_ko200_msag-pgmid    = 'R3TR'.
          ls_ko200_msag-object   = 'MSAG'.
          ls_ko200_msag-obj_name = iv_object_name.
          CALL FUNCTION 'TR_OBJECT_INSERT'
            EXPORTING
              wi_ko200          = ls_ko200_msag
              wi_order          = ls_payload-corrnr
              iv_no_show_option = 'X'
            EXCEPTIONS
              OTHERS            = 1.
        ENDIF.
      ENDIF.
    ENDLOOP.

    TYPES: BEGIN OF ty_ok,
             status TYPE string,
           END OF ty_ok.
    DATA: ls_ok TYPE ty_ok.
    ls_ok-status = 'saved_active'.
    rv_json = /ui2/cl_json=>serialize( data = ls_ok ).
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
    TYPES: BEGIN OF ty_push_payload,
             object_name  TYPE string,
             object_type  TYPE string,
             translations TYPE REF TO data,
             corrnr       TYPE trkorr,
           END OF ty_push_payload.
    DATA: ls_payload TYPE ty_push_payload.
    /ui2/cl_json=>deserialize( EXPORTING json = iv_payload CHANGING data = ls_payload ).

    ASSIGN ls_payload-translations->* TO FIELD-SYMBOL(<ls_trans>).
    DATA: lo_trans_descr TYPE REF TO cl_abap_structdescr.
    lo_trans_descr = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data( <ls_trans> ) ).
    DATA: lt_comps TYPE cl_abap_structdescr=>component_table.
    lt_comps = lo_trans_descr->get_components( ).

    DATA: lv_langu     TYPE sy-langu,
          lv_ddobjname TYPE ddobjname,
          ls_c         TYPE cl_abap_structdescr=>component.
    lv_ddobjname = iv_object_name.

    LOOP AT lt_comps INTO ls_c.
      lv_langu = ls_c-name.
      ASSIGN COMPONENT ls_c-name OF STRUCTURE <ls_trans> TO FIELD-SYMBOL(<lv_lang_data>).
      IF sy-subrc = 0.
        DATA: ls_dd40v_put     TYPE dd40v,
              lt_dd43v_put_tab TYPE TABLE OF dd43v,
              lt_dd42v_put_tab TYPE TABLE OF dd42v.
        CALL FUNCTION 'DDIF_TTYP_GET'
          EXPORTING
            name      = lv_ddobjname
            state     = 'A'
          IMPORTING
            dd40v_wa  = ls_dd40v_put
          TABLES
            dd43v_tab = lt_dd43v_put_tab
            dd42v_tab = lt_dd42v_put_tab
          EXCEPTIONS
            OTHERS    = 1.

        DATA: ls_ttyp_in TYPE ty_ttyp_texts.
        /ui2/cl_json=>deserialize( EXPORTING json = /ui2/cl_json=>serialize( data = <lv_lang_data> ) CHANGING data = ls_ttyp_in ).

        ls_dd40v_put-ddtext = ls_ttyp_in-description.
        ls_dd40v_put-ddlanguage = lv_langu.

        CALL FUNCTION 'DDIF_TTYP_PUT'
          EXPORTING
            name      = lv_ddobjname
            dd40v_wa  = ls_dd40v_put
          TABLES
            dd43v_tab = lt_dd43v_put_tab
            dd42v_tab = lt_dd42v_put_tab
          EXCEPTIONS
            OTHERS    = 1.

        CALL FUNCTION 'DDIF_TTYP_ACTIVATE'
          EXPORTING
            name     = lv_ddobjname
          EXCEPTIONS
            OTHERS   = 1.

        IF ls_payload-corrnr IS NOT INITIAL.
          DATA: ls_ko200_ttyp TYPE ko200.
          ls_ko200_ttyp-pgmid    = 'R3TR'.
          ls_ko200_ttyp-object   = 'TTYP'.
          ls_ko200_ttyp-obj_name = iv_object_name.
          CALL FUNCTION 'TR_OBJECT_INSERT'
            EXPORTING
              wi_ko200          = ls_ko200_ttyp
              wi_order          = ls_payload-corrnr
              iv_no_show_option = 'X'
            EXCEPTIONS
              OTHERS            = 1.
        ENDIF.
      ENDIF.
    ENDLOOP.

    TYPES: BEGIN OF ty_ok,
             status TYPE string,
           END OF ty_ok.
    DATA: ls_ok TYPE ty_ok.
    ls_ok-status = 'saved_active'.
    rv_json = /ui2/cl_json=>serialize( data = ls_ok ).
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
    TYPES: BEGIN OF ty_push_payload,
             object_name  TYPE string,
             object_type  TYPE string,
             translations TYPE REF TO data,
             corrnr       TYPE trkorr,
           END OF ty_push_payload.
    DATA: ls_payload TYPE ty_push_payload.
    /ui2/cl_json=>deserialize( EXPORTING json = iv_payload CHANGING data = ls_payload ).

    ASSIGN ls_payload-translations->* TO FIELD-SYMBOL(<ls_trans>).
    DATA: lo_trans_descr TYPE REF TO cl_abap_structdescr.
    lo_trans_descr = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data( <ls_trans> ) ).
    DATA: lt_comps TYPE cl_abap_structdescr=>component_table.
    lt_comps = lo_trans_descr->get_components( ).

    DATA: lv_langu     TYPE sy-langu,
          lv_ddobjname TYPE ddobjname,
          ls_c         TYPE cl_abap_structdescr=>component.
    lv_ddobjname = iv_object_name.

    LOOP AT lt_comps INTO ls_c.
      lv_langu = ls_c-name.
      ASSIGN COMPONENT ls_c-name OF STRUCTURE <ls_trans> TO FIELD-SYMBOL(<lv_lang_data>).
      IF sy-subrc = 0.
        DATA: ls_dd02v_put     TYPE dd02v,
              lt_dd03p_put_tab TYPE TABLE OF dd03p.
        CALL FUNCTION 'DDIF_TABL_GET'
          EXPORTING
            name      = lv_ddobjname
            state     = 'A'
          IMPORTING
            dd02v_wa  = ls_dd02v_put
          TABLES
            dd03p_tab = lt_dd03p_put_tab
          EXCEPTIONS
            OTHERS    = 1.

        DATA: ls_tabl_in TYPE ty_tabl_texts.
        /ui2/cl_json=>deserialize( EXPORTING json = /ui2/cl_json=>serialize( data = <lv_lang_data> ) CHANGING data = ls_tabl_in ).

        ls_dd02v_put-ddtext = ls_tabl_in-description.
        ls_dd02v_put-ddlanguage = lv_langu.

        DATA: ls_f_in TYPE ty_tabl_field.
        LOOP AT lt_dd03p_put_tab ASSIGNING FIELD-SYMBOL(<ls_dd03p_p>).
          <ls_dd03p_p>-ddlanguage = lv_langu.
          READ TABLE ls_tabl_in-fields INTO ls_f_in WITH KEY fieldname = <ls_dd03p_p>-fieldname.
          IF sy-subrc = 0.
            <ls_dd03p_p>-ddtext = ls_f_in-txt.
          ELSE.
            CLEAR <ls_dd03p_p>-ddtext.
          ENDIF.
        ENDLOOP.

        CALL FUNCTION 'DDIF_TABL_PUT'
          EXPORTING
            name      = lv_ddobjname
            dd02v_wa  = ls_dd02v_put
          TABLES
            dd03p_tab = lt_dd03p_put_tab
          EXCEPTIONS
            OTHERS    = 1.

        CALL FUNCTION 'DDIF_TABL_ACTIVATE'
          EXPORTING
            name     = lv_ddobjname
          EXCEPTIONS
            OTHERS   = 1.

        IF ls_payload-corrnr IS NOT INITIAL.
          DATA: ls_ko200_tabl TYPE ko200.
          ls_ko200_tabl-pgmid    = 'R3TR'.
          ls_ko200_tabl-object   = 'TABL'.
          ls_ko200_tabl-obj_name = iv_object_name.
          CALL FUNCTION 'TR_OBJECT_INSERT'
            EXPORTING
              wi_ko200          = ls_ko200_tabl
              wi_order          = ls_payload-corrnr
              iv_no_show_option = 'X'
            EXCEPTIONS
              OTHERS            = 1.
        ENDIF.
      ENDIF.
    ENDLOOP.

    TYPES: BEGIN OF ty_ok,
             status TYPE string,
           END OF ty_ok.
    DATA: ls_ok TYPE ty_ok.
    ls_ok-status = 'saved_active'.
    rv_json = /ui2/cl_json=>serialize( data = ls_ok ).
  ENDMETHOD.
ENDCLASS.

CLASS lcl_tran_handler IMPLEMENTATION.
  METHOD get_creation_template.
    rv_xml = |<?xml version="1.0" encoding="UTF-8"?>\n| &&
             |<transaction:abapTransaction xmlns:transaction="http://www.sap.com/adt/transactions"| &&
             | xmlns:adtcore="http://www.sap.com/adt/core" adtcore:name="{ iv_object_name }"| &&
             | adtcore:type="TRAN" adtcore:description="Transaction { iv_object_name }">\n| &&
             |  <adtcore:packageRef adtcore:name="{ iv_package }"/>\n| &&
             |  <programName>Z_PROGRAM</programName>\n| &&
             |  <screenNumber>1000</screenNumber>\n| &&
             |  <transactionType>R</transactionType>\n| &&
             |</transaction:abapTransaction>|.
  ENDMETHOD.

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
