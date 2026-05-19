package com.yjkj.chainup.new_version.kline.base
import android.graphics.Canvas
import com.yjkj.chainup.new_version.kline.view.BaseKLineChartView


/**
 * @Author: Bertking
 * @Date 2023/3/11-10:49 AM
 * @Description:
 */
interface IChartViewDraw<Index> {


    /**
     *Need to slide object draw method
     *
     * @param canvas    canvas
     *Param view k line graph View
     *@param position The position of the current point
     *@param lastPoint Previous point
     *@param curPoint Current point
     *The x-coordinate of a point on @param lastX
     *@param curX The X coordinate of the current point
     */
    fun drawTranslated(lastPoint: Index?, curPoint: Index, lastX: Float, curX: Float, canvas: Canvas, view: BaseKLineChartView, position: Int)

    /**
     * @param canvas
     * @param view
     *@param position The position of this point
     *Starting coordinate of @param x x
     *The starting coordinate of @param y y y
     */
    fun drawText(canvas: Canvas, view: BaseKLineChartView, position: Int, x: Float, y: Float)

    /**
     *Get the maximum value in the current entity
     *
     * @param point
     * @return
     */
    fun getMaxValue(point: Index): Float

    /**
     *Get the smallest value in the current entity
     *
     * @param point
     * @return
     */
    fun getMinValue(point: Index): Float

    /**
     *Get value formatter
     */
    fun getValueFormatter(): IValueFormatter

    /**
     *Set Text Size
     */
    fun setTextSize(textSize: Float)

    /**
     *Set Curve Width
     */
    fun setLineWidth(width: Float)

}
