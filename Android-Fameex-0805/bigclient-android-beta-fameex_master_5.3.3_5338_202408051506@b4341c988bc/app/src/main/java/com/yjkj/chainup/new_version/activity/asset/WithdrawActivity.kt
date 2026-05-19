package com.yjkj.chainup.new_version.activity.asset

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.text.Editable
import android.text.TextUtils
import android.text.TextWatcher
import android.view.View
import android.view.View.OnClickListener
import androidx.core.content.ContextCompat
import com.alibaba.android.arouter.facade.annotation.Route
import com.chainup.contract.utils.CpPermissionUtil
 import com.chainup.contract.view.dialog.CpTDialog
import com.chainup.kit.views.PublicHeaderKit
import com.chainup.kit.KKDialogUtils
import com.chainup.kit.dialog.KKTDialog
import com.chainup.kit.dialog.adapter.KKItemCardEntity
import com.tbruyelle.rxpermissions2.RxPermissions
import com.yjkj.chainup.R
import com.yjkj.chainup.app.AppConstant
import com.yjkj.chainup.base.NBaseActivity
import com.yjkj.chainup.bean.AuthBean
import com.yjkj.chainup.bean.EquityBean
import com.yjkj.chainup.bean.address.AddressBean
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.constant.ScanIntentEnum
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.manager.DataManager
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.manager.SymbolManager
import com.yjkj.chainup.net.HttpClient
import com.yjkj.chainup.net.retrofit.NetObserver
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.net_new.rxjava.NModelDisposableObserver
import com.yjkj.chainup.new_version.activity.CoinActivity
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.view.*
import com.yjkj.chainup.securityVerifyRule.VerifyRule3
import com.yjkj.chainup.util.*
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.activity_withdraw.*
import kotlinx.android.synthetic.main.activity_withdraw.mcv_layout
import kotlinx.android.synthetic.main.activity_withdraw.tv_fee_title
import kotlinx.android.synthetic.main.activity_withdraw.tv_number_title
import kotlinx.android.synthetic.main.layout_withdraw_amount_tip.*
import org.json.JSONArray
import org.json.JSONObject

/**
 * @Author lianshangljl
 * @Date 2023/5/16-10:11 AM
 * @Email buptjinlong@163.com
 *@description Withdrawing coins
 */
@Route(path = RoutePath.WithdrawActivity)
class WithdrawActivity : NBaseActivity() {
    override fun setContentView() = R.layout.activity_withdraw


    lateinit var bean: JSONObject

    /**
     *Accuracy of currency pairs
     */
    var coinPrecision = 0

    var addressId: Int = 0
    var fee: String = ""
    var amount: String = ""
    var actualaMount: String = ""
    var showSymbol: String = ""
    var symbol: String = ""


    var feeMax = ""
    var feeMin = ""
    var withdrawMin = ""
    var withdrawMan = ""

    var tokenBase = ""
    var address: String? = ""
    var addressTag = ""
    //is trust address?
    var addressStatus = false

    /**
     *Is there an address
     */
    var newAddress = true

    var isShowTag = true
    var eFeeStatus = true


    var tagBean = 0

    /**
     *Minimum withdrawal amount
     */
    var amountvalue = ""

    /**
     *Handling fees
     */
    var feevalue = ""

    var isShowDisableWithdrawDialog:Boolean = false

    companion object {
        const val WITHDRAW = "WITHDRAW"
        fun enter2(context: Context, bean: String?) {
            var intent = Intent()
            intent.setClass(context, WithdrawActivity::class.java)
            intent.putExtra(WITHDRAW, bean)
            context.startActivity(intent)

        }
    }

    fun getData() {
        intent ?: return
        var jsonString = intent.getStringExtra(WITHDRAW) ?: return
        bean = JSONObject(jsonString)
    }

    override fun onInit(savedInstanceState: Bundle?) {
        super.onInit(savedInstanceState)
        window.navigationBarColor = ContextCompat.getColor(this,R.color.special_3)
        getData()
        initView()
        initClickListener()
    }

