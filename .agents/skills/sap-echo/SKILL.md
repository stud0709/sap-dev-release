---
name: sap-echo
description: SAP Echo RFC Connection Test Plugin
---

# SAP Echo
Provides capability to test RFC communication with the SAP backend via Function Module `STFC_CONNECTION`.

## Usage
Invoke the `sap_execute_plugin` tool:
* **script_path**: `.agents/skills/sap-echo/echo_call.js`
* **payload**: `{ "text": "Your message here" }`

---

## ABAP Backend Installation (`ZCL_SAP_DEV_RPC_EXT`)
To support this plugin, the ICF handler extension class `ZCL_SAP_DEV_RPC_EXT` must redefine `if_http_extension~handle_request`:

```abap
  METHOD if_http_extension~handle_request.
    DATA: lv_body TYPE string.
    lv_body = server->request->get_cdata( ).

    TYPES: BEGIN OF ty_req,
             tool TYPE string,
           END OF ty_req.
    DATA: ls_req TYPE ty_req.

    " Parse tool name
    /ui2/cl_json=>deserialize( EXPORTING json = lv_body CHANGING data = ls_req ).

    IF ls_req-tool = 'sap_execute_rfc'.
      " Parse RFC payload details
      TYPES: BEGIN OF ty_rfc_payload,
               requtext TYPE sy-lisel,
             END OF ty_rfc_payload.
      TYPES: BEGIN OF ty_rfc_req,
               payload TYPE ty_rfc_payload,
             END OF ty_rfc_req.
      DATA: ls_rfc_req TYPE ty_rfc_req.

      /ui2/cl_json=>deserialize( EXPORTING json = lv_body CHANGING data = ls_rfc_req ).

      DATA: lv_echotext TYPE sy-lisel,
            lv_resptext TYPE sy-lisel.

      " Call target Function Module
      CALL FUNCTION 'STFC_CONNECTION'
        EXPORTING
          requtext = ls_rfc_req-payload-requtext
        IMPORTING
          echotext = lv_echotext
          resptext = lv_resptext.

      " Construct JSON response
      TYPES: BEGIN OF ty_response,
               echotext TYPE string,
               resptext TYPE string,
             END OF ty_response.
      DATA: ls_resp TYPE ty_response.
      ls_resp-echotext = lv_echotext.
      ls_resp-resptext = lv_resptext.

      DATA(lv_json_out) = /ui2/cl_json=>serialize( data = ls_resp ).

      server->response->set_status( code = 200 reason = 'OK' ).
      server->response->set_content_type( 'application/json' ).
      server->response->set_cdata( lv_json_out ).
      RETURN.
    ELSE.
      " Pass standard tools to parent handler
      super->if_http_extension~handle_request( server ).
    ENDIF.
  ENDMETHOD.
```
