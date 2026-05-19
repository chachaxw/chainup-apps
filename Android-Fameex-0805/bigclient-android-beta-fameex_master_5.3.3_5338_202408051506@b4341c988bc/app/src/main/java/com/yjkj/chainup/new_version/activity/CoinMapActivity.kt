package com.yjkj.chainup.new_version.activity

import android.app.Activity
import android.content.Context
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.text.Editable
import android.text.TextUtils
import android.text.TextWatcher
import android.view.View
import android.view.inputmethod.InputMethodManager
import android.widget.LinearLayout
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.viewpager.widget.ViewPager
import com.alibaba.android.arouter.facade.annotation.Autowired
import com.alibaba.android.arouter.facade.annotation.Route
import com.alibaba.fastjson.JSON
import com.chainup.contract.eventbus.CpMessageEvent
import com.chainup.contract.utils.CpClLogicContractSetting
import com.chainup.contract.utils.CpJsonUtils
import com.chainup.contract.ws.CpWsContractAgentManager
import com.flyco.tablayout.SlidingTabLayout
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseActivity
import com.yjkj.chainup.db.constant.HomeTabMap
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.service.LikeDataService
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.db.service.SearchDataService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.LoginManager
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.model.model.MainModel
import com.yjkj.chainup.net_new.JSONUtil
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_version.activity.like.view.SearchTopView
import com.yjkj.chainup.new_version.adapter.CoinMapAdapter
import com.yjkj.chainup.new_version.adapter.NVCoinPagerAdapter
import com.yjkj.chainup.new_version.home.NewContractHotDetailFragmentItem
import com.yjkj.chainup.new_version.home.NewHotDetailFragmentItem
import com.yjkj.chainup.new_version.home.homeMarketRecommend
import com.yjkj.chainup.util.*
import com.yjkj.chainup.ws.WsAgentManager
import kotlinx.android.synthetic.main.activity_coin_map.*
import kotlinx.android.synthetic.main.activity_viewpage_list.view.*
import kotlinx.android.synthetic.main.fragment_search_list.*
import kotlinx.android.synthetic.main.fragment_search_list.view.*
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode
import org.jetbrains.anko.find
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject
import java.util.*
import kotlin.collections.ArrayList
import kotlin.collections.HashMap


/**
 * @Date 2023-5-28
 *@description Search&Add Coin Pairs
 *
 *
 */
