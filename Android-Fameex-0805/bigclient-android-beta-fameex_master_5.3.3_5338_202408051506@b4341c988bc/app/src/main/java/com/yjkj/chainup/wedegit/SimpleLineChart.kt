package com.yjkj.chainup.wedegit

import android.content.Context
import android.util.AttributeSet
import com.github.mikephil.charting.charts.LineChart
import com.github.mikephil.charting.data.Entry
import com.github.mikephil.charting.data.LineDataSet
import com.yjkj.chainup.manager.RateManager
import com.yjkj.chainup.util.ColorUtil

/**
 * @Author lianshangljl
 * @Date 2023-08-12-11:12
 * @Email buptjinlong@163.com
 * @description
 *Simplified K-line diagram
 *Used for abbreviated display of trends in the list
 */
class SimpleLineChart @JvmOverloads constructor(
        context: Context, attrs: AttributeSet? = null, defStyleAttr: Int = 0
) : LineChart(context, attrs, defStyleAttr) {

    init {
        minOffset = 0f
        isLogEnabled = false
        legend.isEnabled = false
        description.isEnabled = false
        xAxis.isEnabled = false
        axisLeft.isEnabled = false
        axisRight.isEnabled = false
        setBorderWidth(0.5f)
        setTouchEnabled(false)
        setScaleEnabled(false)
        setDrawGridBackground(false)


    }

    fun setColor(data: List<Entry>, rose: String) {
        var lineDataSet = LineDataSet(data, "")
        lineDataSet.color = ColorUtil.getMainColorType(isRise = RateManager.getRoseTrend(rose) >= 0)
    }
}
