package com.yjkj.chainup.new_version.fragment

import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.text.TextUtils
import android.util.Log
import android.view.View
import android.widget.LinearLayout
import androidx.recyclerview.widget.DefaultItemAnimator
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.chainup.contract.app.CpParamConstant
import com.chainup.contract.eventbus.CpMessageEvent
import com.chainup.contract.utils.ChainUpLogUtil
import com.chainup.contract.utils.CpChainUtil
import com.chainup.contract.utils.CpClLogicContractSetting
import com.chainup.kit.views.KKEmptyViewKit
import com.google.gson.Gson
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseFragment
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.service.LikeDataService
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.extra_service.eventbus.EventBusUtil
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.LoginManager
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.manager.SymbolWsData
import com.yjkj.chainup.net_new.rxjava.CpNDisposableObserver
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_contract.activity.CpMarketDetail4Activity
import com.yjkj.chainup.new_version.adapter.ContractMarketDetailAdapter
import com.yjkj.chainup.new_version.adapter.RecommendCoinAdapter
import com.yjkj.chainup.new_version.dialog.DialogUtil
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.home.callback.MarketTabDiffCallback
import com.yjkj.chainup.new_version.view.CommonlyUsedButton
import com.yjkj.chainup.new_version.view.EmptyMarketForAdapterView
import com.yjkj.chainup.util.*
import kotlinx.android.synthetic.main.fragment_spot_likes.*
import kotlinx.android.synthetic.main.include_market_sort.*
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode
import org.jetbrains.anko.doAsync
import org.jetbrains.anko.imageResource
import org.json.JSONArray
import org.json.JSONObject
import java.util.*


/**
 *@description: The self selected page of the market
 * @Date 2023-1- 5
 * @author Bertking
 *
 *PS: Although this fragment is similar to the MarketFragment, it is handled separately
 *1 Improve code readability;
 *2 Improve performance
 */
class ContractLikesFragment : NBaseFragment() {

    override fun setContentView() = R.layout.fragment_spot_likes

    var adapter: ContractMarketDetailAdapter? = null
    private var curIndex = 0
    var isScrollStatus = false

    var mRecommendCoinAdapter: RecommendCoinAdapter? = null
    var mRecommendCoinData: ArrayList<JSONObject> = ArrayList()
    private var wsArrayTempMap:HashMap<String,JSONObject>? = null
    //Does the record display a self selected list
    private var isShowLikeView:Boolean = false

    override fun loadData() {
        super.loadData()
        curIndex = arguments?.getInt(CUR_INDEX) ?: 0
    }

    override fun initView() {
        btn_confirm?.textContent = "market_recommand_selet".tr(mActivity!!)
        tv_name?.text = LanguageUtil.getString(context, "home_action_coinNameTitle")
        tv_new_price?.text = LanguageUtil.getString(context, "home_text_dealLatestPrice")
        tv_limit?.text = LanguageUtil.getString(context, "common_text_priceLimit")
//        swipe_refresh.setColorSchemeColors(ContextUtil.getColor(R.color.colorPrimary))


        initRecylerView()
        setOnclick()
        initAdapter()
        setOnScrowListener()
        renderReViewData()
    }

    fun renderReViewData() {
        doAsync {
            wsArrayTempMap = CpClLogicContractSetting.getConvertMapFromRepData(normalTickList)
            if(wsArrayTempMap==null || (wsArrayTempMap?.size?:0)>0) {
                ChainUpLogUtil.e(TAG,"wsArrayTempMap is null-----------!!!")
                return@doAsync
            }
            if(normalTickList.isEmpty()){
                val collectData = getCollecData()?:return@doAsync
                normalTickList.addAll(collectData)
            }
            if(normalTickList.isNotEmpty()){
                val newList = arrayListOf<JSONObject>()
                newList.addAll(normalTickList)
                for(entry in wsArrayTempMap!!.entries) {
                    SymbolWsData().getNewSymbolObjContract(newList,entry.value)!!
                }
                val diffCallback = MarketTabDiffCallback(normalTickList, newList)
                activity?.runOnUiThread {
                    adapter?.setDiffData(diffCallback)
                }
            }
        }
    }


