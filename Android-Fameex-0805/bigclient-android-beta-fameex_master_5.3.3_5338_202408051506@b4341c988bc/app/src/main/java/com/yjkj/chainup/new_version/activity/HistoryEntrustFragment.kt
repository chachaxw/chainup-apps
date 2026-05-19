package com.yjkj.chainup.new_version.activity

import android.os.Bundle
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import android.text.TextUtils
import android.util.Log
import android.view.View
import com.chainup.kit.views.KKEmptyViewKit
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseFragment
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.model.model.MainModel
import com.yjkj.chainup.net_new.JSONUtil
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_version.adapter.NHistoryEntrustAdapter
import com.yjkj.chainup.new_version.view.HistoryScreeningControl
import com.yjkj.chainup.util.BigDecimalUtils
import com.yjkj.chainup.new_version.view.EmptyForAdapterView
import com.yjkj.chainup.new_version.view.ScreeningPopupWindowView
import com.yjkj.chainup.util.LogUtil
import kotlinx.android.synthetic.main.activity_cash_flow4.swipe_refresh
import kotlinx.android.synthetic.main.activity_history_entrust.*
import org.json.JSONObject

/**
 * @Author: Bertking
 * @Date 2023/4/8-10:26 AM
 *@description: Historical commission
 */
class HistoryEntrustFragment : NBaseFragment(), HistoryScreeningListener {
    override fun ConfirmationScreen(status: Boolean, statusType: Int, symbolCoin: String, symbolAndUnit: String, tradingType: Int, priceType: Int, begin: String, end: String) {
        var activity = activity

        if (activity != null && !activity.isFinishing) {
            if (activity is EntrustActivity) {

                if (!TextUtils.isEmpty(symbolCoin) || !TextUtils.isEmpty(symbolAndUnit)) {
                    ll_tip_layout?.visibility = View.GONE
                } else {
                    ll_tip_layout?.visibility = View.VISIBLE
                }
                var trading = ""
                page = 1
                if (status) {
                    isShowCanceled = "1"
                } else {
                    isShowCanceled = "0"
                }
                isScrollStatus = true
                when (tradingType) {
                    1 -> {
                        trading = "BUY"
                    }
                    2 -> {
                        trading = "SELL"

                    }
                }
                this.statusType = statusType
                side = trading
                if (symbolCoin.isNotEmpty()){
                    symbol = NCoinManager.setShowNameGetName(symbolCoin) + NCoinManager.setShowNameGetName(symbolAndUnit)
                }
                if (priceType == 0) {
                    type = ""
                } else {
                    type = priceType.toString()
                }
                startTime = begin
                endTime = end
                if (activity.currentItem == 1) {
                    if (PublicInfoDataService.getInstance().getOpenOrderCollect(null)) {
                        getNewHistoryEntrust(true)
                    } else {
                        getHistoryEntrust(true)
                    }
                }
            }
        }
    }


    fun initData() {
        page = 1
        if (PublicInfoDataService.getInstance().getOpenOrderCollect(null)) {
//            ll_tip_layout?.visibility = View.VISIBLE
            getNewHistoryEntrust(true)
        } else {
            if (symbol.isEmpty()){
                symbol = if (orderType == ParamConstant.LEVER_INDEX) {
                    PublicInfoDataService.getInstance().currentSymbol4Lever
                } else {
                    PublicInfoDataService.getInstance().currentSymbol
                }
            }
//            ll_tip_layout?.visibility = View.GONE
            getHistoryEntrust(true)
        }
    }


    override fun setContentView() = R.layout.activity_history_entrust
    var orderList = ArrayList<JSONObject>()
    var coinList = arrayListOf<String>()

    companion object {

        @JvmStatic
        fun newInstance(orderType: String) =
                HistoryEntrustFragment().apply {
                    arguments = Bundle().apply {
                        putString(ParamConstant.TYPE, orderType)

                    }
                }
    }

    override fun loadData() {
        arguments.let {
            orderType = it?.getString(ParamConstant.TYPE, ParamConstant.BIBI_INDEX)
                    ?: ParamConstant.BIBI_INDEX
        }
    }

    var orderType = ParamConstant.BIBI_INDEX


    var isShowCanceled = "1"
    var side = ""
    var type = ""
    var startTime = ""
    var endTime = ""
    var symbol = ""
    val pageSize = 20
    var page = 1
    var statusType = 0

    var isScrollStatus = true

