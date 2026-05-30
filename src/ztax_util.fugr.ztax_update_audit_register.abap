FUNCTION ztax_update_audit_register.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(CVBRK) LIKE  VBRK STRUCTURE  VBRK
*"     REFERENCE(XACCIT) LIKE  ACCIT STRUCTURE  ACCIT
*"     REFERENCE(DOC_NUMBER) LIKE  VBRK-VBELN
*"  TABLES
*"      CVBRP STRUCTURE  VBRPVB OPTIONAL
*"      CKOMV STRUCTURE  KOMV OPTIONAL
*"  EXCEPTIONS
*"      ERROR_CALLING_AVALARA
*"----------------------------------------------------------------------
** DMA Inc. / Dietmar Hinz / 06/08/2016
** Update Avalara audit DB for transactions that contain a tax amount
** that is calculated in an external system (Babylon, Web Credits, Intershop)
*&----------------------------------------------------------------------*
* Author        : Aashana Yadav                                                 *
* Date          : 11.04.2022                                                    *
* Reference     : YADAVAAS/ SAPA 6897                                           *
* Description   : Pass the material description to AVALARA                      *
*********************************************************************************
  IF ( cvbrk-kalsm = 'ZWEBUS' AND
     ( cvbrk-fkart = 'ZWEB' OR
       cvbrk-fkart = 'G2' OR          "OTS-268255 Add credit and debit invoices babylon
       cvbrk-fkart = 'L2' OR
       cvbrk-fkart = 'ZWS1'
* YADAVAAS++
* OTS: SAP 764 - During the month close the user have found out that we are missing
* some credit invoices for Webfleet in Avalara. The reason is that they have started to use
* credits directly in Babylon (before it was done in SAP only) and those credits are being
* processed in SAP with a different invoice type.
      OR cvbrk-fkart = 'ZWCR'
* YADAVAAS--
  ) ) OR    "Babylon
   ( cvbrk-kalsm = 'ZWNWUS' AND
     ( cvbrk-fkart = 'ZWCR' OR
       cvbrk-fkart = 'ZWS1' OR        "OTS-268255 Add cancellation
       cvbrk-fkart = 'ZWS2' ) ) OR    "Web Credits
   ( cvbrk-kalsm = 'ZWNWUS' AND
     cvbrk-fkart = 'ZWEB' ).          "Intershop
***Populate Control structure
    SELECT SINGLE kalsm INTO t005-kalsm FROM t005
           WHERE land1 = cvbrk-landtx.

    CLEAR ttxd.
    SELECT SINGLE *
           FROM ttxd
           WHERE kalsm = t005-kalsm.

    i_sap_control_data-app_server = sy-host.
    i_sap_control_data-sap_version = sy-saprl.
    i_sap_control_data-interf_version = ttxd-intversion.
***Populate Header structure
    i_tax_frc_head_in-syst_name = sy-sysid.
    i_tax_frc_head_in-client = cvbrk-mandt.
    i_tax_frc_head_in-comp_code = cvbrk-bukrs.
    i_tax_frc_head_in-doc_number = cvbrk-vbeln.
    i_tax_frc_head_in-currency = cvbrk-waerk.
    i_tax_frc_head_in-curr_dec = '002'.
    i_tax_frc_head_in-txjcd_l1 = ttxd-leng1.
    i_tax_frc_head_in-txjcd_l2 = ttxd-leng2.
    i_tax_frc_head_in-txjcd_l3 = ttxd-leng3.
    i_tax_frc_head_in-txjcd_l4 = ttxd-leng4.
    i_tax_frc_head_in-tax_per_item = ttxd-xtxit.
***Populate item stucture
    CLEAR lin.
    REFRESH: i_tax_frc_item_in, i_tax_frc_jur_level_in.
*    loop at cvbrp where vbeln(1) = '$'.
    LOOP AT cvbrp WHERE vbeln = doc_number OR
                        vbeln = cvbrk-vbeln.
      lin = lin + 1.
      CLEAR i_tax_frc_item_in.
      i_tax_frc_item_in-item_no = sy-tabix.
      i_tax_frc_item_in-pos_no = cvbrp-posnr.
      i_tax_frc_item_in-country = cvbrk-landtx.
      i_tax_frc_item_in-division = cvbrp-werks.
      i_tax_frc_item_in-matnr = cvbrp-matnr. "#EC CI_FLDEXT_OK[2215424]
*BISATI-Added Pseudo Code Comment for S4 HANA Custom Code Adaptation
      SELECT SINGLE maktx FROM makt " SAPA 6987 - Material Desc for AVALARA
        INTO i_tax_frc_item_in-zflexfield1
        WHERE matnr = cvbrp-matnr AND spras = sy-langu.
