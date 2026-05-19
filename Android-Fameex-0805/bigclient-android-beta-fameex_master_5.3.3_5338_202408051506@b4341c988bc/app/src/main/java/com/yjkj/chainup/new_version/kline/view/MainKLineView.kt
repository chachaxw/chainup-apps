package com.yjkj.chainup.kline.view

import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.RectF
import android.util.Log
import androidx.core.content.ContextCompat
import com.chainup.contract.kline.view.CpBaseKLineChartView
import com.chainup.contract.utils.CpBigDecimalUtils
import com.chainup.contract.utils.CpColorUtil
import com.yjkj.chainup.R
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.manager.CpLanguageUtil
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.RateManager
import com.yjkj.chainup.new_version.kline.base.IChartViewDraw
import com.yjkj.chainup.new_version.kline.base.IValueFormatter
import com.yjkj.chainup.new_version.kline.bean.CandleBean
import com.yjkj.chainup.new_version.kline.bean.CpCandleBean
import com.yjkj.chainup.new_version.kline.bean.CpIKLine
import com.yjkj.chainup.new_version.kline.bean.IKLine
import com.yjkj.chainup.new_version.kline.formatter.ValueFormatter
import com.yjkj.chainup.new_version.kline.view.BaseKLineChartView
import com.yjkj.chainup.new_version.kline.view.IFallRiseColor
import com.yjkj.chainup.new_version.kline.view.MainKlineViewStatus
import com.yjkj.chainup.util.BigDecimalUtils
import com.yjkj.chainup.util.ColorUtil
import com.yjkj.chainup.util.DisplayUtil
import org.jetbrains.anko.dip

/**
 * @Author: Bertking
 * @Date 2023/3/11-11:28 AM
 *@description: K-line main diagram
 */
class MainKLineView(kLineChartView: KLineChartView) : IChartViewDraw<CandleBean>, IFallRiseColor {

    val TAG = MainKLineView::class.java.simpleName

    private var candleWidth = 0f

    private var candleLineWidth = 0f

    private val paint = Paint(Paint.ANTI_ALIAS_FLAG)

    private val mLinePaint = Paint(Paint.ANTI_ALIAS_FLAG)

    private val fallPaint = Paint(Paint.ANTI_ALIAS_FLAG)

    private val risePaint = Paint(Paint.ANTI_ALIAS_FLAG)

    private val paint4MA5 = Paint(Paint.ANTI_ALIAS_FLAG)

    private val paint4MA10 = Paint(Paint.ANTI_ALIAS_FLAG)

    private val paint4MA30 = Paint(Paint.ANTI_ALIAS_FLAG)

    private var mPricePrecision = -1
    private var mVolumePrecision = 2

    /**
     * marker
     */
    private val markerTitlePaint = Paint(Paint.ANTI_ALIAS_FLAG)
    private val markerValuePaint = Paint(Paint.ANTI_ALIAS_FLAG)
    private val markerBgPaint = Paint(Paint.ANTI_ALIAS_FLAG)
    private val markerBorderPaint = Paint(Paint.ANTI_ALIAS_FLAG)

    //Is the candle line a solid line
    var isCandleSolid = true
    //Time sharing or not
    var isLine = false
        set(value) {
            field = value
            if (isLine != value) {
                isLine = value
                if (isLine) {
                    kChartView.setCandleWidth(
                            context.dip(7f).toFloat())
                } else {
                    kChartView.setCandleWidth(
                            context.dip(6).toFloat())
                }
            }

        }

    lateinit var context: Context

    var status = MainKlineViewStatus.MA


    lateinit var kChartView: KLineChartView

    init {
        context = kLineChartView.context
        kChartView = kLineChartView
        mLinePaint.color = ContextCompat.getColor(context, R.color.main_color)
        paint.color = ContextCompat.getColor(context, R.color.chart_line_background)
        markerBorderPaint.color = ContextCompat.getColor(context, R.color.marker_border)
        markerBorderPaint.style = Paint.Style.STROKE
    }

    fun setVolumePrecision(precision:Int){
        mVolumePrecision = precision
    }


