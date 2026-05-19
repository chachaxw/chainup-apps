package com.yjkj.chainup.new_version.adapter


import android.content.Context
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.module.LoadMoreModule
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.yjkj.chainup.R
import com.yjkj.chainup.util.BigDecimalUtils
import org.json.JSONObject

/**
 *Contract asset records
 */
class ClContractAssetRecordAdapter(ctx: Context, data: ArrayList<JSONObject>) : BaseQuickAdapter<JSONObject, BaseViewHolder>(R.layout.cl_item_asset_record, data), LoadMoreModule {

    override fun convert(helper: BaseViewHolder, item: JSONObject) {
        helper?.run {
            //Amount
            setText(R.id.tv_amount_value, BigDecimalUtils.showSNormal(item.optString("amount"), item.optInt("mMarginCoinPrecision")))
            //Time
            setText(R.id.tv_time_value, item.optString("ctime"))
            //Flow type 1 transfer in, 2 transfer out, 5 fund expenses, 8 allocation
            setText(R.id.tv_type_value, item.optString("type"))
            //Symbol name
            setText(R.id.tv_symbol_name, item.optString("contractName"))
//            setText(R.id.tv_type_value, when (item.optString("type")) {
//                "1" -> "转入"
//                "2" -> "转出"
//                "5" -> "资金费用"
//                "8" -> "分摊"
//                else -> "error"
//            })
        }
    }
}