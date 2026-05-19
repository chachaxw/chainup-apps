package com.yjkj.chainup.new_version.activity.personalCenter

import android.Manifest
import android.accounts.NetworkErrorException
import android.app.Activity
import android.graphics.Bitmap
import android.graphics.drawable.BitmapDrawable
import android.os.Build
import android.os.Bundle
import android.text.InputFilter
import android.text.TextUtils
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.ViewManager
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.RelativeLayout
import androidx.core.content.ContextCompat
import com.alibaba.android.arouter.facade.annotation.Route
import com.blankj.utilcode.util.GsonUtils
import com.bumptech.glide.request.RequestOptions
import com.chainup.contract.utils.CpBigDecimalUtils
import com.chainup.contract.utils.CpPermissionUtil
import com.chainup.contract.utils.getLineText
import com.tbruyelle.rxpermissions2.RxPermissions
 import com.chainup.contract.view.dialog.CpTDialog
import com.chainup.kit.KKDialogUtils
import com.chainup.kit.dialog.KKTDialog
import com.chainup.kit.utils.InputPatternFilter
import com.chainup.kit.utils.ToastUtils
import com.google.gson.Gson
import com.jaeger.library.StatusBarUtil
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseActivity
import com.yjkj.chainup.bean.AgentBean
import com.yjkj.chainup.bean.AgentInfoBean
import com.yjkj.chainup.bean.AgentUserBean
import com.yjkj.chainup.bean.CoAgentInfoBean
import com.yjkj.chainup.bean.ScaleInfoBean
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.freestaking.ITEM_ID
import com.yjkj.chainup.freestaking.PROJECT_TYPE
import com.yjkj.chainup.freestaking.bean.MyPosRecordBean
import com.yjkj.chainup.freestaking.bean.NotificationRefreshBean
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.LoginManager
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.net.HttpClient
import com.yjkj.chainup.net.retrofit.NetObserver
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_version.bean.InviteConfig
import com.yjkj.chainup.new_version.bean.MyInvitationsListBean
import com.yjkj.chainup.new_version.bean.SwitchVoBean
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.util.*
import com.yjkj.chainup.wedegit.DisplayUtils
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.activity_contract_agent.*
import kotlinx.android.synthetic.main.activity_personal_center.aiv_invite_friends_enter
import kotlinx.android.synthetic.main.activity_safety_setting.ctrl_white_list
//import kotlinx.android.synthetic.main.item_contract_agent_content.*
import kotlinx.android.synthetic.main.item_invitation_layout.*
import kotlinx.android.synthetic.main.item_invitation_registration_rewards.*
import org.greenrobot.eventbus.EventBus
import org.json.JSONObject
import rx.Observable
import java.math.BigDecimal
import java.text.DecimalFormat
import java.util.function.Consumer

/**
 * @Author lianshangljl
 * @Date 2023-05-04-20:53
 * @Email buptjinlong@163.com
 * @description
 */
@Route(path = RoutePath.ContractAgentActivity)
class ContractAgentActivity : NBaseActivity() {
    private var scaleInfoList = arrayListOf<ScaleInfoBean>()
    override fun setContentView() = R.layout.activity_contract_agent

    override fun onInit(savedInstanceState: Bundle?) {

        super.onInit(savedInstanceState)
        layoutView?.fitsSystemWindows = false
        StatusBarUtil.setTranslucentForImageView(this,0,rl_back_layout)
        initView()
        setOnClick()
        setContent()
        initRedPacketView()
    }

    /*
   *Initialize red envelope view
   */
    private fun initRedPacketView() {
        val isRedPacketOpen = PublicInfoDataService.getInstance().isRedPacketOpen(null)
        showRedPacket(isRedPacketOpen)
    }

    private fun showRedPacket(isVisibile: Boolean) {
        if (isVisibile) {
            rl_red_envelope_entranc_layout?.visibility = View.VISIBLE
        } else {
            rl_red_envelope_entranc_layout?.visibility = View.GONE
        }
    }


