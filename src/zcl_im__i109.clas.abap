class ZCL_IM__I109 definition
  public
  final
  create public .

*"* public components of class ZCL_IM__I109
*"* do not include other source files here!!!
public section.

  interfaces IF_EX_SMOD_V50B0001 .
protected section.
*"* protected components of class ZCL_IM__I109
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_IM__I109
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_IM__I109 IMPLEMENTATION.


method IF_EX_SMOD_V50B0001~EXIT_SAPLV50I_001.


endmethod.


method IF_EX_SMOD_V50B0001~EXIT_SAPLV50I_002.


endmethod.


method IF_EX_SMOD_V50B0001~EXIT_SAPLV50I_003.
endmethod.


METHOD if_ex_smod_v50b0001~exit_saplv50i_004.
ENDMETHOD.


method IF_EX_SMOD_V50B0001~EXIT_SAPLV50I_009.
endmethod.


method IF_EX_SMOD_V50B0001~EXIT_SAPLV50I_010.
endmethod.


method IF_EX_SMOD_V50B0001~EXIT_SAPLV50K_005.



endmethod.


method IF_EX_SMOD_V50B0001~EXIT_SAPLV50K_006.


endmethod.


METHOD if_ex_smod_v50b0001~exit_saplv50k_007.

*&---------------------------------------------------------------------&*
*----------------------------------------------------------------------&*
* Author        : Tapan Kumar Rath
* Date          : 20-11-2007
* I/E-number    : I109, I110
* Version FD/TD : 0.0.1/1.0
* Request       :
*&---------------------------------------------------------------------&*
* Description   : BADI Implementation for populating extension segments
*                 of IDoc having Message Type SHP_OBDLV_SAVE_REPLICA
*                 and basic IDoc type SHP_OBDLV_SAVE_REPLICA02
*
*&---------------------------------------------------------------------&*
* Change log
*&---------------------------------------------------------------------&*
* Author        : Tapan Kumar Rath
* Date          : 17-04-2008
* Request       : TRDK902041
* I/E-number    : I109
* Reference     : I109
* Version FD/TD : 1.0/1.0
* Description   : Added extra fields (field1, field2,field3,field4)
*                 segment E1BPEXTC.
*&---------------------------------------------------------------------&*
* Author        : Manoj Kumar Memba
* Date          : 28-08-2008
* Request       : TRDK902041
* I/E-number    : I109
* Reference     : I109
* Version FD/TD : 1.0/1.0
* Description   : Changed the Code populating data for et_extension1
*&---------------------------------------------------------------------&*
* Author        : Ron Hogeboom
* Date          : 18-09-2008
* Request       : TRDK902041
* I/E-number    : I109
* Reference     : I109
* Version FD/TD : 1.0/1.0
* Description   : No price segment was generated in case of STO's
*                 Segment must always be generated but with value 0
*&---------------------------------------------------------------------&*
* Author        : Ron Hogeboom
* Date          : 07-04-2009
* Request       : TRDK
* I/E-number    : I109
* Reference     : RHO20090407
* Version FD/TD : 1.0/1.0
* Description   : Add new field BILLFROM for support commercial invoice
*&---------------------------------------------------------------------&*
* Author        : Ron Hogeboom
* Date          : 02-02-2010
* Request       : TRDK
* I/E-number    : #1-12372971
* Reference     : RHO20100202
* Version FD/TD : 1.0/1.0
* Description   : Add new field for translation Ship-to and Sold-to codes
*                 from SAP internal to external numbering
*&---------------------------------------------------------------------&*
* Author        : Ellen Muntjewerf
* Date          : 12-07-2010
* Request       : TRDK909042/TRDK909058
* I/E-number    : #1-15766121 - Apeldoorn - Bonded - E1BPEXTC segment idoc
* Reference     : EM12072010
* Version FD/TD : 1.0/1.0
* Description   : E1BPEXTC segment idoc for ZNLN and RLN items
*&---------------------------------------------------------------------&*
* Author        : Ron Hogeboom
* Date          : 12-11-2010
* Request       :
* I/E-number    : #1-20907355 Extend field length to 20 positions
* Reference     : RH20101112
* Version FD/TD : 1.0/1.0
* Description   : Ship to party and sold to party field should be 20
*                 instead of 10
*&---------------------------------------------------------------------&*
* Author        : Ron Hogeboom
* Date          : 20-03-2013
* Request       :
* I/E-number    : SAP Upgrade
* Reference     : RH20130320
* Version FD/TD :
* Description   : Support of subcontracting delivery to handle that
*                 segment is created with price
*
*&---------------------------------------------------------------------&*
* Author        : Rajesh Padya
* Date          : 10-05-2013
* Request       :
* I/E-number    : SAP Upgrade
* Reference     : PAD10052013
* Version FD/TD :
* Description   : Delivery Items are missing incase of Multiple orders in
*                 one delivery
*&---------------------------------------------------------------------&*
* Author        : Rajesh Padya
* Date          : 28-07-2015
* Request       :
* I/E-number    : OTS-101955
* Reference     : PADYA20150728
* Version FD/TD :
* Description   : Segment E1BPEXTC Field FIELD2 is not populating with
*               : Net Value for CH15 and NO15
*&---------------------------------------------------------------------&*
* Author        : Asifa Mirza
* Date          : 20-05-2016
* Request       :
* I/E-number    : OTS-99813
* Reference     : AM 20.05.2016
* Version FD/TD :
* Description   : Segment E1BPEXTC Field FIELD2 = KZWI3 For Direct Sales
*                 Pricing Procedure the COntract value needs to be populated
*                 on the commercial invoice
*&---------------------------------------------------------------------&*
* Author        : Rajesh Padya
* Date          : 26.08.2016
* Request       :
* I/E-number    : OTS-180411
* Reference     : PADYA28082016
* Description   : Country Chile shouldn't populate with decimal points in
*               : currency in Segment field E1BPEXTC-FIELD2
*&---------------------------------------------------------------------&*
*&---------------------------------------------------------------------&*
* Author        : Murali
* Date          : 25.05.2017
* Request       :
* I/E-number    :DMSRRT-99
* Reference     : Murali250517
* Description   : The Commercial Invoice printed for sofybundle orders having
*               : zero value in Segment field E1BPEXTC-FIELD2
*&---------------------------------------------------------------------&*
*&---------------------------------------------------------------------&*
* Author        : Elizabeth Thomas
* Date          : 09.10.2017
* I/E-number    : OTS-275763
* Reference     : OTS-275763
* Description   : Norway and South Africa commercial invoices not
*                 passing correct values to Moduslink.
*                 Also provive EUR and country currency for Norway and Switz
*&---------------------------------------------------------------------&*
* Author        : Elizabeth Thomas
* Date          : 28.06.2019
* Story         : SAPA-2945
* Description   : Prices being shown incorrectly on the commercial
*                 invoice for india
*&---------------------------------------------------------------------&*
* Author        : Elizabeth Thomas
* Date          : 22.10.2020
* Story         : SAPA-4985
* Description   : Additional checks in web order duplicate orders
*&---------------------------------------------------------------------&*
* Author        : Aashana Yadav
* Date          : 01.03.2022
* Story         : SAPA-7786
* Reference     : YADAVAAS
* Description   : S4 HANA Custom Code adaptation. Changed the type
*                 declaration from VBTYP to VBTYPL and added
*                 a pseudo code comment.
*&---------------------------------------------------------------------&*
*&---------------------------------------------------------------------&*
* Author        : Aashana Yadav                                       *
* Date          : 20-04-2023                                          *
* Reference     : YADAVAAS/ITSD 114636                                *
* Version FD/TD :                                                     *
* Description   : For CH15 to NL15 shift, the VAT registration number *
*                 be picked up from T001N based on land as CH and     *
*                 company code NL15                                   *
*---------------------------------------------------------------------*


