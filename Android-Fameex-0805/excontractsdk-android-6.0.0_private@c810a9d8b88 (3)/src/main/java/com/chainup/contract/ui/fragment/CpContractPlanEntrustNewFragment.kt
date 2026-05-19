package com.chainup.contract.ui.fragment

import android.app.ActionBar
import android.view.Gravity
import android.view.View
import android.widget.TextView
import androidx.core.content.ContextCompat
import com.chainup.contract.R
import com.chainup.contract.base.CpNBaseFragment
import com.chainup.contract.eventbus.CpEventBusUtil
import com.chainup.contract.eventbus.CpMessageEvent
import com.chainup.contract.utils.*
import com.chainup.contract.utils.CpClLogicContractSetting
import com.chainup.contract.utils.CpNToastUtil
import com.chainup.contract.view.CpEmptyForAdapterView
import com.chainup.contract.view.CpEmptyOrderForAdapterView
import com.chainup.contract.view.CpMyLinearLayoutManager
import com.chainup.contract.view.CpNewDialogUtils
import com.chainup.kit.views.KKEmptyViewKit
import com.google.gson.Gson
import com.yjkj.chainup.manager.CpLanguageUtil
import com.yjkj.chainup.net_new.rxjava.CpNDisposableObserver
import com.yjkj.chainup.new_contract.adapter.CpContractPlanEntrustNewAdapter
import com.yjkj.chainup.new_contract.bean.CpCurrentOrderBean
import kotlinx.android.synthetic.main.cp_fragment_cl_contract_hold.*
import kotlinx.android.synthetic.main.cp_header_tradelist.*
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode
import org.jetbrains.anko.textColor
import org.json.JSONObject


class CpContractPlanEntrustNewFragment : CpNBaseFragment(),View.OnClickListener {

    private var adapter: CpContractPlanEntrustNewAdapter? = null
    private var mList = ArrayList<CpCurrentOrderBean>()
    var mContractId = -1

    var isCurrentContract:Boolean? = null
        get() {
            return if(field==null){
                val isSelect = CpPreferenceManager.getInstance(mActivity).getSharedBoolean(
                    CpPreferenceManager.PREF_SHOW_CURRENT_CONTRACT_PlanEntrust, false)
                isSelect
            }else{
                field
            }
        }

    override fun setContentView(): Int {
        return R.layout.cp_fragment_cl_contract_hold
    }

    override fun initView() {
        tv_onekey_close_title.text = CpLanguageUtil.getString(requireContext(),"cl_close_1")
        tv_onekey_close.text = CpLanguageUtil.getString(mActivity,"cp_order_text52")
        if(!CpClLogicContractSetting.isLogin()) tv_onekey_close.visibility = View.GONE
        adapter = CpContractPlanEntrustNewAdapter(requireActivity(),mList)
        rv_hold_contract.layoutManager = CpMyLinearLayoutManager(context)
        rv_hold_contract.adapter = adapter
        adapter?.setEmptyView(KKEmptyViewKit(context ?: return).apply {
            setImageViewTop(32.0f)
        })
        adapter?.addChildClickViewIds(R.id.tv_cancel)
        adapter?.setOnItemChildClickListener { adapter, view, position ->
            val item = adapter.data[position] as CpCurrentOrderBean
            cancelOrder(item.contractId, item.triggerOrderId!!, true)
        }
        switch_contract_type.setImageResource(if (isCurrentContract!!) R.drawable.trade_switch_open else R.mipmap.trade_switch_close)
        //Full withdrawal
        tv_onekey_close.setOnClickListener(this)
        switch_contract_type.setOnClickListener(this)
        tv_onekey_close_title.setOnClickListener(this)
    }

