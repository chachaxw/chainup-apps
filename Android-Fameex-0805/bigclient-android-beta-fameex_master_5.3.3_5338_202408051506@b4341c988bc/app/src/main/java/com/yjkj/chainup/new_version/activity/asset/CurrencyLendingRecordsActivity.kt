package com.yjkj.chainup.new_version.activity.asset

import android.os.Bundle
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.LinearLayoutManager
import android.text.TextUtils
import android.widget.TextView
import com.alibaba.android.arouter.facade.annotation.Autowired
import com.alibaba.android.arouter.facade.annotation.Route
 import com.chainup.contract.view.dialog.CpTDialog
import com.chainup.kit.KKDialogUtils
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseActivity
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.manager.RateManager
import com.yjkj.chainup.net_new.JSONUtil
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_version.adapter.CurrencyLendingAdapter
import com.yjkj.chainup.new_version.view.EmptyForAdapterView
import com.yjkj.chainup.util.BigDecimalUtils
import com.yjkj.chainup.util.ColorUtil
import com.yjkj.chainup.util.StringUtil
import kotlinx.android.synthetic.main.activity_currency_lending_records.*
import kotlinx.android.synthetic.main.item_currency_lending_view.*
import org.jetbrains.anko.textColor
import org.json.JSONObject

/**
 * @Author lianshangljl
 * @Date 2023-11-13-11:04
 * @Email buptjinlong@163.com
 *@description Current loan
 */
@Route(path = RoutePath.CurrencyLendingRecordsActivity)
class CurrencyLendingRecordsActivity : NBaseActivity() {

    @JvmField
    @Autowired(name = ParamConstant.symbol)
    var symbol = ""

    @JvmField
    @Autowired(name = ParamConstant.JSON_BEAN)
    var jsonbean = ""

    var symbolJSONObject = JSONObject()
    var dialog:  CpTDialog? = null


    override fun setContentView() = R.layout.activity_currency_lending_records


    override fun onInit(savedInstanceState: Bundle?) {
        super.onInit(savedInstanceState)
        ArouterUtil.inject(this)
//        setSupportActionBar(toolbar)
//        toolbar?.setNavigationOnClickListener {
//            finish()
//        }
//        collapsing_toolbar?.setCollapsedTitleTextColor(ContextCompat.getColor(mActivity, R.color.text_color))
//        collapsing_toolbar?.setExpandedTitleColor(ContextCompat.getColor(mActivity, R.color.text_color))
//        collapsing_toolbar?.setExpandedTitleTypeface(Typeface.DEFAULT_BOLD)
//        collapsing_toolbar?.expandedTitleGravity = Gravity.BOTTOM



        recycler_view?.layoutManager = LinearLayoutManager(mActivity)
        adapter.setEmptyView(EmptyForAdapterView(this))
        recycler_view?.adapter = adapter

        adapter.setOnItemClickListener { adapter, view, position ->
            ArouterUtil.navigation(RoutePath.BorrowRecordsActivity, Bundle().apply {
                putString(ParamConstant.ORDER_ID, list[position].optString("id"))
            })
        }

    }

    override fun onResume() {
        super.onResume()
        if (!TextUtils.isEmpty(symbol)) {
            getBalanceList()
            getCurrent()
        } else {
            symbolJSONObject = JSONObject(jsonbean)
            if (null != symbolJSONObject) {
                symbol = symbolJSONObject.optString("symbol", "")
                initView()
                getCurrent()
            }

        }
    }

    var basePrecision = 0
    var quotePrecision = 0
    override fun initView() {
        ly_appbar?.setContentTitle( NCoinManager.getShowMarketName(symbolJSONObject.optString("name", "")))
        tv_contract_text_type?.text = LanguageUtil.getString(this,"contract_text_type")
        tv_assets_text_available?.text = LanguageUtil.getString(this,"assets_text_available")
        tv_assets_text_freeze?.text = LanguageUtil.getString(this,"assets_text_freeze")
        tv_leverage_have_borrowed?.text = LanguageUtil.getString(this,"leverage_have_borrowed")
        tv_currency_equivalence?.text = LanguageUtil.getString(this,"assets_text_equivalence")
        tv_current_application?.text = LanguageUtil.getString(this,"leverage_current_borrow")
        tv_asset_lever_history?.text = LanguageUtil.getString(this,"asset_lever_history")

        basePrecision = NCoinManager.getCoinShowPrecision(symbolJSONObject.optString("baseCoin"))
        quotePrecision = NCoinManager.getCoinShowPrecision(symbolJSONObject.optString("quoteCoin"))

        type_base?.text = NCoinManager.getShowMarket(symbolJSONObject.optString("baseCoin", ""))
        type_quote?.text = NCoinManager.getShowMarket(symbolJSONObject.optString("quoteCoin", ""))

        setRiskView()

        setBaseContent(canUse_base, symbolJSONObject.optString("baseNormalBalance", ""))
        setBaseContent(lock_base, symbolJSONObject.optString("baseLockBalance", ""))
        setBaseContent(tv_have_borrow_base, symbolJSONObject.optString("baseBorrowBalance", ""))

        setQuoteContent(canUse_quote, symbolJSONObject.optString("quoteNormalBalance", ""))
        setQuoteContent(lock_quote, symbolJSONObject.optString("quoteLockBalance", ""))
        setQuoteContent(tv_have_borrow_quote, symbolJSONObject.optString("quoteBorrowBalance", ""))
        var temp = RateManager.getCNYByCoinName("BTC", symbolJSONObject?.optString("symbolBalance", ""), isOnlyResult = true)

        tv_currency_equivalence?.text = "${ LanguageUtil.getString(mActivity,"assets_text_equivalence")} $temp ${RateManager.getCurrencyLang()}"

        /**
         *Loan records
         */
        ll_history_layout?.setOnClickListener {
            ArouterUtil.navigation(RoutePath.LeverActivity, Bundle().apply {
                putString(ParamConstant.symbol, symbol)
                putInt(ParamConstant.CUR_INDEX, ParamConstant.HISTORY_TYPE)
            })
        }
    }

