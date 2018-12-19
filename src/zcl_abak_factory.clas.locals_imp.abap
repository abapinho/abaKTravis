CLASS lcl_cache DEFINITION.
  PUBLIC SECTION.

    CLASS-METHODS get
      IMPORTING
        i_format_type TYPE zabak_format_type
        i_content_type TYPE zabak_content_type
        i_content_param TYPE string
      RETURNING value(ro_instance) TYPE REF TO zif_abak.

    CLASS-METHODS add
      IMPORTING
        i_format_type   TYPE zabak_format_type
        i_content_type  TYPE zabak_content_type
        i_content_param TYPE string
        io_instance     TYPE REF TO zif_abak
      RAISING
        zcx_abak.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_s_instance,
        format_type TYPE zabak_format_type,
        content_type TYPE zabak_content_type,
        content_param TYPE string,
        o_instance TYPE REF TO zif_abak,
      END OF ty_s_instance .
    TYPES:
      ty_t_instance TYPE SORTED TABLE OF ty_s_instance WITH UNIQUE KEY format_type content_type content_param.

    CLASS-DATA gt_instance TYPE ty_t_instance .
ENDCLASS.

CLASS lcl_cache IMPLEMENTATION.
  METHOD get.
    FIELD-SYMBOLS: <s_instance> LIKE LINE OF gt_instance.

    READ TABLE gt_instance ASSIGNING <s_instance>
      WITH KEY format_type = i_format_type
               content_type = i_content_type
               content_param = i_content_param.
    IF sy-subrc = 0.
      ro_instance = <s_instance>-o_instance.
    ENDIF.
  ENDMETHOD.

  METHOD add.
    DATA: s_instance LIKE LINE OF gt_instance.

    s_instance-format_type = i_format_type.
    s_instance-content_type = i_content_type.
    s_instance-content_param = i_content_param.
    s_instance-o_instance = io_instance.
    INSERT s_instance INTO TABLE gt_instance.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_abak
        EXPORTING
          textid = zcx_abak=>unexpected_error.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
