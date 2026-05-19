package com.yjkj.chainup.new_contract.fragment

import android.content.res.ColorStateList
import android.graphics.Typeface
import android.os.Build
import android.os.Bundle
import android.text.Editable
import android.text.Html
import android.text.TextUtils
import android.text.TextWatcher
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.widget.TextView
import androidx.core.content.ContextCompat
import com.chainup.contract.R
import com.chainup.contract.base.CpNBaseFragment
import com.chainup.contract.bean.CpTabInfo
import com.chainup.contract.eventbus.CpMessageEvent
import com.chainup.contract.ui.fragment.CpCapitalRateFragment
import com.chainup.contract.utils.*
import com.chainup.contract.view.CpCommonlyUsedButton
import com.chainup.contract.view.CpNewDialogUtils
import com.chainup.contract.view.CpSlDialogHelper
import com.chainup.contract.view.bubble.CpBubbleSeekBar
import com.chainup.contract.view.dialog.CpTDialog
import com.chainup.kit.utils.ToastUtils
import com.chainup.kit.utils.numberFilter
import com.yjkj.chainup.manager.CpLanguageUtil
import com.yjkj.chainup.net_new.rxjava.CpNDisposableObserver
import com.yjkj.chainup.new_contract.activity.CpContractCalculateActivity
import kotlinx.android.synthetic.main.cp_fragment_contract_calculate_item.*
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode
import org.jetbrains.anko.backgroundResource
import org.jetbrains.anko.doAsync
import org.jetbrains.anko.uiThread
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject
import java.lang.Exception


/**
 *Qiangping Price
 */
class CpLiquidationPriceFragment : CpNBaseFragment(),TextWatcher {

    override fun setContentView(): Int {
        return R.layout.cp_fragment_contract_calculate_item
    }


    protected val directionList = ArrayList<CpTabInfo>()
    protected var currDirectionInfo: CpTabInfo? = null
    protected var directionDialog: CpTDialog? = null
    private var contractId = 0
    private var leverage = "0"
    private var indexPrice = "0"
    private var keepMarginRate = "0"
    private lateinit var mContractJson: JSONObject
    private lateinit var leverList: JSONArray
    private lateinit var ladderList: JSONArray

    private var isPriceLongClick: Boolean = false
    private var isStartPriceSubClick = false
    private var isStartPricePlusClick = false
    private var coUnit = 0
    private var multiplierCoin = ""
    private var multiplier = "0"
    private var MultiplierCoinPrecision = 0
    private lateinit var leverCeilingObject: JSONObject
    private lateinit var leverCeilingList: ArrayList<Int>
    private var minLeverage = 1
    private var maxLeverage = 100
    private var selectLeverage = 0 //Select lever
    private var minOrderMoneyPrecision:Int = 1
    private val pActivity by lazy { mActivity as? CpContractCalculateActivity }
    private var symbolPricePrecision = 2
    private var marginCoinPrecision = 2
    private var multiplierPrecision = 2

    override fun initView() {
        rb_buy.setText(getLineText("cp_order_text75"))
        rb_sell.setText(getLineText("cp_overview_text14"))
        setButtonBuyOrSellBg(true,rb_buy)
        tv_cp_assets_text5.setText(getLineText("cp_content_text17"))
        tv_cp_calculator_text8.setText(getLineText("cp_calculator_text8"))
        et_input.setHint(getLineText("cp_content_text31"))
        et_open_price.setHint(getLineText("cp_content_text31"))
        et_extras.setHint(getLineText("cp_content_text31"))
        et_position.setHint(getLineText("cp_content_text31"))
        tv_extras_title.setText(getLineText("cp_calculator_text28"))
        tv_position_title.setText(getLineText("cp_order_text43"))
        tv_contract_calculator_tips.setText(getLineText("cp_extra_text148"))
        tv_calc_result.setText(getLineText("cp_calculator_text12"))
        btn_calculate.setContent(getLineText("cp_calculator_text11"))

        tv_level_tip?.visibility = if(pActivity?.currentPositionType==1) View.VISIBLE else View.GONE
        ll_quantity?.visibility = View.GONE

        initListener()

        createDefaultResult()
    }

