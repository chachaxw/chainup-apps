package com.yjkj.chainup.new_contract.activity

import android.content.Intent
import android.content.res.Configuration
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.text.TextUtils
import android.util.Log
import android.view.View
import androidx.annotation.NonNull
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentManager
import com.chainup.contract.R
import com.chainup.contract.adapter.CpKLineScaleAdapter
import com.chainup.contract.app.CpCommonConstant
import com.chainup.contract.app.CpMyApp
import com.chainup.contract.app.CpParamConstant
import com.chainup.contract.base.CpNBaseActivity
import com.chainup.contract.eventbus.CpEventBusUtil
import com.chainup.contract.eventbus.CpMessageEvent
import com.chainup.contract.eventbus.CpNLiveDataUtil
import com.chainup.contract.ui.fragment.CpContractCoinSearchDialog
import com.chainup.contract.utils.ChainUpLogUtil
import com.chainup.contract.utils.CpBigDecimalUtils
import com.chainup.contract.utils.CpChainUtil
import com.chainup.contract.utils.CpClLogicContractSetting
import com.chainup.contract.utils.CpDateUtils
import com.chainup.contract.utils.CpFlutterEngineCacheUtil
import com.chainup.contract.utils.CpFlutterEngineCacheUtil.getPlugin
import com.chainup.contract.utils.CpZXingUtils
import com.chainup.contract.utils.RateManager
import com.chainup.contract.utils.CpWsLinkUtils
import com.chainup.contract.utils.getAppSharePermission
import com.chainup.contract.view.CpDialogUtil
import com.chainup.contract.view.dialog.CpTDialog
import com.chainup.contract.ws.CpWsContractAgentManager
import com.chainup.kit.utils.ToastUtils
import com.google.gson.Gson
import com.jaeger.library.StatusBarUtil
import com.tbruyelle.rxpermissions2.RxPermissions
import com.yjkj.chainup.manager.CpLanguageUtil
import com.yjkj.chainup.net_new.rxjava.CpNDisposableObserver
import com.yjkj.chainup.new_contract.bean.CpCurrentOrderBean
import com.yjkj.chainup.new_version.kline.bean.CpKLineBean
import com.yjkj.chainup.new_version.kline.data.CpKLineChartAdapter
import io.flutter.embedding.android.FlutterFragment
import io.flutter.embedding.engine.renderer.FlutterUiDisplayListener
import io.reactivex.Observable
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import kotlinx.android.synthetic.main.cp_flutter_activity_market_detail4.fl_flutter_page
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import org.json.JSONArray
import org.json.JSONObject
import java.text.DecimalFormat
import java.util.concurrent.TimeUnit

/**
 *@ description: Detailed interface of currency pair market
 * @date 2019-3-2
 * @author Bertking
 *
 */