    override fun drawTranslated(lastPoint: CandleBean?, curPoint: CandleBean, lastX: Float, curX: Float, canvas: Canvas, view: BaseKLineChartView, position: Int) {
        if (isLine) {

            view.drawMainLine(canvas, mLinePaint, lastX, lastPoint?.closePrice
                    ?: 0f, curX, curPoint.closePrice)

            /**
             *Draw a timeline
             */
            view.drawMainMinuteLine(canvas, paint, lastX, lastPoint?.closePrice
                    ?: 0f, curX, curPoint.closePrice)
        } else {
            drawCandle(view, canvas, curX, curPoint.highPrice, curPoint.lowPrice, curPoint.openPrice, curPoint.closePrice)

            if (status == MainKlineViewStatus.MA) {
                //Draw ma5
                if (lastPoint!!.price4MA5 != 0f) {
                    view.drawMainLine(canvas, paint4MA5, lastX, lastPoint.price4MA5, curX, curPoint.price4MA5)
                }
                //Draw ma10
                if (lastPoint.price4MA10 != 0f) {
                    view.drawMainLine(canvas, paint4MA10, lastX, lastPoint.price4MA10,
                            curX, curPoint.price4MA10)
                }
                //Draw ma30
                if (lastPoint.price4MA30 != 0f) {
                    view.drawMainLine(canvas, paint4MA30, lastX, lastPoint.price4MA30,
                            curX, curPoint.price4MA30)
                }
            } else if (status == MainKlineViewStatus.BOLL) {
                //Draw a ball
                if (lastPoint!!.up != 0f) {
                    view.drawMainLine(canvas, paint4MA5, lastX, lastPoint.up, curX, curPoint.up)
                }
                if (lastPoint.mb != 0f) {
                    view.drawMainLine(canvas, paint4MA10, lastX, lastPoint.mb, curX, curPoint.mb)
                }
                if (lastPoint.dn != 0f) {
                    view.drawMainLine(canvas, paint4MA30, lastX, lastPoint.dn, curX, curPoint.dn)
                }
            }
        }
    }

    override fun drawText(canvas: Canvas, view: BaseKLineChartView, position: Int, x: Float, y: Float) {
        val point = view.getItem(position) as IKLine?
        var textHeight = y
        textHeight -= 5
        if (isLine) {
            if (status == MainKlineViewStatus.MA) {
                if (point!!.price4MA60 != 0f) {
                    val text = "MA60:" + view.formatValue(if (mPricePrecision==-1) point.price4MA60 else BigDecimalUtils.showSNormal(point.price4MA60.toString(),mPricePrecision).toFloat()) + "     "
                    canvas.drawText(text, x + DisplayUtil.dip2px(5f), textHeight, paint4MA10)
                }
            } else if (status == MainKlineViewStatus.BOLL) {
                if (point!!.mb != 0f) {
                    val text = "BOLL:" + view.formatValue(if (mPricePrecision==-1) point.mb else BigDecimalUtils.showSNormal(point.mb.toString(),mPricePrecision).toFloat()) + "     "
                    canvas.drawText(text, +DisplayUtil.dip2px(5f), textHeight, paint4MA10)
                }
            }
        } else {
            if (status == MainKlineViewStatus.MA) {
                var text: String
                var textLen = x
                if (point!!.price4MA5 != 0f) {
                    text = "MA5:" + view.formatValue(if (mPricePrecision==-1) point.price4MA5 else BigDecimalUtils.showSNormal(point.price4MA5.toString(),mPricePrecision).toFloat())
                    canvas.drawText(text, textLen + DisplayUtil.dip2px(15f), textHeight, paint4MA5)
                    textLen += paint4MA5.measureText(text)
                }
                if (point.price4MA10 != 0f) {
                    text = "MA10:" + view.formatValue(if (mPricePrecision==-1) point.price4MA10 else BigDecimalUtils.showSNormal(point.price4MA10.toString(),mPricePrecision).toFloat())
                    canvas.drawText(text, textLen + DisplayUtil.dip2px(25f), textHeight, paint4MA10)
                    textLen += paint4MA10.measureText(text)
                }
                if (point.price4MA30 != 0f) {
                    text = "MA30:" + view.formatValue(if (mPricePrecision==-1) point.price4MA30 else BigDecimalUtils.showSNormal(point.price4MA30.toString(),mPricePrecision).toFloat())
                    canvas.drawText(text, textLen + DisplayUtil.dip2px(35f), textHeight, paint4MA30)
                }
            } else if (status == MainKlineViewStatus.BOLL) {
                if (point!!.mb != 0f) {
                    var textLen = x
                    var text = "BOLL:" + view.formatValue(if (mPricePrecision==-1) point.mb else BigDecimalUtils.showSNormal(point.mb.toString(),mPricePrecision).toFloat()) + "     "
                    canvas.drawText(text, textLen + DisplayUtil.dip2px(5f), textHeight, paint4MA10)
                    textLen += paint4MA5.measureText(text)
                    text = "UB:" + view.formatValue(if (mPricePrecision==-1) point.up else BigDecimalUtils.showSNormal(point.up.toString(),mPricePrecision).toFloat()) + "     "
                    canvas.drawText(text, textLen, textHeight, paint4MA5)
                    textLen += paint4MA10.measureText(text)
                    text = "LB:" + view.formatValue(if (mPricePrecision==-1) point.dn else BigDecimalUtils.showSNormal(point.dn.toString(),mPricePrecision).toFloat())
                    canvas.drawText(text, textLen, textHeight, paint4MA30)
                }
            }
        }
        if (view.isLongPress) {
            drawMarker(view, canvas)
        }

    }

