package com.chainup.contract.view

import android.content.Context
import android.util.AttributeSet
import android.view.MotionEvent
import com.github.mikephil.charting.charts.LineChart
import kotlin.math.abs


class CpLineChart @JvmOverloads constructor(
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
                    if(diffValue >= 100){
                        //1 right -1 left
                        direction = if((downPointX - x) > 0) 1 else -1
                        if(direction == -1){
                            parent.requestDisallowInterceptTouchEvent(canLeftScroll())
                        } else {
                            parent.requestDisallowInterceptTouchEvent(canRightScroll())
                        }
                    }else{
                        parent.requestDisallowInterceptTouchEvent(false)
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