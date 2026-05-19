package com.chainup.contract.utils

import android.content.Context
import com.chainup.contract.R
import com.chainup.contract.app.CpMyApp
import com.yjkj.chainup.manager.CpLanguageUtil
import com.yjkj.chainup.new_version.kline.view.cp.MainKlineViewStatus
import com.yjkj.chainup.new_version.kline.view.vice.CpViceViewStatus
import kotlinx.android.synthetic.main.cp_activity_market_detail4.view.*
import java.lang.IndexOutOfBoundsException

/**
 * @Author: Bertking
 * @Date：2019/3/19-11:52 AM
 *@ Description: Configuration items related to K line
 */
object CpKLineUtil {

    /**
     *Current scale of KLine
     */
    private const val CURRENT_TIME = "cur_time"


    private const val CURRENT_TIME_CONTENT = "cur_time_content"

    /**
     *Sub graph index
     */
    private const val VICE_INDEX = "vice_index"

    /**
     *Main Chart Indicators
     */
    private const val MAIN_INDEX = "main_index"


    /**
     *Get the scale of Kline
     */
    fun getKLineScale(): ArrayList<String> {
        var list = arrayListOf<String>()
        list.add("1min")
        list.add("5min")
        list.add("15min")
        list.add("30min")
        list.add("60min")
        list.add("4h")
        list.add("1day")
        list.add("1week")
        list.add("1month")


        /**
         *Add time sharing
         */
        list.add(0, "line")
        return list
    }

    fun getShowKLineScaleName(name:String,context:Context): String {
        return when (name) {
            "1min" -> CpLanguageUtil.getString(context,"cp_extra_text41")
            "5min" -> CpLanguageUtil.getString(context,"cp_extra_text42")
            "15min" -> CpLanguageUtil.getString(context,"cp_extra_text43")
            "30min" -> CpLanguageUtil.getString(context,"cp_extra_text44")
            "60min" -> CpLanguageUtil.getString(context,"cp_extra_text45")
            "1h" -> CpLanguageUtil.getString(context,"cp_extra_text45")
            "4h" -> CpLanguageUtil.getString(context,"cp_extra_text46")
            "1day" -> CpLanguageUtil.getString(context,"cp_extra_text47")
            "1week" -> CpLanguageUtil.getString(context,"cp_extra_text48")
            "1month" -> CpLanguageUtil.getString(context,"cp_extra_text49")
            "line" -> CpLanguageUtil.getString(context,"cp_extra_text40")
            else -> name
        }
    }

    /**
     *@Return Obtain the current scale of KLine
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
        CpPreferenceManager.getInstance(CpMyApp.Companion.instance())
                .putSharedString(CURRENT_TIME_CONTENT, curTime);
    }

    /**
     *Set sub image indicators
     *Param status sub graph index
     */
    fun setViceIndex(status: Int) {
        CpPreferenceManager.getInstance(CpMyApp.Companion.instance())
                .putSharedInt(VICE_INDEX, status);
    }

    fun getCurTime(): String {
        return  CpPreferenceManager.getInstance(CpMyApp.Companion.instance())
                .getSharedString(CURRENT_TIME_CONTENT, "15min");
    }


    /**
     *@return Get the subscript of KLine's current scale
     */
    fun getCurTime4Index(): Int {
        return CpPreferenceManager.getInstance(CpMyApp.Companion.instance())
                .getSharedInt(CURRENT_TIME, getKLineScale().indexOf("15min"));
    }

    /**
     *Save the current scale of KLine
     *@param curPosition KLine's current scale subscript
     */
    fun setCurTime4KLine(curPosition: Int) {
        CpPreferenceManager.getInstance(CpMyApp.Companion.instance())
                .putSharedInt(CURRENT_TIME, curPosition);
    }

    /**
     *Obtain sub image indicators
     *@return sub map indicator
     */
    fun getViceIndex(): Int{
        return CpPreferenceManager.getInstance(CpMyApp.Companion.instance())
                .getSharedInt(VICE_INDEX, CpViceViewStatus.NONE.status);
    }



    /**
     *Set main graph indicators
     *@param status Main graph indicator
     */
    fun setMainIndex(status: Int) {
        CpPreferenceManager.getInstance(CpMyApp.Companion.instance())
                .putSharedInt(MAIN_INDEX, status);
    }

    /**
     *Obtain main map indicators
     *@return Main Map Indicator
     */
    fun getMainIndex(): Int {
        return CpPreferenceManager.getInstance(CpMyApp.Companion.instance())
                .getSharedInt(MAIN_INDEX,MainKlineViewStatus.MA.status);
    }


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
