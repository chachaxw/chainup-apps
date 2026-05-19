package com.chainup.contract.view.trade

import android.app.Activity
import android.content.Context
import android.text.TextUtils
import android.util.AttributeSet
import android.util.Log
import android.util.Pair
import android.view.LayoutInflater
import android.view.View
import android.widget.LinearLayout
import androidx.core.content.ContextCompat
import com.blankj.utilcode.util.LogUtils
import com.blankj.utilcode.util.SizeUtils
import com.chainup.contract.R
import com.chainup.contract.app.CpMyApp
import com.chainup.contract.app.CpParamConstant
import com.chainup.contract.bean.CpTabInfo
import com.chainup.contract.eventbus.CpEventBusUtil
import com.chainup.contract.eventbus.CpMessageEvent
import com.chainup.contract.listener.CpDoListener
import com.chainup.contract.utils.ChainUpLogUtil
import com.chainup.contract.utils.CpBigDecimalUtils
import com.chainup.contract.utils.CpClLogicContractSetting
import com.chainup.contract.utils.CpColorUtil
import com.chainup.contract.utils.CpContractBuyOrSellHelper
import com.chainup.contract.utils.CpNToastUtil
import com.chainup.contract.utils.CpPreferenceManager
import com.chainup.contract.utils.CpSoftKeyboardUtil
import com.chainup.contract.utils.CpStringUtil
import com.chainup.contract.utils.numberFilter
import com.chainup.contract.utils.onLineText
import com.chainup.contract.utils.setSafeListener
import com.chainup.contract.utils.setTransferStatus
import com.chainup.contract.view.CpCommonlyUsedButton
import com.chainup.contract.view.CpDialogUtil
import com.chainup.contract.view.CpNewDialogUtils
import com.chainup.kit.utils.ToastUtils
import com.chainup.talkingdata.AppAnalyticsExt
import com.jakewharton.rxbinding2.view.RxView
import com.timmy.tdialog.TDialog
import com.warkiz.widget.IndicatorSeekBar
import com.warkiz.widget.OnSeekChangeListener
import com.warkiz.widget.SeekParams
import com.yjkj.chainup.manager.CpLanguageUtil
import com.yjkj.chainup.new_contract.bean.CpCreateOrderBean
import com.yjkj.chainup.new_contract.bean.CpCurrentOrderBean
import io.reactivex.android.schedulers.AndroidSchedulers
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.btn_buy
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.btn_login_contract
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.btn_open_contract
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.btn_sell
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.cb_only_reduce_positions
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.cb_stop_loss
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.custom_seekbar
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.et_price
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.et_stop_loss_price
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.et_stop_profit_price
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.et_trigger_price
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.icon_transfer
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.iv_arrow
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.ll_all_price
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.ll_buy_cost
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.ll_long_title
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.ll_only_reduce_positions
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.ll_price
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.ll_quantity_type
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.ll_sell_cost
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.ll_short_title
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.ll_stop_loss
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.ll_stop_loss_price
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.ll_stop_profit_loss_price
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.ll_stop_profit_price
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.ll_trigger_price
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.ly_transfer
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.mAvailableVal
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.mEditCtrl
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.pll_ll_quantity_type
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.rb_buy
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.rb_sell
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.tv_buy_cost
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.tv_buy_cost_label
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.tv_coin_name
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.tv_cp_available_label
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.tv_cp_order_text54
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.tv_cp_order_text57
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.tv_cp_overview_text64
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.tv_cp_overview_text65
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.tv_equivalent
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.tv_long_title
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.tv_long_value
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.tv_order_tips_layout
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.tv_order_tips_layout_plan
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.tv_order_type
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.tv_price_hint
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.tv_rival_price_hint
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.tv_rival_price_type
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.tv_sell_cost
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.tv_sell_cost_label
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.tv_short_title
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.tv_short_value
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.tv_type_unit
import org.jetbrains.anko.backgroundResource
import org.jetbrains.anko.view
import org.json.JSONArray
import org.json.JSONObject
import java.math.BigDecimal
import java.util.concurrent.TimeUnit


class CpTradeView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : LinearLayout(context, attrs, defStyleAttr) {

    val TAG = CpTradeView::class.java.simpleName
    private val buyOrSellHelper = CpContractBuyOrSellHelper()

    //Transaction Type
    var transactionType = CpParamConstant.TYPE_BUY
    var isLever = false
    var isPercentPlaceOrder = false
    var dialog: TDialog? = null
    var isRivalPriceModel = false
    var isMarketPriceModel = false

    var mUserConfigInfoJson: JSONObject? = null
    var mUserAssetsInfoJson: JSONObject? = null
    var mContractJson: JSONObject? = null

    var mContractId = 0
    var contractSide = ""
    var percent = "0.0"
    var canOpenBuy = "0"
    var canOpenSell = "0"
    var maxOpenValue = "0"
    var positionType = ""
    var maxOpenLimit = "0"
    var positionValue = "0"
    var entrustedValue = "0"
    var price = "0"
    var triggerPrice = "0"
    var multiplier = "0"
    var canUseAmount = "0"
    var canCloseVolumeBuy = "0"
    var canCloseVolumeSell = "0"
    var level = 20
    var marginModel = ""
    var marginRate = "0"
    var marginCoin = ""
    var marginCoinPrecision = 0
    var multiplierPrecision = 0
    var symbolPricePrecision = 9
    var minOrderMoneyPrecision = 0
    var base = ""
    var quote = ""

    var mContractUint = 0

    var buyMaxPrice = ""
    var askMaxPrice = ""
    var lastPrice = ""
    //Latest prices that change in real time
    var lastPriceing = ""

    var buyCost = ""
    var sellCost = ""

    var buyMaxPriceList = arrayListOf<JSONArray>()
    var sellMaxPriceList = arrayListOf<JSONArray>()

    var transferClick: OnTransferClick? = null

    //Select an order type 0 to place an order by quantity 1 to place an order by value
    var selectOrderType:Pair<Int,String>? = null

    //Order quantity input accuracy
    var quantityPrecision:Int = 0

