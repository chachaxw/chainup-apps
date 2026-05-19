package com.yjkj.chainup.new_version.activity

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.provider.Settings
import android.text.SpannableString
import android.text.Spanned
import android.text.TextPaint
import android.text.TextUtils
import android.text.method.LinkMovementMethod
import android.text.style.ClickableSpan
import android.util.Log
import android.view.MotionEvent
import android.view.View
import android.view.inputmethod.InputMethodManager
import android.widget.EditText
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.lifecycle.lifecycleScope
import com.alibaba.android.arouter.facade.annotation.Route
import com.blankj.utilcode.util.EncodeUtils
import com.blankj.utilcode.util.LogUtils
import com.chainup.contract.app.CpCommonConstant
import com.chainup.contract.eventbus.CpMessageEvent
import com.chainup.contract.ui.fragment.CpContractNewTradeFragment
import com.chainup.contract.utils.ChainUpLogUtil
import com.chainup.contract.utils.CpClLogicContractSetting
import com.chainup.contract.utils.CpLocalManageUtil
import com.chainup.contract.utils.RateManager
import com.chainup.contract.ws.CpWsContractAgentManager
import com.didichuxing.doraemonkit.DoraemonKit
import com.igexin.sdk.PushManager
import com.jaeger.library.StatusBarUtil
import com.tbruyelle.rxpermissions2.RxPermissions
import com.tencent.mmkv.MMKV
import com.yjkj.chainup.BuildConfig
import com.yjkj.chainup.R
import com.yjkj.chainup.app.AppConstant
import com.yjkj.chainup.app.ChainUpApp
import com.yjkj.chainup.base.NBaseActivity
import com.yjkj.chainup.db.constant.HomeTabMap
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.db.service.RateDataService
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.extra_service.eventbus.EventBusUtil
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.extra_service.eventbus.NLiveDataUtil
import com.yjkj.chainup.extra_service.push.RouteApp
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.LoginManager
import com.yjkj.chainup.manager.NetworkLineService
import com.yjkj.chainup.net.HttpClient
import com.yjkj.chainup.net.api.ApiConstants
import com.yjkj.chainup.net_new.NetUrl
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_version.activity.asset.NewVersionMyAssetFragment
import com.yjkj.chainup.new_version.activity.leverage.TradeFragment
import com.yjkj.chainup.new_version.dialog.DialogUtil
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.fragment.MarketFragment
import com.yjkj.chainup.new_version.home.*
import com.yjkj.chainup.util.*
import com.yjkj.chainup.ws.WsAgentManager
import com.yjkj.chainup.ws.WsContractAgentManager
import io.reactivex.Observable
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.activity_new_main.*
import kotlinx.android.synthetic.main.check_visit_status.*
import kotlinx.android.synthetic.main.no_network_remind.*
import kotlinx.coroutines.*
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode
import org.java_websocket.util.Base64
import org.json.JSONObject
import java.util.concurrent.TimeUnit

//TODO optimization
@Route(path = RoutePath.NewMainActivity)
class NewMainActivity : NBaseActivity(), RateManager.IRateBridge,CpClLogicContractSetting.ICpUserDataBridge, CpWsContractAgentManager.WsResultCallback {

    override fun setContentView() = R.layout.activity_new_main

    /*
     *Bottom tab navigation index, default to homepage
     */
    var curPosition = 0
    var lastPosition = 0
    var connectCount = 0

    private var assetsTab = -1

    /**
     *Game Popup
     */
    var gameID = ""
    var gameName = ""
    var gameToken = ""
    var pushUrl = ""

    private lateinit var homePageFragment:NewVersionHomepageFragment
    private var japanHomepageFragment:NewVersionJapanHomepageFragment? = null
    private var homefristPageFragment:NewVersionHomepageFirstFragment? = null
    private lateinit var marketFragment: MarketFragment
    private lateinit var tradeFragment: TradeFragment
    private val contractFragment: CpContractNewTradeFragment by lazy { CpContractNewTradeFragment() }
    private lateinit var assetFragment: NewVersionMyAssetFragment

