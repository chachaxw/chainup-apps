package com.yjkj.chainup.new_version.kline.bean.vice

import com.yjkj.chainup.new_version.kline.bean.Index


/**
 * @Author: Bertking
 * @Date 2023/2/25-10:48 AM
 *@description: IRSI (relative strength) indicator
 * https://baike.baidu.com/item/IRSI%E6%8C%87%E6%A0%87
 */
interface IRSI : Index {
    var RSI: Float
}