@Route(path = RoutePath.CoinMapActivity)
class CoinMapActivity : NBaseActivity(), SearchTopView.SearchViewListener,
    WsAgentManager.WsResultCallback,CpWsContractAgentManager.WsResultCallback {
    override fun setContentView() = R.layout.activity_coin_map

    var markList = ArrayList<JSONObject>()
    var searchHistroylist = ArrayList<JSONObject>()
    var likeList = ArrayList<JSONObject>()

    @JvmField
    @Autowired(name = ParamConstant.TYPE)
    var type = ""
    var isSearch = false

    @JvmField
    @Autowired(name = ParamConstant.SEARCH_COIN_MAP_FOR_LEVER)
    var leverStatus = false

    @JvmField
    @Autowired(name = ParamConstant.SEARCH_COIN_MAP_FOR_LEVER_UNREFRESH)
    var refreshLever = false

    @JvmField
    @Autowired(name = ParamConstant.SEARCH_COIN_MAP_FOR_LEVER_INTO_TRANSFER)
    var intoTransfer = false

    @JvmField
    @Autowired(name = "position")
    var position = 0

    lateinit var searchView: SearchTopView

    override fun onInit(savedInstanceState: Bundle?) {
        super.onInit(savedInstanceState)
        ArouterUtil.inject(this)
        setBgFill2()
        window.navigationBarColor = ContextCompat.getColor(this,R.color.bg_search_color)
        isSearch = (type == ParamConstant.SEARCH_COIN_MAP)
        WsAgentManager.instance.addWsCallback(this)
        CpWsContractAgentManager.instance.addWsCallback(this)
        getSearchSymbol()
        tv_cancel?.text = LanguageUtil.getString(this, "common_text_btnCancel")
        et_search?.hint = LanguageUtil.getString(this, "market_search_ex")
        searchView = search_view
        searchView.searchViewListener = this
        marketPageAdapter = NVCoinPagerAdapter(supportFragmentManager, titles, fragments)
        val hotViewPager  = layout_list_hot.fragment_page_list
        hotViewPager?.adapter = marketPageAdapter
        hotViewPager.addOnPageChangeListener(object : ViewPager.OnPageChangeListener {
            override fun onPageScrollStateChanged(state: Int) {
            }

            override fun onPageScrolled(position: Int, positionOffset: Float, positionOffsetPixels: Int) {

            }
            override fun onPageSelected(position: Int) {
                selectPostion = position
            }
        })

        marketPageAdapterSearch = NVCoinPagerAdapter(supportFragmentManager, titlesSearch, fragmentSearch)
        val hotViewPagerSearch  = layout_list_search.fragment_search_page_list
        hotViewPagerSearch?.adapter = marketPageAdapterSearch
        hotViewPagerSearch.addOnPageChangeListener(object : ViewPager.OnPageChangeListener {
            override fun onPageScrollStateChanged(state: Int) {
            }

            override fun onPageScrolled(position: Int, positionOffset: Float, positionOffsetPixels: Int) {

            }
            override fun onPageSelected(position: Int) {
                selectPostion = position
            }
        })
        initOnClickListener()

//        val hint = PublicInfoDataService.getInstance().contractOpen(null).getSearchHint(this)
//        et_search?.hint = hint

        if (leverStatus) {
            getBalanceList()
            return
        } else {
            val tempMarket = NCoinManager.getMarketArray(false)
            if (null != tempMarket && tempMarket.length() > 0) {
                markList.addAll(JSONUtil.arrayToList(tempMarket))
                markList.sortBy { it.optInt("sort") }
            }

            val tempLikeList = LikeDataService.getInstance().getCollecData(false)
            if (null != tempLikeList && tempLikeList.size > 0) {
                likeList.addAll(tempLikeList)
            }
            initSearchHisotry()
        }
        initViews()

    }

    /**
     *Obtain a list of leveraged accounts
     */
    fun getBalanceList() {
        addDisposable(getMainModel().getBalanceList(object : NDisposableObserver() {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                val json = jsonObject.optJSONObject("data")
                val jsonLeverMap = json?.optJSONObject("leverMap")
                searchHistroylist.clear()
                searchHistroylist.addAll(
                    NCoinManager.getLeverMapList(jsonLeverMap)
                        ?: arrayListOf()
                )
                searchHistroylist.sortBy { it?.optInt("sort") }
                markList.clear()
                markList.addAll(searchHistroylist)
                initViews()
            }
        }))
    }


    private fun initOnClickListener() {
        /**
         *Add hidden soft keyboard
         */
        tv_cancel?.setOnClickListener {
            val imm: InputMethodManager =
                getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
            imm.hideSoftInputFromWindow(et_search.windowToken, 0)
            finish()
        }
    }


    fun initViews() {

        /**
         *Listening search edit box
         */
        et_search?.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(s: Editable?) {
                var resultList = getSearchMatchList(s.toString())
                if (!leverStatus) {
                    resultList = getLikeData(resultList, 0)
                }
                if (TextUtils.isEmpty(s.toString())) {
//                    initHot()
                    initSearchHisotry()
                    layout_list_search.visibility = View.GONE
                    initWsData(JSONUtil.arrayToList(JSONArray(recommStr)))
                } else {
                    layout_list_search.visibility = View.VISIBLE
                    initSearchView(resultList, s.toString())
                }
            }

            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {
            }

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
            }

        })
        et_search.requestFocus()
        Handler(Looper.getMainLooper()).postDelayed({
            KeyBoardUtils.showKeyBoard(this,et_search)
        },500L)

    }

    /*
     *Local Search
     */
    private fun getSearchMatchList(input: String?): ArrayList<JSONObject>? {

        if (null == input || input.trim().isEmpty() || markList.size <= 0) {
            return null
        }

        val temp = ArrayList<JSONObject>()
        markList.forEach {
            var name = NCoinManager.showAnoterName(it)
            if (null != name) {
                if (name.contains(input.toUpperCase()) || name.contains(input.toLowerCase()) || name.contains(
                        input
                    )
                ) {
                    temp.add(it)
                }
            }
        }
        return if (leverStatus) {
            temp
        } else {
            getLikeData(temp, 0)
        }

    }

    override fun onResume() {
        super.onResume()
        initSearchHisotry()
        subContractWs()
        val searchContent = et_search.text.toString()

        if(searchContent.isEmpty()){
            if("".equals(recommStr)) return
            initWsData(JSONUtil.arrayToList(JSONArray(recommStr)))
        }else{
            val resultList = getSearchMatchList(searchContent)
            initWsData(resultList)
        }

    }

    /*
     *Determine whether it exists in the selected data and return a newList
     *
     *@param count=Top 5 out of 5
     */
    private fun getLikeData(list: ArrayList<JSONObject>?, count: Int): ArrayList<JSONObject>? {
        if (null == list || list.size <= 0)
            return list

        val tempList = ArrayList<JSONObject>()

        for (i in 0 until list.size) {
            if (count > 0 && i == count) {
                return tempList
            }
            val obj = list[i]
            for (v in likeList) {
                if (obj.optString("symbol").equals(v.optString("symbol"), true)) {
                    obj.put("isAdd", true)
                }
            }
            tempList.add(obj)
        }
        return tempList
    }

    /**
     *Add or delete custom data
     *@param operationType identifier 0 (batch addition)/1 (single addition)/2 (single deletion)
     *@param symbol Single currency pair name
     */
    private fun addOrDeleteSymbol(operationType: Int = 0, symbol: String?) {

        if (null == symbol || !LoginManager.isLogin(this))
            return
        var list = ArrayList<String>()
        list.add(symbol)
        addDisposable(
            getMainModel().addOrDeleteSymbol(
                operationType,
                list,
                object : NDisposableObserver() {
                    override fun onResponseSuccess(jsonObject: JSONObject) {
                        if (operationType == 1) {
                            NToastUtil.showTopToastNet(
                                this@CoinMapActivity,
                                true,
                                LanguageUtil.getString(
                                    this@CoinMapActivity,
                                    "kline_tip_addCollectionSuccess"
                                )
                            )
                            LikeDataService.getInstance().saveCollecData(symbol, null)
                        } else {
                            NToastUtil.showTopToastNet(
                                this@CoinMapActivity,
                                true,
                                LanguageUtil.getString(
                                    this@CoinMapActivity,
                                    "kline_tip_removeCollectionSuccess"
                                )
                            )
                            LikeDataService.getInstance().removeCollect(symbol)
                        }

                    }
                })
        )
    }

    override fun clearSearch() {
        SearchDataService.getInstance().removeSearchData()
        searchHistroylist.clear()
    }

    override fun hotItemClick(name: String) {
        et_search.setText(name)
        et_search.setSelection(name.length)
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    override fun onMessageEvent(event: MessageEvent) {
        super.onMessageEvent(event)
        when (event.msg_type) {
            MessageEvent.symbol_switch_type -> {
                finish()
            }
            MessageEvent.like_coin_symbol_type -> {
                val type = event.msg_content_data as Int
                val symbol = event.msg_content as String
                if (event.ismBibi()) {
                    addOrDeleteSymbol(type, symbol)
                }
            }
        }

    }

    private var recommStr = ""
    val fragments = arrayListOf<Fragment>()
    var selectPostion = 0

    val fragmentSearch = arrayListOf<Fragment>()

    /**
     *Obtain a list of leveraged accounts
     */
    fun getSearchSymbol() {
        addDisposable(getMainModel().searchRecommendSymbol(object : NDisposableObserver() {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                val json = jsonObject.optJSONObject("data")
                json?.apply {
                    recommStr = optJSONArray("recommendSymbolList").toString()
                    initHot()
                }
            }
        }))
    }

    var titles = arrayListOf<String>()

    var titlesSearch = arrayListOf<String>()

    private fun initHot() {
        initSearchHisotry()
        titles.clear()
        titles.add(LanguageUtil.getString(this, "search_topSearch_title"))
        if (titles.isEmpty())
            return
        fragments.clear()
        LogUtil.e(TAG, "initSearchView ${recommStr}")
        //Popular searches
        val hotFragment = NewHotDetailFragmentItem.newInstance("hot", 0, "", recommStr).apply {
            intoTransfer = this@CoinMapActivity.intoTransfer
            leverStatus = this@CoinMapActivity.leverStatus
            isSearch = this@CoinMapActivity.isSearch
            refreshLever = this@CoinMapActivity.refreshLever
        }
        fragments.add(hotFragment)

        initWsData(JSONUtil.arrayToList(JSONArray(recommStr)))
        marketPageAdapter?.notifyDataSetChanged()
        val hotViewPager  = layout_list_hot.fragment_page_list
        val tabList  = layout_list_hot.stl_tab_list
        hotViewPager.offscreenPageLimit = titles.size
        tabList.setViewPagerFont(hotViewPager, titles.toTypedArray())

    }

    var marketPageAdapter: NVCoinPagerAdapter? = null

    var marketPageAdapterSearch: NVCoinPagerAdapter? = null

    private fun initSearchView(items: ArrayList<JSONObject>?, searchStr: String) {
        fragmentSearch.clear()
        titlesSearch.clear()
        titlesSearch.add(LanguageUtil.getString(this, "mainTab_text_transaction"))
        val bibi = "bibi"
        val tempStr = JSONArray(items).toString()
        initWsData(items)
        LogUtil.e(TAG, "initSearchView ${items?.size}")
        //Spot
        val searchFragment = NewHotDetailFragmentItem.newInstance(bibi, 0, bibi, tempStr)
            .apply {
                intoTransfer = this@CoinMapActivity.intoTransfer
                leverStatus = this@CoinMapActivity.leverStatus
                isSearch = this@CoinMapActivity.isSearch
                refreshLever = this@CoinMapActivity.refreshLever
            }
        fragmentSearch.add(searchFragment)

        if (titlesSearch.isEmpty())
            return
        //Contract
        if (PublicInfoDataService.getInstance().contractOpen(null)) {
            titlesSearch.add(LanguageUtil.getString(this, "trade_contract_title"))
            val contract = "contract"

            val searchContractFragment = NewContractHotDetailFragmentItem.newInstance(contract, 1, contract, searchStr)
                .apply {
                    intoTransfer = this@CoinMapActivity.intoTransfer
                    leverStatus = this@CoinMapActivity.leverStatus
                    isSearch = this@CoinMapActivity.isSearch
                    refreshLever = this@CoinMapActivity.refreshLever
                }
            fragmentSearch.add(searchContractFragment)

        }

        val searchViewPagerSearch  = layout_list_search.fragment_search_page_list
        searchViewPagerSearch.currentItem = position
        marketPageAdapterSearch?.notifyDataSetChanged()
        val hotViewPager  = fragment_search_page_list
        val tabList  = stl_search_tab_list
        hotViewPager.offscreenPageLimit = titlesSearch.size
        tabList.setViewPagerFont(hotViewPager, titlesSearch.toTypedArray())
    }

    private fun initSearchHisotry() {
        var tempHistoryList = SearchDataService.getInstance().searchData
        if (tempHistoryList.isNotEmpty()) {
            Collections.reverse(tempHistoryList)
        }
        val isNull = tempHistoryList != null && tempHistoryList.size != 0
        if (isNull) {
            searchView.initTopView(tempHistoryList)
            if (!leverStatus) {
//                if (tempHistoryList.isNotEmpty())
//                    homeMarketRecommend(this@CoinMapActivity, searchView.getItemView())
            }
        }

        searchView.visibility = isNull.getVisible()
        searchView.visibility =if (TextUtils.isEmpty(et_search.text.toString())) View.VISIBLE else View.GONE
        searchView.initItems(isNull)

    }

    override fun onWsMessage(json: String) {
        val fragment = (if(layout_list_search.visibility == View.GONE) fragments else fragmentSearch).get(currentItem())
        if (fragment is NewHotDetailFragmentItem) {
            val json = JSONObject(json)
            fragment.showWsData(json)
        }
    }

    private fun initWsData(items: ArrayList<JSONObject>?) {
        if (items == null) {
            return
        }

        WsAgentManager.instance.unbind(this, true)
        var arrays = arrayListOf<String>()
        for (item in items) {
            arrays.add(item.getString("symbol"))
        }
        val json = JsonUtils.gson.toJson(arrays)
        WsAgentManager.instance.sendMessage(hashMapOf("bind" to true, "symbols" to json), this)
    }

    private fun currentItem(): Int {
        return if(layout_list_search.visibility == View.GONE){
            layout_list_hot.fragment_page_list
        } else {
            fragment_search_page_list
        }.currentItem
    }

    override fun onPause() {
        super.onPause()
        WsAgentManager.instance.unbind(this, true)
        CpWsContractAgentManager.instance.unbind(this,true)
    }


    override fun onCpMessageEvent(event: CpMessageEvent) {
        if (CpMessageEvent.contract_switch_type == event.msg_type) {
            finish()
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        WsAgentManager.instance.removeWsCallback(this)
        CpWsContractAgentManager.instance.removeWsCallback(this)
    }

    override fun onCpWsMessage(json: String) {
        if(layout_list_search.visibility == View.GONE) return
        if(fragmentSearch.size<=1) return
        val contractFragment = fragmentSearch[1] as? NewContractHotDetailFragmentItem
        val jsonObj = JSONObject(json)
        contractFragment?.showWsData(jsonObj)
    }

    private fun subContractWs() {
        if(!PublicInfoDataService.getInstance().contractOpen(null)) return
        val symbolsName = arrayListOf<String>()
        var mContractObj = CpClLogicContractSetting.getContractJsonListStr(mActivity)
        if (!TextUtils.isEmpty(mContractObj)){
            var mContractList = JSONArray(mContractObj)
            for (i in 0..(mContractList.length() - 1)) {
                var obj: JSONObject = mContractList.get(i) as JSONObject
                val currentSymbolBuff = (obj.getString("contractType") + "_" + obj.getString("symbol")
                    .replace("-", "")).lowercase(
                    Locale.getDefault()
                )
                symbolsName.add(currentSymbolBuff)
            }
            val rmap = HashMap<String, Any>()
            rmap["bind"] = true
            rmap["symbols"] = CpJsonUtils.gson.toJson(symbolsName)
            CpWsContractAgentManager.instance.sendMessage(rmap,this)
        }
    }

}
