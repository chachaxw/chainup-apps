package com.yjkj.chainup.new_version.kline.bean.vice

import com.yjkj.chainup.new_version.kline.bean.Index


/**
 * @Author: Bertking
 * @Date 2023/2/25-10:37 AM
 *@description: MACD Index (Similarities and Differences Moving Average)
 * https://baike.baidu.com/item/IMACD%E6%8C%87%E6%A0%87/6271283?fr=aladdin
 *
 *The MACD indicator is formed by combining two lines and one column, with the fast line being DIF, the slow line being DEA, and the bar chart being MACD
 */
interface IMACD : Index {
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
