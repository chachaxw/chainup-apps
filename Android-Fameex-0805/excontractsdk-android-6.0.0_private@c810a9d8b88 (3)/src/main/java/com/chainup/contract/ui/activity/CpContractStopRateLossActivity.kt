package com.yjkj.chainup.new_contract.activity

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.text.Editable
import android.text.TextUtils
import android.text.TextWatcher
import android.view.View
import com.chainup.contract.R
import com.chainup.contract.app.CpMyApp
import com.chainup.contract.base.CpNBaseActivity
import com.chainup.contract.bean.CpTpslOrderBean
import com.chainup.contract.eventbus.CpEventBusUtil
import com.chainup.contract.eventbus.CpMessageEvent
import com.chainup.contract.utils.*
import com.chainup.contract.view.*
import com.chainup.contract.ws.CpWsContractAgentManager
import com.yjkj.chainup.manager.CpLanguageUtil
import com.yjkj.chainup.net_new.rxjava.CpNDisposableObserver
import com.yjkj.chainup.new_contract.bean.CpContractPositionBean
import kotlinx.android.synthetic.main.cp_activity_stop_rate_loss.*
import org.json.JSONArray
import org.json.JSONObject

/**
 *Stop profit and stop loss
 */
class CpContractStopRateLossActivity : CpNBaseActivity(), CpWsContractAgentManager.WsResultCallback, TextWatcher {
    override fun setContentView(): Int {
        return R.layout.cp_activity_stop_rate_loss
    }

    private var mContractPositionBean: CpContractPositionBean? = null
    private var isStopProfitMarket = false
    private var isStopLossMarket = false
    private var multiplier = "0"
    private var multiplierPrecision = 0
    private var marginCoinPrecision = 0
    private var mPricePrecision = 0
    private var currentSymbol = ""
    private var marginRate = ""
    private var mMarginCoin = ""
    private var mCanCloseVolumeStr = "0"
    private lateinit var mTakeProfitList: JSONArray
    private lateinit var mStopLossList: JSONArray
    private lateinit var orderList: ArrayList<CpTpslOrderBean>
    private lateinit var mContractJsonStr: JSONObject
    var orderType=1
    private var isLimit = false
    private var base = ""

