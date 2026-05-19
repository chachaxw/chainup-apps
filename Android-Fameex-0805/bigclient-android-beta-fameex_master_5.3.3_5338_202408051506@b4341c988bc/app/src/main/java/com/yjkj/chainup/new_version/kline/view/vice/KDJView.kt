package com.yjkj.chainup.kline.view.vice

import android.graphics.Canvas
import android.graphics.Paint
import com.yjkj.chainup.kline.view.KLineChartView
import com.yjkj.chainup.new_version.kline.base.IChartViewDraw
import com.yjkj.chainup.new_version.kline.base.IValueFormatter
import com.yjkj.chainup.new_version.kline.bean.vice.IKDJ
import com.yjkj.chainup.new_version.kline.formatter.ValueFormatter
import com.yjkj.chainup.new_version.kline.view.BaseKLineChartView
import com.yjkj.chainup.util.BigDecimalUtils

/**
 * @Author: Bertking
 * @Date 2023/3/11-11:02 AM
 *@description: KDJ View
 */
class KDJView(view: KLineChartView) : IChartViewDraw<IKDJ> {
    val TAG = KDJView::class.java.simpleName
    private var mPricePrecision = -1
    private val paint4K = Paint(Paint.ANTI_ALIAS_FLAG)
    private val paint4D = Paint(Paint.ANTI_ALIAS_FLAG)
    private val paint4J = Paint(Paint.ANTI_ALIAS_FLAG)


    override fun drawTranslated(lastPoint: IKDJ?, curPoint: IKDJ, lastX: Float, curX: Float, canvas: Canvas, view: BaseKLineChartView, position: Int) {

        if (lastPoint?.K != 0f) {
            view.drawChildLine(canvas, paint4K, lastX, lastPoint?.K ?: 0f, curX, curPoint.K)
        }
        if (lastPoint?.D != 0f) {
            view.drawChildLine(canvas, paint4D, lastX, lastPoint?.D ?: 0f, curX, curPoint.D)
        }
        if (lastPoint?.J != 0f) {
            view.drawChildLine(canvas, paint4J, lastX, lastPoint?.J ?: 0f, curX, curPoint.J)
        }

    }

    override fun drawText(canvas: Canvas, view: BaseKLineChartView, position: Int, x: Float, y: Float) {
        val point = view.getItem(position) as IKDJ
        if (point.K != 0f) {
            var text = "KDJ(14,1,3)  "
            canvas.drawText(text, x, y, view.textPaint)
            var textLen = x
            textLen += view.textPaint.measureText(text)
//            text = "K:" + view.formatValue(point.K) + " "
            text = "K:" +view.formatValue(if (mPricePrecision==-1) point.K else BigDecimalUtils.showSNormal(point.K.toString(),mPricePrecision).toFloat())+" "
            canvas.drawText(text, textLen, y, paint4K)
            textLen += paint4K.measureText(text)
            if (point.D != 0f) {
//                text = "D:" + view.formatValue(point.D) + " "
                text = "D:" +view.formatValue(if (mPricePrecision==-1) point.D else BigDecimalUtils.showSNormal(point.D.toString(),mPricePrecision).toFloat())+" "
                canvas.drawText(text, textLen, y, paint4D)
                textLen += paint4D.measureText(text)
//                text = "J:" + view.formatValue(point.J) + " "
                text = "J:" +view.formatValue(if (mPricePrecision==-1) point.J else BigDecimalUtils.showSNormal(point.J.toString(),mPricePrecision).toFloat())+" "
                canvas.drawText(text, textLen, y, paint4J)
            }
        }
    }

    override fun getMaxValue(point: IKDJ): Float {
        return maxOf(point.K, point.D, point.J)
    }

    override fun getMinValue(point: IKDJ): Float {
        return minOf(point.K, point.D, point.J)
    }

    override fun getValueFormatter(): IValueFormatter {
        return ValueFormatter()
    }


    /**
     *Set K Color
     */
    fun setKColor(color: Int) {
        paint4K.color = color
    }

    /**
     *Set D color
     */
    fun setDColor(color: Int) {
        paint4D.color = color
    }

    /**
     *Set J Color
     */
    fun setJColor(color: Int) {
        paint4J.color = color
    }

    /**
     *Set Curve Width
     */
    override fun setLineWidth(width: Float) {
        paint4K.strokeWidth = width
        paint4D.strokeWidth = width
        paint4J.strokeWidth = width
    }

    /**
     *Set Text Size
     */
    override fun setTextSize(textSize: Float) {
        paint4K.textSize = textSize
        paint4D.textSize = textSize
        paint4J.textSize = textSize
    }
    fun setMaPricePrecision(pricePrecision: Int) {
        this.mPricePrecision = pricePrecision
    }
}
