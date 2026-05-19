package com.yjkj.chainup.wedegit

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.widget.LinearLayout
import android.widget.TextView
import com.yjkj.chainup.R
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.util.LogUtil
import com.yjkj.chainup.util.Utils
import com.yjkj.chainup.wedegit.DataPickView.DatePickDialog
import com.yjkj.chainup.wedegit.DataPickView.DatePicker
import com.yjkj.chainup.wedegit.DataPickView.OnChangeLisener
import com.yjkj.chainup.wedegit.DataPickView.bean.DateType
import kotlinx.android.synthetic.main.layout_select_date_lever.view.*
import java.text.SimpleDateFormat
import java.util.*


/**
 * @Author: Bertking
 * @Date：2019-05-27-16:47
 * @Description:
 */
class SelectDateLeverView @JvmOverloads constructor(context: Context,
                                                    attrs: AttributeSet? = null,
                                                    defStyleAttr: Int = 0
) : LinearLayout(context, attrs, defStyleAttr) {
    val TAG = SelectDateLeverView::class.java.simpleName

    var beginTime: String = ""
    var endTime: String = ""
    var dateListener: IDateValue? = null


    interface IDateValue {
        fun returnValue(startTime: String, endTimes: String)
    }

    init {
        attrs?.let {
            /**
             * 这里的必须为：True
             */
            LayoutInflater.from(context).inflate(R.layout.layout_select_date_lever, this, true)

            pet_start_time?.text = "--"
            pet_end_time?.text = "--"
            pet_start_time?.setOnClickListener {
                showDatePickDialog(0, Utils.parseServerTime(beginTime))
            }
            pet_end_time?.setOnClickListener {
                showDatePickDialog(1, Utils.parseServerTime(endTime))
            }


        }

    }


    fun initDate() {
        dateListener?.returnValue(beginTime, endTime)
    }

    fun resetTime() {
        beginTime = ""
        endTime = ""
        pet_start_time.text  = LanguageUtil.getString(context,"filter_date_start")
        pet_end_time.text = LanguageUtil.getString(context,"filter_date_end")
    }


    /**
     * 显示 选择日历dialog
     */
    private fun showDatePickDialog(index: Int, date: Date? = null) {
        currIndex = index
        LogUtil.e(TAG,"showDatePickDialog ${currIndex}   ${beginTime}  ${endTime}")
        val picker = getDatePicker(index,date)
        if(isBibi){
            message(date)
        } else {
            if(index == 0){
                message(date)
            }
        }

        if(date_time.childCount == 0){
            date_time.addView(picker)
        }
    }
    val type = DateType.TYPE_YMD
    var datePicker: DatePicker? = null
    //开始时间
    private val startDate = Date()

    //年分限制，默认上下5年
    private val yearLimt = 11
    private var currIndex  = 0

    private fun getDatePicker(index: Int, date: Date? = null): DatePicker? {
        if(datePicker == null){
             datePicker = DatePicker(context, type)
             datePicker?.setOnChangeLisener {
                   message(it)
             }
        }
        datePicker?.setStartDate(date ?: startDate)
        datePicker?.setYearLimt(yearLimt)
        datePicker?.init()

        return datePicker
    }
    fun initData(){
        showDatePickDialog(0, Utils.parseServerTime(beginTime))
    }

    private fun message(date:Date?){
        var message = ""
        try {
            message = SimpleDateFormat("yyyy-MM-dd").format(date)
        } catch (e: Exception) {
            e.printStackTrace()
        }
        when (currIndex) {
            0 -> {
                beginTime = message
                pet_start_time.text = beginTime
                pet_start_time.isSelected = true
                pet_end_time.isSelected = false
            }
            1 -> {
                endTime = message
                pet_end_time.text = endTime
                pet_start_time.isSelected = false
                pet_end_time.isSelected = true
            }
        }
        LogUtil.e(TAG,"message ${currIndex} ${message}  ${beginTime}  ${endTime}")
        initDate()
    }
    private var isBibi = false
    fun initData(startTimeTemp: String = "", endTimeTemp: String = "",isStart:Boolean = true){
        isBibi = true
        if(startTimeTemp.isNotEmpty()){
            pet_start_time.text = startTimeTemp
            pet_end_time.text = endTimeTemp
            beginTime = startTimeTemp
            endTime = endTimeTemp
        }
        if(isStart){
            currIndex = 0
            pet_start_time.isSelected = true
            pet_end_time.isSelected = false
        } else {
            currIndex = 1
            pet_start_time.isSelected = false
            pet_end_time.isSelected = true
        }
        showDatePickDialog(currIndex, Utils.parseServerTime(if(isStart) startTimeTemp else endTimeTemp))
    }



}