package com.yjkj.chainup.new_version.view.depth

import android.app.Activity
import android.content.Context
import android.graphics.Typeface
import android.os.Bundle
import android.text.Editable
import android.text.TextUtils
import android.text.TextWatcher
import android.util.AttributeSet
import android.util.Log
import android.view.Gravity
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.widget.LinearLayout
import android.widget.RadioButton
import androidx.core.content.ContextCompat
import androidx.lifecycle.Observer
import com.chainup.contract.listener.CpDoListener
import com.chainup.contract.view.CpDialogUtil
import com.chainup.contract.view.CpNewDialogUtils
import com.jakewharton.rxbinding2.view.RxView
import com.chainup.talkingdata.AppAnalyticsExt
import com.chainup.contract.view.dialog.CpTDialog
import com.chainup.kit.bean.KKItemTabInfo
import com.chainup.kit.utils.ToastUtils
import com.chainup.kit.utils.numberFilter
import com.chainup.kit.views.KKPopupSelectKit
import com.chainup.kit.views.KKSelectRatioViewKit
import com.chainup.kit.views.KKTradeTabBarKit
import com.yjkj.chainup.R
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.ParamConstant.*
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.extra_service.eventbus.EventBusUtil
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.extra_service.eventbus.NLiveDataUtil
import com.yjkj.chainup.manager.*
import com.yjkj.chainup.model.model.MainModel
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_version.activity.NewMainActivity
import com.yjkj.chainup.new_version.activity.leverage.TradeFragment
import com.yjkj.chainup.new_version.dialog.DialogUtil
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.view.CommonlyUsedButton
import com.yjkj.chainup.util.*
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.CompositeDisposable
import kotlinx.android.synthetic.main.depth_vertical_layout.view.ll_etf_item
import kotlinx.android.synthetic.main.trade_amount_view_new.view.*
import kotlinx.android.synthetic.main.trade_header_tools.*
import org.jetbrains.anko.backgroundResource
import org.jetbrains.anko.doAsync
import org.jetbrains.anko.uiThread
import org.jetbrains.anko.view
import org.json.JSONArray
import org.json.JSONObject
import java.math.BigDecimal
import java.util.concurrent.TimeUnit

/**
 * @Author: Bertking
 * @Date 2023/3/7-5:43 PM
 *@description: View of transaction volume
 */
class TradeView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : LinearLayout(context, attrs, defStyleAttr) {

    val TAG = TradeView::class.java.simpleName


    private val delayTime = 100L

    //Transaction type
    var transactionType = ParamConstant.TYPE_BUY
    var isLever = false
    var isETF = false

    //Price Type
    var priceType = 0

    //Available balance
    var canUseMoney: String = "0"
    var inputPrice: String = ""
    var inputQuantity: String = ""

    var priceScale = 2

    var volumeScale = 2
    var etfInfo: JSONObject? = null

    private var isPriceLongClick: Boolean = false
    private var isStartPriceSubClick = false
    private var isStartPricePlusClick = false
    var disposable: CompositeDisposable? = null
    var mainModel: MainModel? = null
    var isVolumeFocus = false;

    var dialog: CpTDialog? = null
    var coinMapData: JSONObject? =
        NCoinManager.getSymbolObj(PublicInfoDataService.getInstance().currentSymbol)
        set(value) {

            field = value
            synchronized(this) {
                priceScale = value?.optInt("price", 2) ?: 2
                volumeScale = value?.optInt("volume", 2) ?: 2
            }

            tv_coin_name?.text = NCoinManager.getMarketCoinName(showAnoterName(value))

            LogUtil.d(
                TAG,
                "TradeView==coinMapData==priceScale ${context} is $priceScale,volumeScale is $volumeScale"
            )

            getAvailableBalance()

            /**
             *Set the selection effect of RadioButton
             */
            for (i in 0 until rg_trade.childCount step 2) {
                val radioButton = rg_trade?.getChildAt(i) as RadioButton
                radioButton.setTextColor(ColorUtil.getColor(R.color.normal_text_color))
                radioButton.backgroundResource = R.color.transparent
            }
            // et_price?.setText("")
            et_volume?.setText("")
            if (!StringUtil.checkStr(et_price?.text.toString())) {
                tv_convert_price?.text = "--"
            }

            tv_transaction_money?.setText("")
        }


    fun setPrice() {

        synchronized(this) {
            priceScale = coinMapData?.optInt("price", 2) ?: 2
            volumeScale = coinMapData?.optInt("volume", 2) ?: 2
        }


        et_price?.filters = arrayOf(DecimalDigitsInputFilter(priceScale))
        if (transactionType == ParamConstant.TYPE_BUY && priceType == ParamConstant.TYPE_MARKET) {
            et_volume?.filters = arrayOf(DecimalDigitsInputFilter(priceScale))
            LogUtil.d(TAG, "setPrice()==市价数量精度")
        } else {
            et_volume?.filters = arrayOf(DecimalDigitsInputFilter(volumeScale))
        }
    }

    private fun showAnoterName(jsonObject: JSONObject?): String {
        return NCoinManager.showAnoterName(jsonObject)
    }

    /**
     *Obtain available balance
     */

    fun getAvailableBalance() {

        if (!LoginManager.checkLogin(context, false)) {
            /**
             *Available balance
             */
            tv_available_balance?.text = "--"
            return
        }


    }

    fun setTextContent() {

//        tv_order_type?.textContent = LanguageUtil.getString(context, "contract_action_limitPrice")
        tv_transaction_text?.text = "${LanguageUtil.getString(context, "transaction_text_tradeSum")}(${showMarket()})"
        v_tb_bar.tvTabText1 = LanguageUtil.getString(context, "contract_action_buy")
        v_tb_bar.tvTabText2 = LanguageUtil.getString(context, "contract_action_sell")
        val buyOrSellPair = ColorUtil.getBuyOrSellPair(context)
        v_tb_bar.setTabSelectColor(buyOrSellPair.first, buyOrSellPair.second)
//        rb_buy?.text = LanguageUtil.getString(context, "contract_action_buy")
//        rb_sell?.text = LanguageUtil.getString(context, "contract_action_sell")
        tv_balance_text?.text = LanguageUtil.getString(context, "assets_text_available")
        et_price?.hint = LanguageUtil.getString(context, "contract_text_price")

    }

