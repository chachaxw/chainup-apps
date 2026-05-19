package com.yjkj.chainup.new_version.home

import android.app.Activity
import android.content.Intent
import androidx.lifecycle.Observer
import android.os.Bundle
import android.view.View
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.SimpleItemAnimator
import com.alibaba.android.arouter.facade.annotation.Autowired
import com.google.gson.Gson
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseFragment
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.service.LikeDataService
import com.yjkj.chainup.db.service.SearchDataService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.extra_service.eventbus.EventBusUtil
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.extra_service.eventbus.NLiveDataUtil
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.LoginManager
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.manager.RateManager
import com.yjkj.chainup.net_new.JSONUtil
import com.yjkj.chainup.new_version.activity.CoinMapActivity
import com.yjkj.chainup.new_version.activity.NewMainActivity
import com.yjkj.chainup.new_version.adapter.CoinMapAdapter
import com.yjkj.chainup.new_version.adapter.NewHomepageMarketAdapter
import com.yjkj.chainup.new_version.home.callback.EmployeeDiffCallback
import com.yjkj.chainup.new_version.view.EmptyForAdapterView
import com.yjkj.chainup.util.LogUtil
import com.yjkj.chainup.util.NToastUtil
import com.yjkj.chainup.util.Utils
import com.yjkj.chainup.ws.WsAgentManager
import kotlinx.android.synthetic.main.fragment_search_detail.*
import org.jetbrains.anko.doAsync
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject

/**
 * @Author lianshangljl
 * @Date 2023/11/9-4:40 PM
 * @Email buptjinlong@163.com
 *@description homepage market details page rasing, falling, deal
 */
class NewHotDetailFragmentItem : NBaseFragment() {

    /**
     *Bottom Market
     */
    private var bottomMarketAdapter: CoinMapAdapter? = null

    private var tradeType = ""
    private var marketName = ""
    private var curIndex = 0
    private var coins: JSONArray? = null

    var isSearch = false

    var leverStatus = false

    var refreshLever = false
    var intoTransfer = false

    companion object {
        @JvmStatic
        fun newInstance(param1: String, param2: Int, chooseType: String, coins: String?) =
                NewHotDetailFragmentItem().apply {
                    arguments = Bundle().apply {
                        putString(ParamConstant.MARKET_NAME, param1)
                        putString(ParamConstant.TYPE, chooseType)
                        putInt(ParamConstant.CUR_INDEX, param2)
                        putString(ParamConstant.CUR_HOME_COINS, coins)
                    }
                }
    }

    override fun setContentView(): Int = R.layout.fragment_search_detail

    override fun initView() {
        initParams()
        rv_market_detail?.apply {
            itemAnimator?.moveDuration = 0
            if (itemAnimator is SimpleItemAnimator) {
                (itemAnimator as SimpleItemAnimator).supportsChangeAnimations = false
            }
        }
        NLiveDataUtil.observeData(this, Observer<MessageEvent> {
            if (null != it) {
                if (MessageEvent.color_rise_fall_type == it.msg_type) {
                    bottomMarketAdapter?.notifyDataSetChanged()
                }
            }
        })
        setTextConetnt()
    }

    fun setTextConetnt() {
    }

    private var curShowData: ArrayList<JSONObject>? = null
    fun initV(data: JSONArray?) {
        var tempData: JSONArray? = null
        if (data == null) {
        } else {
            tempData = data
        }
        val dataList = JSONUtil.arrayToList(tempData)
        initV(dataList,tempData)
    }

