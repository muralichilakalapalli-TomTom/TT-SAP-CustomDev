REPORT ZSDV03V02 LINE-SIZE 132 LINE-COUNT 65 MESSAGE-ID VV.
*ENHANCEMENT-POINT SDV03V02_G4 SPOTS ES_SDV03V02 STATIC.
*ENHANCEMENT-POINT SDV03V02_G5 SPOTS ES_SDV03V02.
*ENHANCEMENT-POINT SDV03V02_G6 SPOTS ES_SDV03V02 STATIC.
*ENHANCEMENT-POINT SDV03V02_G7 SPOTS ES_SDV03V02.
******************************************************************************************************************
* Author        : Aashana Yadav                                                                                  *
* Date          : 20.02.2023                                                                                     *
* Reference     : YADAVAAS/ SAPA 7786/ S4 HANA                                                                   *
* Description   : Adapted below custom code as per S4 ATC checks                                                 *
*                1. Changed the select on table VBUK and VBUP by a select on view V_VBUK_S4 and V_VBUP_S4 .      *
*                  Adjusted the syntax of the query as per the S4 coding standards, but kept the original        *
*                  logic AS-IS.                                                                                  *
*                2. Commented the followind declaration : LFGSA LIKE VBUP-LFGSA. LFGSA field is now already      *
*                   included in VBAP, so no need to declare it as a separate entity.                             *
*                3. Commented the followind declaration : BESTA LIKE VBUP-BESTA. BESTA field is now already      *
*                   included in VBAP, so no need to declare it as a separate entity.                             *
******************************************************************************************************************

***********************************************************************
*                  DATENDEKLARATIONSTEIL                              *
***********************************************************************

*---------------------------------------------------------------------*
* Dictionary tables                                                   *
*---------------------------------------------------------------------*
  TABLES:
*         Sales relevant tables
          MARC,                        " Materialstamm C-Segment
          MARD,                        " Storage Location Data for Material
          V_VMVAC,                     " Matchcode Unvollst.
          VAPMA,                       " Aufträge zum Material
          VBAK,                        " Auftragskopf
          VBAP,                        " Position
          VBEP,                        " Einteilung
          VBUK,                        " Status Kopf
          VBUP,                        " Status Position
          KNVV,
          TVAK,
          T459A,
          T459K,
*         Others
          INDX.


*---------------------------------------------------------------------*
* Internal tables                                                     *
*---------------------------------------------------------------------*

* Common -------------------------------------------------------------*
* Übergabetabelle mit zu prüfenden Positionen
* Note: Field WERKS for purchasing documents is filled with the
*       supplying plant (RESWK) as this is the location of requirement
  DATA: BEGIN OF XTAB OCCURS 0.
          INCLUDE STRUCTURE AV03R.
  DATA: END OF XTAB.

* Store the sort sequence
  DATA: BEGIN OF SORT_TAB OCCURS 0,
           FIELDNAME   LIKE DD03D-FIELDNAME,
           PRIORITY    TYPE P_SORT,
*          PRIORITY(1) TYPE C,
        END OF SORT_TAB.

* Counter for xtab
  DATA: DA_TABIX LIKE SY-TABIX,

* Item or schedule line processing (for export to database)
        GV_ITEM_OR_SCHED(1) TYPE C,
        GV_DCREAT(1)        TYPE C,
        GV_INDX_SRTFD       LIKE INDX-SRTFD,

* Dummy-field for messages
        gl_dummy_message(72),

* Global fields for APO-active checks
        gv_apoactive(1)     type c,
        gv_logsys           like desmat_atp-logsys.

* Sales --------------------------------------------------------------*
* Tabelle der nicht vollständig bestätigten Verkaufsbelege zum Material
  DATA: BEGIN OF MATUNV OCCURS 0,
          MATNR LIKE AV03R-MATNR,
          WERKS LIKE AV03R-WERKS,
        END OF MATUNV.

* Purchasing ---------------------------------------------------------*
* Transport purchase documents: Relevant data for ATP-Check
  DATA: T_PDOC type table of rpdoc with header line.
* Transport purchase requisitions: Relevant data for ATP-Check
  DATA: T_PREQ type table of rpreq with header line.
* Account assignments purchase documents
  DATA: T_EKKN_ALL type table of EKKN with header line.
* Account assignments purchase requisitions
  DATA: T_EBKN_ALL type table of ebkn with header line.
* Shipping information purchase documents
  DATA: T_EKPV_ALL type table of ekpv with header line.