    private fun setOnScrowListener() {
        rv_market_detail?.addOnScrollListener(object : RecyclerView.OnScrollListener() {

            override fun onScrollStateChanged(recyclerView: RecyclerView, newState: Int) {
                super.onScrollStateChanged(recyclerView, newState)
                if (RecyclerView.SCROLL_STATE_DRAGGING == newState || RecyclerView.SCROLL_STATE_SETTLING==newState) {
                    isScrollStatus = true
                } else {
                    isScrollStatus = false
                }
            }
        })
    }

    private var isFirstInitRecylerView = true
    private fun initRecylerView() {
        if (!isFirstInitRecylerView)
            return
        isFirstInitRecylerView = false

        rv_market_detail?.layoutManager = LinearLayoutManager(context)
        (rv_market_detail.itemAnimator as DefaultItemAnimator).supportsChangeAnimations = false

    }


    /**
     *Original
     */
    private var oriSymbols = arrayListOf<JSONObject>()

    private var normalTickList = arrayListOf<JSONObject>()

    private var bufferTickList = arrayListOf<JSONObject>()

    private var serverOriDataList = arrayListOf<JSONObject>()  //Only used to record the raw self selected data returned by the interface

    var nameIndex = 0
    var newPriceIndex = 0
    var limitIndex = 0

