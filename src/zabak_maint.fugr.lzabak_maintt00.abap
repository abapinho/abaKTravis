*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 30.10.2018 at 10:57:39
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