    private val mRatios = arrayOf(0.25f,0.50f,0.75f,1.00f)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        loadData()
        initView()
        initListener()

    }


    override fun onResume() {
        super.onResume()
        CpWsContractAgentManager.instance.sendData(CpWsLinkUtils.tickerFor24HLink(currentSymbol, isSub = true, isChannel = false))

    }
    override fun onPause() {
        super.onPause()
        CpWsContractAgentManager.instance.sendData(CpWsLinkUtils.tickerFor24HLink(currentSymbol, isSub = false, isChannel = false))

    }

    override fun onDestroy() {
        super.onDestroy()
        CpWsContractAgentManager.instance.removeWsCallback(this)
    }


    override fun loadData() {
        super.loadData()
        CpWsContractAgentManager.instance.addWsCallback(this)
        mContractPositionBean = intent.getSerializableExtra("ContractPositionBean") as CpContractPositionBean?

        mContractJsonStr = CpClLogicContractSetting.getContractJsonStrById(mActivity, mContractPositionBean?.contractId!!)
        multiplier = mContractJsonStr?.optString("multiplier").toString()

        multiplierPrecision = CpClLogicContractSetting.getContractMultiplierPrecisionById(mActivity, mContractPositionBean?.contractId!!)

        marginCoinPrecision = CpClLogicContractSetting.getContractMarginCoinPrecisionById(mActivity, mContractPositionBean?.contractId!!)

        multiplierPrecision = if (CpClLogicContractSetting.getContractUint(mActivity) == 0) 0 else multiplierPrecision

        mPricePrecision = CpClLogicContractSetting.getContractSymbolPricePrecisionById(mContext, mContractPositionBean?.contractId!!)

        currentSymbol = CpClLogicContractSetting.getContractWsSymbolById(mContext, mContractPositionBean?.contractId!!)

        marginRate = CpClLogicContractSetting.getContractMarginRateById(mContext, mContractPositionBean?.contractId!!)

        mMarginCoin = CpClLogicContractSetting.getContractMarginCoinById(mContext, mContractPositionBean?.contractId!!)

        ChainUpLogUtil.e(TAG, "multiplierPrecision:" + multiplierPrecision)
        et_stop_profit_position.numberFilter(multiplierPrecision)
        et_stop_loss_position.numberFilter(multiplierPrecision)
        et_stop_profit_trigger_price.numberFilter(mPricePrecision)
        et_stop_loss_trigger_price.numberFilter(mPricePrecision)
        et_stop_loss_price.numberFilter(mPricePrecision)
        et_stop_profit_price.numberFilter(mPricePrecision)

        tv_stop_profit_trigger_coin_name.setText(mContractJsonStr?.optString("quote"))
        tv_stop_loss_trigger_coin_name.setText(mContractJsonStr?.optString("quote"))
        tv_stop_profit_coin_name.setText(mContractJsonStr?.optString("quote"))
        tv_stop_loss_coin_name.setText(mContractJsonStr?.optString("quote"))

        base = if (CpClLogicContractSetting.getContractUint(CpMyApp.instance()) == 0)  CpLanguageUtil.getString(this,"cp_overview_text9") else mContractJsonStr?.optString("multiplierCoin")
        tv_position_key.setText( CpLanguageUtil.getString(this,"cp_extra_text90") + "(" + base + ")")
        tv_stop_profit_volume_unit.setText(base)
        tv_stop_loss_volume_unit.setText(base)

        mHeaderKit?.setFilterTitleContent(CpLanguageUtil.getString(this,"cp_overview_text12"))
        tv_cp_order_quantity.setText(CpLanguageUtil.getString(this,"cp_overview_text8"))
        tv_open_price_key.setText(CpLanguageUtil.getString(this,"cp_order_text30"))
        tv_position_key.setText(CpLanguageUtil.getString(this,"cp_extra_text90"))
        tv_cp_order_text31.setText(CpLanguageUtil.getString(this,"cp_order_text31"))
        tv_cp_calculator_text33.setText(CpLanguageUtil.getString(this,"cp_calculator_text33"))
        tv_cp_stoporder_text1.setText(CpLanguageUtil.getString(this,"cp_stoporder_text1"))
        tv_cp_stoporder_text2.setText(CpLanguageUtil.getString(this,"cp_stoporder_text2"))
        tv_order_type.setText(CpLanguageUtil.getString(this,"cp_overview_text53"))
        tv_cp_overview_text15.setText(CpLanguageUtil.getString(this,"cp_overview_text15"))
        tv_cp_order_text36.setText(CpLanguageUtil.getString(this,"cp_order_text36"))
        tv_cp_overview_text16.setText(CpLanguageUtil.getString(this,"cp_overview_text16"))
        tv_cp_order_text37.setText(CpLanguageUtil.getString(this,"cp_order_text37"))
        tv_cp_order_text35.setText(CpLanguageUtil.getString(this,"cp_order_text35"))
        tv_confirm_btn.setContent(CpLanguageUtil.getString(this,"cp_calculator_text16"))
        et_stop_profit_trigger_price.setHint(CpLanguageUtil.getString(this,"cp_content_text31"))
        et_stop_profit_price.setHint(CpLanguageUtil.getString(this,"cp_content_text31"))
        et_stop_loss_trigger_price.setHint(CpLanguageUtil.getString(this,"cp_content_text31"))
        et_stop_loss_price.setHint(CpLanguageUtil.getString(this,"cp_content_text31"))

        var orderSideStr=""
        if (mContractPositionBean?.orderSide.equals("BUY")) {
            orderSideStr="多"
            tv_type.setText( CpLanguageUtil.getString(this,"cp_order_text6"))
        }else{
            orderSideStr="空"
            tv_type.setText( CpLanguageUtil.getString(this,"cp_order_text15"))
        }

        var mPositionVolumeStr = if (CpClLogicContractSetting.getContractUint(CpMyApp.instance()) == 0) {
            mContractPositionBean?.positionVolume
        } else {
            CpBigDecimalUtils.mulStr(mContractPositionBean?.positionVolume, multiplier, multiplierPrecision)
        }

        mCanCloseVolumeStr = if (CpClLogicContractSetting.getContractUint(CpMyApp.instance()) == 0) {
            mContractPositionBean?.canCloseVolume.toString()
        } else {
            CpBigDecimalUtils.mulStr(mContractPositionBean?.canCloseVolume, multiplier, multiplierPrecision)
        }

        tv_can_close_volume.setText(mCanCloseVolumeStr + " " + base)
        et_stop_profit_position.setText(mCanCloseVolumeStr)
        tv_position_num.setText(mPositionVolumeStr + "/" + mCanCloseVolumeStr)
        tv_mark_price.setText(CpBigDecimalUtils.showSNormal(mContractPositionBean?.indexPrice, mPricePrecision))

        var reducePriceStr = CpBigDecimalUtils.showSNormal(mContractPositionBean?.reducePrice, mPricePrecision)
        if (CpBigDecimalUtils.compareTo(reducePriceStr, "0") != 1) {
            reducePriceStr = "--"
        }
        tv_force_close_price.setText(reducePriceStr)

        var openAvgPriceStr = CpBigDecimalUtils.showSNormal(mContractPositionBean?.openAvgPrice, mPricePrecision)
        tv_open_price_value.setText(openAvgPriceStr)

        tv_contract_name.setText(CpClLogicContractSetting.getContractShowNameById(this, mContractPositionBean?.contractId!!))


        when (mContractPositionBean?.positionType) {
            1 -> {
                tv_contract_name_lable.setText(CpLanguageUtil.getString(this,"cp_contract_setting_text1")+" " + mContractPositionBean?.leverageLevel + "X")
            }
            2 -> {
                tv_contract_name_lable.setText(CpLanguageUtil.getString(this,"cp_contract_setting_text2")+" " + mContractPositionBean?.leverageLevel + "X")
            }
            else -> {
            }
        }

//        tv_contract_name_lable.setText(orderSideStr+" " + mContractPositionBean?.leverageLevel + "X")

//        tv_contract_name_lable.setBackgroundResource(if (mContractPositionBean?.orderSide.equals("BUY")) R.drawable.cp_border_green_fill else R.drawable.cp_border_red_fill)
        tv_type.setTextColor(CpColorUtil.getMainColorType(mContractPositionBean?.orderSide.equals("BUY")))
    }


    override fun initView() {
        super.initView()


        mSelectRatioView.setRadios(mRatios,initSelectPosition = mRatios.size-1){ value:Float,position:Int,view:View? ->
            if(position==-1){
                et_stop_profit_position.setText("")
                return@setRadios
            }
            val scale = if (CpClLogicContractSetting.getContractUint(CpMyApp.instance()) == 0) 0 else multiplierPrecision

            et_stop_profit_position.setText(CpBigDecimalUtils.mulStrRoundUp(mCanCloseVolumeStr, value.toString(), scale))
        }


        initAutoTextView()



        et_stop_profit_trigger_price?.setOnFocusChangeListener { _, hasFocus ->
            ll_trigger_price?.setBackgroundResource(if (hasFocus) R.drawable.bg_selected_contract else R.drawable.bg_select_contract)
        }


        et_stop_loss_trigger_price?.setOnFocusChangeListener { _, hasFocus ->
            ll_stop_loss_trigger_price?.setBackgroundResource(if (hasFocus) R.drawable.bg_selected_contract else R.drawable.bg_select_contract)
        }



        orderList = ArrayList();
//        if (isStopProfitMarket) {
//            tv_market_price_hint.visibility = View.VISIBLE
//            et_stop_profit_price.visibility = View.GONE
//            tv_stop_profit_coin_name.visibility = View.GONE
//            tv_stop_profit_price_hint?.setBackgroundResource(R.drawable.bg_selected_bbo)
//            tv_stop_profit_price_hint?.setTextColor(CpColorUtil.getColor(R.color.main_blue))
//            et_stop_profit_price.requestFocus()
//        } else {
//            tv_market_price_hint.visibility = View.GONE
//            et_stop_profit_price.visibility = View.VISIBLE
//            tv_stop_profit_coin_name.visibility = View.VISIBLE
//            tv_stop_profit_price_hint?.setBackgroundResource(R.drawable.bg_select_contract)
//            tv_stop_profit_price_hint?.setTextColor(CpColorUtil.getColor(R.color.normal_text_color))
//            et_stop_profit_price.clearFocus()
//        }

//        if (isStopLossMarket) {
//            tv_market_loss_price_hint.visibility = View.VISIBLE
//            et_stop_loss_price.visibility = View.GONE
//            tv_stop_loss_coin_name.visibility = View.GONE
//            tv_stop_loss_price_hint?.setBackgroundResource(R.drawable.bg_selected_bbo)
//            tv_stop_loss_price_hint?.setTextColor(CpColorUtil.getColor(R.color.main_blue))
//            et_stop_loss_price.requestFocus()
//        } else {
//            tv_market_loss_price_hint.visibility = View.GONE
//            et_stop_loss_price.visibility = View.VISIBLE
//            tv_stop_loss_coin_name.visibility = View.VISIBLE
//            tv_stop_loss_price_hint?.setBackgroundResource(R.drawable.bg_select_contract)
//            tv_stop_loss_price_hint?.setTextColor(CpColorUtil.getColor(R.color.normal_text_color))
//            et_stop_loss_price.clearFocus()
//        }

        et_stop_profit_price?.setOnFocusChangeListener { _, hasFocus ->
            ll_stop_profit_price?.setBackgroundResource(if (hasFocus) R.drawable.bg_selected_contract else R.drawable.bg_select_contract)
            if (hasFocus) {
                isStopProfitMarket = false
            }
        }

        et_stop_loss_price?.setOnFocusChangeListener { _, hasFocus ->
            ll_stop_loss_price?.setBackgroundResource(if (hasFocus) R.drawable.bg_selected_contract else R.drawable.bg_select_contract)
            if (hasFocus) {
                isStopProfitMarket = false
            }
        }

        //Switch the market price button No
//        tv_stop_profit_price_hint.setSafeListener {
//            isStopProfitMarket = !isStopProfitMarket
//            if (isStopProfitMarket) {
//                tv_market_price_hint.visibility = View.VISIBLE
//                et_stop_profit_price.isEnabled = false
////                et_stop_profit_price.visibility = View.GONE
////                tv_stop_profit_coin_name.visibility = View.GONE
//                tv_stop_profit_price_hint?.setBackgroundResource(R.drawable.bg_selected_bbo)
//
////                tv_stop_profit_price_hint?.setTextColor(CpColorUtil.getColor(R.color.main_blue))
////                et_stop_profit_price.clearFocus()
//            } else {
//                tv_market_price_hint.visibility = View.GONE
//                et_stop_profit_price.isEnabled = true
////                et_stop_profit_price.visibility = View.VISIBLE
////                tv_stop_profit_coin_name.visibility = View.VISIBLE
//                tv_stop_profit_price_hint?.setBackgroundResource(R.drawable.bg_select_contract)
////                tv_stop_profit_price_hint?.setTextColor(CpColorUtil.getColor(R.color.normal_text_color))
////                et_stop_profit_price.requestFocus()
//            }
//        }

        //Market price button No
//        tv_stop_loss_price_hint.setSafeListener {
//            isStopLossMarket = !isStopLossMarket
//            if (isStopLossMarket) {
//                tv_market_loss_price_hint.visibility = View.VISIBLE
//                et_stop_loss_price.isEnabled = false
////                et_stop_loss_price.visibility = View.GONE
////                tv_stop_loss_coin_name.visibility = View.GONE
//                tv_stop_loss_price_hint?.setBackgroundResource(R.drawable.bg_selected_bbo)
////                tv_stop_loss_price_hint?.setTextColor(CpColorUtil.getColor(R.color.main_blue))
////                et_stop_loss_price.clearFocus()
//            } else {
//                tv_market_loss_price_hint.visibility = View.GONE
//                et_stop_loss_price.isEnabled = true
////                et_stop_loss_price.visibility = View.VISIBLE
////                tv_stop_loss_coin_name.visibility = View.VISIBLE
//                tv_stop_loss_price_hint?.setBackgroundResource(R.drawable.bg_select_contract)
////                tv_stop_loss_price_hint?.setTextColor(CpColorUtil.getColor(R.color.normal_text_color))
////                et_stop_loss_price.requestFocus()
//            }
//        }

        btn_cancel_stop_profit.setSafeListener {
            var buff = StringBuffer()
            for (i in 0..(mTakeProfitList.length() - 1)) {
                var obj: JSONObject = mTakeProfitList.get(i) as JSONObject
                buff.append(obj.optString("id"))
                buff.append(",")
            }
            val buff1 = buff.substring(0, buff.length - 1)
            cancelProfitStopLossOrder(buff1)
        }

        btn_cancel_stop_loss.setSafeListener {
            var buff = StringBuffer()
            for (i in 0..(mStopLossList.length() - 1)) {
                var obj: JSONObject = mStopLossList.get(i) as JSONObject
                buff.append(obj.optString("id"))
                buff.append(",")
            }
            val buff1 = buff.substring(0, buff.length - 1)
            cancelProfitStopLossOrder(buff1)
        }

        tv_stop_loss_tip.setSafeListener {
            CpSlDialogHelper.showSubmitProfitLossDetailsDialog(this@CpContractStopRateLossActivity)
        }

        ll_order_type.setOnClickListener {
            img_order_type.animate().setDuration(300).rotation(180f).start()
            CpDialogUtil.createOrderTypePop(this, orderType, it, object : CpNewDialogUtils.DialogOnSigningItemClickListener {
                override fun clickItem(position: Int, text: String) {
                    tv_order_type.setText(text)
                    orderType=position
                    when (position) {
                        1 -> {
                            isLimit = false
                        }
                        2 -> {
                            isLimit = true
                        }
                    }
                    pview_ll_stop_profit_price.visibility = if (isLimit) View.VISIBLE else View.GONE
                    pview_ll_stop_loss_price.visibility = if (isLimit) View.VISIBLE else View.GONE
                    et_stop_profit_trigger_price.setText("")
                    et_stop_profit_price.setText("")
                    et_stop_loss_trigger_price.setText("")
                    et_stop_loss_price.setText("")

                    setSubmitBtnStatus()
                }
            }, object : CpNewDialogUtils.DialogOnDismissClickListener {
                override fun clickItem() {
                    img_order_type.animate().setDuration(300).rotation(0f).start()
                }
            },dgWidth = CpSizeUtils.dp2px(192.0f))
        }

        et_stop_profit_trigger_price.addTextChangedListener(this)
        et_stop_profit_price.addTextChangedListener(this)
        et_stop_loss_trigger_price.addTextChangedListener(this)
        et_stop_loss_price.addTextChangedListener(this)
        et_stop_profit_position.addTextChangedListener(this)

//        ll_stop_profit_price.visibility = if (isLimit) View.VISIBLE else View.GONE
//        ll_stop_loss_price.visibility = if (isLimit) View.VISIBLE else View.GONE
    }

    private fun initAutoTextView() {
//        title_layout.title = getLineText("cl_stoporder_titletext")
    }