    override fun initView() {
        tv_content.text = "withdraw_safety_tips".tr(this)
        tv_single_max_withdraw_label.text = "charge_chargeAlert_contentB".tr(this)
        title_layout?.setContentTitle(LanguageUtil.getString(this, "assets_action_withdraw"))
        title_layout?.setTvRightText(LanguageUtil.getString(this, "withdraw_action_withdrawHistory"))
        tv_can_use_amount_label.text = "kyc_withdrawal_amount".tr(this)
        tv_withdraw_amount_label.text = "kyc_withdrawal_24h".tr(this)
        tv_choose_symbol?.text = LanguageUtil.getString(this, "charge_action_selectCoin")
        tv_withdraw_adr_title?.text = LanguageUtil.getString(this, "withdraw_text_address")
        cet_withdraw_adr?.hint = LanguageUtil.getString(this, "withdraw_tip_addressEmpty")
        tv_adr_note_title?.text = LanguageUtil.getString(this, "charge_text_tagAddress")
        cet_withdraw_adr_note?.hint = LanguageUtil.getString(this, "withdraw_tip_tagEmpty")
        tv_number_title?.text = LanguageUtil.getString(this, "charge_text_volume")
        btn_all_amount?.text = LanguageUtil.getString(this, "common_action_sendall")
        et_amount?.hint = String.format(LanguageUtil.getString(this, "withdraw_tip_withdrawMinValueError"),"--")
        tv_fee_title?.text = LanguageUtil.getString(this, "withdraw_text_fee")
        tv_instructions_title?.text = LanguageUtil.getString(this, "withdraw_tip_notice")
        tv_withdraw_text_moneyWithoutFee?.text = LanguageUtil.getString(this, "withdraw_text_moneyWithoutFee")
        cubtn_confirm?.textContent = LanguageUtil.getString(this, "common_text_btnConfirm")

        if (null != bean?.has("coinName")) {
            showSymbol = bean?.optString("coinName").toString()
            symbol = showSymbol
        }
       var follCoinByMainList = PublicInfoDataService.getInstance().getFollowCoinsByMainCoinName(showSymbol,"withdraw")
        if (follCoinByMainList.size != 0) {
            getCost(follCoinByMainList[0].optString("name", ""))
        }else{
            getCost(symbol)
        }
        initManyChain()
        setView()

        getEquity(showSymbol)
        title_layout?.listener = object : PublicHeaderKit.IOnBackClickListener {
            override fun onRightBtn(view: View) {
                super.onRightBtn(view)
                WithDrawRecordActivity.enter2(this@WithdrawActivity, showSymbol, ParamConstant.TRANSFER_WITHDRAW_RECORD, WITHDRAWTYPE)
            }
        }
        /**
         *Minimum withdrawal amount
         */
        et_amount?.isFocusable = true
        et_amount?.isFocusableInTouchMode = true
        et_amount?.setOnFocusChangeListener { v, hasFocus ->
            view_amount_line?.setBackgroundResource(if (hasFocus) R.color.main_blue else R.color.new_line_color)
        }
        et_amount?.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(s: Editable?) {
                amountvalue = s.toString()

                realAmount(et_fee.text.toString(), s.toString())


            }

            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {
            }

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
            }
        })


        /**
         *New Address
         */
        cet_withdraw_adr?.isFocusable = true
        cet_withdraw_adr?.isFocusableInTouchMode = true
        cet_withdraw_adr?.setOnFocusChangeListener { v, hasFocus ->
            view_withdraw_adr_line?.setBackgroundResource(if (hasFocus) R.color.main_blue else R.color.new_line_color)
        }
        cet_withdraw_adr?.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(s: Editable?) {

            }

            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {

            }

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
                var add = s.toString()
                if(UserDataService.getInstance().withdrawWhitelistFlag==1) return
                if (add != address) {
                    addressId = 0
                    addressStatus = false
                }
                address = s.toString()

            }
        })
        /**
         *New Address Label
         */
        cet_withdraw_adr_note?.isFocusable = true
        cet_withdraw_adr_note?.isFocusableInTouchMode = true
        cet_withdraw_adr_note?.setOnFocusChangeListener { v, hasFocus ->
            view_withdraw_adr_note_line?.setBackgroundResource(if (hasFocus) R.color.main_blue else R.color.new_line_color)
        }
        cet_withdraw_adr_note?.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(s: Editable?) {

            }

            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {

            }

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
                addressTag = s.toString()
            }

        })

        val withdrawWhitelistFlag = UserDataService.getInstance().withdrawWhitelistFlag
        if(withdrawWhitelistFlag==1){
            iv_sweep_the_yard.visibility = View.GONE
            view_withdraw_line.visibility = View.GONE
            cet_withdraw_adr.isEnabled = true
            cet_withdraw_adr.isFocusable = false
            cet_withdraw_adr.isFocusableInTouchMode = false
            cet_withdraw_adr.isClickable = true
            cet_withdraw_adr.setOnClickListener(object: View.OnClickListener{
                override fun onClick(v: View?) {
                    createSelectWithdrawAddressDialog()
                }

            })
        }
    }

    private fun realAmount(fee: String, amount: String) {
        var value = "0"
        if (TextUtils.isEmpty(amount)) {

        } else {
            value = amount
        }

        if (value.startsWith(".")) {
            value = "0"
        }

        if (value.endsWith(".")) {
            value = value.substring(0, value.length - 1)
        }
        /**
         *Actual Received Quantity
         */
        var result = BigDecimalUtils.sub(value, fee).toString()
        /**
         *To avoid Scientific notation
         */
        if (amount.isEmpty()) {
            tv_real_amount?.text = "0" + NCoinManager.getShowMarket(showSymbol)
        } else {
            tv_real_amount?.setTextColor(ColorUtil.getColor(R.color.main_font_color))
            tv_real_amount?.text = BigDecimalUtils.showSNormal(BigDecimalUtils.divForDown(result, coinPrecision).toPlainString()) + NCoinManager.getShowMarket(showSymbol)
        }
    }

    /**
     *Set address related
     */
    private fun setAdressView(jsonObject: JSONObject, status: Boolean) {
        /**
         *Set Address
         */

        var withdrawAddressMaps: JSONArray
        if (status) {
            withdrawAddressMaps = JSONArray(jsonObject?.optString("withdrawAddressMap"))
        } else {
            withdrawAddressMaps = JSONArray(jsonObject?.optString("userWithdrawAddrList"))
        }

        if (null != withdrawAddressMaps && withdrawAddressMaps.length() > 0) {
            var bean = withdrawAddressMaps.optJSONObject(0)

            addressId = bean?.optInt("id") ?: 0
            addressRemark = bean?.optString("label")
            addressStatus = bean?.optInt("trustType") == 1
            val split = bean?.optString("address")?.split("_")

            if (null != split) {
                if (split.size > 1) {
                    addressTag = split[1]
                    cet_withdraw_adr?.setText(split[0])
                    ll_tag_layout?.visibility = View.VISIBLE
                    cet_withdraw_adr_note?.setText(addressTag)
                    address = split[0]
                } else {
                    address = bean?.optString("address")
                    ll_tag_layout?.visibility = View.GONE
                    cet_withdraw_adr?.setText(bean.optString("address"))
                }
            }

            newAddress = false
        } else {
            address = ""
            addressTag = ""
            addressStatus = false
            newAddress = true
            addressRemark = ""
            val coinBean = DataManager.getCoinByName(symbol)
            tokenBase = coinBean?.tokenBase ?: ""
            tagBean = coinBean?.tagType ?: 0
            if (tagBean == 0) {
                ll_tag_layout?.visibility = View.GONE
            } else {
                ll_tag_layout?.visibility = View.VISIBLE
            }
            cet_withdraw_adr?.setText("")
        }
    }


    var chainJson: JSONObject? = null


    /**
     *Set up multi chain
     */
    private fun initManyChain() {
        mcv_layout?.listener = object : ManyChainSelectListener {
            override fun selectCoin(coinName: JSONObject) {
                chainJson = coinName
                symbol = coinName.optString("name", "")
//                coinPrecision = chainJson?.optInt("showPrecision", 8) ?: 8
                et_amount?.setText("")
                addressTag = ""
                addressId = 0
                getCost(symbol)
                getEquity(showSymbol)
            }
        }
        mcv_layout?.setManyChainView(showSymbol,"","withdraw")
    }


    /**
     *After selecting multiple chains
     *Set the corresponding maximum and minimum handling fees
     */
    private fun setFeeView(jsonObject: JSONObject) {
        /**
         *Handling fees
         *To avoid Scientific notation
         */
        cubtn_confirm.isEnable(true)
        feeMin = jsonObject.optString("feeMin")
        feeMax = jsonObject.optString("feeMax")
        withdrawMin = jsonObject.optString("withdraw_min")
        withdrawMan = jsonObject.optString("withdraw_max")
        /**
         *Available balance
         */
        var normalBalance = bean?.optString("normal_balance") ?: ""
        var normalBalanceN = BigDecimalUtils.divForDown(normalBalance, coinPrecision).toPlainString()
        normalBalanceN = BigDecimalUtils.showSNormal(normalBalanceN)
        var marketName = NCoinManager.getShowMarket(showSymbol)
        tv_available_balance?.text = LanguageUtil.getString(mActivity, "withdraw_text_available") + ": $normalBalanceN $marketName"
        et_fee?.filters = arrayOf(DecimalDigitsInputFilter(coinPrecision))

        feevalue = jsonObject.optString("defaultFee")
        realAmount(feevalue, et_amount.text.toString())
        var buff=BigDecimalUtils.divForDown(jsonObject.optString("defaultFee"), coinPrecision).toPlainString()
        et_fee?.setText(BigDecimalUtils.showSNormal(buff))

        /**
         *Minimum value of single withdrawal
         */

        var withdrawMinBuff1=BigDecimalUtils.divForDown(withdrawMin, coinPrecision).toPlainString()
        withdrawMinBuff1=BigDecimalUtils.showSNormal(withdrawMinBuff1)

        /**
         *The limit for a single withdrawal is
         */
        var withdrawManBuff=BigDecimalUtils.divForDown(withdrawMan, coinPrecision).toPlainString()
        withdrawManBuff=BigDecimalUtils.showSNormal(withdrawManBuff)
        tv_single_max_withdraw_value?.text = "$withdrawManBuff ${NCoinManager.getShowMarket(showSymbol)}"

        /**
         *Set minimum withdrawal amount
         */
        var withdrawMinBuff=BigDecimalUtils.divForDown(withdrawMin, coinPrecision).toPlainString()
        withdrawMinBuff=BigDecimalUtils.showSNormal(withdrawMinBuff)
        et_amount?.hint = String.format(LanguageUtil.getString(mActivity, "withdraw_tip_withdrawMinValueError"),withdrawMinBuff)
        et_amount?.filters = arrayOf(DecimalDigitsInputFilter(coinPrecision))
//        setAdressView(jsonObject, false)
    }


    /**
     *Set initial view
     */
    private fun setView() {

        cubtn_confirm?.isEnable(true)
        val coinBean = DataManager.getCoinByName(showSymbol)
        tokenBase = coinBean?.tokenBase ?: ""
        tagBean = coinBean?.tagType ?: 0
        if (tagBean == 0) {
            ll_tag_layout?.visibility = View.GONE
        } else {
            ll_tag_layout?.visibility = View.VISIBLE
        }
        tv_coin_name?.text = NCoinManager.getShowMarket(showSymbol)
        isShowTag = tagBean == 2

//        if (null != chainJson && chainJson?.length() ?: 0 > 0) {
//            coinPrecision = chainJson?.optInt("showPrecision", 8) ?: 8
//        } else {
//            coinPrecision = NCoinManager.getCoinShowPrecision(symbol)
//        }
        coinPrecision = NCoinManager.getCoinShowPrecision(symbol)

        tv_symbol_name?.text = NCoinManager.getShowMarket(showSymbol)
        /**
         *Available balance
         */
        var normalBalance = bean?.optString("normal_balance") ?: ""
        var normalBalanceN = BigDecimalUtils.divForDown(normalBalance, coinPrecision).toPlainString()
        normalBalanceN= BigDecimalUtils.showSNormal(normalBalanceN)
        var marketName = NCoinManager.getShowMarket(showSymbol)
        tv_available_balance?.text = LanguageUtil.getString(mActivity, "withdraw_text_available") + ": $normalBalanceN $marketName"


        /**
         *Currency of handling fee
         */
        tv_fee_symbol?.text = NCoinManager.getShowMarket(showSymbol)


        /**
         *Actual Received Quantity
         */

        tv_real_amount?.text = "0" + NCoinManager.getShowMarket(showSymbol)
    }


    private fun setNewAdr() {
        cet_withdraw_adr?.setText("")
        cet_withdraw_adr_note?.setText("")
        et_amount?.setText("")
        addressTag = ""
        addressId = 0
        mcv_layout?.clearLables()
        et_fee?.setText(BigDecimalUtils.divForDown(feeMin, coinPrecision).toPlainString())
        newAddress = true
        addressStatus = false
        addressRemark = ""
    }


    private fun initClickListener() {

        /**
         *All available balances
         */
        btn_all_amount?.setOnClickListener {
            et_amount?.setText(BigDecimalUtils.divForDown(bean.optString("normal_balance"), coinPrecision).toPlainString())

            /**
             *Actual Received Quantity
             */
            var result = BigDecimalUtils.sub(bean.optString("normal_balance"), et_fee.text.toString()).toString()
            if (result.toDouble() < 0) {
                tv_real_amount?.setTextColor(ColorUtil.getColor(R.color.red))
                tv_real_amount?.text = LanguageUtil.getString(mActivity, "common_tip_balanceNotEnough")

            } else {
                tv_real_amount?.setTextColor(ColorUtil.getColor(R.color.main_font_color))
                tv_real_amount?.text = BigDecimalUtils.showSNormal(BigDecimalUtils.divForDown(result, coinPrecision).toPlainString()) + NCoinManager.getShowMarket(showSymbol)
            }
        }

        /**
         *Jump to the scanning interface
         */
        iv_sweep_the_yard?.setOnClickListener {
//            val intentIntegrator = IntentIntegrator(this)
//            intentIntegrator.captureActivity = ScanningActivity::class.java
//            intentIntegrator.setPrompt(LanguageUtil.getString(mActivity, "scan_tip_aimToScan"))
//            intentIntegrator.setBeepEnabled(true)
//            intentIntegrator.initiateScan()
            RxPermissions(this).request(android.Manifest.permission.CAMERA)
                .subscribe { granted ->
                    if (granted) {
                        val intent = Intent(this, CaptureActivity::class.java)
                        intent.putExtra(CaptureActivity.SCAN_INTENT, ScanIntentEnum.ADDRESS_ADD.value)
                        startActivityForResult(intent, 0x1111)
                    }else{
//                        ToastUtils.showToast("Turn on camera permission")
                        CpPermissionUtil.showOpenPermission(this, message = "common_tip_cameraPermission".tr(this))
                    }
                }
        }
        /**
         *Cash withdrawal address list
         */
        iv_into_withdraw_list?.setOnClickListener {
            var note = cet_withdraw_adr_note?.text.toString()
            if (note.isNotEmpty()) {
                WithdrawAddressActivity.enter4Result(this, symbol, showSymbol, cet_withdraw_adr?.text.toString() + "_$note")
            } else {
                WithdrawAddressActivity.enter4Result(this, symbol, showSymbol, cet_withdraw_adr?.text.toString())
            }
        }

        /**
         *Select currency pair
         */
        rl_symbol_name?.setOnClickListener {
//            ArouterUtil.navigation4Result(RoutePath.SelectCoinActivity, Bundle().apply {
//                putInt(ParamConstant.OPTION_TYPE, ParamConstant.WITHDRAW)
//                putBoolean(ParamConstant.COIN_FROM, false)
//            }, this, 321)

            ArouterUtil.navigation4Result(RoutePath.WithdrawSelectCoinActivity, Bundle().apply {
                putInt(ParamConstant.OPTION_TYPE, ParamConstant.WITHDRAW)
                putBoolean(ParamConstant.COIN_FROM, false)
            }, this, 321)
        }

        /**
         *Confirm
         */
        cubtn_confirm?.setOnClickListener(object :OnClickListener{
            override fun onClick(v: View?) {
                if (UserDataService.getInstance().googleStatus != 1 && UserDataService.getInstance().isOpenMobileCheck != 1) {
                    DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(mActivity, "unbind_verify_warn"), isSuc = false)
                    return
                }
                fee = BigDecimalUtils.showSNormal(et_fee?.text.toString())
                var minAmount = et_amount?.text.toString().trim()
                amount = BigDecimalUtils.showSNormal(BigDecimalUtils.divForDown(minAmount, coinPrecision).toPlainString())
                actualaMount = BigDecimalUtils.divForDown(BigDecimalUtils.sub(minAmount, et_fee.text.toString()).toString(), coinPrecision).toPlainString()

                if (BigDecimalUtils.compareToDraw(minAmount, withdrawMin) == -1) {
                    DisplayUtil.showSnackBar(window?.decorView,  String.format(LanguageUtil.getString(mActivity, "withdraw_tip_withdrawMinValueError"),withdrawMin), isSuc = false)
                    return
                }
                if (BigDecimalUtils.compareToDraw(minAmount, withdrawMan) == 1) {
                    DisplayUtil.showSnackBar(window?.decorView, String.format(LanguageUtil.getString(mActivity, "withdraw_tip_withdrawMaxValueError"),withdrawMan), isSuc = false)
                    return
                }

                if (!TextUtils.isEmpty(bean.optString("normal_balance")) && StringUtil.isNumeric(bean.optString("normal_balance"))) {
                    if (minAmount.toDouble() > bean.optDouble("normal_balance")) {
                        DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(mActivity, "toast_withdraw_too_max"), isSuc = false)
                        return
                    }
                }
                if(BigDecimalUtils.compareTo(actualaMount, "0") != 1){
                    DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(mActivity, "withdraw_tip_withdrawMinArrivalError"), isSuc = false)
                    return
                }
                if (newAddress) {
                    addressTag = cet_withdraw_adr_note?.text.toString()
                }
                if (tagBean == 2 && addressTag.isEmpty()) {
                    DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(mActivity, "toast_no_tag"), isSuc = false)
                    return
                }

                /**
                 *Handling fees
                 */
                if (TextUtils.isEmpty(fee)) {
                    DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(mActivity, "toast_no_fee"), isSuc = false)
                    return
                }

                if (newAddress) {
                    address = cet_withdraw_adr?.text.toString()
                }
                if (TextUtils.isEmpty(address)) {
                    DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(mActivity, "toast_no_withdraw_address"), isSuc = false)
                    return
                }

                /**
                 *Insufficient available assets
                 */
                val normalBal = bean.optString("normal_balance")

                if (BigDecimalUtils.sub(normalBal, amount).toDouble() < 0) {
                    DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(mActivity, "common_tip_balanceNotEnough"), isSuc = false)
                    return
                }
                if (addressTag.isNotEmpty()) {
                    address += "_$addressTag"
                }

                addWithdrawAddrValidate(symbol, address ?: "")
            }

        })


    }

    var trustDialog:  CpTDialog? = null
    var untrustDialog:  CpTDialog? = null

    var addressRemark : String? = ""
    /**
     *Requirements
     */
