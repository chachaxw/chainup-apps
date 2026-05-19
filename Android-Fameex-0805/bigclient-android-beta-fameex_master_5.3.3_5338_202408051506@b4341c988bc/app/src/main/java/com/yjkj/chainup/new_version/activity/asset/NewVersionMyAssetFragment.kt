package com.yjkj.chainup.new_version.activity.asset

import android.os.Bundle
import androidx.fragment.app.Fragment
import androidx.viewpager.widget.ViewPager
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import android.view.View
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseFragment
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.extra_service.eventbus.NLiveDataUtil
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.RateManager
import com.yjkj.chainup.net.api.ApiConstants
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_version.adapter.NVPagerAdapter
import com.yjkj.chainup.new_version.adapter.OTCMyAssetHeatAdapter
import kotlinx.android.synthetic.main.fragment_new_version_my_asset.*
import org.json.JSONObject
import android.graphics.Color
import android.os.Build
import android.util.Log
import android.view.ViewOutlineProvider
import android.widget.TextView
import androidx.lifecycle.Observer
import com.chainup.contract.utils.CpPreferenceManager
import com.google.android.material.appbar.AppBarLayout
import com.chainup.contract.view.dialog.listener.OnCpBindViewListener
import com.chainup.kit.utils.setSafeListener
import com.yjkj.chainup.app.AppConstant
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.fragment.ClContractAssetFragment
import com.yjkj.chainup.util.*

private const val ARG_PARAM1 = "param1"
/**
 * @Author lianshangljl
 * @Date 2023/5/14-7:49 PM
 * @Email buptjinlong@163.com
 *@description My assets
 *
 *NOTE: Spot, Legal Currency (B2C), Off Market (OTC), Contract, Leverage
 */
class NewVersionMyAssetFragment : NBaseFragment() {

    override fun setContentView() = R.layout.fragment_new_version_my_asset

    val assetlist = ArrayList<JSONObject>()
    var fragments = ArrayList<Fragment>()
    var tabTitles = arrayListOf<String>()


    val showTitles = arrayListOf<String>()


    // TODO: Rename and change types of parameters
    private var param1: String? = null
    private var param2: String? = null


    private var totalBalance: String? = null
    private var legalCurrency: String? = null

    var contractAssetFragment: ClContractAssetFragment? = null



    /**
     *Off site
     */
    var otcOpen = false

    /**
     *Contract
     */
    var contractOpen = false
    var chooseIndex = 0

    /**
     * b2c
     */
    var b2cOpen = false

    /**
     *Lever
     */
    var leverOpen = false

    /**
     *Header Page
     */
    var adapter4Heat: OTCMyAssetHeatAdapter? = null

    var indexList = ArrayList<String>()

    /*
     *Have you logged in
     */
    var isLogined = false

    /**
     *Is it the first time to accept contract data
     */
    var isFristContract = true

    var contractTotal: Double = 0.0

    val ARG_INDEX = "param_index"

    private var isFromAssetsActivity = false
    open fun setFromAssetsActivity(isFromAssetsActivity: Boolean) {
        this.isFromAssetsActivity = isFromAssetsActivity
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        retainInstance = true
        arguments?.let {
            param1 = it.getString(ARG_PARAM1)
            param2 = it.getString(ARG_PARAM2)
            chooseIndex = it.getInt(ParamConstant.CHOOSE_INDEX, 0)
        }
        NLiveDataUtil.observeData(this, Observer {
            if (MessageEvent.hide_safety_advice == it?.msg_type) {
                rl_safety_advice.visibility = if (CpPreferenceManager.getBoolean(mActivity, "isShowSafetyAdviceDialog", true)) View.VISIBLE else View.GONE
//                rl_safety_advice.visibility = View.GONE
            }
        })


    }

    override fun fragmentVisibile(isVisibleToUser: Boolean) {
        super.fragmentVisibile(isVisibleToUser)
        if (isVisibleToUser) {
            isLogined = UserDataService.getInstance().isLogined
            if (isLogined) {
                adapter4Heat?.notifyDataSetChanged()
                setAssetViewVisible()
                getAccountBalance()
                for (fragment in fragments) {
                    if(fragment is NewVersionAssetOptimizeDetailFragment){
                        fragment.clearViewing()
                    }
                }
            }
        }
    }

