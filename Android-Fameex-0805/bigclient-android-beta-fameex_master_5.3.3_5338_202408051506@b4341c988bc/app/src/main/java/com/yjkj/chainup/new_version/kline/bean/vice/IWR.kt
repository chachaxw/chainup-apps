package com.yjkj.chainup.new_version.kline.bean.vice

import com.yjkj.chainup.new_version.kline.bean.Index


/**
 * @Author: Bertking
 * @Date 2023/2/25-10:43 AM
 *@description: WR indicator
 *
 *IWR, also known as the Williams Overbuy/Oversell Index or the Williams Overbuy/Oversell Index, is a technical indicator used to analyze short-term buying and selling trends in the market.
 *
 * https://baike.baidu.com/item/wR%E6%8C%87%E6%A0%87
 */
interface IWR : Index {
    var R: Float
}
