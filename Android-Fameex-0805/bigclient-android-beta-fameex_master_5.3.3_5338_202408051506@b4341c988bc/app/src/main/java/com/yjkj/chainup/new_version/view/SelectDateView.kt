package com.yjkj.chainup.new_version.view

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.widget.LinearLayout
import com.yjkj.chainup.R
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.util.Utils
import com.yjkj.chainup.wedegit.DataPickView.DatePickDialog
import com.yjkj.chainup.wedegit.DataPickView.OnSureLisener
import com.yjkj.chainup.wedegit.DataPickView.bean.DateType
import kotlinx.android.synthetic.main.layout_select_date.view.*
import java.text.SimpleDateFormat
import java.util.*

/**
 * @Author: Bertking
 * @Date 2023-05-27-16:47
 * @Description:
 */
class SelectDateView @JvmOverloads constructor(context: Context,
                                               attrs: AttributeSet? = null,
                                               defStyleAttr: Int = 0
) : LinearLayout(context, attrs, defStyleAttr) {
    val TAG = SelectDateView::class.java.simpleName

    var beginTime: String = ""
    var endTime: String = ""
    var dateListener: IDateValue? = null


    interface IDateValue {
        fun returnValue(startTime: String, endTimes: String)
    }

    init {
        attrs?.let {
            /**
             *The value here must be: True
             */
            LayoutInflater.from(context).inflate(R.layout.layout_select_date, this, true)
            initDate()
            pet_start_time?.setEditText(LanguageUtil.getString(context,"filter_date_start"))
            pet_end_time?.setEditText(LanguageUtil.getString(context,"filter_date_end"))
            pet_start_time?.onTextListener = object : PwdSettingView.OnTextListener {
                override fun showText(text: String): String {
                    return text
                }

                override fun returnItem(item: Int) {

                }

                override fun onclickImage() {
                    showDatePickDialog(0, Date().apply { if(!"".equals(beginTime)) time = beginTime.toLong() }, pet_start_time)
                }

            }
            pet_end_time?.onTextListener = object : PwdSettingView.OnTextListener {
                override fun showText(text: String): String {
                    return text
                }

                override fun returnItem(item: Int) {

                }

                override fun onclickImage() {
                    showDatePickDialog(1, Date().apply { if(!"".equals(endTime)) time = endTime.toLong() }, pet_end_time)
                }

            }
        }

    }


    fun initDate() {
        dateListener?.returnValue(beginTime, endTime)
    }

    fun resetTime() {
        beginTime = ""
        endTime = ""
        pet_start_time.setEditText(LanguageUtil.getString(context,"filter_date_start"))
        pet_end_time.setEditText(LanguageUtil.getString(context,"filter_date_end"))
    }


    /**
     *Display Selection Calendar dialog
     */
    private fun showDatePickDialog(index: Int, date: Date? = null, view: PwdSettingView) {
        val dialog = DatePickDialog(context)
        //Set up upper and lower year limit
        dialog.setYearLimt(15)
        if (date != null) {
            dialog.setStartDate(date)

            dialog.setDateValue(
                if("".equals(beginTime)) null else Date().apply { time = beginTime.toLong() },
                if("".equals(endTime)) null else Date().apply { time = endTime.toLong() },
                index
            )
        }
        //Set Title
        //Select year, year, and day as the setting type here
        dialog.setType(DateType.TYPE_YMD)
////Set selection callback
//        dialog.setOnChangeLisener { date ->
//
//        }
        //Set the callback by clicking the OK button
        dialog.setOnSureLisener(object: OnSureLisener{
            override fun onSure(date: Date?) {
                date?.run {
                    when (index) {
                        0 -> {
                            beginTime = this.time.toString()
                        }
                        1 -> {
                            //2020-01-01 00:00:00 - 2024-01-01 23:59:59
                            val calendar = Calendar.getInstance()
                            calendar.timeInMillis = this.time
                            calendar.add(Calendar.HOUR,23)
                            calendar.add(Calendar.MINUTE,59)
                            calendar.add(Calendar.SECOND,59)
                            endTime = calendar.timeInMillis.toString()
                        }
                    }
                    var message = ""
                    try {
                        message = SimpleDateFormat("yyyy-MM-dd").format(this)
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }

                    view.setEditText(message)
                }

                dateListener?.returnValue(beginTime, endTime)
            }
        })
        dialog.show()
    }


}