    init {
        attrs?.let {
            val typedArray = context.obtainStyledAttributes(it, R.styleable.ComVerifyView, 0, 0)
            typedArray.recycle()
        }


        LogUtil.d(TAG, "TradeView==init==priceScale is $priceScale,volumeScale is $volumeScale")
        /**
         *The value here must be: True
         */
        LayoutInflater.from(context).inflate(R.layout.trade_amount_view_new, this, true)

        setTextContent()



        v_tb_bar?.listener = object : KKTradeTabBarKit.OnKKTradeTabChangeListener {
            override fun onChange(position: Int) {
                when (position) {
                    0 -> {
                        transactionType = ParamConstant.TYPE_BUY
                        buyOrSell(transactionType, isLever)
                        showBalanceData()
                        initVolView()
                    }

                    1 -> {
                        transactionType = ParamConstant.TYPE_SELL
                        buyOrSell(transactionType, isLever)
                        showBalanceData()
                        initVolView()
                    }
                }
            }

        }

        observeData()

        NLiveDataUtil.observeData(this.context as NewMainActivity, Observer {
            if (it == null) return@Observer
            if (MessageEvent.login_operation_type == it.msg_type) {
                operator4PriceVolume(context)
                getAvailableBalance()
            }
        })
        tv_order_type?.apply {
            val list = ArrayList<KKItemTabInfo>()
            list.add(
                KKItemTabInfo(
                    LanguageUtil.getString(context, "contract_action_limitPrice"),
                    0
                )
            )
            list.add(
                KKItemTabInfo(
                    LanguageUtil.getString(context, "contract_action_marketPrice"),
                    1
                )
            )
            this.data = list
            this.currentPosition = 0
            this.setTipVisible(false)
            this.setSelectorGravity(Gravity.CENTER)
            this.listener = object : KKPopupSelectKit.OnKKPopupSelectListener {
                override fun onChangeSelect(position: Int) {
                    changePriceType(position)
                }

                override fun onPopTipClick(position: Int) {
                }

                override fun onSelectTipClick() {
                }

            }
        }
        getAvailableBalance()

        // cbtn_create_order?.normalBgColor = ColorUtil.getMainColorType()

        operator4Price(context)


        /**
         *Transaction volume
         */
        if (priceType == TYPE_MARKET) {
            ll_transaction?.visibility = View.INVISIBLE
//            tv_convert_price?.visibility = View.INVISIBLE

        } else {
            ll_transaction?.visibility = View.VISIBLE
            tv_transaction_money?.visibility = View.VISIBLE
            tv_transaction_money?.setText("")
//            tv_convert_price?.visibility = View.VISIBLE
        }


        /**
         *Transaction volume percentage
         *TODO code optimization
         */
        rg_trade?.setOnCheckedChangeListener { group, checkedId ->


            /**
             *Set the selection effect of RadioButton
             */
            for (i in 0 until rg_trade.childCount step 2) {
                val radioButton = rg_trade?.getChildAt(i) as RadioButton
                radioButton.setTextColor(ColorUtil.getCheck4ColorStateList(isBuy()))
                radioButton.background = ColorUtil.getCheck4StateListDrawable(isBuy())
            }

            if (checkedId > -1) {
                if (!LoginManager.checkLogin(context, true)) {
                    group.clearCheck()
                    return@setOnCheckedChangeListener
                }
            }

            when (checkedId) {
                R.id.rb_1st -> {
                    adjustRatio("0.25")
                }

                R.id.rb_2nd -> {
                    adjustRatio("0.50")
                }

                R.id.rb_3rd -> {
                    adjustRatio("0.75")
                }

                R.id.rb_4th -> {
                    adjustRatio("1.0")

                }

                else -> {
                    adjustRatio("0.25")
                }
            }
        }

        operator4PriceVolume(context)

        addTextListener()

        cbtn_create_order?.isEnable(true)
        cbtn_create_order?.listener = object : CommonlyUsedButton.OnBottonListener {
            override fun bottonOnClick() {
                if (!LoginManager.checkLogin(context, true)) return

                var status =
                    if (TradeFragment.currentIndex == LEVER_INDEX_TAB) PublicInfoDataService.getInstance().leverTradeKycOpen else PublicInfoDataService.getInstance().exchangeTradeKycOpen

                if (status && UserDataService.getInstance().authLevel != 1) {
                    NewDialogUtils.KycSecurityDialog(context!!,
                        context?.getString(R.string.common_kyc_trading)
                            ?: "",
                        object : NewDialogUtils.DialogBottomListener {
                            override fun sendConfirm() {
                                if (UserDataService.getInstance().authLevel != 1) {
                                    ArouterUtil.greenChannel(RoutePath.KycActivity, null)
                                }
                            }
                        })
                    return
                }

                LogUtil.e(TAG, "isETF ${isETF}")
                if (isETF) {
                    if (!UserDataService.getInstance().userIsOpenEtf) {
                        tradeETF()
                        return
                    }
                }
                /**
                 *Limit trading
                 */
                if (priceType == TYPE_LIMIT) {
                    if (TextUtils.isEmpty(inputPrice)) {
                        NToastUtil.showTopToastNet(
                            getActivity(),
                            false,
                            LanguageUtil.getString(context, "contract_tip_pleaseInputPrice")
                        )
                        return
                    }

                    if (TextUtils.isEmpty(inputQuantity)) {
                        NToastUtil.showTopToastNet(
                            getActivity(),
                            false,
                            LanguageUtil.getString(context, "transfer_tip_emptyVolume")
                        )
                        return
                    }


                    val limitPriceMin = coinMapData?.optString("limitPriceMin")
                    if (BigDecimalUtils.compareTo(inputPrice, limitPriceMin) < 0) {
                        val msg = LanguageUtil.getString(
                            context,
                            "common_tip_limitMinTransactionPrice"
                        ) + BigDecimalUtils.showSNormal(limitPriceMin)
                        NToastUtil.showTopToastNet(getActivity(), false, msg)
                        return
                    }

                    val limitVolumeMin = coinMapData?.optString("limitVolumeMin")
                    if (BigDecimalUtils.compareTo(inputQuantity, limitVolumeMin) < 0) {
                        val msg = LanguageUtil.getString(
                            context,
                            "common_tip_limitMaxTransactionVolume"
                        ) +" "+  BigDecimalUtils.showSNormal(limitVolumeMin)
                        NToastUtil.showTopToastNet(getActivity(), false, msg)
                        return
                    }

                    if (transactionType == TYPE_SELL) {
                        if (BigDecimalUtils.compareTo(canUseMoney, inputQuantity) < 0) {
                            // DisplayUtil.showSnackBar(this@TradeView.rootView, LanguageUtil.getString(context,R.string.common_tip_balanceNotEnough), isSuc = false)
                            NToastUtil.showTopToastNet(
                                getActivity(),
                                false,
                                LanguageUtil.getString(context, "common_tip_balanceNotEnough")
                            )
                            return
                        }
                    } else {

                    }
                }

                /**
                 *Current price transaction
                 */
                if (priceType == TYPE_MARKET) {
                    if (TextUtils.isEmpty(inputQuantity)) {
                        NToastUtil.showTopToastNet(
                            getActivity(),
                            false,
                            LanguageUtil.getString(context, "transfer_tip_emptyVolume")
                        )
                        return
                    }
                    val marketBuyMin = coinMapData?.optString("marketBuyMin")
                    val marketSellMin = coinMapData?.optString("marketSellMin")

                    /**
                     *Market value trading
                     *Under the premise of market price trading, whether buying or selling, the use of et_ Volume, So the context is inputQuantity
                     */
                    if (transactionType == TYPE_BUY) {


                        /**
                         *Minimum price
                         */
                        if (BigDecimalUtils.compareTo(inputQuantity, marketBuyMin) < 0) {
                            NToastUtil.showTopToastNet(
                                getActivity(),
                                false,
                                LanguageUtil.getString(
                                    context,
                                    "common_tip_limitMinTransactionPrice"
                                ) + BigDecimalUtils.showSNormal(marketBuyMin)
                            )
                            return
                        }

                        if (BigDecimalUtils.compareTo(canUseMoney, inputQuantity) < 0) {
                            NToastUtil.showTopToastNet(
                                getActivity(),
                                false,
                                LanguageUtil.getString(context, "common_tip_balanceNotEnough")
                            )
                            return
                        }

                    } else {
                        /**
                         *Minimum transaction volume
                         */
                        if (BigDecimalUtils.compareTo(inputQuantity, marketSellMin) < 0) {
                            NToastUtil.showTopToastNet(
                                getActivity(),
                                false,
                                LanguageUtil.getString(
                                    context,
                                    "common_tip_limitMaxTransactionVolume"
                                ) +" "+  BigDecimalUtils.showSNormal(marketSellMin)
                            )
                            return
                        }

                        if (BigDecimalUtils.compareTo(canUseMoney, inputQuantity) < 0) {
                            NToastUtil.showTopToastNet(
                                getActivity(),
                                false,
                                LanguageUtil.getString(context, "common_tip_balanceNotEnough")
                            )
                            return
                        }

                    }
                }

                createOrder()
            }
        }
        img_transfer?.setOnClickListener {
            if (!LoginManager.checkLogin(context, true)) {
                return@setOnClickListener
            }
            if (isLever) {
                ArouterUtil.navigation(RoutePath.NewVersionTransferActivity, Bundle().apply {
                    putString(ParamConstant.TRANSFERSTATUS, ParamConstant.LEVER_INDEX)
                    putString(ParamConstant.TRANSFERCURRENCY, getCurrentSymbol())
                })
            } else {
                ArouterUtil.forwardTransfer(ParamConstant.TRANSFER_BIBI, getCurrentCoin())
            }
        }

        val onlySpot = PublicInfoDataService.getInstance().isOnlySpot
        LogUtil.e(TAG,"onlySpot"+onlySpot.toString())
        img_transfer.visibility = if (onlySpot) View.GONE else View.VISIBLE
    }

