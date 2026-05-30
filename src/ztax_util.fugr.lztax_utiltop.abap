FUNCTION-POOL ZTAX_UTIL.                    "MESSAGE-ID ..

tables: t005, ttxd, ztax_difference.

data: lin type i.
data: item_tax like vbrp-kzwi3.
data: tax_base like vbrp-kzwi2.
data: item_jur_cnt like TAX_FRC_ITEM_IN00-NR_JUR_LEVELS.
data: i_sap_control_data like SAP_CONTROL_DATA.
data: i_tax_frc_head_in like TAX_FRC_HEAD_IN00.
data: begin of i_tax_frc_item_in occurs 0.
       include structure TAX_FRC_ITEM_IN00.
data: end of i_tax_frc_item_in.
data: begin of i_tax_frc_jur_level_in occurs 0.
       include structure TAX_FRC_JUR_LEVEL_IN00.
data: end of i_tax_frc_jur_level_in.

data: begin of jur_level occurs 0,
        txjlv like TAX_FRC_JUR_LEVEL_IN00-txjlv,
        kbetr like vbrp-kzwi3,
      end of jur_level.

data: matkl type mara-matkl,
      xprcd type ttxp-xprcd,
      mtart type mara-mtart.
