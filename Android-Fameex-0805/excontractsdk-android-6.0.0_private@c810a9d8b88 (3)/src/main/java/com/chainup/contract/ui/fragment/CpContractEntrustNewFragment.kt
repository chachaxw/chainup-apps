package com.chainup.contract.ui.fragment

import android.os.Bundle
import android.view.View
import com.chad.library.adapter.base.listener.OnLoadMoreListener
import com.chainup.contract.R
import com.chainup.contract.base.CpNBaseFragment
import com.chainup.contract.eventbus.CpMessageEvent
import com.chainup.contract.utils.CpClickUtil
import com.chainup.contract.view.CpEmptyOrderForAdapterView
import com.chainup.contract.view.CpMyLinearLayoutManager
import com.chainup.talkingdata.AppAnalyticsExt
import com.google.gson.Gson
import com.yjkj.chainup.net_new.rxjava.CpNDisposableObserver
import com.yjkj.chainup.new_contract.activity.CpContractEntrustDetailActivity
import com.chainup.contract.ui.activity.CpContractEntrustNewActivity
import com.chainup.contract.utils.CpClLogicContractSetting
import com.chainup.contract.utils.CpPreferenceManager
import com.chainup.contract.utils.CpNToastUtil
import com.chainup.contract.view.trade.ContractLoadMoreView
import com.chainup.kit.views.KKEmptyViewKit
import com.yjkj.chainup.manager.CpLanguageUtil
import com.yjkj.chainup.new_contract.adapter.CpContractEntrustNewAdapter
import com.yjkj.chainup.new_contract.bean.CpCurrentOrderBean
import kotlinx.android.synthetic.main.cp_activity_contract_entrust.*
import kotlinx.android.synthetic.main.cp_activity_contract_entrust.swipe_refresh
import kotlinx.android.synthetic.main.cp_activity_contract_entrust_new.*
import kotlinx.android.synthetic.main.cp_contract_common_entrust.*
import kotlinx.android.synthetic.main.cp_contract_common_entrust.ll_sel_ctrl
import kotlinx.android.synthetic.main.cp_contract_common_entrust.tv_coins_name
import kotlinx.android.synthetic.main.cp_fragment_cl_contract_hold.*
import kotlinx.android.synthetic.main.cp_fragment_cl_contract_hold.rv_hold_contract
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode
import org.json.JSONObject

/**
 *Current entrustment of the contract
 */
class CpContractEntrustNewFragment : CpNBaseFragment() {

    var adapter: CpContractEntrustNewAdapter? = null
    private var mList = ArrayList<CpCurrentOrderBean>()

    override fun setContentView(): Int {
        return R.layout.cp_contract_common_entrust
    }

    var mContractId = CpContractEntrustNewActivity.mContractId
    var mOrderType = 0
    var isCommonEntrust = true
    var isCurrentEntrust = true

    var isConditionOrder = false

    internal class PageInfo {
        var page = 1
        fun nextPage() {
            page++
        }

        fun reset() {
            page = 1
        }

        val isFirstPage: Boolean
            get() = page == 1
    }

    private val pageInfo = PageInfo()