    fun initV(dataList: ArrayList<JSONObject>?,tempData: JSONArray? = null) {

        var temp: ArrayList<JSONObject> = arrayListOf()
        if (tempData != null) {
            val temps = NCoinManager.getSymbols(tempData)
            if(!temps.isNullOrEmpty()){
                temp.addAll(temps)
            }
        }
        temp = initReq(temp)
        if (null == bottomMarketAdapter) {
            bottomMarketAdapter = CoinMapAdapter()
            bottomMarketAdapter?.setSearch(marketName == "hot");
            rv_market_detail?.adapter = bottomMarketAdapter
            rv_market_detail?.layoutManager = LinearLayoutManager(context)
            rv_market_detail?.isNestedScrollingEnabled = false
            bottomMarketAdapter?.setEmptyView(EmptyForAdapterView(context ?: return))
            if (null == curShowData) {
                bottomMarketAdapter?.setList(temp)
            } else {
                bottomMarketAdapter?.replaceData(temp!!)
            }
        } else {
            val diffCallback = EmployeeDiffCallback(bottomMarketAdapter?.data!!, temp!!)
            bottomMarketAdapter?.setDiffData(diffCallback)
        }

        curShowData = temp
        //Ensure late arrival of HTTP data
        val isMain = isMaineTabSort()
        LogUtil.d(TAG, "isMaineTabSort is  ${curIndex}  ${marketName} $isMain")
        if (isMaineTabSort()) {
            startInit()
        }

        /**
         *Add Action
         *
         */
        bottomMarketAdapter?.addChildClickViewIds(R.id.ib_add)
        /**
         *Jump ->Transaction Details
         */
        bottomMarketAdapter?.setOnItemClickListener { adapter, view, position ->

            var obj = adapter.data[position] as JSONObject
            var symbol = obj.optString("symbol")
            if (leverStatus) {
                if (refreshLever) {
                    if (intoTransfer) {
                        ArouterUtil.navigation(RoutePath.NewVersionTransferActivity, Bundle().apply {
                            putString(ParamConstant.TRANSFERSTATUS, ParamConstant.LEVER_INDEX)
                            putString(ParamConstant.TRANSFERSYMBOL, "")
                            putString(ParamConstant.TRANSFERCURRENCY, symbol)
                        })
                    } else {
                        ArouterUtil.navigation(RoutePath.NewVersionBorrowingActivity, Bundle().apply {
                            putString(ParamConstant.symbol, symbol)
                        })
                    }
                } else {
                    val intent = Intent()
                    intent.putExtra(ParamConstant.symbol, symbol)
                    mActivity?.setResult(Activity.RESULT_OK, intent)
                }
                mActivity?.finish()
            } else {
                val name = obj.optString("name").split("/")[0]
                ArouterUtil.forwardKLine(symbol, ParamConstant.BIBI_INDEX)
                SearchDataService.getInstance().saveSearchData(name)
                SearchDataService.getInstance().removeLastSearchData()
            }

        }

        /**
         *Click to add self selection
         */
        bottomMarketAdapter?.setOnItemChildClickListener { adapter, view, position ->
            var obj = adapter.data[position] as JSONObject

            val symbol = obj.optString("symbol")
            val isAdd = obj.optBoolean("isAdd")
            var hasAdd = isAdd
            if (hasAdd) {
                LikeDataService.getInstance().removeCollect(symbol)
                hasAdd = false
            } else {
                LikeDataService.getInstance().saveCollecData(symbol, null)
                hasAdd = true
            }
            if (!LoginManager.isLogin(mActivity)) {
                if (hasAdd) {
                    NToastUtil.showTopToast(true, LanguageUtil.getString(mActivity, "kline_tip_addCollectionSuccess"))
                } else {
                    NToastUtil.showTopToast(true, LanguageUtil.getString(mActivity, "kline_tip_removeCollectionSuccess"))
                }
            }
            val messageEvent = MessageEvent(MessageEvent.like_coin_symbol_type,symbol,if (hasAdd) 1 else 2,true)
            EventBusUtil.post(messageEvent)

            try {
                obj.put("isAdd", hasAdd)
                adapter.notifyItemChanged((adapter as CoinMapAdapter).getCurrentPosition(position))
            } catch (e: JSONException) {
                e.printStackTrace()
            }
        }
    }

