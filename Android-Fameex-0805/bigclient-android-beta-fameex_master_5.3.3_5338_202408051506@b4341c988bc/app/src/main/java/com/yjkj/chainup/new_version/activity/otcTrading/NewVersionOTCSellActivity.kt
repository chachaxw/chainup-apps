package com.yjkj.chainup.new_version.activity.otcTrading

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.view.View
import com.chainup.contract.utils.numberFilter
import com.google.gson.JsonObject
 import com.chainup.contract.view.dialog.CpTDialog
import com.google.android.material.tabs.TabLayout
import com.yjkj.chainup.R
import com.yjkj.chainup.app.AppConstant
import com.yjkj.chainup.base.NBaseActivity
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.manager.RateManager
import com.yjkj.chainup.net.HttpClient
import com.yjkj.chainup.net.retrofit.NetObserver
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.view.CommonlyUsedButton
import com.yjkj.chainup.securityVerifyRule.VerifyRule4
import com.yjkj.chainup.util.BigDecimalUtils
import com.yjkj.chainup.util.ColorUtil
import com.yjkj.chainup.util.EdittextUtil
import com.yjkj.chainup.util.LogUtil
import io.reactivex.Flowable
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import io.reactivex.functions.Action
import io.reactivex.functions.Consumer
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.activity_new_version_otc_buy.*
import kotlinx.android.synthetic.main.activity_new_version_otc_buy.title_layout
import kotlinx.android.synthetic.main.item_otc_buy_or_sell_detail.*
import kotlinx.android.synthetic.main.mine_order_activity.*
import org.json.JSONObject
import java.util.concurrent.TimeUnit

/**
 * @Author lianshangljl
 * @Date 2023/4/18-5:18 PM
 * @Email buptjinlong@163.com
 * @description
 */
class NewVersionOTCSellActivity : NBaseActivity() {
    override fun setContentView(): Int {
        return R.layout.activity_new_version_otc_buy
    }


    var advertID = -1
    private var mdDisposable: Disposable? = null

    /**
     *Price in terms of quantity
     */
    var amountPrice = "0"


    var precision:Int = 2
    var showPrecision:Int = 2

    companion object {
        val ADVERTID = "advertId"

        fun enter2(context: Context, advertID: Int) {
            var intent = Intent(context, NewVersionOTCSellActivity::class.java)
            intent.putExtra(ADVERTID, advertID)
            context.startActivity(intent)
        }
    }


    override fun onInit(savedInstanceState: Bundle?) {
        super.onInit(savedInstanceState)
        getData()
        setOnClick()
        setTextContent()
        rb_price_buy?.text = LanguageUtil.getString(this, "otc_action_sellByPrice")
        rb_amount_buy?.text = LanguageUtil.getString(this, "otc_action_sellByVolume")
        rb_price_buy?.setCompoundDrawablesWithIntrinsicBounds(0, 0, 0, ColorUtil.getOTCBuyOrSellDrawable())
        rb_amount_buy?.setCompoundDrawablesWithIntrinsicBounds(0, 0, 0, 0)

        EdittextUtil.setEditTextEditable(cet_total_money, true)
        cub_confirm_for_buy?.isEnable(false)
        cet_total_money?.setOnFocusChangeListener { v, hasFocus ->
            v_line?.setBackgroundResource(if (hasFocus) R.color.main_blue else R.color.new_edit_line_color)
        }
        cet_total_money?.hint = LanguageUtil.getString(this, "otc_tip_inputWishSellPrice")
        getADDetail4OTC()

        stl_market_type?.apply {
            addTab(
                newTab().apply {
                    text = LanguageUtil.getString(this@NewVersionOTCSellActivity,"otc_action_sellByPrice")
                }
            )
            addTab(
                newTab().apply {
                    text = LanguageUtil.getString(this@NewVersionOTCSellActivity,"otc_action_sellByVolume")
                }
            )
        }

        stl_market_type?.addOnTabSelectedListener(object: TabLayout.OnTabSelectedListener{
            override fun onTabSelected(tab: TabLayout.Tab?) {
                val position = stl_market_type.selectedTabPosition
                when(position){
                    0 -> {
                        rb_price_buy?.setCompoundDrawablesWithIntrinsicBounds(0, 0, 0, ColorUtil.getOTCBuyOrSellDrawable())
                        rb_amount_buy?.setCompoundDrawablesWithIntrinsicBounds(0, 0, 0, 0)
                        tv_total_money?.text = LanguageUtil.getString(this@NewVersionOTCSellActivity, "otc_text_orderTotal") + otcADDbean?.optString("payCoin")
                        cet_total_money?.hint = LanguageUtil.getString(this@NewVersionOTCSellActivity, "otc_tip_inputWishSellPrice")
                        cet_total_money?.setText("")
                        tv_market_price.text = "≈0 " + NCoinManager.getShowMarket(otcADDbean?.optString("coin"))
                        v_line?.setBackgroundResource(R.color.main_blue)
                        priceOrtotal = true
                        cet_total_money.numberFilter(precision)
                    }
                    1 -> {
                        rb_amount_buy?.setCompoundDrawablesWithIntrinsicBounds(0, 0, 0, ColorUtil.getOTCBuyOrSellDrawable())
                        rb_price_buy?.setCompoundDrawablesWithIntrinsicBounds(0, 0, 0, 0)
                        tv_total_money?.text = LanguageUtil.getString(this@NewVersionOTCSellActivity, "charge_text_volume") + "(${NCoinManager.getShowMarket(symbol)})"
                        cet_total_money?.hint = LanguageUtil.getString(this@NewVersionOTCSellActivity, "otc_tip_inputWishSellPrice")
                        v_line?.setBackgroundResource(R.color.main_blue)
                        cet_total_money?.setText("")
                        tv_market_price?.text = "≈0 " + otcADDbean?.optString("payCoin")
                        priceOrtotal = false
                        cet_total_money.numberFilter(showPrecision)
                    }
                }
            }

            override fun onTabUnselected(tab: TabLayout.Tab?) {

            }

            override fun onTabReselected(tab: TabLayout.Tab?) {

            }

        })
    }