class CpMarketDetail4Activity : CpNBaseActivity(), CpWsContractAgentManager.WsResultCallback,
    FlutterUiDisplayListener {
    override fun setContentView(): Int = R.layout.cp_flutter_activity_market_detail4
    private var mShareDialog: CpTDialog? = null
    private var flutterFragment:FlutterFragment? = null
    var subscribe: Disposable? = null//Save Subscriber
    var isMore = false
    var baseSymbol = ""
    var quoteSymbol = ""
    var symbol = ""
    var contractId = -1
    var tv24hVolUnit = ""
    var mMultiplierCoin = ""
    var mPricePrecision = 0
    var mMultiplierPrecision = 0
    var mMultiplier = "0"
    var coUnit = 0

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

    companion object {

        private const val TAG_FLUTTER_FRAGMENT = "flutter_fragment"

    }

    override fun onInit(savedInstanceState: Bundle?) {
        super.onInit(savedInstanceState)
        layoutView?.fitsSystemWindows = false
        updateStatusBarColor()
        StatusBarUtil.setColor(this,ContextCompat.getColor(this,R.color.bg_card_color),0)
        CpWsContractAgentManager.instance.addWsCallback(this)
        initView()

        CpNLiveDataUtil.observeData(this) {
            if (it.msg_type == CpMessageEvent.sl_contract_ws_reLink_finish) {
                initSocket()
                getPlugin(this).updateMainIndexVisible()
                updateWaterLogoPath()
                switchKLineScale(if ("".equals(curTime)) "15min" else curTime)
            }
        }
    }

    private fun initFlutterFm(){
        val fragmentManager: FragmentManager = supportFragmentManager
        flutterFragment = fragmentManager
            .findFragmentByTag(TAG_FLUTTER_FRAGMENT) as? FlutterFragment
        if (flutterFragment == null) {
            val newFlutterFragment = FlutterFragment
                .withCachedEngine(CpFlutterEngineCacheUtil.getEngineId(this,CpFlutterEngineCacheUtil.contract_kline_page_engine_id))
                .build<FlutterFragment>()
            flutterFragment = newFlutterFragment
            fragmentManager.beginTransaction()
                .add(R.id.fl_flutter_page, newFlutterFragment, TAG_FLUTTER_FRAGMENT)
                .commit()
        }


    }



    override fun onResume() {
        super.onResume()
        Handler(Looper.getMainLooper()).postDelayed({
            updateStatusBarColor()
        },500L)
        CpWsContractAgentManager.instance.changeKlineKey(this.javaClass.simpleName)
        getMarkertInfo()
        CpFlutterEngineCacheUtil.getEngine(this).lifecycleChannel.appIsResumed()
    }

    private fun updateStatusBarColor(){
        if(CpClLogicContractSetting.getThemeMode(this)==CpClLogicContractSetting.THEME_MODE_DAYTIME){
            StatusBarUtil.setLightMode(this)
        }else{
            StatusBarUtil.setDarkMode(this)
        }
    }

    override fun onPause() {
        super.onPause()
        CpWsContractAgentManager.instance.unbind(this, true)
        val scale = if (curTime == "line") "1min" else curTime
        CpWsContractAgentManager.instance.sendData(CpWsLinkUtils.getKlineNewLink(symbol, scale,false))
        loopStop()
        CpFlutterEngineCacheUtil.getEngine(this).lifecycleChannel.appIsInactive()
    }

    override fun onStop() {
        super.onStop()
        CpFlutterEngineCacheUtil.getEngine(this).lifecycleChannel.appIsPaused()
    }

    private fun addOrDelCollect(contractId:Int) {
        if (!CpClLogicContractSetting.isLogin()) {
            return
        }
        var mContractIds= StringBuffer()
        var mCollectListStr =
            CpClLogicContractSetting.getContractJsonCollectListStr(this)
        if (!TextUtils.isEmpty(mCollectListStr)){
            val jsonArray = JSONArray(mCollectListStr)
            for (i in 0 until jsonArray.length()) {
                val mJSONObject = jsonArray[i] as JSONObject
                mContractIds.append(mJSONObject.optInt("id"))
                mContractIds.append(",")
            }
        }else{
            mContractIds.append(contractId)
            mContractIds.append(",")
        }
        addDisposable(
            getContractModel().setOptionalList(
                if (TextUtils.isEmpty(mContractIds)) "" else  mContractIds.substring(0,mContractIds.length-1),
                consumer = object : CpNDisposableObserver(true) {
                    override fun onResponseSuccess(jsonObject: JSONObject?) {

                    }
                }
            )
        )
    }


    private var curTime: String? = ""

    override fun initView() {
        initFlutterFm()
        symbol = intent.getStringExtra(CpParamConstant.symbol).toString()
        contractId = intent.getIntExtra("contractId", -1)
        baseSymbol = intent.getStringExtra("baseSymbol").toString()
        quoteSymbol = intent.getStringExtra("quoteSymbol").toString()

        mPricePrecision =
            CpClLogicContractSetting.getContractSymbolPricePrecisionById(this, contractId)

        mMultiplierCoin =
            CpClLogicContractSetting.getContractMultiplierCoinPrecisionById(this, contractId)

        mMultiplierPrecision =
            CpClLogicContractSetting.getContractMultiplierPrecisionById(this, contractId)

        coUnit = CpClLogicContractSetting.getContractUint(CpMyApp.instance())

        mMultiplier = CpClLogicContractSetting.getContractMultiplierById(this, contractId)

        tv24hVolUnit =
            if (CpClLogicContractSetting.getContractUint(this) == 0) "" + CpLanguageUtil.getString(
                this,
                "cp_overview_text9"
            ) else "" + mMultiplierCoin
    }

    fun updateCoinInfo(){
        runOnUiThread {
            val contractShowName = CpClLogicContractSetting.getContractShowNameById(mActivity, contractId)
            val isCollect = CpClLogicContractSetting.hasCollect(this,contractId)
            val mCurrencyPrecision = RateManager.instance.getRateRateBridgeImpl()?.getCurrencyPrecision() ?: 2
            val mCurrencyRates = RateManager.instance.getRateRateBridgeImpl()?.getRate(contractId) ?: "6.5"
            val mCurrencyLogo = RateManager.instance.getRateRateBridgeImpl()?.getCurrencySign() ?: "¥"
            val plugin = getPlugin(this)
            plugin?.setCoinInfo(hashMapOf(
                "coinName" to contractShowName,
                "mSymbolPricePrecision" to mPricePrecision,
                "isCollect" to isCollect,
                "mklineScale" to (curTime?:"15min"),
                "mCurrencyPrecision" to mCurrencyPrecision,
                "mCurrencyRates" to mCurrencyRates,
                "mCurrencyUnit" to mCurrencyLogo,
                "leverMultiple" to "",
                "marketTag" to "",
                "etfRisk" to "",
                "mPriceUnit" to "USDT",
                "mAmountUnit" to tv24hVolUnit,
                "FundRate" to "--",
                "etfOpen" to false,
                "symbol_profile" to false,
                "isContractKline" to true,
                "isCoin" to (coUnit==1),
                "mMultiplier" to mMultiplier,
                "marginCoinPrecision" to CpClLogicContractSetting.getContractMarginCoinPrecisionById(this,contractId),
            ))
        }
    }

    override fun onMessageEvent(event: CpMessageEvent) {
        super.onMessageEvent(event)
        when(event.msg_type){
            CpMessageEvent.market_switch_curTime,CpMessageEvent.reload_kline -> {
                switchKLineScale(event.msg_content as? String)
                updateCoinInfo()
            }
            CpMessageEvent.close_kline_vpage -> {
                finish()
            }
            CpMessageEvent.kline_trading_sell,CpMessageEvent.kline_trading_buy -> {
                val messageEvent = CpMessageEvent(CpMessageEvent.contract_switch_type)
                CpEventBusUtil.post(messageEvent)
                CpClLogicContractSetting.setContractCurrentSelectedId(this@CpMarketDetail4Activity, contractId)
                finish()
            }
            CpMessageEvent.kline_coin_sidebar -> {
                /**
                 *Switch currency pairs
                 */
                if (CpChainUtil.isFastClick()) return

                var mContractCoinSearchDialog = CpContractCoinSearchDialog()
                var bundle = Bundle()
                bundle.putString(CpContractCoinSearchDialog.contractList, CpClLogicContractSetting.getContractJsonListStr(mActivity))
                bundle.putString(CpContractCoinSearchDialog.focusViewName, this@CpMarketDetail4Activity::class.java.simpleName)
                mContractCoinSearchDialog.arguments = bundle
                mContractCoinSearchDialog.showDialog(supportFragmentManager, symbol)
            }
            CpMessageEvent.kline_coin_share -> {
                //Share
                val rxPermissions = RxPermissions(this@CpMarketDetail4Activity)
                val observable = rxPermissions.request("share".getAppSharePermission())
                observable.subscribe { granted ->
                    if (granted) {
                        val qrCodeStr = CpClLogicContractSetting.getInviteUrl()
                        mShareDialog = CpDialogUtil.showKLineShareDialog(flutterEngineRenderer = getPlugin(this)?.engineRenderer,context = mActivity, mView = fl_flutter_page as View, qrCodeString = qrCodeStr)
                    } else {
                        ToastUtils.showToast(this@CpMarketDetail4Activity,CpLanguageUtil.getString(this@CpMarketDetail4Activity,"cp_extra_text128"))
                    }
                }
            }
            CpMessageEvent.kline_coin_collect -> {
                val that = this@CpMarketDetail4Activity
                /**
                 *Add custom currency
                 */
                val collectContractCoin = CpClLogicContractSetting.collectContractCoin(that, contractId)
                val isCollect = collectContractCoin==1

                if (isCollect){
                    ToastUtils.showToast(that,CpLanguageUtil.getString(that, "kline_tip_addCollectionSuccess"))
                }else{
                    ToastUtils.showToast(that,CpLanguageUtil.getString(that, "kline_tip_removeCollectionSuccess"))
                }

                addOrDelCollect(contractId)
            }
            CpMessageEvent.sl_contract_left_coin_type -> {
                if(event.msg_content_data is String) {
                    val vName = event.msg_content_data as String
                    if(this::class.java.simpleName.equals(vName)){
                        contractId = event.msg_content as Int
                        val ticker =CpClLogicContractSetting.getContractJsonStrById(this, contractId)
                        baseSymbol = ticker.getString("base")
                        quoteSymbol = ticker.getString("quote")
                        symbol =ticker.getString("subSymbol")
                        mPricePrecision =
                            CpClLogicContractSetting.getContractSymbolPricePrecisionById(this, contractId)

                        mMultiplierCoin =
                            CpClLogicContractSetting.getContractMultiplierCoinPrecisionById(this, contractId)

                        mMultiplierPrecision =
                            CpClLogicContractSetting.getContractMultiplierPrecisionById(this, contractId)

                        coUnit = CpClLogicContractSetting.getContractUint(CpMyApp.instance())

                        mMultiplier = CpClLogicContractSetting.getContractMultiplierById(this, contractId)

                        tv24hVolUnit =
                            if (CpClLogicContractSetting.getContractUint(this) == 0) "" + CpLanguageUtil.getString(
                                this,
                                "cp_overview_text9"
                            ) else "" + mMultiplierCoin

                        initSocket()
                        updateCoinInfo()
                        getMarkertInfo()
                        switchKLineScale(curTime)

                    }

                }
            }
            CpMessageEvent.more_history_kline -> {
                val params = event.msg_content as Map<String,Int>
                val endIdx = params["endIdx"]
                reqKlineLoadMore(endIdx)
            }
            else -> {

            }
        }
    }
    private fun reqKlineLoadMore(endIdx:Int?){
        endIdx?.let {
            isMore = true
            val otherLink = CpWsLinkUtils.getKlineHistoryOther(symbol,if (curTime == "line") "1min" else curTime ?: "15min",it.toString())
            CpWsContractAgentManager.instance.sendData(otherLink)
        }
    }

    //Triggered during initial and switching currency pairs
    private fun initSocket() {
        if (isNotEmpty(symbol)) {
            // sub ticker
            val scale: String = if (curTime == "line") "1min" else curTime ?: "15min"
            CpWsContractAgentManager.instance.sendMessage(
                hashMapOf(
                    "symbol" to symbol,
                    "line" to scale
                ), this
            )
        }
    }

    var selectPosition = 0

    var calibrationAdapter: CpKLineScaleAdapter? = null

    private var isRealNew = false

    /**
     *Processing 24H, KLine data
     */
    fun handleData(data: String) {
        try {

            var jsonObj = JSONObject(data)
            if (!jsonObj.isNull("tick")) {
                /**
                 *24H market
                 */
                if (jsonObj.getString("channel") == CpWsLinkUtils.tickerFor24HLink(symbol, isChannel = true)) {
                    render24H(data)
                    return
                }

                /**
                 *Latest K-line data
                 */
                var scale = if (curTime == "line") "1min" else curTime
                ChainUpLogUtil.e(
                    TAG,
                    "本地channel：" + CpWsLinkUtils.getKlineNewLink(symbol, scale).channel
                )
                ChainUpLogUtil.e(TAG, "远端channel：" + jsonObj.getString("channel"))
                if (jsonObj.getString("channel") == CpWsLinkUtils.getKlineNewLink(
                        symbol,
                        scale
                    ).channel
                ) {
                    Log.w(
                        TAG,
                        "=======最新K线： ${klineData.size} ||  ${klineData.lastIndex}==  adapter ${adapter.getCount()}======"
                    )

                    handlerNewKLine(data)

                }

                if (jsonObj.getString("channel") == CpWsLinkUtils.getDepthLink(symbol).channel) {
//                    if (mClDepthFragment != null) {
//                        mClDepthFragment?.onClDepthFragment(data)
//                    }
                    handlerBookDepth(data)
                }

                realtData(jsonObj,data)
                return
            } else {
                var scale = if (curTime == "line") "1min" else curTime
                if (!jsonObj.isNull("data") && jsonObj.getString("channel") == CpWsLinkUtils.getKLineHistoryLink(
                        symbol,
                        scale
                    ).channel
                ) {
                    handlerKLineHistory(data)
                    return
                }
                realtData(jsonObj,data)
            }

        } catch (e: Exception) {
            e.printStackTrace()
            ChainUpLogUtil.e(TAG, e.message)
        }
    }

    /**
     *Rendering 24H market data
     */
    private fun render24H(tickStr: String) {
        runOnUiThread {
            val plugin = getPlugin(this)
            plugin?.set24HTickerData(hashMapOf(
                "mTickerData" to tickStr
            ))
        }
    }



    private fun handlerNewKLine(data:String){
        runOnUiThread {
            val plugin = getPlugin(this)
            plugin?.setNewKlineData(hashMapOf(
                "mSymbolPricePrecision" to mPricePrecision,
                "isLine" to ("line".equals(curTime)),
                "mKlineData" to data
            ))
        }

    }


    private fun handlerDealRecordData(data:String,isHistory:Boolean = false){
        runOnUiThread {
            val plugin = getPlugin(this)
            plugin?.setTransactionRecordData(hashMapOf(
                "mRecordData" to data,
                "isHistory" to isHistory
            ))
        }
    }
    private fun handlerDepth(data:String){
        runOnUiThread {
            val plugin = getPlugin(this)
            plugin?.setDepthMapData(hashMapOf(
                "mDepthMapData" to data
            ))
        }
    }

    private fun handlerBookDepth(data:String){
        runOnUiThread {
            val plugin = getPlugin(this)
            plugin?.setOrderBookData(hashMapOf(
                "mOrderBookData" to data
            ))
        }
    }
    /**
     *Processing K Line Historical Data
     *@param data K line historical data
     */
    private fun handlerKLineHistory(data: String) {
        val jsonObj = JSONObject(data)
        if(jsonObj.isNull("data")) return
        runOnUiThread {
            val plugin = getPlugin(this)
            plugin?.setHistoryKlineData(hashMapOf(
                "mSymbolPricePrecision" to mPricePrecision,
                "isLine" to ("line".equals(curTime)),
                "mKlineData" to data,
                "isMore" to isMore
            ))
            initKlineData()
            updateWaterLogoPath()
            getHistoryCommonOrderList()
        }
    }

    private fun initKlineData() {
        if(!isMore){
            val scale = if (curTime == "line") "1min" else curTime
            CpWsContractAgentManager.instance.sendData(CpWsLinkUtils.getKlineNewLink(symbol, scale))
        }

    }

    override fun onDestroy() {
        super.onDestroy()
        CpWsContractAgentManager.instance.removeWsCallback(this,true)
        loopStop()
        CpFlutterEngineCacheUtil.getEngine(this).lifecycleChannel.appIsDetached()
        CpFlutterEngineCacheUtil.removeEngine(CpFlutterEngineCacheUtil.contract_kline_page_engine_id)
    }

    override fun onCpWsMessage(json: String) {
        handleData(json)
    }

    private fun realtData(jsonObj: JSONObject, data: String) {
        val historyList = jsonObj.getString("channel") == CpWsLinkUtils.getDealHistoryLink(symbol).channel && !jsonObj.isNull("data")
        val depthReal = historyList ||
                jsonObj.getString("channel") == CpWsLinkUtils.getDealNewLink(symbol).channel
        if (depthReal) {
            if (historyList) isRealNew = false
            if (!isRealNew) {
                CoroutineScope(Dispatchers.Main).launch {
                    delay(200)
                    handlerDealRecordData(data,true)
                    CpWsContractAgentManager.instance.sendData(CpWsLinkUtils.getDealNewLink(symbol).json)
                    isRealNew = true
                }
            } else {
                handlerDealRecordData(data)
            }
        }
    }

    private fun getMarkertInfo() {
        if (contractId == -1) {
            return
        }
        loopStop()
        subscribe = Observable.interval(0L, CpCommonConstant.capitalRateLoopTime, TimeUnit.SECONDS)
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe {
                addDisposable(
                    getContractModel().getMarkertInfo(symbol, contractId.toString(),
                        consumer = object : CpNDisposableObserver() {
                            override fun onResponseSuccess(jsonObject: JSONObject?) {
                                jsonObject?.optJSONObject("data")?.run {
                                    val tagPrice = optString("tagPrice")
                                    val fundRate = optDouble("currentFundRate")
                                    val indexPrice = optString("indexPrice")
                                    ChainUpLogUtil.e("标记价格", tagPrice)
                                    ChainUpLogUtil.e("资金费率", fundRate)
                                    ChainUpLogUtil.e("指数价格", indexPrice)
                                    getPlugin(this@CpMarketDetail4Activity)?.updatePriceInfo(hashMapOf(
                                        "markPrice" to CpBigDecimalUtils.scaleStr(tagPrice,mPricePrecision),
                                        "fundRate" to DecimalFormat("0.00000%").format(fundRate)
                                    ))
                                }
                            }
                        })
                )

                addDisposable(
                    getContractModel().getCoinDepth(contractId, symbol,
                        consumer = object : CpNDisposableObserver(true) {
                            override fun onResponseSuccess(jsonObject: JSONObject?) {
                                jsonObject?.optJSONObject("data")?.run {
                                    handlerDepth(this.toString())
                                }
                            }

                            override fun onError(e: Throwable) {
                                super.onError(e)
                            }
                        })
                )
            }
    }

    private fun loopStop() {
        if (subscribe != null) {
            subscribe?.dispose()
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        flutterFragment!!.onActivityResult(
            requestCode,
            resultCode,
            data
        )
        if(CpZXingUtils.SHARE_CODE==requestCode){

            Log.d(TAG,"系统分享的结果")
            //Only cancel operations are performed here
            if(mShareDialog!=null) mShareDialog?.dismiss()

        }
    }


    private fun getHistoryCommonOrderList() {
        if (!CpClLogicContractSetting.isLogin()) {
            return
        }
        if (!CpClLogicContractSetting.isOpenContract()) {
            return
        }
        addDisposable(
            getContractModel().getHistoryOrderList(contractId.toString(),
                0,
                1,
                200,
                isKline = 1,
//                isV6 = 1,
                consumer = object : CpNDisposableObserver(true) {
                    override fun onResponseSuccess(jsonObject: JSONObject?) {
                        val dataList:ArrayList<HashMap<String,Any>> = arrayListOf()
                        jsonObject?.optJSONObject("data")?.run {
                            if (!isNull("orderList")) {
                                val mOrderListJson = optJSONArray("orderList")
                                if (mOrderListJson != null) {
                                    for (i in 0..(mOrderListJson.length() - 1)) {
                                        val obj = mOrderListJson.getString(i)
                                        val mClCurrentOrderBean = Gson().fromJson<CpCurrentOrderBean>(
                                            obj,
                                            CpCurrentOrderBean::class.java
                                        )
                                        val timesMillisAgo = CpDateUtils.getAgoTimeByAmountDays(-30)
                                        if(mClCurrentOrderBean.ctime.toLong() >= timesMillisAgo){
                                            val itemMap = hashMapOf<String,Any>().apply {
                                                put("price",mClCurrentOrderBean.price)
                                                put("ctime",mClCurrentOrderBean.ctime.toLong())
                                                put("vol",mClCurrentOrderBean.volume)
                                                put("isBuy",mClCurrentOrderBean.side=="BUY")
                                            }
                                            dataList.add(itemMap)
                                        }

                                    }
                                }

                                runOnUiThread {
                                    val plugin = getPlugin(this@CpMarketDetail4Activity)
                                    plugin?.setKlineBuySellData(dataList)
                                }

                            }
                        }
                    }

                    override fun onError(e: Throwable) {
                        super.onError(e)
                        closeLoadingDialog()
                    }
                })
        )
    }

    override fun onBackPressed() {
//        super.onBackPressed()
        flutterFragment!!.onBackPressed()
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


    override fun onUserLeaveHint() {
        flutterFragment!!.onUserLeaveHint()
    }

    override fun onTrimMemory(level: Int) {
        super.onTrimMemory(level)
        flutterFragment!!.onTrimMemory(level)
    }

    fun switchKLineScale(kLineScale: String?) {
        isMore = false
        val oldTime = curTime?.replace("line","1min")
        CpWsContractAgentManager.instance.sendData(CpWsLinkUtils.getKlineNewLink(symbol,oldTime,false))
        if(kLineScale!=null){
            curTime = kLineScale
        }
        val scale: String = if (curTime == "line") "1min" else curTime ?: "15min"
        CpWsContractAgentManager.instance.sendData(CpWsLinkUtils.getKLineHistoryLink(symbol, scale))
    }

    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        if(newConfig.orientation == Configuration.ORIENTATION_LANDSCAPE){
            updateCoinInfo()
            updateWaterLogoPath()
        }
    }

    private fun updateWaterLogoPath(){
        runOnUiThread {
            val plugin = getPlugin(this)
            val waterPath = CpClLogicContractSetting.getInstance().userDataBridgeImpl?.klineWaterPath
            plugin?.updateWaterLogoPath(waterPath?:"")
        }
    }

    override fun onFlutterUiDisplayed() {
        Handler(Looper.getMainLooper()).postDelayed({
            initSocket()
            getPlugin(this).updateMainIndexVisible()

        },500L)

    }

    override fun onFlutterUiNoLongerDisplayed() {

    }

}
