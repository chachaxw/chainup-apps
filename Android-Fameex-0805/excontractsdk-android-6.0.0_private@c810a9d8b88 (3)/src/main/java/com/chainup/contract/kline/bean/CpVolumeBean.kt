package  com.yjkj.chainup.new_version.kline.bean


/**
 * @Author: Bertking
 * @Date：2019/2/25-10:55 AM
 * @Description:
 */
interface CpVolumeBean : CpIndex {
    /**
     *Opening price
     */
    var openPrice: Float
    /**
     *Closing Price
     */
    var closePrice: Float
    /**
     *Volume
     */
    val volume: Float
    /**
     *Average quantity of five (month, day, hour, minute, 5 minutes, etc.)
     */
    val volume4MA5: Float

    /**
     *Average amount of ten (month, day, hour, minute, 5 minutes, etc.)
     */
    var volume4MA10: Float
}
