package com.yjkj.chainup.new_version.activity.oldgrid

import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.util.Log
import android.view.View
import androidx.recyclerview.widget.LinearLayoutManager
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseFragment
import com.yjkj.chainup.db.constant.CommonConstant
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.extra_service.eventbus.NLiveDataUtil
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.LoginManager
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.net_new.JSONUtil
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_version.activity.NewMainActivity
import com.yjkj.chainup.new_version.activity.oldgrid.adapter.OldAiGridAdapter
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.view.CommonlyUsedButton
import com.yjkj.chainup.new_version.view.EmptyForAdapterView
import com.yjkj.chainup.util.*
import io.reactivex.Observable
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import kotlinx.android.synthetic.main.item_ai_grid_adapter_old.*
import kotlinx.android.synthetic.main.item_ai_grid_adapter_old.gt_division_profits
import kotlinx.android.synthetic.main.item_ai_grid_adapter_old.ll_profit_taking_price_layout
import kotlinx.android.synthetic.main.item_ai_grid_adapter_old.ll_stop_price_layout
import kotlinx.android.synthetic.main.item_ai_grid_adapter_old.ll_volum_layout
import kotlinx.android.synthetic.main.item_ai_grid_adapter_old.recycler_view
import kotlinx.android.synthetic.main.item_ai_grid_adapter_old.switch_fingerprint_pwd
import kotlinx.android.synthetic.main.item_ai_grid_adapter_old.tv_balance_str
import kotlinx.android.synthetic.main.item_ai_grid_adapter_old.tv_history_grid_title
import kotlinx.android.synthetic.main.item_ai_grid_adapter_old.tv_used_btc
import org.jetbrains.anko.support.v4.runOnUiThread
import org.json.JSONObject
import java.util.concurrent.TimeUnit

/**
 * @Author lianshangljl
 * @Date 2023/2/1-5:21 PM
 * @Email buptjinlong@163.com
 * @description
 */
class OldNAIGridFragment : NBaseFragment() {

    var symbol = ""

    var coin = ""
    var base = ""

    /*Seven day yield*/
    var sevenAnnualizedYield = ""

    /*High price range*/
    var highestPrice = ""

    /*Low price range*/
    var lowestPrice = ""

    /*Expected minimum profit margin*/
    var everyProfitMin = ""

    /*Expected maximum profit margin*/
    var everyProfitMax = ""

    /*Number of grids*/
    var gridNumber = ""

    /*Total investment amount*/
    var totalQuoteAmount = ""

    /*Grid type 1: Equal difference 2: Equal ratio*/
    var gridLineType = ""

    /*Do you want to use existing assets 0: Do not use 1: Use*/
    var useOwnBase = "0"

    /*Stop loss price*/
    var stopPrice = ""

    /*Stop profit price*/
    var profitTakingPrice = ""

    /*Minimum order quantity*/
    var minimumOrderQuantity = ""

    /*Handling fees*/
    var makerFee = ""

    /*Current price*/
    var currentPrice = ""

    /*Total investment/grid quantity*/
    var gridAmount = ""

    var oldAiGridAdapter: OldAiGridAdapter? = null

    var list: ArrayList<JSONObject> = arrayListOf()

    override fun initView() {

        getAIStrategyInfo(symbol)
        observeData()
        setOnclick()
        btn_begin_grid?.isEnable(true)
        initAdapter()
        tv_check_full_stop?.text = LanguageUtil.getString(context, "quant_stop_hign_and_low") + LanguageUtil.getString(context, "common_text_optionalinput")
    }

    fun initAdapter() {
        oldAiGridAdapter = OldAiGridAdapter(list, object : OldGridStopStrategyListener {
            override fun stopStrategy(id: String) {
                NewDialogUtils.showNormalDialog(context!!, getString(R.string.quant_alert_stopGrid), object : NewDialogUtils.DialogBottomListener {
                    override fun sendConfirm() {
                        stopStrategyForNetwork(id)
                    }
                }, LanguageUtil.getString(context, "common_text_tip"))
            }

        }, false)
        recycler_view?.layoutManager = LinearLayoutManager(activity)
        oldAiGridAdapter?.setEmptyView(EmptyForAdapterView(activity ?: return))
        recycler_view?.adapter = oldAiGridAdapter
    }


