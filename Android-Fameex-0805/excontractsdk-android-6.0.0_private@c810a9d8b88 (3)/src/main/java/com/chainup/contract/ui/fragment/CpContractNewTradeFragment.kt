package com.chainup.contract.ui.fragment

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.text.TextUtils
import android.util.Log
import android.view.View
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.RelativeLayout
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.viewpager.widget.ViewPager
import com.chainup.contract.CapitalRateService
import com.chainup.contract.R
import com.chainup.contract.api.CpContractApiService
import com.chainup.contract.app.CpCommonConstant
import com.chainup.contract.app.CpParamConstant
import com.chainup.contract.base.CpNBaseFragment
import com.chainup.contract.eventbus.CpEventBusUtil
import com.chainup.contract.eventbus.CpMessageEvent
import com.chainup.contract.eventbus.CpNLiveDataUtil
import com.chainup.contract.kline.KlineHelper
import com.chainup.contract.net.CpJSONUtil
import com.chainup.contract.ui.activity.CpContractEntrustNewActivity
import com.chainup.contract.ui.activity.CpWebViewActivity
import com.chainup.contract.utils.ChainUpLogUtil
import com.chainup.contract.utils.CpBigDecimalUtils
import com.chainup.contract.utils.CpChainUtil
import com.chainup.contract.utils.CpClLogicContractSetting
import com.chainup.contract.utils.CpColorUtil
import com.chainup.contract.utils.CpContractBuyOrSellHelper
import com.chainup.contract.utils.CpFlutterEngineCacheUtil
import com.chainup.contract.utils.CpGuideUtil
import com.chainup.contract.utils.CpNToastUtil
import com.chainup.contract.utils.CpNumberUtil
import com.chainup.contract.utils.CpPreferenceManager
import com.chainup.contract.utils.CpSizeUtils
import com.chainup.contract.utils.CpWsLinkUtils
import com.chainup.contract.utils.getLineText
import com.chainup.contract.utils.setSafeListener
import com.chainup.contract.utils.toDinproMedium
import com.chainup.contract.view.CpDialogUtil
import com.chainup.contract.view.CpNewDialogUtils
import com.chainup.contract.view.dialog.CpTDialog
import com.chainup.contract.view.kline.KTimeTab
import com.chainup.contract.view.trade.CpNHorizontalDepthLayout
import com.chainup.contract.ws.CpWsContractAgentManager
import com.chainup.contract.ws.CpwsLinkType
import com.chainup.contract.ws.reConnectWSTAG
import com.chainup.kit.utils.PublicSizeUtil
import com.chainup.kit.utils.SkeletonUtil
import com.chainup.kit.utils.ToastUtils
import com.chainup.kit.views.PublicHeaderKit
import com.chainup.talkingdata.AppAnalyticsExt
import com.ethanhua.skeleton.SkeletonScreen
import com.google.android.material.appbar.AppBarLayout
import com.google.gson.GsonBuilder
import com.google.gson.reflect.TypeToken
import com.yjkj.chainup.kline.view.CpKLineChartView
import com.yjkj.chainup.manager.CpLanguageUtil
import com.yjkj.chainup.net_new.rxjava.CpNDisposableObserver
import com.yjkj.chainup.new_contract.activity.CpContractAssetRecordActivity
import com.yjkj.chainup.new_contract.activity.CpContractCalculateActivity
import com.yjkj.chainup.new_contract.activity.CpContractDetailActivity
import com.yjkj.chainup.new_contract.activity.CpContractSettingActivity
import com.yjkj.chainup.new_contract.activity.CpMarketDetail4Activity
import com.yjkj.chainup.new_contract.bean.CpCreateOrderBean
import io.flutter.embedding.android.FlutterView
import io.reactivex.Observable
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.cp_depth_horizontal_layout.view.trade_amount_view
import kotlinx.android.synthetic.main.cp_fragment_cl_contract_trade_new.activity_main
import kotlinx.android.synthetic.main.cp_fragment_cl_contract_trade_new.appbarlayout
import kotlinx.android.synthetic.main.cp_fragment_cl_contract_trade_new.bottom_klineView
import kotlinx.android.synthetic.main.cp_fragment_cl_contract_trade_new.community_container_tab_container
import kotlinx.android.synthetic.main.cp_fragment_cl_contract_trade_new.fl_skeleton
import kotlinx.android.synthetic.main.cp_fragment_cl_contract_trade_new.ll_all_entrust_order
import kotlinx.android.synthetic.main.cp_fragment_cl_contract_trade_new.ll_collapsing
import kotlinx.android.synthetic.main.cp_fragment_cl_contract_trade_new.mHeaderKit
import kotlinx.android.synthetic.main.cp_fragment_cl_contract_trade_new.mklineView
import kotlinx.android.synthetic.main.cp_fragment_cl_contract_trade_new.rl_tab_view
import kotlinx.android.synthetic.main.cp_fragment_cl_contract_trade_new.swipeLayout
import kotlinx.android.synthetic.main.cp_fragment_cl_contract_trade_new.tab_order
import kotlinx.android.synthetic.main.cp_fragment_cl_contract_trade_new.top_border
import kotlinx.android.synthetic.main.cp_fragment_cl_contract_trade_new.vp_order
import kotlinx.android.synthetic.main.cp_fragment_cl_contract_trade_new.vs_announcement
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.ll_quantity_type
import kotlinx.android.synthetic.main.cp_trade_header_tag.symbol_tag
import kotlinx.android.synthetic.main.layout_announcement.cl_view
import kotlinx.android.synthetic.main.layout_announcement.iv_close
import kotlinx.android.synthetic.main.layout_announcement.tv_content
import okhttp3.ResponseBody
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode
import org.jetbrains.anko.backgroundColor
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject
import java.math.BigDecimal
import java.util.concurrent.TimeUnit
import kotlin.math.abs


/**
 * Contract
 */
class CpContractNewTradeFragment : CpNBaseFragment(), CpWsContractAgentManager.WsResultCallback,KlineHelper.OnKlineReload {

    override fun setContentView() = R.layout.cp_fragment_cl_contract_trade_new

    private var v_horizontal_depth:CpNHorizontalDepthLayout? = null

    var currentSymbol = "e_btcusdt"
    var quote = ""
    var base = ""
    var mSymbol = "btcusdt"
    val prevKlineSubInfoMap:HashMap<String,String> by lazy { hashMapOf() }
    var mContractId = -1
        set(value) {
            field = value
            currentEntrustNewFragment.mContractId = value
            planEntrustNewFragment.mContractId = value
        }

    private val currentEntrustNewFragment:CpContractCurrentEntrustNewFragment by lazy { CpContractCurrentEntrustNewFragment() }
    private val planEntrustNewFragment:CpContractPlanEntrustNewFragment by lazy { CpContractPlanEntrustNewFragment() }
    var mContractName = ""
    var depthLevel = "0"
    var contractType = "0"
    var symbolPricePrecision = 2
    var mMultiplierPrecision = 0
    var couponTag = 1 //Experience Gold ID: 0: Not claimed 1: Received
    var openContract = 0//Has contract transaction been activated? 1 has been activated, 0 has not been activated
    var futuresLocalLimit = 0 //0 is not within the restricted range of the 1 area
    var authLevel = 0 //0. Not audited, 1. Passed, 2. Not passed, 3. Not certified
    var priceBasis = 0 //0Latest price1 Tag price
    var subscribe: Disposable? = null
    var subscribePriceList: Disposable? = null
    private var mKlineHelper:KlineHelper? = null

    private var isfirstKHistory:Boolean = true
    private var isMoreHistory:Boolean = false

    //Record the ws depth String, which is used here to transfer the details to the k line. [Test feedback: ws may be slow and the details cannot be flushed out. It is necessary to bring in the depth from the fragment]
    private var prevWsDataStringForDepth:String? = null

    //Whether to turn on the small K line 0, turn off 1, and turn it on (the fault tolerance when - 1 is null is equivalent to not turning it on)
    var chartFlag:Int = 1

    private var smallKline:FlutterView? = null
    private var curTime: String = ""

    private var disposableLoader:Disposable? = null
    private var skeletionScreen:SkeletonScreen? = null

    //is visible announcement?
    private var announcementPath:String = ""

    private var accountList = ""

    private var serviceMillSecondTime:Long = 0L
    private var cacheCurKTime:String? = ""
    override fun loadData() {
        super.loadData()
        CpWsContractAgentManager.instance.addWsCallback(this)
        CpNLiveDataUtil.observeData(this) {
            if (it.msg_type == CpMessageEvent.sl_contract_ws_reLink_finish){
                if(it.msg_content is CpwsLinkType){
                    val linkType = it.msg_content as CpwsLinkType
                    if(linkType == CpwsLinkType.REFRESH){
                        doRefshing()
                    }
                }
            }
        }

    }