*-----------------------------------------------------------------------*
*&-----------------Type Declarations-----------------------------------&*
*-----------------------------------------------------------------------*
** type declaration for Organizational Unit: Sales Organizations
  TYPES: BEGIN OF lt_tvko,
           adrnr TYPE    tvko-adrnr,                             " Address
           kunnr TYPE    tvko-kunnr,                             " Customer number for intercompany billing
         END OF lt_tvko.

** type declaration sales document header.
  TYPES : BEGIN OF lt_vbak,
            vbeln TYPE     vbeln_va,                            " Sales Document
            auart TYPE     auart,                               " Sales Document Type
            autlf TYPE     autlf,                               " Complete delivery defined for each sales order
          END OF lt_vbak.
** type for on  Sales Document
  TYPES : BEGIN OF lt_vbkd,
            vbeln TYPE     vbkd-vbeln,                           " Sales and Distribution Document Number
            zterm TYPE     vbkd-zterm,                           " Terms of Payment Key
          END OF lt_vbkd .

*** Type Declaration For Delivery Numbers
  TYPES: BEGIN OF lt_deliv,
           vbelv TYPE vbeln_von,                                 " Preceding sales and distribution document
         END OF lt_deliv.

** type declaration for item data.
  TYPES:BEGIN OF lt_vbap,
          posnr  TYPE posnr_va,                                      " Sales Document Item
          netwr  TYPE netwr,                                         " Net value.
          kwmeng TYPE kwmeng,
          waerk  TYPE waerk,
          werks  TYPE werks,
          wavwr  TYPE wavwr,
          kzwi3  TYPE kzwi3,                                         " AM 20.05.2016 OTS-99813
        END OF lt_vbap.
