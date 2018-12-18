class ZCL_ABAK_CONTENT_FACTORY definition
  public
  final
  create public .

public section.

  class-methods GET_INSTANCE
    importing
      !I_CONTENT_TYPE type ZABAK_CONTENT_TYPE
      !I_CONTENT_PARAM type STRING
    returning
      value(RO_CONTENT) type ref to ZIF_ABAK_CONTENT
    raising
      ZCX_ABAK .
  PROTECTED SECTION.
PRIVATE SECTION.

  TYPES:
    BEGIN OF ty_s_param,
      name TYPE string,
      value TYPE string,
    END OF ty_s_param .
  TYPES:
    ty_t_param TYPE SORTED TABLE OF ty_s_param WITH UNIQUE KEY name .

  CONSTANTS:
    begin of gc_regex,
      so10_param TYPE string VALUE '(ID|NAME|SPRAS)=(\w+)', "#EC NOTEXT
    end of gc_regex.

  CLASS-METHODS get_params
    IMPORTING
      !i_text TYPE string
    RETURNING
      value(rt_param) TYPE ty_t_param .
ENDCLASS.



CLASS ZCL_ABAK_CONTENT_FACTORY IMPLEMENTATION.


  METHOD get_instance.
    DATA: so10_name TYPE tdobname.

    CASE i_content_type.
      WHEN zif_abak_consts=>content_type-inline.
        CREATE OBJECT ro_content TYPE zcl_abak_content_inline
          EXPORTING
            i_text = i_content_param.

      WHEN zif_abak_consts=>content_type-url.
        CREATE OBJECT ro_content TYPE zcl_abak_content_url
          EXPORTING
            i_url = i_content_param.

      WHEN zif_abak_consts=>content_type-server.
        CREATE OBJECT ro_content TYPE zcl_abak_content_server
          EXPORTING
            i_filepath = i_content_param.

      WHEN zif_abak_consts=>content_type-standard_text.
        so10_name = i_content_param.
        CREATE OBJECT ro_content TYPE zcl_abak_content_so10
          EXPORTING
*            i_id    = 'ST'
            i_name  = so10_name.
*            i_spras = sy-langu.

      WHEN OTHERS.
        RAISE EXCEPTION TYPE zcx_abak
          EXPORTING
            textid = zcx_abak=>invalid_parameters.
    ENDCASE.

  ENDMETHOD.


METHOD get_params.

  DATA: o_regex   TYPE REF TO cl_abap_regex,
        o_exp     TYPE REF TO cx_root,
        o_matcher TYPE REF TO cl_abap_matcher,
        t_result  type match_result_tab.

  TRY.
      CREATE OBJECT o_regex
        EXPORTING
          pattern     = gc_regex-so10_param
          ignore_case = abap_true.

      o_matcher = o_regex->create_matcher( text = i_text ).

      t_result = o_matcher->find_all( ).

    CATCH cx_sy_regex cx_sy_matcher INTO o_exp.
      RAISE EXCEPTION TYPE zcx_abak
        EXPORTING
          previous = o_exp.
  ENDTRY.

ENDMETHOD.
ENDCLASS.
