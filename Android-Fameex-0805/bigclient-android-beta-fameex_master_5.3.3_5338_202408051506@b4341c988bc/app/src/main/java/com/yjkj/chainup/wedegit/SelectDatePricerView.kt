package com.yjkj.chainup.wedegit

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.widget.LinearLayout
import com.bigkoo.pickerview.builder.TimePickerBuilder
import com.bigkoo.pickerview.view.TimePickerView
import com.contrarywind.view.WheelView
import com.yjkj.chainup.R
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.util.*
import com.yjkj.chainup.wedegit.DataPickView.DatePicker
import com.yjkj.chainup.wedegit.DataPickView.bean.DateType
import kotlinx.android.synthetic.main.layout_select_date_lever.view.*
import java.text.SimpleDateFormat
import java.util.*


/**
 * @Author: Bertking
 * @Date：2019-05-27-16:47
 * @Description:
 */
class SelectDatePricerView @JvmOverloads constructor(context: Context,
                                                     attrs: AttributeSet? = null,
                                                     defStyleAttr: Int = 0
) : LinearLayout(context, attrs, defStyleAttr) {
    val TAG = SelectDatePricerView::class.java.simpleName

    var beginTime: String = ""
    var endTime: String = ""
    var dateListener: IDateValue? = null

    var pvTime: TimePickerView? = null

    interface IDateValue {
        fun returnValue(startTime: String, endTimes: String)
    }

    init {
        attrs?.let {
            /**
             * 这里的必须为：True
             */
            LayoutInflater.from(context).inflate(R.layout.layout_select_date_nor, this, true)

            pet_start_time?.text = "--"
            pet_end_time?.text = "--"
            pet_start_time?.setOnClickListener {
                changeClick(0)
            }
            pet_end_time?.setOnClickListener {
                changeClick(1)
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
    fun initData(context: Context,startTimeTemp: String = "", endTimeTemp: String = "",isStart:Boolean = true){
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
        initPicker(context,startTimeTemp,endTimeTemp,isStart)
    }

    private fun initPicker(context: Context,startTimeTemp: String = "", endTimeTemp: String = "",isStart:Boolean = true){
        //时间选择器
        val tempTime = if(isStart) startTimeTemp else endTimeTemp
        val selectCal = Calendar.getInstance()
        val selectData =  DateUtils.getTimeToLong(tempTime.getLeverCoinTime(true)).toLong()
        selectCal.time = Date(selectData)
        pvTime = TimePickerBuilder(context) { date, v -> //选中事件回调
            // 这里回调过来的v,就是show()方法里面所添加的 View 参数，如果show的时候没有添加参数，v则为null
            /*btn_Time.setText(getTime(date));*/
            LogUtil.e(TAG," ${DateUtils.getYearMonthDayHourMinSecond(date.time)}   ")

        }.setTimeSelectChangeListener {
            val times = DateUtils.get7DayTimeStart("3")
            val time = DateUtils.getYearMonthDayHourMinSecond(it.time)
            val isRange= DateUtils.dayIsRegion(times.first.toLong(),times.second.toLong(),it.time)
            LogUtil.e(TAG," ${time}  ${isRange} " +
                    "${DateUtils.getYearMonthDayHourMinSecond(times.first.toLong())}  " +
                    " ${DateUtils.getYearMonthDayHourMinSecond(times.second.toLong())}")

            val tempDate = DateUtils.getYearMonthDayMS(it.time)

            val today = DateUtils.getYearMonthDayMS(times.second.toLong())
            val isTime = DateUtils.dayIsStop(tempDate,today)
           if(!isTime){
               if(currIndex == 0){
                   beginTime = today
                   pvTime?.setDate(today.timeToCal())
                   pet_start_time.text = beginTime
               } else if(currIndex == 1){
                   endTime = today
                   pvTime?.setDate(today.timeToCal())
                   pet_end_time.text = endTime
               }
               callTime()
               return@setTimeSelectChangeListener
           }
            val tempShowDate = time.split(" ")[0]
            if(currIndex == 0){
                pet_start_time.text = tempShowDate
                beginTime = tempShowDate
            } else if(currIndex == 1){
                pet_end_time.text = tempShowDate
                endTime = tempShowDate
            }
            callTime()

        }
            .setLayoutRes(R.layout.item_time_top) { v ->
            }
            .setType(booleanArrayOf(true, true, true, false, false, false))
            .setLabel("", "", "", "", "", "") //设置空字符串以隐藏单位提示   hide label
            .setDividerType(WheelView.DividerType.FILL) // 分隔线类型
            .setDividerColor(ColorUtil.getColor(context,R.color.card_bg_color_2))
            .setTextColorCenter(ColorUtil.getColor(context,R.color.text_color_1))
            .setTextColorOut(ColorUtil.getColor(context,R.color.text_color_2))
            .setBgColor(ColorUtil.getColor(context,R.color.dialog_bg_color))
            .setContentTextSize(24)
            .isCyclic(true)
            .setDate(selectCal)
            .setDecorView(date_time) //非dialog模式下,设置ViewGroup, pickerView将会添加到这个ViewGroup中
            .setOutSideColor(0x00000000)
            .setOutSideCancelable(false)
            .build()



        pvTime?.setKeyBackCancelable(false) //系统返回键监听屏蔽掉
        pvTime?.show(date_time, false)


    }

    private fun changeClick(position:Int = 0){
        val tempTime = if(position == 0) beginTime else endTime
        val selectCal = Calendar.getInstance()
        val selectData =  DateUtils.getTimeToLong(tempTime.getLeverCoinTime(true)).toLong()
        selectCal.time = Date(selectData)
        pvTime?.setDate(selectCal)

        if(position == 0){
            currIndex = 0
            pet_start_time.isSelected = true
            pet_end_time.isSelected = false
        } else {
            currIndex = 1
            pet_start_time.isSelected = false
            pet_end_time.isSelected = true
        }
    }

    private fun callTime (){
        dateListener?.returnValue(beginTime,endTime)
    }

    fun String.timeToCal(): Calendar {
        val selectCal = Calendar.getInstance()
        val selectData =  DateUtils.getTimeToLong(this.getLeverCoinTime(true)).toLong()
        selectCal.time = Date(selectData)
        return selectCal
    }
    fun String.getLeverCoinTime(isStart: Boolean = true): String {
        return if(isStart){
            this.appendSpace("00:00:00")
        } else {
            this.appendSpace("23:59:59")
        }
    }
    fun String.appendSpace(symbol: String?): String {
        return StringBuffer(this).append(" $symbol").toString()
    }

}