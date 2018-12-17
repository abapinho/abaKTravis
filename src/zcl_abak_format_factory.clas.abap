CLASS ZCL_ABAK_FORMAT_FACTORY DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS:
      BEGIN OF gc_format_type,
          database                TYPE zabak_format_type VALUE 'DB',
          xml                     TYPE zabak_format_type VALUE 'XML',
        END OF gc_format_type .

    CLASS-METHODS get_instance
      IMPORTING
        !i_format_type TYPE zabak_format_type
        !i_origin_type TYPE zabak_origin_type
        !i_param TYPE string
        !i_use_shm TYPE zabak_use_shm OPTIONAL
      RETURNING
        value(ro_instance) TYPE REF TO zif_abak_format
      RAISING
        zcx_abak .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-METHODS create_shm
      IMPORTING
        !i_format_type TYPE zabak_format_type
        !i_origin_type TYPE zabak_origin_type
        !i_param TYPE string
      RETURNING
        value(ro_instance) TYPE REF TO zif_abak_format
      RAISING
        zcx_abak .
    CLASS-METHODS create_no_shm
      IMPORTING
        !i_format_type TYPE zabak_format_type
        !i_origin_type TYPE zabak_origin_type
        !i_param TYPE string
      RETURNING
        value(ro_instance) TYPE REF TO zif_abak_format
      RAISING
        zcx_abak .
ENDCLASS.



CLASS ZCL_ABAK_FORMAT_FACTORY IMPLEMENTATION.


  METHOD create_no_shm.
    DATA: o_location TYPE REF TO zif_abak_origin.

    o_location = zcl_abak_origin_factory=>get_instance( i_origin_type = i_origin_type
                                                          i_param         = i_param ).

    CASE i_format_type.
      WHEN gc_format_type-database.
        CREATE OBJECT ro_instance TYPE zcl_abak_format_db
          EXPORTING
            io_origin = o_location.

      WHEN gc_format_type-xml.
        CREATE OBJECT ro_instance TYPE zcl_abak_format_xml
          EXPORTING
            io_origin = o_location.

      WHEN OTHERS.
        RAISE EXCEPTION TYPE zcx_abak
          EXPORTING
            textid = zcx_abak=>invalid_parameters.

    ENDCASE.

  ENDMETHOD.


  METHOD create_shm.
    CREATE OBJECT ro_instance TYPE zcl_abak_format_shm
      EXPORTING
        i_format_type = i_format_type
        i_origin_type = i_origin_type
        i_param       = i_param.

  ENDMETHOD.


  METHOD get_instance.

    IF i_use_shm = abap_true.
      ro_instance = create_shm( i_format_type   = i_format_type
                                i_origin_type = i_origin_type
                                i_param         = i_param ).

    ELSE.
      ro_instance = create_no_shm( i_format_type   = i_format_type
                                   i_origin_type = i_origin_type
                                   i_param         = i_param ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
