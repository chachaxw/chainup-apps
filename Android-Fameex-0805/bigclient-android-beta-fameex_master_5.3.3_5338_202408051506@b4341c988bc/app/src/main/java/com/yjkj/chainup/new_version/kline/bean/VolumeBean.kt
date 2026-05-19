package  com.yjkj.chainup.new_version.kline.bean


/**
 * @Author: Bertking
 * @Date 2023/2/25-10:55 AM
 * @Description:
 */
interface VolumeBean : Index {
    /**
     *Opening price
     */
    var openPrice: Float
    /**
     *Closing price
     */
    var closePrice: Float
    /**
     *Trading volume
     */
    val volume: Float
    /**
     *Five (month, day, hour, minute, 5 minutes, etc.) average quantity
     */
    val volume4MA5: Float

    /**
     *Average quantity of ten (month, day, hour, minute, 5 minutes, etc.)
     */
    var volume4MA10: Float
}
