interface ZIF_ABAK_SOURCE
  public .


  methods GET_DATA
    returning
      value(RT_DATA) type ZABAK_DATA_T .
  methods INVALIDATE .
  methods GET_NAME
    returning
      value(R_NAME) type STRING .
endinterface.
