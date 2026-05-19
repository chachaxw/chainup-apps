package com.yjkj.chainup.new_version.activity.asset

import android.app.Activity
import android.content.Intent
import android.graphics.Typeface
import android.os.Bundle
import androidx.core.content.ContextCompat
import android.view.Gravity
import android.view.View
import androidx.core.widget.addTextChangedListener
import com.alibaba.android.arouter.facade.annotation.Autowired
import com.alibaba.android.arouter.facade.annotation.Route
import com.chainup.contract.view.CpTabEntity
import com.chainup.kit.utils.StringUtil
import com.chainup.kit.utils.ToastUtils
import com.chainup.kit.views.PublicHeaderKit
import com.flyco.tablayout.listener.OnTabSelectListener
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseActivity
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.manager.ActivityManager
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_version.activity.CoinMapSelectActivity
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.view.BorrowingAndReturnView
import com.yjkj.chainup.new_version.view.CommonlyUsedButton
import com.yjkj.chainup.util.BigDecimalUtils
import com.yjkj.chainup.util.tr
import kotlinx.android.synthetic.main.activity_borrowing.*
import kotlinx.android.synthetic.main.item_borrowing_and_return_view.view.et_amount
import org.json.JSONObject

/**
 * @Author lianshangljl
 * @Date 2023-11-09-10:44
 * @Email buptjinlong@163.com
 *@description Loan
 */
@Route(path = RoutePath.NewVersionBorrowingActivity)
class NewVersionBorrowingActivity : NBaseActivity() {
    override fun setContentView() = R.layout.activity_borrowing


    @JvmField
    @Autowired(name = ParamConstant.symbol)
    var symbol = ""

    var selectEmptyOrMore: ArrayList<String> = arrayListOf()


    override fun onInit(savedInstanceState: Bundle?) {
        super.onInit(savedInstanceState)
//        setSupportActionBar(toolbar)
//        toolbar?.setNavigationOnClickListener {
//            finish()
//        }
//        collapsing_toolbar?.setCollapsedTitleTextColor(ContextCompat.getColor(mActivity, R.color.text_color))
//        collapsing_toolbar?.setExpandedTitleColor(ContextCompat.getColor(mActivity, R.color.text_color))
//        collapsing_toolbar?.setExpandedTitleTypeface(Typeface.DEFAULT_BOLD)
//        collapsing_toolbar?.expandedTitleGravity = Gravity.BOTTOM
        ly_appbar?.setContentTitle(LanguageUtil.getString(this, "leverage_borrow"))
            ArouterUtil.inject(this)
        bar_layout?.setFirstTitleContent(LanguageUtil.getString(this, "leverage_asset"))
        bar_layout?.setSecondTitleContent(LanguageUtil.getString(this, "leverage_have_borrowed"))
        bar_layout?.setThirdTitleContent(LanguageUtil.getString(this, "leverage_text_biggestLimit"))
        bar_layout?.setFourthTitleContent(LanguageUtil.getString(this, "leverage_rate"))
        bar_layout?.setColumeTitle(LanguageUtil.getString(this, "charge_text_volume"))
        btn_confirm?.textContent=(LanguageUtil.getString(this, "leverage_borrow"))
        ly_appbar?.apply {
            this.setTvRightText(LanguageUtil.getString(this@NewVersionBorrowingActivity, "leverage_borrowRecord"))
            this.listener=object : PublicHeaderKit.IOnBackClickListener {
                override fun onRightBtn(view: View) {
                    super.onRightBtn(view)
                    ArouterUtil.navigation(RoutePath.LeverActivity, Bundle().apply {
                        putString(ParamConstant.symbol, symbol)
                        putInt(ParamConstant.CUR_INDEX, ParamConstant.CURRENT_TYPE)
                    })
                }
            }
        }
    }


    override fun onResume() {
        super.onResume()
        bar_layout?.setEdittextContent("")
        getBalanceList()
    }

    var symbolJSONObject = JSONObject()


