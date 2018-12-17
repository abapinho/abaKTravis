class ZCL_ABAK_ORIGIN_FACTORY definition
  public
  final
  create public .

public section.

  constants:
    BEGIN OF gc_origin_type,
        inline        TYPE zabak_origin_type VALUE 'INLINE',
        url           TYPE zabak_origin_type VALUE 'URL',
        standard_text TYPE zabak_origin_type VALUE 'SO10',
        server        TYPE zabak_origin_type VALUE 'SERVER',
      END OF gc_origin_type .

  class-methods GET_INSTANCE
    importing
      !i_origin_type type ZABAK_ORIGIN_TYPE
      !I_PARAM type STRING
    returning
      value(ro_origin) type ref to zif_abak_origin
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



CLASS ZCL_ABAK_ORIGIN_FACTORY IMPLEMENTATION.


  METHOD get_instance.

    CASE i_origin_type.
      WHEN gc_origin_type-inline.
        CREATE OBJECT ro_origin TYPE zcl_abak_origin_inline
          EXPORTING
            i_text = i_param.

      WHEN gc_origin_type-url.
        CREATE OBJECT ro_origin TYPE zcl_abak_origin_url
          EXPORTING
            i_url = i_param.

      WHEN gc_origin_type-server.
        CREATE OBJECT ro_origin TYPE zcl_abak_origin_server
          EXPORTING
            i_filepath = i_param.

      WHEN gc_origin_type-standard_text.
        CREATE OBJECT ro_origin TYPE ZCL_ABAK_ORIGIN_SO10
          EXPORTING
            i_id = ''
            i_name = ''
            i_spras = ''.


      when gc_origin_type-standard_text.

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
