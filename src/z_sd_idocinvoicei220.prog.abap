*&---------------------------------------------------------------------*
*&  Include           Z_SD_IDOCINVOICEI220
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Author        : Sajid Ghulam                                         *
* Date          : 18-12-2007                                           *
* I/E-number    : I220                                                 *
* Version FD/TD : V1.0                                                 *
*----------------------------------------------------------------------*
* Description   : This Include program populate the segment E1EDPT1    *
* OF IDOC INVOIC01 for Qualifier Z4BL                                   *
*-----------------------------------------------------------------------*
* Change log                                                            *
*-----------------------------------------------------------------------*
* Author        : <name of developer>                                   *
* Date          : <DD-MM-CCYY>                                          *
* Request       : <transport request>                                   *
* I/E-number    : <development number>                                  *
* Reference     : <CS number>                                           *
* Version FD/TD : <fdver>/<tdver>                                       *
* Description   : <Description change>                                  *
*-----------------------------------------------------------------------*

** Local Constants

CONSTANTS :  lc_z4bl(4)       TYPE c  VALUE 'Z4BL',
             lc_memoid        TYPE char10  VALUE  'Z_MEMOID',             " constant for memory id
             lc_e1edkt1(7)    TYPE c  VALUE 'E1EDKT1' .

** Local Work Areas

DATA :       lwa_e1edkt1      TYPE e1edkt1,                               " IDoc: Document Header Text Identification
             lwa_e1edkt2      TYPE e1edkt2,
             lv_memoid(1)     TYPE c .

IMPORT param = lv_memoid FROM MEMORY ID lc_memoid.                        " check the value of lv_memid to execute rest of stmt
IF lv_memoid IS INITIAL AND sy-subrc <> 0.


  CASE int_edidd-segnam.

    WHEN   lc_e1edkt1.

      CLEAR : int_edidd,
              lwa_e1edkt1 .


      int_edidd-segnam = 'E1EDKT1'.
      lwa_e1edkt1-tdid = lc_z4bl .                                           " *- Text-ID

      MOVE lwa_e1edkt1 TO int_edidd-sdata.

      APPEND int_edidd.

      CLEAR : int_edidd,
              lwa_e1edkt1 .

      int_edidd-segnam = 'E1EDKT2'.

*- Textzeilen  --------------------------------------------------------

      lwa_e1edkt2-tdline  = 'Bill of Lading'.

*  e1edkt2-tdformat = tlinetab-tdformat.

      MOVE lwa_e1edkt2 TO int_edidd-sdata.
      APPEND int_edidd.

      EXPORT  param = lv_memoid TO MEMORY ID lc_memoid .

  ENDCASE .

ENDIF.
