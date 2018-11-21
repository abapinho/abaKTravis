class ZCL_ABAK_UTIL definition
  public
  final
  create public
  shared memory enabled .

public section.

  methods CHECK_TABLE
    importing
      !I_TABLENAME type TABNAME
    raising
      ZCX_ABAK .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ABAK_UTIL IMPLEMENTATION.


METHOD CHECK_TABLE.
  DATA: o_structdescr TYPE REF TO cl_abap_structdescr,
        t_component TYPE cl_abap_structdescr=>component_table.

  FIELD-SYMBOLS: <s_component> LIKE LINE OF t_component.

  o_structdescr ?= cl_abap_structdescr=>describe_by_name( i_tablename ).
  t_component = o_structdescr->get_components( ).

* Two components expected
  IF lines( t_component ) <> 2.
    RAISE EXCEPTION TYPE zcx_abak.
  ENDIF.

* Both components are includes
  LOOP AT t_component TRANSPORTING NO FIELDS WHERE as_include <> 'X'.
    RAISE EXCEPTION TYPE zcx_abak.
  ENDLOOP.

* 1st include is ZABAK_KEYS
  READ TABLE t_component ASSIGNING <s_component> INDEX 1.
  IF <s_component>-type->absolute_name <> '\TYPE=ZABAK_KEY'.
    RAISE EXCEPTION TYPE zcx_abak.
  ENDIF.

* 2nd include is ZABAK_FIELDS
  READ TABLE t_component ASSIGNING <s_component> INDEX 2.
  IF <s_component>-type->absolute_name <> '\TYPE=ZABAK_FIELDS'.
    RAISE EXCEPTION TYPE zcx_abak.
  ENDIF.

ENDMETHOD.
ENDCLASS.
