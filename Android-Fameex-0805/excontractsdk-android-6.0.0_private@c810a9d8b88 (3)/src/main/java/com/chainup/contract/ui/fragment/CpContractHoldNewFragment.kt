package com.chainup.contract.ui.fragment

import android.Manifest
import android.content.DialogInterface
import android.content.Intent
import android.database.Observable
import android.graphics.Bitmap
import android.os.Build
import android.os.Bundle
import android.text.TextUtils
import android.text.TextWatcher
import android.util.Log
import android.view.View
import android.widget.*
import androidx.core.content.ContextCompat
import com.blankj.utilcode.util.LogUtils
import com.chainup.contract.R
import com.chainup.contract.app.CpMyApp
import com.chainup.contract.base.CpNBaseFragment
import com.chainup.contract.eventbus.CpEventBusUtil
import com.chainup.contract.eventbus.CpMessageEvent
import com.chainup.contract.listener.CpDoListener
import com.chainup.contract.utils.*
import com.chainup.contract.view.*
import com.chainup.contract.view.trade.SelectRatioView
import com.chainup.talkingdata.AppAnalyticsExt
import com.coorchice.library.SuperTextView
import com.flyco.tablayout.CommonTabLayout
import com.flyco.tablayout.listener.CustomTabEntity
import com.flyco.tablayout.listener.OnTabSelectListener
import com.google.gson.Gson
import com.tbruyelle.rxpermissions2.RxPermissions
import com.timmy.tdialog.base.BindViewHolder
import com.timmy.tdialog.listener.OnBindViewListener
import com.yjkj.chainup.manager.CpLanguageUtil
import com.yjkj.chainup.net_new.rxjava.CpNDisposableObserver
import com.yjkj.chainup.new_contract.activity.CpContractStopRateLossActivity
import com.yjkj.chainup.new_contract.adapter.CpHoldContractNewAdapter
import com.yjkj.chainup.new_contract.bean.CpContractPositionBean
import kotlinx.android.synthetic.main.cp_fragment_cl_contract_hold_tx.*
import kotlinx.android.synthetic.main.cp_item_close_position_new_dialog.*
import kotlinx.android.synthetic.main.cp_item_kline_target_more.view.*
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode
import org.jetbrains.anko.textColor
import org.json.JSONArray
import org.json.JSONObject
import com.chainup.contract.view.dialog.CpTDialog
import com.chainup.contract.view.dialog.base.CpBindViewHolder
import com.chainup.contract.view.dialog.listener.OnCpBindViewListener
import kotlinx.android.synthetic.main.cp_header_tradelist.*
import com.chainup.kit.KKDialogUtils
import com.chainup.kit.views.KKEmptyViewKit
import kotlinx.android.synthetic.main.cp_guide_layout_toast.content

class CpContractHoldNewFragment : CpNBaseFragment() {

    private var adapter: CpHoldContractNewAdapter? = null
    private var mList = ArrayList<CpContractPositionBean>()
    private var mContractId:Int = 0

    //Whether closing position dialogue is in progress
    private var isClosePosition = false
    private var isQkClosePosition = false

    private var closeOrderSide:String? = null

    private var mShareDialog:CpTDialog? = null


    override fun setContentView(): Int {
        return R.layout.cp_fragment_cl_contract_hold_tx
    }

    var mAdjustRoiDialog: CpTDialog? = null
    var mAdjustMarginDialog: CpTDialog? = null
    var mQuickClosePositionDialog: CpTDialog? = null
    var mClosePositionDialog: CpTDialog? = null
    var mPositionObj: JSONObject? = null
    lateinit var mPriceListObj: JSONArray
    var priceBasis = 0 //0Latest price1 Tag price
    var mBindViewHolder: CpBindViewHolder? = null
    var mCurrentClickId: Int? = -1

