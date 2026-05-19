package com.yjkj.chainup.new_version.fragment

import android.os.Handler
import android.util.Log
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import android.view.View
import com.chainup.contract.view.CpTabEntity
import com.chainup.kit.views.KKEmptyViewKit
import com.flyco.tablayout.listener.CustomTabEntity
import com.flyco.tablayout.listener.OnTabSelectListener
import com.google.gson.Gson
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseFragment
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.service.LikeDataService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.extra_service.eventbus.EventBusUtil
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.LoginManager
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_version.adapter.MarketDetailAdapter
import com.yjkj.chainup.new_version.dialog.DialogUtil
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.home.callback.MarketTabDiffCallback
import com.yjkj.chainup.new_version.home.homeMarketItemTips
import com.yjkj.chainup.new_version.view.EmptyForAdapterView
import com.yjkj.chainup.util.*
import com.yjkj.chainup.ws.WsAgentManager
import kotlinx.android.synthetic.main.fragment_market_detail.rv_market_detail
import kotlinx.android.synthetic.main.fragment_market_detail.swipe_refresh
import kotlinx.android.synthetic.main.include_market_sort.*
import okhttp3.internal.filterList
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode
import org.jetbrains.anko.doAsync
import org.jetbrains.anko.imageResource
import org.json.JSONObject


/**
 * @Author: Bertking
 * @Date 2023-06-15-15:26
 * @Description:
 */

class MarketTrendFragment : NBaseFragment() {


    override fun setContentView() = R.layout.fragment_market_detail

    override fun initView() {
        Log.d("CeshiLike","MarketTrendFragment initView>>>")
        tv_name?.text = LanguageUtil.getString(context, "home_action_coinNameTitle")
        tv_new_price?.text = LanguageUtil.getString(context, "home_text_dealLatestPrice")
        tv_limit?.text = LanguageUtil.getString(context, "common_text_priceLimit")
//        swipe_refresh.setColorSchemeColors(ContextUtil.getColor(R.color.colorPrimary))
        initAdapter()
        setOnclick()
        setOnScrowListener()
    }


    override fun loadData() {
        super.loadData()

        marketName = arguments?.getString(MARKET_NAME) ?: ""
        curIndex = arguments?.getInt(CUR_INDEX) ?: 1

        if (null == marketName || marketName.isEmpty())
            return
        LogUtil.e(TAG, "loadData ${marketName}")
        val arrays =  NCoinManager.getMarketByNameNew(marketName);

        var mAllMarketStr=  MarketUtil.getAllMarketData();

        symbols = arrays.first
        symbolType = arrays.second

        setMarket2List(symbols,mAllMarketStr);

        LogUtil.e(TAG,"symbolType ${symbolType}")
        if (null == symbols || symbols.isEmpty())
            return

        oriSymbols.clear()
        oriSymbols.addAll(symbols)

        normalTickList.clear()
        normalTickList.addAll(oriSymbols)

        normalTickList?.sortBy { it?.optInt("sort") }

    }

    private fun setMarket2List(first: java.util.ArrayList<JSONObject>?, mAllMarketStr: String) {
        if("".equals(mAllMarketStr.trim())) return
        val mAllMarketJson = JSONObject(mAllMarketStr)
        first?.forEach {
            var symbolBuff= it.optString("symbol")
           if( !mAllMarketJson.isNull(symbolBuff)){
               var symbolJson=mAllMarketJson.optJSONObject(symbolBuff)
               it.put("rose",symbolJson.optString("rose"))
               it.put("close",symbolJson.optString("close"))
               it.put("vol",symbolJson.optString("vol"))
           }
        }
    }

    var adapterScroll = false
    private fun setOnScrowListener() {
        rv_market_detail?.addOnScrollListener(object : RecyclerView.OnScrollListener() {

            override fun onScrollStateChanged(recyclerView: RecyclerView, newState: Int) {
                super.onScrollStateChanged(recyclerView, newState)
                if (RecyclerView.SCROLL_STATE_DRAGGING == newState || RecyclerView.SCROLL_STATE_SETTLING == newState) {
                    adapterScroll = true
                } else {
                    adapterScroll = false
                }
            }
        })
    }

