package com.chainup.contract.ui.fragment

import android.os.Bundle
import android.text.TextUtils
import android.view.View
import androidx.recyclerview.widget.LinearLayoutManager
import com.chainup.contract.R
import com.chainup.contract.app.CpParamConstant
import com.chainup.contract.base.CpNBaseFragment
import com.chainup.contract.eventbus.CpMessageEvent
import com.chainup.contract.eventbus.CpNLiveDataUtil
import com.chainup.contract.utils.*
import com.chainup.contract.view.CpEmptyForAdapterView
import com.chainup.contract.view.CpNewDialogUtils
import com.chainup.kit.utils.ToastUtils
import com.chainup.kit.views.KKEmptyViewKit
import com.google.gson.Gson
import com.yjkj.chainup.manager.CpLanguageUtil
import com.yjkj.chainup.net_new.rxjava.CpNDisposableObserver
import com.yjkj.chainup.new_contract.adapter.CpContractDropAdapter
import kotlinx.android.synthetic.main.cp_fragment_sl_search_coin.*
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode
import org.jetbrains.anko.doAsync
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject
import java.util.*
import kotlin.collections.ArrayList

class CpCoinSearchItemFragment : CpNBaseFragment() {
    ///  (反向：0，1：正向 , 2 : 混合 , 3 : 模拟)
    private var index = 0
    private var contractDropAdapter: CpContractDropAdapter? = null
    private var tickers: ArrayList<JSONObject> = ArrayList()
    private val localTickers: ArrayList<JSONObject> = ArrayList()

    private lateinit var mContractList: JSONArray
    private var contractListJson: String? = null
    private var wsArrayTempMap:HashMap<String,JSONObject>? = null
    override fun setContentView(): Int {
        return R.layout.cp_fragment_sl_search_coin
    }

    override fun initView() {


        contractDropAdapter = CpContractDropAdapter(tickers)
        rv_search_coin.layoutManager = LinearLayoutManager(context)
        rv_search_coin.adapter = contractDropAdapter
        contractDropAdapter?.setEmptyView(KKEmptyViewKit(context ?: return))
        rv_search_coin.adapter = contractDropAdapter


        contractDropAdapter?.listener = object: CpContractDropAdapter.OnMyItemEvent{
            override fun onLongPress(view: View, position: Int) {
                this@CpCoinSearchItemFragment.contractDropAdapter?.setSelectPosition(position)
                val itemData = tickers[position]
                val isCollect = CpClLogicContractSetting.hasCollect(context,itemData.optInt("id"))

                CpNewDialogUtils.createMarketPop(
                    mActivity,view,
                    isCollect = isCollect,
                    dialogItemClickListener = object: CpNewDialogUtils.DialogOnSigningItemClickListener{
                        override fun clickItem(position: Int, text: String) {
                            //Cancel the collection Click the collection operation
                            setLocalCollectItem(isCollect,itemData,position)
                            delOrChangeCollect()
                        }

                        override fun dismiss() {
                            super.dismiss()
                            this@CpCoinSearchItemFragment.contractDropAdapter?.clearPostioin(position)
                        }
                    }
                )
            }

            override fun onPress(view: View, position: Int, ticker: JSONObject) {
                super.onPress(view, position, ticker)
                val pFragment = parentFragment as? CpContractCoinSearchDialog
                pFragment?.onItemClick(ticker)
            }

        }

        setInputListener()

        renderReViewData()
    }

    /**
     *Collection method
     *Whether @param isCollect has been collected
     *@param itemData The item object to operate on<JSONObject>
     *@param position Position affected by
     * */
    fun setLocalCollectItem(isCollect:Boolean,itemData:JSONObject,position:Int){
        if(isCollect){
            //Cancel Collection
            val likesCollect = CpClLogicContractSetting.getContractJsonCollectListArr(mActivity)
            for(item in likesCollect){
                if(item.optInt("id") == itemData.optInt("id")){
                    likesCollect.remove(item)
                    break
                }
            }
            CpClLogicContractSetting.setContractJsonCollectListStr(mActivity, CpJsonUtils.listToJson(likesCollect))
            ToastUtils.showToast(context, CpLanguageUtil.getString(context, "kline_tip_removeCollectionSuccess"))

        }else{
            //Collections
            val likesCollect = CpClLogicContractSetting.getContractJsonCollectListArr(mActivity)
            likesCollect.add(itemData)
            CpClLogicContractSetting.setContractJsonCollectListStr(mActivity, CpJsonUtils.listToJson(likesCollect))
            ToastUtils.showToast(context, CpLanguageUtil.getString(context, "kline_tip_addCollectionSuccess"))
        }

        contractDropAdapter?.notifyItemChanged(position)

        val cpMessageEvent = CpMessageEvent(CpMessageEvent.market_updateList)
        CpNLiveDataUtil.postValue(cpMessageEvent)
    }

