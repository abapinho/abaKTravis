CLASS zcl_abak_factory DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.

    CLASS-METHODS get_instance
      IMPORTING
        !i_format_type TYPE zabak_format_type
        !i_content_type TYPE zabak_content_type
        !i_content_param TYPE string
      RETURNING
        value(ro_instance) TYPE REF TO zif_abak
      RAISING
        zcx_abak .
    CLASS-METHODS get_custom_instance
      IMPORTING
        !io_format TYPE REF TO zif_abak_format
        !io_content TYPE REF TO zif_abak_content
      RETURNING
        value(ro_instance) TYPE REF TO zif_abak
      RAISING
        zcx_abak .
    CLASS-METHODS get_zabak_instance
      IMPORTING
        !i_id TYPE zabak_id
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
ENDCLASS.



CLASS zcl_abak_factory IMPLEMENTATION.


  METHOD get_custom_instance.
    LOG-POINT ID zabak SUBKEY 'factory.get_custom_instance'.

    IF io_format IS NOT BOUND OR io_content IS NOT BOUND.
      RAISE EXCEPTION TYPE zcx_abak
        EXPORTING
          textid = zcx_abak=>invalid_parameters.
    ENDIF.

    CREATE OBJECT ro_instance TYPE zcl_abak
      EXPORTING
        io_data = zcl_abak_data_factory=>get_custom_instance( io_format = io_format
                                                              io_content = io_content ).

  ENDMETHOD.


  METHOD get_instance.
    LOG-POINT ID zabak SUBKEY 'factory.get_instance' FIELDS i_format_type i_content_type i_content_param.

    IF i_format_type IS INITIAL OR i_content_type IS INITIAL OR i_content_param IS INITIAL.
      RAISE EXCEPTION TYPE zcx_abak
        EXPORTING
          textid = zcx_abak=>invalid_parameters.
    ENDIF.

    CREATE OBJECT ro_instance TYPE zcl_abak
      EXPORTING
        io_data = zcl_abak_data_factory=>get_instance( i_format_type  = i_format_type
                                                  i_content_type  = i_content_type
                                                  i_content_param = i_content_param ).
  ENDMETHOD.


  METHOD get_zabak_instance.

    DATA: s_zabak      TYPE zabak,
          content_param TYPE string.

    SELECT SINGLE *
      FROM zabak
      INTO s_zabak
      WHERE id = i_id.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_abak. " TODO
    ENDIF.

    content_param = s_zabak-params.

    ro_instance = get_instance( i_format_type  = s_zabak-format_type
                                i_content_type  = s_zabak-content_type
                                i_content_param = content_param ).

  ENDMETHOD.
ENDCLASS.