    /**
     *Obtain a list of leveraged accounts
     */
    fun getBalanceList() {
        addDisposable(getMainModel().getBalance4Lever(symbol, object : NDisposableObserver(mActivity) {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                symbolJSONObject = jsonObject.optJSONObject("data")
                if (null != symbolJSONObject) {
                    setEmptyAndMore()
                }

            }
        }))
    }


    /**
     *Fill in data
     */
    fun setBorrowingAndReturnView() {
        bar_layout?.setFirst(NCoinManager.getShowMarketName(symbolJSONObject.optString("name", "")))
        var rate = BigDecimalUtils.mulStr(symbolJSONObject.optString("rate"), "100",2)
        when (dialogSelect) {
            /**
             *Short selling
             */
            ParamConstant.TYPE_BUY -> {

                bar_layout?.setSecond("${BigDecimalUtils.divForDown(symbolJSONObject.optString("baseBorrowBalance", ""), ParamConstant.NORMAL_PRECISION).toPlainString()} ${NCoinManager.getShowMarket(baseCoin)}")
                bar_layout?.setThird("${BigDecimalUtils.divForDown(symbolJSONObject.optString("baseTotalBorrow", ""), ParamConstant.NORMAL_PRECISION).toPlainString()} ${NCoinManager.getShowMarket(baseCoin)}")
                bar_layout?.setFourth("$rate%")
                bar_layout?.setEdittextFilter(ParamConstant.NORMAL_EDITTEXT)
                bar_layout?.setEditHintContent(BigDecimalUtils.divForDown(symbolJSONObject.optString("baseMinBorrow", ""), ParamConstant.NORMAL_EDITTEXT).toPlainString())
                bar_layout?.setEditTextCoinContent(NCoinManager.getShowMarket(symbolJSONObject.optString("baseCoin", "")))
                bar_layout?.setEndTextViewContent(BigDecimalUtils.divForDown(symbolJSONObject.optString("baseCanBorrow", ""), ParamConstant.NORMAL_EDITTEXT).toPlainString())
            }
            /**
             *Go long
             */
            ParamConstant.TYPE_SELL -> {

                bar_layout?.setSecond("${BigDecimalUtils.divForDown(symbolJSONObject.optString("quoteBorrowBalance", ""), ParamConstant.NORMAL_PRECISION).toPlainString()} ${NCoinManager.getShowMarket(quoteCoin)}")
                bar_layout?.setThird("${BigDecimalUtils.divForDown(symbolJSONObject.optString("quoteTotalBorrow", ""), ParamConstant.NORMAL_PRECISION).toPlainString()} ${NCoinManager.getShowMarket(quoteCoin)}")
                bar_layout?.setFourth("$rate%")
                bar_layout?.setEdittextFilter(ParamConstant.NORMAL_EDITTEXT)
                bar_layout?.setEditHintContent(BigDecimalUtils.divForDown(symbolJSONObject.optString("quoteMinBorrow", ""), ParamConstant.NORMAL_EDITTEXT).toPlainString())
                bar_layout?.setEditTextCoinContent(NCoinManager.getShowMarket(symbolJSONObject.optString("quoteCoin", "")))
                bar_layout?.setEndTextViewContent(BigDecimalUtils.divForDown(symbolJSONObject.optString("quoteCanBorrow", ""), ParamConstant.NORMAL_EDITTEXT).toPlainString())
            }
        }
        btn_confirm?.isEnable(false)

        bar_layout?.et_amount?.addTextChangedListener {
            val textValue = bar_layout?.et_amount?.text ?: ""
            var content = textValue.toString()
            if(content.endsWith(".")) {
                btn_confirm?.isEnable(false)
                return@addTextChangedListener
            }
            if(!StringUtil.isNumeric(content)) {
                btn_confirm?.isEnable(false)
                return@addTextChangedListener
            }
            if(BigDecimalUtils.compareTo(content,"0")<=0){
                btn_confirm?.isEnable(false)
                return@addTextChangedListener
            }
            btn_confirm?.isEnable(!"".equals(textValue.toString()))
        }
        /**
         *Loan button
         */
        btn_confirm?.setOnClickListener {
            if (setConfirmError(bar_layout?.minVolume ?: "0")) {
                when (dialogSelect) {
                    /**
                     *Short selling
                     */
                    ParamConstant.TYPE_BUY -> {
                        setBorrowing(symbolJSONObject.optString("symbol", ""), symbolJSONObject.optString("baseCoin", ""), bar_layout?.minVolume
                            ?: "0")
                    }
                    /**
                     *Go long
                     */
                    ParamConstant.TYPE_SELL -> {
                        setBorrowing(symbolJSONObject.optString("symbol", ""), symbolJSONObject.optString("quoteCoin", ""), bar_layout?.minVolume
                            ?: "0")
                    }

                }

            }
        }


        /**
         *Click to select a currency pair
         */
        rl_lever_account_layout?.setOnClickListener {
//            ArouterUtil.navigation4Result(RoutePath.CoinMapActivity, Bundle().apply {
//                putBoolean(ParamConstant.SEARCH_COIN_MAP_FOR_LEVER, true)
//            }, mActivity, ParamConstant.BORROW_TYPE)
            ArouterUtil.navigation4Result(RoutePath.CoinMapSelectActivity, Bundle().apply {
                putBoolean(ParamConstant.SEARCH_COIN_MAP_FOR_LEVER, true)
                putBoolean(ParamConstant.SEARCH_COIN_MAP_FOR_LEVER_UNREFRESH, false)
            },this,ParamConstant.BORROW_TYPE)
            bar_layout?.setEdittextContent("")
        }
        /**
         *Click on all
         */
        bar_layout?.listener = object : BorrowingAndReturnView.AllBtnClickListener {
            override fun btnClick() {

                var canBorrow = ""
                var orecision = 0
                var normalBalance = ""
                var coin = ""
                when (dialogSelect) {
                    ParamConstant.TYPE_BUY -> {
                        canBorrow = symbolJSONObject.optString("baseCanBorrow", "")
                        coin = symbolJSONObject.optString("baseCoin", "")
                        normalBalance = symbolJSONObject.optString("baseNormalBalance", "")
                        orecision = NCoinManager.getCoinShowPrecision(symbolJSONObject.optString("baseCoin", ""))
                    }
                    ParamConstant.TYPE_SELL -> {
                        canBorrow = symbolJSONObject.optString("quoteCanBorrow", "")
                        coin = symbolJSONObject.optString("quoteCoin", "")
                        normalBalance = symbolJSONObject.optString("quoteNormalBalance", "")
                        orecision = NCoinManager.getCoinShowPrecision(symbolJSONObject.optString("quoteCoin", ""))
                    }
                }
                bar_layout?.setEditTextCoinContent(NCoinManager.getShowMarket(coin))
                /**
                 *If two numbers are the same, return 0; if the first number is larger than the second number, return 1; otherwise, return -1
                 */
                bar_layout?.setEdittextContent(BigDecimalUtils.divForDown(canBorrow, ParamConstant.NORMAL_EDITTEXT).toPlainString())
            }
        }
        if (BigDecimalUtils.compareTo(symbolJSONObject.optString("symbolBalance"), "0") == 0) {
            showTransferDialog()
            return
        }
    }

    fun setConfirmError(amount: String): Boolean {
        if (amount == "") {
            showSnackBar(LanguageUtil.getString(this,"cl_input_the_volume_str"))
//            ToastUtils.showToast(this,"leverage_loan_quantity_check".tr(this))
            return false
        }
        /**
         *If two numbers are the same, return 0; if the first number is larger than the second number, return 1; otherwise, return -1
         */
        when (dialogSelect) {
            /**
             *Short selling
             */
            ParamConstant.TYPE_BUY -> {

                val min = BigDecimalUtils.compareTo(BigDecimalUtils.divForDown(symbolJSONObject.optString("baseMinBorrow", ""), NCoinManager.getCoinShowPrecision(baseCoin)).toPlainString(), amount)
                if (min == 1) {
                    var msg = String.format(LanguageUtil.getString(mActivity, "leverage_text_noLess"), BigDecimalUtils.showSNormal(symbolJSONObject.optString("baseMinBorrow", "")).toString(), NCoinManager.getShowMarket(baseCoin))
                    showSnackBar(msg, isSuc = false)
//                    bar_layout?.setReturnError(msg)
                    return false
                }
                val max = BigDecimalUtils.compareTo(BigDecimalUtils.divForDown(symbolJSONObject.optString("baseCanBorrow", ""), NCoinManager.getCoinShowPrecision(baseCoin)).toPlainString(), amount)
                if (max == -1) {
                    showSnackBar(LanguageUtil.getString(mActivity, "leverage_text_lessThanCanuse"), isSuc = false)
//                    bar_layout?.setReturnError(LanguageUtil.getString(mActivity, "leverage_text_lessThanCanuse"))
                    return false
                }

            }
            /**
             *Go long
             */
            ParamConstant.TYPE_SELL -> {

                val min = BigDecimalUtils.compareTo(BigDecimalUtils.divForDown(symbolJSONObject.optString("quoteMinBorrow", ""), NCoinManager.getCoinShowPrecision(baseCoin)).toPlainString(), amount)
                /**
                 *If two numbers are the same, return 0; if the first number is larger than the second number, return 1; otherwise, return -1
                 */
                if (min == 1) {
                    var msg = String.format(LanguageUtil.getString(mActivity, "leverage_text_noLess"), BigDecimalUtils.showSNormal(symbolJSONObject.optString("quoteMinBorrow", "")).toString(), NCoinManager.getShowMarket(quoteCoin))
                    showSnackBar(msg, isSuc = false)
//                    bar_layout?.setReturnError(msg)
                    return false
                }
                val max = BigDecimalUtils.compareTo(BigDecimalUtils.divForDown(symbolJSONObject.optString("quoteCanBorrow", ""), NCoinManager.getCoinShowPrecision(baseCoin)).toPlainString(), amount)
                if (max == -1) {
                    showSnackBar(LanguageUtil.getString(mActivity, "leverage_text_lessThanCanuse"), isSuc = false)
//                    bar_layout?.setReturnError(LanguageUtil.getString(mActivity, "leverage_text_lessThanCanuse"))
                    return false
                }
            }
        }
        return true
    }
    private var isShow = false
    private fun showTransferDialog() {
        var msg = String.format(LanguageUtil.getString(mActivity, "leverage_notEnught_prompt"), NCoinManager.getShowMarketName(symbolJSONObject.optString("name", "")))
        isShow = true
        NewDialogUtils.showNormalDialog(this@NewVersionBorrowingActivity, msg, object : NewDialogUtils.DialogBottomListener {
            override fun sendConfirm() {
                ActivityManager.pushAct2Stack(this@NewVersionBorrowingActivity)
                ArouterUtil.navigation(RoutePath.NewVersionTransferActivity, Bundle().apply {
                    putString(ParamConstant.TRANSFERSTATUS, ParamConstant.LEVER_INDEX)
                    putString(ParamConstant.TRANSFERSYMBOL, "")
                    putString(ParamConstant.TRANSFERCURRENCY, symbol)
                    putBoolean(ParamConstant.FROMBORROW, true)
                })
                finish()
            }

        }, "", LanguageUtil.getString(mActivity, "assets_action_transfer"), LanguageUtil.getString(mActivity, "common_text_btnCancel"))
    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (resultCode == Activity.RESULT_OK) {
            when (requestCode) {
                /**Currency*/
                ParamConstant.BORROW_TYPE -> {
                    symbol = data?.getStringExtra(ParamConstant.symbol) ?: ""
                }
            }
        }
    }

    var dialogSelect = 0
    var baseCoin = ""
    var quoteCoin = ""

    /**
     *Obtaining Multiple and Empty Data
     */
    fun setEmptyAndMore() {
        baseCoin = symbolJSONObject.optString("baseCoin", "")
        quoteCoin = symbolJSONObject.optString("quoteCoin", "")
        selectEmptyOrMore.clear()

        selectEmptyOrMore?.add(String.format(LanguageUtil.getString(mActivity, "leverage_short"), NCoinManager.getShowMarket(baseCoin)))
        selectEmptyOrMore?.add(String.format(LanguageUtil.getString(mActivity, "leverage_more"), NCoinManager.getShowMarket(quoteCoin)))
        changeCurrent()
        when (dialogSelect) {
            ParamConstant.TYPE_BUY -> {
                bar_layout?.setEditTextCoinContent(NCoinManager.getShowMarket(baseCoin))
            }
            ParamConstant.TYPE_SELL -> {
                bar_layout?.setEditTextCoinContent(NCoinManager.getShowMarket(quoteCoin))
            }
        }



        tv_lever_account_title?.text = "${NCoinManager.getShowMarketName(symbolJSONObject.optString("name", ""))} ${LanguageUtil.getString(mActivity, "leverage_asset")}"
        stl_market_loop?.setOnTabSelectListener(object : OnTabSelectListener {
            override fun onTabSelect(position: Int) {
                dialogSelect = position
                when (dialogSelect) {
                    ParamConstant.TYPE_BUY -> {
                        bar_layout?.setEditTextCoinContent(NCoinManager.getShowMarket(baseCoin))
                    }
                    ParamConstant.TYPE_SELL -> {
                        bar_layout?.setEditTextCoinContent(NCoinManager.getShowMarket(quoteCoin))
                    }
                }
                bar_layout?.setEdittextContent("")
                setBorrowingAndReturnView()
            }

            override fun onTabReselect(position: Int) {

            }

        })
        setBorrowingAndReturnView()

    }

    /**
     *Lending
     */
    fun setBorrowing(symbol: String, coin: String, amount: String) {
        addDisposable(getMainModel().setBorrow(symbol, coin, amount, object : NDisposableObserver(mActivity,true) {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                ToastUtils.showNewToast(this@NewVersionBorrowingActivity,"leverage_loan_success".tr(this@NewVersionBorrowingActivity))
                finish()
            }
        }))
    }

    private fun changeCurrent() {
        stl_market_loop?.apply {
            val itemFirst = CpTabEntity(NCoinManager.getShowMarket(selectEmptyOrMore[0]), 0, 0)
            val itemTwo = CpTabEntity(NCoinManager.getShowMarket(selectEmptyOrMore[1]), 0, 0)
            setTabData(arrayListOf(itemFirst, itemTwo))
        }
    }


}
