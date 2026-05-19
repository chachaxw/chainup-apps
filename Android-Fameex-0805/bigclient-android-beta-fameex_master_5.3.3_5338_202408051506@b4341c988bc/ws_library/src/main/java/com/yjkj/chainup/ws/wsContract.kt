package com.yjkj.chainup.ws

import android.util.Log
import com.chainup.ws.BuildConfig
import com.google.gson.reflect.TypeToken
import com.yjkj.chainup.bean.kline.WsLinkBean
import com.yjkj.chainup.util.*
import io.reactivex.Observable
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import io.reactivex.schedulers.Schedulers
import okhttp3.*
import okio.ByteString
import org.json.JSONException
import org.json.JSONObject
import java.util.*
import java.util.concurrent.TimeUnit

class WsContractAgentManager private constructor() {
    var mOkHttpClient: OkHttpClient? = null
    var mWebSocket: WebSocket? = null
    var serverUrl: String = ""
    private val TAG = this.javaClass.simpleName
    private var mCount = 0
    private var reCount = 9
    private var isAppStopWs = true
    var isBackgroud = false
    private val callbacks = arrayListOf<WsResultCallback>()
    var subscribePong: Disposable? = null//Save subscribers
    private val mapSubCallbacks = hashMapOf<String, HashMap<String, WsLinkBean>>()
    private val mapAnySubCallbacks = hashMapOf<String, HashMap<String, Any>>()

    private val subCallbacks = hashMapOf<String, WsResultCallback>()
    private var marketInit = 0
    var cid: Int = 0

    interface WsResultCallback {
        fun onWsMessage(json: String)
    }

    companion object {
        var wsAgentManager: WsContractAgentManager? = null
        const val WEBSOCKET_tickerFor24HLink = "tickerFor24HLink" //24H market
        const val WEBSOCKET_getDepthLink = "depthLink" //Deep disc mouth
        val instance: WsContractAgentManager
            get() {
                if (wsAgentManager == null)
                    wsAgentManager = WsContractAgentManager()
                return wsAgentManager!!
            }
    }

    init {
        val newBuilder = OkHttpClient().newBuilder()
        if (BuildConfig.DEBUG) {
            val sslParams = HttpsUtils.getSslSocketFactory(null, null, null)
            newBuilder.protocols(Collections.singletonList(Protocol.HTTP_1_1))
            newBuilder.sslSocketFactory(sslParams.sSLSocketFactory, sslParams.trustManager)
        }
        mOkHttpClient = newBuilder
                .retryOnConnectionFailure(true)
                .connectTimeout(20, TimeUnit.SECONDS)
                .writeTimeout(20, TimeUnit.SECONDS)
                .readTimeout(20, TimeUnit.SECONDS)
                .build()

    }

    fun socketUrl(socketUrl: String, isMainThread: Boolean = true) {
        this.serverUrl = socketUrl
        if (isMainThread) {
            initWS()
        }
    }
    fun connectionSocket(){
        if (!isConnection()) {
            initWS()
        }
    }

