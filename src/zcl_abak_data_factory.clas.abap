class ZCL_ABAK_DATA_FACTORY definition
  public
  final
  create public .

public section.

  class-methods GET_INSTANCE
    importing
      !I_FORMAT_TYPE type ZABAK_FORMAT_TYPE
      !I_ORIGIN_TYPE type ZABAK_ORIGIN_TYPE
      !I_ORIGIN_PARAM type STRING
      !I_USE_SHM type ZABAK_USE_SHM optional
    returning
      value(RO_INSTANCE) type ref to ZIF_ABAK_DATA .
  class-methods GET_CUSTOM_INSTANCE
    importing
      !IO_FORMAT type ref to ZIF_ABAK_FORMAT
      !IO_ORIGIN type ref to ZIF_ABAK_ORIGIN
    returning
      value(RO_INSTANCE) type ref to ZIF_ABAK_DATA
    raising
      ZCX_ABAK .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ABAK_DATA_FACTORY IMPLEMENTATION.


METHOD get_custom_instance.
  CREATE OBJECT ro_instance TYPE zcl_abak_data_normal
    EXPORTING
      io_format = io_format
      io_origin = io_origin.
ENDMETHOD.


METHOD get_instance.
  IF i_use_shm = abap_true.
    CREATE OBJECT ro_instance TYPE zcl_abak_data_shm
      EXPORTING
        i_format_type = i_format_type
        i_origin_type = i_origin_type
        i_param       = i_origin_param.
  ELSE.
    CREATE OBJECT ro_instance TYPE zcl_abak_data_normal
      EXPORTING
        io_format = zcl_abak_format_factory=>get_instance( i_format_type )
        io_origin = zcl_abak_origin_factory=>get_instance( i_origin_type = i_origin_type
                                                           i_param       = i_origin_param ).
  ENDIF.
ENDMETHOD.
ENDCLASS.