    override fun initView() {
        skeletionScreen =
            SkeletonUtil.showView(fl_skeleton, R.layout.skeleton_contract_view)
                .show()
        v_horizontal_depth?.isLoading = true
        initTabInfo()
        initAnnouncement()

        appbarlayout.addOnOffsetChangedListener(object: AppBarLayout.OnOffsetChangedListener {
            override fun onOffsetChanged(appBarLayout: AppBarLayout?, verticalOffset: Int) {
                val newVerticalOffset = abs(verticalOffset)
                val totalScrollRange = appBarLayout?.totalScrollRange?:0
                Log.d(TAG,"verticalOffset=$verticalOffset appBarLayout=${appBarLayout?.measuredHeight} totalScrollRange=${appBarLayout?.totalScrollRange}")
                if(verticalOffset<0){
                    top_border.visibility = View.GONE
                }else{
                    val contractChartPosition = CpClLogicContractSetting.getContractChartPosition(mActivity)
                    if(chartFlag==1 && contractChartPosition==0){
                        top_border.visibility = View.VISIBLE
                    }else{
                        top_border.visibility = View.GONE
                    }
                }

                if(newVerticalOffset>=totalScrollRange){
                    community_container_tab_container.backgroundColor = ContextCompat.getColor(mActivity!!,R.color.main_bg_color)
                    rl_tab_view.background = ContextCompat.getDrawable(mActivity!!,R.drawable.bg_contract_page_top_radius)
                }else{
                    community_container_tab_container.backgroundColor = ContextCompat.getColor(mActivity!!,R.color.bg_card_color)
                    rl_tab_view.background = null
                }
            }
        })

        ll_all_entrust_order.setSafeListener {
            if (!CpClLogicContractSetting.isLogin()) {
                CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.sl_contract_go_login_page))
            } else if (openContract == 0) {
                CpDialogUtil.showCreateContractDialog(requireActivity(), object : CpNewDialogUtils.DialogBottomListener {
                    override fun sendConfirm() {
                        CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.sl_contract_open_contract_event))
                    }
                })
            } else {
                CpContractEntrustNewActivity.show(mActivity!!, mContractId, mSymbol)
            }
        }
        swipeLayout?.setEnableLoadMore(false)
        swipeLayout.setOnRefreshListener{
//            adapter.clearData()
            doRefshing()
        }
        vs_announcement.setOnInflateListener { stub, inflated ->
            cl_view?.setOnClickListener {
                if("".equals(announcementPath)) return@setOnClickListener
                CpWebViewActivity.enterActivity(requireActivity(), announcementPath)
            }
            iv_close?.setOnClickListener {
                if(CpClLogicContractSetting.isLogin() && CpClLogicContractSetting.isOpenContract()){
                    getContractModel().closeAnnouncement(object :CpNDisposableObserver(){
                        override fun onResponseSuccess(jsonObject: JSONObject?) {
                            vs_announcement.visibility = View.GONE
                            Log.d(TAG,"iv_close.setOnClickListener>>>jsonObject=$jsonObject")
                        }

                        override fun onResponseFailure(code: Int, msg: String?) {
                            super.onResponseFailure(code, msg)
                            Log.e(TAG,"iv_close.setOnClickListener>>>code=$code,msg=$msg")
                        }
                    })
                }else{
                    vs_announcement.visibility = View.GONE
                }
            }
        }

        mHeaderKit?.run {
            setContractHeaderTag(R.layout.cp_trade_header_tag)
            setBackIconGone(true)
            listener = object : PublicHeaderKit.IOnBackClickListener{
                //Switch currency pairs
                override fun onFilterTitle(view: View) {
                    super.onFilterTitle(view)
                    showLeftCoinWindow()
                }

                //iv_more
                override fun onRightBtn(view: View) {
                    super.onRightBtn(view)
                    var moreMenu: ArrayList<Map<String,Any>> = arrayListOf()
                    moreMenu.add(hashMapOf("name" to CpLanguageUtil.getString(context, "cp_extra_text142"),"icon" to R.drawable.contract_icon_morefunctions_fundstransfer))
                    moreMenu.add(hashMapOf("name" to CpLanguageUtil.getString(context, "cp_extra_text143"),"icon" to R.drawable.contract_icon_morefunctions_moneyflowing))
                    moreMenu.add(hashMapOf("name" to CpLanguageUtil.getString(context, "cp_contract_setting_text13"),"icon" to R.drawable.contract_icon_morefunctions_preference))
                    moreMenu.add(hashMapOf("name" to CpLanguageUtil.getString(context, "cp_calculator_text17"),"icon" to R.drawable.contract_icon_morefunctions_calculator))
                    moreMenu.add(hashMapOf("name" to CpLanguageUtil.getString(context, "cp_contract_info_text1"),"icon" to R.drawable.contract_icon_morefunctions_infomation))
                    moreMenu.add(hashMapOf("name" to CpLanguageUtil.getString(context, "cp_extra_text144"),"icon" to R.drawable.contract_icon_morefunctions_contractguide))

                    var dialog: CpTDialog? = null
                    dialog = CpNewDialogUtils.createContractSettingDialog(mActivity!!,mContractId,moreMenu,object:CpNewDialogUtils.DialogOnclickListenerTx{
                        override fun clickItem(data: ArrayList<Map<String,Any>>, item: Int) {
                            dialog?.dismiss()
                            when(item){
                                //Fund transfer
                                0 -> {
                                    if (!CpClLogicContractSetting.isLogin()) {
                                        CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.sl_contract_go_login_page))
                                        return
                                    }
                                    if (openContract == 0) {
                                        CpEventBusUtil.post(
                                            CpMessageEvent(
                                                CpMessageEvent.sl_contract_create_account_event
                                            )
                                        )
                                    } else {
                                        //Fund transfer
                                        toTransferActivity()
                                    }
                                }
                                //Capital flow
                                1 -> {
                                    if (mContractId > 0) {
                                        if (!CpClLogicContractSetting.isLogin()) {
                                            CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.sl_contract_go_login_page))
                                            return
                                        }
                                        if (openContract == 0) {
                                            CpEventBusUtil.post(
                                                CpMessageEvent(
                                                    CpMessageEvent.sl_contract_create_account_event
                                                )
                                            )
                                        } else {
                                            CpContractAssetRecordActivity.show(context as Activity)
                                        }
                                    }
                                }
                                //Contract Settings
                                2 -> {
                                    if (!CpClLogicContractSetting.isLogin()) {
                                        CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.sl_contract_go_login_page))
                                        return
                                    }
                                    if (openContract == 0) {
                                        CpEventBusUtil.post(
                                            CpMessageEvent(
                                                CpMessageEvent.sl_contract_create_account_event
                                            )
                                        )
                                    } else {
                                        CpContractSettingActivity.show(context as Activity, mContractId, openContract)
                                    }
                                }
                                //Contract Calculator
                                3 -> {
                                    if (mContractId > 0) {
                                        CpContractCalculateActivity.show(context as Activity, mContractId, accountList)
                                    }
                                }
                                //Contract Information
                                4 -> {
                                    if (mContractId > 0) {
                                        CpContractDetailActivity.show(context as Activity, mContractId)
                                    }
                                }
                                //The last entry into the h5 ->contract guide
                                5 -> {
                                   toContractGuide()
                                }

                            }
                        }
                    })
                }

                //Details of line k
                override fun onSubRightBtn(view: View) {
                    super.onSubRightBtn(view)
                    if (!CpChainUtil.isFastClick()) {
                        val mIntent = Intent(mActivity!!, CpMarketDetail4Activity::class.java)
                        mIntent.putExtra(CpParamConstant.symbol, currentSymbol)
                        mIntent.putExtra("contractId", mContractId)
                        mIntent.putExtra("baseSymbol", base)
                        mIntent.putExtra("quoteSymbol", quote)
                        startActivity(mIntent)
                    }

                }
            }
        }
        initKlineByUserConfig()
    }

    //Create a small K line according to the configuration
    private fun initKlineByUserConfig(){
        chartFlag = CpClLogicContractSetting.getContractChartOff(mActivity)
        if(chartFlag==0 || chartFlag==-1){
            return
        }
        //0 top 1 bottom
        when(CpClLogicContractSetting.getContractChartPosition(mActivity)){
            0 -> createTopKline()
            1 -> createBottomKline()
        }
    }

    private fun doRefshing(){
        Log.e(reConnectWSTAG,"trigger refresh:doRefshing()>>>")
        val contractJsonStr = CpClLogicContractSetting.getContractJsonListStr(activity)
        val mContractList = if("".equals(contractJsonStr)) JSONArray() else JSONArray(contractJsonStr)
        initCoin(mContractList)
        if(mContractList.length() > 0) {
            addDisposable(
                getContractPublicInfoObservable()
                    .subscribeOn(Schedulers.io())
                    .observeOn(Schedulers.io())
                    .subscribe({
                        saveContractPublicInfo(it){ }
                    },{
                        it.printStackTrace()
                    })
            )
        }

        v_horizontal_depth?.setLoginContractLayout(CpClLogicContractSetting.isLogin(), openContract == 1)
    }


    fun initAnnouncement(){
        //contract_demand Announcement
        val islogin = CpClLogicContractSetting.isLogin()
        val consumer = object :CpNDisposableObserver(){
            override fun onResponseSuccess(jsonObject: JSONObject?) {
                if(jsonObject != null) {
                    val data = jsonObject.optJSONObject("data")
                    if(data != null) {
                        val content = data.optString("content")
                        announcementPath = data.optString("url")
                        vs_announcement.visibility = View.VISIBLE
                        tv_content?.text = content
                    }else{
                        announcementPath = ""
                        vs_announcement.visibility = View.GONE
                    }
                }
            }
        }
        if(islogin && CpClLogicContractSetting.isOpenContract()){
            getContractModel().getAnnouncement(if(islogin) 1 else 0, consumer = consumer)
        }else{
            getContractModel().getCommonAnnouncement(if(islogin) 1 else 0, consumer = consumer)
        }
    }

    //Create the kline located below
    private fun createBottomKline() {
        top_border.visibility = View.GONE
        resetKline()
        //Add a timescale first tab
        val timeTab = KTimeTab(requireContext())
        val lparams = FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT,FrameLayout.LayoutParams.WRAP_CONTENT)
        timeTab.backgroundColor = ContextCompat.getColor(mActivity!!,R.color.tabbar_bg_color)
        timeTab.setBottomBorderVisible(true)
        bottom_klineView.addView(timeTab,lparams)
        //Add k line
        val kparams = FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT,PublicSizeUtil.dp2px(mActivity,180.0f))
        kparams.topMargin = CpSizeUtils.dp2px(36f)

        setMainContentLayoutMarginByBottomKline()
        smallKline = CpFlutterEngineCacheUtil.getFlutterKlineView(mActivity)

        bottom_klineView.addView(smallKline,kparams)

        mKlineHelper = KlineHelper.init(timeTab,smallKline!!).also {
            it.listener = this
            reload()
        }
    }

    //Create a kline located above
    private fun createTopKline() {
        top_border.visibility = View.VISIBLE
        resetKline()
        val timeTab = KTimeTab(requireContext())
        val params = LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT,LinearLayout.LayoutParams.WRAP_CONTENT)
        mklineView.addView(timeTab,params)

        //Add a line id>>mklineView to the layout
        smallKline = CpFlutterEngineCacheUtil.getFlutterKlineView(mActivity)
        val lParams = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            PublicSizeUtil.dp2px(mActivity,180.0f)
        )
        smallKline?.layoutParams = lParams

        mklineView.addView(smallKline)

        mKlineHelper = KlineHelper.init(timeTab,smallKline!!).also {
            it.listener = this
            reload()
        }
    }

    override fun onToggleOpen(isOpen: Boolean) {
        val contractChartPosition = CpClLogicContractSetting.getContractChartPosition(mActivity)
        if(contractChartPosition==1){
            setMainContentLayoutMarginByBottomKline()
            //Coordinate Layout Bottom Margin
            val lyparams = activity_main.layoutParams as RelativeLayout.LayoutParams
            lyparams.bottomMargin = bottom_klineView.measuredHeight
            activity_main.layoutParams = lyparams
        }
        //Set Bottom Border Toggle Display
        if(contractChartPosition==0) mKlineHelper?.kTimeTab?.setBottomBorderVisible(isOpen)

        if(isOpen) {
            setKTimePosition()
            Handler(Looper.getMainLooper()).postDelayed({
                CpFlutterEngineCacheUtil.getPlugin(requireContext(),CpFlutterEngineCacheUtil.contract_kline_engine_id).updateMainIndexVisible()
            },500L)
        }
//        smallKline?.resetAllStatus()
    }

    //Set the bottom margin of the content area
    fun setMainContentLayoutMarginByBottomKline(){
        //Measure the bottom first_ klineView
        val intw = View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED)
        val inth = View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED)
        bottom_klineView.measure(intw, inth)

        //Coordinate Layout Bottom Margin
        val lyparams = activity_main.layoutParams as RelativeLayout.LayoutParams
        lyparams.bottomMargin = bottom_klineView.measuredHeight
        activity_main.layoutParams = lyparams
    }

    //Reset All
    private fun resetKline(){
        mklineView.removeAllViews()
        bottom_klineView.removeAllViews()
        smallKline?.detachFromFlutterEngine()
        mKlineHelper = null
        //Reset Coordinated Layout Bottom Margin
        val lyparams = activity_main.layoutParams as RelativeLayout.LayoutParams
        lyparams.bottomMargin = 0
        activity_main.layoutParams = lyparams
    }


    override fun reload() {
        KlineHelper.klinePosition = CpClLogicContractSetting.getContractChartPosition(mActivity)
    }

    override fun doAppBarExpanded() {
//        appbarlayout.setExpanded(true,true)
    }

    override fun clickTime(timeBuff: String) {
        switchKLineScale(timeBuff)
    }

    private fun unSubPrevKlineNewLink() {
        val prevSymbol = prevKlineSubInfoMap["symbol"] ?: ""
        val prevTime = prevKlineSubInfoMap["curTime"] ?: ""
        if(!"".equals(prevSymbol) && !"".equals(prevTime)){
            val ptime = prevTime.replace("line","1min")
            Log.d(TAG,"unsub kline>>> $prevSymbol")
            CpWsContractAgentManager.instance.sendData(CpWsLinkUtils.getKlineNewLink(prevSymbol, ptime,false))
        }else{
            Log.d(TAG,"unsub kline empty!!!")
        }
    }


    private fun showLeftCoinWindow() {
        if (CpChainUtil.isFastClick())
            return
        val mContractList = CpClLogicContractSetting.getContractJsonListStr(activity)
        if (!TextUtils.isEmpty(mContractList)) {
            val mContractCoinSearchDialog = CpContractCoinSearchDialog()
            val bundle = Bundle()
            bundle.putString(CpContractCoinSearchDialog.contractList, mContractList)
            bundle.putString(CpContractCoinSearchDialog.focusViewName, this::class.java.simpleName)
            mContractCoinSearchDialog.arguments = bundle
            mContractCoinSearchDialog.showDialog(childFragmentManager, currentSymbol)
        }
    }


    private var mFragments: ArrayList<Fragment>? = null
    private fun initTabInfo() {
        mFragments = ArrayList<Fragment>().apply {
            add(CpContractHoldNewFragment.newInstance(mContractId))
            add(currentEntrustNewFragment)
            add(planEntrustNewFragment)
        }

        tab_order?.run{
            val tabTitles = arrayOf(CpLanguageUtil.getString(context,"cp_order_text1"), CpLanguageUtil.getString(context,"cp_order_text2"), CpLanguageUtil.getString(context,"cp_order_text3"))
            setViewPager(vp_order, tabTitles, activity, mFragments)
            for (i in 0 until tabCount) getTitleView(i).toDinproMedium()
        }

        vp_order.addOnPageChangeListener(object : ViewPager.OnPageChangeListener {
            override fun onPageScrollStateChanged(state: Int) {
            }

            override fun onPageScrolled(position: Int, positionOffset: Float, positionOffsetPixels: Int) {
            }

            override fun onPageSelected(position: Int) {
                if (position != 0) {
                    if (!CpClLogicContractSetting.isLogin()) {
                        CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.sl_contract_go_login_page))
                        return
                    }
                    if (openContract == 0) {
                        CpDialogUtil.showCreateContractDialog(activity!!, object : CpNewDialogUtils.DialogBottomListener {
                            override fun sendConfirm() {
                                CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.sl_contract_open_contract_event))
                            }
                        })
                        return
                    }
                }
            }

        })
    }


    private fun getContractPublicInfoObservable():Observable<ResponseBody> {
        return getContractModel().httpHelper.getContractNewUrlService(CpContractApiService::class.java)
            .getPublicInfo(getContractModel().getBaseReqBody())
    }


    private fun loopStart() {
        loopStop()
        subscribe = Observable.interval(0L, CpCommonConstant.capitalRateLoopTime, TimeUnit.SECONDS)
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe {
                    getContractUserConfig()
                    getMarkertInfo()
                    getPositionAssetsList()
                    getCurrentOrderList()
                    getCurrentPlanOrderList()
                }
        subscribePriceList = Observable.interval(0L, 1, TimeUnit.SECONDS)
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe {
                    getPriceList()
                }
    }

    private fun getContractUserConfig() {
        if (!CpClLogicContractSetting.isLogin()) {
            CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.sl_contract_logout_event))
            resetTabTitle()
            v_horizontal_depth?.setUserLogout()
            hideSkeletion()
            return
        }
        addDisposable(
                getContractModel().getUserConfig(mContractId.toString(),
                        consumer = object : CpNDisposableObserver() {
                            override fun onResponseSuccess(jsonObject: JSONObject?) {
                                jsonObject?.optJSONObject("data")?.run {
                                    openContract = optInt("openContract")
                                    couponTag = optInt("couponTag")
                                    futuresLocalLimit = optInt("futuresLocalLimit")
                                    authLevel = optInt("authLevel")
                                    priceBasis = optInt("priceBasis")
                                    v_horizontal_depth?.setLoginContractLayout(CpClLogicContractSetting.isLogin(), openContract == 1)
                                    v_horizontal_depth?.setUserConfigInfo(this)
                                    receiveCoupon()
                                    CpClLogicContractSetting.setContractIsOpen(requireActivity(),openContract)
                                    val msgEvent = CpMessageEvent(CpMessageEvent.sl_contract_priceBasis_event)
                                    msgEvent.msg_content = priceBasis
                                    CpEventBusUtil.post(msgEvent)
                                    hideSkeletion()
                                }

                            }

                            override fun onResponseFailure(code: Int, msg: String?) {
                                super.onResponseFailure(code, msg)
                                hideSkeletion()
                                // 10002 -> user not login
                                // 100106 -> user not exist
                                if(code == 10002 || code == 100106){
                                    //Unable to clear the contract token here will cause the CpNHorizontalDepthLayout dispatchTouchEvent to consume the event, resulting in the transaction area being unable to click and triggering login, as the token of the main package has not been cleared
                                    if(code == 100106){
                                        CpClLogicContractSetting.cleanToken()
                                        CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.sl_contract_logout_event))
                                    }
                                    CpClLogicContractSetting.cleanToken()
                                    val userDataBridgeImpl = CpClLogicContractSetting.getInstance().userDataBridgeImpl
                                    if(userDataBridgeImpl!=null){
                                        CpClLogicContractSetting.getInstance().userDataBridgeImpl.clearToken()
                                    }
                                    loopStop()

                                    v_horizontal_depth?.setUserLogout()
                                    resetTabTitle()

                                }
                            }
                        })
        )
    }
    private fun hideSkeletion(){
        v_horizontal_depth?.isLoading = false
        if(skeletionScreen != null) {
            SkeletonUtil.hideSkeleton(skeletionScreen!!)
            skeletionScreen = null
        }
    }

    //Reset tab
    private fun resetTabTitle(){
        tab_order.getTitleView(0).text = CpLanguageUtil.getString(context,"cp_order_text1")
        tab_order.getTitleView(1).text = CpLanguageUtil.getString(context,"cp_order_text2")
        tab_order.getTitleView(2).text = CpLanguageUtil.getString(context,"cp_order_text3")
    }

    private fun getMarkertInfo() {
        addDisposable(
                getContractModel().getMarkertInfo(mSymbol, mContractId.toString(),
                        consumer = object : CpNDisposableObserver() {
                            override fun onResponseSuccess(jsonObject: JSONObject?) {
                                jsonObject?.optJSONObject("data")?.run {
                                    activity?.runOnUiThread {
                                        v_horizontal_depth?.setMarkertInfo(this)
                                    }
                                }
                            }
                        })
        )
    }

    private fun getPositionAssetsList() {
        if (!CpClLogicContractSetting.isLogin()){
            v_horizontal_depth?.setUserAssetsInfo(null)
            return
        }
        if (openContract == 0){
            v_horizontal_depth?.setUserAssetsInfo(null)
            return
        }
        addDisposable(
                getContractModel().getPositionAssetsList(
                        consumer = object : CpNDisposableObserver(true) {
                            override fun onResponseSuccess(jsonObject: JSONObject?) {
                                jsonObject?.optJSONObject("data")?.run {

                                    if(!isNull("accountList")){
                                        accountList = optJSONArray("accountList")?.toString()?:""
                                    }

                                    val mOrderListJson = optJSONArray("positionList")
                                    var num=0
                                    for (i in 0..(mOrderListJson.length() - 1)) {
                                        var obj = mOrderListJson.getJSONObject(i)
                                        val contractId = obj.optInt("contractId")
                                        var isChecked= CpPreferenceManager.getInstance(mActivity).getSharedBoolean(
                                            CpPreferenceManager.PREF_SHOW_CURRENT_CONTRACT, false)
                                        if (isChecked){
                                            if (mContractId==contractId){
                                                num++
                                            }
                                        }else{
                                            num++
                                        }
                                    }
                                    tab_order.getTitleView(0).text = CpLanguageUtil.getString(context,"cp_order_text1") + "(" +num+")"

                                    val msgEvent = CpMessageEvent(CpMessageEvent.sl_contract_refresh_position_list_event)
                                    msgEvent.msg_content = this
                                    CpEventBusUtil.post(msgEvent)
                                    v_horizontal_depth?.setUserAssetsInfo(this)
                                }
                            }
                        })
        )
    }
    private fun getPriceList() {
//        if (!CpClLogicContractSetting.isLogin()) return
//        if (openContract == 0) return
        addDisposable(
                getContractModel().getPriceList(
                        consumer = object : CpNDisposableObserver(true) {
                            override fun onResponseSuccess(jsonObject: JSONObject?) {
                                jsonObject?.optJSONArray("data")?.run {
                                    val msgEvent = CpMessageEvent(CpMessageEvent.sl_contract_refresh_price_list_event)
                                    msgEvent.msg_content = this
                                    CpEventBusUtil.post(msgEvent)
                                    for (i in 0..(this?.length() - 1)) {
                                        var positionListobj = this?.getJSONObject(i)
                                        val buff = positionListobj.optJSONObject(mContractName)
                                        if (buff != null) {
                                            val tagPrice = buff.optString("tagPrice")
                                            v_horizontal_depth?.setTagPrice(tagPrice)
                                        }
                                    }
                                }
                            }
                        })
        )
    }

    private fun getCurrentOrderList() {
        if (mContractId == -1) return
        if (!CpClLogicContractSetting.isLogin()) return
        if (openContract == 0) return


        val cid = mFragments?.let {
            val currentEntrustNewFragment = it[1] as CpContractCurrentEntrustNewFragment
            if(currentEntrustNewFragment.isCurrentContract!!){
                mContractId.toString()
            }else{
                ""
            }
        } ?: mContractId.toString()


        addDisposable(
                getContractModel().getCurrentOrderList(cid, 0, 1,
                        limit = 100,
                        consumer = object : CpNDisposableObserver(true) {
                            override fun onResponseSuccess(jsonObject: JSONObject?) {
                                jsonObject?.optJSONObject("data")?.run {
                                    tab_order.getTitleView(1).text = CpLanguageUtil.getString(context,"cp_order_text2") + "(" + this.optString("count")+")"
                                    val msgEvent = CpMessageEvent(CpMessageEvent.sl_contract_refresh_current_entrust_list_event)
                                    msgEvent.msg_content = this
                                    CpEventBusUtil.post(msgEvent)
                                    v_horizontal_depth?.setCurrentOrderJsonInfo(this)
                                }
                            }
                        }
                )
        )
    }

    private fun getCurrentPlanOrderList() {
        if (!CpClLogicContractSetting.isLogin()) return
        if (openContract == 0) return

        val cid = mFragments?.let {
            val planEntrustNewFragment = it[2] as CpContractPlanEntrustNewFragment
            if(planEntrustNewFragment.isCurrentContract!!){
                mContractId.toString()
            }else{
                ""
            }
        } ?: mContractId.toString()

        addDisposable(
                getContractModel().getCurrentPlanOrderList(cid,0, 1,
                        limit = 100,
                        consumer = object : CpNDisposableObserver(true) {
                            override fun onResponseSuccess(jsonObject: JSONObject?) {
                                jsonObject?.optJSONObject("data")?.run {
                                    tab_order.getTitleView(2).text = CpLanguageUtil.getString(context,"cp_order_text3") + "(" + this.optString("count")+")"
                                    val msgEvent = CpMessageEvent(CpMessageEvent.sl_contract_refresh_plan_entrust_list_event)
                                    msgEvent.msg_content = this
                                    CpEventBusUtil.post(msgEvent)
                                }
                            }
                        })
        )
    }

    private fun doCreateContractAccount() {

        if (authLevel!=3){
            if (authLevel==0){
                kycTips(CpLanguageUtil.getString(context,"cp_kyc_4"))
            }else if (authLevel==1){
                //Approved
                if (futuresLocalLimit==1){
                    //Prompt within the area limit
                    kycTips(CpLanguageUtil.getString(context,"cp_kyc_3"))

                }else{
                    //Not within regional limits
                    addDisposable(
                            getContractModel().createContract(
                                    consumer = object : CpNDisposableObserver(true) {
                                        override fun onResponseSuccess(jsonObject: JSONObject?) {
                                            CpClLogicContractSetting.setContractIsOpen(requireActivity(),1)
                                            CpNewDialogUtils.createContractOpenSuccessDialog(
                                                requireContext(),
                                                callback = object : CpNewDialogUtils.DialogOnItemClickListener{
                                                    override fun clickItem(position: Int) {
                                                        when(position){
                                                            //Click "To Transfer" to enter the fund transfer page.
                                                            0 -> {
                                                                toTransferActivity()
                                                            }
                                                            //Click "Understanding Contract Trading Rules" to enter the contract guide page, and enter the contract guide link in the corresponding language according to the currently set language
                                                            1 -> {
                                                                toContractGuide()
                                                            }
                                                        }
                                                    }

                                                }
                                            )
                                            getContractUserConfig()
                                            initAnnouncement()
                                        }
                                    })
                    )
                }
            }else if (authLevel==2){
                //Review failed
                if (futuresLocalLimit==1){
                    //Prompt within the area limit
                    kycTips(CpLanguageUtil.getString(context,"cp_kyc_3"))
                }else{
                    goKycTips(CpLanguageUtil.getString(context,"cp_kyc_5"))
                }

            }else{
                kycTips(CpLanguageUtil.getString(context,"cp_kyc_7"))
            }
        }else{
            goKycTips(CpLanguageUtil.getString(context,"cp_kyc_2"))
        }
    }


    //Contract Guide
    private fun toContractGuide(){
        val url = "https://futuresdoc.gitbook.io/help-center/"
        val mInfoUrl = CpClLogicContractSetting.getContractInfoUrlStr(context)
        CpWebViewActivity.enterActivity(context as Activity, if (TextUtils.isEmpty(mInfoUrl)) url else mInfoUrl)
    }

    private fun kycTips(s: String) {
        CpNewDialogUtils.showDialog(
                requireContext(),
                s,
                true,
                null,
                CpLanguageUtil.getString(context,"cp_extra_text27"),
                CpLanguageUtil.getString(context,"cp_overview_text56")
        )
    }

    /**
     *Prompt for insufficient balance
     */
    private fun balanceInsufficient() {
        CpNewDialogUtils.showDialog(
                requireContext(),
            CpLanguageUtil.getString(context,"cp_set_4"),
                false,
                object : CpNewDialogUtils.DialogBottomListener{
                    override fun sendConfirm() {
                        toTransferActivity()
                    }
                },
            CpLanguageUtil.getString(context,"cp_str_insufficient"),
                    CpLanguageUtil.getString(context,"cp_assets_text7"),
                CpLanguageUtil.getString(context,"cp_overview_text56"),


        )
    }

    private fun toTransferActivity(){
        val mMessageEvent = CpMessageEvent(CpMessageEvent.sl_contract_go_fundsTransfer_page)
        mMessageEvent.msg_content = Bundle().apply {
            val contractJSON = CpClLogicContractSetting.getContractJsonStrById(context as Activity, mContractId)
            putString("originCoin",contractJSON.optString("originalCoin").toString())
            putString("marginCoin",contractJSON.optString("originalCoin").toString())
        }
        CpEventBusUtil.post(mMessageEvent)
    }
    private fun goKycTips(s: String) {
        CpNewDialogUtils.showDialog(
                requireContext(),
                s.replace("\n", "<br/>"),
                false,
                object : CpNewDialogUtils.DialogBottomListener {
                    override fun sendConfirm() {
                        CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.sl_contract_go_kyc_page)
                        )
                    }
                },
                CpLanguageUtil.getString(context,"cp_kyc_1"),
                CpLanguageUtil.getString(context,"cp_kyc_6"),
                CpLanguageUtil.getString(context,"cp_overview_text56")
        )
    }

    private fun modifyMarginModel(marginModel: String) {
        addDisposable(getContractModel().modifyMarginModel(mContractId.toString(), marginModel,
                consumer = object : CpNDisposableObserver(true) {
                    override fun onResponseSuccess(jsonObject: JSONObject?) {
                        getContractUserConfig()
                    }
                }))
    }

    private inline fun saveContractPublicInfo(repBody: ResponseBody,crossinline action:((list:JSONArray) -> Unit)) {
        Log.d(TAG,"saveContractPublicInfo at Thread: >>>${Thread.currentThread().name}")
        val jsonObj = CpJSONUtil.parse(repBody, false)
        if (null != jsonObj) {
            val code = jsonObj.optString("code")
            if ("0".equals(code, true)) {
                jsonObj.optJSONObject("data")?.run {
                    val contractList = optJSONArray("contractList")
                    if (contractList.length()==0||contractList==null){
                        return
                    }
                    serviceMillSecondTime = optLong("currentTimeMillis")
                    val marginCoinList = optJSONArray("marginCoinList")
                    CpClLogicContractSetting.setContractInfoUrlStr(context, optString("contractProInfo"))
                    CpClLogicContractSetting.setContractJsonListStr(context, contractList.toString())
                    CpClLogicContractSetting.setContractMarginCoinListStr(context, marginCoinList.toString())
                    action.invoke(contractList)
                }
            }
        }
    }

    private fun createHorizontalDepthLayout() {
        if(v_horizontal_depth!=null) return
        v_horizontal_depth = CpNHorizontalDepthLayout(mActivity!!)
        val layoutParams = LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT,LinearLayout.LayoutParams.WRAP_CONTENT)
        v_horizontal_depth?.layoutParams = layoutParams
        ll_collapsing.addView(v_horizontal_depth)
        CpGuideUtil.showGuide(mActivity,
            v_horizontal_depth?.trade_amount_view?.ll_quantity_type!!, getLineText("order_setting_text5")
        )
    }


    private fun getDefContractByList(contractList:JSONArray?):JSONObject{

        if(null==contractList || contractList.length()==0) return JSONObject()

        val listu = arrayListOf<JSONObject>()
        val listb = arrayListOf<JSONObject>()
        val listh = arrayListOf<JSONObject>()
        val listm = arrayListOf<JSONObject>()
        for (i in 0 until contractList.length()) {
            try {
                val obj = contractList.getJSONObject(i)
                val classification: Int = obj.getInt("classification")
                //Classification 1, USDT contract 2, currency standard contract 3, hybrid contract 4, simulation contract
                if (classification == 1) {
                    listu.add(obj)
                } else if (classification == 2) {
                    listb.add(obj)
                } else if (classification == 4) {
                    listm.add(obj)
                } else {
                    listh.add(obj)
                }

            } catch (e: JSONException) {
                e.printStackTrace()
            }
        }

        if(listu.size>0){
            listu.sortBy { it.getInt("sort") }
            return listu[0]
        }
        if(listb.size>0){
            listb.sortBy { it.getInt("sort") }
            return listb[0]
        }
        if(listh.size>0){
            listh.sortBy { it.getInt("sort") }
            return listh[0]
        }

        if(listm.size>0){
            listm.sortBy { it.getInt("sort") }
            return listm[0]
        }

        return contractList.optJSONObject(0)

    }


    private fun loopStop() {
        if (subscribe != null) {
            subscribe?.dispose()
        }
        if (subscribePriceList != null) {
            subscribePriceList?.dispose()
        }
    }

    override fun onCpWsMessage(json: String) {
        val jsonObj = JSONObject(json)
        val channel = jsonObj.optString("channel")
        val m24HLinkChannel = CpWsLinkUtils.tickerFor24HLink(currentSymbol, isChannel = true)
        val mDepthChannel = CpWsLinkUtils.getDepthLink(currentSymbol, isSub = true, step = depthLevel).channel
        val kineListChannel =  CpWsLinkUtils.getKlineNewLink(currentSymbol, curTime.replace("line","1min")).channel
        when (channel) {
            mDepthChannel -> {
                prevWsDataStringForDepth = json
                activity?.runOnUiThread {
                    v_horizontal_depth?.refreshDepthView(jsonObj)
                }
            }
            m24HLinkChannel -> {
                activity?.runOnUiThread {
                    setSelectSymbolData(jsonObj.optJSONObject("tick"))
                    v_horizontal_depth?.setTickInfo(jsonObj)
                }
            }
            kineListChannel -> {
                activity?.runOnUiThread {
                    if (!jsonObj.isNull("data") ){
//                        smallKline?.setMainDrawLine(curTimeIndex==0)
                        handlerKLineHistory(json)
                    }else{
                        handlerKLineNew(json)
                    }
                }

            }
        }
    }

    private fun handlerKLineNew(data: String) {
        if(chartFlag!=1) return
        val plugin = CpFlutterEngineCacheUtil.getPlugin(requireContext(),CpFlutterEngineCacheUtil.contract_kline_engine_id)
        plugin?.setNewKlineData(hashMapOf(
            "mSymbolPricePrecision" to symbolPricePrecision,
            "isLine" to ("line".equals(curTime)),
            "mKlineData" to data
        ))

    }
    private fun handlerKLineHistory(data: String) {
        if(chartFlag!=1) return
        val jsonObj = JSONObject(data)
        if(jsonObj.isNull("data")) return
        val plugin = CpFlutterEngineCacheUtil.getPlugin(requireContext(),CpFlutterEngineCacheUtil.contract_kline_engine_id)
        plugin?.setHistoryKlineData(hashMapOf(
            "mSymbolPricePrecision" to symbolPricePrecision,
            "isLine" to ("line".equals(curTime)),
            "mKlineData" to data,
            "isMore" to isMoreHistory
        ))
        if(isfirstKHistory){
            prevKlineSubInfoMap.put("symbol",currentSymbol)
            prevKlineSubInfoMap.put("curTime",curTime)
            CpWsContractAgentManager.instance.sendData(CpWsLinkUtils.getKlineNewLink(currentSymbol, curTime,true))
            isfirstKHistory = false
        }

    }

    //Set real-time change of selected currency
    private fun setSelectSymbolData(tick:JSONObject) {
        val dfRate = CpNumberUtil().getDecimal(2)
        val bigChg = CpBigDecimalUtils.mul(tick.optString("rose"), "100", 2)
        val chg = bigChg.toDouble()
        //Scale
        symbol_tag?.run {
            text = if (chg > 0) "+" + dfRate.format(chg) + "%" else dfRate.format(chg) + "%"
            setTextColor( CpColorUtil.getMainColorType(chg >= 0,bigChg.compareTo(BigDecimal.ZERO)==0))
            setBackgroundColor(CpColorUtil.getMinorColorType(chg >= 0,bigChg.compareTo(BigDecimal.ZERO)==0))
        }
    }
    private fun resetTag(){
        symbol_tag?.run {
            text = "0.00%"
            setTextColor(CpColorUtil.getMainColorType(isZero = true))
            setBackgroundColor(CpColorUtil.getMinorColorType(isZero = true))
        }
    }

    fun setChartTitle(cid:Int){
        if(chartFlag==0 || chartFlag==-1){
            return
        }

        mKlineHelper?.run {
            kTimeTab?.mSymbolTitle?.text = CpLanguageUtil.getString(context,"cp_contract_perpetual_chart").format(CpClLogicContractSetting.getContractShowNameById(activity, cid))
        }
    }
    fun getOrderActionName(obj:CpCreateOrderBean):String{
        if(obj.type==2){
            return AppAnalyticsExt.APP_FUTURES_MARKET_ORDER_PLACE_ORDER
        }else{
            return AppAnalyticsExt.APP_FUTURES_LIMIT_ORDER_PLACE_ORDER
        }
    }
    /**
     * @param flag Whether to check the explosion warehouse
     * */
    fun createOrder(obj:CpCreateOrderBean,flag:Boolean = true){
        Log.d(TAG,"createOrder >>> volume=" + obj.volume)
        obj.isCheckLiq = if(flag) 1 else 0

        if(obj.side.equals("BUY")){
            if(obj.open.equals("OPEN")){
                AppAnalyticsExt.instance.clickAction(getOrderActionName(obj),mapOf("open_long" to 1))
            }else{
                AppAnalyticsExt.instance.clickAction(getOrderActionName(obj),mapOf("close_long" to 1))
            }
        }else{
            if(obj.open.equals("OPEN")){
                AppAnalyticsExt.instance.clickAction(getOrderActionName(obj),mapOf("open_short" to 1))
            }else{
                AppAnalyticsExt.instance.clickAction(getOrderActionName(obj),mapOf("close_short" to 1))
            }
        }

        addDisposable(getContractModel().createOrder(
            obj,
            consumer = object : CpNDisposableObserver(mActivity, false) {
                override fun onResponseSuccess(jsonObject: JSONObject?) {
                    v_horizontal_depth?.let { it.trade_amount_view.clearUiEtVal() }
                    getPositionAssetsList()
                    getCurrentOrderList()
                    getCurrentPlanOrderList()
                    CpNToastUtil.showTopToastNet(
                        this.mActivity,
                        true,
                        CpLanguageUtil.getString(context,"cp_extra_text109")
                    )
                    AppAnalyticsExt.instance.clickAction(AppAnalyticsExt.APP_FUTURES_PLACE_ORDER_SUCCESS,mapOf((if(obj.type==2) "market_order" else "limit_order" )to 1))
                }

                override fun onResponseFailure(code: Int, msg: String?) {
                    super.onResponseFailure(code, msg)
                    AppAnalyticsExt.instance.clickAction(AppAnalyticsExt.APP_FUTURES_PLACE_ORDER_FAIL,mapOf((if(obj.type==2) "market_order" else "limit_order" ) to 1))
//                                if(code==10005){
//                                    balanceInsufficient()
//                                }else{
//                                    kycTips(code.toString());
//                                }

                    if(10065 == code){
                        showOrderLiqTip(obj)
                    }else{
                        ToastUtils.showToast(context,msg)
                    }

                }
            })
        )
    }


    //When submitting the opening order, if there are positions in the same direction in the current contract (when adding positions), add strong parity check
    fun showOrderLiqTip(obj:CpCreateOrderBean){
        val direction = when (obj.side) {
            "BUY" -> {
                CpLanguageUtil.getString(context,"cp_order_text6")

            }
            "SELL" -> {
                CpLanguageUtil.getString(context,"cp_order_text15")
            }
            else -> ""
        }
        val cname = CpClLogicContractSetting.getContractShowNameById(context,obj.contractId)
        //We might be out of stock
        CpNewDialogUtils.showDialogNewWithIcon(
            mActivity!!,
            content = String.format(getLineText("order_placement_text2"),"$cname $direction"),
            false,
            title = getLineText("order_placement_text1"),
            cancelTitle = getLineText("order_placement_text5"),
            confrimTitle = getLineText("cp_overview_text56"),
            listener = object : CpNewDialogUtils.DialogBottomListener{
                override fun sendConfirm() {
                    //
                }
                override fun dismiss() {
                    super.dismiss()
                    //Confirmation of warehouse explosion
                    createOrder(obj,false)
                }
            },
            icon = R.mipmap.public_prompt
        )
    }


    fun switchKLineScale(kLineScale: String?) {
        if(chartFlag==0 || chartFlag==-1){
            CpFlutterEngineCacheUtil.removeEngine(CpFlutterEngineCacheUtil.contract_kline_engine_id)
            unSubPrevKlineNewLink()
            return
        }
        isfirstKHistory = true
        isMoreHistory = false
        unSubPrevKlineNewLink()
        if(kLineScale!=null){
            curTime = kLineScale
        }
        if("".equals(kLineScale)){
            curTime = "15min"
        }
        val scale: String = if (curTime == "line") "1min" else curTime
        CpWsContractAgentManager.instance.sendData(CpWsLinkUtils.getKLineHistoryLink(currentSymbol, scale))
        CpFlutterEngineCacheUtil.getPlugin(requireContext(),CpFlutterEngineCacheUtil.contract_kline_page_engine_id).nativeClickKTimeChange(curTime)
        CpFlutterEngineCacheUtil.getPlugin(requireContext(),CpFlutterEngineCacheUtil.contract_kline_engine_id).nativeClickKTimeChange(curTime)
    }


    private fun reqKlineLoadMore(endIdx:Int?){

        endIdx?.let {
            isMoreHistory = true
            val otherLink = CpWsLinkUtils.getKlineHistoryOther(currentSymbol,if (curTime == "line") "1min" else curTime,it.toString())
            CpWsContractAgentManager.instance.sendData(otherLink)
        }
    }

    @Subscribe(threadMode = ThreadMode.POSTING)
    override fun onMessageEvent(event: CpMessageEvent) {
        when (event.msg_type) {
            CpMessageEvent.market_switch_curTime,CpMessageEvent.reload_kline -> {
                if(!mIsVisibleToUser){
                    cacheCurKTime = event.msg_content as? String
                    return
                }
                switchKLineScale(event.msg_content as? String)
            }
            CpMessageEvent.more_history_kline -> {
                if(!mIsVisibleToUser) return
                val params = event.msg_content as Map<String,Int>
                val endIdx = params["endIdx"]
                reqKlineLoadMore(endIdx)
            }
            CpMessageEvent.kline_scroll -> {
                val isKlineScroll = event.msg_content as Boolean
                activity_main.isKlineDrag = isKlineScroll
            }
            CpMessageEvent.sl_contract_open_contract_event -> {
                doCreateContractAccount()
            }
            CpMessageEvent.sl_contract_switch_lever_event -> {
                modifyMarginModel(event.msg_content as String)
            }
            CpMessageEvent.sl_contract_left_coin_type -> {
                if(event.msg_content_data is String) {
                    v_horizontal_depth?.run {

                        trade_amount_view.resetPrice()
                        val vName = event.msg_content_data as String
                        if(this@CpContractNewTradeFragment::class.java.simpleName.equals(vName)){
                            //Update information after switching currency pairs
                            mContractId = event.msg_content as Int
                            updateCoinInfo()
                            //After replacing and comparing, empty the selected ones and fill them
                            trade_amount_view.selectOrderType = null

                            resetTag()
                            val obj =CpClLogicContractSetting.getContractJsonStrById(requireContext(), mContractId)
                            mActivity?.run {
                                val intent = Intent(this,CapitalRateService::class.java)
                                intent.putExtra(CapitalRateService.contractId,obj?.optInt("id"))
                                startService(intent)
                            }
                            showTabInfo(obj,true)
                        }

                    }
                }

            }
            CpMessageEvent.sl_contract_create_order_event -> {
                val obj = event.msg_content as CpCreateOrderBean
                createOrder(obj)
            }
            CpMessageEvent.sl_contract_balance_insufficient_event -> {
                balanceInsufficient()
            }
            CpMessageEvent.sl_contract_req_current_entrust_list_event -> {
                getCurrentOrderList()
            }
            CpMessageEvent.sl_contract_req_plan_entrust_list_event -> {
                getCurrentPlanOrderList()
            }
            CpMessageEvent.sl_contract_refresh_assets_position_event -> {
                getPositionAssetsList()
            }
            CpMessageEvent.sl_contract_req_modify_leverage_event -> {
                modifyLevel(event.msg_content as String)
                v_horizontal_depth?.cleanInputData()
            }
            CpMessageEvent.sl_contract_change_unit_event -> {
                v_horizontal_depth?.run {
                    cleanInputData()
                    swicthUnit()
                    //After replacing and comparing, empty the selected ones and fill them
                    trade_amount_view.selectOrderType = null
                }

            }
            CpMessageEvent.sl_contract_depth_level_event -> {
                depthLevel = event.msg_content as String
                val paramMap: HashMap<String, Any> = hashMapOf("symbol" to currentSymbol, "step" to depthLevel)
                CpWsContractAgentManager.instance.sendMessage(paramMap, this@CpContractNewTradeFragment)
            }
            CpMessageEvent.sl_contract_receive_coupon -> {
                //Receive simulation contract experience fee
                receiveCoupon()
            }
            CpMessageEvent.sl_contract_modify_depth_event -> {
                //Processing depth display number
                v_horizontal_depth?.swicthShowNum(event.msg_content as CpContractBuyOrSellHelper)
            }
            CpMessageEvent.sl_contract_change_position_model_event -> {
                v_horizontal_depth?.run {
                    cleanInputData()
                    swicthUnit()
                }

            }
            CpMessageEvent.color_rise_fall_type -> {
                smallKline?.detachFromFlutterEngine()
                CpFlutterEngineCacheUtil.removeAllEngine()
                initKlineByUserConfig()
            }
            CpMessageEvent.sl_contract_trade_chart_kline_config_update -> {
                if(event.msg_content is Int){
                    //Update flag
                    chartFlag = CpClLogicContractSetting.getContractChartOff(mActivity)
                    val position = event.msg_content as Int
                    when(position){
                        //Delete
                        -1 -> {
                            smallKline?.detachFromFlutterEngine()
                            CpFlutterEngineCacheUtil.removeEngine(CpFlutterEngineCacheUtil.contract_kline_engine_id)
                            resetKline()
                        }
                        //Upper
                        0 -> {
                            createTopKline()
                        }
                        //Lower
                        1 -> {
                            createBottomKline()
                        }
                    }
                }
            }
            CpMessageEvent.color_rise_fall_type -> {
                v_horizontal_depth?.changeMainColor()
            }
            //Opening the contract risk notification dialog box
            CpMessageEvent.sl_contract_create_account_event -> {
                CpDialogUtil.showCreateContractDialog(
                    requireActivity(),
                    object : CpNewDialogUtils.DialogBottomListener {
                        override fun sendConfirm() {
                            CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.sl_contract_open_contract_event))
                        }
                    }
                )
            }
            CpMessageEvent.sl_contract_logout_event -> {
                v_horizontal_depth?.trade_amount_view?.selectOrderType = null
            }

            CpMessageEvent.sl_contract_position_num_event -> {
                val content = event.msg_content as Int
                val num = content.toString()
                tab_order.getTitleView(0).text = CpLanguageUtil.getString(context,"cp_order_text1") + "(" +num+")"
            }
            CpMessageEvent.cp_net_status_change -> {
                val isConnect = event.msg_content as Boolean
                Log.e(reConnectWSTAG,"Network change:isConnect>>>$isConnect...")
                if(!mIsVisibleToUser || !isCanShowing) return
                if(isConnect) {
                    if(CpWsContractAgentManager.instance.isReConnecting) return
                    if(CpWsContractAgentManager.instance.reConnectTasked){
                        Log.e(reConnectWSTAG,"Network change:trigger refresh>>>")
                        doRefshing()
                    }
                }
                else {
                    Log.e(reConnectWSTAG,"Network change:No available networks>>>stop loop")
                    loopStop()
                }
            }
        }
    }

    private fun receiveCoupon() {
        if (!CpClLogicContractSetting.isLogin()) return
        if (openContract == 0) return
        if (!contractType.equals("S")) return
        if (couponTag == 1) return
        addDisposable(
                getContractModel().receiveCoupon(
                        consumer = object : CpNDisposableObserver(true) {
                            override fun onResponseSuccess(jsonObject: JSONObject?) {
                                getContractUserConfig()
                            }
                        })
        )
    }

    private fun modifyLevel(s: String) {
        addDisposable(getContractModel().modifyLevel(mContractId.toString(), s,
                consumer = object : CpNDisposableObserver(mActivity,true) {
                    override fun onResponseSuccess(jsonObject: JSONObject?) {
                        getContractUserConfig()
                    }
                }))
    }

    private fun showTabInfo(obj: JSONObject,isLeftCoin:Boolean? = false) {
        swipeLayout?.finishRefresh(true)
        base = obj.getString("base")
        quote = obj.getString("quote")
        mContractId = obj.getInt("id")
        mSymbol = obj.optString("symbol")
        mContractName = obj.optString("contractName")
        contractType = obj.getString("contractType")
        currentSymbol = obj.optString("subSymbol")
        depthLevel = "0"
        symbolPricePrecision = CpClLogicContractSetting.getContractSymbolPricePrecisionById(activity, mContractId)
        mMultiplierPrecision = CpClLogicContractSetting.getContractMultiplierPrecisionById(activity,mContractId)
//        mKlineHelper?.run {
//            kline?.setPricePrecision(symbolPricePrecision)
//            kline?.setMultiplierPrecision(mMultiplierPrecision)
//        }
        updateUICoin(mContractId)
        v_horizontal_depth?.setContractJsonInfo(obj,isLeftCoin)
        updateSubKLineWithDepth()

        loopStart()
        val msgEvent =
            CpMessageEvent(
                CpMessageEvent.sl_contract_change_contract_event
            )
        msgEvent.msg_content = mContractId
        CpEventBusUtil.post(msgEvent)
    }

    private fun updateUICoin(cid:Int) {
        mHeaderKit?.setFilterTitleContent(CpClLogicContractSetting.getContractShowNameById(activity, cid))
        setChartTitle(cid)
    }
    private fun updateSubKLineWithDepth() {
        val paramMap: java.util.HashMap<String, Any> = hashMapOf("symbol" to currentSymbol, "step" to depthLevel)
        CpWsContractAgentManager.instance.sendMessage(paramMap, this@CpContractNewTradeFragment)
        if(cacheCurKTime!=null && !"".equals(cacheCurKTime)){
            curTime = cacheCurKTime!!
            cacheCurKTime = null
            setKTimePosition()
        }
        clickTime(curTime)
    }

    private fun initCoin(mContractList:JSONArray) {
        disposableLoader?.dispose()
        val noSelectContract = 0
        val noContractList = -1
        disposableLoader = Observable.just(mContractList)
            .subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
            .map {
                if(it.length() > 0){
                    val contractId = CpClLogicContractSetting.getContractCurrentSelectedId(mActivity)
                    //THE LAST TIME THE CONTRACT WAS SELECTED
                    if(contractId != -1) {
                        val isHasContract = isHasContract(it, contractId)
                        if(!isHasContract) {
                            //remove ContractCurrentSelectedId : reset -1
                            CpClLogicContractSetting.setContractCurrentSelectedId(mActivity,-1)
                            noSelectContract
                        }else{
                            //update ui : title and kline title
                            updateUICoin(contractId)
                            contractId
                        }
                    } else {
                        noSelectContract
                    }
                }else{
                    noContractList
                }
            }
            .map {
                //create ui : HorizontalDepthLayout
                createHorizontalDepthLayout()
                lifecycle.addObserver(v_horizontal_depth!!)
                it
            }
            .observeOn(Schedulers.io())
            .map {
                //Relink ws
                val wsConnectionStatus = CpWsContractAgentManager.instance.isConnection()
                if(!wsConnectionStatus){
                    CpWsContractAgentManager.instance.isRefreshReConnectWs = true
                    CpWsContractAgentManager.instance.reConnection()
                    return@map -2
                }
                it
            }
            .filter {
                return@filter it != -2
            }
            .observeOn(Schedulers.io())
            .flatMap {
                when(it){
                    noSelectContract -> {
                        //NO CONTRACT HAS BEEN SELECTED
//                        return@flatMap Observable.just(defContractByList)
                        return@flatMap Observable.just(
                            Pair<JSONArray,Int?>(mContractList,null)
                        )
                    }
                    noContractList -> {
                        //get public info
                        return@flatMap getContractPublicInfoObservable()
                    }
                    else -> {
                        //THE LAST TIME THE CONTRACT WAS SELECTED
//                        val itemContractObj = CpClLogicContractSetting.getContractJsonStrById(mActivity,it)
                        return@flatMap Observable.just(
                            Pair<JSONArray,Int>(mContractList,Integer.valueOf(it))
                        )
                    }
                }
            }
            .map {
                var contractJsonList:JSONArray? = null
                var contractId:Int? = -1
                if(it is Pair<*, *>){
                    contractJsonList = it.first as JSONArray
                    contractId = it.second as? Int
                } else if(it is ResponseBody){
                    saveContractPublicInfo(it) {
                        contractJsonList = it
                    }
                }

                if(contractId==-1 || contractId==null){
                    val defContractByList = getDefContractByList(contractJsonList)
                    contractId = defContractByList.optInt("id")
                }

                Pair<JSONArray,Int>(contractJsonList ?: JSONArray(),contractId)
            }
            .observeOn(Schedulers.io())
            .map {
                var jsonObject = JSONObject()
                val contractList = it.first
                val contractId = it.second
                for(i in 0 until contractList.length()){
                    val current = contractList[i]
                    if(current is JSONObject){
                        if(current.optInt("id") == contractId){
                            jsonObject = current
                        }
                    }
                }
                jsonObject
            }
            .observeOn(AndroidSchedulers.mainThread())
            .doOnComplete {
                swipeLayout?.finishRefresh(true)

            }
            .subscribe({
                if(!it.isNull("id")){
                    showTabInfo(it)
                    mActivity?.run {
                        val intent = Intent(this,CapitalRateService::class.java)
                        intent.putExtra(CapitalRateService.currentTimeMillisParam,serviceMillSecondTime.toString())
                        intent.putExtra(CapitalRateService.itemContractJson,it.toString())
                        intent.putExtra(CapitalRateService.contractId,it?.optInt("id"))
                        startService(intent)
                    }
                }else{
                    swipeLayout?.finishRefresh(true)
                }
            },{
                it.printStackTrace()
                swipeLayout?.finishRefresh(true)
            })
    }

    private fun isHasContract(contractList:JSONArray,contractId:Int):Boolean {
        var isExist = false
        if(contractList.length()<=0) return isExist
        for(i in 0 until contractList.length()){
            val current = contractList[i]
            if(current is JSONObject){
                if(current.optInt("id") == contractId){
                    isExist = true
                }
            }
        }
        return isExist
    }

    override fun onDestroy() {
        super.onDestroy()
        lifecycle.removeObserver(v_horizontal_depth!!)
        disposableLoader?.dispose()
        smallKline?.detachFromFlutterEngine()
        CpFlutterEngineCacheUtil.removeAllEngine()
    }

    override fun onDetach() {
        super.onDetach()
//        CpFlutterEngineCacheUtil.getEngine(CpFlutterEngineCacheUtil.contract_kline_engine_id).lifecycleChannel.appIsDetached()
    }


    override fun fragmentVisibile(isVisibleToUser: Boolean) {
        super.fragmentVisibile(isVisibleToUser)
        if(isVisibleToUser && isCanShowing) {
            AppAnalyticsExt.instance.activityStart(AppAnalyticsExt.APP_FUTURES_MAIN_PAGE)
            ChainUpLogUtil.e(TAG, "visible $TAG>>>>>>")
            val mainToken = CpClLogicContractSetting.getInstance().userDataBridgeImpl?.token
            val cpToken = CpClLogicContractSetting.getToken()
            if("".equals(cpToken)){
                if(!TextUtils.isEmpty(mainToken)){
                    CpClLogicContractSetting.setToken(mainToken)
                }
            }
            doRefshing()
        }else{
            loopStop()
            CpWsContractAgentManager.instance.unbind(this, true)
            unSubPrevKlineNewLink()
        }

    }



    override fun onHiddenChanged(hidden: Boolean) {
        super.onHiddenChanged(hidden)
        if(!hidden) {
            Log.d(TAG,"initAnnouncement>>>")
            initAnnouncement()
            if(chartFlag==1) smallKline?.attachToFlutterEngine(CpFlutterEngineCacheUtil.getEngine(requireContext(),CpFlutterEngineCacheUtil.contract_kline_engine_id))
        }else{
            if(chartFlag==1) smallKline?.detachFromFlutterEngine()
        }
    }

    override fun onPause() {
        super.onPause()
        if(chartFlag==1) CpFlutterEngineCacheUtil.getEngine(requireContext(),CpFlutterEngineCacheUtil.contract_kline_engine_id).lifecycleChannel.appIsInactive()
    }

    override fun onResume() {
        super.onResume()
        CpWsContractAgentManager.instance.changeKlineKey(this.javaClass.simpleName)
        ChainUpLogUtil.e(TAG, "合约展示 onResume ")
        v_horizontal_depth?.setLoginContractLayout(CpClLogicContractSetting.isLogin(), openContract == 1)
        AppAnalyticsExt.instance.activityStart(AppAnalyticsExt.APP_FUTURES_MAIN_PAGE)
        if(chartFlag==1){
            setKTimePosition()
            CpFlutterEngineCacheUtil.getEngine(requireContext(),CpFlutterEngineCacheUtil.contract_kline_engine_id).lifecycleChannel.appIsResumed()
            CpFlutterEngineCacheUtil.getPlugin(requireContext(),CpFlutterEngineCacheUtil.contract_kline_engine_id).updateMainIndexVisible()
            updateCoinInfo()
        }
    }

    //Retrieve the selected time scale and set it
    fun setKTimePosition(){
        mKlineHelper?.run {
            kTimeTab?.let {
                if(!isShowKline) return@let
                val index = it.getPositionByTime(curTime)
                if(index==-1) return@let
                it.setSelectTab(index)
            }
        }
    }

    override fun onStop() {
        super.onStop()
        AppAnalyticsExt.instance.activityStop(AppAnalyticsExt.APP_FUTURES_MAIN_PAGE)
        if(chartFlag==1){
            CpFlutterEngineCacheUtil.getEngine(requireContext(),CpFlutterEngineCacheUtil.contract_kline_engine_id).lifecycleChannel.appIsPaused()
        }
    }

    private fun updateCoinInfo(){
        if(chartFlag!=1) return
        CpFlutterEngineCacheUtil.getPlugin(requireContext(),CpFlutterEngineCacheUtil.contract_kline_engine_id).setCoinInfo(hashMapOf(
            "isCoin" to (CpClLogicContractSetting.getContractUint(context)==1),
            "mMultiplier" to CpClLogicContractSetting.getContractMultiplierById(context,mContractId),
            "marginCoinPrecision" to CpClLogicContractSetting.getContractMarginCoinPrecisionById(context,mContractId),
        ))
    }
}