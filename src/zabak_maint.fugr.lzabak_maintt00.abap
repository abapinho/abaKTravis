*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 10.12.2018 at 19:42:54
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZABAK...........................................*
DATA:  BEGIN OF STATUS_ZABAK                         .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZABAK                         .
CONTROLS: TCTRL_ZABAK
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZABAK                         .
TABLES: ZABAK                          .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
