class ZCL_ABAK_FACTORY definition
  public
  final
  create private .

public section.

  class-methods GET_INSTANCE
    importing
      !I_FORMAT_TYPE type ZABAK_FORMAT_TYPE
      !I_ORIGIN_TYPE type ZABAK_ORIGIN_TYPE
      !I_ORIGIN_PARAM type STRING
    returning
      value(RO_INSTANCE) type ref to ZIF_ABAK
    raising
      ZCX_ABAK .
  class-methods GET_CUSTOM_INSTANCE
    importing
      !IO_FORMAT type ref to ZIF_ABAK_FORMAT
      !IO_ORIGIN type ref to ZIF_ABAK_ORIGIN
    returning
      value(RO_INSTANCE) type ref to ZIF_ABAK
    raising
      ZCX_ABAK .
  class-methods GET_ZABAK_INSTANCE
    importing
      !I_ID type ZABAK_ID
    returning
      value(RO_INSTANCE) type ref to ZIF_ABAK
    raising
      ZCX_ABAK .
  PROTECTED SECTION.
private section.

  types:
    BEGIN OF ty_s_instance,
        id TYPE zabak_id,
        o_instance TYPE REF TO zif_abak,
      END OF ty_s_instance .
  types:
    ty_t_instance TYPE SORTED TABLE OF ty_s_instance WITH UNIQUE KEY id .

  class-data GT_INSTANCE type TY_T_INSTANCE .

  class-methods CREATE_INSTANCE
    importing
      !IO_FORMAT type ref to ZIF_ABAK_FORMAT
      !IO_ORIGIN type ref to ZIF_ABAK_ORIGIN
    returning
      value(RO_INSTANCE) type ref to ZIF_ABAK
    raising
      ZCX_ABAK .
ENDCLASS.



CLASS ZCL_ABAK_FACTORY IMPLEMENTATION.


METHOD create_instance.
  CREATE OBJECT ro_instance TYPE zcl_abak
    EXPORTING
      io_data = zcl_abak_data_factory=>get_custom_instance( io_format = io_format
                                                            io_origin = io_origin ).
ENDMETHOD.


  METHOD get_custom_instance.

    LOG-POINT ID zabak SUBKEY 'factory.get_custom_instance'.

    IF io_format IS NOT BOUND OR io_origin IS NOT BOUND.
      RAISE EXCEPTION TYPE zcx_abak
        EXPORTING
          textid = zcx_abak=>invalid_parameters.
    ENDIF.

    ro_instance = create_instance( io_format = io_format
                                   io_origin = io_origin ).

  ENDMETHOD.


  METHOD get_instance.

    LOG-POINT ID zabak SUBKEY 'factory.get_instance' FIELDS i_format_type i_origin_type i_origin_param.

    IF i_format_type IS INITIAL OR i_origin_type IS INITIAL OR i_origin_param IS INITIAL.
      RAISE EXCEPTION TYPE zcx_abak
        EXPORTING
          textid = zcx_abak=>invalid_parameters.
    ENDIF.

    ro_instance = create_instance(
      io_format = zcl_abak_format_factory=>get_instance( i_format_type )
      io_origin = zcl_abak_origin_factory=>get_instance( i_origin_type  = i_origin_type
                                                       i_param        = i_origin_param ) ).
  ENDMETHOD.


METHOD get_zabak_instance.

  DATA: s_zabak      TYPE zabak,
        origin_param TYPE string.

  SELECT SINGLE *
    FROM zabak
    INTO s_zabak
    WHERE id = i_id.
  IF sy-subrc <> 0.
    RAISE EXCEPTION TYPE zcx_abak. " TODO
  ENDIF.

  origin_param = s_zabak-params.

  ro_instance = get_instance( i_format_type  = s_zabak-format_type
                              i_origin_type  = s_zabak-origin_type
                              i_origin_param = origin_param ).

ENDMETHOD.
ENDCLASS.
