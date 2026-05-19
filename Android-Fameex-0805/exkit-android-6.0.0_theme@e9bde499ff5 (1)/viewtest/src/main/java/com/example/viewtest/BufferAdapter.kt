package com.example.viewtest

import androidx.core.content.ContextCompat
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.coorchice.library.SuperTextView

class BufferAdapter(layoutResId: Int, data: MutableList<String>) :
    BaseQuickAdapter<String, BaseViewHolder>(layoutResId, data) {
    override fun convert(helper: BaseViewHolder, item: String) {
        helper.getView<SuperTextView>(R.id.tv_rose).solid = ContextCompat.getColor(context, R.color.main_green)
    }
}
