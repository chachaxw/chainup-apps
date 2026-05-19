package com.yjkj.chainup.new_version.adapter

import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.yjkj.chainup.R
import com.yjkj.chainup.util.setGoneV3
import org.json.JSONObject

/**
 * @Author lianshangljl
 *@ Date 2018/10/17-5:08 PM
 * @Email buptjinlong@163.com
 *@description Select payment type
 */
open class OTCChangePayCoinAdapter(data: ArrayList<JSONObject>) :
        BaseQuickAdapter<JSONObject, BaseViewHolder>(R.layout.item_change_payment, data) {

    override fun convert(helper: BaseViewHolder, item: JSONObject) {
        helper?.setText(R.id.item_change_payment_name, item?.optString("title"))
        helper.setGoneV3(R.id.item_change_payment_status, item?.optBoolean("open") ?: false)
    }

}
