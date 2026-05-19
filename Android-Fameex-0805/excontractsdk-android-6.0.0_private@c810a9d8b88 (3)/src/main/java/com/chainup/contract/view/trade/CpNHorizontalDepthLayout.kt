package com.chainup.contract.view.trade

import android.app.Activity
import android.content.Context
import android.content.DialogInterface
import android.graphics.Rect
import android.os.Bundle
import android.text.Editable
import android.text.TextUtils
import android.text.TextWatcher
import android.util.AttributeSet
import android.util.Log
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.widget.EditText
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import com.blankj.utilcode.util.LogUtils
import com.chainup.contract.R
import com.chainup.contract.app.CpAppConstant
import com.chainup.contract.app.CpCommonConstant
import com.chainup.contract.bean.CpTabInfo
import com.chainup.contract.eventbus.CpEventBusUtil
import com.chainup.contract.eventbus.CpMessageEvent
import com.chainup.contract.eventbus.CpNLiveDataUtil
import com.chainup.contract.model.CpNewContractModel
import com.chainup.contract.utils.*
import com.chainup.contract.view.CpCommonlyUsedButton
import com.chainup.contract.view.CpDialogUtil
import com.chainup.contract.view.CpNewDialogUtils
import com.chainup.contract.view.bubble.CpBubbleSeekBar
import com.chainup.contract.view.dialog.CpTDialog
import com.chainup.contract.view.dialog.base.CpBindViewHolder
import com.chainup.contract.view.dialog.listener.OnCpBindViewListener
import com.chainup.kit.views.KKEditNumberKit
import com.chainup.talkingdata.AppAnalyticsExt
import com.google.gson.Gson
import com.yjkj.chainup.manager.CpLanguageUtil
import com.yjkj.chainup.new_contract.bean.CpCurrentOrderBean
import io.reactivex.Observable
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import io.reactivex.functions.Consumer
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.cp_depth_horizontal_layout.view.*
import kotlinx.android.synthetic.main.cp_item_transaction_detail.view.*
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.*
import org.jetbrains.anko.backgroundColor
import org.jetbrains.anko.backgroundResource
import org.jetbrains.anko.layoutInflater
import org.jetbrains.anko.textColor
import org.json.JSONArray
import org.json.JSONObject
import java.math.BigDecimal
import java.util.concurrent.TimeUnit
import kotlin.collections.ArrayList

class CpNHorizontalDepthLayout @JvmOverloads constructor(context: Context,
                                                         attrs: AttributeSet? = null,
                                                         defStyleAttr: Int = 0
) : LinearLayout(context, attrs, defStyleAttr), KKEditNumberKit.IEditNumberViewCase, DefaultLifecycleObserver {

    val TAG = CpNHorizontalDepthLayout::class.java.simpleName
    val newContractModel:CpNewContractModel by lazy { CpNewContractModel() }
    private var currentTimeMillis = 0L
    var dialog: CpTDialog? = null

    var mSelectLeverDialog: CpTDialog? = null

    var tapeDialog: CpTDialog? = null

    var tapeLevel: Int = 0

    var depthNum: Int = 8

    var depth_level = 0

    var depthList = ArrayList<CpTabInfo>()
    var depthDialog: CpTDialog? = null
    var depthType: CpTabInfo? = null

    var transactionData: JSONObject? = null

    var mContractId = 0

    var capitalFrequency = 0
    var contractSide = ""
    var multiplier = ""
    var marginRate = ""
    var multiplierCoin = ""
    var base = ""
    var quote = ""
    var coUnit = 0
    var multiplierPrecision = 0
    var symbolPricePrecision = 0
    var nowLevel = "0"
    var maxOpenLimit = "0"
    var positionValue = "0"
    var entrustedValue = "0"
    var lastPrice = "0"

    var canCloseVolumeBuy = "0"
    var canCloseVolumeSell = "0"
    var canUseAmount = "0"
    var marginCoin = "USDT"
    var originCoin = "USDT"

    var positionModel = 1 //1 one-way position not 1 two-way position

    var mMarkertInfoJson: JSONObject? = null
    var mUserConfigInfoJson: JSONObject? = null
    var mUserAssetsInfoJson: JSONObject? = null
    var mContractJson: JSONObject? = null
    var openContract = 0//Has contract transaction been activated? 1 has been activated, 0 has not been activated

    var isShowPositionInfo = false
    var isShowPositionDesc = false
    var mBindViewHolder: CpBindViewHolder? = null

    //Record the latest transaction price
    private var mLastClosePrice:String? = null

    //Contract risk prompt dialog flag to prevent repeated pop-up
    private var mContractDialogFlag:Boolean = true
//    var coinMapData: JSONObject? = NCoinManager.getSymbolObj(PublicInfoDataService.getInstance().currentSymbol)
//        set(value) {
//            field = value
////            trade_amount_view?.coinMapData = value ?: return
////            trade_amount_view?.setPrice()
//            setDepth(context)
//        }

    /**
     *Item sold
     */
    private var sellViewList = mutableListOf<View>()

    /**
     *Buying item
     */
    private var buyViewList = mutableListOf<View>()

    var orderList = mutableListOf<CpCurrentOrderBean>()
    var tvCapitalView:TextView? = null
    var isLoading:Boolean = false
    init {

        /**
         *The value here must be: True
         */
        LayoutInflater.from(context).inflate(R.layout.cp_depth_horizontal_layout, this, true)

        tv_cp_overview_text6?.text = CpLanguageUtil.getString(context, "cp_overview_text6")
        tv_cp_overview_text8?.text = CpLanguageUtil.getString(context, "cp_overview_text8")
        tv_overview_text26?.text = CpLanguageUtil.getString(context, "cp_overview_text26")
        tv_extra_text136?.text = CpLanguageUtil.getString(context, "cp_extra_text136")
        tv_aavl_unit?.text = CpLanguageUtil.getString(context, "cp_overview_text19")
        tv_position?.text = CpLanguageUtil.getString(context,"cp_contract_setting_text1")

        //Select Position Mode
        ll_position.setOnClickListener {

            if (CpClickUtil.isFastDoubleClick()){
                return@setOnClickListener
            }

            if (!CpClLogicContractSetting.isLogin()) {
                CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.sl_contract_go_login_page))
                return@setOnClickListener
            }
            if (openContract == 0) {
                CpDialogUtil.showCreateContractDialog(context, object : CpNewDialogUtils.DialogBottomListener {
                    override fun sendConfirm() {
                        CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.sl_contract_open_contract_event))
                    }
                })
                return@setOnClickListener
            }
            val mMarginModel = mUserConfigInfoJson?.optInt("marginModel")
//            tv_tab_full.setBackgroundResource(if (mMarginModel == 1) R.drawable.cp_btn_linear_blue_bg else R.drawable.cp_btn_linear_grey_bg)
//            tv_tab_gradually.setBackgroundResource(if (mMarginModel == 2) R.drawable.cp_btn_linear_blue_bg else R.drawable.cp_btn_linear_grey_bg)
//            tv_tab_full.setTextColor(if (mMarginModel == 1) CpColorUtil.getColor(R.color.main_blue) else CpColorUtil.getColor(R.color.normal_text_color))
//            tv_tab_gradually.setTextColor(if (mMarginModel == 2) CpColorUtil.getColor(R.color.main_blue) else CpColorUtil.getColor(R.color.normal_text_color))
//
            var mMarginModelCanSwitch = mUserConfigInfoJson?.getInt("marginModelCanSwitch")