    private fun setInputListener() {
        var isFirst = true
        CpNLiveDataUtil.observeData(this, androidx.lifecycle.Observer {
            if(isFirst){
                isFirst = false
                return@Observer
            }
            val content = it?.msg_content
            if(it.msg_type.equals(CpMessageEvent.market_updateList)){
                contractDropAdapter?.notifyDataSetChanged()
                return@Observer
            }

            if (content is String) {
                ChainUpLogUtil.d(TAG,"input string content>>>$content")
                if (CpStringUtil.checkStr(content)) {
                    tickers.clear()
                    for (index in localTickers.indices) {
                        if (localTickers[index].optString("symbol").contains(content.toUpperCase())) {
                            tickers.add(localTickers[index])
                        }
                    }
                    val newData = getAdapterDataWith24TickerByReqData(tickers)
                    contractDropAdapter?.setList(newData)
                } else {
                    tickers.clear()
                    tickers.addAll(localTickers)
                    val newData = getAdapterDataWith24TickerByReqData(tickers)
                    contractDropAdapter?.setList(newData)
                }
            }
        })
    }
    //Store existing favorites to the server
    private fun delOrChangeCollect() {
        if (!CpClLogicContractSetting.isLogin()) {
            return
        }
        var mContractIds = StringBuffer()
        var mCollectListStr =
            CpClLogicContractSetting.getContractJsonCollectListStr(requireContext())
        if (!TextUtils.isEmpty(mCollectListStr)) {
            val jsonArray = JSONArray(mCollectListStr)
            for (i in 0 until jsonArray.length()) {
                val mJSONObject = jsonArray[i] as JSONObject
                mContractIds.append(mJSONObject.optInt("id"))
                mContractIds.append(",")
            }
            addDisposable(
                getContractModel().setOptionalList(
                    if (TextUtils.isEmpty(mContractIds)) "" else  mContractIds.substring(0,mContractIds.length-1),
                    consumer = object : CpNDisposableObserver(true) {
                        override fun onResponseSuccess(jsonObject: JSONObject?) {

                        }
                    }
                )
            )
        }
    }

    override fun loadData() {
        super.loadData()

        index = requireArguments().getInt(CpParamConstant.CUR_INDEX)
        try {
            contractListJson= CpClLogicContractSetting.getContractJsonListStr(mActivity)
            mContractList = JSONArray(contractListJson)
            updateData()
        } catch (e: JSONException) {
            e.printStackTrace()
        }
    }

    private fun updateData() {
        //Index 1: usdt 0: Reverse 2: Hybrid 3: Simulation
        for (i in 0..(mContractList.length() - 1)) {
            var obj: JSONObject = mContractList.get(i) as JSONObject
            var contractSide = obj.getInt("contractSide")
            val contractType = mContractList.getJSONObject(i).getString("contractType")
            val classification = mContractList.getJSONObject(i).getInt("classification")
            //classification
            //1. USDT contract 2. Currency standard contract 3. Hybrid contract 4. Simulation contract
            if (index == 1 && classification == 1) {
                tickers.add(obj)
                localTickers.add(obj)
            } else if (index == 0 && classification == 2) {
                tickers.add(obj)
                localTickers.add(obj)
            } else if (index == 2 && classification==3) {
                tickers.add(obj)
                localTickers.add(obj)
            } else if (index == 3 && classification==4) {
                tickers.add(obj)
                localTickers.add(obj)
            }
            tickers.sortBy { it.getInt("sort") }
            localTickers.sortBy { it.getInt("sort") }
        }
        contractDropAdapter?.notifyDataSetChanged()
    }

    private fun renderReViewData(){
        doAsync {
            wsArrayTempMap = CpClLogicContractSetting.getConvertMapFromRepData(tickers)
            if(wsArrayTempMap==null) {
                ChainUpLogUtil.e(TAG,"wsArrayTempMap is null-----------!!!")
                return@doAsync
            }

            ChainUpLogUtil.d(TAG,"wsArrayTempMap = " + wsArrayTempMap)
            dropListsAdapter(wsArrayTempMap!!,true)
        }
    }

    companion object {
        @JvmStatic
        fun newInstance(index: Int, contractListJson: String): CpCoinSearchItemFragment {
            val fg = CpCoinSearchItemFragment()
            val bundle = Bundle()
            bundle.putInt(CpParamConstant.CUR_INDEX, index)
            bundle.putString("contractList", contractListJson)
            fg.arguments = bundle
            return fg
        }
    }

