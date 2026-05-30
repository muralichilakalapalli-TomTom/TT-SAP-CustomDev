*&---------------------------------------------------------------------*
*&  Include           Z_SD_SHIPMENTNOTIFI113
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Author        : Sajid Ghulam                                         *
* Date          : 21-11-2007                                           *
* I/E-number    : I901                                                 *
* Version FD/TD : V1.0                                                 *
*----------------------------------------------------------------------*
* Description   : This Include program Update the database table
* value                                                                *
*----------------------------------------------------------------------*
*-----------------------------------------------------------------------*
* Change log                                                            *
*-----------------------------------------------------------------------*
* Author        : Ghulam Sajid                                          *
* Date          : 20-06-2008                                            *
* Request       : TRDK903335                                            *
* I/E-number    : I113                                                  *
* Reference     : <CS number>                                           *
* Version FD/TD : <1.0/1.0>                                             *
* Description   : Three fields(SCAC Code , routing ID and BOLNR)  are   *
*coming in the GI IDOC in the extension2 segment and to be updated in   *
* LIKP so that this can be used to appropriately populate the INVOICE IDOC.
*these fields are                                                       *
*BOLNR      = LIKP-BOLNR (Currently no value being updated).            *
*ROUT_ID    = LIKP- SPE_GEOROUTE.                                       *
*SCAC_CODE  = LIKP- ZZVLABDATA(struc needs to be enhanced)              *
*-----------------------------------------------------------------------*


*----------------------------------------------------------------------*
* FORM update_likp USING lv_vbeln fieldname value date                 *
*    This form Update the database table LIKP
*                                                                      *
*----------------------------------------------------------------------*

FORM update_likp USING lv_vbeln fieldname value date.

  CONSTANTS : lc_wadat_ist  TYPE char9 VALUE 'WADAT_IST',
              lc_lifex      TYPE char5 VALUE 'LIFEX'   ,
              lc_vlabdata   TYPE char9 VALUE 'ZVLABDATA',
* Three fields updated/modified by saghulam
              lc_scac     TYPE char9   VALUE  'SCAC_CODE',         " Carrier SCAC Code
              lc_bolnr    TYPE char5   VALUE  'BOLNR',             " Bill of lading
              lc_route    TYPE char12   VALUE  'SPE_GEOROUTE'.      " Route ID

*CHECK LV_VBELN must not be INITIAL for updation
  CHECK NOT lv_vbeln IS INITIAL .

  ASSIGN fieldname TO  <lfs_field>.

* Update the  LIKP TABLE for Actual Shipping date
  IF <lfs_field> = lc_wadat_ist AND NOT date IS INITIAL.
    UPDATE likp SET wadat_ist = date
                 WHERE vbeln  = lv_vbeln .

  ELSEIF <lfs_field> =  lc_vlabdata.
* Update the  LIKP TABLE for Carrier Tracking number
    UPDATE likp SET zvlabdata = value
              WHERE vbeln = lv_vbeln .

  ELSEIF <lfs_field> =  lc_lifex.
* Update the  LIKP TABLE for External delivery number
    UPDATE likp SET lifex = value
              WHERE vbeln = lv_vbeln .
* Start of Modification by saghulam Request: TRDK903335
* UPDATE Carrier SCAC Code
  ELSEIF <lfs_field> =  lc_scac.    " 'SCAC_CODE'  Carrier SCAC Code
    UPDATE likp SET scac_code = value
                    WHERE vbeln = lv_vbeln .

  ELSEIF <lfs_field> =  lc_bolnr.   " 'BOLNR'      Bill of lading
* UPDATE Bill of lading
    UPDATE likp SET bolnr = value
                    WHERE vbeln = lv_vbeln .

  ELSEIF <lfs_field> =  lc_route.   " rout ID
* UPDATE  Route ID
    UPDATE likp SET spe_georoute = value
                    WHERE vbeln = lv_vbeln .

*end of modificaton
  ENDIF .

ENDFORM.                    " UPDATE_LIKP
