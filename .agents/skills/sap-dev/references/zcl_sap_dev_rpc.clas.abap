CLASS zcl_sap_dev_rpc DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_http_extension.
    CLASS-METHODS handle_sap_create_transaction
      IMPORTING
        iv_payload     TYPE string
      RETURNING
        VALUE(rv_json) TYPE string.
    METHODS get_object_handler
      IMPORTING
        iv_object_type    TYPE string
      RETURNING
        VALUE(ro_handler) TYPE REF TO zcl_sap_dev_object_hdlr.
  PROTECTED SECTION.
    METHODS handle_sap_read_screen
      IMPORTING
        iv_payload     TYPE string
      RETURNING
        VALUE(rv_json) TYPE string.
    METHODS handle_sap_read_screen_status
      IMPORTING
        iv_payload     TYPE string
      RETURNING
        VALUE(rv_json) TYPE string.
    METHODS handle_sap_push_source
      IMPORTING
        iv_payload     TYPE string
      RETURNING
        VALUE(rv_json) TYPE string.
    METHODS handle_sap_push_metadata
      IMPORTING
        iv_payload     TYPE string
      RETURNING
        VALUE(rv_json) TYPE string.
    METHODS handle_sap_search_customizing
      IMPORTING
        iv_payload     TYPE string
      RETURNING
        VALUE(rv_json) TYPE string.
    METHODS handle_sap_fetch_transaction
      IMPORTING
        iv_payload     TYPE string
      RETURNING
        VALUE(rv_json) TYPE string.
    METHODS handle_sap_reapply_metadata
      IMPORTING
        iv_payload     TYPE string
      RETURNING
        VALUE(rv_json) TYPE string.
    METHODS handle_sap_read_translations
      IMPORTING
        iv_payload     TYPE string
      RETURNING
        VALUE(rv_json) TYPE string.
    METHODS handle_sap_push_translations
      IMPORTING
        iv_payload     TYPE string
      RETURNING
        VALUE(rv_json) TYPE string.
    METHODS handle_sap_fetch_metadata
      IMPORTING
        iv_payload     TYPE string
      RETURNING
        VALUE(rv_json) TYPE string.
    METHODS handle_sap_fetch_source_rpc
      IMPORTING
        iv_payload     TYPE string
      RETURNING
        VALUE(rv_json) TYPE string.
    METHODS handle_sap_fetch
      IMPORTING
        iv_payload     TYPE string
      RETURNING
        VALUE(rv_json) TYPE string.
    METHODS handle_sap_push
      IMPORTING
        iv_payload     TYPE string
      RETURNING
        VALUE(rv_json) TYPE string.
    METHODS handle_sap_search_src_code
      IMPORTING
        iv_payload     TYPE string
      RETURNING
        VALUE(rv_json) TYPE string.
  PRIVATE SECTION.
ENDCLASS.

