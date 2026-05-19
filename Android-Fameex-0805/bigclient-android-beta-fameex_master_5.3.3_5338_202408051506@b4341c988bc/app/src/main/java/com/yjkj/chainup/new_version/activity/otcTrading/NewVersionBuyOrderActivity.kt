package com.yjkj.chainup.new_version.activity.otcTrading

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.text.TextUtils
import android.util.Log
import android.view.View
import com.fengniao.news.util.DateUtil
 import com.chainup.contract.view.dialog.CpTDialog
import com.yjkj.chainup.R
import com.yjkj.chainup.db.service.OTCPublicInfoDataService
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.RateManager
import com.yjkj.chainup.net.HttpClient
import com.yjkj.chainup.net.retrofit.NetObserver
import com.yjkj.chainup.new_version.activity.NewBaseActivity
import com.yjkj.chainup.new_version.activity.ShowImageActivity
import com.yjkj.chainup.new_version.activity.TitleShowListener
import com.yjkj.chainup.new_version.bean.OTCOrderDetailBean
import com.yjkj.chainup.new_version.bean.TradingSuccessBean
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.view.CommonlyUsedButton
import com.yjkj.chainup.new_version.view.PersonalCenterView
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
import org.greenrobot.eventbus.EventBus
import java.util.concurrent.TimeUnit

/**
 * @Author lianshangljl
 * @Date 2023/4/18-4:04 PM
 * @Email buptjinlong@163.com
 *@description Sales Order
 */
class NewVersionBuyOrderActivity : NewBaseActivity() {


    var orderId = ""

    companion object {
        val ORDERID = "orderId"

        fun enter2(context: Context, orderId: String) {
            var intent = Intent(context, NewVersionBuyOrderActivity::class.java)
            intent.putExtra(ORDERID, orderId)
            context.startActivity(intent)
        }
    }

    var paymentList: ArrayList<String> = arrayListOf()

    var contactDilaog:  CpTDialog? = null

    var remindBuyerWaitConfirmTitle = ""

