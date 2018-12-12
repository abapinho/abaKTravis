INTERFACE ZIF_ABAK_ORIGIN
  PUBLIC .


  METHODS get
    RETURNING
      value(r_text) TYPE string
    RAISING
      zcx_abak.
  METHODS invalidate
    RAISING
      zcx_abak.
ENDINTERFACE.
