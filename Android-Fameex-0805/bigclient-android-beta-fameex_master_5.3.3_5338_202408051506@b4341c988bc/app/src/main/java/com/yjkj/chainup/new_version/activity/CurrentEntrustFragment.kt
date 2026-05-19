package com.yjkj.chainup.new_version.activity

import android.os.Bundle
import androidx.recyclerview.widget.LinearLayoutManager
import android.text.TextUtils
import android.view.View
import com.chainup.kit.views.KKEmptyViewKit
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseFragment
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_version.adapter.NCurrentEntrustAdapter
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.view.HistoryScreeningControl
import com.yjkj.chainup.util.NToastUtil
import com.yjkj.chainup.util.ToastUtils
import kotlinx.android.synthetic.main.activity_current_entrust.*
import kotlinx.android.synthetic.main.activity_withdraw_record.swipe_refresh
import org.json.JSONObject

/**
 * @Author: Bertking
 * @Date 2023/4/4-10:26 AM
 *@description: All current commissions (in stock)
 */

class CurrentEntrustFragment : NBaseFragment(), HistoryScreeningListener {


    var isShowCanceled = "0"
    var side = ""
    var type = ""
    var startTime = ""
    var endTime = ""
    val pageSize = 100
    var page = 1
    var isScrollStatus = true

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
                isScrollStatus = true
                when (tradingType) {
                    1 -> {
                        trading = "BUY"
                    }
                    2 -> {
                        trading = "SELL"

                    }
                }

