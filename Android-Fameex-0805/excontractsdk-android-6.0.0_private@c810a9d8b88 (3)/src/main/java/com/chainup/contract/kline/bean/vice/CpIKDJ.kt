package com.yjkj.chainup.new_version.kline.bean.vice

import com.yjkj.chainup.new_version.kline.bean.CpIndex


/**
 * @Author: Bertking
 * @Date：2019/2/25-10:34 AM
 *@ Description: KDJ index (random index) interface
 * https://baike.baidu.com/item/IKDJ%E6%8C%87%E6%A0%87/6328421?fr=aladdin&fromid=3423560&fromtitle=kdj
 */
interface CpIKDJ : CpIndex {
    var K: Float
    var D: Float
    var J: Float
}