    /**
     *Handling multilingual issues
     */
    fun setContent() {
//        tv_right_title?.text = LanguageUtil.getString(this, "coAgent_text_explain")
        tv_setps1_content?.text = LanguageUtil.getString(this, "send_invitation")
        tv_setps2_content?.text = LanguageUtil.getString(this, "invitee_complete_registration_transaction")
        tv_setps3_content?.text = LanguageUtil.getString(this, "receive_corresponding_ratio_commission")


        tv_invitaion_link?.text = LanguageUtil.getString(this, "invitation_Link")
        tv_my_qr_code?.text = LanguageUtil.getString(this, "my_invitation_code")
        tv_invitaion_add_key?.text = LanguageUtil.getString(this, "add_invite_code")
        tv_add?.text = LanguageUtil.getString(this, "referral_superior_button")
        btn_generate_poster?.text = LanguageUtil.getString(this, "generate_invitation_poster")
        btn_face_to_face?.text = LanguageUtil.getString(this, "face_to_face_invitation")
        tv_registration_title?.text = LanguageUtil.getString(this, "referral_inviteRewards_")

        tv_contract_agent_rule_description?.text = LanguageUtil.getString(this, "rules_and_regulations")

        tv_invitation_registration_rule_description?.text = LanguageUtil.getString(this, "referral_inviteRewards_rules")

        tv_contract_agent_rule_description?.text = LanguageUtil.getString(this, "rules_and_regulations")

        tv_inviter?.text = LanguageUtil.getString(this, "referral_inviteRewards_number")
        tv_commission_ratio?.text = LanguageUtil.getString(this, "referral_inviteRewards_amount")

        tv_coAgent_text2?.text = LanguageUtil.getString(this, "RebateRate")
        tv_coAgent_text6?.text = LanguageUtil.getString(this, "MngTotalUser")
        tv_coAgent_text7?.text = LanguageUtil.getString(this, "coAgent_text7")
        tv_coAgent_text8?.text = LanguageUtil.getString(this, "coAgent_text8")
        tv_coAgent_text9?.text = LanguageUtil.getString(this, "coAgent_text9")
        tv_invitaion_add_key?.text = LanguageUtil.getString(this, "add_invite_code")
        tv_add?.text = LanguageUtil.getString(this, "payMethod_action_addnew")

        if(UserDataService.getInstance().ableToAddPid()){
            rl_invitaion_add.visibility=View.VISIBLE
        }else{
            rl_invitaion_add.visibility=View.GONE
        }

//        tv_registration_title_agent?.text = LanguageUtil.getString(this, "spot_trading_broker")
//        tv_inviter_agent?.text = LanguageUtil.getString(this, "number_people_invited")
//        tv_commission_ratio_agent?.text = LanguageUtil.getString(this, "ratio_commission")
//        tv_total_commission?.text = LanguageUtil.getString(this, "cumulative_rewards_amount") + "(USDT)"




//        tl_agent_return_layout?.setTitleContent(LanguageUtil.getString(this, "coAgent_text_return"))
//        tl_agent_childReturn_layout?.setTitleContent(LanguageUtil.getString(this, "coAgent_text_childReturn"))
//        tl_agent_childTotal_layout?.setTitleContent(LanguageUtil.getString(this, "coAgent_text_childTotal"))
//        tl_agent_childTotalUSDT_layout?.setTitleContent(LanguageUtil.getString(this, "coAgent_text_childTotalUSDT"))
//        tl_agent_yesterdayReturn_layout?.setTitleContent(LanguageUtil.getString(this, "coAgent_text_yesterdayReturn"))
//        tl_agent_byesterdayReturn_layout?.setTitleContent(LanguageUtil.getString(this, "coAgent_text_byesterdayReturn"))
//        tl_agent_child_layout?.setTitleContent(LanguageUtil.getString(this, "coAgent_text_level2return"))


    }

