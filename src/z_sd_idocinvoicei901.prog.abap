*----------------------------------------------------------------------* "#EC ..
*INCLUDE Z_SD_IDOCINVOICEI901                                          *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Author        : Sajid Ghulam                                         *
* Date          : 21-11-2007                                           *
* I/E-number    : I901                                                 *
* Version FD/TD : V1.0                                                 *
*----------------------------------------------------------------------*
* Description   : This Include program populate the segment E1EDKA1    *
* OF IDOC INVOIC01 for partner goods recepient                         *
*-----------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Author        : Murali                                               *
* Date          : 050418                                               *
* I/E-number    : SAPA-1109                                            *
* Version FD/TD :                                                  *
*----------------------------------------------------------------------*
* Description   : This Include program populate the segment E1EDKA1    *
* OF IDOC INVOIC01 with no partner but would have the china ware house *
* address and it is not mapped to Amazon                               *
* THis is changes only for Amazon Direct china shipments               *
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
*----------------------------------------------------------------------*
* Author        : Aashana                                              *
* Date          : 06-09-2018                                           *
* Request       :                                                      *
* I/E-number    : OTS 338078                                           *
* Reference     : Amazon DI - output EDI message invoice               *
*                 shipment segment                                     *
* Version FD/TD :                                                      *
* Description   : The segments of ship to are not added when doing     *
*                 the billing output for multiple invoices in one go   *
*                for amazon DI.                                        *
*----------------------------------------------------------------------*
* Author        : Aashana                                              *
* Date          : 07-03-2019                                           *
* I/E-number    : SAPA - 2172                                          *
* Reference     : YADAVAAS                                             *
* Description   : 'Tom Tom VAT registration number' needs to be picked *
*                 up from table ZBRIM_VAT_NUMBER and passed to         *
*                 E1EDK01-EIGENUINR in the idoc. Same iformation is    *
*                 then passed to customer through idoc via Biztalk     *
*                 in the form of email through SFMC.                   *
*----------------------------------------------------------------------*
* Author        : Elizabeth Thomas                                     *
* Date          : 19-07-2019                                           *
* Story         : SAPA - 3073                                          *
* Description   : AMAZON DI - VMS Booking Key in the AR invoice        *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Author        : Murali C                                             *
* Date          : 18-02-2020                                           *
* Story         : ITSD-52830                                           *
* Description   : Reference incorrect on Renault invoices              *
* for renault invoice the reference should be filled with the your ref-*
*-rence field from the order header in the invoice IDOC                *
*----------------------------------------------------------------------*


*----------------------------------------------------------------------*
*      T  Y  P  E  -  P  O  O  L  S                                    *
*----------------------------------------------------------------------*

TYPE-POOLS abap .
*----------------------------------------------------------------------*
*     C  O  N  S  T  A  N  T  S                                        *
*----------------------------------------------------------------------*

CONSTANTS : lc_mestyp  TYPE char6   VALUE  'INVOIC',              " constant for Message type
            lc_memid   TYPE char10  VALUE  'Z_MEMID',             " constant for memory id
            lc_e1edka1 TYPE char7   VALUE  'E1EDKA1' ,            " constant for E1EDKA1
            lc_we      TYPE char2   VALUE  'WE',                  " For parter role WE
            lc_parvw   TYPE char5   VALUE  'PARVW',               " For qualifier
            lc_name1   TYPE char5   VALUE  'NAME1',               " For parter Name1
            lc_name2   TYPE char5   VALUE  'NAME2',               " For parter Name2
            lc_name3   TYPE char5   VALUE  'NAME3',               " For parter Name3
            lc_name4   TYPE char5   VALUE  'NAME4',               " For parter Name4
            lc_stras   TYPE char5   VALUE  'STRAS',               " House number and street
            lc_strs2   TYPE char5   VALUE  'STRS2',               "Street no 2
            lc_ort01   TYPE char5   VALUE  'ORT01',               " City
            lc_pstlz   TYPE char5   VALUE  'PSTLZ',               " P.O. Box Postal Code
            lc_pstl2   TYPE char5   VALUE  'PSTL2',               " Postal Code
            lc_land1   TYPE char5   VALUE  'LAND1',               " country
            lc_regio   TYPE char5   VALUE  'REGIO',               " Region (State, Province, County)
            lc_lifnr   TYPE char5   VALUE  'LIFNR'.