    private fun initListener() {
        contractId = arguments?.getInt("contractId")!!

//        indexPrice = arguments?.getString("indexPrice")!!
        mContractJson = CpClLogicContractSetting.getContractJsonStrById(mActivity, contractId)
        symbolPricePrecision = CpClLogicContractSetting.getContractSymbolPricePrecisionById(mActivity,contractId)
        val coinResultVo = mContractJson.optJSONObject("coinResultVo")
        val minOrderMoney = coinResultVo?.optString("minOrderMoney")
        minOrderMoneyPrecision = CpBigDecimalUtils.getPrecisionByPrice(minOrderMoney)
        marginCoinPrecision = CpClLogicContractSetting.getContractMarginCoinPrecisionById(mActivity,contractId)
        multiplierPrecision = CpClLogicContractSetting.getContractMultiplierPrecisionById(mActivity,contractId)
        val contractUint = CpClLogicContractSetting.getContractUint(context)
        et_open_price.numberFilter(symbolPricePrecision)
        et_input.numberFilter(0)
        et_extras.numberFilter(if(contractUint==0) 0 else multiplierPrecision)
        et_position?.numberFilter(minOrderMoneyPrecision)
        maxLeverage = mContractJson.optInt("maxLever")
        minLeverage = mContractJson.optInt("minLever")
        selectLeverage = 20

        var showUnit = ""
        if (CpClLogicContractSetting.getContractUint(context) == 0) {
            showUnit = CpLanguageUtil.getString(context,"cp_overview_text9")
        } else {
            showUnit = mContractJson.optString("multiplierCoin")
        }

        tv_extras_title.setText(CpLanguageUtil.getString(context,"cp_calculator_text38"))
//        et_extras.setHint(CpLanguageUtil.getString(this,"cp_calculator_text38"))
        tv_position_title.setText(CpLanguageUtil.getString(context,"cp_calculator_text39"))
//        et_position.setHint(CpLanguageUtil.getString(this,"cp_calculator_text3"9))

        tv_open_price_symbol.setText(mContractJson.optString("quote"))
        tv_extras_symbol.setText(showUnit)//Position Quantity Currency
        tv_position_symbol.setText(mContractJson.optString("marginCoin"))//Amount and currency of deposit
        val maxLeverage = mContractJson.optString("maxLever")
        val minLeverage = mContractJson.optString("minLever")
        val selectLeverage = "20"
        seekbar.configBuilder
                .min(minLeverage.toFloat())
                .max(maxLeverage.toFloat())
                .progress(selectLeverage.toFloat())
                .build()
        seekbar.onProgressChangedListener = object : CpBubbleSeekBar.OnProgressChangedListener {
            override fun onProgressChanged(bubbleSeekBar: CpBubbleSeekBar?, progress: Int, progressFloat: Float) {
                leverage = progress.toString()
                if (progress == 0) leverage = "1"
                tv_leverage.setText(leverage+"X")
            }

            override fun getProgressOnActionUp(bubbleSeekBar: CpBubbleSeekBar?, progress: Int, progressFloat: Float) {
                for (i in 0 until leverList.length()) {
                    try {
                        ChainUpLogUtil.e(TAG, progress.toString())
                        ChainUpLogUtil.e(TAG, leverList.getJSONObject(i).getInt("maxLever").toString())
                        if (progress <= leverList.getJSONObject(i).getInt("maxLever")) {
                            tv_amount_user_max.setText(CpLanguageUtil.getString(context,"cp_extra_text120"))
                            tv_amount_user_max_value.text = leverList.getJSONObject(i).getString("maxHoldAmount") + " BTC"
                            break
                        }
                    } catch (e: JSONException) {
                        e.printStackTrace()
                    }
                }
            }

            override fun getProgressOnFinally(bubbleSeekBar: CpBubbleSeekBar?, progress: Int, progressFloat: Float) {
            }
        }


        //Direction
        directionList.add(CpTabInfo(CpLanguageUtil.getString(context,"cp_overview_text13"), 0))
        directionList.add(CpTabInfo(CpLanguageUtil.getString(context,"cp_overview_text14"), 1))
        currDirectionInfo = directionList[0]
        tv_direction_value.text = currDirectionInfo?.name
        rb_buy.setOnClickListener {
            changeBuyOrSellUI("buy")
            currDirectionInfo = directionList[0]
        }

        rb_sell.setOnClickListener {
            changeBuyOrSellUI("sell")
            currDirectionInfo = directionList[1]
        }

        //Direction
        rl_direction_layout.setOnClickListener {
            directionDialog = CpNewDialogUtils.showNewBottomListDialog(mActivity!!, directionList, currDirectionInfo!!.index, object : CpNewDialogUtils.DialogOnItemClickListener {
                override fun clickItem(index: Int) {
                    currDirectionInfo = directionList[index]
                    directionDialog?.dismiss()
                    tv_direction_value.text = currDirectionInfo?.name
                }
            })
        }
//        btn_calculate.isEnable(true)
        btn_calculate.listener = object : CpCommonlyUsedButton.OnBottonListener {
            override fun bottonOnClick() {
                var etPositionStr = et_position.text.toString()
                var etOpenPriceStr = et_open_price.text.toString()
                var etClosePriceStr = et_extras.text.toString()
                var etLevelStr = et_input.text.toString()



//                if (TextUtils.isEmpty(etPositionStr)|| CpBigDecimalUtils.compareTo(etPositionStr,"0")!=1){
//                    CpNToastUtil.showTopToastNet(this@CpLiquidationPriceFragment.mActivity,false, CpLanguageUtil.getString(context,"cp_extra_text36"))
//                    return
//                }
                if (TextUtils.isEmpty(etOpenPriceStr)|| CpBigDecimalUtils.compareTo(etOpenPriceStr,"0")!=1){
                    CpNToastUtil.showTopToastNet(this@CpLiquidationPriceFragment.mActivity,false, CpLanguageUtil.getString(context,"cp_extra_text35"))
                    return
                }
                if (TextUtils.isEmpty(etClosePriceStr)|| CpBigDecimalUtils.compareTo(etClosePriceStr,"0")!=1){
                    CpNToastUtil.showTopToastNet(this@CpLiquidationPriceFragment.mActivity,false, CpLanguageUtil.getString(context,"cp_extra_text37"))
                    return
                }

                if (CpClLogicContractSetting.getContractUint(context) == 1) {
                    etClosePriceStr = etClosePriceStr
                } else {
                    etClosePriceStr = CpBigDecimalUtils.mulStr(etClosePriceStr,multiplier,
                        CpClLogicContractSetting.getContractMultiplierPrecisionById(context,mContractJson.optInt("id")))
                }

                var progress = CpBigDecimalUtils.mul(etOpenPriceStr, etClosePriceStr, 0).toInt()
                if(this@CpLiquidationPriceFragment::ladderList.isInitialized) {
                    for (i in 0 until ladderList.length()) {
                        try {
                            if (progress <= ladderList.getJSONObject(i)
                                    .getInt("maxPositionValue")
                            ) {
                                keepMarginRate =
                                    ladderList.getJSONObject(i).getString("minMarginRate")
                                break
                            }
                        } catch (e: JSONException) {
                            e.printStackTrace()
                        }
                    }
                }

                var marginRate = mContractJson.optString("marginRate")

                val multiplier=mContractJson.optString("multiplier")

                val forceClosePrice = if(pActivity?.currentPositionType==1){
                    CpBigDecimalUtils.calcForceClosePriceValue(
                        mContractJson.optString("contractSide").equals("1"),
                        currDirectionInfo?.index!!,
                        etPositionStr,
                        etClosePriceStr,
                        etOpenPriceStr,
                        keepMarginRate,
                        marginRate,
                        CpClLogicContractSetting.getContractSymbolPricePrecisionById(mActivity,contractId))
                }else if(pActivity?.currentPositionType==0){
                    CpBigDecimalUtils.calcForceClosePriceForIsolated(
                        mContractJson.optString("contractSide").equals("1"),
                        currDirectionInfo?.index!!,
                        etLevelStr,
                        etClosePriceStr,
                        etOpenPriceStr,
                        keepMarginRate,
                        marginRate,
                        CpClLogicContractSetting.getContractSymbolPricePrecisionById(mActivity,contractId))
                }else {
                    "0"
                }

                if (CpBigDecimalUtils.compareTo("0",forceClosePrice)>=0){
                    CpNToastUtil.showTopToastNet(this@CpLiquidationPriceFragment.mActivity,false, CpLanguageUtil.getString(context,"cp_extra_text39"))
                    return
                }
                if(pActivity?.currentPositionType==1){
                    val openMargin = CpBigDecimalUtils.calcOpenMargin(
                        mContractJson.optString("contractSide").equals("1"),
                        etLevelStr,
                        etClosePriceStr,
                        etOpenPriceStr,
                        CpClLogicContractSetting.getContractSymbolPricePrecisionById(mActivity,contractId)
                    )
                    if(CpBigDecimalUtils.compareTo(etPositionStr,openMargin)==-1){
                        ToastUtils.showToast(this@CpLiquidationPriceFragment.mActivity, CpLanguageUtil.getString(context,"cp_calculator_text44"))
                        return
                    }
                }



                val tabList = ArrayList<CpTabInfo>()
                tabList.add(CpTabInfo(CpLanguageUtil.getString(context,"cp_calculator_text4"), forceClosePrice + mContractJson.optString("quote")))
                createResult(tabList)
//                CpSlDialogHelper.showCalculatorResultDialog(mActivity!!, tabList)
            }
        }
        tv_add?.setOnTouchListener { _, event ->
            isPriceLongClick = true
            isStartPricePlusClick = true
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    var inputLeverage = CpBigDecimalUtils.add(et_input.text.toString(), "1").toPlainString()
                    et_input?.setText(CpBigDecimalUtils.subZeroAndDot(inputLeverage))

                    doAsync {
                        while (isPriceLongClick) {
                            Thread.sleep(100L)
                            if (!isStartPricePlusClick) continue
                            inputLeverage = try {
                                CpBigDecimalUtils.add(et_input.text.toString(), "1").toPlainString()
                            } catch (e: NumberFormatException) {
                                ""
                            }

                            uiThread {
                                et_input?.setText(CpBigDecimalUtils.subZeroAndDot(inputLeverage))
                            }

                        }
                    }

                    return@setOnTouchListener true
                }
                MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                    isPriceLongClick = false
                    isStartPricePlusClick = false
                }
            }
            true
        }
        tv_sub?.setOnTouchListener { _, event ->
            isPriceLongClick = true
            isStartPriceSubClick = true
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    var inputLeverage = CpBigDecimalUtils.sub(et_input.text.toString(), "1").toPlainString()
                    et_input?.setText(CpBigDecimalUtils.subZeroAndDot(inputLeverage))

                    doAsync {
                        while (isPriceLongClick) {
                            Thread.sleep(100L)
                            if (!isStartPriceSubClick) continue
                            inputLeverage = try {
                                CpBigDecimalUtils.sub(et_input.text.toString(), "1").toPlainString()
                            } catch (e: NumberFormatException) {
                                ""
                            }
                            uiThread {
                                et_input?.setText(CpBigDecimalUtils.subZeroAndDot(inputLeverage))
                            }

                        }
                    }

                    return@setOnTouchListener true
                }
                MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                    isPriceLongClick = false
                    isStartPriceSubClick = false
                }
            }
            true
        }

        et_open_price.addTextChangedListener(this)
        et_extras.addTextChangedListener(this)
        et_position.addTextChangedListener(this)
        et_input.addTextChangedListener(this)
        getLadderInfo()
    }

    //Generate Results
    private fun createResult(list: List<CpTabInfo>?){
        resultContent.visibility = View.VISIBLE
        //The old result was a dialog
//        CpSlDialogHelper.showCalculatorResultDialog(mActivity!!, tabList)
        val layoutInflater = LayoutInflater.from(context)
        ll_fee_warp_layout.removeAllViews()
        for (index in list!!.indices) {
            val info = list[index]
            val itemView = layoutInflater.inflate(R.layout.cp_auto_relative_item, ll_fee_warp_layout, false)
            itemView.findViewById<TextView>(R.id.tv_left).text = info.name
            itemView.findViewById<TextView>(R.id.tv_right).text = Html.fromHtml(info.extras)
            ll_fee_warp_layout.addView(itemView)
        }
    }

    private fun createDefaultResult(){
        resultContent.visibility = View.VISIBLE
        val tabList = ArrayList<CpTabInfo>()
        tabList.add(CpTabInfo(CpLanguageUtil.getString(context,"cp_calculator_text4"), "--" + mContractJson.optString("quote")))
        createResult(tabList)
    }

    private fun getLadderInfo() {
        leverCeilingList=ArrayList()
        multiplierCoin = mContractJson.optString("multiplierCoin")
        multiplier = mContractJson.optString("multiplier")
        MultiplierCoinPrecision = CpClLogicContractSetting.getContractMultiplierPrecisionById(mActivity, contractId)
        coUnit = CpClLogicContractSetting.getContractUint(mActivity)
        addDisposable(getContractModel().getLadderInfo(contractId.toString(),
                consumer = object : CpNDisposableObserver() {
                    override fun onResponseSuccess(jsonObject: JSONObject?) {
                        jsonObject?.optJSONObject("data")?.run {
                            leverList = optJSONObject("leverList").optJSONArray("leverList")
                            ladderList = optJSONObject("ladderList").optJSONArray("ladderList")
                            try {
                                leverCeilingObject = optJSONObject("leverCeiling")
                                val iteratorKeys = leverCeilingObject.keys()
                                while (iteratorKeys.hasNext()) {
                                    val key = iteratorKeys.next().toString()
                                    leverCeilingList.add(key.toInt())
                                }
                            } catch (e: Exception) {
                            } finally {
                                initSeekBarUi()
                            }
                        }
                    }
                }))
    }

    @Subscribe(threadMode = ThreadMode.POSTING)
    override fun onMessageEvent(event: CpMessageEvent) {
        when (event.msg_type) {
            CpMessageEvent.sl_contract_calc_switch_contract_event -> {
                et_position.setText("")
                et_open_price.setText("")
                et_extras.setText("")
                contractId = event.msg_content as Int
                mContractJson = CpClLogicContractSetting.getContractJsonStrById(mActivity, contractId)
                val coinResultVo = mContractJson.optJSONObject("coinResultVo")
                val minOrderMoney = coinResultVo?.optString("minOrderMoney")
                minOrderMoneyPrecision = CpBigDecimalUtils.getPrecisionByPrice(minOrderMoney)
                et_position?.numberFilter(minOrderMoneyPrecision)
                changePositionType(pActivity!!.currentPositionType)

                symbolPricePrecision = CpClLogicContractSetting.getContractSymbolPricePrecisionById(mActivity,contractId)
                marginCoinPrecision = CpClLogicContractSetting.getContractMarginCoinPrecisionById(mActivity,contractId)
                multiplierPrecision = CpClLogicContractSetting.getContractMultiplierPrecisionById(mActivity,contractId)
                val contractUint = CpClLogicContractSetting.getContractUint(context)
                et_extras.numberFilter(if(contractUint==0) 0 else multiplierPrecision)
                et_open_price.numberFilter(symbolPricePrecision)

                var showUnit = ""
                if (CpClLogicContractSetting.getContractUint(context) == 0) {
                    showUnit = CpLanguageUtil.getString(context,"cp_overview_text9")
                } else {
                    showUnit = mContractJson.optString("multiplierCoin")
                }
                tv_open_price_symbol.setText(mContractJson.optString("quote"))
                tv_extras_symbol.setText(showUnit)//Position Quantity Currency
                tv_position_symbol.setText(mContractJson.optString("marginCoin"))//Amount and currency of deposit
                 maxLeverage = mContractJson.optInt("maxLever")
                 minLeverage = mContractJson.optInt("minLever")
                seekbar.configBuilder
                        .min(1.toFloat())
                        .max(maxLeverage.toFloat())
                        .progress(leverage.toFloat())
                        .build()
                getLadderInfo()
            }
        }
    }
    private fun initSeekBarUi() {
        seekbar.configBuilder
                .min(1.toFloat())
                .max(maxLeverage.toFloat())
                .progress(selectLeverage.toFloat())
                .build()
        seekbar.onProgressChangedListener = object : CpBubbleSeekBar.OnProgressChangedListener {
            override fun onProgressChanged(bubbleSeekBar: CpBubbleSeekBar?, progress: Int, progressFloat: Float) {
                et_input.setText(progress.toString())
                et_input.setSelection(progress.toString().length)
            }

            override fun getProgressOnActionUp(bubbleSeekBar: CpBubbleSeekBar?, progress: Int, progressFloat: Float) {
            }

            override fun getProgressOnFinally(bubbleSeekBar: CpBubbleSeekBar?, progress: Int, progressFloat: Float) {
            }
        }

        et_input.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(s: Editable?) {
                if (TextUtils.isEmpty(s.toString())) {
                    seekbar.setProgress(minLeverage.toFloat())
                    return
                }
                var leverage = et_input.text.toString().toInt()
                if (leverage > maxLeverage) {
                    et_input.setText("$maxLeverage")
                    et_input.setSelection(maxLeverage.toString().length)
                    leverage = maxLeverage
                }
                if (leverage < minLeverage) {
                    et_input.setText("$minLeverage")
                    et_input.setSelection(minLeverage.toString().length)
                    leverage = minLeverage
                }
                seekbar.setProgress(et_input.text.toString().toFloat())

                leverCeilingList.clear()
                var unit = ""
                if (coUnit == 1) {
                    unit = multiplierCoin
                } else {
                    unit = CpLanguageUtil.getString(context,"cp_overview_text9")
                }
                var max = ""
                if (this@CpLiquidationPriceFragment::leverCeilingObject.isInitialized) {
                    val iteratorKeys = leverCeilingObject.keys()
                    while (iteratorKeys.hasNext()) {
                        val key = iteratorKeys.next().toString()
                        leverCeilingList.add(key.toInt())
                    }

                    var isExist = false
                    for (buff in leverCeilingList) {
                        if (leverage == buff) {
                            isExist = true
                        }
                    }
                    if (!isExist) {
                        leverCeilingList.add(leverage)
                    }
                    leverCeilingList.sort()
                    var indexBuff = 0
                    for (index in leverCeilingList.indices) {
                        if (leverCeilingList[index] == leverage) {
                            indexBuff = index
                        }
                    }
                    if (!isExist) {
                        indexBuff++
                    }
                    max = CpBigDecimalUtils.showSNormal(leverCeilingObject.optString(leverCeilingList[indexBuff].toString()), CpClLogicContractSetting.getContractMultiplierPrecisionById(mActivity, contractId))
                    if (coUnit == 1) {
                    } else {
                        max = CpBigDecimalUtils.divStr(max, multiplier, 0)
                    }
                    tv_amount_user_max.text = CpLanguageUtil.getString(context,"cp_calculator_text7")
                    tv_amount_user_max_value.text = "$max $unit"
                } else {
                    max = "0"
                    tv_amount_user_max.setText(CpLanguageUtil.getString(context,"cp_calculator_text7"))
                    tv_amount_user_max_value.text = "$max $unit"
                }
            }

            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {
            }

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
            }

        })
        et_input.setText(selectLeverage.toString())
    }
    private fun changeBuyOrSellUI(type: String) {
        when (type) {
            //Buy
            "buy" -> {
                rb_buy?.run {
//                    typeface = Typeface.defaultFromStyle(Typeface.BOLD)
                    setTextColor(ContextCompat.getColor(mActivity!!, R.color.white))
                    backgroundResource = R.drawable.contract_thecalculator_buy_hover
                    setButtonBuyOrSellBg(true,this)
                }

                rb_sell?.run {
//                    typeface = Typeface.defaultFromStyle(Typeface.NORMAL)
                    setTextColor(ContextCompat.getColor(mActivity!!, R.color.text_color_2))
                    backgroundResource = R.drawable.contract_thecalculator_sell
                    setButtonBuyOrSellBg(null,this)
                }
            }
            //Sell
            "sell" -> {
                rb_buy?.run {
//                    typeface = Typeface.defaultFromStyle(Typeface.NORMAL)
                    setTextColor(ContextCompat.getColor(mActivity!!, R.color.text_color_2))
                    backgroundResource = R.drawable.contract_openpositions
                    setButtonBuyOrSellBg(null,this)
                }

                rb_sell?.run {
//                    typeface = Typeface.defaultFromStyle(Typeface.BOLD)
                    setTextColor(ContextCompat.getColor(mActivity!!, R.color.white))
                    backgroundResource = R.drawable.contract_thecalculator_ssell_hover
                    setButtonBuyOrSellBg(false,this)
                }
            }
        }
    }

    /**
     * @param isBuy
     * @param view
     * */
    private fun setButtonBuyOrSellBg(isBuy:Boolean?,view:View?){
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            if(isBuy==null){
                view?.run {
                    backgroundTintList = null
                }
                return
            }
            view?.run {
                backgroundTintList = ColorStateList.valueOf(CpColorUtil.getMainColorType(isBuy))
            }
        }
    }

    companion object {
        @JvmStatic
        fun newInstance(param1: Int) =
                CpLiquidationPriceFragment().apply {
                    arguments = Bundle().apply {
                        putInt("contractId", param1)
                    }
                }
    }

    override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {

    }

    override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
        setCalcBtnStatus()
    }
    private fun setCalcBtnStatus(){
        val etOpenPriceVal = et_open_price.text.toString()
        val etExtrasVal = et_extras.text.toString()
        val etPositionVal = et_position.text.toString()
        val etInputVal = et_input.text.toString()
        var etPositionCondition = true
        if(pActivity?.currentPositionType == 1){
            etPositionCondition = etPositionVal.isNotEmpty()
        }else{
            etPositionCondition = true
        }
        if(etOpenPriceVal.isNotEmpty() && etExtrasVal.isNotEmpty() && etPositionCondition && etInputVal.isNotEmpty()){
            btn_calculate.isEnable(true)
        }else{
            btn_calculate.isEnable(false)
        }
    }

    override fun afterTextChanged(s: Editable?) {

    }

    //type: 0 -> Isolated 1 -> Cross
    fun changePositionType(type:Int){
        setCalcBtnStatus()
        when(type) {
            //Isolated
            0 -> {
                ll_quantity?.visibility = View.GONE
                tv_level_tip?.visibility = View.GONE
            }
            //Cross
            1 -> {
                ll_quantity?.visibility = View.VISIBLE
                tv_position_title?.text = getLineText("cp_calculator_text43")
                et_position?.setText(if(CpClLogicContractSetting.isLogin()) getCanUseAmount() else "")
                tv_level_tip?.visibility = View.VISIBLE
            }
        }
        createDefaultResult()
    }
    private fun getCanUseAmount():String{
        return if(pActivity!=null){
            val canUseAmount = pActivity?.getCanUseAmount(mContractJson.optString("marginCoin"))
            CpBigDecimalUtils.showSNormal(canUseAmount,minOrderMoneyPrecision)
        }else{
            "0"
        }
    }
}
