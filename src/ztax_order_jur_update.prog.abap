REPORT  ztax_order_jur_update.
*
* Created : Apr 2003
* Author  : Dietmar Hinz
* Purpose : Update Jurisdiction code for Avalara on open sales orders
*           which contain a manually overwritten delivery address.
************************************************************************
************************************************************************
* Author        : Aashana Yadav                                        *
* Date          : 04-01-2023                                           *
* Story         : SAPA-7796                                            *
* Description   : Select statement on VBUK table is replaced by a      *
*                 select on CDS view V_VBUK_CDS as a part of S4        *
*                 Readiness custom code adaptation.                    *
************************************************************************
TABLES: vbak, vbuv, tvko, *tvko, t001, tvkwz, t001w, tstl, adrc.

DATA:   BEGIN OF vbak_TAB OCCURS 0,
           vbeln LIKE vbak-vbeln,
           ORT01 LIKE KNA1-ORT01,
           ORT02 like kna1-ort02,
           PSTLZ LIKE KNA1-PSTLZ,
           REGIO LIKE KNA1-REGIO,
           LAND1 LIKE KNA1-LAND1,
           stras like kna1-stras,
           str_suppl1 like adrc-str_suppl1,
           pfach like adrc-po_box,
           txjcd like kna1-txjcd,
           adrnr like vbpa-adrnr,
        END OF VBAK_TAB.

DATA: validate_address_out TYPE TABLE OF zvalidate_address_out.
DATA: results TYPE zvalidate_address_out.
data: x(5) type n,
      y type i,
      text(80),
      counter type i.

SELECT-OPTIONS: s_vbeln FOR vbak-vbeln,
                s_vkorg for vbak-vkorg,
                sland1 FOR adrc-country,
                scnt for counter.
*parameters: taxkd like knvi-taxkd obligatory.
PARAMETERS: update AS CHECKBOX.


*-----------------------------------------------------------------------
* This table is used to pass transaction-data to the called-transaction.
*-----------------------------------------------------------------------
DATA: BEGIN OF bdc_tab OCCURS 30.
        INCLUDE STRUCTURE bdcdata.
DATA: END OF bdc_tab.

DATA: BEGIN OF messtab OCCURS 10.
        INCLUDE STRUCTURE bdcmsgcoll.
DATA: END OF messtab.

DATA: BEGIN OF location_data.
        INCLUDE STRUCTURE com_jur.
DATA: END OF location_data.
DATA: BEGIN OF location_err.
        INCLUDE STRUCTURE com_err.
DATA: END OF location_err.
DATA: BEGIN OF location_results OCCURS 10.
        INCLUDE STRUCTURE com_jur.
DATA: END OF location_results.
DATA: popup_flag.
DATA: lin TYPE i.
data: lin2 type i.
DATA: i TYPE i.

************************************************************************
*                               MAIN
************************************************************************
START-OF-SELECTION.
*
  clear: lin, lin2, i, x, y.
  PERFORM load_vbak_data.
*
  PERFORM process_records.
  SKIP 2.
  WRITE: / i, 'sales order records updated successfully'.
*
END-OF-SELECTION.


************************************************************************
*                          SUBROUTINES
************************************************************************
*-----------------------------------------------------------------------
* load sales orders
*-----------------------------------------------------------------------
FORM LOAD_VBAK_DATA .

* Selection open sales order w/manual delivery address
* YADAVAAS++
* Commeneted the below statement as a part of custom code adaptation
*  select vbak~vbeln vbpa~adrnr
*         into (vbak_tab-vbeln, vbak_tab-adrnr)
*         from vbak join vbpa on ( vbak~vbeln = vbpa~vbeln )
*                   join vbuk on ( vbpa~vbeln = vbuk~vbeln )
*         where vbak~vbeln in s_vbeln and
*               vbak~vkorg in s_vkorg and
*               vbpa~adrda ne 'D' and
*               vbpa~adrda ne 'A' and
*               vbpa~parvw = 'WE' and
*               vbuk~gbstk ne 'C' and
*               ( ( vbuk~fkstk = space and
*                 vbuk~fksak ne space and
*                 vbuk~fksak ne 'C' ) or
*               ( vbuk~fksak = space and
*                 vbuk~fkstk ne space and
*                 vbuk~fkstk ne 'C' ) or
*                 vbuk~lfgsk ne 'C' ).
* Added the below code
select vbak~vbeln vbpa~adrnr
         into (vbak_tab-vbeln, vbak_tab-adrnr)
         from vbak join vbpa on ( vbak~vbeln = vbpa~vbeln )
                   join v_vbuk_cds on ( vbpa~vbeln = v_vbuk_cds~vbeln )
         where vbak~vbeln in s_vbeln and
               vbak~vkorg in s_vkorg and
               vbpa~adrda ne 'D' and
               vbpa~adrda ne 'A' and
               vbpa~parvw = 'WE' and
               v_vbuk_cds~gbstk ne 'C' and
               ( ( v_vbuk_cds~fkstk = space and
                 v_vbuk_cds~fksak ne space and
                 v_vbuk_cds~fksak ne 'C' ) or
               ( v_vbuk_cds~fksak = space and
                 v_vbuk_cds~fkstk ne space and
                 v_vbuk_cds~fkstk ne 'C' ) or
                 v_vbuk_cds~lfgsk ne 'C' ).
