package com.yjkj.chainup.new_contract.activity

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.view.Window
import android.view.WindowManager
import android.widget.CheckBox
import android.widget.CompoundButton
import android.widget.LinearLayout
import android.widget.TextView
import androidx.annotation.NonNull
import androidx.core.content.ContextCompat
import androidx.core.view.children
import androidx.fragment.app.FragmentManager
import androidx.recyclerview.widget.GridLayoutManager
import com.chainup.contract.R
import com.chainup.contract.adapter.CpHKLineScaleAdapter
import com.chainup.contract.app.CpParamConstant
import com.chainup.contract.base.CpNBaseActivity
import com.chainup.contract.bean.KlineTick
import com.chainup.contract.eventbus.CpEventBusUtil
import com.chainup.contract.eventbus.CpMessageEvent
import com.chainup.contract.utils.*
import com.chainup.contract.ws.CpWsContractAgentManager
import com.yjkj.chainup.manager.CpLanguageUtil
import com.yjkj.chainup.new_version.kline.bean.CpKLineBean
import com.yjkj.chainup.new_version.kline.data.CpKLineChartAdapter
import com.yjkj.chainup.new_version.kline.view.cp.MainKlineViewStatus
import com.yjkj.chainup.new_version.kline.view.vice.CpViceViewStatus
import io.flutter.embedding.android.FlutterFragment
import org.jetbrains.anko.textColor
import org.json.JSONObject
import java.util.*


import kotlinx.android.synthetic.main.cp_activity_horizon_market_detail.*
import kotlinx.android.synthetic.main.cp_activity_horizon_market_detail.rv_kline_scale
import kotlinx.android.synthetic.main.cp_activity_horizon_market_detail.tv_24h_vol
import kotlinx.android.synthetic.main.cp_activity_horizon_market_detail.tv_close_price
import kotlinx.android.synthetic.main.cp_activity_horizon_market_detail.tv_coin_map
import kotlinx.android.synthetic.main.cp_activity_horizon_market_detail.tv_converted_close_price
import kotlinx.android.synthetic.main.cp_activity_horizon_market_detail.tv_high_price
import kotlinx.android.synthetic.main.cp_activity_horizon_market_detail.tv_low_price
import kotlinx.android.synthetic.main.cp_activity_horizon_market_detail.tv_rose

/**
 *@ description: Detailed interface of horizontal screen market
 * @date 2019-3-16
 * @author Bertking
 *
 */
class CpHorizonMarketDetailActivity : CpNBaseActivity(), CpWsContractAgentManager.WsResultCallback {
    companion object{
        private const val TAG_FLUTTER_FRAGMENT = "flutter_fragment"
    }
    private var flutterFragment: FlutterFragment? = null
    private val secondaryUIList:ArrayList<String> = arrayListOf()
    private val mainUIList:ArrayList<String> = arrayListOf()
    private var volState:Boolean = true
    override fun setContentView(): Int {
        return R.layout.cp_activity_horizon_market_detail
    }

    lateinit var context: Context
    var curTime = ""
    var type = CpParamConstant.BIBI_INDEX
    var isFrist = true

    var klineData: ArrayList<CpKLineBean> = arrayListOf()
    private val adapter by lazy {
        CpKLineChartAdapter().apply {
            setDateFormat(
                if("1day".equals(curTime) || "1week".equals(curTime) || "1month".equals(curTime)){
                    CpDateUtils.FORMAT_KLINE_DATE_YMD
                }else{
                    CpDateUtils.FORMAT_KLINE_DATE_MDHM
                }
            )
        }
    }


    var coinMap = "BTC/USDT"

    var symbol = ""

    var jsonObject: JSONObject? = null

    var tv24hVolUnit = ""
    var mMultiplierCoin = ""
    var mPricePrecision = 0
    var mMultiplierPrecision = 0
    var mMultiplier = "0"
    var coUnit = 0
    var mContractId:Int = -1

