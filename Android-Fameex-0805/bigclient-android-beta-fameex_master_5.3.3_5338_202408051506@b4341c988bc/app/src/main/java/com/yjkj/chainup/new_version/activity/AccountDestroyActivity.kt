package com.yjkj.chainup.new_version.activity

import android.os.Bundle
import android.text.Spannable
import android.text.SpannableString
import android.text.style.ForegroundColorSpan
import android.view.LayoutInflater
import android.view.View
import android.widget.*
import androidx.core.content.ContextCompat
import com.alibaba.android.arouter.facade.annotation.Route
import com.chainup.contract.view.dialog.CpTDialog
import com.chainup.contract.view.dialog.listener.OnCpBindViewListener
import com.yjkj.chainup.R
import com.yjkj.chainup.app.AppConstant
import com.yjkj.chainup.base.NBaseActivity
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.extra_service.eventbus.EventBusUtil
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.LoginManager
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.view.CommonlyUsedButton
import com.yjkj.chainup.util.BigDecimalUtils
import com.yjkj.chainup.util.LogUtil
import com.yjkj.chainup.util.SizeUtils
import com.yjkj.chainup.util.ToastUtils
import com.yjkj.chainup.util.getLineText
import com.yjkj.chainup.util.tr
import kotlinx.android.synthetic.main.activity_account_destroy.*
import org.json.JSONObject

/**
 *Account cancellation
 *
 * */
@Route(path = RoutePath.AccountDestroyActivity)
class AccountDestroyActivity : NBaseActivity(),CommonlyUsedButton.OnBottonListener {

    override fun setContentView(): Int = R.layout.activity_account_destroy

    override fun onInit(savedInstanceState: Bundle?) {
        super.onInit(savedInstanceState)
        setStatusBarColor(R.color.card_bg_color_1)
        window.navigationBarColor = ContextCompat.getColor(this,R.color.card_bg_color_1)
        initView()
        setViewListener()
        getTotalBalance()
    }

    private fun setViewListener() {
        rl_agree?.setOnClickListener {
            cb_agree?.run{
                isChecked = !isChecked
            }
        }

        cub_submit?.run{
            setContent(getLineText("account_destory_text6"))
            listener = this@AccountDestroyActivity
        }

        cb_agree?.setOnCheckedChangeListener(object: CompoundButton.OnCheckedChangeListener {
            override fun onCheckedChanged(buttonView: CompoundButton?, isChecked: Boolean) {
                cub_submit.isEnable(isChecked)
            }
        })
    }

    override fun initView() {
        super.initView()
        tv_warn_msg?.text = getLineText("account_destory_text3")
        tv_destroy_title?.text = getLineText("account_destory_text2")
        title_layout?.title = "account_destory_text1".tr(this)
        cub_submit?.isEnable(false)
        setExplainList()
    }

    //Obtain balance
    private fun getTotalBalance() {
        addDisposable(
            getMainModel().getTotalAsset(consumer = object : NDisposableObserver() {
                override fun onResponseSuccess(jsonObject: JSONObject) {
                    val data = jsonObject.optJSONObject("data")
                    data?.run {
                        val coin = optString("totalBalanceSymbol")?:"BTC"
                        val coinData = PublicInfoDataService.getInstance().getCoinByName(coin)
                        val precision = coinData.optInt("showPrecision",8)
                        val balances = BigDecimalUtils.showSNormal(data.optString("totalBalance"),precision)
                        setAgreeMsg("$balances $coin")
                    }

                }
            })
        )
    }

    //Set bottom selection box balance
    private fun setAgreeMsg(value:String) {
        val agreeMsgString = SpannableString(String.format(LanguageUtil.getString(this,"account_destory_text5"),value))
        try {
            if("zh_CN".equals(LanguageUtil.getSelectLanguage())){
                agreeMsgString.setSpan(ForegroundColorSpan(ContextCompat.getColor(this,R.color.text_color_1)), agreeMsgString.indexOf(" "), agreeMsgString.indexOf("，"), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)
            }else{
                agreeMsgString.setSpan(ForegroundColorSpan(ContextCompat.getColor(this,R.color.text_color_1)), agreeMsgString.indexOf("is")+2, agreeMsgString.indexOf(","), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)
            }
        }catch (e:Exception){
            e.printStackTrace()
        }
        tv_agree?.text = agreeMsgString
    }