    private var disposables = CompositeDisposable()
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_new_buy_order)
        remindBuyerWaitConfirmTitle = if (PublicInfoDataService.getInstance().getB2CSwitchOpen(null)) {
            LanguageUtil.getString(this, "otc_tip_remindBuyerWaitConfirm_forotc")
        } else {
            LanguageUtil.getString(this, "otc_tip_remindBuyerWaitConfirm")
        }
        getData()
        listener = object : TitleShowListener {
            override fun TopAndBottom(status: Boolean) {
                title_layout.slidingShowTitle(status)
            }
        }
        getOrderStateEachMin()
        pay_attention_to?.text = LanguageUtil.getString(this, "otc_tip_buyerConfirmPaid")
        tv_name_copy?.setOnClickListener {
            Utils.copyString(tv_firstaname.text.toString())
            DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this, "common_tip_copySuccess"))
        }
    }

    fun getData() {
        if (intent != null) {
            orderId = intent.getStringExtra(ORDERID) ?: ""
        }
        title_layout?.rightIcon(R.mipmap.personal_messagecenter)

    }

    var cancelIsCheck = true
    var otcOrderDetailBean: OTCOrderDetailBean? = null

    var title = ""

    var coin = ""
    var payCoin = ""
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

    fun initView(bean: OTCOrderDetailBean) {
        setTextContent()
        payment_information_layout?.visibility = View.VISIBLE
        line_layout?.visibility = View.VISIBLE
        waiting_attention_to?.visibility = View.GONE
        coin = bean.coin
        title = if (PublicInfoDataService.getInstance().getB2CSwitchOpen(null)) {
            LanguageUtil.getString(this, "otc_tip_buyerOrderComplete_forotc")
        } else {
            LanguageUtil.getString(this, "otc_tip_buyerOrderComplete")
        }
        payCoin = bean.paycoin
        otcOrderDetailBean = bean
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
                /**
                 *Jump to Chat
                 */
                if (bean.status == 5 && bean.isComplainUser == 1) {
                    OTCIMActivity.newIntent(this@NewVersionBuyOrderActivity, bean.complainId, bean.coin, bean.totalPrice.toString()
                            , bean.status.toString(), bean.paycoin, DateUtil.longToString("yyyy-MM-dd HH:mm:ss", bean.ctime), bean.seller.uid, bean.sequence
                            , bean.seller.otcNickName, (bean.limitTime / 1000).toLong(), bean.isComplainUser, "buy",bean.paycoin)
                } else {
                    OTCIMActivity.newIntent4Seller(this@NewVersionBuyOrderActivity, bean.seller.uid, bean.sequence, bean.coin, bean.totalPrice.toString(),
                            bean.status.toString(), bean.paycoin, bean.seller.otcNickName,
                            DateUtil.longToString("yyyy-MM-dd HH:mm:ss", bean.ctime), (bean.limitTime / 1000).toLong(), bean.isComplainUser, bean.complainId, bean.seller.imageUrl,bean.paycoin)
                }

            }

        }

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
                    val jsonObj = OTCPublicInfoDataService.getInstance().getOTCPaymentInfoByKey(payment.payment)
                    if(jsonObj!=null){
                        val title = jsonObj.optString("title")
                        paymentList.add(title)
                    }else{
                        paymentList.add(payment.payment)
                    }

                }
            }
        }




        /**
         *
         *Status: Order status:
         *Pending Payment 1
         *Paid to be received currency 2
         *Transaction successful 3
         *Cancel 4
         *Appeal pending 5
         *Currency to be received 6
         *Abnormal Order 7
         *End of appeal processing 8
         */
        if (bean.showWarnTip && bean.status == 1) {
            payment_information_layout?.visibility = View.GONE
            line_layout?.visibility = View.GONE
            waiting_attention_to?.visibility = View.VISIBLE
            waiting_attention_to?.text = LanguageUtil.getString(this, "otc_tip_orderDuringReview")
            title_layout?.setRightVisible(false)
        } else {
            title_layout?.setRightVisible(true)
        }

        when (bean.status) {
            //Pending payment
            1 -> {
                title_layout?.setContentTitle(LanguageUtil.getString(this, "otc_text_orderWaitPay"))
                btn_cancel?.isEnable(true)
                tv_payment_type?.text = LanguageUtil.getString(this, "common_text_paymentInfoBuyer")

                cub_confirm_for_buy?.isEnable(true)
                tv_money_copy?.visibility = View.GONE
                tv_switching?.visibility = View.VISIBLE
                if (bean?.showWarnTip) {
                    cub_confirm_for_buy?.setContent(LanguageUtil.getString(this, "otc_action_refreshOrder"))
                } else {
                    cub_confirm_for_buy?.setContent(LanguageUtil.getString(this, "otc_action_buyerDidPay"))
                }
                if (isfirst) {
                    countTotalTime = bean.limitTime / 1000
                }

                cancelBtnState()
                tv_user_copy?.visibility = View.VISIBLE
                tv_payment_account_copy?.visibility = View.VISIBLE
                tv_user_copy?.setOnClickListener {
                    ClipboardUtil.copy(tv_user_content)
                    DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this, "common_tip_copySuccess"))
                }

            }
            //Paid to be received currency
            2 -> {

                tv_switching?.visibility = View.GONE
                tv_payment_type?.text = LanguageUtil.getString(this, "common_text_paymentInfoBuyer")
                tv_money_copy?.visibility = View.GONE
                title_layout?.setContentTitle(LanguageUtil.getString(this, "otc_text_waitReceiveCoin"))
                cub_confirm_for_buy?.setContent(LanguageUtil.getString(this, "otc_tip_sellerPendingCoin"))
                btn_cancel?.setContent(LanguageUtil.getString(this, "otc_action_appeal"))
                /**
                 *It will take 5 minutes to click
                 *Appeal
                 */
                btn_cancel?.isEnable(true)
                var curTime = System.currentTimeMillis()
                if (bean.payTime.toLong() != 0L) {
                    cancelIsCheck = (curTime / 1000 - 300 - bean.payTime.toLong() / 1000) > 0
                }
                cub_confirm_for_buy?.isEnable(false)
//                waiting_attention_to.visibility = View.VISIBLE
                disposeTime()

                /**
                 *Cancel
                 */
                btn_cancel?.isEnable(true)
                btn_cancel?.listener = object : CommonlyUsedButton.OnBottonListener {
                    override fun bottonOnClick() {
                        if (cancelIsCheck) {
                            NewComplaintActivity.enter2(this@NewVersionBuyOrderActivity, bean.sequence, true, "8", payCoin)
                            finish()
                        } else {
                            DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this@NewVersionBuyOrderActivity, "otc_tip_appealTimeLimit"), isSuc = false)
                        }

                    }
                }

            }
            //Successful transaction
            3 -> {
                title_layout?.setContentTitle(LanguageUtil.getString(this, "otc_text_orderComplete"))
                ll_trading_layout?.visibility = View.GONE
                waiting_attention_to?.visibility = View.GONE
                tv_switching?.visibility = View.GONE
                tv_payment_type?.text = LanguageUtil.getString(this, "common_text_paymentInfoBuyer")
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
            }
            /**
             *Cancel
             */
            4 -> {
                title_layout?.setContentTitle(LanguageUtil.getString(this, "filter_otc_cancel"))
                order_cancellation_layout?.visibility = View.VISIBLE
                line_layout?.visibility = View.GONE
                tv_money_copy?.visibility = View.GONE
                ll_trading_layout?.visibility = View.GONE
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
            /**
             *In appeal
             */
            5 -> {
                title_layout?.setContentTitle(LanguageUtil.getString(this, "filter_otc_appeal"))
                pey_time_layout?.visibility = View.VISIBLE
                tv_pay_time_copy?.visibility = View.GONE
                if (!TextUtils.isEmpty(bean.payTime)) {
                    tv_pay_time?.text = DateUtil.longToString("yyyy/MM/dd HH:mm:ss", bean.payTime.toLong())
                }

                tv_switching?.visibility = View.GONE
                tv_payment_type?.text = LanguageUtil.getString(this, "common_text_paymentInfoBuyer")
                if (bean.isComplainUser == 1) {
                    pay_attention_to?.text = String.format(LanguageUtil.getString(this, "otc_tip_appealOffence"),bean.complainCommand)
                    cub_confirm_for_buy?.setContent(LanguageUtil.getString(this, "otc_text_orderPendingAppeal"))
                    cub_confirm_for_buy?.isEnable(false)
                    btn_cancel?.isEnable(true)
                    btn_cancel?.setContent(LanguageUtil.getString(this, "otc_action_cancelAppeal"))
                    btn_cancel?.listener = object : CommonlyUsedButton.OnBottonListener {
                        override fun bottonOnClick() {
                            NewDialogUtils.showNormalDialog(this@NewVersionBuyOrderActivity, LanguageUtil.getString(this@NewVersionBuyOrderActivity, "otc_tip_cancleAppealConfirm"), object : NewDialogUtils.DialogBottomListener {
                                override fun sendConfirm() {
                                    cancelComplain4OTC()
                                }
                            }, "")
                        }
                    }

                } else {
                    btn_cancel?.visibility = View.GONE
                    cub_confirm_for_buy?.setContent(LanguageUtil.getString(this, "otc_tip_appealCharged"))
                    cub_confirm_for_buy?.isEnable(false)
                }

//                tv_complainCommand.text = bean?.complainCommand


            }
            //Currency to be received
            6 -> {
                tv_switching?.visibility = View.GONE
                tv_payment_type?.text = LanguageUtil.getString(this, "common_text_paymentInfoBuyer")
                title_layout?.setContentTitle(LanguageUtil.getString(this, "otc_text_waitReceiveCoin"))
                cub_confirm_for_buy?.setContent(LanguageUtil.getString(this, "otc_tip_sellerPendingCoin"))
                btn_cancel?.setContent(LanguageUtil.getString(this, "otc_action_appeal"))
                /**
                 *It will take 5 minutes to click
                 *Appeal
                 */
                btn_cancel?.isEnable(true)
                var curTime = System.currentTimeMillis()
                if (bean.payTime.toLong() != 0L) {
                    cancelIsCheck = (curTime / 1000 - 300 - bean.payTime.toLong() / 1000) > 0
                }
                cub_confirm_for_buy?.isEnable(false)
//                waiting_attention_to.visibility = View.VISIBLE
                disposeTime()

                /**
                 *Cancel
                 */
                btn_cancel?.isEnable(true)
                btn_cancel?.listener = object : CommonlyUsedButton.OnBottonListener {
                    override fun bottonOnClick() {
                        if (cancelIsCheck) {
                            NewComplaintActivity.enter2(this@NewVersionBuyOrderActivity, bean.sequence, true, "8", payCoin)
                            finish()
                        } else {
                            DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this@NewVersionBuyOrderActivity, "otc_tip_appealTimeLimit"), isSuc = false)
                        }

                    }

                }
            }
            7 -> {
                title_layout?.setContentTitle(LanguageUtil.getString(this, "contract_text_orderError"))
                ll_trading_layout?.visibility = View.GONE
                tv_switching?.visibility = View.GONE
            }

            8 -> {
                /***
                 *Appeal closed OTC/complaint_ Cancel
                 *Display the status of order completion
                 */
                title_layout?.setContentTitle(LanguageUtil.getString(this, "otc_text_orderComplete"))

                ll_trading_layout?.visibility = View.GONE
                waiting_attention_to?.visibility = View.GONE
                tv_switching?.visibility = View.GONE

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
                payment_information_layout?.visibility = View.GONE
                when (bean.cancelStatus) {
                    "0" -> {
                        order_cancellation_layout?.visibility = View.GONE
                    }
                    "1" -> {
                        tv_order_cancellation_type.text = LanguageUtil.getString(this, "otc_text_cancelByBuyer")
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
        tv_user_nick_name?.text = bean.seller.otcNickName

        tv_real_name.text = bean.seller.realName
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
                    contactDilaog = NewDialogUtils.OTCOorderContactDialog(this, bean.seller.mobileNumber, bean.seller.email, object : NewDialogUtils.DialogBottomListener {
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
        if (TextUtils.isEmpty(bean?.sequence)) {
            tv_order_number_copy.visibility = View.GONE
        } else {
            tv_order_number_copy.visibility = View.VISIBLE
        }
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
        tv_money_title?.text = LanguageUtil.getString(this, "journalAccount_text_amount") + "(${bean.paycoin})"
        /**
         *Unit price
         */
        tv_otc_price_title?.text = LanguageUtil.getString(this, "otc_text_price") + "(${bean.paycoin})"
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




        cub_confirm_for_buy?.listener = object : CommonlyUsedButton.OnBottonListener {
            override fun bottonOnClick() {
                if (bean?.status == 1 && bean?.showWarnTip) {
                    getOrderDetail4OTC()
                } else {
                    NewDialogUtils.tradingOTCConfirm(this@NewVersionBuyOrderActivity, LanguageUtil.getString(this@NewVersionBuyOrderActivity, "otc_text_didPayConfirm"), peymentString, selectPaymentBean?.userName
                            ?: "", BigDecimalUtils.showSNormal(bean.totalPrice.toString()) + bean.paycoin, object : NewDialogUtils.DialogBottomListener {
                        override fun sendConfirm() {
                            cub_confirm_for_buy.isEnable(false)
                            confirmOrder = true
                            disposables.clear()
                            disposeTime()
                            confirmPay2Buyer4OTC()
                        }
                    }, LanguageUtil.getString(this@NewVersionBuyOrderActivity, "common_text_btnConfirm"), true)
                }
            }

        }

        ll_payment_type_layout?.setOnClickListener {

            if (bean.status == 1 && bean.payment.size != 1) {
                dialogForPayment = NewDialogUtils.showBottomListDialog(this@NewVersionBuyOrderActivity, paymentList, selectPosition, object : NewDialogUtils.DialogOnclickListener {
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

        if (null != bean.payment && bean.payment.size > 0) {
            peymentString = setPaymentLayout(paymentBean ?: bean.payment[0])
        }

    }

    var selectPosition = 0

    var confirmOrder = false

    var dialogForPayment: CpTDialog? = null

    var peymentString = ""
    var paymentKey = ""
    var selectPaymentBean: OTCOrderDetailBean.Payment? = null
    fun setPaymentLayout(paymentBean: OTCOrderDetailBean.Payment): String {
        var peymentString = ""
        paymentKey = paymentBean.payment
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


                tv_payment_title?.text = LanguageUtil.getString(this, "wxpay_text_qrcode")
                tv_payment?.text = ""
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
                    DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this, "common_tip_copySuccess"))
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
                tv_payment?.text = ""
                tv_payment_title?.text = LanguageUtil.getString(this, "alipay_text_qrcode")
                peymentString = LanguageUtil.getString(this, "payMethod_text_alipay")

                peyment_code?.visibility = View.VISIBLE

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

            else -> {
                var nameTitle = paymentBean.payment
                if(nameTitle.contains("otc.payment")){
                    val ary = nameTitle.split(".")
                    nameTitle = if(ary.size==3){
                        ary[2].toUpperCase()
                    }else{
                        ""
                    }
                }else{
                    nameTitle = ""
                }
                GlideUtils.loadImage(this, paymentBean.icon, iv_payment_imageview)

                if (TextUtils.isEmpty(paymentBean.icon)) {
                    iv_payment_imageview?.visibility = View.GONE
                }

                //Payee
                tv_firstaname_title?.text = LanguageUtil.getString(this, "otc_text_payee")
                tv_firstaname?.text = paymentBean.userName

                tv_payment_type?.text = paymentList[selectPosition]

                tv_user_title?.text =  "$nameTitle ${LanguageUtil.getString(this, "noun_account_accountName")}"
                tv_user_content?.text = paymentBean.account
                tv_payment?.text = ""
                tv_payment_title?.text = ""
                peymentString = "$nameTitle ${LanguageUtil.getString(this, "noun_account_accountName")}"

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
        }
        return peymentString
    }


    var countTotalTime = 60
    private var mdDisposable: Disposable? = null
    private var isfirst = true


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
                            cancelOrder4OTC()
                            return
                        }

                        var formatLongToTimeStr = formatLongToTimeStr((countTotalTime - t.toInt()).toLong())

                        var split = formatLongToTimeStr.split(":")

                        try {
                            btn_cancel?.setContent(split[0] + "'" + split[1] + "\"" + LanguageUtil.getString(this@NewVersionBuyOrderActivity, "oct_action_autoCancelDesc"))
                        } catch (e: Exception) {
                            e.printStackTrace()
                        }
                    }
                })


                .doOnComplete(object : Action {
                    override fun run() {
                        //Set countdown to clickable state
                        cancelOrder4OTC()
                    }
                })
                .subscribe()

        /**
         *Cancel
         */
        btn_cancel?.listener = object : CommonlyUsedButton.OnBottonListener {
            override fun bottonOnClick() {
                NewDialogUtils.tradingOTCCancelOrder(this@NewVersionBuyOrderActivity, object : NewDialogUtils.DialogBottomListener {
                    override fun sendConfirm() {
                        cancelOrder4OTC()
                    }
                })
            }
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
                        t ?: return
                        ll_trading_layout?.visibility = View.VISIBLE
                        nsv_layout?.visibility = View.VISIBLE
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
        disposables.add(Observable.interval(0, 60, TimeUnit.SECONDS).subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribeWith(getObserver()))
    }

    override fun onDestroy() {
        super.onDestroy()
        disposables?.clear()
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
        try {
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
        } catch (e: java.lang.Exception) {
            e.printStackTrace()
        }

    }

    /**
     *Confirm payment
     */
    private fun confirmPay2Buyer4OTC() {
        showProgressDialog()
        HttpClient.instance
                .confirmPay2Buyer4OTC(sequence = orderId, payment = paymentKey)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<Any>() {
                    override fun onHandleSuccess(t: Any?) {
                        cancelProgressDialog()
                        EventBus.getDefault().post(TradingSuccessBean(coin))
                        /**
                         * TODO
                         *Retrieve order information again
                         *This: Wait for the seller to release the coin
                         */
                        getOrderDetail4OTC()

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

    /**
     *Cancel Order
     */
    private fun cancelOrder4OTC() {
        showProgressDialog()
        HttpClient.instance
                .cancelOrder4OTC(sequence = orderId)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<Any>() {
                    override fun onHandleSuccess(t: Any?) {
                        cancelProgressDialog()
                        /***
                         *Display the status of order cancellation
                         */
                        finish()
                    }


                    override fun onHandleError(code: Int, msg: String?) {
                        super.onHandleError(code, msg)
                        cancelProgressDialog()
                        DisplayUtil.showSnackBar(window?.decorView, msg, isSuc = false)
                    }
                })
    }


}