    private fun createFooterView():View {
        val tv = TextView(context).apply {
            width = ActionBar.LayoutParams.MATCH_PARENT
            height = CpSizeUtils.dp2px(76.0f)
            gravity =  Gravity.CENTER
            text = getLineText("orderlist_text1")
            textColor = ContextCompat.getColor(requireContext(),R.color.text_color_2)
            textSize = 12.0f
            toDinproMedium()
        }
        return tv
    }

    private fun cancelOrder(mContractId: String, orderId: String, isConditionOrder: Boolean) {
        addDisposable(
                getContractModel().orderCancel(mContractId, orderId,
                        isConditionOrder,
                        consumer = object : CpNDisposableObserver(activity,true) {
                            override fun onResponseSuccess(jsonObject: JSONObject?) {
                                CpNToastUtil.showTopToast(false, CpLanguageUtil.getString(context,"cp_content_text3"))
                                CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.sl_contract_refresh_assets_position_event))
                                CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.sl_contract_req_plan_entrust_list_event))
                            }
                        })
        )
    }

    @Subscribe(threadMode = ThreadMode.POSTING)
    override fun onMessageEvent(event: CpMessageEvent) {
        when (event.msg_type) {
            CpMessageEvent.sl_contract_refresh_plan_entrust_list_event -> {
                if (!CpClLogicContractSetting.isLogin()) return
                val mPositionObj = event.msg_content as JSONObject
                val mListBuffer = ArrayList<CpCurrentOrderBean>()
                mPositionObj.run {
                    if (!isNull("trigOrderList")) {
                        val mOrderListJson = optJSONArray("trigOrderList")
                        for (i in 0..(mOrderListJson.length() - 1)) {
                            var obj = mOrderListJson.getString(i)
                            val mClCurrentOrderBean =
                                    Gson().fromJson<CpCurrentOrderBean>(
                                            obj,
                                            CpCurrentOrderBean::class.java
                                    )
                            mClCurrentOrderBean.isPlan = true
                            mListBuffer.add(mClCurrentOrderBean)
                        }
                    }
                    tv_onekey_close.visibility = if(mListBuffer.size==0) View.GONE else View.VISIBLE
                    adapter?.let {
                        if(!isNull("count")){
                            val count = optInt("count",0)
                            if(count > 100){
                                val fview = createFooterView()
                                it.setFooterView(fview)
                            }else{
                                if(it.hasFooterLayout()) it.removeAllFooterView()
                            }
                        }
                        it.setList(mListBuffer)
                    }
                }
            }
            CpMessageEvent.sl_contract_logout_event->{
                mList.clear()
                adapter?.notifyDataSetChanged()
            }
        }
    }

    private fun switchCurrentContractOff(){
        isCurrentContract = !isCurrentContract!!
        CpPreferenceManager.getInstance(mActivity).putSharedBoolean(CpPreferenceManager.PREF_SHOW_CURRENT_CONTRACT_PlanEntrust,isCurrentContract!!)
        switch_contract_type.setImageResource(if (isCurrentContract!!) R.drawable.trade_switch_open else R.mipmap.trade_switch_close)
    }

    override fun onClick(v: View?) {
        when(v?.id){
            R.id.tv_onekey_close -> {
                CpNewDialogUtils.showDialogNew(
                    requireContext(),
                    CpLanguageUtil.getString(mActivity,"cp_overview_text58"),
                    false,
                    object : CpNewDialogUtils.DialogBottomListener {
                        override fun sendConfirm() {
                            cancelOrder(if(isCurrentContract==true) mContractId.toString() else "", "", true)
                        }
                    },
                    cancelTitle = CpLanguageUtil.getString(mActivity,"cp_overview_text56"),
                    confrimTitle = CpLanguageUtil.getString(mActivity,"cp_calculator_text16"),
                    contentGravity = Gravity.CENTER
                )
            }
            R.id.switch_contract_type,R.id.tv_onekey_close_title -> {
                switchCurrentContractOff()
                CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.sl_contract_req_plan_entrust_list_event))
            }
        }
    }


}
