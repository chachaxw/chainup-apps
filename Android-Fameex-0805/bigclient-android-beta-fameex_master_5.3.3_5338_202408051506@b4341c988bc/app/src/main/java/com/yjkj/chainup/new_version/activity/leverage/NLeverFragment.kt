package com.yjkj.chainup.new_version.activity.leverage

import android.os.Bundle
import android.os.Handler
import androidx.core.widget.NestedScrollView
import androidx.recyclerview.widget.LinearLayoutManager
import android.text.TextUtils
import android.view.View
import com.jakewharton.rxbinding2.view.RxView
import com.chainup.talkingdata.AppAnalyticsExt
 import com.chainup.contract.view.dialog.CpTDialog
import com.chainup.kit.views.KKEmptyViewKit
import com.yjkj.chainup.R
import com.yjkj.chainup.app.AppConstant
import com.yjkj.chainup.base.NBaseFragment
import com.yjkj.chainup.db.constant.CommonConstant
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.constant.TradeTypeEnum
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.extra_service.eventbus.NLiveDataUtil
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.LoginManager
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.manager.RateManager
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_version.adapter.NCurrentEntrustAdapter
import com.yjkj.chainup.new_version.dialog.DialogUtil
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.util.*
import com.yjkj.chainup.wedegit.CoinSearchDialogFg
import com.yjkj.chainup.ws.WsAgentManager
import io.reactivex.Observable
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import kotlinx.android.synthetic.main.depth_vertical_layout.view.*
import kotlinx.android.synthetic.main.depth_vertical_layout_lever.view.trade_amount_view
import kotlinx.android.synthetic.main.fragment_nlever.*
import kotlinx.android.synthetic.main.fragment_nlever.rv_current_entrust
import kotlinx.android.synthetic.main.fragment_nlever.swipe_refresh
import kotlinx.android.synthetic.main.fragment_nlever.tv_risk_rate
import kotlinx.android.synthetic.main.trade_amount_view.*
import kotlinx.android.synthetic.main.trade_amount_view.view.*
import kotlinx.android.synthetic.main.trade_amount_view_new.v_tb_bar
import kotlinx.android.synthetic.main.trade_header_tools.*
import kotlinx.android.synthetic.main.trade_header_view.*
import org.java_websocket.client.WebSocketClient
import org.jetbrains.anko.backgroundResource
import org.jetbrains.anko.doAsync
import org.jetbrains.anko.textColor
import org.json.JSONObject
import java.util.concurrent.TimeUnit

private const val ARG_PARAM1 = "param1"
private const val ARG_PARAM2 = "param2"

/**
 * @author Bertking
 *@description lever
 * @Date 2023-11-05
 *
 */
class NLeverFragment : NBaseFragment(), View.OnClickListener,WsAgentManager.WsResultCallback {

    var dialog:  CpTDialog? = null

    /**
     *Obtain available balance
     */
    var availableBalanceData: JSONObject? = null
    var coinMapData: JSONObject? = null
    val currentOrderList = arrayListOf<JSONObject>()
    val curEntrustAdapter = NCurrentEntrustAdapter(currentOrderList)
    var riskRateData: JSONObject? = null

    private var param1: String? = null
    private var param2: String? = null
    private var socketClient: WebSocketClient? = null

    var symbol = ""
    var subscribeCoin: Disposable? = null//Save subscribers
    var isScrollStatus = true
    private var lastTick: JSONObject? = null
    private var lastRose: String? = null
    companion object {
        @JvmStatic
        fun newInstance(param1: String, param2: String) =
                NLeverFragment().apply {
                    arguments = Bundle().apply {
                        putString(ARG_PARAM1, param1)
                        putString(ARG_PARAM2, param2)
                    }
                }

        var curDepthIndex = 0
        var tradeOrientation = ParamConstant.TYPE_BUY
        var tapeLevel = 0

    }

    override fun setContentView() = R.layout.fragment_nlever


