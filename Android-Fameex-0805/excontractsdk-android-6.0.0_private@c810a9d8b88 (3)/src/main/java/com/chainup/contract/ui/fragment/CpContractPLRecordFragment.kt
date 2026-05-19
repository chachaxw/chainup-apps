package com.chainup.contract.ui.fragment

import android.view.View
import com.blankj.utilcode.util.LogUtils
import com.chad.library.adapter.base.listener.OnLoadMoreListener
import com.chainup.contract.R
import com.chainup.contract.base.CpNBaseFragment
import com.chainup.contract.bean.CpTabInfo
import com.chainup.contract.eventbus.CpMessageEvent
import com.chainup.contract.utils.CpClLogicContractSetting
import com.chainup.contract.view.*
import com.chainup.talkingdata.AppAnalyticsExt
import com.timmy.tdialog.TDialog
import com.yjkj.chainup.manager.CpLanguageUtil
import com.yjkj.chainup.net_new.rxjava.CpNDisposableObserver
import com.chainup.contract.ui.activity.CpContractEntrustNewActivity
import com.chainup.contract.utils.CpPreferenceManager
import com.chainup.contract.utils.getLineText
import com.chainup.contract.view.dialog.CpTDialog
import com.chainup.contract.view.trade.ContractLoadMoreView
import com.chainup.kit.views.KKEmptyViewKit
import com.yjkj.chainup.new_contract.adapter.CpContractHistoricalPositionAdapter
import kotlinx.android.synthetic.main.cp_activity_contract_entrust.swipe_refresh
import kotlinx.android.synthetic.main.cp_contract_common_entrust.*
import kotlinx.android.synthetic.main.cp_contract_common_entrust.ll_contract_direction
import kotlinx.android.synthetic.main.cp_contract_common_entrust.ll_sel_coins
import kotlinx.android.synthetic.main.cp_contract_common_entrust.tv_coins_name
import kotlinx.android.synthetic.main.cp_contract_common_entrust.tv_contract_direction
import kotlinx.android.synthetic.main.cp_fragment_cl_contract_hold.rv_hold_contract
import org.json.JSONObject

/**
 *Current entrustment of the contract
 */
class CpContractPLRecordFragment : CpNBaseFragment() {

    private var adapter: CpContractHistoricalPositionAdapter? = null
    private var mList = ArrayList<JSONObject>()

    //All directions/all types
    private var sideList = ArrayList<CpTabInfo>()
    private var mCurrSideInfo: CpTabInfo? = null

    override fun setContentView(): Int {
        return R.layout.cp_contract_common_entrust
    }

    var mContractId = CpContractEntrustNewActivity.mContractId
    var mOrderType = 0
    var mOrderSide = ""
    var isCommonEntrust = true
    var isCurrentEntrust = true

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
        val isCheckCurrentContract = CpPreferenceManager.getInstance(mActivity).getSharedBoolean(
            CpPreferenceManager.PREF_SHOW_CURRENT_CONTRACT_CurrentEntrust, false)
        if(isCheckCurrentContract){
            mContractId = CpContractEntrustNewActivity.mContractId
        }else{
            mContractId = -2
        }

        tv_contract_direction.text = getLineText("cp_order_text98")

        ll_sel_ctrl.visibility = View.VISIBLE
        tv_coins_name.text = CpClLogicContractSetting.getContractShowNameById(mActivity,mContractId)
        //Direction and type
        sideList.add(CpTabInfo(CpLanguageUtil.getString(mActivity,"cp_order_text98"), 0, ""))
        sideList.add(CpTabInfo(CpLanguageUtil.getString(mActivity,"cp_order_text6"), 1, "BUY"))
        sideList.add(CpTabInfo(CpLanguageUtil.getString(mActivity,"cp_order_text15"), 2, "SELL"))
        mCurrSideInfo = sideList[0]