*-----------------------------------------------------------------------*
*&-----------------Internal Table Declarations-------------------------&*
*-----------------------------------------------------------------------*
  DATA : li_vbak TYPE STANDARD TABLE OF lt_vbak INITIAL SIZE 0,    " Internal table for vbak table
         li_vbkd TYPE STANDARD TABLE OF lt_vbkd INITIAL SIZE 0,    " Internal table for vbkd table
         li_vbap TYPE STANDARD TABLE OF lt_vbap.                   " Internal table for vbap table.
*-----------------------------------------------------------------------*
*&-----------------Work Area Declarations------------------------------&*
*-----------------------------------------------------------------------*
  DATA: lwa_vbfa  TYPE LINE OF  shp_vl10_vbfa_t,                 " Work area for document flow
        lwa_vbkd  TYPE lt_vbkd,                                  " Work area for vbkd table
        lwa_vbak  TYPE lt_vbak,                                  " Work area for vbak table
        lwa_likp  TYPE likpvb,                                   " Work area for Delivery header data
        lwa_lips  TYPE shp_lips_t,
        lwa_lips1 TYPE lipsvb,
        lwa_tvko  TYPE lt_tvko,                                  " Work area for tvko table
        lwa_vbpa  TYPE LINE OF vbpa_tab,                         " Work area for partner data
        lwa_vbadr TYPE sadrvb.                                   " Work area for partner address data
  DATA: lv_vbeln     TYPE vbeln_vl,
        lv_netwr     TYPE netwr,
        lv_netwr1    TYPE char21,
        lv_posnr     TYPE posnr_va,
        lwa_lwa_likp TYPE likpvb,
        lv_vbelv     TYPE vbeln_von,
        lwa_vbap     TYPE lt_vbap.
  DATA: lv_amount  TYPE netwr,
        lv_amount1 TYPE netwr.
  DATA :lv_lfimg     TYPE lfimg,
        lv_waerk     TYPE waerk,
        lv_kwmeng    TYPE kwmeng,
        lv_kvgr2     TYPE kvgr2,
        lv_count     TYPE num4  VALUE 1,
        lv_billfrom  TYPE vkorg,
        lv_ihrez     TYPE ihrez,                                    " Your Reference
        lv_kunwe_ext TYPE edi_expnr,                                    " External number for ship-to code RH20101112
        lv_kunag_ext TYPE edi_expnr,                                  " Internal number for sold-to code RH20101112
        lv_uepos     TYPE posnr,                                    "higher level item
        lv_tmpos     TYPE posnr.


*-----------------------------------------------------------------------*
*&-----------------Variable Declarations-------------------------------&*
*-----------------------------------------------------------------------*
  DATA: ls_bapiext             TYPE bapiext,                       " Used for BAPI Extention2
        ls_bapiext1            TYPE bapiextc,                      " used for  bapi extenion1.BAPIEXTC
        lv_stceg               TYPE stceg,                         " Used for VAT number
        lv_kunnr               TYPE kunnr,                         " Used for Customer number
        lv_zterm               TYPE zterm,                         " Used for Payment terms
        lv_vkorg               TYPE vkorg,                         " Used for Sales orgn
        lv_vtweg               TYPE vtweg,                         " used for distribution channel " added by murali
        lv_vkoiv               TYPE vkoiv,                         " Used for Intercompany sales org.         RHO20090407
        lv_werks               TYPE werks_d,                       " Used for Plant                           RHO20090407
        lv_delslot             TYPE vbtypl VALUE 'N',               " Used for Partner role indc. "#EC CI_USAGE_OK[2198647]
* YADAVAAS - S4 HANA Custom Code adaptation. Changed the type declaration from VBTYP to VBTYPL and added
* a pseudo code comment.
        lv_autlf               TYPE c,                             " Used for Delivery indicator
        lv_comp_vat_number(30) TYPE c,                             " Used for vat number
        lv_add(255)            TYPE c,                             " Used for Extension2 value
        lv_bukrs_so            TYPE bukrs,                         " Used for Company code Sales organization RHO20090407
        lv_land1_so            TYPE land1,                         " Used for Country sales organization      RHO20090407
        lv_land1_pl            TYPE land1,                         " Used for Country plant                   RHO20090407
        lv_vbeln1              TYPE vbeln_vl,
        lv_cur1                TYPE string,
        lv_cur2(5)             TYPE c,
        lv_currkey             TYPE sycurr.