//    fun addWithdrawAddrValidate(symbol: String, address: String) {
//        addDisposable(getMainModel().addWithdrawAddrValidate(symbol, address, object : NDisposableObserver() {
//            override fun onResponseSuccess(jsonObject: JSONObject) {
//                /**
//                 *Do you trust the address
//                 *True is
//                 */
//                if (addressStatus) {
//                    NewDialogUtils.showNewDoubleDialog(this@WithdrawActivity, LanguageUtil.getString(this@WithdrawActivity, "withdraw_confirm_tips1"), object : NewDialogUtils.DialogBottomListener {
//                        override fun sendConfirm() {
//                            submitWithDraw()
//                        }
//
//                    }, LanguageUtil.getString(this@WithdrawActivity, "common_text_tip"), LanguageUtil.getString(this@WithdrawActivity, "common_text_btnCancel"), LanguageUtil.getString(this@WithdrawActivity, "common_text_btnConfirm"))
//                } else {
//                    NewDialogUtils.showNewDoubleDialog(this@WithdrawActivity, LanguageUtil.getString(this@WithdrawActivity, "withdraw_confirm_tips2"), object : NewDialogUtils.DialogBottomListener {
//                        override fun sendConfirm() {
//                            /**
//                             *Secondary verification of untrusted addresses
//                             */
//                            untrustDialog = NewDialogUtils.showSecondDialog(this@WithdrawActivity, AppConstant.CRYPTO_WITHDRAW, object : NewDialogUtils.DialogSecondListener {
//                                override fun returnCode(phone: String?, mail: String?, googleCode: String?, pwd: String?) {
//                                    submitWithDraw(phone ?: "", googleCode
//                                            ?: "", mail ?: "")
//                                    untrustDialog?.dismiss()
//                                }
//                            }, loginPwdShow = false, confirmTitle = LanguageUtil.getString(this@WithdrawActivity, "common_text_btnConfirm"))
//
//                        }
//                    }, LanguageUtil.getString(this@WithdrawActivity, "login_success_action_alert_title"), LanguageUtil.getString(this@WithdrawActivity, "common_text_btnCancel"), LanguageUtil.getString(this@WithdrawActivity, "alert_common_i_understand"))
//                }
//            }
//
//            override fun onResponseFailure(code: Int, msg: String?) {
//                super.onResponseFailure(code, msg)
//                NToastUtil.showToast(msg, false)
//            }
//        }))
//    }

    private fun createSelectWithdrawAddressDialog(){
        showLoadingDialog()
        HttpClient.instance.getAddressList(symbol)
            .subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(object : NetObserver<AddressBean>() {
                override fun onHandleSuccess(t: AddressBean?) {
                    closeLoadingDialog()
                    val list = arrayListOf<KKItemCardEntity>()
                    if (null != t?.addressList) {
                        val iterator = t.addressList.iterator()
                        while (iterator.hasNext()){
                            val item = iterator.next()
                            val entity = KKItemCardEntity(
                                KKItemCardEntity.withdraw_address_type,
                                item.label ?: "",
                                item.address
                            )
                            entity.arg = Pair(item.trustType,item.id)

                            entity.isSelect = item.id == addressId
                            list.add(entity)
                        }
                    }
                    var dialog: KKTDialog? = null
                    dialog = NewDialogUtils.createWithdrawAddressSelectDialog(
                        this@WithdrawActivity,list,
                        listener = object : KKDialogUtils.DialogOnItemClickListener {
                            override fun clickItem(position: Int) {
                                val item = list[position]
                                val dataPair = (item.arg as Pair<Int,Int>)
                                val id = dataPair.second
                                val trustType = dataPair.first
                                addressId = id
                                cet_withdraw_adr.setText(item.content as String)
                                addressStatus = trustType==1
                                addressRemark = item.title
                                address = item.content
                                dialog?.dismiss()
                            }

                        }
                    )

                }

                override fun onHandleError(code: Int, msg: String?) {
                    super.onHandleError(code, msg)
                    DisplayUtil.showSnackBar(window?.decorView, msg, isSuc = false)
                    closeLoadingDialog()
                }

            })

    }

    fun addWithdrawAddrValidate(symbol: String, address: String) {
        NewDialogUtils.showConfirmWithDialog(this,tv_real_amount?.text?.toString(),chainJson?.optString("mainChainName", ""),addressRemark,address,addressStatus,NCoinManager.getShowMarket(showSymbol),amount,fee,object : NewDialogUtils.DialogBottomListener{
            override fun sendConfirm() {
                showLoadingDialog()
                addDisposable(getMainModel().addWithdrawAddrValidate(symbol, address, object : NDisposableObserver() {
                    override fun onResponseSuccess(jsonObject: JSONObject) {

                        /**
                         *Do you trust the address
                         *True is
                         */
                        if (addressStatus) {
                            submitWithDraw()
                        } else {
                            closeLoadingDialog()
                            /**
                             *Secondary verification of untrusted addresses
                             */
                            untrustDialog = NewDialogUtils.createNewVersionSecurityDialog(
                                this@WithdrawActivity,
                                VerifyRule3(),
                                AppConstant.CRYPTO_WITHDRAW,
                                coinTypeEmail = AppConstant.CRYPTO_WITHDRAW_EMAIL,
                                listener = object : NewDialogUtils.DialogVerifiactionListener{
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
                                        submitWithDraw(phone, googleCode, mail,capitalPwd)
                                        untrustDialog?.dismiss()
                                    }

                                }
                            )
                        }
                    }

                    override fun onResponseFailure(code: Int, msg: String?) {
                        super.onResponseFailure(code, msg)
                        closeLoadingDialog()
                        NToastUtil.showTopToastNet(this@WithdrawActivity, false,msg)
                    }
                }))
            }

        })

    }

    /**
     *Scan result
     */
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (resultCode == Activity.RESULT_OK) {
            cet_withdraw_adr?.setText("")
            cet_withdraw_adr_note?.setText("")
            et_amount?.setText("")
            addressStatus = false
            addressRemark = ""
            when (requestCode) {
                /**
                 *Currency
                 */
                321 -> {
                    showSymbol = data?.getStringExtra(CoinActivity.SELECTED_COIN) ?: ""
                    bean = SymbolManager.instance.getFundCoinByName(showSymbol)
                    setNewAdr()
                    initView()
                }

                /**
                 *Recharge address
                 */
                WithdrawAddressActivity.REQUEST_CODE_ADDRESS -> {
                    ll_tag_layout?.visibility = View.VISIBLE
                    val addressbean = data?.getParcelableExtra<AddressBean.Address>(WithdrawAddressActivity.OBJECT_ADDRESS)
                    if (addressbean == null) {
                        setNewAdr()
                    } else {
                        val addr = addressbean?.address
                        if (!TextUtils.isEmpty(addr)) {
                            val split = addr?.split("_")
                            if (split!!.size > 1) {
                                ll_tag_layout?.visibility = View.VISIBLE
                                cet_withdraw_adr?.setText(split[0])
                                cet_withdraw_adr_note?.setText(split[1])
                                address = split[0]
                                addressTag = split[1]
                            } else {
                                ll_tag_layout?.visibility = View.GONE
                                cet_withdraw_adr?.setText(addressbean.address)
                                address = addressbean.address
                                addressTag = ""
                            }
                        }
                        newAddress = false
                        addressStatus = addressbean.trustType == 1
                        addressRemark = addressbean.label
                        if (addressbean != null) {
                            addressId = addressbean.id
                        }
                    }

                }

                0x1111 -> {
                    data?.let { intent ->
                        setNewAdr()
                        intent.getStringExtra(CaptureActivity.SCAN_RESULT)?.apply {
                            var re = this.split(":")
                            if (re.size == 2) {
                                var address = re[1]
                                cet_withdraw_adr?.setText(address)
                            } else {
                                var addressSaoma = this
                                if (addressSaoma.contains("_") && ll_tag_layout.visibility == View.VISIBLE) {
                                    val split = addressSaoma.split("_")
                                    cet_withdraw_adr?.setText(split[0])
                                    cet_withdraw_adr_note?.setText(split[1])
                                } else {
                                    cet_withdraw_adr?.setText(this)
                                }

                            }
                        }
                    }
                }
            }

        }