******
      CLEAR mtart.
      SELECT SINGLE mtart INTO mtart
             FROM mara
             WHERE matnr = cvbrp-matnr.
      SELECT SINGLE xprcd INTO i_tax_frc_item_in-prod_code
             FROM ztax_map
             WHERE mtart = mtart AND
                   zprdha = cvbrp-prodh(8).

      WRITE cvbrp-lmeng TO i_tax_frc_item_in-quantity
            USING EDIT MASK '_______________'.
      SHIFT i_tax_frc_item_in-quantity RIGHT DELETING TRAILING space.
      SHIFT i_tax_frc_item_in-quantity RIGHT BY 3 PLACES.
      SHIFT i_tax_frc_item_in-quantity LEFT DELETING  LEADING space.
      i_tax_frc_item_in-unit = cvbrp-vrkme.
      i_tax_frc_item_in-apar_ind = 'A'.
      i_tax_frc_item_in-tax_type = '0'.
*      I_TAX_FRC_ITEM_IN-TAX_DATE = cvbrp-fbuda.
      i_tax_frc_item_in-tax_date = cvbrk-fkdat.
      tax_base = cvbrp-kzwi2.
      WRITE tax_base TO i_tax_frc_item_in-amount
            USING EDIT MASK '_______________'.
      i_tax_frc_item_in-gross_amount = i_tax_frc_item_in-amount.
*      I_TAX_FRC_ITEM_IN-rep_date = cvbrp-fbuda.
      i_tax_frc_item_in-rep_date = cvbrk-fkdat.
      IF cvbrk-vbtyp = 'N' OR  "Invoice Cancelation
         cvbrk-vbtyp = 'O'.    "Credit Note
        i_tax_frc_item_in-credit_ind = '1'.
        IF tax_base < 0.
          CLEAR i_tax_frc_item_in-credit_ind.
        ENDIF.
      ELSE.
        IF tax_base < 0.
          i_tax_frc_item_in-credit_ind = '1'.
        ENDIF.
      ENDIF.
      i_tax_frc_item_in-accnt_no = cvbrk-kunag.
      i_tax_frc_item_in-txjcd_st = cvbrp-txjcd.
      IF cvbrp-lland_auft NE 'US' AND
         cvbrp-lland_auft NE 'CA'.
        i_tax_frc_item_in-txjcd_st = 'US00000000000'.
      ENDIF.
      SELECT SINGLE txjcd INTO i_tax_frc_item_in-txjcd_sf
             FROM t001w
             WHERE werks = cvbrp-werks.
      i_tax_frc_item_in-txjcd_poo = i_tax_frc_item_in-txjcd_sf.
      i_tax_frc_item_in-txjcd_poa = i_tax_frc_item_in-txjcd_sf.

      REFRESH jur_level.
      PERFORM calculate_jur_level TABLES jur_level
                                  USING i_tax_frc_head_in
                                        i_tax_frc_item_in
                                        i_sap_control_data
                                        ttxd-rfcdest
                                        cvbrp-mwsbp.

      CLEAR: item_tax, item_jur_cnt.
      LOOP AT jur_level.
        CLEAR i_tax_frc_jur_level_in.
        item_tax = item_tax + jur_level-kbetr.
        item_jur_cnt = item_jur_cnt + 1.
********Populate item jurisdiction structure
        i_tax_frc_jur_level_in-item_no = i_tax_frc_item_in-item_no.
        i_tax_frc_jur_level_in-txjlv = jur_level-txjlv.
        WRITE jur_level-kbetr TO i_tax_frc_jur_level_in-taxamt
              USING EDIT MASK '_______________'.
        i_tax_frc_jur_level_in-taxbas = i_tax_frc_item_in-amount.
        IF jur_level-kbetr = 0.
          i_tax_frc_jur_level_in-examt = i_tax_frc_item_in-amount.
        ENDIF.
        APPEND i_tax_frc_jur_level_in.
      ENDLOOP.
      i_tax_frc_item_in-nr_jur_levels = item_jur_cnt.

      WRITE cvbrp-mwsbp TO i_tax_frc_item_in-taxamov
        USING EDIT MASK '_______________'.
* SAPA 6897 : AVATAX Changes - Comment code due to issue with double amounts for 0 tax
*      IF cvbrp-mwsbp = 0.
*        WRITE tax_base TO i_tax_frc_item_in-exempt_amt
*          USING EDIT MASK '_______________'.
*      ENDIF.
      i_tax_frc_item_in-accnt_no = cvbrk-kunag.
      APPEND i_tax_frc_item_in.
    ENDLOOP.
    i_tax_frc_head_in-nr_line_items = lin.
    IF NOT lin IS INITIAL.
***Update Avalara Audit DB
      CALL FUNCTION 'TRFC_SET_QUEUE_NAME'
        EXPORTING
          qname  = 'TIF_UPDATE_AUDIT_FILE'
        EXCEPTIONS
          OTHERS = 2.
*
      CALL FUNCTION 'RFC_FORCE_TAXES_DOC'
        IN BACKGROUND TASK
        DESTINATION ttxd-rfcdest
        EXPORTING
          i_sap_control_data     = i_sap_control_data
          i_tax_frc_head_in      = i_tax_frc_head_in
        TABLES
          i_tax_frc_item_in      = i_tax_frc_item_in
          i_tax_frc_jur_level_in = i_tax_frc_jur_level_in.
*
*     commit work.

    ENDIF.
  ENDIF.






ENDFUNCTION.
