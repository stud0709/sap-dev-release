CLASS zcl_sap_dev_dev_helper DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS dispatch
      IMPORTING
        !iv_action      TYPE string
        !iv_payload     TYPE string
        !io_rpc         TYPE REF TO zcl_sap_dev_rpc OPTIONAL
        !iv_object_name TYPE string OPTIONAL
      RETURNING
        VALUE(rv_json)  TYPE string.

  PRIVATE SECTION.
    CLASS-METHODS handle_sap_push
      IMPORTING
        !iv_payload TYPE string
        !io_rpc     TYPE REF TO zcl_sap_dev_rpc
      RETURNING
        VALUE(rv_json) TYPE string .

    CLASS-METHODS handle_sap_push_source
      IMPORTING
        !iv_payload TYPE string
        !io_rpc     TYPE REF TO zcl_sap_dev_rpc
      RETURNING
        VALUE(rv_json) TYPE string .

    CLASS-METHODS handle_sap_push_metadata
      IMPORTING
        !iv_payload TYPE string
        !io_rpc     TYPE REF TO zcl_sap_dev_rpc
      RETURNING
        VALUE(rv_json) TYPE string .

    CLASS-METHODS handle_sap_reapply_metadata
      IMPORTING
        !iv_payload TYPE string
        !io_rpc     TYPE REF TO zcl_sap_dev_rpc
      RETURNING
        VALUE(rv_json) TYPE string .

    CLASS-METHODS handle_sap_create_transaction
      IMPORTING
        !iv_payload TYPE string
      RETURNING
        VALUE(rv_json) TYPE string .
ENDCLASS.

CLASS zcl_sap_dev_dev_helper IMPLEMENTATION.
  METHOD dispatch.
    CASE iv_action.
      WHEN 'HANDLE_PUSH'.
        rv_json = handle_sap_push( iv_payload = iv_payload io_rpc = io_rpc ).
      WHEN 'HANDLE_PUSH_SOURCE'.
        rv_json = handle_sap_push_source( iv_payload = iv_payload io_rpc = io_rpc ).
      WHEN 'HANDLE_PUSH_METADATA'.
        rv_json = handle_sap_push_metadata( iv_payload = iv_payload io_rpc = io_rpc ).
      WHEN 'HANDLE_REAPPLY_METADATA'.
        rv_json = handle_sap_reapply_metadata( iv_payload = iv_payload io_rpc = io_rpc ).
      WHEN 'HANDLE_CREATE_TRANSACTION'.
        rv_json = handle_sap_create_transaction( iv_payload = iv_payload ).
      WHEN 'HANDLE_PUSH_TRANSLATIONS'.
        rv_json = lcl_translation_writer=>handle_sap_push_translations( iv_payload = iv_payload io_rpc = io_rpc ).
      WHEN 'HANDLE_MAINTAIN_CUSTOM'.
        rv_json = lcl_customizing_runner=>handle_maintain_custom( iv_payload = iv_payload io_rpc = io_rpc ).
      WHEN 'PUSH_PROG_TRANSLATIONS'.
        rv_json = lcl_translation_writer=>push_prog_translations( iv_object_name = iv_object_name iv_payload = iv_payload ).
      WHEN 'PUSH_DTEL_TRANSLATIONS'.
        rv_json = lcl_translation_writer=>push_dtel_translations( iv_object_name = iv_object_name iv_payload = iv_payload ).
      WHEN 'PUSH_DOMA_TRANSLATIONS'.
        rv_json = lcl_translation_writer=>push_doma_translations( iv_object_name = iv_object_name iv_payload = iv_payload ).
      WHEN 'PUSH_CLAS_TRANSLATIONS'.
        rv_json = lcl_translation_writer=>push_clas_translations( iv_object_name = iv_object_name iv_payload = iv_payload ).
      WHEN 'PUSH_MSAG_TRANSLATIONS'.
        rv_json = lcl_translation_writer=>push_msag_translations( iv_object_name = iv_object_name iv_payload = iv_payload ).
      WHEN 'PUSH_TTYP_TRANSLATIONS'.
        rv_json = lcl_translation_writer=>push_ttyp_translations( iv_object_name = iv_object_name iv_payload = iv_payload ).
      WHEN 'PUSH_TABL_TRANSLATIONS'.
        rv_json = lcl_translation_writer=>push_tabl_translations( iv_object_name = iv_object_name iv_payload = iv_payload ).
      WHEN 'PUSH_DYNPRO'.
        rv_json = lcl_dynpro_engine=>push_dynpro( iv_payload = iv_payload ).
      WHEN 'CHECK_DYNPRO_SYNTAX'.
        rv_json = lcl_dynpro_engine=>check_dynpro_syntax( iv_payload = iv_payload ).
      WHEN 'ANALYZE_DYNPRO'.
        rv_json = lcl_dynpro_engine=>analyze_dynpro( iv_payload = iv_payload ).
      WHEN 'GENERATE_CUA_STATUS' OR 'COPY_CUA_STATUS'.
        rv_json = lcl_cua_engine=>generate_cua_status( iv_payload = iv_payload ).
      WHEN OTHERS.
        rv_json = |\{"error": "Unknown action { iv_action }"\}|.
    ENDCASE.
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

    DATA(lo_hdlr) = io_rpc->get_object_handler( ls_payload-object_type ).
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
      DATA(lo_hdlr) = io_rpc->get_object_handler( ls_payload-object_type ).
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
      DATA(lo_hdlr) = io_rpc->get_object_handler( ls_payload-object_type ).
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


ENDCLASS.
