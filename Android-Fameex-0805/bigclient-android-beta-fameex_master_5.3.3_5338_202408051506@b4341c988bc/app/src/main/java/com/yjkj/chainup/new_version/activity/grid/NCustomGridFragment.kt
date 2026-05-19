package com.yjkj.chainup.new_version.activity.grid

import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.util.Log
import android.view.View
import android.widget.Switch
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.LinearLayoutManager
import com.chainup.kit.KKDialogUtils
import com.chainup.kit.utils.PublicSizeUtil
import com.chainup.kit.views.KKEmptyViewKit
import com.chainup.kit.views.SwitchButtonView
import com.chainup.kit.views.base.BaseEditTextKit
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseFragment
import com.yjkj.chainup.db.constant.CommonConstant
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.extra_service.eventbus.EventBusUtil
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.extra_service.eventbus.NLiveDataUtil
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.LoginManager
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.net_new.JSONUtil
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_version.activity.NewMainActivity
import com.yjkj.chainup.new_version.activity.grid.adapter.AiGridAdapter
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.view.CommonlyUsedButton
import com.yjkj.chainup.new_version.view.EmptyForAdapterView
import com.yjkj.chainup.util.*
import io.reactivex.Observable
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import kotlinx.android.synthetic.main.item_custom_grid_adapter.*
import kotlinx.android.synthetic.main.item_grid_tips_profit.*
import kotlinx.android.synthetic.main.trade_grid_history_tools.*
import org.jetbrains.anko.support.v4.runOnUiThread
import org.jetbrains.anko.textColor
import org.json.JSONObject
import java.util.concurrent.TimeUnit
import kotlin.math.max

/**
 * @Author lianshangljl
 * @Date 2023/2/1-5:23 PM
 * @Email buptjinlong@163.com
 * @description
 */
class NCustomGridFragment : NBaseFragment() {

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
    var gridLineType = "1"

    /*Do you want to use existing assets 0: Do not use 1: Use*/
    var useOwnBase = "0"

    /*Stop loss price*/
    var stopPrice = ""

    /*Stop profit price*/
    var profitTakingPrice = ""

    /*Minimum order quantity*/
    var minimumOrderQuantity = ""

    /*Handling fees*/
    var makerFee = "0"

    /*Current price*/
    var currentPrice = ""

    /*Number of grids*/
    var gridAmount = ""

    var list: ArrayList<JSONObject> = arrayListOf()

    var minPriceNumber = "0"

    /*Lattice number*/
    var minGridNumber = "0"

    var everyGridLimitMin = "0"