    fun sendMessage(message: HashMap<String, Any>, callback: WsResultCallback?) {
        if (!isConnection()) {
            initWS()
        }
        if (callback != null) {
            val key = callback.javaClass.simpleName
            
            if (mapSubCallbacks.containsKey(key)) {
                lastNew = key
                when (key) {
                    "ClContractFragment" -> {
                        mapAnySubCallbacks.put(key, message)
                        if (message.contains("symbol")) {
                            val symbol = message.get("symbol") as String
                            
                            val step = if (message.containsKey("step")) message.get("step") as String else "0"
                            val team = mapSubCallbacks.get(key) as HashMap
                            val temp = if (team.containsKey("depthLink")) (team.get("depthLink") as WsLinkBean).symbol else ""
                            val tempStep = if (team.containsKey("depthLink")) (team.get("depthLink") as WsLinkBean).step else ""
                            val symbolEquls = temp != symbol //false
                            val symbolStep = tempStep != step && tempStep.isNotEmpty() //false
                            val reSend = symbolEquls || symbolStep
                            
                            if (team.isNotEmpty() && team.size != 0 && reSend) {
                                unbind(callback, false, symbolEquls, symbolStep)
                            }

                            val isReSend = temp.isEmpty() || reSend
                            
                            
                            
                            
                            if (isReSend) {
                                
                                val ticker = WsLinkUtils.tickerFor24HLinkBean(symbol)
                                val depthLink = WsLinkUtils.getDepthLink(symbol, true, if (step.isEmpty()) "0" else step)
                                val map = hashMapOf("ticker24H" to ticker, "depthLink" to depthLink)
                                mapSubCallbacks.put(key, map)
                                // ticker
                                if (!symbolStep || symbolEquls) {
                                    sendData(ticker)
                                }
                                // depthLink
                                sendData(depthLink)
                            }
                        }
                    }
                    "ClContractCoinSearchDialog" -> {
                        val symbol = message.get("symbols") as String
                        val bind = message.get("bind") as Boolean
                        val type = JsonWSUtils.gson.fromJson<Array<String>>(symbol, object : TypeToken<Array<String>>() {}.type)
                        val arrays = StringBuffer()
                        for (item in type) {
                            arrays.append(item + ",")
                        }
                        if (arrays.isEmpty()) {
                            return
                        }
                        val event = WsLinkUtils.tickerFor24HLinkBatchBean(arrays.substring(0, arrays.length - 1), bind)
                        unbind(callback, false)
                        sendData(event)
                        mapAnySubCallbacks.put(key, message)
                        mapSubCallbacks.put(key, hashMapOf("batchMarket" to event))
                    }
                    "ClMarketDetail4Activity" -> {
                        val symbol = message.get("symbol") as String
                        val step = if (message.containsKey("line")) message.get("line") as String else "15min"

                        val team = mapSubCallbacks.get(key) as HashMap
                        val temp = if (team.containsKey("depthLink")) (team.get("depthLink") as WsLinkBean).symbol else ""

                        val symbolEquls = temp != symbol
                        //Does not equal to specifying a new currency
                        val isSend = temp.isNotEmpty()
                        if (team.isNotEmpty() && team.size != 0 && isSend) {
                            unbind(callback, false, symbolEquls, false)
                        }

                        var map = hashMapOf<String, WsLinkBean>()
                        val isReSend = temp.isEmpty() || symbolEquls
                        if ((team.isEmpty() || team.size == 0) || isReSend) {
                            val ticker = WsLinkUtils.tickerFor24HLinkBean(symbol)
                            sendData(ticker)
                            map["ticker24H"] = ticker

                            val depthLink = WsLinkUtils.getDepthLink(symbol)
                            sendData(depthLink)
                            map["depthLink"] = depthLink

                            val depthList = WsLinkUtils.getDealHistoryLink(symbol)
                            sendData(depthList)
                            map["depthList"] = depthList
                        } else {
                            map = mapSubCallbacks.get(key) as HashMap<String, WsLinkBean>
                        }
                        //
                        val kineHistory = WsLinkUtils.getKLineHistoryLink(symbol, step)
                        sendData(kineHistory)
                        map["line"] = kineHistory
                        mapAnySubCallbacks.put(key, message)


                        mapSubCallbacks.put(key, map)
                    }
                    "ClHorizonMarketDetailActivity" -> {
                        val symbol = message.get("symbol") as String
                        val step = if (message.containsKey("line")) message.get("line") as String else "15min"

                        val team = mapSubCallbacks.get(key) as HashMap
                        val temp = if (team.containsKey("line")) (team.get("line") as WsLinkBean).symbol else ""

                        val symbolEquls = temp != symbol
                        //Does not equal to specifying a new currency
                        val isSend = temp.isNotEmpty()
                        if (team.isNotEmpty() && team.size != 0 && isSend) {
                            unbind(callback, false, symbolEquls, false)
                        }
                        var map = hashMapOf<String, WsLinkBean>()
                        val isReSend = temp.isEmpty() || symbolEquls
                        if ((team.isEmpty() || team.size == 0) || isReSend) {
                            val ticker = WsLinkUtils.tickerFor24HLinkBean(symbol)
                            sendData(ticker)
                            map["ticker24H"] = ticker
                        } else {
                            map = mapSubCallbacks.get(key) as HashMap<String, WsLinkBean>
                        }
                        //
                        val kineHistory = WsLinkUtils.getKLineHistoryLink(symbol, step)
                        sendData(kineHistory)
                        map["line"] = kineHistory
                        mapAnySubCallbacks.put(key, message)
                        mapSubCallbacks.put(key, map)
                    }
                    else -> {

                    }
                }
            }
        }
    }