    override fun initView() {

        tv_onekey_close_title.setText(CpLanguageUtil.getString(requireContext(),"cl_close_1"))
        tv_onekey_close.setText(CpLanguageUtil.getString(requireContext(),"cl_close_2"))
        mContractId= arguments?.getInt("contractId")!!
        LogUtils.e("mContractId:"+mContractId)
        adapter = CpHoldContractNewAdapter(mList)
        if(!CpClLogicContractSetting.isLogin()) tv_onekey_close.visibility = View.GONE
        adapter?.setViewVisible(tv_onekey_close)
        rv_hold_contract.layoutManager = CpMyLinearLayoutManager(context)
        rv_hold_contract.adapter = adapter
        adapter?.setEmptyView(KKEmptyViewKit(context ?: return).apply {
            setImageViewTop(32.0f)
        })
        adapter?.addChildClickViewIds(R.id.tv_quick_close_position, R.id.tv_close_position, R.id.tv_forced_close_price_key, R.id.tv_adjust_margins, R.id.tv_floating_gains_balance_key, R.id.tv_profit_loss, R.id.iv_share, R.id.tv_tag_price, R.id.tv_settled_profit_loss_key,R.id.ll_adl)
        adapter?.setOnItemChildClickListener { adapter, view, position ->
            if (CpClickUtil.isFastDoubleClick()) return@setOnItemChildClickListener
            val clickData = adapter.data[position] as CpContractPositionBean
            mCurrentClickId=clickData.id
            when (view.id) {
                R.id.ll_adl -> {
                    KKDialogUtils.showCommonDialog(
                        mActivity!!,
                        title=CpLanguageUtil.getString(mActivity,"cp_adl_title"),
                        style = 2,
                        isShowCancel = false,
                        confrimTitle = CpLanguageUtil.getString(mActivity,"cp_extra_text28"),
                        listener = null,
                        content = CpLanguageUtil.getString(mActivity,"cp_adl_content"),
                    )
                }
                R.id.tv_close_position -> {
                    isClosePosition = true
//                    AppAnalyticsExt.instance.clickAction(AppAnalyticsExt.CONTRACT_APP_ACTION_11)
                    AppAnalyticsExt.instance.clickAction(AppAnalyticsExt.APP_FUTURES_POSITIONS_CLOSE)
                    mClosePositionDialog = CpDialogUtil.showClosePositionDialog(this.requireActivity(), OnCpBindViewListener {
                        mBindViewHolder=it
                        closeOrderSide = clickData.orderSide
                        val mSelectRatioView = it.getView<SelectRatioView>(R.id.mSelectRatioView)
                        val btn_close_position = it.getView<CpCommonlyUsedButton>(R.id.btn_close_position)

                        it.setText(R.id.tv_title, CpLanguageUtil.getString(context, "cp_order_text17"))
                        it.setText(R.id.tv_cancel, CpLanguageUtil.getString(context, "cp_overview_text56"))
                        it.setText(R.id.tv_price_label, CpLanguageUtil.getString(context, "cp_overview_text6"))
                        it.setText(R.id.tv_quantity_label, CpLanguageUtil.getString(context, "cp_order_text43"))
                        it.setText(R.id.tv_can_use_title,CpLanguageUtil.getString(context, "cp_can_be_reduced"))
                        it.setText(R.id.tv_estimated_pl_title,CpLanguageUtil.getString(context, "cp_expected_profit_and_loss_simple"))

                        it.setText(R.id.tv_type, if (clickData.orderSide.equals("BUY")) CpLanguageUtil.getString(context, "cp_order_text6") else CpLanguageUtil.getString(context, "cp_order_text15"))
                        it.setTextColor(R.id.tv_type, CpColorUtil.getMainColorType(clickData.orderSide.equals("BUY")))
                        val superTagView = it.getView<SuperTextView>(R.id.tv_type)
                        superTagView.solid = CpColorUtil.getMinorColorType(clickData.orderSide.equals("BUY"))
                        it.setText(R.id.tv_contract_name, CpClLogicContractSetting.getContractShowNameById(context, clickData.contractId))
                        it.setText(R.id.tv_level_value, (if (clickData.positionType == 1) CpLanguageUtil.getString(context, "cp_contract_setting_text1") else CpLanguageUtil.getString(context, "cp_contract_setting_text2")) + " " + clickData.leverageLevel + "X")
                        it.setText(R.id.tv_price_unit, CpClLogicContractSetting.getContractQuoteById(activity, clickData.contractId))
                        val volumeUnit = if (CpClLogicContractSetting.getContractUint(context) == 0) CpLanguageUtil.getString(context, "cp_overview_text9") else CpClLogicContractSetting.getContractMultiplierCoinById(activity, clickData.contractId)
                        it.setText(R.id.tv_volume_unit, volumeUnit)

                        if (CpClLogicContractSetting.getContractUint(context) == 0) {
                            it.setText(R.id.et_volume, clickData.canCloseVolume)
                            it.setText(R.id.tv_can_use_value, "${clickData.canCloseVolume} $volumeUnit")
                        } else {
                          val canCloseVolumeBuff=  CpBigDecimalUtils.mulStr(
                                clickData.canCloseVolume,
                                CpClLogicContractSetting.getContractMultiplierById(activity, clickData.contractId),
                                CpClLogicContractSetting.getContractMultiplierPrecisionById(activity, clickData.contractId)
                            )
                            it.setText(R.id.et_volume, canCloseVolumeBuff)
                            it.setText(R.id.tv_can_use_value, "$canCloseVolumeBuff $volumeUnit")
                        }
                        var showPrice:String

                        getObjFromPriceListById(mCurrentClickId!!){ priceObj, positionObj ->
                            val mPricePrecision = CpClLogicContractSetting.getContractSymbolPricePrecisionById(requireContext(),clickData.contractId)
                            showPrice = CpBigDecimalUtils.showSNormal(priceObj.getString("lastPrice"), mPricePrecision)
                            it.setText(R.id.et_price,showPrice)
                        }

                        var checkedIdBuff = 0
                        val rg_order_type = it.getView<RadioGroup>(R.id.rg_order_type)
                        val rb_1 = it.getView<RadioButton>(R.id.rb_1)
                        val rb_2 = it.getView<RadioButton>(R.id.rb_2)
                        val rb_3 = it.getView<RadioButton>(R.id.rb_3)
                        rb_1.setText(CpLanguageUtil.getString(context, "cp_overview_text53"))
                        rb_2.setText(CpLanguageUtil.getString(context, "cp_order_text44"))
                        rb_3.setText(CpLanguageUtil.getString(context, "cp_order_text45"))
                        val etPrice = it.getView<EditText>(R.id.et_price)
                        val tvEstimatedPlTitle = it.getView<TextView>(R.id.tv_estimated_pl_title)
                        val etVolume = it.getView<EditText>(R.id.et_volume)
                        etVolume.setHint(CpLanguageUtil.getString(context, "cp_order_text43"))
                        val llPrice = it.getView<LinearLayout>(R.id.ll_price)

                        val quantityLayout = it.getView<LinearLayout>(R.id.trade_quantity)
                        val tvOrderTips = it.getView<SuperTextView>(R.id.tv_order_tips_layout)
                        val multiplierPrecision = CpClLogicContractSetting.getContractMultiplierPrecisionById(activity, clickData.contractId)

                        //Input listening
                        etVolume.numberFilter(if (CpClLogicContractSetting.getContractUint(context) == 0) 0 else multiplierPrecision, otherFilter = object : CpDoListener {
                            override fun doThing(obj: Any?): Boolean {
                                checkCloseEtValue(etPrice,etVolume,checkedIdBuff,btn_close_position)
                                return true
                            }
                        })
                        val mPricePrecision = CpClLogicContractSetting.getContractSymbolPricePrecisionById(requireContext(),clickData.contractId)
                        //Input listening
                        etPrice?.numberFilter(decimal = mPricePrecision,otherFilter = object : CpDoListener{
                            override fun doThing(obj: Any?): Boolean {
                                checkCloseEtValue(etPrice,etVolume,checkedIdBuff,btn_close_position)

                                return true
                            }

                        })

                        etPrice?.setOnFocusChangeListener { _, hasFocus ->
                            llPrice?.setBackgroundResource(if (hasFocus) R.drawable.bg_selected_contract else R.drawable.bg_select_contract)
                        }

                        for (buff in 0..rg_order_type?.childCount?.toInt()!! - 1) {
                            rg_order_type.getChildAt(buff).setOnClickListener {

                                for (itemChild in 0..rg_order_type?.childCount?.toInt()!! - 1){
                                    val currentView = rg_order_type.getChildAt(itemChild) as RadioButton
                                    currentView.textColor = ContextCompat.getColor(requireActivity(),R.color.text_color_2)
                                }

                                val cView = it as RadioButton
                                when (it.id) {
                                    R.id.rb_1 -> {
                                        tvOrderTips.setText(CpLanguageUtil.getString(context, "cp_overview_text53"))
                                        tvOrderTips.visibility = View.VISIBLE
                                        llPrice.visibility = View.GONE
                                        if (checkedIdBuff == it.id) {
                                            checkedIdBuff = -1

                                            rg_order_type.clearCheck()
                                            tvOrderTips.visibility = View.GONE
                                            llPrice.visibility = View.VISIBLE
                                            cView.textColor = ContextCompat.getColor(requireActivity(),R.color.text_color_2)
                                        } else {
                                            checkedIdBuff = it.id
                                            rg_order_type.check(it.id)
                                            cView.textColor = ContextCompat.getColor(requireActivity(),R.color.text_color_1)
                                        }
                                        AppAnalyticsExt.instance.clickAction(AppAnalyticsExt.CONTRACT_APP_ACTION_12)
                                    }
                                    R.id.rb_2 -> {
                                        tvOrderTips.setText(CpLanguageUtil.getString(context, "cp_order_text44"))
                                        tvOrderTips.visibility = View.VISIBLE
                                        llPrice.visibility = View.GONE
                                        if (checkedIdBuff == it.id) {
                                            checkedIdBuff = -1

                                            rg_order_type.clearCheck()
                                            tvOrderTips.visibility = View.GONE
                                            llPrice.visibility = View.VISIBLE
                                            cView.textColor = ContextCompat.getColor(requireActivity(),R.color.text_color_2)
                                        } else {
                                            checkedIdBuff = it.id
                                            rg_order_type.check(it.id)
                                            cView.textColor = ContextCompat.getColor(requireActivity(),R.color.text_color_1)
                                        }
                                        AppAnalyticsExt.instance.clickAction(AppAnalyticsExt.CONTRACT_APP_ACTION_14)
                                    }
                                    R.id.rb_3 -> {
                                        tvOrderTips.setText(CpLanguageUtil.getString(context, "cp_order_text45"))
                                        tvOrderTips.visibility = View.VISIBLE
                                        llPrice.visibility = View.GONE
                                        if (checkedIdBuff == it.id) {
                                            checkedIdBuff = -1

                                            rg_order_type.clearCheck()
                                            tvOrderTips.visibility = View.GONE
                                            llPrice.visibility = View.VISIBLE
                                            cView.textColor = ContextCompat.getColor(requireActivity(),R.color.text_color_2)
                                        } else {
                                            checkedIdBuff = it.id
                                            rg_order_type.check(it.id)
                                            cView.textColor = ContextCompat.getColor(requireActivity(),R.color.text_color_1)
                                        }
                                        AppAnalyticsExt.instance.clickAction(AppAnalyticsExt.CONTRACT_APP_ACTION_13)
                                    }
                                }
                            }
                        }

                        val ratios = arrayOf(0.25f,0.50f,0.75f,1.00f)
                        var selectPosition = -1
                        mSelectRatioView.setRadios(
                            ratios,
                            callback = { value,position,view ->
                                CpSoftKeyboardUtil.hideSoftKeyboard(mActivity)
                                if(position==-1){
                                    it.setText(R.id.et_volume, "")
                                    etVolume.clearFocus()
                                    return@setRadios
                                }
                                selectPosition = position
                                etVolume.clearFocus()
                                val scale = if (CpClLogicContractSetting.getContractUint(CpMyApp.instance()) == 0) 0 else multiplierPrecision
                                val mCanCloseVolumeStr = if (CpClLogicContractSetting.getContractUint(CpMyApp.instance()) == 0) {
                                    clickData?.canCloseVolume.toString()
                                } else {
                                    CpBigDecimalUtils.mulStr(clickData?.canCloseVolume, CpClLogicContractSetting.getContractMultiplierById(activity, clickData.contractId), multiplierPrecision)
                                }

                                it.setText(R.id.et_volume, CpBigDecimalUtils.mulStrRoundUp(mCanCloseVolumeStr, ratios[position].toString(), scale))

                            },
                            initSelectPosition = ratios.size-1
                        )

                        etVolume?.setOnFocusChangeListener { _, hasFocus ->
//                            CpSoftKeyboardUtil.showORhideSoftKeyboard(activity)
                            if (hasFocus) {
                                mSelectRatioView.resetViewColor()
                                etVolume.setText("")
                                selectPosition = -1
                            }
                            quantityLayout?.setBackgroundResource(if (hasFocus) R.drawable.bg_selected_contract else R.drawable.bg_select_contract)
                        }
                        etPrice.setOnClickListener {
                            it.setFocusable(true);
                            it.setFocusableInTouchMode(true);
                            it.requestFocus();
                            it.findFocus();
                            rg_order_type.clearCheck()
                        }
                        tvEstimatedPlTitle.setOnClickListener {
                            CpNewDialogUtils.showDialogNew(
                                this.requireActivity(),
                                content = CpLanguageUtil.getString(mActivity!!,"cp_contract_close_expected_profit_and_loss_msg"),
                                true,
                                title = CpLanguageUtil.getString(mActivity!!,"cp_expected_profit_and_loss"),
                                cancelTitle = CpLanguageUtil.getString(context, "cp_extra_text28"),
                                listener = null
                            )
                        }
                        checkCloseEtValue(etPrice,etVolume,checkedIdBuff,btn_close_position)
                        btn_close_position.setContent(CpLanguageUtil.getString(context, "cp_content_text28"))
                        btn_close_position.listener = object : CpCommonlyUsedButton.OnBottonListener {
                            override fun bottonOnClick() {
                                var priceStr = etPrice.text.toString().trim()
                                val inputVolume = etVolume.text.toString().trim()
                                var volStr = inputVolume
                                val multiplier = CpClLogicContractSetting.getContractMultiplierById(activity, clickData.contractId)
                                volStr = CpBigDecimalUtils.getOrderNum(false, volStr, multiplier, 1)
                                var type = 1
                                var priceType = ""
                                if (rb_1.isChecked) {
                                    type = 2
                                    priceStr = ""
                                    showPrice = CpLanguageUtil.getString(context, "cp_overview_text53")
                                } else if (rb_2.isChecked) {
                                    priceType = "1"
                                    priceStr = "0"
                                    showPrice = CpLanguageUtil.getString(context, "cp_order_text44")
                                } else if (rb_3.isChecked) {
                                    priceType = "0"
                                    priceStr = "0"
                                    showPrice = CpLanguageUtil.getString(context, "cp_order_text45")
                                } else {
                                    showPrice = priceStr + " " + CpClLogicContractSetting.getContractQuoteById(activity, clickData.contractId)
                                }
                                if(selectPosition!=-1){
                                    volStr = CpBigDecimalUtils.mulStrRoundUp(clickData.canCloseVolume, ratios[selectPosition].toString(), 0)
                                }

                                if (type == 1 && TextUtils.isEmpty(priceType)) {
                                    if (TextUtils.isEmpty(priceStr)) {
                                        mClosePositionDialog?.dismiss()
                                        CpNToastUtil.showTopToastNet(getActivity(), false, CpLanguageUtil.getString(context, "cp_extra_text33"))
                                        return
                                    }
                                }
                                if (TextUtils.isEmpty(volStr)) {
                                    mClosePositionDialog?.dismiss()
                                    CpNToastUtil.showTopToastNet(getActivity(), false, CpLanguageUtil.getString(context, "cp_extra_text34"))
                                    return
                                }

                                val contractJsonObj = CpClLogicContractSetting.getContractJsonStrById(mActivity,mContractId)
                                val coinResultVo = JSONObject(contractJsonObj.optString("coinResultVo"))
                                val minOrderVolume = coinResultVo.optString("minOrderVolume")//Minimum order quantity
                                val minMessage:String = if(CpClLogicContractSetting.getContractUint(mActivity) == 0) {
                                    minOrderVolume + " " + CpLanguageUtil.getString(context, "cp_overview_text9")
                                }else{
                                    CpBigDecimalUtils.mulStr(minOrderVolume,multiplier,multiplierPrecision) + " " + volumeUnit
                                }

                                if(CpBigDecimalUtils.orderNumMinCheck(inputVolume,minOrderVolume,multiplier)){
                                    CpNToastUtil.showTopToastNet(
                                        mActivity, false,
                                        "${CpLanguageUtil.getString(context, "order_placement_text7")} $minMessage"
                                    )
                                    return
                                }
                                //contract_demand https://jira.dw2nn.com/browse/BIGFUTURES-2530
                                Log.d(TAG,"close position volume = $volStr")
                                if(CpBigDecimalUtils.compareTo(volStr,clickData.canCloseVolume) == 1){
                                    Log.d(TAG,"close position canCloseVolume = ${clickData.canCloseVolume}")
                                    CpNToastUtil.showTopToastNet(mActivity, false,
                                        CpLanguageUtil.getString(context, "order_placement_text9")
                                    )
                                    return
                                }

                                var dialogTitle = ""
//                                if (type==1){
//                                    dialogTitle= CpLanguageUtil.getString(this,.string.contract_action_limitPrice).toString()
//                                }else{
//                                    dialogTitle= CpLanguageUtil.getString(this,"cp_overview_text53").toString()
//                                }
                                val titleColor = if (clickData.orderSide.equals("BUY")) {
                                    dialogTitle = dialogTitle + CpLanguageUtil.getString(context, "cp_extra_text5")

                                    CpColorUtil.getMainColorType(false)
                                } else {
                                    dialogTitle = dialogTitle + CpLanguageUtil.getString(context, "cp_extra_text4")
                                    CpColorUtil.getMainColorType(true)
                                }
                                val showTag = when (clickData.positionType) {
                                    1 -> {
                                        CpLanguageUtil.getString(context, "cp_contract_setting_text1") + " " + clickData.leverageLevel.toString() + "X"
                                    }
                                    2 -> {
                                        CpLanguageUtil.getString(context, "cp_contract_setting_text2") + " " + clickData.leverageLevel.toString() + "X"
                                    }
                                    else -> {
                                        ""
                                    }
                                }
                                context?.let { it1 ->
                                    val tradeConfirm = CpPreferenceManager.getInstance(CpMyApp.instance())
                                            .getSharedBoolean(CpPreferenceManager.PREF_TRADE_CONFIRM, true)
                                    if (tradeConfirm) {
                                        CpDialogUtil.showCloseOrderDialog(it1,
                                                titleColor,
                                                dialogTitle,
                                                CpClLogicContractSetting.getContractShowNameById(context, clickData.contractId),
                                                showPrice,
                                                "",
                                                "",
                                                etVolume.text.toString() + " " + volumeUnit,
                                                type,
                                                "",
                                                "",
                                                showTag,
                                                object : CpNewDialogUtils.DialogBottomListener {
                                                    override fun sendConfirm() {
                                                        closePosition(clickData, type, priceType, priceStr, volStr)
                                                    }
                                                })
                                    } else {
                                        closePosition(clickData, type, priceType, priceStr, volStr)
                                    }
                                }
//                                closePosition(clickData, type, priceType, priceStr, volStr)
                                mClosePositionDialog?.dismiss()
                            }
                        }
                    }){
                        isClosePosition = false
                        closeOrderSide = null
                    }
                }

                //---闪电平仓----
                R.id.tv_quick_close_position -> {
                    isQkClosePosition = true
                    mQuickClosePositionDialog = CpDialogUtil.showQuickClosePositionDialog(this.requireActivity(), OnCpBindViewListener {

                        mBindViewHolder=it
                        closeOrderSide = clickData.orderSide
                        it.setText(R.id.tv_title, CpLanguageUtil.getString(context, "cp_order_text18"))
                        it.setText(R.id.tv_cancel, CpLanguageUtil.getString(context, "cp_overview_text56"))
                        it.setText(R.id.tv_cp_order_text42, CpLanguageUtil.getString(context, "cp_order_text42"))
                        it.setText(R.id.tv_cp_order_text49, CpLanguageUtil.getString(context, "cp_order_text49"))
                        it.setText(R.id.tv_order_tips_layout, CpLanguageUtil.getString(context, "cp_order_text48"))
                        it.setText(R.id.tv_cp_order_text43, CpLanguageUtil.getString(context, "cp_order_text43"))
                        it.setText(R.id.tv_estimated_pl_title,CpLanguageUtil.getString(context,"cp_expected_profit_and_loss_simple"))
                        val tvEstimatedPlTitle = it.getView<TextView>(R.id.tv_estimated_pl_title)
                        it.setText(R.id.tv_type, if (clickData.orderSide.equals("BUY")) CpLanguageUtil.getString(context, "cp_order_text6") else CpLanguageUtil.getString(context, "cp_order_text15"))
                        it.setTextColor(R.id.tv_type, CpColorUtil.getMainColorType(clickData.orderSide.equals("BUY")))
                        val superTagView = it.getView<SuperTextView>(R.id.tv_type)
                        superTagView.solid = CpColorUtil.getMinorColorType(clickData.orderSide.equals("BUY"))
                        it.setText(R.id.tv_contract_name, CpClLogicContractSetting.getContractShowNameById(context, clickData.contractId))
                        it.setText(R.id.tv_level_value, (if (clickData.positionType == 1) CpLanguageUtil.getString(context, "cp_contract_setting_text1") else CpLanguageUtil.getString(context, "cp_contract_setting_text2")) + " " + clickData.leverageLevel + "X")
                        val unit = if (CpClLogicContractSetting.getContractUint(context) == 0) CpLanguageUtil.getString(context, "cp_overview_text9") else CpClLogicContractSetting.getContractMultiplierCoinById(activity, clickData.contractId)
                        if (CpClLogicContractSetting.getContractUint(context) == 0) {
                            it.setText(R.id.tv_position_amount, CpLanguageUtil.getString(context, "cp_order_text50") + "：" + clickData.positionVolume +" "+ unit)
                        } else {
                            it.setText(R.id.tv_position_amount, CpLanguageUtil.getString(context, "cp_order_text50") + "：" + CpBigDecimalUtils.mulStr(
                                    clickData.positionVolume,
                                    CpClLogicContractSetting.getContractMultiplierById(activity, clickData.contractId),
                                    CpClLogicContractSetting.getContractMultiplierPrecisionById(activity, clickData.contractId)
                            ) + " "+unit)
                        }
                        tvEstimatedPlTitle.setOnClickListener {
                            CpNewDialogUtils.showDialogNew(
                                this.requireActivity(),
                                content = CpLanguageUtil.getString(mActivity!!,"cp_contract_quick_close_expected_profit_and_loss_msg"),
                                true,
                                title = CpLanguageUtil.getString(mActivity!!,"cp_expected_profit_and_loss"),
                                cancelTitle = CpLanguageUtil.getString(context, "cp_extra_text28"),
                                listener = null
                            )
                        }
                        val btn_close_position = it.getView<CpCommonlyUsedButton>(R.id.btn_close_position)
                        btn_close_position.setContent(CpLanguageUtil.getString(context, "cp_content_text29"))
                        btn_close_position.listener = object : CpCommonlyUsedButton.OnBottonListener {
                            override fun bottonOnClick() {
                                AppAnalyticsExt.instance.clickAction(AppAnalyticsExt.APP_FUTURES_POSITIONS_LIGHT_CLOSE)
                                quickClosePosition(clickData.contractId.toString(), "CLOSE", clickData.orderSide, clickData.positionType.toString())
                                mQuickClosePositionDialog?.dismiss()
                            }
                        }
                    },dismissListener = object: DialogInterface.OnDismissListener{
                        override fun onDismiss(dialog: DialogInterface?) {
                            isQkClosePosition = false
                            closeOrderSide=null
                        }

                    })
                }

                //Modify margin
                R.id.tv_adjust_margins -> {
                    mAdjustMarginDialog = CpDialogUtil.showAdjustMarginDialog(mActivity!!, OnCpBindViewListener {

                        it.setText(R.id.tv_cancel, CpLanguageUtil.getString(context, "cp_overview_text56"))
                        it.setText(R.id.tv_cp_order_text28, CpLanguageUtil.getString(context, "cp_order_text28"))
                        it.setText(R.id.tv_cp_order_text27, CpLanguageUtil.getString(context, "cp_order_text27"))
                        it.setText(R.id.tv_cp_order_text26, CpLanguageUtil.getString(context, "cp_order_text26"))
                        it.setText(R.id.tv_canuse_key, CpLanguageUtil.getString(context,"cp_order_text22"))
                        it.setText(R.id.tv_amount_label, CpLanguageUtil.getString(context,"cp_volume"))
                        val tab1 = object : CustomTabEntity{
                            override fun getTabTitle(): String {
                                return CpLanguageUtil.getString(context, "cp_order_text20")
                            }

                            override fun getTabSelectedIcon(): Int {
                                return 0
                            }

                            override fun getTabUnselectedIcon(): Int {
                                return 0
                            }

                        }
                        val tab2 = object : CustomTabEntity{
                            override fun getTabTitle(): String {
                                return CpLanguageUtil.getString(context, "cp_order_text21")
                            }

                            override fun getTabSelectedIcon(): Int {
                                return 0
                            }

                            override fun getTabUnselectedIcon(): Int {
                                return 0
                            }

                        }

                        val ratioGroupData = arrayOf(0.25f,0.50f,0.75f,1.00f)
                        val ly_et_volume = it.getView<LinearLayout>(R.id.ly_et_volume)
                        val tvCanuseKey = it.getView<TextView>(R.id.tv_canuse_key)
                        val tvCanuseValue = it.getView<TextView>(R.id.tv_canuse_value)
                        val tv_expect_price = it.getView<TextView>(R.id.tv_expect_price)
                        val tv_lever = it.getView<TextView>(R.id.tv_lever)
                        val tv_position_margin_value = it.getView<TextView>(R.id.tv_position_margin_value)
                        val imgTransfer = it.getView<ImageView>(R.id.img_transfer)
                        val lyTransfer = it.getView<View>(R.id.ly_transfer)
                        val etVolume = it.getView<EditText>(R.id.et_volume)
                        val mTabLayout = it.getView<CommonTabLayout>(R.id.mTabLayout)
                        val mSelectRatio = it.getView<SelectRatioView>(R.id.mSelectRatioView)

                        mTabLayout?.setTabData(arrayListOf(tab1,tab2))

                        val marginCoin = CpClLogicContractSetting.getContractMarginCoinById(activity, clickData.contractId)
                        val marginCoinPrecision = CpClLogicContractSetting.getContractMarginCoinPrecisionById(activity, clickData.contractId)
                        val currentPositionMargin = clickData?.holdAmount.toString()
                        val classification = CpClLogicContractSetting.getContractClassificationById(activity,clickData.contractId)
                        it.setText(R.id.tv_coin_name, marginCoin)
                        imgTransfer.setTransferStatus(classification)
                        lyTransfer.isEnabled = classification!=4

                        var canUseAmountStr = ""
                        var canSubAmountStr = clickData.canSubMarginAmount
                        mPositionObj?.apply {
                            if (!isNull("accountList")) {
                                val mOrderListJson = optJSONArray("accountList")
                                for (i in 0..(mOrderListJson.length() - 1)) {
                                    val obj = mOrderListJson.getJSONObject(i)
                                    var canUseAmount = obj.getString("canUseAmount")
                                    val csymbol = obj?.optString("symbol")
                                    if (marginCoin.equals(csymbol)) {
                                        canUseAmountStr = canUseAmount
                                    }
                                }
                            }
                        }
                        etVolume.setHint(CpLanguageUtil.getString(context, "cp_overview_text8"))
                        etVolume?.setOnFocusChangeListener { _, hasFocus ->
                            ly_et_volume?.setBackgroundResource(if (hasFocus) R.drawable.bg_selected_contract else R.drawable.bg_select_contract)
                        }

                        val canUseAmountShowStr = CpBigDecimalUtils.showSNormal(canUseAmountStr, marginCoinPrecision)
                        val canSubMarginAmountShowStr = CpBigDecimalUtils.showSNormal(clickData.canSubMarginAmount, marginCoinPrecision)
                        tvCanuseValue.setText(canUseAmountShowStr + " " + marginCoin)
                        var isAdd = true

                        mTabLayout?.setOnTabSelectListener(object: OnTabSelectListener{
                            override fun onTabSelect(position: Int) {
                                mSelectRatio?.resetViewColor()
                                etVolume.setText("")
                                when(position){
                                    0 -> {
                                        tvCanuseKey.setText(CpLanguageUtil.getString(context, "cp_order_text22"))
                                        tvCanuseValue.setText(canUseAmountShowStr + " " + marginCoin)
                                        imgTransfer.visibility = View.VISIBLE
                                        isAdd = true

                                    }
                                    1 -> {
                                        tvCanuseKey.setText(CpLanguageUtil.getString(context, "cp_order_text23"))
                                        tvCanuseValue.setText(canSubMarginAmountShowStr + " " + marginCoin)
                                        imgTransfer.visibility = View.GONE
                                        isAdd = false
                                    }
                                }
                            }

                            override fun onTabReselect(position: Int) {

                            }

                        })
                        lyTransfer.setOnClickListener {
                            if(!isAdd) return@setOnClickListener
                            val mMessageEvent =
                                    CpMessageEvent(CpMessageEvent.sl_contract_go_fundsTransfer_page)
                            mMessageEvent.msg_content = CpClLogicContractSetting.getContractMarginCoinById(activity, clickData.contractId)
                            CpEventBusUtil.post(mMessageEvent)
                        }

                        val volumeDecimal = CpClLogicContractSetting.getContractMarginCoinPrecisionById(activity, clickData.contractId)

                        mSelectRatio?.setRadios(ratioGroupData){ value:Float,position:Int,view:View? ->
                            CpSoftKeyboardUtil.hideSoftKeyboard(mActivity!!)
                            etVolume.clearFocus()
                            if(position==-1){
                                etVolume.setText("")

                                etVolume.requestFocus()
                                return@setRadios
                            }

                            if (value > -1) {
                                if (!CpClLogicContractSetting.isLogin()) {
                                    CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.sl_contract_go_login_page))
                                    return@setRadios
                                }
                            }
                            var buff = ""
                            if (isAdd) {
                                buff = canUseAmountShowStr
                            } else {
                                buff = canSubMarginAmountShowStr
                            }
                            it.setText(R.id.et_volume, CpBigDecimalUtils.mulStr(buff, value.toString(), volumeDecimal))

                        }

                        val btn_close_position = it.getView<CpCommonlyUsedButton>(R.id.btn_close_position)
                        btn_close_position.setContent(CpLanguageUtil.getString(context, "cp_calculator_text29"))
                        etVolume.setOnClickListener {
                            it.setFocusable(true);
                            it.setFocusableInTouchMode(true);
                            it.requestFocus();
                            it.findFocus();
                        }
                        var amount = ""
                        var marginValue = currentPositionMargin

                        etVolume.numberFilter(volumeDecimal, otherFilter = object : CpDoListener {
                            override fun doThing(obj: Any?): Boolean {
                                amount = etVolume.text.toString()
                                if (isAdd) {
                                    amount = CpBigDecimalUtils.addStr(currentPositionMargin, amount, marginCoinPrecision)
                                    marginValue = CpBigDecimalUtils.add(currentPositionMargin,etVolume.text.toString()).toPlainString()
                                } else {
                                    amount = CpBigDecimalUtils.subStr(currentPositionMargin, amount, marginCoinPrecision)
                                    marginValue = CpBigDecimalUtils.sub(currentPositionMargin, etVolume.text.toString()).toPlainString()
                                }
                                tv_position_margin_value.setText(amount + " " + marginCoin)
                                if (TextUtils.isEmpty(amount) || TextUtils.equals(amount, ".") || CpBigDecimalUtils.compareTo(amount, "0") == 0) {
                                    tv_lever.text = "--"
                                    tv_expect_price.text = "--"
                                    return true
                                }
                                //Margin exchange rate:
                                var marginRate = CpClLogicContractSetting.getContractMarginRateById(activity, clickData.contractId)

                                var mPricePrecision = CpClLogicContractSetting.getContractSymbolPricePrecisionById(activity, clickData.contractId)
                                //Nominal value:
                                var multiplier = CpClLogicContractSetting.getContractMultiplierById(activity, clickData.contractId)
                                //Tag Price
                                var indexPrice = clickData?.indexPrice
                                //Contract direction: (Reverse: 0, Forward: 1)
                                var contractSide = CpClLogicContractSetting.getContractSideById(activity, clickData.contractId).toString()

                                //Position direction
                                var positionDirection = if (clickData?.orderSide.equals("BUY")) "1" else "-1"
                                //Maintain margin ratio
                                var keepRate = clickData?.keepRate
                                //Fee rate
                                var maxFeeRate = clickData?.maxFeeRate
                                //Number of positions
                                var positionVolume = CpBigDecimalUtils.mulStr(clickData?.positionVolume, multiplier, 4)

                                ChainUpLogUtil.e(TAG, positionVolume)
                                ChainUpLogUtil.e(TAG, clickData?.positionVolume)
                                ChainUpLogUtil.e(TAG, multiplier)

                                val contractQuoteById = CpClLogicContractSetting.getContractQuoteById(activity,clickData.contractId)
                                //Position direction: multi position is 1, short position is - 1
                                var reducePriceStr = CpBigDecimalUtils.calcForcedPrice(contractSide.equals("1"), marginValue, positionVolume, positionDirection, indexPrice, keepRate, maxFeeRate, mPricePrecision)
                                if (CpBigDecimalUtils.compareTo(reducePriceStr, "0") != 1) {
                                    reducePriceStr = "--"
                                }
                                tv_expect_price.setText("$reducePriceStr $contractQuoteById")

                                /**
                                实际杠杆（正向合约） = 仓位数量 *Tag Price/Adjusted Position Margin/Margin Exchange Rate
                                实际杠杆（反向合约） = 仓位数量 / 标记价格 / 调整后仓位保证金 / 保证金汇率
                                 */
                                var adjustingLever = "0X"
                                if (contractSide.equals("1")) {
                                    //Forward direction
                                    val buff1 = CpBigDecimalUtils.mul(positionVolume, indexPrice)//Number of positions * Tag Price
                                    val buff2 = CpBigDecimalUtils.div(amount, marginRate)//Adjusted position margin/margin exchange rate
                                    adjustingLever = CpBigDecimalUtils.div(buff1, buff2, 1)
                                } else {
                                    val buff1 = CpBigDecimalUtils.div(positionVolume, indexPrice)//Position Quantity/Tag Price
                                    val buff2 = CpBigDecimalUtils.div(amount, marginRate)//Adjusted position margin/margin exchange rate
                                    adjustingLever = CpBigDecimalUtils.div(buff1, buff2, 1)
                                }
                                if (CpBigDecimalUtils.compareTo(adjustingLever, "0") != 1) {
                                    adjustingLever = "--"
                                }
                                tv_lever.setText(adjustingLever + " " + "X")

                                btn_close_position.isEnable(CpBigDecimalUtils.compareTo(etVolume.text.toString(), "0") == 1)
                                return true
                            }
                        })
                        etVolume.setText("")
                        btn_close_position.listener = object : CpCommonlyUsedButton.OnBottonListener {
                            override fun bottonOnClick() {
                                var type = "1"
                                if (CpBigDecimalUtils.compareTo(amount, currentPositionMargin) == 1) {
                                    //Increase margin
                                    type = "1"
                                    amount = CpBigDecimalUtils.subStr(amount, currentPositionMargin, marginCoinPrecision)
                                } else {
                                    //Decrease in margin
                                    type = "2"
                                    amount = CpBigDecimalUtils.subStr(amount, currentPositionMargin, marginCoinPrecision)
                                }
                                addDisposable(getContractModel().modifyPositionMargin(clickData?.contractId.toString(), clickData?.id.toString(), type.toString(), amount,
                                        consumer = object : CpNDisposableObserver(mActivity, true) {
                                            override fun onResponseSuccess(jsonObject: JSONObject?) {
                                                CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.sl_contract_refresh_assets_position_event))
                                                CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.sl_contract_modify_position_margin_event))
                                            }
                                        }))
                                mAdjustMarginDialog?.dismiss()
                            }
                        }
                    })
                }
                R.id.tv_profit_loss -> {
                    AppAnalyticsExt.instance.clickAction(AppAnalyticsExt.APP_FUTURES_POSITIONS_TPSL)
                    CpContractStopRateLossActivity.show( requireActivity(), clickData)
                }
                //Share Graph
                R.id.iv_share -> {

                    AppAnalyticsExt.instance.clickAction(AppAnalyticsExt.CONTRACT_APP_ACTION_15)
                    doShare(clickData)
                }
                R.id.tv_tag_price -> {
                    KKDialogUtils.showCommonDialog(
                        requireActivity(),
                        title = getLineText("cp_extra_text135"),
                        content = CpLanguageUtil.getString(context, "cp_extra_text129"),
                        confrimTitle = getLineText("cp_extra_text28"),
                        isShowCancel = false,
                        style = 2,
                        listener = null
                    )
                }
                R.id.tv_forced_close_price_key -> {
                    CpNewDialogUtils.showDialogNew(
                        requireActivity(),
                            CpLanguageUtil.getString(context, "cp_extra_text130"),
                            true,
                            null,
                            getLineText("cp_calculator_text4"),
                            getLineText("cp_extra_text28")
                    )
                }
