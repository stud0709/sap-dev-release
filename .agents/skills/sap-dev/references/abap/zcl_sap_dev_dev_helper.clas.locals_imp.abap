*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

"======================================================================
" 1. Translation Writer Implementation
"======================================================================
  CLASS lcl_translation_writer IMPLEMENTATION.
  METHOD handle_sap_push_translations.
    TYPES: BEGIN OF ty_push_payload,
             object_name  TYPE string,
             object_type  TYPE string,
             translations TYPE REF TO data,
             corrnr       TYPE trkorr,
           END OF ty_push_payload.
    DATA: ls_payload TYPE ty_push_payload.

    /ui2/cl_json=>deserialize( EXPORTING json = iv_payload CHANGING data = ls_payload ).

    TRANSLATE ls_payload-object_name TO UPPER CASE.
    TRANSLATE ls_payload-object_type TO UPPER CASE.

    DATA: lv_type_key TYPE string.
    lv_type_key = ls_payload-object_type.

    DATA(lo_handler) = io_rpc->get_object_handler( lv_type_key ).
    IF lo_handler IS NOT BOUND.
      TYPES: BEGIN OF ty_err_resp,
               error TYPE string,
             END OF ty_err_resp.
      DATA: ls_err_resp TYPE ty_err_resp.
      ls_err_resp-error = |Unsupported object type { lv_type_key } for translations. Consider extending ZCL_SAP_DEV_RPC_EXT to support it.|.
      rv_json = /ui2/cl_json=>serialize( data = ls_err_resp ).
      RETURN.
    ENDIF.

    rv_json = lo_handler->push_translations(
      iv_object_name = ls_payload-object_name
      iv_payload     = iv_payload ).
  ENDMETHOD.

  METHOD push_prog_translations.
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

  METHOD push_dtel_translations.
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

  METHOD push_doma_translations.
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
          READ TABLE ls_doma_in-fixed_values INTO ls_fv_in WITH KEY val = <ls_dd07v_p>-domvalue_l.
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

  METHOD push_clas_translations.
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

  METHOD push_msag_translations.
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

  METHOD push_ttyp_translations.
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

  METHOD push_tabl_translations.
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

"======================================================================
" 2. Customizing Runner Implementation
"======================================================================
CLASS lcl_customizing_runner IMPLEMENTATION.
  METHOD handle_maintain_custom.
    TYPES: BEGIN OF ty_payload,
             customizing_target TYPE string,
             action             TYPE string,
             entries            TYPE REF TO data,
             transport_request  TYPE trkorr,
           END OF ty_payload.
    DATA: ls_payload TYPE ty_payload.
    DATA: lv_viewname   TYPE tabname,
          lv_is_cluster TYPE abap_bool.

    TRY.
        /ui2/cl_json=>deserialize( EXPORTING json = iv_payload CHANGING data = ls_payload ).
        TRANSLATE ls_payload-action TO UPPER CASE.

        io_rpc->resolve_target_to_view(
          EXPORTING iv_target = ls_payload-customizing_target
          IMPORTING ev_viewname = lv_viewname
                    ev_is_cluster = lv_is_cluster ).

        DATA: lv_entries_json TYPE string.
        lv_entries_json = /ui2/cl_json=>serialize( ls_payload-entries ).

        rv_json = run_direct_api(
          iv_viewname     = lv_viewname
          iv_action       = ls_payload-action
          iv_entries_json = lv_entries_json
          iv_trkorr       = ls_payload-transport_request
          io_rpc          = io_rpc ).

      CATCH cx_root INTO DATA(lx_root).
        rv_json = |\{"success":false,"error":"{ lx_root->get_text( ) } (OuterDevHelper: View={ lv_viewname }, Target={ ls_payload-customizing_target })"\}|.
    ENDTRY.
  ENDMETHOD.

  METHOD run_direct_api.
    DATA: lo_structdescr TYPE REF TO cl_abap_structdescr,
          lo_tabledescr  TYPE REF TO cl_abap_tabledescr,
          lr_table       TYPE REF TO data.
    FIELD-SYMBOLS: <lt_table> TYPE STANDARD TABLE.

    TRY.
        DATA: lt_components  TYPE cl_abap_structdescr=>component_table,
              lo_struct      TYPE REF TO cl_abap_structdescr,
              lo_flag_struct TYPE REF TO cl_abap_structdescr.

        lo_struct ?= cl_abap_typedescr=>describe_by_name( iv_viewname ).
        lt_components = lo_struct->get_components( ).

        lo_flag_struct ?= cl_abap_typedescr=>describe_by_name( 'VIMFLAGTAB' ).
        DATA(lt_flag_components) = lo_flag_struct->get_components( ).
        APPEND LINES OF lt_flag_components TO lt_components.

        lo_structdescr = cl_abap_structdescr=>create( lt_components ).
        lo_tabledescr   = cl_abap_tabledescr=>create( lo_structdescr ).

        CREATE DATA lr_table TYPE HANDLE lo_tabledescr.
        ASSIGN lr_table->* TO <lt_table>.

        /ui2/cl_json=>deserialize(
          EXPORTING
            json          = iv_entries_json
            pretty_name   = /ui2/cl_json=>pretty_mode-none
          CHANGING
            data          = <lt_table> ).

        DATA: lv_action TYPE char1.
        IF iv_action = 'DELETE'.
          lv_action = 'D'.
        ELSE.
          lv_action = 'U'.
        ENDIF.

        FIELD-SYMBOLS: <ls_row> TYPE any,
                       <lv_act> TYPE any.
        LOOP AT <lt_table> ASSIGNING <ls_row>.
          ASSIGN COMPONENT 'ACTION' OF STRUCTURE <ls_row> TO <lv_act>.
          IF sy-subrc = 0.
            <lv_act> = lv_action.
          ENDIF.
        ENDLOOP.

        CALL FUNCTION 'VIEW_MAINTENANCE_GIVEN_DATA'
          EXPORTING
            action                       = lv_action
            view_name                    = iv_viewname
            corr_number                  = iv_trkorr
          TABLES
            data                         = <lt_table>
          EXCEPTIONS
            foreign_lock                 = 1
            invalid_action               = 2
            no_tvdir_entry               = 3
            no_upd_auth                  = 4
            view_not_found               = 5
            OTHERS                       = 6.

        IF sy-subrc = 0.
          rv_json = |\{"success":true,"message":"Customizing updated successfully via Direct API"\}|.
        ELSE.
          rv_json = |\{"success":false,"error":"VIEW_MAINTENANCE_GIVEN_DATA failed with subrc { sy-subrc }"\}|.
        ENDIF.
      CATCH cx_root INTO DATA(lx_root).
        rv_json = |\{"success":false,"error":"{ lx_root->get_text( ) } (DirectAPI: View={ iv_viewname })"\}|.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.