    fun sendData(wsLinkBean: WsLinkBean) {
        if (isConnection()) {
            val send = mWebSocket?.send(wsLinkBean.json)
            
        }
    }

    fun sendData(wsLinkBean: String) {
        
        if (isConnection()) {
            val sendStatus = mWebSocket?.send(wsLinkBean)
            
        } else {
            
        }
    }


    fun unbind(callback: WsResultCallback?, isStop: Boolean = true, isSymbol: Boolean = false, step: Boolean = false, time: Boolean = false) {
        
        if (callback != null) {
            val key = callback.javaClass.simpleName
            
            if (mapSubCallbacks.containsKey(key)) {
                when (key) {
                    "NCVCTradeFragment" -> {
                        val map = mapSubCallbacks.get(key) as HashMap
                        if (map.contains("depthLink")) {
                            val bean = map.get("depthLink") as WsLinkBean
                            val symbol = bean.symbol
                            val ticker = WsLinkUtils.tickerFor24HLinkBean(symbol, false)
                            val depthLink = WsLinkUtils.getDepthLink(symbol, false, bean.step)
                            if (!step || isSymbol) {
                                sendData(ticker)
                            }
                            sendData(depthLink)
                        }

                    }
                    "NewVersionMarketFragment", "NewVersionHomepageFragment" -> {
                        val map = mapSubCallbacks.get(key) as HashMap
                        if (map.contains("batchMarket")) {
                            val bean = map.get("batchMarket") as WsLinkBean
                            val symbol = bean.symbol
                            val event = WsLinkUtils.tickerFor24HLinkBatchBean(symbol, false)
                            sendData(event)
                        }
                    }
                    "MarketDetail4Activity" -> {
                        val map = mapSubCallbacks.get(key) as HashMap
                        if (map.contains("line")) {
                            val bean = map.get("line") as WsLinkBean
                            val symbol = bean.symbol

                            val ticker = WsLinkUtils.tickerFor24HLinkBean(symbol, false)
                            if (isSymbol || isStop) {
                                sendData(ticker)

                                val depthLink = WsLinkUtils.getDepthLink(symbol, false)
                                sendData(depthLink)

                                val depthNew = WsLinkUtils.getDealNewLink(symbol, false)
                                sendData(depthNew)
                            }
                            val time = if (bean.time != "") bean.time else "15min"
                            val depthKline = WsLinkUtils.getKlineNewLink(symbol, time, false)
                            sendData(depthKline)

                        }
                    }
                    "ClHorizonMarketDetailActivity" -> {
                        val map = mapSubCallbacks.get(key) as HashMap
                        if (map.contains("line")) {
                            val bean = map.get("line") as WsLinkBean
                            val symbol = bean.symbol
                            val ticker = WsLinkUtils.tickerFor24HLinkBean(symbol, false)
                            if (isSymbol || isStop) {
                                sendData(ticker)
                            }
                            val time = if (bean.time != "") bean.time else "15min"
                            val depthNew = WsLinkUtils.getKlineNewLink(symbol, time, false)
                            sendData(depthNew)
                        }
                    }
                    else -> {

                    }

                }
                if (isStop) {
                    removeWsCallback(callback)
                }
            } else {
                
            }
        }
    }