    var dialog:  CpTDialog? = null
    var mKKTDialog : KKTDialog? = null
    fun setOnClick() {
        /**
         *Return
         */
//        iv_back?.setOnClickListener { finish() }
//        /**
//         *Jump to instructions
//         *TODO needs to determine if the URL is correct
//         */
//        tv_right_title?.setOnClickListener {
//
//            var bundle = Bundle()
//
//            bundle.putString(ParamConstant.head_title, "")
//            bundle.putString(ParamConstant.web_url, PublicInfoDataService.getInstance().getAgentUrl(null))
//
//            ArouterUtil.greenChannel(RoutePath.ItemDetailActivity, bundle)
//        }


        /**
         *Click on the red envelope to jump to
         */
        rl_red_envelope_entrance?.setOnClickListener {
            if (!LoginManager.checkLogin(this, true)) {
                return@setOnClickListener
            }

            var isEnforceGoogleAuth = PublicInfoDataService.getInstance().isEnforceGoogleAuth(null)

            var authLevel = UserDataService.getInstance().authLevel
            var googleStatus = UserDataService.getInstance().googleStatus
            var isOpenMobileCheck = UserDataService.getInstance().isOpenMobileCheck

            if (isEnforceGoogleAuth) {
                if (authLevel != 1 || googleStatus != 1) {
                    NewDialogUtils.redPackageCondition(this ?: return@setOnClickListener)
                    return@setOnClickListener
                }
            } else {
                if (authLevel != 1 || (googleStatus != 1 && isOpenMobileCheck != 1)) {
                    NewDialogUtils.redPackageCondition(this ?: return@setOnClickListener)
                    return@setOnClickListener
                }
            }
            ArouterUtil.navigation(RoutePath.CreateRedPackageActivity, null)
        }

        item_invitation_registration_rewards.visibility=View.GONE

//        item_contract_agent_content.visibility = View.GONE
        /**
         *Click to close the red envelope
         */
        iv_close_red_envelope?.setOnClickListener {
            showRedPacket(false)
        }

        /**
         *Face to face invitation
         */
        btn_face_to_face?.setOnClickListener {
            NewDialogUtils.showFaceToFace(this, faceToFaceImg)
        }

        /**
         *Invitation Registration Page
         */
        item_invitation_registration_rewards?.setOnClickListener {
            ArouterUtil.navigation(RoutePath.InvitationRewardActivity, null)
        }
        /**
         *Click on the reward
         */
        ll_commission_ratio_reward_layout?.setOnClickListener {
            ArouterUtil.navigation(RoutePath.InvitationRewardActivity, Bundle().apply {
                putString(ParamConstant.TYPE, ParamConstant.INVITE_REWARDS)
            })
        }

        /**
         *Generate invitation poster
         */
        btn_generate_poster?.setOnClickListener {
            var list: ArrayList<String> = arrayListOf()
            if (TextUtils.isEmpty(posterOneImg)) {
                list.add("url1")
            } else {
                list.add(posterOneImg)
            }
            if (TextUtils.isEmpty(posterTwoImg)) {
                list.add("url2")
            } else {
                list.add(posterTwoImg)
            }
            dialog = NewDialogUtils.showInvitationPosters(this, list, object : NewDialogUtils.DialogSharePostersListener {
                override fun saveIamgePosters(imageUrl: String, shareView: ImageView) {
                    createShareView(shareView)
                    dialog?.dismiss()
                }

                override fun saveIamgePostersNew(imageUrl: String) {

                }
            })
        }

        tv_direct_commission.setOnClickListener {
            NewDialogUtils.showAgentRebateRatioDialog(this,scaleInfoList)
        }

        /**
         *Spot broker
         */
//        ll_spot_agent_rule_description_layout?.setOnClickListener {
//            goWebview(exchangeBrokerRuleUrl)
//        }
        /**
         *Invitation to register
         */
        ll_invitation_registration_rule_description_layout?.setOnClickListener {
            goWebview(invitationRuleUrl)
        }
        /**
         *Contract Broker
         */
//        ll_contract_agent_rule_description?.setOnClickListener {
//            goWebview(coBrokerRuleUrl)
//        }

        /**
         *Number of Invitations
         */
//        ll_inviter_layout?.setOnClickListener {
//            if (!agent_data_query_url.contains("http")) {
//                agent_data_query_url = "http://$agent_data_query_url"
//            }
//            goWebview(agent_data_query_url)
//
//        }

        /**
         *Accumulated commission
         */
//        ll_commission_layout?.setOnClickListener {
//            if (!agent_account_query_url.contains("http")) {
//                agent_account_query_url = "http://$agent_account_query_url"
//            }
//            goWebview(agent_account_query_url)
//        }


        tv_add.setOnClickListener {
            mKKTDialog= KKDialogUtils.showInputBottomDialog(this,"add_invite_code".tr(this),"cancel".tr(this),"confirm".tr(this),"referral_superior_pop_text".tr(this),object :
                KKDialogUtils.DialogDoubleBottomStrListener{
                override fun sendCancel(data: String) {

                }

                override fun sendConfirm(data: String) {
                    addInvitationedCode(data)
                }
            }  , filters = arrayOf(InputPatternFilter("[a-zA-Z0-9]",false), InputFilter.LengthFilter(10)))
        }
    }

