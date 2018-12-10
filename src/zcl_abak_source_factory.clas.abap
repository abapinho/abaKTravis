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
      !I_CONTENT type STRING
      !I_USE_SHMO type ZABAK_USE_SHMO optional
    returning
      value(RO_INSTANCE) type ref to ZIF_ABAK_SOURCE
    raising
      ZCX_ABAK .
protected section.
PRIVATE SECTION.

  TYPES:
    BEGIN OF ty_s_instance,
      id TYPE zabak_id,
      o_instance TYPE REF TO zif_abak,
    END OF ty_s_instance .
  TYPES:
    ty_t_instance TYPE SORTED TABLE OF ty_s_instance WITH UNIQUE KEY id .

  CLASS-DATA gt_instance TYPE ty_t_instance .
ENDCLASS.



CLASS ZCL_ABAK_SOURCE_FACTORY IMPLEMENTATION.


METHOD get_instance.
  DATA: tablename TYPE tabname.

  IF i_use_shmo = abap_true.
    CREATE OBJECT ro_instance TYPE zcl_abak_source_shm
      EXPORTING
        i_source_type = i_source_type
        i_content     = i_content.

  ELSE.
    CASE i_source_type.
      WHEN gc_source_type-database.
        tablename = i_content.
        CREATE OBJECT ro_instance TYPE zcl_abak_source_db
          EXPORTING
            i_tablename = tablename.

      WHEN gc_source_type-xml.
        CREATE OBJECT ro_instance TYPE zcl_abak_source_xml
          EXPORTING
            i_xml = i_content.

      WHEN OTHERS.
        RAISE EXCEPTION TYPE zcx_abak
          EXPORTING
            textid = zcx_abak=>invalid_parameters.

    ENDCASE.
  ENDIF.

ENDMETHOD.
ENDCLASS.