    private fun initAdapter() {
        if (null == adapter) {
            adapter = MarketDetailAdapter()
            rv_market_detail?.layoutManager = LinearLayoutManager(mActivity)
            rv_market_detail?.adapter = adapter
            adapter?.notifyDataSetChanged()
            rv_market_detail?.isNestedScrollingEnabled = false
            rv_market_detail?.setHasFixedSize(true)
            rv_market_detail?.setItemViewCacheSize(8)
            ll_item_titles?.visibility = View.VISIBLE
            adapter?.setEmptyView(KKEmptyViewKit(context ?: return))
        }

        adapter?.setList(normalTickList)
        initReq()
        adapter?.setOnItemClickListener { adapter, _, position ->
            adapter?.apply {
                val model = (data.get(position) as JSONObject)
                ArouterUtil.forwardKLine(model.optString("symbol"))
            }
        }
        adapter?.setOnItemLongClickListener { _adapter, view, position ->
            var mJSONObject:JSONObject= _adapter.data.get(position) as JSONObject
            val symbol=   mJSONObject.optString("symbol")
            var hasCollect = LikeDataService.getInstance().hasCollect(symbol)
            adapter?.modifySelBg(position,true)
            DialogUtil.createMarketPop(requireContext(), view,!hasCollect,dialogItemClickListener=object :
                NewDialogUtils.DialogOnSigningItemClickListener {
                override fun clickItem(pos: Int, text: String) {
                    if (hasCollect){
                        LikeDataService.getInstance().removeCollect(symbol)
                    }else{
                        LikeDataService.getInstance().saveCollecData(symbol, null)
                    }
                    if (!LoginManager.isLogin(mActivity)) {
                        if (!hasCollect) {
                            NToastUtil.showTopToast(true, LanguageUtil.getString(mActivity, "kline_tip_addCollectionSuccess"))
                        } else {
                            NToastUtil.showTopToast(true, LanguageUtil.getString(mActivity, "kline_tip_removeCollectionSuccess"))
                        }
                    }
                    addOrDeleteSymbol(operationType=if (hasCollect) 2 else 1, symbol=symbol)
                    _adapter.notifyItemChanged(position)
                    val messageEvent = MessageEvent(MessageEvent.like_coin_symbol_type,symbol,1,true)
                    EventBusUtil.post(messageEvent)
                }

                override fun onDismiss() {
                    adapter?.modifySelBg(position,false)
                }
            })
            true
        }

        //Only the main area (1) or not displaying level 3 tabs
        if(symbolType.size == 0 || (symbolType.size == 1 && symbolType.containsKey(1)) ){
            stl_market_chain_type.visibility = View.GONE
        } else {
            stl_market_chain_type.visibility = View.VISIBLE
            val chainList = arrayListOf<CustomTabEntity>()
            chainList.add(CpTabEntity(LanguageUtil.getString(mActivity, "otc_all"),0,0))
            symbolType.forEach {
                symbolSortType.put(chainList.size,it.key)
                chainList.add(CpTabEntity(it.key.byMarketGroupTypeGetName(mActivity!!),0,0))
            }
            stl_market_chain_type.setTabDataFont(chainList)
        }
    }

    /**
     *Original
     */
    private var oriSymbols = arrayListOf<JSONObject>()

    private var normalTickList = arrayListOf<JSONObject>()

    var adapter: MarketDetailAdapter? = null

    private var marketName = ""
    private var curIndex = 1
    var selectIndex = 1
        set(value) {
            field = value
        }
    private var symbols = arrayListOf<JSONObject>()
    private var symbolType = hashMapOf<Int,String>()
    private var symbolSortType = hashMapOf<Int,Int>()

    var nameIndex = 0
    var newPriceIndex = 0
    var limitIndex = 0

