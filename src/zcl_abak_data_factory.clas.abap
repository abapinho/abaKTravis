CLASS zcl_abak_data_factory DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS get_instance
      IMPORTING
        !i_format_type TYPE zabak_format_type
        !i_content_type TYPE zabak_content_type
        !i_content_param TYPE string
        !i_use_shm TYPE zabak_use_shm OPTIONAL
      RETURNING
        value(ro_instance) TYPE REF TO zif_abak_data .
    CLASS-METHODS get_custom_instance
      IMPORTING
        !io_format TYPE REF TO zif_abak_format
        !io_content TYPE REF TO zif_abak_content
      RETURNING
        value(ro_instance) TYPE REF TO zif_abak_data
      RAISING
        zcx_abak .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_abak_data_factory IMPLEMENTATION.


  METHOD get_custom_instance.
    CREATE OBJECT ro_instance TYPE zcl_abak_data_normal
      EXPORTING
        io_format = io_format
        io_content = io_content.
  ENDMETHOD.


  METHOD get_instance.
    IF i_use_shm = abap_true.
      CREATE OBJECT ro_instance TYPE zcl_abak_data_shm
        EXPORTING
          i_format_type = i_format_type
          i_content_type = i_content_type
          i_param       = i_content_param.
    ELSE.
      CREATE OBJECT ro_instance TYPE zcl_abak_data_normal
        EXPORTING
          io_format = zcl_abak_format_factory=>get_instance( i_format_type )
          io_content = zcl_abak_content_factory=>get_instance( i_content_type = i_content_type
                                                             i_param       = i_content_param ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
