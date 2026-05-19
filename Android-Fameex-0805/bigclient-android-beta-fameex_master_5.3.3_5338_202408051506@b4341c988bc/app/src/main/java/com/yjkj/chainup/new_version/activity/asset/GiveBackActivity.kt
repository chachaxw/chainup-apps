package com.yjkj.chainup.new_version.activity.asset

import android.graphics.Typeface
import android.os.Bundle
import android.text.Editable
import androidx.core.content.ContextCompat
import android.text.TextUtils
import android.text.TextWatcher
import android.view.Gravity
import com.alibaba.android.arouter.facade.annotation.Autowired
import com.alibaba.android.arouter.facade.annotation.Route
import com.chainup.kit.utils.ToastUtils
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseActivity
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_version.view.BorrowingAndReturnView
import com.yjkj.chainup.new_version.view.CommonlyUsedButton
import com.yjkj.chainup.util.BigDecimalUtils
import com.yjkj.chainup.util.LogUtil
import com.yjkj.chainup.util.tr
import kotlinx.android.synthetic.main.activity_give_back.*
import kotlinx.android.synthetic.main.item_borrowing_and_return_view.view.et_amount
import org.json.JSONObject

/**
 * @Author lianshangljl
 * @Date 2023-11-11-11:48
 * @Email buptjinlong@163.com
 *@description Return
 */
@Route(path = RoutePath.GiveBackActivity)
class GiveBackActivity : NBaseActivity() {
    override fun setContentView() = R.layout.activity_give_back


    var giveBackJSONObject = JSONObject()
    var symbolJsonobject = JSONObject()

    @JvmField
    @Autowired(name = ParamConstant.JSON_BEAN)
    var json = ""

    var coin = ""
    var symbol = ""
    var oweAmount = ""

    override fun onInit(savedInstanceState: Bundle?) {
        super.onInit(savedInstanceState)
        setSupportActionBar(toolbar)
        toolbar?.setNavigationOnClickListener {
            finish()
        }
        collapsing_toolbar?.setCollapsedTitleTextColor(ContextCompat.getColor(mActivity, R.color.text_color))
        collapsing_toolbar?.setExpandedTitleColor(ContextCompat.getColor(mActivity, R.color.text_color))
        collapsing_toolbar?.setExpandedTitleTypeface(Typeface.DEFAULT_BOLD)
        collapsing_toolbar?.expandedTitleGravity = Gravity.BOTTOM
        collapsing_toolbar?.title = LanguageUtil.getString(this,"asset_give_back")
        ArouterUtil.inject(this)
        initView()
        bar_layout?.setFirstTitleContent(LanguageUtil.getString(this,"leverage_asset"))
        bar_layout?.setSecondTitleContent(LanguageUtil.getString(this,"leverage_returnCoin"))
        bar_layout?.setThirdTitleContent(LanguageUtil.getString(this,"leverage_shouldReturn_amount"))
        bar_layout?.setFourthTitleContent(LanguageUtil.getString(this,"leverage_totalBorrow_amount"))
        bar_layout?.setFifthTitleContent(LanguageUtil.getString(this,"leverage_interest"))
        bar_layout?.setColumeTitle(LanguageUtil.getString(this,"charge_text_volume"))
    }


    override fun initView() {
        super.initView()
        giveBackJSONObject = JSONObject(json)
        if (null != giveBackJSONObject) {
            setDataView()
        }
    }


