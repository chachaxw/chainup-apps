package com.yjkj.chainup.new_version.home

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
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
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.lifecycle.Observer
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.viewpager.widget.ViewPager
import com.chainup.contract.utils.setSafeListener
import com.chainup.contract.view.dialog.CpTDialog
import com.chainup.kit.utils.SkeletonUtil
import com.ethanhua.skeleton.ViewSkeletonScreen
import com.tbruyelle.rxpermissions2.RxPermissions
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseFragment
import com.yjkj.chainup.db.constant.*
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.db.service.v5.CommonService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.extra_service.eventbus.EventBusUtil
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.extra_service.eventbus.NLiveDataUtil
import com.yjkj.chainup.manager.*
import com.yjkj.chainup.net.HttpClient
import com.yjkj.chainup.net.api.ApiConstants
import com.yjkj.chainup.net.retrofit.NetObserver
import com.yjkj.chainup.net_new.JSONUtil
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_version.activity.NewMainActivity
import com.yjkj.chainup.new_version.activity.RewardCenterActivity
import com.yjkj.chainup.new_version.activity.asset.CaptureActivity
import com.yjkj.chainup.new_version.activity.personalCenter.MailActivity
import com.yjkj.chainup.new_version.activity.personalCenter.NoticeActivity
import com.yjkj.chainup.new_version.adapter.*
import com.yjkj.chainup.new_version.bean.ReadMessageCountBean
import com.yjkj.chainup.new_version.dialog.DialogUtil
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.home.adapter.ImageNetAdapter
import com.yjkj.chainup.util.*
import com.yjkj.chainup.wedegit.VerticalTextview4ChainUp
import com.yjkj.chainup.wedegit.ViewUtil
import com.yjkj.chainup.wedegit.indicator.NumIndicator
import com.yjkj.chainup.wedegit.item.GridSpacingDecoration
import com.yjkj.chainup.wedegit.item.GridSpacingItemDecoration
import com.yjkj.chainup.ws.WsAgentManager
import com.youth.banner.config.IndicatorConfig
import io.reactivex.Observable
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.activity_home_title.*
import kotlinx.android.synthetic.main.activity_personal_center.aiv_mail
import kotlinx.android.synthetic.main.fragment_new_version_homepage.*
import kotlinx.android.synthetic.main.no_network_remind.*
import kotlinx.android.synthetic.main.redpackage_item_view.*
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode
import org.jetbrains.anko.doAsync
import org.jetbrains.anko.imageResource
import org.json.JSONArray
import org.json.JSONObject
import java.util.*
import java.util.concurrent.TimeUnit

/**
 * @Author lianshangljl
 * @Date 2023/5/5-2:54 PM
 * @Email buptjinlong@163.com
 *@description homepage
 */
class NewVersionHomepageFragment : NBaseFragment(), WsAgentManager.WsResultCallback {

    val getTopDataReqType = 1 //Request for market data at the top of the homepage
    val homepageReqType = 2 //Homepage Data Request
    val accountBalanceReqType = 5 //Total Account Asset Request
    val homeData = 11 //Total Account Asset Request
    var isShowSkeleton = false
    /**
     *Whether to open off site
     */
    private var otcOpen = false

    private var leverOpen = false

    /**
     *Whether to open the contract
     */
    private var contractOpen = false

    /**
     *Functional Services
     */
    private var serviceAdapter: NewHomePageServiceAdapter? = null

    var defaultBanner = 0
    var defaultHome = 0


    /*
     *Have you logged in
     */
    var isLogined = false
    var subscribeCoin: Disposable? = null//Save subscribers
    var isScrollStatus = false
    var bannerLastClick=0L
     var mSkeletonHome: ViewSkeletonScreen?=null

    override fun setContentView() = R.layout.fragment_new_version_homepage

    override fun initView() {
        otcOpen = PublicInfoDataService.getInstance().otcOpen(null)
        leverOpen = PublicInfoDataService.getInstance().isLeverOpen(null)
        contractOpen = PublicInfoDataService.getInstance().contractOpen(null)
        WsAgentManager.instance.addWsCallback(this)
        observeData()

        if (ApiConstants.HOME_VIEW_STATUS != ParamConstant.CONTRACT_HOME_PAGE) {
            initTop24HourView()
        }
        tv_network?.text = LanguageUtil.getString(context,"check_network_error_settings")
        tv_network?.text = LanguageUtil.getString(context,"check_network_error_settings")
        et_search?.hint = LanguageUtil.getString(context,"market_search_ex")
        tv_go_register?.text = LanguageUtil.getString(context, "login_action_register")
        tv_go_login?.text = LanguageUtil.getString(context, "login_action_login")
        tv_login_tips?.text = LanguageUtil.getString(context, "login_bottom_tips")
        setTopBar()
        setOnClick()
        try {
            initNetWorkRemind()
        }catch (e:Exception){
            e.printStackTrace()
        }
        LogUtil.d(TAG, "切换语言==NewVersionHomepageFragment==")

        when (ApiConstants.HOME_PAGE_STYLE) {
            ParamConstant.DEFAULT_HOME_PAGE -> {
                defaultBanner = R.drawable.banner_king

            }
            ParamConstant.INTERNATIONAL_HOME_PAGE -> {
                defaultBanner = R.drawable.banner_king
                defaultHome = R.drawable.home_king
            }

        }
        val data = CommonService.instance.getHomeData()
        showHomepageData(data, true)

//        swipe_refresh.setColorSchemeColors(ContextUtil.getColor(R.color.colorPrimary))

        NLiveDataUtil.observeData(this) {
            if(it.msg_type == MessageEvent.home_event_page_market_type){
                getHomeData()
            }
        }
        getHomeData()
        mSkeletonHome = SkeletonUtil.showView(v_container, R.layout.skeleton_home_view).show()
    }

    fun initNetWorkRemind() {
        no_network_retry_btn?.textContent = LanguageUtil.getString(mActivity,"check_refresh_more")
        val spanStrStart = SpannableString(LanguageUtil.getString(mActivity,"check_network_settings"))
        val spanStrClick = SpannableString(LanguageUtil.getString(mActivity,"check_network"))
        LogUtil.e(TAG,"initNetWorkRemind ${spanStrStart} [] $spanStrClick")
        val index = spanStrStart.indexOf(spanStrClick.toString(), 0)
        var spanStrStartSub = spanStrStart.subSequence(0, index)
        var spanStrEnd = spanStrStart.subSequence(index + spanStrClick.length, spanStrStart.length)

        spanStrClick.setSpan(object : ClickableSpan() {
            override fun onClick(widget: View) {
                startActivity(Intent(Settings.ACTION_SETTINGS))
            }

            override fun updateDrawState(ds: TextPaint) {
                super.updateDrawState(ds)
                ds.color = context?.resources!!.getColor(R.color.main_color) //Set Color
                //Remove the underline, default to underlined
                ds.isUnderlineText = false
            }
        }, 0, spanStrClick.length, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)
        no_network_check.append(spanStrStartSub)
        no_network_check.append(spanStrClick)
        no_network_check.append(spanStrEnd)
        no_network_check.setMovementMethod(LinkMovementMethod.getInstance())

    }

