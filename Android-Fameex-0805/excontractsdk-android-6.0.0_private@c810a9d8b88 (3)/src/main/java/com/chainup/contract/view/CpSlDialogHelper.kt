package com.chainup.contract.view

import android.app.Activity
import android.content.Context
import androidx.appcompat.app.AppCompatActivity
import android.text.Html
import android.text.TextUtils
import android.view.*
import android.widget.*
import com.chainup.contract.R
import com.chainup.contract.app.CpMyApp
import com.chainup.contract.bean.CpTabInfo
import com.chainup.contract.eventbus.CpEventBusUtil
import com.chainup.contract.eventbus.CpMessageEvent
import com.chainup.contract.ui.activity.CpWebViewActivity
import com.chainup.contract.utils.*
import com.chainup.contract.view.dialog.CpTDialog
import com.chainup.contract.view.dialog.listener.OnCpBindViewListener
import com.chainup.kit.utils.PublicSizeUtil
import com.chainup.kit.views.base.BaseMaxHeightScrollView
import com.timmy.tdialog.listener.OnBindViewListener
import com.yjkj.chainup.manager.CpLanguageUtil
import com.yjkj.chainup.new_contract.activity.*
import com.zyyoona7.popup.EasyPopup
import com.zyyoona7.popup.XGravity
import com.zyyoona7.popup.YGravity
import org.json.JSONObject


object CpSlDialogHelper {


    /**
     *Opening Contract/Purchase Prompt Dialog Box
     */
    fun showSimpleCreateContractDialog(context: Context, viewListener: OnCpBindViewListener?,
                                       listener: CpNewDialogUtils.DialogBottomListener
    ): CpTDialog {
        return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.cp_item_simple_create_contract_dialog)
                .setScreenWidthAspect(context, 0.8f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.5f)
                .setCancelableOutside(false)
                .setOnBindViewListener(viewListener)
                .addOnClickListener(R.id.tv_confirm_btn, R.id.tv_cancel_btn)
                .setOnViewClickListener { _, view, tDialog ->
                    when (view.id) {
                        R.id.tv_confirm_btn -> {
                            listener.sendConfirm()
                            tDialog.dismiss()
                        }
                        R.id.tv_cancel_btn -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()

    }


    /**
     *Contract Transaction Confirmation Dialog Box
     */
    fun showOrderCreateConfirmDialog(context: Context,
                                     titleColor: Int,
                                     title: String,
                                     contractName: String,
                                     price: String,
                                     triggerPrice: String,
                                     costPrice: String,
                                     amountValue: String,
                                     orderType: Int,
                                     profitTriggerPrice: String,
                                     lossTriggerPrice: String,
                                     sureLisener: CpNewDialogUtils.DialogBottomListener
    ): CpTDialog {
        return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.cp_item_order_create_confirm_dialog)
                .setScreenWidthAspect(context, 0.9f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.5f)
                .setCancelableOutside(false)
                .setOnBindViewListener(OnCpBindViewListener {
                    it.getView<TextView>(R.id.btn_cancel).setText(CpLanguageUtil.getString(context, "cp_overview_text56"))
                    it.getView<TextView>(R.id.btn_ok).setText(R.string.cp_calculator_text16)
                    //Title
                    it.setText(R.id.tv_title, title)
                    it.setTextColor(R.id.tv_title, titleColor)
                    //Contract
                    it.setText(R.id.tv_contract, contractName)
                    //Price
                    it.setText(R.id.tv_price_value, price)
                    //Commission price
                    it.setText(R.id.tv_commission_price_value, price)
                    //Trigger Price
                    it.setText(R.id.tv_trigger_price_value, triggerPrice)
                    //Cost
                    it.setText(R.id.tv_cost_value, costPrice)
                    //Quantity
                    it.setText(R.id.tv_number_value, amountValue)
                    //Stop Profit Trigger Price
                    it.setText(R.id.tv_stop_profit_entrust_price_value, profitTriggerPrice)
                    //Stop Loss Trigger Price
                    it.setText(R.id.tv_stop_loss_trigger_price_value, lossTriggerPrice)

                    it.setVisibility(R.id.ll_stop_profit, if (TextUtils.isEmpty(profitTriggerPrice)) View.GONE else View.VISIBLE)
                    it.setVisibility(R.id.ll_stop_loss, if (TextUtils.isEmpty(lossTriggerPrice)) View.GONE else View.VISIBLE)

                    when (orderType) {
                        1, 2, 4, 5, 6 -> {
                            it.setVisibility(R.id.ll_price, View.VISIBLE)
                            it.setVisibility(R.id.ll_cost, View.VISIBLE)

                            it.setVisibility(R.id.ll_trigger_price, View.GONE)
                            it.setVisibility(R.id.ll_commission_price, View.GONE)
                        }
                        else -> {
                            it.setVisibility(R.id.ll_price, View.GONE)
                            it.setVisibility(R.id.ll_cost, View.GONE)

                            it.setVisibility(R.id.ll_trigger_price, View.VISIBLE)
                            it.setVisibility(R.id.ll_commission_price, View.VISIBLE)
                        }
                    }
                })
                .addOnClickListener(R.id.btn_cancel, R.id.btn_ok, R.id.rl_not_remind)
                .setOnViewClickListener { it, view, tDialog ->
                    //Prompt or not
                    val cbNotRemind = it.getView<CheckBox>(R.id.cb_not_remind)
                    when (view.id) {
                        R.id.btn_cancel -> {
                            tDialog.dismiss()
                            CpPreferenceManager.getInstance(CpMyApp.instance()).putSharedBoolean(
                                    CpPreferenceManager.PREF_TRADE_CONFIRM, !cbNotRemind.isChecked)
                        }
                        R.id.btn_ok -> {
                            tDialog.dismiss()
                            sureLisener.sendConfirm()
                            CpPreferenceManager.getInstance(CpMyApp.instance()).putSharedBoolean(
                                    CpPreferenceManager.PREF_TRADE_CONFIRM, !cbNotRemind.isChecked)
                        }
                        R.id.rl_not_remind -> {
                            cbNotRemind.isChecked = !cbNotRemind.isChecked
                        }
                    }
                }
                .create()
                .show()

    }