* Store plant data of T001W
  DATA: BEGIN OF I_T001W OCCURS 0,
           MANDT LIKE T001W-MANDT,
           WERKS LIKE T001W-WERKS,
           KUNNR LIKE T001W-KUNNR,
           VKORG LIKE T001W-VKORG,
           VTWEG LIKE T001W-VTWEG,
           SPART LIKE T001W-SPART,
           LPRIO LIKE KNVV-LPRIO,
        END OF I_T001W.

* Purchasing checking rules for standard document-types UB and LU
  DATA: BEGIN OF I_T161V OCCURS 0,
           BSTYP LIKE T161V-BSTYP,
           BSART LIKE T161V-BSART,
           RESWK LIKE T161V-RESWK,
           PRREG LIKE T161V-PRREG,
           REVFE like t161v-REVFE,
        END OF I_T161V.

DATA: BEGIN OF I_T161VN OCCURS 0,                 "^2133276
           BSTYP LIKE T161VN-BSTYP,
           BSART LIKE T161VN-BSART,
           RESWK LIKE T161VN-RESWK,
           PRREG LIKE T161VN-PRREG,
           REVFE like t161VN-REVFE,
           RESLO LIKE T161VN-RESLO,
        END OF I_T161VN.                            "v2133276

* Error table to store errors during selection process
  DATA: BEGIN OF GT_ERROR_TAB_SELECT OCCURS 0.
           INCLUDE STRUCTURE ERROR_TAB_RESCHED.
  DATA: END OF GT_ERROR_TAB_SELECT.


  DATA:    BEGIN OF OUTPUT OCCURS 1000.
              INCLUDE STRUCTURE BV03R.
  DATA:    END OF OUTPUT.
*---------------------------------------------------------------------*
* Variables                                                           *
*---------------------------------------------------------------------*
* Selektionsflag
  DATA: SELEKTION(1).
* Festwerte RV
  INCLUDE RVDIREKT.

* Variables to enable prioization between sales and pur-documents
  DATA: DOCTYPE_PUR(5)    TYPE C VALUE 'PUR',
        DOCTYPE_SALES(5)  TYPE C VALUE 'SALES',
        V_SORT_DOCTYPE(5) TYPE C,
        V_SORT_PRIO       TYPE C,
        V_SORT_PRIO1      TYPE C VALUE '1',
        V_SORT_PRIO2      TYPE C VALUE '2',
        V_SORT_PRIO3      TYPE C VALUE '3',
* Constants to differ calling method for correction record handling
        C_DO_APPEND(2)    TYPE C VALUE 'DA',
        C_NO_APPEND(2)    TYPE C VALUE 'NA',                 "1000455
* Variables for checking entered priorities
        gv_prio1(1)       type c value ' ',
        gv_prio2(1)       type c value ' ',
        gv_prio3(1)       type c value ' ',
        gv_prio4(1)       type c value ' ',
        gv_prio5(1)       type c value ' '.

*---------------------------------------------------------------------*
* Selection screen definitions                                        *
*---------------------------------------------------------------------*
  TABLES: RV03R.
  INCLUDE ZSDV03V02_SELECTION_SCREEN.

***********************************************************************
*                  VERARBEITUNGSTEIL                                  *
***********************************************************************

***********************************************************************
*                  HAUPTPROGRAMM                                      *
***********************************************************************

AT SELECTION-SCREEN.

PERFORM DELETE_INDX.

PERFORM INITIAL_CHECKS.

* Im Batch lokale Verbuchung - geringere Datenbankbelastung
IF SY-BATCH NE SPACE.
   SET UPDATE TASK LOCAL.
ENDIF.

* Nur bei Batch/Neuselektion
PERFORM SICHERHEITSABFRAGE.

* If materials selected or flag "unconf.docs required" is set, then
* don´t process product selection, but lock quantities    note 576113
IF S_MATNR NE SPACE OR P_MACO_C NE SPACE.
   SELEKTION               = CHARX.
ELSE.
  CLEAR SELEKTION.
ENDIF.

START-OF-SELECTION.

* Preparation --------------------------------------------------------*
IF P_DCREAT = 'X'.
   GV_DCREAT = 'C'.
ENDIF.

IF P_PURDOC = 'X'.
   PERFORM READ_T001W_T161V.
ENDIF.

PERFORM XTAB_PREPARE_SORT
   TABLES
      SORT_TAB
   CHANGING
      V_SORT_DOCTYPE.

* Determining whether APO and core-interface for ATP is active -------*
  Perform check_apo_cif_active
     changing gv_apoactive
              gv_logsys.