"======================================================================
" 3. Dynpro Engine Implementation
"======================================================================
  CLASS lcl_dynpro_engine IMPLEMENTATION.
  METHOD push_dynpro.
    TYPES: BEGIN OF ty_dynpro_resp,
             status  TYPE string,
             message TYPE string,
             error   TYPE string,
           END OF ty_dynpro_resp.
    DATA: ls_resp    TYPE ty_dynpro_resp,
          ls_payload TYPE ty_dynpro_payload.
    /ui2/cl_json=>deserialize( EXPORTING json = iv_payload CHANGING data = ls_payload ).

    IF ls_payload-program IS INITIAL OR ls_payload-screen IS INITIAL.
      rv_json = '{"error": "Program and screen number are required."}'.
      RETURN.
    ENDIF.

    IF ls_payload-fields IS INITIAL AND ls_payload-elements IS NOT INITIAL.
      ls_payload-fields = ls_payload-elements.
    ENDIF.

    " Validate explicit OKCODE element definition on main/modal screens
    DATA: lv_ok_var_name TYPE d021s-fnam.
    LOOP AT ls_payload-fields INTO DATA(ls_chk_ok).
      DATA(lv_ok_t) = to_upper( ls_chk_ok-type ).
      IF lv_ok_t = 'OKCODE' OR ls_chk_ok-line = 255.
        IF lv_ok_t <> 'OKCODE'.
          ls_resp-status  = 'error'.
          ls_resp-message = |Field '{ ls_chk_ok-name }' at line 255 must have canonical type 'OKCODE' (got '{ ls_chk_ok-type }').|.
          ls_resp-error   = ls_resp-message.
          rv_json = /ui2/cl_json=>serialize( data = ls_resp ).
          RETURN.
        ENDIF.
        IF lv_ok_var_name IS NOT INITIAL.
          ls_resp-status  = 'error'.
          ls_resp-message = 'Screen contains duplicate OKCODE element definitions.'.
          ls_resp-error   = ls_resp-message.
          rv_json = /ui2/cl_json=>serialize( data = ls_resp ).
          RETURN.
        ENDIF.
        IF ls_chk_ok-name IS INITIAL.
          ls_resp-status  = 'error'.
          ls_resp-message = 'OKCODE element has an empty name. Specify the exact global ABAP variable name of type sy-ucomm to bind (e.g. OK_CODE or GV_UCOMM).'.
          ls_resp-error   = ls_resp-message.
          rv_json = /ui2/cl_json=>serialize( data = ls_resp ).
          RETURN.
        ENDIF.
        lv_ok_var_name = to_upper( condense( ls_chk_ok-name ) ).
      ENDIF.
    ENDLOOP.
    IF ls_payload-header-type <> 'I' AND ls_payload-header-type <> 'N'.
      IF lv_ok_var_name IS INITIAL.
        ls_resp-status  = 'error'.
        ls_resp-message = 'Main/modal screen is missing an OKCODE element definition. ' &&
                          'Define an explicit OKCODE element (e.g. {"name": "OK_CODE", "type": "OKCODE", "line": 255, "colm": 1, "leng": 20}) ' &&
                          'matching your global ABAP variable (DATA: <var_name> TYPE sy-ucomm).'.
        ls_resp-error   = ls_resp-message.
        rv_json = /ui2/cl_json=>serialize( data = ls_resp ).
        RETURN.
      ENDIF.
    ELSE.
      IF lv_ok_var_name IS NOT INITIAL.
        ls_resp-status  = 'error'.
        ls_resp-message = |Subscreens (type '{ ls_payload-header-type }') cannot contain an OKCODE element.|.
        ls_resp-error   = ls_resp-message.
        rv_json = /ui2/cl_json=>serialize( data = ls_resp ).
        RETURN.
      ENDIF.
    ENDIF.

    DATA: ls_ext_head TYPE rpy_dyhead,
          lt_ext_cnt  TYPE dycatt_tab,
          lt_ext_fld  TYPE dyfatc_tab,
          lt_ext_flow TYPE TABLE OF rpy_dyflow,
          lt_ext_par  TYPE TABLE OF rpy_dypara,
          ls_header   TYPE d020s,
          lt_fields   TYPE TABLE OF d021s,
          lt_flow     TYPE dyn_flowlist,
          lt_params   TYPE TABLE OF d023s,
          lv_text     TYPE d020t-dtxt.

    ls_ext_head-program    = ls_payload-program.
    ls_ext_head-screen     = ls_payload-screen.
    ls_ext_head-language   = sy-langu.
    ls_ext_head-descript   = ls_payload-header-dtxt.
    ls_ext_head-type       = COND #( WHEN ls_payload-header-type IS NOT INITIAL THEN ls_payload-header-type ELSE ' ' ).
    ls_ext_head-nextscreen = COND #( WHEN ls_payload-header-next IS NOT INITIAL THEN ls_payload-header-next ELSE ls_payload-screen ).
    ls_ext_head-lines      = COND #( WHEN ls_payload-header-linc > 0 THEN ls_payload-header-linc ELSE 27 ).
    ls_ext_head-columns    = COND #( WHEN ls_payload-header-colc > 0 THEN ls_payload-header-colc ELSE 120 ).
    ls_ext_head-screen_grp = ls_payload-header-dgrp.

    " Add default root screen container
    APPEND VALUE rpy_dycatt(
      type = 'SCREEN'
      name = 'SCREEN'
    ) TO lt_ext_cnt.

    " Collect Radio Button Group containers
    TYPES: BEGIN OF ty_rad_grp_bounds,
             name     TYPE rpy_dycatt-name,
             min_line TYPE i,
             max_line TYPE i,
             min_col  TYPE i,
             max_col  TYPE i,
           END OF ty_rad_grp_bounds.
    DATA: lt_rad_groups TYPE TABLE OF ty_rad_grp_bounds.

    LOOP AT ls_payload-fields INTO DATA(ls_check_elem).
      DATA(lv_chk_type) = to_upper( ls_check_elem-type ).
      IF lv_chk_type = 'RADIOBUTTON'
         AND ls_check_elem-radio_group IS NOT INITIAL.
        DATA(lv_grp_name) = to_upper( ls_check_elem-radio_group ).
        READ TABLE lt_rad_groups ASSIGNING FIELD-SYMBOL(<ls_rg>) WITH KEY name = lv_grp_name.
        IF sy-subrc <> 0.
          APPEND VALUE #(
            name     = lv_grp_name
            min_line = ls_check_elem-line
            max_line = ls_check_elem-line
            min_col  = ls_check_elem-colm
            max_col  = ls_check_elem-colm + ls_check_elem-leng
          ) TO lt_rad_groups.
        ELSE.
          IF ls_check_elem-line < <ls_rg>-min_line. <ls_rg>-min_line = ls_check_elem-line. ENDIF.
          IF ls_check_elem-line > <ls_rg>-max_line. <ls_rg>-max_line = ls_check_elem-line. ENDIF.
          IF ls_check_elem-colm < <ls_rg>-min_col. <ls_rg>-min_col = ls_check_elem-colm. ENDIF.
          IF ls_check_elem-colm + ls_check_elem-leng > <ls_rg>-max_col. <ls_rg>-max_col = ls_check_elem-colm + ls_check_elem-leng. ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_rad_groups INTO DATA(ls_rg_entry).
      APPEND VALUE rpy_dycatt(
        name       = ls_rg_entry-name
        element_of = 'SCREEN'
        type       = 'RADIOGROUP'
        line       = ls_rg_entry-min_line
        column     = ls_rg_entry-min_col
        length     = ls_rg_entry-max_col - ls_rg_entry-min_col + 1
        height     = ls_rg_entry-max_line - ls_rg_entry-min_line + 1
      ) TO lt_ext_cnt.
    ENDLOOP.

    " Auto-register container controls into lt_ext_cnt
    LOOP AT ls_payload-fields INTO DATA(ls_cnt_check).
      DATA(lv_cnt_chk_type) = to_upper( ls_cnt_check-type ).
      DATA(lv_parent_cnt) = COND rpy_dycatt-element_of(
        WHEN ls_cnt_check-control_id IS NOT INITIAL THEN to_upper( ls_cnt_check-control_id )
        ELSE 'SCREEN'
      ).
      CASE lv_cnt_chk_type.
        WHEN 'CUSTOMCONTROL'.
          APPEND VALUE rpy_dycatt(
            name       = to_upper( ls_cnt_check-name )
            element_of = lv_parent_cnt
            type       = 'CUST_CTRL'
            line       = ls_cnt_check-line
            column     = ls_cnt_check-colm
            length     = ls_cnt_check-leng
            height     = ls_cnt_check-height
            c_line_min = 1
            c_coln_min = 1
          ) TO lt_ext_cnt.
        WHEN 'TABLECONTROL'.
          APPEND VALUE rpy_dycatt(
            name       = to_upper( ls_cnt_check-name )
            element_of = lv_parent_cnt
            type       = 'TABLE_CTRL'
            line       = ls_cnt_check-line
            column     = ls_cnt_check-colm
            length     = ls_cnt_check-leng
            height     = ls_cnt_check-height
            tc_tabtype = 'ENTRY'
            tc_separ_v = 'X'
            tc_separ_h = 'X'
            tc_title   = COND #( WHEN ls_cnt_check-stxt IS NOT INITIAL OR ls_cnt_check-text IS NOT INITIAL THEN 'X' ELSE ' ' )
            tc_header  = 'X'
            tc_config  = 'X'
            c_resize_v = 'X'
            c_resize_h = 'X'
            c_scroll_v = 'X'
            c_scroll_h = 'X'
          ) TO lt_ext_cnt.
        WHEN 'TABSTRIP'.
          APPEND VALUE rpy_dycatt(
            name       = to_upper( ls_cnt_check-name )
            element_of = lv_parent_cnt
            type       = 'STRIP_CTRL'
            line       = ls_cnt_check-line
            column     = ls_cnt_check-colm
            length     = ls_cnt_check-leng
            height     = ls_cnt_check-height
            c_line_min = 4
            c_coln_min = 7
          ) TO lt_ext_cnt.
        WHEN 'SUBSCREEN'.
          APPEND VALUE rpy_dycatt(
            name       = to_upper( ls_cnt_check-name )
            element_of = lv_parent_cnt
            type       = 'SUBSCREEN'
            line       = ls_cnt_check-line
            column     = ls_cnt_check-colm
            length     = ls_cnt_check-leng
            height     = ls_cnt_check-height
            c_line_min = 3
            c_coln_min = 3
            c_scroll_v = 'X'
            c_scroll_h = 'X'
          ) TO lt_ext_cnt.
      ENDCASE.
    ENDLOOP.

    " Map fields to containers for RPY_DYNPRO_INSERT
    LOOP AT ls_payload-fields INTO DATA(ls_elem).
      DATA: ls_f TYPE rpy_dyfatc.
      CLEAR ls_f.
      ls_f-cont_name   = 'SCREEN'.
      ls_f-cont_type   = 'SCREEN'.
      ls_f-name        = to_upper( ls_elem-name ).
      ls_f-line        = ls_elem-line.
      ls_f-column      = ls_elem-colm.
      ls_f-length      = ls_elem-leng.
      ls_f-height      = ls_elem-height.
      ls_f-text        = COND #( WHEN ls_elem-stxt IS NOT INITIAL THEN ls_elem-stxt ELSE ls_elem-text ).
      ls_f-format      = to_upper( ls_elem-format ).
      ls_f-push_fcode  = ls_elem-fcod.
      ls_f-push_ftype  = ls_elem-functype.
      ls_f-cxt_menon   = COND #( WHEN ls_elem-context_menu IS NOT INITIAL THEN ls_elem-context_menu ELSE ' ' ).
      ls_f-group1      = COND #( WHEN ls_elem-grp1 IS NOT INITIAL THEN ls_elem-grp1 ELSE ls_elem-group1 ).
      ls_f-group2      = COND #( WHEN ls_elem-grp2 IS NOT INITIAL THEN ls_elem-grp2 ELSE ls_elem-group2 ).
      ls_f-group3      = COND #( WHEN ls_elem-grp3 IS NOT INITIAL THEN ls_elem-grp3 ELSE ls_elem-group3 ).
      ls_f-group4      = COND #( WHEN ls_elem-grp4 IS NOT INITIAL THEN ls_elem-grp4 ELSE ls_elem-group4 ).
      IF ls_elem-poss_entry IS NOT INITIAL.
        ls_f-poss_entry = ls_elem-poss_entry.
      ELSEIF ls_elem-search_help IS NOT INITIAL.
        ls_f-poss_entry = '2'.
        ls_f-matchcode  = to_upper( ls_elem-search_help ).
      ENDIF.

      IF ls_f-name IS INITIAL.
        ls_f-name = |%#AUTOTEXT{ sy-tabix WIDTH = 3 PAD = '0' }|.
      ENDIF.

      DATA(lv_el_type) = to_upper( ls_elem-type ).
      IF lv_el_type = 'OKCODE' OR ls_elem-line = 255.
        CONTINUE.
      ENDIF.

      " Containers belong exclusively in lt_ext_cnt (RPY_DYCATT)
      IF lv_el_type = 'CUSTOMCONTROL' OR lv_el_type = 'TABLECONTROL' OR lv_el_type = 'TABSTRIP' OR lv_el_type = 'SUBSCREEN'.
        CONTINUE.
      ENDIF.

      IF lv_el_type = 'RADIOBUTTON'.
        IF ls_elem-radio_group IS NOT INITIAL.
          ls_f-cont_name = to_upper( ls_elem-radio_group ).
          ls_f-cont_type = 'RADIOGROUP'.
        ELSEIF ls_elem-control_id IS NOT INITIAL.
          ls_f-cont_name = to_upper( ls_elem-control_id ).
          ls_f-cont_type = 'RADIOGROUP'.
        ENDIF.
      ELSEIF ls_elem-control_id IS NOT INITIAL.
        READ TABLE lt_ext_cnt ASSIGNING FIELD-SYMBOL(<ls_match_cnt>) WITH KEY name = to_upper( ls_elem-control_id ).
        IF sy-subrc = 0 AND <ls_match_cnt>-type <> 'SCREEN' AND <ls_match_cnt>-type <> 'RADIOGROUP'.
          ls_f-cont_name = <ls_match_cnt>-name.
          ls_f-cont_type = <ls_match_cnt>-type.
        ENDIF.
      ENDIF.

      IF ls_f-cont_type = 'STRIP_CTRL'.
        IF ls_elem-functype IS NOT INITIAL.
          ls_f-push_ftype = ls_elem-functype.
        ELSEIF ls_elem-fcod IS NOT INITIAL.
          ls_f-push_ftype = ' '.
        ELSE.
          ls_f-push_ftype = 'P'.
        ENDIF.
        IF ls_elem-ref_field IS NOT INITIAL.
          ls_f-ref_field = to_upper( ls_elem-ref_field ).
        ELSE.
          READ TABLE lt_ext_cnt ASSIGNING FIELD-SYMBOL(<ls_sub_cnt>) WITH KEY element_of = ls_f-cont_name type = 'SUBSCREEN'.
          IF sy-subrc = 0.
            ls_f-ref_field = <ls_sub_cnt>-name.
          ENDIF.
        ENDIF.
      ENDIF.

      IF ls_f-cont_type = 'TABLE_CTRL'.
        IF lv_el_type = 'TEXT' OR lv_el_type = '%#AUTOTEXT'.
          ls_f-tc_heading = 'X'.
        ENDIF.
      ENDIF.

      " Fail-fast validation of element coordinates
      TYPES: BEGIN OF ty_val_err_resp,
               error TYPE string,
             END OF ty_val_err_resp.
      DATA: ls_val_err TYPE ty_val_err_resp.

      IF ls_elem-line < 1 OR ls_elem-line > 200.
        ls_val_err-error = |Field '{ ls_f-name }': invalid line { ls_elem-line } (must be 1..200)|.
        rv_json = /ui2/cl_json=>serialize( data = ls_val_err pretty_name = /ui2/cl_json=>pretty_mode-low_case ).
        RETURN.
      ENDIF.
      IF ls_elem-colm < 1 OR ls_elem-colm > 255.
        ls_val_err-error = |Field '{ ls_f-name }': invalid column { ls_elem-colm } (must be 1..255)|.
        rv_json = /ui2/cl_json=>serialize( data = ls_val_err pretty_name = /ui2/cl_json=>pretty_mode-low_case ).
        RETURN.
      ENDIF.

      CASE lv_el_type.
        WHEN 'TEXT' OR '%#AUTOTEXT'.
          ls_f-type = 'TEXT'.
        WHEN 'PUSHBUTTON'.
          ls_f-type = 'PUSH'.
          IF ls_f-text IS INITIAL.
            ls_val_err-error = |Pushbutton '{ ls_f-name }': text or icon caption is required|.
            rv_json = /ui2/cl_json=>serialize( data = ls_val_err pretty_name = /ui2/cl_json=>pretty_mode-low_case ).
            RETURN.
          ENDIF.
        WHEN 'CHECKBOX'.
          ls_f-type = 'CHECK'.
          IF ls_elem-fcod IS NOT INITIAL.
            ls_f-push_fcode = ls_elem-fcod.
          ENDIF.
        WHEN 'RADIOBUTTON'.
          ls_f-type = 'RADIO'.
          IF ls_elem-fcod IS NOT INITIAL.
            ls_f-push_fcode = ls_elem-fcod.
          ENDIF.
        WHEN 'FRAME'.
          ls_f-type = 'FRAME'.
          IF ls_f-height < 1.
            ls_val_err-error = |Frame '{ ls_f-name }': height must be >= 1 (got { ls_f-height })|.
            rv_json = /ui2/cl_json=>serialize( data = ls_val_err pretty_name = /ui2/cl_json=>pretty_mode-low_case ).
            RETURN.
          ENDIF.
        WHEN 'SUBSCREEN'.
          ls_f-type = 'SUBSCREEN'.
        WHEN 'CUSTOMCONTROL'.
          ls_f-type = 'CUST_CTRL'.
        WHEN 'TABSTRIP'.
          ls_f-type = 'TAB_CTRL'.
        WHEN 'TABLECONTROL'.
          ls_f-type = 'TABLE_CTRL'.
        WHEN 'STATUSICON'.
          ls_f-type       = 'TEMPLATE'.
          ls_f-with_icon  = 'X'.
          ls_f-length     = 132.
          ls_f-vislength  = COND #( WHEN ls_elem-leng > 0 THEN ls_elem-leng ELSE 4 ).
          ls_f-format     = 'CHAR'.
          ls_f-output_fld = 'X'.
          ls_f-outputonly = 'X'.
          ls_f-input_fld  = ' '.
        WHEN 'ENTRYFIELD'.
          ls_f-type = 'TEMPLATE'.
        WHEN 'OUTPUT'.
          ls_f-type = 'TEMPLATE'.
          ls_f-output_fld = 'X'.
          ls_f-input_fld  = ' '.
        WHEN 'DROPDOWN'.
          ls_f-type     = 'TEMPLATE'.
          ls_f-dropdown = 'L'.
          IF ls_elem-fcod IS NOT INITIAL.
            ls_f-push_fcode = ls_elem-fcod.
          ENDIF.
        WHEN OTHERS.
          ls_val_err-error = |Unsupported dynpro element type '{ lv_el_type }' for field '{ ls_f-name }'. | &&
            |Allowed canonical types: [TEXT, ENTRYFIELD, OUTPUT, DROPDOWN, PUSHBUTTON, CHECKBOX, RADIOBUTTON, FRAME, SUBSCREEN, CUSTOMCONTROL, TABSTRIP, TABLECONTROL, STATUSICON, OKCODE].|.
          rv_json = /ui2/cl_json=>serialize( data = ls_val_err pretty_name = /ui2/cl_json=>pretty_mode-low_case ).
          RETURN.
      ENDCASE.

      IF ls_elem-input = 'X' OR ls_elem-input = 'true' OR ls_elem-input = 'TRUE'
         OR ( ls_elem-input IS INITIAL AND lv_el_type <> 'OUTPUT'
              AND lv_el_type <> 'TEXT' AND lv_el_type <> '%#AUTOTEXT'
              AND lv_el_type <> 'FRAME' AND lv_el_type <> 'SUBSCREEN'
              AND lv_el_type <> 'CUSTOMCONTROL' AND lv_el_type <> 'TABSTRIP'
              AND lv_el_type <> 'TABLECONTROL' AND lv_el_type <> 'STATUSICON' ).
        ls_f-input_fld = 'X'.
      ENDIF.
      IF ls_elem-output = 'X' OR ls_elem-output = 'true' OR ls_elem-output = 'TRUE'
         OR ls_elem-output IS INITIAL.
        ls_f-output_fld = 'X'.
      ENDIF.
      IF ls_elem-required = 'X' OR ls_elem-required = 'true' OR ls_elem-required = 'TRUE'.
        ls_f-requ_entry = 'X'.
      ENDIF.
      IF ls_elem-lowercase = 'X' OR ls_elem-lowercase = 'true' OR ls_elem-lowercase = 'TRUE'.
        ls_f-up_lower = 'X'.
      ENDIF.
      IF ls_elem-invisible = 'X' OR ls_elem-invisible = 'true' OR ls_elem-invisible = 'TRUE'.
        ls_f-invisible = 'X'.
      ENDIF.
      IF ls_elem-right_justified = 'X' OR ls_elem-right_justified = 'true' OR ls_elem-right_justified = 'TRUE'.
        ls_f-right_just = 'X'.
      ENDIF.
      IF ls_elem-leading_zeros = 'X' OR ls_elem-leading_zeros = 'true' OR ls_elem-leading_zeros = 'TRUE'.
        ls_f-lead_zeros = 'X'.
      ENDIF.
      IF ls_elem-intensified = 'X' OR ls_elem-intensified = 'true' OR ls_elem-intensified = 'TRUE'.
        ls_f-bright = 'X'.
      ENDIF.
      IF lv_el_type = 'DROPDOWN' OR ls_elem-dropdown IS NOT INITIAL.
        ls_f-dropdown = 'L'.
        ls_f-type     = 'TEMPLATE'.
        IF ls_elem-fcod IS NOT INITIAL.
          ls_f-push_fcode = ls_elem-fcod.
        ENDIF.
      ENDIF.
      IF ls_elem-param_id IS NOT INITIAL.
        ls_f-set_param = 'X'.
        ls_f-get_param = 'X'.
      ENDIF.

      APPEND ls_f TO lt_ext_fld.
    ENDLOOP.

    LOOP AT ls_payload-flow_logic INTO DATA(ls_fl).
      APPEND VALUE rpy_dyflow( line = ls_fl-line ) TO lt_ext_flow.
    ENDLOOP.

    CALL FUNCTION 'RPY_DYNPRO_INSERT'
      EXPORTING
        header                 = ls_ext_head
        suppress_exist_checks  = 'X'
        suppress_corr_checks   = 'X'
        suppress_generate      = ' '
      TABLES
        containers             = lt_ext_cnt
        fields_to_containers   = lt_ext_fld
        flow_logic             = lt_ext_flow
        params                 = lt_ext_par
      EXCEPTIONS
        cancelled              = 1
        already_exists         = 2
        program_not_exists     = 3
        not_executed           = 4
        missing_required_field = 5
        illegal_field_value    = 6
        field_not_allowed      = 7
        not_generated          = 8
        illegal_field_position = 9
        OTHERS                 = 10.

    IF sy-subrc <> 0.
      DATA: lv_ins_err TYPE string.
      IF sy-msgid IS NOT INITIAL.
        MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                INTO lv_ins_err.
      ENDIF.
      ROLLBACK WORK.
      ls_resp-status  = 'error'.
      ls_resp-message = |RPY_DYNPRO_INSERT failed: { lv_ins_err } (subrc { sy-subrc })|.
      ls_resp-error   = lv_ins_err.
      rv_json = /ui2/cl_json=>serialize( data = ls_resp ).
      RETURN.
    ENDIF.

    " 3b. Ensure OK_CODE is explicitly bound in D021S element catalog
    IF ls_ext_head-type <> 'I' AND ls_ext_head-type <> 'N'.
      TYPES: BEGIN OF ty_dynp_sync_id,
               prog TYPE progname,
               dnum TYPE dynnr,
             END OF ty_dynp_sync_id.
      DATA: ls_sync_id     TYPE ty_dynp_sync_id,
            ls_sync_header TYPE d020s,
            lt_sync_fields TYPE TABLE OF d021s,
            lt_sync_flow   TYPE dyn_flowlist,
            lt_sync_params TYPE TABLE OF d023s,
            lv_sync_msg    TYPE string,
            lv_sync_line   TYPE i,
            lv_sync_word   TYPE string.

      ls_sync_id-prog = ls_payload-program.
      ls_sync_id-dnum = ls_payload-screen.

      IMPORT DYNPRO ls_sync_header lt_sync_fields lt_sync_flow lt_sync_params ID ls_sync_id.
      IF sy-subrc = 0.
        READ TABLE lt_sync_fields ASSIGNING FIELD-SYMBOL(<ls_sync_ok>) WITH KEY line = 255.
        IF sy-subrc = 0.
          <ls_sync_ok>-fnam = lv_ok_var_name.
          <ls_sync_ok>-flg1 = '80'.
          <ls_sync_ok>-flg2 = '10'.
          <ls_sync_ok>-flg3 = '08'.
        ELSE.
          APPEND VALUE #(
            fnam = lv_ok_var_name
            type = 'CHAR'
            line = 255
            coln = 1
            leng = 20
            stxt = '____________________'
            ltyp = 'O'
            flg1 = '80'
            flg2 = '10'
            flg3 = '08'
            fmb1 = '00'
            fmb2 = '00'
          ) TO lt_sync_fields.
        ENDIF.
        EXPORT DYNPRO ls_sync_header lt_sync_fields lt_sync_flow lt_sync_params ID ls_sync_id.
        GENERATE DYNPRO ls_sync_header lt_sync_fields lt_sync_flow lt_sync_params ID ls_sync_id
          MESSAGE lv_sync_msg LINE lv_sync_line WORD lv_sync_word.
      ENDIF.
    ENDIF.

    " 4. Ensure GUI Status (CUA) exists and update EUDB catalog
    IF ls_payload-program IS NOT INITIAL.
      DATA: lv_target_cua_status TYPE rsmpe-status,
            lv_cua_req           TYPE string.
      lv_target_cua_status = |STATUS_{ ls_payload-screen }|.
      lv_cua_req = |\{"program":"{ ls_payload-program }","status":"{ lv_target_cua_status }","title":"TITLE_{ ls_payload-screen }"\}|.
      lcl_cua_engine=>generate_cua_status( iv_payload = lv_cua_req ).
    ENDIF.

    " 5. Clear inactive worklist (DWINACTIV)
    DATA: lv_dynp_pattern TYPE dwinactiv-obj_name.
    lv_dynp_pattern = |{ ls_payload-program }%|.
    DELETE FROM dwinactiv WHERE object = 'DYNP' AND obj_name LIKE lv_dynp_pattern.

    " 6. Commit LUW in ICF
    COMMIT WORK AND WAIT.

    ls_resp-status  = 'saved_active'.
    ls_resp-message = 'Dynpro saved and generated successfully.'.
    rv_json = /ui2/cl_json=>serialize( data = ls_resp ).
  ENDMETHOD.

  METHOD check_dynpro_syntax.
    DATA: ls_payload TYPE ty_dynpro_payload.
    /ui2/cl_json=>deserialize( EXPORTING json = iv_payload CHANGING data = ls_payload ).

    IF ls_payload-program IS INITIAL OR ls_payload-screen IS INITIAL.
      rv_json = '[{"severity":"E","text":"Program and screen number are required."}]'.
      RETURN.
    ENDIF.

    IF ls_payload-fields IS INITIAL AND ls_payload-elements IS NOT INITIAL.
      ls_payload-fields = ls_payload-elements.
    ENDIF.

    DATA: ls_header TYPE d020s,
          lt_fields TYPE TABLE OF d021s,
          lt_flow   TYPE dyn_flowlist,
          lt_params TYPE TABLE OF d023s.

    ls_header-prog = ls_payload-program.
    ls_header-dnum = ls_payload-screen.
    IF ls_payload-header-type IS NOT INITIAL.
      ls_header-type = ls_payload-header-type.
    ELSE.
      ls_header-type = ' '.
    ENDIF.
    IF ls_payload-header-linc > 0.
      ls_header-noli = ls_payload-header-linc.
    ELSE.
      ls_header-noli = 27.
    ENDIF.
    IF ls_payload-header-colc > 0.
      ls_header-noco = ls_payload-header-colc.
    ELSE.
      ls_header-noco = 120.
    ENDIF.
    ls_header-spra = sy-langu.

    lt_fields = build_dynpro_fields( it_fields = ls_payload-fields ).
    lt_flow   = ls_payload-flow_logic.

    TYPES: BEGIN OF ty_dynpro_id,
             prog TYPE progname,
             dnum TYPE dynnr,
           END OF ty_dynpro_id.
    DATA: ls_id TYPE ty_dynpro_id.
    ls_id-prog = ls_payload-program.
    ls_id-dnum = ls_payload-screen.

    DATA: lv_msg  TYPE string,
          lv_line TYPE i,
          lv_word TYPE string.

    GENERATE DYNPRO ls_header lt_fields lt_flow lt_params ID ls_id
      MESSAGE lv_msg LINE lv_line WORD lv_word.

    IF sy-subrc <> 0.
      ROLLBACK WORK.
      TYPES: BEGIN OF ty_msg,
               severity TYPE string,
               line     TYPE i,
               text     TYPE string,
               word     TYPE string,
             END OF ty_msg.
      DATA: lt_msgs TYPE TABLE OF ty_msg,
            ls_m    TYPE ty_msg.
      ls_m-severity = 'E'.
      ls_m-line     = lv_line.
      ls_m-text     = lv_msg.
      ls_m-word     = lv_word.
      APPEND ls_m TO lt_msgs.
      rv_json = /ui2/cl_json=>serialize( data = lt_msgs ).
    ELSE.
      rv_json = '[]'.
    ENDIF.
  ENDMETHOD.

  METHOD build_field_text.
    cs_chfld-feldformat = 'CHAR'.
    cs_chfld-inttyp     = '0'.
    cs_chfld-flg1       = '00'.
    cs_chfld-flg2       = '00'.
    cs_chfld-flg3       = '00'.
    IF is_inp-icon IS NOT INITIAL OR ( is_inp-stxt IS NOT INITIAL AND is_inp-stxt(1) = '@' ).
      cs_chfld-fmb1     = '32'.
    ELSE.
      cs_chfld-fmb1     = '30'.
    ENDIF.
    cs_chfld-fmb2       = '00'.
  ENDMETHOD.

  METHOD build_field_pushbutton.
    cs_chfld-fill       = 'P'.
    cs_chfld-feldformat = 'CHAR'.
    cs_chfld-flg1       = '00'.
    cs_chfld-flg2       = '00'.
    cs_chfld-flg3       = '00'.
    cs_chfld-fmb1       = '30'.
    cs_chfld-fmb2       = '00'.
    IF is_inp-control_id CO '0123456789' AND is_inp-control_id IS NOT INITIAL.
      cs_chfld-auth     = is_inp-control_id.
    ELSE.
      cs_chfld-auth     = |{ iv_tabix + 100 WIDTH = 3 }|.
    ENDIF.
    IF is_inp-fcod IS NOT INITIAL.
      cs_res1-funccode   = is_inp-fcod.
    ENDIF.
    IF is_inp-functype IS NOT INITIAL.
      cs_res1-functype   = is_inp-functype.
    ENDIF.
  ENDMETHOD.

  METHOD build_field_choice.
    IF iv_type = 'DROPDOWN' OR is_inp-dropdown IS NOT INITIAL.
      cs_chfld-feldformat = COND #( WHEN iv_format IS NOT INITIAL THEN iv_format ELSE 'CHAR' ).
      cs_chfld-inttyp     = 'C'.
      cs_chfld-flg1       = '80'.
      cs_chfld-flg2       = '80'.
      IF is_inp-dropdown = 'LISTBOX_WITH_SEARCH_HELP' OR is_inp-search_help IS NOT INITIAL.
        cs_chfld-flg3     = '84'.
        cs_res1-dropval   = 'A'.
      ELSE.
        cs_chfld-flg3     = '80'.
        cs_res1-dropval   = ' '.
      ENDIF.
      cs_chfld-fmb1       = '80'.
      cs_chfld-fmb2       = '18'.
      cs_chfld-didx       = |{ is_inp-leng WIDTH = 3 ALIGN = RIGHT }|.
      cs_chfld-aglt       = |{ is_inp-leng WIDTH = 3 ALIGN = RIGHT }|.
      cs_res1-dropdown    = 'D'.
      cs_res1-droptyp     = 'L'.
      IF is_inp-stxt IS INITIAL.
        cs_chfld-stxt     = |{ '' WIDTH = is_inp-leng PAD = '_' }|.
      ENDIF.

    ELSEIF iv_type = 'RADIOBUTTON'.
      cs_chfld-fill       = 'A'.
      cs_chfld-feldformat = 'CHAR'.
      IF lv_is_input = abap_true OR is_inp-input IS INITIAL.
        cs_chfld-flg1     = '80'.
        cs_chfld-flg3     = '80'.
      ELSE.
        cs_chfld-flg1     = '00'.
        cs_chfld-flg3     = '00'.
        cs_chfld-fmb1     = '30'.
        cs_res1-labelright = 'X'.
      ENDIF.
      IF is_inp-radio_group CO '0123456789' AND is_inp-radio_group IS NOT INITIAL.
        cs_chfld-auth     = is_inp-radio_group.
      ELSEIF is_inp-control_id CO '0123456789' AND is_inp-control_id IS NOT INITIAL.
        cs_chfld-auth     = is_inp-control_id.
      ELSE.
        cs_chfld-auth     = |{ iv_tabix + 100 WIDTH = 3 }|.
      ENDIF.

    ELSEIF iv_type = 'CHECKBOX'.
      cs_chfld-fill       = 'C'.
      cs_chfld-feldformat = 'CHAR'.
      IF lv_is_input = abap_true OR is_inp-input IS INITIAL.
        cs_chfld-flg1     = '80'.
        cs_chfld-flg3     = '80'.
      ELSE.
        cs_chfld-flg1     = '00'.
        cs_chfld-flg3     = '00'.
        cs_chfld-fmb1     = '30'.
        cs_res1-labelright = 'X'.
      ENDIF.
      IF is_inp-control_id CO '0123456789' AND is_inp-control_id IS NOT INITIAL.
        cs_chfld-auth     = is_inp-control_id.
      ELSEIF is_inp-control_id IS NOT INITIAL.
        cs_chfld-auth     = |{ iv_tabix + 100 WIDTH = 3 }|.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD build_field_container.
    IF iv_type = 'FRAME'.
      cs_chfld-fill       = 'R'.
      cs_chfld-flg1       = '00'.
      cs_chfld-flg2       = '80'.
      cs_chfld-fmb1       = '00'.
      cs_chfld-fmb2       = '80'.
      IF is_inp-height > 0.
        cs_chfld-didx      = |{ is_inp-height WIDTH = 3 ALIGN = RIGHT }|.
        cs_chfld-loopblock = |{ is_inp-height WIDTH = 3 ALIGN = RIGHT }|.
      ENDIF.

    ELSEIF iv_type = 'SUBSCREEN'.
      cs_chfld-fill       = 'B'.
      cs_chfld-flg1       = '00'.
      cs_chfld-flg2       = '00'.
      cs_chfld-flg3       = '00'.
      cs_chfld-fmb1       = '00'.
      cs_chfld-fmb2       = '00'.
      IF is_inp-height > 0.
        cs_chfld-didx     = |{ is_inp-height WIDTH = 3 ALIGN = RIGHT }|.
      ENDIF.
      IF is_inp-control_id CO '0123456789' AND is_inp-control_id IS NOT INITIAL.
        cs_chfld-auth     = is_inp-control_id.
      ELSE.
        cs_chfld-auth     = '100'.
      ENDIF.

    ELSEIF iv_type = 'CUSTOMCONTROL'.
      cs_chfld-fill       = 'U'.
      cs_chfld-flg1       = '00'.
      cs_chfld-flg2       = '00'.
      cs_chfld-flg3       = '00'.
      cs_chfld-fmb1       = '30'.
      cs_chfld-fmb2       = '00'.
      IF is_inp-height > 0.
        cs_chfld-didx     = |{ is_inp-height WIDTH = 3 ALIGN = RIGHT }|.
      ENDIF.
      IF is_inp-control_id CO '0123456789' AND is_inp-control_id IS NOT INITIAL.
        cs_chfld-auth     = is_inp-control_id.
      ELSE.
        cs_chfld-auth     = '100'.
      ENDIF.
      cs_chfld-aglt       = |{ is_inp-min_lines WIDTH = 3 ALIGN = RIGHT }|.
      cs_chfld-adez       = |{ is_inp-min_cols WIDTH = 3 ALIGN = RIGHT }|.

    ELSEIF iv_type = 'TABSTRIP'.
      cs_chfld-fill       = 'I'.
      cs_chfld-looptype   = 'J'.
      cs_chfld-flg1       = '08'.
      cs_chfld-flg2       = '00'.
      cs_chfld-flg3       = '00'.
      cs_chfld-fmb1       = '00'.
      cs_chfld-fmb2       = '00'.
      IF is_inp-height > 0.
        cs_chfld-didx     = |{ is_inp-height WIDTH = 3 ALIGN = RIGHT }|.
      ENDIF.
      cs_chfld-loopbegin  = '  1'.
      cs_chfld-loopblock  = '  1'.
      cs_chfld-looprepeat = '  1'.

    ELSEIF iv_type = 'TABLECONTROL'.
      cs_chfld-fill       = 'T'.
      cs_chfld-looptype   = 'E'.
      cs_chfld-flg1       = 'F9'.
      cs_chfld-flg2       = 'FC'.
      cs_chfld-flg3       = '00'.
      cs_chfld-fmb1       = '00'.
      cs_chfld-fmb2       = '00'.
      IF is_inp-height > 0.
        cs_chfld-didx     = |{ is_inp-height WIDTH = 3 ALIGN = RIGHT }|.
      ENDIF.
      cs_chfld-loopbegin  = '  1'.
      cs_chfld-loopblock  = '  1'.
      cs_chfld-looprepeat = '  1'.
    ENDIF.
  ENDMETHOD.

  METHOD build_field_entry.
    CONSTANTS: c_x80 TYPE x LENGTH 1 VALUE '80',
               c_x40 TYPE x LENGTH 1 VALUE '40',
               c_x20 TYPE x LENGTH 1 VALUE '20',
               c_x10 TYPE x LENGTH 1 VALUE '10',
               c_x08 TYPE x LENGTH 1 VALUE '08',
               c_x04 TYPE x LENGTH 1 VALUE '04',
               c_x02 TYPE x LENGTH 1 VALUE '02',
               c_x01 TYPE x LENGTH 1 VALUE '01'.

    cs_chfld-feldformat = COND #( WHEN iv_format IS NOT INITIAL THEN iv_format
                                  WHEN iv_type IS NOT INITIAL AND iv_type <> 'ENTRYFIELD'
                                       AND iv_type <> 'INOU' AND iv_type <> 'IN'
                                       AND iv_type <> 'OUT' AND iv_type <> 'TEMPLATE' THEN iv_type
                                  ELSE 'CHAR' ).
    cs_chfld-inttyp     = COND #( WHEN is_inp-format IS NOT INITIAL THEN is_inp-format(1) ELSE 'C' ).

    DATA(lv_is_out_only) = COND abap_bool( WHEN is_inp-input = 'false' OR is_inp-type = 'OUT' THEN abap_true ELSE abap_false ).

    IF lv_is_out_only = abap_true.
      cs_chfld-flg1 = '80'.
      cs_chfld-flg2 = '00'.
      cs_chfld-flg3 = '80'.
      cs_chfld-fmb1 = COND #( WHEN lv_is_intens = abap_true THEN '38' ELSE '30' ).
      cs_chfld-fmb2 = '00'.
    ELSE.
      DATA: lv_f1 TYPE x LENGTH 1,
            lv_f2 TYPE x LENGTH 1,
            lv_f3 TYPE x LENGTH 1,
            lv_fmb1 TYPE x LENGTH 1,
            lv_fmb2 TYPE x LENGTH 1.

      lv_f1 = '80'. " Standard input entry field
      IF is_inp-scrollable = 'X' OR is_inp-scrollable = 'true'.
        lv_f1 = lv_f1 BIT-OR c_x01.
      ENDIF.
      cs_chfld-flg1 = |{ lv_f1 }|.

      lv_f2 = '80'.
      IF lv_is_right = abap_true.
        lv_f2 = lv_f2 BIT-OR c_x20.
      ENDIF.
      IF lv_is_lower = abap_true.
        lv_f2 = lv_f2 BIT-OR c_x02.
      ENDIF.
      IF is_inp-param_id IS NOT INITIAL.
        lv_f2 = lv_f2 BIT-OR c_x08 BIT-OR c_x04.
      ENDIF.
      cs_chfld-flg2 = |{ lv_f2 }|.

      lv_f3 = '80'.
      IF lv_is_req = abap_true.
        lv_f3 = lv_f3 BIT-OR c_x20.
      ENDIF.
      IF is_inp-search_help IS NOT INITIAL.
        lv_f3 = lv_f3 BIT-OR c_x04.
      ENDIF.
      cs_chfld-flg3 = |{ lv_f3 }|.

      lv_fmb1 = '00'.
      IF lv_is_invis = abap_true.
        lv_fmb1 = lv_fmb1 BIT-OR c_x04.
      ENDIF.
      IF lv_is_intens = abap_true.
        lv_fmb1 = lv_fmb1 BIT-OR c_x08.
      ENDIF.
      IF lv_is_zeros = abap_true.
        lv_fmb1 = lv_fmb1 BIT-OR c_x10.
      ENDIF.
      cs_chfld-fmb1 = |{ lv_fmb1 }|.
      cs_chfld-fmb2 = '00'.
    ENDIF.

    IF is_inp-stxt IS INITIAL.
      IF lv_is_req = abap_true AND lv_is_out_only = abap_false.
        DATA(lv_rem) = is_inp-leng - 1.
        IF lv_rem < 0. lv_rem = 0. ENDIF.
        cs_chfld-stxt = |?{ '' WIDTH = lv_rem PAD = '_' }|.
      ELSE.
        cs_chfld-stxt = |{ '' WIDTH = is_inp-leng PAD = '_' }|.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD apply_raw_bitmasks.
    DATA: lv_hex4 TYPE x LENGTH 4.
    LOOP AT it_meta INTO DATA(ls_m).
      READ TABLE ct_fields ASSIGNING FIELD-SYMBOL(<ls_raw_fld>)
        WITH KEY fnam = ls_m-name line = ls_m-line coln = ls_m-coln.
      IF sy-subrc = 0.
        IF ls_m-fld-functype IS NOT INITIAL.
          ls_m-res1+167(1) = ls_m-fld-functype.
        ENDIF.
        IF ls_m-fld-fcod IS NOT INITIAL.
          ls_m-res1+168(20) = ls_m-fld-fcod.
        ENDIF.
        <ls_raw_fld>-res1 = ls_m-res1.
        IF to_upper( ls_m-fld-type ) = 'NUMC' OR to_upper( ls_m-fld-format ) = 'NUMC'.
          <ls_raw_fld>-type = 'NUMC'.
          <ls_raw_fld>-ityp = 'N'.
          <ls_raw_fld>-fmb1 = '10'.
        ENDIF.
        IF ls_m-fld-height > 0.
          lv_hex4 = ls_m-fld-height.
          <ls_raw_fld>-didx = lv_hex4+2(2).
          IF <ls_raw_fld>-fill = 'R'.
            <ls_raw_fld>-lblk = lv_hex4+3(1).
          ENDIF.
        ENDIF.
        IF <ls_raw_fld>-flg3 = '80' OR <ls_raw_fld>-flg3 = '84'.
          lv_hex4 = ls_m-fld-leng.
          <ls_raw_fld>-didx = lv_hex4+2(2).
          <ls_raw_fld>-aglt = lv_hex4+3(1).
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD build_dynpro_fields.
    DATA: lt_meta  TYPE ty_elem_meta_tab,
          lt_chfld TYPE TABLE OF scr_chfld,
          ls_chfld TYPE scr_chfld,
          ls_res1  TYPE d021s_res1.

    LOOP AT it_fields INTO DATA(ls_inp).
      DATA(lv_tabix) = sy-tabix.
      CLEAR: ls_chfld, ls_res1.

      DATA(lv_name)   = to_upper( ls_inp-name ).
      DATA(lv_type)   = to_upper( ls_inp-type ).
      DATA(lv_format) = to_upper( ls_inp-format ).

      IF lv_name IS INITIAL.
        lv_name = |%#AUTOTEXT{ lv_tabix WIDTH = 3 PAD = '0' }|.
      ENDIF.

      IF ls_inp-stxt IS INITIAL AND ls_inp-text IS NOT INITIAL.
        ls_inp-stxt = ls_inp-text.
      ENDIF.
      IF ls_inp-grp1 IS INITIAL AND ls_inp-group1 IS NOT INITIAL.
        ls_inp-grp1 = ls_inp-group1.
      ENDIF.
      IF ls_inp-grp2 IS INITIAL AND ls_inp-group2 IS NOT INITIAL.
        ls_inp-grp2 = ls_inp-group2.
      ENDIF.
      IF ls_inp-grp3 IS INITIAL AND ls_inp-group3 IS NOT INITIAL.
        ls_inp-grp3 = ls_inp-group3.
      ENDIF.
      IF ls_inp-grp4 IS INITIAL AND ls_inp-group4 IS NOT INITIAL.
        ls_inp-grp4 = ls_inp-group4.
      ENDIF.
      IF ls_inp-height > 0 AND ls_inp-leng = 0.
        ls_inp-leng = ls_inp-width.
      ENDIF.

      DATA(lv_is_input)  = xsdbool( ls_inp-input = 'X' OR ls_inp-input = 'true' OR ls_inp-input = 'TRUE' ).
      DATA(lv_is_output) = xsdbool( ls_inp-output = 'X' OR ls_inp-output = 'true' OR ls_inp-output = 'TRUE' ).
      DATA(lv_is_req)    = xsdbool( ls_inp-required = 'X' OR ls_inp-required = 'true' OR ls_inp-required = 'TRUE' ).
      DATA(lv_is_lower)  = xsdbool( ls_inp-lowercase = 'X' OR ls_inp-lowercase = 'true' OR ls_inp-lowercase = 'TRUE' ).
      DATA(lv_is_intens) = xsdbool( ls_inp-intensified = 'X' OR ls_inp-intensified = 'true' OR ls_inp-intensified = 'TRUE' ).
      DATA(lv_is_invis)  = xsdbool( ls_inp-invisible = 'X' OR ls_inp-invisible = 'true' OR ls_inp-invisible = 'TRUE' ).
      DATA(lv_is_right)  = xsdbool( ls_inp-right_justified = 'X' OR ls_inp-right_justified = 'true' OR ls_inp-right_justified = 'TRUE' ).
      DATA(lv_is_zeros)  = xsdbool( ls_inp-leading_zeros = 'X' OR ls_inp-leading_zeros = 'true' OR ls_inp-leading_zeros = 'TRUE' ).
      DATA(lv_is_dblclk) = xsdbool( ls_inp-double_click = 'X' OR ls_inp-double_click = 'true' OR ls_inp-double_click = 'TRUE' ).
      DATA(lv_is_recom)  = xsdbool( ls_inp-recommended = 'X' OR ls_inp-recommended = 'true' OR ls_inp-recommended = 'TRUE' ).

      ls_chfld-feldname = lv_name.
      ls_chfld-line     = |{ ls_inp-line WIDTH = 3 ALIGN = RIGHT }|.
      ls_chfld-coln     = |{ ls_inp-colm WIDTH = 3 ALIGN = RIGHT }|.
      ls_chfld-laenge   = |{ ls_inp-leng WIDTH = 3 ALIGN = RIGHT }|.
      ls_chfld-stxt     = ls_inp-stxt.
      ls_chfld-grp1     = ls_inp-grp1.
      ls_chfld-grp2     = ls_inp-grp2.
      ls_chfld-grp3     = ls_inp-grp3.
      ls_chfld-grp4     = ls_inp-grp4.
      ls_chfld-paid     = ls_inp-param_id.
      ls_chfld-ucnv     = ls_inp-conv_exit.
      ls_chfld-dmac     = ls_inp-search_help.
      ls_chfld-looptype = ls_inp-ltyp.

      IF ls_inp-fcod IS NOT INITIAL.
        ls_res1-funccode = ls_inp-fcod.
        ls_chfld-paid    = ls_inp-fcod.
        ls_chfld-fmky    = ls_inp-fcod.
      ENDIF.
      IF ls_inp-functype IS NOT INITIAL.
        ls_res1-functype = ls_inp-functype.
      ENDIF.
      IF ls_inp-search_help IS NOT INITIAL.
        ls_res1-f4availabl = 'X'.
      ENDIF.
      IF ls_inp-context_menu IS NOT INITIAL.
        ls_res1-ctmenuflg  = 'X'.
        ls_res1-ctmenustat = ls_inp-context_menu.
        ls_res1-ctmenuprog = ls_inp-context_menu_prog.
      ENDIF.
      IF lv_is_dblclk = abap_true.
        ls_res1-dblclick = 'X'.
      ENDIF.
      IF lv_is_recom = abap_true.
        ls_res1-recentry = 'X'.
      ENDIF.

      " Dispatch to sub-builders
      IF lv_type = 'OKCODE'.
        ls_chfld-feldname   = to_upper( ls_inp-name ).
        ls_chfld-line       = '255'.
        ls_chfld-coln       = '  1'.
        ls_chfld-laenge     = ' 20'.
        ls_chfld-looptype   = 'O'.
        ls_chfld-feldformat = 'CHAR'.
        ls_chfld-flg1       = '80'.
        ls_chfld-flg2       = '10'.
        ls_chfld-flg3       = '08'.
        ls_chfld-fmb1       = '00'.
        ls_chfld-fmb2       = '00'.
        IF ls_chfld-stxt IS INITIAL.
          ls_chfld-stxt = |{ '' WIDTH = 20 PAD = '_' }|.
        ENDIF.
        CLEAR: ls_chfld-paid, ls_chfld-fmky, ls_res1.

      ELSEIF lv_type = 'TEXT'
          OR ( lv_type IS INITIAL AND ls_inp-name CS '%#AUTOTEXT' ).
        build_field_text(
          EXPORTING
            is_inp   = ls_inp
          CHANGING
            cs_chfld = ls_chfld
            cs_res1  = ls_res1 ).

      ELSEIF lv_type = 'DROPDOWN' OR lv_type = 'RADIOBUTTON' OR lv_type = 'CHECKBOX'
          OR ls_inp-dropdown IS NOT INITIAL.
        build_field_choice(
          EXPORTING
            is_inp      = ls_inp
            iv_type     = lv_type
            iv_format   = lv_format
            lv_is_input = lv_is_input
            iv_tabix    = lv_tabix
          CHANGING
            cs_chfld    = ls_chfld
            cs_res1     = ls_res1 ).

      ELSEIF lv_type = 'PUSHBUTTON'
          OR ( ls_inp-fcod IS NOT INITIAL AND lv_type <> 'RADIOBUTTON' AND lv_type <> 'CHECKBOX' AND lv_type <> 'DROPDOWN' ).
        build_field_pushbutton(
          EXPORTING
            is_inp   = ls_inp
            iv_tabix = lv_tabix
          CHANGING
            cs_chfld = ls_chfld
            cs_res1  = ls_res1 ).

      ELSEIF lv_type = 'FRAME' OR lv_type = 'SUBSCREEN' OR lv_type = 'CUSTOMCONTROL'
          OR lv_type = 'TABSTRIP' OR lv_type = 'TABLECONTROL'.
        build_field_container(
          EXPORTING
            is_inp   = ls_inp
            iv_type  = lv_type
          CHANGING
            cs_chfld = ls_chfld
            cs_res1  = ls_res1 ).

      ELSEIF lv_type = 'STATUSICON'.
        ls_chfld-feldformat = 'CHAR'.
        ls_chfld-inttyp     = 'C'.
        ls_chfld-flg1       = '80'.
        ls_chfld-flg2       = '00'.
        ls_chfld-flg3       = '80'.
        ls_chfld-fmb1       = '32'.
        ls_chfld-fmb2       = '00'.
        IF ls_chfld-stxt IS INITIAL.
          ls_chfld-stxt     = |@00@{ '' WIDTH = 22 PAD = '_' }|.
        ENDIF.

      ELSE.
        build_field_entry(
          EXPORTING
            is_inp       = ls_inp
            iv_type      = lv_type
            iv_format    = lv_format
            lv_is_intens = lv_is_intens
            lv_is_input  = lv_is_input
            lv_is_lower  = lv_is_lower
            lv_is_req    = lv_is_req
            lv_is_invis  = lv_is_invis
            lv_is_right  = lv_is_right
            lv_is_zeros  = lv_is_zeros
          CHANGING
            cs_chfld     = ls_chfld
            cs_res1      = ls_res1 ).
      ENDIF.

      " Explicit manual overrides
      IF ls_inp-ltyp IS NOT INITIAL.
        ls_chfld-looptype = ls_inp-ltyp.
      ENDIF.
      IF ls_inp-flg1 IS NOT INITIAL.
        ls_chfld-flg1 = ls_inp-flg1.
      ENDIF.
      IF ls_inp-flg2 IS NOT INITIAL.
        ls_chfld-flg2 = ls_inp-flg2.
      ENDIF.
      IF ls_inp-flg3 IS NOT INITIAL.
        ls_chfld-flg3 = ls_inp-flg3.
      ENDIF.
      IF ls_inp-fmb1 IS NOT INITIAL.
        ls_chfld-fmb1 = ls_inp-fmb1.
      ENDIF.
      IF ls_inp-fmb2 IS NOT INITIAL.
        ls_chfld-fmb2 = ls_inp-fmb2.
      ENDIF.
      IF ls_inp-fill IS NOT INITIAL.
        ls_chfld-fill = ls_inp-fill.
      ENDIF.
      IF ls_inp-auth IS NOT INITIAL.
        ls_chfld-auth = ls_inp-auth.
      ENDIF.

      APPEND ls_chfld TO lt_chfld.
      APPEND VALUE ty_elem_meta(
        name = lv_name
        line = ls_inp-line
        coln = ls_inp-colm
        res1 = ls_res1
        fld  = ls_inp
      ) TO lt_meta.
    ENDLOOP.

    CALL FUNCTION 'RS_SCRP_FIELDS_CHAR_TO_RAW'
      TABLES
        fields_char = lt_chfld
        fields_raw  = rt_fields
      EXCEPTIONS
        OTHERS      = 1.

    apply_raw_bitmasks(
      EXPORTING
        it_meta   = lt_meta
      CHANGING
        ct_fields = rt_fields ).
  ENDMETHOD.
  METHOD analyze_dynpro.
    TYPES: BEGIN OF ty_req,
             program TYPE progname,
             screen  TYPE dynnr,
           END OF ty_req.
    DATA: ls_req TYPE ty_req.
    /ui2/cl_json=>deserialize( EXPORTING json = iv_payload CHANGING data = ls_req ).

    DATA: ls_head TYPE rpy_dyhead,
          lt_cnt  TYPE dycatt_tab,
          lt_fld  TYPE dyfatc_tab,
          lt_d21  TYPE TABLE OF d021s.

    CALL FUNCTION 'RPY_DYNPRO_READ'
      EXPORTING
        progname              = ls_req-program
        dynnr                 = ls_req-screen
        suppress_exist_checks = ' '
        suppress_corr_checks  = ' '
      IMPORTING
        header                = ls_head
      TABLES
        containers            = lt_cnt
        fields_list           = lt_d21
        fields_to_containers  = lt_fld
      EXCEPTIONS
        OTHERS                = 1.

    TYPES: BEGIN OF ty_analysis,
             subrc                TYPE i,
             header               TYPE rpy_dyhead,
             containers           TYPE dycatt_tab,
             fields_to_containers TYPE dyfatc_tab,
             fields_list          TYPE STANDARD TABLE OF d021s WITH DEFAULT KEY,
           END OF ty_analysis.
    DATA: ls_out TYPE ty_analysis.
    ls_out-subrc                = sy-subrc.
    ls_out-header               = ls_head.
    ls_out-containers           = lt_cnt.
    ls_out-fields_to_containers = lt_fld.
    ls_out-fields_list          = lt_d21.

    rv_json = /ui2/cl_json=>serialize( data = ls_out ).
  ENDMETHOD.


