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

    CLASS-METHODS handle_sap_push_translations
      IMPORTING
        !iv_payload TYPE string
        !io_rpc     TYPE REF TO zcl_sap_dev_rpc
      RETURNING
        VALUE(rv_json) TYPE string .

    CLASS-METHODS push_prog_translations
      IMPORTING
        !iv_object_name TYPE string
        !iv_payload     TYPE string
      RETURNING
        VALUE(rv_json)  TYPE string .

    CLASS-METHODS push_dtel_translations
      IMPORTING
        !iv_object_name TYPE string
        !iv_payload     TYPE string
      RETURNING
        VALUE(rv_json)  TYPE string .

    CLASS-METHODS push_doma_translations
      IMPORTING
        !iv_object_name TYPE string
        !iv_payload     TYPE string
      RETURNING
        VALUE(rv_json)  TYPE string .

    CLASS-METHODS push_clas_translations
      IMPORTING
        !iv_object_name TYPE string
        !iv_payload     TYPE string
      RETURNING
        VALUE(rv_json)  TYPE string .

    CLASS-METHODS push_msag_translations
      IMPORTING
        !iv_object_name TYPE string
        !iv_payload     TYPE string
      RETURNING
        VALUE(rv_json)  TYPE string .

    CLASS-METHODS push_ttyp_translations
      IMPORTING
        !iv_object_name TYPE string
        !iv_payload     TYPE string
      RETURNING
        VALUE(rv_json)  TYPE string .

    CLASS-METHODS push_tabl_translations
      IMPORTING
        !iv_object_name TYPE string
        !iv_payload     TYPE string
      RETURNING
        VALUE(rv_json)  TYPE string .

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
ENDCLASS.

CLASS ZCL_SAP_DEV_DEV_HELPER IMPLEMENTATION.
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
        rv_json = handle_sap_push_translations( iv_payload = iv_payload io_rpc = io_rpc ).
      WHEN 'PUSH_PROG_TRANSLATIONS'.
        rv_json = push_prog_translations( iv_object_name = iv_object_name iv_payload = iv_payload ).
      WHEN 'PUSH_DTEL_TRANSLATIONS'.
        rv_json = push_dtel_translations( iv_object_name = iv_object_name iv_payload = iv_payload ).
      WHEN 'PUSH_DOMA_TRANSLATIONS'.
        rv_json = push_doma_translations( iv_object_name = iv_object_name iv_payload = iv_payload ).
      WHEN 'PUSH_CLAS_TRANSLATIONS'.
        rv_json = push_clas_translations( iv_object_name = iv_object_name iv_payload = iv_payload ).
      WHEN 'PUSH_MSAG_TRANSLATIONS'.
        rv_json = push_msag_translations( iv_object_name = iv_object_name iv_payload = iv_payload ).
      WHEN 'PUSH_TTYP_TRANSLATIONS'.
        rv_json = push_ttyp_translations( iv_object_name = iv_object_name iv_payload = iv_payload ).
      WHEN 'PUSH_TABL_TRANSLATIONS'.
        rv_json = push_tabl_translations( iv_object_name = iv_object_name iv_payload = iv_payload ).
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
