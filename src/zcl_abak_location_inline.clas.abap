class ZCL_ABAK_LOCATION_INLINE definition
  public
  final
  create public .

public section.

  interfaces ZIF_ABAK_LOCATION .

  methods CONSTRUCTOR
    importing
      !I_TEXT type STRING
    raising
      ZCX_ABAK .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA g_text TYPE string .

ENDCLASS.



CLASS ZCL_ABAK_LOCATION_INLINE IMPLEMENTATION.


  METHOD constructor.
    g_text = i_text.
  ENDMETHOD.


  METHOD zif_abak_location~get.
    r_text = g_text.
  ENDMETHOD.


  METHOD zif_abak_location~invalidate.
    RETURN. " Nothing to invalidate
  ENDMETHOD.
ENDCLASS.