    override fun initView() {
        isCheck = tv_history_grid_current?.isChecked ?: true
        getAIStrategyInfo(symbol)
        setOnclick()
        observeData()
        initAdapter()
        btn_begin_grid_custom?.isEnable(true)
        tv_check_full_stop?.text = LanguageUtil.getString(context, "quant_stop_hign_and_low") + LanguageUtil.getString(context, "common_text_optionalinput")
        setTextContent()
    }
    fun setTextContent() {
        tv_custom_price_range_title?.setText(LanguageUtil.getString(context, "quant_price_section") )
        tv_grid_number_title?.setText(LanguageUtil.getString(context, "quant_grid_amount") )
        tv_arithmetic_grid?.setText(LanguageUtil.getString(context, "quant_grid_line_type1") )
        tv_geometric_grid?.setText(LanguageUtil.getString(context, "quant_grid_line_type2"))
//        tv_history_grid_title?.setText(LanguageUtil.getString(context, "asset_lever_history") )
        tv_investment_assets?.setText(LanguageUtil.getString(context, "quant_quote_amount") )
        tv_available?.setText(LanguageUtil.getString(context, "cl_available_balance_str") )
        rd_check_surplus?.hint=(LanguageUtil.getString(context, "quant_low_price"))
        ed_stop_loss?.hint=(LanguageUtil.getString(context, "quant_high_price"))
        rd_check_surplus_check_full?.hint=(LanguageUtil.getString(context, "quant_stop_low_price"))
        ed_stop_loss_check_full?.hint=(LanguageUtil.getString(context, "quant_stop_high_price"))
        et_volume_investment?.hint=(LanguageUtil.getString(context, "cl_volume_str"))
        gt_division_profits?.setTitleContent(LanguageUtil.getString(context, "quant_every_profit"))

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
                MessageEvent.login_operation_type ->{
                    if (!UserDataService.getInstance().isLogined) {
                        tv_balance_str?.text = "-- ${NCoinManager.getShowMarket(coin)} -- ${NCoinManager.getShowMarket(base)}"
                    }
                }
            }
        }
    }

    fun setEditFocusable() {
        if (!LoginManager.isLogin(context)) {
            rd_check_surplus?.isFocusableInTouchMode = false
            ed_stop_loss?.isFocusableInTouchMode = false
            ed_custom_grid_num?.isFocusableInTouchMode = false
            et_volume_investment?.isFocusableInTouchMode = false
            rd_check_surplus_check_full?.isFocusableInTouchMode = false
            ed_stop_loss_check_full?.isFocusableInTouchMode = false
        } else {
            if (rd_check_surplus?.isFocusableInTouchMode?.not() == true) {
                rd_check_surplus?.isFocusable = true
                rd_check_surplus?.isFocusableInTouchMode = true
                rd_check_surplus?.requestFocus()
                rd_check_surplus?.findFocus()
            }
            if (ed_stop_loss?.isFocusableInTouchMode?.not() == true) {
                ed_stop_loss?.isFocusable = true
                ed_stop_loss?.isFocusableInTouchMode = true
                ed_stop_loss?.requestFocus()
                ed_stop_loss?.findFocus()
            }
            if (ed_custom_grid_num?.isFocusableInTouchMode?.not() == true) {
                ed_custom_grid_num?.isFocusable = true
                ed_custom_grid_num?.isFocusableInTouchMode = true
                ed_custom_grid_num?.requestFocus()
                ed_custom_grid_num?.findFocus()
            }
            if (et_volume_investment?.isFocusableInTouchMode?.not() == true) {
                et_volume_investment?.isFocusable = true
                et_volume_investment?.isFocusableInTouchMode = true
                et_volume_investment?.requestFocus()
                et_volume_investment?.findFocus()
            }
            if (rd_check_surplus_check_full?.isFocusableInTouchMode?.not() == true) {
                rd_check_surplus_check_full?.isFocusable = true
                rd_check_surplus_check_full?.isFocusableInTouchMode = true
                rd_check_surplus_check_full?.requestFocus()
                rd_check_surplus_check_full?.findFocus()
            }
            if (ed_stop_loss_check_full?.isFocusableInTouchMode?.not() == true) {
                ed_stop_loss_check_full?.isFocusable = true
                ed_stop_loss_check_full?.isFocusableInTouchMode = true
                ed_stop_loss_check_full?.requestFocus()
                ed_stop_loss_check_full?.findFocus()
            }
        }
    }

    fun setOnclick() {

        /**
         *Equidistant network
         */
        tv_arithmetic_grid?.setOnClickListener {
            if (LoginManager.checkLogin(context, true)) {
                if (lowestPrice == "0" || lowestPrice.isEmpty() || highestPrice == "0" || highestPrice.isEmpty() || gridNumber == "0" || gridNumber.isEmpty()) {
                    gt_division_profits?.setContentTextInterval("--% ~ --%(${LanguageUtil.getString(context, "trading_fee_deducted")})")
                }
                gridLineType = "1"
                calculateMaxOrMin()
                tv_arithmetic_grid?.run {
                    textColor = ContextCompat.getColor(context, R.color.text_4)
                    setBackgroundResource(R.drawable.bg_grid)
                }
                tv_geometric_grid?.run {
                    textColor = ContextCompat.getColor(context, R.color.text_1)
                    setBackgroundResource(R.drawable.bg_grid_gray)
                }
            }
        }
        /**
         *Proportional network
         */
        tv_geometric_grid?.setOnClickListener {
            if (LoginManager.checkLogin(context, true)) {

                if (lowestPrice == "0" || lowestPrice.isEmpty() || highestPrice == "0" || highestPrice.isEmpty() || gridNumber == "0" || gridNumber.isEmpty()) {
                    gt_division_profits?.setContentTextInterval("--%(${LanguageUtil.getString(context, "trading_fee_deducted")})")
                }


                gridLineType = "2"
                calculateMaxOrMin()
                tv_arithmetic_grid?.run {
                    textColor = ContextCompat.getColor(context, R.color.text_1)
                    setBackgroundResource(R.drawable.bg_grid_gray)
                }
                tv_geometric_grid?.run {
                    textColor = ContextCompat.getColor(context, R.color.text_4)
                    setBackgroundResource(R.drawable.bg_grid)
                }
            }
        }
        /**
         *Low price range
         */
        rd_check_surplus?.setOnClickListener {
            LoginManager.checkLogin(context, true)
        }
        rd_check_surplus?.listener=object : BaseEditTextKit.OnKKBaseListener{
            override fun textChange(text: String) {
                lowestPrice = text.toString()
                if (lowestPrice.isNotEmpty()) {
                    checkBase()
                }
                calculateMaxOrMin()
            }

        }
        /**
         *High price range
         */
        ed_stop_loss?.setOnClickListener {
            LoginManager.checkLogin(context, true)
        }
        ed_stop_loss?.listener=object : BaseEditTextKit.OnKKBaseListener{
            override fun textChange(text: String) {
                highestPrice = text.toString()
                if (highestPrice.isNotEmpty()) {
                    checkBase()
                }
                calculateMaxOrMin()
            }
        }
        /**
         *Number of grids
         */
        ed_custom_grid_num?.setOnClickListener {
            LoginManager.checkLogin(context, true)
        }

        ed_custom_grid_num?.listener=object : BaseEditTextKit.OnKKBaseListener{
            override fun textChange(text: String) {
                gridNumber = text.toString()
                if (gridNumber.isNotEmpty()) {
                    ed_custom_grid_num?.setBackgroundResource(R.drawable.bg_grid_gray)
                    checkBase()
                }
                calculateMaxOrMin()
            }
            }
        /**
         *Invested assets
         */
        et_volume_investment?.setOnClickListener {
            LoginManager.checkLogin(context, true)
        }
        et_volume_investment?.listener=object : BaseEditTextKit.OnKKBaseListener{
            override fun textChange(text: String) {
                totalQuoteAmount = text.toString()
                if (totalQuoteAmount.isNotEmpty()) {
                    checkBase()
                }
                changeTotalQuoteAmount()
            }
            }
        /**
         *Stop loss price
         */
        rd_check_surplus_check_full?.setOnClickListener {
            LoginManager.checkLogin(context, true)
        }
        rd_check_surplus_check_full?.listener=object : BaseEditTextKit.OnKKBaseListener{
            override fun textChange(text: String) {
                stopPrice = text.toString()

            }
            }
        /**
         *Stop profit price
         */
        ed_stop_loss_check_full?.setOnClickListener {
            LoginManager.checkLogin(context, true)
        }
        ed_stop_loss_check_full?.listener=object : BaseEditTextKit.OnKKBaseListener{
            override fun textChange(text: String) {
                profitTakingPrice = text.toString()
            }
        }

        tv_history_grid_title?.setOnClickListener {
            if (LoginManager.checkLogin(context, true)) {
                ArouterUtil.navigation(RoutePath.HistoryGridActivity, Bundle().apply {
                    putString(ParamConstant.COIN_SYMBOL, symbol)
                })
            }
        }
        /**
         *Save Policy
         */
        btn_begin_grid_custom?.listener = object : CommonlyUsedButton.OnBottonListener {
            override fun bottonOnClick() {
                if (LoginManager.checkLogin(context, true)) {
                    val isSubmit = isSubmit()
                    if (!isSubmit) {
                        return
                    }

                    if(BigDecimalUtils.compareTo(highestPrice, lowestPrice) == -1){
                        NToastUtil.showTopToastNet(mActivity, false, "quant_grid_price_check".tr(mActivity!!))
//                        ll_stop_loss_layout?.setBackgroundResource(R.drawable.bg_grid_red)
//                        ll_check_surplus_layout?.setBackgroundResource(R.drawable.bg_grid_red)
                        return
                    }

                    if (BigDecimalUtils.compareTo(highestPrice, BigDecimalUtils.mul(lowestPrice, "1.02").toPlainString()) < 0) {
                        NToastUtil.showTopToastNet(mActivity, false, getString(R.string.price_range_smal))
//                        ll_stop_loss_layout?.setBackgroundResource(R.drawable.bg_grid_red)
//                        ll_check_surplus_layout?.setBackgroundResource(R.drawable.bg_grid_red)
                        return
                    }

                    if (currentPrice.isNotEmpty() && BigDecimalUtils.compareTo(lowestPrice, currentPrice, pricePrecision) == 1) {
                        NToastUtil.showTopToastNet(mActivity, false, getString(R.string.quant_grid_closeLessThanLow))
                        return
                    }
                    if (currentPrice.isNotEmpty() && BigDecimalUtils.compareTo(highestPrice, currentPrice, pricePrecision) == -1) {
                        NToastUtil.showTopToastNet(mActivity, false, getString(R.string.quant_grid_closeGreaterThanHigh))
                        return
                    }

                    if (BigDecimalUtils.compareTo(gridNumber, "2") < 0 || BigDecimalUtils.compareTo(gridNumber, "100") > 0) {
//                        ed_custom_grid_num?.setBackgroundResource(R.drawable.bg_grid_red)
                        NToastUtil.showTopToastNet(mActivity, false, getString(R.string.grid_range_number))
                        return
                    }

                    if (BigDecimalUtils.compareTo(everyProfitMin, "0") <= 0 || BigDecimalUtils.compareTo(everyProfitMax, "0") <= 0) {
                        NToastUtil.showTopToastNet(mActivity, false, getString(R.string.profit_per_grid_small))
                        return
                    }


                    if (BigDecimalUtils.compareTo(totalCoinAmount, totalQuoteAmount) < 0) {
                        NToastUtil.showTopToastNet(mActivity, false, "${NCoinManager.getShowMarket(totalBaseCoin)} ${LanguageUtil.getString(context, "common_tip_balanceNotEnough")}")
//                        ll_volum_layout?.setBackgroundResource(R.drawable.bg_grid_red)
                        return
                    }
                    if (BigDecimalUtils.compareTo(gridAmount, minimumOrderQuantity) < 0) {
//                        ll_volum_layout?.setBackgroundResource(R.drawable.bg_grid_red)
                        NToastUtil.showTopToastNet(mActivity, false, getString(R.string.minimum_current_currency_pair))
                        return
                    }

                    if (stopPrice.isNotEmpty() && BigDecimalUtils.compareTo(stopPrice, lowestPrice) >= 0) {
                        NToastUtil.showTopToastNet(mActivity, false, getString(R.string.quant_stop_low_error))
//                        ll_stop_price_layout?.setBackgroundResource(R.drawable.bg_grid_red)
                        return
                    }

                    if (stopPrice.isNotEmpty() && BigDecimalUtils.compareTo(stopPrice, currentPrice) >= 0) {
                        NToastUtil.showTopToastNet(mActivity, false, getString(R.string.stop_loss_price_price))
//                        ll_stop_price_layout?.setBackgroundResource(R.drawable.bg_grid_red)
                        return
                    }

                    if (profitTakingPrice.isNotEmpty() && BigDecimalUtils.compareTo(profitTakingPrice, highestPrice) <= 0) {
                        NToastUtil.showTopToastNet(mActivity, false, getString(R.string.quant_stop_high_error))
//                        ll_profit_taking_price_layout?.setBackgroundResource(R.drawable.bg_grid_red)
                        return
                    }

                    if (profitTakingPrice.isNotEmpty() && BigDecimalUtils.compareTo(profitTakingPrice, currentPrice) <= 0) {
                        NToastUtil.showTopToastNet(mActivity, false, getString(R.string.loss_price_higher_current_price))
//                        ll_profit_taking_price_layout?.setBackgroundResource(R.drawable.bg_grid_red)
                        return
                    }
//                    val number = (gridNumber.toInt() - 1).toString()
//                    val gridNumLast = max(minPriceNumber.toFloat(), BigDecimalUtils.mul(everyGridLimitMin, number, pricePrecision).toFloat())
//                    val isMinNumber = BigDecimalUtils.compareTo(totalQuoteAmount, gridNumLast.toString()) <= 0
//                    if (isMinNumber) {
//                        ll_volum_layout?.setBackgroundResource(R.drawable.bg_grid_red)
//                        NToastUtil.showTopToastNet(mActivity, false, LanguageUtil.getString(context, "quant_limitInvestment_error").format("${gridNumLast.getTradeCoinPrice(pricePrecision)} ${tv_coin_name_investment?.text}"))
//                        return
//                    }
                    var totalPriceTemp = totalBaseAmount
                    if (useOwnBase == "1") {
                        if (BigDecimalUtils.compareTo(totalBaseAmount, totalBaseAmountTemp) >= 0) {
                            totalPriceTemp = totalBaseAmountTemp
                        } else {
                            NToastUtil.showTopToastNet(mActivity, false, getString(R.string.grid_need_least) + " " + totalBaseAmountTemp + NCoinManager.getShowMarket(base))
                            return
                        }
                    }
                    val totalPrice = if (useOwnBase == "1") totalPriceTemp else "0"
                    saveStrategy(symbol, "1", gridLineType, gridNumber, lowestPrice, highestPrice, profitTakingPrice, stopPrice, totalQuoteAmount, useOwnBase, makerFee, totalPrice)

//                    if (useOwnBase == "1") {
//                        calBaseAmount(symbol, lowestPrice, highestPrice, gridNumber, gridLineType, totalQuoteAmount, currentPrice, makerFee)
//                    } else {
//                        saveStrategy(symbol, "1", gridLineType, gridNumber, lowestPrice, highestPrice, profitTakingPrice, stopPrice, totalQuoteAmount, useOwnBase, makerFee, "0")
//                    }
                }
            }
        }
        /**
         *Use existing baseCoin
         */
        switch_fingerprint_pwd?.listener=object : SwitchButtonView.OnKKSwitchListener{
            override fun onSwitch(b: Boolean) {
                Log.e("jinlong", "b:$b")
                if (!LoginManager.checkLogin(context, true) && b){
                    switch_fingerprint_pwd?.setSwitchStatus(false)
                    return
                }
                val isSubmit = isSubmit()
                if (!isSubmit && b) {
                    switch_fingerprint_pwd?.setSwitchStatus(false)
                    return
                }
                if (BigDecimalUtils.compareTo(highestPrice, BigDecimalUtils.mul(lowestPrice, "1.02").toPlainString()) < 0) {
                    NToastUtil.showTopToastNet(mActivity, false, getString(R.string.price_range_smal))
//                    ll_stop_loss_layout?.setBackgroundResource(R.drawable.bg_grid_red)
//                    ll_check_surplus_layout?.setBackgroundResource(R.drawable.bg_grid_red)
                    switch_fingerprint_pwd?.setSwitchStatus(false)
                }else{
                    useOwnBase = if (b) {
                        "1"
                    } else {
                        "0"
                    }
                    if (b) {
                        checkBase()
                    } else {
                        changeUsed(useOwnBase)
                    }
                    switch_fingerprint_pwd?.setSwitchStatus(useOwnBase == "1")
                }
            }
            }

        ll_profit_item?.setOnClickListener {
            KKDialogUtils.showOneBtnDialogTitle(
                mActivity!!,
                content = LanguageUtil.getString(context, "quant_stopLossProfit_tip").replace("\\n","\n"),
                confrimTitle = LanguageUtil.getString(context, "alert_common_iknow"),
                mTitle = LanguageUtil.getString(context, "coAgent_text_explain")
            )
//            NewDialogUtils.showSingleDialog(context!!, LanguageUtil.getString(context, "quant_stopLossProfit_tip"), null,
//                    LanguageUtil.getString(context, "coAgent_text_explain"), LanguageUtil.getString(context, "alert_common_iknow"), false)
        }

        tv_history_grid_current?.setOnClickListener {
            isCheck = !isCheck
            tv_history_grid_current.isChecked = isCheck
            val message = MessageEvent(MessageEvent.grid_changeHide_coin)
            message.msg_content =  tagGrid
            message.msg_content_data = isCheck
            EventBusUtil.post(message)
            getStrategyList(symbol)
        }
    }

    var isCheck = false
    fun setViewSelect(view: Switch, status: Boolean) {
        view.isChecked = status
//        if (status) {
//            view.setBackgroundResource(R.drawable.open)
//        } else {
//            view.setBackgroundResource(R.drawable.shut_down)
//        }
    }

    fun setEditPrice() {
        var name = NCoinManager.getMarket4Name((base + coin).toLowerCase())
        var prico = name.optInt("price")
        rd_check_surplus?.getRealEditText()?.filters = arrayOf(DecimalDigitsInputFilter(prico))
        ed_stop_loss?.getRealEditText()?.filters = arrayOf(DecimalDigitsInputFilter(prico))
        et_volume_investment?.getRealEditText()?.filters = arrayOf(DecimalDigitsInputFilter(prico))
        rd_check_surplus_check_full?.getRealEditText()?.filters = arrayOf(DecimalDigitsInputFilter(prico))
        ed_stop_loss_check_full?.getRealEditText()?.filters = arrayOf(DecimalDigitsInputFilter(prico))
    }

    fun getAIStrategyInfo(symbol: String = "") {
        runOnUiThread {
            if (symbol.isNotEmpty()) {
                base = symbol.split("/")[0]
                coin = symbol.split("/")[1]
                tv_used_btc?.text = "${LanguageUtil.getString(context, "quant_use_own_base")} ${NCoinManager.getShowMarket(base)}"
                setEditPrice()
//                rd_check_surplus?.action1=NCoinManager.getShowMarket(coin)
//                ed_stop_loss?.action1=NCoinManager.getShowMarket(coin)
                et_volume_investment?.action1 = NCoinManager.getShowMarket(coin)
                rd_check_surplus_check_full?.action1 = NCoinManager.getShowMarket(coin)
                ed_stop_loss_check_full?.action1 = NCoinManager.getShowMarket(coin)
                if (!UserDataService.getInstance().isLogined) {
                    tv_balance_str?.text = "-- ${NCoinManager.getShowMarket(coin)} -- ${NCoinManager.getShowMarket(base)}"
                }
                setDivisionProfits()
            }
        }
        addDisposable(getMainModel().getAIStrategyInfo(symbol, object : NDisposableObserver() {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                var json = jsonObject.optJSONObject("data") ?: return
                /*Handling fees*/
                makerFee = json.optString("makerFee")
                makerFee = BigDecimalUtils.showSNormal(makerFee)
                /*Minimum order quantity*/
                minimumOrderQuantity = json.optString("minimumOrderQuantity")

                minPriceNumber = json.optString("limitTotalMin")
                everyGridLimitMin = json.optString("everyGridLimitMin")
                /*Specific configuration of strategies*/
                val configParamMap = json.optJSONObject("configParamMap")
                if (configParamMap != null) {
                    minGridNumber = configParamMap.optString("gridNumber")
                }
            }
        }))
    }

    fun setDivisionProfits() {
        when (gridLineType) {
            "1" -> {
                gt_division_profits?.setContentTextInterval("--% ~ --%(${LanguageUtil.getString(context, "trading_fee_deducted")})")
            }
            "2" -> {
                gt_division_profits?.setContentTextInterval("--%(${LanguageUtil.getString(context, "trading_fee_deducted")})")
            }
        }
    }


    fun calculateMaxOrMin() {
        if (updateIsEmpty(highestPrice) || updateIsEmpty(lowestPrice) || updateIsEmpty(gridNumber)) {
            setDivisionProfits()
            return
        }
        when (gridLineType) {
            "1" -> {
                var poor = BigDecimalUtils.sub(highestPrice, lowestPrice).toPlainString()
                var division = BigDecimalUtils.div(poor, BigDecimalUtils.sub(gridNumber, "1").toPlainString()).toPlainString()
                var geometricDivMax = BigDecimalUtils.div(division, lowestPrice).toPlainString()
                var geometricDivMin = BigDecimalUtils.div(division, BigDecimalUtils.sub(highestPrice, division).toPlainString()).toPlainString()
                var max = BigDecimalUtils.sub(geometricDivMax, BigDecimalUtils.mul(makerFee, "2").toPlainString()).toPlainString()
                everyProfitMax = BigDecimalUtils.mulStr(max, "100", 2)
                var min = BigDecimalUtils.sub(geometricDivMin, BigDecimalUtils.mul(makerFee, "2").toPlainString()).toPlainString()
                everyProfitMin = BigDecimalUtils.mulStr(min, "100", 2)
                gt_division_profits?.setContentTextInterval("$everyProfitMin% ~ $everyProfitMax%(${LanguageUtil.getString(context, "trading_fee_deducted")})")

            }
            "2" -> {
                var division = BigDecimalUtils.div(highestPrice, lowestPrice).toPlainString()
                var gridNum = BigDecimalUtils.sub(gridNumber, "1").toDouble()
                var prescribing = Math.pow(division.toDouble(), BigDecimalUtils.div("1", gridNum.toString()).toDouble()).toString()
                var max = BigDecimalUtils.sub(prescribing, BigDecimalUtils.mul(makerFee, "2").toPlainString()).toPlainString()
                var max2 = BigDecimalUtils.sub(max, "1").toPlainString()
                everyProfitMax = BigDecimalUtils.mulStr(max2, "100", 2)
                everyProfitMin = everyProfitMax
                gt_division_profits?.setContentTextInterval("$everyProfitMax%(${LanguageUtil.getString(context, "trading_fee_deducted")})")
            }
        }
    }


    fun updateIsEmpty(temp: String): Boolean {
        if (temp.isEmpty() || temp == "0") {
            return true
        }
        return false
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
        rd_check_surplus?.getRealEditText()?.setText("")
        ed_stop_loss?.getRealEditText()?.setText("")
        ed_custom_grid_num?.getRealEditText()?.setText("")
        et_volume_investment?.getRealEditText()?.setText("")
        rd_check_surplus_check_full?.getRealEditText()?.setText("")
        ed_stop_loss_check_full?.getRealEditText()?.setText("")

        switch_fingerprint_pwd?.setSwitchStatus(false)
        totalBaseAmountTemp = "0"
        tv_used_btc?.text = "${LanguageUtil.getString(context, "quant_use_own_base")} ${NCoinManager.getShowMarket(base)}"

//        ll_check_surplus_layout?.setBackgroundResource(R.drawable.bg_grid_gray)
//        ll_stop_loss_layout?.setBackgroundResource(R.drawable.bg_grid_gray)
//        ll_profit_taking_price_layout?.setBackgroundResource(R.drawable.bg_grid_gray)
//        ll_stop_price_layout?.setBackgroundResource(R.drawable.bg_grid_gray)
//        ll_volum_layout?.setBackgroundResource(R.drawable.bg_grid_gray)
//        ed_custom_grid_num?.setBackgroundResource(R.drawable.bg_grid_gray)
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
                totalBaseAmountTemp = baseAmount
                changeUsed(useOwnBase)
            }

            override fun onResponseFailure(code: Int, msg: String?) {
                super.onResponseFailure(code, msg)
                NToastUtil.showTopToastNet(activity, false, msg)
                switch_fingerprint_pwd?.setSwitchStatus(false)
                useOwnBase = if (switch_fingerprint_pwd.getSwitchStatus()) {
                    "1"
                } else {
                    "0"
                }
                switch_fingerprint_pwd?.setSwitchStatus(useOwnBase == "1")
            }
        }))
    }

    override fun setContentView() = R.layout.item_custom_grid_adapter

    var totalBaseAmount = "0"
    var totalCoinAmount = "0"
    var totalBaseCoin = ""
    var totalBaseAmountTemp = "0"
    var pricePrecision = 2
    fun setAccountBalance(base: String, baseBalance: String, coin: String, coinBalance: String) {
        totalBaseAmount = baseBalance
        totalCoinAmount = coinBalance
        totalBaseCoin = coin


        var name = NCoinManager.getMarket4Name((base + coin).toLowerCase())
        pricePrecision = name.optInt("price")
        var volumePrecision = name.optInt("volume")

        tv_balance_str?.text = "${BigDecimalUtils.divForDownV2(coinBalance, pricePrecision)} ${NCoinManager.getShowMarket(coin)} ${BigDecimalUtils.divForDownV2(baseBalance, volumePrecision)} ${NCoinManager.getShowMarket(base)}"
    }

    fun initAdapter() {
        aiGridAdapter = AiGridAdapter(list, object : GridStopStrategyListener {
            override fun stopStrategy(id: String) {
                NewDialogUtils.showNewDoubleDialog(context!!, getString(R.string.quant_alert_stopGrid), object : NewDialogUtils.DialogBottomListener {
                    override fun sendConfirm() {
                        stopStrategyForNetwork(id)
                    }
                }, LanguageUtil.getString(context, "common_text_tip"))
            }

        }, false)
        recycler_view?.layoutManager = LinearLayoutManager(activity)
        aiGridAdapter?.setEmptyView(KKEmptyViewKit(activity ?: return).apply {
            setImageViewTop(32.0f)
        })
        recycler_view?.adapter = aiGridAdapter
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
                    setEditFocusable()
                    if (!UserDataService.getInstance().isLogined) {
                        list.clear()
                        aiGridAdapter?.setList(list)
                        changeCoinTitle()
                    }
                    loopData()
                } else {
                    subscribeCoin?.dispose()
                }

            }
        }
    }

    override fun onStop() {
        super.onStop()
        subscribeCoin?.dispose()
    }


    fun setButtonStatus() {
        if (UserDataService.getInstance().isLogined) {
            btn_begin_grid_custom?.setContent(LanguageUtil.getString(context,"quant_start_trade"))
        } else {
            btn_begin_grid_custom?.setContent(LanguageUtil.getString(context,"login_action_login"))
        }
    }

    var aiGridAdapter: AiGridAdapter? = null

    /**
     *Get executing list
     */
    fun getStrategyList(symbol: String = "") {
        if (UserDataService.getInstance().isLogined) {
            addDisposable(getMainModel().getStrategyList(tv_history_grid_current.isChecked, symbol, "1", "1", "100", object : NDisposableObserver() {
                override fun onResponseSuccess(jsonObject: JSONObject) {
                    var json = jsonObject.optJSONObject("data")
                    var strategyVoList = json.optJSONArray("strategyVoList") ?: return
                    var listNew = JSONUtil.arrayToList(strategyVoList) ?: arrayListOf()
                    list.clear()
                    list.addAll(listNew)
                    aiGridAdapter?.setList(list)
                    changeCoinTitle()
                }
            }))
        }
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

    fun changeTotalQuoteAmount() {
        gridAmount = BigDecimalUtils.div(totalQuoteAmount, gridNumber).toPlainString()
    }

    private fun changeCoinTitle() {
        //Processing
        tv_history_grid_execute.text = list.getNumByLists(mActivity)
    }

    private fun isSubmit(): Boolean {
        if (lowestPrice.isEmpty()) {
//            ll_check_surplus_layout?.setBackgroundResource(R.drawable.bg_grid_red)
            NToastUtil.showTopToastNet(mActivity, false, getString(R.string.otc_mustWrite_tex))
            return false
        }
        if (highestPrice.isEmpty()) {
//            ll_stop_loss_layout?.setBackgroundResource(R.drawable.bg_grid_red)
            NToastUtil.showTopToastNet(mActivity, false, getString(R.string.otc_mustWrite_tex))
            return false
        }
        if (gridNumber.isEmpty()) {
//            ed_custom_grid_num?.setBackgroundResource(R.drawable.bg_grid_red)
            NToastUtil.showTopToastNet(mActivity, false, getString(R.string.otc_mustWrite_tex))
            return false
        }
        if (totalQuoteAmount.isEmpty()) {
//            ll_volum_layout?.setBackgroundResource(R.drawable.bg_grid_red)
            NToastUtil.showTopToastNet(mActivity, false, getString(R.string.otc_mustWrite_tex))
            return false
        }
        return true
    }

    private fun checkBase() {
        if (useOwnBase == "1" && lowestPrice.isNotEmpty() && highestPrice.isNotEmpty() && gridNumber.isNotEmpty() && totalQuoteAmount.isNotEmpty()) {
            calBaseAmount(symbol, lowestPrice, highestPrice, gridNumber, gridLineType, totalQuoteAmount, currentPrice, makerFee)
        }
    }

    private fun changeUsed(isUsed: String) {
        val valueBtc = StringBuffer("${LanguageUtil.getString(context, "quant_use_own_base")} ${NCoinManager.getShowMarket(base)}")
        if (isUsed == "1") {
            valueBtc.append(" (${LanguageUtil.getString(context, "grid_need_least_tips")}${totalBaseAmountTemp})")
        }
        tv_used_btc?.text = valueBtc.toString()
    }
    val tagGrid = "customGrid"

    override fun onMessageEvent(event: MessageEvent) {
        super.onMessageEvent(event)
        when (event.msg_type) {
            MessageEvent.grid_changeHide_coin -> {
                if (event.msg_content as String != tagGrid) {
                    isCheck = event.msg_content_data as Boolean
                    tv_history_grid_current.isChecked = isCheck
                }
            }
        }
    }

}
