package com.yjkj.chainup.new_version.kline.bean


/**
 * @Author: Bertking
 * @Date：2019/2/25-10:56 AM
 * @Description:
 */
interface CpCandleBean : CpIndex {
    /**
     *Opening price
     */
    var openPrice: Float
    /**
     *Closing Price
     */
    var closePrice: Float
    /**
     *Maximum Price
     */
    var highPrice: Float
    /**
     *Lowest price
     */
    var lowPrice: Float


    /*************
     *MA data (moving average indicator)
     * https://baike.baidu.com/item/MA%E6%8C%87%E6%A0%87
     * *********************/
    /**
     *Average price of five (month, day, hour, minute, 5 points, etc.)
     */
    var price4MA5: Float
    /**
     *Average price of ten (month, day, hour, minute, 5 points, etc.)
     */
    var price4MA10: Float
    /**
     *Average price of twenty (month, day, hour, minute, 5 points, etc.)
     */
    var price4MA20: Float
    /**
     *Average price of thirty (month, day, hour, minute, 5 points, etc.)
     */
    var price4MA30: Float
    /**
     *Average price of 60 (month, day, hour, minute, 5 points, etc.)
     */
    var price4MA60: Float


    /*****************
     *Boll indicator (Bolin line indicator)
     * https://baike.baidu.com/item/%E5%B8%83%E6%9E%97%E7%BA%BF%E6%8C%87%E6%A0%87/3325894
     * **************************/

    /**
     *Upper rail line
     */
    var up: Float
    /**
     *Midrail line
     */
    var mb: Float
    /**
     *Lower trajectory
     */
    var dn: Float
}
