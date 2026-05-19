package com.yjkj.chainup.kline.view

import android.content.Context
import android.graphics.Color
import android.graphics.Rect
import android.graphics.RectF
import android.util.AttributeSet
import android.util.Log
import android.view.MotionEvent
import android.view.View
import android.view.animation.Animation
import android.view.animation.LinearInterpolator
import android.view.animation.RotateAnimation
import android.widget.ProgressBar
import androidx.annotation.DimenRes
import com.chainup.contract.R
import com.chainup.contract.kline.view.CpBaseKLineChartView
import com.chainup.contract.utils.CpClLogicContractSetting
import com.chainup.contract.utils.CpColorUtil
import com.chainup.contract.utils.CpScreenUtil
import com.chainup.contract.utils.CpSizeUtils
import com.yjkj.chainup.kline.view.vice.CpKDJView
import com.yjkj.chainup.new_version.kline.view.CpIFallRiseColor
import com.yjkj.chainup.new_version.kline.view.cp.MainKlineViewStatus
import com.yjkj.chainup.new_version.kline.view.CpVolumeView
import com.yjkj.chainup.new_version.kline.view.vice.CpMACDView
import com.yjkj.chainup.new_version.kline.view.vice.CpRSIView
import com.yjkj.chainup.new_version.kline.view.vice.CpWRView
import io.reactivex.Observable
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import io.reactivex.schedulers.Schedulers
import org.jetbrains.anko.layoutInflater
import org.jetbrains.anko.runOnUiThread
import java.util.concurrent.TimeUnit
import kotlin.math.abs

/**
 * @Author: Bertking
 * @Date：2019/3/13-10:31 AM
 * @Description:
 */
