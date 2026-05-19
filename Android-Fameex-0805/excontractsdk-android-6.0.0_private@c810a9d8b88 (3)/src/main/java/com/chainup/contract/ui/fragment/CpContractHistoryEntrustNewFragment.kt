package com.chainup.contract.ui.fragment

import android.os.Bundle
import android.text.SpannableString
import android.text.SpannableStringBuilder
import android.text.TextPaint
import android.text.TextUtils
import android.text.style.ClickableSpan
import android.text.style.ForegroundColorSpan
import android.view.Gravity
import android.view.View
import androidx.core.content.ContextCompat
import com.chad.library.adapter.base.listener.OnLoadMoreListener
import com.chainup.contract.R
import com.chainup.contract.app.CpAppConfig
import com.chainup.contract.base.CpNBaseFragment
import com.chainup.contract.eventbus.CpMessageEvent
import com.chainup.contract.view.CpMyLinearLayoutManager
import com.chainup.contract.view.CpNewDialogUtils
import com.chainup.talkingdata.AppAnalyticsExt
import com.google.gson.Gson
import com.yjkj.chainup.manager.CpLanguageUtil
import com.yjkj.chainup.net_new.rxjava.CpNDisposableObserver
import com.yjkj.chainup.new_contract.activity.CpContractEntrustDetailActivity
import com.chainup.contract.ui.activity.CpContractEntrustNewActivity
import com.chainup.contract.ui.activity.CpWebViewActivity
import com.chainup.contract.utils.*
import com.chainup.contract.view.dialog.CpTDialog
import com.chainup.contract.view.trade.ContractLoadMoreView
import com.chainup.kit.KKDialogUtils
import com.chainup.kit.views.KKEmptyViewKit
import com.yjkj.chainup.new_contract.adapter.CpContractEntrustNewAdapter
import com.yjkj.chainup.new_contract.bean.CpCurrentOrderBean
import kotlinx.android.synthetic.main.cp_activity_contract_entrust.swipe_refresh
import kotlinx.android.synthetic.main.cp_contract_common_entrust.*
import kotlinx.android.synthetic.main.cp_fragment_cl_contract_hold.rv_hold_contract
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode
import org.json.JSONObject

/**
 *Contract historical entrustment
 */
class CpContractHistoryEntrustNewFragment : CpNBaseFragment() {