    fun createShareView(shareView: ImageView) {
        var bitmap = (shareView.drawable as BitmapDrawable).bitmap
        sv_view.setShareView(bitmap)
        saveImage(sv_view)
    }


    fun goWebview(httpUrl: String) {
        if (!StringUtil.checkStr(httpUrl)) {
            return
        }
        var bundle = Bundle()
        bundle.putString(ParamConstant.head_title, "")
        bundle.putString(ParamConstant.web_url, httpUrl)
        ArouterUtil.greenChannel(RoutePath.ItemDetailActivity, bundle)
    }

    override fun initView() {
        super.initView()

        /**
         *Does the spot broker display
         */
//        if (PublicInfoDataService.getInstance().getAgentUserOpen(null) && UserDataService.getInstance().agentStatus != 0) {
//            getAccountBalanceV4()
//            view_contract_line_3?.visibility = View.VISIBLE
//            item_spot_agent?.visibility = View.VISIBLE
//        } else {
//            item_spot_agent?.visibility = View.GONE
//            view_contract_line_3?.visibility = View.GONE
//        }
        item_spot_agent?.visibility = View.GONE
        initInvitView()
        getPageConfig()
        getInvitationPublicConfig()
        if (SystemUtils.isZh()) {
            rl_red_envelope_entrance.setImageResource(R.drawable.redenvelope)
        } else {
            rl_red_envelope_entrance.setImageResource(R.drawable.redenvelope_english)
        }
//        mDataList= ArrayList();
//        mBuffAdapter = BuffAdapter(R.layout.item_my_invitation_list, mDataList)
//        rv_invitation_reward_detail.apply {
//            layoutManager = LinearLayoutManager(this@ContractAgentActivity)
//            adapter = mBuffAdapter
//        }
        if (SystemUtils.isZh()) {
            var options = RequestOptions().placeholder(R.mipmap.banner_cn).error(R.mipmap.banner_cn)

            GlideUtils.load(this@ContractAgentActivity, headerIndexImg, iv_bg_image, options)
        } else {
            var options = RequestOptions().placeholder(R.mipmap.banner_en).error(R.mipmap.banner_en)

            GlideUtils.load(this@ContractAgentActivity, headerIndexImg, iv_bg_image, options)
        }
        HttpClient.instance.getInviteConfig()
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<AgentBean>() {
                    override fun onHandleSuccess(t: AgentBean?) {
                        if (!TextUtils.isEmpty(t?.bannerUrl)) {
                            GlideUtils.loadImage(this@ContractAgentActivity,t?.bannerUrl,iv_bg_image)
                        }

                        ll_contract_agent_rule_description_layout.visibility = if (TextUtils.isEmpty(t?.coAgentDesc)) View.GONE else View.VISIBLE
                        tv_contract_agent_rule_description.setOnClickListener {
                            if (!TextUtils.isEmpty(t?.coAgentDesc)) {
                                var bundle = Bundle()
                                bundle.putString(ParamConstant.head_title, "")
                                bundle.putString(ParamConstant.web_url, t?.coAgentDesc)
                                ArouterUtil.greenChannel(RoutePath.ItemDetailActivity, bundle)
                            }
                        }
                        posterOneImg=t?.billOneUrl.toString()
                        posterTwoImg=t?.billTwoUrl.toString()
                        faceToFaceImg=t?.faceToFaceUrl.toString()
                    }

                    override fun onHandleError(code: Int, msg: String?) {
                        super.onHandleError(code, msg)
                        DisplayUtil.showSnackBar(window?.decorView, msg, false)
                    }

                })
        if (PublicInfoDataService.getInstance().isCoAgent()){
            addDisposable(
                HttpClient.instance.getAgentUser()
                    .subscribeOn(Schedulers.io())
                    .observeOn(AndroidSchedulers.mainThread())
                    .map {
                        if(it.isSuccess){
                            val t = it.data
                            if (TextUtils.isEmpty(t?.status)){
                                ll_contract_agent.visibility = View.GONE
                                -1
                            }else{
                                ll_contract_agent.visibility=View.VISIBLE
                                1
                            }
                        }else{
                            ToastUtils.showToast(this,it.msg)
                            -1
                        }
                    }
                    .filter {
                        return@filter it != -1
                    }
                    .observeOn(Schedulers.io())
                    .flatMap {
                        
                        return@flatMap HttpClient.instance.getCoAgentInfo()
                    }
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe({
                        if(it.isSuccess){
                            agentCallback(it.data)
                        }else{
                            ToastUtils.showToast(this,it.msg)
                        }
                    },{
                        it.printStackTrace()
                        ToastUtils.showToast(this,it.message)
                    })
            )

        }else{
            ll_contract_agent.visibility=View.GONE
        }
        mHeaderKit.setLeftImg(R.drawable.special_return)
        commonSwitch()
    }

    fun agentCallback(t:CoAgentInfoBean?){
        t?.run {
            scaleInfoList.clear()
            if(scaleInfo.size>0){
                scaleInfoList.addAll(scaleInfo)
            }

            val roleType = t.roleType

            tv_direct_commission.setCompoundDrawables(null,null,if(roleType==1){
                null
            }else{
                val source = ContextCompat.getDrawable(this@ContractAgentActivity,R.drawable.assets_prompt)
                source?.setBounds(DisplayUtils.dip2px(this@ContractAgentActivity,8.0f),0,DisplayUtils.dip2px(this@ContractAgentActivity,10.0f) + DisplayUtils.dip2px(this@ContractAgentActivity,8.0f),DisplayUtils.dip2px(this@ContractAgentActivity,10.0f))
                source
            },null)

            if(roleType==1){
                tv_direct_commission.isEnabled = false
                tv_direct_commission.text = t.scaleInfo[0].scale.toPercent()
            }else{
                tv_direct_commission.isEnabled = true
                val newInfo = t.scaleInfo.sortedByDescending {
                    it.scale
                }
                if(newInfo.isNotEmpty()){
                    val minRate = newInfo[newInfo.size-1].scale
                    val maxRate = newInfo[0].scale
                    if(minRate == maxRate || newInfo.size<=1){
//                    tv_direct_commission.isEnabled = false
//                    tv_direct_commission.setCompoundDrawables(null,null,null,null)
                        tv_direct_commission.text = minRate.toPercent()
                    }else{
                        tv_direct_commission.text = "${minRate.toPercent()} ~ ${maxRate.toPercent()}"
                    }
                }
            }
            val precision = NCoinManager.getCoinShowPrecision("USDT")

            tv_customers_number.setText(t.countAgent)
            tv_accumulated_commission.setText(BigDecimalUtils.showSNormal(t.amountTotal,precision))
            tv_yesterday_commission.setText(BigDecimalUtils.showSNormal(t.amountYesterday,precision))
            tv_previousday_commission.setText(BigDecimalUtils.showSNormal(t.amountBYesterday,precision))
            tv_registration_title_agent.setText(t.roleName)
        }

    }

    fun initInvitView() {
        tv_content_1?.text = StringUtil.midleReplaceStar(UserDataService.getInstance().inviteUrl,12,8)
        tv_content_2?.text = UserDataService.getInstance().inviteCode
        /**
         *Copy invitation link
         */
        ll_copy_url_layout?.setOnClickListener {
            Utils.copyString(UserDataService.getInstance().inviteUrl)
            NToastUtil.showTopToastNet(this@ContractAgentActivity,true, LanguageUtil.getString(mActivity, "common_tip_copySuccess"))
        }
        /**
         *Copy invitation code
         */
        ll_copy_code_layout?.setOnClickListener {
            Utils.copyString(UserDataService.getInstance().inviteCode)
            NToastUtil.showTopToastNet(this@ContractAgentActivity,true, LanguageUtil.getString(mActivity, "common_tip_copySuccess"))
        }
    }

    fun initViewData() {
//        if (UserDataService.getInstance().isLogined) {
//            item_contract_agent_content?.visibility = View.GONE
//            getNoTokenPublic()
//        } else {
//            item_contract_agent_content?.visibility = View.GONE
//        }
    }

    override fun onResume() {
        super.onResume()
//        initViewData()
    }

    var coAgentStatus = "0"
    /**
     *Determine if it is a contract broker
     */