    private var fragmentManager: FragmentManager? = null
    var subscribe: Disposable? = null
    private var isNetworkChange:Boolean = false
    override fun onInit(savedInstanceState: Bundle?) {
        super.onInit(savedInstanceState)
        LocalManageUtil.setApplicationLanguage()
        CpLocalManageUtil.setApplicationLanguage()
        window.navigationBarColor = ContextCompat.getColor(this,R.color.tabbar_bg_color)
        fragmentManager = supportFragmentManager
        val intent = Intent(this, NetworkLineService::class.java)
        startService(intent)
        loadData()
        getIntentData()
        RouteApp.getInstance().execApp(pushUrl, this)
        RateManager.instance.setRateRateBridgeImpl(this)
        CpClLogicContractSetting.getInstance().setCpUserDataBridge(this)
        netChangeStatus()

//        RxPermissions(this).request(android.Manifest.permission.READ_PHONE_STATE).subscribe()

        loadContractOptional()
        DoraemonKit.disableUpload()
        DoraemonKit.install(application, "cb190f56cf")
        DoraemonKit.setAwaysShowMainIcon(false)
        DoraemonKit.setDebug(BuildConfig.DEBUG)
        DoraemonKit.show()
    }

    fun loadContractOptional(){
        if(!LoginManager.isLogin(this)) return
        if(!contractOpen) return
        addDisposable(getContractModel().getUserConfig("0",object :NDisposableObserver(){
            override fun onResponseSuccess(jsonObject: JSONObject) {
                Log.d("getUserConfigVis",jsonObject.toString())
                jsonObject.optJSONObject("data").run{
                    val isOpen = optInt("openContract")
                    if(isOpen == 1){
                        //The user has opened a contract to obtain a contract selection list
                        addDisposable(getContractModel().getOptionalList(
                            consumer = object : NDisposableObserver( true) {
                                override fun onResponseSuccess(jsonObject: JSONObject) {
                                    jsonObject.optString("data").run {
                                        if (TextUtils.isEmpty(this)){
                                            CpClLogicContractSetting.setContractJsonCollectListStr(this@NewMainActivity, "")
                                        }else{
                                            var contractIds= this.split(",")
                                            for (buff in contractIds){
                                                CpClLogicContractSetting.collectContractCoinTx(this@NewMainActivity, buff.toInt())
                                            }
                                        }
                                    }

                                }

                                override fun onResponseFailure(code: Int, msg: String?) {
                                    super.onResponseFailure(code, msg)
                                }
                            }))

                    }
                }
            }

            override fun onResponseFailure(code: Int, msg: String?) {
                super.onResponseFailure(code, msg)
            }
        }))
    }


    /*
    *Detect network status
    */
    fun netChangeStatus() {
        NetUtil.registerNetConnChangedReceiver(this)
        NetUtil.addNetConnChangedListener(object : NetUtil.Companion.NetConnChangedListener {
            override fun onNetConnChanged(connectStatus: NetUtil.Companion.ConnectStatus) {
                WsAgentManager.instance.changeNotice(connectStatus)
                Handler().postDelayed({
                    var net_event_fragment = MessageEvent(MessageEvent.net_status_change)
                    EventBusUtil.post(net_event_fragment)
                }, 1500)
                if(connectStatus != NetUtil.Companion.ConnectStatus.NO_NETWORK && connectStatus != NetUtil.Companion.ConnectStatus.NO_CONNECTED && isNetworkChange){
                    val chainupApplication = application as ChainUpApp
                    chainupApplication.startTime()
                    lifecycleScope.launchWhenResumed{
                        if(fragmentList.size<5) {
                            addDisposable(getMainModel().public_info_v4(object :NDisposableObserver(this@NewMainActivity){
                                override fun onResponseSuccess(jsonObject: JSONObject) {
                                    var data = jsonObject.optJSONObject("data")
                                    if (null != data && data.length() > 0) {
                                        var rate = data.optJSONObject("rate")
                                        RateDataService.getInstance().saveData(rate)
                                        // downloads lan file
                                        LanguageUtil.checkChangeDefaultLanguage()
                                    }
                                    PublicInfoDataService.getInstance().saveData(data)
                                    contractOpen = PublicInfoDataService.getInstance().contractOpen(data)
                                    if(contractOpen) initUIFragment()
                                }
                            }))
                        }
                    }
                    return
                }
                isNetworkChange = true
            }
        })


    }