    private var adapter: CpContractEntrustNewAdapter? = null
    private var mList = ArrayList<CpCurrentOrderBean>()
    private var mAdlDialog:CpTDialog? = null
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
        adapter = CpContractEntrustNewAdapter(requireActivity(), mList)
        rv_hold_contract.layoutManager = CpMyLinearLayoutManager(context)
        rv_hold_contract.adapter = adapter
        adapter?.setEmptyView(KKEmptyViewKit(context ?: return))
        adapter?.addChildClickViewIds(R.id.tv_status_go, R.id.tv_liquidation)
        adapter?.setOnItemChildClickListener { adapter, view, position ->
            if (CpClickUtil.isFastDoubleClick()) return@setOnItemChildClickListener
            val item = adapter.data[position] as CpCurrentOrderBean
            if (view.id == R.id.tv_status_go) {
                CpContractEntrustDetailActivity.show(mActivity!!, item)
            }else if (view.id == R.id.tv_liquidation) {
                if("11".equals(item.source)){
                    val normalText = CpLanguageUtil.getString(mActivity,"cp_order_adl2")
                    val linkText = CpLanguageUtil.getString(mActivity,"cp_adl_introduce")
                    val spannableStringBuilder = SpannableStringBuilder()
                    spannableStringBuilder.append(normalText)
                    spannableStringBuilder.append(" ")
                    spannableStringBuilder.append(linkText)
                    spannableStringBuilder.setSpan(ForegroundColorSpan(ContextCompat.getColor(mActivity!!,R.color.main_color)),normalText.length+1,(normalText.length+1+linkText.length),SpannableString.SPAN_EXCLUSIVE_EXCLUSIVE)
                    spannableStringBuilder.setSpan(object :ClickableSpan(){
                        override fun onClick(widget: View) {
                            val uri = if(CpSystemUtils.isZh()){
                                CpAppConfig.adl_uri_zh
                            }else{
                                CpAppConfig.adl_uri_en
                            }
                            CpWebViewActivity.enterActivity(requireActivity(), uri)
                            mAdlDialog?.dismiss()
                        }
                    },normalText.length+1,(normalText.length+1+linkText.length),SpannableString.SPAN_EXCLUSIVE_EXCLUSIVE)
                    mAdlDialog = CpNewDialogUtils.showDialogNew(
                        mActivity!!,
                        spannableStringBuilder,
                        true,
                        null,
                        CpLanguageUtil.getString(context,"cp_order_adl1"),
                        CpLanguageUtil.getString(context,"cp_extra_text28"),
                        contentGravity = Gravity.LEFT
                    )
                    return@setOnItemChildClickListener
                }
//                if (!item.source.equals("6")){
//                    return@setOnItemChildClickListener
//                }
//                val timeLong = item.liqPositionMsgTimeStamp
//                if (timeLong.isNotEmpty()){
//                    var tip = item.liqPositionMsg
//                    if (TextUtils.isEmpty(tip)){
//                        tip=""
//                    }
//                    tip= CpStringUtil.liqPositionTime(tip,timeLong);
//                    CpNewDialogUtils.showDialogNew(
//                        mActivity!!,
//                        tip,
//                        true,
//                        null,
//                        CpLanguageUtil.getString(context,"cp_extra_text80"),
//                        CpLanguageUtil.getString(context,"cp_extra_text28"),
//                        contentGravity = Gravity.LEFT
//                    )
//                }
            }else if(view.id == R.id.tv_price_title && "6".equals(item.source)){

                KKDialogUtils.showCommonDialog(
                    mActivity!!,
                    title = CpLanguageUtil.getString(context,"order_history_bankr_price"),
                    listener = null,
                    confrimTitle = CpLanguageUtil.getString(context,"guide_3"),
                    isShowCancel = false,
                    style = 1
                )
            }else if(view.id == R.id.tv_liq_price_title && "6".equals(item.source)){
                KKDialogUtils.showCommonDialog(
                    mActivity!!,
                    title = CpLanguageUtil.getString(context,"order_history_liq_price"),
                    listener = null,
                    confrimTitle = CpLanguageUtil.getString(context,"guide_3"),
                    isShowCancel = false,
                    style = 1
                )
            }
        }
        adapter?.setOnItemClickListener { adapter, view, position ->
            if (CpClickUtil.isFastDoubleClick()) return@setOnItemClickListener
            val item = adapter.data[position] as CpCurrentOrderBean
            if (isCommonEntrust){
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



    @Subscribe(threadMode = ThreadMode.POSTING)
    override fun onMessageEvent(event: CpMessageEvent) {
        when (event.msg_type) {
            CpMessageEvent.sl_contract_record_switch_contract_event -> {
                mContractId = event.msg_content as Int
                val activity = activity as CpContractEntrustNewActivity
                CpContractEntrustNewActivity.mContractId = mContractId
                activity.tv_coins_name.text = CpClLogicContractSetting.getContractShowNameById(activity, mContractId)
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
              if (event.msg_content as Int ==1){
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
        getHistoryOrderList()
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
        addDisposable(
                getContractModel().getCurrentOrderList(mContractId.toString(),
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
                        })
        )
    }

    fun getCurrentPlanOrderList() {
        addDisposable(
                getContractModel().getCurrentPlanOrderList(mContractId.toString(),
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
                        })
        )
    }

    private fun getHistoryCommonOrderList() {
        val cid = if(mContractId==-2) "" else mContractId
        addDisposable(
                getContractModel().getHistoryOrderList(cid.toString(),
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
                        }, isV6 = 1)
        )
    }

    private fun getHistoryPlanOrderList() {
        val cid = if(mContractId==-2) "" else mContractId
        addDisposable(
                getContractModel().getHistoryPlanOrderList(cid.toString(),
                        mOrderType,
                        pageInfo.page,
                        consumer = object : CpNDisposableObserver(
                                true) {
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
        AppAnalyticsExt.instance.activityStart(AppAnalyticsExt.CONTRACT_APP_PAGE_10)
        swipe_refresh?.finishRefresh(true)
    }

    override fun onPause() {
        super.onPause()
        if(!this.isHidden()){
            AppAnalyticsExt.instance.activityStop(AppAnalyticsExt.CONTRACT_APP_PAGE_10)
        }
    }


}