    fun setTextContent() {
        btn_cancel?.setContent(getStringContent("common_text_btnCancel"))
        cub_confirm_for_buy?.setContent(getStringContent("otc_action_placeOrder"))
        rb_price_buy?.text = getStringContent("otc_action_buyByPrice")
        rb_amount_buy?.text = getStringContent("otc_action_buyByVolume")
        tv_price?.text = getStringContent("contract_text_price")
        tv_total_money?.text = getStringContent("otc_text_orderTotal")
        tv_limit?.text = getStringContent("otc_text_priceLimit")
        tv_fiat_balance?.text = getStringContent("otc_asset_availableBalance")
        tv_anti_money_laundering?.text = getStringContent("otc_tip_withdrawLimitTime")
        tv_trading_title?.text = getStringContent("otc_tip_tradeHintTitle")
        tv_trading_content?.text = getStringContent("otc_tip_tradeHintContent")
        cub_confirm_for_sell?.setBottomTextContent(LanguageUtil.getString(this, "otc_action_placeOrder"))
    }


    fun getStringContent(contentId: String): String {
        return LanguageUtil.getString(this, contentId)
    }


    var priceOrtotal = true
    var amount = ""

    fun setOnClick() {
        /**
         *Switch price purchase or quantity purchase
         */
        rg_buy_sell?.setOnCheckedChangeListener { group, checkedId ->

            when (checkedId) {
                R.id.rb_price_buy -> {
                    rb_price_buy?.setCompoundDrawablesWithIntrinsicBounds(0, 0, 0, ColorUtil.getOTCBuyOrSellDrawable())
                    rb_amount_buy?.setCompoundDrawablesWithIntrinsicBounds(0, 0, 0, 0)
                    tv_total_money?.text = LanguageUtil.getString(this, "otc_text_orderTotal") + otcADDbean?.optString("payCoin")
                    cet_total_money?.hint = LanguageUtil.getString(this, "otc_tip_inputWishSellPrice")
                    cet_total_money?.setText("")
                    tv_market_price.text = "≈0 " + NCoinManager.getShowMarket(otcADDbean?.optString("coin"))
                    v_line?.setBackgroundResource(R.color.main_blue)
                    priceOrtotal = true
                }

                R.id.rb_amount_buy -> {
                    rb_amount_buy?.setCompoundDrawablesWithIntrinsicBounds(0, 0, 0, ColorUtil.getOTCBuyOrSellDrawable())
                    rb_price_buy?.setCompoundDrawablesWithIntrinsicBounds(0, 0, 0, 0)
                    tv_total_money?.text = LanguageUtil.getString(this, "charge_text_volume") + "(${NCoinManager.getShowMarket(symbol)})"
                    cet_total_money?.hint = LanguageUtil.getString(this, "otc_tip_inputWishSellPrice")
                    v_line?.setBackgroundResource(R.color.main_blue)
                    cet_total_money?.setText("")
                    tv_market_price?.text = "≈0 " + otcADDbean?.optString("payCoin")
                    priceOrtotal = false
                }
            }
        }
    }


