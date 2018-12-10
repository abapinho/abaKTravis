class ZCL_ABAK_SOURCE_FACTORY definition
  public
  final
  create public .

public section.

  class-methods GET_INSTANCE
    importing
      !I_SOURCE_TYPE type ZABAK_SOURCE_TYPE
      !I_CONTENT type STRING
    returning
      value(RO_INSTANCE) type ref to ZIF_ABAK_SOURCE
    raising
      ZCX_ABAK .
protected section.
private section.

  types:
    BEGIN OF ty_s_instance,
      id TYPE zabak_id,
      o_instance TYPE REF TO zif_abak,
    END OF ty_s_instance .
  types:
    ty_t_instance TYPE SORTED TABLE OF ty_s_instance WITH UNIQUE KEY id .

  class-data GT_INSTANCE type TY_T_INSTANCE .
ENDCLASS.



CLASS ZCL_ABAK_SOURCE_FACTORY IMPLEMENTATION.


METHOD get_instance.
  DATA: tablename TYPE tabname.

  CASE i_source_type.
    WHEN zif_abak_source=>source_type-database.
      tablename = i_content.
      CREATE OBJECT ro_instance TYPE zcl_abak_source_db
        EXPORTING
          i_tablename = tablename.

    WHEN zif_abak_source=>source_type-database_shared_objects.
      tablename = i_content.
      CREATE OBJECT ro_instance TYPE zcl_abak_source_db_shm
        EXPORTING
          i_tablename = tablename.

    WHEN zif_abak_source=>source_type-xml.
      CREATE OBJECT ro_instance TYPE zcl_abak_source_xml
        EXPORTING
          i_xml = i_content.

    WHEN OTHERS.
      RAISE EXCEPTION TYPE zcx_abak. " TODO invalid source

  ENDCASE.
ENDMETHOD.
ENDCLASS.
