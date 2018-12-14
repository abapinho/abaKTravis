CLASS zcl_abak_factory DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.

    CLASS-METHODS get_instance
      IMPORTING
        !i_id TYPE zabak_id
      RETURNING
        value(ro_instance) TYPE REF TO zif_abak
      RAISING
        zcx_abak .
    CLASS-METHODS get_instance_with_source
      IMPORTING
        !io_source TYPE REF TO zif_abak_source
      RETURNING
        value(ro_instance) TYPE REF TO zif_abak
      RAISING
        zcx_abak .
  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES:
      BEGIN OF ty_s_instance,
        id TYPE zabak_id,
        o_instance TYPE REF TO zif_abak,
      END OF ty_s_instance .
    TYPES:
      ty_t_instance TYPE SORTED TABLE OF ty_s_instance WITH UNIQUE KEY id .

    CLASS-DATA gt_instance TYPE ty_t_instance .

    CLASS-METHODS get_config
      IMPORTING
        !i_id TYPE zabak_id
      RETURNING
        value(rs_config) TYPE zabak
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

    DATA: s_config TYPE zabak,
          param    TYPE string.

    LOG-POINT ID zabak SUBKEY 'factory.create_instance' FIELDS i_id.

    s_config = get_config( i_id ).

    param = s_config-params.

    CREATE OBJECT ro_instance TYPE zcl_abak
      EXPORTING
        io_source = zcl_abak_source_factory=>get_instance( i_source_type = s_config-source_type
                                                           i_origin_type = s_config-origin_type
                                                           i_param       = param ).

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
