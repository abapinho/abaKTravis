class ZCL_ABAK_ORIGIN_FACTORY definition
  public
  final
  create public .

public section.

  constants:
    BEGIN OF gc_origin_type,
        inline TYPE zabak_origin_type VALUE 'INLINE',
        url    TYPE zabak_origin_type VALUE 'URL',
        server TYPE zabak_origin_type VALUE 'SERVER',
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

      WHEN OTHERS.
        RAISE EXCEPTION TYPE zcx_abak
          EXPORTING
            textid = zcx_abak=>invalid_parameters.
    ENDCASE.

  ENDMETHOD.
ENDCLASS.
