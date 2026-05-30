"Name: \PR:SAPLV60A\FO:USEREXIT_PRICING_PREPARE_TKOMK\SE:BEGIN\EI
ENHANCEMENT 0 Z_TAX_INVOICE.
*
**  Ensure Avalara Tax call for sales from US->CA. See OS Note 2016990
**  Dietmar Hinz / DMA Inc. / 05/24/2016
If tkomk-land1 = 'CA' and
   tkomk-aland = 'US'.
  tkomk-txjcd = XVBRP-TXJCD.
endif.

ENDENHANCEMENT.
