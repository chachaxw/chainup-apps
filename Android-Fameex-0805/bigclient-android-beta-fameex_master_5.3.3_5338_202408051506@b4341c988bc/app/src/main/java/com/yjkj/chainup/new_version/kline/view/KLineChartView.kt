package com.yjkj.chainup.kline.view

import android.content.Context
import android.util.AttributeSet
import android.util.Log
import android.view.MotionEvent
import android.view.View
import android.view.animation.Animation
import android.view.animation.LinearInterpolator
import android.view.animation.RotateAnimation
import android.widget.ProgressBar
import androidx.annotation.DimenRes
import androidx.databinding.BindingAdapter
import com.chainup.contract.utils.CpColorUtil
import com.chainup.kit.views.KKButtonKit
import com.yjkj.chainup.R
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.extra_service.eventbus.NLiveDataUtil
import com.yjkj.chainup.kline.view.vice.KDJView
import com.yjkj.chainup.net.api.ApiConstants
import com.yjkj.chainup.new_version.kline.data.KLineChartAdapter
import com.yjkj.chainup.new_version.kline.view.BaseKLineChartView
import com.yjkj.chainup.new_version.kline.view.IFallRiseColor
import com.yjkj.chainup.new_version.kline.view.MainKlineViewStatus
import com.yjkj.chainup.new_version.kline.view.VolumeView
import com.yjkj.chainup.new_version.kline.view.vice.MACDView
import com.yjkj.chainup.new_version.kline.view.vice.RSIView
import com.yjkj.chainup.new_version.kline.view.vice.WRView
import com.yjkj.chainup.util.ColorUtil
import com.yjkj.chainup.ws.WsAgentManager
import io.reactivex.Observable
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import io.reactivex.schedulers.Schedulers
import org.jetbrains.anko.find
import org.jetbrains.anko.layoutInflater
import org.jetbrains.anko.runOnUiThread
import java.util.concurrent.TimeUnit
import kotlin.math.abs

/**
 * @Author: Bertking
 * @Date 2023/3/13-10:31 AM
 * @Description:
 */