//    fun getNoTokenPublic() {
//        showLoadingDialog()
//        getMainModel().getNoTokenPublic(object : NDisposableObserver() {
//            override fun onResponseSuccess(jsonObject: JSONObject) {
//                closeLoadingDialog()
//                var data = jsonObject.optJSONObject("data") ?: return
//                coAgentStatus = data?.optString("coAgentStatus")
//                if (coAgentStatus != null && coAgentStatus == "1") {
//                    getAgentIndex()
//                }
//            }
//
//            override fun onResponseFailure(code: Int, msg: String?) {
//                super.onResponseFailure(code, msg)
//                closeLoadingDialog()
//                NToastUtil.showTopToastNet(this@ContractAgentActivity,false, msg)
////                item_contract_agent_content.visibility = View.GONE
//            }
//        })
//
//    }

//    fun getAgentIndex() {
//        /**
//         * TODO
//         *Need to determine if the interface path is correct
//         */
//        getMainModel().getAgentIndex(object : NDisposableObserver() {
//            override fun onResponseSuccess(jsonObject: JSONObject) {
//                var data = jsonObject.optJSONObject("data") ?: return
////                item_contract_agent_content?.visibility = View.VISIBLE
//                var role_name = data?.optString("role_name", "") ?: ""
//
//                tv_agent_title?.text = role_name
//
//                /**
//                 *Subordinate situation
//                 */
//                var childInfo = data?.optJSONObject("child_info")
//                /**
//                 *Number of customers
//                 */
//                tl_agent_childTotal_layout?.setContentText(childInfo?.optString("count_total", "")
//                        ?: "")
//
//                /**
//                 *Refund of commission situation
//                 */
//                var bonusInfo = data?.optJSONObject("bonus_info")
//                /**
//                 *Yesterday's commission converted into
//                 */
//                var  yesterday = bonusInfo?.optString("amount_yesterday", "") ?: ""
//                yesterday=BigDecimal(yesterday).stripTrailingZeros().toPlainString()
//                tl_agent_yesterdayReturn_layout?.setContentText(yesterday.totalNumToDigDown())
//                /**
//                 *Previous day's commission conversion
//                 */
//                var byesterday = bonusInfo?.optString("amount_b_yesterday", "")
//                        ?: ""
//                byesterday=BigDecimal(byesterday).stripTrailingZeros().toPlainString()
//                tl_agent_byesterdayReturn_layout?.setContentText(byesterday.totalNumToDigDown())
//
//                /**
//                 *Accumulated commission conversion
//                 */
//                var total = bonusInfo?.optString("amount_total", "")
//                        ?: ""
//                total=BigDecimal(total).stripTrailingZeros().toPlainString()
//                tl_agent_childTotalUSDT_layout?.setContentText(total.totalNumToDigDown())
//
//                /**
//                 *Share ratio
//                 */
//                var scaleInfo = data?.optJSONObject("scale_info")
//                /**
//                 *Direct push back commission
//                 */
//                var result = scaleInfo?.optString("scale_return", "")
//                        ?: ""
//                var scaleSecond = scaleInfo?.optString("scale_second", "")
//                        ?: ""
//                scaleSecond=BigDecimal(scaleSecond).stripTrailingZeros().toPlainString()
//                if (scaleSecond.isNotEmpty() && scaleSecond != "0") {
//                    tl_agent_child_layout.setContentText(scaleSecond.numToScalePer())
//                    tl_agent_child_layout.visibility = View.VISIBLE
//                } else {
//                    tl_agent_child_layout.visibility = View.INVISIBLE
//                }
//                tl_agent_return_layout?.setContentText(result.numToScalePer())
//                /**
//                 *Sub broker commission
//                 */
//                var sub = scaleInfo?.optString("scale_sub", "")
//                        ?: "0"
//                if (sub.isNotEmpty() && sub != "0") {
//                    tl_agent_childReturn_layout?.setContentText(sub.numToScalePer())
//                    tl_agent_childReturn_layout.visibility = View.VISIBLE
//                } else {
//                    tl_agent_childReturn_layout.visibility = View.INVISIBLE
//                }
//
//            }
//
//            override fun onResponseFailure(code: Int, msg: String?) {
//                super.onResponseFailure(code, msg)
////                item_contract_agent_content?.visibility = View.GONE
//                NToastUtil.showTopToastNet(this@ContractAgentActivity,false, msg)
//            }
//
//        })
//    }

    var agent_data_query_url = ""

    var agent_account_query_url = ""

    /**
     *Obtain spot brokers
     */
