INTERFACE zif_abak
  PUBLIC .


  METHODS get_value
    IMPORTING
      value(i_scope) TYPE zabak_scope
      value(i_fieldname) TYPE name_feld
      value(i_context) TYPE any DEFAULT ' '
    RETURNING
      value(r_value) TYPE zabak_low
    RAISING
      zcx_abak .
  METHODS get_value_if_exists
    IMPORTING
      value(i_scope) TYPE zabak_scope
      value(i_fieldname) TYPE name_feld
      value(i_context) TYPE any DEFAULT ' '
    RETURNING
      value(r_value) TYPE zabak_low .
  METHODS get_range
    IMPORTING
      value(i_scope) TYPE zabak_scope
      value(i_fieldname) TYPE name_feld
      value(i_context) TYPE any DEFAULT ' '
    RETURNING
      value(rr_range) TYPE zabak_range_t
    RAISING
      zcx_abak .
  METHODS get_range_if_exists
    IMPORTING
      value(i_scope) TYPE zabak_scope
      value(i_fieldname) TYPE name_feld
      value(i_context) TYPE any DEFAULT ' '
    RETURNING
      value(rr_range) TYPE zabak_range_t .
  METHODS check_value
    IMPORTING
      !i_scope TYPE zabak_scope
      !i_fieldname TYPE name_feld
      !i_context TYPE any DEFAULT ' '
      !i_value TYPE any
    RETURNING
      value(r_result) TYPE flag
    RAISING
      zcx_abak .
  METHODS check_value_if_exists
    IMPORTING
      !i_scope TYPE zabak_scope
      !i_fieldname TYPE name_feld
      !i_context TYPE any DEFAULT ' '
      !i_value TYPE any
    RETURNING
      value(r_result) TYPE flag .
  METHODS invalidate
    RAISING
      zcx_abak .
ENDINTERFACE.
