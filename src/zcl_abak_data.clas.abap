class ZCL_ABAK_DATA definition
  public
  abstract
  create public

  global friends ZCL_ABAK_FACTORY .

public section.

  interfaces ZIF_ABAK_DATA .
  interfaces ZIF_ABAK_DATA_GET_DATA .
protected section.

  methods LOAD_DATA_AUX
  abstract
    exporting
      !ET_K type ZABAK_K_T
      !E_NAME type STRING
    raising
      ZCX_ABAK .
  methods INVALIDATE_AUX
  abstract .
private section.

  constants:
    BEGIN OF gc_option,
        equal                    TYPE bapioption VALUE 'EQ',
        not_equal                TYPE bapioption VALUE 'NE',
        between                  TYPE bapioption VALUE 'BT',
        not_between              TYPE bapioption VALUE 'NB',
        contains_pattern         TYPE bapioption VALUE 'CP',
        does_not_contain_pattern TYPE bapioption VALUE 'NP',
        less_than                TYPE bapioption VALUE 'LT',
        less_or_equal            TYPE bapioption VALUE 'LE',
        greater_than             TYPE bapioption VALUE 'GT',
        greater_or_equal         TYPE bapioption VALUE 'GE',
      END OF gc_option .
  data GT_K type ZABAK_K_T .
  data G_NAME type STRING .

  methods CHECK_DATA
    importing
      !IT_K type ZABAK_K_T
    raising
      ZCX_ABAK .
  methods CHECK_LINE
    importing
      !IS_K type ZABAK_K
    raising
      ZCX_ABAK .
  methods LOAD_DATA
    exporting
      !ET_K type ZABAK_K_T
      !E_NAME type STRING
    raising
      ZCX_ABAK .
ENDCLASS.



CLASS ZCL_ABAK_DATA IMPLEMENTATION.


  METHOD CHECK_DATA.

    FIELD-SYMBOLS: <s_k> LIKE LINE OF it_k.

    LOOP AT it_k ASSIGNING <s_k>.
      check_line( <s_k> ).
    ENDLOOP.

  ENDMETHOD.


METHOD check_line.

  FIELD-SYMBOLS: <s_kv> LIKE LINE OF is_k-t_kv.

  IF is_k-fieldname IS INITIAL OR is_k-ricef IS INITIAL.
    RAISE EXCEPTION TYPE zcx_abak.
  ENDIF.

  LOOP AT is_k-t_kv ASSIGNING <s_kv>.

* Validate sign
    IF <s_kv>-sign CN 'IE'.
      RAISE EXCEPTION TYPE zcx_abak. " XXX
    ENDIF.

    CASE <s_kv>-option.
      WHEN gc_option-equal OR
           gc_option-not_equal OR
           gc_option-contains_pattern OR
           gc_option-does_not_contain_pattern OR
           gc_option-greater_or_equal OR
           gc_option-greater_than OR
           gc_option-less_or_equal OR
           gc_option-less_than.
*      Single value operators cannot have high defined

        IF <s_kv>-high IS NOT INITIAL.
          RAISE EXCEPTION TYPE zcx_abak. " XXX
        ENDIF.

      WHEN gc_option-between OR
           gc_option-not_between.
*       Two value operator must have high defined

        IF <s_kv>-high IS INITIAL.
          RAISE EXCEPTION TYPE zcx_abak. " XXX
        ENDIF.

        IF <s_kv>-high < <s_kv>-low.
          RAISE EXCEPTION TYPE zcx_abak. " XXX
        ENDIF.

      WHEN OTHERS.
        RAISE EXCEPTION TYPE zcx_abak. " XXX

    ENDCASE.

  ENDLOOP.

ENDMETHOD.


METHOD LOAD_DATA.

  IF gt_k[] IS NOT INITIAL OR g_name IS NOT INITIAL.
    RETURN.
  ENDIF.

  load_data_aux(
    importing
       et_k   = gt_k
       e_name = g_name ).

  check_data( gt_k ).

ENDMETHOD.


METHOD zif_abak_data_get_data~get_data.
  load_data( ).
  rt_k = gt_k.
ENDMETHOD.


METHOD zif_abak_data~get_name.
  load_data( ).
  r_name = g_name.
ENDMETHOD.


METHOD zif_abak_data~invalidate.
  CLEAR gt_k[].
  CLEAR g_name.
  invalidate_aux( ).
ENDMETHOD.


method zif_abak_data~read.
  FIELD-SYMBOLS: <s_k> LIKE LINE OF gt_k.

  LOG-POINT ID zabak SUBKEY 'data.read' FIELDS i_ricef i_fieldname i_context.

  load_data( ).

  READ TABLE gt_k ASSIGNING <s_k>
    WITH KEY ricef = i_ricef
             fieldname = i_fieldname
             context = i_context.
  IF sy-subrc = 0.
    rt_kv = <s_k>-t_kv.
  ENDIF.

endmethod.
ENDCLASS.