//
//
////Check whether the input result meets the click criteria
//    private fun doCheckInputValue():Boolean{
////Stop Profit Trigger Price!
//        val et_stop_profit_trigger_price_str = et_stop_profit_trigger_price.text.toString()
////Stop profit commission price!
//        val et_stop_profit_price_str = et_stop_profit_price.text.toString()
//
//        val et_stop_loss_trigger_price_str = et_stop_loss_trigger_price.text.toString()
//        val et_stop_loss_price_str = et_stop_loss_price.text.toString()
//
////Quantity
//        var et_stop_position_str = et_stop_profit_position.text.toString()
//
//        if(cb_tab_stop_profit.isChecked){
//            if(TextUtils.isEmpty(et_stop_profit_trigger_price_str)) return false
//            if(isLimit){
//                if(!isStopProfitMarket){
//                    if(TextUtils.isEmpty(et_stop_profit_trigger_price_str)){
//
//                    }
//                }
//            }
//        }
//        if(cb_tab_stop_loss.isChecked){
//            if(TextUtils.isEmpty(et_stop_loss_trigger_price_str)) return false
//        }
//
//        if(isLimit){
//            return TextUtils.isEmpty(et_stop_profit_trigger_price_str) ||
//            TextUtils.isEmpty(et_stop_loss_trigger_price_str)
//
//        }else{
//            return false
//        }
//
//    }

    private fun initListener() {
//        et_stop_profit_trigger_price.numberFilter(3)
//        et_stop_profit_price.numberFilter(3)
//        et_stop_profit_position.numberFilter(0)
//
//        et_stop_loss_trigger_price.numberFilter(3)
//        et_stop_loss_price.numberFilter(3)
//        et_stop_loss_position.numberFilter(0)
        pview_ll_stop_profit_price.visibility = if (isLimit) View.VISIBLE else View.GONE
        pview_ll_stop_loss_price.visibility = if (isLimit) View.VISIBLE else View.GONE

        et_stop_profit_trigger_price.setText("")
        et_stop_profit_price.setText("")
        et_stop_loss_trigger_price.setText("")
        et_stop_loss_price.setText("")

        cb_tab_stop_profit.isChecked = true
        cb_tab_stop_loss.isChecked = true

        ll_tab_layout_stop_profit.setSafeListener {
            if (cb_tab_stop_loss.isChecked){
                cb_tab_stop_profit.isChecked = !cb_tab_stop_profit.isChecked
                ll_stop_profit.visibility = if (cb_tab_stop_profit.isChecked) View.VISIBLE else View.GONE
                setSubmitBtnStatus()
            }
        }
        ll_tab_layout_stop_loss.setSafeListener {
            if(cb_tab_stop_profit.isChecked){
                cb_tab_stop_loss.isChecked = !cb_tab_stop_loss.isChecked
                ll_stop_loss.visibility = if (cb_tab_stop_loss.isChecked) View.VISIBLE else View.GONE
                setSubmitBtnStatus()
            }
        }

        tv_confirm_btn.isEnable(false)
        tv_confirm_btn.listener = object : CpCommonlyUsedButton.OnBottonListener {
            override fun bottonOnClick() {
                if (!cb_tab_stop_profit.isChecked && !cb_tab_stop_loss.isChecked) {
                    return
                }
                var orderType = 1;
                orderList.clear()
                var profit_title = ""
                var loss_title = ""
                var profit_info = ""
                var loss_info = ""
                /**
                请输入止盈触发价！
                请输入止损触发价！
                请输入止盈委托价！
                请输入止损委托价！
                请输入止盈止损数量！
                 */
                if (cb_tab_stop_profit.isChecked) {
                    orderType = if (isLimit) 1 else 2
                    //Stop Profit Trigger Price!
                    val et_stop_profit_trigger_price_str = et_stop_profit_trigger_price.text.toString()
                    //Stop profit commission price!
                    val et_stop_profit_price_str = et_stop_profit_price.text.toString()
                    //Quantity
                    var et_stop_profit_position_str = et_stop_profit_position.text.toString()

                    if (TextUtils.isEmpty(et_stop_profit_trigger_price_str)) {
                        CpNToastUtil.showTopToastNet(this@CpContractStopRateLossActivity, false,  CpLanguageUtil.getString(this@CpContractStopRateLossActivity,"cp_extra_text104"))
                        return
                    }
                    if (TextUtils.isEmpty(et_stop_profit_price_str) && isLimit) {
                        CpNToastUtil.showTopToastNet(this@CpContractStopRateLossActivity, false,  CpLanguageUtil.getString(this@CpContractStopRateLossActivity,"cp_extra_text105"))
                        return
                    }
                    if (TextUtils.isEmpty(et_stop_profit_position_str)) {
                        CpNToastUtil.showTopToastNet(this@CpContractStopRateLossActivity, false,  CpLanguageUtil.getString(this@CpContractStopRateLossActivity,"cp_extra_text106"))
                        return
                    }


                    if (CpClLogicContractSetting.getContractUint(CpMyApp.instance()) == 1) {
                        et_stop_profit_position_str = CpBigDecimalUtils.getOrderLossNum(et_stop_profit_position_str, multiplier)
                    }
                    orderList.add(CpTpslOrderBean("2", if (!isLimit) "0" else et_stop_profit_price_str, et_stop_profit_position_str, et_stop_profit_trigger_price_str, orderType.toString(), CpClLogicContractSetting.getStrategyEffectTimeStr(mActivity)))
                    if (isLimit) {
                        profit_title = CpLanguageUtil.getString(this@CpContractStopRateLossActivity,"cp_extra_text99")
                        profit_info = String.format(CpLanguageUtil.getString(this@CpContractStopRateLossActivity,"cp_extra_text92"), et_stop_profit_trigger_price_str, et_stop_profit_position.text.toString(), base, et_stop_profit_price_str)
                    } else {
                        profit_title = CpLanguageUtil.getString(this@CpContractStopRateLossActivity,"cp_extra_text97")
                        profit_info = String.format(CpLanguageUtil.getString(this@CpContractStopRateLossActivity,"cp_extra_text91"), et_stop_profit_trigger_price_str, et_stop_profit_position.text.toString(), base)
                    }
                }
                if (cb_tab_stop_loss.isChecked) {
                    orderType = if (isLimit) 1 else 2
                    val et_stop_loss_trigger_price_str = et_stop_loss_trigger_price.text.toString()
                    val et_stop_loss_price_str = et_stop_loss_price.text.toString()
                    var et_stop_loss_position_str = et_stop_profit_position.text.toString()
                    if (TextUtils.isEmpty(et_stop_loss_trigger_price_str)) {
                        CpNToastUtil.showTopToastNet(this@CpContractStopRateLossActivity, false,  CpLanguageUtil.getString(this@CpContractStopRateLossActivity,"cp_extra_text101"))
                        return
                    }
                    if (TextUtils.isEmpty(et_stop_loss_price_str) && isLimit) {
                        CpNToastUtil.showTopToastNet(this@CpContractStopRateLossActivity, false,  CpLanguageUtil.getString(this@CpContractStopRateLossActivity,"cp_extra_text102"))
                        return
                    }
                    if (TextUtils.isEmpty(et_stop_loss_position_str)) {
                        CpNToastUtil.showTopToastNet(this@CpContractStopRateLossActivity, false,  CpLanguageUtil.getString(this@CpContractStopRateLossActivity,"cp_extra_text103"))
                        return
                    }
                    if (CpClLogicContractSetting.getContractUint(CpMyApp.instance()) == 1) {
                        et_stop_loss_position_str = CpBigDecimalUtils.getOrderLossNum(et_stop_loss_position_str, multiplier)
                    }
                    orderList.add(CpTpslOrderBean("1", if (!isLimit) "0" else et_stop_loss_price_str, et_stop_loss_position_str, et_stop_loss_trigger_price_str, orderType.toString(), CpClLogicContractSetting.getStrategyEffectTimeStr(mActivity)))
                    if (isLimit) {
                        loss_title = CpLanguageUtil.getString(this@CpContractStopRateLossActivity,"cp_extra_text100")
                        loss_info = String.format(CpLanguageUtil.getString(this@CpContractStopRateLossActivity,"cp_extra_text92"), et_stop_loss_trigger_price_str, et_stop_profit_position.text.toString(), base, et_stop_loss_price_str)
                    } else {
                        loss_title = CpLanguageUtil.getString(this@CpContractStopRateLossActivity,"cp_extra_text98")
                        loss_info = String.format(CpLanguageUtil.getString(this@CpContractStopRateLossActivity,"cp_extra_text93"), et_stop_loss_trigger_price_str, et_stop_profit_position.text.toString(), base)
                    }
                }

                if(!doSafeChecking()) return

                val tradeConfirm = CpPreferenceManager.getInstance(CpMyApp.instance())
                        .getSharedBoolean(CpPreferenceManager.PREF_LOSS_CONFIRM, true)
                if (tradeConfirm){
                    CpSlDialogHelper.showSubmitProfitLossDetailsDialog(
                            this@CpContractStopRateLossActivity,
                            object : CpNewDialogUtils.DialogBottomListener {
                                override fun sendConfirm() {
                                    createTpslOrder()
                                }
                            },
                            if (cb_tab_stop_profit.isChecked) profit_title else "",
                            if (cb_tab_stop_loss.isChecked) loss_title else "",
                            profit_info,
                            loss_info)
                }else{
                    createTpslOrder()
                }
            }
        }
        cp_loss_trade.setOnSelectionChangedListener(object : CpUISegmentedView.OnSelectionChangedListener {
            override fun onSelectionChanged(position: Int, value: String?) {

            }

            override fun onSelectionChanged(position: Int) {
                val scale = if (CpClLogicContractSetting.getContractUint(CpMyApp.instance()) == 0) 0 else multiplierPrecision
                when (position) {
                    0 -> {
                        et_stop_profit_position.setText(CpBigDecimalUtils.mulStr(mCanCloseVolumeStr, "0.1", scale))
                    }
                    1 -> {
                        et_stop_profit_position.setText(CpBigDecimalUtils.mulStr(mCanCloseVolumeStr, "0.2", scale))
                    }
                    2 -> {
                        et_stop_profit_position.setText(CpBigDecimalUtils.mulStr(mCanCloseVolumeStr, "0.5", scale))
                    }
                    3 -> {
                        et_stop_profit_position.setText(CpBigDecimalUtils.mulStr(mCanCloseVolumeStr, "1", scale))
                    }
                }

            }
        })

//        for (buff in 0 ..rg_trade?.childCount?.toInt()!!-1){
//            rg_trade.getChildAt(buff).setOnClickListener {
//                rg_trade.check(it.id)
//                et_stop_profit_position.clearFocus()
//                val scale = if (CpClLogicContractSetting.getContractUint(CpMyApp.instance()) == 0) 0 else multiplierPrecision
//                when(it.id){
//                    R.id.rb_1st -> {
//                        et_stop_profit_position.setText(CpBigDecimalUtils.mulStrRoundUp(mCanCloseVolumeStr, "0.1", scale))
//                    }
//                    R.id.rb_2nd -> {
//                        et_stop_profit_position.setText(CpBigDecimalUtils.mulStrRoundUp(mCanCloseVolumeStr, "0.2", scale))
//                    }
//                    R.id.rb_3rd -> {
//                        et_stop_profit_position.setText(CpBigDecimalUtils.mulStrRoundUp(mCanCloseVolumeStr, "0.5", scale))
//                    }
//                    R.id.rb_4th -> {
//                        et_stop_profit_position.setText(CpBigDecimalUtils.mulStrRoundUp(mCanCloseVolumeStr, "1", scale))
//                    }
//                }
//            }
//        }

        et_stop_profit_position.setOnFocusChangeListener(object :View.OnFocusChangeListener{
            override fun onFocusChange(p0: View?, p1: Boolean) {
                if (p1){
//                    rg_trade.clearCheck()
                    mSelectRatioView?.resetViewColor()
                }
            }
        })
//        sv_trade.setOnSelectionChangedListener(object : CpUISegmentedView.OnSelectionChangedListener {
//            override fun onSelectionChanged(position: Int, value: String?) {
//
//            }
//
//            override fun onSelectionChanged(position: Int) {
//                when (position) {
//                    0 -> {
//                        isLimit = false
//                    }
//                    1 -> {
//                        isLimit = true
//                    }
//                }
//                ll_stop_profit_price.visibility = if (isLimit) View.VISIBLE else View.GONE
//                ll_stop_loss_price.visibility = if (isLimit) View.VISIBLE else View.GONE
//                et_stop_profit_trigger_price.setText("")
//                et_stop_profit_price.setText("")
//                et_stop_loss_trigger_price.setText("")
//                et_stop_loss_price.setText("")
//            }
//        })

        getTakeProfitStopLoss()
    }

    private fun doSafeChecking():Boolean {
        if(this::mContractJsonStr.isInitialized){
            val coinResultVo = mContractJsonStr.optJSONObject("coinResultVo")
            val minOrderVolume = coinResultVo.optString("minOrderVolume")
            val volume = et_stop_profit_position.text.toString()

            val minMessage:String = if(CpClLogicContractSetting.getContractUint(this) == 0) {
                minOrderVolume
            }else{
                CpBigDecimalUtils.mulStr(minOrderVolume,multiplier,multiplierPrecision)
            } + " " + base

            return if (CpBigDecimalUtils.orderNumMinCheck(volume, minOrderVolume, multiplier)) {
                CpNToastUtil.showTopToastNet(
                    this, false,
                    "${CpLanguageUtil.getString(this, "order_placement_text7")} $minMessage"
                )
                false
            }else{
                true
            }
        }
        return false
    }

    private fun createTpslOrder() {
        addDisposable(getContractModel().createTpslOrder(mContractPositionBean?.contractId!!, mContractPositionBean?.id!!,mContractPositionBean?.positionType.toString(), mContractPositionBean?.orderSide.toString(), mContractPositionBean?.leverageLevel!!, orderList,
                orderUnit = if(CpClLogicContractSetting.getContractUint(CpMyApp.instance()) == 0) 0 else 2,
                consumer = object : CpNDisposableObserver(mActivity, true) {
                    override fun onResponseSuccess(jsonObject: JSONObject?) {
                        CpNToastUtil.showTopToastNet(this.mActivity, true, CpLanguageUtil.getString(this@CpContractStopRateLossActivity,"cp_extra_text109"))
                        CpEventBusUtil.post(
                                CpMessageEvent(
                                        CpMessageEvent.sl_contract_modify_position_margin_event
                                )
                        )
                        finish()
//                        val errorMsg = StringBuffer()
//                        jsonObject.optJSONObject("data").run {
//                            val respList = optJSONArray("respList")
//                            for (i in 0..(respList.length() - 1)) {
//                                var obj: JSONObject = respList.get(i) as JSONObject
//                                val code = obj.optString("code")
//                                val msg = obj.optString("msg")
//                                if (!code.equals("0")) {
//                                    errorMsg.append(msg)
//                                }
//                            }
//                        }
//                        if (!TextUtils.isEmpty(errorMsg)) {
//                            CpNToastUtil.showTopToastNet(this@CpContractStopRateLossActivity, false, errorMsg.toString())
//                        } else {
//                            finish()
//                            CpEventBusUtil.post(
//                                    CpMessageEvent(
//                                            CpMessageEvent.sl_contract_modify_position_margin_event
//                                    )
//                            )
//                        }
                    }
                }))
    }

    /**
     *Obtain the stop profit and stop loss list
     */
    private fun getTakeProfitStopLoss() {
        addDisposable(getContractModel().getTakeProfitStopLoss(mContractPositionBean?.contractId!!.toString(), mContractPositionBean?.orderSide.toString(),
                consumer = object : CpNDisposableObserver(mActivity, true) {
                    override fun onResponseSuccess(jsonObject: JSONObject?) {
                        jsonObject?.optJSONObject("data")?.run {
                            mTakeProfitList = optJSONArray("takeProfitList")
                            mStopLossList = optJSONArray("stopLossList")
//                            btn_cancel_stop_profit.visibility = if (mTakeProfitList.length() == 0) View.GONE else View.VISIBLE
//                            btn_cancel_stop_loss.visibility = if (mStopLossList.length() == 0) View.GONE else View.VISIBLE
//                            btn_cancel_stop_profit.setText(CpLanguageUtil.getString(this,.string.cl_stoporder_text2) + "：" + mTakeProfitList.length())
//                            btn_cancel_stop_loss.setText(CpLanguageUtil.getString(this,.string.cl_stoporder_text8) + "：" + mStopLossList.length())
                        }
                    }
                }))
    }

    /**
     *Cancellation of Stop Profit and Stop Loss Order
     */
    private fun cancelProfitStopLossOrder(orderIds: String) {
        addDisposable(getContractModel().cancelOrderTpsl(mContractPositionBean?.contractId!!.toString(), orderIds,
                consumer = object : CpNDisposableObserver(mActivity, true) {
                    override fun onResponseSuccess(jsonObject: JSONObject?) {
                        getTakeProfitStopLoss()
                    }
                }))
    }

    companion object {
        fun show(activity: Activity, mContractPositionBean: CpContractPositionBean) {
            val intent = Intent(activity, CpContractStopRateLossActivity::class.java)
            intent.putExtra("ContractPositionBean", mContractPositionBean)
            activity.startActivity(intent)
        }
    }

    override fun onCpWsMessage(json: String) {
        ChainUpLogUtil.e(TAG, "止赢止损界面返回数据：" + json)
        val jsonObj = JSONObject(json)
        val channel = jsonObj.optString("channel")
        if (!jsonObj.isNull("tick")) {
            if (!jsonObj.isNull("tick")) {
                val tick = jsonObj.optJSONObject("tick")
                if (channel == CpWsLinkUtils.tickerFor24HLink(currentSymbol, isChannel = true)) {
                    val close = tick.optString("close")
                    this?.runOnUiThread {
                        tv_mark_price.setText(CpBigDecimalUtils.showSNormal(close, mPricePrecision))
                    }
                }
            }
        }
    }

    override fun afterTextChanged(s: Editable?) {

    }

    override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {

    }

    override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {

        //et_ stop_ profit_ trigger_ Price//Stop profit trigger price
        //et_ stop_ profit_ Price//commission price for stopping profit
        //et_ stop_ loss_ trigger_ Price//Stop loss trigger price
        //et_ stop_ loss_ Price//Stop loss commission price
        //et_ stop_ profit_ Position//Number of delegates

        var stop_profit_trigger_price = et_stop_profit_trigger_price.text.toString().trim()//Trigger price
        var stop_profit_price = et_stop_profit_price.text.toString().trim()//Commission price


        var stop_loss_trigger_price = et_stop_loss_trigger_price.text.toString().trim()//Trigger price
        var stop_loss_price = et_stop_loss_price.text.toString().trim()//Commission price
        var stop_loss_position = et_stop_loss_position.text.toString().trim()

        //Quantity
        var stop_profit_position = et_stop_profit_position.text.toString().trim()

        setSubmitBtnStatus()

        val direction = if (mContractPositionBean?.orderSide.equals("BUY")) 0 else 1

        val isForward = if (CpClLogicContractSetting.getContractSideById(this, mContractPositionBean?.contractId!!) == 1) true else false

        val multiplier = CpClLogicContractSetting.getContractMultiplierById(this, mContractPositionBean?.contractId!!)


        var buff = "0"
        if (cb_tab_stop_profit.isChecked) {
            if (TextUtils.isEmpty(stop_profit_trigger_price) || TextUtils.isEmpty(stop_profit_position)) {
                tv_estimate_stop_profit.visibility = View.GONE
            } else {
                if (TextUtils.isEmpty(stop_profit_price) && isLimit){
                    tv_estimate_stop_profit.visibility = View.GONE
                }else{
                    tv_estimate_stop_profit.visibility = View.VISIBLE
                }
            }
            if(
                CpStringUtil.isNumeric(mContractPositionBean?.openAvgPrice)
                && CpStringUtil.isNumeric(stop_profit_trigger_price)
                && if(isLimit) CpStringUtil.isNumeric(stop_profit_price) else true
                && CpStringUtil.isNumeric(stop_profit_position)
                && CpStringUtil.isNumeric(multiplier)
                && CpStringUtil.isNumeric(marginRate)
            ){
                if (CpClLogicContractSetting.getContractUint(CpMyApp.instance()) == 1) {
                    stop_profit_position = CpBigDecimalUtils.getOrderLossNum(stop_profit_position, multiplier)
                }

                buff = CpBigDecimalUtils.calcEstimatedProfitLoss(
                    isForward,
                    direction, isLimit,
                    mContractPositionBean?.openAvgPrice,
                    stop_profit_trigger_price,
                    stop_profit_price,
                    stop_profit_position,
                    multiplier,
                    marginRate,
                    marginCoinPrecision
                )

                if (CpBigDecimalUtils.compareTo(buff, "0") == 1) {
                    tv_estimate_stop_profit.setText(CpLanguageUtil.getString(this,"cp_order_text38")+"：" + buff + " " + mMarginCoin)
                    tv_estimate_stop_profit.setTextColor(CpColorUtil.getMainColorType(true))
                } else {
                    tv_estimate_stop_profit.setText(CpLanguageUtil.getString(this,"cp_extra_text95") +"："+ buff + " " + mMarginCoin)
                    tv_estimate_stop_profit.setTextColor(CpColorUtil.getMainColorType(false))
                }
            }


        }
        stop_profit_position= et_stop_profit_position.text.toString().trim()
        if (cb_tab_stop_loss.isChecked) {
            if (TextUtils.isEmpty(stop_loss_trigger_price) || TextUtils.isEmpty(stop_profit_position)) {
                tv_estimate_loss_profit.visibility = View.GONE
            } else {
                if (TextUtils.isEmpty(stop_loss_price) && isLimit){
                    tv_estimate_loss_profit.visibility = View.GONE
                }else{
                    tv_estimate_loss_profit.visibility = View.VISIBLE
                }
            }
            if(
                CpStringUtil.isNumeric(mContractPositionBean?.openAvgPrice)
                && CpStringUtil.isNumeric(stop_loss_trigger_price)
                && if(isLimit) CpStringUtil.isNumeric(stop_loss_price) else true
                && CpStringUtil.isNumeric(stop_profit_position)
                && CpStringUtil.isNumeric(multiplier)
                && CpStringUtil.isNumeric(marginRate)
            ) {
                if (CpClLogicContractSetting.getContractUint(CpMyApp.instance()) == 1) {
                    stop_profit_position = CpBigDecimalUtils.getOrderLossNum(stop_profit_position, multiplier)
                }

                buff = CpBigDecimalUtils.calcEstimatedProfitLoss(
                    isForward,
                    direction, isLimit,
                    mContractPositionBean?.openAvgPrice,
                    stop_loss_trigger_price,
                    stop_loss_price,
                    stop_profit_position,
                    multiplier,
                    marginRate,
                    marginCoinPrecision
                )

                if (CpBigDecimalUtils.compareTo(buff, "0") == 1) {
                    tv_estimate_loss_profit.setText(CpLanguageUtil.getString(this,"cp_order_text38") +"："+ buff + " " + mMarginCoin)
                    tv_estimate_loss_profit.setTextColor(CpColorUtil.getMainColorType(true))
                } else {
                    tv_estimate_loss_profit.setText(CpLanguageUtil.getString(this,"cp_extra_text95")  +"："+ buff + " " + mMarginCoin)
                    tv_estimate_loss_profit.setTextColor(CpColorUtil.getMainColorType(false))
                }
            }

        }

    }


    //Set Confirm Button Status
    private fun setSubmitBtnStatus(){
        val stop_profit_trigger_price = et_stop_profit_trigger_price.text.toString().trim()//Trigger price
        val stop_profit_price = et_stop_profit_price.text.toString().trim()//Commission price
        val stop_loss_trigger_price = et_stop_loss_trigger_price.text.toString().trim()//Trigger price
        val stop_loss_price = et_stop_loss_price.text.toString().trim()//Commission price
        //Quantity
        val stop_profit_position = et_stop_profit_position.text.toString().trim()

        if(TextUtils.isEmpty(stop_profit_position)){//Quantity is empty
            tv_confirm_btn.isEnable(false)
            return
        }

        if(cb_tab_stop_loss.isChecked){
            //Stop Loss Selection
            if(TextUtils.isEmpty(stop_loss_trigger_price)){
                tv_confirm_btn.isEnable(false)
                return
            }
            if(isLimit){
                //If it is a limit price, it is necessary to determine the stop loss commission price
                if(TextUtils.isEmpty(stop_loss_price)){
                    tv_confirm_btn.isEnable(false)
                    return
                }
            }
        }

        if(cb_tab_stop_profit.isChecked){
            //Stop profit selection
            if(TextUtils.isEmpty(stop_profit_trigger_price)){
                tv_confirm_btn.isEnable(false)
                return
            }
            if(isLimit){
                //If it is a price limit, it is necessary to determine the commission price for stopping profit
                if(TextUtils.isEmpty(stop_profit_price)){
                    tv_confirm_btn.isEnable(false)
                    return
                }
            }
        }

        tv_confirm_btn.isEnable(true)

    }
}
