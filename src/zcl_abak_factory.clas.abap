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
  class-methods GET_INSTANCE_WITH_SOURCE
    importing
      !IO_SOURCE type ref to ZIF_ABAK_SOURCE
    returning
      value(RO_INSTANCE) type ref to ZIF_ABAK
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

  class-methods GET_CONFIG
    importing
      !I_ID type ZABAK_ID
    returning
      value(RS_CONFIG) type ZABAK
    raising
      ZCX_ABAK .
  class-methods CREATE_INSTANCE
    importing
      !I_ID type ZABAK_ID
    returning
      value(RO_INSTANCE) type ref to ZIF_ABAK
    raising
      ZCX_ABAK .
  class-methods READ_CACHE
    importing
      !I_ID type ZABAK_ID
    returning
      value(RO_INSTANCE) type ref to ZIF_ABAK
    raising
      ZCX_ABAK .
  class-methods WRITE_CACHE
    importing
      !I_ID type ZABAK_ID
      value(IO_INSTANCE) type ref to ZIF_ABAK .
ENDCLASS.



CLASS ZCL_ABAK_FACTORY IMPLEMENTATION.


METHOD create_instance.

  DATA: s_config TYPE zabak,
        content  TYPE string.

  LOG-POINT ID zabak SUBKEY 'factory.create_instance' FIELDS i_id.

  s_config = get_config( i_id ).

  content = s_config-content.

  CREATE OBJECT ro_instance TYPE zcl_abak
    EXPORTING
      io_source = zcl_abak_source_factory=>get_instance(
      i_source_type = s_config-source_type
      i_content     = content ).

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


METHOD get_instance_with_source.

  LOG-POINT ID zabak SUBKEY 'factory.create_instance_with_source'.

  IF io_source IS NOT BOUND.
    RAISE EXCEPTION TYPE zcx_abak.
  ENDIF.

  CREATE OBJECT ro_instance TYPE zcl_abak
    EXPORTING
      io_source = io_source.

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
