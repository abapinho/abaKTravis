interface ZIF_ABAK_CONSTS
  public .

  constants:
    BEGIN OF content_type,
        inline        TYPE zabak_content_type VALUE 'INLINE',
        url           TYPE zabak_content_type VALUE 'URL',
        standard_text TYPE zabak_content_type VALUE 'SO10',
        server        TYPE zabak_content_type VALUE 'SERVER',
      END OF content_type .

  constants:
    BEGIN OF format_type,
          database                TYPE zabak_format_type VALUE 'DB',
          xml                     TYPE zabak_format_type VALUE 'XML',
        END OF format_type .

endinterface.
