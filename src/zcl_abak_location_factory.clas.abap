class ZCL_ABAK_LOCATION_FACTORY definition
  public
  final
  create public .

public section.

  constants:
    BEGIN OF gc_location_type,
        inline TYPE zabak_location_type VALUE 'INLINE',
        url    TYPE zabak_location_type VALUE 'URL',
        server TYPE zabak_location_type VALUE 'SERVER',
      END OF gc_location_type .

  class-methods GET_INSTANCE
    importing
      !I_LOCATION_TYPE type ZABAK_LOCATION_TYPE
      !I_PARAM type STRING
    returning
      value(RO_LOCATION) type ref to ZIF_ABAK_LOCATION
    raising
      ZCX_ABAK .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_ABAK_LOCATION_FACTORY IMPLEMENTATION.


  METHOD get_instance.

    CASE i_location_type.
      WHEN gc_location_type-inline.
        CREATE OBJECT ro_location TYPE zcl_abak_location_inline
          EXPORTING
            i_text = i_param.

      WHEN gc_location_type-url.
        CREATE OBJECT ro_location TYPE zcl_abak_location_url
          EXPORTING
            i_url = i_param.

      WHEN gc_location_type-server.
        CREATE OBJECT ro_location TYPE zcl_abak_location_server
          EXPORTING
            i_filepath = i_param.

      WHEN OTHERS.
        RAISE EXCEPTION TYPE zcx_abak
          EXPORTING
            textid = zcx_abak=>invalid_parameters.
    ENDCASE.

  ENDMETHOD.
ENDCLASS.
