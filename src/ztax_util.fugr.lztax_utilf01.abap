*----------------------------------------------------------------------*
***INCLUDE LZTAX_UTILF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CALCULATE_JUR_LEVEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_JUR_LEVEL  text
*      -->P_I_TAX_FRC_HEAD_IN  text
*      -->P_I_TAX_FRC_ITEM_IN  text
*      -->P_I_SAP_CONTROL_DATA  text
*      -->P_TTXD_RFCDEST  text
*      -->P_CVBRP_MWSBP  text
*----------------------------------------------------------------------*
FORM calculate_jur_level  TABLES   JUR_LEVEL STRUCTURE jur_level
                          USING    I_TAX_FRC_HEAD_IN
                                   I_TAX_FRC_ITEM_IN
                                   i_sap_control_data
                                   ttxd-rfcdest
                                   cvbrp-mwsbp.

  data: tax_cal_head_inxx type tax_cal_head_in00,
          tax_cal_item_inxx type standard table of
                            tax_cal_item_in00 initial size 0,
          tax_cal_item_in_rec type tax_cal_item_in00,

          tax_cal_item_outxx type standard table of
                             tax_cal_item_out00 initial size 0,
          tax_cal_item_out_rec type tax_cal_item_out00,

          tax_cal_jur_level_outxx type standard table of
                             tax_cal_jur_level_out00 initial size 0,
          tax_cal_jur_level_out_rec type tax_cal_jur_level_out00,

          cal_item_in_rec type tax_cal_item_in,
          cal_item_out_rec type tax_cal_item_out,
          cal_jur_level_out_rec type tax_cal_jur_level_out,
          o_ext_control_data type EXT_CONTROL_DATA,
          o_com_err_doc type COM_ERR_DOC,
          calc_tax like vbrp-mwsbp,
          tax_diff like vbrp-mwsbp.

  move-corresponding i_tax_frc_head_in to tax_cal_head_inxx.
  tax_cal_head_inxx-nr_line_items = 1.

  move-corresponding i_tax_frc_item_in to tax_cal_item_in_rec.
  append tax_cal_item_in_rec to tax_cal_item_inxx.


  call function 'RFC_CALCULATE_TAXES_DOC'
    destination ttxd-rfcdest
    EXPORTING
      i_sap_control_data      = i_sap_control_data
      i_tax_cal_head_in       = tax_cal_head_inxx
    IMPORTING
      o_ext_control_data      = o_ext_control_data
      o_com_err_doc           = o_com_err_doc
    TABLES
      i_tax_cal_item_in       = tax_cal_item_inxx
      o_tax_cal_item_out      = tax_cal_item_outxx
      o_tax_cal_jur_level_out = tax_cal_jur_level_outxx
    EXCEPTIONS
      communication_failure   = 01
      system_error            = 02.

  if sy-subrc ne 0.
    raise error_calling_avalara.
  endif.

  loop at tax_cal_item_outxx into tax_cal_item_out_rec.
    calc_tax = tax_cal_item_out_rec-taxamov.
    calc_tax = calc_tax / 100.
  endloop.

  if cvbrp-mwsbp = calc_tax.
    loop at tax_cal_jur_level_outxx into tax_cal_jur_level_out_rec.
      jur_level-txjlv = tax_cal_jur_level_out_rec-txjlv.
      jur_level-kbetr = tax_cal_jur_level_out_rec-taxamt.
      jur_level-kbetr = jur_level-kbetr / 100.
      append jur_level.
    endloop.
  else.
    loop at tax_cal_jur_level_outxx into tax_cal_jur_level_out_rec.
      jur_level-txjlv = tax_cal_jur_level_out_rec-txjlv.
      jur_level-kbetr = tax_cal_jur_level_out_rec-taxamt.
      jur_level-kbetr = jur_level-kbetr / 100.
      if calc_tax ne 0.
        jur_level-kbetr = cvbrp-mwsbp / calc_tax * jur_level-kbetr.
      else.
        jur_level-kbetr = 0.
      endif.
      append jur_level.
    endloop.
** Update log table with the difference amount
    ztax_difference-vbeln = tax_cal_head_inxx-doc_number.
    ztax_difference-posnr = tax_cal_item_in_rec-pos_no.
    ztax_difference-udate = sy-datum.
    ztax_difference-waerk = tax_cal_head_inxx-currency.
    ztax_difference-mwsbp = cvbrp-mwsbp.
    ztax_difference-avalara_tax_amt = calc_tax.
    ztax_difference-difference = cvbrp-mwsbp - calc_tax.
    insert ztax_difference.
    if sy-subrc ne 0.
      update ztax_difference.
    endif.
** Check for rounding differences. If one exists, adjust highest level of tax accordingly,
** so that we always post the externally calculated tax amount to the Avalara Audit file
    clear: calc_tax, tax_diff.
    loop at jur_level.
      calc_tax = calc_tax + jur_level-kbetr.
    endloop.
    if calc_tax ne cvbrp-mwsbp.
      tax_diff = cvbrp-mwsbp - calc_tax.
      loop at jur_level where kbetr ne 0.
        jur_level-kbetr = jur_level-kbetr + tax_diff.
        modify jur_level.
        exit.
      endloop.
    endif.
  endif.

ENDFORM.                    " calculate_jur_level