ENDCLASS.

"======================================================================
" 4. CUA GUI Status Engine Implementation
"======================================================================
  CLASS lcl_cua_engine IMPLEMENTATION.
  METHOD generate_cua_status.
    TYPES: BEGIN OF ty_cua_req,
             program        TYPE trdir-name,
             status         TYPE rsmpe-status,
             title          TYPE rsmpe_titt-code,
             title_text     TYPE string,
             source_program TYPE trdir-name,
           END OF ty_cua_req.
    DATA: ls_req TYPE ty_cua_req.
    /ui2/cl_json=>deserialize( EXPORTING json = iv_payload CHANGING data = ls_req ).

    IF ls_req-program IS INITIAL.
      rv_json = '{"error": "Target program is required."}'.
      RETURN.
    ENDIF.

    DATA: lt_sta TYPE STANDARD TABLE OF rsmpe_stat WITH DEFAULT KEY,
          lt_fun TYPE STANDARD TABLE OF rsmpe_funt WITH DEFAULT KEY,
          lt_men TYPE STANDARD TABLE OF rsmpe_men WITH DEFAULT KEY,
          lt_mtx TYPE STANDARD TABLE OF rsmpe_mnlt WITH DEFAULT KEY,
          lt_act TYPE STANDARD TABLE OF rsmpe_act WITH DEFAULT KEY,
          lt_but TYPE STANDARD TABLE OF rsmpe_but WITH DEFAULT KEY,
          lt_pfk TYPE STANDARD TABLE OF rsmpe_pfk WITH DEFAULT KEY,
          lt_set TYPE STANDARD TABLE OF rsmpe_staf WITH DEFAULT KEY,
          lt_doc TYPE STANDARD TABLE OF rsmpe_atrt WITH DEFAULT KEY,
          lt_tit TYPE STANDARD TABLE OF rsmpe_titt WITH DEFAULT KEY,
          lt_biv TYPE STANDARD TABLE OF rsmpe_buts WITH DEFAULT KEY,
          ls_adm TYPE rsmpe_adm.

    DATA: lv_src TYPE trdir-name.
    IF ls_req-source_program IS NOT INITIAL.
      lv_src = ls_req-source_program.
    ELSE.
      " Try fetching existing CUA from target program first to preserve existing statuses (e.g. STATUS_0100)
      CALL FUNCTION 'RS_CUA_INTERNAL_FETCH'
        EXPORTING
          program         = ls_req-program
        IMPORTING
          adm             = ls_adm
        TABLES
          sta             = lt_sta
          fun             = lt_fun
          men             = lt_men
          mtx             = lt_mtx
          act             = lt_act
          but             = lt_but
          pfk             = lt_pfk
          set             = lt_set
          doc             = lt_doc
          tit             = lt_tit
          biv             = lt_biv
        EXCEPTIONS
          OTHERS          = 1.

      IF sy-subrc <> 0 OR lt_sta IS INITIAL.
        lv_src = 'SAPLKKBL'.
      ENDIF.
    ENDIF.

    IF lv_src IS NOT INITIAL.
      CALL FUNCTION 'RS_CUA_INTERNAL_FETCH'
        EXPORTING
          program         = lv_src
        IMPORTING
          adm             = ls_adm
        TABLES
          sta             = lt_sta
          fun             = lt_fun
          men             = lt_men
          mtx             = lt_mtx
          act             = lt_act
          but             = lt_but
          pfk             = lt_pfk
          set             = lt_set
          doc             = lt_doc
          tit             = lt_tit
          biv             = lt_biv
        EXCEPTIONS
          OTHERS          = 1.

      IF sy-subrc <> 0.
        rv_json = |\{"error": "Failed to fetch source CUA template from { lv_src }"\}|.
        RETURN.
      ENDIF.
    ENDIF.

    DATA(lv_target_status) = COND rsmpe-status( WHEN ls_req-status IS NOT INITIAL THEN ls_req-status ELSE 'STATUS_0100' ).
    DATA(lv_target_title)  = COND rsmpe_titt-code( WHEN ls_req-title IS NOT INITIAL THEN ls_req-title ELSE 'TITLE_0100' ).

    READ TABLE lt_sta ASSIGNING FIELD-SYMBOL(<ls_sta>) WITH KEY code = 'STANDARD'.
    IF sy-subrc <> 0.
      READ TABLE lt_sta ASSIGNING <ls_sta> INDEX 1.
    ENDIF.

    DATA: lv_pfk_code TYPE rsmpe_stat-pfkcode,
          lv_act_code TYPE rsmpe_stat-actcode,
          lv_but_code TYPE rsmpe_stat-butcode.

    IF <ls_sta> IS ASSIGNED.
      lv_pfk_code = <ls_sta>-pfkcode.
      lv_act_code = <ls_sta>-actcode.
    ELSE.
      lv_pfk_code = '000001'.
      lv_act_code = '000001'.
    ENDIF.
    lv_but_code = ' '. " Clean application toolbar (no unwanted ALV buttons)
    CLEAR: lt_but, lt_biv.

    READ TABLE lt_sta ASSIGNING FIELD-SYMBOL(<ls_target_sta>) WITH KEY code = lv_target_status.
    IF sy-subrc = 0.
      <ls_target_sta>-int_note = 'Standard Dynpro GUI Status'.
      <ls_target_sta>-pfkcode  = lv_pfk_code.
      <ls_target_sta>-actcode  = lv_act_code.
      <ls_target_sta>-butcode  = lv_but_code.
    ELSE.
      APPEND VALUE #(
        code     = lv_target_status
        int_note = 'Standard Dynpro GUI Status'
        pfkcode  = lv_pfk_code
        actcode  = lv_act_code
        butcode  = lv_but_code
      ) TO lt_sta.
    ENDIF.

    " Rebuild clean STAF entries for target status without deleting other statuses
    DELETE lt_set WHERE status = lv_target_status.
    DATA: lt_std_func_list TYPE TABLE OF rsmpe_staf-function.
    lt_std_func_list = VALUE #( ( 'BACK' ) ( 'EXIT' ) ( 'CANC' ) ( 'SAVE' ) ( 'EXEC' ) ( 'REST' ) ( 'APPLY' ) ).
    LOOP AT lt_std_func_list INTO DATA(lv_fnc).
      APPEND VALUE #( status = lv_target_status function = lv_fnc ) TO lt_set.
    ENDLOOP.

    " Explicitly ensure standard function keys (F3, F12, Shift+F3, Ctrl+S) are mapped in PFK
    TYPES: BEGIN OF ty_pfk_def,
             pfno    TYPE rsmpe_pfk-pfno,
             funcode TYPE rsmpe_pfk-funcode,
           END OF ty_pfk_def.
    DATA: lt_std_pfks TYPE TABLE OF ty_pfk_def.
    lt_std_pfks = VALUE #(
      ( pfno = '03' funcode = 'BACK' )
      ( pfno = '12' funcode = 'CANC' )
      ( pfno = '15' funcode = 'EXIT' )
      ( pfno = '11' funcode = 'SAVE' )
      ( pfno = '08' funcode = 'EXEC' )
    ).

    LOOP AT lt_std_pfks INTO DATA(ls_spf).
      READ TABLE lt_pfk ASSIGNING FIELD-SYMBOL(<ls_pk>) WITH KEY code = lv_pfk_code pfno = ls_spf-pfno.
      IF sy-subrc = 0.
        <ls_pk>-funcode = ls_spf-funcode.
      ELSE.
        APPEND VALUE #(
          code    = lv_pfk_code
          pfno    = ls_spf-pfno
          funcode = ls_spf-funcode
          funno   = '001'
        ) TO lt_pfk.
      ENDIF.
    ENDLOOP.

    " Ensure standard function definitions exist in lt_fun with correct function types
    TYPES: BEGIN OF ty_fun_def,
             code TYPE rsmpe_funt-code,
             type TYPE rsmpe_funt-type,
             text TYPE rsmpe_funt-fun_text,
           END OF ty_fun_def.
    DATA: lt_std_funs TYPE TABLE OF ty_fun_def.
    lt_std_funs = VALUE #(
      ( code = 'BACK' type = ' ' text = 'Back' )
      ( code = 'EXIT' type = 'E' text = 'Exit' )
      ( code = 'CANC' type = 'E' text = 'Cancel' )
      ( code = 'SAVE' type = ' ' text = 'Save' )
      ( code = 'EXEC' type = ' ' text = 'Execute' )
      ( code = 'REST' type = ' ' text = 'Reset' )
      ( code = 'APPLY' type = ' ' text = 'Apply' )
    ).

    LOOP AT lt_std_funs INTO DATA(ls_sfn).
      READ TABLE lt_fun ASSIGNING FIELD-SYMBOL(<ls_fn>) WITH KEY code = ls_sfn-code.
      IF sy-subrc = 0.
        <ls_fn>-type      = ls_sfn-type.
        <ls_fn>-fun_text  = ls_sfn-text.
        <ls_fn>-text_type = 'S'.
      ELSE.
        APPEND VALUE #(
          code      = ls_sfn-code
          type      = ls_sfn-type
          fun_text  = ls_sfn-text
          text_type = 'S'
        ) TO lt_fun.
      ENDIF.
    ENDLOOP.

    " Add TITLE_0100 to Titlebar list
    DATA: lv_ttext TYPE string.
    IF ls_req-title_text IS NOT INITIAL.
      lv_ttext = ls_req-title_text.
    ELSE.
      lv_ttext = 'ABAP Dynpro Showcase - &1'.
    ENDIF.

    READ TABLE lt_tit ASSIGNING FIELD-SYMBOL(<ls_tit>) WITH KEY code = lv_target_title.
    IF sy-subrc = 0.
      <ls_tit>-text = lv_ttext.
    ELSE.
      APPEND VALUE #( code = lv_target_title text = lv_ttext ) TO lt_tit.
    ENDIF.

    DATA: lv_tgt TYPE trdir-name.
    lv_tgt = ls_req-program.

    DATA: ls_trkey TYPE trkey.
    ls_trkey-obj_type = 'CUAD'.
    ls_trkey-obj_name = lv_tgt.
    ls_trkey-devclass = '$TMP'.

    CALL FUNCTION 'RS_CUA_INTERNAL_WRITE'
      EXPORTING
        program      = lv_tgt
        language     = sy-langu
        tr_key       = ls_trkey
        adm          = ls_adm
        state        = 'A'
      TABLES
        sta          = lt_sta
        fun          = lt_fun
        men          = lt_men
        mtx          = lt_mtx
        act          = lt_act
        but          = lt_but
        pfk          = lt_pfk
        set          = lt_set
        doc          = lt_doc
        tit          = lt_tit
        biv          = lt_biv
      EXCEPTIONS
        OTHERS       = 1.

    IF sy-subrc <> 0.
      rv_json = |\{"error": "RS_CUA_INTERNAL_WRITE failed with subrc={ sy-subrc }"\}|.
      RETURN.
    ENDIF.

    CALL FUNCTION 'RS_CUA_INTERNAL_GENERATE'
      EXPORTING
        program = lv_tgt
      EXCEPTIONS
        OTHERS  = 1.

    COMMIT WORK AND WAIT.

    rv_json = '{"status":"success","message":"CUA GUI Status and Titlebar generated successfully."}'.
  ENDMETHOD.
ENDCLASS.