class KLineChartView @JvmOverloads constructor(
        context: Context, attrs: AttributeSet? = null, defStyleAttr: Int = 0
) : BaseKLineChartView(context, attrs, defStyleAttr), IFallRiseColor {

    val TAG = KLineChartView::class.java.simpleName


    var mProgressBar: ProgressBar? = null
    private var btnRetry: KKButtonKit? = null
    private var isRefreshing = false
    private var isLoadMoreEnd = false
    private var mLastScrollEnable: Boolean = false
    private var mLastScaleEnable: Boolean = false
    var isPressing = false

    private var mRefreshListener: KChartRefreshListener? = null

    private var mMACDDraw: MACDView? = null
    private var mRSIDraw: RSIView? = null
    private var mMainDraw: MainKLineView? = null
    private var mKDJDraw: KDJView? = null
    private var mWRDraw: WRView? = null
    private var mVolumeDraw: VolumeView? = null
    private var startXX = 0
    private var startYY = 0
    private var volumePrecision = 2

    var isblack:Boolean = false
    private var loadDisposable: Disposable? = null
    private var loadingAnimation:RotateAnimation = RotateAnimation(
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



    init {
        initView()
        initAttrs(attrs)
    }

    fun setVolumePrecision(precision:Int){
        volumePrecision = precision
        mMainDraw?.setVolumePrecision(precision)
    }

    private fun initView() {
        if (PublicInfoDataService.getInstance().klineThemeMode != ApiConstants.themeDay()) {
            isblack = true
        }
        /**
         *Progress bar
         */
        val view = context.layoutInflater.inflate(R.layout.layout_kline_loading, this,true)
        mProgressBar = view.findViewById(R.id.pb_kline_load)
        btnRetry = view.findViewById(R.id.kbtn_retry)
        btnRetry!!.visibility = View.GONE
        mProgressBar!!.clearAnimation()
        mProgressBar!!.visibility = View.GONE
        btnRetry!!.setOnClickListener {
            NLiveDataUtil.postValue(MessageEvent(MessageEvent.kline_retry_event,WsAgentManager.instance.keyLine))
        }
        mMACDDraw = MACDView(this)
        mWRDraw = WRView(this)
        mKDJDraw = KDJView(this)
        mRSIDraw = RSIView(this)

        /**
         *Trading volume chart
         */
        mVolumeDraw = VolumeView(this)

        /**
         *Main K diagram
         */
        mMainDraw = MainKLineView(this)

        addChildDraw(mMACDDraw)
        addChildDraw(mKDJDraw)
        addChildDraw(mRSIDraw)
        addChildDraw(mWRDraw)

        volDraw = mVolumeDraw
        mainDraw = mMainDraw
        setMACDView(mMACDDraw)
        setWRView(mWRDraw)
        setKDJDraw(mKDJDraw)
        setRSIDraw(mRSIDraw)
    }

    private fun initAttrs(attrs: AttributeSet?) {
        val array = context.obtainStyledAttributes(attrs, R.styleable.KLineChartView)
        if (array != null) {
            try {
                var text_Color = if (isblack){R.color.text_color_kline_night}else{R.color.text_color}
                var normal_text_color = if (isblack){R.color.normal_text_color_kline_night}else{R.color.normal_text_color}
                var bg_card_color = if (isblack){R.color.bg_card_color_kline_night}else{R.color.bg_card_color}
                var chart_max_min = if (isblack){R.color.chart_max_min_kline_night}else{R.color.chart_max_min}
                var marker_bg = if (isblack){R.color.marker_bg_kline_night}else{R.color.marker_bg}
                /**
                 *Set the color of candle lines and trading volume columns
                 */
                setFallRiseColor(ColorUtil.getMainColorType(), ColorUtil.getMainColorType(false))

                /**
                 *Candle Line Related Settings
                 */
                setCandleWidth(array.getDimension(R.styleable.KLineChartView_kc_candle_width, getDimension(R.dimen.chart_candle_width)))
                setCandleLineWidth(array.getDimension(R.styleable.KLineChartView_kc_candle_line_width, getDimension(R.dimen.chart_candle_line_width)))
                setCandleSolid(array.getBoolean(R.styleable.KLineChartView_kc_candle_solid, true))


                /**
                 *MA&Candle Line
                 */
                setMa5Color(array.getColor(R.styleable.KLineChartView_kc_dif_color, ColorUtil.getColor(context, R.color.chart_ma5)))
                setMa10Color(array.getColor(R.styleable.KLineChartView_kc_dea_color, ColorUtil.getColor(context, R.color.chart_ma10)))
                setMa30Color(array.getColor(R.styleable.KLineChartView_kc_macd_color, ColorUtil.getColor(context, R.color.chart_ma30)))

                /**
                 *Maximum&Minimum Values on KLine Graphs
                 */
                setMTextSize(array.getDimension(R.styleable.KLineChartView_kc_text_size, getDimension(R.dimen.chart_text_size)))

                val textMixColor = array.getColor(R.styleable.KLineChartView_kc_text_color, ColorUtil.getColor(context, text_Color))
                setMTextColor(textMixColor)


                /**
                 *KLineView, boundary value on the right side of VolumeView
                 */
                setBoundaryValueColor(array.getColor(R.styleable.KLineChartView_kc_boundary_value, ColorUtil.getColor(context, normal_text_color)))


                /**
                 *Point determines the gap between the candle lines
                 */
                setPointWidth(array.getDimension(R.styleable.KLineChartView_kc_point_width, getDimension(R.dimen.chart_point_width)))
                setSelectPointColor(array.getColor(R.styleable.KLineChartView_kc_background_color, ColorUtil.getColor(context, bg_card_color)))

                /**
                 *Value on the boundary of KLine, Volume
                 */
                textSize = array.getDimension(R.styleable.KLineChartView_kc_text_size, getDimension(R.dimen.chart_text_size))
                setTextColor(array.getColor(R.styleable.KLineChartView_kc_text_color, ColorUtil.getColor(context,  chart_max_min)))

                /**
                 *Background color of the main image (KLine, volume, sub image)
                 */
                setBackgroundColor(array.getColor(R.styleable.KLineChartView_kc_background_color, ColorUtil.getColor(context, bg_card_color)))
                /**
                 *The width of the indicator line in the main image
                 */
                lineWidth = array.getDimension(R.styleable.KLineChartView_kc_line_width, getDimension(R.dimen.chart_line_width))

                /**
                 *Select the color of the X-axis
                 */
                setSelectedXLineColor(ColorUtil.getColor(context, R.color.chart_selected_x))
                setSelectedXLineWidth(getDimension(R.dimen.chart_line_width))
                /**
                 *Select the color of the Y-axis
                 */
                setSelectedYLineColor(ColorUtil.getColor(context, R.color.chart_selected_y))
                setSelectedYLineWidth(getDimension(R.dimen.chart_selected_y_width))

                /**
                 *Gridline parameters
                 */
                setGridLineWidth(array.getDimension(R.styleable.KLineChartView_kc_grid_line_width, getDimension(R.dimen.chart_grid_line_width)))
                setGridLineColor(array.getColor(R.styleable.KLineChartView_kc_grid_line_color, ColorUtil.getColor(context, R.color.line_color)))


                /**
                 * MACD
                 */
                setMACDWidth(array.getDimension(R.styleable.KLineChartView_kc_macd_width, getDimension(R.dimen.chart_candle_width)))
                setDIFColor(array.getColor(R.styleable.KLineChartView_kc_dif_color, ColorUtil.getColor(context, R.color.chart_ma5)))
                setDEAColor(array.getColor(R.styleable.KLineChartView_kc_dea_color, ColorUtil.getColor(context, R.color.chart_ma10)))
                setMACDColor(array.getColor(R.styleable.KLineChartView_kc_macd_color, ColorUtil.getColor(context, R.color.chart_ma30)))

                /**
                 * KDJ
                 */
                setKColor(array.getColor(R.styleable.KLineChartView_kc_dif_color, ColorUtil.getColor(context, R.color.chart_ma5)))
                setDColor(array.getColor(R.styleable.KLineChartView_kc_dea_color, ColorUtil.getColor(context, R.color.chart_ma10)))
                setJColor(array.getColor(R.styleable.KLineChartView_kc_macd_color, ColorUtil.getColor(context, R.color.chart_ma30)))
                /**
                 * WR
                 */
                setRColor(array.getColor(R.styleable.KLineChartView_kc_dif_color, ColorUtil.getColor(context, R.color.chart_ma5)))
                /**
                 * RSI
                 */
                setRSI1Color(array.getColor(R.styleable.KLineChartView_kc_dif_color, ColorUtil.getColor(context, R.color.chart_ma5)))
                setRSI2Color(array.getColor(R.styleable.KLineChartView_kc_dea_color, ColorUtil.getColor(context, R.color.chart_ma10)))
                setRSI3Color(array.getColor(R.styleable.KLineChartView_kc_macd_color, ColorUtil.getColor(context, R.color.chart_ma30)))


                /**
                 *The background color of MarkView
                 */
                setSelectorBackgroundColor(array.getColor(R.styleable.KLineChartView_kc_selector_background_color, ColorUtil.getColor(context, marker_bg)))
                setSelectorTextSize(array.getDimension(R.styleable.KLineChartView_kc_selector_text_size, getDimension(R.dimen.cp_chart_selector_text_size)))
                setMarkerTitleColor(CpColorUtil.getColor(context, R.color.text_color_2))
                setMarkerValueColor(array.getColor(R.styleable.KLineChartView_kc_marker_value_color, ColorUtil.getColor(context, chart_max_min)))

                setSelectedTextColor(array.getColor(R.styleable.KLineChartView_kc_text_color, ColorUtil.getColor(context, chart_max_min)))


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
                    btnRetry!!.visibility = View.GONE
                    mProgressBar!!.startAnimation(loadingAnimation)
                }
            }

            if (mRefreshListener != null) {
                mRefreshListener!!.onLoadMoreBegin()
            }
            NLiveDataUtil.postValue(MessageEvent(MessageEvent.kline_loadmore_event,WsAgentManager.instance.keyLine))
            super.setScrollEnable(false)
            super.setScaleEnable(false)

            loadDisposable?.dispose()

            loadDisposable = Observable.timer(5L, TimeUnit.SECONDS)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe {
                    //time out
                    Log.d(TAG,"kline loading time out================")
                    refreshComplete()
                    if(!WsAgentManager.instance.isConnection()){
                        btnRetry!!.visibility = View.VISIBLE
                    }
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
                    btnRetry!!.visibility = View.GONE
                    mProgressBar!!.startAnimation(loadingAnimation)
                }
            }

//            if (mRefreshListener != null) {
//                mRefreshListener!!.onLoadMoreBegin(this)
//            }

            super.setScrollEnable(false)
            super.setScaleEnable(false)
            loadDisposable?.dispose()
            loadDisposable = Observable.timer(5L, TimeUnit.SECONDS)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe {
                    //time out
                    Log.d(TAG,"kline loading time out================")
                    refreshComplete()
                    if(!WsAgentManager.instance.isConnection()){
                        btnRetry!!.visibility = View.VISIBLE
                    }
                }
        }
    }

    fun showLoading2(){
        context.runOnUiThread {
            isRefreshing = true
            if (mProgressBar != null) {
                mProgressBar!!.visibility = View.VISIBLE
                btnRetry!!.visibility = View.GONE
                mProgressBar!!.startAnimation(loadingAnimation)
                loadDisposable?.dispose()
                loadDisposable = Observable.timer(5L, TimeUnit.SECONDS)
                    .subscribeOn(Schedulers.io())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe {
                        //time out
                        Log.d(TAG,"kline loading time out================")
                        refreshComplete()
                        if(!WsAgentManager.instance.isConnection()){
                            btnRetry!!.visibility = View.VISIBLE
                        }
                    }
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
        isLoadMoreEnd = false
        isRefreshing = false
        hideLoading()
        btnRetry!!.visibility = View.GONE
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
        fun onLoadMoreBegin()
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
        //TODO must be the opposite here, the logic of the candle line is reversed
        mMainDraw?.setFallRiseColor(fallColor, riseColor)
        mVolumeDraw?.setFallRiseColor(riseColor, fallColor)
        mMACDDraw?.setFallRiseColor(riseColor, fallColor)
    }


    /**
     *Set DIF color
     */
    fun setDIFColor(color: Int) {
        mMACDDraw!!.setDIFColor(color)
    }

    /**
     *Set DEA color
     */
    fun setDEAColor(color: Int) {
        mMACDDraw!!.setDEAColor(color)
    }

    /**
     *Set MACD color
     */
    fun setMACDColor(color: Int) {
        mMACDDraw!!.setMACDColor(color)
    }

    /**
     *Set the width of MACD
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
     *Set D color
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
     *Set R color
     */
    fun setRColor(color: Int) {
        mWRDraw?.setRColor(color)
    }

    /**
     *Set MA5 color
     *
     * @param color
     */
    fun setMa5Color(color: Int) {
        mMainDraw?.setMa5Color(color)
        mVolumeDraw?.setMa5Color(color)
    }


    /**
     *Set MA10 color
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
     *Set selector background
     *
     * @param color
     */
    fun setSelectorBackgroundColor(color: Int) {
        mMainDraw?.setMarkerBackgroundColor(color)
    }
    fun kc_selector_background_color(color: Int) {
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

    fun kc_marker_value_color(color: Int){
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