* YADAVAAS--
    if sy-dbcnt in scnt.
      select single city1 post_code1 region country street str_suppl1
                    po_box
             into (vbak_tab-ort01, vbak_tab-pstlz, vbak_tab-regio,
                   vbak_tab-land1, vbak_tab-stras, vbak_tab-str_suppl1, vbak_tab-pfach)
             from adrc
             where addrnumber = vbak_tab-adrnr and
                   country in sland1 and
                   not taxjurcode like 'US%' and
                   not taxjurcode like 'CA%' and
                   taxjurcode ne space.
      if sy-subrc = 0.
        write: / 'Sales order', vbak_tab-vbeln, 'selected for processing'.
        APPEND vbak_TAB.
        CLEAR vbak_TAB.
      endif.
    endif.
  endselect.

ENDFORM.                    " LOAD_VBAK_DATA

*-----------------------------------------------------------------------
*-----------------------------------------------------------------------
FORM process_records.
  DATA:   city1 LIKE com_jur-city,
          city2 LIKE com_jur-city,
          city3 LIKE com_jur-city,
          city4 LIKE com_jur-city.
  data: lin3(6) type n.
  describe TABLE vbak_tab lines lin2.
  lin3 = lin2.
*
  LOOP AT vbak_tab.
*
    REFRESH: bdc_tab, location_results, validate_address_out.
    CLEAR: location_data, location_err, popup_flag.


    CALL FUNCTION 'Z_VALIDATE_ADDRESS'
      DESTINATION 'AVATAX'
      EXPORTING
        street1              = vbak_tab-stras
        street2              = vbak_tab-str_suppl1
        city                 = vbak_tab-ort01
        state                = vbak_tab-regio
        postalcode           = vbak_tab-pstlz
        country              = vbak_tab-land1
        pobox                = vbak_tab-pfach
      TABLES
        validate_address_out = validate_address_out
      EXCEPTIONS
        system_error         = 1
        OTHERS               = 2.

    IF sy-subrc = 0. "d location_err-retcode = 0.
      READ TABLE validate_address_out INTO results INDEX 1.
      IF sy-subrc NE 0 OR results-jurisdictioncode IS INITIAL OR
         strlen( results-jurisdictioncode ) NE 13.
        "Try looking up jurisdiction code with just the zip code
        location_data-country = vbak_tab-land1.
        location_data-state = vbak_tab-regio.
        location_data-city = vbak_tab-ort01.
        location_data-zipcode = vbak_tab-pstlz.
        CALL FUNCTION 'RFC_DETERMINE_JURISDICTION' DESTINATION 'AVATAX'
          EXPORTING
            location_data    = location_data
          IMPORTING
            location_err     = location_err
          TABLES
            location_results = location_results
          EXCEPTIONS
            OTHERS           = 1.
        IF sy-subrc = 0.
          READ TABLE location_results INDEX 1.
          IF sy-subrc NE 0 OR location_results-txjcd IS INITIAL OR
             strlen( location_results-txjcd ) NE 13.
            WRITE: / '====>ERROR on ', vbak_tab-vbeln, vbak_tab-stras, vbak_tab-pstlz, vbak_tab-regio, vbak_tab-ort01.
            continue.
          ELSE.
            WRITE: / '====>DEFAULT  ', vbak_tab-vbeln, vbak_tab-stras, vbak_tab-pstlz, vbak_tab-regio, vbak_tab-ort01.
            vbak_tab-txjcd = location_results-txjcd.
            MODIFY vbak_tab.
          ENDIF.
        ELSE.
          WRITE: / '====>ERROR on ', vbak_tab-vbeln, vbak_tab-stras, vbak_tab-pstlz, vbak_tab-regio, vbak_tab-ort01.
          continue.
        ENDIF.
      ELSE.
        vbak_tab-txjcd = results-jurisdictioncode.
        MODIFY vbak_tab.
      ENDIF.

      IF NOT update IS INITIAL.
        PERFORM process_bdc.
      ENDIF.
    ELSE.
*         write: / 'RFC did not work for customer:', kna1_tab-kunnr.
      WRITE: / '====>ERROR on ', vbak_tab-vbeln, vbak_tab-stras, vbak_tab-pstlz, vbak_tab-regio, vbak_tab-ort01.
      continue.
    ENDIF.