CLASS ZCL_SAP_DEV_RPC IMPLEMENTATION.
  METHOD if_http_extension~handle_request.
    DATA: lv_body     TYPE string,
          lv_response TYPE string.

    lv_body = server->request->get_cdata( ).

    TYPES: BEGIN OF ty_req,
             tool TYPE string,
           END OF ty_req.
    DATA: ls_req TYPE ty_req.

    TRY.
        " Parse just the tool name for routing
        /ui2/cl_json=>deserialize( EXPORTING json = lv_body CHANGING data = ls_req ).

        CASE ls_req-tool.
          WHEN 'ping'.
            lv_response = '{"status": "pong"}'.
          WHEN 'sap_fetch'.
            lv_response = handle_sap_fetch( lv_body ).
          WHEN 'sap_push'.
            lv_response = handle_sap_push( lv_body ).
          WHEN 'sap_read_screen'.
            lv_response = handle_sap_read_screen( lv_body ).
          WHEN 'sap_read_screen_status'.
            lv_response = handle_sap_read_screen_status( lv_body ).
          WHEN 'sap_push_source'.
            lv_response = handle_sap_push_source( lv_body ).
          WHEN 'sap_push_metadata'.
            lv_response = handle_sap_push_metadata( lv_body ).
          WHEN 'sap_search_customizing_node'.
            lv_response = handle_sap_search_customizing( lv_body ).
          WHEN 'sap_reapply_metadata'.
            lv_response = handle_sap_reapply_metadata( lv_body ).
          WHEN 'sap_fetch_transaction'.
            lv_response = handle_sap_fetch_transaction( lv_body ).
          WHEN 'sap_create_transaction'.
            lv_response = handle_sap_create_transaction( lv_body ).
          WHEN 'sap_read_translations'.
            lv_response = handle_sap_read_translations( lv_body ).
          WHEN 'sap_push_translations'.
            lv_response = handle_sap_push_translations( lv_body ).
          WHEN 'sap_fetch_metadata'.
            lv_response = handle_sap_fetch_metadata( lv_body ).
          WHEN 'sap_fetch_source'.
            lv_response = handle_sap_fetch_source_rpc( lv_body ).
          WHEN 'sap_search_source_code'.
            lv_response = handle_sap_search_src_code( lv_body ).
          WHEN OTHERS.
            server->response->set_status( code = 400 reason = 'Bad Request' ).
            server->response->set_cdata( |Unknown or missing tool parameter: { ls_req-tool }| ).
            RETURN.
        ENDCASE.

        server->response->set_status( code = 200 reason = 'OK' ).
        server->response->set_content_type( 'application/json' ).
        server->response->set_cdata( lv_response ).
      CATCH cx_root INTO DATA(lx_root).
        server->response->set_status( code = 500 reason = 'Internal Server Error' ).
        server->response->set_content_type( 'application/json' ).
        server->response->set_cdata( |\{"error": "{ lx_root->get_text( ) }"\}| ).
    ENDTRY.
  ENDMETHOD.

  METHOD handle_sap_read_screen.
    TYPES: BEGIN OF ty_payload,
             program TYPE c LENGTH 40,
             screen  TYPE c LENGTH 4,
           END OF ty_payload.
    DATA: ls_payload TYPE ty_payload.

    /ui2/cl_json=>deserialize( EXPORTING json = iv_payload CHANGING data = ls_payload ).

    DATA: ls_header TYPE d020s,
          lt_fields TYPE TABLE OF d021s,
          lt_flow   TYPE dyn_flowlist,
          lv_text   TYPE d020t-dtxt.

    TRY.
        CALL FUNCTION 'RPY_DYNPRO_READ_NATIVE'
          EXPORTING
            progname              = ls_payload-program
            dynnr                 = ls_payload-screen
            suppress_exist_checks = ' '
            suppress_corr_checks  = ' '
          IMPORTING
            header                = ls_header
            dynprotext            = lv_text
          TABLES
            fieldlist             = lt_fields
            flowlogic             = lt_flow
          EXCEPTIONS
            cancelled             = 1
            not_found             = 2
            permission_error      = 3
            OTHERS                = 4.

        IF sy-subrc = 0.
          TYPES: BEGIN OF ty_result,
                   header     TYPE d020s,
                   fields     TYPE STANDARD TABLE OF d021s WITH DEFAULT KEY,
                   flow_logic TYPE dyn_flowlist,
                 END OF ty_result.
          DATA: ls_result TYPE ty_result.
          ls_result-header = ls_header.
          ls_result-fields = lt_fields.
          ls_result-flow_logic = lt_flow.

          rv_json = /ui2/cl_json=>serialize( data = ls_result ).
        ELSE.
          DATA: lv_err_msg TYPE string.
          IF sy-msgid IS NOT INITIAL.
            MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                    INTO lv_err_msg.
          ELSE.
            lv_err_msg = |Dynpro read failed with SUBRC: { sy-subrc }|.
          ENDIF.
          rv_json = |\{"error": "{ lv_err_msg }"\}|.
        ENDIF.
      CATCH cx_root INTO DATA(lx_root).
        rv_json = |\{"error": "{ lx_root->get_text( ) }"\}|.
    ENDTRY.
  ENDMETHOD.

  METHOD handle_sap_read_screen_status.
    TYPES: BEGIN OF ty_payload,
             program TYPE c LENGTH 40,
           END OF ty_payload.
    DATA: ls_payload TYPE ty_payload.

    /ui2/cl_json=>deserialize( EXPORTING json = iv_payload CHANGING data = ls_payload ).

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
          lt_biv TYPE STANDARD TABLE OF rsmpe_buts WITH DEFAULT KEY.

    TRY.
        CALL FUNCTION 'RS_CUA_INTERNAL_FETCH'
          EXPORTING
            program         = ls_payload-program
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
            not_found       = 1
            unknown_version = 2
            OTHERS          = 3.

        IF sy-subrc = 0.
          TYPES: BEGIN OF ty_result,
                   sta TYPE STANDARD TABLE OF rsmpe_stat WITH DEFAULT KEY,
                   fun TYPE STANDARD TABLE OF rsmpe_funt WITH DEFAULT KEY,
                   men TYPE STANDARD TABLE OF rsmpe_men WITH DEFAULT KEY,
                   mtx TYPE STANDARD TABLE OF rsmpe_mnlt WITH DEFAULT KEY,
                   act TYPE STANDARD TABLE OF rsmpe_act WITH DEFAULT KEY,
                   but TYPE STANDARD TABLE OF rsmpe_but WITH DEFAULT KEY,
                   pfk TYPE STANDARD TABLE OF rsmpe_pfk WITH DEFAULT KEY,
                   set TYPE STANDARD TABLE OF rsmpe_staf WITH DEFAULT KEY,
                   doc TYPE STANDARD TABLE OF rsmpe_atrt WITH DEFAULT KEY,
                   tit TYPE STANDARD TABLE OF rsmpe_titt WITH DEFAULT KEY,
                   biv TYPE STANDARD TABLE OF rsmpe_buts WITH DEFAULT KEY,
                 END OF ty_result.
          DATA: ls_result TYPE ty_result.
          ls_result-sta = lt_sta.
          ls_result-fun = lt_fun.
          ls_result-men = lt_men.
          ls_result-mtx = lt_mtx.
          ls_result-act = lt_act.
          ls_result-but = lt_but.
          ls_result-pfk = lt_pfk.
          ls_result-set = lt_set.
          ls_result-doc = lt_doc.
          ls_result-tit = lt_tit.
          ls_result-biv = lt_biv.

          rv_json = /ui2/cl_json=>serialize( data = ls_result ).
        ELSE.
          DATA: lv_err_msg TYPE string.
          IF sy-msgid IS NOT INITIAL.
            MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                    INTO lv_err_msg.
          ELSE.
            lv_err_msg = |Status read failed with SUBRC: { sy-subrc }|.
          ENDIF.
          rv_json = |\{"error": "{ lv_err_msg }"\}|.
        ENDIF.
      CATCH cx_root INTO DATA(lx_root).
        rv_json = |\{"error": "{ lx_root->get_text( ) }"\}|.
    ENDTRY.
  ENDMETHOD.

  METHOD handle_sap_push_source.
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
              iv_action  = 'HANDLE_PUSH_SOURCE'
              iv_payload = iv_payload
              io_rpc     = me
            RECEIVING
              rv_json    = rv_json.
        CATCH cx_root INTO DATA(lx_root).
          rv_json = |\{"error": "Failed to execute dev helper: { escape( val = lx_root->get_text( ) format = cl_abap_format=>e_json_string ) }"\}|.
      ENDTRY.
    ELSE.
      rv_json = '{"error": "Write operations are disabled on this system."}'.
    ENDIF.
  ENDMETHOD.

  METHOD handle_sap_search_customizing.
    TYPES: BEGIN OF ty_payload,
             query    TYPE string,
             language TYPE c LENGTH 1,
           END OF ty_payload.
    DATA: ls_payload TYPE ty_payload.

    /ui2/cl_json=>deserialize( EXPORTING json = iv_payload CHANGING data = ls_payload ).

    DATA: lv_langu TYPE sy-langu.
    IF ls_payload-language IS NOT INITIAL.
      lv_langu = ls_payload-language.
    ELSE.
      lv_langu = sy-langu.
    ENDIF.

    SELECT node_id, text FROM tnodeimgt INTO TABLE @DATA(lt_nodes) WHERE spras = @lv_langu.
    SELECT activity, text FROM cus_imgact INTO TABLE @DATA(lt_activities) WHERE spras = @lv_langu.

    TYPES: BEGIN OF ty_node_match,
             node_id TYPE tnodeimgt-node_id,
             text    TYPE tnodeimgt-text,
           END OF ty_node_match.
    DATA: lt_matched_nodes TYPE TABLE OF ty_node_match.

    TYPES: BEGIN OF ty_node_ref,
             node_id TYPE tnodeimgr-node_id,
           END OF ty_node_ref.
    DATA: lt_node_refs TYPE TABLE OF ty_node_ref.

    LOOP AT lt_nodes INTO DATA(ls_node) WHERE text CS ls_payload-query.
      APPEND VALUE #( node_id = ls_node-node_id text = ls_node-text ) TO lt_matched_nodes.
    ENDLOOP.

    LOOP AT lt_activities INTO DATA(ls_act) WHERE text CS ls_payload-query.
      SELECT node_id FROM tnodeimgr APPENDING TABLE @lt_node_refs WHERE ref_object = @ls_act-activity.
    ENDLOOP.

    IF lt_node_refs IS NOT INITIAL.
      SELECT node_id, text FROM tnodeimgt APPENDING TABLE @lt_matched_nodes
        FOR ALL ENTRIES IN @lt_node_refs
        WHERE node_id = @lt_node_refs-node_id AND spras = @lv_langu.
    ENDIF.

    SORT lt_matched_nodes BY node_id.
    DELETE ADJACENT DUPLICATES FROM lt_matched_nodes COMPARING node_id.

    TYPES: BEGIN OF ty_result,
             node_id             TYPE string,
             node_text           TYPE string,
             spro_path           TYPE string_table,
             maintenance_objects TYPE string_table,
           END OF ty_result.
    DATA: lt_results TYPE TABLE OF ty_result,
          ls_result  TYPE ty_result,
          lt_path    TYPE string_table.

    LOOP AT lt_matched_nodes INTO DATA(ls_matched).
      CLEAR: ls_result, lt_path.
      ls_result-node_id   = ls_matched-node_id.
      ls_result-node_text = ls_matched-text.

      DATA(lv_current_node) = ls_matched-node_id.
      DO 20 TIMES.
        SELECT SINGLE parent_id FROM tnodeimg INTO @DATA(lv_parent) WHERE node_id = @lv_current_node.
        IF sy-subrc <> 0 OR lv_parent IS INITIAL.
          EXIT.
        ENDIF.

        SELECT SINGLE text FROM tnodeimgt INTO @DATA(lv_parent_text) WHERE node_id = @lv_parent AND spras = @lv_langu.
        IF sy-subrc = 0.
          INSERT lv_parent_text INTO lt_path INDEX 1.
        ELSE.
          INSERT |[{ lv_parent }]| INTO lt_path INDEX 1.
        ENDIF.
        lv_current_node = lv_parent.
      ENDDO.

      APPEND ls_result-node_text TO lt_path.
      ls_result-spro_path = lt_path.

      SELECT ref_object FROM tnodeimgr INTO TABLE @DATA(lt_refs) WHERE node_id = @ls_matched-node_id.

      DATA: lr_activities TYPE RANGE OF tnodeimgr-ref_object.
      CLEAR lr_activities.
      LOOP AT lt_refs INTO DATA(ls_ref).
        APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_ref-ref_object ) TO lr_activities.
      ENDLOOP.

      IF lr_activities IS NOT INITIAL.
        SELECT objectname
          FROM cus_actobj
          INTO TABLE @DATA(lt_objs)
          WHERE act_id IN @lr_activities.

        SELECT a~objectname
          FROM cus_actobj AS a
          INNER JOIN cus_imgach AS b ON a~act_id = b~c_activity
          APPENDING TABLE @lt_objs
          WHERE b~activity IN @lr_activities.

        LOOP AT lt_objs INTO DATA(ls_obj).
          APPEND ls_obj-objectname TO ls_result-maintenance_objects.
        ENDLOOP.
      ENDIF.

      APPEND ls_result TO lt_results.
    ENDLOOP.

    rv_json = /ui2/cl_json=>serialize( data = lt_results ).
  ENDMETHOD.

  METHOD handle_sap_push_metadata.
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
              iv_action  = 'HANDLE_PUSH_METADATA'
              iv_payload = iv_payload
              io_rpc     = me
            RECEIVING
              rv_json    = rv_json.
        CATCH cx_root INTO DATA(lx_root).
          rv_json = |\{"error": "Failed to execute dev helper: { escape( val = lx_root->get_text( ) format = cl_abap_format=>e_json_string ) }"\}|.
      ENDTRY.
    ELSE.
      rv_json = '{"error": "Write operations are disabled on this system."}'.
    ENDIF.
  ENDMETHOD.

  METHOD handle_sap_reapply_metadata.
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
              iv_action  = 'HANDLE_REAPPLY_METADATA'
              iv_payload = iv_payload
              io_rpc     = me
            RECEIVING
              rv_json    = rv_json.
        CATCH cx_root INTO DATA(lx_root).
          rv_json = |\{"error": "Failed to execute dev helper: { escape( val = lx_root->get_text( ) format = cl_abap_format=>e_json_string ) }"\}|.
      ENDTRY.
    ELSE.
      rv_json = '{"error": "Write operations are disabled on this system."}'.
    ENDIF.
  ENDMETHOD.

  METHOD handle_sap_fetch_transaction.
    TYPES: BEGIN OF ty_payload,
             tcode TYPE c LENGTH 20,
           END OF ty_payload.
    DATA: ls_payload TYPE ty_payload.

    /ui2/cl_json=>deserialize( EXPORTING json = iv_payload CHANGING data = ls_payload ).

    DATA: ls_tstc  TYPE tstc,
          ls_tstct TYPE tstct,
          lv_devclass TYPE devclass.

    SELECT SINGLE * FROM tstc INTO @ls_tstc WHERE tcode = @ls_payload-tcode.
    IF sy-subrc <> 0.
      rv_json = |\{"not_found": true\}|.
      RETURN.
    ENDIF.

    SELECT SINGLE * FROM tstct INTO @ls_tstct WHERE tcode = @ls_payload-tcode AND sprsl = @sy-langu.
    IF sy-subrc <> 0.
      SELECT SINGLE * FROM tstct INTO @ls_tstct WHERE tcode = @ls_payload-tcode.
    ENDIF.

    SELECT SINGLE devclass FROM tadir INTO @lv_devclass
      WHERE pgmid = 'R3TR' AND object = 'TRAN' AND obj_name = @ls_payload-tcode.
    IF sy-subrc <> 0.
      lv_devclass = '$TMP'.
    ENDIF.

    TYPES: BEGIN OF ty_tx_info,
             tcode     TYPE string,
             program   TYPE string,
             screen    TYPE string,
             text      TYPE string,
             type      TYPE string,
             package   TYPE string,
             not_found TYPE abap_bool,
           END OF ty_tx_info.
    DATA: ls_info TYPE ty_tx_info.

    ls_info-tcode     = ls_tstc-tcode.
    ls_info-program   = ls_tstc-pgmna.
    ls_info-screen    = ls_tstc-dypno.
    ls_info-text      = ls_tstct-ttext.
    ls_info-package   = lv_devclass.
    ls_info-not_found = abap_false.

    " Determine type ('R' for Report, 'D' for Dialog/Screen)
    IF ls_tstc-dypno = '1000' AND ls_tstc-pgmna IS NOT INITIAL.
      ls_info-type = 'R'.
    ELSE.
      ls_info-type = 'D'.
    ENDIF.

    rv_json = /ui2/cl_json=>serialize( data = ls_info ).
  ENDMETHOD.

  METHOD handle_sap_create_transaction.
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
              iv_action  = 'HANDLE_CREATE_TRANSACTION'
              iv_payload = iv_payload
            RECEIVING
              rv_json    = rv_json.
        CATCH cx_root INTO DATA(lx_root).
          rv_json = |\{"error": "Failed to execute dev helper: { escape( val = lx_root->get_text( ) format = cl_abap_format=>e_json_string ) }"\}|.
      ENDTRY.
    ELSE.
      rv_json = '{"error": "Write operations are disabled on this system."}'.
    ENDIF.
  ENDMETHOD.
  METHOD handle_sap_read_translations.
    TYPES: BEGIN OF ty_payload,
             object_name TYPE string,
             object_type TYPE string,
             language    TYPE string,
           END OF ty_payload.
    DATA: ls_payload TYPE ty_payload.

    /ui2/cl_json=>deserialize( EXPORTING json = iv_payload CHANGING data = ls_payload ).

    TRANSLATE ls_payload-object_name TO UPPER CASE.
    TRANSLATE ls_payload-object_type TO UPPER CASE.

    DATA: lv_name_key TYPE string,
          lv_type_key TYPE string.
    lv_name_key = ls_payload-object_name.
    lv_type_key = ls_payload-object_type.

    DATA(lo_handler) = get_object_handler( lv_type_key ).
    IF lo_handler IS NOT BOUND.
      TYPES: BEGIN OF ty_err_resp,
               error TYPE string,
             END OF ty_err_resp.
      DATA: ls_err_resp TYPE ty_err_resp.
      ls_err_resp-error = |Unsupported object type { lv_type_key } for translations. Consider extending ZCL_SAP_DEV_RPC_EXT to support it.|.
      rv_json = /ui2/cl_json=>serialize( data = ls_err_resp ).
      RETURN.
    ENDIF.

    DATA: lt_langs TYPE ty_langs,
          lv_langu TYPE sy-langu.

    IF ls_payload-language IS NOT INITIAL AND ls_payload-language <> '*' AND ls_payload-language <> 'ALL'.
      lv_langu = ls_payload-language.
      APPEND lv_langu TO lt_langs.
    ELSE.
      CASE lv_type_key.
        WHEN 'PROG' OR 'REPT'.
          SELECT DISTINCT spras FROM t002 INTO TABLE @lt_langs.
        WHEN 'DTEL'.
          SELECT DISTINCT ddlanguage FROM dd04t INTO TABLE @lt_langs
            WHERE rollname = @lv_name_key AND as4local = 'A'.
        WHEN 'DOMA'.
          SELECT DISTINCT ddlanguage FROM dd07t INTO TABLE @lt_langs
            WHERE domname = @lv_name_key AND as4local = 'A'.
        WHEN 'CLAS'.
          SELECT DISTINCT langu FROM seoclasstx INTO TABLE @lt_langs
            WHERE clsname = @lv_name_key.
        WHEN 'MSAG'.
          SELECT DISTINCT sprsl FROM t100t INTO TABLE @lt_langs
            WHERE arbgb = @lv_name_key.
        WHEN 'TTYP'.
          SELECT DISTINCT ddlanguage FROM dd40t INTO TABLE @lt_langs
            WHERE typename = @lv_name_key AND as4local = 'A'.
        WHEN 'TABL'.
          SELECT DISTINCT ddlanguage FROM dd02t INTO TABLE @lt_langs
            WHERE tabname = @lv_name_key AND as4local = 'A'.
      ENDCASE.
    ENDIF.

    IF lt_langs IS INITIAL.
      APPEND sy-langu TO lt_langs.
    ENDIF.

    DATA: lv_masterlang TYPE tadir-masterlang.
    SELECT SINGLE masterlang FROM tadir INTO @lv_masterlang
      WHERE pgmid = 'R3TR'
        AND object = @lv_type_key
        AND obj_name = @lv_name_key.
    IF sy-subrc <> 0.
      lv_masterlang = sy-langu.
    ENDIF.

    rv_json = lo_handler->read_translations(
      iv_object_name = lv_name_key
      iv_masterlang  = lv_masterlang
      it_langs       = lt_langs ).
  ENDMETHOD.

  METHOD handle_sap_push_translations.
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
              iv_action  = 'HANDLE_PUSH_TRANSLATIONS'
              iv_payload = iv_payload
              io_rpc     = me
            RECEIVING
              rv_json    = rv_json.
        CATCH cx_root INTO DATA(lx_root).
          rv_json = |\{"error": "Failed to execute dev helper: { escape( val = lx_root->get_text( ) format = cl_abap_format=>e_json_string ) }"\}|.
      ENDTRY.
    ELSE.
      rv_json = '{"error": "Write operations are disabled on this system."}'.
    ENDIF.
  ENDMETHOD.

  METHOD handle_sap_fetch_metadata.
    TYPES: BEGIN OF ty_payload,
             object_type TYPE string,
             object_name TYPE string,
           END OF ty_payload.
     DATA: ls_payload TYPE ty_payload.

     /ui2/cl_json=>deserialize( EXPORTING json = iv_payload CHANGING data = ls_payload ).

     DATA(lo_hdlr) = get_object_handler( ls_payload-object_type ).
     IF lo_hdlr IS BOUND.
       TRY.
           DATA(lv_xml) = lo_hdlr->fetch_metadata( ls_payload-object_name ).
           IF lv_xml IS NOT INITIAL.
             rv_json = lv_xml.
             RETURN.
           ENDIF.
         CATCH cx_root INTO DATA(lx_fetch_err).
           rv_json = |\{"error": "{ escape( val = lx_fetch_err->get_text( ) format = cl_abap_format=>e_json_string ) }"\}|.
           RETURN.
       ENDTRY.
     ENDIF.

     rv_json = |\{"error": "Failed to fetch metadata for object type { ls_payload-object_type }. Consider extending ZCL_SAP_DEV_RPC_EXT or redefining get_object_handler to support it."\}|.
  ENDMETHOD.

  METHOD handle_sap_fetch_source_rpc.
    TYPES: BEGIN OF ty_payload,
             object_type TYPE string,
             object_name TYPE string,
             context     TYPE string,
           END OF ty_payload.
     DATA: ls_payload TYPE ty_payload.

     /ui2/cl_json=>deserialize( EXPORTING json = iv_payload CHANGING data = ls_payload ).

     DATA(lo_hdlr) = get_object_handler( ls_payload-object_type ).
     IF lo_hdlr IS BOUND.
       TRY.
           DATA(lv_src) = lo_hdlr->fetch_source(
             iv_object_name = ls_payload-object_name
             iv_context     = ls_payload-context ).
           IF lv_src IS NOT INITIAL.
             TYPES: BEGIN OF ty_src_res,
                      success TYPE abap_bool,
                      source  TYPE string,
                    END OF ty_src_res.
             DATA: ls_src_res TYPE ty_src_res.
             ls_src_res-success = abap_true.
             ls_src_res-source  = lv_src.
             rv_json = /ui2/cl_json=>serialize( data = ls_src_res ).
             RETURN.
           ENDIF.
         CATCH cx_root INTO DATA(lx_src_err).
           rv_json = |\{"error": "{ escape( val = lx_src_err->get_text( ) format = cl_abap_format=>e_json_string ) }"\}|.
           RETURN.
       ENDTRY.
     ENDIF.

     rv_json = |\{"error": "Failed to fetch source for object type { ls_payload-object_type }. Consider extending ZCL_SAP_DEV_RPC_EXT or redefining get_object_handler to support it."\}|.
  ENDMETHOD.

  METHOD handle_sap_fetch.
    TYPES: BEGIN OF ty_payload,
             object_type TYPE string,
             object_name TYPE string,
             aspect      TYPE string,
             context     TYPE string,
             language    TYPE string,
           END OF ty_payload.
    DATA: ls_payload TYPE ty_payload.

    /ui2/cl_json=>deserialize( EXPORTING json = iv_payload CHANGING data = ls_payload ).

    TRANSLATE ls_payload-object_name TO UPPER CASE.
    TRANSLATE ls_payload-object_type TO UPPER CASE.
    TRANSLATE ls_payload-aspect TO LOWER CASE.

    DATA(lo_hdlr) = get_object_handler( ls_payload-object_type ).
    IF lo_hdlr IS BOUND.
      TRY.
          rv_json = lo_hdlr->fetch_aspect(
            iv_object_name = ls_payload-object_name
            iv_aspect      = ls_payload-aspect
            iv_context     = ls_payload-context
            iv_language    = ls_payload-language ).
        CATCH cx_root INTO DATA(lx_err).
          rv_json = |\{"error": "{ escape( val = lx_err->get_text( ) format = cl_abap_format=>e_json_string ) }"\}|.
      ENDTRY.
    ELSE.
      rv_json = |\{"error": "Failed to resolve handler for object type { ls_payload-object_type }"\}|.
    ENDIF.
  ENDMETHOD.

  METHOD handle_sap_push.
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
              iv_action  = 'HANDLE_PUSH'
              iv_payload = iv_payload
              io_rpc     = me
            RECEIVING
              rv_json    = rv_json.
        CATCH cx_root INTO DATA(lx_root).
          rv_json = |\{"error": "Failed to execute dev helper: { escape( val = lx_root->get_text( ) format = cl_abap_format=>e_json_string ) }"\}|.
      ENDTRY.
    ELSE.
      rv_json = '{"error": "Write operations are disabled on this system."}'.
    ENDIF.
  ENDMETHOD.

  METHOD handle_sap_search_src_code.
    TYPES: BEGIN OF ty_payload,
             query        TYPE string,
             package_name TYPE string,
             object_type  TYPE string,
             object_name  TYPE string,
             max_results  TYPE i,
           END OF ty_payload.
    DATA: ls_payload TYPE ty_payload.

    /ui2/cl_json=>deserialize( EXPORTING json = iv_payload CHANGING data = ls_payload ).

    " Defaults
    IF ls_payload-max_results <= 0.
      ls_payload-max_results = 100.
    ENDIF.

    " Convert search scopes to uppercase
    TRANSLATE ls_payload-package_name TO UPPER CASE.
    TRANSLATE ls_payload-object_type TO UPPER CASE.
    TRANSLATE ls_payload-object_name TO UPPER CASE.

    DATA: lt_programs TYPE TABLE OF program,
          lv_prog     TYPE program.

    " Ranges for selection
    DATA: lr_object_type TYPE RANGE OF tadir-object,
          lr_obj_name    TYPE RANGE OF tadir-obj_name,
          lr_devclass    TYPE RANGE OF tadir-devclass.

    DATA: ls_range_ot LIKE LINE OF lr_object_type,
          ls_range_on LIKE LINE OF lr_obj_name,
          ls_range_dc LIKE LINE OF lr_devclass.

    IF ls_payload-object_type IS NOT INITIAL.
      ls_range_ot-sign   = 'I'.
      ls_range_ot-option = 'EQ'.
      ls_range_ot-low    = ls_payload-object_type.
      APPEND ls_range_ot TO lr_object_type.
    ENDIF.

    IF ls_payload-object_name IS NOT INITIAL.
      ls_range_on-sign   = 'I'.
      IF ls_payload-object_name CS '*'.
        ls_range_on-option = 'CP'.
      ELSE.
        ls_range_on-option = 'EQ'.
      ENDIF.
      ls_range_on-low    = ls_payload-object_name.
      APPEND ls_range_on TO lr_obj_name.
    ELSE.
      " If no name specified, scan custom objects only (for safety and speed)
      ls_range_on-sign   = 'I'.
      ls_range_on-option = 'CP'.
      ls_range_on-low    = 'Z*'.
      APPEND ls_range_on TO lr_obj_name.
      ls_range_on-low    = 'Y*'.
      APPEND ls_range_on TO lr_obj_name.
    ENDIF.

    IF ls_payload-package_name IS NOT INITIAL.
      ls_range_dc-sign   = 'I'.
      ls_range_dc-option = 'EQ'.
      ls_range_dc-low    = ls_payload-package_name.
      APPEND ls_range_dc TO lr_devclass.
    ENDIF.

    " Select from TADIR (Only local/custom objects)
    DATA: lt_tadir TYPE TABLE OF tadir.
    SELECT pgmid object obj_name devclass
      FROM tadir
      INTO CORRESPONDING FIELDS OF TABLE lt_tadir
      WHERE pgmid = 'R3TR'
        AND object IN lr_object_type
        AND obj_name IN lr_obj_name
        AND devclass IN lr_devclass.

    DATA: lt_main_programs TYPE TABLE OF program.

    LOOP AT lt_tadir INTO DATA(ls_tadir).
      CASE ls_tadir-object.
        WHEN 'PROG'.
          lv_prog = ls_tadir-obj_name.
          APPEND lv_prog TO lt_main_programs.
        WHEN 'CLAS'.
          DATA: lv_clsname TYPE seoclsname.
          lv_clsname = ls_tadir-obj_name.
          lv_prog = cl_oo_classname_service=>get_classpool_name( lv_clsname ).
          IF lv_prog IS NOT INITIAL.
            APPEND lv_prog TO lt_main_programs.
          ENDIF.
        WHEN 'INTF'.
          DATA: lv_intfname TYPE seoclsname.
          lv_intfname = ls_tadir-obj_name.
          lv_prog = cl_oo_classname_service=>get_interfacepool_name( lv_intfname ).
          IF lv_prog IS NOT INITIAL.
            APPEND lv_prog TO lt_main_programs.
          ENDIF.
        WHEN 'FUGR'.
          DATA: lv_fgroup TYPE rs38l-area.
          lv_fgroup = ls_tadir-obj_name.
          CLEAR lv_prog.
          CALL FUNCTION 'FUNCTION_INCLUDE_CONCATENATE'
            CHANGING
              program       = lv_prog
              complete_area = lv_fgroup
            EXCEPTIONS
              OTHERS        = 1.
          IF sy-subrc = 0 AND lv_prog IS NOT INITIAL.
            APPEND lv_prog TO lt_main_programs.
          ENDIF.
      ENDCASE.
    ENDLOOP.

    SORT lt_main_programs.
    DELETE ADJACENT DUPLICATES FROM lt_main_programs.

    " Recursively resolve all includes
    APPEND LINES OF lt_main_programs TO lt_programs.
    LOOP AT lt_main_programs INTO lv_prog.
      DATA: lt_inc TYPE STANDARD TABLE OF program.
      CALL FUNCTION 'RS_GET_ALL_INCLUDES'
        EXPORTING
          program    = lv_prog
        TABLES
          includetab = lt_inc
        EXCEPTIONS
          OTHERS     = 1.
      IF sy-subrc = 0.
        APPEND LINES OF lt_inc TO lt_programs.
      ENDIF.
    ENDLOOP.

    SORT lt_programs.
    DELETE ADJACENT DUPLICATES FROM lt_programs.

    " Clean technical meta-includes (match RS_ABAP_SOURCE_SCAN behavior)
    DELETE lt_programs WHERE table_line+31(1) = 'T'
                          OR table_line+30(2) = 'CS'
                          OR table_line+30(2) = 'CP'
                          OR table_line+30(2) = 'IP'.

    " Structure to hold matches
    TYPES: BEGIN OF ty_text_line,
             content TYPE string,
             uri     TYPE string,
           END OF ty_text_line.
    TYPES: BEGIN OF ty_match_object,
             parent_uri  TYPE string,
             text_query  TYPE string,
             uri         TYPE string,
             main_object TYPE ty_payload,
             lines       TYPE STANDARD TABLE OF ty_text_line WITH DEFAULT KEY,
           END OF ty_match_object.
    TYPES: BEGIN OF ty_results,
             number_of_results       TYPE i,
             query_time_millis       TYPE i,
             total_number_of_results TYPE i,
             objects                 TYPE STANDARD TABLE OF ty_match_object WITH DEFAULT KEY,
           END OF ty_results.

    DATA: ls_results TYPE ty_results,
          ls_match   TYPE ty_match_object,
          ls_line    TYPE ty_text_line.

    DATA: lt_source TYPE TABLE OF string,
          lv_milli_start TYPE i,
          lv_milli_end   TYPE i.

    GET RUN TIME FIELD lv_milli_start.

    DATA: lv_match_count TYPE i VALUE 0.

    LOOP AT lt_programs INTO lv_prog.
      IF lv_match_count >= ls_payload-max_results.
        EXIT.
      ENDIF.

      CLEAR: lt_source.
      READ REPORT lv_prog INTO lt_source.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      DATA: lt_find_results TYPE match_result_tab.
      FIND ALL OCCURRENCES OF ls_payload-query IN TABLE lt_source
        IGNORING CASE
        RESULTS lt_find_results.

      IF lt_find_results IS NOT INITIAL.
        CLEAR: ls_match.
        
        " Map program name back to a readable ADT URI format
        ls_match-parent_uri  = |/sap/bc/adt/programs/programs/{ lv_prog }|.
        ls_match-text_query  = ls_payload-query.
        ls_match-uri         = |/sap/bc/adt/programs/programs/{ lv_prog }|.

        " Check classpool/interface name mapping to get main object
        DATA: lv_obj_name TYPE string,
              lv_obj_type TYPE string.
        lv_obj_name = lv_prog.
        lv_obj_type = 'PROG'.

        IF lv_prog CS '=='.
          " Might be class pool or interface
          DATA: lv_possible_cls TYPE seoclsname.
          lv_possible_cls = cl_oo_classname_service=>get_clsname_by_include( lv_prog ).
          IF lv_possible_cls IS NOT INITIAL.
            lv_obj_name = lv_possible_cls.
            " Check if it is interface or class
            SELECT SINGLE object FROM tadir INTO lv_obj_type
              WHERE pgmid = 'R3TR' AND obj_name = lv_obj_name AND ( object = 'CLAS' OR object = 'INTF' ).
            IF sy-subrc <> 0.
              lv_obj_type = 'CLAS'.
            ENDIF.
          ENDIF.
        ENDIF.

        ls_match-main_object-object_name = lv_obj_name.
        ls_match-main_object-object_type = lv_obj_type.

        " Get package
        SELECT SINGLE devclass FROM tadir INTO ls_match-main_object-package_name
          WHERE pgmid = 'R3TR' AND object = lv_obj_type AND obj_name = lv_obj_name.

        LOOP AT lt_find_results INTO DATA(ls_find).
          IF lv_match_count >= ls_payload-max_results.
            EXIT.
          ENDIF.

          READ TABLE lt_source INTO DATA(lv_line_content) INDEX ls_find-line.
          IF sy-subrc = 0.
            ls_line-content = lv_line_content.
            ls_line-uri = |/sap/bc/adt/programs/programs/{ lv_prog }/source/main#start={ ls_find-line }|.
            APPEND ls_line TO ls_match-lines.
            lv_match_count = lv_match_count + 1.
          ENDIF.
        ENDLOOP.

        APPEND ls_match TO ls_results-objects.
      ENDIF.
    ENDLOOP.

    GET RUN TIME FIELD lv_milli_end.
    ls_results-query_time_millis = ( lv_milli_end - lv_milli_start ) / 1000.
    ls_results-number_of_results = lv_match_count.
    ls_results-total_number_of_results = lv_match_count.

    rv_json = /ui2/cl_json=>serialize( data = ls_results ).
  ENDMETHOD.

  METHOD get_object_handler.
    ro_handler = lcl_handler_factory=>get( iv_object_type ).
  ENDMETHOD.
ENDCLASS.