    private fun initParams() {
        LogUtil.e(TAG,"initParams ${marketName}")
        arguments?.let {
            marketName = it.getString(ParamConstant.MARKET_NAME) ?: ""
            tradeType = it.getString(ParamConstant.TYPE) ?: ""
            curIndex = it.getInt(ParamConstant.CUR_INDEX)
            coins = JSONArray(it.getString(ParamConstant.CUR_HOME_COINS))
        }
        LogUtil.e(TAG,"initParams ${marketName} ${coins?.length()}")
        initV(coins)
    }

    fun startInit() {
        if (curIndex == 2) {
            return
        }
        pageEventSymbol()
    }

    private fun pageEventSymbol() {
        if (bottomMarketAdapter?.data != null) {
            val data = bottomMarketAdapter?.data
            if (data.isNullOrEmpty()) {
                return
            }
            val arrays = arrayOfNulls<String>(data.size)
            for ((index, item) in data.withIndex()) {
                arrays.set(index, item.getString("symbol"))
            }
            forwardMarketTab(arrays)
        } else {
            LogUtil.d(TAG, "fragmentVisibile==MarketTrendFragment== pageEventSymbol 找不到列表 无法处理")
        }
    }

    private fun forwardMarketTab(coin: Array<String?>) {
        val messageEvent = MessageEvent(MessageEvent.home_event_page_symbol_type)
        messageEvent.msg_content = hashMapOf("symbols" to coin, "curIndex" to curIndex)
        EventBusUtil.post(messageEvent)
    }

    fun showWsData(jsonObject: JSONObject) {
        if (curIndex == 2) {
            return
        }
        if (bottomMarketAdapter?.data == null) {
            return
        }
        if (0 == bottomMarketAdapter?.data?.size)
            return
        val channel = jsonObject.optString("channel")
        val data = bottomMarketAdapter?.data
        val temp = data?.filter {
            channel.contains(it.optString("symbol"))
        }
        if (temp != null && temp.isNotEmpty()) {
            val dataDiff = callDataDiff(jsonObject)
            if (dataDiff != null) {
                val items = dataDiff.second
                dropListsAdapter(items)
                wsArrayTempList.clear()
                wsArrayMap.clear()
            }
        }

    }

    private fun isMaineTabSort(): Boolean {
        if (activity is NewMainActivity) {
            return (activity as NewMainActivity).curPosition == 0
        }
        return false
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
    fun dropListsAdapter(items: HashMap<String, JSONObject>) {
        val data = bottomMarketAdapter?.data
        if (data?.isEmpty()!!) {
            return
        }
        val message = Gson().toJson(data)
        val jsonCopy = Utils.jsonToArrayList(message, JSONObject::class.java)
        val tempNew = jsonCopy
        for ((index, item) in items.entries) {
            val jsonObject = item
            val channel = jsonObject.optString("channel")
            var tempData = 0
            for ((index, item) in data.withIndex()) {
                if (channel.contains(item.optString("symbol"))) {
                    tempData = index
                    break
                }
            }
            val tick = jsonObject.optJSONObject("tick")

            val item = tempNew.get(tempData)
            item.put("rose", tick.optString("rose"))
            item.put("close", tick.optString("close"))
            item.put("vol", tick.optString("vol"))
            tempNew.set(tempData, item)

        }
        for ((index, item) in tempNew.withIndex()) {
            item.put("Index", "|${(index + 1)}")
            item.put("homeIndex", "${(index + 1)}")
        }
        val diffCallback = EmployeeDiffCallback(data, tempNew)
        activity?.runOnUiThread {
            bottomMarketAdapter?.setDiffData(diffCallback)
        }

    }

    private fun initReq(normalTickList: java.util.ArrayList<JSONObject>):java.util.ArrayList<JSONObject> {
        val data = WsAgentManager.instance.reqJson
        if (data != null) {

            normalTickList.forEach {
                val key = it.getString("symbol")
                val tick = data.get(key)
                if (tick != null) {
                    it.put("rose", tick.get("rose"))
                    it.put("close", tick.get("close"))
                    it.put("vol", tick.get("vol"))
                }
            }

        }

        return normalTickList
    }


}
