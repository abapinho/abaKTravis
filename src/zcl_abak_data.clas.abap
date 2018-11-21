class ZCL_ABAK_DATA definition
  public
  final
  create public

  global friends ZCL_ABAK_FACTORY .

public section.

  interfaces ZIF_ABAK_DATA .

  methods CONSTRUCTOR
    importing
      !IO_SOURCE type ref to ZIF_ABAK_SOURCE
    raising
      ZCX_ABAK .
  PROTECTED SECTION.
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
  data GO_SOURCE type ref to ZIF_ABAK_SOURCE .
  data GT_DATA type ZABAK_DATA_T .

  methods CHECK_LINE
    importing
      !I_LINE type ZABAK_DATA
    raising
      ZCX_ABAK .
  methods CHECK_DATA
    importing
      !IT_DATA type ZABAK_DATA_T
    raising
      ZCX_ABAK .
  methods LOAD_FROM_SOURCE
    raising
      ZCX_ABAK .
ENDCLASS.



CLASS ZCL_ABAK_DATA IMPLEMENTATION.


  METHOD CHECK_DATA.

    FIELD-SYMBOLS: <s_data> LIKE LINE OF it_data.

    LOOP AT it_data ASSIGNING <s_data>.
      check_line( <s_data> ).
    ENDLOOP.

  ENDMETHOD.


  METHOD CHECK_LINE.

* Validate sign
    IF i_line-ue_sign CN 'IE'.
      RAISE EXCEPTION TYPE zcx_abak. " XXX
    ENDIF.

* Single value operators cannot have high defined
    CASE i_line-ue_option.
      WHEN gc_option-equal OR
           gc_option-not_equal OR
           gc_option-contains_pattern OR
           gc_option-does_not_contain_pattern OR
           gc_option-greater_or_equal OR
           gc_option-greater_than OR
           gc_option-less_or_equal OR
           gc_option-less_than.

        IF i_line-ue_high IS NOT INITIAL.
          RAISE EXCEPTION TYPE zcx_abak. " XXX
        ENDIF.

*   Two value operator must have high defined
      WHEN gc_option-between OR
           gc_option-not_between.

        IF i_line-ue_high IS INITIAL.
          RAISE EXCEPTION TYPE zcx_abak. " XXX
        ENDIF.

        IF i_line-ue_high < i_line-ue_low.
          RAISE EXCEPTION TYPE zcx_abak. " XXX
        ENDIF.

      WHEN OTHERS.

        RAISE EXCEPTION TYPE zcx_abak. " XXX

    ENDCASE.

  ENDMETHOD.


METHOD constructor.

  IF io_source IS NOT BOUND.
    RAISE EXCEPTION TYPE zcx_abak. " TODO
*        EXPORTING
*          textid = zcx_abak=>invalid_data_source.
  ENDIF.

  go_source = io_source.

ENDMETHOD.


METHOD load_from_source.

  IF gt_data[] IS NOT INITIAL.
    RETURN.
  ENDIF.

  gt_data = go_source->get_data( ).

  check_data( gt_data ).

ENDMETHOD.


METHOD zif_abak_data~get_name.
  r_name = go_source->get_name( ).
ENDMETHOD.


METHOD zif_abak_data~invalidate.

  LOG-POINT ID zabak SUBKEY 'data.invalidate'.

  REFRESH gt_data.

  go_source->invalidate( ).

ENDMETHOD.


METHOD zif_abak_data~read.

  FIELD-SYMBOLS: <s_data> LIKE LINE OF gt_data.

  LOG-POINT ID zabak SUBKEY 'data.read' FIELDS go_source->get_name( ) i_ricef i_fieldname i_context.

  load_from_source( ).

  LOOP AT gt_data
    ASSIGNING <s_data>
    WHERE ricef = i_ricef
      AND fieldname = i_fieldname
      AND context = i_context.
    INSERT <s_data> INTO TABLE rt_data.
  ENDLOOP.

ENDMETHOD.
ENDCLASS.