    //Click on account detection
    override fun bottonOnClick() {
        addDisposable(
            getMainModel().getAccountDestroyVerification(consumer = object: NDisposableObserver(this,true){
                override fun onResponseSuccess(jsonObject: JSONObject) {
                    val data = jsonObject.optJSONObject("data")
                    data?.run {
                        val verifyGeneralOrder = optInt("verifyGeneralOrder")
                        val verifyLeverOrder = optInt("verifyLeverOrder")
                        val verifyContract = optInt("verifyContract")
                        val verifyOutboundTransaction = optInt("verifyOutboundTransaction")
                        val verifyAssets = optInt("verifyAssets")


                        var dialog:CpTDialog? = null
                        dialog = NewDialogUtils.showConfirmAccountDestroyDialog(
                            this@AccountDestroyActivity,
                            bindListener = OnCpBindViewListener {
                                val tvCd1 = it.getView<TextView>(R.id.tv_condition1)
                                val tvCd2 = it.getView<TextView>(R.id.tv_condition2)
                                val tvCd3 = it.getView<TextView>(R.id.tv_condition3)
                                val tvCd4 = it.getView<TextView>(R.id.tv_condition4)
                                val tvCd5 = it.getView<TextView>(R.id.tv_condition5)
                                val cubConfirm = it.getView<CommonlyUsedButton>(R.id.cub_confirm)
                                val isContractOpen = PublicInfoDataService.getInstance().contractOpen(null)
                                val isOTCOpen = PublicInfoDataService.getInstance().otcOpen(null)
                                val isLevelOpen = PublicInfoDataService.getInstance().isLeverOpen(null)

                                it.setText(R.id.tv_title,LanguageUtil.getString(this@AccountDestroyActivity,"account_destory_text7"))
                                it.setText(R.id.cub_cancel,LanguageUtil.getString(this@AccountDestroyActivity,"cancel"))
                                tvCd1.text = LanguageUtil.getString(this@AccountDestroyActivity,"account_destory_text8")
                                tvCd2.text = LanguageUtil.getString(this@AccountDestroyActivity,"account_destory_text9")
                                tvCd2.visibility = if(isLevelOpen) View.VISIBLE else View.GONE
                                tvCd3.text = LanguageUtil.getString(this@AccountDestroyActivity,"account_destory_text10")
                                tvCd3.visibility = if(isContractOpen) View.VISIBLE else View.GONE
                                tvCd4.text = LanguageUtil.getString(this@AccountDestroyActivity,"account_destory_text11")
                                tvCd4.visibility = if(isOTCOpen) View.VISIBLE else View.GONE
                                tvCd5.text = LanguageUtil.getString(this@AccountDestroyActivity,"account_destory_text12")
                                cubConfirm.setContent(LanguageUtil.getString(this@AccountDestroyActivity,"account_destory_text1"))
                                cubConfirm.isEnable(false)


                                tvCd1.isSelected = verifyGeneralOrder == 1
                                tvCd2.isSelected = if(isLevelOpen) verifyLeverOrder == 1 else true
                                tvCd3.isSelected = if(isContractOpen) verifyContract == 1 else true
                                tvCd4.isSelected = if(isOTCOpen) verifyOutboundTransaction == 1 else true
                                tvCd5.isSelected = verifyAssets == 1
                                val isOk = tvCd1.isSelected && tvCd2.isSelected && tvCd3.isSelected && tvCd4.isSelected && tvCd5.isSelected
                                cubConfirm.isEnable(isOk)

                                it.setText(
                                    R.id.tv_title,
                                    if(!isOk){
                                        //Not satisfied
                                        LanguageUtil.getString(this@AccountDestroyActivity,"account_destory_text7")
                                    }else{
                                        //Satisfied
                                        LanguageUtil.getString(this@AccountDestroyActivity,"account_destory_text15")
                                    }
                                )


                                //Dialog click to log out
                                cubConfirm.listener = object: CommonlyUsedButton.OnBottonListener{
                                    override fun bottonOnClick() {
                                        dialog?.dismiss()
                                        NewDialogUtils.showSecondDialog(
                                            this@AccountDestroyActivity,
                                            type = 0,
                                            cointype = AppConstant.ACCOUNT_DELETE_PHONE,
                                            cointype4Email = AppConstant.ACCOUNT_DELETE_EMAIL,
                                            loginPwdShow = false,
                                            confirmTitle = LanguageUtil.getString(this@AccountDestroyActivity, "common_text_btnConfirm"),
                                            listener = object :NewDialogUtils.DialogSecondListener{
                                                override fun returnCode(
                                                    phone: String?,
                                                    mail: String?,
                                                    googleCode: String?,
                                                    pwd: String?
                                                ) {
                                                    LogUtil.d(TAG,"phone:$phone,mail: $mail,googleCode: $googleCode,pwd: $pwd")
                                                    //Received GA result and called cancellation method to start cancellation
                                                    doDestroyAccount(googleCode,phone,mail,dialog)
                                                }
                                            }
                                        )


                                    }
                                }
                            }
                        )


                    }
                }
            })
        )




    }

