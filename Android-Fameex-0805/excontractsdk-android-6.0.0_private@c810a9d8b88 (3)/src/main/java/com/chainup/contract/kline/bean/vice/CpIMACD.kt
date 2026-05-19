package com.yjkj.chainup.new_version.kline.bean.vice

import com.yjkj.chainup.new_version.kline.bean.CpIndex


/**
 * @Author: Bertking
 * @Date：2019/2/25-10:37 AM
 *@ Description: MACD Index (Similarities and Differences Moving Average)
 * https://baike.baidu.com/item/IMACD%E6%8C%87%E6%A0%87/6271283?fr=aladdin
 *
 *The MACD indicator is formed by combining two lines and one column. The fast line is DIF, the slow line is DEA, and the histogram is MACD
 */
interface CpIMACD : CpIndex {
    /**
     *DEA value
     */
    var DEA: Float
    /**
     *Calculate DIF
     */
    var DIF: Float
    var MACD: Float

}
