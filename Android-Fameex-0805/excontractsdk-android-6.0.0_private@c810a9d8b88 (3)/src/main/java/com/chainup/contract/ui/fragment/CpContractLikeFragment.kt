package com.chainup.contract.ui.fragment
import android.text.TextUtils
import android.util.Log
import android.view.View
import androidx.lifecycle.Observer
import androidx.recyclerview.widget.LinearLayoutManager
import com.chainup.contract.R
import com.chainup.contract.base.CpNBaseFragment
import com.chainup.contract.eventbus.CpMessageEvent
import com.chainup.contract.eventbus.CpNLiveDataUtil
import com.chainup.contract.utils.ChainUpLogUtil
import com.chainup.contract.utils.CpClLogicContractSetting
import com.chainup.contract.utils.CpJsonUtils
import com.chainup.contract.utils.CpMarketTabDiffCallback
import com.chainup.contract.view.CpEmptyForAdapterView
import com.chainup.contract.view.CpNewDialogUtils
import com.chainup.kit.utils.ToastUtils
import com.chainup.kit.views.KKEmptyViewKit
import com.google.gson.Gson
import com.google.gson.JsonObject
import com.google.gson.reflect.TypeToken
import com.yjkj.chainup.manager.CpLanguageUtil
import com.yjkj.chainup.net_new.rxjava.CpNDisposableObserver
import com.yjkj.chainup.new_contract.adapter.CpContractDropAdapter
import kotlinx.android.synthetic.main.fragment_cp_contract_like.*
import org.jetbrains.anko.doAsync
import org.json.JSONArray
import org.json.JSONObject
import java.util.HashMap

/**
 *
 *Contract options in the drawer dialog
 * CpContractLikeFragment
 */
class CpContractLikeFragment : CpNBaseFragment(){

    private var collecDataList = arrayListOf<JSONObject>()
    //An immutable collection data container
    private var cpCollecDataList = arrayListOf<JSONObject>()
    private var adapter:CpContractDropAdapter? = null

    private val wsArrayTempList: ArrayList<JSONObject> = arrayListOf()
    private val wsArrayMap = hashMapOf<String, JSONObject>()
    private var wsTimeFirst: Long = 0L

    private var etKeyword:String = ""
    private var wsArrayTempMap:HashMap<String,JSONObject>? = null

    override fun setContentView(): Int = R.layout.fragment_cp_contract_like

    override fun loadData() {
        super.loadData()
        val collecData = getCollecData()
        collecDataList.clear()
        cpCollecDataList.clear()
        if(collecData.isNullOrEmpty()){
            adapter?.notifyDataSetChanged()
            return
        }
        if(collecData.size>0){
            collecDataList.addAll(collecData)
            cpCollecDataList.addAll(collecData)
            adapter?.setList(collecDataList)
        }
    }