*----------------------------------------------------------------------*
*     D  A  T  A     D  E  C  L  A  R  A  T  I  O  N                   *
*----------------------------------------------------------------------*
DATA : lwa_e1edka1 TYPE e1edka1 ,                               " work area of type segment E1EDKA1
       ls_e1edk02  TYPE e1edk02, "SAPA-3073 by elizabeth
       lv_memid(1) TYPE c,
       lv_street   TYPE stras_gp,
       lv_objname  TYPE tdobname,
       gv_shipper  TYPE string,
       lv1_vtweg   TYPE vtweg VALUE '02',
       lv1_spart   TYPE spart VALUE '01',
       ls_stxh     TYPE stxh,
       lv_shipper  TYPE tline-tdline,
       li1_lines1  TYPE   STANDARD  TABLE OF tline,
       lwa1_lines1 TYPE tline,
       lv1_name1   TYPE  string ,               " For parter Name1
       lv_name2    TYPE string ,              " For parter Name2
       lv_stras    TYPE string,               " House number and street
       lv_strs2    TYPE string,              "Street 2
       lv_ort01    TYPE string,               " City
       lv_pstlz    TYPE string,              " Postal Code
       lv_land1    TYPE string,               " country
       lv_lifnr    TYPE  lifnr.

* YADAVAAS++
* OTS 338078
DATA : lv_subrc      TYPE sy-subrc,
* OTS 338078
* SAPA 2172
       lc_e1edk01_t  TYPE char7 VALUE 'E1EDK01',
       lwa_e1edk01_t TYPE e1edk01,
       lv_taxm1      TYPE taklm,
       lv_ourvat     TYPE stceg,
       lv_ihrez      TYPE ihrez ,  " added by Murali 180221
       lv1_curcy    type curcy,
       lv1_hwaer    type hwaer,
       lv1_wkurs    type wkurs.


* SAPA 2172
* YADAVAAS--


*----------------------------------------------------------------------*
*    P  R  O  G  R  A  M      L  O  G  I  C                            *
*----------------------------------------------------------------------*

IF int_edidd-segnam = lc_e1edk01_t.

  MOVE int_edidd-sdata TO lwa_e1edk01_t.

  lv1_curcy = lwa_e1edk01_t-curcy.
  lv1_hwaer = lwa_e1edk01_t-hwaer.
  lv1_wkurs = lwa_e1edk01_t-wkurs.

  EXPORT lv1_curcy TO MEMORY ID 'M_CURCY'.
  EXPORT lv1_hwaer TO MEMORY ID 'M_HWAER'.
  EXPORT lv1_wkurs TO MEMORY ID 'M_WKURS'.
ENDIF.

* Check the message type to execute the code
CHECK control_record_out-mestyp = lc_mestyp .

IMPORT param = lv_memid FROM MEMORY ID lc_memid.                  " check the value of lv_memid to execute rest of stmt

* YADAVAAS++
* OTS 338078 - the segments of ship to are not added when doing the billing output for
* multiple invoices in one go for amazon DI.
* Added the below code.
* lv_memid was not getting refreshed, if the data on VF31 screen was not changed/refreshed,
* hence some segments were getting missed in the idoc
lv_subrc = sy-subrc.
IF sy-tabix EQ '1'.
  IF lv_memid IS NOT INITIAL.
    CLEAR : lv_memid.
    lv_subrc = '4'.
  ENDIF.
ENDIF.
* Commented the below
*IF lv_memid IS INITIAL and sy-subrc <> 0.
IF lv_memid IS INITIAL AND lv_subrc <> 0.
* YADAVAAS--
  IF control_record_out-rcvprn = 'AMAZONDR'.
*
*
    lv_vkorg = xvbdkr-vkorg.

    CONCATENATE xvbdkr-kunwe lv_vkorg lv1_vtweg
                lv1_spart INTO lv_objname.

    SELECT SINGLE * FROM stxh INTO ls_stxh WHERE tdobject =  'KNVV'
                                            AND  tdname   =  lv_objname
                                            AND  tdid     =  'Z003'.
    IF sy-subrc EQ 0.
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          client   = sy-mandt
          id       = 'Z003'
          language = 'E'
          name     = lv_objname
          object   = 'KNVV'
        TABLES
          lines    = li1_lines1.

      IF sy-subrc EQ 0.
        LOOP AT li1_lines1 INTO lwa1_lines1.
          lv_shipper = lwa1_lines1-tdline.
          CONCATENATE gv_shipper lv_shipper INTO gv_shipper .
        ENDLOOP.
      ENDIF.

    ENDIF.

    SPLIT gv_shipper AT '|' INTO lv1_name1
                                 lv_name2
                                 lv_stras
                                 lv_strs2
                                 lv_pstlz
                                 lv_ort01
                                 lv_land1.

    PERFORM move USING lc_parvw   lc_we        CHANGING lwa_e1edka1 .   " Update PARVE FOR WE
    PERFORM move USING lc_name1   lv1_name1    CHANGING lwa_e1edka1 .   " Update E1edka1 WITH NAME1
    PERFORM move USING lc_name2   lv_name2     CHANGING lwa_e1edka1 .   " Update E1edka1 WITH NAME2
    PERFORM move USING lc_stras   lv_stras     CHANGING lwa_e1edka1 .   " Update E1edka1 WITH House number and street
    PERFORM move USING lc_strs2   lv_strs2     CHANGING lwa_e1edka1 .   " Update E1edka1 WITH House number and street
    PERFORM move USING lc_ort01   lv_ort01     CHANGING lwa_e1edka1 .   " Update E1edka1 WITH City
    PERFORM move USING lc_pstlz   lv_pstlz     CHANGING lwa_e1edka1 .   " Update E1edka1 WITH Postal Code
    PERFORM move USING lc_land1   lv_land1     CHANGING lwa_e1edka1 .   " Update E1edka1 WITH Country

    MOVE lc_e1edka1   TO int_edidd-segnam.                              " Update INT_EDIDD WITH E1EDKA1 SEGNME
    MOVE lwa_e1edka1 TO int_edidd-sdata.                                " APPEND INT_EDIDD WITH MODIFIED DATA SEGMENT

    APPEND int_edidd TO int_edidd.


