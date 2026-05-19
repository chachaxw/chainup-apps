package com.yjkj.chainup.new_version.activity.otcTrading

import android.os.Bundle
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.LinearLayoutManager
import android.view.View
import com.alibaba.android.arouter.facade.annotation.Route
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseActivity
import com.yjkj.chainup.db.service.OTCPublicInfoDataService
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.manager.RateManager
import com.yjkj.chainup.net_new.JSONUtil
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_version.adapter.NewAdvertisingDetailAdapter
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.view.CommonlyUsedButton
import com.yjkj.chainup.new_version.view.NewOTCTextView
import com.yjkj.chainup.util.BigDecimalUtils
import com.yjkj.chainup.util.DateUtils
import com.yjkj.chainup.util.LogUtil
import com.yjkj.chainup.util.ToastUtils
import kotlinx.android.synthetic.main.activity_advertising_detail.*
import org.json.JSONObject

/**
 * @Author lianshangljl
 * @Date 2023-10-21-16:22
 * @Email buptjinlong@163.com
 *@description Advertising Details
 */
@Route(path = "/main/otc/NewAdvertisingDetailActivity")
class NewAdvertisingDetailActivity : NBaseActivity() {


    override fun setContentView() = R.layout.activity_advertising_detail
    var advertID = ""
    var referencePrice = "0"
    var payCoinPrecision = 2

    private var adapter: NewAdvertisingDetailAdapter? = null

    override fun onInit(savedInstanceState: Bundle?) {
        super.onInit(savedInstanceState)
        getData()
        setTextContent()
        initAdapter()
    }

    override fun onResume() {
        super.onResume()
        getADDetail4OTC()
    }

    fun setTextContent() {
        v_title?.setContentTitle(LanguageUtil.getString(this, "otc_advertise_detail"))
        net_create_time?.setToptitleContent("otc_create_time")
        ntt_advertising_id?.setToptitleContent("otc_text_advertiseID")
        ntt_coin_symbol?.setToptitleContent("common_text_coinsymbol")
        ntt_advertising_type?.setToptitleContent("otc_advertise_type")
        ntt_payCoin_type?.setToptitleContent("otc_coin_type")
        ntt_num_amount_type?.setToptitleContent("otc_leaveAndTotal")
        ntt_market_reference_price?.setToptitleContent("otc_market_ReferencPrice")
        net_pricing?.setToptitleContent("otc_setPrice_method")
        net_premium_direction?.setToptitleContent("otc_outPrice_direction")
        net_premium_direction_percentage?.setToptitleContent("otc_outPrice_percent")
        net_pricing_is_price?.setToptitleContent("otc_userSet_singlePrice")
        ntt_all_amount?.setToptitleContent("redpacket_send_total")
        net_minimum_limit?.setToptitleContent("otc_min_amount")
        net_max_limit?.setToptitleContent("otc_max_amount")
        net_limit_for_payment?.setToptitleContent("otc_payMoney_time")
        net_minimum_number_of_transactions?.setToptitleContent("otc_other_minTransactionTimes")
        net_failure_time?.setToptitleContent("otc_text_validTime")
        net_auto_reply?.setToptitleContent("otc_text_autoBack")
        net_advertising_message?.setToptitleContent("otc_text_advertiseLeaveWords")
    }

    fun initAdapter() {
        adapter = NewAdvertisingDetailAdapter(arrayListOf())
        rg_complaint_layout?.layoutManager = LinearLayoutManager(this, LinearLayoutManager.HORIZONTAL, false)
        rg_complaint_layout?.layoutManager = GridLayoutManager(this, 3)
        rg_complaint_layout?.adapter = adapter
    }

    fun getData() {
        advertID = intent?.getStringExtra("advertID") ?: ""
    }