//            tv_no_switch_position.visibility = if (mMarginModelCanSwitch == 0) View.VISIBLE else View.GONE
//            ll_select_position.visibility = if (!isShowPositionInfo) View.VISIBLE else View.GONE
//            isShowPositionInfo = !isShowPositionInfo
            //Drop the new dialog deposit
            CpDialogUtil.createModifyMarginModeDialog(context,mMarginModelCanSwitch!!,mMarginModel!!)


//            img_position.animate().setDuration(200).rotation(180f).start()
//            CpDialogUtil.createModifyPositionPop(context, mMarginModelCanSwitch!!, mMarginModel!!, it, object : CpNewDialogUtils.DialogOnSigningItemClickListener {
//                override fun clickItem(position: Int, text: String) {
//
//                }
//            }, object : CpNewDialogUtils.DialogOnDismissClickListener {
//                override fun clickItem() {
//                    img_position.animate().setDuration(200).rotation(0f).start()
//                }
//            })
        }
        //Switch full warehouse mode
        tv_tab_full.setSafeListener {
            if (mUserConfigInfoJson?.getInt("marginModelCanSwitch") == 0) {
                return@setSafeListener
            }
            isShowPositionInfo = false
            ll_select_position.visibility = View.GONE
            val event = CpMessageEvent(CpMessageEvent.sl_contract_switch_lever_event)
            event.msg_content = "1"
            CpEventBusUtil.post(event)

        }
        //Switch warehouse by warehouse mode
        tv_tab_gradually.setSafeListener {
            if (mUserConfigInfoJson?.getInt("marginModelCanSwitch") == 0) {
                return@setSafeListener
            }
            isShowPositionInfo = false
            ll_select_position.visibility = View.GONE
            val event = CpMessageEvent(CpMessageEvent.sl_contract_switch_lever_event)
            event.msg_content = "2"
            CpEventBusUtil.post(event)
        }

        //Display full warehouse and warehouse by warehouse explanation information
        ll_show_position_info.setSafeListener {
            tv_position_info.visibility = if (!isShowPositionDesc) View.VISIBLE else View.GONE
            isShowPositionDesc = !isShowPositionDesc
        }

        //Select lever
        ll_lever.setSafeListener {
            if (!CpClLogicContractSetting.isLogin()) {
                CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.sl_contract_go_login_page))
                return@setSafeListener
            }
            if (openContract == 0) {
                CpDialogUtil.showCreateContractDialog(context, object : CpNewDialogUtils.DialogBottomListener {
                    override fun sendConfirm() {
                        CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.sl_contract_open_contract_event))
                    }
                })
                return@setSafeListener
            }
            if (mUserConfigInfoJson?.getInt("levelCanSwitch") == 0) {
                CpDialogUtil.showNewsingleDialog2(context!!, CpLanguageUtil.getString(context,"cp_contract_setting_text11"), object : CpNewDialogUtils.DialogBottomListener {
                    override fun sendConfirm() {

                    }
                }, cancelTitle = CpLanguageUtil.getString(context, "cp_extra_text28"))
                return@setSafeListener
            }
            mSelectLeverDialog = CpDialogUtil.showSelectLeverDialog(context, OnCpBindViewListener {
                val activity:Activity = context as Activity
                var leverCeilingObject: JSONObject? = null
                var leverCeilingList: ArrayList<Int> = ArrayList()
                it.getView<TextView>(R.id.tv_title).text=CpLanguageUtil.getString(context,"cp_contract_setting_text8")
                it.getView<TextView>(R.id.tv_cancel).text=CpLanguageUtil.getString(context,"cp_overview_text56")
                it.getView<TextView>(R.id.tv_level_tip).text=CpLanguageUtil.getString(context,"cp_contract_setting_text9")


                val etInput = it.getView<EditText>(R.id.et_input)
                val imgReduce = it.getView<ImageView>(R.id.img_reduce)
                val imgAdd = it.getView<ImageView>(R.id.img_add)
                val seekLayout = it.getView<CpBubbleSeekBar>(R.id.seek_layout)
                var minLeverage = 0
                var maxLeverage = 100
                var userMaxLevel = 100
                minLeverage = mUserConfigInfoJson?.optInt("minLevel")?.toInt()!!
                maxLeverage = mUserConfigInfoJson?.optInt("maxLevel")?.toInt()!!
                imgAdd.setOnClickListener {
                    var inputLeverage = CpBigDecimalUtils.add(etInput.text.toString(), "1").toPlainString()
                    etInput?.setText(CpBigDecimalUtils.subZeroAndDot(inputLeverage))
                }

                imgReduce.setOnClickListener {
                    var inputLeverage = CpBigDecimalUtils.sub(etInput.text.toString(), "1").toPlainString()
                    etInput?.setText(CpBigDecimalUtils.subZeroAndDot(inputLeverage))
                }

                seekLayout.configBuilder
                        .min(minLeverage.toFloat())
                        .max(maxLeverage.toFloat())
                        .sectionCount(if(CpBigDecimalUtils.compareTo(maxLeverage.toString(),"25")>0) (maxLeverage / 25) else 4)
                        .progress(nowLevel.toFloat())
                        .build()
                seekLayout.onProgressChangedListener = object : CpBubbleSeekBar.OnProgressChangedListener {
                    override fun onProgressChanged(bubbleSeekBar: CpBubbleSeekBar?, progress: Int, progressFloat: Float) {
                        etInput.setText(progress.toString())
                        if(etInput.isFocused){
                            etInput.clearFocus()
                        }
//                        etInput.setSelection(progress.toString().length)
                    }

                    override fun getProgressOnActionUp(bubbleSeekBar: CpBubbleSeekBar?, progress: Int, progressFloat: Float) {

                        CpSoftKeyboardUtil.hideSoftKeyboard(activity)

                    }

                    override fun getProgressOnFinally(bubbleSeekBar: CpBubbleSeekBar?, progress: Int, progressFloat: Float) {
                    }
                }
                etInput.addTextChangedListener(object : TextWatcher {
                    override fun afterTextChanged(p0: Editable?) {
                        if (TextUtils.isEmpty(p0.toString())) {
                            seekLayout.setProgress(minLeverage.toFloat())
                            return
                        }
                        val leverage = etInput.text.toString().toInt()
                        it.setVisibility(R.id.tv_level_tip, if (CpBigDecimalUtils.compareTo(leverage.toString(), "50") == 1) View.VISIBLE else View.INVISIBLE)
                        leverCeilingList = ArrayList()
                        mUserConfigInfoJson?.apply {
                            minLeverage = optInt("minLevel")
                            maxLeverage = optInt("maxLevel")
                            userMaxLevel = optInt("userMaxLevel")
                            it.setText(R.id.tv_level_user_max, CpLanguageUtil.getString(context,"cp_extra_text114") + " " + userMaxLevel + " X")
                            if (leverage > userMaxLevel) {
                                etInput.setText("$userMaxLevel")
                                return
                            }
                            if (leverage > maxLeverage) {
                                etInput.setText("$maxLeverage")
                                etInput.setSelection(maxLeverage.toString().length)
                                return
                            }
                            if (leverage < minLeverage) {
                                etInput.setText("$minLeverage")
                                etInput.setSelection(minLeverage.toString().length)
                                return
                            }
                            seekLayout.setProgress(etInput.text.toString().toFloat())
                            leverCeilingObject = optJSONObject("leverCeiling")
                            val iteratorKeys = leverCeilingObject?.keys()
                            iteratorKeys?.apply {
                                while (iteratorKeys.hasNext()) {
                                    val key = iteratorKeys.next().toString()
                                    leverCeilingList?.add(key.toInt())
                                }
                                var isExist = false
                                for (buff in leverCeilingList!!) {
                                    if (leverage == buff) {
                                        isExist = true
                                    }
                                }
                                if (!isExist) {
                                    leverCeilingList?.add(leverage)
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
                                var unit = ""
                                var max = CpBigDecimalUtils.showSNormal(leverCeilingObject?.optString(leverCeilingList[indexBuff].toString()), CpClLogicContractSetting.getContractMarginCoinPrecisionById(context, mContractId))
                                if (CpClLogicContractSetting.getContractUint(context) == 1) {
                                    unit = CpClLogicContractSetting.getContractMultiplierCoinById(context, mContractId)
                                } else {
                                    max = CpBigDecimalUtils.divStr(max, CpClLogicContractSetting.getContractMultiplierById(context, mContractId), 0)
                                    unit = CpLanguageUtil.getString(context,"cp_overview_text9")
                                }
                                it.setText(R.id.tv_amount_user_max, max)
                                it.setText(R.id.tv_amount_user_max_key, CpLanguageUtil.getString(context,"cp_overview_text43") + "(" + unit + ")")
                                it.setText(R.id.tv_can_open, updateAvailableVol(lastPrice, leverage))
                                it.setText(R.id.tv_can_open_key, CpLanguageUtil.getString(context,"cp_overview_text10") + "(" + unit + ")")
                            }
                        }

                    }

                    override fun beforeTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {
                    }

                    override fun onTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {
                    }

                })
                it.setText(R.id.et_input, nowLevel)
                val btn_close_position = it.getView<CpCommonlyUsedButton>(R.id.btn_close_position)
                btn_close_position.setContent(CpLanguageUtil.getString(context,"cp_calculator_text16"))
                btn_close_position.listener = object : CpCommonlyUsedButton.OnBottonListener {
                    override fun bottonOnClick() {
                        if (TextUtils.isEmpty(etInput.text.toString())) {
                            return
                        }
                        val CpMessageEvent = CpMessageEvent(CpMessageEvent.sl_contract_req_modify_leverage_event)
                        CpMessageEvent.msg_content = etInput.text.toString()
                        CpEventBusUtil.post(CpMessageEvent)
                        mSelectLeverDialog?.dismiss()
                    }
                }
            })
        }

        //Fund Transfer Settings CpTradeView Click Interface Callback
        trade_amount_view.transferClick = object : CpTradeView.OnTransferClick{
            override fun click() {
                if (!CpClLogicContractSetting.isLogin()) {
                    CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.sl_contract_go_login_page))
                    return
                }
                if (openContract == 0) {
                    CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.sl_contract_open_contract_event))
                    return
                }
                val mMessageEvent = CpMessageEvent(CpMessageEvent.sl_contract_go_fundsTransfer_page)

                mMessageEvent.msg_content = Bundle().apply {
                    putString("marginCoin",originCoin)
                    putString("originCoin",originCoin)
                }
                CpEventBusUtil.post(mMessageEvent)
                AppAnalyticsExt.instance.clickAction(AppAnalyticsExt.CONTRACT_APP_ACTION_10)
            }
        }


        //Capital rate
        ll_rate.setSafeListener {
            var timer2:Disposable? = null
            CpDialogUtil.showCapitalRateDialog(
                context,
                listener = OnCpBindViewListener {
                    val tvCutOffTime = it.getView<TextView>(R.id.tv_cut_off_time)
                    val tvCurrentFundRate = it.getView<TextView>(R.id.tv_current_fund_rate)
                    val tvNextFundRate = it.getView<TextView>(R.id.tv_next_fund_rate)
                    val tv_cp_overview_text32 = it.getView<TextView>(R.id.tv_cp_overview_text32)
                    val tv_cp_overview_text33 = it.getView<TextView>(R.id.tv_cp_overview_text33)
                    val tv_cp_overview_text34 = it.getView<TextView>(R.id.tv_cp_overview_text34)
                    val tv_confirm_btn = it.getView<TextView>(R.id.tv_confirm_btn)
                    tvCutOffTime.text = "00:00 (00:00:00)"
                    tv_cp_overview_text32.setText(CpLanguageUtil.getString(context, "cp_overview_text32"))
                    tv_cp_overview_text33.setText(CpLanguageUtil.getString(context, "cp_overview_text33"))
                    tv_cp_overview_text34.setText(CpLanguageUtil.getString(context, "cp_overview_text34"))
                    tv_confirm_btn.setText(CpLanguageUtil.getString(context, "cp_extra_text28"))
                    it.setText(R.id.dgtitle,CpLanguageUtil.getString(context,"cp_overview_text26"))
                    tvCapitalView = tvCutOffTime
                    timer2 = Observable.interval(0L,CpCommonConstant.currentTimeMillisLoopTime,TimeUnit.MINUTES)
                        .subscribeOn(Schedulers.io())
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribe(object: Consumer<Long>{
                            override fun accept(t: Long?) {
                                mMarkertInfoJson?.let{ cit ->
                                    tvCurrentFundRate.text = CpBigDecimalUtils.mul(cit.optDouble("currentFundRate").toString(),"100",5).toPlainString()+"%"
                                    tvNextFundRate.text = CpBigDecimalUtils.mul(cit.optDouble("nextFundRate").toString(),"100",5).toPlainString()+"%"
                                }
                            }
                        })
                },
                dismissListener = object : DialogInterface.OnDismissListener{
                    override fun onDismiss(dialog: DialogInterface?) {
                        timer2?.dispose()
                        tvCapitalView = null
                    }
                }
            )
        }
        //Tag Price
        tv_extra_text136.setSafeListener {
            CpDialogUtil.showIndexPriceDialog(context, OnCpBindViewListener {
                mBindViewHolder = it
                val tvTagPrice = it.getView<TextView>(R.id.tv_tag_price)
                val tvIndexPrice = it.getView<TextView>(R.id.tv_index_price)
                val tv_cp_overview_text20 = it.getView<TextView>(R.id.tv_cp_overview_text20)
                val tv_cp_stoporder_text8 = it.getView<TextView>(R.id.tv_cp_stoporder_text8)
                val tv_cp_overview_text21 = it.getView<TextView>(R.id.tv_cp_overview_text21)
                val tv_cp_stoporder_text7 = it.getView<TextView>(R.id.tv_cp_stoporder_text7)
                val tv_confirm_btn = it.getView<TextView>(R.id.tv_confirm_btn)

                tv_cp_overview_text20.text=CpLanguageUtil.getString(context, "cp_overview_text20")+":"
                tv_cp_stoporder_text8.text=CpLanguageUtil.getString(context, "cp_stoporder_text8")
                tv_cp_overview_text21.text=CpLanguageUtil.getString(context, "cp_overview_text21")+":"
                tv_cp_stoporder_text7.text=CpLanguageUtil.getString(context, "cp_stoporder_text7")
                tv_confirm_btn.text=CpLanguageUtil.getString(context, "cp_extra_text28")

                tvTagPrice.text = CpBigDecimalUtils.scaleStr(mMarkertInfoJson?.optString("tagPrice"), symbolPricePrecision)
                tvIndexPrice.text = CpBigDecimalUtils.scaleStr(mMarkertInfoJson?.optString("indexPrice"), symbolPricePrecision)
            })
        }

        /**
         *Change the style of the coil mouth
         */
        ib_tape?.setSafeListener {
            tapeDialog = CpNewDialogUtils.showBottomListDialog(context, arrayListOf(CpLanguageUtil.getString(context, "cp_content_text16"), CpLanguageUtil.getString(context, "cp_extra_text50"), CpLanguageUtil.getString(context, "cp_extra_text51")), tapeLevel, object : CpNewDialogUtils.DialogOnclickListener {
                override fun clickItem(data: ArrayList<String>, item: Int) {
                    tapeDialog?.dismiss()
                    tapeLevel = item
                    changeTape(item)
                }
            })
        }
        tv_change_depth?.setSafeListener {
            if (depthList.size == 0) return@setSafeListener
            depthDialog = CpNewDialogUtils.showNewBottomListDialog(
                    context!!,
                    depthList,
                    depthType!!.index,
                    object : CpNewDialogUtils.DialogOnItemClickListener {
                        override fun clickItem(index: Int) {
                            if (depthType != depthList[index]) {
                                depthType = depthList[index]
                                depth_level = depthType?.extras?.toInt()!!
                                (tv_change_depth.getChildAt(0) as TextView).setText(depthType?.name)
                                val mMessageEvent =
                                        CpMessageEvent(
                                                CpMessageEvent.sl_contract_depth_level_event
                                        )
                                mMessageEvent.msg_content = index.toString()
                                CpEventBusUtil.post(mMessageEvent)

                            }
                            depthDialog?.dismiss()
                            depthDialog = null
                        }
                    })
        }


        mEditCtrl?.mEditNumberViewCase = this

        initDetailView()

    }

    override fun onResume(owner: LifecycleOwner) {
        super.onResume(owner)
        Log.d(TAG,"view onResume>>>ownerName=${owner::class.java.simpleName}")
        CpNLiveDataUtil.observeData(owner) {
            if (it.msg_type == CpMessageEvent.sl_contract_capitalRate_event) {
                val bundle = it.msg_content as Bundle
                tvCapitalView?.let {
                    it.text = bundle.getString("nextTimeFormatStr","")+" ("+bundle.getString("diffTimeStr","")+")"
                }
            }
        }
    }

    fun setMarkertInfo(json: JSONObject) {
        mMarkertInfoJson = json
        mMarkertInfoJson?.apply {
            val tagPrice = CpBigDecimalUtils.scaleStr(optString("tagPrice"), symbolPricePrecision)
            tv_index_price.setText(tagPrice)
            tv_rate.text = CpBigDecimalUtils.mul(optDouble("currentFundRate").toString(),"100",5).toPlainString() + "%"
            mBindViewHolder?.apply {
                val tvTagPrice = this.getView<TextView>(R.id.tv_tag_price)
                val tvIndexPrice = this.getView<TextView>(R.id.tv_index_price)
                tvTagPrice.text = CpBigDecimalUtils.scaleStr(mMarkertInfoJson?.optString("tagPrice"), symbolPricePrecision)
                tvIndexPrice.text = CpBigDecimalUtils.scaleStr(mMarkertInfoJson?.optString("indexPrice"), symbolPricePrecision)
            }
        }
    }


    fun setTagPrice(tagPrice: String) {
        val _tagPrice = CpBigDecimalUtils.scaleStr(tagPrice, symbolPricePrecision)
        tv_index_price.setText(_tagPrice)
    }

    fun cleanInputData() {
//        mEditCtrl.setText("")
//        custom_seekbar.setProgress(0f)
        trade_amount_view.clearUiEtVal()
    }

    fun changeMainColor() {
        trade_amount_view.changeBuyOrSellUI()
    }

    fun swicthUnit() {
        base = if (CpClLogicContractSetting.getContractUint(context) == 0) CpLanguageUtil.getString(context,"cp_overview_text9") else multiplierCoin
        tv_cp_overview_text6?.text = CpLanguageUtil.getString(context, "cp_overview_text6") + "(" + quote + ")"
        tv_cp_overview_text8?.text = CpLanguageUtil.getString(context, "cp_overview_text8") + "(" + base + ")"
        coUnit = CpClLogicContractSetting.getContractUint(context)
    }

    fun swicthShowNum(buyOrSellHelper: CpContractBuyOrSellHelper) {
        if (!buyOrSellHelper.isOneWayPosition){
            when (buyOrSellHelper.orderType) {
            1, 4, 5, 6 -> {
                if (buyOrSellHelper.isOpen) {
                    if (buyOrSellHelper.isOto) {
                        depthNum=9
                    } else {
                        depthNum=8
                    }
                } else {
                    depthNum=7
                }
            }
            2 -> {
                if (buyOrSellHelper.isOpen) {
                    if (buyOrSellHelper.isOto) {
                        depthNum=10
                    } else {
                        depthNum=8
                    }
                } else {
                    depthNum=7
                }
            }
            3 -> {
                if (buyOrSellHelper.isOpen) {
                    depthNum=9
                } else {
                    depthNum=8
                }
            }
        }
        }else{
            when (buyOrSellHelper.orderType) {
            1, 4, 5, 6 -> {
                if (buyOrSellHelper.isOpen) {
                    if (buyOrSellHelper.isOto) {
                        depthNum=9
                    } else {
                        depthNum=8
                    }
                } else {
                    depthNum=7
                }
            }
            2 -> {
                if (buyOrSellHelper.isOpen) {
                    if (buyOrSellHelper.isOto) {
                        depthNum=9
                    } else {
                        depthNum=8
                    }
                } else {
                    depthNum=7
                }
            }
            3 -> {
                if (buyOrSellHelper.isOpen) {
                    depthNum=9
                } else {
                    depthNum=8
                }
            }
        }
        }

        changeTape(tapeLevel)
    }

    fun setContractJsonInfo(json: JSONObject,isLeftCoin:Boolean? = false) {
        val oldContractId = mContractId
        mContractJson = json
        mContractId = json.getInt("id")
        val isUpdateContract = oldContractId!=mContractId
        contractSide = json?.optString("contractSide").toString()
        multiplier = json?.optString("multiplier").toString()
        marginRate = json?.optString("marginRate").toString()
        multiplierCoin = json?.optString("multiplierCoin").toString()
        base = if (CpClLogicContractSetting.getContractUint(context) == 0) CpLanguageUtil.getString(context,"cp_overview_text9") else multiplierCoin
        multiplierPrecision = CpClLogicContractSetting.getContractMultiplierPrecisionById(context, mContractId)
        symbolPricePrecision = CpClLogicContractSetting.getContractSymbolPricePrecisionById(context, mContractId)

        et_price.setText("")
        if(isLeftCoin == true || isUpdateContract){
            mLastClosePrice = null
            tv_close_price?.text = "--"
        }else{
            mLastClosePrice?.run{
                if (isFirstSetValue()) {
                    trade_amount_view.initTick(CpDecimalUtil.cutValueByPrecision(this, symbolPricePrecision))
                }
            }
        }

        setDepth(context)
        trade_amount_view.setContractJsonInfo(json)
        mEditCtrl.setText("")
        custom_seekbar.setProgress(0f)
        quote = mContractJson?.optString("quote").toString()
        coUnit = CpClLogicContractSetting.getContractUint(context)
        tv_cp_overview_text6?.text = CpLanguageUtil.getString(context, "cp_overview_text6") + "(" + quote + ")"
        tv_cp_overview_text8?.text = CpLanguageUtil.getString(context, "cp_overview_text8") + "(" + base + ")"
    }

    fun setCurrentOrderJsonInfo(json: JSONObject) {
        val mListBuffer = ArrayList<CpCurrentOrderBean>()
        json?.apply {
            if (!isNull("orderList")) {
                val mOrderListJson = optJSONArray("orderList")
                for (i in 0..(mOrderListJson.length() - 1)) {
                    var obj = mOrderListJson.getString(i)
                    val mClCurrentOrderBean =
                            Gson().fromJson<CpCurrentOrderBean>(
                                    obj,
                                    CpCurrentOrderBean::class.java
                            )
                    mClCurrentOrderBean.isPlan = false
                    mListBuffer.add(mClCurrentOrderBean)
                }
                orderList.clear()
                orderList.addAll(mListBuffer)
                refreshDepthView(transactionData)
            } else {
                orderList.clear()
                refreshDepthView(transactionData)
            }
        }
        trade_amount_view.setCurrentOrderListInfo(mListBuffer)
    }


    fun setUserLogout() {
        setLoginContractLayout(isLoginContract = false)
        //Empty Available
        trade_amount_view.setAvailableAssets(
            value = CpBigDecimalUtils.showSNormal("0", CpClLogicContractSetting.getContractMarginCoinPrecisionById(context, mContractId)),
            unit = marginCoin
        )
        orderList.clear()
        refreshDepthView(transactionData)
    }


    fun setUserConfigInfo(json: JSONObject) {
        mUserConfigInfoJson = json
        trade_amount_view.setUserConfigInfo(json)
        mUserConfigInfoJson?.apply {
            openContract = optInt("openContract")
            positionModel = optInt("positionModel")
            LogUtils.e("positionModel:" + positionModel)
            CpClLogicContractSetting.setPositionModel(context, positionModel)
            rg_buy_sell.visibility = if (positionModel == 2) View.VISIBLE else View.GONE
            ll_only_reduce_positions.visibility = if (positionModel == 1) View.VISIBLE else View.GONE
            tv_position.text = if (optInt("marginModel") == 1) CpLanguageUtil.getString(context,"cp_contract_setting_text1") else CpLanguageUtil.getString(context,"cp_contract_setting_text2")
            tv_lever.text = optString("nowLevel") + "X"
            nowLevel = optString("nowLevel")
        }
    }


    fun setUserAssetsInfo(json: JSONObject?) {
        if(json==null){

            val marginCoin = mContractJson?.optString("marginCoin")

            trade_amount_view.setAvailableAssets(
                value = CpBigDecimalUtils.showSNormal("0", CpClLogicContractSetting.getContractMarginCoinPrecisionById(context, mContractId)),
                unit = marginCoin
            )
            return
        }
        mUserAssetsInfoJson = json
        trade_amount_view.setUserAssetsInfo(json)
        mUserAssetsInfoJson?.apply {
            if (!isNull("accountList")) {
                val mOrderListJson = optJSONArray("accountList")
                for (i in 0..(mOrderListJson.length() - 1)) {
                    val obj = mOrderListJson.getJSONObject(i)
                    var canUseAmountStr = obj.getString("canUseAmount")
                    mContractJson?.run {
                        marginCoin = optString("marginCoin").toString()
                        originCoin = optString("originalCoin").toString()
                    }

                    val csymbol = obj?.optString("symbol")
                    if (marginCoin.equals(csymbol)) {
                        //Set display funds
                        trade_amount_view.setAvailableAssets(
                            value = CpBigDecimalUtils.showSNormal(canUseAmountStr, CpClLogicContractSetting.getContractMarginCoinPrecisionById(context, mContractId)),
                            unit = marginCoin
                        )
                        canUseAmount = canUseAmountStr
                    }
                }
            }
            if (!isNull("positionList")) {
                val mOrderListJson = optJSONArray("positionList")
                var positionValueBuff = BigDecimal.ZERO
                for (i in 0..(mOrderListJson.length() - 1)) {
                    val obj = mOrderListJson.getJSONObject(i)
                    if (obj.getInt("contractId") == mContractId) {
                        var canCloseVolume =
                                obj.getString("canCloseVolume")
                        var orderSid =
                                obj.getString("orderSide")
                        if (orderSid.equals("BUY")) {
                            canCloseVolumeSell = canCloseVolume
                        } else if (orderSid.equals("SELL")) {
                            canCloseVolumeBuy = canCloseVolume
                        }
                        positionValueBuff =
                                BigDecimal(obj.optString("positionBalance")).add(
                                        positionValueBuff
                                )
                    }
                    LogUtils.e("canCloseVolumeBuy:" + canCloseVolumeBuy)
                    LogUtils.e("canCloseVolumeSell:" + canCloseVolumeSell)
                }
                positionValue =
                        positionValueBuff.setScale(multiplierPrecision, BigDecimal.ROUND_HALF_DOWN)
                                .toPlainString()
            }
        }
    }


    fun setLoginContractLayout(isLoginContract: Boolean = false, isOpenContract: Boolean? = false) {
        if (!isLoginContract) {
            ll_login_contract.visibility = View.VISIBLE
            ll_open_contract.visibility = View.GONE
            ll_common.visibility = View.GONE
        } else {
            if (isOpenContract==false) {
                ll_open_contract.visibility = View.VISIBLE
                ll_common.visibility = View.GONE
                ll_login_contract.visibility = View.GONE
            } else {
                ll_open_contract.visibility = View.GONE
                ll_common.visibility = View.VISIBLE
                ll_login_contract.visibility = View.GONE
            }
        }
    }

    private fun setDepth(context: Context) {
        val depthData = CpClLogicContractSetting.getContractJsonStrById(context, mContractId)
        var mCoinResultVo = depthData?.getJSONObject("coinResultVo")
        var mDepthJsonArray = mCoinResultVo?.optJSONArray("depth")
        depthList.clear()
        for (i in 0 until mDepthJsonArray?.length()!!) {
            val obj = mDepthJsonArray[i] as String
            if(obj.isEmpty()) continue
            if (obj.toFloat().toInt() == 0) {
                depthList.add(CpTabInfo("1", i, obj))
            } else {
                var buff = StringBuffer("0")
                buff.append(".")
                for (x in 0 until obj.toInt() - 1) {
                    buff.append("0")
                }
                buff.append("1")
                depthList.add(CpTabInfo(buff.toString(), i, obj))
            }
        }
        depth_level = depthList[0].extras!!.toFloat().toInt()
        depthType = depthList[0]
        (tv_change_depth.getChildAt(0) as TextView).setText(depthType?.name)
    }


    /**
     *Order
     *
     *Initialize transaction details record view
     */
    fun initDetailView(items: Int = depthNum) {
        sellViewList.clear()
        buyViewList.clear()

        if (ll_buy_price?.childCount ?: 0 > 0) {
            (ll_buy_price as LinearLayout).removeAllViews()
        }

        if (ll_sell_price?.childCount ?: 0 > 0) {
            (ll_sell_price as LinearLayout).removeAllViews()
        }

//        val pricePrecision = coinMapData?.optInt("price", 2) ?: 2

        for (i in 0 until items) {
            /**
             *Selling offer
             */
            val sell_layout: View = context.layoutInflater.inflate(R.layout.cp_item_transaction_detail, null)

            sell_layout.im_sell?.backgroundResource = CpColorUtil.getDotDrawableRes(false)
            sell_layout.tv_price_item?.textColor = CpColorUtil.getMainColorType(isRise = false)
//            NLiveDataUtil.observeForeverData {
//                if (null != it && MessageEvent.color_rise_fall_type == it.msg_type) {
//                    sell_layout.tv_price_item?.textColor = ColorUtil.getMainColorType(isRise = false)
//                }
//            }

            sell_layout.setSafeListener {
                val result = sell_layout.tv_price_item?.text.toString()
                click2Data(result)
            }
            sellViewList.add(sell_layout)

            /**
             *Buying
             */
            val buy_layout: View = context.layoutInflater.inflate(R.layout.cp_item_transaction_detail, null)
            buy_layout.im_sell?.backgroundResource = CpColorUtil.getDotDrawableRes(true)
            buy_layout.tv_price_item?.textColor = CpColorUtil.getMainColorType()
//            NLiveDataUtil.observeForeverData {
//                if (null != it && MessageEvent.color_rise_fall_type == it.msg_type) {
//                    buy_layout.tv_price_item?.textColor = ColorUtil.getMainColorType()
//                }
//            }

            buy_layout.setSafeListener {
                val result = buy_layout.tv_price_item?.text.toString()
                click2Data(result)
            }
            buyViewList.add(buy_layout)
        }


        buyViewList.forEach {
            ll_buy_price?.addView(it)
        }

        sellViewList.forEach {
            ll_sell_price?.addView(it)
        }
//        tv_close_price?.text = "--"
//        tv_converted_close_price?.text = "--"

    }

    private fun click2Data(result: String) {
        if (!TextUtils.isEmpty(result) && result != "--" && result != "null") {
            et_price?.setText(CpBigDecimalUtils.divForDown(result, symbolPricePrecision).toPlainString())
            trade_amount_view.updatePrice(CpBigDecimalUtils.divForDown(result, symbolPricePrecision).toPlainString())
        }
    }

    fun changeTape(item: Int, needData: Boolean = true) {
        when (item) {
            CpAppConstant.DEFAULT_TAPE -> {
                ll_buy_price?.visibility = View.VISIBLE
                ll_sell_price?.visibility = View.VISIBLE
//                val params = v_tape_line.layoutParams as LayoutParams
//                params.topMargin = 4.getDip()
//                params.bottomMargin = 4.getDip()
//                v_tape_line.layoutParams = params
                CpColorUtil.setTapeIcon(ib_tape, CpAppConstant.DEFAULT_TAPE)
                initDetailView()
            }

            CpAppConstant.BUY_TAPE -> {
                ll_buy_price?.visibility = View.VISIBLE
                ll_sell_price?.visibility = View.GONE
//                val params = v_tape_line.layoutParams as LayoutParams
//                params.topMargin = 4.getDip()
//                params.bottomMargin = 4.getDip()
//                v_tape_line.layoutParams = params
                CpColorUtil.setTapeIcon(ib_tape, CpAppConstant.BUY_TAPE)
                initDetailView(depthNum * 2)
            }

            CpAppConstant.SELL_TAPE -> {
                ll_buy_price?.visibility = View.GONE
                ll_sell_price?.visibility = View.VISIBLE

//                val params = v_tape_line.layoutParams as LayoutParams
//                params.topMargin = 4.getDip()
//                params.bottomMargin = 4.getDip()
//                v_tape_line.layoutParams = params
                CpColorUtil.setTapeIcon(ib_tape, CpAppConstant.SELL_TAPE)
                initDetailView(depthNum * 2)
            }
        }
//        if (needData) {
        refreshDepthView(transactionData)
//        }
    }

    fun setTickInfo(data: JSONObject?) {
        data?.run {
            if (data.isNull("tick")) {
                return
            }
            val tick = data.optJSONObject("tick")
            val rose = tick.optString("rose")
            val close = tick.optString("close")
            mLastClosePrice = close
            lastPrice = tick.optString("close")
            var mColor = CpColorUtil.getMainColorType(isRise = RateManager.getRoseTrend(rose) >= 0)
            tv_close_price?.run {
                textColor = mColor
                text = CpDecimalUtil.cutValueByPrecision(close, symbolPricePrecision)
            }
            trade_amount_view.setTickLastPrice("", "", close)
            trade_amount_view.lastPriceing = close
//            val riseFallRate: Double = CpMathHelper.round(rose.toDouble() * 100, 2)
//            val sRate = if (riseFallRate >= 0) "+" + CpNumberUtil().getDecimal(2)
//                    .format(riseFallRate) + "%" else CpNumberUtil().getDecimal(2)
//                    .format(riseFallRate) + "%"
//            tv_close_rose?.run {
//                textColor = mColor
//                text = sRate
//            }
            if (isFirstSetValue()) {
                trade_amount_view.initTick(CpDecimalUtil.cutValueByPrecision(close, symbolPricePrecision))
            }
        }
    }

    /**
     *Update data for orders
     */
    fun refreshDepthView(data: JSONObject?) {
        transactionData = data
        data?.run {
            val tick = this.optJSONObject("tick")

            /**
             *The largest selling volume
             */
            val askList = arrayListOf<JSONArray>()
            val asks = tick.optJSONArray("asks")
            if (asks.length() != 0) {
                val item = asks.optJSONArray(0)
                trade_amount_view.setTickLastPrice("", item[0].toString().replace("\"", "").trim(), "")
            }
            for (i in 0 until asks.length()) {
                askList.add(asks.optJSONArray(i))
            }
            trade_amount_view.setTickPrice(null, askList)

            val askMaxVolJson = askList.maxByOrNull {
                it.optDouble(1)
            }
            val askMaxVol = askMaxVolJson?.optDouble(1) ?: 1.0
            Log.d(TAG, "========askMAX:$askMaxVol=======")

            /**
             *The largest volume of buying transactions
             */
            val buyList = arrayListOf<JSONArray>()
            val buys = tick.optJSONArray("buys")
            if (buys.length() != 0) {
                val item = buys.optJSONArray(0)
                trade_amount_view.setTickLastPrice(item[0].toString().replace("\"", "").trim(), "", "")
            }
            for (i in 0 until buys.length()) {
                buyList.add(buys.optJSONArray(i))
            }
            trade_amount_view.setTickPrice(buyList, null)
            /**
             *The largest volume of buying transactions
             */
            val buyMaxVolJson = buyList.maxByOrNull {
                it.optDouble(1)
            }
            val buyMaxVol = buyMaxVolJson?.optDouble(1) ?: 1.0
            Log.d(TAG, "========buyMAX:$buyMaxVol=======")

            val maxVol = Math.max(askMaxVol, buyMaxVol)

            Log.d(TAG, "========maxVol:$maxVol=========")

            sellTape(askList, maxVol)
            buyTape(buyList, maxVol)
        }


    }


    /**
     *Selling offer
     */
    private fun sellTape(list: ArrayList<JSONArray>, maxVol: Double) {
        list.sortByDescending {
            it.optDouble(0)
        }

        for (i in 0 until sellViewList.size) {
            /**
             *Selling offer
             */
            if (list.size > sellViewList.size) {
                val subList = list.subList(list.size - sellViewList.size, list.size)
                if (subList.isNotEmpty()) {
                    /*****Deep Background Color START****/
                    sellViewList[i].fl_bg_item.backgroundColor = CpColorUtil.getMinorColorType(isRise = false)
                    val layoutParams = sellViewList[i].fl_bg_item.layoutParams
                    val curVolume = subList[i].optDouble(1)
                    val width = (curVolume / maxVol) * measuredWidth * 0.37
//                    Log.d(TAG, "=======sell==curVolume is $curVolume,maxVolume is $maxVol,showBgwidth is $width，itemWidth is ${measuredWidth * 0.4}")
                    layoutParams.width = width.toInt()
                    sellViewList[i].fl_bg_item.layoutParams = layoutParams
                    /*****Deep background color END****/
                    val price = CpSymbolInterceptUtils.interceptData(
                            subList[i].optString(0).replace("\"", "").trim(),
                            depth_level,
                            "price")
                    sellViewList[i].tv_price_item.text = price
                    sellViewList[i].tv_price_item.textColor = CpColorUtil.getMainColorType(isRise = false)
                    val order = orderList.filter {
                        val isSell = it.side == "SELL"
                        var orderPrice = it.price.getPriceSplitZero()
                        if(isSell){
                            orderPrice = BigDecimal(orderPrice).setScale(depth_level,BigDecimal.ROUND_UP).toPlainString()
                        }else{
                            orderPrice = BigDecimal(orderPrice).setScale(depth_level,BigDecimal.ROUND_DOWN).toPlainString()
                        }
                        isSell && orderPrice.equals(price) && it.contractId.equals(mContractId.toString())
                    }

                    sellViewList[i].im_sell.visibility = order.isNotEmpty().visiableOrGone()
                    var amount = subList[i].optString(1)
                    //0 pieces and 1 coin
                    amount = if (coUnit == 0) amount else CpBigDecimalUtils.mulStr(
                            amount,
                            multiplier,
                            multiplierPrecision
                    )

                    sellViewList[i].tv_quantity_item.text = CpBigDecimalUtils.showDepthVolumeNew(amount,coUnit,multiplierPrecision)
                }
            } else {
//                Log.d(TAG, "======VVV=======")
                val temp = sellViewList.size - list.size
                sellViewList[i].tv_price_item.text = "--"
                sellViewList[i].tv_quantity_item.text = "--"
                sellViewList[i].ll_item.backgroundColor = CpColorUtil.getColor(R.color.transparent)
                if (i >= temp) {
                    /*****Deep Background Color START****/
                    sellViewList[i].fl_bg_item.backgroundColor = CpColorUtil.getMinorColorType(isRise = false)
                    val layoutParams = sellViewList[i].fl_bg_item.layoutParams
                    val width = (list[i - temp].optDouble(1) / maxVol) * measuredWidth * 0.4
                    layoutParams.width = width.toInt()
                    sellViewList[i].fl_bg_item.layoutParams = layoutParams
                    /*****Deep background color END****/
                    val price = CpSymbolInterceptUtils.interceptData(
                            list[i - temp].optString(0).replace("\"", "").trim(),
                            depth_level,
                            "price")
                    sellViewList[i].tv_price_item.text = price
                    sellViewList[i].tv_price_item.textColor = CpColorUtil.getMainColorType(isRise = false)
                    val order = orderList.filter {
                        val isSell = it.side == "SELL"
                        var orderPrice = it.price.getPriceSplitZero()
                        if(isSell){
                            orderPrice = BigDecimal(orderPrice).setScale(depth_level,BigDecimal.ROUND_UP).toPlainString()
                        }else{
                            orderPrice = BigDecimal(orderPrice).setScale(depth_level,BigDecimal.ROUND_DOWN).toPlainString()
                        }
                        isSell && orderPrice.equals(price) && it.contractId.equals(mContractId.toString())
                    }
                    sellViewList[i].im_sell.visibility = order.isNotEmpty().visiableOrGone()

                    var amount = list[i - temp].optString(1)
                    amount = if (coUnit == 0) amount else CpBigDecimalUtils.mulStr(
                            amount,
                            multiplier,
                            multiplierPrecision
                    )

                    sellViewList[i].tv_quantity_item.text = CpBigDecimalUtils.showDepthVolumeNew(amount,coUnit,multiplierPrecision)

                } else {
                    sellViewList[i].run {
                        tv_price_item.text = "--"
                        tv_quantity_item.text = "--"
                        fl_bg_item.setBackgroundResource(R.color.transparent)
                        im_sell.visibility = View.GONE
                    }

                }
            }


        }
    }

    /**
     *Buying
     */
    private fun buyTape(list: ArrayList<JSONArray>, maxVol: Double) {

        /**
         *Buy to take maximum
         */
        list.sortByDescending {
            it.optDouble(0)
        }

        for (i in 0 until buyViewList.size) {
            /**
             *Buying
             */
//            if (list.size > i) {
//
//                ll_buy_price.get(i).run {
//                    /*****Deep Background Color START****/
//                    fl_bg_item.backgroundColor = CpColorUtil.getMinorColorType()
//                    val layoutParams = fl_bg_item.layoutParams
//                    val width = (list[i].optDouble(1) / maxVol) * measuredWidth * 0.37
//                    layoutParams.width = width.toInt()
//                    fl_bg_item.layoutParams = layoutParams
//                    /*****Deep background color END****/
//                    val price = CpSymbolInterceptUtils.interceptData(
//                            list[i].optString(0).replace("\"", "").trim(),
//                            depth_level,
//                            "price")
//                    tv_price_item.text = price
//                    val order = orderList.filter { it.side == "BUY" && it.price.getPriceSplitZero() == price.getPriceSplitZero() }
//                    buyViewList[i].im_sell.visibility = order.isNotEmpty().visiableOrGone()
//                    tv_quantity_item.text = CpBigDecimalUtils.showDepthVolumeNew(list[i].optString(1).trim())
//                }
//
//            } else {
//                buyViewList[i].run {
//                    tv_price_item.text = "--"
//                    tv_quantity_item.text = "--"
//                    fl_bg_item.setBackgroundResource(R.color.transparent)
//                    im_sell.visibility = View.GONE
//                }
//
//            }


            if (list.size > i) {
//                val subList = list.subList(list.size - buyViewList.size, list.size)
                val subList = list
                if (subList.isNotEmpty()) {
                    /*****Deep Background Color START****/
                    buyViewList[i].fl_bg_item.backgroundColor = CpColorUtil.getMinorColorType(isRise = true)
                    val layoutParams = buyViewList[i].fl_bg_item.layoutParams
                    val curVolume = subList[i].optDouble(1)
                    val width = (curVolume / maxVol) * measuredWidth * 0.37
//                    Log.d(TAG, "=======sell==curVolume is $curVolume,maxVolume is $maxVol,showBgwidth is $width，itemWidth is ${measuredWidth * 0.4}")
                    layoutParams.width = width.toInt()
                    buyViewList[i].fl_bg_item.layoutParams = layoutParams
                    /*****Deep background color END****/
                    val price = CpSymbolInterceptUtils.interceptData(
                            subList[i].optString(0).replace("\"", "").trim(),
                            depth_level,
                            "price")
                    buyViewList[i].tv_price_item.text = price
                    buyViewList[i].tv_price_item.textColor = CpColorUtil.getMainColorType(isRise = true)
                    val order = orderList.filter {
                        val isBuy =  it.side == "BUY"
                        var orderPrice = it.price.getPriceSplitZero()
                        if(!isBuy){
                            orderPrice = BigDecimal(orderPrice).setScale(depth_level,BigDecimal.ROUND_UP).toPlainString()
                        }else{
                            orderPrice = BigDecimal(orderPrice).setScale(depth_level,BigDecimal.ROUND_DOWN).toPlainString()
                        }
                        isBuy && orderPrice.equals(price) && it.contractId.equals(mContractId.toString())
                    }

                    buyViewList[i].im_sell.visibility = order.isNotEmpty().visiableOrGone()
                    var amount = list[i].optString(1).trim()
                    amount = if (coUnit == 0) amount else CpBigDecimalUtils.mulStr(
                            amount,
                            multiplier,
                            multiplierPrecision
                    )
                    buyViewList[i].tv_quantity_item.text = CpBigDecimalUtils.showDepthVolumeNew(amount,coUnit,multiplierPrecision)
                }
            } else {
                buyViewList[i].run {
                    tv_price_item.text = "--"
                    tv_price_item.textColor = CpColorUtil.getMainColorType(isRise = true)
                    tv_quantity_item.text = "--"
                    fl_bg_item.setBackgroundResource(R.color.transparent)
                    im_sell.visibility = View.GONE
                }

//                Log.d(TAG, "======VVV=======")
//                val temp = buyViewList.size - list.size
//                buyViewList[i].tv_price_item.text = "--"
//                buyViewList[i].tv_quantity_item.text = "--"
//                buyViewList[i].ll_item.backgroundColor = CpColorUtil.getColor(R.color.transparent)
//                if (i >= temp) {
//                    /*****Deep Background Color START****/
//                    buyViewList[i].fl_bg_item.backgroundColor = CpColorUtil.getMinorColorType(isRise = true)
//                    val layoutParams = buyViewList[i].fl_bg_item.layoutParams
//                    val width = (list[i - temp].optDouble(1) / maxVol) * measuredWidth * 0.4
//                    layoutParams.width = width.toInt()
//                    buyViewList[i].fl_bg_item.layoutParams = layoutParams
//                    /*****Deep background color END****/
//                    val price = CpSymbolInterceptUtils.interceptData(
//                            list[i - temp].optString(0).replace("\"", "").trim(),
//                            depth_level,
//                            "price")
//                    buyViewList[i].tv_price_item.text = price
//                    val order = orderList.filter { it.side == "BUY" && it.price.getPriceSplitZero() == price.getPriceSplitZero() }
//                    buyViewList[i].im_sell.visibility = order.isNotEmpty().visiableOrGone()
//                    buyViewList[i].tv_quantity_item.text = CpBigDecimalUtils.showDepthVolumeNew(list[i - temp].optString(1))
//
//                } else {
//                    buyViewList[i].run {
//                        tv_price_item.text = "--"
//                        tv_quantity_item.text = "--"
//                        fl_bg_item.setBackgroundResource(R.color.transparent)
//                        im_sell.visibility = View.GONE
//                    }
//
//                }
            }
        }
    }


    override fun onVisibilityChanged(changedView: View, visibility: Int) {
        super.onVisibilityChanged(changedView, visibility)
        if (visibility == View.VISIBLE) {
        }
    }


    /**
     *In case of price limit, the default price is: closing price
     */
    private fun isFirstSetValue(): Boolean {
        return trade_amount_view.editPriceIsNull()
    }


    fun transactionType(): Boolean {
        return trade_amount_view.transactionType == 0
    }


    fun initCoinSymbol(symbols: String?, isLevel: Boolean = false) {
        if (symbols != null && symbols.isNotEmpty()) {
            var symbol = ""
            if (isLevel) {
                symbol = symbols.split(" ")[0]
            } else {
                symbol = symbols
            }
            val result = symbol.split("/")
            if (result.size == 2) {
                tv_cp_overview_text6.text = coinBySplit(true, result[1])
            }
        }
    }

    private fun coinBySplit(isPrice: Boolean, value: String): String {
        val first = CpLanguageUtil.getString(context, if (isPrice) "cp_overview_text6" else "cp_overview_text8")
        val message = StringBuffer(first)
        return message.append("(").append(value).append(")").toString()
    }


    //Whether disk data exists
    fun isDepth(isBuy: Boolean = true): Boolean {
        val items = if (isBuy) buyViewList else sellViewList
        if (items.size == 0) {
            return false
        }
        val price = items[0].tv_price_item.text
        if (price == "--") {
            return false
        }
        return true
    }

    fun depthIsRender(): Boolean {
        return isDepth() || isDepth(false)
    }

    fun depthBuyOrSell(): ArrayList<Any> {
        val array = arrayListOf<Any>();
        if (depthIsRender()) {
            array.add("true")
        }
        return array
    }


    private fun updateAvailableVol(priceStr: String, level: Int): String {
        var isOpen = true;
        var price = "0";
        if (TextUtils.isEmpty(priceStr)) {
            price = "0"
        }
        var buyPrice = priceStr
        var sellPrice = priceStr

        mUserConfigInfoJson?.apply {
            val leverOriginCeilingObj = optJSONObject("leverOriginCeiling")
            val iteratorKeys = leverOriginCeilingObj.keys()
            var leverOriginCeilingArr = ArrayList<Int>()
            while (iteratorKeys.hasNext()) {
                val key = iteratorKeys.next().toInt()
                leverOriginCeilingArr.add(key)
            }
            leverOriginCeilingArr.sort()
            for (buff in leverOriginCeilingArr) {
                if (level.toInt() <= buff.toInt()) {
                    maxOpenLimit = leverOriginCeilingObj.optString(buff.toString())
                    break
                }
            }
        }

        //Available amount calculated by margin
        val buybuff1 = CpBigDecimalUtils.canBuyStr(
                isOpen,
                CpContractBuyOrSellHelper().orderType == 2,
                contractSide.equals("1"),
                buyPrice,
                multiplier,
                canUseAmount,
                canCloseVolumeBuy,
                level.toString(),
                marginRate,
                multiplierPrecision,
                base
        )
        //Available amount calculated by margin
        val sellbuff1 = CpBigDecimalUtils.canBuyStr(
                isOpen,
                CpContractBuyOrSellHelper().orderType == 2,
                contractSide.equals("1"),
                sellPrice,
                multiplier,
                canUseAmount,
                canCloseVolumeSell,
                level.toString(),
                marginRate,
                multiplierPrecision,
                base
        )

        //The amount that can be opened through risk limit calculation
        val buybuff2 = CpBigDecimalUtils.canOpenStr(
                contractSide.equals("1"),
                CpContractBuyOrSellHelper().orderType == 2,
                buyPrice,
                maxOpenLimit,
                positionValue,
                entrustedValue,
                multiplier,
                marginRate,
                multiplierPrecision,
                base
        )
        //The amount that can be opened through risk limit calculation
        val sellbuff2 = CpBigDecimalUtils.canOpenStr(
                contractSide.equals("1"),
                CpContractBuyOrSellHelper().orderType == 2,
                sellPrice,
                maxOpenLimit,
                positionValue,
                entrustedValue,
                multiplier,
                marginRate,
                multiplierPrecision,
                base
        )
        return (CpBigDecimalUtils.min(buybuff1.split(" ")[0], buybuff2.split(" ")[0]))
    }


    override fun dispatchTouchEvent(ev: MotionEvent): Boolean {
        val isClick = inRangeOfView(trade_amount_view, ev)
        LogUtils.e("isClick:" + isClick)
        if (isClick && noLoginOrNoOpenContract()) return true
        return super.dispatchTouchEvent(ev)
    }

    private fun inRangeOfView(view: View, ev: MotionEvent): Boolean {
        val location = IntArray(2)
        view.getLocationOnScreen(location)
        val x = location[0]
        val y = location[1]
//        return if (ev.x < x || ev.x > x + view.width || ev.y < y || ev.y > y + view.height) {
//            false
//        } else true

        val r = Rect()
        view.getGlobalVisibleRect(r)
        if (ev.rawX > r.left && ev.rawX < r.right && ev.rawY > r.top && ev.rawY < r.bottom) {
            return true
        } else {
            return false
        }
    }

    //Scenario of not logging in and not opening a contract
    private fun noLoginOrNoOpenContract():Boolean{
        if(isLoading) return true
        if (!CpClLogicContractSetting.isLogin()) {
            CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.sl_contract_go_login_page))
            return true
        }
        if (openContract == 0 && mContractDialogFlag) {
            mContractDialogFlag = false
            CpDialogUtil.showCreateContractDialog(context, object : CpNewDialogUtils.DialogBottomListener {
                override fun sendConfirm() {
                    CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.sl_contract_open_contract_event))
                }
            }){
                mContractDialogFlag = true
            }
            return true
        }
        return false
    }

    override fun intercept(): Boolean {
        if(noLoginOrNoOpenContract()) return true
        return super.intercept()
    }

}