    var versionAssetStatus = false
    fun activityRefresh(status: Boolean) {
        versionAssetStatus = status
        var message = MessageEvent(MessageEvent.into_my_asset_activity, versionAssetStatus)
        NLiveDataUtil.postValue(message)
    }


    fun refresh4Homepage() {
        adapter4Heat?.notifyDataSetChanged()
        if (UserDataService.getInstance().isLogined) {
            getAccountBalance()
        }
    }

    var isShowAssets = true
    private fun setAssetViewVisible() {
        isShowAssets = UserDataService.getInstance().isShowAssets
        Utils.showAssetsNewSwitch(isShowAssets, iv_hide_asset)
    }

    fun setSelectClick() {
        appBarLayout.addOnOffsetChangedListener(AppBarLayout.OnOffsetChangedListener { appBarLayout, verticalOffset ->
            if (verticalOffset == 0) {
                // AppBarLayout is fully expanded
                tv_title_top.visibility = View.INVISIBLE
            } else if (Math.abs(verticalOffset) >= appBarLayout.totalScrollRange) {
                // appbarlayout is fully folded
                tv_title_top.visibility = View.VISIBLE
            } else {
                // the state between expanding and collapsing
            }
        })


        /**
         *Click to hide or display funds
         */
        iv_hide_asset.setOnClickListener {
            isShowAssets = !isShowAssets
            UserDataService.getInstance().setShowAssetStatus(isShowAssets)
            setAssetViewVisible()

            adapter4Heat?.notifyDataSetChanged()
            for (fragment in fragments) {
                if (fragment is ClContractAssetFragment) {
                    contractAssetFragment?.setRefreshAdapter()
                } else {
                    (fragment as NewVersionAssetOptimizeDetailFragment).setRefreshAdapter()
                }
            }
            refresh()
        }

        rl_safety_advice.setSafeListener {
            NewDialogUtils.showSimpleSafetyAdviceDialog(requireContext(), OnCpBindViewListener { viewHolder ->
                viewHolder?.let {
                    it.getView<TextView>(R.id.tv_cancel_btn).onLineText("common_text_btnCancel")
                    it.setImageResource(R.id.iv_logo, R.drawable.sl_create_contract)
                    it.setText(R.id.tv_text, LanguageUtil.getString(context, "assets_security_advice_tips"))
                    it.setText(R.id.tv_confirm_btn, LanguageUtil.getString(context, "alert_common_i_understand"))
                }

            }, object : NewDialogUtils.DialogBottomListener {
                override fun sendConfirm() {
                    var messageEvent = MessageEvent(MessageEvent.hide_safety_advice)
                    NLiveDataUtil.postValue(messageEvent)
                }
            })
        }

        rl_safety_advice.visibility = if (CpPreferenceManager.getBoolean(mActivity, "isShowSafetyAdviceDialog", true)) View.VISIBLE else View.GONE

    }

    fun refresh() {
        adapter4Heat?.notifyDataSetChanged()
        if (null == totalBalance) return
        Utils.assetsHideShowJrLongData(UserDataService.getInstance().isShowAssets, tv_assets_btc_balance, totalBalance, legalCurrency)
//        Utils.assetsHideShow(UserDataService.getInstance().isShowAssets, tv_assets_btc_balance, totalBalance)
//        Utils.assetsHideShow(UserDataService.getInstance().isShowAssets, tv_assets_legal_currency_balance, legalCurrency)
    }

