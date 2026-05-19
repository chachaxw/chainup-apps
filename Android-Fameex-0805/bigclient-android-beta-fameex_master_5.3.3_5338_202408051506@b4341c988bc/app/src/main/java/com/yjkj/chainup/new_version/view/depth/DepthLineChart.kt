package com.yjkj.chainup.new_version.view.depth

import android.content.Context
import android.util.AttributeSet
import android.view.MotionEvent
import com.github.mikephil.charting.charts.LineChart
import kotlin.math.abs


class DepthLineChart @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null
) : LineChart(context, attrs) {
    var downPointX:Float = 0f
    var downPointY:Float = 0f
    var direction:Int? = null

    fun canLeftScroll():Boolean {
        return lowestVisibleX > xChartMin
    }
    fun canRightScroll():Boolean {
        return highestVisibleX < xChartMax
    }


    override fun dispatchTouchEvent(ev: MotionEvent?): Boolean {
        ev?.run {
            when(this.action){
                MotionEvent.ACTION_DOWN -> {
                    downPointX = x
                    downPointY = y
                }
                MotionEvent.ACTION_MOVE -> {
                    val moveX = abs(downPointX - x)
                    val moveY = abs(downPointY - y)
                    val diffValue = moveX - moveY
                    if(diffValue >= 10){
                        parent.requestDisallowInterceptTouchEvent(true)
                    }
                }
                MotionEvent.ACTION_UP,MotionEvent.ACTION_CANCEL -> {
                    downPointX = 0f
                    downPointY = 0f
                    direction = null
                    parent.requestDisallowInterceptTouchEvent(false)
                }
            }
        }
        return super.dispatchTouchEvent(ev)
    }
}