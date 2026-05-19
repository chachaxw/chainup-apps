package com.yjkj.chainup.new_contract.adapter

import android.view.View
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.DiffUtil
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.chainup.contract.R
import com.chainup.contract.eventbus.CpEventBusUtil
import com.chainup.contract.eventbus.CpMessageEvent
import com.chainup.contract.utils.*
import com.chainup.contract.view.trade.LongPressRelativeLayout
import org.json.JSONObject
import java.util.*

/**
 * Created by zj on 2018/3/7.
 * @param data
 * @param islike Is it optional? If it is, you need to hide the icon
 */
class CpContractDropAdapter(data: ArrayList<JSONObject>,val islike:Boolean = false) : BaseQuickAdapter<JSONObject, BaseViewHolder>(R.layout.cp_item_contract_drop, data) {

    private val TAG:String = this::class.java.simpleName
    //The selected item is used to set the bg of the selected item
    private var selectPosition:Int? = null

    var listener:OnMyItemEvent? = null
    var isPressing:Boolean = false

    override fun convert(helper: BaseViewHolder, ticker: JSONObject) {
        ticker?.let {
            val dfRate = CpNumberUtil().getDecimal(2)
            helper?.setText(R.id.tv_contract_name, CpClLogicContractSetting.getContractShowNameById(context, ticker.optInt("id")))
            if (!ticker.isNull("rose")) {
                val chg = CpBigDecimalUtils.mul(ticker.optString("rose"), "100", 2).toDouble()
                //proportion
                val tvContractChg = helper?.getView<TextView>(R.id.tv_contract_chg)
                tvContractChg?.run {
                    text = if (chg > 0) "+" + dfRate.format(chg) + "%" else dfRate.format(chg) + "%"
                    setTextColor(CpColorUtil.getMainColorType(chg >= 0,CpBigDecimalUtils.compareTo(chg.toString(),"0")==0))
                }
            }
            if (!ticker.isNull("close")) {
                val chg = CpBigDecimalUtils.mul(ticker.optString("rose"), "100", 2).toDouble()
                //Closing price
                val tvLastPrice = helper?.getView<TextView>(R.id.tv_last_price)
                tvLastPrice?.run {
                    text = ticker.optString("close")
                    setTextColor(CpColorUtil.getMainColorType(chg >= 0,CpBigDecimalUtils.compareTo(chg.toString(),"0")==0))
                }
            }


            val mLongPressRelativeLayout:LongPressRelativeLayout = helper.getView(R.id.rl_content)
            mLongPressRelativeLayout.run {
                setOnLongClickListener(object:LongPressRelativeLayout.OnMyLongPressClickListener{
                    override fun onLongClick(v: View?): Boolean {
                        isPressing = false
                        listener?.onLongPress(v!!,helper.adapterPosition)
                        return true
                    }

                    override fun onDown() {
                        isPressing = true
                    }

                    override fun onUp() {
                        isPressing = false
                    }

                })
                setOnClickListener(object :View.OnClickListener{
                    override fun onClick(v: View?) {
//                        clickItemHandler(ticker)
                        listener?.onPress(v!!,helper.adapterPosition,ticker)
                    }
                })
            }

            val isCollect = CpClLogicContractSetting.hasCollect(context,ticker.optInt("id"))

            //Set whether the optional icon is displayed
            helper.setGone(
                R.id.ic_collect_like,
                //If it is optional ->direct true, it will be hidden (||) ->go !isCollect
                islike || !isCollect
            )

            helper.itemView.background = if(selectPosition==helper.adapterPosition) ContextCompat.getDrawable(this.context,R.color.card_bg_color_2)
                else ContextCompat.getDrawable(this.context,R.drawable.bg_market_contract_click)
        }
    }
    fun setDiffData(diffCallback: CpMarketTabDiffCallback) {
        if (emptyLayout!=null &&  emptyLayout?.childCount == 1) {
            setList(diffCallback.getNewData())
            return
        }
        val diffResult = DiffUtil.calculateDiff(diffCallback, true)
        data = diffCallback.getNewData() as ArrayList<JSONObject>
        diffResult.dispatchUpdatesTo(this)
    }

    fun setSelectPosition(position:Int){
        this.selectPosition = position
        notifyItemChanged(position)
    }
    fun clearPostioin(position:Int){
        this.selectPosition = null
        notifyItemChanged(position)
    }





    interface OnMyItemEvent{
        fun onLongPress(view: View,position: Int)
        fun onPress(view: View,position: Int,ticker: JSONObject){

        }
    }

}