    override fun setContentView() = R.layout.item_ai_grid_adapter_old


    fun setEditFocusable() {
        if (!LoginManager.isLogin(context)) {
            rd_stop_price?.isFocusableInTouchMode = false
            ed_profit_taking_price?.isFocusableInTouchMode = false
            et_investment_assets?.isFocusableInTouchMode = false
        } else {
            if (rd_stop_price?.isFocusableInTouchMode?.not() == true) {
                rd_stop_price?.isFocusable = true
                rd_stop_price?.isFocusableInTouchMode = true
                rd_stop_price?.requestFocus()
                rd_stop_price?.findFocus()
            }
            if (ed_profit_taking_price?.isFocusableInTouchMode?.not() == true) {
                ed_profit_taking_price?.isFocusable = true
                ed_profit_taking_price?.isFocusableInTouchMode = true
                ed_profit_taking_price?.requestFocus()
                ed_profit_taking_price?.findFocus()
            }
            if (et_investment_assets?.isFocusableInTouchMode?.not() == true) {
                et_investment_assets?.isFocusable = true
                et_investment_assets?.isFocusableInTouchMode = true
                et_investment_assets?.requestFocus()
                et_investment_assets?.findFocus()
            }
        }
    }

    fun setOnclick() {
        /**
         *Stop loss price
         */
        rd_stop_price?.setOnClickListener {
            LoginManager.checkLogin(context, true)
        }
        rd_stop_price?.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(s: Editable?) {
                stopPrice = s.toString()
                if (stopPrice.isNotEmpty()) {
                    ll_stop_price_layout?.setBackgroundResource(R.drawable.bg_grid_gray)
                }
            }

            override fun beforeTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {

            }

            override fun onTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {

            }

        })

        /**
         *Stop profit price
         */
        ed_profit_taking_price?.setOnClickListener {
            LoginManager.checkLogin(context, true)
        }

        ed_profit_taking_price?.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(p0: Editable?) {
                profitTakingPrice = p0.toString()
                if (profitTakingPrice.isNotEmpty()) {
                    ll_profit_taking_price_layout?.setBackgroundResource(R.drawable.bg_grid_gray)
                }
            }

            override fun beforeTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {

            }

            override fun onTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {

            }

        })

        /**Input investment assets**/
        et_investment_assets?.setOnClickListener {
            LoginManager.checkLogin(context, true)
        }
        et_investment_assets?.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(p0: Editable?) {
                totalQuoteAmount = p0.toString()
                if (totalQuoteAmount.isNotEmpty()) {
                    ll_volum_layout?.setBackgroundResource(R.drawable.bg_grid_gray)
                }
                changeTotalQuoteAmount()
            }

            override fun beforeTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {

            }

            override fun onTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {

            }

        })

        switch_fingerprint_pwd?.setOnClickListener {
            LoginManager.checkLogin(context, true)
        }
        /**
         *Use existing baseCoin
         */
        switch_fingerprint_pwd?.setOnCheckedChangeListener { compoundButton, b ->
            useOwnBase = if (b) {
                "1"
            } else {
                "0"
            }
            setViewSelect(switch_fingerprint_pwd, useOwnBase == "1")
        }

        /**
         *Historical Grid
         */
        tv_history_grid_title?.setOnClickListener {
            if (LoginManager.checkLogin(context, true)) {
                ArouterUtil.navigation(RoutePath.HistoryGridActivity, Bundle().apply {
                    putString(ParamConstant.COIN_SYMBOL, symbol)
                })
            }

        }


        btn_begin_grid?.listener = object : CommonlyUsedButton.OnBottonListener {
            override fun bottonOnClick() {
                if (LoginManager.checkLogin(context, true)) {
                    Log.e("jinlong", "totalQuoteAmount:$totalQuoteAmount")
                    if (totalQuoteAmount.isEmpty()) {
                        NToastUtil.showTopToast(false, getString(R.string.otc_mustWrite_tex))
                        ll_volum_layout?.setBackgroundResource(R.drawable.bg_grid_red)
                        return
                    }

                    if (BigDecimalUtils.compareTo(everyProfitMin, "0") <= 0 || BigDecimalUtils.compareTo(everyProfitMax, "0") <= 0) {
                        NToastUtil.showTopToast(false, getString(R.string.profit_per_grid_small))
                        return
                    }

                    if (BigDecimalUtils.compareTo(totalCoinAmount, totalQuoteAmount) < 0) {
                        NToastUtil.showTopToast(false, "${NCoinManager.getShowMarket(totalBaseCoin)} ${LanguageUtil.getString(context, "common_tip_balanceNotEnough")}")
                        ll_volum_layout?.setBackgroundResource(R.drawable.bg_grid_red)
                        return
                    }

                    Log.e("jinlong", "gridAmount:$gridAmount")
                    Log.e("jinlong", "minimumOrderQuantity:$minimumOrderQuantity")
                    Log.e("jinlong", "11111:${BigDecimalUtils.compareTo(gridAmount, minimumOrderQuantity)}")
                    if (BigDecimalUtils.compareTo(gridAmount, minimumOrderQuantity) < 0) {
                        ll_volum_layout?.setBackgroundResource(R.drawable.bg_grid_red)
                        NToastUtil.showTopToast(false, getString(R.string.minimum_current_currency_pair))
                        return
                    }


                    if (stopPrice.isNotEmpty() && BigDecimalUtils.compareTo(stopPrice, lowestPrice) >= 0) {
                        NToastUtil.showTopToast(false, getString(R.string.quant_stop_low_error))
                        ll_stop_price_layout?.setBackgroundResource(R.drawable.bg_grid_red)
                        return
                    }

                    if (stopPrice.isNotEmpty() && BigDecimalUtils.compareTo(stopPrice, currentPrice) >= 0) {
                        NToastUtil.showTopToast(false, getString(R.string.stop_loss_price_price))
                        ll_stop_price_layout?.setBackgroundResource(R.drawable.bg_grid_red)
                        return
                    }


                    if (profitTakingPrice.isNotEmpty() && BigDecimalUtils.compareTo(profitTakingPrice, highestPrice) <= 0) {
                        NToastUtil.showTopToast(false, getString(R.string.quant_stop_high_error))
                        ll_profit_taking_price_layout?.setBackgroundResource(R.drawable.bg_grid_red)
                        return
                    }
                    if (profitTakingPrice.isNotEmpty() && BigDecimalUtils.compareTo(profitTakingPrice, currentPrice) <= 0) {
                        NToastUtil.showTopToast(false, getString(R.string.loss_price_higher_current_price))
                        ll_profit_taking_price_layout?.setBackgroundResource(R.drawable.bg_grid_red)
                        return
                    }
                    if (useOwnBase == "1") {
                        calBaseAmount(symbol, lowestPrice, highestPrice, gridNumber, gridLineType, totalQuoteAmount, currentPrice, makerFee)
                    } else {
                        saveStrategy(symbol, "1", gridLineType, gridNumber, lowestPrice, highestPrice, profitTakingPrice, stopPrice, totalQuoteAmount, useOwnBase, makerFee, "0")
                    }
                }

            }
        }
    }

    fun setEditPrice() {
        var name = NCoinManager.getMarket4Name((base + coin).toLowerCase())
        var prico = name.optInt("price")
        rd_stop_price?.filters = arrayOf(DecimalDigitsInputFilter(prico))
        et_investment_assets?.filters = arrayOf(DecimalDigitsInputFilter(prico))
        ed_profit_taking_price?.filters = arrayOf(DecimalDigitsInputFilter(prico))
    }


    private fun observeData() {
        NLiveDataUtil.observeForeverData {
            if (null == it || !it.isGrid) {
                return@observeForeverData
            }
            when (it.msg_type) {
                //Switch Currency Event
                MessageEvent.symbol_switch_type -> {
                    if (null != it.msg_content) {
                        var coinSymbol = it.msg_content as String
                        symbol = NCoinManager.getNameForSymbol(coinSymbol)
                        getAIStrategyInfo(symbol)
                        getStrategyList(symbol)
                        clearView()
                    }
                }
            }
        }
    }


    override fun onMessageEvent(event: MessageEvent) {
        super.onMessageEvent(event)
        if (MessageEvent.symbol_switch_type == event?.msg_type) {
            if (null != event.msg_content) {
                var coinSymbol = event.msg_content as String
                symbol = NCoinManager.getNameForSymbol(coinSymbol)
                getAIStrategyInfo(symbol)
                getStrategyList(symbol)
                clearView()
            }
        }
    }

    fun changeTotalQuoteAmount() {
        gridAmount = BigDecimalUtils.div(totalQuoteAmount, gridNumber).toPlainString()
    }

    fun setViewSelect(view: View, status: Boolean) {
        if (status) {
            view.setBackgroundResource(R.drawable.open)
        } else {
            view.setBackgroundResource(R.drawable.shut_down)
        }
    }

    /**
     *Save Policy
     *@param symbol currency to BTC/USDT
     *@param quantType Quantitative Transaction Type 1: Grid
     *@param gridLineType Grid Type 1: Equal Difference 2: Equal Ratio
     *@param gridNumber Number of grids
     *@param lowestPrice grid lower limit
     *@param highestPrice grid upper limit
     *@param stopHighPrice Stop grid upper limit
     *@param stopLowPrice Stop grid lower limit
     *@param totalQuoteAmount User Input Assets
     *@param useOwnBase: Use Base asset 0: Do not use 1: Use
     * @return
     */
    fun saveStrategy(symbol: String, quantType: String, gridLineType: String, gridNumber: String,
                     lowestPrice: String, highestPrice: String, stopHighPrice: String, stopLowPrice: String,
                     totalQuoteAmount: String, useOwnBase: String, fee: String, totalBaseAmount: String) {
        addDisposable(getMainModel().saveStrategy(symbol, quantType, gridLineType, gridNumber,
                lowestPrice, highestPrice, stopHighPrice, stopLowPrice, totalQuoteAmount, useOwnBase, fee, totalBaseAmount, object : NDisposableObserver() {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                clearView()
                NToastUtil.showTopToastNet(activity, true, LanguageUtil.getString(context, "grid_check_execution"))
                getStrategyList(symbol)
            }

            override fun onResponseFailure(code: Int, msg: String?) {
                super.onResponseFailure(code, msg)
                NToastUtil.showTopToastNet(activity, false, msg)
            }

        }))
    }

    fun clearView() {
        et_investment_assets?.setText("")
        rd_stop_price?.setText("")
        ed_profit_taking_price?.setText("")

        ll_volum_layout?.setBackgroundResource(R.drawable.bg_grid_gray)
        ll_profit_taking_price_layout?.setBackgroundResource(R.drawable.bg_grid_gray)
        ll_stop_price_layout?.setBackgroundResource(R.drawable.bg_grid_gray)
    }

    /**
     *Calculate the total assets invested using base
     *@param symbol currency to BTC/USDT
     *@param gridLineType Grid Type 1: Equal Difference 2: Equal Ratio
     *@param gridNumber Number of grids
     *@param lowestPrice grid lower limit
     *@param highestPrice grid upper limit
     *@param totalQuoteAmount User Input Assets
     *@param currentPrice Current price
     * @return
     */
    fun calBaseAmount(symbol: String, lowestPrice: String, highestPrice: String, gridNumber: String, gridLineType: String,
                      totalQuoteAmount: String, currentPrice: String, fee: String) {
        addDisposable(getMainModel().calBaseAmount(symbol, lowestPrice, highestPrice, gridNumber, gridLineType, totalQuoteAmount, currentPrice, fee, object : NDisposableObserver() {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                var json = jsonObject.optJSONObject("data")
                var baseAmount = json.optString("baseAmount")
                if (BigDecimalUtils.compareTo(baseAmount4Newwork, baseAmount) >= 0) {
                    totalBaseAmount = baseAmount
                    saveStrategy(symbol, "1", gridLineType, gridNumber, lowestPrice, highestPrice, profitTakingPrice, stopPrice, totalQuoteAmount, useOwnBase, makerFee, totalBaseAmount)
                } else {
                    NToastUtil.showTopToast(false, getString(R.string.grid_need_least) + " " + baseAmount + NCoinManager.getShowMarket(base))
                }
            }

            override fun onResponseFailure(code: Int, msg: String?) {
                super.onResponseFailure(code, msg)
                NToastUtil.showTopToastNet(activity, false, msg)
            }
        }))
    }


    fun getAIStrategyInfo(symbol: String = "") {
        runOnUiThread {
            base = symbol.split("/")[0]
            coin = symbol.split("/")[1]
            tv_used_btc?.text = "${LanguageUtil.getString(context, "quant_use_own_base")} ${NCoinManager.getShowMarket(base)}"
            setEditPrice()
            tv_coin_name?.text = NCoinManager.getShowMarket(coin)
            st_stop_price?.text = NCoinManager.getShowMarket(coin)
            stv_profit_taking_price?.text = NCoinManager.getShowMarket(coin)
            if (!UserDataService.getInstance().isLogined) {
                tv_balance_str?.text = "--${NCoinManager.getShowMarket(coin)} --${NCoinManager.getShowMarket(base)}"
            }
        }

        addDisposable(getMainModel().getAIStrategyInfo(symbol, object : NDisposableObserver() {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                var json = jsonObject.optJSONObject("data") ?: return


                /*Seven day yield*/
                sevenAnnualizedYield = json.optString("sevenAnnualizedYield") ?: ""

                /*Expected minimum profit margin*/
                everyProfitMin = json.optString("everyProfitMin") ?: ""
                /*Handling fees*/
                makerFee = json.optString("makerFee") ?: ""

                /*Expected maximum profit margin*/
                everyProfitMax = json.optString("everyProfitMax") ?: ""

                /*Minimum order quantity*/
                minimumOrderQuantity = json.optString("minimumOrderQuantity") ?: ""

                /*Specific configuration of strategies*/
                var configParamMap = json.optJSONObject("configParamMap")
                /*High price range*/
                highestPrice = configParamMap?.optString("highestPrice") ?: ""
                /*Low price range*/
                lowestPrice = configParamMap?.optString("lowestPrice") ?: ""


                /*Number of grids*/
                gridNumber = configParamMap?.optString("gridNumber") ?: ""

                /*Grid type 1: Equal difference 2: Equal ratio*/
                gridLineType = configParamMap?.optString("gridLineType") ?: ""

                /*Do you want to use existing assets 0: Do not use 1: Use*/
                useOwnBase = configParamMap?.optString("useOwnBase") ?: ""
                switch_fingerprint_pwd?.isChecked = useOwnBase == "1"
                setViewSelect(switch_fingerprint_pwd, useOwnBase == "1")
                var name = NCoinManager.getMarket4Name((base + coin).toLowerCase())
                var prico = name.optInt("price")
                runOnUiThread {
                    /*Seven day yield*/
                    gt_annual_earnings?.setContentText("${BigDecimalUtils.divForDown(sevenAnnualizedYield, 2)} %")
                    gt_annual_earnings?.setContentSize()
                    /*Price range*/
                    gt_price_interval?.setContentTextInterval("${BigDecimalUtils.divForDown(lowestPrice, prico)} ~ ${BigDecimalUtils.divForDown(highestPrice, prico)}")
                    /*Number of grids*/
                    gt_network_num?.setContentTextInterval("$gridNumber")
                    /*Revenue per grid*/
                    gt_division_profits?.setContentTextInterval("$everyProfitMin%~$everyProfitMax%(${LanguageUtil.getString(context, "trading_fee_deducted")})")

                }
            }
        }))
    }


    override fun fragmentVisibile(isVisibleToUser: Boolean) {
        super.fragmentVisibile(isVisibleToUser)
        val mainActivity = activity
        if (mainActivity != null) {
            if (mainActivity is NewMainActivity) {
                if (isVisibleToUser && mainActivity.curPosition == 2) {
                    getAIStrategyInfo(symbol)
                    setButtonStatus()
                    clearView()
                    list.clear()
                    oldAiGridAdapter?.setList(list)
                    loopData()
                    setEditFocusable()
                } else {
                    subscribeCoin?.dispose()
                }
            }
        }
    }

    /**
     *Get executing list
     */
    fun getStrategyList(symbol: String = "") {
        if (UserDataService.getInstance().isLogined) {
            addDisposable(getMainModel().getStrategyList(symbol, "1", "1", "100", object : NDisposableObserver() {
                override fun onResponseSuccess(jsonObject: JSONObject) {
                    var json = jsonObject.optJSONObject("data")
                    var strategyVoList = json.optJSONArray("strategyVoList") ?: return
                    var listNew = JSONUtil.arrayToList(strategyVoList) ?: arrayListOf()
                    list.clear()
                    list.addAll(listNew)
                    oldAiGridAdapter?.setList(list)
                }
            }))
        }
    }


    /**
     *Stop Policy
     */
    fun stopStrategyForNetwork(id: String) {
        addDisposable(getMainModel().stopStrategy(id, object : NDisposableObserver() {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                getStrategyList(symbol)
            }

            override fun onResponseFailure(code: Int, msg: String?) {
                super.onResponseFailure(code, msg)
                NToastUtil.showTopToastNet(activity, false, msg)
            }
        }))
    }

    fun setButtonStatus() {
        if (UserDataService.getInstance().isLogined) {
            btn_begin_grid?.setContent(LanguageUtil.getString(context, "quant_start_trade"))
        } else {
            btn_begin_grid?.setContent(getString(R.string.login_action_login))

        }
    }

    var totalBaseAmount = "0"
    var baseAmount4Newwork = "0"
    var totalCoinAmount = "0"
    var totalBaseCoin = ""
    fun setAccountBalance(base: String, baseBalance: String, coin: String, coinBalance: String) {
        totalBaseAmount = baseBalance
        baseAmount4Newwork = baseBalance
        totalCoinAmount = coinBalance
        totalBaseCoin = coin
        var name = NCoinManager.getMarket4Name((base + coin).toLowerCase())
        var pricePrecision = name.optInt("price")
        var volumePrecision = name.optInt("volume")

        tv_balance_str?.text = "${BigDecimalUtils.divForDown(coinBalance, pricePrecision).toPlainString()}${NCoinManager.getShowMarket(coin)} ${BigDecimalUtils.divForDown(baseBalance, volumePrecision).toPlainString()}${NCoinManager.getShowMarket(base)}"
    }

    private var cvcFragment = true
    var subscribeCoin: Disposable? = null//Save subscribers

    override fun background() {
        super.background()
        cvcFragment = false
    }

    override fun foreground() {
        super.foreground()
        cvcFragment = true
    }

    private fun loopData(status: Boolean = true) {
        LogUtil.e(TAG, "ETF value loopData  $mIsVisibleToUser $cvcFragment")

        if (!mIsVisibleToUser || !cvcFragment)
            return
        if (subscribeCoin == null || (subscribeCoin != null && subscribeCoin?.isDisposed != null && subscribeCoin?.isDisposed!!)) {
            subscribeCoin = Observable.interval(0L, CommonConstant.etfLoopTime, TimeUnit.SECONDS)//Sending Observeable integers at time intervals
                    .observeOn(AndroidSchedulers.mainThread())//Switch to the main thread to modify the UI
                    .subscribe {
                        if (!UserDataService.getInstance().isLogined) return@subscribe
                        getStrategyList(symbol)
                    }
        }
    }

    override fun onStop() {
        super.onStop()
        subscribeCoin?.dispose()
    }


}
