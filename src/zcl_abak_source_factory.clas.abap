CLASS zcl_abak_source_factory DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS:
      BEGIN OF gc_source_type,
          database                TYPE zabak_source_type VALUE 'DB',
          xml                     TYPE zabak_source_type VALUE 'XML',
          xml_url                 TYPE zabak_source_type VALUE 'XML_URL',
        END OF gc_source_type .

    CLASS-METHODS get_instance
      IMPORTING
        !i_source_type TYPE zabak_source_type
        !i_origin_type TYPE zabak_origin_type
        !i_param TYPE string
        !i_use_shm TYPE zabak_use_shm OPTIONAL
      RETURNING
        value(ro_instance) TYPE REF TO zif_abak_source
      RAISING
        zcx_abak .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-METHODS create_shm
      IMPORTING
        !i_source_type TYPE zabak_source_type
        !i_origin_type TYPE zabak_origin_type
        !i_param TYPE string
      RETURNING
        value(ro_instance) TYPE REF TO zif_abak_source
      RAISING
        zcx_abak .
    CLASS-METHODS create_no_shm
      IMPORTING
        !i_source_type TYPE zabak_source_type
        !i_origin_type TYPE zabak_origin_type
        !i_param TYPE string
      RETURNING
        value(ro_instance) TYPE REF TO zif_abak_source
      RAISING
        zcx_abak .
ENDCLASS.



CLASS zcl_abak_source_factory IMPLEMENTATION.


  METHOD create_no_shm.
    DATA: o_location TYPE REF TO zif_abak_origin.

    o_location = zcl_abak_origin_factory=>get_instance( i_origin_type = i_origin_type
                                                          i_param         = i_param ).

    CASE i_source_type.
      WHEN gc_source_type-database.
        CREATE OBJECT ro_instance TYPE zcl_abak_source_db
          EXPORTING
            io_origin = o_location.

      WHEN gc_source_type-xml.
        CREATE OBJECT ro_instance TYPE zcl_abak_source_xml
          EXPORTING
            io_origin = o_location.

      WHEN OTHERS.
        RAISE EXCEPTION TYPE zcx_abak
          EXPORTING
            textid = zcx_abak=>invalid_parameters.

    ENDCASE.

  ENDMETHOD.


  METHOD create_shm.
    CREATE OBJECT ro_instance TYPE zcl_abak_source_shm
      EXPORTING
        i_source_type = i_source_type
        i_origin_type = i_origin_type
        i_param       = i_param.

  ENDMETHOD.


  METHOD get_instance.

    IF i_use_shm = abap_true.
      ro_instance = create_shm( i_source_type   = i_source_type
                                i_origin_type = i_origin_type
                                i_param         = i_param ).

    ELSE.
      ro_instance = create_no_shm( i_source_type   = i_source_type
                                   i_origin_type = i_origin_type
                                   i_param         = i_param ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
