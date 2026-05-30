class ZCL_IM__ENH_I105 definition
  public
  final
  create public .

*"* public components of class ZCL_IM__ENH_I105
*"* do not include other source files here!!!
public section.

  interfaces IF_EX_SMOD_V50B0001 .
protected section.
*"* protected components of class ZCL_IM__ENH_I105
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_IM__ENH_I105
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_IM__ENH_I105 IMPLEMENTATION.


method IF_EX_SMOD_V50B0001~EXIT_SAPLV50I_001.
endmethod.


method IF_EX_SMOD_V50B0001~EXIT_SAPLV50I_002.
endmethod.


method IF_EX_SMOD_V50B0001~EXIT_SAPLV50I_003.
endmethod.


method IF_EX_SMOD_V50B0001~EXIT_SAPLV50I_004.
endmethod.


method IF_EX_SMOD_V50B0001~EXIT_SAPLV50I_009.
endmethod.


method IF_EX_SMOD_V50B0001~EXIT_SAPLV50I_010.
endmethod.


METHOD if_ex_smod_v50b0001~exit_saplv50k_005.
*&---------------------------------------------------------------------&*
*----------------------------------------------------------------------&*
* Author        : Sajid Ghulam
* Date          : 20-11-2007
* I/E-number    : I105,
* Version FD/TD : 0.0.1/1.0
* Request       :
*&---------------------------------------------------------------------&*
* Description   : Populate the extra segment BAPIEXT to contain the
*                 partner information for inbound delivery
*&---------------------------------------------------------------------&*
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



*&---------------------------------------------------------------------&*
*&   C  O  N  S  T  A  N  T     D  E  C  L  A  R  A  T  I  O  N
*&---------------------------------------------------------------------&*

  CONSTANTS : c_we    TYPE char2 VALUE  'WE',             " WE as partner role
              c_ag    TYPE char2 VALUE  'AG',             " AG as partner role
              c_adrnr TYPE char5 VALUE  'ADRNR'.          " Address Number

*&---------------------------------------------------------------------&*
*&    T  Y  P  E  S     D  E  C  L  A  R  A  T  I  O  N
*&---------------------------------------------------------------------&*

  TYPES : BEGIN OF lt_so ,
          vbeln TYPE vbeln_va ,                                " Sales Document
          END OF lt_so,

**    Customer Address number from VBPA
          BEGIN OF lt_vbpa,
          vbeln  TYPE vbeln,                                    " Sales and Distribution Document Number
          parvw  TYPE parvw,                                    " Partner Function
          kunnr  TYPE kunnr,                                    " Customer Number 1
          adrnr  TYPE adrnr,                                    " Address number
          END OF lt_vbpa,

***  Types for Email address
          BEGIN OF lt_email,
          addrnumber TYPE ad_addrnum ,                            " Address number
          smtp_addr  TYPE ad_smtpadr ,                            " E-Mail Address
          END OF lt_email,

*   Types for partner address WE and AG
          BEGIN OF lt_e1bpext,
          addrnumber  TYPE   ad_addrnum,                          " Address number
          name1       TYPE   name1,                               " Name 1
          name2       TYPE   ad_name2 ,                           " Name 2
          city1       TYPE   ad_city1,                            " city
          city2       TYPE   ad_city2,                            " District
          post_code1  TYPE   ad_pstcd1,                           " City postal code
          street      TYPE   ad_street,                           " Street
          house_num1  TYPE   ad_hsnm1,                            " House Number
          country     TYPE   land1,                               " Country Key
          langu       TYPE   spras,                               " Language Key
          END OF lt_e1bpext.

*&---------------------------------------------------------------------&*
*&    D  A  T  A      D  E  C  L  A  R  A  T  I  O  N
*&---------------------------------------------------------------------&*

DATA:   lwa_bapiext  TYPE  bapiextc,                      " workarea of type BAPIEXTC to populate segment
        lwa_e1bpext  TYPE  lt_e1bpext,                    " workarea for partner detail
        lv_e1bpext   TYPE  char255,                       " Declared to concatenate the all data in this
        lwa_lips     TYPE  lipsvb,                        " workarea for the  lips
        lwa_so       TYPE  lt_so ,                        " workarea of type lt_so
        lwa_vbpa     TYPE  lt_vbpa ,                      " workarea of type lt_vbpa
        lwa_vbpa1    TYPE  vbpavb,                        " workarea for reference structure XVBPA/YVBPA
        lwa_email    TYPE  lt_email.                      " workarea for Email address of parner


*&---------------------------------------------------------------------&*
*&   I  N  T  E  R  N  A  L   T  A  B  L  E
*&---------------------------------------------------------------------&*

  DATA : li_so       TYPE TABLE OF lt_so,                " Internal table that contains SO#
         li_vbpa     TYPE TABLE OF lt_vbpa,              " Internal table for Customer Address number from VBPA
         li_email    TYPE sorted TABLE OF lt_email         " Internal table for Email address
                     WITH UNIQUE KEY addrnumber ,
         li_e1bpext  TYPE TABLE OF lt_e1bpext.           " Internal table for partner address WE and AG

  READ TABLE it_lips INTO lwa_lips INDEX 1 .

  CHECK sy-subrc = 0 .