                isShowCanceled = if (status) "0" else "1"
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
                if (activity.currentItem == 0) {
                    if (PublicInfoDataService.getInstance().getOpenOrderCollect(null)) {
                        getNewHistoryEntrust()
                    } else {
                        getCurrentEntrust()
                    }
                }
            }
        }
    }

    fun initData() {
//        ll_tip_layout?.visibility = View.VISIBLE
        if (PublicInfoDataService.getInstance().getOpenOrderCollect(null)) {
//            ll_tip_layout?.visibility = View.VISIBLE
            getNewHistoryEntrust()
        } else {
//            ll_tip_layout?.visibility = View.GONE
            if (symbol.isEmpty()){
                symbol = if (orderType == ParamConstant.LEVER_INDEX) {
                    PublicInfoDataService.getInstance().currentSymbol4Lever
                } else {
                    PublicInfoDataService.getInstance().currentSymbol
                }
            }
            getCurrentEntrust()
        }
    }


    var list = ArrayList<JSONObject>()
    var curEntrustAdapter = NCurrentEntrustAdapter(list)

    var symbol = ""

    companion object {
        @JvmStatic
        fun newInstance(orderType: String) =
                CurrentEntrustFragment().apply {
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

    override fun setContentView() = R.layout.activity_current_entrust


    override fun initView() {
        HistoryScreeningControl.getInstance().addListener(this)
//        if (PublicInfoDataService.getInstance().getOpenOrderCollect(null)) {
//            ll_tip_layout?.visibility = View.VISIBLE
//        } else {
//            ll_tip_layout?.visibility = View.GONE
//        }
        tv_tip_title?.text = LanguageUtil.getString(mActivity, "common_text_tip")
        tv_tip_content?.text = LanguageUtil.getString(mActivity, "common_text_entrustListLimit")
//        tv_title?.text = LanguageUtil.getString(context, "contract_text_currentEntrust")
//        tv_sub_title?.text = LanguageUtil.getString(context, "contract_text_currentEntrust")
//        tv_history_order?.text = LanguageUtil.getString(context, "contract_text_historyCommision")

        rv_all_entrust?.layoutManager = LinearLayoutManager(mActivity)
        rv_all_entrust?.adapter = curEntrustAdapter
        curEntrustAdapter.setEmptyView(KKEmptyViewKit(requireContext()))
        curEntrustAdapter.addChildClickViewIds(R.id.tv_status)
        curEntrustAdapter.setOnItemChildClickListener { adapter, _, position ->
            if (adapter.data.isNotEmpty()) {
                try {
                    (adapter.data[position] as JSONObject?)?.run {
                        var source = optString("source")
                        if (source == "QUANT-GRID") {
                            NewDialogUtils.showNewsingleDialog2(requireContext(), getString(R.string.stop_grid_operate_again), object : NewDialogUtils.DialogBottomListener {
                                override fun sendConfirm() {

                                }
                            }, cancelTitle = LanguageUtil.getString(context, "alert_common_i_understand"))
                        }else{
                            val status = this.optString("status")
                            val id = this.optString("id")
                            val baseCoin = optString("baseCoin").toLowerCase()
                            val countCoin = optString("countCoin").toLowerCase()

                            when (status) {
                                "0", "1", "3" -> {
                                    deleteOrder(id, baseCoin + countCoin, position)
                                }
                            }
                        }



                    }

                } catch (e: java.lang.Exception) {
                    e.printStackTrace()
                }
            }
        }
        initData()

        swipe_refresh?.setOnRefreshListener {
            getCurrentEntrust()
        }
        swipe_refresh?.setEnableLoadMore(false)
    }

    /**
     *Obtain current delegation
     */
    private fun getCurrentEntrust() {
        if (!UserDataService.getInstance().isLogined) {
            return
        }

//        val symbol = if (orderType == ParamConstant.LEVER_INDEX) {
//            PublicInfoDataService.getInstance().currentSymbol4Lever
//        } else {
//            PublicInfoDataService.getInstance().currentSymbol
//        }

        addDisposable(getMainModel().getNewEntrust(symbol = symbol,type = "",side = side, isLever = (orderType == ParamConstant.LEVER_INDEX), isOnly20 = false, consumer = object : NDisposableObserver(showToast = true) {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                swipe_refresh?.finishRefresh()
                try {
                    val activity = activity
                    if (activity != null && !activity.isFinishing) {
                        if (activity is EntrustActivity) {
                            if (activity.currentItem == 0) {
                                list.clear()
                                closeLoadingDialog()
                                jsonObject.optJSONObject("data")?.run {
                                    optJSONArray("orderList")?.run {
                                        if (length() != 0) {
                                            for (i in 0 until length()) {
                                                list.add(this.optJSONObject(i))
                                            }
                                            curEntrustAdapter.setList(list)
                                        } else {
                                            curEntrustAdapter.setList(list)
                                            curEntrustAdapter.setEmptyView(KKEmptyViewKit(requireContext()))
                                        }
                                    }
                                }
                            }
                        }
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                }

            }

            override fun onError(e: Throwable) {
                super.onError(e)
                ToastUtils.showToast(e.message)
                swipe_refresh?.finishRefresh()
            }
        }))

    }


    /**
     *New version delegation interface
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
    private fun getNewHistoryEntrust() {
        if (!UserDataService.getInstance().isLogined) {
            return
        }

        addDisposable(getMainModel().getNewCurrentEntrustSearch(side, symbol, isShowCanceled, "", page.toString(), pageSize.toString(), (orderType == ParamConstant.LEVER_INDEX), ParamConstant.CURRENT_ENTURST, object : NDisposableObserver() {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                try {
                    var activity = activity

                    if (activity != null && !activity.isFinishing) {
                        if (activity is EntrustActivity) {
                            if (activity.currentItem == 0) {
                                list.clear()
                                closeLoadingDialog()
                                var entrustActivity = activity
                                jsonObject.optJSONObject("data")?.run {
                                    optJSONArray("orders")?.run {
                                        if (length() != 0) {
                                            for (i in 0 until length()) {
                                                list.add(this.optJSONObject(i))
                                            }
                                            curEntrustAdapter.setList(list)
                                        } else {
                                            curEntrustAdapter.setList(list)
                                            curEntrustAdapter.setEmptyView(KKEmptyViewKit(requireContext()))
                                        }
                                    }
                                }
                            }
                        }
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                }

            }
        }))

    }


    /**
     *Cancel Order
     */
    private fun deleteOrder(order_id: String, symbol: String, pos: Int) {
        addDisposable(getMainModel().cancelOrder(order_id = order_id, symbol = symbol, isLever = (orderType == ParamConstant.LEVER_INDEX), consumer = object : NDisposableObserver(mActivity,showToast = true) {
            override fun onResponseSuccess(data: JSONObject) {
                if (pos in (0 until list.size)) {
                    curEntrustAdapter?.remove(pos)
                    curEntrustAdapter?.notifyItemRemoved(pos)
                    NToastUtil.showTopToastNet(mActivity, true, LanguageUtil.getString(context, "common_tip_cancelSuccess"))
                }
            }
        }))
    }
}
