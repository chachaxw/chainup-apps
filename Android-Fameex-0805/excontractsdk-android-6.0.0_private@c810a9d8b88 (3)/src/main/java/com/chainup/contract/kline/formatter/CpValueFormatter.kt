package com.yjkj.chainup.new_version.kline.formatter

import com.chainup.contract.utils.CpBigDecimalUtils
import com.yjkj.chainup.new_version.kline.base.CpIValueFormatter

/**
 * @Author: Bertking
 * @Date：2019/3/11-11:16 AM
 * @Description:
 */
class CpValueFormatter(val scale:Int? = -1) : CpIValueFormatter {
    override fun format(value: Float): String {
        return if(scale!=null && scale!=-1){
            CpBigDecimalUtils.showSNormal(value.toString(),scale)
        }else{
            CpBigDecimalUtils.showSNormal(value.toString())
        }

    }
}