    override fun getMaxValue(point: CandleBean): Float {
        return if (status == MainKlineViewStatus.BOLL) {

//            when (point.up) {
//                Float.NaN -> {
//                    if (point.mb == 0f) point.highPrice else point.mb
//                }
//
//                0f -> {
//                    point.highPrice
//                }
//
//                else -> {
//                    point.up
//                }
//            }
            Math.max(point.up, point.highPrice)

        } else {
            maxOf(point.highPrice, point.price4MA30)
        }
    }

    override fun getMinValue(point: CandleBean): Float {
        return if (status == MainKlineViewStatus.BOLL) {
            if (point.dn == 0f) point.lowPrice else Math.min(point.dn, point.lowPrice)
        } else {
            if (point.price4MA30 == 0f) point.lowPrice else Math.min(point.price4MA30, point.lowPrice)
        }
    }

    override fun getValueFormatter(): IValueFormatter {
        return ValueFormatter()
    }

    override fun setTextSize(textSize: Float) {
        paint4MA30.textSize = textSize
        paint4MA10.textSize = textSize
        paint4MA5.textSize = textSize
    }

    override fun setLineWidth(width: Float) {
        paint4MA30.strokeWidth = width
        paint4MA10.strokeWidth = width
        paint4MA5.strokeWidth = width
        mLinePaint.strokeWidth = width
        markerBorderPaint.strokeWidth = width
    }

    override fun setFallRiseColor(riseColor: Int, fallColor: Int) {
        fallPaint.color = fallColor
        risePaint.color = riseColor
    }


    /**
     *Draw Candle
     *
     * @param canvas
     *@param x x-axis coordinates
     *Param high highest price
     *@param low lowest price
     *@param open opening price
     *@param close closing price
     */
    private fun drawCandle(view: BaseKLineChartView, canvas: Canvas, x: Float, high: Float, low: Float, open: Float, close: Float) {



        var high = high
        var low = low
        var open = open
        var close = close
        high = view.getMainY(high)
        low = view.getMainY(low)
        open = view.getMainY(open)
        close = view.getMainY(close)
        val r = candleWidth / 2
        val lineR = candleLineWidth / 2
        if (open > close) {



            //Solid
            if (isCandleSolid) {
                canvas.drawRect(x - r, close, x + r, open, fallPaint)
                canvas.drawRect(x - lineR, high, x + lineR, low, fallPaint)
            } else {
                fallPaint.strokeWidth = candleLineWidth
                canvas.drawLine(x, high, x, close, fallPaint)
                canvas.drawLine(x, open, x, low, fallPaint)
                canvas.drawLine(x - r + lineR, open, x - r + lineR, close, fallPaint)
                canvas.drawLine(x + r - lineR, open, x + r - lineR, close, fallPaint)
                fallPaint.strokeWidth = candleLineWidth * view.scaleX
                canvas.drawLine(x - r, open, x + r, open, fallPaint)
                canvas.drawLine(x - r, close, x + r, close, fallPaint)
            }

        } else if (open < close) {

            canvas.drawRect(x - r, open, x + r, close, risePaint)
            canvas.drawRect(x - lineR, high, x + lineR, low, risePaint)
        } else {
            canvas.drawRect(x - r, open, x + r, close + 1, fallPaint)
            canvas.drawRect(x - lineR, high, x + lineR, low, fallPaint)
        }
    }