    override fun onClick(v: View?) {
        when (v?.id) {
            R.id.ll_show_dialog, R.id.ll_risk_rate, R.id.tv_burst_sell -> {
                if (!LoginManager.checkLogin(context, true)) {
                    return
                }
                dialog = NewDialogUtils.leverAccountDialog(context
                        ?: return, symbol, riskRateData, object : NewDialogUtils.DialogOnItemClickListener {
                    override fun clickItem(position: Int) {
                        if (!LoginManager.checkLogin(context, true)) return
                        when (position) {
                            1 -> {
                                //Lending
                                ArouterUtil.navigation(RoutePath.NewVersionBorrowingActivity, Bundle().apply {
                                    putString(ParamConstant.symbol, coinMapData?.optString("symbol", ""))
                                })
                            }
                            2 -> {
                                ArouterUtil.navigation(RoutePath.CurrencyLendingRecordsActivity, Bundle().apply {
                                    putString(ParamConstant.symbol, symbol)
                                })
                            }
                            3 -> {
                                //Transfer
                                ArouterUtil.navigation(RoutePath.NewVersionTransferActivity, Bundle().apply {
                                    putString(ParamConstant.TRANSFERSTATUS, ParamConstant.LEVER_INDEX)
                                    putString(ParamConstant.TRANSFERCURRENCY, coinMapData?.optString("symbol", ""))
                                })
                            }
                        }
                        dialog?.dismiss()

                    }
                })

            }

            /*Enter the All Delegation interface*/
            R.id.ll_all_entrust_order -> {
                if (LoginManager.checkLogin(context, true)) {
                    ArouterUtil.navigation(RoutePath.EntrustActivity, Bundle().apply {
                        putString(ParamConstant.TYPE, ParamConstant.LEVER_INDEX)
                        putString("coinName",  coinMapData?.getMarketName(false))
                    })
                }
            }

            /*Enter KLine*/
            R.id.ib_kline -> {
                ArouterUtil.forwardKLine(symbol, ParamConstant.LEVER_INDEX)
            }

        }
    }


    override fun initView() {
        setTextContent()
        iv_more_coin.visibility = View.GONE
        if (PublicInfoDataService.getInstance().isHorizontalDepth4Lever) {
            v_horizontal_depth_lever?.visibility = View.VISIBLE
            v_vertical_depth_lever?.visibility = View.GONE
            v_horizontal_depth_lever?.initVolView()
        } else {
            v_vertical_depth_lever?.visibility = View.VISIBLE
            v_horizontal_depth_lever?.visibility = View.GONE
            v_vertical_depth_lever?.initVolView()
        }

        tv_risk_rate?.text = LanguageUtil.getString(context, "leverage_risk") + " --"
        tv_burst_sell?.text = LanguageUtil.getString(context, "leverage_borrow") + "/" + LanguageUtil.getString(context, "return_the_number")
        changeInitData()
        ll_show_dialog?.setOnClickListener(this)
        ll_risk_rate?.setOnClickListener(this)
        tv_burst_sell?.setOnClickListener(this)
        ll_all_entrust_order?.setOnClickListener(this)
        ib_kline?.setOnClickListener(this)

        /**
         *Entrance
         */
        iv_more?.setOnClickListener {
            DialogUtil.createLeverPop(context, iv_more, this)
        }
        /**
         *More currencies
         */
        RxView.clicks(iv_more_coin)
                .throttleFirst(1000L, TimeUnit.MILLISECONDS)
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({ x ->
                    val coinList = NCoinManager.getSymbolByMarket(coinMapData?.getMarketNameByCoinList(), true)
                    LogUtil.e(TAG, "coinList $coinList")
                    DialogUtil.createCVCPopCoins(context, iv_more_coin, coinList, TradeTypeEnum.LEVER_TRADE.value)
                })
        /**
         *Switch Currency
         */
        ll_coin_map?.setOnClickListener {
            showLeftCoinPopup()
        }


        nsv_lever?.setOnScrollChangeListener { _: NestedScrollView?, _: Int, _: Int, _: Int, _: Int ->
            v_vertical_depth_lever?.et_price?.clearFocus()
            v_horizontal_depth_lever?.et_price?.clearFocus()
        }

        observeData()
        initEntrustOrder()
        setTopBar()

//        swipe_refresh.setColorSchemeColors(ContextUtil.getColor(R.color.colorPrimary))
        /**
         *Refresh Here
         */
        swipe_refresh?.setOnRefreshListener {
            /**
             *Refresh Data Operation
             */
            observeData()
            initEntrustOrder()
            swipe_refresh?.finishRefresh(true)
        }
    }