//        val result = IntentIntegrator.parseActivityResult(requestCode, resultCode, data)
//        if (result != null) {
//            if (TextUtils.isEmpty(result.contents)) {
//                DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(mActivity, "toast_scan_content_empty"), isSuc = false)
//            } else {
//
//                var addressSaoma = result.contents
//                if (addressSaoma.contains("_") && ll_tag_layout.visibility == View.VISIBLE) {
//                    val split = addressSaoma.split("_")
//                    cet_withdraw_adr?.setText(split[0])
//                    cet_withdraw_adr_note?.setText(split[1])
//                } else {
//                    cet_withdraw_adr?.setText(result.contents)
//                }
//            }
//        }
    }


    /**
     *Query service fees and withdrawal addresses based on currency
     */
    private fun getCost(symbol: String = "") {
        addDisposable(getMainModel().getCost(symbol, object : NDisposableObserver(this) {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                var data = jsonObject.optJSONObject("data")
                if (null == data || data.length() == 0) return
                mcv_layout?.content = data?.optString("mainChainNameTip", "")
                setFeeView(data)
            }

            override fun onResponseFailure(code: Int, msg: String?) {
                super.onResponseFailure(code, msg)
                LogUtil.e("LogUtils", "getCost error")
                et_fee?.setText("--")
                et_amount?.hint = String.format(LanguageUtil.getString(mActivity, "withdraw_tip_withdrawMinValueError"),"--")
                cubtn_confirm.isEnable(false)
            }
        }))

    }

    /**
     *Confirm withdrawal
     */
    fun submitWithDraw(first: String = "", second: String = "", emailValidCode: String = "",capitalPwd:String? = "") {
        cubtn_confirm?.isEnable(false)
        HttpClient.instance.doWithdraw(
                addressId = if (addressId == 0) "" else addressId.toString(),
                fee = fee,
                smsCode = first,
                googleCode = second,
                amount = actualaMount,
                symbol = symbol,
                address = address ?: "",
                trustType = if (addressStatus) "" else "0",
                emailValidCode = emailValidCode,
                capitalPwd = capitalPwd
        )
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<AuthBean>() {
                    override fun onHandleSuccess(t: AuthBean?) {
                        closeLoadingDialog()
                        cubtn_confirm?.isEnable(true)
                        if (t == null) {
//                            NToastUtil.showTopToastNet(this@WithdrawActivity, true, getString(R.string.toast_withdraw_suc))
                            NewDialogUtils.showNewsingleDialog2(this@WithdrawActivity!!, getString(R.string.toast_withdraw_suc), object : NewDialogUtils.DialogBottomListener {
                                override fun sendConfirm() {
                                    this@WithdrawActivity.finish()
//                                    finish()
                                }
                            }, cancelTitle = LanguageUtil.getString(this@WithdrawActivity, "OK"),returnListener = true)
                            return
                        }
                        if (t.isOpenUserCheck == true) {
                            //Do you need real name authentication
                            if (t.isUserCheckFace()) {
                                //face++
                                ArouterUtil.greenChannel(RoutePath.ItemDetailActivity, Bundle().apply {
                                    putString(ParamConstant.head_title, "")
                                    putString(ParamConstant.web_url, t.faceUrl())
                                })
                            } else {
                                //User manually submits real name
                                ArouterUtil.greenChannel(RoutePath.IdentityAuthenticationActivity, Bundle().apply {
                                    putString(ParamConstant.WITHDRAW_ID, t.withdrawId ?: "")
                                })
                            }
                            finish()
                        } else {
//                            NToastUtil.showTopToastNet(this@WithdrawActivity, true, getString(R.string.toast_withdraw_suc))
                            NewDialogUtils.showNewsingleDialog2(this@WithdrawActivity!!, getString(R.string.toast_withdraw_suc), object : NewDialogUtils.DialogBottomListener {
                                override fun sendConfirm() {
                                    this@WithdrawActivity.finish()
                                }
                            }, cancelTitle = LanguageUtil.getString(this@WithdrawActivity, "confirm"),returnListener = true)
                        }
                    }

                    override fun onHandleError(code: Int, msg: String?) {
                        super.onHandleError(code, msg)
                        closeLoadingDialog()
                        cubtn_confirm?.isEnable(true)
                        NToastUtil.showTopToastNet(this@WithdrawActivity, false, msg)
                    }
                })
    }

    private fun getEquity(symbol: String){
        addDisposable(
            getMainModel().getEquity(symbol,consumer = object :NModelDisposableObserver<EquityBean>(){
                override fun onResponseSuccess(data: EquityBean) {
                    if(BigDecimalUtils.compareTo(data.withdrawAmount,"0")<=0){
                        if(!isShowDisableWithdrawDialog){
                            isShowDisableWithdrawDialog = true
                            JsonUtils.showAuthPermissionNoEnoughDialog(this@WithdrawActivity,isForce = true)
                        }
                        return
                    }
                    tv_can_use_amount_value.text = BigDecimalUtils.showSNormal(data.currentSymbolAmount) + NCoinManager.getShowMarket(symbol)
                    tv_withdraw_amount_value.text = BigDecimalUtils.showSNormal(data.canUseAmount) + "/" + BigDecimalUtils.showSNormal(data.withdrawAmount) + "USDT"

                }
            })
        )
    }
}
