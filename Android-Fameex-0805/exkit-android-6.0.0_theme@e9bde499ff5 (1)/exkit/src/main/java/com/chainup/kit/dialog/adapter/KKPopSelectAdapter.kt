package com.chainup.kit.dialog.adapter

import android.view.Gravity
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.content.ContextCompat
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.chainup.kit.bean.KKItemTabInfo
import com.example.chainup_kit.R

/**
 *
 *@param position The currently selected type
 *Bottom pop-up daily log adapter
 */
open class KKPopSelectAdapter(data: ArrayList<KKItemTabInfo>, var position: Int,val selectTextSize:Float? = null,val gravity: Int = Gravity.CENTER) : BaseQuickAdapter<KKItemTabInfo, BaseViewHolder>(
    R.layout.public_item_string_pop_adapter, data) {

    init {
        addChildClickViewIds(R.id.ic_tip)
    }
    override fun convert(helper: BaseViewHolder, item: KKItemTabInfo) {
        if(selectTextSize!=null){
            helper.getView<TextView>(R.id.tv_content).paint.textSize = selectTextSize
        }
        helper?.setText(R.id.tv_content, item?.name)
        helper?.setTextColor(
            R.id.tv_content,
            ContextCompat.getColor(context,if (position == helper.adapterPosition) R.color.main_4 else R.color.text_color_1)
        )
        if(item.extras==true){
            helper.setGone(R.id.ic_tip,false)
        }else{
            helper.setGone(R.id.ic_tip,true)
        }

        helper.getView<LinearLayout>(R.id.ll_content).gravity = gravity

//        if (helper.adapterPosition==0){
//            helper?.setBackgroundResource(R.id.tv_content,R.drawable.cp_top_coin_nosel_bg)
//        }else if (helper.adapterPosition==data.size-1){
//            helper?.setBackgroundResource(R.id.tv_content,R.drawable.cp_bottom_coin_nosel_bg)
//        }else{
//            helper?.setBackgroundColor(R.id.tv_content,ContextCompat.getColor(context, R.color.bg_card_color))
//        }
    }

}
