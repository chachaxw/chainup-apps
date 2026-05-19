package com.chainup.contract.adapter

import androidx.core.content.ContextCompat
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.chainup.contract.R
import com.chainup.contract.bean.CpTabInfo
import com.chainup.contract.utils.CpClLogicContractSetting
import com.yjkj.chainup.manager.CpLanguageUtil


open class CpCoinSelectRightAdapter(data: ArrayList<CpTabInfo>, var position: Int) : BaseQuickAdapter<CpTabInfo, BaseViewHolder>(R.layout.item_select_coins_right, data) {

    override fun convert(helper: BaseViewHolder, item: CpTabInfo) {
        helper?.setText(R.id.tv_content, CpClLogicContractSetting.getContractShowNameById(context,item.index))
        if (position == item?.index) {
            helper?.setTextColor(R.id.tv_content, ContextCompat.getColor(context, R.color.main_blue))
        } else {
            helper?.setTextColor(R.id.tv_content, ContextCompat.getColor(context, R.color.text_color))
        }
    }

}
open class CpCoinSelectRightNewAdapter(data: ArrayList<CpTabInfo>) : BaseQuickAdapter<CpTabInfo, BaseViewHolder>(R.layout.item_select_coins_right, data) {

    override fun convert(helper: BaseViewHolder, item: CpTabInfo) {
        if (item.index==-2){
            helper?.setText(R.id.tv_content, CpLanguageUtil.getString(context,"cp_all_contract"))
        }else{
            helper?.setText(R.id.tv_content, CpClLogicContractSetting.getContractShowNameById(context,item.index))
        }
        if (item.extrasBol == true) {
            helper?.setTextColor(R.id.tv_content, ContextCompat.getColor(context, R.color.main_blue))
        } else {
            helper?.setTextColor(R.id.tv_content, ContextCompat.getColor(context, R.color.text_color))
        }
    }

}