    private fun drawMarker(view: BaseKLineChartView, canvas: Canvas) {
        val metrics = markerTitlePaint.fontMetrics
        val textHeight = metrics.descent - metrics.ascent

        val index = view.selectedIndex
        val padding = context.dip(8f).toFloat()
        val margin = context.dip(8f).toFloat()
        val topPadding = context.dip(4.0f).toFloat()
        val marginHor = context.dip(16f).toFloat()
        /**
         *Set the width of the MarkerView
         */
        var width = context.dip(116).toFloat()
        width += padding * 2

        val left: Float
        val top =   context.dip(36.0f).toFloat()
        val height = topPadding * 9 + textHeight * 8
        val radius = context.dip(4.0f).toFloat()

        val point = view.getItem(index) as IKLine

        var map = linkedMapOf<String, String>()
        //Time
        map[CpLanguageUtil.getString(context, "cp_marker_kline_text_dealTime")] = view.adapter?.getDate(index).toString()
        //On
        map[CpLanguageUtil.getString(context, "cp_marker_kline_text_open")] = CpBigDecimalUtils.showSNormal(point.openPrice.toString(),mPricePrecision)
        //High
        map[CpLanguageUtil.getString(context, "cp_marker_kline_text_high")] = CpBigDecimalUtils.showSNormal(point.highPrice.toString(),mPricePrecision)
        //Low
        map[CpLanguageUtil.getString(context, "cp_marker_kline_text_low")] = CpBigDecimalUtils.showSNormal(point.lowPrice.toString(),mPricePrecision)
        //Collection
        map[CpLanguageUtil.getString(context, "cp_marker_kline_text_close")] = CpBigDecimalUtils.showSNormal(point.closePrice.toString(),mPricePrecision)
        //Increase amount
        var lines = BigDecimalUtils.sub(point.closePrice.toString(), point.openPrice.toString()).toPlainString()
        map[LanguageUtil.getString(context, "kline_text_changeValue")] = RateManager.getAbsoluteText4Kline(lines)
        //Growth rate
        var fist = BigDecimalUtils.div(lines, point.openPrice.toString()).toPlainString()
        map[LanguageUtil.getString(context, "kline_text_changeRate")] = RateManager.getRoseText4Kline(fist)
        //Trading volume
        map[LanguageUtil.getString(context, "volume")] = BigDecimalUtils.divForDown(point.volume.toString(),mVolumePrecision).toPlainString()


        val x = view.translateXtoX(view.getX(index))
        left = if (x > view.chartWidth / 2) {
            marginHor
        } else {
            view.chartWidth - width - marginHor
        }

        val r = RectF(left, top, left + width, top + height)
        canvas.drawRoundRect(r, radius, radius, markerBgPaint)
        canvas.drawRoundRect(r, radius, radius, markerBorderPaint)

        var y = top + context.dip(4f) +(textHeight - metrics.bottom - metrics.top) / 2
        /**
         *Set Text R ->L
         */
        markerValuePaint.textAlign = Paint.Align.RIGHT
        for ((k, v) in map) {
            if (CpLanguageUtil.getString(context,"cp_kline_info1") == k || CpLanguageUtil.getString(context, "cp_kline_info2") == k) {
                markerValuePaint.color = CpColorUtil.getMainColorType(!v.contains("-"),
                    CpBigDecimalUtils.compareTo(v.replace("%",""),"0")==0)
            } else {
                markerValuePaint.color = CpColorUtil.getColor(context, com.chainup.contract.R.color.chart_max_min)
            }
            canvas.drawText(k, left + padding, y, markerTitlePaint)
            canvas.drawText(v, width - padding + left, y, markerValuePaint)
            y += textHeight + topPadding
        }

    }

