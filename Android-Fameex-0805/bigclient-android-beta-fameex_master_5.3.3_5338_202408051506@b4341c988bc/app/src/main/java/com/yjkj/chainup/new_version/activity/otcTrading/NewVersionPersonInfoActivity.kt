package com.yjkj.chainup.new_version.activity.otcTrading

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.recyclerview.widget.LinearLayoutManager
import com.blankj.utilcode.util.GsonUtils
import com.chainup.kit.KKDialogUtils
import com.yjkj.chainup.util.JsonUtils
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseActivity
import com.yjkj.chainup.bean.EquityBean
import com.yjkj.chainup.bean.PersonAdsBean
import com.yjkj.chainup.bean.UserInfo4OTC
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.LoginManager
import com.yjkj.chainup.net.HttpClient
import com.yjkj.chainup.net.retrofit.NetObserver
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.net_new.rxjava.NModelDisposableObserver
import com.yjkj.chainup.new_version.adapter.NewOTCPersonAdapter
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.view.EmptyForAdapterView
import com.yjkj.chainup.new_version.view.NewOTCAdsListener
import com.yjkj.chainup.new_version.view.PersonalCenterView
import com.yjkj.chainup.util.BigDecimalUtils
import com.yjkj.chainup.util.ColorUtil
import com.yjkj.chainup.util.DisplayUtil
import com.yjkj.chainup.util.NToastUtil
import com.yjkj.chainup.util.StringUtil
import com.yjkj.chainup.util.tr
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.activity_new_person_info.*
import kotlinx.android.synthetic.main.item_person_info.*
import org.json.JSONArray
import org.json.JSONObject


const val PERSON_BUY = "buy"
const val PERSON_SELL = "sell"

/**
 * @Author lianshangljl
 * @Date 2023/4/23-10:32 AM
 * @Email buptjinlong@163.com
 * @description
 */
class NewVersionPersonInfoActivity : NBaseActivity(), NewOTCAdsListener {
    override fun setContentView(): Int {
        return R.layout.activity_new_person_info
    }


    override fun setOTCClick(item: PersonAdsBean.AdList) {
        getValidateAdvert(item.advertId, adType, item.coin, item.payments.size == 0,item)
    }

    var uid = ""

    companion object {
        const val UID: String = "UID"
        fun enter(context: Context, uid: String) {
            var intent = Intent(context, NewVersionPersonInfoActivity::class.java)
            intent.putExtra(UID, uid)
            context.startActivity(intent)
        }
    }

    fun setTextContent() {
        title_layout?.setContentTitle(getStringContent("otc_text_merchantHomePage"))
        title_layout?.setRightTitle(getStringContent("otc_action_addBlackList"))
        tv_transaction_number_title?.text = getStringContent("otc_text_merchantTradeNumber")
        tv_complain_num_title?.text = getStringContent("otc_text_merchantAppealNumber")
        tv_suc_complain_num_title?.text = getStringContent("otc_text_merchantAppealWin")
        tv_otc_xinyong_title?.text = getStringContent("otc_xinyong")
        tv_merchantPhoneAuth?.text = getStringContent("otc_text_merchantPhoneAuth")
        tv_identify?.text = getStringContent("common_text_identify")
        rb_buy?.text = getStringContent("otc_action_merchantBuy")
        rb_sell?.text = getStringContent("otc_action_merchantSell")

    }

    fun getStringContent(contentId: String): String {
        return LanguageUtil.getString(this, contentId)
    }

    var pageSize: String = "20"
    var page: Int = 1
    var adType = PERSON_BUY
    var adapter: NewOTCPersonAdapter? = null

    override fun onInit(savedInstanceState: Bundle?) {
        super.onInit(savedInstanceState)
        rb_buy?.setCompoundDrawablesWithIntrinsicBounds(0, 0, 0, ColorUtil.getOTCBuyOrSellDrawable())
        rb_sell?.setCompoundDrawablesWithIntrinsicBounds(0, 0, 0, 0)
        setTextContent()
        getData()
        getPersonInfo()
        getPersonAds(adType)
        setOnClick()
    }

    override fun onResume() {
        super.onResume()
        getUserPayment4OTC()
    }

    fun getData() {
        intent ?: return
        uid = intent.getStringExtra(UID)?:""
    }

