package com.yjkj.chainup.new_version.kline.bean


/**
 * @Author: Bertking
 * @Date 2023/2/25-10:56 AM
 * @Description:
 */
interface CandleBean : Index {
    /**
     *Opening price
     */
    var openPrice: Float
    /**
     *Closing price
     */
    var closePrice: Float
    /**
     *Maximum price
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
     *Five (month, day, hour, minute, 5 minutes, etc.) average price
     */
    var price4MA5: Float
    /**
     *Ten (month, day, hour, minute, 5 minutes, etc.) average price
     */
    var price4MA10: Float
    /**
     *Twenty (month, day, hour, minute, 5 minutes, etc.) average price
     */
    var price4MA20: Float
    /**
     *Thirty (month, day, hour, minute, 5 minutes, etc.) average price
     */
    var price4MA30: Float
    /**
     *Average price of sixty (month, day, hour, minute, 5 minutes, etc.)
     */
    var price4MA60: Float


    /*****************
     *Ball indicator (Bollinger Line indicator)
     * https://baike.baidu.com/item/%E5%B8%83%E6%9E%97%E7%BA%BF%E6%8C%87%E6%A0%87/3325894
     * **************************/

    /**
     *Upper track
     */
    var up: Float
    /**
     *Midline
     */
    var mb: Float
    /**
     *Lower track line
     */
    var dn: Float
}