    fun getIntentData() {
        /**
         *Game Popup
         */
        gameID = intent?.getStringExtra("gameId") ?: ""
        gameName = intent?.getStringExtra("gameName") ?: ""
        gameToken = intent?.getStringExtra("gameToken") ?: ""
        pushUrl = intent?.getStringExtra("pushUrl") ?: ""

        if (!TextUtils.isEmpty(gameID)) {
            if (LoginManager.checkLogin(this, true)) {
                DialogUtil.showAuthorizationDialog(this, gameID, gameName, gameToken)
            }
        }

        MMKV.defaultMMKV().putString("gameId", gameID)
    }


    private var fragmentList = arrayListOf<Fragment>()
    private var mImageViewList = ArrayList<Int>()
    var mTextviewList = ArrayList<String>()
    private var otcOpen = false
    private var contractOpen = false
    private fun initTabsData(data: JSONObject?) {
        fragmentList.clear()
        mImageViewList.clear()
        mTextviewList.clear()

        marketFragment = MarketFragment()
        tradeFragment = TradeFragment()
        assetFragment = NewVersionMyAssetFragment()

        otcOpen = PublicInfoDataService.getInstance().otcOpen(data)
        contractOpen = PublicInfoDataService.getInstance().contractOpen(data)
        val cid = PublicInfoDataService.getInstance().getCompanyId(data)
        WsAgentManager.instance.saveCID(cid)
        if(contractOpen) {
            with(CpWsContractAgentManager.instance) {
                saveCID(cid)
                addWsCallback(this@NewMainActivity)
            }
        }
        when (ApiConstants.HOME_VIEW_STATUS) {
            ParamConstant.DEFAULT_HOME_PAGE, ParamConstant.CONTRACT_HOME_PAGE -> {
                homePageFragment = NewVersionHomepageFragment()
                fragmentList.add(homePageFragment)
            }
            ParamConstant.JAPAN_HOME_PAGE -> {
                japanHomepageFragment = NewVersionJapanHomepageFragment()
                fragmentList.add(japanHomepageFragment!!)
            }
            ParamConstant.INTERNATIONAL_HOME_PAGE -> {
                homefristPageFragment = NewVersionHomepageFirstFragment()
                fragmentList.add(homefristPageFragment!!)
            }
        }
        mImageViewList.add(R.mipmap.tabbar_home)
        mTextviewList.add(LanguageUtil.getString(this, "mainTab_text_home"))


        if (ApiConstants.HOME_VIEW_STATUS != ParamConstant.CONTRACT_HOME_PAGE) {
            fragmentList.add(marketFragment)
            fragmentList.add(tradeFragment)
            mImageViewList.add(R.mipmap.tabbar_quotation)
            mImageViewList.add(R.mipmap.tabbar_trading)

            mTextviewList.add(LanguageUtil.getString(this, "mainTab_text_market"))

            mTextviewList.add(LanguageUtil.getString(this, "assets_action_transaction"))
            if (contractOpen) {
                initContract()
            }
            fragmentList.add(assetFragment)
            mImageViewList.add(R.mipmap.tabbar_assest)
            mTextviewList.add(LanguageUtil.getString(this, "mainTab_text_assets"))
            assetsTab = fragmentList.size - 1
        } else {

            if (contractOpen) {
                initContract()
            }

            fragmentList.add(assetFragment)
            mImageViewList.add(R.mipmap.tabbar_assest)
            mTextviewList.add(LanguageUtil.getString(this, "mainTab_text_assets"))
            assetsTab = fragmentList.size - 1
        }

        getAdvert()
        HomeTabMap.initMaps(data)
        initView()
        val isNewForceContract = PublicInfoDataService.getInstance().isNewForceContract()
        if (isNewForceContract && contractOpen) {
            showLogoutDialog()
        }
    }
//
//    @RequiresApi(Build.VERSION_CODES.KITKAT)
//    override fun onResume() {
//        super.onResume()
//        NewDialogUtils.showHomePageDialog(this)
//        loginToken()
//        if (!TextUtils.isEmpty(MMKV.defaultMMKV().getString("gameId", ""))) {
//            if (LoginManager.checkLogin(this, false)) {
//                DialogUtil.showAuthorizationDialog(this, gameID, gameName, gameToken)
//            }
//        }
//
//    }