* Selecting relevant documents ---------------------------------------*
  IF P_SDDOCS = 'X'.
     if p_doctyp is initial.
        clear v_sort_prio.
     else.
        IF V_SORT_DOCTYPE = DOCTYPE_SALES.
           v_sort_prio = v_sort_prio1.
        else.
           v_sort_prio = v_sort_prio3.  "3 as PO/REQ/SALES
        endif.
     endif.
     PERFORM XTAB_SELECT_SALES USING V_SORT_PRIO.
  ENDIF.

  IF P_PURDOC = 'X'.
     if p_doctyp is initial.
        clear v_sort_prio.
     else.
        IF V_SORT_DOCTYPE = DOCTYPE_PUR.
           v_sort_prio = v_sort_prio1.
        else.
           v_sort_prio = v_sort_prio2.
        endif.
     endif.
     PERFORM XTAB_SELECT_PUR USING V_SORT_PRIO.
  ENDIF.

* Handling for unconfirmed documents ---------------------------------*
  PERFORM XTAB_SELECT_UNCONFIRMED_DOCS.

* Export flags to memory in order to access them later ---------------*
  EXPORT P_SDDOCS TO MEMORY ID 'RESCHED_SD'.
  EXPORT P_PURDOC TO MEMORY ID 'RESCHED_PUR'.

END-OF-SELECTION.

* Sorting input documents --------------------------------------------*
  PERFORM XTAB_SORT
     TABLES
        SORT_TAB.

* Prepare and check availability -------------------------------------*
  PERFORM XTAB_CHECK_AND_SAVE.

* Generate output list -----------------------------------------------*
  PERFORM XTAB_LIST.

* Free memory --------------------------------------------------------*
  FREE MEMORY ID 'RESCHED_SD'.
  FREE MEMORY ID 'RESCHED_PUR'.

* Save selection of processing on item/schedule line level to database
  GV_INDX_SRTFD      = 'V03R'.
  GV_INDX_SRTFD+4(11) = 'SDV03V02_II'.
  EXPORT GV_ITEM_OR_SCHED GV_DCREAT
         TO DATABASE INDX(SD) ID GV_INDX_SRTFD.

*&---------------------------------------------------------------------*
*&      Form  INITIAL_CHECKS
*&---------------------------------------------------------------------*
FORM INITIAL_CHECKS.

data: begin of lt_prio occurs 0,
         field like sort_tab-priority,
      end of lt_prio,
      lv_prio like sort_tab-priority,
      lv_sum  like ekpo-menge.

* Verify wether any of the document processing options has been set ---
IF P_SDDOCS IS INITIAL AND
   P_PURDOC IS INITIAL.
   MESSAGE E151(VV).
ENDIF.

*--- Verifying whether inputs are plausible ---------------------------

* Check if for priorities anything else but 0 or 1-5 entered
if p_doctyp ca '012345' and
   p_delpri ca '012345' and
   p_date   ca '012345' and
   p_docno  ca '012345' and
   p_itemno ca '012345'.
*  Fine
else.
   message e158(vv).
endif.

* Check if anything entered at all in the priority-fields
lv_sum = p_doctyp + p_delpri + p_date + p_docno + p_itemno.
if lv_sum = 0.
   message w161(vv).
endif.

IF ( P_DOCNO > P_ITEMNO AND NOT P_ITEMNO IS INITIAL ) OR
   ( P_DOCNO IS INITIAL AND P_ITEMNO > 0 ).
*  Item-number should not be ranked higher than document number
   MESSAGE E156(VV).
ENDIF.

* Check if a priority-value was entered twice
clear: gv_prio1, gv_prio2, gv_prio3, gv_prio4, gv_prio5.
refresh lt_prio.
lt_prio-field = p_doctyp.
  append lt_prio.
lt_prio-field = p_delpri.
  append lt_prio.
lt_prio-field = p_date.
  append lt_prio.
lt_prio-field = p_docno.
  append lt_prio.
lt_prio-field = p_itemno.
  append lt_prio.
loop at lt_prio.
   lv_prio = lt_prio-field.
   perform sort_prio_check
      using lv_prio.
endloop.

ENDFORM.                    " INITIAL_CHECKS

*---------------------------------------------------------------------*
*       FORM SICHERHEITSABFRAGE                                       *
*---------------------------------------------------------------------*
FORM SICHERHEITSABFRAGE.

  DATA: DA_TEXT1(35),
        DA_TEXT2(35),
        DA_ANSWER.