    var beanInfo: UserInfo4OTC? = null
    fun initPersonInfoView(bean: UserInfo4OTC) {
        beanInfo = bean
        if (bean.otcNickName.isNotEmpty()) {
            iv_header_view?.text = bean.otcNickName.substring(0, 1)
        }
        tv_user_name?.text = bean.otcNickName
        /**
         *Number of transactions
         */
        tv_transaction_number_content?.text = bean.completeOrders.toString()
        /**
         *Total number of wins
         */
        tv_complain_num_content?.text = bean.complainNum.toString()
        /**
         *Number of successful lawsuits
         */
        tv_suc_complain_num_content?.text = bean.sucComplainNum.toString()
        /**
         *Credit
         */
        tv_otc_xinyong_content?.text = BigDecimalUtils.divForDown(BigDecimalUtils.mul((1 - bean.trustScore).toString(), "100").toString(), 0).toString() + "%"

        /**
         *Is mobile verification enabled
         */
        if (bean.mobileAuthStatus == 1) {
            iv_phone_status?.setImageResource(R.drawable.fiat_complete)
        } else {
            iv_phone_status?.setImageResource(R.drawable.delete)
        }

        /**
         *Identity authentication
         */
        if (bean.authLevel == 1) {
            iv_identity_certificate_status?.setImageResource(R.drawable.fiat_complete)
        } else {
            iv_identity_certificate_status?.setImageResource(R.drawable.delete)
        }

        /**
         *Determine the access status of this page (as follows):
        0：未登录用户查看他人的主页和登录用户查看自己的主页；
        1：登录用户查看他人的主页，并且当前显示用户在登录用户黑名单中；
        2：登录用户查看他人的主页，并且当前显示用户不在登录用户黑名单中
         */
        when (beanInfo?.identity) {
            0 -> {
                title_layout?.setRightTitle("")
            }
            1 -> {
                title_layout?.setRightTitle(getStringContent("common_action_removeBlackList"))
            }
            2 -> {
                title_layout?.setRightTitle(getStringContent("otc_action_addBlackList"))
            }

        }

        tv_online.visibility = if(bean.loginStatus==1) View.VISIBLE else View.GONE
    }

