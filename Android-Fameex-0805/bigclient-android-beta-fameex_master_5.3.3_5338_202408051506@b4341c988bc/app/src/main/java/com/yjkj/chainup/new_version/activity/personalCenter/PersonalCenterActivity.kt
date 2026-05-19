package com.yjkj.chainup.new_version.activity.personalCenter

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.text.TextUtils
import android.view.View
import androidx.core.content.ContextCompat
import com.alibaba.android.arouter.facade.annotation.Route
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseActivity
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.constant.WebTypeEnum
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.LoginManager
import com.yjkj.chainup.net.HttpClient
import com.yjkj.chainup.net.api.ApiConstants
import com.yjkj.chainup.net.retrofit.NetObserver
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_version.activity.BlackListActivity
import com.yjkj.chainup.new_version.activity.NewMainActivity
import com.yjkj.chainup.new_version.activity.RewardCenterActivity
import com.yjkj.chainup.new_version.bean.CmsAppDataPcBanner
import com.yjkj.chainup.new_version.bean.PcBannerBean
import com.yjkj.chainup.new_version.bean.ReadMessageCountBean
import com.yjkj.chainup.new_version.bean.SwitchVoBean
import com.yjkj.chainup.new_version.home.adapter.ImageNetAdapter
import com.yjkj.chainup.new_version.view.PersonalCenterViewTx2
import com.yjkj.chainup.util.*
import com.youth.banner.config.IndicatorConfig
import com.youth.banner.indicator.RectangleIndicator
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.activity_personal_center.*
import kotlinx.android.synthetic.main.activity_personal_center.aiv_change_newwork
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode
import org.json.JSONObject
import zendesk.android.Zendesk

/**
 * @Author lianshangljl
 * @Date 2023/3/27-11:18 AM
 * @Email buptjinlong@163.com
 *@description Personal Center Page
 */

@Route(path = RoutePath.PersonalCenterActivity)
class PersonalCenterActivity : NBaseActivity() {
    override fun setContentView(): Int {
        return R.layout.activity_personal_center
    }
        var feeTradeStatus:String? = "0"
        var mTradeCoin="0"
        var mTrade="0"
    var bannerImgUrls = arrayListOf<String>()
    override fun initView() {
        setOnClick()

        if (!TextUtils.isEmpty(PublicInfoDataService.getInstance().getOnlineService(null))) {
            aiv_service?.visibility = View.VISIBLE
        }
        val mOnlineServiceConfig= PublicInfoDataService.getInstance().getOnlineServiceConfig(null)
        if (mOnlineServiceConfig.equals("1")){
            aiv_service?.visibility = View.VISIBLE
        }

        if (PublicInfoDataService.getInstance().otcOpen(null)) {
            aiv_mine_black_list?.visibility = View.VISIBLE
        } else {
            aiv_mine_black_list?.visibility = View.GONE
        }
        if (ApiConstants.isSaasNetwork()) {
            aiv_change_newwork?.visibility = View.VISIBLE
        } else {
            aiv_change_newwork?.visibility = View.GONE
        }

    }

    override fun onInit(savedInstanceState: Bundle?) {
        super.onInit(savedInstanceState)
        windowTransitionLeftInRightOut()
        window.navigationBarColor = ContextCompat.getColor(this,R.color.bg_card_color)
        initView()
        aiv_level_rate?.setTitle(LanguageUtil.getString(this, "personal_Center_text3"))
        aiv_invite_friends_enter?.setTitle(LanguageUtil.getString(this, "common_action_inviteFriend"))
        aiv_mail?.setTitle(LanguageUtil.getString(this, "personal_text_message"))
        aiv_announcement?.setTitle(LanguageUtil.getString(this, "personal_text_notice"))
        aiv_service?.setTitle(LanguageUtil.getString(this, "personal_text_onlineservice"))
        aiv_help_center?.setTitle(LanguageUtil.getString(this, "personal_text_helpcenter"))
        aiv_safe_enter?.setTitle(LanguageUtil.getString(this, "personal_text_safetycenter"))
        aiv_setting?.setTitle(LanguageUtil.getString(this, "personal_text_setting"))
        aiv_mine_black_list?.setTitle(LanguageUtil.getString(this, "personal_text_blacklist"))
        aiv_about_us?.setTitle(LanguageUtil.getString(this, "personal_text_aboutus"))
        aiv_rewardCenter?.setTitle(LanguageUtil.getString(this,"menus_rewardCenter"))
        aiv_level_rate_my?.setTitle(LanguageUtil.getString(this,"personal_center_FeeRate"))
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setBgCardBar()
    }