* Nicht im Batch
  CHECK SY-BATCH EQ SPACE AND P_SIMUL EQ SPACE.

  WRITE TEXT-006 TO DA_TEXT1+0(35).
  WRITE TEXT-007 TO DA_TEXT2+0(35).

  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
       EXPORTING
            DEFAULTOPTION = 'N'
            TEXTLINE1     = DA_TEXT1
            TEXTLINE2     = DA_TEXT2
            TITEL         = TEXT-008
       IMPORTING
            ANSWER        = DA_ANSWER.

  CASE DA_ANSWER.
    WHEN CHARN.
      LEAVE TO TRANSACTION SY-TCODE.
    WHEN CHARA.
      LEAVE TO TRANSACTION SY-TCODE.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.
*eject

*---------------------------------------------------------------------*
*       FORM XTAB_CHECK_AND_SAVE                                      *
*---------------------------------------------------------------------*
FORM XTAB_CHECK_AND_SAVE.

  DATA: EXP_TR_PROC_LV(1) TYPE C.

* sort xtab by lprio erdat vbeln posnr.

  IF P_ITEMLV = 'X'.
*    Processing on item level
     EXP_TR_PROC_LV = 'I'.
  ELSEIF P_SCHLV = 'X'.
*    Processing on schedule line level for stock transport orders and
*    scheduling agreements.
     EXP_TR_PROC_LV = 'S'.
  ENDIF.

  CALL FUNCTION 'SD_BACKORDER_CHECK_AND_SAVE'
       EXPORTING
            REPORT                 = 'SDV03V02'
            SIMUL                  = P_SIMUL
            IMP_TR_PROC_LV         = EXP_TR_PROC_LV
       TABLES
            INPUT                  = XTAB
            T_EBKN_ALL             = T_EBKN_ALL
            T_EKKN_ALL             = T_EKKN_ALL
            T_EKPV_ALL             = T_EKPV_ALL
            T_PDOC                 = T_PDOC
            T_PREQ                 = T_PREQ
            IMP_T_ERROR_TAB_SELECT = GT_ERROR_TAB_SELECT
       EXCEPTIONS
            OTHERS         = 1.

  IF SY-SUBRC = 1.
     MESSAGE X026(01) WITH 'SD_BACKORDER_CHECK_AND_SAVE'
                           'OTHERS'.
*  ENDIF.
  ELSE.

    DATA:   da_srtfd           LIKE indx-srtfd.

  da_srtfd            = 'V03R'.
  da_srtfd+4(8)       = sy-repid.
  da_srtfd+12(4)      = sy-datum+4(4).
  da_srtfd+16(6)      = sy-uzeit.

    IMPORT output FROM DATABASE indx(sd) ID da_srtfd.

    Loop at OUTPUT.
*         DELETE TABLE OUTPUT WITH TABLE KEY p_matnr = p_carrid.
    endloop.

    EXPORT output TO DATABASE indx(sd) ID da_srtfd.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM XTAB_LIST                                                *
*---------------------------------------------------------------------*
FORM XTAB_LIST.
  DATA: DA_VKORG LIKE VBAK-VKORG,
        DA_VTWEG LIKE VBAK-VTWEG.

  CALL FUNCTION 'ZSD_BACKORDER_LIST'
       EXPORTING
            VKORG          = DA_VKORG
            VTWEG          = DA_VTWEG
            REPORT         = 'SDV03V02'
*           READ_INDX      = P_RINDX
       TABLES
            INPUT          = XTAB
       EXCEPTIONS
            INDX_NOT_FOUND = 01
            OUTPUT_EMPTY   = 02.
  CASE SY-SUBRC.
    WHEN 1.
      MESSAGE S060 WITH 'SDV03V02'.
    WHEN 2.
      MESSAGE S061.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  XTAB_PREPARE_SORT
*&---------------------------------------------------------------------*
*       Preparing the statement to sort the internal table XTAB
*       according the values entered on the selection screen.
*----------------------------------------------------------------------*
*  -->  table: sort_tab  variable: lv_sort_doctype
*  <--  table: sort_tab  variable: lv_sort_doctype
*----------------------------------------------------------------------*
FORM XTAB_PREPARE_SORT
       TABLES
          P_SORT_TAB STRUCTURE SORT_TAB
       CHANGING
          V_SORT_DOCTYPE.

CLEAR SORT_TAB.

*--- Analyzing inputs for document type--------------------------------
IF P_DOCTYP NE ' '.
   P_SORT_TAB-FIELDNAME = 'SORT_DOCTYPE'.
   P_SORT_TAB-PRIORITY  = P_DOCTYP.
   APPEND P_SORT_TAB.
