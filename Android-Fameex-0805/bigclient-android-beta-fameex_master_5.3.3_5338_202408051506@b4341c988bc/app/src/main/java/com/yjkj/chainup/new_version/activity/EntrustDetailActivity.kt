package com.yjkj.chainup.new_version.activity

import android.os.Bundle
import androidx.recyclerview.widget.LinearLayoutManager
import android.util.Log
import android.view.View
import com.alibaba.android.arouter.facade.annotation.Autowired
import com.alibaba.android.arouter.facade.annotation.Route
import com.fengniao.news.util.DateUtil
import com.google.android.material.appbar.AppBarLayout
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseActivity
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_version.adapter.EntrustDetailAdapter
import com.yjkj.chainup.new_version.view.EmptyForAdapterView
import com.yjkj.chainup.util.BigDecimalUtils
import com.yjkj.chainup.util.ColorUtil
import kotlinx.android.synthetic.main.activity_entrust_detai.*
import kotlinx.android.synthetic.main.layout_com_header.view.*
import kotlinx.android.synthetic.main.ly_entrust_detail_header.*
import org.jetbrains.anko.textColor
import org.json.JSONObject
import java.lang.Math.abs

/**
 * @author Bertking
 * @Date 2023-10-21
 *@description Delegation Details
 */
@Route(path = RoutePath.EntrustDetailActivity)
class EntrustDetailActivity : NBaseActivity() {
    var tradeList = ArrayList<JSONObject>()

    @JvmField
    @Autowired(name = "symbol")
    var symbol = ""

    @JvmField
    @Autowired(name = "id")
    var id = ""

    override fun setContentView() = R.layout.activity_entrust_detai

    override fun onResume() {
        super.onResume()

        getEntrustDetail(id = id, symbol = symbol)
    }

    override fun onInit(savedInstanceState: Bundle?) {
        super.onInit(savedInstanceState)
        setSupportActionBar(anim_toolbar)
        ly_appbar?.addOnOffsetChangedListener (AppBarLayout.OnOffsetChangedListener{ _, verticalOffset ->
            if (abs(verticalOffset) >= 140) {
                tv_title?.visibility = View.VISIBLE
                tv_sub_title?.visibility = View.GONE
            } else {
                tv_title?.visibility = View.GONE
                tv_sub_title?.visibility = View.VISIBLE
            }
        })
        initView()
    }
    override fun initView() {
        iv_back?.setOnClickListener {
            finish()
        }
        val adapter = EntrustDetailAdapter(tradeList)
        rv_detail?.layoutManager = LinearLayoutManager(mActivity)
        rv_detail?.adapter = adapter
        adapter.setEmptyView(EmptyForAdapterView(this))
        tv_sub_title?.text = LanguageUtil.getString(this,"transfer_text_entrustDetails")
        tv_title?.text = LanguageUtil.getString(this,"transfer_text_entrustDetails")
    }

