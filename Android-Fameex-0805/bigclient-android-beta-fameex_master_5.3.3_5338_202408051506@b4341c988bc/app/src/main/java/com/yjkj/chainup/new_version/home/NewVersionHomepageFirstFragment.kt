package com.yjkj.chainup.new_version.home

import android.app.Activity
import android.content.Intent
import androidx.lifecycle.Observer
import android.os.Bundle
import android.os.Handler
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.LinearLayoutManager
import android.text.TextUtils
import android.view.View
import androidx.core.widget.NestedScrollView
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.RecyclerView
import androidx.viewpager.widget.ViewPager
import com.bumptech.glide.request.RequestOptions
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
import com.yjkj.chainup.net.api.ApiConstants
import com.yjkj.chainup.net_new.JSONUtil
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_version.activity.NewMainActivity
import com.yjkj.chainup.new_version.activity.personalCenter.MailActivity
import com.yjkj.chainup.new_version.activity.personalCenter.NoticeActivity
import com.yjkj.chainup.new_version.adapter.NVPagerAdapter
import com.yjkj.chainup.new_version.adapter.NewHomePageServiceAdapter
import com.yjkj.chainup.new_version.adapter.NewhomepageTradeListAdapter
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.home.adapter.ImageNetAdapter
import com.yjkj.chainup.util.*
import com.yjkj.chainup.wedegit.VerticalTextview4ChainUp
import com.yjkj.chainup.ws.WsAgentManager
import com.youth.banner.config.IndicatorConfig
import com.youth.banner.indicator.RectangleIndicator
import io.reactivex.Observable
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import kotlinx.android.synthetic.main.activity_home_title.*
import kotlinx.android.synthetic.main.fragment_new_version_homepage.banner_looper
import kotlinx.android.synthetic.main.fragment_new_version_homepage.fragment_market
import kotlinx.android.synthetic.main.fragment_new_version_homepage.iv_nation_more
import kotlinx.android.synthetic.main.fragment_new_version_homepage.ll_advertising_layout
import kotlinx.android.synthetic.main.fragment_new_version_homepage.recycler_top_24
import kotlinx.android.synthetic.main.fragment_new_version_homepage.rl_red_envelope_entranc_layout
import kotlinx.android.synthetic.main.fragment_new_version_homepage.stl_homepage_list
import kotlinx.android.synthetic.main.fragment_new_version_homepage.vtc_advertising
import kotlinx.android.synthetic.main.fragment_new_version_inter_homepage.*
import kotlinx.android.synthetic.main.view_top_service_layout.*
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode
import org.jetbrains.anko.doAsync
import org.json.JSONArray
import org.json.JSONObject
import java.util.*
import java.util.concurrent.TimeUnit
import kotlin.collections.ArrayList

/**
 * @Author lianshangljl
 * @Date 2023/5/5-2:54 PM
 * @Email buptjinlong@163.com
 *@description homepage
 */
class NewVersionHomepageFirstFragment : NBaseFragment(), WsAgentManager.WsResultCallback {

    val getTopDataReqType = 1 //Request for market data at the top of the homepage
    val homepageReqType = 2 //Homepage Data Request
    val accountBalanceReqType = 5 //Total Account Asset Request
    val homeData = 11 //Total Account Asset Request

    /**
     *Whether to open off site
     */
    private var otcOpen = false

    private var leverOpen = false

    /**
     *Whether to open the contract
     */
    private var contractOpen = false

    private var isAssetsShow = true

    var contractTotal: Double = 0.0
    var contractReturn = false
    var totalBalance: String = "0"

    /**
     *Functional Services
     */
    private var serviceAdapter: NewHomePageServiceAdapter? = null


    /*
     *Have you logged in
     */
    var isLogined = false
    var subscribeCoin: Disposable? = null//Save subscribers

    override fun setContentView() = R.layout.fragment_new_version_inter_homepage