ENDIF.

IF P_CUSTOR EQ 'X'.
*  SD documents will be prioritized
   V_SORT_DOCTYPE = DOCTYPE_SALES.
ELSE.
*  Purchasing documents will be prioritized
   V_SORT_DOCTYPE = DOCTYPE_PUR.
ENDIF.

*--- Analyzing input for delivery priority ----------------------------
IF   P_DELPRI NE ' '.
     P_SORT_TAB-FIELDNAME = 'LPRIO'.
     P_SORT_TAB-PRIORITY  = P_DELPRI.
     APPEND P_SORT_TAB.
ENDIF.

*--- Analyzing input for date -----------------------------------------
IF   P_DATE NE ' '.
     P_SORT_TAB-FIELDNAME = 'ERDAT'.
     P_SORT_TAB-PRIORITY  = P_DATE.
     APPEND P_SORT_TAB.
ENDIF.

*--- Analyzing input for document number ------------------------------
IF   P_DOCNO NE ' '.
     P_SORT_TAB-FIELDNAME = 'VBELN'.
     P_SORT_TAB-PRIORITY  = P_DOCNO.
     APPEND P_SORT_TAB.
ENDIF.

*--- Analyzing input for document item --------------------------------
IF   P_ITEMNO NE ' '.
     P_SORT_TAB-FIELDNAME = 'POSNR'.
     P_SORT_TAB-PRIORITY  = P_ITEMNO.
     APPEND P_SORT_TAB.
ENDIF.

SORT P_SORT_TAB BY PRIORITY.

ENDFORM.                    " XTAB_PREPARE_SORT

*&---------------------------------------------------------------------*
*&      Form  SORT_PRIO_CHECK
*&---------------------------------------------------------------------*
*       Validate if a priority value has been entered more than once
*----------------------------------------------------------------------*
*  -->  P_PRIORITY  Priority which shall be validated if already entered
*----------------------------------------------------------------------*
FORM SORT_PRIO_CHECK
        USING P_PRIORITY LIKE SORT_TAB-PRIORITY.

   case p_priority.
      when '1'.
         if gv_prio1 is initial.
            gv_prio1 = 'X'.
         else.
            message E165(VV).
         endif.
      when '2'.
         if gv_prio2 is initial.
            gv_prio2 = 'X'.
         else.
            message E165(VV).
         endif.
      when '3'.
         if gv_prio3 is initial.
            gv_prio3 = 'X'.
         else.
            message E165(VV).
         endif.
      when '4'.
         if gv_prio4 is initial.
            gv_prio4 = 'X'.
         else.
            message E165(VV).
         endif.
      when '5'.
         if gv_prio5 is initial.
            gv_prio5 = 'X'.
         else.
            message E165(VV).
         endif.
   endcase.

ENDFORM.                    " SORT_PRIO_CHECK


*&---------------------------------------------------------------------*
*&      Form  XTAB_SORT
*&---------------------------------------------------------------------*
*       Sort table xtab according to entries on selection screen.
*
*       In order to ensure a steady sort-output for records which match
*       in the field-values of the sort-criterias a - to the user non-
*       visible 6th and 7th criteria (delivery date, schedule line no.)
*       is always used.
*       This is only necessary when processing on schedule line level
*       (when processing on item level the records are sorted in the
*       the right order just before availability-check) and because MRP
*       might create schedule lines backwards (earliest date has highest
*       schedule line number).
*----------------------------------------------------------------------*
*  -->  table: p_sort_tab
*----------------------------------------------------------------------*
FORM XTAB_SORT
     TABLES
        P_SORT_TAB STRUCTURE SORT_TAB.

* Local variable defintions -------------------------------------------
DATA: LV_SORT1 LIKE DD03D-FIELDNAME,
      LV_SORT2 LIKE DD03D-FIELDNAME,
      LV_SORT3 LIKE DD03D-FIELDNAME,
      LV_SORT4 LIKE DD03D-FIELDNAME,
      LV_SORT5 LIKE DD03D-FIELDNAME,
      LV_INDEX LIKE SY-TABIX.

LV_INDEX = 1.

LOOP AT P_SORT_TAB.
   CASE LV_INDEX.
      WHEN 1.
         LV_SORT1 = P_SORT_TAB-FIELDNAME.
      WHEN 2.
         LV_SORT2 = P_SORT_TAB-FIELDNAME.
      WHEN 3.
         LV_SORT3 = P_SORT_TAB-FIELDNAME.
      WHEN 4.
         LV_SORT4 = P_SORT_TAB-FIELDNAME.
      WHEN 5.
         LV_SORT5 = P_SORT_TAB-FIELDNAME.
   ENDCASE.
   LV_INDEX = LV_INDEX + 1.
