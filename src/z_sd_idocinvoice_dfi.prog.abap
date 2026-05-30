*&---------------------------------------------------------------------*
*&  Include           Z_SD_IDOCINVOICE_DFI
*&---------------------------------------------------------------------*

CONSTANTS :  lc_e1edp05(7)    TYPE c  VALUE 'E1EDP05',
             lc_minus         TYPE c VALUE '-',
             lc_id(4)         TYPE c VALUE 'Z001'.

TABLES : *STXH.

DATA : lwa_ze1edp05 TYPE e1edp05,
       lv_name      TYPE tdobname.

DATA : lt_lines TYPE STANDARD TABLE OF tline,
       lwt_lines  TYPE tline,
       lv_tdlinex TYPE tdline,
       lv_rnd0 TYPE kwert,
       lv_rnd1 TYPE kwert,
       lv_rnd2 TYPE kwert.

IF CONTROL_RECORD_OUT-CIMTYP = 'Z2INVOIC'.
  IF int_edidd-segnam = lc_e1edp05.
    IF int_edidd-sdata+0(1) = lc_minus.
        CLEAR : lv_name,
                lt_lines,
                lwt_lines,
                lv_tdlinex,
                int_edidd,
                lwa_ze1edp05.


        int_edidd-segnam = 'ZE1EDP05'.


        Loop at XIKOMV where KVSL1 = 'Z07'
                       and   KPOSN = XTVBDPR-POSNR.

          concatenate XIKOMV-KNUMH XIKOMV-KOPOS into lv_name.
*         CALL FUNCTION 'SELECT_TEXT'
*             EXPORTING
*               id             = 'Z001'
*               language       = sy-langu
*               name           = lv_name
*               object         = 'KONP'.
*                archive_handle = 0.

          SELECT SINGLE * FROM *STXH
                          WHERE tdobject = 'KONP'
                          AND   tdname = lv_name
                          AND   tdid = lc_id
                          AND   tdspras = sy-langu.


          IF sy-subrc = 0.
            CALL FUNCTION 'READ_TEXT'
              EXPORTING
                  id             = lc_id
                  language       = sy-langu
                  name           = lv_name
                  object         = 'KONP'
                  archive_handle = 0
              TABLES
                  lines          = lt_lines.
* TDLINE+0(4)  contains discount code.
            LOOP AT lt_lines INTO lwt_lines.
              lv_tdlinex = lwt_lines-tdline+0(4).
              exit.
            ENDLOOP.
* Fill  LWA_ZE1EDP05
            If xtvbdpr-fkimg <> 0.
              lwa_ze1edp05-alckz = '-'.
              lwa_ze1edp05-KOTXT = lv_tdlinex.
              lwa_ze1edp05-BETRG = XIKOMV-KWERT.
              condense lwa_ze1edp05-BETRG.
              lv_rnd0 = ( XIKOMV-KWERT / xtvbdpr-fkimg ).
              lv_rnd1 = lv_rnd0 * 10.
              lv_rnd2 = lv_rnd1 / 10.
              lwa_ze1edp05-KRATE = -1 * lv_rnd2.
              condense lwa_ze1edp05-KRATE.
              lwa_ze1edp05-UPRBS = 1.
              condense lwa_ze1edp05-UPRBS.
              lwa_ze1edp05-MEAUN = 'PCE'.
              lwa_ze1edp05-KOEIN = XIKOMV-WAERS.
              lwa_ze1edp05-KOBAS = xtvbdpr-fkimg.
              condense lwa_ze1edp05-KOBAS.
              MOVE lwa_ze1edp05 TO int_edidd-sdata.
              APPEND int_edidd.
            Endif.                 "xtvbdpr <> 0
          Endif.
        Endloop.        "XKOMV

        CLEAR : int_edidd,
                lwa_e1edkt1 .
    ENDIF.
  ENDIF.
ENDIF.
