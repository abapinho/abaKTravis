CLASS zcl_abak_data_normal DEFINITION
  PUBLIC
  INHERITING FROM zcl_abak_data
  FINAL
  CREATE PUBLIC

  GLOBAL FRIENDS zcl_abak_factory .

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        !io_format TYPE REF TO zif_abak_format
        !io_content TYPE REF TO zif_abak_content
      RAISING
        zcx_abak .
  PROTECTED SECTION.

    METHODS load_data_aux
      REDEFINITION .
    METHODS invalidate_aux
      REDEFINITION .
  PRIVATE SECTION.

    DATA go_format TYPE REF TO zif_abak_format .
    DATA go_content TYPE REF TO zif_abak_content .
ENDCLASS.



CLASS ZCL_ABAK_DATA_NORMAL IMPLEMENTATION.


  METHOD constructor.

    super->constructor( ).

    IF io_format IS NOT BOUND OR io_content IS NOT BOUND.
      RAISE EXCEPTION TYPE zcx_abak
        EXPORTING
          textid = zcx_abak=>invalid_parameters.
    ENDIF.

    go_format = io_format.
    go_content = io_content.

  ENDMETHOD.


  METHOD invalidate_aux.
    go_content->invalidate( ).
  ENDMETHOD.


  METHOD load_data_aux.
    go_format->convert(
      EXPORTING
        i_data = go_content->get( )
      IMPORTING
        et_k   = et_k
        e_name = e_name ).
  ENDMETHOD.
ENDCLASS.
