"Name: \FU:RV_ACCOUNTING_DOCUMENT_CREATE\SE:END\EI
ENHANCEMENT 0 ZTAX_UPDATE.
*
*& Author : Dietmar Hinz / DMA Inc. / 06/08/2016
*& Description : call function that updates the Avalara tax audit DB
*&               for documents that contain tax amounts that were
*&               calculated without Avalara, but should be reported
*&               in Avalara
   CALL FUNCTION 'ZTAX_UPDATE_AUDIT_REGISTER'
     EXPORTING
       CVBRK      = vbrk
       XACCIT     = xaccit
       doc_number = XVBRP_KEY-VBELN
     TABLES
       CVBRP      = xvbrp.

ENDENHANCEMENT.