    var isScrollStatus = false
    /**
     *Click Event
     */
    fun setOnclick() {
        /**
         *Click on the name
         */
        ll_name.setOnClickListener {
            refreshTransferImageView(0)
            adapter?.isMarketSort = false
            val normalTickList = adapter?.data
            if (normalTickList.isNullOrEmpty()) return@setOnClickListener
            when (nameIndex) {
                /**
                 *Normal
                 */
                0 -> {
                    normalTickList.sortBy { NCoinManager.showAnoterName(it) }
                    nameIndex = 1
                    iv_name_up?.imageResource = R.mipmap.quotes_on
                }
                /**
                 *Positive order
                 */
                1 -> {
                    normalTickList.sortByDescending { NCoinManager.showAnoterName(it) }
                    nameIndex = 2
                    iv_name_up?.imageResource = R.mipmap.quotes_under
                }
                /**
                 *Reverse order
                 */
                2 -> {
                    normalTickList.sortBy { it.optInt("sort") }
                    nameIndex = 0
                    iv_name_up?.imageResource = R.mipmap.quotes_default
                }
            }

            refreshAdapter(normalTickList as ArrayList<JSONObject>)
        }
        /**
         *Click on the latest price
         */
        ll_new_price.setOnClickListener {
            refreshTransferImageView(1)
            val normalTickList = adapter?.data
            if (normalTickList.isNullOrEmpty()) return@setOnClickListener
            when (newPriceIndex) {
                /**
                 *Normal
                 */
                0 -> {
                    normalTickList.sortBy { it.optDouble("close") }
                    newPriceIndex = 1
                    iv_new_price?.imageResource = R.mipmap.quotes_on

                }
                /**
                 *Positive order
                 */
                1 -> {
                    normalTickList.sortByDescending { it.optDouble("close") }
                    newPriceIndex = 2
                    iv_new_price?.imageResource = R.mipmap.quotes_under
                }
                /**
                 *Reverse order
                 */
                2 -> {
                    normalTickList.sortBy { it.optInt("sort") }
                    newPriceIndex = 0
                    iv_new_price?.imageResource = R.mipmap.quotes_default

                }
            }
            adapter?.isMarketSort = newPriceIndex != 0
            refreshAdapter(normalTickList as ArrayList<JSONObject>)
        }
        /**
         *Click on 24-hour increase
         */
        ll_limit.setOnClickListener {
            refreshTransferImageView(2)
            val normalTickList = adapter?.data
            if (normalTickList.isNullOrEmpty()) return@setOnClickListener
            when (limitIndex) {
                /**
                 *Normal
                 */
                0 -> {
                    normalTickList.sortBy { it.optDouble("rose", 0.0) }
                    limitIndex = 1
                    iv_new_limit?.imageResource = R.mipmap.quotes_on
                }
                /**
                 *Positive order
                 */
                1 -> {
                    normalTickList.sortByDescending { it.optDouble("rose", 0.0) }
                    limitIndex = 2
                    iv_new_limit?.imageResource = R.mipmap.quotes_under
                }
                /**
                 *Reverse order
                 */
                2 -> {
                    normalTickList.sortBy { it.optInt("sort") }
                    limitIndex = 0
                    iv_new_limit?.imageResource = R.mipmap.quotes_default
                }
            }
            adapter?.isMarketSort = limitIndex != 0
            refreshAdapter(normalTickList as ArrayList<JSONObject>)
        }

        /**
         *Refresh Here
         */
        swipe_refresh?.setOnRefreshListener {
            isScrollStatus = true
            /**
             *Refresh Data Operation
             */
            loadData()
            adapter?.notifyDataSetChanged()
            swipe_refresh?.finishRefresh(true)
        }

        stl_market_chain_type?.setOnTabSelectListener(object : OnTabSelectListener {
            override fun onTabSelect(position: Int) {
                val chainType = symbolSortType.get(position)
                val normalList = if(position == 0 ) normalTickList  else  normalTickList.filterList { optInt("newcoinFlag") == chainType }
                adapter?.setList(normalList)

            }

            override fun onTabReselect(position: Int) {

            }

        })
    }


