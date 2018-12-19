CLASS zcl_abak_format_db DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC
  SHARED MEMORY ENABLED .

  PUBLIC SECTION.

    INTERFACES zif_abak_format .
  PROTECTED SECTION.
  PRIVATE SECTION.

    METHODS check_table
      IMPORTING
        !i_tablename TYPE tabname
      RAISING
        zcx_abak .
    METHODS convert_db_2_k
      IMPORTING
        !it_db TYPE zabak_db_t
      RETURNING
        value(rt_k) TYPE zabak_k_t
      RAISING
        zcx_abak .
    METHODS select
      IMPORTING
        !i_tablename TYPE tabname
      RETURNING
        value(rt_data) TYPE zabak_db_t .
ENDCLASS.



CLASS ZCL_ABAK_FORMAT_DB IMPLEMENTATION.


  METHOD check_table.
    DATA: o_structdescr TYPE REF TO cl_abap_structdescr,
          t_component TYPE cl_abap_structdescr=>component_table.

    FIELD-SYMBOLS: <s_component> LIKE LINE OF t_component.

    o_structdescr ?= cl_abap_structdescr=>describe_by_name( i_tablename ).
    t_component = o_structdescr->get_components( ).

* Two components expected
    IF lines( t_component ) <> 2.
      RAISE EXCEPTION TYPE zcx_abak_format_db
        EXPORTING
          textid    = zcx_abak_format_db=>invalid_table_format
          tablename = i_tablename.
    ENDIF.

* Both components are includes
    LOOP AT t_component TRANSPORTING NO FIELDS WHERE as_include <> 'X'.
      RAISE EXCEPTION TYPE zcx_abak_format_db
        EXPORTING
          textid    = zcx_abak_format_db=>invalid_table_format
          tablename = i_tablename.
    ENDLOOP.

* 1st include is ZABAK_DB_KEYS
    READ TABLE t_component ASSIGNING <s_component> INDEX 1.
    IF sy-subrc <> 0 OR <s_component>-type->absolute_name <> '\TYPE=ZABAK_DB_KEY'.
      RAISE EXCEPTION TYPE zcx_abak_format_db
        EXPORTING
          textid    = zcx_abak_format_db=>invalid_table_format
          tablename = i_tablename.
    ENDIF.

* 2nd include is ZABAK_DB_FIELDS
    READ TABLE t_component ASSIGNING <s_component> INDEX 2.
    IF sy-subrc <> 0 OR <s_component>-type->absolute_name <> '\TYPE=ZABAK_DB_FIELDS'.
      RAISE EXCEPTION TYPE zcx_abak_format_db
        EXPORTING
          textid    = zcx_abak_format_db=>invalid_table_format
          tablename = i_tablename.
    ENDIF.

  ENDMETHOD.


  METHOD convert_db_2_k.

    DATA: s_k LIKE LINE OF rt_k,
          s_kv LIKE LINE OF s_k-t_kv.

    FIELD-SYMBOLS: <s_db> LIKE LINE OF it_db,
                   <s_k>  LIKE LINE OF rt_k.

    LOOP AT it_db ASSIGNING <s_db>.

      DO 2 TIMES.                                        "#EC CI_NESTED
*     Get K line
        READ TABLE rt_k ASSIGNING <s_k>
          WITH KEY scope = <s_db>-scope
                   fieldname = <s_db>-fieldname
                   context = <s_db>-context.
        IF sy-subrc = 0.
          EXIT.
        ELSE.
*       Not found: create it and the next DO iteration gets it
          s_k-scope = <s_db>-scope.
          s_k-fieldname = <s_db>-fieldname.
          s_k-context = <s_db>-context.
          INSERT s_k INTO TABLE rt_k.
        ENDIF.
      ENDDO.

      IF <s_k> IS NOT ASSIGNED.
        RAISE EXCEPTION TYPE zcx_abak_format_db
          EXPORTING
            textid = zcx_abak_format_db=>unexpected_error.
      ENDIF.

      s_kv-sign = <s_db>-ue_sign.
      s_kv-option = <s_db>-ue_option.
      s_kv-low = <s_db>-ue_low.
      s_kv-high = <s_db>-ue_high.
      INSERT s_kv INTO TABLE <s_k>-t_kv.

    ENDLOOP.

  ENDMETHOD.                                             "#EC CI_VALPAR


  METHOD select.

    SELECT *
      FROM (i_tablename)
      INTO TABLE rt_data.

  ENDMETHOD.


  METHOD zif_abak_format~convert.
    DATA: tablename TYPE tabname.

    tablename = i_data.

    LOG-POINT ID zabak SUBKEY 'format_db.convert' FIELDS tablename.

    check_table( tablename ).

    IF et_k IS SUPPLIED.
      et_k = convert_db_2_k( select( tablename ) ).
    ENDIF.

    IF e_name IS SUPPLIED.
      e_name = tablename.
    ENDIF.

  ENDMETHOD.


  METHOD zif_abak_format~get_type.
    r_format_type = zif_abak_consts=>format_type-database.
  ENDMETHOD.
ENDCLASS.
