package com.chainup.contract.adapter

import androidx.core.content.ContextCompat
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.chainup.contract.R
import com.chainup.contract.bean.CpTabInfo

/**
 *
 *@param position The currently selected type
 *Bottom pop-up daily log adapter
 */
open class CpPopAdapter(data: ArrayList<CpTabInfo>, var position: Int) : BaseQuickAdapter<CpTabInfo, BaseViewHolder>(R.layout.cp_item_string_pop_adapter, data) {

    init {
        addChildClickViewIds(R.id.ic_tip)
    }
    override fun convert(helper: BaseViewHolder, item: CpTabInfo) {
        helper?.setText(R.id.tv_content, item?.name)
        helper?.setTextColor(
            R.id.tv_content,
            ContextCompat.getColor(context,if (position == item?.index) R.color.main_blue else R.color.text_color_1)
        )
        if(item.extrasBol==true){
            helper.setGone(R.id.ic_tip,false)
        }else{
            helper.setGone(R.id.ic_tip,true)
        }

//        if (helper.adapterPosition==0){
//            helper?.setBackgroundResource(R.id.tv_content,R.drawable.cp_top_coin_nosel_bg)
//        }else if (helper.adapterPosition==data.size-1){
//            helper?.setBackgroundResource(R.id.tv_content,R.drawable.cp_bottom_coin_nosel_bg)
//        }else{
//            helper?.setBackgroundColor(R.id.tv_content,ContextCompat.getColor(context, R.color.bg_card_color))
//        }
    }

}
