package com.yjkj.chainup.new_version.activity.otcTrading

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.text.TextUtils
import android.util.Log
import android.view.View
import com.fengniao.news.util.DateUtil
 import com.chainup.contract.view.dialog.CpTDialog
import com.yjkj.chainup.R
import com.yjkj.chainup.app.AppConstant
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.RateManager
import com.yjkj.chainup.net.HttpClient
import com.yjkj.chainup.net.retrofit.NetObserver
import com.yjkj.chainup.new_version.activity.NewBaseActivity
import com.yjkj.chainup.new_version.activity.ShowImageActivity
import com.yjkj.chainup.new_version.activity.TitleShowListener
import com.yjkj.chainup.new_version.bean.OTCOrderDetailBean
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.view.CommonlyUsedButton
import com.yjkj.chainup.new_version.view.PersonalCenterView
import com.yjkj.chainup.securityVerifyRule.VerifyRule4
import com.yjkj.chainup.util.*
import io.reactivex.Flowable
import io.reactivex.Observable
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.disposables.Disposable
import io.reactivex.functions.Action
import io.reactivex.functions.Consumer
import io.reactivex.observers.DisposableObserver
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.activity_new_buy_order.*
import kotlinx.android.synthetic.main.item_new_version_order.*
import kotlinx.android.synthetic.main.item_payment_information.*
import java.util.concurrent.TimeUnit

/**
 * @Author lianshangljl
 * @Date 2023/4/18-5:18 PM
 * @Email buptjinlong@163.com
 *@description Sales Order
 */
class NewVersionSellOrderActivity : NewBaseActivity() {

    var orderId = ""

    var title = ""


    companion object {
        val ORDERID = "orderId"

        fun enter2(context: Context, orderId: String) {
            var intent = Intent(context, NewVersionSellOrderActivity::class.java)
            intent.putExtra(ORDERID, orderId)
            context.startActivity(intent)
        }
    }

    fun setTextContent() {
        tv_nick_name?.text = getStringContent("otcSafeAlert_action_nickname")
        tv_real_name_title?.text = getStringContent("common_text_realNameTitle")
        tv_money_title?.text = getStringContent("journalAccount_text_amount")
        tv_quantity_title?.text = getStringContent("charge_text_volume")
        tv_otc_price_title?.text = getStringContent("otc_text_price")
        tv_orderCTime?.text = getStringContent("otc_text_orderCTime")
        tv_text_remark?.text = getStringContent("address_text_remark")
        tv_orderCancelReason?.text = getStringContent("otc_text_orderCancelReason")
        tv_switching?.text = getStringContent("noun_order_paymentTerm")
    }

    fun getStringContent(contentId: String): String {
        return LanguageUtil.getString(this, contentId)
    }

    var contactDilaog:  CpTDialog? = null