    /*
     *Initialize red envelope view
     */
    private fun initRedPacketView() {
        val isTipsOpen = UserDataService.getInstance().isLogined
        showRedPacket(rl_login_tips_layout,!isTipsOpen)
        val isRedPacketOpen = PublicInfoDataService.getInstance().isRedPacketOpen(null)
        showRedPacket(rl_red_envelope_entranc_layout,isRedPacketOpen)
        iv_personal_logo?.imageResource = when(isTipsOpen){
            true -> R.drawable.headportrait2
            else -> R.mipmap.headportrait2
        }
    }

    /**
     *Top 24-hour growth chart (recommended currency)
     */
    private var topSymbolAdapter: NewhomepageTradeListAdapter? = null
    private var otherAdapter: NewOtherAdapter? = null
    var scrollX = 0
    private fun initTop24HourView() {
        recycler_top_24?.layoutManager = LinearLayoutManager(mActivity, LinearLayoutManager.HORIZONTAL, false)
        topSymbolAdapter = NewhomepageTradeListAdapter()
        recycler_top_24?.adapter = topSymbolAdapter
        topSymbolAdapter?.setOnItemClickListener { adapter, view, position ->
            var dataList = topSymbolAdapter!!.data
            if (null != dataList && dataList.size > 0) {
                var symbol = dataList[position].optString("symbol")
                ArouterUtil.forwardKLine(symbol)
            }
        }

    }

    val networkParams = hashMapOf<String, String>()
    private fun observeData() {
        NLiveDataUtil.observeData(this, Observer {
            if (null != it) {
                if (MessageEvent.color_rise_fall_type == it.msg_type) {
                    topSymbolAdapter?.notifyDataSetChanged()
                }
            }
        })
        GlobalScope.launch {
            LogUtil.e(TAG, "首页网络统计 start ws状态 " + WsAgentManager.instance.isConnection())
            delay(3000L)
            LogUtil.e(TAG, "首页网络统计 end ws状态 " + WsAgentManager.instance.isConnection())
        }
    }

    inner class MyNDisposableObserver(type: Int) : NDisposableObserver() {

        var req_type = type
        override fun onResponseSuccess(jsonObject: JSONObject) {
            if (getTopDataReqType == req_type) {
                recycler_top_24?.visibility = View.VISIBLE
                showTopSymbolsData(jsonObject.optJSONArray("data"))
            } else if (homepageReqType == req_type) {
                showHomepageData(jsonObject.optJSONObject("data"))
            } else if (homeData == req_type) {
                mSkeletonHome?.let { SkeletonUtil.hideSkeleton(it) }
                v_container.visibility=View.GONE
                closeLoadingDialog()
                showHomepageData(jsonObject.optJSONObject("data"))
                advertTime()
            }
            swipe_refresh?.finishRefresh(true)
        }

        override fun onResponseFailure(code: Int, msg: String?) {
            super.onResponseFailure(code, msg)
            if (getTopDataReqType == req_type) {
                recycler_top_24?.visibility = View.GONE
            }
            if (req_type == homeData) {
                initSocket()
                advertTime(true)
                mSkeletonHome?.let { SkeletonUtil.hideSkeleton(it) }
                v_container.visibility=View.GONE
            }
            closeLoadingDialog()
            swipe_refresh?.finishRefresh(false)
        }
    }


    var homepageData: JSONObject? = null

    var contractHomeRecommendNameList = arrayListOf<String>()

    var contractHomeRecommendList = arrayListOf<JSONArray>()

    /*
     *Home page data display
     */
    private fun showHomepageData(data: JSONObject?, isCache: Boolean = false) {
        if (null == data)
            return
        if (!isCache) {
            homepageData = data
            val jsonObjects = JSONObject(data.toString())
            if (jsonObjects != null) {
                CommonService.instance.saveHomeData(jsonObjects)
            }
//            val arrayGuide = arrayOf(layout_search, iv_nation_more, layout_top_24, recycler_center_service_layout)
//            showGuideHomepage(mActivity, arrayGuide, data)
        }
        var dataStyle = data.optInt("cmsAppDataStyle",2)
        var otherStyle = data.optInt("cmsAppDataOtherStyle",2)
        var noticeInfoList = data.optJSONArray("noticeInfoList")
        var cmsAppAdvertList = data.optJSONArray("cmsAppAdvertList")
        var cmsAppDataList = data.optJSONArray("cmsAppDataList")
        var cmsAppNoteDataList = data.optJSONArray("cmsAppDataListOther")
        var cmsSymbolList = data.optJSONArray("header_symbol")
        var homeRecommendList = data.optJSONArray("home_recommend_list") ?: JSONArray()

        showTopSymbolsData(cmsSymbolList)
        /*
         *Data display such as growth charts
         */
        showBottomVp(homeRecommendList)

        LogUtil.d("NewVersionHomepageFragment", "showHomepageData==cmsAppDataList is ${cmsAppDataList.length()} ${dataStyle}")
        newNoticeInfoList = noticeInfoList
        showGuanggao(noticeInfoList)
        showBannerData(cmsAppAdvertList)
        setServiceData(cmsAppDataList,dataStyle)
        showOtherData(cmsAppNoteDataList,otherStyle)

    }


    var newNoticeInfoList = JSONArray()

    /*
     *Show top rotation chart
     */
    var bannerImgUrls = arrayListOf<String>()
    var bannerNoteUrls: ArrayList<String> = arrayListOf()