    /**
     *Dealing with the relationship between price and volume events and login status
     */
    private fun operator4PriceVolume(context: Context) {
        priceScale = coinMapData?.optInt("price", 2) ?: 2
        volumeScale = coinMapData?.optInt("volume", 2) ?: 2
        setPrice()
        if (!LoginManager.isLogin(context)) {
            tv_transaction_money?.setText("")
            et_price?.isFocusableInTouchMode = false
            et_volume?.isFocusableInTouchMode = false
        } else {
            if (et_volume?.isFocusableInTouchMode?.not() == true) {
                et_volume?.isFocusable = true
                et_volume?.isFocusableInTouchMode = true
                et_volume?.requestFocus()
                et_volume?.findFocus()
            }
            if (et_price?.isFocusableInTouchMode?.not() == true) {
                et_price?.isFocusable = true
                et_price?.isFocusableInTouchMode = true
                et_price?.requestFocus()
                et_price?.findFocus()
            }
        }

        et_price?.setOnClickListener {
            LoginManager.checkLogin(context, true)
        }
        et_volume?.setOnClickListener {
            LoginManager.checkLogin(context, true)
        }


        /**
         *Background transformation of the 'Price' input box
         */
//        et_price?.setOnFocusChangeListener { _, hasFocus ->
//            ll_price?.setBackgroundResource(if (hasFocus) ColorUtil.getMainFocusColorType(isBuy()) else R.drawable.bg_trade_et_unfocused)
//        }

        /**
         *Background transformation of the 'Trading Volume' input box
         */
        et_volume?.setOnFocusChangeListener { _, hasFocus ->
//            ll_volume?.setBackgroundResource(if (hasFocus) ColorUtil.getMainFocusColorType(isBuy()) else R.drawable.bg_trade_et_unfocused)
            isVolumeFocus = hasFocus
            if (isVolumeFocus) {
                for (i in 0 until rg_trade.childCount step 2) {
                    val radioButton = rg_trade?.getChildAt(i) as RadioButton
                    radioButton.setTextColor(ColorUtil.getColor(R.color.normal_text_color))
                    radioButton.backgroundResource = R.color.transparent
                }
                rb_trade_v2?.clearCheck()
            }
        }

        if (priceType == TYPE_MARKET) {
            ll_transaction?.visibility = View.INVISIBLE
//            tv_convert_price?.visibility = View.INVISIBLE
        } else {
            ll_transaction?.visibility = View.VISIBLE
//            tv_convert_price?.visibility = View.VISIBLE
        }
    }

