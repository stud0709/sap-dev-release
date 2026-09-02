*&---------------------------------------------------------------------*
*& Report Z_NAVIGATE_TO_LINE
*&---------------------------------------------------------------------*
REPORT z_navigate_to_line.

PARAMETERS: p_pgm  TYPE char120,
            p_type TYPE wbobjtype DEFAULT 'PROG',
            p_line TYPE i.

START-OF-SELECTION.
  IF p_pgm IS NOT INITIAL.
    DATA: lv_pos      TYPE string,
          lv_obj_name TYPE string,
          lv_obj_type TYPE wbobjtype.

    lv_pos = p_line.
    lv_obj_name = p_pgm.
    lv_obj_type = p_type.

    " Map ADT types to standard workbench types
    IF lv_obj_type = 'FUGR/F' OR lv_obj_type = 'FUGR/FF'.
      lv_obj_type = 'FUNC'.
    ENDIF.

    IF lv_obj_type = 'CLAS/OM' OR lv_obj_type = 'METH'.
      DATA: lv_class  TYPE seoclsname,
            lv_method TYPE seocpdname,
            lv_incl   TYPE program.

      " Split the name at '-' (e.g. ZCL_EWM_RF_ZLOHU-CREATE_STO_OUTBOUND_DELIVERY)
      SPLIT lv_obj_name AT '-' INTO lv_class lv_method.

      IF lv_class IS NOT INITIAL AND lv_method IS NOT INITIAL.
        TRY.
            lv_incl = cl_oo_classname_service=>get_method_include(
              mtdkey = VALUE #( clsname = lv_class
                                cpdname = lv_method ) ).
            IF lv_incl IS NOT INITIAL.
              lv_obj_name = lv_incl.
              lv_obj_type = 'PROG'. " Open as raw program include in SE38!
            ENDIF.
          CATCH cx_root.
        ENDTRY.
      ENDIF.
    ENDIF.

    IF lv_obj_type = 'PROG/P' OR lv_obj_type = 'PROG/I'.
      lv_obj_type = 'PROG'.
    ENDIF.

    IF lv_obj_type = 'CLAS'.
      TRY.
          DATA(lv_classpool) = cl_oo_classname_service=>get_classpool_name( |{ lv_obj_name }| ).
          IF lv_classpool IS NOT INITIAL.
            lv_obj_name = lv_classpool.
            lv_obj_type = 'PROG'.
          ENDIF.
        CATCH cx_root.
      ENDTRY.
    ENDIF.

    DATA: lv_obj_name_param TYPE sobj_name.
    lv_obj_name_param = lv_obj_name.

    CALL FUNCTION 'RS_TOOL_ACCESS'
      EXPORTING
        operation   = 'SHOW'
        object_name = lv_obj_name_param
        object_type = lv_obj_type
        position    = lv_pos
      EXCEPTIONS
        OTHERS      = 1.
  ENDIF.
