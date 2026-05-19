package com.yjkj.chainup.new_version.kline.view.vice

import android.graphics.Canvas
import android.graphics.Paint
import android.util.Log
import com.yjkj.chainup.kline.view.KLineChartView
import com.yjkj.chainup.new_version.kline.base.IChartViewDraw
import com.yjkj.chainup.new_version.kline.base.IValueFormatter
import com.yjkj.chainup.new_version.kline.bean.vice.IMACD
import com.yjkj.chainup.new_version.kline.formatter.ValueFormatter
import com.yjkj.chainup.new_version.kline.view.BaseKLineChartView
import com.yjkj.chainup.new_version.kline.view.IFallRiseColor
import com.yjkj.chainup.util.BigDecimalUtils

/**
 * @Author: Bertking
 * @Date 2023/3/11-11:17 AM
 * @Description:
 */
class MACDView(view: KLineChartView) : IChartViewDraw<IMACD>, IFallRiseColor {


    val TAG = MACDView::class.java.simpleName

    /**
     *Width of columns in macd
     */
    private var mMACDWidth = 0f

    private val fallPaint = Paint(Paint.ANTI_ALIAS_FLAG)
    private val risePaint = Paint(Paint.ANTI_ALIAS_FLAG)

    private val paint4DIF = Paint(Paint.ANTI_ALIAS_FLAG)
    private val paint4DEA = Paint(Paint.ANTI_ALIAS_FLAG)
    private val paint4MACD = Paint(Paint.ANTI_ALIAS_FLAG)

    private var mPricePrecision = -1

    override fun drawTranslated(lastPoint: IMACD?, curPoint: IMACD, lastX: Float, curX: Float, canvas: Canvas, view: BaseKLineChartView, position: Int) {
        drawMACD(canvas, view, curX, curPoint.MACD)
        view.drawChildLine(canvas, paint4DIF, lastX, lastPoint?.DEA ?: 0f, curX, curPoint.DEA)
        view.drawChildLine(canvas, paint4DEA, lastX, lastPoint?.DIF ?: 0f, curX, curPoint.DIF)
    }

    override fun drawText(canvas: Canvas, view: BaseKLineChartView, position: Int, x: Float, y: Float) {

        val point = view.getItem(position) as IMACD
        var text = "MACD(12,26,9)  "
        canvas.drawText(text, x, y, view.textPaint)

        var textLen = x

        textLen += view.textPaint.measureText(text)
       // view.formatValue(if (mPricePrecision==-1) point.MACD else BigDecimalUtils.showSNormal(point.DEA.toString(),mPricePrecision).toFloat())
        text = "MACD:" + view.formatValue(if (mPricePrecision==-1) point.MACD else BigDecimalUtils.showSNormal(point.MACD.toString(),mPricePrecision).toFloat()) + "  "
        canvas.drawText(text, textLen, y, paint4MACD)
        textLen += paint4MACD.measureText(text)
        text = "DIF:" + view.formatValue(if (mPricePrecision==-1) point.MACD else BigDecimalUtils.showSNormal(point.DIF.toString(),mPricePrecision).toFloat()) + "  "
        canvas.drawText(text, textLen, y, paint4DEA)
        textLen += paint4DIF.measureText(text)
        text = "DEA:" + view.formatValue(if (mPricePrecision==-1) point.MACD else BigDecimalUtils.showSNormal(point.DEA.toString(),mPricePrecision).toFloat())
        canvas.drawText(text, textLen, y, paint4DIF)


    }

    override fun getMaxValue(point: IMACD): Float {
        return maxOf(point.MACD, point.DEA, point.DIF)

    }

    override fun getMinValue(point: IMACD): Float {
        return minOf(point.MACD, point.DEA, point.DIF)
    }

    override fun getValueFormatter(): IValueFormatter {
        return ValueFormatter()
    }

    override fun setFallRiseColor(riseColor: Int, fallColor: Int) {
        fallPaint.color = fallColor
        risePaint.color = riseColor
    }

    /**
     *Draw macd
     *
     * @param canvas
     * @param x
     * @param macd
     */
    private fun drawMACD(canvas: Canvas, view: BaseKLineChartView, x: Float, macd: Float) {
        var macdy = view.getChildY(macd)
        val r = mMACDWidth / 2
        var zeroy = view.getChildY(0f)
        
        if (macd > 0) {
            //               left   top   right  bottom
            canvas.drawRect(x - r, macdy, x + r, zeroy, risePaint)
        } else {
            canvas.drawRect(x - r, zeroy, x + r, macdy, fallPaint)
        }
    }

    override fun setTextSize(textSize: Float) {
        paint4DEA.textSize = textSize
        paint4DIF.textSize = textSize
        paint4MACD.textSize = textSize
    }

    override fun setLineWidth(width: Float) {
        paint4DEA.strokeWidth = width
        paint4DIF.strokeWidth = width
        paint4MACD.strokeWidth = width
    }


    /**
     *Set DIF color
     */
    fun setDIFColor(color: Int) {
        paint4DIF.color = color
    }

    /**
     *Set DEA color
     */
    fun setDEAColor(color: Int) {
        paint4DEA.color = color
    }

    /**
     *Set MACD color
     */
    fun setMACDColor(color: Int) {
        paint4MACD.color = color
    }

    /**
     *Set the width of MACD
     *
     * @param MACDWidth
     */
    fun setMACDWidth(MACDWidth: Float) {
        mMACDWidth = MACDWidth
    }


    fun setMaPricePrecision(pricePrecision: Int) {
        this.mPricePrecision = pricePrecision
    }
}