//                R.id.tv_settled_profit_loss_key -> {
//                    val obj: JSONObject = JSONObject()
//                    obj.put("profitRealizedAmount", clickData.profitRealizedAmount)
//                    obj.put("tradeFee", clickData.tradeFee)
//                    obj.put("capitalFee", clickData.capitalFee)
//                    obj.put("closeProfit", clickData.closeProfit)
//                    obj.put("shareAmount", clickData.shareAmount)
//                    obj.put("settleProfit", clickData.settleProfit)
//                    obj.put("marginCoin", CpClLogicContractSetting.getContractMarginCoinById(context, clickData.contractId))
//                    obj.put("marginCoinPrecision", CpClLogicContractSetting.getContractMarginCoinPrecisionById(context, clickData.contractId))
//                    CpSlDialogHelper.showProfitLossDetailsDialog( requireActivity(), obj, 0)
//                }
                R.id.tv_floating_gains_balance_key -> {
                    mAdjustRoiDialog = CpDialogUtil.showAdjustRoiDialog( requireActivity(), OnCpBindViewListener {
                        it.setText(R.id.tv_title, CpLanguageUtil.getString(context, "cp_roi_1"))
                        it.setText(R.id.rb_1, CpLanguageUtil.getString(context, "cp_roi_2"))
                        it.setText(R.id.rb_2, CpLanguageUtil.getString(context, "cp_roi_3"))
                        it.setText(R.id.tv_cancel,CpLanguageUtil.getString(context, "cp_overview_text56"))
                        it.setText(R.id.tv_cp_order_text28111, CpLanguageUtil.getString(context, if (priceBasis==0)  "cp_roi_4" else "cp_roi_5"))
                        val rg_trade = it.getView<RadioGroup>(R.id.rg_order_type)
                        var priceBasisBuff=priceBasis
                        rg_trade?.check(if (priceBasis==0) R.id.rb_1 else R.id.rb_2)
                        rg_trade?.setOnCheckedChangeListener { group, checkedId ->
                            when (checkedId) {
                                R.id.rb_1 -> {
                                    priceBasisBuff=0
                                    it.setText(R.id.tv_cp_order_text28111, CpLanguageUtil.getString(context,"cp_roi_4"))
                                }
                                R.id.rb_2 -> {
                                    priceBasisBuff=1
                                    it.setText(R.id.tv_cp_order_text28111, CpLanguageUtil.getString(context,"cp_roi_5"))
                                }
                            }
                        }
                        val btn_close_position = it.getView<CpCommonlyUsedButton>(R.id.btn_close_position)
                        btn_close_position.setContent(CpLanguageUtil.getString(context,"cp_calculator_text29"))
                        btn_close_position.isEnable(true)
                        btn_close_position.listener = object : CpCommonlyUsedButton.OnBottonListener {
                            override fun bottonOnClick() {

                                addDisposable(getContractModel().getUserConfig(clickData.contractId.toString(),
                                        consumer = object : CpNDisposableObserver(activity,true) {
                                            override fun onResponseSuccess(jsonObject: JSONObject?) {
                                                jsonObject?.optJSONObject("data")?.run {
                                                    val coUnit = optInt("coUnit")//Contract unit 1 target currency, 2 sheets
                                                    val positionModel = optInt("positionModel")//Position Type 1 Position, 2 Bidirectional Position
                                                    val pcSecondConfirm = optInt("pcSecondConfirm")//Popup confirmation switch before placing an order, 0 used, 1 disabled
                                                    val positionModelCanSwitch = optInt("positionModelCanSwitch")//Can the current position type be switched? 0 cannot be switched, 1 can be switched
                                                    val expiredTime = optInt("expireTime")//Unit: Day (fixed enumeration) 1, 7, 14, 30
                                                    addDisposable(getContractModel().modifyTransactionLike(
                                                            clickData.contractId.toString(),
                                                            positionModel.toString(),
                                                            pcSecondConfirm.toString(),
                                                            coUnit.toString(),
                                                            expiredTime.toString(),
                                                            priceBasisBuff.toString(),
                                                            consumer = object : CpNDisposableObserver(true) {
                                                                override fun onResponseSuccess(jsonObject: JSONObject?) {
                                                                    priceBasis= priceBasisBuff
                                                                    mAdjustRoiDialog?.dismiss()
                                                                }
                                                            }))
                                                }
                                            }
                                        }))

                            }
                        }
                    })
                }
            }
        }
        var isChecked= CpPreferenceManager.getInstance(mActivity).getSharedBoolean(
            CpPreferenceManager.PREF_SHOW_CURRENT_CONTRACT, false)
        switch_contract_type.setImageResource(if (isChecked) R.drawable.trade_switch_open else R.mipmap.trade_switch_close)
        switch_contract_type.setOnClickListener {
            switchSelectCurrentContractOff()
        }
        tv_onekey_close_title.setOnClickListener {
            switchSelectCurrentContractOff()
        }

        tv_onekey_close.setOnClickListener {
            AppAnalyticsExt.instance.clickAction(AppAnalyticsExt.APP_FUTURES_POSITIONS_CLOSE_ALL)
            adapter?.apply {
                if (this.data.size==0){
                    return@setOnClickListener
                }
                CpNewDialogUtils.showDialogNew(
                    requireActivity(),
                    String.format(CpLanguageUtil.getString(activity,"cp_close_3"),this.data.size),
                    false,
                    object : CpNewDialogUtils.DialogBottomListener{
                        override fun sendConfirm() {
                            var isChecked= CpPreferenceManager.getInstance(mActivity).getSharedBoolean(
                                CpPreferenceManager.PREF_SHOW_CURRENT_CONTRACT, false)
                            var contractIds=""
                            if (isChecked){
                                contractIds= adapter?.data!![0].contractId.toString()
                            }
                            oneKeyColse(contractIds)
                        }
                    },
                    CpLanguageUtil.getString(activity,"cp_extra_text27"),
                    CpLanguageUtil.getString(activity,"cp_overview_text56"),
                    CpLanguageUtil.getString(activity,"cp_calculator_text16")
                )
            }

        }
    }

    fun switchSelectCurrentContractOff(){
        var isChecked= CpPreferenceManager.getInstance(mActivity).getSharedBoolean(CpPreferenceManager.PREF_SHOW_CURRENT_CONTRACT, false)
        isChecked=!isChecked
        CpPreferenceManager.getInstance(mActivity).putSharedBoolean(CpPreferenceManager.PREF_SHOW_CURRENT_CONTRACT, isChecked)
        switch_contract_type.setImageResource(if (isChecked) R.drawable.trade_switch_open else R.mipmap.trade_switch_close)
        CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.sl_contract_hold_position_isonly).apply { msg_content = isChecked })
    }

    //Monitoring the execution of edittext
    fun checkCloseEtValue(etPrice:EditText,etVolume:EditText,checkedIdBuff:Int,btn:CpCommonlyUsedButton){
        val etPriceValue = etPrice.text.toString()
        val etVolumeValue = etVolume.text.toString()

        val isHasEmpty = if(checkedIdBuff!=-1){
            TextUtils.isEmpty(etPriceValue) || TextUtils.isEmpty(etVolumeValue)
        }else{
            TextUtils.isEmpty(etVolumeValue)
        }
        btn.isEnable(!isHasEmpty)
    }

    private fun oneKeyColse(contractIds: String) {
        addDisposable(
            getContractModel().closeAllPosition(contractIds,
                consumer = object :
                    CpNDisposableObserver(mActivity, true) {
                    override fun onResponseSuccess(jsonObject: JSONObject?) {
                        CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.sl_contract_refresh_assets_position_event))
                        CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.sl_contract_req_position_list_event))
                    }
                })
        )

    }


    private fun closePosition(data: CpContractPositionBean, type: Int, priceType: String, price: String, vol: String) {
        var contractId = data.contractId
        var positionType = data.positionType.toString()
        var open = "CLOSE"
        var side = if (data.orderSide.equals("BUY")) "SELL" else "BUY"
        var type = type
        var leverageLevel = data.leverageLevel
        var price = price
        var volume = vol
        var isConditionOrder = false
        var triggerPrice = ""

        var expireTime =
                CpClLogicContractSetting.getStrategyEffectTimeStr(mActivity)
        addDisposable(
                getContractModel().createOrder(contractId,
                        positionType,
                        open,
                        side,
                        type,
                        leverageLevel,
                        price,
                        volume,
                        isConditionOrder,
                        triggerPrice,
                        expireTime,
                        false,
                        "",
                        "",
                        priceType,
                        orderUnit = if(CpClLogicContractSetting.getContractUint(mActivity)==0) 0 else 2,
                        consumer = object :
                                CpNDisposableObserver(mActivity, true) {
                            override fun onResponseSuccess(jsonObject: JSONObject?) {
                                CpNToastUtil.showTopToastNet(this.mActivity, true, getString(R.string.cp_extra_text109))
                                CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.sl_contract_refresh_assets_position_event))
                                CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.sl_contract_req_position_list_event))
                            }
                        })
        )
    }

    private fun quickClosePosition(contractId: String, open: String, side: String, positionType: String) {
        var side = if (side.equals("BUY")) "SELL" else "BUY"
        addDisposable(
                getContractModel().lightClose(contractId, open, side, positionType,
                        consumer = object : CpNDisposableObserver(mActivity,true) {
                            override fun onResponseSuccess(jsonObject: JSONObject?) {
                                CpNToastUtil.showTopToastNet(this.mActivity, true, CpLanguageUtil.getString(context, "cp_extra_text109"))
                                LogUtils.e("quickClosePosition :success")
                                CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.sl_contract_refresh_assets_position_event))
                                CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.sl_contract_req_position_list_event))
                            }
                        })
        )
    }

    private fun doShare(clickData: CpContractPositionBean) {
        val rxPermissions = activity?.let { RxPermissions(it) }
        val observable = rxPermissions?.request("share".getAppSharePermission())
        observable?.subscribe { granted ->
            if (granted) {
                mShareDialog = CpNewDialogUtils.showShareDialog(requireContext(), clickData)
            } else {
                CpDisplayUtils.showSnackBar(
                        activity?.window?.decorView,
                        CpLanguageUtil.getString(context, "cp_extra_text128"),
                        false
                )
            }
        }
    }


    //Obtain the price through the list ID
    fun getObjFromPriceListById(id:Int,callback:(priceObj:JSONObject,positionObj:CpContractPositionBean)->Unit){
        mPriceListObj?.apply {
            for (i in 0..(mPriceListObj?.length() - 1)) {
                var positionListobj = mPriceListObj?.getJSONObject(i)
                mPositionObj?.apply {
                    if (!isNull("positionList")) {
                        val mOrderListJson = optJSONArray("positionList")
                        for (i in 0..(mOrderListJson.length() - 1)) {
                            val objBuff = Gson().fromJson<CpContractPositionBean>(
                                mOrderListJson.getString(i),
                                CpContractPositionBean::class.java
                            )
                            val buff = positionListobj.optJSONObject(objBuff.contractName)
                            if (objBuff.id == id && buff != null) {
                                callback.invoke(buff,objBuff)
                            }
                        }
                    }
                }
            }
        }
    }


    @Subscribe(threadMode = ThreadMode.POSTING)
    override fun onMessageEvent(event: CpMessageEvent) {
        when (event.msg_type) {
            CpMessageEvent.sl_contract_refresh_price_list_event -> {
                if (!CpClLogicContractSetting.isLogin()) return
                val mListBuffer = ArrayList<CpContractPositionBean>()
                 mPriceListObj = event.msg_content as JSONArray
                //contractName
                mPositionObj?.apply {
                    if (!isNull("positionList")) {
                        val mOrderListJson = optJSONArray("positionList")
                        for (i in 0..(mOrderListJson.length() - 1)) {
                            var obj = mOrderListJson.getJSONObject(i)
                            val objBuff= Gson().fromJson<CpContractPositionBean>(
                                mOrderListJson.getString(i),
                                CpContractPositionBean::class.java
                            )

                            var contractName = obj.optString("contractName")
                            val contractId = obj.optInt("contractId")
                            val orderSide = obj.optString("orderSide")
                            val openAvgPrice = obj.optString("openAvgPrice")
                            val holdAmount = obj.optString("holdAmount")
                            val openAmount = obj.optString("openAmount")
                            val positionVolume = obj.optString("positionVolume")
                            for (i in 0..(mPriceListObj?.length() - 1)) {
                                var positionListobj = mPriceListObj?.getJSONObject(i)
                                val buff = positionListobj.optJSONObject(contractName)
                                if (buff != null) {
                                    LogUtils.e("---------------"+buff.optString("tagPrice"))
                                    val tagPrice= buff.optString("tagPrice")
                                    val lastPrice= buff.optString("lastPrice")
                                    val  marginCoinPrecision = CpClLogicContractSetting.getContractMarginCoinPrecisionById(mActivity, contractId)
                                    val isForward = if (CpClLogicContractSetting.getContractSideById(mActivity, contractId) == 1) true else false
                                    val direction = if (orderSide.equals("BUY")) 0 else 1
                                    val multiplier = CpClLogicContractSetting.getContractMultiplierById(mActivity, contractId)
                                    val marginRate = CpClLogicContractSetting.getContractMarginRateById(mActivity, contractId)
                                    val str=  CpBigDecimalUtils.calcPositionProfit(isForward,direction,if (priceBasis==1) tagPrice else lastPrice,openAvgPrice,multiplier,positionVolume,marginRate,holdAmount,marginCoinPrecision,false)
                                    val strBig=  CpBigDecimalUtils.calcPositionProfitBig(isForward,direction,if (priceBasis==1) tagPrice else lastPrice,openAvgPrice,multiplier,positionVolume,marginRate,holdAmount,marginCoinPrecision)
                                    LogUtils.e("---------------PositionProfit："+str)
                                    val str12= CpBigDecimalUtils.divStr(strBig.toPlainString(),openAmount,8)
                                    LogUtils.e("---------------PositionProfit："+str12)
                                    obj.put("returnRate",str12)
                                    obj.put("openRealizedAmount",str12)
                                    objBuff.returnRate=str12
                                    objBuff.openRealizedAmount=str
                                    var isChecked= CpPreferenceManager.getInstance(mActivity).getSharedBoolean(
                                        CpPreferenceManager.PREF_SHOW_CURRENT_CONTRACT, false)
                                    if (isChecked){
                                        if (mContractId==contractId){
                                            mListBuffer.add(objBuff)
                                        }
                                    }else{
                                        mListBuffer.add(objBuff)
                                    }
                                    break
                                }
                            }
                        }
                    }
                }
                adapter?.setList(mListBuffer)



                //Add calculates the estimated profit and loss in the closing dialog box
                //Filter based on the currently clicked bin ID mCurrentClickId
                mCurrentClickId?.run {
                    getObjFromPriceListById(this){ buff,objBuff ->

                        val contractId = objBuff.contractId

                        val lastPrice = buff.optString("lastPrice")
                        val tagPrice  = buff.optString("tagPrice")
                        val buyOne    = buff.optString("buyOne")
                        val sellOne   = buff.optString("sellOne")
                        val mPricePrecision = CpClLogicContractSetting.getContractSymbolPricePrecisionById(context, contractId)
                        val openAvgPrice = CpBigDecimalUtils.showSNormal(objBuff.openAvgPrice, mPricePrecision)
                        val positionVolume = objBuff.positionVolume
                        val holdAmount= objBuff.holdAmount
                        val multiplier = CpClLogicContractSetting.getContractMultiplierById(mActivity, contractId)
                        val marginRate = CpClLogicContractSetting.getContractMarginRateById(mActivity, contractId)
                        val marginCoin = CpClLogicContractSetting.getContractMarginCoinById(mActivity, contractId)
                        val marginCoinPrecision = CpClLogicContractSetting.getContractMarginCoinPrecisionById(mActivity, contractId)
                        val isForward = if (CpClLogicContractSetting.getContractSideById(mActivity, contractId) == 1) true else false
                        val direction = if (objBuff.orderSide.equals("BUY")) 0 else 1


                        if(isClosePosition){
                            //The estimated profit and loss of ordinary closing positions is calculated based on the selected method
                            mBindViewHolder?.run{

                                val etPrice = getView<EditText>(R.id.et_price)
                                val etPriceText = etPrice.text.trim().toString()

                                if(etPriceText.isEmpty() && !etPrice.isFocused){
                                    //lastPrice
                                    etPrice.setText(CpBigDecimalUtils.showSNormal(lastPrice, mPricePrecision))
                                }

                                val rbMarketPrice = getView<RadioButton>(R.id.rb_1).isChecked
                                val rbBuyOnePrice = getView<RadioButton>(R.id.rb_2).isChecked
                                val rbSellOnePrice = getView<RadioButton>(R.id.rb_3).isChecked
                                val price = if(rbMarketPrice){
//                                                    lastPrice
                                    if("BUY".equals(closeOrderSide)){//Multiheaded
                                        buyOne
                                    }else{
                                        sellOne
                                    }
                                }else if(rbBuyOnePrice){ //Our Best
                                    if("BUY".equals(closeOrderSide)){//Multiheaded
                                        sellOne
                                    }else{
                                        buyOne
                                    }

                                }else if(rbSellOnePrice){//The other party is the best
                                    if("BUY".equals(closeOrderSide)){//Multiheaded
                                        buyOne
                                    }else{
                                        sellOne
                                    }
                                }else{
                                    if(etPriceText.isNotEmpty() && CpStringUtil.isNumeric(etPriceText)) etPriceText else lastPrice
                                }

                                Log.d(TAG,"参与计算价格"+price)



                                val amount = getView<TextView>(R.id.et_volume).text.toString()
                                val closeStr = CpBigDecimalUtils.calcPositionProfit(isForward,direction,price,openAvgPrice,multiplier,amount,marginRate,holdAmount,marginCoinPrecision,true)
                                val tv_estimated_pl_value= getView<TextView>(R.id.tv_estimated_pl_value)
                                tv_estimated_pl_value?.run {
                                    text = "$closeStr $marginCoin"
                                    textColor = CpColorUtil.getMainColorType(CpBigDecimalUtils.compareTo(closeStr,"0") >= 0)
                                }



                            }

                        }

                        if(isQkClosePosition){



                            val quick_closeStr = CpBigDecimalUtils.calcPositionProfit(
                                isForward,
                                direction,
                                if("BUY".equals(closeOrderSide)){//Multiheaded
                                    buyOne
                                }else{
                                    sellOne
                                },
                                openAvgPrice,
                                multiplier,
                                positionVolume,
                                marginRate,
                                holdAmount,
                                marginCoinPrecision,
                                false
                            )
                            val tv_quick_estimated_pl_value= mBindViewHolder?.getView<TextView>(R.id.tv_quick_estimated_pl_value)
                            tv_quick_estimated_pl_value?.run {
                                text = "$quick_closeStr $marginCoin"
                                textColor = CpColorUtil.getMainColorType(CpBigDecimalUtils.compareTo(quick_closeStr,"0") >= 0)
                            }
                        }

                    }
                }
            }
            CpMessageEvent.sl_contract_priceBasis_event -> {
                priceBasis = event.msg_content as Int
            }
            CpMessageEvent.sl_contract_refresh_position_list_event -> {
                if (!CpClLogicContractSetting.isLogin()) return
                mPositionObj = event.msg_content as JSONObject
                val mListBuffer = ArrayList<CpContractPositionBean>()
//                mPositionObj?.apply {
//                    if (!isNull("positionList")) {
//                        val mOrderListJson = optJSONArray("positionList")
//                        for (i in 0..(mOrderListJson.length() - 1)) {
//                            var obj = mOrderListJson.getString(i)
//                            mListBuffer.add(
//                                    Gson().fromJson<CpContractPositionBean>(
//                                            obj,
//                                            CpContractPositionBean::class.java
//                                    )
//                            )
//                        }
//                        val msgEvent =
//                                CpMessageEvent(
//                                        CpMessageEvent.sl_contract_position_num_event
//                                )
//                        msgEvent.msg_content = mOrderListJson.length()
//                        CpEventBusUtil.post(msgEvent)
//                    }
//                    adapter?.setList(mListBuffer)
//                }
                mPriceListObj?.apply {
                    mPositionObj?.apply {
                        if (!isNull("positionList")) {
                            val mOrderListJson = optJSONArray("positionList")
                            for (i in 0..(mOrderListJson.length() - 1)) {
                                var obj = mOrderListJson.getJSONObject(i)
                                val objBuff= Gson().fromJson<CpContractPositionBean>(
                                    mOrderListJson.getString(i),
                                    CpContractPositionBean::class.java
                                )

                                var contractName = obj.optString("contractName")
                                val contractId = obj.optInt("contractId")
                                val orderSide = obj.optString("orderSide")
                                val openAvgPrice = obj.optString("openAvgPrice")
                                val holdAmount = obj.optString("holdAmount")
                                val openAmount = obj.optString("openAmount")
                                val positionVolume = obj.optString("positionVolume")
                                for (i in 0..(mPriceListObj?.length() - 1)) {
                                    var positionListobj = mPriceListObj?.getJSONObject(i)
                                    val buff = positionListobj.optJSONObject(contractName)
                                    if (buff != null) {
                                        LogUtils.e("---------------"+buff.optString("tagPrice"))
                                        val tagPrice= buff.optString("tagPrice")
                                        val lastPrice= buff.optString("lastPrice")
                                        val  marginCoinPrecision = CpClLogicContractSetting.getContractMarginCoinPrecisionById(mActivity, contractId)
                                        val isForward = if (CpClLogicContractSetting.getContractSideById(mActivity, contractId) == 1) true else false
                                        val direction = if (orderSide.equals("BUY")) 0 else 1
                                        val multiplier = CpClLogicContractSetting.getContractMultiplierById(mActivity, contractId)
                                        val marginRate = CpClLogicContractSetting.getContractMarginRateById(mActivity, contractId)
                                        val str=  CpBigDecimalUtils.calcPositionProfit(isForward,direction,if (priceBasis==1) tagPrice else lastPrice,openAvgPrice,multiplier,positionVolume,marginRate,holdAmount,marginCoinPrecision,false)
                                        val strBig=  CpBigDecimalUtils.calcPositionProfitBig(isForward,direction,if (priceBasis==1) tagPrice else lastPrice,openAvgPrice,multiplier,positionVolume,marginRate,holdAmount,marginCoinPrecision)
                                        LogUtils.e("---------------PositionProfit："+str)
                                        val str12= CpBigDecimalUtils.divStr(strBig.toPlainString(),openAmount,8)
                                        LogUtils.e("---------------PositionProfit："+str12)
                                        obj.put("returnRate",str12)
                                        obj.put("openRealizedAmount",str12)
                                        objBuff.returnRate=str12
                                        objBuff.openRealizedAmount=str
                                        var isChecked= CpPreferenceManager.getInstance(mActivity).getSharedBoolean(
                                            CpPreferenceManager.PREF_SHOW_CURRENT_CONTRACT, false)
                                        if (isChecked){
                                            if (mContractId==contractId){
                                                mListBuffer.add(objBuff)
                                            }
                                        }else{
                                            mListBuffer.add(objBuff)
                                        }
                                        break
                                    }
                                }
                            }
                        }
                    }

                    adapter?.setList(mListBuffer)
                }
            }
            CpMessageEvent.sl_contract_req_position_list_event -> {
                if (!CpClLogicContractSetting.isLogin()) return
                addDisposable(
                        getContractModel().getPosition(
                                consumer = object :
                                        CpNDisposableObserver(mActivity, true) {
                                    override fun onResponseSuccess(jsonObject: JSONObject?) {
                                        mPositionObj = jsonObject?.optJSONObject("data")
                                        val mListBuffer = ArrayList<CpContractPositionBean>()
                                        mPositionObj?.apply {
                                            if (!isNull("positionList")) {
                                                val mOrderListJson = optJSONArray("positionList")
                                                for (i in 0..(mOrderListJson.length() - 1)) {
                                                    var obj = mOrderListJson.getJSONObject(i)
                                                    val objBuff= Gson().fromJson<CpContractPositionBean>(
                                                        mOrderListJson.getString(i),
                                                        CpContractPositionBean::class.java
                                                    )
                                                    val contractId = obj.optInt("contractId")
                                                    var isChecked= CpPreferenceManager.getInstance(mActivity).getSharedBoolean(
                                                        CpPreferenceManager.PREF_SHOW_CURRENT_CONTRACT, false)
                                                    if (isChecked){
                                                        if (mContractId==contractId){
                                                            mListBuffer.add(objBuff)
                                                        }
                                                    }else{
                                                        mListBuffer.add(objBuff)
                                                    }
                                                }
                                                val msgEvent =
                                                        CpMessageEvent(
                                                                CpMessageEvent.sl_contract_position_num_event
                                                        )
                                                msgEvent.msg_content = mListBuffer.size
                                                CpEventBusUtil.post(msgEvent)
                                            }
                                            adapter?.setList(mListBuffer)
                                        }
                                    }
                                })
                )

            }

            CpMessageEvent.sl_contract_hold_position_isonly -> {
                if (!CpClLogicContractSetting.isLogin()) return
                val isOnlyCurrentContract = event.msg_content as Boolean
                val mListBuffer = ArrayList<CpContractPositionBean>()
                mPositionObj?.apply {
                    if (!isNull("positionList")) {
                        val mOrderListJson = optJSONArray("positionList")
                        for (i in 0..(mOrderListJson.length() - 1)) {
                            var obj = mOrderListJson.getJSONObject(i)
                            val objBuff = Gson().fromJson(mOrderListJson.getString(i), CpContractPositionBean::class.java)
                            val contractId = obj.optInt("contractId")
                            if (isOnlyCurrentContract) {
                                if (mContractId == contractId) {
                                    mListBuffer.add(objBuff)
                                }
                            } else {
                                mListBuffer.add(objBuff)
                            }
                        }
                    }
                }

                val msgEvent = CpMessageEvent(CpMessageEvent.sl_contract_position_num_event)
                msgEvent.msg_content = mListBuffer.size
                CpEventBusUtil.post(msgEvent)
                adapter?.setList(mListBuffer)
            }

            CpMessageEvent.sl_contract_logout_event -> {
                mList.clear()
                adapter?.notifyDataSetChanged()
            }
            CpMessageEvent.sl_contract_change_contract_event -> {
                mContractId= event.msg_content as Int
                LogUtils.e("contractId:"+mContractId)
            }
        }
    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if(CpZXingUtils.SHARE_CODE==requestCode){

            Log.d(TAG,"系统分享的结果")
            //Only cancel operations are performed here
            if(mShareDialog!=null) mShareDialog?.dismiss()

        }
    }

    companion object{
        fun newInstance(contractId: Int): CpContractHoldNewFragment {
            val fragment = CpContractHoldNewFragment()
            val args = Bundle()
            args.putInt("contractId", contractId)
            fragment.setArguments(args)
            return fragment
        }
    }


}