    fun initView(bean: JSONObject) {
        LogUtil.d(TAG, "NewAdvertisingDetailActivity==bean is $bean")
        payCoinPrecision = RateManager.getFiat4Coin(bean?.optString("payCoin"))
        getConsiderPrice(bean?.optString("coin"), bean?.optString("payCoin"))
        /**
         *Creation time
         */
        net_create_time?.setBottomContent(DateUtils.long2StringMS("yyyy-MM-dd HH:mm:ss", bean?.optLong("ctime")))

        /**
         *Advertising ID
         */
        ntt_advertising_id?.setBottomContent(bean?.optString("advertId"))
        /**
         *Trading currency pair
         */
        ntt_coin_symbol?.setBottomContent(NCoinManager.getShowMarket(bean?.optString("coin")))
        /**
         *Create Type
         */
        if (bean?.optString("side") == "BUY") {
            ntt_advertising_type?.setBottomContent(LanguageUtil.getString(this, "otc_action_buy"))
        } else {
            ntt_advertising_type?.setBottomContent(LanguageUtil.getString(this, "otc_action_sell"))
        }


        /**
         *Market price
         */
        ntt_market_reference_price?.listener = object : NewOTCTextView.OTCTextViewClickListener {
            override fun onclickTopImage() {
                NewDialogUtils.showSingleDialog(this@NewAdvertisingDetailActivity, LanguageUtil.getString(this@NewAdvertisingDetailActivity, "otc_market_ReferencPriceDetail"), object : NewDialogUtils.DialogBottomListener {
                    override fun sendConfirm() {

                    }
                }, cancelTitle = "ok")
            }

            override fun onclickBottomImage() {

            }
        }
        /**
         *Pricing method
         */
        if (bean?.optString("priceRateType") == "0") {
            net_pricing?.setBottomContent(LanguageUtil.getString(this, "otc_custom_price"))
        } else {
            net_pricing?.setBottomContent(LanguageUtil.getString(this, ("otc_text_marketPrice")))
            net_premium_direction?.visibility = View.VISIBLE
            net_premium_direction_percentage?.visibility = View.VISIBLE
            when (bean?.optString("priceRateType")) {
                "2" -> {
                    net_premium_direction?.setBottomContent(LanguageUtil.getString(this, "otc_aboveReference_price"))
                }
                "3" -> {
                    net_premium_direction?.setBottomContent(LanguageUtil.getString(this, "otc_belowReference_price"))
                }
            }
            net_premium_direction_percentage?.setBottomContent(BigDecimalUtils.subZeroAndDot(BigDecimalUtils.showSNormal(bean?.optString("priceRate"))))
            net_premium_direction_percentage?.setRightContent("%")


        }

        /**
         *Custom Price
         */
        net_pricing_is_price?.setBottomContent(BigDecimalUtils.divForDown(bean?.optString("price").toString(), payCoinPrecision).toPlainString())
        net_pricing_is_price?.setRightContent(bean?.optString("payCoin"))

        /**
         *Total amount
         */
        ntt_all_amount?.setBottomContent(BigDecimalUtils.divForDown(bean?.optString("totalPrice"), payCoinPrecision).toPlainString() + "${bean?.optString("payCoin")}")
        /**
         *Minimum limit
         */
        net_minimum_limit?.setBottomContent(BigDecimalUtils.divForDown(bean?.optString("minTrade").toString(), payCoinPrecision).toPlainString())
        net_minimum_limit?.setRightContent(bean?.optString("payCoin"))
        /**
         *Maximum limit
         */
        net_max_limit?.setRightContent(bean?.optString("payCoin"))
        net_max_limit?.setBottomContent(BigDecimalUtils.divForDown(bean?.optString("maxTrade"), payCoinPrecision).toPlainString())
        /**
         *Limited time payment
         */
        net_limit_for_payment?.setBottomContent(bean?.optString("limitTime").toString())
        net_limit_for_payment?.setRightContent(LanguageUtil.getString(this, "otc_payMoney_timeMinute"))

        /**
         *Currency type
         */
        var payCoinList = OTCPublicInfoDataService.getInstance().paycoins
        payCoinList?.forEach {
            if (it.optString("key") == bean?.optString("payCoin")) {
                ntt_payCoin_type?.setBottomContent(it.optString("title"))
            }
        }

        /**
         *Remaining quantity/total quantity
         */
        var rate = NCoinManager.getCoinShowPrecision(bean?.optString("coin"))
        ntt_num_amount_type?.setBottomContent(BigDecimalUtils.divForDown(bean?.optString("volumeBalance").toString(), rate).toPlainString() + "/" +
                BigDecimalUtils.divForDown(bean?.optString("volume").toString(), rate).toPlainString() + " ${NCoinManager.getShowMarket(bean?.optString("coin"))}")

        /**
         *Minimum number of transactions by the counterparty
         */
        net_minimum_number_of_transactions?.setBottomContent(bean?.optString("dealVolume", "").toString())
        /**
         *Expiration time
         */
        net_failure_time?.setBottomContent(bean?.optString("days").toString() + LanguageUtil.getString(this, "otc_advertiseValid_day"))
        /**
         *Payment method
         */
        if (null != bean?.optJSONArray("payments") || bean?.optJSONArray("payments").length() != 0) {

            var jsonArray = bean?.optJSONArray("payments")

            var jsonList = JSONUtil.arrayToList(jsonArray)
            adapter?.setList(jsonList)
        }


        /**
         *Automatic reply
         */
        net_auto_reply?.setBottomContent(bean?.optString("autoReply"))


        /**
         *Advertising messages
         */
        net_advertising_message?.setBottomContent(bean?.optString("description"))


        /**
         *Last button
         */
        when (bean?.optInt("status")) {
            1 -> {
                cub_confirm?.isEnable(true)
                cub_confirm?.setContent(LanguageUtil.getString(this, "otc_close_advertise"))

            }
            2 -> {
                cub_confirm?.isEnable(true)
                cub_confirm?.setContent(LanguageUtil.getString(this, "otc_close_advertise"))
            }
            3 -> {
                cub_confirm?.isEnable(false)
                cub_confirm?.setContent(LanguageUtil.getString(this, "otc_text_expired"))
            }
            4 -> {
                cub_confirm?.isEnable(false)
                cub_confirm?.setContent(LanguageUtil.getString(this, "otc_have_closed"))
            }
        }
        cub_confirm?.listener = object : CommonlyUsedButton.OnBottonListener {
            override fun bottonOnClick() {
                NewDialogUtils.showNormalDialog(this@NewAdvertisingDetailActivity, LanguageUtil.getString(this@NewAdvertisingDetailActivity, "otc_confirm_closeAdvertise"), object : NewDialogUtils.DialogBottomListener {
                    override fun sendConfirm() {
                        cancelAdvertising()
                    }

                }, cancelTitle = LanguageUtil.getString(this@NewAdvertisingDetailActivity, "determine"), confirmTitle = LanguageUtil.getString(this@NewAdvertisingDetailActivity, "common_text_btnCancel"))
            }
        }

    }