    override fun initView() {
        showTabs()
        no_network_check?.setOnClickListener {
            startActivity(Intent(Settings.ACTION_SETTINGS))
        }
        no_network_retry_btn?.setOnClickListener {
            startActivity(Intent(Settings.ACTION_SETTINGS))
        }
//        initNetWorkRemind()
    }

    fun initNetWorkRemind() {
        val spanStrStart = SpannableString(getString(R.string.check_network_settings))
        val spanStrClick = SpannableString(getString(R.string.check_network))
        val index = spanStrStart.indexOf(spanStrClick.toString(), 0)
        var spanStrStartSub = spanStrStart.subSequence(0, index)
        var spanStrEnd = spanStrStart.subSequence(index + spanStrClick.length, spanStrStart.length)

        spanStrClick.setSpan(object : ClickableSpan() {
            override fun onClick(widget: View) {
                startActivity(Intent(Settings.ACTION_SETTINGS))
            }

            override fun updateDrawState(ds: TextPaint) {
                super.updateDrawState(ds)
                ds.color = mActivity.resources.getColor(R.color.color_nonetwork_btn_blue) //Set Color
                //Remove the underline, default to underlined
                ds.isUnderlineText = false
            }
        }, 0, spanStrClick.length, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)
        no_network_check.append(spanStrStartSub)
        no_network_check.append(spanStrClick)
        no_network_check.append(spanStrEnd)
        no_network_check.setMovementMethod(LinkMovementMethod.getInstance())

    }

    private fun showTabs() {
        bottomtab_group?.setData(mImageViewList, mTextviewList, this, contractIndex, false)
//        for (i in 0 until fragmentList.size) {
//            var fg = fragmentList[i]
//            val transaction = fragmentManager?.beginTransaction()
//            transaction?.add(R.id.fragment_container, fg, fg.javaClass.name)?.commitAllowingStateLoss()
//        }
        setCurrentItem()
    }


