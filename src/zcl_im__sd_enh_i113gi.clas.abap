class ZCL_IM__SD_ENH_I113GI definition
  public
  final
  create public .

*"* public components of class ZCL_IM__SD_ENH_I113GI
*"* do not include other source files here!!!
public section.

  interfaces IF_EX_SMOD_V50B0001 .
protected section.
*"* protected components of class ZCL_IM__SD_ENH_I113GI
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_IM__SD_ENH_I113GI
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_IM__SD_ENH_I113GI IMPLEMENTATION.


method IF_EX_SMOD_V50B0001~EXIT_SAPLV50I_001.
endmethod.


method IF_EX_SMOD_V50B0001~EXIT_SAPLV50I_002.
endmethod.


method IF_EX_SMOD_V50B0001~EXIT_SAPLV50I_003.
endmethod.


METHOD if_ex_smod_v50b0001~exit_saplv50i_004.
*----------------------------------------------------------------------*
* Author        : Sajid Ghulam                                         *
* Date          : 21-11-2007                                           *
* I/E-number    : I113                                                 *
* Version FD/TD :  1.0/1.0                                             *
*----------------------------------------------------------------------*
* Description   : This implementaion updates the table as per entry in *
* the E1BAPIEXT segment
*-----------------------------------------------------------------------*
* Change log                                                            *
*-----------------------------------------------------------------------*
* Author        : Ghulam Sajid                                   *
* Date          : 20-06-2008                                          *
* Request       : TRDK903335                                   *
* I/E-number    : I113                                  *
* Reference     : <CS number>                                           *
* Version FD/TD : <fdver>/<tdver>                                       *
* Description   : <Description change>                                  *
*-----------------------------------------------------------------------*

*&---------------------------------------------------------------------&*
*&   C  O  N  S  T  A  N  T     D  E  C  L  A  R  A  T  I  O  N
*&---------------------------------------------------------------------&*

  CONSTANTS: lc_vbeln    TYPE char10  VALUE  'VBELN',             " Delivery number
             lc_shpdate  TYPE char9   VALUE  'WADAT_IST',         " shipment date
             lc_lifex    TYPE char5   VALUE  'LIFEX'    ,         " External delivery number
             lc_vlabdata TYPE char9   VALUE  'ZVLABDATA',         " Carrier tracking nr
* fields are added by saghulam
             lc_scac     TYPE char9   VALUE  'SCAC_CODE',         " Carrier SCAC Code
             lc_bolnr    TYPE char5   VALUE  'BOLNR',             " Bill of lading
             lc_route    TYPE char12  VALUE  'SPE_GEOROUTE',      " Route ID
* Param for the additional fields declaration
             lc_scacid   TYPE char9   VALUE  'CRSCACCD',         " Carrier SCAC Code
             lc_bol_num  TYPE char5   VALUE  'BOL',              " Bill of lading
             lc_routeid  TYPE char12  VALUE  'RTNGCD',           " Route ID

             lc_x        TYPE c       VALUE  'X',                 " flag
             lc_shpdat   TYPE char7   VALUE  'SHPDATE',           " Shipment Date
             lc_crtrack  TYPE char7   VALUE  'CRTRACK',           " Carrier tracking nr
             lc_extnum   TYPE char6   VALUE  'EXTNUM',            " External delivery number
             lc_likp     TYPE char4   VALUE  'LIKP',              " Table LIKP to be updated
             lc_vxsitdl  TYPE char7   VALUE  'VXSITDL'.           " Delivery Company: Meta Description Data Field; to be updated


CONSTANTS:  lc_textid_CARR   TYPE tdid     VALUE 'CARR',
            lc_tdobject      TYPE tdobject VALUE 'VBBK',
            lc_textid_ROUT   TYPE tdid     VALUE 'ROUT'.

DATA : lwa_thead   TYPE thead,
       lwa_tline   TYPE tline.

DATA:   li_tlines   TYPE STANDARD TABLE OF  tline.

**&---------------------------------------------------------------------&*
**&   F I E L D - S Y M B O L S     D  E  C  L  A  R  A  T  I  O  N      *
**&---------------------------------------------------------------------&*
*
  FIELD-SYMBOLS : <lf_bapiextt>  TYPE bapiext.           " field symbol of type bapiext to extract the data from extension2



*&---------------------------------------------------------------------&*
*&    W O R K   A R E A   D E C L A R A T I O N
*&---------------------------------------------------------------------&*
  DATA:  lwa_zitab    TYPE   zzupdate.                   " Structure of type ZZUPDATE

*&---------------------------------------------------------------------&*
*&    I N T E R N A L   T A B L E   D E C L A R A T I O N
*&---------------------------------------------------------------------&*

  DATA : li_zinttab  TYPE  zzupdatett .                  " ITAB to contain the value for updation

*&---------------------------------------------------------------------&*
*&    L O G I C
*&---------------------------------------------------------------------&*

  lwa_zitab-zfieldname = lc_vbeln .
  lwa_zitab-zval_char  = cs_vbkok-vbeln_vl.
  APPEND lwa_zitab TO li_zinttab .

  CLEAR lwa_zitab .

*BREAK SAGHULAM.
CHECK not extension2 is INITIAL.
* loop through extended segment to update the segment data in table
  LOOP AT extension2 ASSIGNING <lf_bapiextt>.

    CASE <lf_bapiextt>-param.

* Actual Shipping date
      WHEN lc_shpdat .
        CS_VBKOK-WADAT_IST   =  <lf_bapiextt>-value .

* Carrier Tracking number
      WHEN lc_crtrack .
        lwa_zitab-ztabname   = lc_likp .
        lwa_zitab-zfieldname =  lc_vlabdata.
        lwa_zitab-zval_char  = <lf_bapiextt>-value .
        APPEND lwa_zitab TO li_zinttab .

* External delivry number
      WHEN lc_extnum.
         CS_VBKOK-LIFEX       =  <lf_bapiextt>-value .
* code modification by SAGHULAM
*  For additional fields added
* ALPHA Numeric Code
      WHEN lc_scacid   .
        lwa_zitab-ztabname   = lc_likp .
        lwa_zitab-zfieldname = lc_scac .
        lwa_zitab-zval_char  = <lf_bapiextt>-value .
        APPEND lwa_zitab TO li_zinttab .
* Bill of lading
      WHEN lc_bol_num.
         CS_VBKOK-BOLNR       =  <lf_bapiextt>-value .

      WHEN lc_routeid.
        lwa_zitab-ztabname   = lc_likp .
        lwa_zitab-zfieldname = lc_route .
        lwa_zitab-zval_char  = <lf_bapiextt>-value .
        APPEND lwa_zitab TO li_zinttab .

*endofaddition

    ENDCASE .
    CLEAR : lwa_zitab .
  ENDLOOP .

* Count the lines of li_zinttab to call the update FM
  DESCRIBE TABLE li_zinttab.
  IF sy-tfill > 1 .

** Call this function module to update fields
    CALL FUNCTION 'Z_SD_UPDATETABLE'
      CHANGING
        inttab = li_zinttab.

  ENDIF .
ENDMETHOD.


method IF_EX_SMOD_V50B0001~EXIT_SAPLV50I_009.
endmethod.


method IF_EX_SMOD_V50B0001~EXIT_SAPLV50I_010.
endmethod.


method IF_EX_SMOD_V50B0001~EXIT_SAPLV50K_005.
endmethod.


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