    fun setDataView() {
        //Add precision to TODO after determining accuracy
        if (null == giveBackJSONObject) return
        coin = giveBackJSONObject.optString("coin", "")
        symbol = giveBackJSONObject.optString("symbol", "")
        precision = NCoinManager.getCoinShowPrecision(coin)
        oweAmount = BigDecimalUtils.divForDown(BigDecimalUtils.add(giveBackJSONObject.optString("oweAmount", ""), giveBackJSONObject.optString("oweInterest", "")).toPlainString(), 8).toPlainString()
        bar_layout?.setFirst(NCoinManager.getShowMarketName(symbol))
        bar_layout?.setSecond(NCoinManager.getShowMarket(coin))
        bar_layout?.setEdittextFilter(8)
        bar_layout?.setThird("$oweAmount ${NCoinManager.getShowMarket(coin)}")
        bar_layout?.setEditTextCoinContent(NCoinManager.getShowMarket(coin))
        bar_layout?.setFourth(BigDecimalUtils.divForDown(giveBackJSONObject.optString("borrowMoney", ""), 8).toPlainString())
        bar_layout?.setFifth(BigDecimalUtils.divForDown(giveBackJSONObject.optString("oweInterest", ""), 8).toPlainString())
        getBalanceList(symbol)
        bar_layout?.listener = object : BorrowingAndReturnView.AllBtnClickListener {
            override fun btnClick() {
                var canBorrow = ""
                var orecision = 8
                var coin = ""
                canBorrow = BigDecimalUtils.add(giveBackJSONObject.optString("oweAmount", ""), giveBackJSONObject.optString("oweInterest", "")).toPlainString()
                coin = giveBackJSONObject.optString("coin", "")
//                orecision = NCoinManager.getCoinShowPrecision(coin)

                bar_layout?.setEditTextCoinContent(NCoinManager.getShowMarket(coin))
                var max = BigDecimalUtils.compareTo(BigDecimalUtils.divForDown(canBorrow, orecision).toPlainString(), BigDecimalUtils.divForDown(normalBalance, orecision).toPlainString())
                /**
                 *If two numbers are the same, return 0; if the first number is larger than the second number, return 1; otherwise, return -1
                 */
                if (max == 1) {
                    bar_layout?.setEdittextContent(BigDecimalUtils.divForDown(normalBalance, 8).toPlainString())
                } else {
                    bar_layout?.setEdittextContent(BigDecimalUtils.divForDown(canBorrow, 8).toPlainString())
                }
            }

        }
        btn_confirm?.isEnable(false)
        bar_layout?.et_amount?.addTextChangedListener(object: TextWatcher{
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {

            }

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {

            }

            override fun afterTextChanged(s: Editable?) {
                val textValue = bar_layout?.et_amount?.text?:""
                btn_confirm?.isEnable(!"".equals(textValue.toString()))
            }

        })

        btn_confirm?.listener = object : CommonlyUsedButton.OnBottonListener {
            override fun bottonOnClick() {
                var minVolume = bar_layout?.minVolume
                if (TextUtils.isEmpty(minVolume)) {
                    minVolume = "0"
                }
                if (BigDecimalUtils.compareTo(minVolume, "0") == 0) {
                    ToastUtils.showToast(this@GiveBackActivity,"leverage_return_quantity_check".tr(this@GiveBackActivity))
//                    bar_layout?.setReturnError(LanguageUtil.getString(this@GiveBackActivity,"filter_Input_placeholder"))
                } else {
                    setReturn(giveBackJSONObject.optString("id", ""), bar_layout?.minVolume ?: "0")
                }
            }
        }

    }

    /**
     *Return
     */
    fun setReturn(id: String, amount: String) {
        addDisposable(getMainModel().setReturn(id, amount, object : NDisposableObserver(mActivity,true) {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                ToastUtils.showToast(this@GiveBackActivity,"leverage_return_success".tr(this@GiveBackActivity))
                finish()
            }
        }))
    }

    /**
     *Available
     */
    var normalBalance = ""
    /**
     *Repayment accuracy
     */
    var precision = 0
    /**
     *Minimum return
     */
    var minBorrow = ""

    /**
     *Obtain a list of leveraged accounts
     */
    fun getBalanceList(symbol: String) {
        addDisposable(getMainModel().getBalance4Lever(symbol, object : NDisposableObserver(mActivity) {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                symbolJsonobject = jsonObject.optJSONObject("data")
                if (null != symbolJsonobject) {
                    if (coin == symbolJsonobject.optString("quoteCoin", "")) {
                        normalBalance = symbolJsonobject.optString("quoteNormalBalance", "")
                        minBorrow = symbolJsonobject.optString("quoteMinPayment", "")

                    } else if (coin == symbolJsonobject.optString("baseCoin", "")) {
                        normalBalance = symbolJsonobject.optString("baseNormalBalance", "")
                        minBorrow = symbolJsonobject.optString("baseMinPayment", "")
                    }
                }
                bar_layout?.setFirst(NCoinManager.getShowMarketName(symbolJsonobject.optString("name", "$symbol")))
                bar_layout?.setGiveEndTextViewContent("${BigDecimalUtils.divForDown(normalBalance, 8).toPlainString()}")
                bar_layout?.setEditHintGiveBackContent("${LanguageUtil.getString(this@GiveBackActivity,"withdraw_text_minimumVolume")}${BigDecimalUtils.divForDown(minBorrow, 8).toPlainString()}")
            }
        }))
    }
}
