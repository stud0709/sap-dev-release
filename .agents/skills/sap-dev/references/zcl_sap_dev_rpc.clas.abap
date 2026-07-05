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
    METHODS handle_sap_get_creation_tmpl
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
    METHODS get_object_handler
      IMPORTING
        iv_object_type    TYPE string
      RETURNING
        VALUE(ro_handler) TYPE REF TO zcl_sap_dev_object_hdlr.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_sap_dev_rpc IMPLEMENTATION.
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
          WHEN 'sap_get_creation_template'.
            lv_response = handle_sap_get_creation_tmpl( lv_body ).
          WHEN 'sap_fetch_metadata'.
            lv_response = handle_sap_fetch_metadata( lv_body ).
          WHEN 'sap_fetch_source'.
            lv_response = handle_sap_fetch_source_rpc( lv_body ).
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
    TYPES: BEGIN OF ty_payload,
             uri         TYPE string,
             source      TYPE string,
             corrnr      TYPE trkorr,
             context     TYPE string,
             object_type TYPE string,
             object_name TYPE string,
           END OF ty_payload.
    DATA: ls_payload TYPE ty_payload.

    /ui2/cl_json=>deserialize( EXPORTING json = iv_payload CHANGING data = ls_payload ).

    IF ls_payload-object_type IS NOT INITIAL.
      DATA(lo_hdlr) = get_object_handler( ls_payload-object_type ).
      IF lo_hdlr IS BOUND.
        TRY.
            DATA: lv_etag TYPE string.
            lv_etag = lo_hdlr->push_source(
              iv_object_name = ls_payload-object_name
              iv_source      = ls_payload-source
              iv_corrnr      = ls_payload-corrnr ).
            IF lv_etag IS NOT INITIAL.
              rv_json = |\{"success": true, "etag": "{ lv_etag }"\}|.
              RETURN.
            ENDIF.
          CATCH cx_root INTO DATA(lx_push_err).
            rv_json = |\{"error": "{ escape( val = lx_push_err->get_text( ) format = cl_abap_format=>e_json_string ) }"\}|.
            RETURN.
        ENDTRY.
      ENDIF.
    ENDIF.

    DATA: ls_request  TYPE sadt_rest_request,
          ls_response TYPE sadt_rest_response,
          ls_header   TYPE ihttpnvp,
          lv_lock_hnd TYPE string,
          lv_body_str TYPE string,
          lv_err_msg  TYPE string.

    " 1. LOCK
    ls_request-request_line-method = 'POST'.
    ls_request-request_line-uri    = ls_payload-uri && '?_action=LOCK&accessMode=MODIFY'.

    ls_header-name  = 'Accept'.
    ls_header-value = 'application/vnd.sap.as+xml'.
    APPEND ls_header TO ls_request-header_fields.

    CALL FUNCTION 'SADT_REST_RFC_ENDPOINT'
      EXPORTING
        request  = ls_request
      IMPORTING
        response = ls_response.

    " Extract lock handle
    TRY.
        lv_body_str = cl_bcs_convert=>xstring_to_string( iv_xstr = ls_response-message_body iv_cp = '4110' ).
      CATCH cx_bcs INTO DATA(lx_bcs1).
        rv_json = |\{"error": "Failed to decode lock response: { lx_bcs1->get_text( ) }"\}|.
        RETURN.
    ENDTRY.
    FIND REGEX '<LOCK_HANDLE>([^<]*)</LOCK_HANDLE>' IN lv_body_str IGNORING CASE SUBMATCHES lv_lock_hnd.

    IF sy-subrc <> 0 OR lv_lock_hnd IS INITIAL.
      lv_err_msg = escape( val = lv_body_str format = cl_abap_format=>e_json_string ).
      rv_json = |\{"error": "Failed to lock object. Response: { lv_err_msg }"\}|.
      RETURN.
    ENDIF.

    " 2. PUT source/main
    CLEAR ls_request.
    CLEAR ls_response.
    ls_request-request_line-method = 'PUT'.
    ls_request-request_line-uri    = ls_payload-uri && '/source/main?lockHandle=' && lv_lock_hnd.
    IF ls_payload-corrnr IS NOT INITIAL.
      ls_request-request_line-uri = ls_request-request_line-uri && '&corrNr=' && ls_payload-corrnr.
    ENDIF.
    IF ls_payload-context IS NOT INITIAL.
      ls_request-request_line-uri = ls_request-request_line-uri && '&context=' && ls_payload-context.
    ENDIF.

    ls_header-name  = 'Content-Type'.
    ls_header-value = 'text/plain; charset=utf-8'.
    APPEND ls_header TO ls_request-header_fields.

    TRY.
        ls_request-message_body = cl_bcs_convert=>string_to_xstring( iv_string = ls_payload-source iv_codepage = '4110' ).
      CATCH cx_bcs INTO DATA(lx_bcs2).
        rv_json = |\{"error": "Failed to encode source payload: { lx_bcs2->get_text( ) }"\}|.
        RETURN.
    ENDTRY.

    CALL FUNCTION 'SADT_REST_RFC_ENDPOINT'
      EXPORTING
        request  = ls_request
      IMPORTING
        response = ls_response.

    TRY.
        lv_body_str = cl_bcs_convert=>xstring_to_string( iv_xstr = ls_response-message_body iv_cp = '4110' ).
      CATCH cx_bcs INTO DATA(lx_bcs3).
        rv_json = |\{"error": "Failed to decode update response: { lx_bcs3->get_text( ) }"\}|.
        RETURN.
    ENDTRY.
    DATA: lv_success TYPE abap_bool VALUE abap_false.
    FIND SUBSTRING '<exc:exception' IN lv_body_str IGNORING CASE MATCH COUNT sy-fdpos.
    IF sy-subrc = 0.
      lv_err_msg = escape( val = lv_body_str format = cl_abap_format=>e_json_string ).
      rv_json = |\{"error": "Failed to update source. Response: { lv_err_msg }"\}|.
    ELSE.
      lv_success = abap_true.
    ENDIF.

    " 3. UNLOCK
    CLEAR ls_request.
    CLEAR ls_response.
    ls_request-request_line-method = 'POST'.
    ls_request-request_line-uri    = ls_payload-uri && '?_action=UNLOCK&lockHandle=' && lv_lock_hnd.

    CALL FUNCTION 'SADT_REST_RFC_ENDPOINT'
      EXPORTING
        request  = ls_request
      IMPORTING
        response = ls_response.

    IF lv_success = abap_true.
      rv_json = |\{"success": true\}|.
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
    TYPES: BEGIN OF ty_payload,
             uri          TYPE string,
             source       TYPE string,
             corrnr       TYPE trkorr,
             content_type TYPE string,
             object_type  TYPE string,
             object_name  TYPE string,
           END OF ty_payload.
    DATA: ls_payload TYPE ty_payload,
          lv_etag    TYPE string.

    /ui2/cl_json=>deserialize( EXPORTING json = iv_payload CHANGING data = ls_payload ).

    IF ls_payload-object_type IS INITIAL.
      IF ls_payload-uri CS 'tran'.
        ls_payload-object_type = 'TRAN'.
        FIND REGEX 'adtcore:name="([^"]*)"' IN ls_payload-source IGNORING CASE SUBMATCHES ls_payload-object_name.
      ENDIF.
    ENDIF.

    IF ls_payload-object_type IS NOT INITIAL.
      DATA(lo_hdlr) = get_object_handler( ls_payload-object_type ).
      IF lo_hdlr IS BOUND.
        TRY.
            lv_etag = lo_hdlr->push_metadata(
              iv_object_name = ls_payload-object_name
              iv_xml         = ls_payload-source
              iv_corrnr      = ls_payload-corrnr ).
            IF lv_etag IS NOT INITIAL.
              rv_json = |\{"success": true, "etag": "{ lv_etag }"\}|.
              RETURN.
            ENDIF.
          CATCH cx_root INTO DATA(lx_push_err).
            rv_json = |\{"error": "{ escape( val = lx_push_err->get_text( ) format = cl_abap_format=>e_json_string ) }"\}|.
            RETURN.
        ENDTRY.
      ENDIF.
    ENDIF.

    DATA: ls_request  TYPE sadt_rest_request,
          ls_response TYPE sadt_rest_response,
          ls_header   TYPE ihttpnvp,
          lv_lock_hnd TYPE string,
          lv_body_str TYPE string,
          lv_err_msg  TYPE string.

    " 1. LOCK
    ls_request-request_line-method = 'POST'.
    ls_request-request_line-uri    = ls_payload-uri && '?_action=LOCK&accessMode=MODIFY'.

    ls_header-name  = 'Accept'.
    ls_header-value = 'application/vnd.sap.as+xml'.
    APPEND ls_header TO ls_request-header_fields.

    CALL FUNCTION 'SADT_REST_RFC_ENDPOINT'
      EXPORTING
        request  = ls_request
      IMPORTING
        response = ls_response.

    " Extract lock handle
    TRY.
        lv_body_str = cl_bcs_convert=>xstring_to_string( iv_xstr = ls_response-message_body iv_cp = '4110' ).
      CATCH cx_bcs INTO DATA(lx_bcs1).
        rv_json = |\{"error": "Failed to decode lock response: { lx_bcs1->get_text( ) }"\}|.
        RETURN.
    ENDTRY.
    FIND REGEX '<LOCK_HANDLE>([^<]*)</LOCK_HANDLE>' IN lv_body_str IGNORING CASE SUBMATCHES lv_lock_hnd.

    IF sy-subrc <> 0 OR lv_lock_hnd IS INITIAL.
      lv_err_msg = escape( val = lv_body_str format = cl_abap_format=>e_json_string ).
      rv_json = |\{"error": "Failed to lock object. Response: { lv_err_msg }"\}|.
      RETURN.
    ENDIF.

    " 2. PUT metadata
    CLEAR ls_request.
    CLEAR ls_response.
    ls_request-request_line-method = 'PUT'.
    ls_request-request_line-uri    = ls_payload-uri && '?lockHandle=' && lv_lock_hnd.
    IF ls_payload-corrnr IS NOT INITIAL.
      ls_request-request_line-uri = ls_request-request_line-uri && '&corrNr=' && ls_payload-corrnr.
    ENDIF.

    ls_header-name  = 'Content-Type'.
    IF ls_payload-content_type IS NOT INITIAL.
      ls_header-value = ls_payload-content_type.
    ELSE.
      ls_header-value = 'application/xml; charset=utf-8'.
    ENDIF.
    APPEND ls_header TO ls_request-header_fields.

    TRY.
        ls_request-message_body = cl_bcs_convert=>string_to_xstring( iv_string = ls_payload-source iv_codepage = '4110' ).
      CATCH cx_bcs INTO DATA(lx_bcs2).
        rv_json = |\{"error": "Failed to encode metadata payload: { lx_bcs2->get_text( ) }"\}|.
        RETURN.
    ENDTRY.

    CALL FUNCTION 'SADT_REST_RFC_ENDPOINT'
      EXPORTING
        request  = ls_request
      IMPORTING
        response = ls_response.

    TRY.
        lv_body_str = cl_bcs_convert=>xstring_to_string( iv_xstr = ls_response-message_body iv_cp = '4110' ).
      CATCH cx_bcs INTO DATA(lx_bcs3).
        rv_json = |\{"error": "Failed to decode update response: { lx_bcs3->get_text( ) }"\}|.
        RETURN.
    ENDTRY.
    DATA: lv_success TYPE abap_bool VALUE abap_false.
    FIND SUBSTRING '<exc:exception' IN lv_body_str IGNORING CASE MATCH COUNT sy-fdpos.
    IF sy-subrc = 0.
      lv_err_msg = escape( val = lv_body_str format = cl_abap_format=>e_json_string ).
      rv_json = |\{"error": "Failed to update metadata. Response: { lv_err_msg }"\}|.
    ELSE.
      lv_success = abap_true.
    ENDIF.

    " 3. UNLOCK
    CLEAR ls_request.
    CLEAR ls_response.
    ls_request-request_line-method = 'POST'.
    ls_request-request_line-uri    = ls_payload-uri && '?_action=UNLOCK&lockHandle=' && lv_lock_hnd.

    CALL FUNCTION 'SADT_REST_RFC_ENDPOINT'
      EXPORTING
        request  = ls_request
      IMPORTING
        response = ls_response.

    IF lv_success = abap_true.
      DATA: lv_funcname TYPE tfdir-funcname,
            lv_proc_type TYPE string,
            lv_basxml    TYPE string,
            lv_fmode     TYPE tfdir-fmode,
            lv_exten2    TYPE enlfdir-exten2.

      IF ls_payload-uri CS '/fmodules/'.
        DATA: lv_pos TYPE i.
        FIND REGEX '/([^/]*)$' IN ls_payload-uri MATCH OFFSET lv_pos.
        IF sy-subrc = 0.
          lv_pos = lv_pos + 1.
          lv_funcname = ls_payload-uri+lv_pos.
          CONDENSE lv_funcname NO-GAPS.
        ENDIF.
      ENDIF.

      IF lv_funcname IS NOT INITIAL.
        TRANSLATE lv_funcname TO UPPER CASE.

        FIND REGEX 'processingType="([^"]*)"' IN ls_payload-source IGNORING CASE SUBMATCHES lv_proc_type.
        FIND REGEX 'basXmlEnabled="([^"]*)"' IN ls_payload-source IGNORING CASE SUBMATCHES lv_basxml.

        IF lv_proc_type = 'rfc'.
          lv_fmode = 'R'.
        ELSE.
          lv_fmode = ' '.
        ENDIF.

        IF lv_basxml = 'true'.
          lv_exten2 = 'X'.
        ELSE.
          lv_exten2 = '1'.
        ENDIF.

        UPDATE tfdir SET fmode = lv_fmode WHERE funcname = lv_funcname.
        UPDATE enlfdir SET exten2 = lv_exten2 WHERE funcname = lv_funcname.
        COMMIT WORK.
      ENDIF.

      CLEAR lv_etag.
      LOOP AT ls_response-header_fields INTO DATA(ls_resp_hdr) WHERE name = 'ETag' OR name = 'etag'.
        lv_etag = ls_resp_hdr-value.
      ENDLOOP.
      rv_json = |\{"success": true, "etag": "{ lv_etag }"\}|.
    ENDIF.
  ENDMETHOD.

  METHOD handle_sap_reapply_metadata.
    TYPES: BEGIN OF ty_payload,
             uri          TYPE string,
             source       TYPE string,
           END OF ty_payload.
    DATA: ls_payload TYPE ty_payload.

    /ui2/cl_json=>deserialize( EXPORTING json = iv_payload CHANGING data = ls_payload ).

    DATA: lv_funcname TYPE tfdir-funcname,
          lv_proc_type TYPE string,
          lv_basxml    TYPE string,
          lv_fmode     TYPE tfdir-fmode,
          lv_exten2    TYPE enlfdir-exten2.

    IF ls_payload-uri CS '/fmodules/'.
      DATA: lv_pos TYPE i.
      FIND REGEX '/([^/]*)$' IN ls_payload-uri MATCH OFFSET lv_pos.
      IF sy-subrc = 0.
        lv_pos = lv_pos + 1.
        lv_funcname = ls_payload-uri+lv_pos.
        CONDENSE lv_funcname NO-GAPS.
      ENDIF.
    ENDIF.

    IF lv_funcname IS NOT INITIAL.
      TRANSLATE lv_funcname TO UPPER CASE.

      FIND REGEX 'processingType="([^"]*)"' IN ls_payload-source IGNORING CASE SUBMATCHES lv_proc_type.
      FIND REGEX 'basXmlEnabled="([^"]*)"' IN ls_payload-source IGNORING CASE SUBMATCHES lv_basxml.

      IF lv_proc_type = 'rfc'.
        lv_fmode = 'R'.
      ELSE.
        lv_fmode = ' '.
      ENDIF.

      IF lv_basxml = 'true'.
        lv_exten2 = 'X'.
      ELSE.
        lv_exten2 = '1'.
      ENDIF.

      UPDATE tfdir SET fmode = lv_fmode WHERE funcname = lv_funcname.
      UPDATE enlfdir SET exten2 = lv_exten2 WHERE funcname = lv_funcname.
      COMMIT WORK.

      rv_json = |\{"success": true\}|.
    ELSE.
      rv_json = |\{"error": "Invalid URI"\}|.
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
    TYPES: BEGIN OF ty_payload,
             tcode     TYPE c LENGTH 20,
             program   TYPE c LENGTH 40,
             screen    TYPE c LENGTH 4,
             text      TYPE c LENGTH 60,
             type      TYPE c LENGTH 1,
             package   TYPE devclass,
             transport TYPE trkorr,
           END OF ty_payload.
    DATA: ls_payload TYPE ty_payload.

    /ui2/cl_json=>deserialize( EXPORTING json = iv_payload CHANGING data = ls_payload ).

    IF ls_payload-screen IS INITIAL.
      ls_payload-screen = '1000'.
    ENDIF.
    IF ls_payload-type IS INITIAL.
      ls_payload-type = 'R'.
    ENDIF.
    IF ls_payload-package IS INITIAL.
      ls_payload-package = '$TMP'.
    ENDIF.
    DATA: lv_tcode TYPE tstc-tcode,
          lv_program TYPE trdir-name,
          lv_dynpro TYPE d020s-dnum,
          lv_devclass TYPE rglif-devclass,
          lv_trkorr TYPE rglif-trkorr,
          lv_type TYPE rglif-docutype,
          lv_text TYPE tstct-ttext,
          lv_html TYPE s_webgui VALUE 'X',
          lv_java TYPE s_platin VALUE 'X',
          lv_win TYPE s_win32 VALUE 'X',
          lv_genflag TYPE tadir-genflag VALUE ' ',
          lv_suppress TYPE char1 VALUE ' '.

    lv_tcode = ls_payload-tcode.
    lv_program = ls_payload-program.
    lv_dynpro = ls_payload-screen.
    lv_devclass = ls_payload-package.
    lv_trkorr = ls_payload-transport.
    IF lv_devclass = '$TMP' OR lv_devclass(1) = '$'.
      lv_suppress = 'X'.
    ENDIF.
    lv_type = ls_payload-type.
    lv_text = ls_payload-text.

    TRY.
        CALL FUNCTION 'RPY_TRANSACTION_INSERT'
          EXPORTING
            transaction          = lv_tcode
            program              = lv_program
            dynpro               = lv_dynpro
            development_class    = lv_devclass
            transport_number     = lv_trkorr
            transaction_type     = lv_type
            shorttext            = lv_text
            html_enabled         = lv_html
            java_enabled         = lv_java
            wingui_enabled       = lv_win
            genflag              = lv_genflag
            suppress_corr_insert = lv_suppress
          EXCEPTIONS
            cancelled           = 1
            already_exist       = 2
            permission_error    = 3
            name_not_allowed    = 4
            name_conflict       = 5
            illegal_type        = 6
            object_inconsistent = 7
            db_access_error     = 8
            OTHERS              = 9.
      CATCH cx_sy_dyn_call_illegal_type INTO DATA(lx_type_err).
        rv_json = |\{"error": "Type Error on parameter { lx_type_err->parameter }: { lx_type_err->get_text( ) }"\}|.
        RETURN.
    ENDTRY.

    IF sy-subrc = 0.
      rv_json = |\{"success": true, "message": "Transaction { ls_payload-tcode } created successfully"\}|.
    ELSE.
      DATA: lv_msg TYPE string.
      CASE sy-subrc.
        WHEN 1. lv_msg = 'Cancelled'.
        WHEN 2. lv_msg = 'Transaction already exists'.
        WHEN 3. lv_msg = 'Permission error'.
        WHEN 4. lv_msg = 'Name not allowed'.
        WHEN 5. lv_msg = 'Name conflict'.
        WHEN 6. lv_msg = 'Illegal type'.
        WHEN 7. lv_msg = 'Object inconsistent'.
        WHEN 8. lv_msg = 'DB access error'.
        WHEN OTHERS. lv_msg = 'Unknown error'.
      ENDCASE.
      rv_json = |\{"error": "{ lv_msg } (SUBRC { sy-subrc })"\}|.
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

    rv_json = lo_handler->push_translations(
      iv_object_name = ls_payload-object_name
      iv_payload     = iv_payload ).
  ENDMETHOD.

  METHOD handle_sap_get_creation_tmpl.
    TYPES: BEGIN OF ty_payload,
             object_type TYPE string,
             object_name TYPE string,
             package     TYPE string,
           END OF ty_payload.
     DATA: ls_payload TYPE ty_payload.

     /ui2/cl_json=>deserialize( EXPORTING json = iv_payload CHANGING data = ls_payload ).

     DATA(lo_hdlr) = get_object_handler( ls_payload-object_type ).
     IF lo_hdlr IS BOUND.
       DATA(lv_tmpl) = lo_hdlr->get_creation_template(
         iv_object_name = ls_payload-object_name
         iv_package     = ls_payload-package ).
       IF lv_tmpl IS NOT INITIAL.
         TYPES: BEGIN OF ty_ok_res,
                  success  TYPE abap_bool,
                  template TYPE string,
                END OF ty_ok_res.
         DATA: ls_ok TYPE ty_ok_res.
         ls_ok-success  = abap_true.
         ls_ok-template = lv_tmpl.
         rv_json = /ui2/cl_json=>serialize( data = ls_ok ).
         RETURN.
       ENDIF.
     ENDIF.

     rv_json = |\{"success": false, "error": "No creation template for type { ls_payload-object_type }. Consider extending ZCL_SAP_DEV_RPC_EXT or redefining get_object_handler to support it."\}|.
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
    TYPES: BEGIN OF ty_payload,
             object_type  TYPE string,
             object_name  TYPE string,
             aspect       TYPE string,
             payload      TYPE string,
             corrnr       TYPE trkorr,
           END OF ty_payload.
    DATA: ls_payload TYPE ty_payload.

    /ui2/cl_json=>deserialize( EXPORTING json = iv_payload CHANGING data = ls_payload ).

    TRANSLATE ls_payload-object_name TO UPPER CASE.
    TRANSLATE ls_payload-object_type TO UPPER CASE.
    TRANSLATE ls_payload-aspect TO LOWER CASE.

    DATA(lo_hdlr) = get_object_handler( ls_payload-object_type ).
    IF lo_hdlr IS BOUND.
      TRY.
          rv_json = lo_hdlr->push_aspect(
            iv_object_name = ls_payload-object_name
            iv_aspect      = ls_payload-aspect
            iv_payload     = ls_payload-payload
            iv_corrnr      = ls_payload-corrnr ).
        CATCH cx_root INTO DATA(lx_err).
          rv_json = |\{"error": "{ escape( val = lx_err->get_text( ) format = cl_abap_format=>e_json_string ) }"\}|.
      ENDTRY.
    ELSE.
      rv_json = |\{"error": "Failed to resolve handler for object type { ls_payload-object_type }"\}|.
    ENDIF.
  ENDMETHOD.

  METHOD get_object_handler.
    ro_handler = lcl_handler_factory=>get( iv_object_type ).
  ENDMETHOD.
ENDCLASS.