    override fun initView() {
        setSelectClick()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            appBarLayout.setOutlineProvider(null);
            collapsingToolbarLayout.setOutlineProvider(ViewOutlineProvider.BOUNDS);
        }
        tv_title_top.text = "mainTab_text_assets".tr(mActivity!!)
        tv_assets_title.setText(LanguageUtil.getString(activity,"assets_total_balances"))
        tv_safety_advice.setText(LanguageUtil.getString(activity,"assets_security_advice"))
        tv_safety_advice_look.setText(LanguageUtil.getString(activity,"otc_text_adLook"))
        otcOpen = PublicInfoDataService.getInstance().otcOpen(null)
        contractOpen = PublicInfoDataService.getInstance().contractOpen(null)
        b2cOpen = PublicInfoDataService.getInstance().getB2CSwitchOpen(null)
        leverOpen = PublicInfoDataService.getInstance().isLeverOpen(null)

        var jsonObject = JSONObject()
        jsonObject.put("title", LanguageUtil.getString(context, "otc_bibi_account"))
        jsonObject.put("totalBalanceSymbol", "BTC")
        jsonObject.put("totalBalance", "0")
        jsonObject.put("balanceType", ParamConstant.BIBI_INDEX)
        assetlist.add(jsonObject)
        val otcText = if (PublicInfoDataService.getInstance().getB2CSwitchOpen(null)) {
            LanguageUtil.getString(context, "assets_text_otc_forotc")
        } else {
            LanguageUtil.getString(context, "assets_text_otc")
        }

        if (ApiConstants.HOME_VIEW_STATUS != ParamConstant.CONTRACT_HOME_PAGE) {
            if (leverOpen) {
                var jsonObject = JSONObject()
                jsonObject.put("title", LanguageUtil.getString(context, "leverage_asset"))
                jsonObject.put("totalBalanceSymbol", "BTC")
                jsonObject.put("totalBalance", "0")
                jsonObject.put("balanceType", ParamConstant.LEVER_INDEX)
                assetlist.add(jsonObject)
            }

            if (b2cOpen) {
                var jsonObject = JSONObject()
                jsonObject.put("title", LanguageUtil.getString(context, "assets_text_otc"))
                jsonObject.put("totalBalanceSymbol", "BTC")
                jsonObject.put("totalBalance", "0")
                jsonObject.put("balanceType", ParamConstant.B2C_INDEX)

                assetlist.add(jsonObject)
            }
        }

        if (otcOpen) {
            var jsonObject = JSONObject()
            jsonObject.put("title", otcText)
            jsonObject.put("totalBalanceSymbol", "BTC")
            jsonObject.put("totalBalance", "0")
            jsonObject.put("balanceType", ParamConstant.FABI_INDEX)
            assetlist.add(jsonObject)
        }
        if (contractOpen) {
            var jsonObject = JSONObject()
            jsonObject.put("title", LanguageUtil.getString(context, "assets_text_contract"))
            jsonObject.put("totalBalanceSymbol", "USDT")
            jsonObject.put("totalBalance", "0")
            jsonObject.put("balanceType", ParamConstant.CONTRACT_INDEX)
            assetlist.add(jsonObject)
        }


        if (titleStatus) {
            rl_title_layout?.visibility = View.GONE
        }


        if (ApiConstants.HOME_VIEW_STATUS == ParamConstant.CONTRACT_HOME_PAGE) {
            tabTitles.add(LanguageUtil.getString(context, "contract_asset_account"))
            indexList.add(ParamConstant.BIBI_INDEX)
            showTitles.add(LanguageUtil.getString(context, "mainTab_text_assets"))

            if (contractOpen) {
                tabTitles.add(LanguageUtil.getString(context, "assets_text_contract"))
                indexList.add(ParamConstant.CONTRACT_INDEX)
                showTitles.add(LanguageUtil.getString(context, "mainTab_text_contract"))
            }

            if (otcOpen) {
                tabTitles.add(otcText)
                indexList.add(ParamConstant.FABI_INDEX)
                showTitles.add(LanguageUtil.getString(context, "mainTab_text_otc"))
            }
        } else {

            tabTitles.add(LanguageUtil.getString(context, "assets_text_exchange"))
            indexList.add(ParamConstant.BIBI_INDEX)
            showTitles.add(LanguageUtil.getString(context, "trade_bb_titile"))

            if (contractOpen) {
                tabTitles.add(LanguageUtil.getString(context, "assets_text_contract"))
                indexList.add(ParamConstant.CONTRACT_INDEX)
                showTitles.add(LanguageUtil.getString(context, "mainTab_text_contract"))
            }

            if (otcOpen) {
                tabTitles.add(otcText)
                indexList.add(ParamConstant.FABI_INDEX)
                showTitles.add(LanguageUtil.getString(context, "mainTab_text_otc"))
            }

            if (leverOpen) {
                tabTitles.add(LanguageUtil.getString(context, "leverage_asset"))
                indexList.add(ParamConstant.LEVER_INDEX)
                showTitles.add(LanguageUtil.getString(context, "contract_action_lever"))

            }
            if (b2cOpen) {
                tabTitles.add(LanguageUtil.getString(context, "assets_text_otc"))
                indexList.add(ParamConstant.B2C_INDEX)
                showTitles.add(LanguageUtil.getString(context, "mainTab_text_otc"))
            }

        }