    /**
     *Rendering order information
     */
    private fun renderOrderInfo(jsonObject: JSONObject?) {
        jsonObject?.optJSONObject("orderInfo")?.run {
            val side = optString("side")
            val baseCoin = optString("baseCoin")
            val countCoin = optString("countCoin")
            val volume = optString("volume")
            val price = optString("price")
            val orderType = optString("type")
            val remainVolume = optString("remain_volume")
            val dealVolume = optString("deal_volume")
            val avgPrice = optString("avg_price")
            /*Handling fees*/
            val feeCoin = optString("feeCoin")
            val fee = optString("fee")

            /*Deduction*/
            val tradeFeeCoin = optString("tradeFeeCoin")
            val tradeFee = optString("tradeFee")

            if (side.equals("BUY", ignoreCase = true)) {
                tv_side?.text = LanguageUtil.getString(this@EntrustDetailActivity,"otc_text_tradeObjectBuy")
                tv_side?.textColor = ColorUtil.getMainColorType()
            } else {
                tv_side?.text = LanguageUtil.getString(this@EntrustDetailActivity,"otc_text_tradeObjectSell")
                tv_side?.textColor = ColorUtil.getMainColorType(isRise = false)
            }

            /**
             *Currency pair
             */
            val pair = NCoinManager.getShowName(baseCoin, countCoin)
            tv_coin_name?.text = pair.first
            tv_market_name?.text = "/${pair.second}"


            tv_prices_title?.text = LanguageUtil.getString(this@EntrustDetailActivity,"contract_text_price")+"(" + pair.second + ")"
            tv_volumes_title?.text = LanguageUtil.getString(this@EntrustDetailActivity,"charge_text_volume")+"(" + pair.first + ")"


            /**
             *Date yyyy MM dd HH: mm: ss
             */
            val timeLong = optString("time_long")
            tv_date?.text = DateUtil.longToString("yyyy/MM/dd HH:mm", timeLong.toLong())

            tv_status?.text = LanguageUtil.getString(this@EntrustDetailActivity,"contract_text_orderComplete")

            /**
             *Number of Commissions
             */
            tv_volume?.text = BigDecimalUtils.showNormal(volume)
            tv_volume_title?.text = LanguageUtil.getString(this@EntrustDetailActivity,"charge_text_volume") + "(" + pair.first + ")"

            /**
             *Handling fees
             */
            tv_fees?.text = BigDecimalUtils.showNormal(fee)
            tv_fees_title?.text = LanguageUtil.getString(this@EntrustDetailActivity,"withdraw_text_fee") + "(" + feeCoin + ")"
            
            /**
             *Deduction
             */
            tv_discount?.text = BigDecimalUtils.showNormal(tradeFee)
            tv_discount_title?.text = LanguageUtil.getString(this@EntrustDetailActivity,"transfer_text_deduction") + "(" + tradeFeeCoin + ")"

            /**
             *Commission price
             *1 Limit Order 2 Market Order
             *There is no commission price on the market price list
             */
            if (orderType == "2") {
                tv_price?.text = LanguageUtil.getString(this@EntrustDetailActivity,"contract_text_typeMarket")
            } else {
                tv_price?.text = BigDecimalUtils.showNormal(price)
            }
            tv_price_title?.text = LanguageUtil.getString(this@EntrustDetailActivity,"contract_text_trustPrice") + "(" + pair.second + ")"

            /**
             *Not closed
             */
            tv_unsettled?.text = BigDecimalUtils.showNormal(remainVolume)
            tv_unsettled_title?.text = LanguageUtil.getString(this@EntrustDetailActivity,"transaction_text_orderUnsettled") + "(" + pair.first + ")"

            /**
             *Actual transaction
             */
            tv_deal_volume?.text = BigDecimalUtils.showNormal(dealVolume)
            tv_deal_volume_title?.text = LanguageUtil.getString(this@EntrustDetailActivity,"transaction_text_tradeValue") + "(" + pair.first + ")"

            /**
             *Average transaction price
             */
            tv_avg_price?.text = BigDecimalUtils.showNormal(avgPrice)
            tv_avg_price_title?.text = LanguageUtil.getString(this@EntrustDetailActivity,"contract_text_dealAverage") + "(" + pair.second + ")"

        }
    }

    /**
     *Obtain commission details
     */
    private fun getEntrustDetail(id: String, symbol: String = PublicInfoDataService.getInstance().currentSymbol) {
        if (!UserDataService.getInstance().isLogined) {
            return
        }
        addDisposable(getMainModel().getEntrustDetail4(id = id, symbol = symbol,
                page = "1",
                pageSize = "100", consumer = object : NDisposableObserver(mActivity) {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                tradeList.clear()
                jsonObject.optJSONObject("data").run {

                    renderOrderInfo(this)


                    val orderJsonArray = optJSONArray("trade_list") ?:return
                    if (orderJsonArray.length() != 0) {
                        orderJsonArray?.run {
                            for (i in 0 until orderJsonArray.length()) {
                                tradeList.add(orderJsonArray.optJSONObject(i))
                            }
                        }
                        initView()
                    }

                }
            }

        }))
    }
}