    /**
     *Adjusting the proportion of available balances
     */
    private fun adjustRatio(radio: String) {
        if (TextUtils.isEmpty(canUseMoney)) return
        when (priceType) {
            /**
             *Price limit
             */
            TYPE_LIMIT -> {
                val price = et_price?.text.toString()
                if (transactionType == TYPE_BUY) {
                    val consume = BigDecimalUtils.mul(canUseMoney, radio, priceScale).toString()
                    if (!TextUtils.isEmpty(price)) {
                        val volume =
                            BigDecimalUtils.div(consume, price, volumeScale).toPlainString()
                        et_volume?.setText(volume)
                    }
                    if (TextUtils.isEmpty(inputPrice) || inputPrice == "0") {
                        tv_transaction_money?.setText("")
                    } else {
                        tv_transaction_money?.setText("${BigDecimalUtils.showSNormal(consume)} ${showMarket()}")
                    }
//                et_volume?.setSelection(et_volume?.text.toString().trim().length)
                } else {
                    val volume =
                        BigDecimalUtils.mul(canUseMoney, radio, volumeScale).toPlainString()
                    et_volume?.setText(volume)
//                et_volume?.setSelection(et_volume?.text.toString().trim().length)
                    var consume = "0"
                    if (TextUtils.isEmpty(price)) {
                        consume = BigDecimalUtils.mul(volume, "0", priceScale).toString()
                    } else {
                        consume = BigDecimalUtils.mul(volume, price, priceScale).toString()
                    }

                    tv_transaction_money?.setText("${BigDecimalUtils.showSNormal(consume)} ${showMarket()}")
                }
            }

            /**
             *Market price
             */
            TYPE_MARKET -> {
                if (transactionType == TYPE_BUY) {
                    val consume =
                        BigDecimalUtils.mul(canUseMoney, radio, priceScale).toPlainString()
                    et_volume?.setText(consume)
                    LogUtil.v(TAG,"marketPrice ${consume} ${et_volume?.text}")
//                    et_volume?.setSelection(et_volume?.text.toString().trim().length)
                    tv_transaction_money?.setText("${BigDecimalUtils.showSNormal(consume)} ${showMarket()}")
                } else {
                    val volume =
                        BigDecimalUtils.mul(canUseMoney, radio, volumeScale).toPlainString()
                    et_volume?.setText(volume)
                    LogUtil.v(TAG,"marketPrice ${volume} ${et_volume?.text}")
//                    et_volume?.setSelection(et_volume?.text.toString().trim().length)

                    tv_transaction_money?.setText("${BigDecimalUtils.showSNormal(volume)} ${showCoinName()}")

                }
            }

        }


    }

    /**
     *Price Operation (Plus Minus -)
     */
    private fun operator4Price(context: Context) {
        /**
         *Price (-)
         */
//        tv_sub?.setOnTouchListener { view, motionEvent -> priceSub(motionEvent) }
//        iv_sub?.setOnTouchListener { view, motionEvent -> priceSub(motionEvent) }
        /**
         *Price (+)
         */
//        tv_add?.setOnTouchListener { view, motionEvent -> priceAdd(motionEvent) }
//        iv_add?.setOnTouchListener { view, motionEvent -> priceAdd(motionEvent) }
    }

    private var beforlong = 0
    private var bhlong: Int = 0
    private fun addTextListener() {

        /**
         *Price
         */
        et_price?.filters = arrayOf(DecimalDigitsInputFilter(priceScale))
        et_price?.step = precision2Step(priceScale)
        et_price.numberFilter(priceScale)
        et_price?.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(s: Editable?) {


                bhlong = s.toString().length
//                et_price?.setSelection(et_price.text.length)

                if (priceType == TYPE_MARKET || TextUtils.isEmpty(s) || s.toString() == "0.") {
//                    tv_convert_price?.visibility = View.INVISIBLE
                } else {

//                    tv_convert_price?.visibility = View.VISIBLE
                    tv_convert_price?.text = RateManager.getCNYByCoinMap(coinMapData, s.toString())
                }

                if (s?.startsWith(".") == true) {
                    et_price?.text?.clear()

                }

                inputPrice = s.toString()
                if (inputPrice.isEmpty()) {
                    isClear = true
                }
                if (inputPrice.startsWith(".")) {
                    inputPrice = "0"
                }
                if (beforlong > bhlong && !TextUtils.isEmpty(s.toString())) {//Determine if it is in a clear state

                }


                if (transactionType == TYPE_BUY) {
                    if (priceType == TYPE_LIMIT) {
                        if (TextUtils.isEmpty(inputPrice) || TextUtils.isEmpty(inputQuantity)) {
                            tv_transaction_money?.setText("")
                        } else {
                            //Calculate total amount
                            var money =
                                BigDecimalUtils.mul(inputPrice, inputQuantity).toPlainString()
                            money = DecimalUtil.cutValueByPrecision(money, priceScale)

                            tv_transaction_money?.setText("${BigDecimalUtils.showSNormal(money)} ${showMarket()}")
                        }
                    } else {
                        //In a buying and market trading state, the price is unknown and the transaction amount is not displayed
//                        tv_transaction_money?.text = SymbolInterceptUtils.interceptData(canUseMoney, coinMapData?.optString("symbol", ""), "price") + marketName
                    }
                } else {
                    //When the market price is sold, this input box inputs the quantity of the product (i.e. the first half of the currency pair)
                    if (priceType == TYPE_LIMIT) {
                        if (TextUtils.isEmpty(inputPrice) || TextUtils.isEmpty(inputQuantity)) {
                            tv_transaction_money?.setText("")
                        } else {
                            var money =
                                BigDecimalUtils.mul(inputPrice, inputQuantity).toPlainString()
                            money = DecimalUtil.cutValueByPrecision(money, priceScale)

                            tv_transaction_money?.setText("${BigDecimalUtils.showSNormal(money)} ${showMarket()}")
                        }

                    }
                }

            }

            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {
                beforlong = s.toString().length

            }

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
            }
        })

        /**
         *Quantity
         */
