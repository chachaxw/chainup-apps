package com.yjkj.chainup.new_contract.adapter

import android.content.res.ColorStateList
import android.os.Build
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import androidx.core.content.ContextCompat
import com.chad.library.adapter.base.BaseMultiItemQuickAdapter
import com.chad.library.adapter.base.module.LoadMoreModule
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.chainup.contract.R
import com.chainup.contract.utils.CpKLineUtil
import com.chainup.contract.view.CpLabelTextView
import com.yjkj.chainup.new_contract.bean.CpKlineCtrlBean
import java.util.*


class CpContractKlineCtrlAdapter(data: ArrayList<CpKlineCtrlBean>) : BaseMultiItemQuickAdapter<CpKlineCtrlBean, BaseViewHolder>(data), LoadMoreModule {
    var selectView: View? = null
    init {
        addItemType(1, R.layout.cp_item_kline_ctrl)
        addItemType(2, R.layout.cp_item_kline_ctrl_label)
        addItemType(3, R.layout.cp_item_kline_ctrl)
    }

    override fun convert(helper: BaseViewHolder, item: CpKlineCtrlBean) {

        when (helper.itemViewType) {
            1 -> {
                val sel=item.isSelect
                if(sel){
                    selectView = helper.getView(R.id.tv_time)
                }

//                val sel=CpKLineUtil.getCurTime4Index().equals(CpKLineUtil.getKLineScale().indexOf(item.time))
                helper.setText(R.id.tv_time, CpKLineUtil.getShowKLineScaleName(item.time,context))
                helper.setTextColor(R.id.tv_time,if (sel) ContextCompat.getColor(context,R.color.text_color_1) else  ContextCompat.getColor(context,R.color.text_color_2))
//                helper.setGone(R.id.tv_line,!sel)
            }
            2 -> {
                helper.setText(R.id.tv_scale, CpKLineUtil.getShowKLineScaleName(item.time,context))
                val tvScale= helper.getView<TextView>(R.id.tv_scale)
                if(item.isSelect){
                    selectView = tvScale
                }
//                tvScale.labelBackgroundColor=if (item.isSelect) ContextCompat.getColor(context,R.color.text_color_1) else  ContextCompat.getColor(context,R.color.text_color_2)
                helper.setTextColor(R.id.tv_scale,if (item.isSelect) ContextCompat.getColor(context,R.color.text_color_1) else  ContextCompat.getColor(context,R.color.text_color_2))
                val igView = helper.getView<ImageView>(R.id.ic_arrow)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    igView?.imageTintList = ColorStateList.valueOf(if (item.isSelect) ContextCompat.getColor(context,R.color.text_color_1) else  ContextCompat.getColor(context,R.color.text_color_2))
                }
//                if (CpKLineUtil.getCurTime4Index().equals(CpKLineUtil.getKLineScale().indexOf(item.time))) {
//                    helper.setGone(R.id.tv_line,false)
//                } else if (CpKLineUtil.getCurTime4Index().equals(CpKLineUtil.getKLineScale().indexOf(item.time))) {
//                    helper.setGone(R.id.tv_line,false)
//                } else if (CpKLineUtil.getCurTime4Index().equals(CpKLineUtil.getKLineScale().indexOf(item.time))) {
//                    helper.setGone(R.id.tv_line,false)
//                } else if (CpKLineUtil.getCurTime4Index().equals(CpKLineUtil.getKLineScale().indexOf(item.time))) {
//                    helper.setGone(R.id.tv_line,false)
//                } else if (CpKLineUtil.getCurTime4Index().equals(CpKLineUtil.getKLineScale().indexOf(item.time))) {
//                    helper.setGone(R.id.tv_line,false)
//                } else {
//                    helper.setGone(R.id.tv_line,true)
//                }
            }
            3 -> {
                val sel=item.isSelect
                helper.setText(R.id.tv_time, CpKLineUtil.getShowKLineScaleName(item.time,context))
                helper.setTextColor(R.id.tv_time,if (sel) ContextCompat.getColor(context,R.color.text_color_1) else  ContextCompat.getColor(context,R.color.text_color_2))
//                helper.setGone(R.id.tv_line,!sel)
            }
            4 -> {
            }
        }

    }

}
