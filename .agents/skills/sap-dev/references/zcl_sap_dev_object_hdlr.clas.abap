CLASS zcl_sap_dev_object_hdlr DEFINITION
  PUBLIC
  ABSTRACT
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES ty_langs TYPE TABLE OF sy-langu WITH DEFAULT KEY .

    METHODS fetch_aspect
      IMPORTING
        !iv_object_name TYPE string
        !iv_aspect      TYPE string
        !iv_context     TYPE string OPTIONAL
        !iv_language    TYPE string OPTIONAL
      RETURNING
        VALUE(rv_payload) TYPE string
      RAISING
        cx_static_check .

    METHODS push_aspect
      IMPORTING
        !iv_object_name TYPE string
        !iv_aspect      TYPE string
        !iv_payload     TYPE string
        !iv_corrnr      TYPE trkorr OPTIONAL
      RETURNING
        VALUE(rv_etag)   TYPE string
      RAISING
        cx_static_check .

    METHODS get_creation_template
      IMPORTING
        !iv_object_name TYPE string
        !iv_package     TYPE string
      RETURNING
        VALUE(rv_xml)   TYPE string .

    METHODS fetch_metadata
      IMPORTING
        !iv_object_name TYPE string
      RETURNING
        VALUE(rv_xml)   TYPE string
      RAISING
        cx_static_check .

    METHODS push_metadata
      IMPORTING
        !iv_object_name TYPE string
        !iv_xml         TYPE string
        !iv_corrnr      TYPE trkorr
      RETURNING
        VALUE(rv_etag)   TYPE string
      RAISING
        cx_static_check .

    METHODS fetch_source
      IMPORTING
        !iv_object_name TYPE string
        !iv_context     TYPE string
      RETURNING
        VALUE(rv_source) TYPE string
      RAISING
        cx_static_check .

    METHODS push_source
      IMPORTING
        !iv_object_name TYPE string
        !iv_source      TYPE string
        !iv_corrnr      TYPE trkorr
      RETURNING
        VALUE(rv_etag)   TYPE string
      RAISING
        cx_static_check .

    METHODS read_translations
      IMPORTING
        !iv_object_name TYPE string
        !iv_masterlang  TYPE tadir-masterlang
        !it_langs       TYPE ty_langs
      RETURNING
        VALUE(rv_json)  TYPE string
      RAISING
        cx_static_check .

    METHODS push_translations
      IMPORTING
        !iv_object_name TYPE string
        !iv_payload     TYPE string
      RETURNING
        VALUE(rv_json)  TYPE string
      RAISING
        cx_static_check .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_sap_dev_object_hdlr IMPLEMENTATION.
  METHOD fetch_aspect.
    CASE iv_aspect.
      WHEN 'source'.
        DATA: lv_src TYPE string.
        lv_src = fetch_source( iv_object_name = iv_object_name iv_context = iv_context ).

        TYPES: BEGIN OF ty_src_res,
                 success TYPE abap_bool,
                 source  TYPE string,
               END OF ty_src_res.
        DATA: ls_src_res TYPE ty_src_res.
        ls_src_res-success = abap_true.
        ls_src_res-source  = lv_src.
        rv_payload = /ui2/cl_json=>serialize( data = ls_src_res ).

      WHEN 'metadata'.
        rv_payload = fetch_metadata( iv_object_name = iv_object_name ).

      WHEN 'translations'.
        DATA: lt_langs TYPE ty_langs,
              lv_langu TYPE sy-langu.

        IF iv_language IS NOT INITIAL AND iv_language <> '*' AND iv_language <> 'ALL'.
          lv_langu = iv_language.
          APPEND lv_langu TO lt_langs.
        ELSE.
          DATA: lv_classname TYPE string.
          lv_classname = cl_abap_classdescr=>describe_by_object_ref( me )->get_relative_name( ).
          IF lv_classname = 'LCL_PROG_HANDLER'.
            SELECT DISTINCT spras FROM t002 INTO TABLE @lt_langs.
          ELSEIF lv_classname = 'LCL_DTEL_HANDLER'.
            SELECT DISTINCT ddlanguage FROM dd04t INTO TABLE @lt_langs
              WHERE rollname = @iv_object_name AND as4local = 'A'.
          ELSEIF lv_classname = 'LCL_DOMA_HANDLER'.
            SELECT DISTINCT ddlanguage FROM dd07t INTO TABLE @lt_langs
              WHERE domname = @iv_object_name AND as4local = 'A'.
          ELSEIF lv_classname = 'LCL_CLAS_HANDLER'.
            SELECT DISTINCT langu FROM seoclasstx INTO TABLE @lt_langs
              WHERE clsname = @iv_object_name.
          ELSEIF lv_classname = 'LCL_MSAG_HANDLER'.
            SELECT DISTINCT sprsl FROM t100t INTO TABLE @lt_langs
              WHERE arbgb = @iv_object_name.
          ELSEIF lv_classname = 'LCL_TTYP_HANDLER'.
            SELECT DISTINCT ddlanguage FROM dd40t INTO TABLE @lt_langs
              WHERE typename = @iv_object_name AND as4local = 'A'.
          ELSEIF lv_classname = 'LCL_TABL_HANDLER'.
            SELECT DISTINCT ddlanguage FROM dd02t INTO TABLE @lt_langs
              WHERE tabname = @iv_object_name AND as4local = 'A'.
          ENDIF.
        ENDIF.

        IF lt_langs IS INITIAL.
          APPEND sy-langu TO lt_langs.
        ENDIF.

        DATA: lv_masterlang TYPE tadir-masterlang.
        SELECT SINGLE masterlang FROM tadir INTO @lv_masterlang
          WHERE pgmid = 'R3TR'
            AND obj_name = @iv_object_name.
        IF sy-subrc <> 0.
          lv_masterlang = sy-langu.
        ENDIF.

        rv_payload = read_translations(
          iv_object_name = iv_object_name
          iv_masterlang  = lv_masterlang
          it_langs       = lt_langs ).

      WHEN OTHERS.
        rv_payload = |\{"error": "Aspect '{ iv_aspect }' is unsupported on this object"\}|.
    ENDCASE.
  ENDMETHOD.

  METHOD push_aspect.
    TYPES: BEGIN OF ty_generic_push,
             payload TYPE string,
           END OF ty_generic_push.
    DATA: ls_gen TYPE ty_generic_push.

    CASE iv_aspect.
      WHEN 'source'.
        /ui2/cl_json=>deserialize( EXPORTING json = iv_payload CHANGING data = ls_gen ).

        DATA: lv_etag_src TYPE string.
        lv_etag_src = push_source(
          iv_object_name = iv_object_name
          iv_source      = ls_gen-payload
          iv_corrnr      = iv_corrnr ).

        TYPES: BEGIN OF ty_push_res,
                 success           TYPE abap_bool,
                 version_signature TYPE string,
               END OF ty_push_res.
        DATA: ls_push_res TYPE ty_push_res.
        ls_push_res-success = abap_true.
        ls_push_res-version_signature = lv_etag_src.
        rv_etag = /ui2/cl_json=>serialize( data = ls_push_res ).

      WHEN 'metadata'.
        /ui2/cl_json=>deserialize( EXPORTING json = iv_payload CHANGING data = ls_gen ).

        DATA: lv_etag_meta TYPE string.
        lv_etag_meta = push_metadata(
          iv_object_name = iv_object_name
          iv_xml         = ls_gen-payload
          iv_corrnr      = iv_corrnr ).

        TYPES: BEGIN OF ty_meta_res,
                 success TYPE abap_bool,
                 etag    TYPE string,
               END OF ty_meta_res.
        DATA: ls_meta_res TYPE ty_meta_res.
        ls_meta_res-success = abap_true.
        ls_meta_res-etag    = lv_etag_meta.
        rv_etag = /ui2/cl_json=>serialize( data = ls_meta_res ).

      WHEN 'translations'.
        rv_etag = push_translations(
          iv_object_name = iv_object_name
          iv_payload     = iv_payload ).

      WHEN OTHERS.
        rv_etag = |\{"error": "Aspect '{ iv_aspect }' is unsupported on this object"\}|.
    ENDCASE.
  ENDMETHOD.

  METHOD get_creation_template.
    " Default empty template
  ENDMETHOD.

  METHOD fetch_metadata.
    " Default empty metadata
  ENDMETHOD.

  METHOD push_metadata.
    " Default unsupported fallback (returns empty ETag)
  ENDMETHOD.

  METHOD fetch_source.
    " Default empty source
  ENDMETHOD.

  METHOD push_source.
    " Default unsupported fallback (returns empty ETag)
  ENDMETHOD.

  METHOD read_translations.
    rv_json = '{}'.
  ENDMETHOD.

  METHOD push_translations.
    rv_json = '{}'.
  ENDMETHOD.
ENDCLASS.