* Form/Routine to populate the segment E1EDKA1 with no partner just to keep Amazon CHina ware house address
    PERFORM move USING lc_parvw   ''              CHANGING lwa_e1edka1 .   " Update PARVE FOR WE
    PERFORM move USING lc_name1   xvbdkr-name1_we CHANGING lwa_e1edka1 .   " Update E1edka1 WITH NAME1
    PERFORM move USING lc_name2   xvbdkr-name2_we CHANGING lwa_e1edka1 .   " Update E1edka1 WITH NAME2
    PERFORM move USING lc_name3   xvbdkr-name3_we CHANGING lwa_e1edka1 .   " Update E1edka1 WITH NAME3
    PERFORM move USING lc_name4   xvbdkr-name4_we CHANGING lwa_e1edka1 .   " Update E1edka1 WITH NAME4
    PERFORM move USING lc_stras   xvbdkr-stras_we CHANGING lwa_e1edka1 .   " Update E1edka1 WITH House number and street

    SELECT SINGLE str_suppl1 FROM adrc INTO lv_street  WHERE addrnumber = xvbdkr-adrnr_we.

    PERFORM move USING lc_strs2   lv_street       CHANGING lwa_e1edka1 .   " Update E1edka1 WITH street2
    PERFORM move USING lc_ort01   xvbdkr-ort01_we CHANGING lwa_e1edka1 .   " Update E1edka1 WITH City
    PERFORM move USING lc_pstlz   xvbdkr-pstlz_we CHANGING lwa_e1edka1 .   " Update E1edka1 WITH Postal Code
    PERFORM move USING lc_pstl2   xvbdkr-pstl2_we CHANGING lwa_e1edka1 .   " Update E1edka1 WITH P.O. Box Postal Code
    PERFORM move USING lc_land1   xvbdkr-land1_we CHANGING lwa_e1edka1 .   " Update E1edka1 WITH Country
    PERFORM move USING lc_regio   xvbdkr-regio_we CHANGING lwa_e1edka1 .   " Update E1edka1 WITH Region (State, Province, County)
    PERFORM move USING lc_lifnr   xvbdkr-kunwe    CHANGING lwa_e1edka1 .   " Update E1edka1 WITH NAME4 SHIP TO CUSTOMER

    MOVE lc_e1edka1   TO int_edidd-segnam.                              " Update INT_EDIDD WITH E1EDKA1 SEGNME
    MOVE lwa_e1edka1 TO int_edidd-sdata.                                " APPEND INT_EDIDD WITH MODIFIED DATA SEGMENT

    APPEND int_edidd TO int_edidd.
  ELSE.
* YADAVAAS++
* SAPA 2172
    IF control_record_out-rcvprn = 'WEBSHOP' or control_record_out-rcvprn = 'CHANLENGN'.  " added by murali on 251125 SAPA-9379 - for channel engine
      IF int_edidd-segnam = lc_e1edk01_t.
        CLEAR : lwa_e1edk01_t.
        MOVE int_edidd-sdata TO lwa_e1edk01_t.
        CLEAR lv_taxm1.
        SELECT SINGLE taxm1 INTO lv_taxm1 FROM vbrp WHERE vbeln = xvbdkr-vbeln.
        CLEAR lv_ourvat.
        SELECT SINGLE stceg FROM zbrim_vat_number
         INTO lv_ourvat
         WHERE vkorg = xvbdkr-vkorg
         AND taxm1 = lv_taxm1
         AND kunnr = xvbdkr-kunre.
        IF lv_ourvat IS NOT INITIAL.
          lwa_e1edk01_t-eigenuinr = lv_ourvat.
          MOVE lwa_e1edk01_t TO int_edidd-sdata.
          MOVE lc_e1edk01_t TO  int_edidd-segnam.
          MODIFY int_edidd INDEX sy-index.
          CLEAR : int_edidd.
        ENDIF.
      ENDIF.
    ENDIF.
