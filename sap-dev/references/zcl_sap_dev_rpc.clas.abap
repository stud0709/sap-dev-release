CLASS zcl_sap_dev_rpc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_http_extension.
  PROTECTED SECTION.
  PRIVATE SECTION.
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
    METHODS handle_sap_search_customizing
      IMPORTING
        iv_payload     TYPE string
      RETURNING
        VALUE(rv_json) TYPE string.
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
          WHEN 'sap_read_screen'.
            lv_response = handle_sap_read_screen( lv_body ).
          WHEN 'sap_read_screen_status'.
            lv_response = handle_sap_read_screen_status( lv_body ).
          WHEN 'sap_push_source'.
            lv_response = handle_sap_push_source( lv_body ).
          WHEN 'sap_search_customizing_node'.
            lv_response = handle_sap_search_customizing( lv_body ).
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
             uri     TYPE string,
             source  TYPE string,
             corrnr  TYPE trkorr,
           END OF ty_payload.
    DATA: ls_payload TYPE ty_payload.

    /ui2/cl_json=>deserialize( EXPORTING json = iv_payload CHANGING data = ls_payload ).

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
ENDCLASS.