        LogUtils.e("--------------------++++"+ CpContractEntrustNewActivity.mContractId)
        adapter = CpContractHistoricalPositionAdapter(mActivity!!, mList)
        rv_hold_contract.layoutManager = CpMyLinearLayoutManager(context)
        rv_hold_contract.adapter = adapter
        adapter?.setEmptyView(KKEmptyViewKit(context ?: return))
        adapter?.addChildClickViewIds(R.id.tv_settled_profit_loss_key)
        adapter?.setOnItemChildClickListener { adapter, view, position ->
            val obj: JSONObject = adapter?.getItem(position) as JSONObject
//            obj.put("marginCoin", CpClLogicContractSetting.getContractMarginCoinById(activity, mContractId))
//            obj.put("marginCoinPrecision", CpClLogicContractSetting.getContractMarginCoinPrecisionById(activity, mContractId))
//            obj.put("marginCoinPrecision", obj.optInt("pricePrecision"))
            obj?.let { activity?.let { it1 -> CpSlDialogHelper.showProfitLossDetailsDialog(it1, it,1) } }

        }
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

        //Select a contract currency pair
        ll_sel_coins.setOnClickListener {
            //New Version
            CpNewDialogUtils.createBottomSearchVpDialog(mActivity!!,
                mContractId,
                listener = object: CpNewDialogUtils.DialogOnSigningItemClickListener{
                    override fun clickItem(position: Int, text: String) {
                        //Here, EventBus: sl is sent internally_ contract_ record_ switch_ contract_ Event to the fg in the current vp
//                        changeContractId(position)
                    }
                },
                //Is it a PnL profit and loss record
                isHasAll = true
            )

        }


        //Select contract direction
        ll_contract_direction.setOnClickListener {
            var dialog: CpTDialog? = null
            dialog = CpNewDialogUtils.showNewBottomListDialog(
                mActivity!!,sideList,
                if(mCurrSideInfo==null) 0 else mCurrSideInfo!!.index,
                listener = object: CpNewDialogUtils.DialogOnItemClickListener{
                    override fun clickItem(position: Int) {
                        mCurrSideInfo = sideList[position]
                        mOrderSide = sideList[position].extras!!
                        tv_contract_direction.setText(mCurrSideInfo?.name)
                        pageInfo.reset()
                        getOrderList()
                        dialog?.dismiss()
                    }

                }
            )
        }

        //Initialize
        pageInfo.reset()
        getOrderList()
    }

    fun getOrderList() {
        LogUtils.e("--------------------"+mContractId)
        addDisposable(
                getContractModel().getHistoryPositionList(mContractId.toString(),
                        pageInfo.page.toString(),
                        mOrderSide,
                        consumer = object : CpNDisposableObserver(true) {
                            override fun onResponseSuccess(jsonObject: JSONObject?) {
                                val mListBuffer = ArrayList<JSONObject>()
                                swipe_refresh?.finishRefresh(true)
                                jsonObject?.optJSONObject("data")?.run {
                                    if (!isNull("positionList")) {
                                        val mOrderListJson = optJSONArray("positionList")
                                        for (i in 0..(mOrderListJson.length() - 1)) {
                                            var obj: JSONObject = mOrderListJson.get(i) as JSONObject
                                            var mMarginCoinPrecision = CpClLogicContractSetting.getContractMarginCoinPrecisionById(activity, obj.optInt("contractId"))
                                            var symbolName = CpClLogicContractSetting.getContractShowNameById(activity, obj.optInt("contractId"))
                                            obj.put("symbol", symbolName)
//                                            obj.put("marginCoinPrecision", obj.optInt("pricePrecision"))
                                            mListBuffer.add(obj)
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
        AppAnalyticsExt.instance.activityStart(AppAnalyticsExt.CONTRACT_APP_PAGE_2)
    }

    override fun onPause() {
        super.onPause()
        if(!this.isHidden()){
            AppAnalyticsExt.instance.activityStop(AppAnalyticsExt.CONTRACT_APP_PAGE_2)
        }
    }

    private fun changeContractId(cid:Int){
        mContractId = cid
        tv_coins_name.text = if(mContractId==-2){
            CpLanguageUtil.getString(mActivity,"OpenOrder_text1")
        }else{
            CpClLogicContractSetting.getContractShowNameById(mActivity, mContractId)
        }
        pageInfo.reset()
        getOrderList()
    }

    override fun onMessageEvent(event: CpMessageEvent) {
        super.onMessageEvent(event)
        when(event.msg_type){
            CpMessageEvent.sl_contract_record_switch_contract_event -> {
                val contractId = event.msg_content as Int
                changeContractId(contractId)
            }
        }
    }


}