    override fun onResume() {
        super.onResume()
        val isLogined = UserDataService.getInstance().isLogined
        //Set Layout Display and Hide
        newHeaderPersonal?.setIsLogin(isLogined)
        //Personal center banner acquisition
        getPersonalBanner()
        //Obtain user information and set user information display
        getDealerInfo()


        getRewardCenterConf()
        aiv_mail?.showMailRed(false)
        if (isLogined) {
            getKycLevel()
            getMessageCount()
        }

    }

    private fun getKycLevel() {
        addDisposable(getMainModel().getMaxLevel(consumer = object :NDisposableObserver(){
            override fun onResponseSuccess(jsonObject: JSONObject) {
                val data = jsonObject.optJSONObject("data")
                data?.let {
                    val showName = it.optString("showName")
                    val isPass = it.optBoolean("isPass")
                    newHeaderPersonal?.setCertificationTx(showName,isPass)
                }
            }

        }))
    }

    private fun getRewardCenterConf(){
        addDisposable(getMainModel().getRewardCenterInfo(consumer = object :NDisposableObserver(){
            override fun onResponseSuccess(jsonObject: JSONObject) {
                val dataObj = jsonObject.optJSONObject("data")
                val confSwitch = dataObj?.optInt("confSwitch")?:0
                if(0==confSwitch){
                    aiv_rewardCenter.visibility = View.GONE
                }else{
                    aiv_rewardCenter.visibility = View.VISIBLE
                }
            }

        }))

        if(UserDataService.getInstance().isLogined){
            addDisposable(getMainModel().getTaskCompleteCount(consumer = object :NDisposableObserver(){
                override fun onResponseSuccess(jsonObject: JSONObject) {
                    val dataObj = jsonObject.optJSONObject("data")
                    val count = dataObj?.optString("count")?:"0"
                    if("0".equals(count)){
                        aiv_rewardCenter.showMailRed(false,R.drawable.person_red_dot)
                    }else{
                        aiv_rewardCenter.showMailRed(true,R.drawable.person_red_dot)
                    }
                }

            }))

        }

    }

    fun initView(t: JSONObject?) {
        if (t == null) return
        newHeaderPersonal?.setUserInfo(t)
    }