    //Logout operation
    private fun doDestroyAccount(gaCode:String?, smsAuthCode:String?, emailAuthCode:String?,dialog:CpTDialog?) {
        addDisposable(
            getMainModel().destroyAccount(
                googleCode = gaCode?:"",
                smsAuthCode = smsAuthCode?:"",
                emailAuthCode = emailAuthCode?:"",
                consumer = object: NDisposableObserver(this,true) {
                    override fun onResponseSuccess(jsonObject: JSONObject) {
                        LogUtil.d(TAG, "void doDestroyAccount>>>$jsonObject")
                        dialog?.dismiss()
                        //Logout successfully cleared login status
                        clearLoginStatus()
                    }
                }
            )
        )

    }

    //Clear login status
    private fun clearLoginStatus() {
        EventBusUtil.post(MessageEvent(MessageEvent.destroy_account_event,this))
        UserDataService.getInstance().clearToken()
        UserDataService.getInstance().saveQuickToken("")
        LoginManager.postValue(false)
        ToastUtils.showToast(getLineText("account_destory_text14"))
        ArouterUtil.greenChannel(RoutePath.NewVersionLoginActivity,null)
        finish()
    }

    override fun onMessageEvent(event: MessageEvent) {
        super.onMessageEvent(event)
        when(event.msg_type){
            MessageEvent.destroy_account_event -> {
                if(null==event.msg_content){
                    finish()
                }
            }
        }
    }

    //Set List Data
    private fun setExplainList() {
        val dataSource = arrayListOf<String>()
        val stringData = getLineText("account_destory_text4")
        val splitDatas = stringData.replace("\n","\\n").split("\\n")
        for (item in splitDatas){
            if(item.isNotEmpty()){
                dataSource.add(item.trim().replace("·","・"))
            }
        }
        for(i in dataSource.indices) {
            val layoutRes = LayoutInflater.from(this).inflate(R.layout.item_layout_destroy_explain,ll_content_list,false)
            val tvView = layoutRes.findViewById<TextView>(R.id.itemView)
            tvView.text = dataSource[i]
            val layoutParams = layoutRes.layoutParams as LinearLayout.LayoutParams
            if(i == dataSource.size-1){
                layoutParams.bottomMargin = 0
                layoutRes.layoutParams = layoutParams
            }else{
                layoutParams.bottomMargin = SizeUtils.dp2px(8f)
                layoutRes.layoutParams = layoutParams
            }

            ll_content_list.addView(layoutRes)
        }
    }
}
