package com.chainup.contract.ui.fragment

import android.app.ActionBar.LayoutParams
import android.os.Bundle
import android.view.View
import android.widget.RelativeLayout
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.LinearLayoutManager
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.listener.OnItemChildClickListener
import com.chainup.contract.R
import com.chainup.contract.adapter.CpContractPublicListAdapter
import com.chainup.contract.base.CpNBaseFragment
import com.chainup.contract.bean.CpContractPublicInfoBean
import com.chainup.contract.eventbus.CpMessageEvent
import com.chainup.contract.net.CpJSONUtil
import com.chainup.contract.utils.CpDateUtils
import com.chainup.contract.utils.getLineText
import com.chainup.contract.utils.toDinproRegular
import com.chainup.kit.KKDialogUtils
import com.chainup.kit.utils.PublicSizeUtil
import com.chainup.kit.views.KKEmptyViewKit
import com.yjkj.chainup.manager.CpLanguageUtil
import com.yjkj.chainup.net_new.rxjava.CpNDisposableObserver
import kotlinx.android.synthetic.main.fragment_cp_contract_public.*
import org.jetbrains.anko.centerInParent
import org.jetbrains.anko.textColor
import org.json.JSONArray
import org.json.JSONObject

/**
 * Contract Public Page
 * PM link:https://7mpuwl.axshare.com/#id=stcive&p=%E6%9D%A0%E6%9D%86%E5%92%8C%E4%BF%9D%E8%AF%81%E9%87%91_1&g=1
 * UI link:https://www.figma.com/file/tvMwaHeS1lwOh3YYR4Robh/%E5%90%88%E7%BA%A6%E4%BA%A4%E6%98%93%E6%A8%A1%E5%9D%97?node-id=5984-73906&t=vOqvq1yJlXM0biDb-0
 * */
class CpContractPublicFragment : CpNBaseFragment(), OnItemChildClickListener {

    private var contractId:Int = -1
    private var adapter:CpContractPublicListAdapter? = null
    // footer view edit update time textView instance
    private var tvUpdateTime:TextView? = null
    override fun setContentView(): Int = R.layout.fragment_cp_contract_public

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        contractId = arguments?.getInt(ARG_PARAM1) ?: -1
    }

    override fun initView() {
        rvlist?.run {
            layoutManager = LinearLayoutManager(context,LinearLayoutManager.VERTICAL,false)
            this@CpContractPublicFragment.adapter = CpContractPublicListAdapter()
            adapter = this@CpContractPublicFragment.adapter
        }
        adapter?.run {
            initMarginCoin(contractId)
            val footerView = createFooterView()
            if(footerView!=null) setFooterView(footerView)
            setEmptyView(KKEmptyViewKit(context ?: return))
            setOnItemChildClickListener(this@CpContractPublicFragment)
//            initDataList()
        }
    }


    private fun initDataList() {
//        val dataString = getStaticData().toString()
//        handleData(dataString)
//        return
        addDisposable(getContractModel().getPublicContractInfo(contractId,object :CpNDisposableObserver(mActivity,true){
            override fun onResponseSuccess(jsonObject: JSONObject?) {
                jsonObject?.run {
                    val data = optJSONObject("data")
                    if(null == data){
                        adapter?.setList(null)
                    }else{
                        val dataString = data.toString()
                        handleData(dataString)
                    }
                }
            }

        }))
    }

    private fun handleData(dataString: String) {
        val result = CpJSONUtil.objectFromJson(dataString,CpContractPublicInfoBean::class.java)
        if(result.leverMarginInfo.isNotEmpty()){
            tvUpdateTime?.text = "${CpLanguageUtil.getString(context,"RulesLastUpdateT")} ${CpDateUtils.getYearMonthDayHourMinSecond(result.mTime.toLong())}（GMT+08:00）"
            adapter?.setList(result.leverMarginInfo)
        }else{
            adapter?.setList(null)
        }
    }

    companion object {
        const val ARG_PARAM1 = "contractId"

        @JvmStatic
        fun newInstance(contractId: Int) =
            CpContractPublicFragment().apply {
                arguments = Bundle().apply {
                    putInt(ARG_PARAM1, contractId)
                }
            }
    }

    override fun onMessageEvent(event: CpMessageEvent) {
        super.onMessageEvent(event)
        when(event.msg_type){
            CpMessageEvent.sl_contract_left_coin_type -> {
                contractId = event.msg_content as Int
                adapter?.initMarginCoin(contractId)
                initDataList()
            }
        }
    }

    private fun showTipDialog(title:String,content:String){
        KKDialogUtils.showCommonDialog(
            style = 2,
            isShowCancel = false,
            title = title,
            content = content,
            context = requireActivity(),
            listener = null,
            confrimTitle = getLineText("cp_extra_text28")
        )
    }


    private fun createFooterView(): View? {
        context?.run {
            val rl = RelativeLayout(this)
            val rlParams = RelativeLayout.LayoutParams(LayoutParams.MATCH_PARENT,LayoutParams.WRAP_CONTENT)
            rlParams.bottomMargin = PublicSizeUtil.dp2px(this@CpContractPublicFragment.context,22.0f) + PublicSizeUtil.getNavigationBarHeight(mActivity)
            rl.layoutParams = rlParams
                val tvLayout = TextView(this).let {
                    it.textSize = 12.0f
                    it.textColor = ContextCompat.getColor(this,R.color.text_color_2)
                    it.toDinproRegular()
                    it.text = CpLanguageUtil.getString(this,"RulesLastUpdateT")
                    val tvParams = RelativeLayout.LayoutParams(LayoutParams.WRAP_CONTENT,LayoutParams.WRAP_CONTENT)
                    tvParams.centerInParent()
                    it.layoutParams = tvParams
                    tvUpdateTime = it
                    it
                }
            rl.addView(tvLayout)
            return rl
        }
        return null
    }

    override fun onItemChildClick(adapter: BaseQuickAdapter<*, *>, view: View, position: Int) {
        val myAdapter = adapter as CpContractPublicListAdapter
        when(view.id){
            R.id.tv_position_hold -> {
                showTipDialog(String.format(getLineText("PositionBraket"),myAdapter.marginCoin),getLineText("PBtips"))
            }

            R.id.tv_lever_max -> {
                showTipDialog(getLineText("MaxLeverage"),getLineText("MLtips"))
            }

            R.id.tv_keep_margin_rate -> {
                showTipDialog(getLineText("MtncMgRt"),getLineText("MMRtips"))
            }
        }
    }

    override fun fragmentVisibile(isVisibleToUser: Boolean) {
        super.fragmentVisibile(isVisibleToUser)
        if(isVisibleToUser) initDataList()
    }

    @Deprecated("test")
    private fun getStaticData() : JSONObject{
        val jsonAry = JSONArray().apply{
            put(JSONObject().apply {
                put("level","2")
                put("minPositionValue","2")
                put("maxPositionValue","2")
                put("maxLever","2")
                put("minMarginRate","2")
            })
            put(JSONObject().apply {
                put("level","2")
                put("minPositionValue","2")
                put("maxPositionValue","2")
                put("maxLever","2")
                put("minMarginRate","2")
            })
        }
        return JSONObject().put("leverMarginInfo",jsonAry).put("mTime",System.currentTimeMillis().toString())
    }
}