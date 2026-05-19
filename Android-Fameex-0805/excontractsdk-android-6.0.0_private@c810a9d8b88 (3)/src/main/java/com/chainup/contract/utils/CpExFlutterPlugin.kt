package com.chainup.contract.utils

import com.chainup.contract.app.CpMyApp
import com.chainup.contract.eventbus.CpEventBusUtil
import com.chainup.contract.eventbus.CpMessageEvent
import com.chainup.kit.utils.ToastUtils
import com.google.gson.Gson
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.TreeMap

class CpExFlutterPlugin: FlutterPlugin , ActivityAware {
    companion object{
        //main chart change cache
        var mainIndexCacheMap:LinkedHashMap<String,Any> = linkedMapOf()
    }
    private var channel: MethodChannel? = null
    private var channelNV: MethodChannel? = null
    lateinit var engineRenderer:Any
    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        setupMethodChannel(binding.binaryMessenger)
        engineRenderer = binding.flutterEngine.renderer
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        tearDownChannel()
    }

    private fun setupMethodChannel(messenger: BinaryMessenger) {
        channel = MethodChannel(messenger, "ex.chainup.app")
        channelNV = MethodChannel(messenger, "ex.chainup.app/NV")
        channel!!.setMethodCallHandler { methodCall: MethodCall, result: MethodChannel.Result ->
            println("methodCall.method：${methodCall.method}")
            when(methodCall.method){
                "close_kline_vpage" -> {
                    CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.close_kline_vpage))
                }
                "kline_coin_sidebar" -> {
                    CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.kline_coin_sidebar))
                }
                "kline_coin_share" -> {
                    CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.kline_coin_share))
                }
                "kline_coin_collect" -> {
                    CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.kline_coin_collect))
                }
                "kline_trading_buy" -> {
                    CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.kline_trading_buy))
                }
                "kline_trading_sell" -> {
                    CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.kline_trading_sell))
                }
                "kline_switch_time_index" ->{
                    val params = methodCall.arguments as Map<String,String>
                    val kTime = params.get("mklineScale") as String
                    val message = CpMessageEvent(CpMessageEvent.market_switch_curTime,kTime)
                    CpEventBusUtil.post(message)
                }
                "more_history_kline" -> {
                    CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.more_history_kline,methodCall.arguments))
                }
                "reload_kline" -> {
                    CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.reload_kline))
                }
                "kline_order_switch_visible" -> {
                    CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.kline_order_switch_visible,methodCall.arguments))
                }
                "kline_scroll" -> {
                    val isScroll= methodCall.argument<Boolean>("isScroll")
                    CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.kline_scroll,isScroll))
                }
                "kline_detail_clickMainIndex" -> {
                    if(methodCall.arguments is Map<*,*>) {
                        val map = methodCall.arguments as HashMap<String,Any>
                        mainIndexCacheMap.putAll(map)
                    }
                }
                "kline_guide_flag" -> {
                    val flutterGuideKey = "kline_v_guide1"
                    mainIndexCacheMap[flutterGuideKey] = "1"
                    if(methodCall.arguments is Map<*,*>) {
                        val map = methodCall.arguments as HashMap<String,String>
                        val flag = map["flagStr"]
                        flag?.run {
                            CpPreferenceManager.getInstance(CpMyApp.instance().applicationContext).putSharedString(CpPreferenceManager.CONTRACT_KLINE_GUIDE_FLAG1,this)
                        }
                    }

                }

                "show_native_toast" -> {
                    val map = methodCall.arguments as HashMap<String,String>
                    val message = map["message"] as String
                    ToastUtils.showToast(CpMyApp.instance().applicationContext,message)
                }
                "kline_etf_coin_intro" -> {
                    CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.kline_etf_position_record))
                }
                "kline_etf_position_record" -> {
                    CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.kline_etf_position_record))
                }
                "kline_coin_intro" -> {
                    CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.kline_coin_intro))
                }
                "kline_transaction_record" -> {
                    CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.kline_transaction_record))
                }
                "kline_coin_info" -> {
                    CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.kline_coin_info))
                }
                else ->{
                    result.notImplemented()
                }
            }
        }
    }


    fun setNewKlineData(msg: HashMap<String,Any>) {
        channelNV?.invokeMethod("setNewKlineData", Gson().toJson(msg))
    }

    fun set24HTickerData(msg: HashMap<String,String>){
        channelNV?.invokeMethod("set24HTickerData", Gson().toJson(msg))
    }

    fun setCoinInfo(msg:HashMap<String,Any>){
        channelNV?.invokeMethod("setCoinInfo", Gson().toJson(msg))
    }

    fun updatePriceInfo(msg:HashMap<String,Any>){
        channelNV?.invokeMethod("updatePriceInfo", Gson().toJson(msg))
    }

    fun setDepthMapData(msg:HashMap<String,Any>){
        channelNV?.invokeMethod("setDepthMapData", Gson().toJson(msg))
    }

    fun setTransactionRecordData(msg:HashMap<String,Any>){
        channelNV?.invokeMethod("setTransactionRecordData", Gson().toJson(msg))
    }

    fun setOrderBookData(msg:HashMap<String,Any>){
        channelNV?.invokeMethod("setOrderBookData", Gson().toJson(msg))
    }

    fun setHistoryKlineData(msg: HashMap<String,Any>) {
        channelNV?.invokeMethod("setHistoryKlineData",Gson().toJson(msg))
    }

    fun setKlineMainState(msg: Int) {
        channelNV?.invokeMethod("setKlineMainState",Gson().toJson(hashMapOf("MainStateIndex" to msg)))
    }

    fun setKlineSecondaryState(msg: Int) {
        channelNV?.invokeMethod("setKlineSecondaryState",Gson().toJson(hashMapOf("SubStateIndex" to msg)))
    }

    fun setKlineVolState(msg: Int) {
        channelNV?.invokeMethod("setKlineVolState",Gson().toJson(hashMapOf("VolStateIndex" to msg)))
    }

    fun setKlineBuySellData(msg: List<HashMap<String,Any>>) {
        channelNV?.invokeMethod("setKlineBuySellData",Gson().toJson(hashMapOf("KlineBuySellData" to msg)))
    }

    fun setKlineOrderShow(msg: Boolean) {
        channelNV?.invokeMethod("setKlineOrderShow",Gson().toJson(hashMapOf("isShowKlineOrder" to msg)))
    }

    fun setKlineState(msg: Int) {
        channelNV?.invokeMethod("setKlineState",Gson().toJson(hashMapOf("KlineStateIndex" to msg)))
    }

    fun setIndexSelectEvent(msg: HashMap<String,Any>) {
        channelNV?.invokeMethod("setIndexSelectEvent",Gson().toJson(msg))
    }


    fun updateMainIndexVisible() {
        channelNV?.invokeMethod("updateMainIndexVisible",Gson().toJson(mainIndexCacheMap))
    }

    fun updateWaterLogoPath(path:String){
        channelNV?.invokeMethod("updateWaterLogoPath",Gson().toJson(hashMapOf("waterLogoPath" to path)))
    }

    fun nativeClickKTimeChange(scale:String){
        channelNV?.invokeMethod("nativeClickKTimeChange",Gson().toJson(hashMapOf("scale" to scale)))
    }

    fun setCoinIntroData(data:String){
        channelNV?.invokeMethod("setCoinIntroData",Gson().toJson(hashMapOf("mCoinIntroData" to data)))
    }

    fun setCoinETFRuleData(data:String){
        channelNV?.invokeMethod("setCoinETFRuleData",Gson().toJson(hashMapOf("mEtfPositionRecord" to data)))
    }

    fun setCoinETFData(data:String){
        channelNV?.invokeMethod("setCoinETFData",Gson().toJson(hashMapOf("mCoinETFData" to data)))
    }



    private fun tearDownChannel() {
        channel!!.setMethodCallHandler(null)
        channel = null
        channelNV = null
    }



    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
//        this.mActivity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
//        this.mActivity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
//        this.mActivity = binding.activity
    }

    override fun onDetachedFromActivity() {
//        this.mActivity = null
    }

}