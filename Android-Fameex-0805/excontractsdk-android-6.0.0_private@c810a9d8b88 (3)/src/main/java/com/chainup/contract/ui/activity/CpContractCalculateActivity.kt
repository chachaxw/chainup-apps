package com.yjkj.chainup.new_contract.activity

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.viewpager.widget.ViewPager
import com.chainup.contract.R
import com.chainup.contract.base.CpNBaseActivity
import com.chainup.contract.bean.CpTabInfo
import com.chainup.contract.eventbus.CpEventBusUtil
import com.chainup.contract.eventbus.CpMessageEvent
import com.chainup.contract.net.CpJSONUtil
import com.chainup.contract.ui.activity.CpContractEntrustNewActivity
import com.chainup.contract.ui.fragment.CpContractCoinSearchDialog
import com.chainup.contract.utils.CpClLogicContractSetting
import com.chainup.contract.utils.CpJsonUtils
import com.chainup.contract.utils.toDinproMedium
import com.chainup.kit.KKDialogUtils
import com.chainup.kit.bean.KKItemTabInfo
import com.chainup.kit.views.PublicHeaderKit
import com.jaeger.library.StatusBarUtil
import com.yjkj.chainup.manager.CpLanguageUtil
import com.yjkj.chainup.new_contract.fragment.CpLiquidationPriceFragment
import com.yjkj.chainup.new_contract.fragment.CpPlCalculatorFragment
import com.yjkj.chainup.new_contract.fragment.CpProfitRateFragment
import kotlinx.android.synthetic.main.cp_activity_contract_calculate.ll_position
import kotlinx.android.synthetic.main.cp_activity_contract_calculate.mHeaderKit
import kotlinx.android.synthetic.main.cp_activity_contract_calculate.sub_tab_layout
import kotlinx.android.synthetic.main.cp_activity_contract_calculate.tv_position
import kotlinx.android.synthetic.main.cp_activity_contract_calculate.vp_order
import org.json.JSONArray
import org.json.JSONObject

/**
 *Contract Calculator
 */
class CpContractCalculateActivity : CpNBaseActivity() {
    override fun setContentView(): Int {
        return R.layout.cp_activity_contract_calculate
    }
    //The currently selected currency pair
    private var mCurrContractInfo: CpTabInfo? = null
    private var contractId = 0
    var accountList:ArrayList<JSONObject> = arrayListOf()
    private var mFragments: ArrayList<Fragment>? = null
    private val positionTypeList by lazy {
        arrayListOf(
            KKItemTabInfo(CpLanguageUtil.getString(this, "cp_contract_setting_text1"),1),//Cross
            KKItemTabInfo(CpLanguageUtil.getString(this, "cp_contract_setting_text2"), 0)//Isolated
        )
    }
    var currentPositionType:Int = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        StatusBarUtil.setColor(this,ContextCompat.getColor(this,R.color.bg_card_color),0)
        val bundle = intent.getBundleExtra("data")
        bundle?.let {
            contractId = it.getInt("contractId", 0)
            val accountListStr = it.getString("accountList")
            if(!"".equals(accountListStr)){
                accountList = CpJSONUtil.arrayToList(JSONArray(accountListStr))
            }
        }