    var fundsPassDialog:  CpTDialog? = null
    var symbol = ""

    fun getData() {
        if (intent != null) {
            advertID = intent.getIntExtra(ADVERTID, -1)
        }
        EdittextUtil.setEditTextEditable(cet_price, false)

        ll_trading_layout?.visibility = View.VISIBLE
        cub_confirm_for_sell?.visibility = View.GONE
    }

    var otcADDbean: JSONObject? = null
    fun initView(bean: JSONObject) {
        otcADDbean = bean
        symbol = bean.optString("coin")


        val title = if (PublicInfoDataService.getInstance().getB2CSwitchOpen(null)) {
            LanguageUtil.getString(this, "otc_asset_availableBalance_forotc")
        } else {
            LanguageUtil.getString(this, "otc_asset_availableBalance")
        }

        tv_fiat_balance?.text = "$title:${BigDecimalUtils.showSNormal(bean.optString("currentUserBanlance"))}"
        tv_price?.text = LanguageUtil.getString(this, "contract_text_price") + "("+bean.optString("payCoin")+")"
        tv_total_money?.text = LanguageUtil.getString(this, "otc_text_orderTotal") + bean.optString("payCoin")
        showPrecision = NCoinManager.getCoinShowPrecision(bean.optString("coin"))
        title_layout?.setContentTitle(LanguageUtil.getString(this, "otc_action_sell") + NCoinManager.getShowMarket(symbol))
        /**
         * (bean?.maxTrade?.div(bean?.price!!))
         */
        val div = BigDecimalUtils.mul(bean.optString("currentUserBanlance").toString(), bean.optString("price").toString(), NCoinManager.getCoinShowPrecision(symbol))
        /**
         *Set User Name
         */
        user_info_view?.setUserNick(bean.optString("otcNickName"))
        /**
         *Set transaction quantity
         */
        user_info_view?.setTransactionNumber(bean.optString("completeOrders").toString())
        /**
         *Set credit rating
         */
        user_info_view?.setCreditContent("${BigDecimalUtils.divForDown((bean.optDouble("creditGrade") * 100).toString(), 0)}%")
        /**
         *Historical transactions
         */
        user_info_view?.setCumulativeClinch(BigDecimalUtils.intercept(bean.optString("turnover").toString(), NCoinManager.getCoinShowPrecision(symbol)).toString())

        var jsonArray = bean.optJSONArray("payments")
        if (null != jsonArray) {
            var paymentList = arrayListOf<JSONObject>()
            for (num in 0 until jsonArray.length()) {
                paymentList.add(jsonArray.optJSONObject(num))
            }
            user_info_view?.initPayments(paymentList)
        }


        /**
         *Set Price
         */
        //cet_price?.setText(bean.optString("price").toString() + " " + bean.optString("payCoin"))
        var price = bean.optString("price")
        var payCoin = bean.optString("payCoin")
        precision = RateManager.getFiat4Coin(payCoin)
        var priceN = BigDecimalUtils.divForDown(price, precision)

        LogUtil.d(TAG, "initView==price is $price,payCoin is $payCoin")
        cet_price?.setText("$priceN $payCoin")

        /**
         *Limit
         */
        //tv_limit?.text = LanguageUtil.getString(this,otc_text_priceLimit) + " " + bean.optString("minTrade").toString() + bean.optString("payCoin") + " - ${bean.optString("maxTrade")} " + bean.optString("payCoin")
        var minTrade = bean.optString("minTrade")
        var maxTrade = bean.optString("maxTrade")
        var minTradeN = BigDecimalUtils.divForDown(minTrade, precision)
        var maxTradeN = BigDecimalUtils.divForDown(maxTrade, precision)

        tv_limit?.text = LanguageUtil.getString(this, "otc_text_priceLimit") + "$minTradeN$payCoin - $maxTrade$payCoin"

        cancelBtnState()
        cet_total_money?.numberFilter(precision)
        cet_total_money?.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(s: Editable?) {

            }

            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {

            }

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
                amount = s.toString()

                if (priceOrtotal) {
                    calculateForPrice(amount, bean)
                } else {
                    calculateForAmount(amount, bean)
                }
                if (amount.isNotEmpty()) {
                    detectionPrice(bean)
                } else {
                    cub_confirm_for_buy?.isEnable(false)
                }

            }

        })

        /**
         *Click on all
         *@param priceOrtotal true Price purchase quantity purchase
         */
        tv_all_buy?.setOnClickListener {
            amount = cet_total_money?.text.toString()
            if (priceOrtotal) {
                if (BigDecimalUtils.compareTo(div.toPlainString(), bean.optString("maxTrade")) > 0) {
                    cet_total_money?.setText(BigDecimalUtils.showSNormal(bean.optString("maxTrade")))
                } else {
                    cet_total_money?.setText(div.toString())
                }
                calculateForPrice(cet_total_money?.text.toString(), bean)
            } else {
                var mul = BigDecimalUtils.div(bean.optString("maxTrade"), bean.optString("price").toString(), NCoinManager.getCoinShowPrecision(symbol))
                if (BigDecimalUtils.compareTo(bean.optString("currentUserBanlance"), mul.toPlainString()) > 0) {
                    cet_total_money?.setText(mul.toString())
                }else{
                    cet_total_money?.setText(BigDecimalUtils.showSNormal(bean.optString("currentUserBanlance").toString()))
                }
                calculateForAmount(cet_total_money?.text.toString(), bean)
            }

        }

        /**
         *Click to place an order
         */
        cub_confirm_for_buy?.listener = object : CommonlyUsedButton.OnBottonListener {
            override fun bottonOnClick() {

                fundsPassDialog = NewDialogUtils.createNewVersionSecurityDialog(
                    this@NewVersionOTCSellActivity,
                    VerifyRule4(),
                    AppConstant.C2C_ORDER_SELL,
                    object : NewDialogUtils.DialogVerifiactionListener{
                        override fun returnCode(
                            phone: String?,
                            mail: String?,
                            googleCode: String?
                        ) {}

                        override fun returnCode(
                            phone: String,
                            mail: String,
                            googleCode: String,
                            capitalPwd: String,
                            loginPwd: String
                        ) {
                            super.returnCode(phone, mail, googleCode, capitalPwd, loginPwd)
                            sellOrderEnd4OTC(
                                advertID = advertID.toString(),
                                volume = if (priceOrtotal) amount4Symbol else amount,
                                price = bean.optString("price").toString(),
                                totalPrice = if (priceOrtotal) amount else amount4Symbol,
                                capitalPword = capitalPwd,
                                type = if (priceOrtotal) "price" else "volume",
                                googleCode,
                                phone
                            )
                            fundsPassDialog?.dismiss()
                        }
                    }
                )

            }

        }

    }

    var amount4Symbol = ""
    var WhetherThrough = true

    /**
     *Check if it exceeds the limit
     */
    fun detectionPrice(bean: JSONObject) {
        val redColor = ColorUtil.getColor(this,R.color.red)
        val textColor = ColorUtil.getColor(this,R.color.text_color)
        if (priceOrtotal) {
            var max = BigDecimalUtils.compareTo(amount, bean.optString("maxTrade").toString())
            if (max == 1) {
                WhetherThrough = false
                cet_total_money?.setTextColor(redColor)
                v_line?.setBackgroundResource(R.color.red)
                cub_confirm_for_buy?.isEnable(false)
                return
            } else {
                cet_total_money?.setTextColor(textColor)
                v_line?.setBackgroundResource(R.color.main_blue)
                cub_confirm_for_buy?.isEnable(true)
                WhetherThrough = true
            }

            var min = BigDecimalUtils.compareTo(bean.optString("minTrade").toString(), amount)
            if (min == 1) {
                cet_total_money?.setTextColor(redColor)
                v_line?.setBackgroundResource(R.color.red)
                cub_confirm_for_buy?.isEnable(false)
                WhetherThrough = false
            } else {
                cet_total_money?.setTextColor(textColor)
                v_line?.setBackgroundResource(R.color.main_blue)
                cub_confirm_for_buy?.isEnable(true)
                WhetherThrough = true
            }
        } else {
            var max = BigDecimalUtils.compareTo(amountPrice, bean.optString("maxTrade").toString())
            if (max == 1) {
                WhetherThrough = false
                cet_total_money?.setTextColor(redColor)
                v_line?.setBackgroundResource(R.color.red)
                cub_confirm_for_buy?.isEnable(false)
                return
            } else {
                WhetherThrough = true
                cet_total_money?.setTextColor(textColor)
                v_line?.setBackgroundResource(R.color.main_blue)
                cub_confirm_for_buy?.isEnable(true)
            }

            var min = BigDecimalUtils.compareTo(bean.optString("minTrade").toString(), amountPrice)
            if (min == 1) {
                WhetherThrough = false
                cet_total_money?.setTextColor(redColor)
                v_line?.setBackgroundResource(R.color.red)
                cub_confirm_for_buy?.isEnable(false)
                return
            } else {
                WhetherThrough = true
                cet_total_money?.setTextColor(textColor)
                v_line?.setBackgroundResource(R.color.main_blue)
                cub_confirm_for_buy?.isEnable(true)
                return
            }
        }
    }


    /**
     *Calculated based on price
     */
    fun calculateForPrice(temp: String, bean: JSONObject) {
        tv_market_price?.text = "≈ " + BigDecimalUtils.div(temp, bean.optString("price").toString(), NCoinManager.getCoinShowPrecision(bean.optString("coin"))).toPlainString() + NCoinManager.getShowMarket(bean.optString("coin"))
        amount4Symbol = BigDecimalUtils.div(temp, bean.optString("price").toString(), NCoinManager.getCoinShowPrecision(bean.optString("coin"))).toPlainString()
    }

    /**
     *Calculate based on the number of units
     */
    fun calculateForAmount(temp: String, bean: JSONObject) {
        amountPrice = BigDecimalUtils.mul(temp, bean.optString("price").toString(), NCoinManager.getCoinShowPrecision(bean.optString("payCoin"))).toPlainString()
        tv_market_price?.text = "≈ " + amountPrice + bean.optString("payCoin")
        amount4Symbol = amountPrice

    }


    var countTotalTime = 60

    /**
     *Process Cancel Button
     */
    private fun cancelBtnState() {
        mdDisposable?.dispose()
        mdDisposable = Flowable.intervalRange(0, 60, 0, 1, TimeUnit.SECONDS)
                .observeOn(AndroidSchedulers.mainThread())
                .doOnNext(object : Consumer<Long> {
                    override fun accept(t: Long?) {
                        btn_cancel?.setContent("${countTotalTime - t!!}s ${LanguageUtil.getString(this@NewVersionOTCSellActivity, "oct_action_autoCancelDesc")}")

                    }
                })


                .doOnComplete(object : Action {
                    override fun run() {
                        //Set countdown to clickable state
                        btn_cancel?.setContent("60s${LanguageUtil.getString(this@NewVersionOTCSellActivity, "oct_action_autoCancelDesc")}")
//                        finish()
                        getADDetail4OTC()

                    }
                })
                .subscribe()

        /**
         *Cancel
         */
        btn_cancel.setOnClickListener {
            finish()
        }
    }

    /**
     *Obtain advertising details
     */
    private fun getADDetail4OTC() {
        if (!UserDataService.getInstance().isLogined) {
            return
        }
        addDisposable(getOTCModel().getADDetail4OTC(advertID.toString(), object : NDisposableObserver(this) {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                var json = jsonObject.optJSONObject("data")
                initView(json)
            }

        }))

    }

    /**
     *Sell and place an order
     */
    private fun sellOrderEnd4OTC(advertID: String, volume: String, price: String, totalPrice: String, capitalPword: String, type: String,googleCode:String,smsAuthCode:String) {
        showLoadingDialog()
        HttpClient.instance
                .sellOrderEnd4OTC(
                    advertId = advertID,
                    volume = volume,
                    price = price,
                    totalPrice = totalPrice,
                    capitalPword = capitalPword,
                    type = type,
                    googleCode = googleCode,
                    smsAuthCode = smsAuthCode
                )
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<JsonObject>() {
                    override fun onHandleSuccess(t: JsonObject?) {
                        closeLoadingDialog()
                        if (t?.has("sequence")!!) {
                            /**
                             *Successfully placed the order, jump to the order details page for sale
                             */
                            var orderId = t.get("sequence").asString
                            NewVersionSellOrderActivity.enter2(this@NewVersionOTCSellActivity, orderId = orderId)
                            finish()
                        }
                    }

                    override fun onHandleError(code: Int, msg: String?) {
                        closeLoadingDialog()
                        NewDialogUtils.showSingleDialog(this@NewVersionOTCSellActivity, msg
                                ?: "", object : NewDialogUtils.DialogBottomListener {
                            override fun sendConfirm() {

                            }
                        }, "", LanguageUtil.getString(this@NewVersionOTCSellActivity, "alert_common_iknow"))

                    }
                })
    }


    override fun onDestroy() {
        super.onDestroy()
        if (mdDisposable != null) {
            mdDisposable?.dispose()
        }
    }
}