    override fun initView() {
        val isCheckCurrentContract = CpPreferenceManager.getInstance(mActivity).getSharedBoolean(CpPreferenceManager.PREF_SHOW_CURRENT_CONTRACT_CurrentEntrust, false)
        if(isCheckCurrentContract){
            mContractId = CpContractEntrustNewActivity.mContractId
        }else{
            mContractId = -2
        }

        ll_sel_ctrl.visibility = View.GONE
        adapter = CpContractEntrustNewAdapter(this.requireActivity(), mList)
        rv_hold_contract.layoutManager = CpMyLinearLayoutManager(context)
        rv_hold_contract.adapter = adapter
        adapter?.setEmptyView(KKEmptyViewKit(context ?: return))
        adapter?.addChildClickViewIds(R.id.tv_cancel, R.id.tv_status_go)
        adapter?.setOnItemChildClickListener { adapter, view, position ->
            if (CpClickUtil.isFastDoubleClick()) return@setOnItemChildClickListener
            val item = adapter.data[position] as CpCurrentOrderBean
            if (view.id == R.id.tv_cancel) {
                AppAnalyticsExt.instance.clickAction(AppAnalyticsExt.APP_FUTURES_ORDERS_CANCEL)
                cancelOrder(item.contractId, if(isCommonEntrust) item.orderId!! else item.triggerOrderId!!, !isCommonEntrust)
            } else if (view.id == R.id.tv_status_go) {
                CpContractEntrustDetailActivity.show(mActivity!!, item)
            }
        }
        getOrderList()
        swipe_refresh?.setEnableLoadMore(false)
        swipe_refresh?.setOnRefreshListener {
            pageInfo.reset()
            getOrderList()
        }
        adapter?.loadMoreModule?.loadMoreView = ContractLoadMoreView()
        adapter?.loadMoreModule?.apply {
            setOnLoadMoreListener(object : OnLoadMoreListener {
                override fun onLoadMore() {
                    getOrderList()
                }
            })
            isAutoLoadMore = true
            isEnableLoadMoreIfNotFullPage = false
        }
    }

    private fun cancelOrder(mContractId: String, orderId: String, isConditionOrder: Boolean) {
        addDisposable(
                getContractModel().orderCancel(mContractId, orderId,
                        isConditionOrder,
                        consumer = object : CpNDisposableObserver(activity,true) {
                            override fun onResponseSuccess(jsonObject: JSONObject?) {
                                CpNToastUtil.showTopToast(false, CpLanguageUtil.getString(context,"cp_content_text3"))
                                pageInfo.reset()
                                getOrderList()
                                //Refresh activity is used to query the number of list items to determine whether all cancel buttons are displayed
                                val activity = mActivity as CpContractEntrustNewActivity
                                activity.getListToRightTv()
                            }
                        })
        )
    }


    @Subscribe(threadMode = ThreadMode.POSTING)
    override fun onMessageEvent(event: CpMessageEvent) {
        when (event.msg_type) {
            CpMessageEvent.sl_contract_record_switch_contract_event -> {
                mContractId = event.msg_content as Int

                val activity = activity as CpContractEntrustNewActivity
                CpContractEntrustNewActivity.mContractId = mContractId
                activity.tv_coins_name.text = if(mContractId==-2){
                    CpLanguageUtil.getString(mActivity,"OpenOrder_text1")
                }else{
                    CpClLogicContractSetting.getContractShowNameById(activity, mContractId)
                }
                pageInfo.reset()
                getOrderList()
            }
            CpMessageEvent.sl_contract_record_switch_entrust_type_event -> {
                val msg = event.msg_content
                if(msg is Boolean){
                    isCommonEntrust = event.msg_content as Boolean
                }else if(msg is Bundle){
                    isCommonEntrust = msg.getBoolean("isCommonEntrust")
                    mOrderType = msg.getInt("orderType")
                }

                pageInfo.reset()
                getOrderList()
            }
            CpMessageEvent.sl_contract_record_switch_order_type_event -> {
                mOrderType = event.msg_content as Int
                pageInfo.reset()
                getOrderList()
            }
            CpMessageEvent.sl_contract_record_switch_tab_event -> {
                isCurrentEntrust = (event.msg_content as Int==0)
                if (isCurrentEntrust){
                    pageInfo.reset()
                    getOrderList()
                }
            }
        }
    }

    private fun getOrderList() {
//        if (mContractId==-2){
//            swipe_refresh?.finishRefresh(true)
//            return
//        }
        getCurrentOrderList()
//        if (isCurrentEntrust) {
//            getCurrentOrderList()
//        } else {
//            getHistoryOrderList()
//        }
    }


    private fun getCurrentOrderList() {
        if (isCommonEntrust) {
            getCurrentCommonOrderList()
        } else {
            getCurrentPlanOrderList()
        }
    }

