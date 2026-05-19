package com.chainup.kit.dialog.adapter

import android.view.View
import android.widget.LinearLayout
import com.chad.library.adapter.base.BaseMultiItemQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.example.chainup_kit.R

open class KKBottomCardListRvAdapter(data: MutableList<KKItemCardEntity>?) : BaseMultiItemQuickAdapter<KKItemCardEntity, BaseViewHolder>(data) {


    init {
        addItemType(KKItemCardEntity.CARD_LAYOUT_TYPE_1, R.layout.public_cell_card1)

        addChildClickViewIds(R.id.iv_icon_tip)
    }


    override fun convert(holder: BaseViewHolder, item: KKItemCardEntity) {
        holder.getView<View>(R.id.ll_item).isSelected = item.isSelect

        when(item.itemType){
            KKItemCardEntity.CARD_LAYOUT_TYPE_1 -> {
                holder.setText(R.id.tv_title,item.title)
                holder.setGone(R.id.iv_icon_tip,"".equals(item.content) || null == item.content)

            }
        }
    }

    override fun setOnItemClick(v: View, position: Int) {
        super.setOnItemClick(v, position)
        for (item in data) item.isSelect = false
        data[position].isSelect = true
        notifyDataSetChanged()
    }

}
