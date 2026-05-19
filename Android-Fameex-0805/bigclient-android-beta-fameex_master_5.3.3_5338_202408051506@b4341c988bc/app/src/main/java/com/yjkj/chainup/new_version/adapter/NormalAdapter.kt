package com.yjkj.chainup.new_version.adapter

import android.widget.RelativeLayout
import androidx.core.content.ContextCompat
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.yjkj.chainup.R
import com.yjkj.chainup.util.setGoneV3
import org.json.JSONObject
import java.util.ArrayList

/**
 * @Author lianshangljl
 * @Date 2023-12-23-15:42
 * @Email buptjinlong@163.com
 * @description
 */
class NormalAdapter(data: ArrayList<JSONObject>?, var position: Int = 0) :
        BaseQuickAdapter<JSONObject, BaseViewHolder>(R.layout.item_new_screening_label, data) {

    fun setSelectPosition(index: Int) {
        position = index
        notifyDataSetChanged()
    }

    override fun convert(helper: BaseViewHolder, item: JSONObject) {
        if (position == helper.adapterPosition) {
            helper.getView<RelativeLayout>(R.id.ll_layout).setBackgroundResource(R.drawable.bg_new_select_style)
            helper.setTextColor(R.id.tv_parent_content, ContextCompat.getColor(context,R.color.text_color_1))
        } else {
            helper.getView<RelativeLayout>(R.id.ll_layout).setBackgroundResource(R.drawable.bg_new_unselect_style)
            helper.setTextColor(R.id.tv_parent_content, ContextCompat.getColor(context,R.color.text_color_2))
        }
        helper.setText(R.id.tv_parent_content, item.optString("mainChainName", ""))

    }

}