        tv_title?.text = tabTitles[0]
        for (i in 0 until tabTitles.size) {
            if (indexList[i] == ParamConstant.CONTRACT_INDEX) {
                contractAssetFragment = ClContractAssetFragment()
                fragments.add(contractAssetFragment!!)
                updateContractAccount()
            } else {
                fragments.add(NewVersionAssetOptimizeDetailFragment.newInstance(tabTitles[i], i, indexList[i]))
            }
        }
        adapter4Heat = OTCMyAssetHeatAdapter(assetlist)
        activity_my_asset_rv?.layoutManager = LinearLayoutManager(context, LinearLayoutManager.HORIZONTAL, false)
        activity_my_asset_rv?.adapter = adapter4Heat
//        var snapHelper = PagerSnapHelper()
//        snapHelper.attachToRecyclerView(activity_my_asset_rv ?: return)
        activity_my_asset_rv?.addOnScrollListener(object : RecyclerView.OnScrollListener() {

            var adapterNowPos = 0
            override fun onScrolled(recyclerView: RecyclerView, dx: Int, dy: Int) {
                super.onScrolled(recyclerView, dx, dy)
                var l: LinearLayoutManager = activity_my_asset_rv.layoutManager as LinearLayoutManager
                adapterNowPos = l.findFirstCompletelyVisibleItemPosition()

            }

            override fun onScrollStateChanged(recyclerView: RecyclerView, newState: Int) {
                super.onScrollStateChanged(recyclerView, newState)
                /**There are three types of new states
                 *SCROLL_ State_ IDLE: Currently, RecyclerView is either scrolling or stationary
                 *SCROLL_ State_ DRAGGING: RecyclerView is currently being input externally, such as user touch input.
                 *SCROLL_ State_ SETTLING: Although the current animation in RecyclerView is not externally controlled in the last position.
                //Here is the operation to load more data*/
                if (newState == RecyclerView.SCROLL_STATE_IDLE) {
                    vp_otc_asset?.currentItem = adapterNowPos
                }
            }

        })