*Start of change for SAPA-4985 by Elizabeth
  TYPES : BEGIN OF ty_vbeln,
            vbeln TYPE vbeln_va,
          END OF ty_vbeln,

          BEGIN OF ty_dlvry,
            vbeln TYPE vbeln_nach,
          END OF ty_dlvry,

          BEGIN OF ty_likp,
            vbeln TYPE vbeln_vl,
          END OF ty_likp.

  DATA : lv_bstnk TYPE bstnk,
         lt_vbeln TYPE STANDARD TABLE OF ty_vbeln,
         lt_dlvry TYPE STANDARD TABLE OF ty_dlvry,
         lt_likp  TYPE STANDARD TABLE OF ty_likp.
*end of change for SAPA-4985 by Elizabeth
*-----------------------------------------------------------------------*
*&----------------- Constant Declarations------------------------------&*
*-----------------------------------------------------------------------*
  DATA : c_y     TYPE c VALUE 'Y',
         c_n     TYPE c VALUE 'N',
         c_we(2) TYPE c VALUE 'WE'.

*** Clearing variables.
  CLEAR : lwa_likp, lwa_vbfa.

*** Assigning Global structure is_likp to local work area.
  MOVE is_likp TO lwa_likp.

*** Get first record from internal table it_vbfa.
  READ TABLE it_vbfa INTO lwa_vbfa INDEX 1 .

**capturing the sales order.
  MOVE lwa_vbfa-vbelv TO lv_vbelv.
  MOVE lwa_vbfa-vbeln TO lv_vbeln.

*** Getting data of sales order and Delivery indicator
  IF NOT lwa_vbfa IS INITIAL.
    SELECT SINGLE vbeln auart autlf
             FROM vbak INTO lwa_vbak
             WHERE vbeln = lwa_vbfa-vbelv.

    SELECT SINGLE vtweg INTO lv_vtweg FROM vbak WHERE vbeln = lwa_vbfa-vbelv.

    CALL FUNCTION 'CONVERSION_EXIT_AUART_OUTPUT'
      EXPORTING
        input  = lwa_vbak-auart
      IMPORTING
        output = lwa_vbak-auart.

  ENDIF.
*  comented by murali
**Start of change for SAPA-4985 by Elizabeth
*  IF lwa_vbak-auart = 'ZWEB'.
*    CLEAR : lv_bstnk.
*    REFRESH : lt_vbeln[],lt_dlvry[],lt_likp[].
**Get customer purchase order
*    SELECT SINGLE bstnk
*             FROM vbak
*             INTO lv_bstnk
*             WHERE vbeln = lwa_vbfa-vbelv.
*    IF sy-subrc = 0.
**get all the order for a particular customer PO
*      SELECT vbeln
*        FROM vbak
*        INTO TABLE lt_vbeln
*        WHERE bstnk = lv_bstnk.
*      IF sy-subrc = 0.
**Get all the delivery for the PO
*        SELECT vbeln
*          INTO TABLE lt_dlvry
*          FROM vbfa
*          FOR ALL ENTRIES IN lt_vbeln
*          WHERE vbelv = lt_vbeln-vbeln AND
*          vbtyp_n = 'J' .
*        IF sy-subrc = 0.
**Check if there is a delivery which was sent to 3PL already
*          SELECT vbeln
*            FROM likp
*            INTO TABLE lt_likp
*            FOR ALL ENTRIES IN lt_dlvry
*            WHERE vbeln = lt_dlvry-vbeln AND
*                 ( vlstk = 'B' OR "Delivery distributed
*                   vlstk = 'C' ). "Delivery confirmed
*          IF sy-subrc = 0.
*            MESSAGE e001(00) WITH 'Delivery already sent for this PO to 3PL'.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*  ENDIF.
**End of change for SAPA-4985 by Elizabeth
*end by murali
  IF NOT lwa_vbak IS INITIAL.
*** Getting payment term
    SELECT SINGLE  zterm
           FROM vbkd
           INTO  lv_zterm
           WHERE vbeln = lwa_vbak-vbeln.
  ENDIF.

*** Get Customer number
  READ TABLE it_vbpa INTO lwa_vbpa WITH KEY vbeln = lwa_likp-vbeln.

  IF NOT lwa_vbpa IS INITIAL.
