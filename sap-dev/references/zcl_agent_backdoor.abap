"! <p class="shorttext synchronized" lang="en">Agent Backdoor HTTP Handler</p>
"! <strong>CRITICAL SECURITY WARNING:</strong>
"! This endpoint empowers the caller to execute arbitrary ABAP code dynamically,
"! completely bypassing all standard application guardrails and authorization checks
"! on the target system.
"! <br/>
"! <strong>Whoever activates this endpoint acts entirely at their own risk, as it may result in irreversible data loss, critical security breaches, or total system damage.</strong>
CLASS zcl_agent_backdoor DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_http_extension.
    CLASS-DATA gv_output TYPE string.
    CLASS-DATA gv_content_type TYPE string.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_agent_backdoor IMPLEMENTATION.
  METHOD if_http_extension~handle_request.
    DATA: lt_source TYPE TABLE OF string,
          lv_prog   TYPE string,
          lv_msg    TYPE string,
          lv_line   TYPE i,
          lv_word   TYPE string,
          lv_off    TYPE i,
          lv_source TYPE string,
          lv_subrc  TYPE sysubrc.

    lv_source = server->request->get_cdata( ).

    " Reset static outputs for current call
    CLEAR: zcl_agent_backdoor=>gv_output, zcl_agent_backdoor=>gv_content_type.

    " Normalize newlines and split
    REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf IN lv_source WITH cl_abap_char_utilities=>newline.
    SPLIT lv_source AT cl_abap_char_utilities=>newline INTO TABLE lt_source.

    " If the code does not start with PROGRAM or REPORT, wrap it in a default program structure
    IF lines( lt_source ) > 0.
      DATA(lv_first_line) = to_upper( lt_source[ 1 ] ).
      IF lv_first_line NS 'PROGRAM ' AND lv_first_line NS 'REPORT '.
        INSERT `PROGRAM z_agent_temp.` INTO lt_source INDEX 1.
        INSERT `FORM execute.` INTO lt_source INDEX 2.
        APPEND `ENDFORM.` TO lt_source.
      ENDIF.
    ENDIF.

    GENERATE SUBROUTINE POOL lt_source NAME lv_prog
      MESSAGE lv_msg
      LINE lv_line
      WORD lv_word
      OFFSET lv_off.

    lv_subrc = sy-subrc.

    IF lv_subrc = 0.
      TRY.
          PERFORM execute IN PROGRAM (lv_prog) IF FOUND.

          IF zcl_agent_backdoor=>gv_output IS NOT INITIAL.
            server->response->set_cdata( zcl_agent_backdoor=>gv_output ).
            IF zcl_agent_backdoor=>gv_content_type IS NOT INITIAL.
              server->response->set_content_type( zcl_agent_backdoor=>gv_content_type ).
            ELSE.
              server->response->set_content_type( 'application/json' ).
            ENDIF.
            server->response->set_status( code = 200 reason = 'OK' ).
          ELSE.
            server->response->set_status( code = 200 reason = 'OK' ).
            server->response->set_cdata( |Execution successful.\nProgram: { lv_prog }| ).
          ENDIF.
        CATCH cx_root INTO DATA(lx_root).
          server->response->set_status( code = 500 reason = 'Runtime Error' ).
          server->response->set_cdata( |Runtime error: { lx_root->get_text( ) }| ).
      ENDTRY.
    ELSE.
      DATA(lv_error) = |Compilation failed:\nMessage: { lv_msg }\nLine: { lv_line }\nWord: { lv_word }|.
      server->response->set_status( code = 400 reason = 'Compilation Error' ).
      server->response->set_cdata( lv_error ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