    fun setOnClick() {

        /**
         *Grade rate
         */
        aiv_level_rate?.setOnClickListener {
            if (!LoginManager.checkLogin(this, true)) {
                return@setOnClickListener
            }
          val mIntent=  Intent(this, RateDiscountActivity::class.java)
            mIntent.putExtra("fee_trade_status",feeTradeStatus)
            mIntent.putExtra("mTradeCoin",mTradeCoin)
            mIntent.putExtra("mTrade",mTrade)
            startActivity(mIntent)
////Display H5 interface
//            ArouterUtil.greenChannel(RoutePath.ItemDetailActivity, Bundle().apply {
//                putInt(ParamConstant.web_type, WebTypeEnum.ROLE_INDEX.value)
//            })
        }

        /**
         *Security Center
         */
        aiv_safe_enter?.setOnClickListener {
            if (!LoginManager.checkLogin(this, true)) {
                return@setOnClickListener
            }
            startActivity(Intent(this, SafetySettingActivity::class.java))
        }

        /**
         * Reward center
         * */
        aiv_rewardCenter?.setOnClickListener {
            RewardCenterActivity.enterActivity(this)
        }

        /**
         *Invite friends
         */
        aiv_invite_friends_enter?.setOnClickListener {
            if (!LoginManager.checkLogin(this, true)) {
                return@setOnClickListener
            }
            ArouterUtil.navigation(RoutePath.ContractAgentActivity, null)
//            ArouterUtil.navigation(RoutePath.InvitFirendsActivity, null)
        }

        /**
         *Settings
         */
        aiv_setting?.setOnClickListener {
            NewSettingActivity.enter2(this)
        }

        /**
         *Click on FreeStaking to jump to\
         */
        aiv_freeStaking.setOnClickListener {
            ArouterUtil.greenChannel(RoutePath.FreeStakingActivity, null)
        }

        /**
         *Station message
         */
        aiv_mail?.setOnClickListener {
            if (LoginManager.checkLogin(this, true)) {
                startActivity(Intent(this, MailActivity::class.java))
            }
        }
        /**
         *Help Center
         */
        aiv_help_center?.setOnClickListener {
            startActivity(Intent(this, HelpCenterActivity::class.java))

        }
        /**
         *About us
         */
        aiv_about_us?.setOnClickListener {
            startActivity(Intent(this, AboutActivity::class.java))
        }
        /**
         *Block List
         */
        aiv_mine_black_list?.setOnClickListener {
            if (!LoginManager.checkLogin(this, true)) {
                return@setOnClickListener
            }
            BlackListActivity.enter2(this)
        }

        /**
         *Human Services
         */
        aiv_service?.setOnClickListener {
            //ItemDetailActivity.enter2（ this@PersonalCenterActivity , PublicInfoDataService. getInstance(). getOnlineService (null), "Online Customer Service", true, true)
//            val intent = Intent()
//            intent.setClass(this, UdeskWebViewActivity::class.java)
//            intent.putExtra(ParamConstant.URL_4_SERVICE, PublicInfoDataService.getInstance().getOnlineService(null))
//            startActivity(intent)
//            RequestActivity.builder()
//                    .show(this);
//            val mChatConfiguration=ChatConfiguration.builder()
//                    .build()
//            MessagingActivity.builder()
//                    .withEngines(ChatEngine.engine())
//                    .show(this,mChatConfiguration )

           val mOnlineServiceConfig= PublicInfoDataService.getInstance().getOnlineServiceConfig(null)
            if (mOnlineServiceConfig.equals("1")){
                ZenDeskUtils.showMessaging(this)
            }else{
                val intent = Intent()
                intent.setClass(this, UdeskWebViewActivity::class.java)
                intent.putExtra(ParamConstant.URL_4_SERVICE, PublicInfoDataService.getInstance().getOnlineService(null))
                startActivity(intent)
            }
        }

        /**
         *Announcement
         */
        aiv_announcement?.setOnClickListener {
            startActivity(Intent(this@PersonalCenterActivity, NoticeActivity::class.java))
        }
        /**
         *Switch network
         */
        aiv_change_newwork?.setOnClickListener {
            ArouterUtil.navigation(RoutePath.ChangenNetworkActivity, null)
        }

        aiv_level_rate_my?.setOnClickListener {
            if (!LoginManager.checkLogin(this, true)) {
                return@setOnClickListener
            }
            ArouterUtil.greenChannel(RoutePath.ItemDetailActivity, Bundle().apply {
                putString(ParamConstant.head_title, "")
                putString(ParamConstant.web_url, PublicInfoDataService.getInstance().membershipUrl(null))
                putInt(ParamConstant.web_type, WebTypeEnum.NORMAL_INDEX.value)
            })
        }



        //New version header click event callback
        newHeaderPersonal.listener = object:PersonalCenterViewTx2.OnViewClick{
            override fun themeModeChange() {
                setBarColor(PublicInfoDataService.getInstance().themeMode)
//                reStart(this@PersonalCenterActivity)
                LocalManageUtil.saveSelectLanguage(mActivity, LanguageUtil.getSelectLanguage())
//                finish()
            }
        }

    }
    fun reStart(context: Context) {
        val intent = Intent(context, NewMainActivity::class.java)
        intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TASK or Intent.FLAG_ACTIVITY_NEW_TASK
        context.startActivity(intent)
        HttpClient.instance.refresh()
        PublicInfoDataService.getInstance().saveData(JSONObject())
    }

    /**
     *Obtain user information
     */

