package com.yjkj.chainup.new_version.fragment

import android.os.Handler
import android.util.Log
import androidx.recyclerview.widget.DefaultItemAnimator
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import android.view.View
import com.google.gson.Gson
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseFragment
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
import com.yjkj.chainup.model.model.MainModel
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_version.adapter.MarketDetailAdapter
import com.yjkj.chainup.new_version.adapter.RecommendCoinAdapter
import com.yjkj.chainup.new_version.dialog.DialogUtil
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.home.callback.MarketTabDiffCallback
import com.yjkj.chainup.new_version.view.CommonlyUsedButton
import com.yjkj.chainup.util.*
import kotlinx.android.synthetic.main.fragment_spot_likes.*
import kotlinx.android.synthetic.main.include_market_sort.*
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode
import org.jetbrains.anko.doAsync
import org.jetbrains.anko.imageResource
import org.json.JSONObject
import java.util.HashMap


/**
 *@description: The self selected page of the market
 * @Date 2023-1- 5
 * @author Bertking
 *
 *PS: Although this fragment is similar to the MarketFragment, it is handled separately
 *1 Improve code readability;
 *2 Improve performance
 */
class SpotLikesFragment : NBaseFragment() {

    override fun setContentView() = R.layout.fragment_spot_likes

    var adapter: MarketDetailAdapter? = null
    var mRecommendCoinAdapter: RecommendCoinAdapter? = null
     var mRecommendCoinData: ArrayList<JSONObject> = ArrayList()
    private var curIndex = 0
    var isScrollStatus = false

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

        getOptionalData()
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

    private var bufferTickList = arrayListOf<JSONObject>()