    fun setTextContent() {
        tv_risk_rate_label?.text = LanguageUtil.getString(context, "leverage_risk")
        tv_price?.text = LanguageUtil.getString(context, "leverage_text_blowingUp")
        tv_currentEntrust?.text = LanguageUtil.getString(context, "contract_text_currentEntrust")
        tv_all?.text = LanguageUtil.getString(context, "common_action_sendall")
    }

    private fun showTopCoin() {
        val symbol = coinMapData?.getMarketName(true)
        tv_coin_map?.text = symbol
        v_vertical_depth_lever?.initCoinSymbol(symbol, true)
        v_horizontal_depth_lever?.initCoinSymbol(symbol, true)
    }


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        arguments?.let {
            param1 = it.getString(ARG_PARAM1)
            param2 = it.getString(ARG_PARAM2)
        }
    }

    private fun setTopBar() {
        v_horizontal_depth_lever?.apply {
            var tradeType = 0
            if (isFromOtherPage) {
                tradeType = trade_amount_view.transactionType
                isFromOtherPage = false
            } else {
                tradeType = trade_amount_view.transactionType
            }
            trade_amount_view?.buyOrSell(tradeType, true)
        }
        v_vertical_depth_lever?.trade_amount_view_l?.buyOrSell(0, true)
    }


    private var hasInit = false

    private fun initEntrustOrder() {
        if (hasInit) {
            return
        }
        hasInit = true

        rv_current_entrust?.run {
            layoutManager = LinearLayoutManager(context)
            curEntrustAdapter.addChildClickViewIds(R.id.tv_status)
            adapter = curEntrustAdapter
            curEntrustAdapter.setEmptyView(KKEmptyViewKit(context).apply {
                setImageViewTop(32.0f)
            })
            curEntrustAdapter.notifyDataSetChanged()
            curEntrustAdapter.setOnItemChildClickListener { adapter, _, position ->
                if (adapter.data.isNotEmpty()) {
                    try {
                        (adapter.data[position] as JSONObject?)?.run {
                            val status = this.optString("status")
                            val id = this.optString("id")
                            val baseCoin = optString("baseCoin").toLowerCase()
                            val countCoin = optString("countCoin").toLowerCase()

                            when (status) {
                                "0", "1", "3" -> {
                                    deleteOrder(id, baseCoin + countCoin, position)
                                }
                            }
                        }

                    } catch (e: java.lang.Exception) {
                        e.printStackTrace()
                    }
                }
            }
        }
    }

    private fun getAvailableBalance() {
        if (!LoginManager.checkLogin(context, false)) {
            currentOrderList.clear()
            curEntrustAdapter.setList(currentOrderList)
            return
        }
        if (!StringUtil.checkStr(symbol)) {
            return
        }
        
        addDisposable(getMainModel().getNewEntrust(symbol = symbol, isLever = true, consumer = object : NDisposableObserver() {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                jsonObject.optJSONObject("data")?.run {
                    
                    availableBalanceData = this
                    showBalanceData()
                    /*Process orders*/
                    val orderList = optJSONArray("orderList")
                    orderList?.run {
                        
                        currentOrderList.clear()
                        for (i in 0 until orderList.length()) {
                            currentOrderList.add(orderList.optJSONObject(i))
                        }
                        curEntrustAdapter.setList(currentOrderList)
                        v_vertical_depth_lever?.changeOrder(currentOrderList)
                        v_horizontal_depth_lever?.changeOrder(currentOrderList)
                    }

                }
            }
        }))
    }

    private fun showBalanceData() {
        if (availableBalanceData == null) {
            return
        }
        v_horizontal_depth_lever?.changeData(availableBalanceData)
        v_vertical_depth_lever?.changeData(availableBalanceData)
    }

    /**
     *Show tags
     */
    private fun setTagView(name: String) {
        val tagCoin = NCoinManager.getMarketCoinName(name)
        if (!TextUtils.isEmpty(NCoinManager.getCoinTag4CoinName(tagCoin))) {
            ctv_content?.visibility = View.GONE
            ctv_content?.text = NCoinManager.getCoinTag4CoinName(tagCoin)
        } else {
            ctv_content?.visibility = View.GONE
        }

    }

    private fun observeData() {
        NLiveDataUtil.observeData(this){
            when(it.msg_type){
                MessageEvent.login_operation_type -> {
                    if (!LoginManager.isLogin(context)) {
                        currentOrderList.clear()
                        curEntrustAdapter.setList(currentOrderList)
                    }
                    v_vertical_depth_lever?.loginSwitch()
                    v_horizontal_depth_lever?.loginSwitch()
                }
            }
        }
        NLiveDataUtil.observeForeverData {
            if (null == it || !it.isLever)
                return@observeForeverData
            when (it.msg_type) {
                //Switch Currency Event
                MessageEvent.symbol_switch_type -> {
                    if (null != it.msg_content) {
                        val nSymbol = it.msg_content as String
                        
                        setTagView(NCoinManager.getNameForSymbol(nSymbol))
                        showSymbolSwitchData(nSymbol)
                        setTopBar()
                    }
                }
                //Depth
                MessageEvent.DEPTH_LEVEL_TYPE -> {
                    if (null != it.msg_content) {
                        val level = it.msg_content as Int
                        if (curDepthIndex != level) {
                            curDepthIndex = level
                            if (StringUtil.checkStr(symbol)) {
                                WsAgentManager.instance.unbind(this)
                                if (StringUtil.checkStr(symbol)) {
                                    WsAgentManager.instance.sendMessage(hashMapOf("symbol" to symbol, "step" to curDepthIndex.toString()), this)
                                }
                            }

                        }
                    }
                }
                //Order notification
                MessageEvent.CREATE_ORDER_TYPE -> {
                    
                    val isRun = it.msg_content as Boolean
                    if (isRun) {
                        getEachEntrust()
                    }
                }

            }
        }
    }

    /**
     *Initial opening&latest transaction price
     */
    private fun initTap() {
        v_vertical_depth_lever?.clearDepthView()
        tapeLevel = 0
        v_horizontal_depth_lever?.tapeLevel = 0
        v_horizontal_depth_lever?.changeTape(AppConstant.DEFAULT_TAPE, needData = false)
    }

    private fun showSymbolSwitchData(newSymbol: String?) {
        LogUtil.d(TAG, "observeData==newSymbol is $newSymbol")
        if (null == newSymbol)
            return
        if (newSymbol != symbol) {
            initTap()

            coinMapData = NCoinManager.getSymbolObj(newSymbol)
            symbol = coinMapData?.optString("symbol", "") ?: return
            curDepthIndex = 0

            if (StringUtil.checkStr(symbol)) {
                WsAgentManager.instance.unbind(this)
                if (StringUtil.checkStr(symbol)) {
                    WsAgentManager.instance.sendMessage(hashMapOf("symbol" to symbol, "step" to curDepthIndex.toString()), this)
                    Handler().postDelayed({
                        v_horizontal_depth_lever?.resetPrice()
                        v_vertical_depth_lever?.resetPrice()
                    },500)
                }
            }
            getRiskRate()
            getAvailableBalance()
            PublicInfoDataService.getInstance().currentSymbol4Lever = newSymbol
            changeCoinMap()

            activity?.runOnUiThread {
                showTopCoin()
                et_price?.setText("")
            }
            currentOrderList.clear()
            curEntrustAdapter.notifyDataSetChanged()
        }
    }



    /**
     *Obtain 'Risk Rate'
     */
    private fun getRiskRate() {
        
        if (!LoginManager.checkLogin(activity, false)) {
            riskRateData = null
            tv_risk_rate?.text = "--"
            tv_risk_rate?.textColor = ColorUtil.getColor(R.color.normal_text_color)
            tv_burst_price?.text = " --"
            return
        }
        addDisposableTrade(getMainModel().getBalance4Lever(symbol = symbol, consumer = object : NDisposableObserver(null, false) {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                
                riskRateData = null
                jsonObject.optJSONObject("data")?.run {
                    riskRateData = this
                    //Risk rate
                    var riskRate = optString("riskRate", "--")
                    if(StringUtil.isNumeric(riskRate) && BigDecimalUtils.compareTo(riskRate, "999")==1){
                        riskRate = "999"
                    }
                    tv_risk_rate?.text = "$riskRate%"
                    if (BigDecimalUtils.compareTo(riskRate,"200") >= 0) {
                        tv_risk_rate?.textColor = ColorUtil.getColor(R.color.green)
                    } else if (BigDecimalUtils.compareTo(riskRate,"110") >= 0 && BigDecimalUtils.compareTo(riskRate,"200") <= 0) {
                        tv_risk_rate?.textColor = ColorUtil.getColor(R.color.red)
                    } else {
                        tv_risk_rate?.textColor = ColorUtil.getColor(R.color.normal_text_color)
                        tv_risk_rate?.text = "--"
                    }
                    //Burst price
                    var burstPrice = optString("burstPrice", "")
                    val precision = v_horizontal_depth_lever?.getPrecision() ?: 4
                    burstPrice = DecimalUtil.cutValueByPrecision(burstPrice
                            ?: "0", precision)
                    if("999".equals(riskRate)){
                        burstPrice = "--"
                    }
                    tv_burst_price?.text = burstPrice

                }
            }

            override fun onResponseFailure(code: Int, msg: String?) {
                super.onResponseFailure(code, msg)
                riskRateData = null
            }
        }))

    }

    private fun loopData() {
        LogUtil.d(TAG, "fragmentVisible==NLeverFragment==isVisible is $isVisible,userVisibleHint is $userVisibleHint")

        if (!mIsVisibleToUser || !leverFragment)
            return
        if (subscribeCoin == null || (subscribeCoin != null && subscribeCoin?.isDisposed != null && subscribeCoin?.isDisposed!!)) {
            subscribeCoin = Observable.interval(0L, CommonConstant.coinLoopTime, TimeUnit.SECONDS)//Sending Observeable integers at time intervals
                    .observeOn(AndroidSchedulers.mainThread())//Switch to the main thread to modify the UI
                    .subscribe {
                        getEachEntrust()
                        getRiskRate()
                    }
        }
    }

    //Current delegation
    private fun getEachEntrust() {
        if (!LoginManager.checkLogin(activity, false)) {
            return
        }

        if (!StringUtil.checkStr(symbol)) {
            return
        }
        addDisposableTrade(getMainModel().getNewEntrust(symbol = symbol, isLever = true, consumer = object : NDisposableObserver(null, false) {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                val data = jsonObject.optJSONObject("data")
                data?.run {
                    availableBalanceData = data
                    showBalanceData()
                    val jsonArray = data.getJSONArray("orderList")
                    if (jsonArray.length() == 0) {
                        currentOrderList.clear()
                        curEntrustAdapter.setList(currentOrderList)
                        disposables?.clear()
                    } else {
                        currentOrderList.clear()
                        jsonArray.run {
                            
                            currentOrderList.clear()
                            for (i in 0 until jsonArray.length()) {
                                currentOrderList.add(jsonArray.optJSONObject(i))
                            }
                            curEntrustAdapter.setList(currentOrderList)
                        }
                    }
                    v_vertical_depth_lever?.changeOrder(currentOrderList)
                    v_horizontal_depth_lever?.changeOrder(currentOrderList)

                }
                loopData()
            }

            override fun onResponseFailure(code: Int, msg: String?) {
                super.onResponseFailure(code, msg)
                loopData()
            }
        }))
    }

    private fun getEntrustInterval5() {
        loopData()
    }

    /**
     *Cancel Order
     */
    private fun deleteOrder(order_id: String, symbol: String, pos: Int) {
        AppAnalyticsExt.instance.clickAction(AppAnalyticsExt.APP_ACTION_LeverCancel, mapOf("orderId" to order_id, "symbol" to symbol))
        addDisposable(getMainModel().cancelOrder(order_id = order_id, symbol = symbol, isLever = true, consumer = object : NDisposableObserver(activity,showToast = true) {
            override fun onResponseSuccess(data: JSONObject) {
                NToastUtil.showTopToastNet(mActivity, true, LanguageUtil.getString(context, "common_tip_cancelSuccess"))
                val obj = curEntrustAdapter.getItem(pos)
                curEntrustAdapter.remove(obj)
                clearToolHttp()
            }
        }))
    }

    /**
     *Processing 24H, KLine data
     */
    fun handleData(data: String) {
        //Log. d (TAG, "==111==24H Market: $data")
        try {
            val jsonObj = JSONObject(data)
            if (!jsonObj.isNull("tick")) {
                val tick = jsonObj.optJSONObject("tick") ?: return
                val channel = jsonObj.getString("channel")
                /**
                 *24H market
                 */
                if (!StringUtil.checkStr(symbol)) {
                    return
                }
                if (channel == WsLinkUtils.tickerFor24HLink(symbol, isChannel = true)) {
                    lastTick = jsonObj
                    doAsync {
                        activity?.runOnUiThread {
                            v_horizontal_depth_lever?.changeTickData(tick)
                            v_vertical_depth_lever?.changeTickData(tick)
                            //
                            val rose = tick.getRose()
                            lastRose=rose
                            RateManager.getRoseText(tv_rose, rose)
                            val roseRes = ColorUtil.getMainColorBgType(RateManager.getRoseTrend(rose) >= 0)
                            tv_rose?.textColor = roseRes.first
                            tv_rose?.backgroundResource = roseRes.second
                        }
                    }
                }
                /**
                 *Depth
                 */
                if (channel == WsLinkUtils.getDepthLink(symbol, isSub = true, step = curDepthIndex.toString()).channel) {
                    activity?.runOnUiThread {
                        v_horizontal_depth_lever?.refreshDepthView(jsonObj)
                        v_vertical_depth_lever?.refreshDepthView(jsonObj)
                    }
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun fragmentVisibile(isVisibleToUser: Boolean) {
        super.fragmentVisibile(isVisibleToUser)
        val isVisibleParentFg = (parentFragment as? NBaseFragment)?.let {
            !it.isHidden
        }?:false
        if (isVisibleToUser && isVisibleParentFg) {
            if(!leverFragment){
                leverFragment = true
                setTopBar()
                if (StringUtil.checkStr(symbol)) {
                    WsAgentManager.instance.sendMessage(hashMapOf("symbol" to symbol, "step" to curDepthIndex.toString()), this)
                }

                getRiskRate()
                getEntrustInterval5()
                getAvailableBalance()
            }
        } else {
            leverFragment = false
            isFromOtherPage = true
            subscribeCoin?.dispose()
            WsAgentManager.instance.unbind(this)
        }
    }

    override fun onStop() {
        super.onStop()
        subscribeCoin?.dispose()
        AppAnalyticsExt.instance.activityStop(AppAnalyticsExt.APP_EVENT_LeveragePage)
    }

    var leverFragment = true
    private var isFromOtherPage = false

    override fun onMessageEvent(event: MessageEvent) {
        super.onMessageEvent(event)
        if (MessageEvent.leverTrade_topTab_type == event.msg_type) {
            val msg_content = event.msg_content
            LogUtil.d(TAG, "onMessageEvent==msg_content is ${event.msg_content}")
            if (null != msg_content && msg_content is Bundle) {
                val bundle = event.msg_content as Bundle
                isFromOtherPage = true
                tradeOrientation = bundle.getInt(ParamConstant.transferType)
                val symbol = bundle.getString(ParamConstant.symbol)
                LogUtil.d(TAG, "observeData==symbol is ${symbol}")
                showSymbolSwitchData(symbol)
                setTopBar()
            }
        } else if (MessageEvent.CREATE_ORDER_TYPE == event.msg_type) {
            //Order notification
            val isCreatedOrder = event.msg_content as Boolean
            
            if (isCreatedOrder) {
                if (event.dataIsNotNull()) {
                    val item = event.dataJson
                    curEntrustAdapter.addData(0, item)
                    curEntrustAdapter.notifyDataSetChanged()
                }
                clearToolHttp()
            }
        }else if(MessageEvent.color_rise_fall_type == event.msg_type) {
            val roseRes = ColorUtil.getMainColorBgType(RateManager.getRoseTrend(lastRose) >= 0)
            tv_rose.textColor = roseRes.first
            tv_rose.backgroundResource = roseRes.second
            LogUtil.e("杠杆！！！！！！！1","$")
            val buyOrSellPair = ColorUtil.getBuyOrSellPair(mActivity!!)
            v_tb_bar.setTabSelectColor(buyOrSellPair.first,buyOrSellPair.second)
            v_tb_bar.setSelectPosition(0)
        } else if(MessageEvent.symbol_switch_type == event.msg_type) {
            if (null != event.msg_content) {
                val nSymbol = event.msg_content as String

                setTagView(NCoinManager.getNameForSymbol(nSymbol))
                showSymbolSwitchData(nSymbol)
                setTopBar()
            }
        }
        //Depth
        else if(MessageEvent.DEPTH_LEVEL_TYPE == event.msg_type) {
            if (null != event.msg_content) {
                val level = event.msg_content as Int
                if (curDepthIndex != level) {
                    curDepthIndex = level
                    if (StringUtil.checkStr(symbol)) {
                        WsAgentManager.instance.unbind(this)
                        if (StringUtil.checkStr(symbol)) {
                            WsAgentManager.instance.sendMessage(hashMapOf("symbol" to symbol, "step" to curDepthIndex.toString()), this)
                        }
                    }

                }
            }
        }
        //Order notification
        else if(MessageEvent.CREATE_ORDER_TYPE == event.msg_type) {
            val isRun = event.msg_content as Boolean
            if (isRun) {
                getEachEntrust()
            }
        }
    }

    private fun clearToolHttp() {
        clearDisposableTrade()
        subscribeCoin?.dispose()
        loopData()
    }

    fun changeInitData() {
        LogUtil.d(TAG, "NCVCTradeFragment==coinMapData changeInitData() is $coinMapData")
        val leverGroup = NCoinManager.getLeverGroup()
        val currentSymbol = PublicInfoDataService.getInstance().currentSymbol4Lever
        if (TextUtils.isEmpty(currentSymbol)) {
            val symbol = leverGroup.getDefaultLeverCoin()
            if (leverGroup==null||NCoinManager.getLeverGroupList(leverGroup[0]) == null) {
                return
            }
            PublicInfoDataService.getInstance().currentSymbol4Lever = symbol
        } else {
            val json = NCoinManager.getMarket4Name(currentSymbol)
            if (json == null) {
                PublicInfoDataService.getInstance().currentSymbol4Lever = leverGroup.getDefaultLeverCoin()
            } else {
                val isOpenLever = json.optString("isOpenLever")
                if ("1" == isOpenLever) {
                    PublicInfoDataService.getInstance().currentSymbol4Lever = json.optString("symbol")
                } else {
                    if (leverGroup != null && leverGroup.size > 0) {
                        val leverGroupList = NCoinManager.getLeverGroupList(leverGroup[0])
                        if (leverGroupList != null && leverGroupList.size > 0) {
                            PublicInfoDataService.getInstance().currentSymbol4Lever = leverGroup.getDefaultLeverCoin()
                        }
                    }
                }
            }
        }
        val tempSymbol = PublicInfoDataService.getInstance().currentSymbol4Lever
        if (TextUtils.isEmpty(tempSymbol)) return

        coinMapData = NCoinManager.getSymbolObj(tempSymbol)
        showTopCoin()
        changeCoinMap()
        LogUtil.d(TAG, "NCVCTradeFragment==coinMapData is $coinMapData")
        symbol = coinMapData?.optString("symbol") ?: ""//return
        setTagView(coinMapData?.optString("name", "").toString())
    }


    private fun showLeftCoinPopup() {
        if (Utils.isFastClick())
            return
        val mCoinSearchDialogFg = CoinSearchDialogFg()
        val bundle = Bundle()
        bundle.putInt(ParamConstant.TYPE, TradeTypeEnum.LEVER_TRADE.value)
        mCoinSearchDialogFg.arguments = bundle
        mCoinSearchDialogFg.showDialog(childFragmentManager, "TradeFragment")
    }

    override fun onResume() {
        super.onResume()
        AppAnalyticsExt.instance.activityStart(AppAnalyticsExt.APP_EVENT_LeveragePage)
    }

    private fun changeCoinMap(){
        if (null != coinMapData) {
            v_horizontal_depth_lever?.coinMapData = coinMapData
            v_vertical_depth_lever?.coinMapData = coinMapData
        }
    }

    override fun onWsMessage(json: String) {
        handleData(json)
    }


}