    /**
     *Show calculation results dialog box
     */
    fun showCalculatorResultDialog(context: Context, itemList: List<CpTabInfo>?
    ): CpTDialog {
        return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.cp_item_calculator_result_dialog)
                .setScreenWidthAspect(context, 0.9f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.5f)
                .setCancelableOutside(false)
                .setOnBindViewListener(OnCpBindViewListener {
                    it.getView<TextView>(R.id.tv_title).setText(R.string.cp_calculator_text12)
                    it.getView<TextView>(R.id.tv_confirm_btn).setText(CpLanguageUtil.getString(context, "cp_extra_text28"))

                    val layoutInflater = LayoutInflater.from(context)
                    val llFeeWarpLayout = it.getView<LinearLayout>(R.id.ll_fee_warp_layout)
                    for (index in itemList!!.indices) {
                        val info = itemList[index]
                        val itemView = layoutInflater.inflate(R.layout.cp_auto_relative_item, llFeeWarpLayout, false)
                        llFeeWarpLayout.addView(itemView)
                        itemView.findViewById<TextView>(R.id.tv_left).text = info.name
                        itemView.findViewById<TextView>(R.id.tv_right).text = Html.fromHtml(info.extras)
                    }
                })
                .addOnClickListener(R.id.tv_cancel, R.id.tv_confirm_btn)
                .setOnViewClickListener { _, view, tDialog ->
                    when (view.id) {
                        R.id.tv_cancel -> {
                            tDialog.dismiss()
                        }
                        R.id.tv_confirm_btn -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()

    }

    /**
     *Open contract account pop-up window
     */
    fun showCreateContractAccountDialog(context: Context,
                                        listener: OnCpBindViewListener
    ): CpTDialog {
        return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.cp_create_contract_account_dialog)
                .setScreenWidthAspect(context, 0.9f)
                .setScreenHeightAspect(context, 0.8f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.5f)
                .setCancelableOutside(true)
                .setOnBindViewListener(listener)
                .create()
                .show()

    }


