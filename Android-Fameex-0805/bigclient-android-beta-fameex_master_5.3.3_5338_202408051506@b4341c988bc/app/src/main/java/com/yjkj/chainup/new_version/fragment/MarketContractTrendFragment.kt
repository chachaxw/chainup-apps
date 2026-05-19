package com.yjkj.chainup.new_version.fragment

import android.content.Intent
import android.os.Handler
import android.text.TextUtils
import android.view.View
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.chainup.contract.app.CpParamConstant
import com.chainup.contract.eventbus.CpMessageEvent
import com.chainup.contract.utils.CpChainUtil
import com.chainup.contract.utils.CpClLogicContractSetting
import com.yjkj.chainup.util.WsLinkUtils
import com.chainup.kit.views.KKEmptyViewKit
import com.google.gson.Gson
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseFragment
import com.yjkj.chainup.extra_service.eventbus.EventBusUtil
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.RateManager
import com.yjkj.chainup.net_new.rxjava.CpNDisposableObserver
import com.yjkj.chainup.new_contract.activity.CpMarketDetail4Activity
import com.yjkj.chainup.new_version.adapter.ContractMarketDetailAdapter
import com.yjkj.chainup.new_version.dialog.DialogUtil
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.home.callback.MarketTabDiffCallback
import com.yjkj.chainup.util.*
import com.yjkj.chainup.ws.WsAgentManager
import kotlinx.android.synthetic.main.fragment_market_detail.*
import kotlinx.android.synthetic.main.include_market_sort.*
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode
import org.jetbrains.anko.doAsync
import org.jetbrains.anko.imageResource
import org.json.JSONArray
import org.json.JSONObject


/**
 * @Author: Bertking
 * @Date 2023-06-15-15:26
 * @Description:
 */

class MarketContractTrendFragment : NBaseFragment() {

    private var wsArrayTempMap:HashMap<String, JSONObject>? = null
    override fun setContentView() = R.layout.fragment_market_detail

    override fun initView() {
        tv_name?.text = LanguageUtil.getString(context, "home_action_coinNameTitle")
        tv_new_price?.text = LanguageUtil.getString(context, "home_text_dealLatestPrice")
        tv_limit?.text = LanguageUtil.getString(context, "common_text_priceLimit")
//        swipe_refresh.setColorSchemeColors(ContextUtil.getColor(R.color.colorPrimary))
        initAdapter()
        setOnclick()
        setOnScrowListener()
        //first render req data
        renderReViewData()
    }

    private fun renderReViewData(){

        doAsync {
            wsArrayTempMap = CpClLogicContractSetting.getConvertMapFromRepData(normalTickList)
            if(null==wsArrayTempMap) return@doAsync
            dropListsAdapter(wsArrayTempMap!!,true)
        }

    }

    override fun loadData() {
        super.loadData()
        marketName = arguments?.getString("classification") ?: ""
        curIndex = arguments?.getInt(CUR_INDEX) ?: 1

        if (null == marketName || marketName.isEmpty())
            return

//        symbols = NCoinManager.getMarketByName(marketName)
        symbols =
            CpClLogicContractSetting.getContractListByClassification(requireContext(), marketName)

        if (null == symbols || symbols.isEmpty())
            return

        oriSymbols.addAll(symbols)

        normalTickList.clear()
        normalTickList.addAll(oriSymbols)

        normalTickList?.sortBy { it?.optInt("sort") }
//        normalTickList.sortBy { it.optInt("newcoinFlag") }

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
            adapter = ContractMarketDetailAdapter()
            adapter?.isMarketLike = false
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
                val obj = (data.get(position) as JSONObject)
                val currentSymbol = (obj.getString("contractType") + "_" + obj.getString("symbol")
                    .replace("-", "")).toLowerCase()
                val base = obj.getString("base")
                val quote = obj.getString("quote")
                val mContractId = obj.getInt("id")
                val symbolPricePrecision =
                    CpClLogicContractSetting.getContractSymbolPricePrecisionById(
                        activity,
                        mContractId
                    )
                if (!CpChainUtil.isFastClick()) {
                    val mIntent = Intent(mActivity!!, CpMarketDetail4Activity::class.java)
                    mIntent.putExtra(CpParamConstant.symbol, currentSymbol)
                    mIntent.putExtra("contractId", mContractId)
                    mIntent.putExtra("baseSymbol", base)
                    mIntent.putExtra("quoteSymbol", quote)
                    mIntent.putExtra("pricePrecision", symbolPricePrecision)
                    mIntent.putExtra(CpParamConstant.TYPE, CpParamConstant.BIBI_INDEX)
                    startActivity(mIntent)
                }
            }
        }
        adapter?.setOnItemLongClickListener { _adapter, view, position ->
            var viewBuff=view
            var mJSONObject:JSONObject= _adapter.data.get(position) as JSONObject
            val isCollect= CpClLogicContractSetting.hasCollect(requireContext(),mJSONObject.optInt("id"))
            adapter?.modifySelBg(position,true)
            DialogUtil.createMarketPop(requireContext(), viewBuff,!isCollect,dialogItemClickListener=object :
                NewDialogUtils.DialogOnSigningItemClickListener {
                override fun clickItem(pos: Int, text: String) {
                    if (isCollect){
                        NToastUtil.showTopToastNet(mActivity, true, LanguageUtil.getString(context, "kline_tip_removeCollectionSuccess"))
                    }else{
                        NToastUtil.showTopToastNet(mActivity, true, LanguageUtil.getString(context, "kline_tip_addCollectionSuccess"))
                    }
                    CpClLogicContractSetting.collectContractCoin(requireContext(), mJSONObject.optInt("id"))
                    _adapter.notifyItemChanged(position)
                    if (!CpClLogicContractSetting.isLogin()) {
                        val messageEvent = MessageEvent(MessageEvent.like_contract_optional_coin)
                        EventBusUtil.post(messageEvent)
                    }else{
                        addOrDelCollect(mJSONObject.optInt("id"))
                    }
                }

                override fun onDismiss() {
                    adapter?.modifySelBg(position,false)
                }
            })
            true
        }