    private val wsArrayTempList: ArrayList<JSONObject> = arrayListOf()
    private val wsArrayMap = hashMapOf<String, JSONObject>()
    private var wsTimeFirst: Long = 0L

    private fun showWsData(jsonObject: JSONObject) {
        doAsync {
            if (null == tickers) return@doAsync
            val dataDiff = callDataDiff(jsonObject)
            if (dataDiff != null) {
                val items = dataDiff.second
                dropListsAdapter(items)
                wsArrayTempList.clear()
                wsArrayMap.clear()
            }
        }

    }

    @Synchronized
    private fun dropListsAdapter(items: HashMap<String, JSONObject>,isReview:Boolean = false) {

        val data = contractDropAdapter?.data
        if (data?.isEmpty()!!) {
            ChainUpLogUtil.e(TAG,"wsArrayTempMap is null-----------!!!")
            return
        }
        if(!isReview) CpClLogicContractSetting.updateReqReviewData(items)
        val message = Gson().toJson(data)
        val jsonCopy = CpJsonUtils.cloneDataByArrayListJSONObject(message)
        val tempNew = jsonCopy
        for ((index, item) in items.entries) {
            val jsonObject = item
            val channel = jsonObject.optString("channel")
            var tempData = -1
            for ((coinIndex, coinItem) in data.withIndex()) {
                val channelBuff= StringBuilder("market_${coinItem.optString("subSymbol")}_ticker").toString()
                if (channel == channelBuff) {
                    tempData = coinIndex
                    break
                }
            }
            if (tempData != -1) {
                val tick = jsonObject.optJSONObject("tick")
                val model = tempNew?.get(tempData)
                model?.put("rose", tick?.optString("rose"))
                model?.put("close", tick?.optString("close"))
                model?.put("vol", tick?.optString("vol"))
                model?.let { tempNew?.set(tempData, it) }
            }
        }
        val diffCallback = tempNew?.let { CpMarketTabDiffCallback(data, it) }
        if(contractDropAdapter?.isPressing == true) return
        activity?.runOnUiThread {
            ChainUpLogUtil.d(TAG,"runOnUiThread >>>")
            diffCallback?.let { contractDropAdapter?.setDiffData(it) }
        }

    }

    private fun getAdapterDataWith24TickerByReqData(data:ArrayList<JSONObject>):ArrayList<JSONObject> {
        wsArrayTempMap = CpClLogicContractSetting.getConvertMapFromRepData(tickers)
        if(wsArrayTempMap==null) {
            //no get cache data???
            return data
        }
        val items = wsArrayTempMap!!

        val message = Gson().toJson(data)
        val jsonCopy = CpJsonUtils.cloneDataByArrayListJSONObject(message)
        val tempNew = jsonCopy
        for ((index, item) in items.entries) {
            val jsonObject = item
            val channel = jsonObject.optString("channel")
            var tempData = -1
            for ((coinIndex, coinItem) in data.withIndex()) {
                val channelBuff= StringBuilder("market_${coinItem.optString("subSymbol")}_ticker").toString()
                if (channel == channelBuff) {
                    tempData = coinIndex
                    break
                }
            }
            if (tempData != -1) {
                val tick = jsonObject.optJSONObject("tick")
                val model = tempNew?.get(tempData)
                model?.put("rose", tick?.optString("rose"))
                model?.put("close", tick?.optString("close"))
                model?.put("vol", tick?.optString("vol"))
                model?.let { tempNew?.set(tempData, it) }
            }
        }

        return tempNew
    }

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
            val channel = jsonObject.optString("channel")
            if (null == channel || !channel.contains("_")) {
                return null
            }
            var tickSymbol = channel.split("_")[1]+channel.split("_")[2]
            val tempCoin = localTickers.filter { (it.optString("subSymbol").replace("_", "")) == tickSymbol }
//            val tempCoin = localTickers.filter { (it.optString("contractType").toLowerCase()+it.optString("symbol").replace("-", "").toLowerCase()) == tickSymbol }
            if (tempCoin.isNotEmpty()) {
                wsArrayTempList.add(jsonObject)
                wsArrayMap.put(jsonObject.optString("channel", ""), jsonObject)
            } else {
                ChainUpLogUtil.d(TAG, "callDataDiff==content is $jsonObject")
            }
        }
        return null
    }

    @Subscribe(threadMode = ThreadMode.POSTING)
    override fun onMessageEvent(event: CpMessageEvent) {
        when (event.msg_type) {
            CpMessageEvent.sl_contract_sidebar_market_event -> {
                showWsData(event.msg_content as JSONObject)
            }
        }
    }

}
