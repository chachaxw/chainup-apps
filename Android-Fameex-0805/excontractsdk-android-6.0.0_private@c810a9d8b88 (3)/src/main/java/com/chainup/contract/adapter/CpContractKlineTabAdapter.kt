package com.chainup.contract.adapter

import android.view.View
import androidx.core.content.ContextCompat
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.chainup.contract.R
import com.chainup.contract.utils.CpKLineUtil
import com.yjkj.chainup.new_contract.bean.CpKlineCtrlBean


class CpContractKlineTabAdapter(data:ArrayList<CpKlineCtrlBean>) : BaseQuickAdapter<CpKlineCtrlBean, BaseViewHolder>(R.layout.cp_item_kline_ctrl2,data) {
    var currentSelect:Int = -1
    var currentView: View? = null
    var showTvLine:Boolean = true
    override fun convert(helper: BaseViewHolder, item: CpKlineCtrlBean) {
            val sel=item.isSelect
            helper.setText(R.id.tv_time, CpKLineUtil.getShowKLineScaleName(item.time,context))

            helper.setGone(R.id.tv_line,if(currentSelect!=-1 && !showTvLine) true else !sel)

            helper.setTextColor(R.id.tv_time,if (sel){
                this.currentSelect = getItemPosition(item)
                this.currentView = helper.itemView
                ContextCompat.getColor(context,R.color.text_color_1)
            } else {
                ContextCompat.getColor(context,R.color.text_color_2)
            })
    }

    fun notifyData(isShowTvLine:Boolean?){
        if(isShowTvLine!=null) showTvLine = isShowTvLine
        notifyDataSetChanged()
    }
}