//    fun getAccountBalanceV4() {
//        addDisposable(getMainModel().getAgentDataQuery("USDT", object : NDisposableObserver() {
//            override fun onResponseSuccess(jsonObject: JSONObject) {
//                var data = jsonObject.optJSONObject("data") ?: return
//
//Var userCount=data OptString ("userCount", "0")?: 0//Total number of invitations
//
//Var oneLevelScale=data OptString ("oneLevelScale", "0")?: "0"//First level commission rebate ratio
//
//Var allBonusCoin=data OptString ("allBonusCoin", "USDT")?: USDT//Rebate currency
//
//Var allBonusAmount=data OptString ("allBonusAmount", "0")?: "0"//Accumulated commission rebate
//
//                agent_data_query_url = data?.optString("agent_data_query_url", "")
//?: //Return commission record URL
//                agent_account_query_url = data?.optString("agent_account_query_url", "")
//?: Position statistics URL
//
////                tv_inviter_content?.text = userCount
////
////                tv_commission_ratio_content?.text = "${BigDecimalUtils.divForDown(oneLevelScale, 2).toPlainString()}%"
////
////                tv_total_commission?.text = LanguageUtil.getString(this@ContractAgentActivity, "total_commission") + "(${allBonusCoin})"
////
////                tv_total_commission_content?.text = "${BigDecimalUtils.divForDown(allBonusAmount, NCoinManager.getCoinShowPrecision("USDT")).toPlainString()}"
//            }
//        }))
//    }

    var inviteQECode = ""


    /**
     *Contract Broker Rule Explanation Link
     */
    var coBrokerRuleUrl = ""
    /**
     *Spot Homo economicus rule description link
     */
    var exchangeBrokerRuleUrl = ""
    /**
     *Face to face sharing of base map address
     */
    var faceToFaceImg = ""
    /**
     *Share the banner base image address on the homepage
     */
    var headerIndexImg = ""
    /**
     *Invitation Registration Reward Rules Explanation
     */
    var invitationRuleUrl = ""
    /**
     *Poster 2 Image Address
     */
    var posterOneImg = ""
    /**
     *Poster 2 Image Address
     */
    var posterTwoImg = ""

    /**
     *Broker display page image link interface
     */
    fun getPageConfig() {
        addDisposable(getMainModel().getPageConfig(object : NDisposableObserver() {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                var data = jsonObject.optJSONObject("data")
                if (data == null) return
                tv_inviter_number_content?.text = data?.optString("invitationUserCount", "0") ?: "0"
                var invitationRewardUsdtSum = data?.optString("invitationRewardUsdtSum", "0")
                        ?: "0"
                tv_commission_ratio_reward?.text = BigDecimalUtils.divForDown(invitationRewardUsdtSum, NCoinManager.getCoinShowPrecision("USDT")).toPlainString()

                val pageConfig = data?.optJSONObject("pageConfig") ?: return
                coBrokerRuleUrl = pageConfig.optString("coBrokerRuleUrl")
                exchangeBrokerRuleUrl = pageConfig.optString("exchangeBrokerRuleUrl")
                faceToFaceImg = pageConfig.optString("faceToFaceImg")
                headerIndexImg = pageConfig.optString("headerIndexImg")
                invitationRuleUrl = pageConfig.optString("invitationRuleUrl")
                posterOneImg = pageConfig.optString("posterOneImg")
                posterTwoImg = pageConfig.optString("posterTwoImg")

                if (TextUtils.isEmpty(coBrokerRuleUrl)) {
                    ll_contract_agent_rule_description_layout?.visibility = View.GONE
                } else {
                    ll_contract_agent_rule_description_layout?.visibility = View.VISIBLE
                }
//
//                if (TextUtils.isEmpty(exchangeBrokerRuleUrl)) {
//                    ll_spot_agent_rule_description_layout?.visibility = View.GONE
//
//                } else {
//                    ll_spot_agent_rule_description_layout?.visibility = View.VISIBLE
//                }
                if (TextUtils.isEmpty(invitationRuleUrl)) {
                    ll_invitation_registration_rule_description_layout?.visibility = View.GONE

                } else {
                    ll_invitation_registration_rule_description_layout?.visibility = View.VISIBLE
                }



            }
        }))
    }


    fun saveImage(view: View) {
        val rxPermissions = RxPermissions(this)
        var bitmap: Bitmap? = null
        /**
         *Obtain read and write permissions
         */
        val observable = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            rxPermissions.request(Manifest.permission.READ_MEDIA_IMAGES)
        }else{
            rxPermissions.request(Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.READ_EXTERNAL_STORAGE)
        }