    /**
     *Cancel Advertising
     */
    private fun cancelAdvertising() {

        addDisposable(getOTCModel().cancelWantend(advertID, object : NDisposableObserver(this, true) {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                ToastUtils.showToast(LanguageUtil.getString(this@NewAdvertisingDetailActivity, "otc_have_closedAdvertise"))
                finish()
            }
        }))
    }

    /**
     *Obtain reference price
     */
    fun getConsiderPrice(coinSymbol: String, payCoin: String) {
        addDisposable(getOTCModel().considerPrice(coinSymbol, payCoin, object : NDisposableObserver(this@NewAdvertisingDetailActivity) {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                var t = jsonObject.optJSONObject("data")

                referencePrice = BigDecimalUtils.divForDown(t?.optString("referencePrice")
                        ?: "0.00", payCoinPrecision).toPlainString()
                ntt_market_reference_price?.setBottomContent("$referencePrice${payCoin}")
            }

        }))


    }


    /**
     *Obtain advertising details
     */
    private fun getADDetail4OTC() {
        if (!UserDataService.getInstance().isLogined) {
            return
        }
        addDisposable(getOTCModel().getADDetail4OTC(advertID, object : NDisposableObserver(this, true) {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                var json = jsonObject.optJSONObject("data") ?: return
                initView(json)
            }

        }))

    }
}