    fun reConnection() {
        
        mWebSocket = null
        isConnection = false
        if (!isAppStopWs) {
            if (mCount <= reCount) {
                
                Observable.timer(1, TimeUnit.SECONDS)
                        .subscribeOn(Schedulers.io())
                        .observeOn(AndroidSchedulers.mainThread()).subscribe {
                            initWS()
                            mCount++
                        }
            } else {
                
                resetParams()
            }
        }
    }

    fun changeNotice(status: NetUtil.Companion.ConnectStatus) {
        if (status != NetUtil.Companion.ConnectStatus.NO_NETWORK) {
            if (!isConnection()) {
                resetParams()
                stopPong()
                reConnection()
            }
        }
    }

    fun resetParams() {
        mCount = 0
    }

    @Synchronized
    fun addWsCallback(callback: WsResultCallback) {
        val key = callback.javaClass.simpleName
        if (mapSubCallbacks.contains(key)) {
            
//            subCallbacks.remove(key)
//            mapSubCallbacks.remove(key)
//            subCallbacks.put(key, callback)
//            callbacks.forEach {
//                if (it.javaClass.simpleName == key) {
//                    callbacks.remove(it)
//                }
//            }
        }
        mapSubCallbacks.put(key, hashMapOf())
        subCallbacks.put(key, callback)
    }

    @Synchronized
    fun removeWsCallback(callback: WsResultCallback): Boolean {
        val key = callback.javaClass.simpleName
        if (mapSubCallbacks.size == 0) {
            
            return false
        }
        mapSubCallbacks.set(key, hashMapOf())
        return true
    }

    private var isConnection = false
    private fun initWS() {
        
        if (isConnection || serverUrl.isEmpty() || !serverUrl.startsWith("ws")) {
            return
        }
        isAppStopWs = false
        isConnection = true
        val request = Request.Builder().url(this.serverUrl).build()
        mOkHttpClient?.newWebSocket(request, wsEventList)
        initPong()

    }

    fun isConnection(): Boolean {
        if (mWebSocket != null) {
            return true
        }
        return false
    }

    private var wsEventList = object : WebSocketListener() {
        override fun onOpen(webSocket: WebSocket, response: Response) {
            super.onOpen(webSocket, response)
            
            mWebSocket = webSocket
            isConnection = false
            resetParams()
            
            if (!isBackgroud) {
                wsBackgroupChange(lastNew)
            }
        }

        override fun onMessage(webSocket: WebSocket, bytes: ByteString) {
            super.onMessage(webSocket, bytes)
            if (bytes.size == 0) {
                return
            }
            val data = GZIPUtils.uncompressToString(bytes.toByteArray())
            if (data.isNullOrEmpty()) {
                return
            }
            if (data.contains("ping")) {
                Log.v(TAG, "onMessage() data =  ${data}")
                val replace = data.replace("ping", "pong")
                sendData(replace)
            } else {
                try {
                    Log.v(TAG, "onMessage() data =  ${data}")
                    val jsonObj = JSONObject(data)
                    if (!jsonObj.isNull("tick")) {
                        val channel = jsonObj.optString("channel")
                        subCallbacks.forEach {
                            val key = it.key
                            val callValue = it.value
                            if (mapSubCallbacks.containsKey(key)) {
                                val hashMap = mapSubCallbacks.get(key)
                                hashMap?.apply {
                                    for (hashItem in hashMap.entries) {
                                        val isSend = dataCall(channel, hashItem.value, callValue, data)
                                        if (isSend) {
                                            break
                                        }
                                    }
                                }
                            }
                            if (key.equals("ClContractStopRateLossActivity")){
                                callValue.onWsMessage(data)
                            }
                        }
                    } else {
                        if (!jsonObj.isNull("data")) {
                            val channel = jsonObj.optString("channel")
                            val key = channel.contains("kline") || channel.contains("trade")
                            if (key) {
                                dataCall(channel, WsLinkBean("", ""), subCallbacks.get(keyLine)!!, data)
                            } else {
                                dataCall(channel, WsLinkBean("", ""), subCallbacks.get("SlContractFragment")!!, data)
                            }

                        }
                    }
                } catch (e: JSONException) {
                    e.printStackTrace()
                }
            }
        }

        override fun onMessage(webSocket: WebSocket, text: String) {
            super.onMessage(webSocket, text)
        }

        override fun onFailure(webSocket: WebSocket, t: Throwable, response: Response?) {
            super.onFailure(webSocket, t, response)
            t.printStackTrace()
            
            reConnection()
        }

        override fun onClosed(webSocket: WebSocket, code: Int, reason: String) {
            super.onClosed(webSocket, code, reason)
            
            reConnection()
        }

        override fun onClosing(webSocket: WebSocket, code: Int, reason: String) {
            super.onClosing(webSocket, code, reason)
            
            reConnection()
        }
    }