    /**
     *Display to achieve profit and loss details
     */
    fun showProfitLossDetailsDialog(context: Context, obj: JSONObject, type: Int): CpTDialog {
        return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.cp_item_profit_loss_detail_dialog)
                .setScreenWidthAspect(context, 0.8f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.5f)
                .setCancelableOutside(false)
                .setOnBindViewListener(OnCpBindViewListener {
                    it.getView<TextView>(R.id.tv_title).setText(R.string.cp_calculator_text12)
                    it.getView<TextView>(R.id.tv_confirm_btn).setText(CpLanguageUtil.getString(context, "cp_extra_text28"))
                    val tv_value1 = it.getView<TextView>(R.id.tv_value1)//Realized profit and loss
                    val tv_value2 = it.getView<TextView>(R.id.tv_value2)//Handling fee
                    val tv_value3 = it.getView<TextView>(R.id.tv_value3)//Capital expenses
                    val tv_value4 = it.getView<TextView>(R.id.tv_value4)//Closing profit and loss
                    val tv_value5 = it.getView<TextView>(R.id.tv_value5)//Apportionment
                    val tv_value6 = it.getView<TextView>(R.id.tv_value6)//Position settlement
                    val tv_loss_desc = it.getView<TextView>(R.id.tv_loss_desc)//Explanatory copy of profit and loss details

                    val tv_title = it.getView<TextView>(R.id.tv_title)
                    val tv_cp_position_text5 = it.getView<TextView>(R.id.tv_cp_position_text5)
                    val tv_cp_order_text14 = it.getView<TextView>(R.id.tv_cp_order_text14)
                    val tv_cp_position_text2 = it.getView<TextView>(R.id.tv_cp_position_text2)
                    val tv_cp_position_text3 = it.getView<TextView>(R.id.tv_cp_position_text3)
                    val tv_cp_position_text4 = it.getView<TextView>(R.id.tv_cp_position_text4)
                    val tv_cp_extra_text138 = it.getView<TextView>(R.id.tv_cp_extra_text138)
                    tv_title.text = CpLanguageUtil.getString(context, "cp_extra_text137")
                    tv_cp_position_text5.text = CpLanguageUtil.getString(context, "cp_position_text5")
                    tv_cp_order_text14.text = CpLanguageUtil.getString(context, "cp_order_text14")
                    tv_cp_position_text2.text = CpLanguageUtil.getString(context, "cp_position_text2")
                    tv_cp_position_text3.text = CpLanguageUtil.getString(context, "cp_position_text3")
                    tv_cp_position_text4.text = CpLanguageUtil.getString(context, "cp_position_text4")
                    tv_cp_extra_text138.text = CpLanguageUtil.getString(context, "cp_extra_text138")

                    tv_cp_order_text14.setText(if (type == 0) CpLanguageUtil.getString(context, "cp_order_text14") else CpLanguageUtil.getString(context, "cp_order_text99"))
                    tv_loss_desc.setText(if (type == 0) CpLanguageUtil.getString(context, "cp_extra_text115") else CpLanguageUtil.getString(context, "cp_extra_text108"))
                    val profitLossColor = if (CpBigDecimalUtils.compareTo(
                                    CpBigDecimalUtils.showSNormal(obj.optString("profitRealizedAmount"), obj.optInt("marginCoinPrecision")), "0") == 1) {
                        CpColorUtil.getMainColorType(true)
                    } else {
                        CpColorUtil.getMainColorType(false)
                    }
                    tv_value1.setTextColor(profitLossColor)

                    tv_value1.setText(CpBigDecimalUtils.showSNormal(obj.optString("profitRealizedAmount"), obj.optInt("marginCoinPrecision")) + " " + obj.optString("marginCoin"))
                    tv_value2.setText(CpBigDecimalUtils.showSNormal(obj.optString("tradeFee"), obj.optInt("marginCoinPrecision")) + " " + obj.optString("marginCoin"))
                    tv_value3.setText(CpBigDecimalUtils.showSNormal(obj.optString("capitalFee"), obj.optInt("marginCoinPrecision")) + " " + obj.optString("marginCoin"))
                    tv_value4.setText(CpBigDecimalUtils.showSNormal(obj.optString("closeProfit"), obj.optInt("marginCoinPrecision")) + " " + obj.optString("marginCoin"))
                    tv_value5.setText(CpBigDecimalUtils.showSNormal(obj.optString("shareAmount"), obj.optInt("marginCoinPrecision")) + " " + obj.optString("marginCoin"))
                    tv_value6.setText(CpBigDecimalUtils.showSNormal(obj.optString("settleProfit"), obj.optInt("marginCoinPrecision")) + " " + obj.optString("marginCoin"))

                    var ret = 0
                    ret = CpBigDecimalUtils.compareTo(
                            CpBigDecimalUtils.showSNormal(obj.optString("tradeFee"), obj.optInt("marginCoinPrecision")), "0")
                    it.getView<RelativeLayout>(R.id.rl_1).visibility = if (ret == 0) View.GONE else View.VISIBLE
                    ret = CpBigDecimalUtils.compareTo(
                            CpBigDecimalUtils.showSNormal(obj.optString("capitalFee"), obj.optInt("marginCoinPrecision")), "0")
                    it.getView<RelativeLayout>(R.id.rl_2).visibility = if (ret == 0) View.GONE else View.VISIBLE
                    ret = CpBigDecimalUtils.compareTo(
                            CpBigDecimalUtils.showSNormal(obj.optString("closeProfit"), obj.optInt("marginCoinPrecision")), "0")
                    it.getView<RelativeLayout>(R.id.rl_3).visibility = if (ret == 0) View.GONE else View.VISIBLE
                    ret = CpBigDecimalUtils.compareTo(
                            CpBigDecimalUtils.showSNormal(obj.optString("shareAmount"), obj.optInt("marginCoinPrecision")), "0")
                    it.getView<RelativeLayout>(R.id.rl_4).visibility = if (ret == 0) View.GONE else View.VISIBLE
                    ret = CpBigDecimalUtils.compareTo(
                            CpBigDecimalUtils.showSNormal(obj.optString("settleProfit"), obj.optInt("marginCoinPrecision")), "0")
                    it.getView<RelativeLayout>(R.id.rl_5).visibility = if (ret == 0) View.GONE else View.VISIBLE

                })
                .addOnClickListener(R.id.tv_cancel, R.id.tv_confirm_btn)
                .setOnViewClickListener { _, view, tDialog ->
                    when (view.id) {
                        R.id.tv_cancel -> {
                            tDialog.dismiss()
                        }
                        R.id.tv_confirm_btn -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()

    }

    fun showSubmitProfitLossDetailsDialog(context: Context, listener: CpNewDialogUtils.DialogBottomListener?, profit_title: String, loss_title: String, profit_info: String, loss_info: String): CpTDialog {
        return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.cp_item_submit_profit_loss_detail_dialog)
                .setScreenWidthAspect(context, 0.8f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.5f)
                .setCancelableOutside(true)
                .setOnBindViewListener(OnCpBindViewListener {
                    val tv_profit_title = it.getView<TextView>(R.id.tv_profit_title)
                    val tv_profit_info = it.getView<TextView>(R.id.tv_profit_info)
                    val tv_loss_title = it.getView<TextView>(R.id.tv_loss_title)
                    val tv_loss_info = it.getView<TextView>(R.id.tv_loss_info)
                    val tv_profit_line = it.getView<View>(R.id.tv_profit_line)
                    val tv_loss_line = it.getView<View>(R.id.tv_loss_line)

                    tv_profit_title.setText(profit_title)
                    tv_profit_info.setText(profit_info)

                    tv_loss_title.setText(loss_title)
                    tv_loss_info.setText(loss_info)

                    it.setText(R.id.tv_cancel,CpLanguageUtil.getString(context,"cp_overview_text56"))

                    tv_profit_title.visibility = if (TextUtils.isEmpty(profit_title)) View.GONE else View.VISIBLE
                    tv_profit_info.visibility = if (TextUtils.isEmpty(profit_title)) View.GONE else View.VISIBLE
                    tv_profit_line.visibility = if(TextUtils.isEmpty(profit_title)) View.GONE else View.VISIBLE

                    tv_loss_title.visibility = if (TextUtils.isEmpty(loss_title)) View.GONE else View.VISIBLE
                    tv_loss_info.visibility = if (TextUtils.isEmpty(loss_title)) View.GONE else View.VISIBLE
                    tv_loss_line.visibility = if(TextUtils.isEmpty(loss_title)) View.GONE else View.VISIBLE
                })
                .addOnClickListener(R.id.btn_ok, R.id.ll_not_again,R.id.tv_cancel)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.btn_ok -> {
                            tDialog.dismiss()
                            listener?.sendConfirm()
                            val cbNotAgain = viewHolder.getView<CheckBox>(R.id.cb_not_again)
                            CpPreferenceManager.getInstance(CpMyApp.instance()).putSharedBoolean(
                                    CpPreferenceManager.PREF_LOSS_CONFIRM, !cbNotAgain.isChecked)
                        }
                        R.id.ll_not_again -> {
                            val cbNotAgain = viewHolder.getView<CheckBox>(R.id.cb_not_again)
                            cbNotAgain.isChecked = !cbNotAgain.isChecked
                        }
                        R.id.tv_cancel -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()

    }