ENDLOOP.

IF P_SCHLV = 'X'.
*  When on schedule line level use additional sort-criterias.
   SORT XTAB BY (LV_SORT1) (LV_SORT2) (LV_SORT3)
                (LV_SORT4) (LV_SORT5) EINDT ETENR.
ELSEIF P_ITEMLV = 'X'.
   SORT XTAB BY (LV_SORT1) (LV_SORT2) (LV_SORT3)
                (LV_SORT4) (LV_SORT5).
ENDIF.

ENDFORM.                    " XTAB_SORT

*&---------------------------------------------------------------------*
*&      Form  XTAB_SELECT_UNCONFIRMED_DOCS
*&---------------------------------------------------------------------*
*       If the user has flagged the parameter 'Unconfirmed documents
*       required' only those materials (on plant-level) will be
*       rescheduled for which at least one document has an unconfirmed
*       quantity. If not, the document will be excluded from selection
*----------------------------------------------------------------------*
FORM XTAB_SELECT_UNCONFIRMED_DOCS.

DATA: BEGIN OF DA_MATWRK,
        MATNR LIKE VBAP-MATNR,
        WERKS LIKE VBAP-WERKS,
      END OF DA_MATWRK.

  IF P_MACO_C NE SPACE.
*   First of all delete duplicate entries which might have been stored
*   during document selection (multiple material/plant-combination).
    DELETE ADJACENT DUPLICATES FROM MATUNV
           COMPARING MATNR WERKS.
    DESCRIBE TABLE MATUNV LINES DA_TABIX.
    SORT MATUNV BY MATNR WERKS.
    IF DA_TABIX = 0.
      REFRESH: XTAB.
      CLEAR  : XTAB.
    ELSE.
      DA_TABIX = 0.
      LOOP AT XTAB.
        DA_MATWRK-MATNR      = XTAB-MATNR.
        DA_MATWRK-WERKS      = XTAB-WERKS.
        READ TABLE MATUNV WITH KEY DA_MATWRK BINARY SEARCH.
        IF SY-SUBRC NE 0.
          DELETE XTAB.
          DA_TABIX           = DA_TABIX + 1.
        ELSE.
          CHECK DA_TABIX > 0.
          XTAB-ISORT         = XTAB-ISORT - DA_TABIX.
          MODIFY XTAB.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDFORM.                    " XTAB_SELECT_UNCONFIRMED_DOCS

*&---------------------------------------------------------------------*
*& Include-list                                                        *
*&---------------------------------------------------------------------*

* Includes for both sales and stock transport documents
  INCLUDE SDV03_GEN01.    "FORM READ_T001W_T161V

* Includes for sales documents
  INCLUDE ZSDV03_SALES01.  "FORM XTAB_SELECT_SALES

* Includes for stock transport documents (p.o.s and sched. agreements)
  INCLUDE SDV03_PDOC01.   "FORM XTAB_SELECT_PUR
  INCLUDE SDV03_PDOC02.   "FORM XTAB_SELECT_PUR_PURDOC_ITEMLV
  INCLUDE SDV03_PDOC03.   "FORM XTAB_SELECT_PUR_PURDOC_SCHLV
  INCLUDE SDV03_PDOC04.   "FORM PURDOC_PREPARE_HEADER_ITEM
  INCLUDE SDV03_PDOC05.   "FORM INITIAL_BUILD_COR_PURDOC

* Includes for stock transport requisitions
  INCLUDE SDV03_PREQ01.   "FORM INITIAL_BUILD_COR_PREQ
  INCLUDE SDV03_PREQ02.   "FORM XTAB_SELECT_PUR_PREQ

*&---------------------------------------------------------------------*
*&      Form  check_apo_cif_active
*&---------------------------------------------------------------------*
*       Determine whether APO is active and whether the CIF interface
*       is active for ATP
*----------------------------------------------------------------------*
*      <--P_APO_ACTIVE APO active or not
*      <--P_LOGSYS     CIF interface active or not
*----------------------------------------------------------------------*
FORM check_apo_cif_active
    CHANGING
        P_APOACTIVE TYPE C
        P_LOGSYS    LIKE DESMAT_ATP-LOGSYS.