    private fun getDealerInfo() {
        if (UserDataService.getInstance().isLogined) {
            addDisposable(getMainModel().getUserInfo(object : NDisposableObserver() {
                override fun onResponseSuccess(jsonObject: JSONObject) {
                    val json = jsonObject.optJSONObject("data")
                    initView(json)
//                    setOnClick()
                    UserDataService.getInstance().saveData(json)
                }

            }))
        } else {
            newHeaderPersonal?.setIsLogin(false)
        }

    }

    private fun getMessageCount() {
        HttpClient.instance.getReadMessageCount()
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<ReadMessageCountBean>() {
                    override fun onHandleSuccess(t: ReadMessageCountBean?) {
                        t ?: return
                        if (StringUtils.isNumeric(t.noReadMsgCount)) {
                            if (t.noReadMsgCount.toInt() > 0) {
                                aiv_mail?.showMailRed(true,R.drawable.person_red_dot)
                            } else {
                                aiv_mail?.showMailRed(false,R.drawable.person_red_dot)
                            }
                        }else{
                            aiv_mail?.showMailRed(false,R.drawable.person_red_dot)
                        }
                    }

                })
    }

    private fun getPersonalBanner() {
        HttpClient.instance.getPcBanner()
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<PcBannerBean>() {
                    override fun onHandleSuccess(t: PcBannerBean?) {
                        t ?: return
                        bannerImgUrls.clear()
                        for (buff in t.cmsAppDataListPcBanner){
                            bannerImgUrls.add(buff.imageUrl)
                        }
                        if (bannerImgUrls.size==0){
                            banner_looper.visibility=View.GONE
                        }else{
                            banner_looper.visibility=View.VISIBLE
                        }
                        banner_looper?.apply {
                            val mAdapter = ImageNetAdapter(bannerImgUrls)
                            adapter = mAdapter
                            mAdapter.setOnBannerListener { data, position ->
                                val cmsAppDataPcBanner = t.cmsAppDataListPcBanner[position]
                                val httpUrl = cmsAppDataPcBanner.httpUrl
                                val nativeUrl = cmsAppDataPcBanner.nativeUrl

                                if (TextUtils.isEmpty(httpUrl)) {
                                    if (StringUtil.checkStr(nativeUrl) && nativeUrl.contains("?")) {
//                                            enter2Activity(nativeUrl.split("?"))
                                    }
                                } else {
                                    forwardWeb(cmsAppDataPcBanner)
                                }
                            }

                            setLoopTime(3000)
                            indicator = RectangleIndicator(context)
                            setIndicatorGravity(IndicatorConfig.Direction.CENTER)
                        }
                        feeTradeStatus= t.fee_trade_status
                        mTradeCoin= t.coin
                        mTrade= t.rate
                        if(PublicInfoDataService.getInstance().rateMy(null)){
                            aiv_level_rate_my?.visibility = View.VISIBLE
                        } else {
                            aiv_level_rate_my?.visibility = View.GONE
                            aiv_level_rate.visibility=if (t.is_open == "1") View.VISIBLE else View.GONE
                            aiv_level_rate.setStatusText(String.format(LanguageUtil.getString(this@PersonalCenterActivity, "personal_Center_text4"),t.coin))
                        }

                    }

                    override fun onHandleError(msg: String?) {
                        super.onHandleError(msg)
                        ToastUtils.showToast(msg.toString())
                    }

                })
    }

    private fun forwardWeb(jsonObject: CmsAppDataPcBanner?) {
        jsonObject?.let {
            var id = it.id.toString()
            var title = it.title
            var httpUrl = it.httpUrl

            var bundle = Bundle()
            bundle.putString(ParamConstant.head_title, title)
            if (StringUtil.isHttpUrl(httpUrl)) {
                bundle.putString(ParamConstant.web_url, httpUrl)
            } else {
                bundle.putString(ParamConstant.web_url, id)
                bundle.putInt(ParamConstant.web_type, WebTypeEnum.Notice.value)
            }
            ArouterUtil.greenChannel(RoutePath.ItemDetailActivity, bundle)
        }

    }



    @Subscribe(threadMode = ThreadMode.MAIN)
    override fun onMessageEvent(event: MessageEvent) {
        super.onMessageEvent(event)
        if (event.msg_type == MessageEvent.finish_page_event) {
            finish()
        }
    }

}
