package com.chainup.kit.dialog.adapter

import androidx.core.content.ContextCompat
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.chainup.kit.bean.KKItemTabInfo
import com.example.chainup_kit.R

open class KKBottomSheetRvAdapterV2(data: ArrayList<KKItemTabInfo>, var position: Int) : BaseQuickAdapter<KKItemTabInfo, BaseViewHolder>(
    R.layout.item_bottom_sheet_list, data) {

    override fun convert(helper: BaseViewHolder, item: KKItemTabInfo) {
        helper.setText(R.id.tv_content, item.name)
        helper.setBackgroundResource(
            R.id.ll_item,
            if(helper.adapterPosition == 0){
                R.drawable.bg_item_press_corner12_selector
            }else {
                R.drawable.bg_item_press_selector
            }
        )
        helper.setGone(R.id.view_line, helper.adapterPosition == data.size-1)

        if (position == helper.adapterPosition) {
            helper.setTextColor(R.id.tv_content, ContextCompat.getColor(context, R.color.main_blue))
        } else {
            helper.setTextColor(R.id.tv_content, ContextCompat.getColor(context, R.color.text_color))
        }
    }

}