*** Getting partner information
    IF sy-subrc = 0 .
      IF lwa_vbpa-parvw = c_we.
        SELECT SINGLE kunnr FROM knva INTO lv_kunnr
                    WHERE kunnr = lwa_vbpa-kunnr.
        IF sy-subrc = 0.
          lv_delslot = c_y.
        ELSE.
          lv_delslot = c_n.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  MOVE is_likp-vkorg TO lv_vkorg.

  MOVE is_likp-vkoiv TO lv_vkoiv.                             "RHO20090407

  CLEAR : lv_stceg, lwa_tvko.

*** Added by Ron Hogeboom for support Bill-From party                  RHO20090407
** logic for fetching the data from sales item data.
*  SELECT posnr netwr kwmeng waerk werks wavwr INTO TABLE li_vbap FROM vbap WHERE vbeln = lv_vbelv. "RHO20090407
  IF it_vbfa IS NOT INITIAL.
    SELECT posnr netwr kwmeng waerk werks wavwr kzwi3 INTO TABLE li_vbap FROM vbap
                                                                   FOR ALL ENTRIES IN it_vbfa
                                                                   WHERE vbeln = it_vbfa-vbelv. "PADYA20130513
  ELSE.
    SELECT posnr netwr kwmeng waerk werks wavwr kzwi3 INTO TABLE li_vbap FROM vbap WHERE vbeln = lv_vbelv. "PADYA20130513
  ENDIF.


  READ TABLE li_vbap INTO lwa_vbap INDEX 1.
  READ TABLE it_lips INTO lwa_lips1 INDEX 1.
*** Collect country sales organization and plant
*     MOVE: lwa_vbap-werks TO lv_werks.                                          "RHO20090407
  MOVE: lwa_lips1-werks TO lv_werks.                                         "RHO20091022

  IF lv_werks IS NOT INITIAL.
    SELECT SINGLE land1 FROM t001w INTO lv_land1_pl
    WHERE werks = lv_werks.
  ENDIF.

  IF lv_vkorg IS NOT INITIAL.
    SELECT SINGLE bukrs FROM tvko INTO lv_bukrs_so
    WHERE vkorg = lv_vkorg.
  ENDIF.

  IF lv_bukrs_so IS NOT INITIAL.
    SELECT SINGLE land1 FROM t001 INTO lv_land1_so
    WHERE bukrs = lv_bukrs_so.
  ENDIF.

  CLEAR: lwa_vbap, lwa_lips1.

  IF NOT lv_vkorg IS INITIAL.
***  Getting customer number and address
    SELECT SINGLE
        adrnr kunnr
        FROM tvko
        INTO  lwa_tvko
        WHERE vkorg = lv_vkorg.
  ENDIF.

*** Added by Ron Hogeboom to use VAT number Bill-to party      RHO20090407
  IF lv_land1_so NE lv_land1_pl AND lv_vkorg NE 'TR15'.     "RHO20090407 exclude Turkey

    IF NOT lwa_tvko IS INITIAL.
***  Getting VAT number.
      SELECT SINGLE stceg FROM kna1 INTO lv_stceg
          WHERE kunnr = lwa_tvko-kunnr.
    ENDIF.
  ELSE.
***  Getting VAT number.
    SELECT SINGLE stceg FROM kna1 INTO lv_stceg
        WHERE kunnr = is_likp-kunnr.
  ENDIF.

*  ITSD 114636 - CH15 to NL15 shift.
  DATA : ls_vbpa  LIKE LINE OF it_vbpa,
         lv_butxt TYPE butxt.
  CLEAR : ls_vbpa,
          lv_butxt.
  READ TABLE it_vbpa INTO ls_vbpa WITH KEY parvw = 'AG' .
  IF sy-subrc EQ 0.
    IF ls_vbpa-land1 = 'CH'.
      SELECT SINGLE butxt FROM t001n
        INTO lv_butxt
        WHERE bukrs = 'NL15'
        AND land1 = 'CH'.
      IF sy-subrc EQ '0'.
        lv_stceg = lv_butxt.
      ENDIF.
    ENDIF.
  ENDIF.
* YADAVAAS--

  CLEAR lwa_vbadr.
  CLEAR ls_bapiext.
  READ TABLE it_vbadr INDEX 1 INTO lwa_vbadr .
*** Preparing data for BAPI- Extension2.
  IF NOT lwa_vbadr IS INITIAL.
    MOVE: lv_zterm           TO lv_add+0(4) ,
          lwa_vbak-autlf     TO lv_add+5(1),
          lv_delslot         TO lv_add+7(1),
          lwa_vbadr-name1    TO lv_add+9(35),
          lwa_vbadr-stras    TO lv_add+45(35),
          lwa_vbadr-pstlz    TO lv_add+81(10),
          lwa_vbadr-ort01    TO lv_add+92(20),
          lwa_vbadr-land1    TO lv_add+112(3),
          lv_stceg           TO lv_comp_vat_number,
          lv_comp_vat_number TO lv_add+116(20).
