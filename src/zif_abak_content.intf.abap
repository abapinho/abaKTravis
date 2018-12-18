INTERFACE zif_abak_content
  PUBLIC .


  METHODS get
    RETURNING
      value(r_text) TYPE string
    RAISING
      zcx_abak.
  METHODS get_type
    RETURNING
      value(r_type) TYPE zabak_content_type.
  METHODS invalidate
    RAISING
      zcx_abak.
ENDINTERFACE.
