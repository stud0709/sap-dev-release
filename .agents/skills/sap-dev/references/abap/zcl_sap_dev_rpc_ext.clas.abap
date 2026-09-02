"! <p class="shorttext synchronized" lang="en">SAP-Bridge Agent Extension Handler &amp; RPC Sandbox</p>
"! This class serves as the authorized extension point for autonomous AI agents and developers.
"! It allows registering custom customizing mappers, custom object handlers, and declaring
"! exploratory extension methods that can be safely invoked via <code>sap_execute_ext_method</code>.
CLASS zcl_sap_dev_rpc_ext DEFINITION
  INHERITING FROM zcl_sap_dev_rpc
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS get_object_handler REDEFINITION.
    METHODS if_http_extension~handle_request REDEFINITION.

    "! <p class="shorttext synchronized" lang="en">Canonical Hello World Extension Method</p>
    "! Example extension method demonstrating JSON input deserialization, system context
    "! retrieval, and JSON output formatting.
    "! @parameter iv_params | JSON input payload (e.g. {"name": "Yuriy"})
    "! @parameter rv_result | JSON output string returned to the agent
    METHODS hello_world
      IMPORTING
        iv_params TYPE string OPTIONAL
      RETURNING
        VALUE(rv_result) TYPE string.

    "! <p class="shorttext synchronized" lang="en">Sample Calculation Method</p>
    "! Demonstrates arithmetic operations with structured JSON input.
    "! @parameter iv_params | JSON input payload (e.g. {"amount": 100, "rate": 19})
    "! @parameter rv_result | JSON output string with calculated total
    METHODS test_calc
      IMPORTING
        iv_params TYPE string OPTIONAL
      RETURNING
        VALUE(rv_result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_sap_dev_rpc_ext IMPLEMENTATION.

  METHOD get_object_handler.
    " Override this method to return custom object handlers for non-standard ABAP types.
    ro_handler = super->get_object_handler( iv_object_type ).
  ENDMETHOD.


  METHOD if_http_extension~handle_request.
    " Delegate all standard tool HTTP requests to the core RPC dispatcher
    super->if_http_extension~handle_request( server ).
  ENDMETHOD.


  METHOD hello_world.
    " -----------------------------------------------------------------------
    " 1. Define input structure matching incoming JSON parameters
    " -----------------------------------------------------------------------
    TYPES: BEGIN OF ty_input,
             name TYPE string,
           END OF ty_input.
    DATA: ls_input TYPE ty_input.

    " -----------------------------------------------------------------------
    " 2. Deserialize JSON parameters (if provided)
    " -----------------------------------------------------------------------
    IF iv_params IS NOT INITIAL.
      /ui2/cl_json=>deserialize(
        EXPORTING json = iv_params
        CHANGING  data = ls_input ).
    ENDIF.

    " -----------------------------------------------------------------------
    " 3. Apply defaults if parameters are empty
    " -----------------------------------------------------------------------
    IF ls_input-name IS INITIAL.
      ls_input-name = 'SAP-Bridge Agent'.
    ENDIF.

    " -----------------------------------------------------------------------
    " 4. Build response message using modern ABAP string templates
    " -----------------------------------------------------------------------
    DATA(lv_msg) = |Hello, { ls_input-name }! Greetings from ZCL_SAP_DEV_RPC_EXT running on SAP system { sy-sysid } (client { sy-mandt }, user { sy-uname }).|.

    " -----------------------------------------------------------------------
    " 5. Return typed JSON result string
    " -----------------------------------------------------------------------
    rv_result = |\{"status":"success","message":"{ lv_msg }","system":"{ sy-sysid }","user":"{ sy-uname }"\}|.
  ENDMETHOD.


  METHOD test_calc.
    " -----------------------------------------------------------------------
    " 1. Define input parameters structure
    " -----------------------------------------------------------------------
    TYPES: BEGIN OF ty_input,
             amount TYPE i,
             rate   TYPE i,
           END OF ty_input.
    DATA: ls_input TYPE ty_input.

    " -----------------------------------------------------------------------
    " 2. Deserialize incoming JSON parameters
    " -----------------------------------------------------------------------
    IF iv_params IS NOT INITIAL.
      /ui2/cl_json=>deserialize(
        EXPORTING json = iv_params
        CHANGING  data = ls_input ).
    ENDIF.

    IF ls_input-amount IS INITIAL.
      ls_input-amount = 100.
    ENDIF.
    IF ls_input-rate IS INITIAL.
      ls_input-rate = 19.
    ENDIF.

    " -----------------------------------------------------------------------
    " 3. Perform business calculation
    " -----------------------------------------------------------------------
    DATA(lv_total) = ls_input-amount * ls_input-rate.

    " -----------------------------------------------------------------------
    " 4. Return result as JSON
    " -----------------------------------------------------------------------
    rv_result = |\{"status":"success","amount":{ ls_input-amount },"rate":{ ls_input-rate },"total":{ lv_total }\}|.
  ENDMETHOD.

ENDCLASS.