    fun stopWs() {
        isAppStopWs = true
        stopPong()
        mWebSocket?.cancel()
        mWebSocket?.close(1000, null)
        mapSubCallbacks.clear()
        mapAnySubCallbacks.clear()
        callbacks.clear()
        subCallbacks.clear()
        resetParams()
        marketInit = 0


    }

    private fun initPong() {
        if (subscribePong == null || (subscribePong != null && subscribePong?.isDisposed != null && subscribePong?.isDisposed!!)) {
            subscribePong = Observable.interval(20, TimeUnit.SECONDS)//Sending Observeable integers at time intervals
                    .observeOn(AndroidSchedulers.mainThread())//Switch to the main thread to modify the UI
                    .subscribe {
                        sendData(WsLinkUtils.pongBean().json)
                    }
        }
    }

    private fun stopPong() {
        subscribePong?.dispose()
    }

    private fun dataCall(dataChannel: String, mapChannel: WsLinkBean, wsResultCallback: WsResultCallback, json: String): Boolean {
        if (dataChannel == mapChannel.channel) {
            wsResultCallback.onWsMessage(json)
        } else {
            if (dataChannel.contains("kline") || dataChannel.contains("trade")) {
                wsResultCallback.onWsMessage(json)
            } else if (dataChannel.contains("ticker")) {
                if (mapChannel.event.contains("batch")) {
                    val arrays = mapChannel.channel.split(",")
                    for (item in arrays) {
                        if (item == dataChannel) {
                            wsResultCallback.onWsMessage(json)
                        }
                    }
                } else {
                    return false
                }
            } else if (dataChannel.contains("review")) {
                marketInit++
                wsResultCallback.onWsMessage(json)
            } else {
                return false
            }
        }
        return true
    }

    var lastNew = ""
    fun wsBackgroupChange(fragmentName: String, unBind: Boolean = false) {
        if (mapSubCallbacks.containsKey(fragmentName)) {
            
            lastNew = fragmentName
            val arrays = mapSubCallbacks.get(fragmentName)
            if (arrays != null) {
                if (unBind) {
                    unbind(subCallbacks.get(fragmentName), true)
                } else {
                    if (mapAnySubCallbacks.containsKey(fragmentName)) {
                        mapSubCallbacks.set(lastNew, hashMapOf())
                        sendMessage(mapAnySubCallbacks.get(fragmentName)!!, subCallbacks.get(fragmentName))
                    }
                }
            } else {
                
            }
        } else {
            
        }
    }

    var keyLine = ""
    fun changeKlineKey(name: String) {
        this.keyLine = name
    }

    enum class WSStatus {
        CONNECTIONING,
        CONNECTION
    }

    fun saveCID(cid: String?) {
        if (cid != null && cid.isNotEmpty()) {
            this.cid = cid.toInt()
        }
    }


}