        initView()
    }

    fun getCanUseAmount(marginCoin:String):String{
        if(accountList.size<=0 || "".equals(marginCoin)) return "0"

        for(item in accountList){
            if(marginCoin.equals(item.optString("symbol"))){
                return item.optString("canUseAmount")
            }
        }
        return "0"
    }

    override fun initView() {
        initTabInfo()
        tv_position.text = positionTypeList[1].name
        ll_position.visibility = View.GONE
        ll_position.setOnClickListener {
            KKDialogUtils.showBottomSheetList(this,positionTypeList,currentPositionType,
                CpLanguageUtil.getString(this,"cp_overview_text56"),
                object : KKDialogUtils.DialogOnItemClickListener {
                    override fun clickItem(position: Int) {
                        val selectInfo = positionTypeList[position]
                        this@CpContractCalculateActivity.currentPositionType = selectInfo.index!!

                        val cpLiquidationPriceFragment = mFragments?.get(1) as? CpLiquidationPriceFragment
                        cpLiquidationPriceFragment?.run {
                            changePositionType(this@CpContractCalculateActivity.currentPositionType)
                        }
                        tv_position.text = selectInfo.name
                    }
                }
            )
        }
        vp_order?.addOnPageChangeListener(object: ViewPager.OnPageChangeListener {
            override fun onPageScrolled(
                position: Int,
                positionOffset: Float,
                positionOffsetPixels: Int
            ) {

            }

            override fun onPageSelected(position: Int) {
                if(position==1){
                    ll_position.visibility = View.VISIBLE
                }else{
                    ll_position.visibility = View.GONE
                }
            }

            override fun onPageScrollStateChanged(state: Int) {

            }

        })

        mHeaderKit?.run {
            val selectName = CpClLogicContractSetting.getContractShowNameById(mActivity, contractId)
            setFilterTitleContent(selectName)

            listener = object : PublicHeaderKit.IOnBackClickListener{
                override fun onFilterTitle(view: View) {
                    super.onFilterTitle(view)

                    var mContractCoinSearchDialog = CpContractCoinSearchDialog()
                    var bundle = Bundle()
                    bundle.putString(
                        "contractList",
                        CpClLogicContractSetting.getContractJsonListStr(mActivity)
                    )
                    mContractCoinSearchDialog.arguments = bundle
                    mContractCoinSearchDialog.showDialog(supportFragmentManager, "SlContractFragment")

                    //New Version
//                    CpNewDialogUtils.createBottomSearchVpDialog(this@CpContractCalculateActivity, contractId,
//                        listener = object: CpNewDialogUtils.DialogOnSigningItemClickListener{
//                            override fun clickItem(position: Int, text: String) {
////EventBus: sl is sent internally here_ contract_ record_ switch_ contract_ Event to the fg in the current vp
//                                mCurrContractInfo = CpTabInfo(text,position)
//
//                                CpContractEntrustNewActivity.mContractId = position
//                                contractId = position
//
//                                mHeaderKit.setFilterTitleContent(text)
//
//                                val event = CpMessageEvent(CpMessageEvent.sl_contract_calc_switch_contract_event)
//                                event.msg_content = CpContractEntrustNewActivity.mContractId
//                                CpEventBusUtil.post(event)
//                            }
//                        }
//                    )
                }
            }

        }
    }

    private fun initTabInfo() {
        mFragments = ArrayList()
        mFragments?.add(CpPlCalculatorFragment.newInstance(contractId))
        mFragments?.add(CpLiquidationPriceFragment.newInstance(contractId))
        mFragments?.add(CpProfitRateFragment.newInstance(contractId))
        sub_tab_layout.setViewPager(vp_order, arrayOf(CpLanguageUtil.getString(this,"cp_calculator_text2"), CpLanguageUtil.getString(this,"cp_calculator_text4"),CpLanguageUtil.getString(this,"cp_calculator_text9") ), this, mFragments)
        for(i in 0 until sub_tab_layout.tabCount){
            sub_tab_layout.getTitleView(i).toDinproMedium()
        }
    }


    companion object {
        fun show(activity: Activity, contractId: Int,accountList:String) {
            val intent = Intent(activity, CpContractCalculateActivity::class.java)
            val bundle = Bundle()
            bundle.putInt("contractId",contractId)
            bundle.putString("accountList",accountList)
            intent.putExtra("data",bundle)
            activity.startActivity(intent)
        }
    }

    override fun onMessageEvent(event: CpMessageEvent) {
        super.onMessageEvent(event)
        when(event.msg_type){
            CpMessageEvent.sl_contract_left_coin_type -> {
                contractId = event.msg_content as Int

                val ctName = CpClLogicContractSetting.getContractShowNameById(this,contractId)
                mCurrContractInfo = CpTabInfo(ctName,contractId)
                CpContractEntrustNewActivity.mContractId = contractId
                mHeaderKit.setFilterTitleContent(ctName)

                val event = CpMessageEvent(CpMessageEvent.sl_contract_calc_switch_contract_event)
                event.msg_content = CpContractEntrustNewActivity.mContractId
                CpEventBusUtil.post(event)
            }
        }
    }

}
