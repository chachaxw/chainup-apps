package com.chainup.contract.adapter

import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.chainup.contract.R

class ContractSettingRvAdapter(data:ArrayList<Map<String,Any>>) : BaseQuickAdapter<Map<String,Any>, BaseViewHolder>(R.layout.item_rv_contract_setting,data) {

    override fun convert(holder: BaseViewHolder, item:Map<String,Any>) {

        holder.setText(R.id.stItemText,item.get("name").toString())
        holder.setImageResource(R.id.stItemIcon, item.get("icon") as Int)
    }
}