    override fun initView() {

        otcOpen = PublicInfoDataService.getInstance().otcOpen(null)
        leverOpen = PublicInfoDataService.getInstance().isLeverOpen(null)
        contractOpen = PublicInfoDataService.getInstance().contractOpen(null)
        WsAgentManager.instance.addWsCallback(this)
        observeData()

        if (ApiConstants.HOME_VIEW_STATUS != ParamConstant.CONTRACT_HOME_PAGE) {
            initTop24HourView()
        }

        setTopBar()
        initRedPacketView()
        setOnClick()
        val data = CommonService.instance.getHomeData()
        showHomepageData(data, true)

    }

    /*
     *Initialize red envelope view
     */
    private fun initRedPacketView() {
        val isRedPacketOpen = PublicInfoDataService.getInstance().isRedPacketOpen(null)
        showRedPacket(isRedPacketOpen)
    }

    /**
     *Top 24-hour growth chart (recommended currency)
     */
    private var topSymbolAdapter: NewhomepageTradeListAdapter? = null
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
        recycler_top_24?.addOnScrollListener(object : RecyclerView.OnScrollListener() {
            override fun onScrolled(recyclerView: RecyclerView, dx: Int, dy: Int) {
                scrollX += dx
                val contentItem = recyclerView.computeHorizontalScrollOffset()
                if (contentItem == 0) {
                    return
                }
                val sum = recyclerView.computeHorizontalScrollRange() - recyclerView.computeHorizontalScrollExtent()
                val count = BigDecimalUtils.div(scrollX.toString(), sum.toString())
                layout_item.setRate(count.toFloat())
            }
        })

    }

    private fun observeData() {
        NLiveDataUtil.observeData(this, Observer {
            if (null != it) {
                if (MessageEvent.color_rise_fall_type == it.msg_type) {
                    topSymbolAdapter?.notifyDataSetChanged()
                }
            }
        })
    }

    inner class MyNDisposableObserver(type: Int) : NDisposableObserver() {

        var req_type = type
        override fun onResponseSuccess(jsonObject: JSONObject) {
            closeLoadingDialog()
            if (getTopDataReqType == req_type) {
                recycler_top_24?.visibility = View.VISIBLE
                v_top_line?.visibility = View.VISIBLE
                showTopSymbolsData(jsonObject.optJSONArray("data"))
            } else if (homepageReqType == req_type) {
                showHomepageData(jsonObject.optJSONObject("data"))
            } else if (homeData == req_type) {
                showHomepageData(jsonObject.optJSONObject("data"))
            }
        }

        override fun onResponseFailure(code: Int, msg: String?) {
            super.onResponseFailure(code, msg)
            if (getTopDataReqType == req_type) {
                recycler_top_24?.visibility = View.GONE
                v_top_line?.visibility = View.GONE
            }
            if (req_type == homeData) {
                initSocket()
            }
            closeLoadingDialog()
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
            CommonService.instance.saveHomeData(jsonObjects)
        }
        var noticeInfoList = data.optJSONArray("noticeInfoList")
        var cmsAppAdvertList = data.optJSONArray("cmsAppAdvertList")
        var cmsAppDataList = data.optJSONArray("cmsAppDataList")
        var cmsAppNoteDataList = data.optJSONArray("cmsAppDataListOther")
        var cmsSymbolList = data.optJSONArray("header_symbol")
        var homeRecommendList = data.optJSONArray("home_recommend_list") ?: JSONArray()
        showTopSymbolsData(cmsSymbolList)
        showBottomVp(homeRecommendList)

        LogUtil.d("NewVersionHomepageFragment", "showHomepageData==cmsAppAdvertList is $cmsAppAdvertList")
        newNoticeInfoList = noticeInfoList
        showGuanggao(noticeInfoList)
        showBannerData(cmsAppAdvertList)
        initNoteBanner(cmsAppNoteDataList)
        setServiceData(cmsAppDataList)

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
            adapter = mAdapter
            //Set the rotation time
            setLoopTime(3000)
            indicator = RectangleIndicator(context)
            //Set indicator position (when there is an indicator in banner mode)
            setIndicatorGravity(IndicatorConfig.Direction.CENTER)
        }
        banner_looper?.setOnBannerListener { data, position ->
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
        if (null == homepageData) {
            getHomeData()
        }
    }


    private fun setTopBar() {
        ns_layout?.setOnScrollChangeListener { v: NestedScrollView?, scrollX: Int, scrollY: Int, oldScrollX: Int, oldScrollY: Int ->
            val distance = resources.getDimension(R.dimen.dp_64)
            if ((1 - scrollY / distance) < (0.0001)) {
                item_view_market_line.visibility = View.VISIBLE
            } else {
                item_view_market_line.visibility = View.INVISIBLE
            }
        }
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
    private fun homeTabSwitch(tabType: Int?) {
        var msgEvent = MessageEvent(MessageEvent.hometab_switch_type)
        var bundle = Bundle()
        bundle.putInt(ParamConstant.homeTabType, tabType ?: 0)
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

        if (SystemUtils.isZh()) {
            rl_red_envelope_entrance.setImageResource(R.drawable.redenvelope)
        } else {
            rl_red_envelope_entrance.setImageResource(R.drawable.redenvelope_english)
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

        /**
         *Click to close the red envelope
         */
        iv_close_red_envelope?.setOnClickListener {
            showRedPacket(false)
        }
    }


    private fun showRedPacket(isVisibile: Boolean) {
        if (isVisibile) {
            rl_red_envelope_entranc_layout?.visibility = View.VISIBLE
        } else {
            rl_red_envelope_entranc_layout?.visibility = View.GONE
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
        if (bottomCoins.isNotEmpty()) {
            val temp = bottomCoins union arrays
            json = JsonUtils.gson.toJson(temp)
        } else {
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
                } else {
                    showAdvertising(false)
                    showBanner(false)
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
            if (selectTopSymbol != null && selectTopSymbol!!.size >= 3) {
                layout_item?.visibility = View.VISIBLE
            } else {
                layout_item?.visibility = View.GONE
            }
            v_top_line?.visibility = View.VISIBLE
        } else {
            recycler_top_24?.visibility = View.GONE
            layout_item?.visibility = View.GONE
            v_top_line?.visibility = View.GONE
        }
    }

    /**
     *Obtain top symbol 24-hour market
     */
    fun getHomeData() {
        showLoadingDialog()
        val disposable = getMainModel().getHomeData("1", MyNDisposableObserver(homeData))
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
        var titles = arrayListOf<String>()

        var serviceDatas = JSONUtil.arrayToList(data)
        if (serviceDatas == null) {
            return
        }
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

        val marketPageAdapter = NVPagerAdapter(childFragmentManager, titles, fragments)
        fragment_market?.adapter = marketPageAdapter
        fragment_market?.offscreenPageLimit = fragments.size
        fragment_market?.addOnPageChangeListener(object : ViewPager.OnPageChangeListener {
            override fun onPageScrollStateChanged(state: Int) {
            }

            override fun onPageScrolled(position: Int, positionOffset: Float, positionOffsetPixels: Int) {
            }

            override fun onPageSelected(position: Int) {
                selectPostion = position
                WsAgentManager.instance.unbind(this@NewVersionHomepageFirstFragment)
                loopData()
                fragment_market?.resetHeight(selectPostion)
            }
        })
        loopData()
        try {
            stl_homepage_list?.setViewPager(fragment_market, titles.toTypedArray())
        } catch (e: Exception) {
            e.printStackTrace()
        }
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
                vtc_advertising?.setText(12f, 0, ContextCompat.getColor(requireContext(), R.color.text_color),true)
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
        var httpUrl = jsonObject?.optString("httpUrl")

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
     *Get homepage data
     */
    private fun getHomepageData() {
        showLoadingDialog()
        var disposable = getMainModel().common_index(MyNDisposableObserver(homepageReqType))
        addDisposable(disposable!!)
    }


    /**
     *
     *Fill in after obtaining feature service data from the server
     */

    private fun setServiceData(cmsAppDataList: JSONArray?, viewType: Int = 0) {
        var serviceDataList = JSONUtil.arrayToList(cmsAppDataList)
        if (serviceDataList.size > 0) {
            if (serviceDataList.size == 1) {
                ll_rigth_top_layout?.visibility = View.GONE
                tv_top_title.text = serviceDataList[0].optString("title", "") ?: ""
                val requestOptions = RequestOptions()
                requestOptions.error(R.drawable.home_top_image).placeholder(R.drawable.home_top_image)
                GlideUtils.load(context as Activity?, serviceDataList[0].optString("imageUrl"), im_top, requestOptions)
            } else if (serviceDataList.size == 2) {
                tv_top_title.text = serviceDataList[0].optString("title", "") ?: ""
                tv_second_title.text = serviceDataList[1].optString("title", "") ?: ""
                val requestOptions = RequestOptions()
                requestOptions.error(R.drawable.home_top_image).placeholder(R.drawable.home_top_image)
                GlideUtils.load(context as Activity?, serviceDataList[0].optString("imageUrl"), im_top, requestOptions)
                val requestOptions2 = RequestOptions()
                requestOptions2.error(R.drawable.home_contract).placeholder(R.drawable.home_contract)
                GlideUtils.load(context as Activity?, serviceDataList[1].optString("imageUrl"), iv_second_title, requestOptions2)
                ll_help_center?.visibility = View.GONE
            } else if (serviceDataList.size >= 3) {
                tv_top_title.text = serviceDataList[0].optString("title", "") ?: ""
                tv_second_title.text = serviceDataList[1].optString("title", "") ?: ""
                tv_three_title.text = serviceDataList[2].optString("title", "") ?: ""
                val requestOptions = RequestOptions()
                requestOptions.error(R.drawable.home_top_image).placeholder(R.drawable.home_top_image)
                GlideUtils.load(context as Activity?, serviceDataList[0].optString("imageUrl"), im_top, requestOptions)
                val requestOptions2 = RequestOptions()
                requestOptions2.error(R.drawable.home_contract).placeholder(R.drawable.home_contract)
                GlideUtils.load(context as Activity?, serviceDataList[1].optString("imageUrl"), iv_second_title, requestOptions2)
                val requestOptions3 = RequestOptions()
                requestOptions3.error(R.drawable.home_center).placeholder(R.drawable.home_center)
                GlideUtils.load(context as Activity?, serviceDataList[2].optString("imageUrl"), iv_three_title, requestOptions3)
            }
        } else {
            ic_new_service_layout?.visibility = View.GONE
        }


        rl_fait_layout?.setOnClickListener {
            if (activity != null && !activity?.isFinishing!! && !activity?.isDestroyed!!) {

                var obj = cmsAppDataList?.optJSONObject(0)
                var httpUrl = obj?.optString("httpUrl") ?: ""
                var nativeUrl = obj?.optString("nativeUrl") ?: ""

                //TODO requires a title
                if (TextUtils.isEmpty(httpUrl)) {
                    if (StringUtil.checkStr(nativeUrl) && nativeUrl.contains("?")) {
                        enter2Activity(nativeUrl.split("?"))
                    }
                } else {
                    if (httpUrl == PublicInfoDataService.getInstance().getOnlineService(null)) {
                        forUdeskWebView()
                    } else {
                        forwardWeb(obj)
                    }
                }

            }
        }

        ll_contract_deal?.setOnClickListener {
            if (activity != null && !activity?.isFinishing!! && !activity?.isDestroyed!!) {
                var obj = cmsAppDataList?.optJSONObject(1)
                var httpUrl = obj?.optString("httpUrl") ?: ""
                var nativeUrl = obj?.optString("nativeUrl") ?: ""

                //TODO requires a title
                if (TextUtils.isEmpty(httpUrl)) {
                    if (StringUtil.checkStr(nativeUrl) && nativeUrl.contains("?")) {
                        enter2Activity(nativeUrl.split("?"))
                    }
                } else {
                    if (httpUrl == PublicInfoDataService.getInstance().getOnlineService(null)) {
                        forUdeskWebView()
                    } else {
                        forwardWeb(obj)
                    }
                }
            }
        }

        ll_help_center?.setOnClickListener {
            if (activity != null && !activity?.isFinishing!! && !activity?.isDestroyed!!) {
                var obj = cmsAppDataList?.optJSONObject(2)
                var httpUrl = obj?.optString("httpUrl") ?: ""
                var nativeUrl = obj?.optString("nativeUrl") ?: ""

                //TODO requires a title
                if (TextUtils.isEmpty(httpUrl)) {
                    if (StringUtil.checkStr(nativeUrl) && nativeUrl.contains("?")) {
                        enter2Activity(nativeUrl.split("?"))
                    }
                } else {
                    if (httpUrl == PublicInfoDataService.getInstance().getOnlineService(null)) {
                        forUdeskWebView()
                    } else {
                        forwardWeb(obj)
                    }
                }
            }
        }
    }


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
                SymbolManager.instance.saveTradeSymbol(temp[1])
                var tabType = HomeTabMap.maps[HomeTabMap.coinTradeTab]
                homeTabSwitch(tabType)
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
                    ArouterUtil.navigation(RoutePath.NewVersionOTCActivity, null)
                } else {
                    NToastUtil.showTopToastNet(this.mActivity, false, LanguageUtil.getString(context, "common_tip_notSupportOTC"))
                }
            }
            "otc_sell" -> {
                /**
                 *Off exchange trading - sale
                 */
                if (otcOpen) {
                    ArouterUtil.navigation(RoutePath.NewVersionOTCActivity, null)
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
        try {
            val json = JSONObject(data)
            if (!json.isNull("tick")) {
                doAsync {
                    val quotesData = json
                    showWsData(quotesData)
                    if (fragments.size == 0) {
                        return@doAsync
                    }
                    val fragment = fragments[selectPostion]
                    if (fragment is NewHomeDetailFragmentItem) {
                        val tick = json.optJSONObject("tick")
                        val channel = json.optString("channel")
                        val temp = bottomCoins.filter {
                            channel.contains(it)
                        }
                        if (temp.isEmpty()) {
                            return@doAsync
                        }
                        val roseStr = tick.getString("rose")
                        val rose = RateManager.getNumRose(roseStr)
                        if (chooseType[selectPostion] == "rasing") {
                            if (!rose) {
                                return@doAsync
                            }
                        } else if (chooseType[selectPostion] == "falling") {
                            if (rose) {
                                return@doAsync
                            }
                        }
                        fragment.showWsData(json)
                    }
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun showWsData(jsonObject: JSONObject) {
        if (0 == topSymbolAdapter?.data?.size)
            return
        val datas = topSymbolAdapter?.data
        val obj = SymbolWsData().getNewSymbolObj(datas as java.util.ArrayList<JSONObject>, jsonObject)
        if (null != obj && obj.length() > 0) {
            val pos = datas.indexOf(obj)
            if (pos >= 0) {
                activity?.runOnUiThread {
                    topSymbolAdapter?.notifyItemChanged(pos, null)
                }
            }
        }
    }

    override fun onVisibleChanged(isVisible: Boolean) {
        super.onVisibleChanged(isVisible)
        LogUtil.e(TAG, "onVisibleChanged==NewVersionHomepageFragment ${isVisible} ")
        if (isVisible) {
            Handler().postDelayed({
                isRoseHttp()
                initSocket()
                if (fragments.size == 0) {
                    return@postDelayed
                }
                val fragment = fragments[selectPostion]
                if (fragment is NewHomeDetailFragmentItem) {
                    fragment.startInit()
                }
            }, 100)
        } else {
            if (selectTopSymbol != null) {
                WsAgentManager.instance.unbind(this)
            }
            clearToolHttp()
        }
    }

    var bottomCoins = arrayListOf<String>()

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

    private fun initNoteBanner(cmsAppDataList: JSONArray?) {

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
}
