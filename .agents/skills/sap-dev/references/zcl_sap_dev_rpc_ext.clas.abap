class ZCL_SAP_DEV_RPC_EXT definition
  inheriting FROM zcl_sap_dev_rpc
  public
  final
  create public .

public section.
  methods GET_OBJECT_HANDLER redefinition.
protected section.
private section.
ENDCLASS.

CLASS ZCL_SAP_DEV_RPC_EXT IMPLEMENTATION.
  method GET_OBJECT_HANDLER.
    " Override this method to return custom object handlers.
    " Example:
    " if iv_object_type = 'ZWDY'.
    "   create object ro_handler type zcl_my_custom_wdy_handler.
    "   return.
    " endif.
    ro_handler = super->get_object_handler( iv_object_type ).
  endmethod.
ENDCLASS.
