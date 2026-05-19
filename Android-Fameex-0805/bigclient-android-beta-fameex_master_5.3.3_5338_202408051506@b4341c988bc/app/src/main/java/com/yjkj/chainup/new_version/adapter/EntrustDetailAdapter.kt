package com.yjkj.chainup.new_version.adapter

import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.yjkj.chainup.R
import com.yjkj.chainup.util.BigDecimalUtils
import org.json.JSONObject
import java.math.BigDecimal
import java.util.ArrayList

/**
 * @Author: Bertking
 * @Date 2023-10-21-14:42
 *@description: The flow of commission details
 */
class EntrustDetailAdapter(data: ArrayList<JSONObject>) : NBaseAdapter(data, R.layout.item_entrust_detail) {
    override fun convert(helper: BaseViewHolder, item: JSONObject) {
        item?.run {
            val volume = optString("volume")
            val fee = optString("fee")
            val feeCoin = optString("feeCoin")
            val price = optString("price")

            helper?.run {
                setText(R.id.tv_prices, BigDecimal(price).toPlainString())
                setText(R.id.tv_volumes, BigDecimal(volume).toPlainString())
                setText(R.id.tv_fee, BigDecimal(fee).toPlainString() + feeCoin.toUpperCase())
            }
        }
    }
}