*** Populate the  idoc segment
    ls_bapiext-param =   'ADD'.
    ls_bapiext-field =  'ADDITIONAL_FIELD'.
    ls_bapiext-value =   lv_add.
    APPEND ls_bapiext TO et_extension2.
  ENDIF.
  CLEAR ls_bapiext1.


  SORT li_vbap BY posnr. "MMEMBA20080828i

*Looped Delivery data instead of sales data and checked them based on Item No value
  LOOP AT it_lips INTO lwa_lips1 WHERE vbeln = is_likp-vbeln. "RH20090107

*  added by Murali
    AT NEW vbeln.

      CLEAR : lv_tmpos.

    ENDAT.

*    end of changes

*   IF lwa_lips1-pstyv = 'NLN' AND lwa_lips1-vgtyp = 'V'. "EM12072010
    IF ( ( lwa_lips1-pstyv = 'NLN' OR lwa_lips1-pstyv = 'ZNLN' OR lwa_lips1-pstyv = 'RLN' ) AND lwa_lips1-vgtyp = 'V') OR ( lwa_lips1-pstyv = 'LBN' ) . "RH20130320

      MOVE: lwa_lips1-posnr TO lv_posnr,
            lwa_lips1-kvgr2 TO lv_kvgr2,
            0  TO lv_netwr1,
            'EUR' TO lv_waerk,
            1 TO lv_kwmeng.

      ls_bapiext1-field1 = lv_posnr.
      ls_bapiext1-field2 = lv_netwr1.
      ls_bapiext1-field3 = lv_waerk.
      ls_bapiext1-field4 = lv_kvgr2.
      SELECT SINGLE currkey FROM ztcurx                               " Begin of PADYA28082016
                            INTO lv_currkey
                            WHERE currkey = lv_waerk.
      IF sy-subrc EQ 0.
        SPLIT ls_bapiext1-field2 AT '.' INTO lv_cur1 lv_cur2.
        CONCATENATE lv_cur1 lv_cur2 INTO ls_bapiext1-field2.
      ENDIF.                                                          " End of  PADYA28082016

      APPEND ls_bapiext1 TO et_extension1.

    ELSE.

      READ TABLE li_vbap INTO lwa_vbap WITH KEY posnr = lwa_lips1-vgpos. "MMEMBA20080828i



      IF sy-subrc EQ 0.                                                  "RHO20080918
        MOVE: lwa_lips1-lfimg   TO lv_lfimg.
        MOVE: lwa_lips1-kvgr2   TO lv_kvgr2.
*    Needs to Passs value of POSNR from Delivery table instead of Sales Item table

        MOVE: lwa_lips1-posnr TO lv_posnr,      "MMEMBA20080828i
              lwa_vbap-kwmeng TO lv_kwmeng,
              lwa_vbap-waerk  TO lv_waerk.
*Start of SAPA-2945 By Elizabeth
* Add external ship-to party number to delivery interface
        READ TABLE it_vbpa INTO lwa_vbpa WITH KEY parvw = 'WE'.
*End of SAPA-2945 By Elizabeth
*** Added by Ron Hogeboom for support Bill-From party                  RHO20090407
* Use customer value or intercompany value depending on country
*IF ( lv_land1_so NE lv_land1_pl and lv_vkorg NE 'TR15' ) "RHO20090407 exclude Turkey
*Along with Turkey TR15, CH15 and NO15 also needs to be skipped for Commercial Invoices  PADYA20150728
*For all EU countries the inter company value should be picked up for for all other countries Net value in the order needs to be picked. OTS-275763 by Elizabeth
        IF ( lv_land1_so NE lv_land1_pl AND lv_vkorg NE 'TR15') AND "Changed from or to and for skipping the logic for NO,TR and CH OTS-275763 by Elizabeth
           ( lv_land1_so NE lv_land1_pl AND lv_vkorg NE 'CH15') AND "Changed from or to and for skipping the logic NO,TR and CH OTS-275763 by Elizabeth
           ( lv_land1_so NE lv_land1_pl AND lv_vkorg NE 'ZA15') AND "Need to skip south africa as well OTS-275763 by Elizabeth
           ( lv_land1_so NE lv_land1_pl AND lv_vkorg NE 'NO15') OR
           ( lv_land1_so EQ lv_land1_pl AND lv_vkorg EQ 'NL15').
          MOVE lwa_vbap-wavwr  TO lv_netwr. "Interconpany price