*
    IF NOT update IS INITIAL.
      COMMIT WORK.
    ENDIF.

    IF sy-batch IS INITIAL.
      y = y + 1.
      x = x + 1.
      IF y > 9.
        CLEAR y.
        CONCATENATE 'Addresses processed:' x 'from' lin3 INTO text SEPARATED BY space.
        CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
          EXPORTING
            text   = text
          EXCEPTIONS
            OTHERS = 1.
      ENDIF.
    ENDIF.

  ENDLOOP.
ENDFORM.


*-----------------------------------------------------------------------
*
*-----------------------------------------------------------------------
FORM process_bdc.
*

  DATA: name(30).
  DATA: BEGIN OF xvbpa OCCURS 0.
          INCLUDE STRUCTURE vbpa.
  DATA: END OF xvbpa.
  DATA: i(2).

  name = 'GVS_TC_DATA-REC-PARTNER(&)'.

  SELECT * FROM vbpa INTO CORRESPONDING FIELDS OF TABLE xvbpa
  WHERE vbeln = vbak_tab-vbeln AND
        posnr = '000000'.

  LOOP AT xvbpa.
    IF xvbpa-parvw = 'WE'.
      i = sy-tabix.
      REPLACE '&' WITH i INTO name.
      EXIT.
    ENDIF.
  ENDLOOP.


  PERFORM insert_row_in_bdc_tab TABLES bdc_tab USING:
     'X' 'SAPMV45A'             '0102',
     ' ' 'VBAK-VBELN'           vbak_tab-vbeln,
     ' ' 'BDC_OKCODE'           '/00',
     'X' 'SAPMV45A'             '4001',
     ' ' 'BDC_OKCODE'           '=KPAR_SUB',
     'X' 'SAPMV45A'             '4002',
     ' ' 'BDC_CURSOR'           name,
     ' ' 'BDC_OKCODE'           '=PSDE',
     'X' 'SAPLV09C'             '5000',
     ' ' 'ADDR1_DATA-CITY1'          vbak_tab-ort01,
     ' ' 'ADDR1_DATA-TAXJURCODE'     vbak_tab-txjcd,
     ' ' 'ADDR1_DATA-LANGU'          sy-langu,
     ' ' 'BDC_OKCODE'           '=ENT1',
*     'X' 'SAPLSPO2'             '0300',
*     ' ' 'BDC_OKCODE'           '=OPT2',
     'X' 'SAPMV45A'             '4002',
     ' ' 'BDC_OKCODE'           '=T\03',
     'X' 'SAPMV45A'             '4002',
     ' ' 'VBAK-TAXK1'           '1',
     ' ' 'BDC_OKCODE'           '=SICH'.
  SELECT * FROM vbuv WHERE vbeln = vbak_tab-vbeln.
  ENDSELECT.
  IF sy-subrc NE 0.
    PERFORM insert_row_in_bdc_tab TABLES bdc_tab USING:
      'X' 'SAPLSPO2 '             '0101',
      ' ' 'BDC_OKCODE'           '=OPT1'.
  ENDIF.


  PERFORM call_transaction USING 'VA02'.

ENDFORM.


*-----------------------------------------------------------------------
* Call the transaction, and get back a message of whether it completed
* successfully or not in "zmsgli"...
*-----------------------------------------------------------------------
FORM call_transaction USING ztrancode.

  DATA: mode.

  REFRESH messtab.
  mode = 'N'.
  CALL TRANSACTION  ztrancode USING bdc_tab MODE mode
                          MESSAGES INTO messtab.
  IF sy-subrc <> 0.
    WRITE: / '====>ERROR on ', vbak_tab-vbeln.
  ELSE.
*    write: / '=> OK', kna1_tab-kunnr.
    LOOP AT messtab WHERE msgid = 'V1' AND
                          ( msgnr = '041' OR
                            msgnr = '311' ).
      CHECK messtab-msgnr = '311'.
      IF NOT vbak_tab-txjcd IS INITIAL.
        i = i + 1.
        write: / '====>UPDAT on ', vbak_tab-vbeln.
      ENDIF.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / '====>ERROR on ', vbak_tab-vbeln.
    ENDIF.
  ENDIF.
*  LOOP AT messtab WHERE msgtyp = 'E'.
*    WRITE: /20 messtab.
*  ENDLOOP.

ENDFORM.

*-----------------------------------------------------------------------
*-----------------------------------------------------------------------
FORM insert_row_in_bdc_tab
            TABLES bdc
            STRUCTURE bdcdata
                USING begin name value.
  CLEAR bdc.
  IF begin = 'X'.
    MOVE: name  TO bdc-program,
          value TO bdc-dynpro,
          'X'   TO bdc-dynbegin.
  ELSE.
    MOVE: name  TO bdc-fnam,
          value TO bdc-fval.
  ENDIF.
  APPEND bdc.
ENDFORM.