//        adapter?.setOnItemTouchListener(object : OnItemTouchListener() {
//            fun onTouch(v: View?, event: MotionEvent): Boolean {
//                when (event.action) {
//                    MotionEvent.ACTION_DOWN -> {
//                        isClick = true
//                        Log.i(TAG, "Item: ACTION_DOWN")
//                    }
//                    MotionEvent.ACTION_MOVE -> Log.i(TAG, "Item: ACTION_MOVE")
//                    MotionEvent.ACTION_UP -> {
//                        isClick = false
//                        Log.i(TAG, "Item: ACTION_UP")
//                    }
//                    MotionEvent.ACTION_CANCEL -> Log.i(TAG, "Item: ACTION_CANCEL")
//                }
//                return false
//            }
//        })
    }

    /**
     *Original
     */
    private var oriSymbols = arrayListOf<JSONObject>()

    private var normalTickList = arrayListOf<JSONObject>()

    var adapter: ContractMarketDetailAdapter? = null

    private var marketName = ""
    private var curIndex = 1
    var selectIndex = 1
        set(value) {
            field = value
        }
    private var symbols = arrayListOf<JSONObject>()


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
                    normalTickList.sortBy { it.optString("contractOtherName") }
                    nameIndex = 1
                    iv_name_up?.imageResource = R.mipmap.quotes_on
                }
                /**
                 *Positive order
                 */
                1 -> {
                    normalTickList.sortByDescending { it.optString("contractOtherName")}
                    nameIndex = 2
                    iv_name_up?.imageResource = R.mipmap.quotes_under
                }
                /**
                 *Reverse order
                 */
                2 -> {
                    val newList = arrayListOf<JSONObject>()
                    newList.addAll(oriSymbols)
                    reloadLocalTick(newList)
                    normalTickList.clear()
                    normalTickList.addAll(newList)
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
                    normalTickList.sortBy { it.optDouble("close",0.0) }
                    newPriceIndex = 1
                    iv_new_price?.imageResource = R.mipmap.quotes_on

                }
                /**
                 *Positive order
                 */
                1 -> {
                    normalTickList.sortByDescending { it.optDouble("close",0.0) }
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
            val newList = arrayListOf<JSONObject>()
            val normalTickList = adapter?.data
            if (normalTickList.isNullOrEmpty()) return@setOnClickListener
            when (limitIndex) {
                /**
                 *Normal
                 */
                0 -> {
                    val (hasData, noData) = getFilterData("rose")
                    hasData.sortBy{ it.optDouble("rose", 0.0) }
                    newList.addAll(hasData)
                    newList.addAll(noData)
                    limitIndex = 1
                    iv_new_limit?.imageResource = R.mipmap.quotes_on
                }
                /**
                 *Positive order
                 */
                1 -> {
                    val (hasData, noData) = getFilterData("rose")
                    newList.addAll(noData)
                    hasData.sortByDescending{ it.optDouble("rose", 0.0) }
                    newList.addAll(hasData)
                    limitIndex = 2
                    iv_new_limit?.imageResource = R.mipmap.quotes_under
                }
                /**
                 *Reverse order
                 */
                2 -> {
                    normalTickList.sortBy { it.optInt("sort") }
                    newList.addAll(normalTickList)
                    limitIndex = 0
                    iv_new_limit?.imageResource = R.mipmap.quotes_default
                }
            }
            adapter?.isMarketSort = limitIndex != 0
            refreshAdapter(newList)
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
    }

    private fun getFilterData(key:String): Pair<MutableList<JSONObject>,MutableList<JSONObject>> {
        val originList = adapter?.data ?: return Pair(arrayListOf(), arrayListOf())
        val noData = originList.filter {
            val item = it.optString(key)
            "".equals(item) || item==null
        } as MutableList
        val hasData = originList.filter {
            val item = it.optString(key)
            !"".equals(item) && item!=null
        } as MutableList
        return hasData to noData
    }

    private fun reloadLocalTick(news: java.util.ArrayList<JSONObject>) {
        for (item in news) {
            val currentList = adapter?.data?:return
            val symbolLocal =
                currentList.findLast { it.optString("contractName") == item.optString("contractName") }
            if (symbolLocal != null) {
                item.put("rose", symbolLocal.optString("rose"))
                item.put("close", symbolLocal.optString("close"))
                item.put("vol", symbolLocal.optString("vol"))
            }
        }
    }

    private fun addOrDelCollect( contractId:Int) {
        if (!CpClLogicContractSetting.isLogin()) {
            return
        }
        var mContractIds= StringBuffer()
        var mCollectListStr =
            CpClLogicContractSetting.getContractJsonCollectListStr(requireContext())
        if (!TextUtils.isEmpty(mCollectListStr)){
            val jsonArray = JSONArray(mCollectListStr)
            for (i in 0 until jsonArray.length()) {
                val mJSONObject = jsonArray[i] as JSONObject
                mContractIds.append(mJSONObject.optInt("id"))
                mContractIds.append(",")
            }
        }else{
            mContractIds.append(contractId)
            mContractIds.append(",")
        }
        addDisposable(
            getContractModel().setOptionalList(
                if (TextUtils.isEmpty(mContractIds)) "" else  mContractIds.substring(0,mContractIds.length-1),
                consumer = object : CpNDisposableObserver(mActivity, true) {
                    override fun onResponseSuccess(jsonObject: JSONObject?) {
                        val messageEvent = MessageEvent(MessageEvent.like_contract_optional_coin)
                        EventBusUtil.post(messageEvent)
                    }
                }
            )
        )
    }

    @Subscribe(threadMode = ThreadMode.POSTING)
    override fun onMessageEvent(event: MessageEvent) {
        when (event.msg_type) {
            CpMessageEvent.sl_contract_market_event -> {
                handleData(JSONObject(event.msg_content as String))
            }
            MessageEvent.market_updateList -> {
                loadData()
                adapter?.notifyDataSetChanged()
            }
        }
    }


    fun handleData(data: JSONObject) {
        if(!mIsVisibleToUser) return
        
        try {
            val json = data
            val channel = json.optString("channel")
            val isTicker = WsLinkUtils.is24HLinkTicker(channel)
            if (!json.isNull("tick") && isTicker) {
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
                            LogUtil.e(
                                TAG,
                                "dropListsAdapter req ${marketName} list ${normalTickList.size} ${wsArrayMap.size}"
                            )
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
        adapter?.setList(list)
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
        if (System.currentTimeMillis() - wsTimeFirst >= 1000L && wsTimeFirst != 0L) {
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
    fun dropListsAdapter(items: HashMap<String, JSONObject>,isReview:Boolean = false) {
        val data = adapter?.data
        if (data?.isEmpty()!!) {
            return
        }
        if(!isReview) CpClLogicContractSetting.updateReqReviewData(items)
        val message = Gson().toJson(data)
        val jsonCopy = Utils.jsonToArrayList(message, JSONObject::class.java)
        val tempNew = jsonCopy
        for ((index, item) in items.entries) {
            val jsonObject = item
            val channel = jsonObject.optString("channel")
            var tempData = -1
            var tickSymbol = channel.split("_")[1] + channel.split("_")[2]
            for ((coinIndex, coinItem) in data.withIndex()) {
                val symbol =
                    coinItem.optString("contractType").toLowerCase() + coinItem.optString("symbol")
                        .replace("-", "").toLowerCase()
                if (tickSymbol == symbol) {
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
                var name = model?.optString("marginCoin")
                val rateResult = RateManager.getCNYByCoinName(name, tick?.optString("close"))
                model.put("rateResult", rateResult)
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
}