    private var normalTickList = arrayListOf<JSONObject>()

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
        btn_confirm?.listener = object : CommonlyUsedButton.OnBottonListener {
            override fun bottonOnClick() {
                var symbols = arrayListOf<String>()
                for (buff in mRecommendCoinData) {
                    if (buff.optBoolean("isSel")) {
                        val symbol=   buff.optString("symbol")
                        symbols.add(symbol)
                        LikeDataService.getInstance().saveCollecData(symbol, null)
                    }
                }
                if (symbols.size!=0){
                    //Batch Add
                    operationType = 0
                    addOrDeleteSymbol(symbols)
                }
                showData()
                sendUpdateListMessage()

            }
        }
        btn_confirm.isEnable(true)

    }

    private fun sendUpdateListMessage(){
        Handler().postDelayed(Runnable {
            EventBusUtil.post(MessageEvent(MessageEvent.market_updateList))
        },1000)
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
       var collecData= LikeDataService.getInstance().getCollecData(false)
        LikeDataService.getInstance().clearAllCollect()
        for (i in 0 until collecData.size) {
            var symbol = collecData.get(i).optString("symbol")
            var symbolObj = NCoinManager.getSymbolObj(symbol)
            if (null != symbolObj && symbolObj.length() > 0) {
                LikeDataService.getInstance().saveCollecData(symbol, symbolObj)
            }
        }
        return LikeDataService.getInstance().getCollecData(false)
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
            setMarket2List(normalTickList)
            adapter?.setList(normalTickList)
            initSocket()

        } else {
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
            ll_item_titles?.visibility = View.VISIBLE
            rv_market_detail?.visibility = View.VISIBLE
        } else {
            normalTickList.clear()
            ll_item_titles?.visibility = View.GONE
            adapter?.setList(normalTickList)
        }

        //Recommend adding visibility settings for currency to one click
        ll_recommend.visibility = if(!isShowLikeView && mRecommendCoinData.size>0){
            View.VISIBLE
        }else{

            View.GONE
        }
        //If the recommended currency pair is displayed but there is no recommended currency pair, the proportion map will be displayed
        if(!isShowLikeView && mRecommendCoinData.size<=0){
            ll_no_data.visibility = View.VISIBLE
        }else{
            ll_no_data.visibility = View.GONE
        }

        ll_content.visibility=if (isShowLikeView) View.VISIBLE else View.GONE
    }


    private fun initAdapter() {
        mRecommendCoinData.clear()
        mRecommendCoinData.addAll(NCoinManager.getMarketByLikeDefault())
        for (buff in mRecommendCoinData){
            buff.put("isSel", true)
        }
        mRecommendCoinAdapter=RecommendCoinAdapter(R.layout.item_favorites_empty,"spot",mRecommendCoinData)
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

        adapter = MarketDetailAdapter()
        adapter?.isMarketLike = true
        rv_market_detail?.adapter = adapter
        rv_market_detail?.setHasFixedSize(true)
        rv_market_detail?.setItemViewCacheSize(8)
//        val emptyForAdapterView = EmptyMarketForAdapterView(context ?: return)
//        adapter?.setEmptyView(emptyForAdapterView)
//        adapter?.emptyLayout?.findViewById<LinearLayout>(R.id.layout_add_like)?.setOnClickListener {
//            ArouterUtil.greenChannel(RoutePath.CoinMapActivity, Bundle().apply {
//                putString(ParamConstant.TYPE, ParamConstant.ADD_COIN_MAP)
//            })
//        }

        adapter?.setOnItemClickListener { adapter, _, position ->
            val data = adapter.data[position] as JSONObject
            ArouterUtil.forwardKLine(data.optString("symbol"))

        }
        adapter?.setOnItemLongClickListener { _adapter, view, position ->
            adapter?.modifySelBg(position,true)
            DialogUtil.createMarketPop(requireContext(), view,false,true,dialogItemClickListener=object :
                NewDialogUtils.DialogOnSigningItemClickListener {
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
                        adapter?.setList(normalTickList)

                        LikeDataService.getInstance().apply {
                            clearAllCollect()
                            //Update local cache
                            saveCollecData(normalTickList)
                            if(LoginManager.isLogin(mActivity)) upload()
                        }
                    }else{
                        //Collection
                     var symbol = normalTickList[position].optString("symbol")
                    if (isLogined && isOptionalSymbolServerOpen) {
                        var tempList = ArrayList<String>()
                        tempList.add(symbol)
                        operationType = 2
                        addOrDeleteSymbol(tempList)
                    } else {
                        removeLocalCollecta(symbol)
                    }
                        NToastUtil.showTopToastNet(mActivity, true, LanguageUtil.getString(context, "kline_tip_removeCollectionSuccess"))
                    }
                    _adapter.notifyItemChanged(position)

                    sendUpdateListMessage()
                }

                override fun onDismiss() {
                    adapter?.modifySelBg(position,false)
                }
            })