    override fun onClick(view: View) {
        super.onClick(view)
        var tag = view.tag
        if (tag is Int) {
            if (assetsTab > 0 && tag == assetsTab) {
                if (!LoginManager.checkLogin(mActivity, true)) {
                    return
                }
            }
            curPosition = tag
            if (lastPosition != curPosition) {
                for (i in 0 until fragmentList.size) {
//                    fragmentList[i].refreshOkhttp(lastPosition)
                }
                lastPosition = curPosition
            }

            setCurrentItem()
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        for (fragment in supportFragmentManager.fragments) {
            fragment.onActivityResult(requestCode, resultCode, data)
        }

    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    override fun onMessageEvent(event: MessageEvent) {
        super.onMessageEvent(event)
        if (event.msg_type == MessageEvent.finish_page_event) {
            finish()
        }
        if (event.msg_type == MessageEvent.coin_payment) {

            var msg_content = event.msg_content
            if (null != msg_content && msg_content is JSONObject) {
                var json = msg_content
                var position = json.optInt("position")
                if (ParamConstant.TYPE_COIN == position) {
                    curPosition = HomeTabMap.maps[HomeTabMap.coinTradeTab] ?: 2
                    setCurrentItem()
                } else if (ParamConstant.TYPE_FAIT == position) {
                    ArouterUtil.navigation(RoutePath.NewVersionOTCActivity, null)
                }
            }
        } else if (MessageEvent.hometab_switch_type == event.msg_type) {
            //Spot trading tab switching
            var msg_content = event.msg_content
            if (null != msg_content && msg_content is Bundle) {
                curPosition = msg_content.getInt(ParamConstant.homeTabType)
                if (HomeTabMap.maps[HomeTabMap.coinTradeTab] == curPosition) {
                    Handler().postDelayed({
                        forwardConinTradeTab(event.msg_content as Bundle)
                    }, 150)

                } else if (HomeTabMap.maps[HomeTabMap.assetsTab] == curPosition) {
                    Handler().postDelayed({
                        forwardAssetsTab(event.msg_content as Bundle)
                    }, 150)
                }
                setCurrentItem()
            }
        } else if (MessageEvent.contract_switch_type == event.msg_type) {
            /**
             *Jump contract
             */
            curPosition = HomeTabMap.maps[HomeTabMap.contractTab] ?: 0
            setCurrentItem()
        } else if (MessageEvent.market_switch_type == event.msg_type) {
            //Spot trading tab switching
            var msg_content = event.msg_content
            if (null != msg_content) {
                curPosition = 1
                setCurrentItem()
            }
        } else if (MessageEvent.login_bind_type == event.msg_type) {
            LogUtil.e("LogUtils", "登录监听 ${UserDataService.getInstance().token}  [] ${PushManager.getInstance().getClientid(this)}")
            CpClLogicContractSetting.setToken(UserDataService.getInstance().token)
            HttpClient.instance.bindToken(PushManager.getInstance().getClientid(this)).subscribeOn(Schedulers.io())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe({

                    }, {
                        it.printStackTrace()
                    })
        } else if (MessageEvent.sl_contract_force_event == event.msg_type) {
            LogUtil.e("LogUtils", "重新配置新合约")
            showLogoutDialog()
        } else if (event.msg_type == MessageEvent.refresh_ws_error_change) {
            LogUtil.e("LogUtils", "ws 异常需要网络检测")
            connectCount++
            if (connectCount == 11) {
                wsConnectCount()
            }
//            changeNetworkError()
        } else if (event.msg_type == MessageEvent.refresh_ws_open_change) {
            LogUtil.e("LogUtils", "ws 建立链接")
            connectCount = 0
            wsConnectCount()
            val klineTime = event.msg_content as Long
            sendWsHomepage(mActivity, 0, NetworkDataService.KEY_PAGE_MARKET_SERVICE, NetworkDataService.KEY_WS_OPEN, klineTime)
        }
    }

    /**
     *Determine the network based on the number of ws reconnections
     */
    fun wsConnectCount() {
        if (connectCount > 10) {
            if (mActivity?.let { NetUtil.isNetConnected(it) } != true) {
//                no_network_main_bg?.visibility = View.VISIBLE
//                main_bg?.visibility = View.GONE
            } else {
//                no_network_main_bg?.visibility = View.GONE
//                main_bg?.visibility = View.VISIBLE
            }
        } else {
//            no_network_main_bg?.visibility = View.GONE
//            main_bg?.visibility = View.VISIBLE
        }
//        var net_event_fragment = MessageEvent(MessageEvent.net_status_change)
//        EventBusUtil.post(net_event_fragment)
    }

    override fun onCpMessageEvent(event: CpMessageEvent) {
        if (CpMessageEvent.sl_contract_go_login_page == event.msg_type) {
            LoginManager.checkLogin(this, true)
        } else if (CpMessageEvent.sl_contract_go_fundsTransfer_page == event.msg_type) {
            ArouterUtil.navigation(RoutePath.NewVersionTransferActivity, Bundle().apply {
                putString(ParamConstant.TRANSFERSTATUS, ParamConstant.TRANSFER_CONTRACT)
                if(event.msg_content is Bundle){
                    val bundle = event.msg_content as Bundle
                    putString(ParamConstant.TRANSFERSYMBOL, bundle.getString("marginCoin"))
                    putString(ParamConstant.TRANSFERORIGINCOIN, bundle.getString("originCoin"))
                }
            })
        } else if (CpMessageEvent.sl_contract_go_kyc_page == event.msg_type) {
            ArouterUtil.navigation(RoutePath.KycActivity, null)
        } else if (CpMessageEvent.contract_switch_type == event.msg_type) {
            /**
             *Jump contract
             */
            curPosition = HomeTabMap.maps[HomeTabMap.contractTab] ?: 0
            setCurrentItem()
        }
    }

    /*
     *Jump to the spot tab
     */
    private fun forwardConinTradeTab(bundle: Bundle) {
        LogUtil.d(TAG, "onMessageEvent==NewMainActivity==现货交易==bundle is $bundle")
        var msg_event = MessageEvent(MessageEvent.coinTrade_tab_type)
        msg_event.msg_content = bundle
        EventBusUtil.post(msg_event)
    }


    /*
     *Jump to Asset
     */
    private fun forwardAssetsTab(bundle: Bundle) {
        var msg_event = MessageEvent(MessageEvent.assetsTab_type)
        msg_event.msg_content = bundle
        EventBusUtil.post(msg_event)
    }


    private var exitTime = 0L
    override fun onBackPressed() {
        if (System.currentTimeMillis() - exitTime > 2000) {
            UIUtils.showToast(LanguageUtil.getString(this, "exit_remind"))
            exitTime = System.currentTimeMillis()
            return
        }
        HttpClient.instance.setToken("")
        super.onBackPressed()
    }

    private fun setCurrentItem() {
        mActivity.runOnUiThread {
            bottomtab_group?.showCurTabView(curPosition)
        }
        val cTextview = mTextviewList[curPosition]
        if (cTextview.equals(LanguageUtil.getString(this, "mainTab_text_assets"))) {
            StatusBarUtil.setColor(this, ColorUtil.getColor(this,R.color.main_color), 0)
        } else if(cTextview.equals(LanguageUtil.getString(this,"assets_action_transaction"))){
            //Contract or transaction
            StatusBarUtil.setColor(this, ContextCompat.getColor(this,R.color.fill_1), 0)
        }else{
            StatusBarUtil.setColor(this, ContextCompat.getColor(this,R.color.main_bg_color), 0)
        }
        for (i in 0 until fragmentList.size) {
            val transaction = fragmentManager?.beginTransaction()
            var fg = fragmentList[i]
            if (i == curPosition) {
                if(!fg.isAdded){
                    //No add execution added
                    transaction?.add(R.id.fragment_container,fg)?.commitAllowingStateLoss()
                    continue
                }
                mActivity?.runOnUiThread {
                    transaction?.show(fg)?.commitAllowingStateLoss()
                }
            } else {
                if(!fg.isAdded) continue//If not added, there is no need to perform hiding
                if (!fg.isHidden) { //No hidden execution hidden
                    transaction?.hide(fg)?.commitAllowingStateLoss()
                }
            }
        }
    }


    override fun loadData() {
        super.loadData()

        initUIFragment()

        initMethod()
        LanguageUtil.checkChangeDefaultLanguage()
    }

    private fun initUIFragment(){

        Log.d(TAG,"initUIFragment")
        if(fragmentList.size>0){
            val beginTransaction = supportFragmentManager.beginTransaction()
            val currentVisibleFg = fragmentList[curPosition]
            beginTransaction.hide(currentVisibleFg).commit()
        }

        curPosition = 0
        val catchObj = PublicInfoDataService.getInstance().getData(null)
        if (null != catchObj && catchObj.length() > 0) {
            Log.d(TAG, "Go to the tab menu at the bottom of the cache rendering")
            initTabsData(catchObj)
        } else {
            Log.d(TAG, "cache free rendering at the bottom tab menu")
            addDisposable(getMainModel().public_info_v4(MyNDisposableObserver(mActivity)))
        }
    }

    //Initialization method
    private fun initMethod(){

        if (ApiConstants.isGooglePlay()) {
            CheckUpdateUtil.update(mActivity, true)
        }

        WsContractAgentManager.instance.connectionSocket()

        if (LoginManager.isLogin(this)) {
            getMainModel().saveUserInfo()
        }
    }


    private fun loopStart() {
        loopStop()
        subscribe = Observable.interval(0L, CpCommonConstant.coinLoopTime, TimeUnit.SECONDS)
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe {
                    getLimitIpLogin()
                }
    }

    private fun getLimitIpLogin() {
        addDisposable(getMainModel().limit_ip_login(object : NDisposableObserver() {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                check_visitstatus.visibility = View.GONE
            }

            override fun onResponseFailure(code: Int, msg: String?) {
                if (code == 109109) {
                    check_visitstatus.visibility = View.VISIBLE
                    check_visit_tv2.setText(msg)
                }
            }
        }))
    }

    /*
    *If the current page is a request, it is not necessary to override the Inner class
    * */
    inner class MyNDisposableObserver(activity: Activity) : NDisposableObserver(activity, false) {
        override fun onResponseSuccess(jsonObject: JSONObject) {
            var data = jsonObject.optJSONObject("data")
            if (null != data && data.length() > 0) {
                var rate = data.optJSONObject("rate")
                RateDataService.getInstance().saveData(rate)
                // downloads lan file
                LanguageUtil.checkChangeDefaultLanguage()
            }

            PublicInfoDataService.getInstance().saveData(data)
            initTabsData(data)
        }

        override fun onResponseFailure(code: Int, msg: String?) {
            super.onResponseFailure(code, msg)
            var cachObj = PublicInfoDataService.getInstance().getData(null)
            initTabsData(cachObj)
        }
    }

    private fun loadContractPublicInfo() {
        addDisposable(getContractModel().getPublicInfo(
                consumer = object : NDisposableObserver(mActivity, true) {
                    override fun onResponseSuccess(jsonObject: JSONObject) {
                        jsonObject.optJSONObject("data").run {
                            val contractList = optJSONArray("contractList")
                            var marginCoinList = optJSONArray("marginCoinList")
                            var langList = optJSONArray("langList")
                            if (contractList.length() == 0) {
                                return
                            }
                            CpClLogicContractSetting.setContractJsonListStr(mActivity, contractList.toString())
                            CpClLogicContractSetting.setContractMarginCoinListStr(mActivity, marginCoinList.toString())
                            CpClLogicContractSetting.setContractOriginalMarginCoinListStr(mActivity, optJSONArray("originalCoinList").toString())

                            LanguageUtil.checkChangeDefaultLanguage(false)
                            if (langList!=null&&langList.length() != 0) {
                                CpClLogicContractSetting.setContractLanguageJsonListStr(mActivity, langList.toString())
                            }
                        }
                    }
                }))


        addDisposable(getContractModel().getSymbolRateList(
            consumer = object : NDisposableObserver(mActivity, true) {
                override fun onResponseSuccess(jsonObject: JSONObject) {
                    jsonObject.optJSONObject("data").run {
                        CpClLogicContractSetting.setContractJsonRateStr(mActivity,this.toString())
                    }
                }
            }))

    }

    var hasCommmitBikiUserInfo = false
    fun loginToken() {
        if (hasCommmitBikiUserInfo)
            return
        var token = UserDataService.getInstance().token
        if (getString(R.string.applicationId) == "com.chainup.exchange.bikicoin" && !TextUtils.isEmpty(token)) {
            hasCommmitBikiUserInfo = true
            addDisposable(getOTCModel().loginInformation(token, object : NDisposableObserver(null, false) {
                override fun onResponseSuccess(jsonObject: JSONObject) {
                }
            }))
        }
    }

    override fun onStart() {
        super.onStart()
        LogUtil.e("ForegroundCallbacks", "MainActivity onStart")
    }

    override fun onResume() {
        super.onResume()
        loopStart()
        if(!LoginManager.isLogin(this)){
            if(fragmentList.size>0){
                if(fragmentList[curPosition] is NewVersionMyAssetFragment){
                    curPosition = 0
                    setCurrentItem()
                }
            }
        }
    }

    override fun onPause() {
        super.onPause()
        LogUtil.e("ForegroundCallbacks", "MainActivity onPause")
        loopStop()
    }

    override fun onStop() {
        super.onStop()
        LogUtil.e("ForegroundCallbacks", "MainActivity onStop")
        loopStop()
    }

    override fun onDestroy() {
        super.onDestroy()
        NLiveDataUtil.removeObservers()
        WsAgentManager.instance.stopWs()
        WsContractAgentManager.instance.stopWs()
        dialogType = 0
        NetUtil.unregisterNetConnChangedReceiver(this)
        loopStop()
    }


    private fun loopStop() {
        LogUtil.e("-----","停止轮询")
        if (subscribe != null) {
            subscribe?.dispose()
        }
    }


    @SuppressLint("MissingSuperCall")
    override fun onSaveInstanceState(outState: Bundle) {
//        super.onSaveInstanceState(outState)
    }

    private var contractIndex = -1

    private fun initContract() {
        fragmentList.add(contractFragment)
        UserDataService.getInstance().token
        UserDataService.getInstance().notifyContractLoginStatusListener()
        mImageViewList.add(R.mipmap.tabbar_contract)
        mTextviewList.add(LanguageUtil.getString(this, "mainTab_text_contract"))

        AppConstant.IS_NEW_CONTRACT = (PublicInfoDataService.getInstance().getContractMode() == 1)
        if (contractOpen){
            loadContractPublicInfo()
        }
    }

    /**
     *Log out of the login dialog
     */
    private fun showLogoutDialog(position: Int = 1) {
        NewDialogUtils.showSingleForceDialog(this, LanguageUtil.getString(this, "newContract_force_changeCo_desc"), object : NewDialogUtils.DialogBottomListener {
            override fun sendConfirm() {
                initPushCheck(position)
            }
        })
    }

    /**
     *Log out of login
     */
    fun initPushCheck(position: Int) {
        PublicInfoDataService.getInstance().contractMode = position
        val intent = Intent(this, SplashActivity::class.java)
        intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TASK or Intent.FLAG_ACTIVITY_NEW_TASK
        startActivity(intent)
        finish()
        android.os.Process.killProcess(android.os.Process.myPid())
        System.exit(0)
    }

    private fun getAdvert() {
        homeAdvert(this)
        HttpClient.instance.getHomeAdvert()
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    if (it != null) AdvertDataService.instance.getAdvertAndCacheLocal(it.data)
                }, {
                    it.printStackTrace()
                })
    }

    override fun dispatchTouchEvent(ev: MotionEvent?): Boolean {
        if (ev?.getAction() == MotionEvent.ACTION_DOWN) {
            val v = getCurrentFocus()
            v?.let {
                if (isShouldHideKeyboard(it, ev)) {
                    val im = getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
                    im.hideSoftInputFromWindow(v.windowToken, InputMethodManager.HIDE_NOT_ALWAYS);
                    it.clearFocus();
                }
            }
        }
        return super.dispatchTouchEvent(ev)
    }

    fun isShouldHideKeyboard(v: View, event: MotionEvent): Boolean {
        if (v != null && (v is EditText)) {
            val l = intArrayOf(0, 0)
            v.getLocationInWindow(l)
            val left = l[0]
            val top = l[1]
            val bottom = top + v.getHeight()
            val right = left + v.getWidth()
            if (event.getX() > left && event.getX() < right
                    && event.getY() > top && event.getY() < bottom) {
                return false;
            } else {
                return true;
            }
        }
        return false
    }

    override fun getRate(contractId: Int): String {
        val quote = CpClLogicContractSetting.getContractQuoteById(this,contractId)
        val rate = com.yjkj.chainup.manager.RateManager.getContractRatesByClassification(quote,getCurrencyLang())
        return rate
    }

    override fun getCurrencyPrecision(): Int {
        return com.yjkj.chainup.manager.RateManager.getCurrencyPrecision()
    }

    override fun getCurrencyLang() :String{
        return com.yjkj.chainup.manager.RateManager.getCurrencyLang()
    }

    override fun getCurrencySign() :String{
        return com.yjkj.chainup.manager.RateManager.getCurrencySign()
    }

    override fun getToken(): String {
        return UserDataService.getInstance().token
    }

    override fun clearToken() {
        UserDataService.getInstance().clearToken()
    }

    override fun getDefLan(): String {
        return PublicInfoDataService.getInstance().defLan
    }

    override fun getKlineWaterPath(): String {
        val isDay = CpClLogicContractSetting.getThemeMode(this) == CpClLogicContractSetting.THEME_MODE_DAYTIME
        return PublicInfoDataService.getInstance().getKline_background_logo_img(null,isDay)
    }

    override fun onCpWsMessage(json: String) {
        ChainUpLogUtil.d(TAG,"contract req review>>>\n $json")
        CpClLogicContractSetting.setReqReviewData(json)
    }
}