        val marketPageAdapter = NVPagerAdapter(childFragmentManager, tabTitles.toMutableList(), fragments)
        vp_otc_asset?.adapter = marketPageAdapter
        vp_otc_asset?.offscreenPageLimit = tabTitles.size
        vp_otc_asset?.addOnPageChangeListener(object : ViewPager.OnPageChangeListener {

            override fun onPageScrollStateChanged(state: Int) {

            }

            override fun onPageScrolled(position: Int, positionOffset: Float, positionOffsetPixels: Int) {

            }

            override fun onPageSelected(position: Int) {
                viewpagePosotion = position
                tv_title?.text = tabTitles[position]
                activity_my_asset_rv?.smoothScrollToPosition(position)
            }
        })
        stl_assets_type.setViewPager(vp_otc_asset, showTitles.toTypedArray())


//        appBarLayout.addOnOffsetChangedListener(object : AppBarLayout.OnOffsetChangedListener {
//            var isShow = true
//            var scrollRange = -1
//            override fun onOffsetChanged(appBarLayout: AppBarLayout, verticalOffset: Int) {
//                if (scrollRange == -1) {
//                    scrollRange = appBarLayout.getTotalScrollRange();
//                }
//                LogUtil.e("scrollRange + verticalOffset", (verticalOffset).toString())
////                val distance = resources.getDimension(R.dimen.dp_30)
////                tv_title_top?.alpha = -verticalOffset / distance - 1
//                if (-verticalOffset >= 150) {
//                    tv_title_top.setTextColor(Color.argb(255, 255, 255, 255))
//                } else {
//                    tv_title_top.setTextColor(Color.argb(-verticalOffset, 255, 255, 255))
//                }
//
////                collapsingToolbarLayout.setExpandedTitleColor(Color.argb(scrollRange + verticalOffset, 255, 255, 255))
////                if (scrollRange + verticalOffset == 0) {
////                    collapsingToolbarLayout.setTitle(LanguageUtil.getString(activity, "mainTab_text_assets"));
////                    isShow = true;
////                } else if (isShow) {
////                    collapsingToolbarLayout.setTitle(" ");
////                    isShow = false;
////                }
//            }
//
//        })
        appBarLayout.addOnOffsetChangedListener(object : AppBarStateChangeListener() {
            override fun onStateChanged(appBarLayout: AppBarLayout?, state: State?) {
                if (state == State.COLLAPSED) {
                    img_line.visibility = View.VISIBLE
                } else {
                    img_line.visibility = View.GONE
                }
            }
        })