* Determine whether an APO is active
  PERFORM APO_ACTIVE CHANGING P_APOACTIVE.

  IF NOT P_APOACTIVE IS INITIAL.

* Determine whether core interface is active for ATP check
    PERFORM CIF_ACTIVE_ATPCHECK CHANGING P_APOACTIVE.

* Determine own logical system
    IF NOT P_APOACTIVE IS INITIAL.
      PERFORM GET_OWN_LOGICAL_SYSTEM CHANGING P_LOGSYS.
    ENDIF.
  ENDIF.

ENDFORM.                    " check_apo_cif_active

*&---------------------------------------------------------------------*
*&      Form  APO_ACTIVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_APOACTIVE  text                                            *
*----------------------------------------------------------------------*

FORM APO_ACTIVE CHANGING P_APOACTIVE.

  STATICS: S_FLAG      LIKE ATP00-XFELD,
           S_APOACTIVE TYPE C.

  IF S_FLAG IS INITIAL.
    CALL FUNCTION 'OUTBOUND_CALL_01010000_P'
         IMPORTING
              EF_APO_ACTIVE = S_APOACTIVE.

    S_FLAG = CHARX.
  ENDIF.

  IF S_APOACTIVE IS INITIAL.
    CLEAR: P_APOACTIVE.
  ELSE.
    P_APOACTIVE = CHARX.
  ENDIF.

ENDFORM.                               " APO_ACTIVE
*&---------------------------------------------------------------------*
*&      Form  CIF_ACTIVE_ATPCHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ACTIVE  text                                               *
*----------------------------------------------------------------------*

FORM CIF_ACTIVE_ATPCHECK CHANGING P_ACTIVE.

  STATICS: S_FLAG,
           S_ACTIVE,
           S_ND_ACTIVE .

* call BTE only once per transaction
  IF S_FLAG IS INITIAL.
    PERFORM CIF_ND_ACTIVE
            CHANGING
                S_ND_ACTIVE.

    IF NOT S_ND_ACTIVE IS INITIAL.
      CALL FUNCTION 'OUTBOUND_CALL_01000802_P'
           IMPORTING
                EF_ACTIVE = S_ACTIVE
           EXCEPTIONS
                OTHERS    = 1.
      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
    ENDIF.

    S_FLAG = CHARX.
  ENDIF.

  P_ACTIVE = S_ACTIVE.

ENDFORM.                               " CIF_ACTIVE_ATPCHECK
*&---------------------------------------------------------------------*
*&      Form  CIF_IMOD_DESTINATIONS_ATPCHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_S_FLTMATX  text                                            *
*      -->P_P_DESMATX  text                                            *
*      -->P_P_DESTX  text                                              *
*----------------------------------------------------------------------*

FORM CIF_IMOD_DESTINATIONS_ATPCHECK
     TABLES
         P_FLTMATX STRUCTURE FLTMAT_ATP
         P_DESMATX STRUCTURE DESMAT_ATP
         P_DESTX STRUCTURE DEST_ATP.

  STATICS: S_ND_ACTIVE.

  PERFORM CIF_ND_ACTIVE
          CHANGING
              S_ND_ACTIVE.

  CHECK NOT S_ND_ACTIVE IS INITIAL.

  CALL FUNCTION 'OUTBOUND_CALL_01000803_P'
       TABLES
            IT_FLTMAT = P_FLTMATX
            ET_DESMAT = P_DESMATX
            ET_DEST   = P_DESTX
       EXCEPTIONS
            OTHERS    = 1.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                               " CIF_IMOD_DESTINATIONS_ATPCHECK


*&---------------------------------------------------------------------*
*&      Form  cif_nd_active
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_S_ND_ACTIVE  text
*----------------------------------------------------------------------*
FORM CIF_ND_ACTIVE CHANGING P_ND_ACTIVE LIKE ATP00-XFELD.

  STATICS: S_FLAG,
           S_ND_ACTIVE.

  IF NOT S_FLAG IS INITIAL.
    P_ND_ACTIVE = S_ND_ACTIVE.
    EXIT.
  ENDIF.

  CALL FUNCTION 'ND_EXITS_ACTIVE_CHECK'
       EXCEPTIONS
            EXITS_NOT_ACTIVE = 1
            OTHERS           = 2.
  IF SY-SUBRC = 0.
    S_ND_ACTIVE = CHARX.
  ELSE.
    CLEAR: S_ND_ACTIVE.
  ENDIF.

  P_ND_ACTIVE = S_ND_ACTIVE.
  S_FLAG      = CHARX.

