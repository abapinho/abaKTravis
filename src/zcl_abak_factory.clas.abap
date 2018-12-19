class ZCL_ABAK_FACTORY definition
  public
  final
  create private .

public section.

  class-methods GET_INSTANCE
    importing
      !I_FORMAT_TYPE type ZABAK_FORMAT_TYPE
      !I_CONTENT_TYPE type ZABAK_CONTENT_TYPE
      !I_CONTENT_PARAM type STRING
      !I_BYPASS_CACHE type FLAG optional
    returning
      value(RO_INSTANCE) type ref to ZIF_ABAK
    raising
      ZCX_ABAK .
  class-methods GET_CUSTOM_INSTANCE
    importing
      !IO_FORMAT type ref to ZIF_ABAK_FORMAT
      !IO_CONTENT type ref to ZIF_ABAK_CONTENT
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
  class-methods GET_DB_INSTANCE
    importing
      !I_TABLENAME type TABNAME
      !I_BYPASS_CACHE type FLAG optional
    returning
      value(RO_INSTANCE) type ref to ZIF_ABAK
    raising
      ZCX_ABAK .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_ABAK_FACTORY IMPLEMENTATION.


  METHOD get_custom_instance.
    LOG-POINT ID zabak SUBKEY 'factory.get_custom_instance'.

    IF io_format IS NOT BOUND OR io_content IS NOT BOUND.
      RAISE EXCEPTION TYPE zcx_abak
        EXPORTING
          textid = zcx_abak=>invalid_parameters.
    ENDIF.

    CREATE OBJECT ro_instance TYPE zcl_abak
      EXPORTING
        io_data = zcl_abak_data_factory=>get_custom_instance( io_format = io_format
                                                              io_content = io_content ).

  ENDMETHOD.


METHOD get_db_instance.
  DATA: content_param TYPE string.
* Since it will probably be used a lot, this is a convenience method

  content_param = i_tablename.
  ro_instance = get_instance(
      i_format_type   = zif_abak_consts=>format_type-database
      i_content_type  = zif_abak_consts=>content_type-inline
      i_content_param = content_param
      i_bypass_cache  = i_bypass_cache ).
ENDMETHOD.


  METHOD get_instance.
    LOG-POINT ID zabak SUBKEY 'factory.get_instance' FIELDS i_format_type i_content_type i_content_param.

    IF i_format_type IS INITIAL OR i_content_type IS INITIAL OR i_content_param IS INITIAL.
      RAISE EXCEPTION TYPE zcx_abak
        EXPORTING
          textid = zcx_abak=>invalid_parameters.
    ENDIF.

    IF i_bypass_cache IS INITIAL.
      ro_instance = lcl_cache=>get( i_format_type   = i_format_type
                                    i_content_type  = i_content_type
                                    i_content_param = i_content_param ).
      IF ro_instance IS BOUND.
        RETURN.
      ENDIF.
    ENDIF.

    CREATE OBJECT ro_instance TYPE zcl_abak
      EXPORTING
        io_data = zcl_abak_data_factory=>get_instance( i_format_type  = i_format_type
                                                  i_content_type  = i_content_type
                                                  i_content_param = i_content_param ).
    IF i_bypass_cache IS INITIAL.
      lcl_cache=>add( i_format_type   = i_format_type
                      i_content_type  = i_content_type
                      i_content_param = i_content_param
                      io_instance     = ro_instance ).
    ENDIF.
  ENDMETHOD.


  METHOD get_zabak_instance.

    DATA: s_zabak      TYPE zabak,
          content_param TYPE string.

    SELECT SINGLE *
      FROM zabak
      INTO s_zabak
      WHERE id = i_id.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_abak. " TODO
    ENDIF.

    content_param = s_zabak-params.

    ro_instance = get_instance( i_format_type  = s_zabak-format_type
                                i_content_type  = s_zabak-content_type
                                i_content_param = content_param ).

  ENDMETHOD.
ENDCLASS.
