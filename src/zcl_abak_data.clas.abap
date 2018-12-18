CLASS zcl_abak_data DEFINITION
  PUBLIC
  ABSTRACT
  CREATE PUBLIC

  GLOBAL FRIENDS zcl_abak_factory .

  PUBLIC SECTION.

    INTERFACES zif_abak_data .
  PROTECTED SECTION.

    METHODS load_data_aux
    ABSTRACT
      EXPORTING
        !et_k TYPE zabak_k_t
        !e_name TYPE string
      RAISING
        zcx_abak .
    METHODS invalidate_aux
    ABSTRACT
      RAISING
        zcx_abak .
  PRIVATE SECTION.

    CONSTANTS:
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
    DATA gt_k TYPE zabak_k_t .
    DATA g_name TYPE string .

    METHODS check_data
      IMPORTING
        !it_k TYPE zabak_k_t
      RAISING
        zcx_abak .
    METHODS check_line
      IMPORTING
        !is_k TYPE zabak_k
      RAISING
        zcx_abak .
    METHODS load_data
      EXPORTING
        !et_k TYPE zabak_k_t
        !e_name TYPE string
      RAISING
        zcx_abak .
ENDCLASS.



CLASS zcl_abak_data IMPLEMENTATION.


  METHOD check_data.

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


  METHOD load_data.

    IF gt_k[] IS NOT INITIAL OR g_name IS NOT INITIAL.
      RETURN.
    ENDIF.

    load_data_aux(
      IMPORTING
         et_k   = gt_k
         e_name = g_name ).

    check_data( gt_k ).

  ENDMETHOD.


  METHOD zif_abak_data~get_data.
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


  METHOD zif_abak_data~read.
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

  ENDMETHOD.
ENDCLASS.
