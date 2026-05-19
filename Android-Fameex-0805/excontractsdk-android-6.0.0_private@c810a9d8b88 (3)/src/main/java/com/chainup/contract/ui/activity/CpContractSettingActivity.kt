package com.yjkj.chainup.new_contract.activity

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.core.content.ContextCompat
import com.chainup.contract.R
import com.chainup.contract.base.CpNBaseActivity
import com.chainup.contract.bean.CpTabInfo
import com.chainup.contract.eventbus.CpEventBusUtil
import com.chainup.contract.eventbus.CpMessageEvent
import com.chainup.contract.utils.CpClLogicContractSetting
import com.chainup.contract.utils.CpPreferenceManager
import com.chainup.contract.view.CpNewDialogUtils
import com.yjkj.chainup.manager.CpLanguageUtil
import com.yjkj.chainup.net_new.rxjava.CpNDisposableObserver
import kotlinx.android.synthetic.main.cp_activity_contract_setting.*
import org.json.JSONObject
import com.chainup.contract.view.CpDialogUtil
import com.chainup.contract.view.dialog.CpTDialog
import com.jaeger.library.StatusBarUtil

/**
 *Contract Settings
 */
class CpContractSettingActivity : CpNBaseActivity() {
    override fun setContentView(): Int {
        return R.layout.cp_activity_contract_setting
    }

    //Position mode
    private val positionModeList = ArrayList<CpTabInfo>()
    private var positionModeDialog: CpTDialog? = null


    //Position display unit
    private val unitList = ArrayList<CpTabInfo>()
    private var currUnitInfo: CpTabInfo? = null
    private var unitDialog: CpTDialog? = null
    private var originUnitIndex: Int? = 0

    //Unrealized profits and losses
    private val pnlList = ArrayList<CpTabInfo>()
    private var currPnlInfo: CpTabInfo? = null
    private var pnlDialog: CpTDialog? = null
    private var originPnlIndex: Int? = 0

    //Effective time
    private val timeList = ArrayList<CpTabInfo>()
    private var currTimeInfo: CpTabInfo? = null
    private var timeDialog: CpTDialog? = null

    //Trigger Type
    private val triggerList = ArrayList<CpTabInfo>()
    private var currTriggerInfo: CpTabInfo? = null
    private var triggerDialog: CpTDialog? = null
    private var originTriggerIndex: Int? = 0

    private var coUnit = 1
    private var positionModel = 1
    private var pcSecondConfirm = 1
    private var positionModelCanSwitch = -1
    private var expiredTime = 1
    private var priceBasis = 0

    //Place an order for secondary confirmation
    private var tradeConfirm = true

    private var contractId = 0

    private var openContract = 0