//            NewDialogUtils.showNormalDialog(context!!, LanguageUtil.getString(context, "new_confrim_likes"), object : NewDialogUtils.DialogBottomListener {
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


    private fun upload(isDelete: Boolean = false) {
        val symbols = normalTickList.getSymbols()
        showLoadingDialog()
        MainModel().likesCoinsUpload(symbols, object : NDisposableObserver() {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                closeLoadingDialog()
            }

            override fun onResponseFailure(code: Int, msg: String?) {
                super.onResponseFailure(code, msg)
                closeLoadingDialog()
            }
        })
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
        Handler().postDelayed({
            initSocket()
        }, 200)
        NToastUtil.showTopToastNet(mActivity, true, LanguageUtil.getString(context, "kline_tip_removeCollectionSuccess"))
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
        addDisposable(getMainModel().getOptionalSymbol(MyNDisposableObserver(null, getUserSelfDataReqType)))
    }


    val getUserSelfDataReqType = 2 //Server user selected data
    val addCancelUserSelfDataReqType = 3

    inner class MyNDisposableObserver(symbols: ArrayList<String>?, type: Int) : NDisposableObserver() {

        var msymbols = symbols
        var req_type = type
        override fun onResponseSuccess(jsonObject: JSONObject) {
            //LogUtil.d("LikesFragment","onResponseSuccess==req_type is $req_type,jsonObject is &jsonObject ")
            closeLoadingDialog()
            if (getUserSelfDataReqType == req_type) {
                LogUtil.d("LikesFragment", "onResponseSuccess==req_type is $req_type,jsonObject is $jsonObject ")
                showServerSelfSymbols(jsonObject.optJSONObject("data"))
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
    private fun showServerSelfSymbols(data: JSONObject?) {

        if (null == data || data.length() <= 0) {
            showData()
            return
        }

        var array = data.optJSONArray("symbols")
        var sync_status = data.optString("sync_status", "")

        if ("0".equals(sync_status)) {
            var array = LikeDataService.getInstance().symbols
            if (null != array && array.length() > 0) {
                var temps = ArrayList<String>()
                for (i in 0 until array.length()) {
                    temps.add(array.optString(i))
                }
                operationType = 0
                addOrDeleteSymbol(temps)
            }
        }

        if (null == array || array.length() <= 0) {
            LikeDataService.getInstance().clearAllCollect()
            showLikeView(false)
            return
        }

        LikeDataService.getInstance().clearAllCollect()
        var tempList = ArrayList<JSONObject>()
        for (i in 0 until array.length()) {
            var symbol = array.optString(i)
            var symbolObj = NCoinManager.getSymbolObj(symbol)
            if (null != symbolObj && symbolObj.length() > 0) {
                LikeDataService.getInstance().saveCollecData(symbol, symbolObj)
                tempList.add(symbolObj)
            }
        }

        if (!tempList.isEmpty()) {

            serverOriDataList.clear()
            serverOriDataList.addAll(tempList)

            oriSymbols.clear()
            oriSymbols.addAll(tempList)
            reloadLocalTick(tempList)
            normalTickList.clear()
            normalTickList.addAll(tempList)
        }
        showLikeView(true)
        setMarket2List(normalTickList)
        adapter?.setList(normalTickList)
        initSocket()
    }

    private fun refreshAdapter(list: ArrayList<JSONObject>) {
        adapter?.setList(list)
    }

    private fun initSocket() {
        pageEventSymbol()
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
            addDisposable(getMainModel().addOrDeleteSymbol(operationType, symbols, MyNDisposableObserver(symbols, addCancelUserSelfDataReqType)))
        }
    }

    fun startInit() {
        Handler().postDelayed({
            pageEventSymbol()
        }, 200)
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
        var messageEvent = MessageEvent(MessageEvent.market_event_page_symbol_type)
        messageEvent.msg_content = hashMapOf("symbols" to coin, "bind" to isBind, "curIndex" to curIndex)
        EventBusUtil.post(messageEvent)
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
        val obj = SymbolWsData().getNewSymbolObj(normalTickList, jsonObject)
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
            val symbolLocal = normalTickList.findLast { it.optString("symbol") == item.optString("symbol") }
            if (symbolLocal != null){
                item.put("rose", symbolLocal.optString("rose"))
                item.put("close", symbolLocal.optString("close"))
                item.put("vol", symbolLocal.optString("vol"))
            }
        }
        if (newPriceIndex != 0 || limitIndex != 0 ||  nameIndex != 0) {
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
            MessageEvent.like_coin_symbol_type,MessageEvent.login_success_event -> {
                getOptionalData()
            }
        }
    }

    private fun getOptionalData() {
        isLogined = UserDataService.getInstance().isLogined
        if (isLogined) {
            isOptionalSymbolServerOpen = PublicInfoDataService.getInstance().isOptionalSymbolServerOpen(null)
        }
        if (isLogined && isOptionalSymbolServerOpen) {
            getOptionalSymbol()
        } else {
            showData()
        }
    }

    private fun setMarket2List(first: java.util.ArrayList<JSONObject>?) {
        var mAllMarketStr=  MarketUtil.getAllMarketData();
        if(mAllMarketStr.isNotEmpty()){
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
    }

}