    private fun getHistoryOrderList() {
        if (isCommonEntrust) {
            getHistoryCommonOrderList()
        } else {
            getHistoryPlanOrderList()
        }
    }


    fun getCurrentCommonOrderList() {
        val cid = if(mContractId==-2) "" else mContractId
        addDisposable(
                getContractModel().getCurrentOrderList(cid.toString(),
                        mOrderType,
                        pageInfo.page,
                        consumer = object : CpNDisposableObserver(true) {
                            override fun onResponseSuccess(jsonObject: JSONObject?) {
                                val mListBuffer = ArrayList<CpCurrentOrderBean>()
                                swipe_refresh?.finishRefresh(true)
                                jsonObject?.optJSONObject("data")?.run {
                                    if (!isNull("orderList")) {
                                        val mOrderListJson = optJSONArray("orderList")
                                        for (i in 0..(mOrderListJson.length() - 1)) {
                                            var obj = mOrderListJson.getString(i)
                                            val mClCurrentOrderBean = Gson().fromJson<CpCurrentOrderBean>(
                                                    obj,
                                                    CpCurrentOrderBean::class.java
                                            )
                                            mClCurrentOrderBean.isPlan = false
                                            mClCurrentOrderBean.layoutType = 1
                                            mListBuffer.add(mClCurrentOrderBean)
                                        }
                                    }
                                }
                                if (pageInfo.isFirstPage) {
                                    adapter?.setList(mListBuffer)
                                } else {
                                    adapter?.addData(mListBuffer)
                                }
                                if (mListBuffer.size < 20) {
                                    adapter?.loadMoreModule?.loadMoreEnd()
                                } else {
                                    adapter?.loadMoreModule?.loadMoreComplete()
                                }
                                pageInfo.nextPage()
                                closeLoadingDialog()
                            }

                            override fun onError(e: Throwable) {
                                super.onError(e)
                                swipe_refresh?.finishRefresh(true)
                                closeLoadingDialog()
                            }

                            override fun onComplete() {
                                super.onComplete()
                                //Refresh Activity
                                val activity = requireActivity() as CpContractEntrustNewActivity
                                activity.getListToRightTv()
                            }
                        })
        )
    }

    fun getCurrentPlanOrderList() {
        val cid = if(mContractId==-2) "" else mContractId
        addDisposable(
                getContractModel().getCurrentPlanOrderList(cid.toString(),
                        mOrderType,
                        pageInfo.page,
                        consumer = object : CpNDisposableObserver(true) {
                            override fun onResponseSuccess(jsonObject: JSONObject?) {
                                val mListBuffer = ArrayList<CpCurrentOrderBean>()
                                swipe_refresh?.finishRefresh(true)
                                jsonObject?.optJSONObject("data")?.run {
                                    if (!isNull("trigOrderList")) {
                                        val mOrderListJson = optJSONArray("trigOrderList")
                                        for (i in 0..(mOrderListJson.length() - 1)) {
                                            var obj = mOrderListJson.getString(i)
                                            val mClCurrentOrderBean = Gson().fromJson<CpCurrentOrderBean>(
                                                    obj,
                                                    CpCurrentOrderBean::class.java
                                            )
                                            mClCurrentOrderBean.layoutType = 2
                                            mListBuffer.add(mClCurrentOrderBean)
                                        }
                                    }
                                }
                                if (pageInfo.isFirstPage) {
                                    adapter?.setList(mListBuffer)
                                } else {
                                    adapter?.addData(mListBuffer)
                                }
                                if (mListBuffer.size < 20) {
                                    adapter?.loadMoreModule?.loadMoreEnd()
                                } else {
                                    adapter?.loadMoreModule?.loadMoreComplete()
                                }
                                pageInfo.nextPage()
                                closeLoadingDialog()
                            }

                            override fun onError(e: Throwable) {
                                super.onError(e)
                                swipe_refresh?.finishRefresh(true)
                                closeLoadingDialog()
                            }
                            override fun onComplete() {
                                super.onComplete()
                                //Refresh Activity
                                val activity = requireActivity() as CpContractEntrustNewActivity
                                activity.getListToRightTv()
                            }
                        })
        )
    }