    /**
     *Obtain personal information
     */
    fun getPersonInfo() {
        HttpClient.instance.getPerson4otc(uid)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<UserInfo4OTC>() {
                    override fun onHandleSuccess(t: UserInfo4OTC?) {
                        t ?: return
                        initPersonInfoView(t)
                    }

                    override fun onHandleError(code: Int, msg: String?) {
                        super.onHandleError(code, msg)
                        DisplayUtil.showSnackBar(window?.decorView, msg, isSuc = false)
                    }
                })
    }


    fun setOnClick() {
        /**
         *Switch price purchase or quantity purchase
         */
        rg_buy_sell?.setOnCheckedChangeListener { group, checkedId ->

            when (checkedId) {
                R.id.rb_buy -> {
                    rb_buy?.setCompoundDrawablesWithIntrinsicBounds(0, 0, 0, ColorUtil.getOTCBuyOrSellDrawable())
                    rb_sell?.setCompoundDrawablesWithIntrinsicBounds(0, 0, 0, 0)
                    isfrister = true
                    adType = PERSON_BUY
                    getPersonAds(adType)
                }

                R.id.rb_sell -> {
                    rb_sell?.setCompoundDrawablesWithIntrinsicBounds(0, 0, 0, ColorUtil.getOTCBuyOrSellDrawable())
                    rb_buy?.setCompoundDrawablesWithIntrinsicBounds(0, 0, 0, 0)
                    isfrister = true
                    adType = PERSON_SELL
                    getPersonAds(adType)
                }
            }
        }
        title_layout.listener = object : PersonalCenterView.MyProfileListener {
            override fun onclickHead() {

            }

            override fun onclickRightIcon() {
                if (!LoginManager.checkLogin(this@NewVersionPersonInfoActivity, true)) {
                    return
                }
                /**
                 *Determine the access status of this page (as follows):
                0：未登录用户查看他人的主页和登录用户查看自己的主页；
                1：登录用户查看他人的主页，并且当前显示用户在登录用户黑名单中；
                2：登录用户查看他人的主页，并且当前显示用户不在登录用户黑名单中
                 */
                when (beanInfo?.identity) {
                    1 -> {
                        KKDialogUtils.showCommonDialog(
                            this@NewVersionPersonInfoActivity,
                            content = getStringContent("common_tip_removeBlackList"),
                            style = 1,
                            listener = object: KKDialogUtils.DialogDoubleBottomListener{
                                override fun sendConfirm() {
                                    removeRelationFromBlack(uid)
                                }

                                override fun sendCancel() {

                                }

                            },
                            confrimTitle = getStringContent("common_text_btnConfirm"),
                            cancelTitle = getStringContent("common_action_thinkAgain")
                        )

                    }
                    2 -> {
                        KKDialogUtils.showCommonDialog(
                            this@NewVersionPersonInfoActivity,
                            content = getStringContent("common_tip_addToBlackList"),
                            style = 1,
                            listener = object: KKDialogUtils.DialogDoubleBottomListener{
                                override fun sendConfirm() {
                                    userContacts4OTC(uid)
                                }

                                override fun sendCancel() {

                                }

                            },
                            confrimTitle = getStringContent("common_text_btnConfirm"),
                            cancelTitle = getStringContent("common_action_thinkAgain")
                        )

                    }
                }

            }

            override fun onclickName() {

            }

            override fun onRealNameCertificat() {

            }

        }
    }

    var adList: ArrayList<PersonAdsBean.AdList> = arrayListOf()
    var payments: ArrayList<PersonAdsBean.Payments> = arrayListOf()

    fun initAdapter(bean: PersonAdsBean) {
        if (recycler_view == null) return
        adList = bean.adList
        adapter = NewOTCPersonAdapter(adList, this)
        recycler_view?.layoutManager = LinearLayoutManager(this)
        adapter?.setEmptyView(EmptyForAdapterView(this))
        recycler_view?.adapter = adapter
    }

    fun refreshView(bean: PersonAdsBean) {
        adapter?.setList(bean.adList)
    }

    var isfrister = true
    /**
     *Obtain advertising information
     */

    fun getPersonAds(adType: String) {
        adList.clear()
        adapter?.notifyDataSetChanged()
        showLoadingDialog()
        HttpClient.instance.getPersonAds(uid, pageSize, page.toString(), adType)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<PersonAdsBean>() {
                    override fun onHandleSuccess(t: PersonAdsBean?) {
                        t ?: return
                        if (isfrister) {
                            isfrister = false
                            initAdapter(t)
                        } else {
                            refreshView(t)
                        }
                        closeLoadingDialog()
                    }

                })
    }


    /**
     *Remove blacklist
     */
    fun removeRelationFromBlack(userId: String) {
        HttpClient.instance.removeRelationFromBlack(friendId = userId.toInt())
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<Any>() {
                    override fun onHandleSuccess(t: Any?) {
                        //TODO Remove this item
                        title_layout?.setRightTitle(getStringContent("otc_action_addBlackList"))
                        beanInfo?.identity = 0
                        DisplayUtil.showSnackBar(window?.decorView, getStringContent("otc_tip_didRemoveBlackList"), isSuc = true)
                    }

                    override fun onHandleError(code: Int, msg: String?) {
                        super.onHandleError(code, msg)
                        DisplayUtil.showSnackBar(window?.decorView, msg, isSuc = false)
                    }
                })
    }

    /**
     *Join blacklist
     */
    fun userContacts4OTC(otherUid: String) {
        HttpClient.instance.userContacts4OTC(otherUid)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<Any>() {
                    override fun onHandleSuccess(t: Any?) {
                        title_layout?.setRightTitle(getStringContent("common_action_removeBlackList"))
                        beanInfo?.identity = 1
                        DisplayUtil.showSnackBar(window?.decorView, getStringContent("common_tip_didinBlacklist"), isSuc = true)

                    }

                    override fun onHandleError(code: Int, msg: String?) {
                        super.onHandleError(code, msg)
                        DisplayUtil.showSnackBar(window?.decorView, msg, isSuc = false)
                    }
                })
    }


    /**
     *Verification before purchase and sale (app4.0)
     */
    fun getValidateAdvert(id: String, advertType: String, coin: String, status: Boolean,item:PersonAdsBean.AdList) {

        if (!LoginManager.checkLogin(this, true)) {
            return
        }
        getEquity {

            if(it==0) {
                JsonUtils.showAuthPermissionNoEnoughDialog(this,isForce = false)
                return@getEquity
            }

            var type = if (advertType == "sell") "buy" else "sell"
            if (type == "sell") {
                if (JsonUtils.getCertification(this)) {
                    if (beans.size == 0) {
                        NewDialogUtils.OTCTradingSecurityDialog(this, object : NewDialogUtils.DialogBottomListener {
                            override fun sendConfirm() {
                                if (UserDataService.getInstance().isCapitalPwordSet != 1) {
                                    ArouterUtil.greenChannel(RoutePath.SafetySettingActivity, null)
                                } else {
                                    ArouterUtil.greenChannel(RoutePath.PaymentMethodActivity, null)
                                }

                            }
                        }, beans.size != 0)
                        return@getEquity
                    }else {
                        if (showFiatPaymentDialog(item.payments)) {
                            return@getEquity
                        }
                    }
                } else {
                    return@getEquity
                }
            }

            addDisposable(getOTCModel().getValidateAdvert(id, type, object : NDisposableObserver() {
                override fun onResponseSuccess(jsonObject: JSONObject) {
                    if (advertType == "buy") {
                        NewVersionOTCSellActivity.enter2(this@NewVersionPersonInfoActivity, if (id.isNotEmpty()) id.toInt() else 0)
                    } else {
                        NewVersionOTCBuyActivity.enter2(this@NewVersionPersonInfoActivity, if (id.isNotEmpty()) id.toInt() else 0)
                    }
                }

                override fun onResponseFailure(code: Int, msg: String?) {
                    super.onResponseFailure(code, msg)
                    TradeCertification(type, code, msg, coin)
                }
            }))
        }

    }

    private fun getEquity(bolck:(c2cStatus:Int) -> Unit){
        addDisposable(
            getMainModel().getEquity(null,consumer = object :
                NModelDisposableObserver<EquityBean>(){
                override fun onResponseSuccess(data: EquityBean) {
                    bolck.invoke(data.c2cStatus)
                }
            })
        )
    }

    private fun showFiatPaymentDialog(payments:ArrayList<PersonAdsBean.Payments>?): Boolean {

        if (null != payments && payments.size > 0) {
            var match = false
            for (i in 0 until payments.size) {
                var key = payments[i].key
                for (j in 0 until beans.size) {
                    var payment = beans[j].optString("payment") ?: ""
                    if (StringUtil.checkStr(payment) && payment == key) {
                        var isOpen = beans[j]?.optInt("isOpen") ?: 0
                        if (1 == isOpen) {
                            match = true
                        }
                    }
                }
            }
            if (!match) {
                NewDialogUtils.activationPaymentMethodDialog(this, object : NewDialogUtils.DialogBottomListener {
                    override fun sendConfirm() {
                        ArouterUtil.greenChannel(RoutePath.PaymentMethodActivity, null)
                    }
                }, JSONArray(JsonUtils.listToJson(payments)))
                return true
            }
        }
        return false
    }

    private fun TradeCertification(advertType: String, code: Int, msg: String?, coin: String?) {
        if (advertType == "buy") {
            if (code == 2074 || code == 2055) {
                JsonUtils.getCertificationNew(this, isNeedBindGa = false)
                return
            } else if (code == 2079) {
                NewDialogUtils.showNormalDialog(this@NewVersionPersonInfoActivity, msg
                        ?: "", object : NewDialogUtils.DialogBottomListener {
                    override fun sendConfirm() {

                    }
                }, "", getStringContent("alert_common_iknow"))
                return
            } else if (code == 2069) {
                NewDialogUtils.showNormalDialog(this@NewVersionPersonInfoActivity, msg
                        ?: "", object : NewDialogUtils.DialogBottomListener {
                    override fun sendConfirm() {
                        if (LoginManager.checkLogin(this@NewVersionPersonInfoActivity, true)) {
                            ArouterUtil.greenChannel(RoutePath.NewOTCOrdersActivity, null)
                        }

                    }
                }, "", getStringContent("alert_action_toDealWith"))
                return
            } else if (code != -1) {
                NToastUtil.showTopToastNet(mActivity,false, msg)
            }

        } else {
            if (code == 2056) {
                NewDialogUtils.OTCTradingSecurityDialog(this@NewVersionPersonInfoActivity, object : NewDialogUtils.DialogBottomListener {
                    override fun sendConfirm() {
                        if (code == 2001) {
                            ArouterUtil.greenChannel(RoutePath.SafetySettingActivity, null)
                        } else {
                            ArouterUtil.greenChannel(RoutePath.PaymentMethodActivity, null)
                        }

                    }
                }, beans.size != 0)
                return
            } else if (code == 2078) {
                NewDialogUtils.showNormalDialog(this@NewVersionPersonInfoActivity, msg
                        ?: "", object : NewDialogUtils.DialogBottomListener {
                    override fun sendConfirm() {
                        ArouterUtil.forwardTransfer(ParamConstant.TRANSFER_BIBI, coin)
                    }
                }, "", getStringContent("alert_action_toTransfer"), getStringContent("common_text_btnCancel"))
                true
            } else if (code == 2069) {
                NewDialogUtils.showSingle2Dialog(this@NewVersionPersonInfoActivity, msg
                        ?: "", object : NewDialogUtils.DialogBottomListener {
                    override fun sendConfirm() {
                        if (LoginManager.checkLogin(this@NewVersionPersonInfoActivity, true)) {
                            ArouterUtil.greenChannel(RoutePath.NewOTCOrdersActivity, null)
                        }

                    }
                }, "", getStringContent("alert_action_toDealWith"))
                return
            } else if (code != -1) {
                NToastUtil.showTopToastNet(mActivity,false, msg)
            }
        }
    }


    var beans: ArrayList<JSONObject> = arrayListOf()
    /**
     *Obtain payment method
     */
    private fun getUserPayment4OTC() {
        if (UserDataService.getInstance().isLogined) {
            addDisposable(getOTCModel().getUserPayment4OTC(consumer = object : NDisposableObserver() {
                override fun onResponseSuccess(jsonObject: JSONObject) {
                    beans.clear()
                    val json = jsonObject.optJSONArray("data")
                    if (json?.length() ?: 0 > 0) {
                        for (num in 0 until json.length()) {
                            beans.add(json.optJSONObject(num))
                        }
                    }

                }

            }))
        }
    }
}
