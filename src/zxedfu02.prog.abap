*&---------------------------------------------------------------------*
*&  Include           ZXEDFU02
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* Author        : Sajid Ghulam                                         *
* Date          : 21-11-2007                                           *
* I/E-number    : I901                                                 *
* Version FD/TD : V1.0                                                 *
*----------------------------------------------------------------------*
* Description   :  This Include program populate the segment E1EDKA1   *
* OF IDOC INVOIC01 for partner goods recepient.                        *
*                  This Include program (Z_SD_IDOC_DELIV_I221) populate*
*                  the custom segment containing delivery details.     *
*                  INVOIC01 is extended with ZINVOIC to hold addiditional
*                  delivery related data.                              *
*----------------------------------------------------------------------*
* Author        : Ron Hogeboom                                         *
* Date          : 06-01-2011                                           *
* Request       :                                                      *
* I/E-number    : RHO20110106                                          *
* Reference     : SPS Commerce Project                                 *
* Version FD/TD :                                                      *
* Description   : Include tax condition type in segment to identify    *
*                 different tax types for Canada (PST / GST / HST)     *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Author        : Rajesh Padya                                         *
* Date          : 24-07-2014                                           *
* Request       :                                                      *
* I/E-number    : PADYA24072014                                        *
* Reference     : BRIM Distributor Order                               *
* Version FD/TD :                                                      *
* Description   : The new include will add the data into extended IDOC *
*               : INVOIC02 in order to map the data in SAP CRM system  *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Author        : Murali                                               *
* Date          : 10-03-2018                                           *
* Request       :                                                      *
* I/E-number    : SAPA-990                                             *
* Reference     : Amazon Direct invoice mapping                        *
* Version FD/TD :                                                      *
* Description   : The new include will add the original shipment info- *
*               : rmation in partner function WE in item segment E1EDPA1*
*----------------------------------------------------------------------*
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
* Author        : Ron HOgeboom                                         *
* Date          : 01-11-2018                                           *
* Request       :                                                      *
* I/E-number    :                                                      *
* Reference     : Subscription accounting to SAP BPC                   *
* Description   : In case of revenue breakdown and intercompany the    *
*                 wrong profitability segment is used. Therefore losing*
*                 valuable information such as parent SKU              *
*----------------------------------------------------------------------*
* Author        : Elizabeth Thomas                                     *
* Date          : 20-04-2021                                           *
* Story         : SAPA-5674                                            *
* Description   : BMW Invoice mapping changes                          *
*----------------------------------------------------------------------*
  TYPES : BEGIN OF ty_kunrg,
            kunrg TYPE char255,
          END OF ty_kunrg.
  DATA : lv_vbelv_bmw TYPE vbeln,
         lv_guebg     TYPE datum,
         lv_gueen     TYPE datum,
         ls_e1edk03   TYPE e1edk03,
         lt_kunrg     TYPE STANDARD TABLE OF ty_kunrg,
         ls_kunrg     TYPE ty_kunrg,
         lv_tabix     TYPE sy-tabix.
* Out Type ZSUB(CRM Distributor Order)
  IF control_record_out-cimtyp = 'Z2SUB'.
    INCLUDE z_brim_distorder_zsubcond.
  ENDIF.


  INCLUDE z_sd_idocinvoicei901 .


  INCLUDE z_sd_idocinvoicei220 .

* Add text of condition to tax element RHO20110106
  INCLUDE z_sd_idocinvoice_tax .

* next include to populate additional segment
* for Discount with discount code
  INCLUDE z_sd_idocinvoice_dfi .

* commented by saghulam and added another below includes
* To Populate Extra Custom Segment.
* Addd By Dibyajyoti Kanungo
  INCLUDE z_sd_idoc_deliv_i221.

*added by Murali on 100318 for amazon direct china shipment
  INCLUDE z_sd_amazon_direct_shipment.

*added for handling profitability segments on IC for revenue breakdown
  INCLUDE z_sd_idocinvoice_zrr.

*Start of change for SAPA-5674 by Elizabeth
  CLEAR lv_tabix.
  lv_tabix = sy-tabix.
  SELECT low
    FROM tvarvc
    INTO TABLE lt_kunrg
    WHERE name = 'Z_ZXEDFU02_KUNRG_BMW' AND
          type = 'S'.
  LOOP AT lt_kunrg INTO ls_kunrg.
    IF control_record_out-rcvprn = ls_kunrg-kunrg.
      CLEAR : lv_vbelv_bmw,lv_guebg,lv_gueen.
      IF xvbdkr-vbeln IS NOT INITIAL .
*Get order from invoice
        SELECT SINGLE vbelv
          INTO lv_vbelv_bmw
          FROM vbfa
          WHERE vbeln = xvbdkr-vbeln.
        IF lv_vbelv_bmw IS NOT INITIAL .
*Get start date and end date from order
          SELECT SINGLE guebg gueen
            INTO (lv_guebg, lv_gueen)
            FROM vbak
            WHERE vbeln = lv_vbelv_bmw.
        ENDIF.
*Populate the dates in IDOC
        CLEAR ls_e1edk03.
        IF  int_edidd-segnam = 'E1EDK03'.
          ls_e1edk03 = int_edidd-sdata.
          IF ls_e1edk03-iddat = '024'.
            ls_e1edk03-datum = lv_guebg.
          ENDIF.
          IF ls_e1edk03-iddat = '028'.
            ls_e1edk03-datum = lv_gueen.
          ENDIF.
          MOVE ls_e1edk03 TO int_edidd-sdata.
          sy-tabix = lv_tabix.
          MODIFY int_edidd INDEX sy-tabix.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.
*End of change for SAPA-5674 by Elizabeth