    override fun initView() {
        HistoryScreeningControl.getInstance().addListener(this)
//        if (PublicInfoDataService.getInstance().getOpenOrderCollect(null)) {
//            ll_tip_layout?.visibility = View.VISIBLE
//        } else {
//            ll_tip_layout?.visibility = View.GONE
//        }
        initAdapter()
        tv_tip_title?.text = LanguageUtil.getString(mActivity, "common_text_tip")
        tv_tip_content?.text = LanguageUtil.getString(mActivity, "common_text_entrustListLimit")
        /**
         *This is the refresh page
         */
        swipe_refresh?.setOnRefreshListener {
            page = 1
            isScrollStatus = true
            if (PublicInfoDataService.getInstance().getOpenOrderCollect(null)) {
                getNewHistoryEntrust(true)
            } else {
                getHistoryEntrust(true)
            }
        }
        swipe_refresh?.setOnLoadMoreListener {
            page += 1
            if (PublicInfoDataService.getInstance().getOpenOrderCollect(null)) {
                getNewHistoryEntrust(false)
            } else {
                getHistoryEntrust(false)
            }
        }
        initData()
    }


    var historyAdapter = NHistoryEntrustAdapter(orderList)

    fun initAdapter() {

        rv_history_entrust?.layoutManager = LinearLayoutManager(mActivity)
        rv_history_entrust?.adapter = historyAdapter
        historyAdapter?.setEmptyView(KKEmptyViewKit(requireContext()))
        historyAdapter.setOnItemClickListener { adapter, view, position ->

            if (adapter?.data?.isNotEmpty() == true) {
                try {
                    (adapter.data[position] as JSONObject?)?.run {
                        if (optString("status") == "2" || optString("status") == "3" || (optString("status") == "4" && BigDecimalUtils.compareTo(optString("deal_volume"), "0") == 1)) {
                            ArouterUtil.greenChannel(RoutePath.EntrustDetialsActivity, Bundle().apply {
                                putString(ParamConstant.DEAL_VOLUME, optString("deal_volume", ""))

                                putString(ParamConstant.HISTORY_SIDE, optString("side", ""))

                                putString(ParamConstant.AVG_PRICE, optString("avg_price", ""))

                                putString(ParamConstant.DEAL_MONEY, optString("deal_money", ""))

                                putString(ParamConstant.ENTRUST_ID, optString("id", ""))

                                putString(ParamConstant.TYPE, orderType)
                                putString(ParamConstant.BASE_COIN, optString("baseCoin"))
                                putString(ParamConstant.COUNT_COIN, optString("countCoin"))
                                putString(ParamConstant.symbol, symbol)

                            })
                        }
                    }

                } catch (e: java.lang.Exception) {
                    e.printStackTrace()
                }
            }


        }
    }


    /**
     *Obtaining Historical Commissions
     * @param symbol
     * @param pageSize default 10
     * @param page  default 1
     *Does @param isShowCanceled display cancelled orders? 0 indicates no display, 1 indicates display, default to 1
     *@param side order buying and selling direction, BUY buy sell, do not transfer all
     *@param type Delegate type: 1 limit, 2 market, do not pass all
     *@param startTime, month, day, year, year. Input of hours, minutes, and seconds is prohibited: April 22, 2019
     *@param endTime, month, day, year, year. Input of hours, minutes, and seconds is prohibited: April 22, 2019
     */
    private fun getHistoryEntrust(refresh: Boolean) {
        if (!UserDataService.getInstance().isLogined) {
            return
        }
        var statusTypeStr=""
        if (statusType == 0){
            statusTypeStr=""
        }else if (statusType == 1){
            statusTypeStr="2"
        }else if (statusType == 2){
            statusTypeStr="4"
        }else{
            statusTypeStr=""
        }
        addDisposable(MainModel().getHistoryEntrust4(symbol = symbol,
                page = page.toString(),
                pageSize = "20",
                isShowCanceled = isShowCanceled,
                side = side,
                type = type,
                statusType = statusTypeStr,
                isLever = (orderType == ParamConstant.LEVER_INDEX),
                consumer = object : NDisposableObserver() {
                    override fun onResponseSuccess(jsonObject: JSONObject) {
                        try {

                            var activity = activity

                            if (activity != null && !activity.isFinishing) {
                                if (activity is EntrustActivity) {
                                    if (activity.currentItem == 1) {
                                        swipe_refresh?.finishRefresh(true)
                                        jsonObject.optJSONObject("data")?.run {
                                            val orderJsonArray = optJSONArray("orderList")
                                            var entrustActivity = activity
                                            if (orderJsonArray != null && orderJsonArray.length() != 0) {
                                                if (refresh) {
                                                    orderList.clear()
                                                    var list = JSONUtil.arrayToList(orderJsonArray)
                                                    if (null != list) {
                                                        orderList.addAll(list)
                                                    }
                                                    swipe_refresh?.finishRefresh(100,true,list.size < 20)
                                                } else {
                                                    if (orderJsonArray?.length() ?: 0 < 20) {
                                                        isScrollStatus = false
                                                    }
                                                    var list = JSONUtil.arrayToList(orderJsonArray)
                                                    if (null != list) {
                                                        orderList.addAll(list)
                                                    }
                                                    swipe_refresh?.finishLoadMore(100,true,list.size < 20)
                                                }
                                                historyAdapter?.setList(orderList)
                                            }
                                            if ((orderJsonArray == null || orderJsonArray.length() == 0) && refresh) {
                                                orderList.clear()
                                                historyAdapter?.setList(orderList)
                                                historyAdapter.setEmptyView(KKEmptyViewKit(requireContext()))
                                                swipe_refresh?.finishRefresh(100,true,true)
                                            }else{
                                                swipe_refresh?.finishLoadMore(100,true,true)
                                            }

                                        }
                                    }
                                }
                            }
                        } catch (e: Exception) {
                            e.printStackTrace()
                        }

                    }

                    override fun onResponseFailure(code: Int, msg: String?) {
                        super.onResponseFailure(code, msg)
                        try {

                        } catch (e: Exception) {
                            e.printStackTrace()
                        }
                        swipe_refresh?.finishRefresh(false)
                        swipe_refresh?.finishLoadMore(false)
                        orderList.clear()
                        historyAdapter?.setList(orderList)
                    }
                }))
    }


