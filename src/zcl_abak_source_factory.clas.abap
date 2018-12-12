class ZCL_ABAK_SOURCE_FACTORY definition
  public
  final
  create public .

public section.

  constants:
    BEGIN OF gc_source_type,
        database                TYPE zabak_source_type VALUE 'DB',
        xml                     TYPE zabak_source_type VALUE 'XML',
        xml_url                 TYPE zabak_source_type VALUE 'XML_URL',
      END OF gc_source_type .

  class-methods GET_INSTANCE
    importing
      !I_SOURCE_TYPE type ZABAK_SOURCE_TYPE
      !I_LOCATION_TYPE type ZABAK_LOCATION_TYPE
      !I_PARAM type STRING
      !I_USE_SHM type ZABAK_USE_SHM optional
    returning
      value(RO_INSTANCE) type ref to ZIF_ABAK_SOURCE
    raising
      ZCX_ABAK .
  PROTECTED SECTION.
private section.

  class-methods CREATE_SHM
    importing
      !I_SOURCE_TYPE type ZABAK_SOURCE_TYPE
      !I_LOCATION_TYPE type ZABAK_LOCATION_TYPE
      !I_PARAM type STRING
    returning
      value(RO_INSTANCE) type ref to ZIF_ABAK_SOURCE
    raising
      ZCX_ABAK .
  class-methods CREATE_NO_SHM
    importing
      !I_SOURCE_TYPE type ZABAK_SOURCE_TYPE
      !I_LOCATION_TYPE type ZABAK_LOCATION_TYPE
      !I_PARAM type STRING
    returning
      value(RO_INSTANCE) type ref to ZIF_ABAK_SOURCE
    raising
      ZCX_ABAK .
ENDCLASS.



CLASS ZCL_ABAK_SOURCE_FACTORY IMPLEMENTATION.


  METHOD CREATE_NO_SHM.
    DATA: o_location TYPE REF TO zif_abak_location.

    o_location = zcl_abak_location_factory=>get_instance( i_location_type = i_location_type
                                                          i_param         = i_param ).

    CASE i_source_type.
      WHEN gc_source_type-database.
        CREATE OBJECT ro_instance TYPE zcl_abak_source_db
          EXPORTING
            io_location = o_location.

      WHEN gc_source_type-xml.
        CREATE OBJECT ro_instance TYPE zcl_abak_source_xml
          EXPORTING
            io_location = o_location.

      WHEN OTHERS.
        RAISE EXCEPTION TYPE zcx_abak
          EXPORTING
            textid = zcx_abak=>invalid_parameters.

    ENDCASE.

  ENDMETHOD.


  METHOD create_shm.
    CREATE OBJECT ro_instance TYPE zcl_abak_source_shm
      EXPORTING
        i_source_type   = i_source_type
        i_location_type = i_location_type
        i_param         = i_param.

  ENDMETHOD.


  METHOD get_instance.

    IF i_use_shm = abap_true.
      ro_instance = create_shm( i_source_type   = i_source_type
                                i_location_type = i_location_type
                                i_param         = i_param ).

    ELSE.
      ro_instance = create_no_shm( i_source_type   = i_source_type
                                   i_location_type = i_location_type
                                   i_param         = i_param ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