    fun showSubmitProfitLossDetailsDialog(context: Context): CpTDialog {
        return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.cp_item_submit_profit_loss_tip)
                .setWidth(CpSizeUtils.dp2px(312.0f))
                .setHeight(ViewGroup.LayoutParams.WRAP_CONTENT)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.5f)
                .setCancelableOutside(false)
                .setOnBindViewListener(OnCpBindViewListener {
                    it.getView<BaseMaxHeightScrollView>(R.id.sv_max_height).setMaxHeight(PublicSizeUtil.dp2px(context,458.0f))
                    it.setText(R.id.btn_ok, CpLanguageUtil.getString(context, "cp_extra_text28"))
                    it.setText(R.id.tv_title, CpLanguageUtil.getString(context, "cp_tip_text15"))
                    it.setText(R.id.tv_profit_title, CpLanguageUtil.getString(context, "cp_tip_text16"))
                    it.setText(R.id.tv_profit_info, CpLanguageUtil.getString(context, "cp_tip_text17"))
                    it.setText(R.id.tv_loss_title, CpLanguageUtil.getString(context, "cp_tip_text18"))
                    it.setText(R.id.tv_loss_info, CpLanguageUtil.getString(context, "cp_tip_text19"))
                    it.setText(R.id.tv_cp_tip_text20, CpLanguageUtil.getString(context, "cp_tip_text20"))
                    it.setText(R.id.tv_cp_tip_text21, CpLanguageUtil.getString(context, "cp_tip_text21"))
                    it.setText(R.id.tv_cp_tip_text22, CpLanguageUtil.getString(context, "cp_tip_text22"))
                    it.setText(R.id.tv_cp_tip_text23, CpLanguageUtil.getString(context, "cp_tip_text23"))
                })
                .addOnClickListener(R.id.btn_ok)
                .setOnViewClickListener { _, view, tDialog ->
                    when (view.id) {
                        R.id.btn_ok -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()

    }

}