    fun handleData(data: String) {

        if(!mIsVisibleToUser || adapterScroll) return

        

        try {
            val json = JSONObject(data)
            if (!json.isNull("tick")) {
                doAsync {
                    val quotesData = json
                    showWsData(quotesData)
                }
            } else {
                if (!json.isNull("data")) {
                    doAsync {
                        val array = json.optJSONObject("data")
                        if (null != array && array.length() > 0) {
                            val it = array.keys()
                            LogUtil.d(TAG, "showWsData== req count ${array.length()}")
                            val wsArrayMap = hashMapOf<String, JSONObject>()
                            normalTickList.forEach {
                                val key = it.getString("symbol")
                                val tick = array.optJSONObject(key)
                                if (tick != null) {
                                    val itemObj = JSONObject()
                                    itemObj.put("tick", tick)
                                    itemObj.put("channel", "market_${key}_ticker")
                                    wsArrayMap.put(itemObj.optString("channel", ""), itemObj)
                                }
                            }
                            LogUtil.e(TAG, "dropListsAdapter req ${marketName} list ${normalTickList.size} ${wsArrayMap.size}")
                            dropListsAdapter(wsArrayMap)
                        }
                    }
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    @Synchronized
    private fun showWsData(jsonObject: JSONObject) {
        if (normalTickList.isEmpty())
            return
        val dataDiff = callDataDiff(jsonObject)
        if (dataDiff != null) {
            val items = dataDiff.second
            dropListsAdapter(items)
            wsArrayTempList.clear()
            wsArrayMap.clear()
        }
    }


    fun startInit() {
        Handler().postDelayed({
            pageEventSymbol()
        }, 200)
    }


    private fun refreshTransferImageView(status: Int) {
        when (status) {
            0 -> {
                iv_new_price?.imageResource = R.mipmap.quotes_default
                iv_new_limit?.imageResource = R.mipmap.quotes_default
                newPriceIndex = 0
                limitIndex = 0
            }
            1 -> {
                iv_name_up?.imageResource = R.mipmap.quotes_default
                iv_new_limit?.imageResource = R.mipmap.quotes_default
                nameIndex = 0
                limitIndex = 0
            }
            2 -> {
                iv_name_up?.imageResource = R.mipmap.quotes_default
                iv_new_price?.imageResource = R.mipmap.quotes_default
                nameIndex = 0
                newPriceIndex = 0
            }
        }

    }

    private fun refreshAdapter(list: ArrayList<JSONObject>) {
        adapter?.replaceData(list)
    }

    private fun pageEventSymbol() {
        if (normalTickList.size == 0) {
            return
        }
        val arrays = arrayOfNulls<String>(normalTickList.size)
        for ((index, item) in normalTickList.withIndex()) {
            arrays.set(index, item.getString("symbol"))
        }
        forwardMarketTab(arrays)
    }

    private fun forwardMarketTab(coin: Array<String?>, isBind: Boolean = true) {
        val messageEvent = MessageEvent(MessageEvent.market_event_page_symbol_type)
        messageEvent.msg_content = hashMapOf("symbols" to coin, "bind" to isBind, "curIndex" to 1)
        EventBusUtil.post(messageEvent)
    }


    private val wsArrayTempList: ArrayList<JSONObject> = arrayListOf()
    private val wsArrayMap = hashMapOf<String, JSONObject>()
    private var wsTimeFirst: Long = 0L

    @Synchronized
    private fun callDataDiff(jsonObject: JSONObject): Pair<ArrayList<JSONObject>, HashMap<String, JSONObject>>? {
        if (System.currentTimeMillis() - wsTimeFirst >= 2000L && wsTimeFirst != 0L) {
            //Greater than one second
            wsTimeFirst = 0L
            if (wsArrayMap.size != 0) {
                return Pair(wsArrayTempList, wsArrayMap)
            }
        } else {
            if (wsTimeFirst == 0L) {
                wsTimeFirst = System.currentTimeMillis()
            }
            wsArrayTempList.add(jsonObject)
            wsArrayMap.put(jsonObject.optString("channel", ""), jsonObject)
        }
        return null
    }

    @Synchronized
    fun dropListsAdapter(items: HashMap<String, JSONObject>) {
        val data = adapter?.data
        if (data?.isEmpty()!!) {
            return
        }
        val message = Gson().toJson(data)
        val jsonCopy = Utils.jsonToArrayList(message, JSONObject::class.java)
        val tempNew = jsonCopy
        for ((index, item) in items.entries) {
            val jsonObject = item
            val channel = jsonObject.optString("channel")
            var tempData = -1
            for ((coinIndex, coinItem) in data.withIndex()) {
                if (channel == coinItem.optString("symbol").getSymbolChannel()) {
                    tempData = coinIndex
                    break
                }
            }
            if (tempData != -1) {
                val tick = jsonObject.optJSONObject("tick")
                val model = tempNew.get(tempData)
                model.put("rose", tick?.optString("rose"))
                model.put("close", tick?.optString("close"))
                model.put("vol", tick?.optString("vol"))
                tempNew.set(tempData, model)
            }
        }
        if (newPriceIndex != 0 || limitIndex != 0) {
            if (newPriceIndex != 0) {
                when (newPriceIndex) {
                    1 -> {
                        tempNew.sortBy { it.optDouble("close", 0.0) }
                    }
                    2 -> {
                        tempNew.sortByDescending { it.optDouble("close", 0.0) }
                    }
                }
            } else if (limitIndex != 0) {
                when (limitIndex) {
                    1 -> {
                        tempNew.sortBy { it.optDouble("rose", 0.0) }
                    }
                    2 -> {
                        tempNew.sortByDescending { it.optDouble("rose", 0.0) }
                    }
                }
            }
        }
        val diffCallback = MarketTabDiffCallback(data, tempNew)
        activity?.runOnUiThread {
            adapter?.setDiffData(diffCallback)
        }

    }

    private fun initReq() {
        val data = WsAgentManager.instance.reqJson
        if (data != null) {
            doAsync {
                normalTickList.forEach {
                    val key = it.getString("symbol")
                    val tick = data.get(key)
                    if (tick != null) {
                        it.put("rose", tick.get("rose"))
                        it.put("close", tick.get("close"))
                        it.put("vol", tick.get("vol"))
                    }
                }
                activity?.runOnUiThread {
                    adapter?.setList(normalTickList)
                }
            }
        }
    }

    private fun addOrDeleteSymbol(operationType: Int = 0, symbol: String?) {
        if (null == symbol || !LoginManager.isLogin(requireContext()))
            return
        var list = ArrayList<String>()
        list.add(symbol)
        addDisposable(getMainModel().addOrDeleteSymbol(operationType, list, object : NDisposableObserver() {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                if (operationType == 1) {
                    NToastUtil.showTopToastNet(requireActivity(), true, LanguageUtil.getString(requireActivity(), "kline_tip_addCollectionSuccess"))
                    LikeDataService.getInstance().saveCollecData(symbol, null)
                } else {
                    NToastUtil.showTopToastNet(requireActivity(), true, LanguageUtil.getString(requireActivity(), "kline_tip_removeCollectionSuccess"))
                    LikeDataService.getInstance().removeCollect(symbol)
                }

            }
        }))
    }


    @Subscribe(threadMode = ThreadMode.MAIN)
    override fun onMessageEvent(event: MessageEvent) {
        super.onMessageEvent(event)
        when(event.msg_type){
            MessageEvent.market_long_press -> {
                adapter?.getViewByPosition(0,R.id.tv_coin_name)
                    ?.let { homeMarketItemTips(requireActivity(), it) }
            }
            MessageEvent.market_updateList -> {
                loadData()
                adapter?.notifyDataSetChanged()
            }
        }

    }
}