    //The currently stored chart position - 1 represents not being opened
    private var chartPosition:Int = -1

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        loadData()
        initView()
        initListener()
        loadContractUserConfig()
    }


    override fun loadData() {
        chartPosition = CpClLogicContractSetting.getContractChartPosition(this)

        positionModeList.add(CpTabInfo(CpLanguageUtil.getString(this,"cp_contract_setting_text15"), 0))
        positionModeList.add(CpTabInfo(CpLanguageUtil.getString(this,"cp_contract_setting_text16"), 1))

        unitList.add(CpTabInfo(CpLanguageUtil.getString(this,"cp_overview_text9"), 0))
        unitList.add(CpTabInfo(CpLanguageUtil.getString(this,"cp_extra_text82"), 1))
        currUnitInfo = findTabInfo(unitList, CpClLogicContractSetting.getContractUint(mActivity))
        originUnitIndex = currUnitInfo?.index

        pnlList.add(CpTabInfo(CpLanguageUtil.getString(this,"cp_extra_text83"), 0))
        pnlList.add(CpTabInfo(CpLanguageUtil.getString(this,"cp_order_text31"), 1))
        currPnlInfo = findTabInfo(pnlList, CpClLogicContractSetting.getPnlCalculate(mActivity))
        originPnlIndex = currPnlInfo?.index

        timeList.add(CpTabInfo(CpLanguageUtil.getString(this,"cp_extra_text88"), 0, "1"))
        timeList.add(CpTabInfo(CpLanguageUtil.getString(this,"cp_extra_text139"), 1, "7"))
        timeList.add(CpTabInfo(CpLanguageUtil.getString(this,"cp_extra_text140"), 2, "14"))
        timeList.add(CpTabInfo(CpLanguageUtil.getString(this,"cp_extra_text141"), 3, "30"))
        currTimeInfo = findTabInfo(timeList, CpClLogicContractSetting.getStrategyEffectTime(mActivity))

        triggerList.add(CpTabInfo(CpLanguageUtil.getString(this,"cp_order_text31"), 1))
        triggerList.add(CpTabInfo(CpLanguageUtil.getString(this,"cp_extra_text83"), 2))
        triggerList.add(CpTabInfo(CpLanguageUtil.getString(this,"cp_extra_text85"), 4))
        currTriggerInfo = findTabInfo(triggerList, CpClLogicContractSetting.getTriggerPriceType(mActivity))
        originTriggerIndex = currTriggerInfo?.index

        tradeConfirm = CpPreferenceManager.getInstance(mActivity).getSharedBoolean(
                CpPreferenceManager.PREF_TRADE_CONFIRM, true)

        contractId = intent.getIntExtra("contractId", 0)
        openContract = intent.getIntExtra("openContract", 0)

        positionModel = CpClLogicContractSetting.getPositionModel(mActivity)
        coUnit = CpClLogicContractSetting.getContractUint(mActivity)
        tv_position_mode_value.setText(if (positionModel == 1) CpLanguageUtil.getString(this,"cp_contract_setting_text15") else CpLanguageUtil.getString(this,"cp_contract_setting_text16"))
        tv_contracts_unit_value.setText(if (coUnit == 1) CpLanguageUtil.getString(this,"cp_extra_text82") else CpLanguageUtil.getString(this,"cp_overview_text9"))
    }

    override fun initView() {
        StatusBarUtil.setColor(this,ContextCompat.getColor(this,R.color.bg_card_color),0)
        initAutoTextView()
        tv_contracts_unit_value.text = currUnitInfo?.name
        tv_pnl_calculator_value.text = currPnlInfo?.name
        tv_effective_time_value.text = currTimeInfo?.name
        tv_trigger_type_value.text = currTriggerInfo?.name


        //0 Off 1 On
        val contractChartOff = CpClLogicContractSetting.getContractChartOff(this)
        if(contractChartOff==1){
            setChartLabel(chartPosition)
        }

    }

    private fun initAutoTextView() {

        tv_position_mode_label.setText(CpLanguageUtil.getString(this,"cp_contract_setting_text14"))
        tv_contracts_unit_label.setText(CpLanguageUtil.getString(this,"cp_extra_text86"))
        tv_plan_settings_label.setText(CpLanguageUtil.getString(this,"cp_tip_text26"))
        tv_pnl_calculator_label.setText(CpLanguageUtil.getString(this,"cp_extra_text87"))
        tv_book_confirm_label.setText(CpLanguageUtil.getString(this,"cp_contract_setting_text19"))
        tv_effective_time_label.setText(CpLanguageUtil.getString(this,"cp_contract_setting_text21"))
        trade_area_label.setText(CpLanguageUtil.getString(this,"cp_trading_area_chart_title"))
//        tv_plan_settings_label.onLineText("sl_str_plan_settings")
    }

    private fun initListener() {
        rl_position_mode_layout.setOnClickListener {

            if (positionModelCanSwitch == -1) {
                //At this time, select through local configuration
                positionModeDialog = CpNewDialogUtils.showNewBottomListDialog(mActivity, positionModeList, if (positionModel == 1) 0 else 1, object : CpNewDialogUtils.DialogOnItemClickListener {
                    override fun clickItem(index: Int) {
                        currTriggerInfo = positionModeList[index]
                        positionModeDialog?.dismiss()
                        positionModel = if (index == 0) 1 else 2
                        tv_position_mode_value.setText(currTriggerInfo?.name)
                        CpClLogicContractSetting.setPositionModel(mActivity, positionModel)
                        CpEventBusUtil.post(
                                CpMessageEvent(
                                        CpMessageEvent.sl_contract_change_position_model_event
                                )
                        )
                        modifyTransactionLike()
                    }
                })
            } else {
                if (positionModelCanSwitch == 0) {
                    CpDialogUtil.showNewsingleDialog2(this!!, CpLanguageUtil.getString(this,"cp_contract_setting_text7"), object : CpNewDialogUtils.DialogBottomListener {
                        override fun sendConfirm() {

                        }
                    }, cancelTitle = CpLanguageUtil.getString(this, "cp_extra_text28"))
                    return@setOnClickListener
                }
                positionModeDialog = CpNewDialogUtils.showNewBottomListDialog(mActivity, positionModeList, if (positionModel == 1) 0 else 1, object : CpNewDialogUtils.DialogOnItemClickListener {
                    override fun clickItem(index: Int) {
                        currTriggerInfo = triggerList[index]
                        positionModeDialog?.dismiss()
                        positionModel = if (index == 0) 1 else 2
                        CpClLogicContractSetting.setPositionModel(mActivity, positionModel)
                        CpEventBusUtil.post(
                                CpMessageEvent(
                                        CpMessageEvent.sl_contract_change_position_model_event
                                )
                        )
                        modifyTransactionLike()
                    }
                })
            }


        }


        //Trigger Type
        rl_trigger_type_layout.setOnClickListener {
            triggerDialog = CpNewDialogUtils.showNewBottomListDialog(mActivity, triggerList, currTriggerInfo!!.index, object : CpNewDialogUtils.DialogOnItemClickListener {
                override fun clickItem(index: Int) {
                    currTriggerInfo = triggerList[index]
                    triggerDialog?.dismiss()
                    tv_trigger_type_value.text = currTriggerInfo?.name
                    CpClLogicContractSetting.setTriggerPriceType(mActivity, currTriggerInfo!!.index)
                }
            })
        }
        //Effective time
        rl_effective_time_layout.setOnClickListener {
            timeDialog = CpNewDialogUtils.showNewBottomListDialog(mActivity, timeList, currTimeInfo!!.index, object : CpNewDialogUtils.DialogOnItemClickListener {
                override fun clickItem(index: Int) {
                    currTimeInfo = timeList[index]
                    timeDialog?.dismiss()
                    tv_effective_time_value.text = currTimeInfo?.name
                    expiredTime=currTimeInfo!!.extras!!.toInt()
                    CpClLogicContractSetting.setStrategyEffectTime(mActivity, currTimeInfo!!.index)
                    CpClLogicContractSetting.setStrategyEffectTimeStr(mActivity, currTimeInfo!!.extras!!.toInt())
                    modifyTransactionLike()
                }
            })
        }
        //Position display unit
        rl_display_unit_layout.setOnClickListener {
            if (positionModelCanSwitch == -1) {
                //At this time, select through local configuration
                unitDialog = CpNewDialogUtils.showNewBottomListDialog(mActivity, unitList, currUnitInfo!!.index, object : CpNewDialogUtils.DialogOnItemClickListener {
                    override fun clickItem(index: Int) {
                        currUnitInfo = unitList[index]
                        unitDialog?.dismiss()
//                    tv_contracts_unit_value.text = currUnitInfo?.name
                        coUnit = if (index == 0) 2 else 1
                        tv_contracts_unit_value.setText(currUnitInfo!!.name)
                        CpClLogicContractSetting.setContractUint(mActivity, currUnitInfo!!.index)
                        CpEventBusUtil.post(
                                CpMessageEvent(
                                        CpMessageEvent.sl_contract_change_unit_event
                                )
                        )
                    }
                })
            } else {
                unitDialog = CpNewDialogUtils.showNewBottomListDialog(mActivity, unitList, currUnitInfo!!.index, object : CpNewDialogUtils.DialogOnItemClickListener {
                    override fun clickItem(index: Int) {
                        currUnitInfo = unitList[index]
                        unitDialog?.dismiss()
//                    tv_contracts_unit_value.text = currUnitInfo?.name
                        CpClLogicContractSetting.setContractUint(mActivity, currUnitInfo!!.index)
                        coUnit = if (index == 0) 2 else 1
                        CpEventBusUtil.post(
                                CpMessageEvent(
                                        CpMessageEvent.sl_contract_change_unit_event
                                )
                        )
                        modifyTransactionLike()
                    }
                })
            }

        }
        //Unrealized profit and loss tv_ price_ hint
        rl_pnl_calculator_layout.setOnClickListener {
            pnlDialog = CpNewDialogUtils.showNewBottomListDialog(mActivity, pnlList, currPnlInfo!!.index, object : CpNewDialogUtils.DialogOnItemClickListener {
                override fun clickItem(index: Int) {
                    currPnlInfo = pnlList[index]
                    pnlDialog?.dismiss()
                    tv_pnl_calculator_value.text = currPnlInfo?.name
                    CpClLogicContractSetting.setPnlCalculate(mActivity, currPnlInfo!!.index)
                }
            })
        }
        //Place an order for secondary confirmation
        switch_book_again.isChecked = tradeConfirm
        switch_book_again.setOnCheckedChangeListener { _, isChecked ->
            CpPreferenceManager.getInstance(mActivity).putSharedBoolean(
                    CpPreferenceManager.PREF_TRADE_CONFIRM, isChecked)
            switch_book_again.isChecked = isChecked
            setViewSelect(switch_book_again, isChecked)
        }
        setViewSelect(switch_book_again, tradeConfirm)

        //Transaction Area Chart Settings
        trade_area_layout.setOnClickListener {

            CpNewDialogUtils.createContractTradingAreaSettingDialog(this,chartPosition?:0,listener = object:CpNewDialogUtils.DialogOnItemClickListener{
                override fun clickItem(position: Int) {
                    setChartLabel(position)

                    CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.sl_contract_trade_chart_kline_config_update).apply {
                        msg_content = position
                    })
                }

            })

        }

    }

    //Set chart label
    private fun setChartLabel(position:Int){
        chartPosition = position
//      0 top 1 bottom
        when(position){
//          0 top
            0 -> {
                trade_area_value.text = CpLanguageUtil.getString(this@CpContractSettingActivity,"cp_set_1")
            }
//          1 bottom
            1 -> {
                trade_area_value.text = CpLanguageUtil.getString(this@CpContractSettingActivity,"cp_set_2")
            }
            //The representative didn't open it
            -1 -> {
                trade_area_value.text =CpLanguageUtil.getString(this@CpContractSettingActivity,"cp_set_3")
            }
        }
    }


    fun setViewSelect(view: View, status: Boolean) {
//        if (status) {
//            view.setBackgroundResource(R.drawable.ic_public_native_switch_open)
//        } else {
//            view.setBackgroundResource(R.mipmap.ic_public_native_switch_close)
//        }
    }

    private fun loadContractUserConfig() {
        if (!CpClLogicContractSetting.isLogin()) return
        if (openContract == 0) return
        addDisposable(getContractModel().getUserConfig(contractId.toString(),
                consumer = object : CpNDisposableObserver(true) {
                    override fun onResponseSuccess(jsonObject: JSONObject?) {
                        jsonObject?.optJSONObject("data")?.run {
                            coUnit = optInt("coUnit")//Contract unit 1 target currency, 2 sheets
                            positionModel = optInt("positionModel")//Position Type 1 Position, 2 Bidirectional Position
                            pcSecondConfirm = optInt("pcSecondConfirm")//Popup confirmation switch before placing an order, 0 used, 1 disabled
                            positionModelCanSwitch = optInt("positionModelCanSwitch")//Can the current position type be switched? 0 cannot be switched, 1 can be switched
                            expiredTime = optInt("expireTime")//Unit: Day (fixed enumeration) 1, 7, 14, 30
                            priceBasis = optInt("priceBasis")

                            currTimeInfo = findTabInfoByExpiredTime(timeList,expiredTime.toString())
                            tv_position_mode_value.setText(if (positionModel == 1) CpLanguageUtil.getString(this@CpContractSettingActivity ,"cp_contract_setting_text15") else CpLanguageUtil.getString(this@CpContractSettingActivity,"cp_contract_setting_text16"))
                            tv_contracts_unit_value.setText(if (coUnit == 1) CpLanguageUtil.getString(this@CpContractSettingActivity,"cp_extra_text82") else CpLanguageUtil.getString(this@CpContractSettingActivity,"cp_overview_text9"))
                            tv_effective_time_value.setText(currTimeInfo?.name)
                        }
                    }
                }))
    }

    private fun modifyTransactionLike() {
        addDisposable(getContractModel().modifyTransactionLike(
                contractId.toString(),
                positionModel.toString(),
                pcSecondConfirm.toString(),
                coUnit.toString(),
                expiredTime.toString(),
                priceBasis.toString(),
                consumer = object : CpNDisposableObserver(true) {
                    override fun onResponseSuccess(jsonObject: JSONObject?) {
                        loadContractUserConfig()
                    }
                }))
    }


    override fun finish() {
        super.finish()
        if (currUnitInfo?.index != originUnitIndex || originTriggerIndex != currTriggerInfo?.index || currPnlInfo?.index != originPnlIndex) {
            CpClLogicContractSetting.getInstance().refresh()
        }
    }

    companion object {
        fun show(activity: Activity, contractId: Int, openContract: Int) {
            val intent = Intent(activity, CpContractSettingActivity::class.java)
            intent.putExtra("contractId", contractId)
            intent.putExtra("openContract", openContract)
            activity.startActivity(intent)
        }
    }

    private fun findTabInfo(list: ArrayList<CpTabInfo>, index: Int = 0): CpTabInfo {
        for (i in list.indices) {
            if (list[i].index == index) {
                return list[i]
            }
        }
        return list[0]
    }


    private fun findTabInfoByExpiredTime(list: ArrayList<CpTabInfo>, value:String): CpTabInfo{
        for (i in list.indices) {
            if (list[i].extras == value) {
                return list[i]
            }
        }
        return list[0]
    }
}