    /**
     *Click Event
     */
    fun setOnclick() {
        /**
         *Click on the name
         */
        ll_name.setOnClickListener {
            refreshTransferImageView(0)
            when (nameIndex) {
                /**
                 *Normal
                 */
                0 -> {
                    normalTickList.sortBy {  it.optString("contractOtherName") }
                    nameIndex = 1
                    iv_name_up?.imageResource = R.mipmap.quotes_on

                }
                /**
                 *Positive order
                 */
                1 -> {
                    normalTickList.sortByDescending {  it.optString("contractOtherName")}
                    nameIndex = 2
                    iv_name_up?.imageResource = R.mipmap.quotes_under

                }
                /**
                 *Reverse order
                 */
                2 -> {
                    normalTickList.clear()
                    normalTickList.addAll(oriSymbols)
                    nameIndex = 0
                    iv_name_up?.imageResource = R.mipmap.quotes_default
                }
            }
            if (normalTickList.size > 0) {
                refreshAdapter(normalTickList)
            }

        }
        /**
         *Click on the latest price
         */
        ll_new_price.setOnClickListener {
            refreshTransferImageView(1)
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
                    normalTickList.clear()
                    normalTickList.addAll(oriSymbols)
                    newPriceIndex = 0
                    iv_new_price?.imageResource = R.mipmap.quotes_default

                }
            }
            if (normalTickList.size > 0) {
                refreshAdapter(normalTickList)
            }
        }
        /**
         *Click on 24-hour increase
         */
        ll_limit.setOnClickListener {
            refreshTransferImageView(2)
            when (limitIndex) {
                /**
                 *Normal
                 */
                0 -> {
                    normalTickList.sortBy { it.optDouble("rose") }
                    limitIndex = 1
                    iv_new_limit?.imageResource = R.mipmap.quotes_on
                }
                /**
                 *Positive order
                 */
                1 -> {
                    normalTickList.sortByDescending { it.optDouble("rose") }
                    limitIndex = 2
                    iv_new_limit?.imageResource = R.mipmap.quotes_under
                }
                /**
                 *Reverse order
                 */
                2 -> {
                    normalTickList.clear()
                    normalTickList.addAll(oriSymbols)
                    limitIndex = 0
                    iv_new_limit?.imageResource = R.mipmap.quotes_default
                }
            }
            if (normalTickList.size > 0) {
                refreshAdapter(normalTickList)
            }
        }
        /**
         *Refresh Here
         */
        swipe_refresh?.setOnRefreshListener {

            /**
             *Refresh Data Operation
             */
            getOptionalData()
            swipe_refresh?.finishRefresh(true)
        }
        //Click to add self selection
        btn_confirm?.listener = object : CommonlyUsedButton.OnBottonListener {
            override fun bottonOnClick() {
                for (buff in mRecommendCoinData) {
                    if (buff.optBoolean("isSel")) {
                        CpClLogicContractSetting.collectContractCoin(
                            requireContext(),
                            buff.optInt("id")
                        )
                    }
                }
                delOrChangeCollect()
                showData()
                sendUpdateListMessage()
            }
        }
        btn_confirm.isEnable(true)
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
            LogUtil.e("error",e.message)
        }
        return sModelList
    }

    /*
     列表展示
     */
    private fun showData() {
        var collecData = getCollecData()
        if (null != collecData && collecData.size > 0) {
            serverOriDataList.clear()
            oriSymbols.clear()
            oriSymbols.addAll(collecData)
            reloadLocalTick(collecData)
            normalTickList.clear()
            normalTickList.addAll(collecData)

            showLikeView(true)
            adapter?.setList(normalTickList)

        } else {
            var mCollectListStr = CpClLogicContractSetting.getContractJsonListStr(requireContext())
            ll_no_data.visibility=if (TextUtils.isEmpty(mCollectListStr)) View.VISIBLE else View.GONE
            if (TextUtils.isEmpty(mCollectListStr)){
                return
            }
            val jsonArray = JSONArray(mCollectListStr)
            var mRecommendCoinDataTx: ArrayList<JSONObject> = ArrayList()
            mRecommendCoinData.clear()
            for (i in 0 until jsonArray.length()) {
                val mJSONObject = jsonArray[i] as JSONObject
                mJSONObject.put("isSel", true)
                mRecommendCoinDataTx.add(mJSONObject)
            }
            mRecommendCoinDataTx.sortBy { it.optInt("sort") }
            if (mRecommendCoinDataTx.size>6){
                mRecommendCoinData.addAll(mRecommendCoinDataTx.subList(0,6))
            }else{
                mRecommendCoinData.addAll(mRecommendCoinDataTx)
            }
            mRecommendCoinAdapter?.notifyDataSetChanged()
            showLikeView(false)
        }
    }

    /*
     *Displaying and Hiding Custom Coins for View
     */
    private fun showLikeView(isShowLikeView: Boolean) {
        this.isShowLikeView = isShowLikeView
        setIcEditVisible()
        if (isShowLikeView) {
            ll_no_data.visibility = View.GONE
            ll_item_titles?.visibility = View.VISIBLE
            rv_market_detail?.visibility = View.VISIBLE
            ll_recommend?.visibility = View.GONE
            ll_content?.visibility = View.VISIBLE
        } else {
            normalTickList.clear()
            ll_item_titles?.visibility = View.GONE
            adapter?.setList(normalTickList)
            ll_content?.visibility = View.GONE

            btn_confirm.visibility = if(mRecommendCoinData.size>0){
                View.VISIBLE
            }else View.GONE
            if(mRecommendCoinData.size<=0){
                ll_no_data.visibility = View.VISIBLE
                ll_recommend?.visibility = View.GONE
            }else{
                ll_recommend?.visibility = View.VISIBLE
                ll_no_data.visibility = View.GONE
            }

        }
    }


    private fun initAdapter() {
        mRecommendCoinData.clear()
        mRecommendCoinAdapter =
            RecommendCoinAdapter(R.layout.item_favorites_empty,"contract", mRecommendCoinData)
        rv_recommend_coin?.apply {
            layoutManager = GridLayoutManager(requireContext(), 2)
            adapter = mRecommendCoinAdapter
        }
        mRecommendCoinAdapter?.setOnItemClickListener { adapter, view, position ->
            val isSel = mRecommendCoinData.get(position).optBoolean("isSel")
            mRecommendCoinData.get(position).put("isSel", !isSel)
            mRecommendCoinAdapter?.notifyItemChanged(position)

            var buffSel = false;
            for (buff in mRecommendCoinData) {
                if (buff.optBoolean("isSel")) {
                    buffSel = true
                    break
                }
            }
            btn_confirm.isEnable(buffSel)
        }
        adapter = ContractMarketDetailAdapter()
        adapter?.isMarketLike = true
        rv_market_detail?.adapter = adapter
        rv_market_detail?.setHasFixedSize(true)
        val emptyForAdapterView = KKEmptyViewKit(context ?: return)
        adapter?.setEmptyView(emptyForAdapterView)
        adapter?.emptyLayout?.findViewById<LinearLayout>(R.id.layout_add_like)?.setOnClickListener {
            ArouterUtil.greenChannel(RoutePath.CoinMapActivity, Bundle().apply {
                putString(ParamConstant.TYPE, ParamConstant.ADD_COIN_MAP)
            })
        }

        adapter?.setOnItemClickListener { adapter, _, position ->
//            val data = adapter.data[position] as JSONObject
//            ArouterUtil.forwardKLine(data.optString("symbol"))
            adapter?.apply {
                val obj = (data.get(position) as JSONObject)
                val  currentSymbol = (obj.getString("contractType") + "_" + obj.getString("symbol")
                    .replace("-", "")).toLowerCase()
                val base = obj.getString("base")
                val quote = obj.getString("quote")
                val mContractId = obj.getInt("id")
                val symbolPricePrecision = CpClLogicContractSetting.getContractSymbolPricePrecisionById(activity, mContractId)
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
            val isCollect= CpClLogicContractSetting.hasCollect(requireContext(),normalTickList[position].optInt("id"))
            adapter?.modifySelBg(position,true)
            DialogUtil.createMarketPop(requireContext(), view,!isCollect,true,object :NewDialogUtils.DialogOnSigningItemClickListener{
                override fun clickItem(pos: Int, text: String) {
                    if (pos==0){
                        //Topping
                        bufferTickList.clear()
                        bufferTickList.add(normalTickList[position])
                        for (index in normalTickList.indices){
                            if (index!=position){
                                bufferTickList.add(normalTickList[index])
                            }
                        }
                        normalTickList.clear()
                        normalTickList.addAll(bufferTickList)
                    }else{
                        //Collection
                        val buff = normalTickList.filter {
                            normalTickList[position].optInt("id") !=(it.optInt("id"))
                        }
                        normalTickList.clear()
                        normalTickList.addAll(buff)
                        NToastUtil.showTopToastNet(mActivity, true, LanguageUtil.getString(context, "kline_tip_removeCollectionSuccess"))
                        sendUpdateListMessage()
                    }
                    CpClLogicContractSetting.setContractJsonCollectListStr(
                        requireContext(),
                        normalTickList.toString()
                    )
                    if (normalTickList.size==0){
                        showData()
                    }
                    oriSymbols.clear()
                    oriSymbols.addAll(normalTickList)
                    delOrChangeCollect()
                    refreshAdapter(normalTickList)
                }

                override fun onDismiss() {
                    adapter?.modifySelBg(position,false)
                }
            })
//            NewDialogUtils.showNormalDialog(
//                    context!!,
//            LanguageUtil.getString(context, "new_confrim_likes"),
//            object : NewDialogUtils.DialogBottomListener {
//                override fun sendConfirm() {
//
//                    var symbol = normalTickList[position].optString("symbol")
//                    if (isLogined && isOptionalSymbolServerOpen) {
//                        var tempList = ArrayList<String>()
//                        tempList.add(symbol)
//                        operationType = 2
//                        addOrDeleteSymbol(tempList)
//                    } else {
//                        removeLocalCollecta(symbol)
//                    }
//                }
//            })
            true
        }
    }

    private fun delOrChangeCollect() {
        if (!LoginManager.isLogin(requireContext())) {
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

    private fun removeLocalCollecta(symbol: String) {

        var newArray = LikeDataService.getInstance().removeCollect(symbol)
        if (null == newArray || newArray.size <= 0) {
            normalTickList.clear()
        } else {
            normalTickList = newArray
        }
        oriSymbols.clear()
        oriSymbols.addAll(normalTickList)
        LikeDataService.getInstance().removeCollect(symbol)
        if (oriSymbols.size != 0) {
            refreshAdapter()
        } else {
            showLikeView(false)
        }
//        mMarketWsData?.closeWS()
        NToastUtil.showTopToastNet(
            mActivity,
            true,
            LanguageUtil.getString(context, "kline_tip_removeCollectionSuccess")
        )
    }

    /**
     *Refresh
     */
    fun refreshAdapter() {
        refreshAdapter(normalTickList)
    }

    /*
     *Obtain server user selected data
     * sync_status
     */
    fun getOptionalSymbol() {
        //Do you want to activate the contract for 'Obtaining User Configuration Now'
        addDisposable(getContractModel().getUserConfig("0",object :NDisposableObserver(){
            override fun onResponseSuccess(jsonObject: JSONObject) {
                Log.d("getUserConfigVis",jsonObject.toString())
                jsonObject.optJSONObject("data").run{
                    val isOpen = optInt("openContract")
                    if(isOpen == 1){

                        //The user has opened a contract to obtain a contract selection list
                        addDisposable(getContractModel().getOptionalList(
                            consumer = object : NDisposableObserver( true) {
                                override fun onResponseSuccess(jsonObject: JSONObject) {
                                    jsonObject.optString("data").run {
                                        showServerSelfSymbols(this)
                                    }
                                }

                                override fun onResponseFailure(code: Int, msg: String?) {
                                    super.onResponseFailure(code, msg)
                                    //Failed to obtain the self selected contract list, and then go to showData to display the list normally
                                    showData()
                                }
                            }))


                    }else{
                        showData()
//                        showLikeView(false)
                    }
                }
            }

            override fun onResponseFailure(code: Int, msg: String?) {
                super.onResponseFailure(code, msg)
                showLikeView(false)
            }
        }))
    }

    val getUserSelfDataReqType = 2 //Server user selected data
    val addCancelUserSelfDataReqType = 3

    inner class MyNDisposableObserver(symbols: ArrayList<String>?, type: Int) :
        NDisposableObserver() {

        var msymbols = symbols
        var req_type = type
        override fun onResponseSuccess(jsonObject: JSONObject) {
            //LogUtil.d("LikesFragment","onResponseSuccess==req_type is $req_type,jsonObject is &jsonObject ")
            closeLoadingDialog()
            if (getUserSelfDataReqType == req_type) {
                LogUtil.d(
                    "LikesFragment",
                    "onResponseSuccess==req_type is $req_type,jsonObject is $jsonObject "
                )
                showServerSelfSymbols(jsonObject.optString("data"))
            } else if (addCancelUserSelfDataReqType == req_type) {
                if (0 == operationType) {
                    //showLoadingDialog()
                    //getOptionalSymbol()
                } else if (2 == operationType) {
                    if (null != msymbols && msymbols!!.size > 0) {
                        removeLocalCollecta(msymbols!![0])
                    }
                }
            }
        }

        override fun onResponseFailure(code: Int, msg: String?) {
            super.onResponseFailure(code, msg)
            closeLoadingDialog()
        }
    }

    /*
     *Display server user's custom currency pair data
     */
    private fun showServerSelfSymbols(data: String?) {
            data?.apply {
                if (TextUtils.isEmpty(this)){
                    CpClLogicContractSetting.setContractJsonCollectListStr(
                        requireContext(),
                        ""
                    )
                }else{
                    var contractIds= this.split(",")
                    for (buff in contractIds){
                        CpClLogicContractSetting.collectContractCoinTx(
                            requireContext(),
                            buff.toInt()
                        )
                    }
                }
            }
        showData()
    }

    private fun refreshAdapter(list: ArrayList<JSONObject>) {
        adapter?.setList(list)
    }

    override fun fragmentVisibile(isVisibleToUser: Boolean) {
        super.fragmentVisibile(isVisibleToUser)
        LogUtil.d(TAG, "$TAG is $isVisibleToUser")
        if(isVisibleToUser){
            getOptionalData()
            setIcEditVisible()
        }
    }
    //Set whether Dad's editing icon is displayed
    private fun setIcEditVisible(){
        val likesFragment = parentFragment as LikesFragment
        if(isShowLikeView){
            //The icon that displays its father's edit preferences list
            likesFragment.setEditIconGone(false)
        }else{
            //Hide the icon from its father's edit selection list
            likesFragment.setEditIconGone(true)
        }
    }

    var isLogined = false
    var isOptionalSymbolServerOpen = false


    private fun getOptionalData() {
        isLogined = UserDataService.getInstance().isLogined
        if (isLogined) {
            isOptionalSymbolServerOpen =
                PublicInfoDataService.getInstance().isOptionalSymbolServerOpen(null)
        }
        if (isLogined && isOptionalSymbolServerOpen) {
            getOptionalSymbol()
        } else {
            showData()
        }

    }

    /**
     *Add or delete custom data
     *@param operationType identifier 0 (batch addition)/1 (single addition)/2 (single deletion)
     *@param symbol Single currency pair name
     */
    var operationType = 0

    fun addOrDeleteSymbol(symbols: ArrayList<String>?) {
        if (isLogined && isOptionalSymbolServerOpen) {
            if (null == symbols || symbols.isEmpty())
                return
            addDisposable(
                getMainModel().addOrDeleteSymbol(
                    operationType,
                    symbols,
                    MyNDisposableObserver(symbols, addCancelUserSelfDataReqType)
                )
            )
        }
    }

    fun handleData(data: String) {
        if(!mIsVisibleToUser||isScrollStatus) return
        
        try {
            val json = JSONObject(data)
            val channel = json.optString("channel")
            if(!WsLinkUtils.is24HLinkTicker(channel)) return
            if (!json.isNull("tick")) {
                doAsync {
                    val quotesData = json
                    showWsData(quotesData)
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun showWsData(jsonObject: JSONObject) {
        if (normalTickList.isEmpty())
            return
        LogUtil.d(TAG, "showWsData==jsonObject is $jsonObject")
        if (rv_market_detail?.layoutManager == null) {
            return
        }
        val obj = SymbolWsData().getNewSymbolObjContract(normalTickList, jsonObject)
        val layoutManager = rv_market_detail?.layoutManager as LinearLayoutManager
        val firstView = layoutManager.findFirstVisibleItemPosition()
        val lastItem = layoutManager.findLastVisibleItemPosition()
        if (obj?.length() ?: 0 > 0) {
            val pos = normalTickList.indexOf(obj)
            if (pos >= 0) {
                val isRange = (firstView..lastItem).contains(pos)
                if (!isRange) return
                activity?.runOnUiThread {
                    if (obj != null) {
                        adapter?.setData(pos, obj)
                    }
                }
            }
        }
    }

    fun getCoins(): ArrayList<Any> {
        val items = arrayListOf<Any>()
        if (adapter != null && adapter?.data != null) {
            items.addAll(adapter?.data!!)
        }
        return items
    }

    fun handleData(items: HashMap<String, JSONObject>) {
        if(!mIsVisibleToUser||isScrollStatus) return
        
        val data = adapter?.data
        if (data?.isEmpty()!!)
            return
        LogUtil.d(TAG, "showWsData==jsonObject is $items")
        if (rv_market_detail?.layoutManager == null) {
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
                normalTickList.set(tempData, model)
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

    private fun reloadLocalTick(news: ArrayList<JSONObject>) {
        for (item in news) {
            val symbolLocal =
                normalTickList.findLast { it.optString("contractName") == item.optString("contractName") }
            if (symbolLocal != null) {
                item.put("rose", symbolLocal.optString("rose"))
                item.put("close", symbolLocal.optString("close"))
                item.put("vol", symbolLocal.optString("vol"))
            }
        }
        if (newPriceIndex != 0 || limitIndex != 0 || nameIndex != 0) {
            if (newPriceIndex != 0) {
                when (newPriceIndex) {
                    1 -> {
                        news.sortBy { it.optDouble("close", 0.0) }
                    }
                    2 -> {
                        news.sortByDescending { it.optDouble("close", 0.0) }
                    }
                }
            } else if (nameIndex != 0) {
                when (nameIndex) {
                    1 -> {
                        news.sortBy { NCoinManager.showAnoterName(it) }
                    }
                    2 -> {
                        news.sortByDescending { NCoinManager.showAnoterName(it) }
                    }
                }
            } else if (limitIndex != 0) {
                when (limitIndex) {
                    1 -> {
                        news.sortBy { it.optDouble("rose", 0.0) }
                    }
                    2 -> {
                        news.sortByDescending { it.optDouble("rose", 0.0) }
                    }
                }
            }
        }
    }


    @Subscribe(threadMode = ThreadMode.POSTING)
    override fun onMessageEvent(event: MessageEvent) {
        when (event.msg_type) {
            CpMessageEvent.sl_contract_market_event -> {
                handleData(event.msg_content as String)
            }
            MessageEvent.like_contract_optional_coin,MessageEvent.login_success_event -> {
                getOptionalData()
            }
        }
    }

    private fun sendUpdateListMessage(){
        Handler().postDelayed(Runnable {
            EventBusUtil.post(MessageEvent(MessageEvent.market_updateList))
        },1000)
    }

}
