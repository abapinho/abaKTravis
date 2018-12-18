interface ZIF_ABAK_DATA_GET_DATA
  public .


  methods GET_DATA
    returning
      value(RT_K) type ZABAK_K_T
    raising
      ZCX_ABAK .
endinterface.