** Fetch SO number from VBAK condition BSTNK(Purchase Order#)
  SELECT vbeln "(SO#)
    FROM vbak
    INTO TABLE li_so
    WHERE bstnk = lwa_lips-vgbel .

* check internal table is not empty
  IF NOT li_so IS INITIAL .

** Get the address number of respective parter
    SELECT vbeln
           parvw
           kunnr
           adrnr
      FROM vbpa
      INTO TABLE li_vbpa
      FOR ALL ENTRIES IN li_so
      WHERE vbeln = li_so-vbeln .
    IF sy-subrc = 0 .

*** Delete duplicate entries from Li_vbpa so that only one entry W.R.T. parter exist in table
*      DELETE ADJACENT DUPLICATES FROM li_vbpa COMPARING parvw kunnr adrnr .

      CHECK NOT li_vbpa IS INITIAL . " If li_vbpa is initial then no need to populate the segment
** Get the address detail of partner goods recepient and sold-to-party
** Get the Email address
      SELECT addrnumber
             smtp_addr "(E-Mail Address)
             FROM adr6
             INTO TABLE li_email
             FOR ALL ENTRIES IN li_vbpa
             WHERE addrnumber = li_vbpa-adrnr .


** Get the address detail
      SELECT addrnumber
             name1
             name2
             city1
             city2
             post_code1
             street
             house_num1
             country
             langu
             FROM adrc
             INTO TABLE li_e1bpext
             FOR ALL ENTRIES IN li_vbpa
             WHERE addrnumber = li_vbpa-adrnr .

      IF sy-subrc = 0 .
        SORT: li_e1bpext,li_vbpa .
**   Read table LI_VBPA  parter Role "WE" for address number
        READ TABLE li_vbpa INTO lwa_vbpa
        WITH KEY parvw = c_we BINARY SEARCH.

        IF sy-subrc = 0 .
**   Read table li_e1bpext FOR Address Detail
          READ TABLE li_e1bpext INTO lwa_e1bpext
          WITH KEY  addrnumber = lwa_vbpa-adrnr BINARY SEARCH.

**   Read li_email for email address
          IF sy-subrc = 0 .  "AND NOT li_email IS INITIAL.
            READ TABLE li_email INTO lwa_email
            WITH KEY  addrnumber = lwa_vbpa-adrnr BINARY SEARCH.

            lv_e1bpext+0(10)   =  lwa_e1bpext-addrnumber.
            lv_e1bpext+10(40)  =  lwa_e1bpext-name1.
            lv_e1bpext+50(40)  =  lwa_e1bpext-name2 .
            lv_e1bpext+90(40)  =  lwa_e1bpext-city1.          " City
            lv_e1bpext+130(40) =  lwa_e1bpext-city2.          " District
            lv_e1bpext+170(10) =  lwa_e1bpext-post_code1.     " Postal code
            lv_e1bpext+180(60) =  lwa_e1bpext-street .        " Street
            lv_e1bpext+240(10) =  lwa_e1bpext-house_num1.

*** Populate the BAPIEXT FOR WE
            lwa_bapiext-field1        =   c_we.
            lwa_bapiext-field2        =   lv_e1bpext.
            lwa_bapiext-field3+0(3)   =   lwa_e1bpext-country.
            lwa_bapiext-field3+3(241) =   lwa_email-smtp_addr.
            lwa_bapiext-field3+244(2) =   lwa_e1bpext-langu.
            APPEND lwa_bapiext TO et_extension1.
          ENDIF.
        ENDIF.

      CLEAR : lwa_vbpa,lwa_e1bpext,lwa_email.

**   Read table LI_VBPA  parter Role "AG" for address number.
        READ TABLE li_vbpa INTO lwa_vbpa
        WITH KEY parvw = c_ag BINARY SEARCH.

**   Read li_e1bpext for address Detail

        READ TABLE li_e1bpext INTO lwa_e1bpext
        WITH KEY  addrnumber = lwa_vbpa-adrnr BINARY SEARCH.

        IF sy-subrc = 0 AND NOT li_email IS INITIAL .
**   Read li_email for email address
          READ TABLE li_email INTO lwa_email
          WITH KEY  addrnumber = lwa_vbpa-adrnr BINARY SEARCH.
        ENDIF.

        lv_e1bpext+0(10)   =  lwa_e1bpext-addrnumber.
        lv_e1bpext+10(40)  =  lwa_e1bpext-name1.
        lv_e1bpext+50(40)  =  lwa_e1bpext-name2 .
        lv_e1bpext+90(40)  =  lwa_e1bpext-city1.          " City
        lv_e1bpext+130(40) =  lwa_e1bpext-city2.          " District
        lv_e1bpext+170(10) =  lwa_e1bpext-post_code1.     " Postal code
        lv_e1bpext+180(60) =  lwa_e1bpext-street .        " Street
        lv_e1bpext+240(10) =  lwa_e1bpext-house_num1.

*** Populate the BAPIEXT FOR AG
        lwa_bapiext-field1        =   c_ag.
        lwa_bapiext-field2        =   lv_e1bpext.
        lwa_bapiext-field3+0(3)   =   lwa_e1bpext-country.
        lwa_bapiext-field3+3(241) =   lwa_email-smtp_addr.
        lwa_bapiext-field3+244(2) =   lwa_e1bpext-langu.
        APPEND lwa_bapiext TO et_extension1.

      ENDIF.
    ENDIF .
  ENDIF.       "  NOT li_so IS INITIAL
ENDMETHOD.


method IF_EX_SMOD_V50B0001~EXIT_SAPLV50K_006.
endmethod.


method IF_EX_SMOD_V50B0001~EXIT_SAPLV50K_007.
endmethod.


method IF_EX_SMOD_V50B0001~EXIT_SAPLV50K_008.
endmethod.


method IF_EX_SMOD_V50B0001~EXIT_SAPLV50K_011.
endmethod.


method IF_EX_SMOD_V50B0001~EXIT_SAPLV50K_012.
endmethod.


method IF_EX_SMOD_V50B0001~EXIT_SAPLV50K_013.
endmethod.
ENDCLASS.