    private fun getHistoryCommonOrderList() {
        addDisposable(
                getContractModel().getHistoryOrderList(mContractId.toString(),
                        mOrderType,
                        pageInfo.page,
                        consumer = object : CpNDisposableObserver(true) {
                            override fun onResponseSuccess(jsonObject: JSONObject?) {
                                val mListBuffer = ArrayList<CpCurrentOrderBean>()
                                swipe_refresh?.finishRefresh(true)
                                jsonObject?.optJSONObject("data")?.run {
                                    if (!isNull("orderList")) {
                                        val mOrderListJson = optJSONArray("orderList")
                                        for (i in 0..(mOrderListJson.length() - 1)) {
                                            var obj = mOrderListJson.getString(i)
                                            val mClCurrentOrderBean = Gson().fromJson<CpCurrentOrderBean>(
                                                    obj,
                                                    CpCurrentOrderBean::class.java
                                            )
                                            mClCurrentOrderBean.layoutType = 3
                                            mClCurrentOrderBean.isPlan = false
                                            mListBuffer.add(mClCurrentOrderBean)
                                        }
                                    }
                                }
                                if (pageInfo.isFirstPage) {
                                    adapter?.setList(mListBuffer)
                                } else {
                                    adapter?.addData(mListBuffer)
                                }
                                if (mListBuffer.size < 20) {
                                    adapter?.loadMoreModule?.loadMoreEnd()
                                } else {
                                    adapter?.loadMoreModule?.loadMoreComplete()
                                }
                                pageInfo.nextPage()
                                closeLoadingDialog()
                            }

                            override fun onError(e: Throwable) {
                                super.onError(e)
                                swipe_refresh?.finishRefresh(true)

                                closeLoadingDialog()
                            }
                        })
        )
    }

    private fun getHistoryPlanOrderList() {
        addDisposable(
                getContractModel().getHistoryPlanOrderList(mContractId.toString(),
                        mOrderType,
                        pageInfo.page,
                        consumer = object : CpNDisposableObserver(true) {
                            override fun onResponseSuccess(jsonObject: JSONObject?) {
                                val mListBuffer = ArrayList<CpCurrentOrderBean>()
                                swipe_refresh?.finishRefresh(true)
                                jsonObject?.optJSONObject("data")?.run {
                                    if (!isNull("trigOrderList")) {
                                        val mOrderListJson = optJSONArray("trigOrderList")
                                        for (i in 0..(mOrderListJson.length() - 1)) {
                                            var obj = mOrderListJson.getString(i)
                                            val mClCurrentOrderBean = Gson().fromJson<CpCurrentOrderBean>(
                                                    obj,
                                                    CpCurrentOrderBean::class.java
                                            )
                                            mClCurrentOrderBean.layoutType = 4
                                            mClCurrentOrderBean.isPlan = true
                                            mListBuffer.add(mClCurrentOrderBean)
                                        }
                                    }
                                }
                                if (pageInfo.isFirstPage) {
                                    adapter?.setList(mListBuffer)
                                } else {
                                    adapter?.addData(mListBuffer)
                                }
                                if (mListBuffer.size < 20) {
                                    adapter?.loadMoreModule?.loadMoreEnd()
                                } else {
                                    adapter?.loadMoreModule?.loadMoreComplete()
                                }
                                pageInfo.nextPage()
                                closeLoadingDialog()
                            }

                            override fun onError(e: Throwable) {
                                super.onError(e)
                                swipe_refresh?.finishRefresh(true)

                                closeLoadingDialog()
                            }
                        })
        )
    }

    override fun onResume() {
        super.onResume()
        AppAnalyticsExt.instance.activityStart(AppAnalyticsExt.CONTRACT_APP_PAGE_9)
    }

    override fun onPause() {
        super.onPause()
        if(!this.isHidden()){
            AppAnalyticsExt.instance.activityStop(AppAnalyticsExt.CONTRACT_APP_PAGE_9)
        }
    }


}