ENDFORM.                               " cif_nd_active
*&---------------------------------------------------------------------*
*&      Form  GET_OWN_LOGICAL_SYSTEM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_S_LOGSYS  text                                             *
*----------------------------------------------------------------------*
FORM GET_OWN_LOGICAL_SYSTEM CHANGING P_LOGSYS.

  STATICS: S_LOGSYS LIKE DESMAT_ATP-LOGSYS,
           S_FLAG.

  IF S_FLAG = CHARX.
    P_LOGSYS = S_LOGSYS.
    EXIT.
  ENDIF.

  CALL FUNCTION 'OWN_LOGICAL_SYSTEM_GET'
       IMPORTING
            OWN_LOGICAL_SYSTEM             = P_LOGSYS
       EXCEPTIONS
            OWN_LOGICAL_SYSTEM_NOT_DEFINED = 1
            OTHERS                         = 2.
  IF SY-SUBRC <> 0.
    CLEAR: P_LOGSYS.
  ENDIF.

  S_LOGSYS = P_LOGSYS.
  S_FLAG   = CHARX.

ENDFORM.                               " GET_OWN_LOGICAL_SYSTEM
***********************************************************************
*                  Unterroutinen                                      *
***********************************************************************

*&---------------------------------------------------------------------*
*&      Form  DELETE_INDX
*&      delete all entries from INDX (SD) except the youngest one
*&---------------------------------------------------------------------*
FORM DELETE_INDX.

  " this FORM runs at the beginning of rescheduling
  " the commit is preventing parallel
  "     rescheduling processes to lock INDX

  DATA:   DA_SRTFD_LAST      LIKE INDX-SRTFD,
          DA_SRTFD_LIKE      LIKE INDX-SRTFD.
  DATA:   BEGIN OF SA_SRTFD,
            MANDT TYPE MANDT,
            RELID TYPE INDX_RELID,
            SRTFD TYPE INDX_SRTFD,
            SRTF2 TYPE INDX_SRTF2,
          END   OF SA_SRTFD.
  DATA:   BEGIN OF TA_SRTFD  occurs 0,
            MANDT TYPE MANDT,
            RELID TYPE INDX_RELID,
            SRTFD TYPE INDX_SRTFD,
            SRTF2 TYPE INDX_SRTF2,
          END   OF TA_SRTFD.
  DATA:   DA_DELETED.

  DA_SRTFD_LIKE       = 'V03R'.     "char  1- 4 = tcode
  DA_SRTFD_LIKE+4(8)  = 'SDV03V02'. "char  5-12 = repid
  DA_SRTFD_LIKE+12    = '%'.        "char 13-22 = anything

  SELECT MANDT RELID SRTFD SRTF2
    FROM INDX
         INTO TABLE TA_SRTFD
              WHERE RELID = 'SD'
                AND SRTFD LIKE DA_SRTFD_LIKE.

  DELETE TA_SRTFD WHERE SRTFD+12(4) CN '0123456789'.
         "this deletes SRTFD = V03RSDV03V02
         "                OR = V03RSDV03V02_II
         "only SRTFD

  CHECK NOT TA_SRTFD[] IS INITIAL.

  SORT TA_SRTFD BY SRTFD DESCENDING.
  DELETE ADJACENT DUPLICATES FROM TA_SRTFD COMPARING SRTFD.

* keep youngest entry (char13-22 = MMDDHHMMSS without YYYY)
*      by deleting all other entries
*      considering change of year within following loop
*      since the space in SRTFD did not allow for the year
*      (otherwise, simply
*       DELETE TA_SRTFD INDEX 1.
*       would be sufficient)
  LOOP AT TA_SRTFD INTO SA_SRTFD.
    IF  SA_SRTFD-SRTFD+12(4) LE sy-datum+4(4)
    AND DA_DELETED           IS INITIAL.
      DELETE TA_SRTFD INDEX SY-TABIX.
      DA_DELETED = 'X'.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF DA_DELETED IS INITIAL.
*    the year changed and there is not yet
*    any MMDD entry from the new year
     DELETE TA_SRTFD INDEX 1.
  ENDIF.

  CHECK NOT TA_SRTFD[] IS INITIAL.

*  DELETE INDX FROM TABLE TA_SRTFD.
  LOOP AT TA_SRTFD INTO SA_SRTFD.
    DELETE FROM DATABASE INDX(SD) ID SA_SRTFD-SRTFD.
  ENDLOOP.

  CALL FUNCTION 'DB_COMMIT'.

ENDFORM. "DELETE_INDX
