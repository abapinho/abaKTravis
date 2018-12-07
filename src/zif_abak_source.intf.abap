interface ZIF_ABAK_SOURCE
  public .


  constants:
    begin of SOURCE_TYPE,
      database type zabak_source_type value 'DB',
      xml      type zabak_source_type value 'XML',
      xml_url  type zabak_source_type value 'XML_URL',
    end of source_type.

  methods GET_DATA
    returning
      value(RT_DATA) type ZABAK_DATA_T .
  methods INVALIDATE .
  methods GET_NAME
    returning
      value(R_NAME) type STRING .
endinterface.