    /**
     *
     * MarkerView
     * @param view
     * @param canvas
     */
    private fun drawMarker1(view: BaseKLineChartView, canvas: Canvas) {
        val metrics = markerTitlePaint.fontMetrics
        val textHeight = metrics.descent - metrics.ascent

        val index = view.selectedIndex
        val padding = context.dip(5f).toFloat()
        val margin = context.dip(5f).toFloat()
        /**
         *Set the width of the MarkerView
         */
        var width = context.dip(108).toFloat()
        width += padding * 2


        val left: Float
        val top = margin + view.topPadding
        val height = padding * 8 + textHeight * 9

        val point = view.getItem(index) as IKLine

        var map = linkedMapOf<String, String>()
        map[LanguageUtil.getString(context, "kline_text_dealTime")] = view.adapter?.getDate(index).toString()
        //On
        map[LanguageUtil.getString(context, "kline_text_open")] = BigDecimalUtils.showSNormal(point.openPrice.toString())
        //High
        map[LanguageUtil.getString(context, "kline_text_high")] = BigDecimalUtils.showSNormal(point.highPrice.toString())
        //Low
        map[LanguageUtil.getString(context, "kline_text_low")] = BigDecimalUtils.showSNormal(point.lowPrice.toString())
        //Collection
        map[LanguageUtil.getString(context, "kline_text_close")] = BigDecimalUtils.showSNormal(point.closePrice.toString())
        //Increase amount
        var lines = BigDecimalUtils.sub(point.closePrice.toString(), point.openPrice.toString()).toPlainString()
        map[LanguageUtil.getString(context, "kline_text_changeValue")] = RateManager.getAbsoluteText4Kline(lines)

        //Growth rate
        var fist = BigDecimalUtils.div(lines, point.openPrice.toString()).toPlainString()

        map[LanguageUtil.getString(context, "kline_text_changeRate")] = RateManager.getRoseText4Kline(fist)
        //Trading volume
        map[LanguageUtil.getString(context, "volume")] = BigDecimalUtils.divForDown(point.volume.toString(),mVolumePrecision).toPlainString()


        val x = view.translateXtoX(view.getX(index))
        left = if (x > view.chartWidth / 2) {
            margin
        } else {
            view.chartWidth - width - margin
        }
        val r = RectF(left, top, left + width, top + height + padding)
        canvas.drawRoundRect(r, padding, padding, markerBgPaint)

        canvas.drawRoundRect(r, DisplayUtil.dip2px(1.5f), DisplayUtil.dip2px(1.5f), markerBorderPaint)

        var y = top + padding * 2 + (textHeight - metrics.bottom - metrics.top) / 2
        /**
         *Set Text R ->L
         */
        markerValuePaint.textAlign = Paint.Align.RIGHT
        for ((k, v) in map) {
            if (LanguageUtil.getString(context,"kline_text_changeRate") == k || LanguageUtil.getString(context, "kline_text_changeValue") == k) {
                markerValuePaint.color = ColorUtil.getMainColorType(!v.contains("-"))
            } else {
                if (PublicInfoDataService.getInstance().klineThemeMode == 1){
                    markerValuePaint.color = ColorUtil.getColor(context,R.color.chart_max_min_kline_night)
                }else{
                    markerValuePaint.color = ColorUtil.getColor(context,R.color.chart_max_min)
                }
            }
            canvas.drawText(k, left + padding, y, markerTitlePaint)
            canvas.drawText(v, width - padding + left, y, markerValuePaint)
            y += textHeight + padding
        }

    }


    /**
     *Set candle width
     *
     * @param candleWidth
     */
    fun setCandleWidth(candleWidth: Float) {
        this.candleWidth = candleWidth
    }

    /**
     *Set candle line width
     *
     * @param candleLineWidth
     */
    fun setCandleLineWidth(candleLineWidth: Float) {
        this.candleLineWidth = candleLineWidth
    }

    /**
     *Set MA5 color
     *
     * @param color
     */
    fun setMa5Color(color: Int) {
        this.paint4MA5.color = color
    }

    /**
     *Set MA10 color
     *
     * @param color
     */
    fun setMa10Color(color: Int) {
        this.paint4MA10.color = color
    }

    fun setMaPricePrecision(pricePrecision: Int) {
        this.mPricePrecision = pricePrecision
    }

    /**
     *Set ma30 color
     *
     * @param color
     */
    fun setMa30Color(color: Int) {
        this.paint4MA30.color = color
    }

    /**
     *Set selector title text color (time, on, high, low, close)
     * @param color
     */
    fun setMarkerTitleColor(color: Int) {
        markerTitlePaint.color = color
    }

    /**
     *Set selector value text color
     * @param color
     */
    fun setMarkerValueColor(color: Int) {
        markerValuePaint.color = color
    }

    /**
     *Set selector text size
     * @param textSize
     */
    fun setMarkerTextSize(textSize: Float) {
        markerTitlePaint.textSize = textSize
        markerValuePaint.textSize = textSize
    }

    /**
     *Set selector background
     *
     * @param color
     */
    fun setMarkerBackgroundColor(color: Int) {
        markerBgPaint.color = color
    }


}