*Start of SAPA-2945 By Elizabeth
          IF lwa_vbpa-land1 = 'IN' .
            MOVE lwa_vbap-netwr  TO lv_netwr.  "Net price
          ELSE.
            MOVE lwa_vbap-wavwr  TO lv_netwr. "Interconpany price
          ENDIF.
*End of SAPA-2945 By Elizabeth
*
*        ELSEIF ( lv_land1_so EQ 'NL' and lv_vtweg EQ '06' ). "For NL it should pick intercompany OTS-275763 by Elizabeth
*
*          MOVE lwa_vbap-netwr  TO lv_netwr.  "Net price

        ELSE.

          MOVE lwa_vbap-netwr  TO lv_netwr.  "Net price
          IF lwa_vbak-auart = 'FD'."Free of charge
            MOVE lwa_vbap-wavwr  TO lv_netwr. "Interconpany price
          ENDIF.
        ENDIF.
* commented by muralic on 060723 for s4 clean up as this is not needed i.e. telematics logic
** For Telematics DIrect Sales, COntract value from the Sales Order should be used on the commercial Invoice.
*        IF lwa_lips1-pstyv EQ 'ZTDO' OR lwa_lips1-pstyv EQ 'ZTDR'.                            "AM 20.05.2016
*          MOVE lwa_vbap-kzwi3 TO lv_netwr.
*        ENDIF.
**Ended by muralic 060723
* For web softbundles,  the top kit value shall be sent with the first line item "Murali250517
        IF lwa_lips1-pstyv EQ 'ZTAP'.

          SELECT SINGLE uepos INTO lv_uepos FROM vbap WHERE vbeln = lwa_lips1-vgbel
                                                        AND posnr = lwa_lips1-vgpos.

          IF lv_uepos IS NOT INITIAL AND lv_uepos NE lv_tmpos.

            lv_tmpos = lv_uepos.

            IF lwa_vbak-auart = 'ZWEB'.

              SELECT SINGLE netwr FROM vbap INTO lv_netwr WHERE vbeln = lwa_lips1-vgbel
                                                            AND posnr = lv_uepos.
* commented by muralic on 060723 for s4 clean up as this is not needed
*            ELSEIF lwa_vbak-auart = 'ZRPP'.
*
*              SELECT SINGLE wavwr FROM vbap INTO lv_netwr WHERE vbeln = lwa_lips1-vgbel
*                                                           AND posnr = lv_uepos.
*ended by muralic on 060723 for s4 clean up as this is not needed

            ENDIF.
          ENDIF.


        ENDIF.


* end of chnages by Murali250517



** logic for amount
        lv_amount   = ( lv_netwr * 10000 ) / lv_kwmeng.
        lv_amount1  = ( lv_amount * lv_lfimg ) / 10000.
        MOVE lv_amount1  TO lv_netwr1.

** populate the idoc segment.
        ls_bapiext1-field1 = lv_posnr.
        ls_bapiext1-field2 = lv_netwr1.
        ls_bapiext1-field3 = lv_waerk.
        ls_bapiext1-field4 = lv_kvgr2.
        SELECT SINGLE currkey FROM ztcurx                             " Begin of PADYA28082016
                                   INTO lv_currkey
                                   WHERE currkey = lv_waerk.
        IF sy-subrc EQ 0.
          SPLIT ls_bapiext1-field2 AT '.' INTO lv_cur1 lv_cur2.
          CONCATENATE lv_cur1 lv_cur2 INTO ls_bapiext1-field2.
        ENDIF.

        APPEND ls_bapiext1 TO et_extension1.                          " End of PADYA28082016
*Start of change for OTS-275763 by Elizabeth
*        DATA : lv_amt_eur      TYPE netwr,
*               lv_amt_eur_char TYPE char21.
*        IF lv_vkorg = 'NO15' OR "Norway
*           lv_vkorg = 'CH15'.   "Switz
*          CALL FUNCTION 'CONVERT_TO_FOREIGN_CURRENCY'
*            EXPORTING
*              date             = sy-datum
*              foreign_currency = 'EUR'
*              local_amount     = lv_netwr1
*              local_currency   = lv_waerk
*            IMPORTING
*              foreign_amount   = lv_amt_eur.
*          lv_amt_eur_char = lv_amt_eur.
*          ls_bapiext1-field2 = lv_amt_eur_char.
*          ls_bapiext1-field3 = 'EUR'.
*          APPEND ls_bapiext1 TO et_extension1.
*        ENDIF.
*End of change for OTS-275763 by Elizabeth
      ENDIF.                                                             "RHO20080918
    ENDIF.

    CLEAR: lwa_lips1, lwa_vbap, lv_uepos.

  ENDLOOP.