//        et_volume?.filters = arrayOf(DecimalDigitsInputFilter(volumeScale))
        et_volume.numberFilter(volumeScale)
        et_volume?.step = precision2Step(volumeScale)
        et_volume?.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(s: Editable?) {
                inputQuantity = s.toString()
                /**
                 *Clear the selected effect of RadioButton
                 */
                if (isVolumeFocus) {
                    for (i in 0 until rg_trade.childCount step 2) {
                        val radioButton = rg_trade?.getChildAt(i) as RadioButton
                        radioButton.setTextColor(ColorUtil.getColor(R.color.normal_text_color))
                        radioButton.backgroundResource = R.color.transparent
                    }
                }
                //Remember that not all issues are client related. Grass Mud Horse
//                if (s.toString().length < volumeScale + 2) {
//                    for (i in 0 until rg_trade.childCount step 2) {
//                        val radioButton = rg_trade?.getChildAt(i) as RadioButton
//                        radioButton.setTextColor(ColorUtil.getColor(R.color.normal_text_color))
//                        radioButton.backgroundResource = R.color.transparent
//                    }
//                }

//                inputQuantity = if (TextUtils.isEmpty(s)) {
//                    "0"
//                } else {
//                    s.toString()
//                }


                if (inputQuantity.startsWith(".")) {
                    inputQuantity = "0"
                }

                if (transactionType == TYPE_BUY) {
                    if (priceType == TYPE_LIMIT) {
                        //Transaction volume
                        if (TextUtils.isEmpty(inputPrice) || TextUtils.isEmpty(inputQuantity)) {
                            tv_transaction_money?.setText("")
                        } else {
                            var money =
                                BigDecimalUtils.mul(inputPrice, inputQuantity).toPlainString()
                            money = DecimalUtil.cutValueByPrecision(money, priceScale)
                            tv_transaction_money?.setText("${BigDecimalUtils.showSNormal(money)} ${showMarket()}")
                        }
                    }
                } else {
                    if (priceType == TYPE_LIMIT) {
                        if (TextUtils.isEmpty(inputQuantity) || TextUtils.isEmpty(inputPrice)) {
                            tv_transaction_money?.setText("")
                        } else {
                            //Transaction volume
                            var money =
                                BigDecimalUtils.mul(inputPrice, inputQuantity).toPlainString()
                            money = DecimalUtil.cutValueByPrecision(money, priceScale)
                            tv_transaction_money?.setText("${BigDecimalUtils.showSNormal(money)} ${showMarket()}")
                        }

                    }
                }
//                et_volume?.setSelection(et_volume?.text?.length ?: 0)
            }

            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {
            }

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
            }

        })
    }

    /**
     *Place an order
     */
    fun createOrder() {
        cbtn_create_order?.showLoading()
        val side = if (transactionType == TYPE_BUY) {
            "BUY"
        } else {
            "SELL"
        }

        val type = if (priceType == TYPE_LIMIT) {
            1
        } else {
            2
        }
        //At market price: buy represents the transaction amount, sell represents the total number; Under price limit: number of transactions
        val volume = inputQuantity
        //In the price limit mode, it represents the price, and the market price is meaningless
        val price = inputPrice
        val eventType =
            if (isLever) AppAnalyticsExt.APP_ACTION_LeverCreate else AppAnalyticsExt.APP_ACTION_OrderCreate
        AppAnalyticsExt.instance.clickAction(
            eventType,
            mapOf(
                "side" to side,
                "type" to type,
                "volume" to volume,
                "price" to price,
                "symbol" to getCurrentSymbol()
            )
        )

        (disposable ?: CompositeDisposable()).add((mainModel
            ?: MainModel()).createOrder(side,
            type,
            volume,
            price,
            coinMapData?.optString("symbol", "")
                ?: return,
            isLever = isLever,
            consumer = object : NDisposableObserver(true) {
                override fun onResponseSuccess(data: JSONObject) {
                    cbtn_create_order?.hideLoading()
                    NToastUtil.showTopToastNet(
                        getActivity(),
                        true,
                        LanguageUtil.getString(context, "contract_tip_submitSuccess")
                    )
                    val event = MessageEvent(
                        MessageEvent.CREATE_ORDER_TYPE,
                        true,
                        TradeFragment.currentIndex == LEVER_INDEX_TAB
                    )
                    try {
                        val item = data.getJSONObject("data")
                        event.msg_content_data = item
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                    NLiveDataUtil.postValue(event)
                    EventBusUtil.post(event)
                    //Refresh delegation list
                    getAvailableBalance()
                    /**
                     *Set the selection effect of RadioButton
                     */
                    for (i in 0 until rg_trade.childCount step 2) {
                        val radioButton = rg_trade?.getChildAt(i) as RadioButton
                        radioButton.setTextColor(ColorUtil.getColor(R.color.normal_text_color))
                        radioButton.backgroundResource = R.color.transparent
                    }
                    rg_trade.clearCheck()
                    et_volume?.text?.clear()
                    et_volume?.invalidate()
                    et_volume?.setText("")
                }

                override fun onResponseFailure(code: Int, msg: String?) {
                    super.onResponseFailure(code, msg)
                    cbtn_create_order?.hideLoading()
                }
            })!!
        )

    }


    private fun observeData() {

        NLiveDataUtil.observeData((this.context as NewMainActivity), Observer<MessageEvent> {
            if (null == it)
                return@Observer

            if (TradeFragment.currentIndex == CVC_INDEX_TAB) {
                if (it.isLever) {
                    return@Observer
                }
            } else {
                if (!it.isLever) {
                    return@Observer
                }
            }

            when (it.msg_type) {
                MessageEvent.TAB_TYPE -> {
                    coinMapData = if (it.isLever) {
                        NCoinManager.getSymbolObj(PublicInfoDataService.getInstance().currentSymbol4Lever)
                    } else {
                        NCoinManager.getSymbolObj(PublicInfoDataService.getInstance().currentSymbol)
                    }

                    if (it.isLever) {
                        buyOrSell(transactionType, it.isLever)
                    } else {
                        buyOrSell(transactionType, it.isLever)
                    }
                    tv_transaction_money?.hint="${LanguageUtil.getString(context,"transaction_text_tradeSum")}(${showMarket()})}"
                }

                MessageEvent.symbol_switch_type -> {
                    if (null != it.msg_content) {
                        val symbol = it.msg_content as String
                        if (symbol != coinMapData?.optString("symbol", "")) {
                            coinMapData = NCoinManager.getSymbolObj(symbol)
                            tv_coin_name?.text = "${showCoinName()}"
                            tv_convert_price?.text = "--"
                            tv_transaction_money?.setText("")
                            getAvailableBalance()
                            tv_transaction_money?.hint="${LanguageUtil.getString(context,"transaction_text_tradeSum")}(${showMarket()})}"
                        }
                    }
                }

            }
        })
    }

    private fun showCoinName(): String? {
        return NCoinManager.getMarketShowCoinName(showAnoterName(coinMapData))
    }

    private fun showMarket(): String? {
        return NCoinManager.getMarketName(showAnoterName(coinMapData))
    }

    /**
     *Buy&Sell
     */
    fun buyOrSell(transferType: Int, isLever: Boolean = false) {
        this.isLever = isLever
        if (isLever) {
            coinMapData =
                NCoinManager.getSymbolObj(PublicInfoDataService.getInstance().currentSymbol4Lever)
        } else {
            coinMapData =
                NCoinManager.getSymbolObj(PublicInfoDataService.getInstance().currentSymbol)
        }
        tv_transaction_money?.hint="${LanguageUtil.getString(context,"transaction_text_tradeSum")}(${showMarket()})"
        ll_etf_item?.visibility = View.GONE
        resetPrice()
        setPrice()
        tabChangeReset()
        if (priceType == TYPE_LIMIT) {
            v_market_trade_tip?.visibility = View.GONE
            ll_price?.visibility = View.VISIBLE
//            tv_convert_price?.visibility = View.VISIBLE
            tv_convert_price?.text = "--"
            ll_transaction?.visibility = View.VISIBLE
            tv_transaction_money?.setText("")
            if (transactionType == TYPE_BUY) {
                et_volume?.hint = "${LanguageUtil.getString(context, "transaction_tip_buyVolume")}(${showCoinName()})"
                et_price?.hint = LanguageUtil.getString(context, "common_text_buyPrice")
            } else {
                et_volume?.hint = "${LanguageUtil.getString(context, "common_text_sellVolume")}(${showCoinName()})"
                et_price?.hint = LanguageUtil.getString(context, "common_text_sellPrice")
            }
            et_volume.numberFilter(volumeScale)
            et_volume?.step = precision2Step(volumeScale)
            getAvailableBalance()
        } else {
            v_market_trade_tip?.visibility = View.VISIBLE
            ll_price?.visibility = View.GONE
//            tv_convert_price?.visibility = View.INVISIBLE
            ll_transaction?.visibility = View.INVISIBLE
            tv_transaction_money?.setText("")
            if (transactionType == TYPE_BUY) {
                et_volume?.hint = "${LanguageUtil.getString(context, "transaction_text_tradeSum")}(${showMarket()})"
                et_volume.numberFilter(priceScale)
                et_volume?.step = precision2Step(priceScale)
                et_price?.hint = LanguageUtil.getString(context, "common_text_buyPrice")
            } else {
                et_volume?.hint = "${LanguageUtil.getString(context, "common_text_sellVolume")}(${showCoinName()})"
                et_volume.numberFilter(volumeScale)
                et_volume?.step = precision2Step(volumeScale)
                et_price?.hint = LanguageUtil.getString(context, "common_text_sellPrice")
            }
            getAvailableBalance()
        }

        val priceClose = et_price?.text?.toString()
        if (!priceClose.isNullOrEmpty()) {
            LogUtil.d(TAG, "========buyOrSell======price_close is $priceClose")
            tv_convert_price?.text = "${RateManager.getCNYByCoinMap(coinMapData, priceClose)}"
        }
        transactionType = transferType

        /**
         *Switching direction to clear quantity
         */
//        rg_trade?.clearCheck()
        et_volume?.text?.clear()

        if (currentItem != null) {
            changeSellOrBuyData(currentItem!!)
        }
        if (transferType == TYPE_BUY) {
            if (UserDataService.getInstance().isLogined) {
                cbtn_create_order?.textContent =
                    LanguageUtil.getString(context, "contract_action_buy") + " " + showCoinName()
            } else {
                cbtn_create_order?.textContent =
                    LanguageUtil.getString(context, "login_action_login")
            }
            cbtn_create_order?.normalBgColor = ColorUtil.getMainColorType()

            /**
             *Currency
             */
            tv_coin_name?.text =
                if (priceType == TYPE_LIMIT) {
                    "${showCoinName()}"
                } else {
                    "${showMarket()}"
                }

            if (priceType == TYPE_LIMIT) {
                et_volume?.hint ="${LanguageUtil.getString(context, "transaction_tip_buyVolume")}(${showCoinName()})"
                et_price?.hint = LanguageUtil.getString(context, "common_text_buyPrice")
            } else {
                et_volume?.hint = "${LanguageUtil.getString(context, "transaction_text_tradeSum")}(${showMarket()})"
                et_price?.hint = LanguageUtil.getString(context, "common_text_sellPrice")
            }
            /**
             *Set the selection effect of RadioButton
             */
            for (i in 0 until rg_trade.childCount step 2) {
                val radioButton = rg_trade?.getChildAt(i) as RadioButton
                radioButton.setTextColor(ColorUtil.getCheck4ColorStateList())
                radioButton.background = ColorUtil.getCheck4StateListDrawable()
            }

        } else {
            if (UserDataService.getInstance().isLogined) {
                cbtn_create_order?.textContent =
                    LanguageUtil.getString(context, "contract_action_sell") + " " + showCoinName()
            } else {
                cbtn_create_order?.textContent =
                    LanguageUtil.getString(context, "login_action_login")
            }

            cbtn_create_order?.normalBgColor = ColorUtil.getMainColorType(false)

            /**
             *Currency
             */
            tv_coin_name?.text = "${showCoinName()}"

            et_volume?.hint = "${LanguageUtil.getString(context, "common_text_sellVolume")}(${showCoinName()})"

            /**
             *Set the selection effect of RadioButton
             */
            for (i in 0 until rg_trade.childCount step 2) {
                val radioButton = rg_trade?.getChildAt(i) as RadioButton
                radioButton.setTextColor(ColorUtil.getCheck4ColorStateList(isRise = false))
                radioButton.background = ColorUtil.getCheck4StateListDrawable(isRise = false)
            }
        }
    }

    var currentItem: JSONObject? = null
    fun changeSellOrBuyData(data: JSONObject) {
        LogUtil.d("getAvailableBalance", "getAvailableBalance==data is $data")

        val countCoinBalance = data.optString("countCoinBalance")
        val baseCoinBalance = data.optString("baseCoinBalance")
        val marketName = NCoinManager.getMarketName(coinMapData?.optString("name", ""))
        if (transactionType == TYPE_BUY) {
            val coinName = NCoinManager.getMarketName(coinMapData?.optString("name", ""))
            var precision = NCoinManager.getCoinShowPrecision(coinName)
            if (TradeFragment.currentIndex == LEVER_INDEX_TAB) {
                precision = 8
            }
            canUseMoney = DecimalUtil.cutValueByPrecision(
                countCoinBalance
                    ?: "0", precision
            )

            NCoinManager.getMarketByName(showCoinName())
            tv_available_balance?.text = "$canUseMoney ${showMarket()}"

            tv_coin_name?.text =
                if (priceType == TYPE_LIMIT) "${showCoinName()}" else "${showMarket()}"
        } else {
            val coinName = NCoinManager.getMarketCoinName(coinMapData?.optString("name", ""))
            var precision = NCoinManager.getCoinShowPrecision(coinName)

            if (TradeFragment.currentIndex == LEVER_INDEX_TAB) {
                precision = 8
            }

            canUseMoney = baseCoinBalance.getTradeCoinBalance(coinMapData)
            tv_coin_name?.text = "${showCoinName()}"
            tv_available_balance?.text = "$canUseMoney ${showCoinName()}"
        }
        currentItem = data
    }


    /*
     *Default color value corresponding to green rise, red fall
     */
    private fun showBuyOrSellBg(isBuy: Boolean) {


    }

    private fun showBalanceData() {

    }

    fun editPriceIsNull(): Boolean {
        if (et_price.text.isNullOrEmpty() && !isClear) {
            return true
        }
        return false
    }

    fun initTick(tick: JSONArray, depthLevel: Int = 2) {
        et_price.text = tick.getPriceTick(depthLevel).editable()
    }

    fun initClickData(tempPrice: String) {
        et_price?.setText(tempPrice)
        inputPrice = tempPrice
//        priceOrAmout(null)
    }


    fun verticalDepth(isVertical: Boolean = false, isBuy: Boolean = true, isLever: Boolean = true) {
        v_tb_bar.visibility = (!isVertical).visiableOrGone()
        tv_order_type.visibility = (!isVertical).visiableOrGone()
        val onlySpot = PublicInfoDataService.getInstance().isOnlySpot
        img_transfer.visibility = if (onlySpot) View.GONE else View.VISIBLE
//        img_transfer.visibility = (!isVertical).visiableOrGone()
        transactionType = when (isBuy) {
            true -> ParamConstant.TYPE_BUY
            else -> ParamConstant.TYPE_SELL
        }
        this.isLever = isLever
        buyOrSell(transactionType, isLever)

//        tv_sub.visibility = (!isVertical).visiableOrGone()
//        v_line.visibility = (!isVertical).visiableOrGone()
//        tv_add.visibility = (!isVertical).visiableOrGone()
//        v_sub_line.visibility = (!isVertical).visiableOrGone()

        layout_v_tools.visibility = isVertical.visiableOrGone()
//        et_price.gravity = when (isVertical) {
//            true -> Gravity.CENTER_VERTICAL
//            else -> Gravity.CENTER
//        }


    }

    fun changePriceTypeL(item: Int) {
        changePriceType(item)
    }

    fun changePriceType(item: Int) {
        var showCoinName =
            NCoinManager.getMarketShowCoinName(coinMapData?.optString("showName", ""))
        when (item) {
            0 -> {
                priceType = TYPE_LIMIT
                v_market_trade_tip?.visibility = View.GONE
                ll_price?.visibility = View.VISIBLE
//                tv_convert_price?.visibility = View.VISIBLE
                ll_transaction?.visibility = View.VISIBLE
                if (transactionType == TYPE_BUY) {
                    et_volume?.hint = "${LanguageUtil.getString(context, "transaction_tip_buyVolume")}(${showCoinName()})"
                    et_price?.hint = LanguageUtil.getString(context, "common_text_buyPrice")
                } else {
                    et_volume?.hint = "${LanguageUtil.getString(context, "common_text_sellVolume")}(${showCoinName()})"
                    et_price?.hint = LanguageUtil.getString(context, "common_text_sellPrice")
                }
                tv_coin_name?.text = "$showCoinName"
                getAvailableBalance()
                rg_trade.clearCheck()
                // change market number
                et_volume?.numberFilter(volumeScale)
                et_volume?.step = precision2Step(volumeScale)
            }

            1 -> {
                priceType = TYPE_MARKET
                v_market_trade_tip?.visibility = View.VISIBLE
                ll_price?.visibility = View.GONE
//                tv_convert_price?.visibility = View.INVISIBLE
                ll_transaction?.visibility = View.INVISIBLE
                if (transactionType == TYPE_BUY) {
                    et_volume?.hint = "${LanguageUtil.getString(context, "transaction_text_tradeSum")}(${showMarket()})"
                    et_price?.hint = LanguageUtil.getString(context, "common_text_buyPrice")
                    et_volume?.numberFilter(priceScale)
                    et_volume?.step = precision2Step(priceScale)
                } else {
                    et_volume?.hint = "${LanguageUtil.getString(context, "common_text_sellVolume")}(${showCoinName()})"
                    et_price?.hint = LanguageUtil.getString(context, "common_text_sellPrice")
                    et_volume?.numberFilter(volumeScale)
                    et_volume?.step = precision2Step(volumeScale)
                }
                tv_coin_name?.text = showMarket()
                getAvailableBalance()
                resetPrice()
                rg_trade.clearCheck()
            }
        }
        for (i in 0 until rg_trade.childCount step 2) {
            val radioButton = rg_trade?.getChildAt(i) as RadioButton
            radioButton.setTextColor(ColorUtil.getColor(R.color.normal_text_color))
            radioButton.backgroundResource = R.color.transparent
        }
        et_volume?.setText("")
        rb_trade_v2?.clearCheck()
    }

    var isClear = false
    fun resetPrice() {
        et_price?.text?.clear()
        isClear = false
    }


    private fun priceSub(event: MotionEvent): Boolean {
        isPriceLongClick = true
        isStartPriceSubClick = true

        when (event.action) {
            MotionEvent.ACTION_DOWN -> {
                if (!LoginManager.checkLogin(context, true)) return false
                val unit = if (transactionType == ParamConstant.TYPE_SELL &&
                    priceType == TYPE_MARKET
                ) {
                    (1 / Math.pow(10.0, volumeScale.toDouble())).toString()
                } else {
                    (1 / Math.pow(10.0, priceScale.toDouble())).toString()
                }

                if (TextUtils.isEmpty(unit)) return false
                if (inputPrice.isEmpty()) {
                    et_price?.setText("")
                    tv_convert_price?.text = ""
                    return true
                }
                if (BigDecimal(inputPrice).toFloat() > 0f) {
                    inputPrice = BigDecimalUtils.sub(inputPrice, unit).toPlainString()
                    et_price?.setText(BigDecimalUtils.subAndDot(inputPrice))
                    tv_convert_price?.text = RateManager.getCNYByCoinMap(coinMapData, inputPrice)
                } else {
                    et_price?.setText("")
                    tv_convert_price?.text = ""
                    return true
                }

                doAsync {
                    while (isPriceLongClick) {
                        Thread.sleep(delayTime)
                        if (!isStartPriceSubClick) continue

                        inputPrice = try {
                            if (BigDecimal(inputPrice).toFloat() > 0f) {
                                BigDecimalUtils.sub(inputPrice, unit).toPlainString()
                            } else {
                                ""
                            }
                        } catch (e: NumberFormatException) {
                            ""
                        }
                        uiThread {
                            et_price?.setText(BigDecimalUtils.subAndDot(inputPrice))
                            tv_convert_price?.text =
                                RateManager.getCNYByCoinMap(coinMapData, inputPrice)
                        }

                    }
                }
                return true
            }

            MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                isPriceLongClick = false
                isStartPriceSubClick = false
            }
        }


        return true
    }

    private fun priceAdd(event: MotionEvent): Boolean {
        isPriceLongClick = true
        isStartPricePlusClick = true

        when (event.action) {
            MotionEvent.ACTION_DOWN -> {
                if (!LoginManager.checkLogin(context, true)) return false

                val unit = if (transactionType == TYPE_SELL && priceType == TYPE_MARKET) {
                    (1 / Math.pow(10.0, volumeScale.toDouble())).toString()
                } else {
                    (1 / Math.pow(10.0, priceScale.toDouble())).toString()
                }

                if (TextUtils.isEmpty(unit)) return false

                inputPrice = BigDecimalUtils.add(inputPrice, unit).toPlainString()
                et_price?.setText(BigDecimalUtils.subAndDot(inputPrice))

                tv_convert_price?.text = RateManager.getCNYByCoinMap(coinMapData, inputPrice)

                doAsync {
                    while (isPriceLongClick) {
                        Thread.sleep(delayTime)
                        if (!isStartPricePlusClick) continue
                        inputPrice = try {
                            BigDecimalUtils.add(inputPrice, unit).toPlainString()
                        } catch (e: NumberFormatException) {
                            ""
                        }

                        uiThread {
                            et_price?.setText(BigDecimalUtils.subAndDot(inputPrice))
                            tv_convert_price?.text =
                                RateManager.getCNYByCoinMap(coinMapData, inputPrice)
                        }

                    }
                }
            }

            MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                isPriceLongClick = false
                isStartPricePlusClick = false
            }
        }
        return true
    }

    fun changeEtfLayout(isVerticalOrGone: Boolean = false) {
//        val layoutParams = ll_transaction.layoutParams as LinearLayout.LayoutParams
//        layoutParams.topMargin = DisplayUtil.dip2px(when (isVerticalOrGone) {
//            true -> 18
//            else -> 35
//        })
        isETF = !isVerticalOrGone
    }

    private fun isBuy(): Boolean {
        return transactionType == ParamConstant.TYPE_BUY
    }

    private fun tabChangeReset() {
        et_price?.clearFocus()
        et_volume?.clearFocus()
        KeyBoardUtils.closeKeyBoard(context)

    }

    fun notLoginLayout(isShow: Boolean = false) {
        cbtn_create_order?.visibility = isShow.visiableOrGone()
    }


    fun getActivity(): Activity? {
        if (context is Activity) {
            return context as Activity
        }
        return null
    }

    private fun getCurrentSymbol(): String {
        return coinMapData?.optString("symbol", "") ?: ""
    }

    private fun getCurrentCoin(): String {
        return NCoinManager.getMarketName(coinMapData?.optString("name", "") ?: "")
    }

    fun getPrecision(): Int {
        return NCoinManager.getMarketCoinShowPrecision(getCurrentSymbol())
    }

    private fun tradeETF() {
        (disposable ?: CompositeDisposable()).add((mainModel
            ?: MainModel()).getETFCoin(consumer = object : NDisposableObserver(true) {
            override fun onResponseSuccess(data: JSONObject) {

                try {
                    val item = data.getJSONObject("data")
                    val status = item.optInt("status", 0)
                    if (status == 0) {
                        val url = etfInfo?.optString("faqUrl") ?: ""
                        val domainName = etfInfo?.optString("domainName") ?: ""
                        DialogUtil.showETFStatement(
                            context
                                ?: return, domainName, url, this@TradeView
                        )
                    } else if (status == 1) {
                        NToastUtil.showTopToastNet(
                            getActivity(),
                            false,
                            LanguageUtil.getString(context, "etf_agreement_pendingKYC")
                        )
                    } else if (status == 2) {
                        //Jump to KYC
                        ArouterUtil.navigation(RoutePath.KycActivity, null)
                    } else if (status == 3) {
                        NToastUtil.showTopToastNet(
                            getActivity(),
                            false,
                            LanguageUtil.getString(context, "etf_agreement_countryNotSurpport")
                        )
                    } else {
                        MainModel().saveUserInfo()
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }

            override fun onResponseFailure(code: Int, msg: String?) {
                super.onResponseFailure(code, msg)

            }
        })!!
        )
    }

    var volArrays = arrayOf(0.25f, 0.50f, 0.75f, 1.00f)
    fun initVolView() {
        rb_trade_v2?.setRadios(volArrays, null, object : KKSelectRatioViewKit.KKVolListener {
            override fun result(value: Float, position: Int, view: View?) {
                if (position == -1) {
                    adjustRatio("0")
                    return
                }
                adjustRatio(value.toString())
            }
        }, 0, color = ColorUtil.getMainColorV3Type(isBuy()))
    }

    fun precision2Step(precision: Int): String {
        val strbuild = StringBuilder().apply {
            if (precision > 0) {
                append("0.")
                for (i in 1..(precision - 1)) {
                    append("0")
                }
                append("1")
            } else {
                append("1")
            }
        }
        return strbuild.toString()
    }


}




