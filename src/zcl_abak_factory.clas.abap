class ZCL_ABAK_FACTORY definition
  public
  final
  create private .

public section.

  class-methods GET_INSTANCE
    importing
      !I_ID type ZABAK_ID
    returning
      value(RO_INSTANCE) type ref to ZIF_ABAK
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

  CLASS-DATA gt_instance TYPE ty_t_instance.

  CLASS-METHODS get_config
    IMPORTING
      !i_id TYPE zabak_id
    RETURNING
      value(rs_config) TYPE zabak
    RAISING
      zcx_abak .
  CLASS-METHODS get_source
    IMPORTING
      !is_config TYPE zabak
    RETURNING
      value(ro_object) TYPE REF TO zif_abak_source
    RAISING
      zcx_abak .
  CLASS-METHODS create_instance
    IMPORTING
      !i_id TYPE zabak_id
    RETURNING
      value(ro_instance) TYPE REF TO zif_abak
    RAISING
      zcx_abak .
  CLASS-METHODS read_cache
    IMPORTING
      !i_id TYPE zabak_id
    RETURNING
      value(ro_instance) TYPE REF TO zif_abak
    RAISING
      zcx_abak .
  CLASS-METHODS write_cache
    IMPORTING
      !i_id TYPE zabak_id
      value(io_instance) TYPE REF TO zif_abak .
ENDCLASS.



CLASS ZCL_ABAK_FACTORY IMPLEMENTATION.


METHOD create_instance.

  DATA: o_data TYPE REF TO zif_abak_data.

  LOG-POINT ID zabak SUBKEY 'factory.create_data' FIELDS i_id.

  CREATE OBJECT o_data TYPE zcl_abak_data
    EXPORTING
      io_source = get_source( get_config( i_id ) ).

  CREATE OBJECT ro_instance TYPE zcl_abak
    EXPORTING
      io_data = o_data.

ENDMETHOD.


METHOD get_config.
  SELECT SINGLE *
    FROM zabak
    INTO rs_config
    WHERE id = i_id.
  IF sy-subrc <> 0.
    RAISE EXCEPTION TYPE zcx_abak. " TODO
  ENDIF.
ENDMETHOD.


METHOD get_instance.

  ro_instance = read_cache( i_id ).

  IF ro_instance IS NOT BOUND.
    ro_instance = create_instance( i_id ).
    write_cache( i_id      = i_id
                 io_instance = ro_instance ).
  ENDIF.

ENDMETHOD.


METHOD get_source.
  DATA: tablename TYPE tabname,
        xml       TYPE string.

  CASE is_config-source.
    WHEN 'DB'.
      tablename = is_config-content.
      CREATE OBJECT ro_object TYPE zcl_abak_source_db
        EXPORTING
          i_tablename = tablename.

    WHEN 'XML'.
      xml = is_config-content.
      CREATE OBJECT ro_object TYPE zcl_abak_source_xml
        EXPORTING
          i_xml = xml.

    WHEN OTHERS.
      RAISE EXCEPTION TYPE zcx_abak. " TODO invalid source

  ENDCASE.
ENDMETHOD.


METHOD read_cache.
  DATA: s_instance LIKE LINE OF gt_instance.

  READ TABLE gt_instance INTO s_instance WITH KEY id = i_id.
  IF sy-subrc = 0.
    ro_instance = s_instance-o_instance.
  ENDIF.
ENDMETHOD.


METHOD write_cache.
  DATA: s_instance LIKE LINE OF gt_instance.

  s_instance-id = i_id.
  s_instance-o_instance = io_instance.
  INSERT s_instance INTO TABLE gt_instance.
ENDMETHOD.
ENDCLASS.