    private fun showBannerData(cmsAppAdvertList: JSONArray?) {

        if (null == cmsAppAdvertList || cmsAppAdvertList.length() <= 0)
            return

        bannerImgUrls.clear()
        for (i in 0 until cmsAppAdvertList.length()) {
            var obj = cmsAppAdvertList.optJSONObject(i)
            var imageUrl = obj.optString("imageUrl")
            if (StringUtil.isHttpUrl(imageUrl)) {
                bannerImgUrls.add(imageUrl)
            }
        }
        banner_looper?.apply {
            //Set Picture Collection
            val mAdapter = ImageNetAdapter(bannerImgUrls)
            mAdapter.mContext = context
            adapter = mAdapter
            //Set the rotation time
            setLoopTime(3000)
            val numberIndicator = NumIndicator(context)
            numberIndicator.indicatorConfig
            indicator = numberIndicator
            //Set indicator position (when there is an indicator in banner mode)
            setIndicatorGravity(IndicatorConfig.Direction.RIGHT)

        }
        banner_looper?.setOnBannerListener { data, position ->
            val gap = System.currentTimeMillis() - bannerLastClick
            bannerLastClick=System.currentTimeMillis()
            if(gap<1000) return@setOnBannerListener

            var obj = cmsAppAdvertList.optJSONObject(position)
            var httpUrl = obj?.optString("httpUrl") ?: ""
            var nativeUrl = obj?.optString("nativeUrl") ?: ""

            //TODO requires a title
            if (TextUtils.isEmpty(httpUrl)) {
                if (StringUtil.checkStr(nativeUrl) && nativeUrl.contains("?")) {
                    enter2Activity(nativeUrl.split("?"))
                }
            } else {
                forwardWeb(obj)
            }
        }
        //Called last when all the banner setting methods are called
        banner_looper?.start()

    }

    private fun showAdvertising(isShow: Boolean) {
        if (null != vtc_advertising?.textList && vtc_advertising?.textList!!.size > 0) {
            if (isShow) {
                vtc_advertising?.startAutoScroll()
            } else {
                vtc_advertising?.stopAutoScroll()
            }
        }
    }

    private fun showBanner(isShow: Boolean) {
        if (null != bannerImgUrls && bannerImgUrls!!.size > 0) {
            if (isShow) {
                banner_looper?.start()
            } else {
                banner_looper?.stop()
            }
        }

    }


    private fun getAllAccounts() {
        isLogined = UserDataService.getInstance().isLogined

//        if (null == homepageData) {
            getHomeData()
//        }
    }

    private fun showOtherData(cmsAppAdvertList: JSONArray?, styleType: Int = 1) {
        if (null == cmsAppAdvertList || cmsAppAdvertList.length() <= 0){
            recycler_other_service?.visibility = View.GONE
            return
        }

        //Requirement: Style 2 requires 2 images to be configured with only one image, not displayed on the front end
        if(styleType==2 && cmsAppAdvertList.length()<2){
            recycler_other_service?.visibility = View.GONE
            return
        }
        if(cmsAppAdvertList.length()>=2){
            val bannerOne = cmsAppAdvertList.optJSONObject(0).optInt("bannerDirection")
            val bannerTwo = cmsAppAdvertList.optJSONObject(1).optInt("bannerDirection")
            if(styleType==2 && bannerOne==bannerTwo){
                recycler_other_service?.visibility = View.GONE
                return
            }
        }

        recycler_other_service?.visibility = View.VISIBLE
        val serviceOther = JSONUtil.arrayToList(cmsAppAdvertList)

        if(styleType==2){
            serviceOther.sortBy {
                it.optInt("bannerDirection")
            }
        }

        val isTopNull =  selectTopSymbol != null && selectTopSymbol?.size != 0
        val linearParams2 = recycler_other_service?.layoutParams as  LinearLayout.LayoutParams
        val marStart = SizeUtils.dp2px(16f)
        val marBottom = SizeUtils.dp2px(20f)
        linearParams2?.width = ViewGroup.LayoutParams.MATCH_PARENT
        linearParams2?.height = SizeUtils.dp2px(if (styleType == 1) 70f else 88f)
        linearParams2.setMargins(marStart,0,marStart,marBottom)
        recycler_other_service?.apply{
            layoutParams = linearParams2
            layoutManager = LinearLayoutManager(mActivity, LinearLayoutManager.HORIZONTAL, false)
            if(recycler_other_service?.itemDecorationCount == 0 &&  styleType == 2){
                val divider = GridSpacingDecoration(styleType, ViewUtil.dpToPx(10f),false)
                addItemDecoration(divider)
            }
        }
        otherAdapter = NewOtherAdapter()
        otherAdapter?.setList(serviceOther)
        recycler_other_service?.adapter = otherAdapter
        otherAdapter?.setSafeListener { adapter, view, position ->
            var dataList = otherAdapter!!.data
            if (null != dataList && dataList.size > 0) {
                routeApp(dataList.get(position))
            }
        }

    }

    private fun setTopBar() {
    }

    /*
     *Asset tab jump
     */
    private fun homeAssetstab_switch(type: Int) {
        var msgEvent = MessageEvent(MessageEvent.hometab_switch_type)
        var bundle = Bundle()
        var homeTabType = HomeTabMap.maps.get(HomeTabMap.assetsTab)
        bundle.putInt(ParamConstant.homeTabType, homeTabType ?: 4)
        bundle.putInt(ParamConstant.assetTabType, type)
        msgEvent.msg_content = bundle
        EventBusUtil.post(msgEvent)
    }

    /*
     *Handling of tab jumps at the bottom of the homepage
     */
    private fun homeTabSwitch(tabType: Int?, symbol: String? = "") {
        var msgEvent = MessageEvent(MessageEvent.hometab_switch_type)
        var bundle = Bundle()
        bundle.putInt(ParamConstant.homeTabType, tabType ?: 0)
        if (symbol != null) {
            bundle.putString(ParamConstant.symbol, symbol)
        }
        msgEvent.msg_content = bundle
        EventBusUtil.post(msgEvent)
    }

    /*
     *Jump to NewVersionMyAssetActivity
     */
    private fun forwardAssetsActivity(type: Int) {
        var bundle = Bundle()
        bundle.putInt(ParamConstant.assetTabType, type)//Jump to the spot trading page
        ArouterUtil.navigation(RoutePath.NewVersionMyAssetActivity, bundle)
    }


