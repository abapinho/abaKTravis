INTERFACE zif_abak_source
  PUBLIC .


  CONSTANTS:
    BEGIN OF source_type,
      database                TYPE zabak_source_type VALUE 'DB',
      database_shared_objects TYPE zabak_source_type VALUE 'DB_SHM',
      xml                     TYPE zabak_source_type VALUE 'XML',
      xml_url                 TYPE zabak_source_type VALUE 'XML_URL',
    END OF source_type.

  METHODS get_data
    RETURNING
      value(rt_data) TYPE zabak_data_t .
  METHODS invalidate .
  METHODS get_name
    RETURNING
      value(r_name) TYPE string .
ENDINTERFACE.