* YADAVAAS--
* Form/Routine to populate the segment E1EDKA1
    PERFORM move USING lc_parvw   lc_we        CHANGING lwa_e1edka1 .   " Update PARVE FOR WE
    PERFORM move USING lc_name1   xvbdkr-name1 CHANGING lwa_e1edka1 .   " Update E1edka1 WITH NAME1
    PERFORM move USING lc_name2   xvbdkr-name2 CHANGING lwa_e1edka1 .   " Update E1edka1 WITH NAME2
    PERFORM move USING lc_name3   xvbdkr-name3 CHANGING lwa_e1edka1 .   " Update E1edka1 WITH NAME3
    PERFORM move USING lc_name4   xvbdkr-name4 CHANGING lwa_e1edka1 .   " Update E1edka1 WITH NAME4
    PERFORM move USING lc_stras   xvbdkr-stras CHANGING lwa_e1edka1 .   " Update E1edka1 WITH House number and street
    PERFORM move USING lc_ort01   xvbdkr-ort01 CHANGING lwa_e1edka1 .   " Update E1edka1 WITH City
    PERFORM move USING lc_pstlz   xvbdkr-pstlz CHANGING lwa_e1edka1 .   " Update E1edka1 WITH Postal Code
    PERFORM move USING lc_pstl2   xvbdkr-pstl2 CHANGING lwa_e1edka1 .   " Update E1edka1 WITH P.O. Box Postal Code
    PERFORM move USING lc_land1   xvbdkr-land1 CHANGING lwa_e1edka1 .   " Update E1edka1 WITH Country
    PERFORM move USING lc_regio   xvbdkr-regio CHANGING lwa_e1edka1 .   " Update E1edka1 WITH Region (State, Province, County)
    PERFORM move USING lc_lifnr   xvbdkr-kunwe CHANGING lwa_e1edka1 .   " Update E1edka1 WITH NAME4 SHIP TO CUSTOMER

    MOVE lc_e1edka1   TO int_edidd-segnam.                              " Update INT_EDIDD WITH E1EDKA1 SEGNME
    MOVE lwa_e1edka1 TO int_edidd-sdata.                                " APPEND INT_EDIDD WITH MODIFIED DATA SEGMENT

    APPEND int_edidd TO int_edidd.

  ENDIF.

  lv_memid = abap_true .

  EXPORT param = lv_memid TO MEMORY ID lc_memid.                   " update the memory id in the memory

  CLEAR :lv_street.

ENDIF .

* YADAVAAS++
CLEAR lv_subrc.
* YADAVAAS--

IF control_record_out-rcvprn = 'AMAZONDR' AND
   int_edidd-segnam = 'E1EDP01'.
*Start of change for SAPA-3073 by Elizabeth
  DATA : lv_ebeln   TYPE ebeln,
         lv_frbnr   TYPE frbnr,
         ls_e1edp01 TYPE e1edp01,
         ls_e1edp02 TYPE e1edp02.
  ls_e1edp01 = int_edidd-sdata.
*From order get the PO number
  SELECT SINGLE ebeln
         INTO lv_ebeln
         FROM ekkn
         WHERE vbeln = xvbdkr-vbeln_vauf.
  IF sy-subrc = 0.
*Get booking number from PO number
    SELECT SINGLE frbnr
         INTO lv_frbnr
         FROM rseg
         WHERE ebeln  = lv_ebeln AND
               ebelp  = ls_e1edp01-posex AND
               frbnr ne ' '.

  ENDIF.
*Move booking number to segment E1EDP02,QUALF = 064
  IF lv_frbnr IS NOT INITIAL.
    ls_e1edp02-qualf = '064'.
    ls_e1edp02-belnr = lv_frbnr.
    MOVE 'E1EDP02' TO int_edidd-segnam.
    MOVE ls_e1edp02 TO int_edidd-sdata.
    APPEND int_edidd TO int_edidd.
  ENDIF.
  CLEAR: lv_ebeln,lv_frbnr,ls_e1edp02.
*End of change for SAPA-3073 by Elizabeth
ENDIF.

*Start of changes ITSD-52830 by Murali

if xvbdkr-vtweg = '08'.

if  int_edidd-segnam = 'E1EDK02'.

    ls_e1edk02 = int_edidd-sdata.

    if ls_e1edk02-qualf = '087'.   " BIll of ladding number

    select single ihrez from vbkd into lv_ihrez where vbeln = xvbdkr-VBELN_VAUF.

    if lv_ihrez is NOT INITIAL.

    ls_e1edk02-belnr =  lv_ihrez.

    MOVE ls_e1edk02 TO int_edidd-sdata.
    MODIFY int_edidd INDEX sy-tabix.

    clear : lv_ihrez.

    endif.

    endif.

endif.

endif.


*end of changes