//        rxPermissions.request(android.Manifest.permission.WRITE_EXTERNAL_STORAGE)
        observable.subscribe { granted ->
                    if (granted) {
                        bitmap = ScreenShotUtil.createViewBitmap(view, ContextCompat.getColor(this, R.color.white))
                        if (bitmap != null) {
                            val saveImageToGallery = ImageTools.saveImageToGallery4ContractAgent(this, bitmap)
                            if (saveImageToGallery) {
                                DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this, "common_tip_saveImgSuccess"), true)
                            } else {
                                DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this, "common_tip_saveImgFail"), false)
                            }
                        } else {
                            DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this, "common_tip_saveImgFail"), false)
                        }
                    } else {
//                        DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this, "common_tip_saveImgFail"), false)
                        CpPermissionUtil.showOpenPermission(mActivity)
                    }
                }
    }

    private fun addInvitationedCode(invitedCode: String){
        HttpClient.instance.addInvitationedCode(invitedCode)
            .subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(object: NetObserver<Any>(){
                override fun onHandleSuccess(t: Any?) {
                    ToastUtils.showToast(this@ContractAgentActivity,"referral_superior_toast_succ".tr(this@ContractAgentActivity))
                    rl_invitaion_add.visibility=View.GONE
                    mKKTDialog?.dismiss()
                }

                override fun onHandleError(code: Int, msg: String?) {
                    ToastUtils.showToast(this@ContractAgentActivity,msg)
                }
            })
    }

    private fun getInvitationPublicConfig(){
        HttpClient.instance.getInvitationPublicConfig()
            .subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(object: NetObserver<InviteConfig>(){
                override fun onHandleSuccess(t: InviteConfig?) {
                    t?.apply {
                        var count=BigDecimal(this.inviteUserDirectCount)+BigDecimal(this.inviteUserSubOneCount)+BigDecimal(this.inviteUserSubTwoCount)
                        tv_inviter_number_content?.text = count.toPlainString()
                        var inviteRewardUsdtSumStr=if(this.inviteRewardUsdtSum==null) "0" else this.inviteRewardUsdtSum
                        inviteRewardUsdtSumStr=BigDecimal(inviteRewardUsdtSumStr).setScale(NCoinManager.getCoinShowPrecision("USDT"), BigDecimal.ROUND_DOWN).toPlainString()
                        tv_commission_ratio_reward?.text=inviteRewardUsdtSumStr
                        this.config?.apply {
                            if (SystemUtils.isZh()) {
                                var options = RequestOptions().placeholder(R.mipmap.banner_cn).error(R.mipmap.banner_cn)
                                GlideUtils.load(this@ContractAgentActivity, this.appBannerImg, iv_bg_image, options)
                            } else {
                                var options = RequestOptions().placeholder(R.mipmap.banner_en).error(R.mipmap.banner_en)
                                GlideUtils.load(this@ContractAgentActivity, this.appBannerImg, iv_bg_image, options)
                            }
                            this@ContractAgentActivity.posterOneImg=if(this.posterOneImg!=null) this.posterOneImg else ""
                            this@ContractAgentActivity.posterTwoImg=if(this.posterTwoImg!=null) this.posterTwoImg else ""
                            this@ContractAgentActivity.faceToFaceImg=if(this.faceToFaceImg!=null) this.faceToFaceImg else ""
                            this@ContractAgentActivity.invitationRuleUrl=if(this.invitationRuleUrl!=null) this.invitationRuleUrl else ""
                        }
                        if (TextUtils.isEmpty(invitationRuleUrl)) {
                            ll_invitation_registration_rule_description_layout?.visibility = View.GONE

                        } else {
                            ll_invitation_registration_rule_description_layout?.visibility = View.VISIBLE
                        }
                    }
                }

                override fun onHandleError(code: Int, msg: String?) {
                }
            })
    }

    fun commonSwitch() {
        HttpClient.instance.commonSwitch()
            .subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(object: NetObserver<SwitchVoBean>(){
                override fun onHandleSuccess(t: SwitchVoBean?) {
                    if(UserDataService.getInstance().ableToAddPid()){
                        rl_invitaion_add.visibility=View.VISIBLE
                        rl_invitaion_add.visibility=if(t?.switchVo?.invitationSwitch==1) View.VISIBLE else View.GONE
                    }else{
                        rl_invitaion_add.visibility=View.GONE
                    }
                    item_invitation_registration_rewards.visibility=if(t?.switchVo?.invitationSwitch==1) View.VISIBLE else View.GONE
                }

                override fun onHandleError(code: Int, msg: String?) {

                }
            })
    }
}