class CpKLineChartView @JvmOverloads constructor(
        context: Context, attrs: AttributeSet? = null, defStyleAttr: Int = 0
) : CpBaseKLineChartView(context, attrs, defStyleAttr), CpIFallRiseColor {

    val TAG = CpKLineChartView::class.java.simpleName
    var isPressing = false

    private var loadingAnimation:RotateAnimation? = null

    var mProgressBar: ProgressBar? = null
    private var isRefreshing = false
    private var isLoadMoreEnd = false
    private var loadDisposable:Disposable? = null

    private var mRefreshListener: KChartRefreshListener? = null

    private var mMACDDraw: CpMACDView? = null
    private var mRSIDraw: CpRSIView? = null
    private var mMainDraw: CpMainKLineView? = null
    private var mKDJDraw: CpKDJView? = null
    private var mWRDraw: CpWRView? = null
    private var mVolumeDraw: CpVolumeView? = null
    private var startXX = 0
    private var startYY = 0


    init {
        initView()
        initAttrs(attrs)
    }

    private fun initView() {
        /**
         *Progress bar
         */
        val view = context.layoutInflater.inflate(R.layout.cp_layout_kline_loading, this,true)
        mProgressBar = view.findViewById(R.id.pb_kline_load)

        loadingAnimation = RotateAnimation(
            0f,360f,
            Animation.RELATIVE_TO_SELF,
            0.5f,
            Animation.RELATIVE_TO_SELF,
            0.5f
        ).apply {
            repeatCount = Animation.INFINITE
            fillAfter = true
            interpolator = LinearInterpolator()
            duration = 300L
        }

        mProgressBar!!.visibility = View.GONE
        mMACDDraw = CpMACDView(this)
        mWRDraw = CpWRView(this)
        mKDJDraw = CpKDJView(this)
        mRSIDraw = CpRSIView(this)

        /**
         *Transaction volume chart
         */
        mVolumeDraw = CpVolumeView(this)

        /**
         *Main K diagram
         */
        mMainDraw = CpMainKLineView(this)

        addChildDraw(mMACDDraw)
        addChildDraw(mKDJDraw)
        addChildDraw(mRSIDraw)
        addChildDraw(mWRDraw)

        volDraw = mVolumeDraw
        mainDraw = mMainDraw

    }

    override fun setPricePrecision(position: Int) {
        super.setPricePrecision(position)
        mVolumeDraw?.setPricePrecision(position)
        mMACDDraw?.pricePrecision = position
    }

    fun setVolumeDrawVisible(visible:Boolean){
        if(visible) volDraw = mVolumeDraw
        else volDraw = null
    }

    private fun initAttrs(attrs: AttributeSet?) {
        val array = context.obtainStyledAttributes(attrs, R.styleable.CpKLineChartView)
        if (array != null) {
            try {
                /**
                 *Set the color of candle lines and transaction volume columns
                 */
                setFallRiseColor(CpColorUtil.getMainColorType(), CpColorUtil.getMainColorType(false))

                /**
                 *Candle Line Related Settings
                 */
                setCandleWidth(array.getDimension(R.styleable.CpKLineChartView_kc_candle_width, getDimension(R.dimen.chart_candle_width)))
                setCandleLineWidth(array.getDimension(R.styleable.CpKLineChartView_kc_candle_line_width, getDimension(R.dimen.chart_candle_line_width)))
                setCandleSolid(array.getBoolean(R.styleable.CpKLineChartView_kc_candle_solid, true))


                /**
                 *MA&Candle Line
                 */
                setMa5Color(array.getColor(R.styleable.CpKLineChartView_kc_dif_color, CpColorUtil.getColor(context,R.color.chart_ma5)))
                setMa10Color(array.getColor(R.styleable.CpKLineChartView_kc_dea_color, CpColorUtil.getColor(context,R.color.chart_ma10)))
                setMa30Color(array.getColor(R.styleable.CpKLineChartView_kc_macd_color, CpColorUtil.getColor(context,R.color.chart_ma30)))

                /**
                 *Maximum&Minimum Values on KLine Graphs
                 */
                setMTextSize(array.getDimension(R.styleable.CpKLineChartView_kc_text_size, getDimension(R.dimen.chart_text_size)))
                val textMixColor = array.getColor(R.styleable.CpKLineChartView_kc_text_color, CpColorUtil.getColor(context,R.color.text_color))
                setMTextColor(textMixColor)


                /**
                 *The boundary value on the right side of KLineView and VolumeView
                 */
                setBoundaryValueColor(array.getColor(R.styleable.CpKLineChartView_kc_boundary_value, CpColorUtil.getColor(context,R.color.text_color_3)))


                /**
                 *Point determines the gap between the candle lines
                 */
                setPointWidth(array.getDimension(R.styleable.CpKLineChartView_kc_point_width, getDimension(R.dimen.chart_point_width)))

                setSelectPointColor(array.getColor(R.styleable.CpKLineChartView_kc_background_color, CpColorUtil.getColor(context,R.color.bg_card_color)))

                /**
                 *The value on the boundary of KLine, Volume
                 */
                textSize = array.getDimension(R.styleable.CpKLineChartView_kc_text_size, getDimension(R.dimen.chart_text_size))

                setTextColor(array.getColor(R.styleable.CpKLineChartView_kc_text_color, CpColorUtil.getColor(context,R.color.chart_max_min)))

                /**
                 *Background color of the main graph (KLine, volume, sub graph)
                 */

                val dayMode = CpClLogicContractSetting.getThemeMode(context)
                val hasLinearGradient = array.getBoolean(R.styleable.CpKLineChartView_has_linear_gradient,false)
                if(dayMode==1 && hasLinearGradient){
                    val mRect = Rect(0,0,CpScreenUtil.getWidth(context),CpSizeUtils.dp2px(410.0f))
                    setLinearGradientColor(mRect, Color.parseColor("#010101"),Color.parseColor("#111111"))
                }else{
                    setBackgroundColor(array.getColor(R.styleable.CpKLineChartView_kc_background_color, CpColorUtil.getColor(context,R.color.bg_card_color)))
                }

                /**
                 *Width of indicator line in main graph
                 */
                lineWidth = array.getDimension(R.styleable.CpKLineChartView_kc_line_width, getDimension(R.dimen.cp_chart_line_width))

                /**
                 *Select the color of the X axis
                 */
                setSelectedXLineColor(CpColorUtil.getColor(context,R.color.cp_chart_selected_x))
                setSelectedXLineWidth(getDimension(R.dimen.cp_chart_line_width))
                /**
                 *Select the color of the Y axis
                 */
                setSelectedYLineColor(CpColorUtil.getColor(context,R.color.cp_chart_selected_y))
                setSelectedYLineWidth(getDimension(R.dimen.cp_chart_selected_y_width))

                /**
                 *Gridline parameters
                 */
                setGridLineWidth(array.getDimension(R.styleable.CpKLineChartView_kc_grid_line_width, getDimension(R.dimen.chart_grid_line_width)))
                setGridLineColor(array.getColor(R.styleable.CpKLineChartView_kc_grid_line_color, CpColorUtil.getColor(context,R.color.line_color)))


                /**
                 * MACD
                 */
                setMACDWidth(array.getDimension(R.styleable.CpKLineChartView_kc_macd_width, getDimension(R.dimen.chart_candle_width)))
                setDIFColor(array.getColor(R.styleable.CpKLineChartView_kc_dif_color, CpColorUtil.getColor(context,R.color.chart_ma5)))
                setDEAColor(array.getColor(R.styleable.CpKLineChartView_kc_dea_color, CpColorUtil.getColor(context,R.color.chart_ma10)))
                setMACDColor(array.getColor(R.styleable.CpKLineChartView_kc_macd_color, CpColorUtil.getColor(context,R.color.chart_ma30)))

                /**
                 * KDJ
                 */
                setKColor(array.getColor(R.styleable.CpKLineChartView_kc_dif_color, CpColorUtil.getColor(context,R.color.chart_ma5)))
                setDColor(array.getColor(R.styleable.CpKLineChartView_kc_dea_color, CpColorUtil.getColor(context,R.color.chart_ma10)))
                setJColor(array.getColor(R.styleable.CpKLineChartView_kc_macd_color, CpColorUtil.getColor(context,R.color.chart_ma30)))
                /**
                 * WR
                 */
                setRColor(array.getColor(R.styleable.CpKLineChartView_kc_dif_color, CpColorUtil.getColor(context,R.color.chart_ma5)))
                /**
                 * RSI
                 */
                setRSI1Color(array.getColor(R.styleable.CpKLineChartView_kc_dif_color, CpColorUtil.getColor(context,R.color.chart_ma5)))
                setRSI2Color(array.getColor(R.styleable.CpKLineChartView_kc_dea_color, CpColorUtil.getColor(context,R.color.chart_ma10)))
                setRSI3Color(array.getColor(R.styleable.CpKLineChartView_kc_macd_color, CpColorUtil.getColor(context,R.color.chart_ma30)))


                /**
                 *The background color of MarkView
                 */
                setSelectorBackgroundColor(array.getColor(R.styleable.CpKLineChartView_kc_selector_background_color, CpColorUtil.getColor(context,R.color.marker_bg)))
                setSelectorTextSize(array.getDimension(R.styleable.CpKLineChartView_kc_selector_text_size, getDimension(R.dimen.cp_chart_selector_text_size)))
//                setMarkerTitleColor(array.getColor(R.styleable.CpKLineChartView_kc_text_color, CpColorUtil.getColor(context,R.color.normal_text_color)))
                setMarkerTitleColor( CpColorUtil.getColor(context,R.color.text_color_2))
                setMarkerValueColor(array.getColor(R.styleable.CpKLineChartView_kc_marker_value_color, CpColorUtil.getColor(context,R.color.chart_max_min)))

                setSelectedTextColor(array.getColor(R.styleable.CpKLineChartView_kc_text_color, CpColorUtil.getColor(context,R.color.chart_max_min)))


            } catch (e: Exception) {
                e.printStackTrace()
            } finally {
                array.recycle()
            }
        }
    }

    private fun getDimension(@DimenRes resId: Int): Float {
        return resources.getDimension(resId)
    }


    override fun onLeftSide() {
        showLoading()
    }

    override fun onRightSide() {}

    fun showLoading() {
        if (!isLoadMoreEnd && !isRefreshing) {
            isRefreshing = true

            context.runOnUiThread {
                if (mProgressBar != null) {
                    mProgressBar!!.visibility = View.VISIBLE
                    mProgressBar!!.startAnimation(loadingAnimation)
                }
            }

            if (mRefreshListener != null) {
                mRefreshListener!!.onLoadMoreBegin(this)
            }
            super.setScrollEnable(false)
            super.setScaleEnable(false)

            loadDisposable?.dispose()

            loadDisposable = Observable.timer(5L,TimeUnit.SECONDS)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe {
                    //time out
                    Log.d(TAG,"kline loading time out================")
                    refreshComplete()
                }

        }
    }

    fun justShowLoading() {
        if (!isRefreshing) {
            isLongPress = false
            isRefreshing = true
            context.runOnUiThread {
                if (mProgressBar != null) {
                    mProgressBar!!.visibility = View.VISIBLE
                    mProgressBar!!.startAnimation(loadingAnimation)
                }
            }

            if (mRefreshListener != null) {
                mRefreshListener!!.onLoadMoreBegin(this)
            }

            super.setScrollEnable(false)
            super.setScaleEnable(false)
        }
    }

    fun showLoading2(){
        context.runOnUiThread {
            if (mProgressBar != null) {
                mProgressBar!!.visibility = View.VISIBLE
                mProgressBar!!.startAnimation(loadingAnimation)
            }
        }
    }

    private fun hideLoading() {
        context.runOnUiThread {
            if (mProgressBar != null) {
                mProgressBar!!.clearAnimation()
                mProgressBar!!.visibility = View.GONE

            }
        }

        super.setScrollEnable(true)
        super.setScaleEnable(true)
        loadDisposable?.dispose()
    }
    /**
     *Refresh Complete
     */
    fun refreshComplete() {
        isRefreshing = false
        hideLoading()
    }

    /**
     *Refresh completed, no data available
     */
    fun refreshEnd() {
        isLoadMoreEnd = true
        isRefreshing = false
        hideLoading()
    }

    fun resetAllStatus(){
        isLoadMoreEnd = false
        isRefreshing = false
        hideLoading()
    }

    interface KChartRefreshListener {
        /**
         *Load more
         *
         * @param chart
         */
        fun onLoadMoreBegin(chart: CpKLineChartView)
    }

    override fun setScaleEnable(scaleEnable: Boolean) {
        if (isRefreshing) {
            throw IllegalStateException("请勿在刷新状态设置属性")
        }
        super.setScaleEnable(scaleEnable)

    }

    override fun setScrollEnable(scrollEnable: Boolean) {
        if (isRefreshing) {
            throw IllegalStateException("请勿在刷新状态设置属性")
        }
        super.setScrollEnable(scrollEnable)
    }

    override fun setFallRiseColor(riseColor: Int, fallColor: Int) {
        //TODO must be reversed here, the logic of the candle line is reversed
        mMainDraw?.setFallRiseColor(fallColor, riseColor)
        mVolumeDraw?.setFallRiseColor(riseColor, fallColor)
        mMACDDraw?.setFallRiseColor(riseColor, fallColor)
    }


    /**
     *Set DIF Color
     */
    fun setDIFColor(color: Int) {
        mMACDDraw!!.setDIFColor(color)
    }

    /**
     *Set DEA Color
     */
    fun setDEAColor(color: Int) {
        mMACDDraw!!.setDEAColor(color)
    }

    /**
     *Set MACD Color
     */
    fun setMACDColor(color: Int) {
        mMACDDraw!!.setMACDColor(color)
    }

    /**
     *Set the width of the MACD
     *
     * @param MACDWidth
     */
    fun setMACDWidth(MACDWidth: Float) {
        mMACDDraw?.setMACDWidth(MACDWidth)
    }

    /**
     *Set K Color
     */
    fun setKColor(color: Int) {
        mKDJDraw?.setKColor(color)
    }

    /**
     *Set D Color
     */
    fun setDColor(color: Int) {
        mKDJDraw?.setDColor(color)
    }

    /**
     *Set J Color
     */
    fun setJColor(color: Int) {
        mKDJDraw?.setJColor(color)
    }

    /**
     *Set R Color
     */
    fun setRColor(color: Int) {
        mWRDraw?.setRColor(color)
    }

    /**
     *Set ma5 color
     *
     * @param color
     */
    fun setMa5Color(color: Int) {
        mMainDraw?.setMa5Color(color)
        mVolumeDraw?.setMa5Color(color)
    }


    /**
     *Set ma10 color
     *
     * @param color
     */
    fun setMa10Color(color: Int) {
        mMainDraw?.setMa10Color(color)
        mVolumeDraw?.setMa10Color(color)
    }

    /**
     *Set ma20 color
     *
     * @param color
     */
    fun setMa30Color(color: Int) {
        mMainDraw?.setMa30Color(color)
    }

    /**
     *Set selector text size
     *
     * @param textSize
     */
    fun setSelectorTextSize(textSize: Float) {
        mMainDraw?.setMarkerTextSize(textSize)
    }

    /**
     *Set Selector Background
     *
     * @param color
     */
    fun setSelectorBackgroundColor(color: Int) {
        mMainDraw?.setMarkerBackgroundColor(color)
    }

    /**
     *Set candle width
     *
     * @param candleWidth
     */
    fun setCandleWidth(candleWidth: Float) {
        mMainDraw?.setCandleWidth(candleWidth)
    }

    /**
     *Set candle line width
     *
     * @param candleLineWidth
     */
    fun setCandleLineWidth(candleLineWidth: Float) {
        mMainDraw!!.setCandleLineWidth(candleLineWidth)
    }

    /**
     *Is the candle hollow
     */
    fun setCandleSolid(candleSolid: Boolean) {
        mMainDraw!!.isCandleSolid = candleSolid
    }

    fun setRSI1Color(color: Int) {
        mRSIDraw!!.setRSI1Color(color)
    }

    fun setRSI2Color(color: Int) {
        mRSIDraw!!.setRSI2Color(color)
    }

    fun setRSI3Color(color: Int) {
        mRSIDraw!!.setRSI3Color(color)
    }

    override fun setTextSize(textSize: Float) {
        super.setTextSize(textSize)
        mMainDraw?.setTextSize(textSize)
        mRSIDraw?.setTextSize(textSize)
        mMACDDraw?.setTextSize(textSize)
        mKDJDraw?.setTextSize(textSize)
        mWRDraw?.setTextSize(textSize)
        mVolumeDraw?.setTextSize(textSize)
    }

    override fun setLineWidth(lineWidth: Float) {
        super.setLineWidth(lineWidth)
        mMainDraw!!.setLineWidth(lineWidth)
        mRSIDraw!!.setLineWidth(lineWidth)
        mMACDDraw!!.setLineWidth(lineWidth)
        mKDJDraw!!.setLineWidth(lineWidth)
        mWRDraw!!.setLineWidth(lineWidth)
        mVolumeDraw!!.setLineWidth(lineWidth)
    }


    fun setMarkerTitleColor(color: Int) {
        mMainDraw?.setMarkerTitleColor(color)
    }


    fun setMarkerValueColor(color: Int) {
        mMainDraw?.setMarkerValueColor(color)
    }

    /**
     *Set refresh listening
     */
    fun setRefreshListener(refreshListener: KChartRefreshListener) {
        mRefreshListener = refreshListener
    }

    fun setMainDrawLine(isLine: Boolean) {
        mMainDraw!!.isLine = isLine
        mVolumeDraw!!.isLine = isLine
        invalidate()
    }


    override fun onInterceptTouchEvent(ev: MotionEvent): Boolean {
        when (ev.action) {
            MotionEvent.ACTION_DOWN -> {
                startXX = ev.x.toInt()
                startYY = ev.y.toInt()
                Log.d("onInterceptTouchEvent", "====DOWN====x:${ev.x.toInt()},y:${ev.y.toInt()}========")
            }
            MotionEvent.ACTION_MOVE -> {
                Log.d("onInterceptTouchEvent", "====MOVE====x:${ev.x.toInt()},y:${ev.y.toInt()}========")
                val dX = (ev.x - startXX).toInt()
                val dY = (ev.y - startYY).toInt()
            }
            MotionEvent.ACTION_UP -> {
                Log.d("onInterceptTouchEvent", "====UP====x:${ev.x.toInt()},y:${ev.y.toInt()}========")

//                return Math.abs(dX) > Math.abs(dY)
            }
        }
        return super.onInterceptTouchEvent(ev)
    }


    override fun onTouchEvent(event: MotionEvent?): Boolean {
        val action = event?.action?.and(MotionEvent.ACTION_MASK)
        when (action) {
            MotionEvent.ACTION_DOWN -> {
                startXX = event.x.toInt()
                startYY = event.y.toInt()

                Log.d("onTouchEvent", "====DOWN====x:${event.x.toInt()},y:${event.y.toInt()}========")

            }

            MotionEvent.ACTION_MOVE -> {
                val dx = (event.x.toInt() - startXX)
                val dy = (event.y.toInt() - startYY)
                //Press more than 1 finger
                if (event.pointerCount > 1) {
                    parent.requestDisallowInterceptTouchEvent(true)
                } else {
                    if(!isPressing){
                        val isHor = (abs(dx) - abs(dy)) > 100
                        if(isHor) isPressing = true
                    }
                    parent.requestDisallowInterceptTouchEvent(isPressing||isLongPress)
                }
            }

            MotionEvent.ACTION_UP -> {
                isPressing = false
                parent.requestDisallowInterceptTouchEvent(false)
                Log.d("onTouchEvent", "====UP====x:${event.x.toInt()},y:${event.y.toInt()}========")
            }
        }
        return super.onTouchEvent(event)
    }


    override fun onLongPress(e: MotionEvent) {
        if (!isRefreshing) {
            super.onLongPress(e)
        }
    }


    fun getMainDrawStatus(): MainKlineViewStatus? {
        return mMainDraw?.status
    }


}