    /**
     *Set Risk Rate Page
     */
    fun setRiskView() {
        //Risk rate
        var riskRate = symbolJSONObject.optString("riskRate", "--")
        if(StringUtil.isNumeric(riskRate) && BigDecimalUtils.compareTo(riskRate, "999")==1){
            riskRate = "999"
        }
        tv_risk_rate?.text =  "$riskRate%"
        tv_risk_rate_label?.text =  LanguageUtil.getString(mActivity,"leverage_risk")
//        if (BigDecimalUtils.compareTo(riskRate, "150") >= 0) {
//            riskRate = "150"
//        }
        val rateProgress = BigDecimalUtils.sub(riskRate,"110").toPlainString()
        progress_bar?.progress = if(BigDecimalUtils.compareTo(rateProgress,"100")>=0) 100 else rateProgress.toInt()
        if (BigDecimalUtils.compareTo(riskRate,"200") >= 0) {
            tv_risk_rate?.textColor = ColorUtil.getColor(R.color.green)
            progress_bar?.progressDrawable = ContextCompat.getDrawable(mContext!!, R.drawable.bg_progressbar_green)
        } else if (BigDecimalUtils.compareTo(riskRate,"110") >= 0 && BigDecimalUtils.compareTo(riskRate,"200") <= 0) {
            tv_risk_rate?.textColor = ColorUtil.getColor(R.color.red)
            progress_bar?.progressDrawable = ContextCompat.getDrawable(mContext!!, R.drawable.bg_progressbar_red)
        } else {
            tv_risk_rate?.textColor = ColorUtil.getColor(R.color.normal_text_color)
            tv_risk_rate?.text =  "--"
            progress_bar?.progressDrawable = ContextCompat.getDrawable(mContext!!, R.drawable.bg_progressbar_default)
        }
        iv_risk_rate?.setOnClickListener {
//            NewDialogUtils.showSingleDialog(this@CurrencyLendingRecordsActivity,  LanguageUtil.getString(mActivity,"leverage_risk_prompt"), object : NewDialogUtils.DialogBottomListener {
//                override fun sendConfirm() {
//                }
//            })

            KKDialogUtils.showCommonDialog(
                this,
                LanguageUtil.getString(mActivity,"leverage_risk_prompt"),
                LanguageUtil.getString(mActivity,"common_text_tip"),
                object : KKDialogUtils.DialogDoubleBottomListener {
                    override fun sendConfirm() {}
                    override fun sendCancel() {}
                },
                confrimTitle = LanguageUtil.getString(mActivity,"alert_common_i_understand"),
                isShowCancel = false,
                style = 1
            )
        }
    }


    fun setBaseContent(view: TextView, content: String) {
        view?.text = BigDecimalUtils.divForDown(content, 8).toPlainString()
    }

    fun setQuoteContent(view: TextView, content: String) {
        view?.text = BigDecimalUtils.divForDown(content, 8).toPlainString()
    }

    /**
     *Obtain a list of leveraged accounts
     */
    fun getBalanceList() {
        addDisposable(getMainModel().getBalanceList(object : NDisposableObserver(mActivity) {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                var json = jsonObject.optJSONObject("data")
                if (null != json) {
                    var leverMap = json.optJSONObject("leverMap")
                    if (null != leverMap) {
                        getSymbolJSONobject(leverMap)
                    }
                }
            }
        }))
    }

    /**
     *Obtain symbol from large interface
     */
    fun getSymbolJSONobject(jsonObject: JSONObject) {
        val iterator = jsonObject.keys()
        while (iterator.hasNext()) {
            val data = jsonObject.optJSONObject(iterator.next())
            if (null != data && data!!.length() > 0) {
                val symbolTemp = data!!.optString("symbol", "")
                if (symbolTemp == symbol) {
                    symbolJSONObject = data
                    initView()
                    return
                }
            }
        }
    }

    var list: ArrayList<JSONObject> = arrayListOf()

    val adapter = CurrencyLendingAdapter(list)


    /**
     *Obtain current loan
     */
    private fun getCurrent() {
        addDisposable(getMainModel().borrowNew(symbol,
                consumer = object : NDisposableObserver(mActivity) {
                    override fun onResponseSuccess(jsonObject: JSONObject) {
                        list.clear()
                        jsonObject.optJSONObject("data").run {
                            val orderJsonArray = optJSONArray("financeList")
                            if (null != orderJsonArray && orderJsonArray.length() != 0) {
                                list?.addAll(JSONUtil.arrayToList(orderJsonArray))
                            }
                            adapter.setList(list)
                        }
                    }
                }, pageSize = "1000"))
    }


}