    fun setOnClick() {

        /**
         *Personal Center
         */
        iv_personal_logo?.setOnClickListener {
            ArouterUtil.navigation(RoutePath.PersonalCenterActivity, null)
        }

        et_search?.setOnClickListener {
            ArouterUtil.greenChannel(RoutePath.CoinMapActivity, Bundle().apply {
                putString("type", ParamConstant.ADD_COIN_MAP)
            })
        }
        iv_market_msg?.setOnClickListener {
            if (LoginManager.checkLogin(mActivity, true)) {
                startActivity(Intent(mActivity, MailActivity::class.java))
            }
        }

        iv_nation_more?.setOnClickListener {
//            if (LoginManager.checkLogin(mActivity, true)) {
            startActivity(Intent(mActivity, NoticeActivity::class.java))
//            }
        }

        tv_go_login?.setOnClickListener {
            LoginManager.checkLogin(mActivity, true)
        }
        tv_go_register?.setOnClickListener {
            ArouterUtil.greenChannel("/login/newversionregisteractivity", null)
        }

        /**
         *Click on the red envelope to jump to
         */
        rl_red_envelope_entrance?.setOnClickListener {
            if (!LoginManager.checkLogin(activity, true)) {
                return@setOnClickListener
            }

            var isEnforceGoogleAuth = PublicInfoDataService.getInstance().isEnforceGoogleAuth(null)

            var authLevel = UserDataService.getInstance().authLevel
            var googleStatus = UserDataService.getInstance().googleStatus
            var isOpenMobileCheck = UserDataService.getInstance().isOpenMobileCheck

            if (isEnforceGoogleAuth) {
                if (authLevel != 1 || googleStatus != 1) {
                    NewDialogUtils.redPackageCondition(context ?: return@setOnClickListener)
                    return@setOnClickListener
                }
            } else {
                if (authLevel != 1 || (googleStatus != 1 && isOpenMobileCheck != 1)) {
                    NewDialogUtils.redPackageCondition(context ?: return@setOnClickListener)
                    return@setOnClickListener
                }
            }
            ArouterUtil.navigation(RoutePath.CreateRedPackageActivity, null)
        }
        iv_close_red_envelope?.setOnClickListener {
            showRedPacket(rl_red_envelope_entranc_layout,false)
        }

        /**
         *Refresh Here
         */
        swipe_refresh.setEnableLoadMore(false)
        swipe_refresh?.setOnRefreshListener {
            isScrollStatus = true
            /**
             *Refresh Data Operation
             */
            getHomeData()
            if (homepageData == null || fragments.size == 0 || selectTopSymbol == null) {

            } else {
                getVPTab()
            }
//            swipe_refresh?.isRefreshing = false
        }
        net_wrong?.setOnClickListener {
            startActivity(Intent(Settings.ACTION_SETTINGS))
        }
        no_network_check?.setOnClickListener {
            startActivity(Intent(Settings.ACTION_SETTINGS))
        }
        no_network_retry_btn?.setOnClickListener {
            getHomeData()
        }
        val isScanQRLoginOpen = PublicInfoDataService.getInstance().isScanQRLoginOpen(null)
        iv_qrcode.visibility = if(isScanQRLoginOpen) View.VISIBLE else View.GONE
        //Click to scan the code
        iv_qrcode?.setOnClickListener {
            if(!LoginManager.checkLogin(requireContext(),true)) return@setOnClickListener
            //Check permissions
            val isHasCamera = ContextCompat.checkSelfPermission(mActivity!!,android.Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED
            if(!isHasCamera){

                RxPermissions(mActivity!!)
                    .request(android.Manifest.permission.CAMERA)
                    .subscribe{ isTrue ->
                        if (isTrue) {
                            startScanCodeActivity()
                        } else {
                            //Denied scanning permission
                            DialogUtil.showAlertDialog(mActivity!!,LanguageUtil.getString(mActivity!!,"no_camera_permission_msg_tip"))
                        }
                    }
            }else{
                startScanCodeActivity()
            }


        }
    }

    //Jump to Scan Code
    private fun startScanCodeActivity(){
        val intent = Intent(mActivity, CaptureActivity::class.java)
        startActivityForResult(intent, 0x1111)
    }


    private fun showRedPacket(view:View?,isVisibile: Boolean) {
        if (isVisibile) {
            view?.visibility = View.VISIBLE
        } else {
            view?.visibility = View.GONE
        }
    }

    /*
     *Symbol 24-hour market display at the top of the homepage
     */
    var selectTopSymbol: ArrayList<JSONObject>? = null

    private fun showTopSymbolsData(topSymbol: JSONArray?) {
        selectTopSymbol = NCoinManager.getSymbols(topSymbol)
        if (null == selectTopSymbol || selectTopSymbol?.size!! <= 0) {
            setTopViewVisible(false)
            return
        } else {
            if(selectTopSymbol !=null && selectTopSymbol?.size!! >3){
                selectTopSymbol = ArrayList(selectTopSymbol?.subList(0,3))
            }
        }
        setTopViewVisible(true)
        topSymbolAdapter?.setList(selectTopSymbol)
    }


    private fun initSocket() {
        if (selectTopSymbol == null) {
            return
        }
        var arrays = arrayListOf<String>()
        for (item in selectTopSymbol!!) {
            arrays.add(item.getString("symbol"))
        }
        var json = ""
        homeCoins.clear()
        if (bottomCoins.isNotEmpty()) {
            val temp = bottomCoins union arrays
            homeCoins.addAll(temp)
            json = JsonUtils.gson.toJson(temp)
        } else {
            homeCoins.addAll(arrays)
            json = JsonUtils.gson.toJson(arrays)
        }
        WsAgentManager.instance.sendMessage(hashMapOf("bind" to true, "symbols" to json), this)
    }

    override fun fragmentVisibile(isVisible: Boolean) {
        super.fragmentVisibile(isVisible)
        var mainActivity = activity
        if (mainActivity != null) {
            if (mainActivity is NewMainActivity) {
                if (isVisible && mainActivity.curPosition == 0) {
                    getAllAccounts()
                    showAdvertising(true)
                    showBanner(true)
                    updateNetWrongLayout()
                    Handler().postDelayed({
                        isRoseHttp()
                        if (fragments.size == 0) {
                            return@postDelayed
                        }
                        val fragment = fragments[selectPostion]
                        if (fragment is NewHomeDetailFragmentItem) {
                            fragment.startInit()
                        }
                    }, 100)

                } else {
                    showAdvertising(false)
                    showBanner(false)
                    WsAgentManager.instance.unbind(this)
                    clearToolHttp()
                }

            }
        }

    }


    /**
     *Is the 24-hour market displayed
     */
    fun setTopViewVisible(isShow: Boolean) {
        if (isShow) {
            recycler_top_24?.visibility = View.VISIBLE
        } else {
            recycler_top_24?.visibility = View.GONE
        }
    }

    /**
     *Obtain top symbol 24-hour market
     */
    fun getHomeData() {
        var type = "1"
        if (ApiConstants.HOME_VIEW_STATUS == ParamConstant.CONTRACT_HOME_PAGE) {
            type = "2"
        }
        klineTime = System.currentTimeMillis()
        var disposable = getMainModel().getHomeData(type, MyNDisposableObserver(homeData))
        addDisposable(disposable)

    }

    override fun refreshOkhttp(position: Int) {
        if (position == 0) {
            getTopData()
        }
    }

    val fragments = arrayListOf<Fragment>()
    var selectPostion = 0
    val chooseType = arrayListOf<String>()

    fun showBottomVp(data: JSONArray) {

        if(data.length()<=0) return
        if (serviceDatas == null) {
            if(!NetUtil.isNetConnected(mActivity!!)){
                no_network_bottom_vp?.visibility = View.VISIBLE
                bottom_vp_linearlayout?.visibility = View.GONE
            }
            return
        }
        no_network_bottom_vp?.visibility = View.GONE
        bottom_vp_linearlayout?.visibility = View.VISIBLE
        if(fragments.size<=0){
            var titles = arrayListOf<String>()
            var serviceDatas = JSONUtil.arrayToList(data)
            if(serviceDatas==null) return
            for (item in serviceDatas) {
                titles.add(item.getString("title"))
                chooseType.add(item.getString("key"))
            }
            fragments.clear()
            if (titles.isEmpty())
                return

            for (i in titles.indices) {
                fragments.add(NewHomeDetailFragmentItem.newInstance(titles[i], i, chooseType[i], fragment_market, serviceDatas.get(i).getJSONArray("list").toString()))
            }

            var marketPageAdapter = NVPagerAdapter(childFragmentManager, titles, fragments)
            fragment_market?.adapter = marketPageAdapter
            fragment_market?.offscreenPageLimit = fragments.size
            fragment_market?.addOnPageChangeListener(object : ViewPager.OnPageChangeListener {
                override fun onPageScrollStateChanged(state: Int) {
                }

                override fun onPageScrolled(position: Int, positionOffset: Float, positionOffsetPixels: Int) {
                }

                override fun onPageSelected(position: Int) {
                    selectPostion = position
//                WsAgentManager.instance.unbind(this@NewVersionHomepageFragment)
                    loopData()
                    getVPTab()
                    val fragment = fragments[selectPostion]
                    if (fragment is NewHomeDetailFragmentItem) {
                        fragment.startInit()
                    }
                    fragment_market?.resetHeight(selectPostion)
                }
            })
            try {
                stl_homepage_list?.setViewPagerFont(fragment_market, titles.toTypedArray())
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }else{
            for(i in fragments.indices){
                val cfragment = fragments[i] as NewHomeDetailFragmentItem
                if(cfragment.isAdded){
                    val cData = data.optJSONObject(i).optJSONArray("list")
                    cfragment.initV(cData)
                }
            }

            getVPTab()
            fragment_market?.resetHeight(selectPostion)
        }

        loopData()

    }

    /**
     *Get scrolling advertisements
     */
    fun getNoticeInfoList(notcieList: JSONArray): ArrayList<String> {
        var noticeList4String: ArrayList<String> = arrayListOf()
        for (i in 0 until notcieList.length()) {
            var obj = notcieList.optJSONObject(i)
            var title = obj.optString("title")
            if (null != title) {
                noticeList4String.add(title)
            }
        }
        return noticeList4String
    }

    /**
     *Advertising is loaded based on data
     *With data display, without data hiding
     */
    private fun showGuanggao(noticeInfoList: JSONArray?) {
        if (null != noticeInfoList && noticeInfoList.length() > 0) {
            ll_advertising_layout?.visibility = View.VISIBLE
            if (null == vtc_advertising?.textList || vtc_advertising?.textList!!.size == 0) {
                vtc_advertising?.setText(12f, 0, ContextCompat.getColor(requireContext(), R.color.text_color_2), true)
                vtc_advertising?.setTextStillTime(4000)//Set dwell time interval
                vtc_advertising?.setAnimTime(400)//Set the time interval between entry and exit
                vtc_advertising?.setOnItemClickListener(object : VerticalTextview4ChainUp.OnItemClickListener {
                    override fun onItemClick(pos: Int) {
                        var obj = newNoticeInfoList.optJSONObject(pos)
                        forwardWeb(obj)
                    }
                })
            }
            vtc_advertising?.setTextList(getNoticeInfoList(noticeInfoList))
            vtc_advertising?.startAutoScroll()
        } else {
            ll_advertising_layout?.visibility = View.GONE
        }
    }

    private fun forwardWeb(jsonObject: JSONObject?) {
        var id = jsonObject?.optString("id")
        var title = jsonObject?.optString("title")
        var httpUrl = jsonObject?.optString("httpUrl")?:return

        if(httpUrl.contains("kolTradersListNew")){
            if(!LoginManager.checkLogin(mActivity,true)) return
        }

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


    private fun forUdeskWebView() {
        var bundle = Bundle()
        bundle.putString(ParamConstant.URL_4_SERVICE, PublicInfoDataService.getInstance().getOnlineService(null))
        ArouterUtil.greenChannel(RoutePath.UdeskWebViewActivity, bundle)
    }

    /**
     *If the server does not return service data
     *The overall GONE of the service function here
     */
    private fun setServiceView() {
        recycler_center_service_layout?.visibility = View.GONE
    }

    private fun setServiceShowView() {
        recycler_center_service_layout?.visibility = View.VISIBLE
    }

    private var servicePageSize = 0

    /**
     *
     *Fill in after obtaining feature service data from the server
     */

    var serviceDatas = arrayListOf<JSONObject>()
    private fun setServiceData(appData: JSONArray?, viewType: Int = 2) {
        if (null == appData || appData.length() <= 0) {
            setServiceView()
            return
        }
        serviceDatas = JSONUtil.arrayToList(appData)
        setServiceShowView()
        val noticeInfoZero =  null != newNoticeInfoList && newNoticeInfoList.length() > 0
        val mardBottom = if (noticeInfoZero) DisplayUtil.dip2px(0) else DisplayUtil.dip2px(12)
        val linearParams = center_app_layout?.layoutParams as LinearLayout.LayoutParams
        linearParams.setMargins(0, mardBottom, 0, 0)
        center_app_layout?.layoutParams = linearParams
        var row = if(viewType == 2 && serviceDatas.size > 5) 2 else 1
        LogUtil.e(TAG,"serviceDatas ${serviceDatas.size} ${row} ${recycler_center_service?.itemDecorationCount}")
        if(recycler_center_service?.itemDecorationCount == 0){
            val divider = GridSpacingItemDecoration(5, ViewUtil.dpToPx(10f), ViewUtil.dpToPx(2f))
            recycler_center_service?.addItemDecoration(divider)
        }
        val mLayoutManager = GridLayoutManager(context,5)
        recycler_center_service?.layoutManager = mLayoutManager
        var tempData = ArrayList<JSONObject>()
        if(row == 1 && serviceDatas.size > 5 || row == 2 && serviceDatas.size > 10){
            val endIndex = if(row == 1 && serviceDatas.size > 5) 4 else if(row == 2 && serviceDatas.size > 10) 9 else serviceDatas.size
            tempData.addAll(serviceDatas.subList(0,endIndex))
            tempData.add(JSONObject().apply {
                put("nativeUrl","more?")
                put("title",LanguageUtil.getString(mActivity,"common_action_showMore"))
            })
        } else {
            tempData.addAll(serviceDatas)
        }
        LogUtil.e(TAG,"serviceDatas ${tempData.size}")
        serviceAdapter = NewHomePageServiceAdapter(this.requireActivity(),tempData)
        serviceAdapter?.setSafeListener { adapter, view, position ->

            var obj = tempData.get(position)
            var httpUrl = obj.optString("httpUrl")
            var nativeUrl = obj.optString("nativeUrl")

            LogUtil.d(TAG, "httpUrl is $httpUrl , nativeUrl is $nativeUrl")
            if (TextUtils.isEmpty(httpUrl)) {
                if (StringUtil.checkStr(nativeUrl) && nativeUrl.contains("?")) {
                    enter2Activity(nativeUrl?.split("?"))
                }
            } else {
                if (httpUrl == PublicInfoDataService.getInstance().getOnlineService(null)) {
                    forUdeskWebView()
                } else {
                    forwardWeb(obj)
                }
            }
        }

        recycler_center_service?.adapter = serviceAdapter
    }

    var popDialog: CpTDialog? = null
    /**
     *Corresponding services
     */
    fun enter2Activity(temp: List<String>?) {

        if (null == temp || temp.size <= 0)
            return

        when (temp[0]) {
            "coinmap_market" -> {
                /**
                 *Market
                 */
                var tabType = HomeTabMap.maps[HomeTabMap.marketTab]
                homeTabSwitch(tabType)
            }
            "coinmap_trading" -> {
                /**
                 *Currency pair transaction page
                 */
                var tabType = HomeTabMap.maps[HomeTabMap.coinTradeTab]
                homeTabSwitch(tabType, temp[1])
            }
            "coinmap_details" -> {
                /**
                 *Currency Pair Details Page
                 * MarketDetailActivity
                 */
                if (!TextUtils.isEmpty(temp[1])) {
                    ArouterUtil.forwardKLine(temp[1])
                } else {
                    NToastUtil.showTopToastNet(this.mActivity, false, LanguageUtil.getString(context, "common_tip_hasNoCoinPair"))
                }
            }
            "otc_buy" -> {
                /**
                 *Off exchange transactions - purchases
                 */
                /*if (LoginManager.checkLogin(activity, true)) {
                }*/
                if (otcOpen) {
                    var bundle = Bundle()
                    bundle.putInt("tag", 0)
                    ArouterUtil.navigation(RoutePath.NewVersionOTCActivity, bundle)
                } else {
                    NToastUtil.showTopToastNet(this.mActivity, false, LanguageUtil.getString(context, "common_tip_notSupportOTC"))
                }
            }
            "otc_sell" -> {
                /**
                 *Off exchange trading - sale
                 */
                if (otcOpen) {
                    var bundle = Bundle()
                    bundle.putInt("tag", 1)
                    ArouterUtil.navigation(RoutePath.NewVersionOTCActivity, bundle)
                } else {
                    NToastUtil.showTopToastNet(this.mActivity, false, LanguageUtil.getString(context, "common_tip_notSupportOTC"))
                }
            }

            "order_record" -> {
                /**
                 *Order Record
                 */

                if (LoginManager.checkLogin(activity, true)) {
                    if (otcOpen) {
                        ArouterUtil.greenChannel(RoutePath.NewOTCOrdersActivity, null)
                    } else {
                        NToastUtil.showTopToastNet(this.mActivity, false, LanguageUtil.getString(context, "common_tip_notSupportOTC"))
                    }
                }
            }
            "account_transfer" -> {
                /**
                 *Account transfer
                 */
                if (LoginManager.checkLogin(activity, true)) {
                    ArouterUtil.forwardTransfer(ParamConstant.TRANSFER_BIBI, "BTC")
                }
            }
            "otc_account" -> {
                /**
                 *Assets - Off Market Accounts
                 */
                if (LoginManager.checkLogin(activity, true)) {

                    if (otcOpen) {
                        if (ApiConstants.HOME_VIEW_STATUS == ParamConstant.CONTRACT_HOME_PAGE) {
                            homeAssetstab_switch(1)
                        } else {
                            if (contractOpen) {
                                forwardAssetsActivity(1)
                            } else {
                                homeAssetstab_switch(1)
                            }
                        }

                    } else {
                        NToastUtil.showTopToastNet(this.mActivity, false, LanguageUtil.getString(context, "common_tip_notSupportOTC"))
                    }
                }
            }
            "contract_follow_order" -> {
                /**
                 *Tracking page
                 */

            }

            "coin_account" -> {
                /**
                 *Asset spot account
                 */
                if (LoginManager.checkLogin(activity, true)) {
                    if (ApiConstants.HOME_VIEW_STATUS == ParamConstant.CONTRACT_HOME_PAGE) {
                        homeAssetstab_switch(0)
                    } else {
                        if (contractOpen && otcOpen) {
                            forwardAssetsActivity(0)
                        } else {
                            homeAssetstab_switch(0)
                        }
                    }

                }

            }
            "safe_set" -> {
                /**
                 *Security Settings
                 */
                if (LoginManager.checkLogin(activity, true)) {
                    ArouterUtil.navigation(RoutePath.SafetySettingActivity, null)
                }
            }
            "safe_money" -> {
                /**
                 *Security Settings - Fund Password
                 */
                if (LoginManager.checkLogin(activity, true)) {
                    if (UserDataService.getInstance()?.authLevel != 1) {
                        NToastUtil.showTopToastNet(this.mActivity, false, LanguageUtil.getString(context, "otc_please_cert"))
                        return
                    }
                    if (UserDataService.getInstance().isCapitalPwordSet == 0) {
                        ArouterUtil.forwardModifyPwdPage(ParamConstant.SET_PWD, ParamConstant.FROM_OTC)
                    } else {
                        ArouterUtil.forwardModifyPwdPage(ParamConstant.RESET_PWD, ParamConstant.FROM_OTC)
                    }
                }
            }
            "personal_information" -> {
                /**
                 *Personal information
                 */
                if (LoginManager.checkLogin(activity, true)) {
                    ArouterUtil.greenChannel(RoutePath.PersonalInfoActivity, null)
                }

            }
            "personal_invitation" -> {
                /**
                 *Profile - Invitation Code
                 */
                if (LoginManager.checkLogin(activity, true)) {
                    ArouterUtil.navigation(RoutePath.ContractAgentActivity, null)
                }

            }
            "collection_way" -> {
                /**
                 *Payment method
                 */
                if (LoginManager.checkLogin(activity, true)) {
                    ArouterUtil.greenChannel(RoutePath.PaymentMethodActivity, null)
                }
            }
            "real_name" -> {
                /**
                 *Real name authentication
                 */
                if (LoginManager.checkLogin(activity, true)) {
                    when (UserDataService.getInstance().authLevel) {
                        0 -> {
                            ArouterUtil.navigation(RoutePath.KycActivity, null)
                        }
                        1 -> {
                            NToastUtil.showTopToastNet(this.mActivity,true, LanguageUtil.getString(context, "personal_text_verified"))
                        }
                    }
                }
            }
            "contract_transaction" -> {
                /**
                 *Go to the contract trading page
                 */
                forwardContractTab()
            }

            "market_etf" -> {
                /**
                 *ETF List
                 */
                forwardMarketTab("ETF")
            }

            /**
             *Contract Broker
             *TODO needs to determine the key here
             */
            "config_contract_agent_key" -> {
                if (!LoginManager.checkLogin(context, true)) {
                    return
                }
                ArouterUtil.navigation(RoutePath.ContractAgentActivity, null)
            }

            "financial_asset" -> {
                if (LoginManager.checkLogin(activity, true)) {

                    if (PublicInfoDataService.getInstance().financeOpen(null)) {
                        homeAssetstab_switch(-1)
                    } else {
                        NToastUtil.showTopToastNet(this.mActivity, false, LanguageUtil.getString(context, "common_tip_notSupportOTC"))
                    }
                }
            }

            "financial_projects" -> {
                if (LoginManager.checkLogin(activity, true)) {
                    ArouterUtil.greenChannel(RoutePath.FinanceHomeActivity,Bundle())
                }
            }

            "QuickMoney" -> {
                if (LoginManager.checkLogin(activity, true)) {
                    ArouterUtil.greenChannel(RoutePath.FastHomeActivity,Bundle())
                }
            }
            //Financial management
            "account_freeStaking" -> {
                if (!LoginManager.checkLogin(context, true)) {
                    return
                }
                /**
                 *FreeStaking homepage
                 */
                ArouterUtil.greenChannel(RoutePath.FreeStakingActivity, null)
            }

            //Quick coin buying credit_ Card_ Deposit?
            "credit_card_deposit" -> {
                if (!LoginManager.checkLogin(context, true)) {
                    return
                }
                /**
                 *FreeStaking homepage
                 */
                ArouterUtil.greenChannel(RoutePath.QuickBuyCoinIndexActivity, null)
            }
            "reward_center" -> {
                RewardCenterActivity.enterActivity(mActivity!!)
            }

            "more" -> {
                popDialog = NewDialogUtils.showNewHomeGridDialog(requireActivity(),serviceDatas,object :
                    NewDialogUtils.DialogOnItemClickListener {
                    override fun clickItem(position: Int) {
                        popDialog?.dismiss()
                        routeApp(serviceDatas.get(position))
                    }
                })
            }

        }
    }

    private fun forwardContractTab() {
        var messageEvent = MessageEvent(MessageEvent.contract_switch_type)
        EventBusUtil.post(messageEvent)
    }

    private fun forwardMarketTab(coin: String) {
        var messageEvent = MessageEvent(MessageEvent.market_switch_type)
        messageEvent.msg_content = coin
        EventBusUtil.post(messageEvent)
    }

    /**
     *Obtain account information
     */
    var accountBalance = ""
    var accountFlat = ""
    private fun getAccountBalance() {
        var disposable = getMainModel().getTotalAsset(MyNDisposableObserver(accountBalanceReqType))
        addDisposable(disposable!!)

    }

    override fun onWsMessage(json: String) {
        handleData(json)
    }

    fun handleData(data: String) {
        Log.d(TAG,data)
        try {
            val json = JSONObject(data)
            if (!json.isNull("tick")) {
                doAsync {
                    val channel = json.optString("channel")
                    if(!WsLinkUtils.is24HLinkTicker(channel)) return@doAsync
                    val temp = homeCoins.filter {
                        channel.contains(it)
                    }
                    if (temp.isNotEmpty()) {
                        val dataDiff = callDataDiff(json)
                        if (dataDiff != null) {
                            val items = dataDiff.second
                            if (selectTopSymbol?.size != 0) {
                                showWsData(items)
                            }
                            if (fragments.size == 0) {
                                return@doAsync
                            }
                            val fragment = fragments[selectPostion]
                            if (fragment is NewHomeDetailFragmentItem) {
                                val tempMap = HashMap<String, JSONObject>()
                                LogUtil.e(TAG, "showWsData bottom ${items.size}")
                                for (item in items) {
                                    val channelNew = item.value.optString("channel").split("_")[1]
                                    val tempBottom = bottomCoins.filter {
                                        channelNew.contains(it)
                                    }
                                    if (tempBottom.isNotEmpty()) {
                                        tempMap.put(item.key, item.value)
                                    }
                                }
                                LogUtil.e(TAG, "showWsData bottom 过滤 ${tempMap.size}")
                                if (tempMap.isEmpty()) {
                                    return@doAsync
                                }
                                fragment.dropListsAdapter(tempMap,mActivity)
                            }
                            wsArrayTempList.clear()
                            wsArrayMap.clear()
                        }
                    }
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun showWsDataTx(item: JSONObject) {
        if (0 == selectTopSymbol?.size)
            return
        val dates = selectTopSymbol
        var isLoad = 0
        val channel = item.optString("channel").split("_")[1]
        val temp = dates?.filter {
            channel.contains(it.optString("symbol"))
        }
        if (temp != null && temp.isNotEmpty()) {
            val jsonObject = temp[0]
            val tick = item.optJSONObject("tick")
            tick?.apply {
                jsonObject.put("rose", this.optString("rose"))
                jsonObject.put("close", this.optString("close"))
                jsonObject.put("vol", this.optString("vol"))
                val index = dates.indexOf(jsonObject)
                dates.set(index, jsonObject)
                isLoad++
            }
        }
        if (isLoad != 0) {
            activity?.runOnUiThread {
                topSymbolAdapter?.setList(dates)
            }
        }

    }
    private fun showWsData(items: HashMap<String, JSONObject>) {
        if (0 == selectTopSymbol?.size)
            return
        val dates = selectTopSymbol
        var isLoad = 0
        for (item in items) {
            val channel = item.value.optString("channel").split("_")[1]
            val temp = dates?.filter {
                channel == it.optString("symbol")
            }
            if (temp != null && temp.isNotEmpty()) {
                val jsonObject = temp[0]
                val data = item.value
                val tick = data.optJSONObject("tick")
                tick?.apply {
                    jsonObject.put("rose", this.optString("rose"))
                    jsonObject.put("close", this.optString("close"))
                    jsonObject.put("vol", this.optString("vol"))
                    val index = dates.indexOf(jsonObject)
                    dates.set(index, jsonObject)
                    isLoad++
                }
            }
        }
        if (isLoad != 0) {
            activity?.runOnUiThread {
                topSymbolAdapter?.setList(dates)
            }
        }

    }


    private var bottomCoins = arrayListOf<String>()
    private var homeCoins = arrayListOf<String>()

    @Subscribe(threadMode = ThreadMode.POSTING)
    override fun onMessageEvent(event: MessageEvent) {
        super.onMessageEvent(event)
        if (MessageEvent.home_event_page_symbol_type == event.msg_type) {
            val mainActivity = activity
            if (mainActivity is NewMainActivity) {
                if (mainActivity.curPosition != 0) {
                    return
                }
            }
            val map = event.msg_content as HashMap<String, Array<String>>
            val curIndex = map.get("curIndex") as Int
            if (selectPostion != curIndex) {
                return
            }
            bottomCoins.clear()
            val array = map.get("symbols") as Array<String>
            for (item in array) {
                bottomCoins.add(item)
            }
            initSocket()
        }
        /*
         *Detect network status
         */
        if (MessageEvent.net_status_change == event.msg_type) {
            updateNetWrongLayout()
        }
    }

    fun updateNetWrongLayout(){
        if (mActivity?.let { NetUtil.isNetConnected(it) } == true) {
            net_wrong?.visibility = View.GONE
        } else {
            net_wrong?.visibility = View.VISIBLE
        }
    }

    private var isRose = true
    private fun loopData() {
        LogUtil.e(TAG, "tradeList value loopData  ${mIsVisibleToUser} ")
        if (!mIsVisibleToUser)
            return
        clearToolHttp()
        if (subscribeCoin == null || (subscribeCoin != null && subscribeCoin?.isDisposed != null && subscribeCoin?.isDisposed!!)) {
            subscribeCoin = Observable.interval(10L, CommonConstant.homeLoopTime, TimeUnit.SECONDS)//Sending Observeable integers at time intervals
                .observeOn(AndroidSchedulers.mainThread())//Switch to the main thread to modify the UI
                .subscribe {
                    getVPTab()
                }
        }
    }

    override fun onResume() {
        super.onResume()
        LogUtil.e(TAG, "onResume() ")
        initRedPacketView()
        getMessageCount()
    }

    private fun isRoseHttp() {
        if (!isRose) {
            return
        }
        isRose = false
        loopData()
    }

    /**
     *Obtaining data
     */
    private fun getVPTab() {
        return
        if (chooseType.size == 0) {
            return
        }
        val type = chooseType[selectPostion]
        var disposable = getMainModel().trade_list_v4(type, object : NDisposableObserver(null, false, type) {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                isRose = true
                val fragment = fragments[selectPostion]
                if (fragment is NewHomeDetailFragmentItem) {
                    if (type == this.getHomeTabType()) {
                        fragment.initV(jsonObject.optJSONArray("data"))
                    }
                }
                this.mapParams
            }

            override fun onResponseFailure(code: Int, msg: String?) {
                super.onResponseFailure(code, msg)
                isRose = true
            }
        })
        addDisposable(disposable)
    }

    private fun clearToolHttp() {
        if (subscribeCoin != null) {
            subscribeCoin?.dispose()
        }
    }

    override fun appBackGroundChange(isVisible: Boolean) {
        super.appBackGroundChange(isVisible)
        LogUtil.e(TAG, "appBackGroundChange==NewVersionHomepageFragment ${isVisible} ")
        mIsVisibleToUser = isVisible
        if (isVisible) {
            isRoseHttp()
        } else {
            clearToolHttp()
        }
    }


    private fun routeApp(obj: JSONObject?) {
        var httpUrl = obj?.optString("httpUrl") ?: ""
        var nativeUrl = obj?.optString("nativeUrl") ?: ""
        if (TextUtils.isEmpty(httpUrl)) {
            if (StringUtil.checkStr(nativeUrl) && nativeUrl.contains("?")) {
                enter2Activity(nativeUrl.split("?"))
            }
        } else {
            forwardWeb(obj)
        }
    }

    /**
     *Obtain top symbol 24-hour market
     */
    fun getTopData() {
        if (ApiConstants.HOME_VIEW_STATUS != ParamConstant.CONTRACT_HOME_PAGE) {
            var disposable = getMainModel().header_symbol(MyNDisposableObserver(getTopDataReqType))
            addDisposable(disposable)
        }
    }

    var klineTime = 0L
    private fun advertTime(isError: Boolean = false) {
        klineTime = System.currentTimeMillis() - klineTime
        val temp = if (isError) {
            4
        } else {
            val market = PublicInfoDataService.getInstance().getMarket(null)
            if (market == null) {
                5
            } else {
                if (fragments.isNotEmpty()) {
                    0
                } else {
                    3
                }

            }

        }
        sendWsHomepage(mIsVisibleToUser, temp, NetworkDataService.KEY_PAGE_HOME, NetworkDataService.KEY_HTTP_HOME, klineTime)
    }


    private val wsArrayTempList: ArrayList<JSONObject> = arrayListOf()
    private val wsArrayMap = hashMapOf<String, JSONObject>()
    private var wsTimeFirst: Long = 0L

    @Synchronized
    private fun callDataDiff(jsonObject: JSONObject): Pair<ArrayList<JSONObject>, HashMap<String, JSONObject>>? {
        wsArrayTempList.add(jsonObject)
        wsArrayMap.put(jsonObject.optString("channel", ""), jsonObject)
        if (wsArrayMap.size != 0) {
              return Pair(wsArrayTempList, wsArrayMap)
            }
//        if (System.currentTimeMillis() - wsTimeFirst >= 200L && wsTimeFirst != 0L) {
////        if (wsTimeFirst != 0L) {
////Greater than one second
//            wsTimeFirst = 0L
//            if (wsArrayMap.size != 0) {
//                return Pair(wsArrayTempList, wsArrayMap)
//            }
//        } else {
//            if (wsTimeFirst == 0L) {
//                wsTimeFirst = System.currentTimeMillis()
//            }
//            wsArrayTempList.add(jsonObject)
//            wsArrayMap.put(jsonObject.optString("channel", ""), jsonObject)
//        }
        return null
    }

    private fun getMessageCount() {
        if(UserDataService.getInstance().isLogined){
        HttpClient.instance.getReadMessageCount()
            .subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(object : NetObserver<ReadMessageCountBean>() {
                override fun onHandleSuccess(t: ReadMessageCountBean?) {
                    t ?: return
                    if (StringUtils.isNumeric(t.noReadMsgCount)) {
                        if (t.noReadMsgCount.toInt() > 0) {
                            //show
                            iv_red_dot_mail?.visibility=View.VISIBLE
                        } else {
                            //hide
                            iv_red_dot_mail?.visibility=View.GONE
                        }
                    }else{
                        //hide
                        iv_red_dot_mail?.visibility=View.GONE
                    }
                }

            })
        }

    }

}
