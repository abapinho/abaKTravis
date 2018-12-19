CLASS zcl_abak_content_inline DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_abak_content .

    METHODS constructor
      IMPORTING
        !i_text TYPE string
      RAISING
        zcx_abak .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA g_text TYPE string .

ENDCLASS.



CLASS ZCL_ABAK_CONTENT_INLINE IMPLEMENTATION.


  METHOD constructor.
    g_text = i_text.
  ENDMETHOD.


  METHOD zif_abak_content~get.
    r_text = g_text.
  ENDMETHOD.


  METHOD zif_abak_content~get_type.
    r_type = zif_abak_consts=>content_type-inline.
  ENDMETHOD.


  METHOD zif_abak_content~invalidate.
    RETURN. " Nothing to invalidate
  ENDMETHOD.
ENDCLASS.
