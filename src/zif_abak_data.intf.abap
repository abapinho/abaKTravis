interface ZIF_ABAK_DATA
  public .


  methods READ
    importing
      !I_RICEF type ZABAK_RICEF
      !I_FIELDNAME type NAME_FELD
      !I_CONTEXT type ZABAK_CONTEXT
    returning
      value(RT_DATA) type ZABAK_DATA_T
    raising
      ZCX_ABAK .
  methods INVALIDATE
    raising
      ZCX_ABAK .
  methods GET_NAME
    returning
      value(R_NAME) type STRING .
endinterface.
