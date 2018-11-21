CLASS zcl_abak_unit_tests DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
PROTECTED SECTION.

  CONSTANTS:
    BEGIN OF gc_tablename,
                 valid TYPE tabname VALUE 'ZABAK_UNITTESTS',
                 invalid TYPE tabname VALUE 'USR01',
               END OF gc_tablename .
  CONSTANTS:
    begin of gc_ricef,
      utest TYPE zabak_ricef VALUE 'UTEST',
    end of gc_ricef.        "#EC NOTEXT
  CONSTANTS:
    begin of gc_context,
      c1             TYPE zabak_context VALUE 'C1',
      does_not_exist type zabak_context value 'DOES_NOT_EXIST',
    end of gc_context.

  METHODS generate_test_data .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_ABAK_UNIT_TESTS IMPLEMENTATION.


  METHOD generate_test_data.

    DATA: t_data TYPE zabak_data_t,
          s_data LIKE LINE OF t_data.

    CLEAR s_data.
    s_data-ricef = gc_ricef.
    s_data-fieldname = 'BUKRS'.
    s_data-ue_option = 'EQ'.
    s_data-ue_sign = 'I'.
    s_data-ue_low = '0231'.
    INSERT s_data INTO TABLE t_data.

    CLEAR s_data.
    s_data-ricef = gc_ricef.
    s_data-fieldname = 'KOART'.
    s_data-ue_option = 'EQ'.
    s_data-ue_sign = 'I'.
    s_data-ue_low = 'D'.
    s_data-idx = 1.
    INSERT s_data INTO TABLE t_data.
    s_data-ue_low = 'K'.
    s_data-idx = 2.
    INSERT s_data INTO TABLE t_data.

    CLEAR s_data.
    s_data-ricef = gc_ricef.
    s_data-fieldname = 'KUNNR'.
    s_data-context = gc_context-c1.
    s_data-ue_option = 'EQ'.
    s_data-ue_sign = 'I'.
    s_data-ue_low = '1234567890'.
    INSERT s_data INTO TABLE t_data.

*   Delete table content
    DELETE FROM zabak_unittests WHERE ricef <> space.   "#EC CI_NOFIELD

    INSERT zabak_unittests FROM TABLE t_data.

  ENDMETHOD.
ENDCLASS.