    /**
     *New version historical delegation
     *@param entrustment 1: current entrustment, 2: historical entrustment
     *Param side BUY: buy, SELL: sell fFfFUuPp
     *@param symbol currency pair
     *@param orderType Order Type 1: Regular Order, 2: Leveraged Order
     *@param status Order status: 1 New order, 2 Completed, 3 Partial transactions, 4 Cancelled, 5 Pending cancellation, 6 Abnormal orders
     *@param isShowCanceled 0: Do not display cancelled orders, default to displaying cancelled orders for others
     *@param quote is located in the trading area (USDT...)
     *@param page pagination
     *@param pageSize Page size
     */
    private fun getNewHistoryEntrust(refresh: Boolean) {
        if (!UserDataService.getInstance().isLogined) {
            return
        }

        addDisposable(getMainModel().getNewEntrustSearch(side, symbol, isShowCanceled, statusType, type, page.toString(), pageSize.toString(), (orderType == ParamConstant.LEVER_INDEX), ParamConstant.HISTORY_ENTURST, object : NDisposableObserver() {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                try {

                    var activity = activity

                    if (activity != null && !activity.isFinishing) {
                        if (activity is EntrustActivity) {
                            if (activity.currentItem == 1) {
                                var t = jsonObject.optJSONObject("data")
                                
                                swipe_refresh?.finishRefresh(true)

                                var ordersList = t?.optJSONArray("orders")
                                var entrustActivity = activity
                                if (ordersList != null && ordersList.length() > 0) {
                                    if (refresh) {
                                        orderList?.clear()
                                        var list = JSONUtil.arrayToList(ordersList)
                                        if (list != null) {
                                            orderList?.addAll(list)
                                        }
                                        swipe_refresh?.finishRefresh(100,true,list.size < 20)
                                    } else {
                                        if (ordersList.length() < 20) {
                                            isScrollStatus = false
                                        }
                                        var list = JSONUtil.arrayToList(ordersList)
                                        if (list != null) {
                                            orderList?.addAll(list)
                                        }
                                        swipe_refresh?.finishLoadMore(100,true,list.size < 20)
                                    }
                                    historyAdapter?.setList(orderList)
                                } else {
                                    if (refresh) {
                                        orderList.clear()
                                        historyAdapter.setList(orderList)
                                        historyAdapter.setEmptyView(KKEmptyViewKit(requireContext()))
                                        swipe_refresh?.finishRefresh(100,true,true)
                                    }else{
                                        swipe_refresh?.finishLoadMore(100,true,true)
                                    }
                                }
                            }
                        }
                    }


                } catch (e: Exception) {
                    e.printStackTrace()
                }

            }

            override fun onResponseFailure(code: Int, msg: String?) {
                super.onResponseFailure(code, msg)
                try {
                    if (isResumed) {
                        orderList.clear()
                        historyAdapter?.setList(orderList)
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                }
                swipe_refresh?.finishRefresh(false)
                swipe_refresh?.finishLoadMore(false)
            }

        }))
    }


}
