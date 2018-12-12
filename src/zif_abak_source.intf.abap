interface ZIF_ABAK_SOURCE
  public .


  methods GET_DATA
    returning
      value(RT_K) type ZABAK_K_T
    raising
      ZCX_ABAK . "#EC CI_VALPAR
  methods INVALIDATE
    raising
      ZCX_ABAK .
  methods GET_NAME
    returning
      value(R_NAME) type STRING .
endinterface.
