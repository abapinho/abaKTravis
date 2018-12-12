INTERFACE zif_abak_location
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