        if(PublicInfoDataService.getInstance().isOnlySpot){
            ll_tab.visibility = View.GONE
            rl_safety_advice.visibility = View.GONE
        }
    }

    override fun onMessageEvent(event: MessageEvent) {
        super.onMessageEvent(event)
        if (MessageEvent.assetsTab_type == event.msg_type) {
            val msg_content = event.msg_content
            if (null != msg_content && msg_content is Bundle) {
                val vpPos = msg_content.getInt(ParamConstant.assetTabType)
                setViewPagePosition(vpPos)
            }
        }
        if (MessageEvent.refresh_local_coin_trans_type == event.msg_type) {
            val msg_content = event.msg_content
            if (null != msg_content && msg_content is Bundle) {
                val content = msg_content.getString(ARG_INDEX)
                when (content) {
                    //Spot
                    ParamConstant.BIBI_INDEX -> {
                        getAccountBalance()
                    }
                    //Fiat currency
                    ParamConstant.FABI_INDEX -> {
                        getAccountBalance4OTC()
                    }
                    //Lever
                    ParamConstant.LEVER_INDEX -> {
                        getLeverData()
                    }
                    //B2C
                    ParamConstant.B2C_INDEX-> {
                        getB2CAccount()
                    }
                }
            }
        }
    }


    var accountBean: JSONObject = JSONObject()

    /**
     *Obtaining Account Information in Legal Currency
     */
    private fun getAccountBalance4OTC() {
        addDisposable(getMainModel().otc_account_list(object : NDisposableObserver() {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                var t = jsonObject.optJSONObject("data")
                if (leverOpen && b2cOpen) {
                    if (assetlist.size > 3) {
                        assetlist.get(3).put("totalBalance", t.optString("totalBalance") ?: "")
                        assetlist.get(3).put("totalBalanceSymbol", t.optString("totalBalanceSymbol")
                                ?: "")
                    }
                } else if (leverOpen || b2cOpen) {
                    assetlist.get(2).put("totalBalance", t.optString("totalBalance") ?: "")
                    assetlist.get(2).put("totalBalanceSymbol", t.optString("totalBalanceSymbol")
                            ?: "")
                } else {
                    assetlist.get(1).put("totalBalance", t.optString("totalBalance") ?: "")
                    assetlist.get(1).put("totalBalanceSymbol", t.optString("totalBalanceSymbol")
                            ?: "")
                }


                if (contractOpen) {
                    getContractAccount()
                }
                refresh()

                var message = MessageEvent(MessageEvent.refresh_local_trans_type)
                message.msg_content = t
                NLiveDataUtil.postValue(message)
            }
        }))

    }

    var isFristRequest = true

    /**
     *Obtain account information Bibi
     */
    private fun getAccountBalance() {
        var loadingActivity = activity
        if (!isFristRequest) {
            loadingActivity = null
        }
        addDisposable(getMainModel().accountBalance(object : NDisposableObserver(loadingActivity) {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                closeLoadingDialog()
                isFristRequest = false

                var json = jsonObject.optJSONObject("data")
                vp_otc_asset ?: return
                activity_my_asset_rv ?: return
                accountBean = json
                assetlist.get(0).put("totalBalance", json.optString("totalBalance") ?: "")
                assetlist.get(0).put("totalBalanceSymbol", json.optString("totalBalanceSymbol")
                        ?: "")
                vp_otc_asset?.currentItem = viewpagePosotion
                activity_my_asset_rv?.smoothScrollToPosition(viewpagePosotion)
                if (ApiConstants.HOME_VIEW_STATUS == ParamConstant.CONTRACT_HOME_PAGE) {
                    if (otcOpen) {
                        getAccountBalance4OTC()
                    } else if (contractOpen) {
                        getContractAccount()
                    }
                } else {
                    if (leverOpen) {
                        getLeverData()
                    } else if (b2cOpen) {
                        getB2CAccount()
                    } else if (otcOpen) {
                        getAccountBalance4OTC()
                    } else if (contractOpen) {
                        getContractAccount()
                    }
                }
                getTotalAssets()

                refresh()

                var message = MessageEvent(MessageEvent.refresh_local_coin_trans_type)
                message.msg_content = json
                NLiveDataUtil.postValue(message)

            }

            override fun onResponseFailure(code: Int, msg: String?) {
                super.onResponseFailure(code, msg)
                isFristRequest = false
            }


        }))
    }

    private fun getContractAccount() {
//        try {
//            ContractUserDataAgent.getContractAccounts(true)
//        } catch (e: Exception) {
//        }
    }

    var titleStatus = false
    var viewpagePosotion = 0

    /**
     *Update account information contract
     */
    private fun updateContractAccount() {
        val totalBalanceSymbol = "BTC"
//        val totalBalance = ContractUtils.calculateTotalBalance(totalBalanceSymbol)
        val totalBalance = "0"

        if (leverOpen && b2cOpen && otcOpen) {
            if (assetlist.size > 4) {
                assetlist.get(4).put("totalBalance", totalBalance)
                assetlist.get(4).put("totalBalanceSymbol", totalBalanceSymbol)
            }
        } else if ((b2cOpen && otcOpen) || (leverOpen && otcOpen) || (leverOpen && b2cOpen)) {
            if (assetlist.size > 3) {
                assetlist.get(3).put("totalBalance", totalBalance)
                assetlist.get(3).put("totalBalanceSymbol", totalBalanceSymbol)
            }
        } else if ((!leverOpen && !b2cOpen && otcOpen) || (!leverOpen && b2cOpen && !otcOpen) || (leverOpen && !b2cOpen && !b2cOpen)) {
            assetlist.get(2).put("totalBalance", totalBalance)
            assetlist.get(2).put("totalBalanceSymbol", totalBalanceSymbol)
        } else {
            assetlist.get(1).put("totalBalance", totalBalance)
            assetlist.get(1).put("totalBalanceSymbol", totalBalanceSymbol)
        }

        //Refresh header
        refresh()
        contractAssetFragment?.setRefreshAdapter()
    }

    /**
     *Obtain a list of B2C assets
     */
    private fun getB2CAccount() {
        addDisposable(getMainModel().fiatBalance(symbol = "",
                consumer = object : NDisposableObserver() {
                    override fun onResponseSuccess(jsonObject: JSONObject) {
                        val data = jsonObject.optJSONObject("data")
                        if (leverOpen) {
                            assetlist.get(2).put("totalBalance", data.optString("totalBtcValue")
                                    ?: "")
                            assetlist.get(2).put("totalBalanceSymbol", data.optString("totalBalanceSymbol")
                                    ?: "")
                        } else {
                            assetlist.get(1).put("totalBalance", data.optString("totalBtcValue")
                                    ?: "")
                            assetlist.get(1).put("totalBalanceSymbol", data.optString("totalBalanceSymbol")
                                    ?: "")
                        }
                        val allCoinMap = data?.optJSONArray("allCoinMap")
                        if (allCoinMap != null && allCoinMap.length() > 0) {
                            val json = allCoinMap.optJSONObject(0)
                            PublicInfoDataService.getInstance().saveCoinInfo4B2C(json?.optString("symbol"))
                        }
                        if (otcOpen) {
                            getAccountBalance4OTC()
                        } else if (contractOpen) {
//                            ContractUserDataAgent.getContractAccounts(true)
                        }
                        refresh()

                        var message = MessageEvent(MessageEvent.refresh_local_b2c_coin_trans_type)
                        message.msg_content = data
                        NLiveDataUtil.postValue(message)

                    }

                }))
    }

    /**
     *Obtain total assets
     */
    private fun getTotalAssets() {
        addDisposable(getMainModel().getTotalAsset(
                consumer = object : NDisposableObserver() {
                    override fun onResponseSuccess(jsonObject: JSONObject) {
                        val data = jsonObject.optJSONObject("data")
                        if (null == totalBalance) {
                            totalBalance = data.optString("totalBalance")
                        } else {

                            totalBalance = BigDecimalUtil.add(data.optString("totalBalance"), contractTotal.toString(), NCoinManager.getCoinShowPrecision("BTC")).toPlainString()
                        }
//Total assets conversion calculation: total spot assets+total assets in French currency+total contract Business valuation+leverage net assets (total assets - loan assets)

                        updateAsset(false)
                    }
                }))
    }


    fun updateAsset(status: Boolean) {
        if (status) {
            totalBalance = BigDecimalUtil.add(totalBalance, contractTotal.toString(), NCoinManager.getCoinShowPrecision("BTC")).toPlainString()
        } else {
            totalBalance = BigDecimalUtil.add(totalBalance, "0", NCoinManager.getCoinShowPrecision("BTC")).toPlainString()
        }
        legalCurrency = RateManager.getCNYByCoinName("BTC", totalBalance)
        Utils.assetsHideShowJrLongData(UserDataService.getInstance().isShowAssets,tv_assets_btc_balance,totalBalance,legalCurrency)
//        Utils.assetsHideShow(UserDataService.getInstance().isShowAssets, tv_assets_btc_balance, totalBalance)
//        Utils.assetsHideShow(UserDataService.getInstance().isShowAssets, tv_assets_legal_currency_balance, legalCurrency)
    }


    fun hideTitle(status: Boolean) {
        titleStatus = status
        rl_title_layout?.visibility = View.GONE
    }

    fun setViewPagePosition(position: Int) {
        chooseIndex = position
        viewpagePosotion = position
        vp_otc_asset?.currentItem = viewpagePosotion
    }

    /**
     *Leverage List
     */

    fun getLeverData() {
        addDisposable(getMainModel().getBalanceList(object : NDisposableObserver() {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                var json: JSONObject? = jsonObject.optJSONObject("data") ?: return
                var jsonLeverMap: JSONObject? = json?.optJSONObject("leverMap") ?: return
                assetlist.get(1).put("totalBalance", json.optString("totalBalance")
                        ?: "")
                assetlist.get(1).put("totalBalanceSymbol", json.optString("totalBalanceSymbol")
                        ?: "")
                if (b2cOpen) {
                    getB2CAccount()
                } else if (otcOpen) {
                    getAccountBalance4OTC()
                } else if (contractOpen) {
                    getContractAccount()
                }
                refresh()
                var message = MessageEvent(MessageEvent.refresh_local_lever_type)
                message.msg_content = json
                NLiveDataUtil.postValue(message)
            }
        }))
    }

}
private const val ARG_PARAM2 = "param2"

