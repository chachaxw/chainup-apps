package com.yjkj.chainup.new_version.kline.bean.vice

import com.yjkj.chainup.new_version.kline.bean.CpIndex


/**
 * @Author: Bertking
 * @Date：2019/2/25-10:43 AM
 *@ Description: WR indicator
 *
 *IWR is a swing type indicator, also known as the Williams Overbuy/Oversold Index, and the Williams Overbuy/Oversold Index. It is a technical indicator for analyzing short-term trading trends in the market.
 *
 * https://baike.baidu.com/item/wR%E6%8C%87%E6%A0%87
 */
interface CpIWR : CpIndex {
    var R: Float
}