    override fun onCreate(savedInstanceState: Bundle?) {
        requestWindowFeature(Window.FEATURE_NO_TITLE)
        window.setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN)
        context = this
        curTime = CpKLineUtil.getCurTime()
//        isLandscape = true
        super.onCreate(savedInstanceState)

    }

    override fun onInit(savedInstanceState: Bundle?) {
        super.onInit(savedInstanceState)
        initView()
    }

    override fun initView() {
        super.initView()

        val fragmentManager: FragmentManager = supportFragmentManager

        // Attempt to find an existing FlutterFragment, in case this is not the
        // first time that onCreate() was run.
        flutterFragment = fragmentManager
            .findFragmentByTag(TAG_FLUTTER_FRAGMENT) as FlutterFragment?

        // Create and attach a FlutterFragment if one does not exist.
        if (flutterFragment == null) {
            val newFlutterFragment = FlutterFragment
                .withCachedEngine(CpFlutterEngineCacheUtil.contract_kline_engine_id)
                .build<FlutterFragment>()
            flutterFragment = newFlutterFragment
            fragmentManager
                .beginTransaction()
                .add(
                    R.id.exFlutter_kline,
                    newFlutterFragment,
                    TAG_FLUTTER_FRAGMENT
                )
                .commit()
        }

        symbol = intent.getStringExtra("symbolHorizon").toString()

//        val themeMode = PublicInfoDataService.getInstance().themeMode
//        val kLineLogo = PublicInfoDataService.getInstance().getKline_background_logo_img(null, themeMode == PublicInfoDataService.THEME_MODE_DAYTIME)
//        GlideUtils.load(this, kLineLogo, iv_logo, RequestOptions())


//        tv_rose_title?.text = CpLanguageUtil.getString(context, "cp_extra_text110")
        tv_rose_title?.text = CpLanguageUtil.getString(this,"cp_extra_text110")
//        tv_high_price_title?.text = CpLanguageUtil.getString(context, "cp_extra_text111")
        tv_high_price_title?.text = CpLanguageUtil.getString(this,"cp_extra_text111")
//        tv_low_price_title?.text = CpLanguageUtil.getString(context, "cp_extra_text112")
        tv_low_price_title?.text = CpLanguageUtil.getString(this,"cp_extra_text112")

        tv_main_title?.text = CpLanguageUtil.getString(context, "cp_extra_text155")
        tv_vice_title?.text = CpLanguageUtil.getString(context, "cp_extra_text156")
        tv_rose_title?.text = CpLanguageUtil.getString(context, "cp_extra_text110")




        initKLineScale()

        action4KLineIndex()

        mContractId = intent.getIntExtra("contractId",-1)

        mPricePrecision = CpClLogicContractSetting.getContractSymbolPricePrecisionById(this, intent.getIntExtra("contractId", -1))

        mMultiplierCoin = CpClLogicContractSetting.getContractMultiplierCoinPrecisionById(this, intent.getIntExtra("contractId", -1))

        mMultiplierPrecision = CpClLogicContractSetting.getContractMultiplierPrecisionById(this,  intent.getIntExtra("contractId", -1))

        coUnit = CpClLogicContractSetting.getContractUint(this)

        mMultiplier = CpClLogicContractSetting.getContractMultiplierById(this, intent.getIntExtra("contractId", -1))

        tv24hVolUnit = if (CpClLogicContractSetting.getContractUint(this) == 0) " " + CpLanguageUtil.getString(this,"cp_overview_text9") else " " + mMultiplierCoin

        tv_coin_map?.text = CpClLogicContractSetting.getContractShowNameById(mActivity,intent.getIntExtra("contractId", -1));
        isFrist = true
        klineData.clear()
        CpWsContractAgentManager.instance.addWsCallback(this)
        tv_converted_close_price.visibility=View.GONE

        iv_close?.setOnClickListener {
            var message =
                CpMessageEvent(CpMessageEvent.market_switch_curTime)
            message.msg_content = curTime
            CpEventBusUtil.post(message)
            finish()
        }
    }

    override fun onResume() {
        super.onResume()
        CpWsContractAgentManager.instance.changeKlineKey(this.javaClass.simpleName)
        sendWsHistory()
    }

    override fun onBackPressed() {
        var message =
            CpMessageEvent(CpMessageEvent.market_switch_curTime)
        message.msg_content = curTime
        CpEventBusUtil.post(message)
        super.onBackPressed()
        flutterFragment!!.onBackPressed()
    }

    /**
     *Rendering 24H market data
     */
    private fun render24H(tick: KlineTick) {
//        val price = jsonObject?.optInt("price") ?: 4
        val price = mPricePrecision

        runOnUiThread {
            if (tick.rose >= 0.0) {
                tv_close_price?.textColor = CpColorUtil.getMainColorType()
            } else {
                tv_close_price?.textColor = CpColorUtil.getMainColorType(isRise = false)
            }

//            tv_coin_map?.text = coinMap
            tv_coin_map?.text = CpClLogicContractSetting.getContractShowNameById(mActivity, intent.getIntExtra("contractId", -1))
            tv_close_price?.text = CpDecimalUtil.cutValueByPrecision(tick.close, price)


            cnPrice.text = RateManager.getContractCNYByContractId(mContractId,tick.close)

            val rose = tick.rose.toString()
            RateManager.getRoseText(tv_rose ?: return@runOnUiThread, rose)
            tv_rose?.textColor = CpColorUtil.getMainColorType(RateManager.getRoseTrend(rose) >= 0)
            tv_high_price?.text = CpDecimalUtil.cutValueByPrecision(tick.high, price)

            tv_low_price?.text = CpDecimalUtil.cutValueByPrecision(tick.low, price)
//            tv_24h_vol?.text = BigDecimalUtils.showDepthVolume(tick.vol)
            val amount = if (coUnit == 0) tick.vol else CpBigDecimalUtils.mulStr(tick.vol, mMultiplier, mMultiplierPrecision)
            tv_24h_vol?.text = CpBigDecimalUtils.showDepthVolume(context,amount,mPricePrecision) + tv24hVolUnit
        }
    }

    private fun setKLineViewIndexStatus(isMain: Boolean = true, position: Int = 0) {

    }

    /**
     *K Line Indicator Processing
     */
    private fun action4KLineIndex() {
        when (CpKLineUtil.getMainIndex()) {
            MainKlineViewStatus.MA.status -> {
                setKLineViewIndexStatus(position = 0)
            }

            MainKlineViewStatus.BOLL.status -> {
                setKLineViewIndexStatus(position = 1)
            }

            MainKlineViewStatus.NONE.status -> {
                setKLineViewIndexStatus(position = 2)
            }
        }

        when (CpKLineUtil.getViceIndex()) {
            CpViceViewStatus.MACD.status -> {
                setKLineViewIndexStatus(isMain = false, position = 0)
            }

            CpViceViewStatus.KDJ.status -> {
                setKLineViewIndexStatus(isMain = false, position = 1)
            }

            CpViceViewStatus.RSI.status -> {
                setKLineViewIndexStatus(isMain = false, position = 2)

            }

            CpViceViewStatus.WR.status -> {
                setKLineViewIndexStatus(isMain = false, position = 3)
            }

            CpViceViewStatus.NONE.status -> {
            }
        }

        addCheckBoxChange(ll_main) { buttonView, isChecked ->
            when (buttonView?.id) {
                R.id.cb_ma,R.id.cb_ema,R.id.cb_boll -> {
                    val textValue = buttonView.text as String
                    if(mainUIList.contains(textValue)){
                        mainUIList.remove(textValue)
                    }else{
                        mainUIList.add(textValue)
                    }
                    val plugin = getPlugin(flutterFragment?:return@addCheckBoxChange)
                    plugin?.setIndexSelectEvent(hashMapOf(
                        "secondaryUIList" to secondaryUIList.joinToString(","),
                        "mainUIList" to mainUIList.joinToString(","),
                        "volState" to if(volState) 1 else 0
                    ))
                }

            }
        }

        addCheckBoxChange(ll_vice) { buttonView, isChecked ->
            when (buttonView?.id) {
                R.id.cb_vol -> {
                    volState = isChecked
                    val plugin = getPlugin(flutterFragment?:return@addCheckBoxChange)
                    plugin?.setIndexSelectEvent(hashMapOf(
                        "secondaryUIList" to secondaryUIList.joinToString(","),
                        "mainUIList" to mainUIList.joinToString(","),
                        "volState" to if(volState) 1 else 0
                    ))
                }
                R.id.cb_macd,R.id.cb_kdj,R.id.cb_rsi,R.id.cb_wr -> {
                    val textValue = buttonView.text as String
                    if(secondaryUIList.contains(textValue)){
                        secondaryUIList.remove(textValue)
                    }else{
                        secondaryUIList.add(textValue)
                    }
                    val plugin = getPlugin(flutterFragment?:return@addCheckBoxChange)
                    plugin?.setIndexSelectEvent(hashMapOf(
                        "secondaryUIList" to secondaryUIList.joinToString(","),
                        "mainUIList" to mainUIList.joinToString(","),
                        "volState" to if(volState) 1 else 0
                    ))

                }
            }


        }

    }

    //Radio click processing Add click deselect logic
    private fun addCheckBoxChange(layoutGroup: LinearLayout,listener: CompoundButton.OnCheckedChangeListener){
        val iterator = layoutGroup.children.iterator()
        while (iterator.hasNext()){
            val next = iterator.next()
            if(next is CheckBox){
                next.setOnCheckedChangeListener(listener)
            }
        }
    }

    /**
     *Process K scale
     */
    private fun initKLineScale() {
        rv_kline_scale?.isLayoutFrozen = true
        rv_kline_scale?.setHasFixedSize(true)
        val klineScale = CpKLineUtil.getKLineScale()
        val layoutManager = GridLayoutManager(context, klineScale.size)
        layoutManager.isAutoMeasureEnabled = false
        rv_kline_scale?.layoutManager = layoutManager
        val adapter = CpHKLineScaleAdapter(klineScale)
        rv_kline_scale?.adapter = adapter
//        adapter.bindToRecyclerView(rv_kline_scale ?: return)
        /**
         *Time-sharing line
         */

        adapter.setOnItemClickListener { viewHolder, view, position ->
            /**
             *Time-sharing line
             */
            if (position != CpKLineUtil.getCurTime4Index()) {
                for (i in 0 until klineScale.size) {
                    val textView = viewHolder.getViewByPosition(i, R.id.tv_scale) as TextView
//                    textView.setCompoundDrawablesRelativeWithIntrinsicBounds(0, 0, 0, 0)
                    textView.setTextColor(ContextCompat.getColor(this,R.color.text_color_2))
                }

                val textView = viewHolder.getViewByPosition(position, R.id.tv_scale) as TextView
//                textView.setCompoundDrawablesRelativeWithIntrinsicBounds(0, 0, 0, R.drawable.cp_kline_item_selected_shape)
                textView.setTextColor(ContextCompat.getColor(this,R.color.text_color_1))
                CpKLineUtil.setCurTime4KLine(position)
                val time = curTime
                curTime = klineScale[position]
                CpKLineUtil.setCurTime(klineScale[position])
                switchKLineScale(time, klineScale[position])
            }
        }
    }

    /**
     *Initialize WebSocket
     */
    private fun sendWsHistory() {
        if (isNotEmpty(symbol)) {
            val scale: String = if (curTime == "line") "1min" else curTime
            CpWsContractAgentManager.instance.sendMessage(hashMapOf("symbol" to symbol, "line" to scale), this)
        }

    }

    /**
     *Processing 24H, KLine data
     */
    fun handleData(data: String) {
        try {
            val jsonObj = JSONObject(data)
            if (!jsonObj.isNull("tick")) {
                /**
                 *24H market
                 */
                if (jsonObj.getString("channel") == CpWsLinkUtils.tickerFor24HLink(symbol = symbol, isChannel = true)) {
                    val quotesData = CpJsonUtils.convert2Quote(jsonObj.toString())
                    render24H(quotesData.tick)
                    return
                }


                /**
                 *Latest K-line data
                 */
                if (jsonObj.getString("channel") == CpWsLinkUtils.getKlineNewLink(symbol, curTime).channel) {
                    runOnUiThread {
                        val plugin = getPlugin(flutterFragment?:return@runOnUiThread)
                        plugin?.setNewKlineData(hashMapOf(
                            "mSymbolPricePrecision" to mPricePrecision,
                            "isLine" to ("line".equals(curTime)),
                            "mKlineData" to data
                        ))
                    }

                    return

                }

                return
            }


            if (!jsonObj.isNull("data")) {
                /**
                 *Request (req) -->K Line Historical Data
                 *That is, historical data of the K line diagram
                 *
                 * channel ---> channel":"market_ltcusdt_kline_1week
                 */
                handlerKLineHistory(data)
            }


        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    /**
     *Processing K Line Historical Data
     *@param data K line historical data
     */
    private fun handlerKLineHistory(data: String) {
        runOnUiThread {
            flutterFragment?.let {
                val plugin = getPlugin(it)
                plugin?.setHistoryKlineData(hashMapOf(
                    "mSymbolPricePrecision" to mPricePrecision,
                    "isLine" to ("line".equals(curTime)),
                    "mKlineData" to data,
                    "isMore" to false
                ))
            }
            initKlineData()
        }
    }

    private fun getPlugin(it:FlutterFragment):CpExFlutterPlugin?{
        var plugin = it.flutterEngine?.plugins?.get(CpExFlutterPlugin::class.java) ?: return null
        plugin = plugin as CpExFlutterPlugin
        return plugin
    }

    private fun initKlineData() {
        if(isFrist){
            val scale = if (curTime == "line") "1min" else curTime
            CpWsContractAgentManager.instance.sendData(CpWsLinkUtils.getKlineNewLink(symbol, scale))
            isFrist = false
        }
    }

    /**
     *Toggle K scale
     *@param kLineScale K line scale
     */
    private fun switchKLineScale(curTime: String, kLineScale: String) {
        if (curTime != kLineScale) {
            isFrist = true
            sendWsHistory()
        }
    }


    override fun onPause() {
        super.onPause()
        CpWsContractAgentManager.instance.unbind(this, true)
    }

    override fun onDestroy() {
        super.onDestroy()
        CpWsContractAgentManager.instance.removeWsCallback(this,true)
    }

    /**
     *Ws Send Message
     */
    private fun sendMsg(msg: String) {

    }


    override fun onCpWsMessage(json: String) {
        handleData(json)
    }


    override fun onPostResume() {
        super.onPostResume()
        flutterFragment!!.onPostResume()
    }

    override fun onNewIntent(@NonNull intent: Intent) {
        super.onNewIntent(intent)
        flutterFragment!!.onNewIntent(intent)
    }


    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String?>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        flutterFragment!!.onRequestPermissionsResult(
            requestCode,
            permissions,
            grantResults
        )
    }

    override fun onActivityResult(
        requestCode: Int,
        resultCode: Int,
        data: Intent?
    ) {
        super.onActivityResult(requestCode, resultCode, data)
        flutterFragment!!.onActivityResult(
            requestCode,
            resultCode,
            data
        )
    }

    override fun onUserLeaveHint() {
        flutterFragment!!.onUserLeaveHint()
    }

    override fun onTrimMemory(level: Int) {
        super.onTrimMemory(level)
        flutterFragment!!.onTrimMemory(level)
    }

}