    init {
        attrs?.let {
            val typedArray = context.obtainStyledAttributes(it, R.styleable.ComVerifyView, 0, 0)
            typedArray.recycle()
        }
        LayoutInflater.from(context).inflate(R.layout.cp_trade_amount_view_new, this, true)

        mEditCtrl.setCtrlGone(true)
        tv_rival_price_type.setContent(CpLanguageUtil.getString(context, "cp_overview_text38"))

        et_price?.setOnFocusChangeListener { _, hasFocus ->
            ll_price?.setBackgroundResource(if (hasFocus) R.drawable.bg_selected_contract else R.drawable.bg_select_contract)
            if(hasFocus){
                AppAnalyticsExt.instance.clickAction(AppAnalyticsExt.APP_FUTURES_LIMIT_ORDER_PRICE_INPUT)
            }
        }

        //New version price input box
        mEditCtrl?.setOnFocusChangeListener { _, hasFocus ->
            if (hasFocus) {
                if (isPercentPlaceOrder) {

                    mEditCtrl.setText("")
                    custom_seekbar.setProgress(0f)
                    isPercentPlaceOrder = !isPercentPlaceOrder
                }
                if(buyOrSellHelper.orderType==1){
                    AppAnalyticsExt.instance.clickAction(AppAnalyticsExt.APP_FUTURES_LIMIT_ORDER_QUANTITY_INPUT)
                }else if(buyOrSellHelper.orderType==2){
                    AppAnalyticsExt.instance.clickAction(AppAnalyticsExt.APP_FUTURES_MARKET_ORDER_QUANTITY_INPUT)
                }
            }

            mEditCtrl.setBackgroundResource(if (hasFocus) R.drawable.bg_selected_contract else R.drawable.bg_select_contract)
        }


        et_stop_profit_price?.setOnFocusChangeListener { _, hasFocus ->
            ll_stop_profit_price?.setBackgroundResource(if (hasFocus) R.drawable.bg_selected_contract else R.drawable.bg_select_contract)
        }

        et_stop_loss_price?.setOnFocusChangeListener { _, hasFocus ->
            ll_stop_loss_price?.setBackgroundResource(if (hasFocus) R.drawable.bg_selected_contract else R.drawable.bg_select_contract)
        }

        et_trigger_price.numberFilter(symbolPricePrecision, otherFilter = object : CpDoListener {
            override fun doThing(obj: Any?): Boolean {
                updateAvailableVol()
                return true
            }
        })

        et_price.numberFilter(symbolPricePrecision, otherFilter = object : CpDoListener {
            override fun doThing(obj: Any?): Boolean {
                updateAvailableVol()
                return true
            }
        })


        quantityPrecision = if (mContractUint == 0) 0 else multiplierPrecision
        mEditCtrl?.numberFilter(quantityPrecision,
            otherFilter = object : CpDoListener {
                override fun doThing(obj: Any?): Boolean {
                    updateAvailableVol(showBalanceInsufficientTips = true)
                    return true
                }
            })
        tv_cp_overview_text65.text = CpLanguageUtil.getString(context, "cp_overview_text65")
        tv_cp_overview_text64.text = CpLanguageUtil.getString(context, "cp_overview_text64")
        btn_login_contract.text = CpLanguageUtil.getString(context, "cp_overview_text67")
        btn_open_contract.text = CpLanguageUtil.getString(context, "cp_overview_text66")
        rb_buy.text = CpLanguageUtil.getString(context, "cp_overview_text1")
        rb_sell.text = CpLanguageUtil.getString(context, "cp_overview_text2")
        tv_order_tips_layout_plan.text = CpLanguageUtil.getString(context, "cp_overview_text36")
        tv_order_tips_layout.text = CpLanguageUtil.getString(context, "cp_overview_text36")
        tv_cp_order_text54.text = CpLanguageUtil.getString(context, "cp_order_text54")
        tv_rival_price_hint.text = CpLanguageUtil.getString(context, "cp_overview_text7")
        tv_cp_order_text57.text = CpLanguageUtil.getString(context, "cp_order_text57")
        tv_buy_cost_label.text = CpLanguageUtil.getString(context, "cp_overview_text11")
        tv_sell_cost_label.text = CpLanguageUtil.getString(context, "cp_overview_text11")
        et_stop_profit_price.hint = CpLanguageUtil.getString(context, "cp_extra_text65")
        et_stop_loss_price.hint = CpLanguageUtil.getString(context, "cp_extra_text64")
        et_price.hint = CpLanguageUtil.getString(context, "cp_contract_price")
        et_trigger_price.hint = CpLanguageUtil.getString(context, "cp_overview_text29")
        tv_price_hint.text = CpLanguageUtil.getString(context, "cp_overview_text53")
        tv_cp_available_label.text = CpLanguageUtil.getString(context,"cp_overview_text19")

        rb_buy.setSafeListener {
            transactionType = CpParamConstant.TYPE_BUY
            changeBuyOrSellUI()
            clearUIFocus()
            buyOrSellHelper.isOpen = true
            val mCpMessageEvent = CpMessageEvent(CpMessageEvent.sl_contract_modify_depth_event)
            mCpMessageEvent.msg_content = buyOrSellHelper
            CpEventBusUtil.post(mCpMessageEvent)
            AppAnalyticsExt.instance.clickAction(AppAnalyticsExt.CONTRACT_APP_ACTION_1)

            selectOrderType?.run {
                quantityPrecision = if(first==1){
                    //value
                    minOrderMoneyPrecision
                }else{
                    //btc
                    if (mContractUint == 0) {
                        0
                    } else {
                        multiplierPrecision
                    }
                }
            }

            mEditCtrl?.run {
                numberFilter(quantityPrecision)
                setText("")
            }
            isPercentPlaceOrder = false
            custom_seekbar.setProgress(0f)
            updateAvailableVol()
        }
        rb_sell.setSafeListener {
            transactionType = CpParamConstant.TYPE_SELL
            changeBuyOrSellUI()
            clearUIFocus()
            buyOrSellHelper.isOpen = false
            val mCpMessageEvent = CpMessageEvent(CpMessageEvent.sl_contract_modify_depth_event)
            mCpMessageEvent.msg_content = buyOrSellHelper
            CpEventBusUtil.post(mCpMessageEvent)
            AppAnalyticsExt.instance.clickAction(AppAnalyticsExt.CONTRACT_APP_ACTION_2)
            quantityPrecision = if(mContractUint==0) 0 else multiplierPrecision
            mEditCtrl?.run {
                numberFilter(quantityPrecision)
                setText("")
            }
            isPercentPlaceOrder = false
            custom_seekbar.setProgress(0f)
            updateAvailableVol()
        }


        btn_login_contract.setSafeListener {
            if (!CpClLogicContractSetting.isLogin()) {
                CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.sl_contract_go_login_page))
            }
        }

        btn_open_contract.setSafeListener {
            CpDialogUtil.showCreateContractDialog(
                context,
                object : CpNewDialogUtils.DialogBottomListener {
                    override fun sendConfirm() {
                        CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.sl_contract_open_contract_event))
                    }
                })
        }

        //Default unit price limit
        changePriceType(1, CpLanguageUtil.getString(context, "cp_overview_text3"))
        //Select Order Type
        tv_order_type?.run {
            RxView.clicks(findViewById<View>(R.id.pid))
                .throttleFirst(500L, TimeUnit.MILLISECONDS) //Only the first click is valid within 1 second
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({ x ->
                    clearUIFocus()
                    tv_order_type?.stratAnim()
                    CpDialogUtil.createCVCOrderPop(
                        context,
                        buyOrSellHelper.orderType,
                        this,
                        object : CpNewDialogUtils.DialogOnSigningItemClickListener {
                            override fun clickItem(position: Int, text: String) {
                                tv_order_type?.textContent = text
                                changePriceType(position, text)
                            }
                        },
                        object : CpNewDialogUtils.DialogOnDismissClickListener {
                            override fun clickItem() {
                                tv_order_type?.stopAnim()
                            }
                        })
                })
            findViewById<View>(R.id.ic_tip)?.setOnClickListener {
//                showTipDialog()
                CpNewDialogUtils.showTipDialogByOrderType(context,buyOrSellHelper.orderType-1)
            }
        }


        //contract_ Demand Order Setting
        ll_quantity_type.setSafeListener {
            val datas = getOrderTypeDataList()

            iv_arrow.animate().setDuration(200).rotation(180f).start()
            CpDialogUtil.createQuantityTypePop(
                context, selectOrderType?.first?:0, pll_ll_quantity_type, datas,
                object : CpNewDialogUtils.DialogOnSigningItemClickListener {
                    override fun clickItem(position: Int, text: String) {
                        Log.d(TAG,"createQuantityTypePop itemclick")
                        selectOrderType = Pair(position,text)
                        changeSelectOrderType(selectOrderType)
                    }
                },
                object : CpNewDialogUtils.DialogOnSigningItemClickListener {
                    override fun clickItem(position: Int, text: String) {
                        Log.d(TAG,"createQuantityTypePop childTipClick")
                        CpNewDialogUtils.showDialogNew(
                            context,
                            content = CpLanguageUtil.getString(context,"order_setting_text4"),true,
                            null,
                            title = CpLanguageUtil.getString(context,"order_setting_text3"),
                            confrimTitle = CpLanguageUtil.getString(context,"cp_calculator_text16"),
                        )
                    }
                },
                object : CpNewDialogUtils.DialogOnDismissClickListener {
                    override fun clickItem() {
                        iv_arrow.animate().setDuration(200).rotation(0f).start()
                        Log.d(TAG,"createQuantityTypePop cancelClick")
                    }
                }
            )

        }


        //Select Opposite Price Gear
        tv_rival_price_type?.view()?.let {
            RxView.clicks(it)
                .throttleFirst(500L, TimeUnit.MILLISECONDS) //Only the first click is valid within 1 second
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({ x ->
                    clearUIFocus()
                    tv_rival_price_type?.stratAnim()
                    CpDialogUtil.createRivalPricePop(
                        context,
                        buyOrSellHelper,
                        it,
                        tv_order_type,
                        object : CpNewDialogUtils.DialogOnSigningItemClickListener {
                            override fun clickItem(position: Int, text: String) {
                                tv_rival_price_type?.textContent = text
                                when (position) {
                                    0 -> AppAnalyticsExt.instance.clickAction(AppAnalyticsExt.CONTRACT_APP_ACTION_7)
                                    1 -> AppAnalyticsExt.instance.clickAction(AppAnalyticsExt.CONTRACT_APP_ACTION_8)
                                    2 -> AppAnalyticsExt.instance.clickAction(AppAnalyticsExt.CONTRACT_APP_ACTION_9)
                                }
                            }
                        },
                        object : CpNewDialogUtils.DialogOnDismissClickListener {
                            override fun clickItem() {
                                tv_rival_price_type?.stopAnim()
                            }
                        })
                })
        }

        //Click on the market price list under the condition list
        tv_price_hint.setOnClickListener {
            isMarketPriceModel = !isMarketPriceModel
            if(isMarketPriceModel) {
                selectOrderType=null
                var coinResultVo = JSONObject(mContractJson?.optString("coinResultVo"))
                var minOrderMoney = coinResultVo.optString("minOrderMoney")//Minimum order amount
                minOrderMoney=CpBigDecimalUtils.showSNormal(minOrderMoney)
                var minOrderMoneyArr= minOrderMoney.split(".")
                if(minOrderMoneyArr.size>1){
                    minOrderMoneyPrecision=minOrderMoneyArr[1].length
                }

                if (isMarket() && transactionType == CpParamConstant.TYPE_BUY) {
                    quantityPrecision = minOrderMoneyPrecision
                }
                mEditCtrl?.run {
                    numberFilter(quantityPrecision)
                    clearUiEtVal()
                }

            }else{

                val orderSelectTypeList = getOrderTypeDataList()
                selectOrderType=Pair(orderSelectTypeList[0].index,orderSelectTypeList[0].name)
                changeSelectOrderType(selectOrderType)
            }
            if (CpClLogicContractSetting.getExecution(CpMyApp.instance()) == 1) {
                CpClLogicContractSetting.setExecution(CpMyApp.instance(), 0)
                et_price.requestFocus()
            } else {
                CpClLogicContractSetting.setExecution(CpMyApp.instance(), 1)
                et_price.clearFocus()
            }
            updataMarketPriceUI()
            updateAvailableVol()
            clearUIFocus()
        }
        //Click Opposite Price
        tv_rival_price_hint.setOnClickListener {
            isRivalPriceModel = !isRivalPriceModel
            updataRivalPriceUI()
            clearUIFocus()
        }
        //Only reduce positions
        ll_only_reduce_positions.setSafeListener {
            cb_only_reduce_positions.isChecked = !cb_only_reduce_positions.isChecked
            clearUIFocus()
        }
        //Only reduce positions and select monitoring
        cb_only_reduce_positions.setOnCheckedChangeListener { buttonView, isChecked ->
            if (isChecked) {
                cb_stop_loss.isChecked = false
            }
            transactionType =
                if (!isChecked) CpParamConstant.TYPE_BUY else CpParamConstant.TYPE_SELL
            changeBuyOrSellUI()
            buyOrSellHelper.isOpen = !isChecked

            clearUiEtVal()
            val mCpMessageEvent = CpMessageEvent(CpMessageEvent.sl_contract_modify_depth_event)
            mCpMessageEvent.msg_content = buyOrSellHelper
            CpEventBusUtil.post(mCpMessageEvent)
        }

        //Stop profit and stop loss
        ll_stop_loss.setSafeListener {
            cb_stop_loss.isChecked = !cb_stop_loss.isChecked
            clearUIFocus()
        }
        //Stop profit and stop loss selection monitoring
        cb_stop_loss.setOnCheckedChangeListener { buttonView, isChecked ->
            ll_stop_profit_loss_price.visibility = if (isChecked) View.VISIBLE else View.GONE
            et_stop_profit_price.setText("")
            et_stop_loss_price.setText("")
            buyOrSellHelper.isOto = isChecked
            val mCpMessageEvent = CpMessageEvent(CpMessageEvent.sl_contract_modify_depth_event)
            mCpMessageEvent.msg_content = buyOrSellHelper
            CpEventBusUtil.post(mCpMessageEvent)
        }


        custom_seekbar.onSeekChangeListener = object : OnSeekChangeListener {
            var isSliding = false
            override fun onSeeking(seekParams: SeekParams) {
                if(isSliding) {
                    mEditCtrl.setText("${seekParams.seekBar.progress}%")
                    ChainUpLogUtil.e("${seekParams.seekBar.progress}%")
                    percent = CpBigDecimalUtils.divStr(seekParams.seekBar.progress.toString(), "100", 2)
                    adjustRatio()
                }
            }

            override fun onStartTrackingTouch(seekBar: IndicatorSeekBar?) {
                isPercentPlaceOrder = true
                isSliding = true
                if(buyOrSellHelper.orderType==1){
                    AppAnalyticsExt.instance.clickAction(AppAnalyticsExt.APP_FUTURES_LIMIT_ORDER_QUANTITY_SLIDER)
                }else if(buyOrSellHelper.orderType==2){
                    AppAnalyticsExt.instance.clickAction(AppAnalyticsExt.APP_FUTURES_MARKET_ORDER_QUANTITY_SLIDER)
                }
            }

            override fun onStopTrackingTouch(seekBar: IndicatorSeekBar?) {
                isPercentPlaceOrder = true
                isSliding = false
                seekBar?.let {
                    mEditCtrl.setText("${it.progress}%")
                    ChainUpLogUtil.e("${it.progress}%")
                    percent = CpBigDecimalUtils.divStr(it.progress.toString(), "100", 2)
                    adjustRatio()
                }

            }

        }


        btn_buy.isEnable(true)
        btn_buy.listener = object : CpCommonlyUsedButton.OnBottonListener {
            override fun bottonOnClick() {
                var isOpen = false;
                if (transactionType == CpParamConstant.TYPE_BUY) {
                    isOpen = true
                } else {
                    isOpen = false
                }
                if (isOpen && mUserConfigInfoJson?.optInt("forceKycOpen") == 1) {
                    if (mUserConfigInfoJson?.optInt("authLevel") == 3) {
                        goKycTips(CpLanguageUtil.getString(context, "cp_kyc_8"));
                        return
                    } else if (mUserConfigInfoJson?.optInt("authLevel") == 2) {
                        goKycTips(CpLanguageUtil.getString(context, "cp_kyc_8"));
                        return
                    } else if (mUserConfigInfoJson?.optInt("authLevel") == 0) {
                        kycTips(CpLanguageUtil.getString(context, "cp_kyc_9"));
                        return
                    }
                }
                doBuyOrSell("BUY")
            }
        }
        btn_sell.isEnable(true)
        btn_sell.listener = object : CpCommonlyUsedButton.OnBottonListener {
            override fun bottonOnClick() {
                var isOpen = false;
                if (transactionType == CpParamConstant.TYPE_BUY) {
                    isOpen = true
                } else {
                    isOpen = false
                }
                if (isOpen && mUserConfigInfoJson?.optInt("forceKycOpen") == 1) {
                    if (mUserConfigInfoJson?.optInt("authLevel") == 3) {
                        goKycTips(CpLanguageUtil.getString(context, "cp_kyc_8"));
                        return
                    } else if (mUserConfigInfoJson?.optInt("authLevel") == 2) {
                        goKycTips(CpLanguageUtil.getString(context, "cp_kyc_8"));
                        return
                    } else if (mUserConfigInfoJson?.optInt("authLevel") == 0) {
                        kycTips(CpLanguageUtil.getString(context, "cp_kyc_9"));
                        return
                    }
                }
                doBuyOrSell("SELL")
            }
        }


        //Fund transfer
        ly_transfer.setSafeListener {
            transferClick?.click()
        }
    }


    private fun setEtPriceStep(){
        val strbuild = StringBuilder().apply {
            if(symbolPricePrecision>0){
                append("0.")
                for(i in 1..(symbolPricePrecision-1)){
                    append("0")
                }
                append("1")
            }else{
                append("1")
            }
        }
        et_price.step = strbuild.toString()
    }

    //Set Step
    private fun setETCtrlStep(){
        val strbuild = StringBuilder().apply {
            if(multiplierPrecision>0){
                append("0.")
                for(i in 1..(multiplierPrecision-1)){
                    append("0")
                }
                append("1")
            }else{
                append("1")
            }
        }

        if(buyOrSellHelper.orderType==2){
            mEditCtrl.step = "1"
            mEditCtrl.minValue = "1"
        }else if(buyOrSellHelper.orderType==3 && isMarketPriceModel){
            mEditCtrl.step = "1"
            mEditCtrl.minValue = "1"
        } else {
            mEditCtrl?.run{
                when(mContractUint){
                    //Zhang
                    0 -> {
                        step = "1"
                        minValue = "1"
                    }
                    //Coins
                    1 -> {
                        step = strbuild.toString()
                        minValue = strbuild.toString()
                    }
                }
            }
        }

    }

    //Get selectable order types 0 by quantity 1 by value
    private fun getOrderTypeDataList():ArrayList<CpTabInfo>{
        val list = arrayListOf<CpTabInfo>()
        mContractJson?.run {
            //Order by quantity
            val quantitySelect = if(mContractUint==0) {
                CpLanguageUtil.getString(context, "cp_overview_text9")
            }else{
                if("1".equals(contractSide)) optString("base") else optString("quote")
            }
            list.add(CpTabInfo(quantitySelect,0,false))

            //Order by value
            val valueSelect = if("1".equals(contractSide)){
                //Forward contract: The unit is the currency of account, for example, BTCUSDT, and the currency of account is USDT
                optString("quote")
            }else{
                optString("base")
            }
            list.add(CpTabInfo(valueSelect,1,true))
        }

        return list

    }

    //Change the order type selected 0 by quantity 1 by value
    private fun changeSelectOrderType(selectOrderType:Pair<Int,String>?){
        selectOrderType?.run {
            tv_type_unit.text = second
            quantityPrecision = if(first==1){
                AppAnalyticsExt.instance.clickAction(AppAnalyticsExt.CONTRACT_APP_ACTION_21)
                //value
                minOrderMoneyPrecision
            }else{
                //btc
                if (mContractUint == 0) {
                    AppAnalyticsExt.instance.clickAction(AppAnalyticsExt.CONTRACT_APP_ACTION_20)
                    0
                } else {
                    AppAnalyticsExt.instance.clickAction(AppAnalyticsExt.CONTRACT_APP_ACTION_19)
                    multiplierPrecision
                }
            }
            mEditCtrl?.run {
                numberFilter(quantityPrecision)
                setText("")
            }
            isPercentPlaceOrder = false
            custom_seekbar.setProgress(0f)
            updateAvailableVol()
        }
    }

    private fun clearUIFocus() {
        clearFocus()
        CpSoftKeyboardUtil.hideSoftKeyboard(getActivity())
    }

    //Click to switch the counter price mode
    fun updateRivalPriceUI() {
        isRivalPriceModel = false
        updataRivalPriceUI()
    }

    fun updatePrice(tickPrice: String) {
        et_price?.setText(tickPrice)
        if (buyOrSellHelper.orderType == 1) {
            updateRivalPriceUI()
        }
        if(buyOrSellHelper.orderType==1){
            AppAnalyticsExt.instance.clickAction(AppAnalyticsExt.APP_FUTURES_LIMIT_ORDER_PRICE_CLICK)
        }
    }

    fun initTick(tickPrice: String) {
        LogUtils.e("tickPrice:" + tickPrice)
        et_price.setText(tickPrice)
    }

    fun setTickLastPrice(buyMaxPrice: String, sellMaxPrice: String, lastPrice: String) {
        if (!TextUtils.isEmpty(buyMaxPrice)) {
            this.buyMaxPrice = buyMaxPrice
        }
        if (!TextUtils.isEmpty(sellMaxPrice)) {
            this.askMaxPrice = sellMaxPrice
        }
        if (!TextUtils.isEmpty(lastPrice)) {
            this.lastPrice = lastPrice
        }
        updateAvailableVol()
    }
    fun resetPrice() {
        buyMaxPrice = ""
        askMaxPrice = ""
        lastPrice = ""
    }

    fun setTickPrice(
        buyMaxPriceList: ArrayList<JSONArray>?,
        sellMaxPriceList: ArrayList<JSONArray>?
    ) {
        buyMaxPriceList?.let {
            this.buyMaxPriceList = buyMaxPriceList
        }
        sellMaxPriceList?.let {
            this.sellMaxPriceList = sellMaxPriceList
        }
    }

    fun editPriceIsNull(): Boolean {
        if (et_price.text.isNullOrEmpty() && !et_price.isFocused) {
            return true
        }
        return false
    }


    /**
     * @param volume input volume
     * @param isOpen is open position
     * @param price  entrust price
     * @return order is check pass?
     * */
    private fun doSafeChecking(volume:String,isOpen:Boolean,price:String,side:String):Boolean {

        if (TextUtils.isEmpty(price) || "0".equals(price)) {
            CpNToastUtil.showTopToastNet(
                getActivity(),
                false,
                CpLanguageUtil.getString(context, "order_placement_text6")
            )
            return false
        }

        if (TextUtils.isEmpty(volume)) {
            mEditCtrl.requestFocus()
            CpSoftKeyboardUtil.showORhideSoftKeyboard(context as Activity)
            return false
        }
        val isStopLoss = cb_stop_loss.isChecked
        val stopProfitPrice = et_stop_profit_price.text.toString().trim()
        val stopLossPrice = et_stop_loss_price.text.toString().trim()

        if (isOpen && isStopLoss) {
            if (TextUtils.isEmpty(stopProfitPrice) && TextUtils.isEmpty(stopLossPrice)) {
                CpNToastUtil.showTopToastNet(
                    getActivity(), false, CpLanguageUtil.getString(context, "cp_overview_text41")
                )
                return false
            }
        }


        return mContractJson?.let {
            val isMarket = isMarket()
            val coinResultVo = JSONObject(it.optString("coinResultVo"))
            val minOrderVolume = coinResultVo.optString("minOrderVolume")//Minimum order quantity
            val minOrderPrecision = coinResultVo.optString("minOrderMoney")//order precision
            val maxMarketVolume = coinResultVo.optString("maxMarketVolume")//Maximum order quantity of market price order
            val maxLimitVolume = coinResultVo.optString("maxLimitVolume")//Maximum order quantity for price limit orders
            val isMarketOrValue = isValueOrder() || (isMarket)//is market order,value order,trigger market order?
            //The number of intercepting prompts is configured for the single order limit configuration
            val contractUint = CpClLogicContractSetting.getContractUint(context)
            var unit = selectOrderType?.second ?: base

            if(isMarketOrValue && isOpen){
                if(isMarket) unit = marginCoin
                val precision = CpBigDecimalUtils.getPrecisionByPrice(minOrderPrecision)
                val isForward = "1".equals(contractSide)
                val minValue = CpBigDecimalUtils.getOrderNumMinValue(isForward,minOrderVolume,volume,price,multiplier,precision)
                val maxValue = CpBigDecimalUtils.getOrderNumMaxValue(isForward,if(isMarket) maxMarketVolume else maxLimitVolume,volume,price,multiplier,precision)

                if(minValue!=null){
                    CpNToastUtil.showTopToastNet(
                        getActivity(), false,
                        String.format(CpLanguageUtil.getString(context, "order_placement_text3"),"$minValue $unit")
                    )
                    return@let false
                }
                if(maxValue!=null){
                    CpNToastUtil.showTopToastNet(
                        getActivity(), false,
                        String.format(CpLanguageUtil.getString(context, "order_placement_text4"),"$maxValue $unit")
                    )
                    return@let false
                }
            }else{
                val maxMessage:String = if(contractUint==0){
                        maxLimitVolume + " " + CpLanguageUtil.getString(context, "cp_overview_text9")
                    }else{
                        CpBigDecimalUtils.mulStr(maxLimitVolume,multiplier,multiplierPrecision) + " " + unit
                    }
                val minMessage:String = if(contractUint==0){
                        minOrderVolume + " " + CpLanguageUtil.getString(context, "cp_overview_text9")
                    }else{
                        CpBigDecimalUtils.mulStr(minOrderVolume,multiplier,multiplierPrecision) + " " + unit
                    }

                if (CpBigDecimalUtils.orderNumMinCheck(volume, minOrderVolume, multiplier)) {
                    CpNToastUtil.showTopToastNet(
                        getActivity(), false,
                        "${CpLanguageUtil.getString(context, "order_placement_text7")} $minMessage"
                    )
                    return@let false
                }

                if(isOpen){
                    if (CpBigDecimalUtils.orderNumMaxCheck(volume, maxLimitVolume, multiplier)) {
                        CpNToastUtil.showTopToastNet(
                            getActivity(), false,
                            "${CpLanguageUtil.getString(context,"order_placement_text8")} $maxMessage"
                        )
                        return@let false
                    }
                }

            }

            //contract_demand https://jira.dw2nn.com/browse/BIGFUTURES-2530 close position check
            if(!isOpen){//close position
                when(side){
                    "BUY" -> {
                        //short check...(volume canOpenBuy)
                        val compareResult = CpBigDecimalUtils.compareTo(volume,canOpenBuy) == 1
                        if(compareResult){
                            CpNToastUtil.showTopToastNet(getActivity(), false,
                                CpLanguageUtil.getString(context,"order_placement_text9")
                            )
                            return@let false
                        }
                    }
                    "SELL" -> {
                        //long check...(volume canOpenSell)
                        val compareResult = CpBigDecimalUtils.compareTo(volume,canOpenSell) == 1
                        if(compareResult){
                            CpNToastUtil.showTopToastNet(getActivity(), false,
                                CpLanguageUtil.getString(context,"order_placement_text9")
                            )
                            return@let false
                        }
                    }
                }

            }
            true
        } ?: false
    }

    private fun doBuyOrSell(side: String) {
        var isOpen = false;
        var isConditionOrder = false
        var orderType = 1;
        var dialogTitle = ""
        var volume = mEditCtrl.text.toString()
        if (transactionType == CpParamConstant.TYPE_BUY) {
            isOpen = true
        } else {
            isOpen = false
        }
        val isStopLoss = cb_stop_loss.isChecked
        val stopProfitPrice = et_stop_profit_price.text.toString().trim()
        val stopLossPrice = et_stop_loss_price.text.toString().trim()
        var price = et_price.text.toString()
        val triggerPrice = et_trigger_price.text.toString()//Trigger Price

        var buyPositionAmount = volume
        var sellPositionAmount = volume
        if (TextUtils.isEmpty(volume)) {
            volume = "0"
        }
        if (isPercentPlaceOrder) {
            if (side.equals("BUY")) {
                volume = CpBigDecimalUtils.mulStr(canOpenBuy, percent, multiplierPrecision)
                buyPositionAmount = volume
            } else {
                volume = CpBigDecimalUtils.mulStr(canOpenSell, percent, multiplierPrecision)
                sellPositionAmount = volume
            }



        }
        if (side.equals("BUY")) {
            volume = buyPositionAmount
        } else {
            volume = sellPositionAmount
        }

        if(!isValueOrder() && isNotMarket()){
            if (mContractUint == 0) {
                if (isOpen) {
                    volume = CpBigDecimalUtils.showSNormal(volume, 0)
                } else {
                    volume = CpBigDecimalUtils.showSNormalUp(volume, 0)
                }
            }
        }

        if(isOpen && isValueOrder() && isPercentPlaceOrder){
            var buff = CpBigDecimalUtils.mulStr(maxOpenValue, percent, symbolPricePrecision)
//            volume = CpBigDecimalUtils.mulStr(buff, level.toString(), symbolPricePrecision)
            volume = buff
        }



        //Order balance judgment:
        if(isOpen){
            val mAvailable= mAvailableVal.text.split(" ")[0]

            val noHaveMoney = CpBigDecimalUtils.compareTo(mAvailable,"0")==0
            var isMockContract = false//Is it a simulated contract
            mContractJson?.run {
                isMockContract = getInt("classification") == 4
            }

            if (side.equals("BUY")){
                //Actual needs
                val actualBuy= buyCost.split(" ")[0]
                if (CpBigDecimalUtils.greaterThan(actualBuy,mAvailable)||noHaveMoney){
                    if(isMockContract){
                        ToastUtils.showToast(context,CpLanguageUtil.getString(context,"common_tip_balanceNotEnough"))
                    }else{
                        CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.sl_contract_balance_insufficient_event))
                    }
                    return
                }
            }else{
                val actualSell= sellCost.split(" ")[0]
                if (CpBigDecimalUtils.greaterThan(actualSell,mAvailable)||noHaveMoney){
                    if(isMockContract){
                        ToastUtils.showToast(context,CpLanguageUtil.getString(context,"common_tip_balanceNotEnough"))
                    }else{
                        CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.sl_contract_balance_insufficient_event))
                    }
                    return
                }
            }
        }


        when (buyOrSellHelper.orderType) {
            1 -> {
                orderType = 1
                if (isRivalPriceModel) {
                    sellMaxPriceList.sortBy {
                        it.optDouble(0)
                    }
                    if (side.equals("BUY")) {
                        if (sellMaxPriceList.size > buyOrSellHelper.rivalPricePosition) {
                            price =
                                sellMaxPriceList[buyOrSellHelper.rivalPricePosition].optDouble(0)
                                    .toString()
                        } else {
                            CpNToastUtil.showTopToastNet(
                                getActivity(),
                                false,
                                CpLanguageUtil.getString(context, "cp_overview_text50")
                            )
                            return
                        }
                    } else {
                        if (buyMaxPriceList.size > buyOrSellHelper.rivalPricePosition) {
                            price = buyMaxPriceList[buyOrSellHelper.rivalPricePosition].optDouble(0)
                                .toString()
                        } else {
                            CpNToastUtil.showTopToastNet(
                                getActivity(),
                                false,
                                CpLanguageUtil.getString(context, "cp_overview_text50")
                            )
                            return
                        }
                    }
                }
            }
            2 -> {
                orderType = 2
                price = CpBigDecimalUtils.median(
                    buyMaxPrice,
                    askMaxPrice,
                    lastPrice
                )
                isMarketPriceModel = true
                if (isOpen && isPercentPlaceOrder) {
                    var buff = CpBigDecimalUtils.mulStr(maxOpenValue, percent, symbolPricePrecision)
//                    volume = CpBigDecimalUtils.mulStr(buff, level.toString(), minOrderMoneyPrecision)
                    volume = buff
                }
            }
            3 -> {
                isConditionOrder = true
                if (TextUtils.isEmpty(triggerPrice)) {
                    et_trigger_price.requestFocus()
                    CpSoftKeyboardUtil.showORhideSoftKeyboard(context as Activity)
                    return
                }
                if (isMarketPriceModel) {
                    orderType = 2 //Market Price List
                    price = triggerPrice
                } else {
                    orderType = 1
                }
                if (isOpen && isPercentPlaceOrder && isMarketPriceModel) {
                    var buff = CpBigDecimalUtils.mulStr(maxOpenValue, percent, symbolPricePrecision)
//                    volume = CpBigDecimalUtils.mulStr(buff, level.toString(), minOrderMoneyPrecision)
                    volume = buff
                }
            }
            4 -> {
                orderType = 5
            }
            5 -> {
                orderType = 4
            }
            6 -> {
                orderType = 3
            }
        }

        ChainUpLogUtil.d(TAG,"doBuyOrSell>>> Order Volume=$volume")

        if(!doSafeChecking(volume, isOpen,price,side)) return


        val expireTime = CpClLogicContractSetting.getStrategyEffectTimeStr(context)

        // (Zhang)
        val orderNum = if(isValueOrder()){
            //When users place an order by value, the front end needs to convert the value of the warehouse into a quantity and send it to the back end
            CpBigDecimalUtils.getOrderVolumeByValue("1".equals(contractSide),volume,price,multiplier)
        }else{
            //Order by quantity
            CpBigDecimalUtils.getOrderNum(isOpen, volume, multiplier, buyOrSellHelper.orderType)
        }


        val isMarket = isValueOrder() || isMarket()
        val orderUnit:Int = if(isMarket && isOpen){
            1
        }else if(mContractUint==0){
            0
        }else{
            2
        }

        val mCpCreateOrderBean = CpCreateOrderBean(
            mContractId,
            positionType,
            if (isOpen) "OPEN" else "CLOSE",
            side,
            orderType,
            level,
            if (isMarketPriceModel) "0" else price,
            orderNum,
            isConditionOrder,
            triggerPrice,
            expireTime,
            isStopLoss,
            stopProfitPrice,
            stopLossPrice,
            orderUnit = orderUnit
        )
        val titleColor = CpColorUtil.getMainColorType(side.equals("BUY"))
        if (isOpen && side.equals("BUY")) {
            dialogTitle = CpLanguageUtil.getString(context, "cp_overview_text13")//Purchase of Kaiduo
        } else if (isOpen && side.equals("SELL")) {
            dialogTitle = CpLanguageUtil.getString(context, "cp_overview_text14")//Selling open space
        } else if (!isOpen && side.equals("BUY")) {
            dialogTitle = CpLanguageUtil.getString(context, "cp_extra_text4")//Purchase of Ping Kong
        } else if (!isOpen && side.equals("SELL")) {
            dialogTitle = CpLanguageUtil.getString(context, "cp_extra_text5")//Sales of Pingduo
        }
        val contractName = CpClLogicContractSetting.getContractShowNameById(context, mContractId)
        val contractSide = CpClLogicContractSetting.getContractSideById(context, mContractId)
        var mAmoutValue = ""
        val base = mContractJson?.optString("base")
        val quote = mContractJson?.optString("quote")
        mAmoutValue = if (buyOrSellHelper.orderType == 2 && isOpen) {
            "$volume $marginCoin"
        } else if (buyOrSellHelper.orderType == 3 && isMarketPriceModel && isOpen) {
            "$volume $marginCoin"
        } else {
            if(isValueOrder()){
                val isForward = "1".equals(this.contractSide)
                CpBigDecimalUtils.canUSDTPositionStr(isForward,volume,price,multiplierPrecision,mContractJson?.optString("multiplierCoin"))
            }else{
                volume + " " + if (mContractUint == 0) CpLanguageUtil.getString(context, "cp_overview_text9") else mContractJson?.optString("multiplierCoin")
            }
        }
        if (isPercentPlaceOrder) {
            mAmoutValue = mEditCtrl.text.toString()
        }
        var showPrice = ""
        var showTriggerPrice = ""

        showPrice = if (isMarketPriceModel) {
            CpLanguageUtil.getString(context, "cp_overview_text53")
        } else {
            if (isRivalPriceModel) {
                if (buyOrSellHelper.rivalPricePosition == 0) {
                    CpLanguageUtil.getString(context, "cp_overview_text38")
                } else if (buyOrSellHelper.rivalPricePosition == 4) {
                    CpLanguageUtil.getString(context, "cp_overview_text39")
                } else {
                    CpLanguageUtil.getString(context, "cp_overview_text40")
                }
            } else {
                price + " " + quote
            }
        }
        showTriggerPrice = triggerPrice + " " + quote
        val showTag = marginModel.toString() + level.toString() + "X"
        val tradeConfirm = CpPreferenceManager.getInstance(CpMyApp.instance())
            .getSharedBoolean(CpPreferenceManager.PREF_TRADE_CONFIRM, true)
        if (tradeConfirm) {
            CpDialogUtil.showCreateOrderDialog(context,
                titleColor,
                dialogTitle,
                contractName,
                showPrice,
                showTriggerPrice,
                tv_buy_cost.text.toString(),
                mAmoutValue,
                buyOrSellHelper.orderType,
                stopProfitPrice,
                stopLossPrice,
                quote.toString(),
                showTag,
                object : CpNewDialogUtils.DialogBottomListener {
                    override fun sendConfirm() {
                        val event = CpMessageEvent(CpMessageEvent.sl_contract_create_order_event)
                        event.msg_content = mCpCreateOrderBean
                        CpEventBusUtil.post(event)
                    }
                },isOpen)
        } else {
            val event = CpMessageEvent(CpMessageEvent.sl_contract_create_order_event)
            event.msg_content = mCpCreateOrderBean
            CpEventBusUtil.post(event)

        }
    }

    //is a value order?
    private fun isValueOrder() : Boolean {
        return buyOrSellHelper.isOpen && selectOrderType!=null && selectOrderType!!.first==1 && isNotMarket()
    }

    //is not market?
    private fun isNotMarket():Boolean{
        val tiggerOrderMarket = buyOrSellHelper.orderType==3 && isMarketPriceModel
        return buyOrSellHelper.orderType!=2 && !tiggerOrderMarket
    }

    private fun isMarket():Boolean {
        return (buyOrSellHelper.orderType == 2) || isMarketPriceModel
    }

    //Clear the input data quantity, stop profit and stop loss
    fun clearUiEtVal() {
        mEditCtrl.setText("")
        custom_seekbar.setProgress(0f)
        tv_buy_cost.setText("0"+marginCoin)
        tv_sell_cost.setText("0"+marginCoin)
        percent = "0.0"
        if(cb_stop_loss.isChecked){
            et_stop_profit_price.setText("")
            et_stop_loss_price.setText("")
        }
    }


    fun setCurrentOrderListInfo(jsonList: ArrayList<CpCurrentOrderBean>) {
        var entrustedValueBuff = BigDecimal.ZERO
        for (buff in jsonList) {
            var mOrderBalance = buff.orderBalance
            if (TextUtils.isEmpty(mOrderBalance)) {
                mOrderBalance = "0"
            }
            entrustedValueBuff = BigDecimal(mOrderBalance).add(entrustedValueBuff)
        }
        entrustedValue =
            entrustedValueBuff.setScale(multiplierPrecision, BigDecimal.ROUND_HALF_DOWN)
                .toPlainString()
    }

    fun setContractJsonInfo(json: JSONObject) {
        mContractUint = CpClLogicContractSetting.getContractUint(context)
        mContractJson = json
        mContractJson?.let {
            contractSide = it.optString("contractSide")
            marginRate = it.optString("marginRate")
            marginCoin = it.optString("marginCoin")
            multiplier = it.optString("multiplier")
            mContractId = it.getInt("id")

            setTransferStatus(it.getInt("classification"))
            var multiplierCoin = it.optString("multiplierCoin")
            base = if (mContractUint == 0) CpLanguageUtil.getString(
                context,
                "cp_overview_text9"
            ) else multiplierCoin
            quote = mContractJson?.optString("quote").toString()
            multiplierPrecision =
                CpClLogicContractSetting.getContractMultiplierPrecisionById(context, mContractId)
            marginCoinPrecision =
                CpClLogicContractSetting.getContractMarginCoinPrecisionById(context, mContractId)
            symbolPricePrecision =
                CpClLogicContractSetting.getContractSymbolPricePrecisionById(context, mContractId)
            val volumeUnit = if (mContractUint == 0) {
                CpLanguageUtil.getString(context, "cp_overview_text9")
            } else {
                mContractJson?.optString("base")
            }
            val equivalentUnit = if (mContractUint != 0) {
                CpLanguageUtil.getString(context, "cp_overview_text9")
            } else {
                mContractJson?.optString("base")
            }
            if(buyOrSellHelper.isOpen){
                mEditCtrl.hint = CpLanguageUtil.getString(context, "cp_order_text43")
            }else{
                mEditCtrl.hint = CpLanguageUtil.getString(context, "cp_order_text43") + "($volumeUnit)"
            }

//            tv_volume_unit.setText(volumeUnit)
            tv_coin_name.setText(quote)
            tv_equivalent.setText("≈ 0 " + equivalentUnit)
            et_price.numberFilter(symbolPricePrecision, otherFilter = object : CpDoListener {
                override fun doThing(obj: Any?): Boolean {
                    updateAvailableVol()
                    return true
                }
            })
            setEtPriceStep()

            var coinResultVo = JSONObject(mContractJson?.optString("coinResultVo"))
            var minOrderMoney = coinResultVo.optString("minOrderMoney")//Minimum order amount
            minOrderMoney=CpBigDecimalUtils.showSNormal(minOrderMoney)
            var minOrderMoneyArr= minOrderMoney.split(".")
            if(minOrderMoneyArr.size>1){
                minOrderMoneyPrecision=minOrderMoneyArr[1].length
            }

            if (isMarket() && transactionType == CpParamConstant.TYPE_BUY) {
                quantityPrecision = minOrderMoneyPrecision
            }

            mEditCtrl?.numberFilter(quantityPrecision)
            setETCtrlStep()
            this.mUserAssetsInfoJson?.let { it1 -> setUserAssetsInfo(it1) }

            if(selectOrderType==null && buyOrSellHelper.isOpen && isNotMarket()) {
                val orderSelectTypeList = getOrderTypeDataList()
                selectOrderType=Pair(orderSelectTypeList[0].index,orderSelectTypeList[0].name)
                changeSelectOrderType(selectOrderType)
            }
            doRefshSelectOrderTypeUnit()

        }

    }

    private fun doRefshSelectOrderTypeUnit(){
        if(!isNotMarket()) return
        if(selectOrderType == null) return
        if(!buyOrSellHelper.isOpen) return
        val unit = selectOrderType!!.first
        mContractJson?.run {
            if(unit==0){
                //Order by quantity
                val quantitySelect = if(mContractUint==0) {
                    CpLanguageUtil.getString(context, "cp_overview_text9")
                }else{
                    if("1".equals(contractSide)) optString("base") else optString("quote")
                }
                tv_type_unit.text = quantitySelect
                quantityPrecision = if(mContractUint==0) 0 else multiplierPrecision
            }

            if(unit==1){
                //Order by value
                val valueSelect = if("1".equals(contractSide)){
                    //Forward contract: The unit is the currency of account, for example, BTCUSDT, and the currency of account is USDT
                    optString("quote")
                }else{
                    optString("base")
                }
                quantityPrecision = minOrderMoneyPrecision
                tv_type_unit.text = valueSelect
            }
            mEditCtrl?.numberFilter(quantityPrecision)
        }
    }

    //Set whether transfer is allowed for simulated contracts. Transfer is not allowed
    fun setTransferStatus(classification:Int){
        ly_transfer.isClickable = classification != 4
        icon_transfer.setTransferStatus(classification)
    }

    fun setUserConfigInfo(json: JSONObject) {
        mUserConfigInfoJson = json
        mUserConfigInfoJson?.let {
            level = it.optInt("nowLevel")
            marginModel = if (it.optInt("marginModel") == 1) CpLanguageUtil.getString(
                context,
                "cp_contract_setting_text1"
            ) else CpLanguageUtil.getString(context, "cp_contract_setting_text2")
            positionType = it.optString("positionModel")
            buyOrSellHelper.isOneWayPosition = (!positionType.equals("2"))
            var coUnit = it.optInt("coUnit")//Contract unit 1 target currency, 2 sheets
            CpClLogicContractSetting.setContractUint(
                context,
                if (coUnit == 1) 1 else 0
            )
//            CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.sl_contract_change_unit_event))

            if (!it.isNull("leverOriginCeiling")) {
                val leverOriginCeilingObj = it.optJSONObject("leverOriginCeiling")
                val iteratorKeys = leverOriginCeilingObj.keys()
                var leverOriginCeilingArr = ArrayList<Int>()
                while (iteratorKeys.hasNext()) {
                    val key = iteratorKeys.next().toInt()
                    leverOriginCeilingArr.add(key)
                }
                leverOriginCeilingArr.sort()
                for (buff in leverOriginCeilingArr) {
                    if (level.toInt() <= buff.toInt()) {
                        maxOpenLimit = leverOriginCeilingObj.optString(buff.toString())
                        break
                    }
                }
            }
        }
        if (positionType.equals("1")) {
            transactionType =
                if (!cb_only_reduce_positions.isChecked) CpParamConstant.TYPE_BUY else CpParamConstant.TYPE_SELL
            changeBuyOrSellUI()
            if (isFrist) {
                val mCpMessageEvent = CpMessageEvent(CpMessageEvent.sl_contract_modify_depth_event)
                mCpMessageEvent.msg_content = buyOrSellHelper
                CpEventBusUtil.post(mCpMessageEvent)
            }
            isFrist = false
        }
        mContractUint = CpClLogicContractSetting.getContractUint(context)


        mContractJson?.let {
            setContractJsonInfo(it)
        }
    }

    var isFrist = true

    fun setUserAssetsInfo(json: JSONObject) {
        canCloseVolumeSell = "0"
        canCloseVolumeBuy = "0"
        positionValue = "0"
        canUseAmount = "0"
        mUserAssetsInfoJson = json
        mUserAssetsInfoJson?.apply {
            canUseAmount = optString("canUseAmount")
            if (!isNull("positionList")) {
                val mOrderListJson = optJSONArray("positionList")
                var positionValueBuff = BigDecimal.ZERO
                for (i in 0..(mOrderListJson.length() - 1)) {
                    val obj = mOrderListJson.getJSONObject(i)
                    if (obj.getInt("contractId") == mContractId) {
                        var canCloseVolume =
                            obj.getString("canCloseVolume")
                        var orderSid =
                            obj.getString("orderSide")
                        if (orderSid.equals("BUY")) {
                            canCloseVolumeSell = canCloseVolume
                        } else if (orderSid.equals("SELL")) {
                            canCloseVolumeBuy = canCloseVolume
                        }
                        positionValueBuff =
                            BigDecimal(obj.optString("positionBalance")).add(
                                positionValueBuff
                            )
                    }
                    LogUtils.e("canCloseVolumeBuy:" + canCloseVolumeBuy)
                    LogUtils.e("canCloseVolumeSell:" + canCloseVolumeSell)
                }
                positionValue =
                    positionValueBuff.setScale(multiplierPrecision, BigDecimal.ROUND_HALF_DOWN)
                        .toPlainString()
            }
            if (!isNull("accountList")) {
                val mOrderListJson = optJSONArray("accountList")
                for (i in 0..(mOrderListJson.length() - 1)) {
                    val obj = mOrderListJson.getJSONObject(i)
                    if (mContractJson?.optString("marginCoin")
                            .toString()
                            .equals(obj.optString("symbol"))
                    ) {
                        canUseAmount = obj.getString("canUseAmount")
                        canUseAmount =
                            CpBigDecimalUtils.scaleStr(
                                canUseAmount,
                                3
                            )
                    }
                }
            }
            updateAvailableVol()
        }

    }

    private fun adjustRatio() {
        //Calculate the multiple costs that can be opened
        updateAvailableVol()
    }

    private fun updateAvailableVol(showBalanceInsufficientTips : Boolean? = false) {
        val isValueOrder = isValueOrder()
        //Remove All
        mEditCtrl.setCtrlGone(true)
        et_price.setCtrlGone(false)

        var isOpen = false;
        if (transactionType == CpParamConstant.TYPE_BUY) {
            isOpen = true
        } else {
            isOpen = false
        }
        if (positionType.equals("1")) {
            isOpen = !cb_only_reduce_positions.isChecked
        }


        val contractUint = CpClLogicContractSetting.getContractUint(context)

        tv_equivalent.visibility = if(isValueOrder){
            // If it is a value order, you need to show the conversion
            View.VISIBLE
        }else{
            // If it is the current price, and the currency set by the contract, and the currency selected by the unit to place an order, conversion is not displayed, and conversely, conversion is displayed
            if(isNotMarket() && isOpen && contractUint==1) View.INVISIBLE else View.VISIBLE
        }

        if (!isOpen) tv_equivalent.visibility = View.INVISIBLE


        if (isOpen) {
            tv_long_title.onLineText("cp_overview_text46")
            tv_short_title.onLineText("cp_overview_text37")
        } else {
            tv_long_title.onLineText("cp_overview_text18")
            tv_short_title.onLineText("cp_overview_text17")
        }
        ChainUpLogUtil.e("-------base:" + base)
//        tv_volume_unit.setText(base)

        if(isOpen){

            mEditCtrl.hint = CpLanguageUtil.getString(context, "cp_overview_text8")
        }else{

            mEditCtrl.hint = CpLanguageUtil.getString(context, "cp_overview_text8") + "($base)"
        }

        if (isOpen && buyOrSellHelper.orderType == 2) {
            mEditCtrl.hint = CpLanguageUtil.getString(
                context,
                "cp_overview_text28"
            ) + "(${marginCoin})"
        }
        if (isOpen && buyOrSellHelper.orderType == 3 && isMarketPriceModel) {
            mEditCtrl.setHint(CpLanguageUtil.getString(context, "cp_overview_text28"))
            mEditCtrl.hint = CpLanguageUtil.getString(
                context,
                "cp_overview_text28"
            ) + "(${marginCoin})"

        }
        price = et_price.text.toString()
        triggerPrice = et_trigger_price.text.toString()
        val triggerPrice = et_trigger_price.text.toString()
        if (TextUtils.isEmpty(price)) {
            price = "0"
        }
        var buyPrice = price
        var sellPrice = price

        if (isRivalPriceModel) {
            sellMaxPriceList.sortBy {
                it.optDouble(0)
            }
            if (sellMaxPriceList.size > buyOrSellHelper.rivalPricePosition) {
                buyPrice =
                    sellMaxPriceList[buyOrSellHelper.rivalPricePosition].optDouble(0).toString()
            }
            if (buyMaxPriceList.size > buyOrSellHelper.rivalPricePosition) {
                sellPrice =
                    buyMaxPriceList[buyOrSellHelper.rivalPricePosition].optDouble(0).toString()
            }
        }
        LogUtils.e("-------- buyPrice:" + buyPrice)
        LogUtils.e("-------- sellPrice:" + sellPrice)
        var positionAmount = mEditCtrl.text.toString()
        var buyPositionAmount = positionAmount
        var sellPositionAmount = positionAmount
        if (TextUtils.isEmpty(positionAmount)) {
            positionAmount = "0"
        }


        val maxMarginCoinCanOpenValue = CpBigDecimalUtils.calcMaxValueByMarginCoinAmount(canUseAmount,level.toString())
        val maxRiskCanOpenValue = CpBigDecimalUtils.calcMaxValueByRisk(maxOpenLimit, positionValue, entrustedValue)
        maxOpenValue = CpBigDecimalUtils.getMaxCanOpenValue(maxRiskCanOpenValue,maxMarginCoinCanOpenValue)
        canOpenBuy = CpBigDecimalUtils.getUIMaxOpen(contractSide.equals("1"),isOpen,multiplier,buyPrice,maxOpenValue,canCloseVolumeBuy,multiplierPrecision,base)
        canOpenSell = CpBigDecimalUtils.getUIMaxOpen(contractSide.equals("1"),isOpen,multiplier,sellPrice,maxOpenValue,canCloseVolumeSell,multiplierPrecision,base)


        //jira:https://jira.dw2nn.com/browse/BIGFUTURES-2453
        if(!CpBigDecimalUtils.greaterThan(canOpenBuy,"0")){
            canOpenBuy = if(contractUint==0) "0" else "0.00"
        }
        if(!CpBigDecimalUtils.greaterThan(canOpenSell,"0")){
            canOpenSell = if(contractUint==0) "0" else "0.00"
        }


        if (isPercentPlaceOrder) {
            Log.d("wangbadan","canOpenBuy>>>"+canOpenBuy)
            positionAmount = CpBigDecimalUtils.mulStr(canOpenBuy, percent, if(contractUint==0) 0 else multiplierPrecision)
            if(isValueOrder && isOpen) {
                val buff = CpBigDecimalUtils.mulStr(maxOpenValue, percent, multiplierPrecision)
//                positionAmount = CpBigDecimalUtils.mulStr(buff, level.toString(), multiplierPrecision)
                positionAmount = buff
            }
            buyPositionAmount = positionAmount
            sellPositionAmount = positionAmount
        }


        if(!isOpen){
            ll_quantity_type.visibility = View.GONE
        }
        when (buyOrSellHelper.orderType) {
            1, 4, 5, 6 -> {

                if(isOpen){
                    ll_quantity_type.visibility = View.VISIBLE

                }
            }
            2 -> {
                ll_quantity_type.visibility = View.GONE
                if (isOpen) {
                    price = CpBigDecimalUtils.median(
                        buyMaxPrice,
                        askMaxPrice,
                        lastPrice
                    )
                    buyPrice = price
                    sellPrice = price
                }
                if (isOpen && isPercentPlaceOrder) {
//                    if (mContractUint == 0) {
//                        if (contractSide.equals("1")) {
//                            positionAmount = BigDecimal(positionAmount).multiply(BigDecimal(price)).multiply(BigDecimal(multiplier)).toPlainString()
//                        } else {
//                            positionAmount = BigDecimal(positionAmount).multiply(BigDecimal(multiplier)).divide(BigDecimal(multiplier), symbolPricePrecision, BigDecimal.ROUND_DOWN).toPlainString()
//                        }
//                    } else {
//                        if (contractSide.equals("1")) {
//                            positionAmount = CpBigDecimalUtils.mulStr(positionAmount, price, symbolPricePrecision)
//                        } else {
//                            positionAmount = CpBigDecimalUtils.divStr(positionAmount, price, symbolPricePrecision)
//                        }
//                    }
                    var buff = CpBigDecimalUtils.mulStr(maxOpenValue, percent, multiplierPrecision)
//                    positionAmount =
//                        CpBigDecimalUtils.mulStr(buff, level.toString(), multiplierPrecision)
                    positionAmount = buff
                    buyPositionAmount = positionAmount
                    sellPositionAmount = positionAmount
                }
            }
            3 -> {
                et_price.setCtrlGone(true)
                if (isOpen) {
                    if (isMarketPriceModel) {
                        price = triggerPrice
                        ll_quantity_type.visibility = View.GONE

                    }else{
                        ll_quantity_type.visibility = View.VISIBLE

                    }
                    buyPrice = price
                    sellPrice = price
                }
                if (isOpen && isPercentPlaceOrder && isMarketPriceModel) {
//                    if (mContractUint == 0) {
//                        if (contractSide.equals("1")) {
//                            positionAmount = BigDecimal(positionAmount).multiply(BigDecimal(price)).multiply(BigDecimal(multiplier)).toPlainString()
//                        } else {
//                            positionAmount = BigDecimal(positionAmount).multiply(BigDecimal(multiplier)).divide(BigDecimal(multiplier), symbolPricePrecision, BigDecimal.ROUND_DOWN).toPlainString()
//                        }
//                    } else {
//                        if (contractSide.equals("1")) {
//                            positionAmount = CpBigDecimalUtils.mulStr(positionAmount, price, symbolPricePrecision)
//                        } else {
//                            positionAmount = CpBigDecimalUtils.divStr(positionAmount, price, symbolPricePrecision)
//                        }
//                    }
                    var buff = CpBigDecimalUtils.mulStr(maxOpenValue, percent, multiplierPrecision)
//                    positionAmount =
//                        CpBigDecimalUtils.mulStr(buff, level.toString(), multiplierPrecision)
                    positionAmount = buff
                    buyPositionAmount = positionAmount
                    sellPositionAmount = positionAmount
                }
            }
        }

        //Calculate estimated cost price
        val buyCostbuff1 = CpBigDecimalUtils.canCostStr(
            isOpen,
            contractSide.equals("1"),
            if(isValueOrder) 2 else buyOrSellHelper.orderType,
            buyPrice,
            if(buyPositionAmount.equals("0")) "" else buyPositionAmount,
            multiplier,
            level.toString(),
            marginRate,
            marginCoinPrecision,
            marginCoin
        )
        //Calculate estimated cost price
        val sellCostbuff1 = CpBigDecimalUtils.canCostStr(
            isOpen,
            contractSide.equals("1"),
            if(isValueOrder) 2 else buyOrSellHelper.orderType,
            sellPrice,
            if(sellPositionAmount.equals("0")) "" else sellPositionAmount,
            multiplier,
            level.toString(),
            marginRate,
            marginCoinPrecision,
            marginCoin
        )
        buyCost = buyCostbuff1.split(" ")[0]
        sellCost = sellCostbuff1.split(" ")[0]

        if (!CpStringUtil.isNumeric(positionAmount)) {
            return
        }


        val unit =
            if (CpClLogicContractSetting.getContractUint(context) == 0) mContractJson?.optString("multiplierCoin") else CpLanguageUtil.getString(
                context,
                "cp_overview_text9"
            )

        tv_equivalent.text = if(isValueOrder){
            "≈ " + CpBigDecimalUtils.canUSDTPositionStr(
                "1".equals(contractSide),
                positionAmount,
                price,
                multiplierPrecision,
                mContractJson?.optString("multiplierCoin")
            )
        }else{
            "≈ " + CpBigDecimalUtils.canPositionStr(
                positionAmount,
                multiplier,
                multiplierPrecision,
                unit
            )
        }

        if (isOpen && buyOrSellHelper.orderType == 2) {
            tv_equivalent.text = "≈ " + CpBigDecimalUtils.canPositionMarketStr(
                contractSide.equals("1"),
                marginRate,
                multiplier,
                positionAmount,
                price,
                multiplierPrecision,
                if (CpClLogicContractSetting.getContractUint(context) == 0) CpLanguageUtil.getString(
                    context,
                    "cp_overview_text9"
                ) else mContractJson?.optString("multiplierCoin"),
                true
            )
        }
        if (isOpen && buyOrSellHelper.orderType == 3 && isMarketPriceModel) {
            tv_equivalent.text = "≈ " + CpBigDecimalUtils.canPositionMarketStr(
                contractSide.equals("1"),
                marginRate,
                multiplier,
                positionAmount,
                price,
                multiplierPrecision,
                if (CpClLogicContractSetting.getContractUint(context) == 0) CpLanguageUtil.getString(
                    context,
                    "cp_overview_text9"
                ) else mContractJson?.optString("multiplierCoin"),
                true
            )
        }



        //Actual needs
       var actualBuy= buyCostbuff1.split(" ")[0]
        //Available balance
       var mAvailable= mAvailableVal.text.split(" ")[0]
        if (showBalanceInsufficientTips == true &&CpBigDecimalUtils.greaterThan(actualBuy,mAvailable)){
            ToastUtils.showToast(context,CpLanguageUtil.getString(context,"common_tip_balanceNotEnough"))
        }

        tv_buy_cost.setText(buyCostbuff1)
        tv_sell_cost.setText(sellCostbuff1)


        tv_long_value.setText(canOpenBuy + " " + base)
        tv_short_value.setText(canOpenSell + " " + base)


        val llLongTitle = ll_long_title.layoutParams as LinearLayout.LayoutParams
        val llShortTitle = ll_short_title.layoutParams as LinearLayout.LayoutParams

        buyOrSellHelper.isOpen = isOpen
        buyOrSellHelper.isOto = cb_stop_loss.isChecked
        //Change spacing based on order type
        if (positionType.equals("2")) {
            //Two-way position
            when (buyOrSellHelper.orderType) {
                1, 4, 5, 6 -> {
                    if (isOpen) {
                        if (cb_stop_loss.isChecked) {
                            llLongTitle.topMargin = SizeUtils.dp2px(12f)
                            llShortTitle.topMargin = SizeUtils.dp2px(12f)
                        } else {
                            llLongTitle.topMargin = SizeUtils.dp2px(12f)
                            llShortTitle.topMargin = SizeUtils.dp2px(12f)
                        }
                    } else {
                        llLongTitle.topMargin = SizeUtils.dp2px(10f)
                        llShortTitle.topMargin = SizeUtils.dp2px(12f)
                    }
                }
                2 -> {
                    if (isOpen) {
                        if (cb_stop_loss.isChecked) {
                            llLongTitle.topMargin = SizeUtils.dp2px(32f)
                            llShortTitle.topMargin = SizeUtils.dp2px(30f)
                        } else {
                            llLongTitle.topMargin = SizeUtils.dp2px(12f)
                            llShortTitle.topMargin = SizeUtils.dp2px(16f)
                        }
                    } else {
                        llLongTitle.topMargin = SizeUtils.dp2px(10f)
                        llShortTitle.topMargin = SizeUtils.dp2px(12f)
                    }
                }
                3 -> {
                    if (isOpen) {
//                        llLongTitle.topMargin = SizeUtils.dp2px(30f)
//                        llShortTitle.topMargin = SizeUtils.dp2px(24f)
                        llLongTitle.topMargin = SizeUtils.dp2px(4f)
                        llShortTitle.topMargin = SizeUtils.dp2px(10f)
                    } else {
                        llLongTitle.topMargin = SizeUtils.dp2px(4f)
                        llShortTitle.topMargin = SizeUtils.dp2px(10f)
                    }
                }
            }
        } else {
            //One-way position
            when (buyOrSellHelper.orderType) {
                1, 4, 5, 6 -> {
                    if (isOpen) {
                        if (cb_stop_loss.isChecked) {
                            llLongTitle.topMargin = SizeUtils.dp2px(18f)
                            llShortTitle.topMargin = SizeUtils.dp2px(12f)
                        } else {
                            llLongTitle.topMargin = SizeUtils.dp2px(20f)
                            llShortTitle.topMargin = SizeUtils.dp2px(12f)
                        }
                    } else {
                        llLongTitle.topMargin = SizeUtils.dp2px(18f)
                        llShortTitle.topMargin = SizeUtils.dp2px(12f)
                    }
                }
                2 -> {
                    if (isOpen) {
                        if (cb_stop_loss.isChecked) {
                            llLongTitle.topMargin = SizeUtils.dp2px(20f)
                            llShortTitle.topMargin = SizeUtils.dp2px(12f)
                        } else {
                            llLongTitle.topMargin = SizeUtils.dp2px(20f)
                            llShortTitle.topMargin = SizeUtils.dp2px(12f)
                        }
                    } else {
                        llLongTitle.topMargin = SizeUtils.dp2px(14f)
                        llShortTitle.topMargin = SizeUtils.dp2px(20f)
                    }
                }
                3 -> {
                    if (isOpen) {
                        llLongTitle.topMargin = SizeUtils.dp2px(6f)
                        llShortTitle.topMargin = SizeUtils.dp2px(19f)
                    } else {
                        llLongTitle.topMargin = SizeUtils.dp2px(0f)
                        llShortTitle.topMargin = SizeUtils.dp2px(20f)
                    }
                }
            }
        }
    }

    private fun updataMarketPriceUI() {
        tv_price_hint?.setBackgroundResource(if (!isMarketPriceModel) R.drawable.bg_select_contract else R.drawable.bg_selected_bbo)
        tv_price_hint?.setTextColor(this.resources.getColor(R.color.text_color_1))
        ll_price.visibility = if (!isMarketPriceModel) View.VISIBLE else View.GONE
        tv_order_tips_layout_plan.visibility = if (isMarketPriceModel) View.VISIBLE else View.GONE
    }


    private fun updataRivalPriceUI() {
        ll_price.visibility = if (!isRivalPriceModel) View.VISIBLE else View.GONE
        tv_rival_price_type.visibility = if (isRivalPriceModel) View.VISIBLE else View.GONE
        tv_rival_price_hint?.setBackgroundResource(if (!isRivalPriceModel) R.drawable.bg_select_contract else R.drawable.bg_selected_bbo)
        tv_rival_price_hint?.setTextColor(this.resources.getColor(R.color.text_color_1))
    }

    fun changeBuyOrSellUI() {
//        et_price.setText("")
        when (this.transactionType) {
            //Buy
            CpParamConstant.TYPE_BUY -> {
                rb_buy?.run {
//                    typeface = Typeface.defaultFromStyle(Typeface.BOLD)
                    setTextColor(ContextCompat.getColor(context!!, R.color.text_4))
                    backgroundResource = R.drawable.ic_contract_openpositions_hover
                }

                rb_sell?.run {
//                    typeface = Typeface.defaultFromStyle(Typeface.NORMAL)
                    setTextColor(ContextCompat.getColor(context!!, R.color.text_color_2))
                    backgroundResource = R.drawable.contract_unwind
                }

                ll_buy_cost.visibility = View.VISIBLE
                ll_sell_cost.visibility = View.VISIBLE
                if (buyOrSellHelper.orderType != 3) {
                    ll_stop_loss.visibility = View.VISIBLE
                } else {
                    ll_stop_loss.visibility = View.INVISIBLE
                    cb_stop_loss.isChecked = false
                }

                btn_sell.textContent = CpLanguageUtil.getString(context, "cp_overview_text14")
                btn_buy.textContent = CpLanguageUtil.getString(context, "cp_overview_text13")
            }
            //Sell
            CpParamConstant.TYPE_SELL -> {
                rb_buy?.run {
//                    typeface = Typeface.defaultFromStyle(Typeface.NORMAL)
                    setTextColor(ContextCompat.getColor(context!!, R.color.text_color_2))
                    backgroundResource = R.drawable.contract_openpositions
                }

                rb_sell?.run {
//                    typeface = Typeface.defaultFromStyle(Typeface.BOLD)
                    setTextColor(ContextCompat.getColor(context!!, R.color.text_4))
                    backgroundResource = R.drawable.ic_contract_unwind_hover
                }

                ll_buy_cost.visibility = View.GONE
                ll_sell_cost.visibility = View.GONE
                ll_stop_loss.visibility = View.INVISIBLE
                cb_stop_loss.isChecked = false
                btn_sell.textContent = CpLanguageUtil.getString(context, "cp_extra_text5")
                btn_buy.textContent = CpLanguageUtil.getString(context, "cp_extra_text4")
            }
        }
        btn_sell.normalBgColor = CpColorUtil.getMainColorType(isRise = false)
        btn_buy.normalBgColor = CpColorUtil.getMainColorType(isRise = true)
        val mCpMessageEvent=  CpMessageEvent(CpMessageEvent.sl_contract_modify_depth_event)
        mCpMessageEvent.msg_content=buyOrSellHelper
        CpEventBusUtil.post(mCpMessageEvent)
        updateAvailableVol()
    }


    fun changePriceType(item: Int, text: String? = "") {
        CpClLogicContractSetting.setExecution(CpMyApp.instance(), 0)
        et_price.setText(this.lastPriceing)

        custom_seekbar.setProgress(0f)
        mEditCtrl.setText("")
        mEditCtrl.clearFocus()
        et_trigger_price.setText("")
        buyOrSellHelper.orderType = item
        tv_order_tips_layout.visibility = View.GONE
        ll_trigger_price.visibility = View.GONE
        tv_price_hint.visibility = View.GONE
        tv_rival_price_hint.visibility = View.GONE
        tv_order_tips_layout_plan.visibility = View.GONE
        ll_all_price.visibility = View.VISIBLE
        isRivalPriceModel = false
        isMarketPriceModel = false
        isPercentPlaceOrder = false
        updataMarketPriceUI()
        changeBuyOrSellUI()
        updataRivalPriceUI()
        val mCpMessageEvent = CpMessageEvent(CpMessageEvent.sl_contract_modify_depth_event)
        mCpMessageEvent.msg_content = buyOrSellHelper
        CpEventBusUtil.post(mCpMessageEvent)


        when (item) {
            1 -> {
                //Price limit order
                ll_price.visibility = View.VISIBLE
                //contract_demand: Remove the counter price option from the "price" in the ordering area;
                tv_rival_price_hint.visibility = View.GONE
                tv_order_type?.setTipDialogContent(
                    CpPriceTypeButton.TipDialogContent(
                        text!!,
                        CpLanguageUtil.getString(context, "limit_order_tip")
                    )
                )
                AppAnalyticsExt.instance.clickAction(AppAnalyticsExt.APP_FUTURES_SWITCH_ORDER,mapOf("limit_order" to 1))
            }
            2 -> {
                //Market Price List
                ll_price.visibility = View.GONE
                ll_all_price.visibility = View.GONE
                tv_order_tips_layout.visibility = View.VISIBLE
                CpClLogicContractSetting.setExecution(CpMyApp.instance(), 1)
                tv_order_type?.setTipDialogContent(
                    CpPriceTypeButton.TipDialogContent(
                        text!!,
                        CpLanguageUtil.getString(context, "market_order_tip")
                    )
                )
                selectOrderType = null

                AppAnalyticsExt.instance.clickAction(AppAnalyticsExt.APP_FUTURES_SWITCH_ORDER,mapOf("market_order" to 1))
            }
            3 -> {
                //Condition sheet
                ll_price.visibility = View.VISIBLE
                ll_trigger_price.visibility = View.VISIBLE
                tv_price_hint.visibility = View.VISIBLE


                tv_order_type?.setTipDialogContent(
                    CpPriceTypeButton.TipDialogContent(
                        text!!,
                        CpLanguageUtil.getString(context, "trigger_order_tip")
                    )
                )
            }
            4 -> {
                //PostOnly
                ll_price.visibility = View.VISIBLE
                tv_order_type?.setTipDialogContent(
                    CpPriceTypeButton.TipDialogContent(
                        text!!,
                        CpLanguageUtil.getString(context, "post_only_tip")
                    )
                )
            }
            5 -> {
                //IOC
                ll_price.visibility = View.VISIBLE
                tv_order_type?.setTipDialogContent(
                    CpPriceTypeButton.TipDialogContent(
                        text!!,
                        CpLanguageUtil.getString(context, "ioc_tip")
                    )
                )
            }
            6 -> {
                //FOK
                ll_price.visibility = View.VISIBLE
                tv_order_type?.setTipDialogContent(
                    CpPriceTypeButton.TipDialogContent(
                        text!!,
                        CpLanguageUtil.getString(context, "fok_tip")
                    )
                )
            }
        }


    }

    fun getActivity(): Activity? {
        if (context is Activity) {
            return context as Activity
        }
        return null
    }

    private fun kycTips(s: String) {
        CpNewDialogUtils.showDialog(
            context!!,
            s,
            true,
            null,
            CpLanguageUtil.getString(context, "cp_extra_text27"),
            CpLanguageUtil.getString(context, "cp_overview_text56")
        )
    }

    private fun goKycTips(s: String) {
        CpNewDialogUtils.showDialog(
            context!!,
            s.replace("\n", "<br/>"),
            false,
            object : CpNewDialogUtils.DialogBottomListener {
                override fun sendConfirm() {
                    CpEventBusUtil.post(
                        CpMessageEvent(CpMessageEvent.sl_contract_go_kyc_page)
                    )
                }
            },
            CpLanguageUtil.getString(context, "cp_kyc_1"),
            CpLanguageUtil.getString(context, "cp_kyc_6"),
            CpLanguageUtil.getString(context, "cp_overview_text56")
        )
    }


    //Set up funds
    fun setAvailableAssets(value: String, unit: String? = "") {
        mAvailableVal.text = "$value $unit"
    }



    //Set transfer click
    interface OnTransferClick {
        fun click()
    }


}




