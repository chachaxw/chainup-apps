package com.yjkj.chainup.new_version.adapter

import androidx.recyclerview.widget.GridLayoutManager
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.yjkj.chainup.R
import com.yjkj.chainup.bean.ScaleInfoBean
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.util.toPercent
import com.yjkj.chainup.wedegit.DisplayUtils

class AgentLevelAdapter(val list:ArrayList<ScaleInfoBean>) : BaseQuickAdapter<ScaleInfoBean,BaseViewHolder>(R.layout.item_agent_level,list) {
    override fun convert(holder: BaseViewHolder, item: ScaleInfoBean) {

        val adapterPosition = holder.adapterPosition
        val layoutParams = holder.itemView.layoutParams as GridLayoutManager.LayoutParams
        if(adapterPosition%2==0){

            layoutParams.rightMargin = DisplayUtils.dip2px(context,8.0f)

        }
        layoutParams.bottomMargin = DisplayUtils.dip2px(context,10.0f)
        holder.itemView.layoutParams = layoutParams

        holder.setText(R.id.tv_level,String.format(LanguageUtil.getString(context,"agent_level"),item.level))
        holder.setText(R.id.tv_ratio, item.scale.toPercent())
    }
}
