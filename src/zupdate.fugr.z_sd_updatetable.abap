FUNCTION z_sd_updatetable .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  CHANGING
*"     REFERENCE(INTTAB) TYPE  ZZUPDATETT
*"----------------------------------------------------------------------


  CONSTANTS: c_vbeln TYPE char10 VALUE 'VBELN',        " Delivery number
             c_likp  TYPE char4 VALUE 'LIKP'.


  DATA:  lwa_zitab    TYPE   zzupdate,                 " Structure of type zzupdate used as workarea for updation
         lv_vbeln     TYPE   vbeln,                    " contains the PO Number
         lv_fieldname TYPE   fieldname,                " Field name
         lv_value     TYPE   char40,                   " value of field to be updated
         lv_date      TYPE   datum .                   " date field

  SORT inttab BY ztabname.
* Loop inttab to update the fields in it except first record that is vbeln
  LOOP AT inttab INTO lwa_zitab.
*        WHERE ztabname = c_likp.

    IF lwa_zitab-zfieldname = c_vbeln.
      lv_vbeln = lwa_zitab-zval_char.
      CONTINUE .
    ENDIF.

    IF lwa_zitab-zval_date IS INITIAL     .
      lv_fieldname = lwa_zitab-zfieldname .
      lv_value =     lwa_zitab-zval_char  .
    ELSE .
      lv_fieldname = lwa_zitab-zfieldname .
      lv_date =     lwa_zitab-zval_date  .
    ENDIF.

* call this form statement for every field update in likp table
    PERFORM update_likp USING lv_vbeln
                              lv_fieldname
                              lv_value
                              lv_date.

* Clear the workarea.
    CLEAR : lwa_zitab,
            lv_fieldname,
            lv_value,
            lv_date .


  ENDLOOP.
COMMIT WORK.                                   "RHO20110411 Check consequences
ENDFUNCTION.
