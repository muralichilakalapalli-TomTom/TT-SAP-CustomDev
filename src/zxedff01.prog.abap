
*&---------------------------------------------------------------------*
*&      Form  MOVE
*&---------------------------------------------------------------------*
*  This form populate the   E1EDKA1 segment depending the value in     *
*  formal parameter and returns back the workarea                      *
*----------------------------------------------------------------------*
FORM move USING p_field p_value CHANGING value(lwa_e1edka1) TYPE e1edka1.

  IF p_field = 'PARVW' .                            " if for parter role
    lwa_e1edka1-parvw = p_value.
  ELSEIF  p_field = 'NAME1' .                       " for parter name
    lwa_e1edka1-name1 = p_value.
  ELSEIF  p_field = 'NAME2' .
    lwa_e1edka1-name2 = p_value.
  ELSEIF  p_field = 'NAME3' .
    lwa_e1edka1-name3 = p_value.
  ELSEIF  p_field = 'NAME4' .
    lwa_e1edka1-name4 = p_value.
  ELSEIF  p_field =  'STRAS'.
    lwa_e1edka1-stras = p_value.
  ELSEIF  p_field =  'STRS2'.
    lwa_e1edka1-strs2 = p_value.
  ELSEIF  p_field =  'ORT01' .
    lwa_e1edka1-ort01 = p_value.
  ELSEIF  p_field =  'PSTLZ' .
    lwa_e1edka1-pstlz = p_value.

  ELSEIF  p_field =  'PSTL2'.
    lwa_e1edka1-pstl2 = p_value.

  ELSEIF  p_field =  'LAND1' .
    lwa_e1edka1-land1 = p_value.

  ELSEIF  p_field =  'REGIO' .
    lwa_e1edka1-regio = p_value.
  ELSEIF  p_field =  'LIFNR' .
    lwa_e1edka1-LIFNR = p_value.

  ENDIF.
  ENDFORM .