    private var disposables = CompositeDisposable()
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_new_buy_order)
        title = if (PublicInfoDataService.getInstance().getB2CSwitchOpen(null)) {
            LanguageUtil.getString(this, "otc_tip_sellerOrderComplete_forotc")
        } else {
            LanguageUtil.getString(this, "otc_tip_sellerOrderComplete")
        }
        getData()
        setTextContent()
        listener = object : TitleShowListener {
            override fun TopAndBottom(status: Boolean) {
                title_layout.slidingShowTitle(status)
            }
        }
        setOnClick()
        getOrderStateEachMin()
    }

    var coin = ""
    var payCoin = ""
    var paymentList: ArrayList<String> = arrayListOf()
    fun getData() {
        if (intent != null) {
            orderId = intent.getStringExtra(NewVersionBuyOrderActivity.ORDERID) ?: ""
        }
        title_layout?.rightIcon(R.mipmap.personal_messagecenter)
    }

    var clickStatus = true

    var otcOrderDetailBean: OTCOrderDetailBean? = null

    fun initView(bean: OTCOrderDetailBean) {
        payment_information_layout?.visibility = View.VISIBLE
        line_layout?.visibility = View.VISIBLE
        waiting_attention_to?.visibility = View.GONE
        otcOrderDetailBean = bean
        coin = bean?.coin
        payCoin = bean?.paycoin
        /**
         *Click on message
         */
        title_layout?.listener = object : PersonalCenterView.MyProfileListener {
            override fun onRealNameCertificat() {

            }

            override fun onclickName() {

            }

            override fun onclickHead() {

            }

            override fun onclickRightIcon() {
                if (bean.status == 5 && bean.isComplainUser == 1) {
                    OTCIMActivity.newIntent(this@NewVersionSellOrderActivity, bean.complainId, bean.coin, bean.totalPrice.toString()
                            , bean.status.toString(), bean.paycoin, DateUtil.longToString("yyyy-MM-dd HH:mm:ss", bean.ctime), bean.buyer.uid, bean.sequence
                            , bean.buyer.otcNickName, (bean.limitTime / 1000).toLong(), bean.isComplainUser, "sell",bean.paycoin)
                } else {
                    /**
                     *Jump to Chat
                     */
                    OTCIMActivity.newIntent4Buyer(this@NewVersionSellOrderActivity, bean.buyer.uid, bean.sequence,
                            bean.coin, bean.totalPrice.toString(), bean.status.toString(),
                            bean.paycoin, bean.buyer.otcNickName,
                            DateUtil.longToString("yyyy-MM-dd HH:mm:ss", bean.ctime),
                            (bean.limitTime / 1000).toLong(), bean.isComplainUser, bean.complainId, bean.buyer.imageUrl,bean.paycoin)
                }

            }

        }
        iv_payment_imageview?.visibility = View.INVISIBLE

        tv_payment_type?.text = LanguageUtil.getString(this, "common_text_paymentInfoSeller")

        tv_switching?.visibility = View.GONE
        ll_payment_type_layout?.isEnabled = false


        /**
         *Information on payment methods
         */

        var paymentBean: OTCOrderDetailBean.Payment? = null
        if (bean?.payment.size > 0) {
            bean.payment.forEach {
                if (null == it) return@forEach
                if (it.payment == bean.payKey) {
                    paymentBean = it
                }
            }
        }


        if (paymentBean == null && bean?.payment.size > 0) {
            paymentBean = bean.payment[0]
        }

        if (bean.payment.size == 1) {
            tv_switching?.visibility = View.GONE
        }
        paymentList.clear()
        for (payment in bean.payment) {
            when (payment.payment) {
                "otc.payment.wxpay" -> {
                    paymentList.add(LanguageUtil.getString(this, "pyamethod_text_wxpay"))
                }
                "otc.payment.alipay" -> {
                    paymentList.add(LanguageUtil.getString(this, "payMethod_text_alipay"))
                }
                "otc.payment.domestic.bank.transfer" -> {
                    paymentList.add(LanguageUtil.getString(this, "new_otc_bank"))
                }
                "otc.payment.paypal" -> {
                    paymentList.add("PayPal")
                }
                else -> {
                    paymentList.add(payment.payment)
                }
            }
        }
        if (null != bean.payment && bean.payment.size > 0) {
            peymentString = setPaymentLayout(paymentBean ?: bean.payment[0])
        }

        /**
         *
         *Status: Order status:
         *Pending payment 1
         *Payment on behalf of 2
         *Transaction successful 3
         *Cancel 4
         *Appeal pending 5
         *Coining 6
         *Abnormal Order 7
         *End of appeal processing 8
         */

        when (bean.status) {
            1 -> {
                title_layout?.setContentTitle(LanguageUtil.getString(this, "otc_text_orderWaitMoney"))
                btn_cancel?.isEnable(true)
                tv_switching?.visibility = View.VISIBLE
                waiting_attention_to?.visibility = View.VISIBLE
                waiting_attention_to?.text = LanguageUtil.getString(this, "otc_tip_remindSellerWaitPay")
                cub_confirm_for_buy?.isEnable(false)
                cub_confirm_for_buy?.setContent(LanguageUtil.getString(this, "otc_text_waitPay"))
                payment_information_layout?.visibility = View.GONE
                countTotalTime = bean.limitTime / 1000
                cancelBtnState()
            }

            2 -> {
                /**
                 *Currency to be released
                 */
                iv_payment_imageview?.visibility = View.GONE
                tv_switching?.visibility = View.GONE
                tv_payment_type?.text = LanguageUtil.getString(this, "common_text_paymentInfoSeller")
                title_layout?.setContentTitle(LanguageUtil.getString(this, "otc_text_orderWaitSendCoin"))
                cub_confirm_for_buy?.setContent(LanguageUtil.getString(this, "otc_action_confirmSendCoin"))
                btn_cancel?.setContent(LanguageUtil.getString(this, "otc_action_appeal"))
                /**
                 *It will take 5 minutes to click
                 *Appeal
                 */
                btn_cancel?.isEnable(true)
                var curTime = System.currentTimeMillis()
                if (bean.payTime.toLong() != 0L) {
                    clickStatus = (curTime / 1000 - 300 - bean.payTime.toLong() / 1000) > 0
                }
                pay_attention_to?.text = "对方已经支付，支付方式如上，请确认到账后，点击下方“确认收款并放币”按钮"
                cub_confirm_for_buy?.isEnable(true)
//                waiting_attention_to.visibility = View.VISIBLE
                disposeTime()
                /**
                 *Go to appeal
                 */
                btn_cancel?.listener = object : CommonlyUsedButton.OnBottonListener {
                    override fun bottonOnClick() {
                        if (clickStatus) {
                            NewComplaintActivity.enter2(this@NewVersionSellOrderActivity, bean.sequence, false, "9", payCoin)
                            finish()
                        } else {
                            DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this@NewVersionSellOrderActivity, "otc_tip_appealTimeLimit"), isSuc = false)
                        }

                    }

                }

            }

            6 -> {
                /**
                 *Coining
                 */
                payment_information_layout?.visibility = View.VISIBLE
                iv_payment_imageview?.visibility = View.GONE
                tv_switching?.visibility = View.GONE
                tv_money_copy?.visibility = View.GONE
                tv_payment_type?.text = LanguageUtil.getString(this, "common_text_paymentInfoSeller")
                title_layout?.setContentTitle(LanguageUtil.getString(this, "otc_text_orderWaitSendCoin"))
                cub_confirm_for_buy?.setContent(LanguageUtil.getString(this, "otc_action_confirmSendCoin"))
                btn_cancel?.setContent(LanguageUtil.getString(this, "otc_action_appeal"))
                /**
                 *It will take 5 minutes to click
                 *Appeal
                 */
                btn_cancel?.isEnable(true)
                var curTime = System.currentTimeMillis()
                if (bean.payTime.toLong() != 0L) {
                    clickStatus = curTime / 1000 - 300 - bean.payTime.toLong() / 1000 > 0
                }
                pay_attention_to?.text = "对方已经支付，支付方式如上，请确认到账后，点击下方“确认收款并放行”按钮"
                cub_confirm_for_buy?.isEnable(false)
//                waiting_attention_to.visibility = View.VISIBLE
                disposeTime()
                /**
                 *Cancel
                 */
                btn_cancel?.listener = object : CommonlyUsedButton.OnBottonListener {
                    override fun bottonOnClick() {
                        if (clickStatus) {
                            NewComplaintActivity.enter2(this@NewVersionSellOrderActivity, bean.sequence, false, "9", payCoin)
                            finish()
                        } else {
                            DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this@NewVersionSellOrderActivity, "otc_tip_appealTimeLimit"), isSuc = false)
                        }

                    }

                }
            }
            7 -> {
                title_layout?.setContentTitle(LanguageUtil.getString(this, "contract_text_orderError"))
                ll_trading_layout?.visibility = View.GONE
                tv_switching?.visibility = View.GONE
            }

            4 -> {
                title_layout?.setContentTitle(LanguageUtil.getString(this, "filter_otc_cancel"))
                order_cancellation_layout?.visibility = View.VISIBLE
                line_layout?.visibility = View.GONE
                ll_trading_layout?.visibility = View.GONE
                tv_money_copy?.visibility = View.GONE
                tv_payment_type?.text = LanguageUtil.getString(this, "common_text_paymentInfoSeller")
                payment_information_layout?.visibility = View.GONE
                when (bean.cancelStatus) {
                    "0" -> {
                        order_cancellation_layout?.visibility = View.GONE
                    }
                    "1" -> {
                        tv_order_cancellation_type?.text = LanguageUtil.getString(this, "otc_text_cancelByBuyer")
                    }
                    "2" -> {
                        tv_order_cancellation_type?.text = LanguageUtil.getString(this, "otc_text_cancelByAppeal")
                    }
                    "3" -> {
                        tv_order_cancellation_type?.text = LanguageUtil.getString(this, "otc_text_cancelReasonNotPay")
                    }
                }
                btn_cancel?.listener = object : CommonlyUsedButton.OnBottonListener {
                    override fun bottonOnClick() {
                        finish()
                    }
                }
            }

            3 -> {
                /***
                 *Display the status of order completion
                 */
                title_layout?.setContentTitle(LanguageUtil.getString(this, "otc_text_orderComplete"))
                ll_trading_layout?.visibility = View.GONE
                waiting_attention_to?.visibility = View.GONE
                iv_payment_imageview?.visibility = View.GONE
                pay_attention_to?.visibility = View.VISIBLE
                tv_payment_type?.text = LanguageUtil.getString(this, "common_text_paymentInfoSeller")
                pay_attention_to?.text = title
                put_coin_code_layout?.visibility = View.VISIBLE
                pey_time_layout?.visibility = View.VISIBLE
                /**
                 *Release time
                 */
                if (!TextUtils.isEmpty(bean.sendCoinTime) && StringUtils.isNumeric(bean.sendCoinTime)) {
                    tv_put_coin?.text = DateUtil.longToString("yyyy/MM/dd HH:mm:ss", bean.sendCoinTime.toLong())
                }
                /**
                 *Payment time
                 */
                if (!TextUtils.isEmpty(bean.payTime) && StringUtils.isNumeric(bean.payTime)) {
                    tv_pay_time?.text = DateUtil.longToString("yyyy/MM/dd HH:mm:ss", bean.payTime.toLong())
                }
                btn_cancel?.listener = object : CommonlyUsedButton.OnBottonListener {
                    override fun bottonOnClick() {
                        finish()
                    }
                }
            }

            /**
             *In appeal
             */
            5 -> {
                title_layout?.setContentTitle(LanguageUtil.getString(this, "filter_otc_appeal"))
                pey_time_layout?.visibility = View.VISIBLE
                tv_pay_time_copy?.visibility = View.GONE
                tv_pay_time?.text = DateUtil.longToString("yyyy/MM/dd HH:mm:ss", bean.payTime.toLong())


                iv_payment_imageview?.visibility = View.GONE
                tv_switching?.visibility = View.GONE
                tv_payment_type?.text = LanguageUtil.getString(this, "common_text_paymentInfoSeller")
                if (bean.isComplainUser == 1) {
                    btn_cancel?.isEnable(true)
                    btn_cancel?.setContent(LanguageUtil.getString(this, "otc_action_cancelAppeal"))
                    cub_confirm_for_buy?.setContent(LanguageUtil.getString(this, "otc_text_orderPendingAppeal"))
                    cub_confirm_for_buy?.isEnable(false)
                    pay_attention_to?.text = LanguageUtil.getString(this, "otc_tip_appealOffence")
                    btn_cancel?.listener = object : CommonlyUsedButton.OnBottonListener {
                        override fun bottonOnClick() {
                            NewDialogUtils.showNormalDialog(this@NewVersionSellOrderActivity, LanguageUtil.getString(this@NewVersionSellOrderActivity, "otc_tip_cancleAppealConfirm"), object : NewDialogUtils.DialogBottomListener {
                                override fun sendConfirm() {
                                    cancelComplain4OTC()
                                }
                            }, "")
                        }
                    }

                } else {
                    pay_attention_to?.text = LanguageUtil.getString(this, "otc_tip_appealDefense")
                    btn_cancel?.visibility = View.GONE
                    cub_confirm_for_buy?.setContent(LanguageUtil.getString(this, "otc_tip_appealCharged"))
                    cub_confirm_for_buy?.isEnable(false)
                }


//                tv_complainCommand.text = bean?.complainCommand
            }

            8 -> {
                /***
                 *Appeal closed
                 *Display the status of order completion
                 */
                title_layout?.setContentTitle(LanguageUtil.getString(this, "otc_text_orderComplete"))
                ll_trading_layout?.visibility = View.GONE
                waiting_attention_to?.visibility = View.GONE
                iv_payment_imageview?.visibility = View.GONE

                pay_attention_to?.visibility = View.VISIBLE
                pay_attention_to?.text = title
                put_coin_code_layout?.visibility = View.VISIBLE
                pey_time_layout?.visibility = View.VISIBLE
                /**
                 *Release time
                 */
                if (!TextUtils.isEmpty(bean.sendCoinTime) && StringUtils.isNumeric(bean.sendCoinTime)) {
                    tv_put_coin?.text = DateUtil.longToString("yyyy/MM/dd HH:mm:ss", bean.sendCoinTime.toLong())
                }
                /**
                 *Payment time
                 */
                if (!TextUtils.isEmpty(bean.payTime) && StringUtils.isNumeric(bean.payTime)) {
                    tv_pay_time?.text = DateUtil.longToString("yyyy/MM/dd HH:mm:ss", bean.payTime.toLong())
                }
                btn_cancel?.listener = object : CommonlyUsedButton.OnBottonListener {
                    override fun bottonOnClick() {
                        finish()
                    }
                }
            }

            9 -> {
                /**
                 *Display the status of order cancellation
                 */
                title_layout?.setContentTitle(LanguageUtil.getString(this, "filter_otc_cancel"))
                order_cancellation_layout?.visibility = View.VISIBLE
                line_layout?.visibility = View.GONE
                ll_trading_layout?.visibility = View.GONE
                tv_money_copy?.visibility = View.GONE
                tv_payment_type?.text = LanguageUtil.getString(this, "common_text_paymentInfoSeller")
                payment_information_layout?.visibility = View.GONE
                when (bean.cancelStatus) {
                    "0" -> {
                        order_cancellation_layout?.visibility = View.GONE
                    }
                    "1" -> {
                        tv_order_cancellation_type?.text = LanguageUtil.getString(this, "otc_text_cancelByBuyer")
                    }
                    "2" -> {
                        tv_order_cancellation_type?.text = LanguageUtil.getString(this, "otc_text_cancelByAppeal")
                    }
                    "3" -> {
                        tv_order_cancellation_type?.text = LanguageUtil.getString(this, "otc_text_cancelReasonNotPay")
                    }
                }
                btn_cancel?.listener = object : CommonlyUsedButton.OnBottonListener {
                    override fun bottonOnClick() {
                        finish()
                    }
                }

            }
        }

        /**
         *Remarks
         */
        tv_otc_note?.text = bean.description
        /**
         *Seller's nickname
         */
        ll_nick_name_layout?.visibility = View.GONE
        tv_user_nick_name?.text = bean.buyer.otcNickName

        tv_real_name.text = bean.buyer.realName

        /**
         *Determine whether to display the real name
         */
        if (bean.otcAuthnameOpen == "1") {
            tv_real_name_copy.visibility = View.VISIBLE
            tv_real_name_copy.setOnClickListener {
                if (bean?.isTwoMin == 0) {
                    NewDialogUtils.showSingleDialog(context, LanguageUtil.getString(this, "common_tip_showContactOTC"), object : NewDialogUtils.DialogBottomListener {
                        override fun sendConfirm() {

                        }
                    })
                } else {
                    contactDilaog = NewDialogUtils.OTCOorderContactDialog(this, bean.buyer.mobileNumber, bean.buyer.email, object : NewDialogUtils.DialogBottomListener {
                        override fun sendConfirm() {
                            contactDilaog?.dismiss()
                        }
                    })
                }
            }
        }


        /**
         *Order number
         */
        tv_order_number?.text = LanguageUtil.getString(this, "otc_text_orderId") + " " + bean.sequence


        /**
         *Copy order number
         */
        tv_order_number_copy.setOnClickListener {
            ClipboardUtil.copy(bean.sequence)
            DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this, "common_tip_copySuccess"))
        }

        /**
        *Transaction volume
         */
        var paycoin = bean.paycoin
        tv_money_title?.text = LanguageUtil.getString(this, "journalAccount_text_amount") + "(${paycoin})"
        var totalPrice = bean.totalPrice
        var precision = RateManager.getFiat4Coin(paycoin)
        var totalPriceN = BigDecimalUtils.divForDown(totalPrice, precision).toPlainString()
        tv_money?.text = totalPriceN
        /**
         *Unit price
         */
        tv_otc_price_title?.text = LanguageUtil.getString(this, "otc_text_price") + "(${paycoin})"
        var priceN = BigDecimalUtils.divForDown(bean.price, precision).toPlainString()
        tv_otc_price?.text = priceN

        /**
         *Transaction quantity
         */
        tv_quantity_title?.text = LanguageUtil.getString(this, "charge_text_volume") + "(${NCoinManager.getShowMarket(bean.coin)})"
        tv_quantity?.text = BigDecimalUtils.showSNormal(bean.volume.toString())


        tv_money_copy?.setOnClickListener {
            ClipboardUtil.copy(tv_money)
            DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this, "common_tip_copySuccess"))
        }


        /**
         *Order time
         */

        tv_otc_place_order_time?.text = DateUtil.longToString("yyyy/MM/dd HH:mm:ss", bean.ctime)


        /**
         *Confirm disbursement
         */
        cub_confirm_for_buy?.listener = object : CommonlyUsedButton.OnBottonListener {
            override fun bottonOnClick() {

//                if (UserDataService.getInstance().nickName.isEmpty() || UserDataService.getInstance().authLevel != 1 || (UserDataService.getInstance().isOpenMobileCheck != 1 && UserDataService.getInstance().googleStatus != 1)) {
//                    NewDialogUtils.OTCTradingPermissionsDialog(this@NewVersionSellOrderActivity, object : NewDialogUtils.DialogBottomListener {
//                        override fun sendConfirm() {
//                            if (UserDataService.getInstance().nickName.isEmpty()) {
//                                //Certification status 0. Under review, 1. Passed, 2. Not passed, 3. Not certified
//                                //PersonalInfoActivity.enter2(context!!)
//
//                            } else if (UserDataService.getInstance().authLevel != 1) {
//                                when (UserDataService.getInstance().authLevel) {
//                                    0 -> {
//                                        ArouterUtil.navigation(RoutePath.KycActivity, null)
//                                    }
//                                }
//                            } else {
//                                ArouterUtil.greenChannel(RoutePath.SafetySettingActivity, null)
//                            }
//                        }
//
//                    })
//                    return
//                }

                NewDialogUtils.tradingOTCConfirm(this@NewVersionSellOrderActivity, LanguageUtil.getString(this@NewVersionSellOrderActivity, "otc_action_confirmSendCoinTitle"), peymentString, selectPaymentBean?.userName
                        ?: "", BigDecimalUtils.showSNormal(bean.totalPrice.toString()) + bean.paycoin, object : NewDialogUtils.DialogBottomListener {
                    override fun sendConfirm() {
                        disposables.clear()
                        disposeTime()
                        showPayCoinDialog()
                    }
                }, LanguageUtil.getString(this@NewVersionSellOrderActivity, "otc_action_confirmSendCoin"))
            }

        }

        ll_payment_type_layout?.setOnClickListener {
            if (bean.status == 1 && bean.payment.size != 1) {
                dialogForPayment = NewDialogUtils.showBottomListDialog(this@NewVersionSellOrderActivity, paymentList, selectPosition, object : NewDialogUtils.DialogOnclickListener {
                    override fun clickItem(data: ArrayList<String>, item: Int) {
                        selectPosition = item
                        peymentString = setPaymentLayout(bean.payment[item])
                        dialogForPayment?.dismiss()
                    }

                    override fun onDismiss() {

                    }
                })
            }
        }

        if (bean?.showWarnTip && bean?.status == 1) {
            payment_information_layout?.visibility = View.GONE
            waiting_attention_to?.visibility = View.VISIBLE
            line_layout?.visibility = View.GONE
            waiting_attention_to?.text = LanguageUtil.getString(this, "otc_tip_orderDuringReview")
            title_layout?.setRightVisible(false)
        } else {
            pay_attention_to?.visibility = View.GONE
            title_layout?.setRightVisible(true)
        }
    }

    var selectPosition = 0
    var dialogForPayment: CpTDialog? = null

    var peymentString = ""
    var selectPaymentBean: OTCOrderDetailBean.Payment? = null
    fun setPaymentLayout(paymentBean: OTCOrderDetailBean.Payment): String {
        var peymentString = ""
        selectPaymentBean = paymentBean
        /**
         *Set order seller information
         */
        when (paymentBean.payment) {
            "otc.payment.wxpay" -> {
                tv_payment_type?.text = LanguageUtil.getString(this, "pyamethod_text_wxpay")

                iv_payment_imageview?.setImageResource(R.drawable.wechat)

                tv_firstaname_title?.text = LanguageUtil.getString(this, "otc_text_payee")
                tv_firstaname?.text = paymentBean.userName

                tv_user_title?.text = LanguageUtil.getString(this, "otc_text_wxID")
                tv_user_content?.text = paymentBean.account
                tv_payment?.text = ""
                tv_payment_title?.text = LanguageUtil.getString(this, "wxpay_text_qrcode")
                peymentString = LanguageUtil.getString(this, "pyamethod_text_wxpay")
                peyment_code?.visibility = View.VISIBLE
                account_number_layout?.visibility = View.GONE
                tv_payment_copy?.setImageResource(R.mipmap.personal_qrcode)
                tv_payment_copy?.setOnClickListener {
                    ShowImageActivity.enter2(this, paymentBean.qrcodeImg)
                }
                tv_user_copy?.visibility = View.VISIBLE
                tv_user_copy?.setOnClickListener {
                    Utils.copyString(tv_user_content)
                }
            }
            "otc.payment.paypal" -> {
                GlideUtils.loadImage(this, paymentBean.icon, iv_payment_imageview)

                if (TextUtils.isEmpty(paymentBean.icon)) {
                    iv_payment_imageview?.visibility = View.GONE
                }

                //Payee
                tv_firstaname_title?.text = LanguageUtil.getString(this, "otc_text_payee")
                tv_firstaname?.text = paymentBean.userName

                tv_payment_type?.text = paymentList[selectPosition]

                tv_user_title?.text = "PayPal" + LanguageUtil.getString(this, "noun_account_accountName")
                tv_user_content?.text = paymentBean.account
                tv_payment?.text = ""
                tv_payment_title?.text = ""
                peymentString = "PayPal"

                peyment_code?.visibility = View.GONE

                tv_payment_copy?.setImageResource(R.mipmap.personal_qrcode)
                account_number_layout?.visibility = View.GONE
                tv_payment_copy?.setOnClickListener {
                    ShowImageActivity.enter2(this, paymentBean.qrcodeImg)
                }
                tv_user_copy?.visibility = View.VISIBLE
                tv_user_copy?.setOnClickListener {
                    Utils.copyString(tv_user_content)
                    DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this, "common_tip_copySuccess"))
                }
            }

            "otc.payment.alipay" -> {
                iv_payment_imageview?.setImageResource(R.drawable.alipay)
                //Payee
                tv_firstaname_title?.text = LanguageUtil.getString(this, "otc_text_payee")
                tv_firstaname?.text = paymentBean.userName

                tv_payment_type?.text = LanguageUtil.getString(this, "payMethod_text_alipay")

                tv_user_title?.text = LanguageUtil.getString(this, "alipay_text_account")
                tv_user_content?.text = paymentBean.account

                tv_payment_title?.text = LanguageUtil.getString(this, "alipay_text_qrcode")
                peymentString = LanguageUtil.getString(this, "payMethod_text_alipay")
                tv_payment?.text = ""
                peyment_code?.visibility = View.VISIBLE
                tv_payment_copy?.setImageResource(R.mipmap.personal_qrcode)
                account_number_layout?.visibility = View.GONE
                tv_payment_copy?.setOnClickListener {
                    ShowImageActivity.enter2(this, paymentBean.qrcodeImg)
                }
                tv_user_copy?.visibility = View.VISIBLE
                tv_user_copy?.setOnClickListener {
                    Utils.copyString(tv_user_content)
                }
            }

            "otc.payment.domestic.bank.transfer" -> {
                iv_payment_imageview?.setImageResource(R.drawable.bankcard)
                //Opening Bank
                tv_firstaname_title?.text = LanguageUtil.getString(this, "otc_text_bankName")
                tv_firstaname?.text = paymentBean.bankName
                //Opening branch
                tv_user_title?.text = LanguageUtil.getString(this, "otc_text_bankBranchName")
                tv_user_content?.text = paymentBean.bankOfDeposit
                tv_user_copy?.visibility = View.VISIBLE
                tv_user_copy?.setOnClickListener {
                    Utils.copyString(tv_user_content)
                    DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this, "common_tip_copySuccess"))
                }

                //Payee
                tv_payment_account_title?.text = LanguageUtil.getString(this, "otc_text_payee")
                tv_payment_account?.text = paymentBean.userName
                tv_payment_account_copy?.visibility = View.VISIBLE
                tv_payment_account_copy?.setImageResource(R.drawable.fiat_copy)
                tv_payment_copy?.setImageResource(R.drawable.fiat_copy)
                tv_payment_account_copy?.setOnClickListener {
                    Utils.copyString(tv_payment_account)
                    DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this, "common_tip_copySuccess"))
                }
                //Card number
                peyment_code?.visibility = View.VISIBLE
                tv_payment_title?.text = LanguageUtil.getString(this, "otc_text_paymentCardNumber")
                tv_payment?.text = paymentBean.account
                tv_payment_copy?.setOnClickListener {
                    Utils.copyString(tv_payment)
                    DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this, "common_tip_copySuccess"))
                }



                tv_payment_type?.text = LanguageUtil.getString(this, "new_otc_bank")
                peymentString = LanguageUtil.getString(this, "new_otc_bank")

                account_number_layout?.visibility = View.VISIBLE
            }
        }
        return peymentString
    }

    var fundsPsaaDialog:  CpTDialog? = null

    /**
     *Fund password pop-up window
     */
    fun showPayCoinDialog() {

        fundsPsaaDialog = NewDialogUtils.createNewVersionSecurityDialog(
            this,
            VerifyRule4(),
            AppConstant.C2C_ORDER_CONFIRM,
            object : NewDialogUtils.DialogVerifiactionListener{
                override fun returnCode(phone: String?, mail: String?, googleCode: String?) {}
                override fun returnCode(
                    phone: String,
                    mail: String,
                    googleCode: String,
                    capitalPwd: String,
                    loginPwd: String
                ) {
                    confirmOrder2Seller4OTC(capitalPwd,phone,googleCode)
                    cub_confirm_for_buy.isEnable(false)
                    fundsPsaaDialog?.dismiss()
                }
            }
        )

    }

    fun setOnClick() {

    }

    var confirmOrder = false
    var isfirst = true
    var countTotalTime = 60
    private var mdDisposable: Disposable? = null

    /**
     *Process Cancel Button
     */
    private fun cancelBtnState() {
        if (isfirst) {
            isfirst = !isfirst
        } else {
            return
        }
        mdDisposable = Flowable.intervalRange(0, countTotalTime.toLong(), 0, 1, TimeUnit.SECONDS)
                .observeOn(AndroidSchedulers.mainThread())
                .doOnNext(object : Consumer<Long> {
                    override fun accept(t: Long) {
                        if (otcOrderDetailBean?.status != 1) {
                            return
                        }
                        if (confirmOrder) {
                            return
                        }
                        if ((countTotalTime - t.toInt()) == 0) {
                            getOrderDetail4OTC()
                            return
                        }

                        var formatLongToTimeStr = formatLongToTimeStr((countTotalTime - t.toInt()).toLong())

                        var split = formatLongToTimeStr.split(":")

                        try {
                            btn_cancel.setContent(split[0] + "'" + split[1] + "\"" + LanguageUtil.getString(this@NewVersionSellOrderActivity, "oct_action_autoCancelDesc"))
                        } catch (e: Exception) {
                            e.printStackTrace()
                        }


                    }
                })


                .doOnComplete(object : Action {
                    override fun run() {
                        //Set countdown to clickable state
                        getOrderDetail4OTC()
                    }
                })
                .subscribe()

        /**
         *Cancel
         */
        btn_cancel?.setOnClickListener {
            finish()
        }
    }

    fun formatLongToTimeStr(l: Long): String {
        if (isFinishing || isDestroyed) return ""
        var minute = 0
        var second = l.toInt()
        if (second > 60) {
            minute = second / 60 //Rounding
            second %= 60 //Withdrawal of surplus
        }

        var strtime = ""

        if (minute < 10) {
            strtime += "0$minute:"
        } else {
            strtime += "$minute:"
        }
        if (second < 10) {
            strtime += "0$second"
        } else {
            strtime += "$second"
        }
        return strtime
    }

    /**
     *Confirm coin release
     */
    private fun confirmOrder2Seller4OTC(capitalPword: String,smsAuthCode:String,googleCode:String) {
        showProgressDialog()
        HttpClient.instance
                .confirmOrder2Seller4OTC(sequence = orderId, capitalPword = capitalPword,smsAuthCode,googleCode)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<Any>() {
                    override fun onHandleSuccess(t: Any?) {
                        cancelProgressDialog()
                        /**
                         * TODO
                         *Retrieve order information again
                         *This: Wait for the seller to release the coin
                         */
                        finish()

                    }


                    override fun onHandleError(code: Int, msg: String?) {
                        super.onHandleError(code, msg)
                        cancelProgressDialog()
                        cub_confirm_for_buy.isEnable(true)
                        DisplayUtil.showSnackBar(window?.decorView, msg, isSuc = false)
                    }
                })
    }

    /**
     *Obtain order details
     */
    private fun getOrderDetail4OTC() {
        if (!UserDataService.getInstance().isLogined) {
            return
        }
        showProgressDialog()
        HttpClient.instance
                .getOrderDetail4OTC(sequence = orderId)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<OTCOrderDetailBean>() {
                    override fun onHandleSuccess(t: OTCOrderDetailBean?) {
                        cancelProgressDialog()
                        ll_trading_layout?.visibility = View.VISIBLE
                        nsv_layout?.visibility = View.VISIBLE
                        t ?: return
                        initView(t)

                    }


                    override fun onHandleError(code: Int, msg: String?) {
                        super.onHandleError(code, msg)
                        cancelProgressDialog()
                        DisplayUtil.showSnackBar(window?.decorView, msg, isSuc = false)

                    }
                })
    }

    /**
     *Call interface x every 1 minute
     */
    private fun getOrderStateEachMin() {
        disposables?.add(Observable.interval(0, 60, TimeUnit.SECONDS).subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribeWith(getObserver()))
    }

    override fun onDestroy() {
        super.onDestroy()
        disposables.clear()
        disposeTime()

    }

    fun disposeTime() {
        if (mdDisposable != null) {
            mdDisposable?.dispose()
        }
    }

    fun getObserver(): DisposableObserver<Long> {
        return object : DisposableObserver<Long>() {
            override fun onComplete() {
            }

            override fun onNext(t: Long) {
                Log.d("x", t.toString() + "time")
                loopOrderState()
            }

            override fun onError(e: Throwable) {
            }
        }

    }

    /**
     *Polling Order Interface
     */
    fun loopOrderState() {
        if (!UserDataService.getInstance().isLogined) {
            return
        }
        HttpClient.instance
                .getOrderDetail4OTC(sequence = orderId)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<OTCOrderDetailBean>() {
                    override fun onHandleSuccess(t: OTCOrderDetailBean?) {
                        t ?: return
                        initView(t)
                    }


                    override fun onHandleError(code: Int, msg: String?) {
                        super.onHandleError(code, msg)
                        DisplayUtil.showSnackBar(window?.decorView, msg, isSuc = false)

                    }
                })
    }

    /**
     *Cancel appeal
     */
    private fun cancelComplain4OTC() {
        showProgressDialog()
        HttpClient.instance
                .cancelComplain4OTC(sequence = orderId)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<Any>() {
                    override fun onHandleSuccess(t: Any?) {
                        cancelProgressDialog()
                        /***
                         *Retrieve the status of the order again
                         */
                        getOrderDetail4OTC()
                    }


                    override fun onHandleError(code: Int, msg: String?) {
                        super.onHandleError(code, msg)
                        cancelProgressDialog()
                        DisplayUtil.showSnackBar(window?.decorView, msg, isSuc = false)
                    }
                })
    }
}
