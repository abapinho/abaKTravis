**"* use this source file for your ABAP unit test classes
*CLASS lcl_unittest DEFINITION FOR TESTING
*  INHERITING FROM zcl_abak_unit_tests
*  DURATION SHORT
*  RISK LEVEL DANGEROUS.
*
*  PRIVATE SECTION.
*
*    DATA:
*      f_cut TYPE REF TO zcl_abak_origin_server.
*
*    METHODS: setup RAISING zcx_abak.
*    METHODS: read FOR TESTING RAISING zcx_abak.
*
*ENDCLASS.       "lcl_Unittest
*
*
*CLASS lcl_unittest IMPLEMENTATION.
*
*  METHOD setup.
*    DATA: temp_folder TYPE char255,
*          filename    TYPE string,
*          xml         TYPE string.
*
*    CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'DIR_TEMP'        "#EC CI_CCALL
*                       ID 'VALUE' FIELD temp_folder.
*
*    filename = |{ temp_folder }/zcl_abak_orign_server_{ cl_system_uuid=>create_uuid_x16_static( ) }.xml|.
*
*    OPEN DATASET filename FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
*    TRANSFER xml TO filename.
*    CLOSE DATASET filename.
*
*    CREATE OBJECT f_cut
*      EXPORTING
*        i_text = 'Something'.
*  ENDMETHOD.
*
*  METHOD read.
*    cl_abap_unit_assert=>assert_equals( exp = 'Something'
*                                        act = f_cut->zif_abak_origin~get( ) ).
*  ENDMETHOD.
*
*ENDCLASS.
