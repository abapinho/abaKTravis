CLASS zcl_abak DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE

  GLOBAL FRIENDS zcl_abak_factory .

  PUBLIC SECTION.

    INTERFACES zif_abak .

    METHODS constructor
      IMPORTING
        !io_data TYPE REF TO zif_abak_data
      RAISING
        zcx_abak .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA go_data TYPE REF TO zif_abak_data .

    METHODS get_value_aux
      IMPORTING
        value(i_ricef) TYPE zabak_ricef
        value(i_fieldname) TYPE name_feld
        value(i_context) TYPE any
      RETURNING
        value(r_value) TYPE zabak_low
      RAISING
        zcx_abak .
    METHODS convert_context
      IMPORTING
        !i_context TYPE any
      RETURNING
        value(r_context) TYPE zabak_context .
    METHODS check_value_aux
      IMPORTING
        value(i_ricef) TYPE zabak_ricef
        value(i_fieldname) TYPE name_feld
        value(i_context) TYPE any
        value(i_value) TYPE any
      RETURNING
        value(r_result) TYPE flag
      RAISING
        zcx_abak .
    METHODS get_range_aux
      IMPORTING
        value(i_ricef) TYPE zabak_ricef
        value(i_fieldname) TYPE name_feld
        value(i_context) TYPE any
      RETURNING
        value(rr_range) TYPE zabak_range_t
      RAISING
        zcx_abak .
ENDCLASS.



CLASS ZCL_ABAK IMPLEMENTATION.


  METHOD check_value_aux.

    IF get_value_aux( i_ricef     = i_ricef
                      i_fieldname = i_fieldname
                      i_context   = i_context ) = i_value.
      r_result = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD constructor.

    IF io_data IS NOT BOUND.
      RAISE EXCEPTION TYPE zcx_abak. " TODO
    ENDIF.

    go_data = io_data.

  ENDMETHOD.


  METHOD convert_context.
    WRITE i_context TO r_context LEFT-JUSTIFIED.
  ENDMETHOD.


  METHOD get_range_aux.


    DATA: t_data TYPE zabak_data_t,
          context TYPE zabak_context.

    DATA: s_range LIKE LINE OF rr_range.

    FIELD-SYMBOLS: <s_data> LIKE LINE OF t_data.

    context = convert_context( i_context ).

    t_data = go_data->read( i_ricef     = i_ricef
                            i_fieldname = i_fieldname
                            i_context   = context ).

    LOOP AT t_data ASSIGNING <s_data>
      WHERE ricef = i_ricef
        AND fieldname = i_fieldname
        AND context = context.

      CLEAR s_range.
      s_range-sign = <s_data>-ue_sign.
      s_range-option = <s_data>-ue_option.
      s_range-low = <s_data>-ue_low.
      s_range-high = <s_data>-ue_high.
      INSERT s_range INTO TABLE rr_range.

    ENDLOOP.

    IF rr_range[] IS INITIAL.

      RAISE EXCEPTION TYPE zcx_abak. " TODO
*      EXPORTING
*        textid    = zcx_zs_consts=>value_not_found
*        ricef     = i_ricef
*        fieldname = i_fieldname
*        context   = context.

    ENDIF.

  ENDMETHOD.


  METHOD get_value_aux.

    DATA: t_data TYPE zabak_data_t,
          context TYPE zabak_context.

    FIELD-SYMBOLS: <s_data> LIKE LINE OF t_data.

    context = convert_context( i_context ).

    t_data = go_data->read( i_ricef     = i_ricef
                            i_fieldname = i_fieldname
                            i_context   = context ).

    READ TABLE t_data
      ASSIGNING <s_data>
      WITH KEY ricef = i_ricef
               fieldname = i_fieldname
               context = context.

    IF sy-subrc = 0.

      r_value = <s_data>-ue_low.

    ELSE.

      RAISE EXCEPTION TYPE zcx_abak. " TODO
*      EXPORTING
*        textid    = zcx_zs_consts=>value_not_found
*        ricef     = i_ricef
*        fieldname = i_fieldname
*        context   = context.

    ENDIF.

  ENDMETHOD.


  METHOD zif_abak~check_value.

    LOG-POINT ID zabak SUBKEY 'engine.check_value' FIELDS go_data->get_name( ) i_ricef i_fieldname i_context i_value.

    r_result = check_value_aux( i_ricef     = i_ricef
                                i_fieldname = i_fieldname
                                i_context   = i_context
                                i_value     = i_value ).
  ENDMETHOD.


  METHOD zif_abak~check_value_if_exists.

    TRY.

        LOG-POINT ID zabak SUBKEY 'engine.check_value_if_exists' FIELDS go_data->get_name( ) i_ricef i_fieldname i_context i_value.

        r_result = check_value_aux( i_ricef     = i_ricef
                                    i_fieldname = i_fieldname
                                    i_context   = i_context
                                    i_value     = i_value ).

      CATCH zcx_abak.
        RETURN. " No problem if it does not exist
    ENDTRY.

  ENDMETHOD.


  METHOD zif_abak~get_range.

    LOG-POINT ID zabak SUBKEY 'engine.get_range' FIELDS go_data->get_name( ) i_ricef i_fieldname i_context.

    rr_range = get_range_aux( i_ricef     = i_ricef
                              i_fieldname = i_fieldname
                              i_context   = i_context ).

  ENDMETHOD.


  METHOD zif_abak~get_range_if_exists.

    TRY.

        LOG-POINT ID zabak SUBKEY 'engine.get_range_if_exists' FIELDS go_data->get_name( ) i_ricef i_fieldname i_context.

        rr_range = get_range_aux( i_ricef     = i_ricef
                                  i_fieldname = i_fieldname
                                  i_context   = i_context ).

      CATCH zcx_abak.
        RETURN. " No problem if it does not exist
    ENDTRY.

  ENDMETHOD.


  METHOD zif_abak~get_value.

    LOG-POINT ID zabak SUBKEY 'engine.get_value' FIELDS go_data->get_name( ) i_ricef i_fieldname i_context.

    r_value = get_value_aux( i_ricef     = i_ricef
                             i_fieldname = i_fieldname
                             i_context   = i_context ).

  ENDMETHOD.


  METHOD zif_abak~get_value_if_exists.

    TRY.

        LOG-POINT ID zabak SUBKEY 'engine.get_value_if_exists' FIELDS go_data->get_name( ) i_ricef i_fieldname i_context.

        r_value = get_value_aux( i_ricef     = i_ricef
                                 i_fieldname = i_fieldname
                                 i_context   = i_context ).

      CATCH zcx_abak.
        RETURN. " No problem if it does not exist
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