* Added by ampradha on 16.10.2008
  READ TABLE it_lips INTO lwa_lips1 INDEX 1.
  IF sy-subrc EQ 0.
    IF lwa_lips1-pstyv = 'NLN' AND lwa_lips1-vgtyp = 'V'.
      SELECT SINGLE ihrez INTO lv_ihrez FROM ekko
        WHERE ebeln = lwa_lips1-vgbel.
      IF lv_ihrez IS NOT INITIAL.
*       Populate the  idoc segment
        ls_bapiext-param = 'ADD'.
        ls_bapiext-field = 'IHREZ'.
        ls_bapiext-value = lv_ihrez.
        APPEND ls_bapiext TO et_extension2.

      ENDIF.
    ENDIF.
  ENDIF.
* End of addition

*** Added for support Bill-From party                                    RHO20090407
  IF lv_land1_so NE lv_land1_pl.
    ls_bapiext-param = 'ADD'.
    ls_bapiext-field = 'BILLFROM'.
    ls_bapiext-value = lv_vkoiv.
    APPEND ls_bapiext TO et_extension2.
  ELSE.
    ls_bapiext-param = 'ADD'.
    ls_bapiext-field = 'BILLFROM'.
    ls_bapiext-value = lv_vkorg.
    APPEND ls_bapiext TO et_extension2.
  ENDIF.
*** End addition                                                          RHO20090407


*** Added for support translation internal SAP number to customer numbers RHO20100202

* Add external sold-to party number to delivery interface
  READ TABLE it_vbpa INTO lwa_vbpa WITH KEY parvw = 'AG'.

* If found
  IF sy-subrc = 0.
* Check EDPAR table if entry can be found for Sold-to party
    SELECT SINGLE expnr FROM edpar INTO lv_kunag_ext WHERE kunnr = lwa_vbpa-kunnr
                                 AND   parvw = 'AG'
                                 AND   inpnr = lwa_vbpa-kunnr.
* Use standard sold-to code if not found
    IF sy-subrc NE 0.
      lv_kunag_ext = lwa_vbpa-kunnr.
    ENDIF.
* Add segment for external sold-to party number
    ls_bapiext-param = 'ADD'.
    ls_bapiext-field = 'SOLDTO_EXT'.
    ls_bapiext-value = lv_kunag_ext.
    APPEND ls_bapiext TO et_extension2.

  ENDIF.

* Add external ship-to party number to delivery interface
  READ TABLE it_vbpa INTO lwa_vbpa WITH KEY parvw = 'WE'.

* If found
  IF sy-subrc = 0.
* Check EDPAR table if entry can be found for Ship-to party
    SELECT SINGLE expnr FROM edpar INTO lv_kunwe_ext WHERE kunnr = lwa_vbpa-kunnr
                                 AND   parvw = 'WE'
                                 AND   inpnr = lwa_vbpa-kunnr.
* Use standard ship-to code if not found
    IF sy-subrc NE 0.
      lv_kunwe_ext = lwa_vbpa-kunnr.
    ENDIF.
* Add segment for external ship-to party number
    ls_bapiext-param = 'ADD'.
    ls_bapiext-field = 'SHIPTO_EXT'.
    ls_bapiext-value = lv_kunwe_ext.
    APPEND ls_bapiext TO et_extension2.
  ENDIF.

** clearing the workarea and  varibale.
  CLEAR: ls_bapiext1,ls_bapiext,lv_posnr,lv_netwr1,lv_netwr,lwa_vbap, lwa_vbpa.

  CLEAR: lv_add, lv_zterm, lv_delslot, lwa_vbadr,
         lv_comp_vat_number,lv_stceg,lv_delslot,
         lv_vkorg, lv_vkoiv, lv_werks, lv_land1_so, lv_land1_pl, lv_bukrs_so, lwa_vbpa, lv_ihrez, lv_billfrom, lv_kunwe_ext, lv_kunag_ext.


ENDMETHOD.


method IF_EX_SMOD_V50B0001~EXIT_SAPLV50K_008.
endmethod.


method IF_EX_SMOD_V50B0001~EXIT_SAPLV50K_011.





endmethod.


method IF_EX_SMOD_V50B0001~EXIT_SAPLV50K_012.
endmethod.


method IF_EX_SMOD_V50B0001~EXIT_SAPLV50K_013.
endmethod.
ENDCLASS.
