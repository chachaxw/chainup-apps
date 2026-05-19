package com.chainup.contract.adapter

import android.view.ViewGroup.MarginLayoutParams
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.chainup.contract.R
import com.chainup.contract.bean.LeverMarginInfo
import com.chainup.contract.utils.CpBigDecimalUtils
import com.chainup.contract.utils.CpClLogicContractSetting
import com.chainup.kit.utils.BigDecimalUtils
import com.chainup.kit.utils.PublicSizeUtil
import com.yjkj.chainup.manager.CpLanguageUtil

class CpContractPublicListAdapter : BaseQuickAdapter<LeverMarginInfo,BaseViewHolder>(R.layout.item_rv_contract_public) {
    var marginCoin = ""
    init {
        addChildClickViewIds(R.id.tv_position_hold,R.id.tv_lever_max,R.id.tv_keep_margin_rate)
    }

    fun initMarginCoin(contractId:Int){
        marginCoin = CpClLogicContractSetting.getContractMarginCoinById(context,contractId)
        notifyDataSetChanged()
    }

    override fun convert(holder: BaseViewHolder, item: LeverMarginInfo) {
        if(holder.adapterPosition == 0) {
            val itemView = holder.itemView
            val marginLayoutParams = itemView.layoutParams as MarginLayoutParams
            marginLayoutParams.topMargin = PublicSizeUtil.dp2px(context,20.0f)
            itemView.layoutParams = marginLayoutParams
        }

        holder.setText(R.id.tv_position_hold_value,BigDecimalUtils.fmtMicrometer(item.minPositionValue) +" - " + BigDecimalUtils.fmtMicrometer(item.maxPositionValue))
        holder.setText(R.id.tv_position_hold,String.format(CpLanguageUtil.getString(context,"PositionBraket"),marginCoin))
        holder.setText(R.id.tv_lever_max_value,item.maxLever)
        holder.setText(R.id.tv_lever_max,CpLanguageUtil.getString(context,"MaxLeverage"))
        holder.setText(R.id.tv_keep_margin_rate_value,item.minMarginRate)
        holder.setText(R.id.tv_keep_margin_rate,CpLanguageUtil.getString(context,"MtncMgRt"))
        holder.setText(R.id.tv_level,item.level)
    }
}