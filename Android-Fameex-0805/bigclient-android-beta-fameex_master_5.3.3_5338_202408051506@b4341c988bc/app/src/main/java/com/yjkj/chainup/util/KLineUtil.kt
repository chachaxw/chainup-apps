package com.yjkj.chainup.util

import com.tencent.mmkv.MMKV
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.new_version.kline.view.MainKlineViewStatus
import com.yjkj.chainup.new_version.kline.view.vice.ViceViewStatus
import java.lang.IndexOutOfBoundsException

/**
 * @Author: Bertking
 * @Date 2023/3/19-11:52 AM
 *Description: Configuration items related to K line
 */
object KLineUtil {
    private val mmkv: MMKV = MMKV.mmkvWithID("kline_configuration")

    /**
     *Current scale of KLine
     */
    private const val CURRENT_TIME = "cur_time"


    private const val CURRENT_TIME_CONTENT = "cur_time_content"

    /**
     *Secondary image indicators
     */
    private const val VICE_INDEX = "vice_index"

    /**
     *Main image indicators
     */
    private const val MAIN_INDEX = "main_index"


    /**
     *Obtain the scale of Kline
     */
    fun getKLineScale(): ArrayList<String> {
        var list = arrayListOf<String>()
        list.add("1min")
        list.add("5min")
        list.add("15min")
        list.add("30min")
        list.add("60min")
        list.add("1day")
        list.add("1week")
        list.add("1month")


        val klineScaleJSONArray = PublicInfoDataService.getInstance().getKlineScale(null)
        if (klineScaleJSONArray != null && klineScaleJSONArray.length() > 0) {
            list.clear()
            for (i in 0..klineScaleJSONArray.length()) {
                val item = klineScaleJSONArray.optString(i)
                if(item.isNotEmpty()){
                    list.add(klineScaleJSONArray.optString(i))
                }
            }
        }

        /**
         *Add time sharing
         */
        list.add(0, "line")
        return list
    }


    /**
     *@Return to obtain the current scale of KLine
     *TODO array out of bounds exception
     */
    fun getCurTime4KLine(): HashMap<Int, String> {
        return try {
            hashMapOf<Int, String>(getCurTime4Index() to getKLineScale()[if (getCurTime4Index() < 0) 0 else getCurTime4Index()])
        } catch (e: IndexOutOfBoundsException) {
            e.printStackTrace()
            hashMapOf((getCurTime4Index() to getKLineScale()[0]))
        }
    }

    fun setCurTime(curTime: String) {
        mmkv.encode(CURRENT_TIME_CONTENT, curTime)
    }

    fun getCurTime(): String {
        return mmkv.decodeString(CURRENT_TIME_CONTENT, "15min")
    }


    /**
     *@return Get the subscript of KLine's current scale
     */
    fun getCurTime4Index(): Int {
        return mmkv.decodeInt(CURRENT_TIME, getKLineScale().indexOf("15min"))
    }

    /**
     *Save the current scale of KLine
     *@param curPosition KLine's current scale subscript
     */
    fun setCurTime4KLine(curPosition: Int) {
        mmkv.encode(CURRENT_TIME, curPosition)
    }

    /**
     *Set sub image indicators
     *Param status sub image indicator
     */
    fun setViceIndex(status: Int) {
        mmkv.encode(VICE_INDEX, status)
    }

    /**
     *Obtain sub image indicators
     *@return sub image indicator
     */
    fun getViceIndex(): Int = mmkv.decodeInt(VICE_INDEX, ViceViewStatus.NONE.status)


    /**
     *Set main image indicators
     *@param status main graph indicator
     */
    fun setMainIndex(status: Int) {
        mmkv.encode(MAIN_INDEX, status)
    }

    /**
     *Obtain main image indicators
     *@return Main image indicator
     */
    fun getMainIndex(): Int = mmkv.decodeInt(MAIN_INDEX, MainKlineViewStatus.MA.status)

    fun getKLineDefaultScale(): ArrayList<String> {
        var list = arrayListOf<String>()
        list.add("15min")
        list.add("60min")
        list.add("4h")
        list.add("1day")
        list.add("1week")
        return list
    }
}
