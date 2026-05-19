package com.yjkj.chainup.new_version.kline.base
import android.graphics.Canvas
import com.chainup.contract.kline.view.CpBaseKLineChartView


/**
 * @Author: Bertking
 * @Date：2019/3/11-10:49 AM
 * @Description:
 */
interface CpIChartViewDraw<Index> {


    /**
     *Need sliding object draw method
     *
     * @param canvas    canvas
     *@param view k line graph View
     *@param position The position of the current point
     *@param lastPoint Previous point
     *@param curPoint Current point
     *X coordinate of a point on @param lastX
     *@param curX The X coordinate of the current point
     */
    fun drawTranslated(lastPoint: Index?, curPoint: Index, lastX: Float, curX: Float, canvas: Canvas, view: CpBaseKLineChartView, position: Int)

    /**
     * @param canvas
     * @param view
     *@param position The position of this point
     *Starting coordinate of @param x x
     *Starting coordinate of @param y y
     */
    fun drawText(canvas: Canvas, view: CpBaseKLineChartView, position: Int, x: Float, y: Float)

    /**
     *Gets the maximum value in the current entity
     *
     * @param point
     * @return
     */
    fun getMaxValue(point: Index): Float

    /**
     *Gets the smallest value in the current entity
     *
     * @param point
     * @return
     */
    fun getMinValue(point: Index): Float

    /**
     *Get value formatter
     */
    fun getValueFormatter(): CpIValueFormatter

    /**
     *Set Text Size
     */
    fun setTextSize(textSize: Float)

    /**
     *Set Curve Width
     */
    fun setLineWidth(width: Float)

}