    override fun initView() {
        ct_likeRv.layoutManager = LinearLayoutManager(mActivity,LinearLayoutManager.VERTICAL,false)

        adapter = CpContractDropAdapter(collecDataList,true)
        ct_likeRv.adapter = adapter

        adapter?.setEmptyView(KKEmptyViewKit(mActivity!!))

        adapter?.listener = object :CpContractDropAdapter.OnMyItemEvent{
            override fun onLongPress(view: View,position: Int) {
                this@CpContractLikeFragment.adapter?.setSelectPosition(position)
                val itemData = collecDataList[position]
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
                            this@CpContractLikeFragment.adapter?.clearPostioin(position)
                        }
                    }
                )
            }

            override fun onPress(view: View, position: Int, ticker: JSONObject) {
                super.onPress(view, position,ticker)
                val pFragment = parentFragment as? CpContractCoinSearchDialog
                pFragment?.onItemClick(ticker)
            }

        }

        var isFirst = true
        CpNLiveDataUtil.observeData(this, Observer {
            if(isFirst){
                isFirst = false
                return@Observer
            }
            if(it.msg_type.equals(CpMessageEvent.market_updateList)){
                if(!"self".equals(it.msg_content)) {
                    loadData()
                    findData(etKeyword)
                }
                return@Observer
            }
            if(it.msg_content is String){
                etKeyword = it.msg_content as String
                findData(etKeyword)
            }
        })

        renderReViewData()
    }

    private fun renderReViewData(){
        doAsync {
            wsArrayTempMap = CpClLogicContractSetting.getConvertMapFromRepData(collecDataList)
            if(wsArrayTempMap==null) {
                ChainUpLogUtil.e(TAG,"wsArrayTempMap is null-----------!!!")
                return@doAsync
            }
            dropListsAdapter(wsArrayTempMap!!,true)
        }
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
            for(item in collecDataList){
                if(item.optInt("id") == itemData.optInt("id")){
                    collecDataList.remove(item)
                    break
                }
            }
            CpClLogicContractSetting.setContractJsonCollectListStr(mActivity,CpJsonUtils.listToJson(collecDataList))
            adapter?.notifyItemRemoved(position)

            ToastUtils.showToast(context, CpLanguageUtil.getString(context, "kline_tip_removeCollectionSuccess"))

        }else{
            //Collections
            val likesCollect = CpClLogicContractSetting.getContractJsonCollectListArr(mActivity)
            likesCollect.add(itemData)
            CpClLogicContractSetting.setContractJsonCollectListStr(mActivity,CpJsonUtils.listToJson(likesCollect))
            adapter?.notifyDataSetChanged()
            ToastUtils.showToast(context, CpLanguageUtil.getString(context, "kline_tip_addCollectionSuccess"))
        }

        val messageEvent = CpMessageEvent(CpMessageEvent.market_updateList)
        //Here, I write self because I'm also listening to the market_ UpdateList to avoid repeating a refresh
        messageEvent.msg_content = "self"
        CpNLiveDataUtil.postValue(messageEvent)
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


    //Get Favorite Data
    private fun getCollecData(): ArrayList<JSONObject>? {
        var sModelList: ArrayList<JSONObject> = ArrayList<JSONObject>()
        try {
            var mCollectListStr =
                CpClLogicContractSetting.getContractJsonCollectListStr(requireContext())
            if (!TextUtils.isEmpty(mCollectListStr)){
                val jsonArray: JSONArray = JSONArray(mCollectListStr)
                for (i in 0 until jsonArray.length()) {
                    val mJSONObject = jsonArray[i] as JSONObject
                    sModelList.add(mJSONObject)
                }
            }
        }catch (e:Exception){
            e.printStackTrace()
        }
        return sModelList
    }


    override fun onMessageEvent(event: CpMessageEvent) {
        super.onMessageEvent(event)
        when (event.msg_type) {
            CpMessageEvent.sl_contract_sidebar_market_event -> {
                showWsData(event.msg_content as JSONObject)
            }
        }
    }

    private fun findData(keyword:String) {
        if("".equals(etKeyword)){
            Log.d(TAG,"cpCollecDataList的长度："+cpCollecDataList.size.toString())
            collecDataList.clear()
            collecDataList.addAll(cpCollecDataList)
            adapter?.setList(collecDataList)
            return
        }
        val newDataList = cpCollecDataList.filter {
            it.optString("symbol")
                .uppercase()
                .contains(keyword.uppercase())
        } as ArrayList<JSONObject>
        collecDataList = newDataList
        adapter?.setList(collecDataList)
    }

    private fun showWsData(jsonObject: JSONObject) {
        doAsync {
            if (null == collecDataList) return@doAsync
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

        val data = adapter?.data
        if (data?.isEmpty()!!) {
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
                val channelBuff= StringBuilder("market_${coinItem.optString("contractType").toLowerCase()}_${coinItem.optString("symbol").replace("-","").toLowerCase()}_ticker").toString()
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
        if(adapter?.isPressing == true) return
        activity?.runOnUiThread {
            diffCallback?.let { adapter?.setDiffData(it) }
        }

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
            val tempCoin = collecDataList.filter { (it.optString("contractType").toLowerCase()+it.optString("symbol").replace("-", "").toLowerCase()) == tickSymbol }
            if (tempCoin.isNotEmpty()) {
                wsArrayTempList.add(jsonObject)
                wsArrayMap.put(jsonObject.optString("channel", ""), jsonObject)
            } else {
                ChainUpLogUtil.d(TAG, "callDataDiff==content is $jsonObject")
            }
        }
        return null
    }


}
