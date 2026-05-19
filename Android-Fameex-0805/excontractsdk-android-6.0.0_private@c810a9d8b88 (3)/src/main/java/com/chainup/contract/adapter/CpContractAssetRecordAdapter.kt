package com.yjkj.chainup.new_contract.adapter

import android.content.Context
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.module.LoadMoreModule
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.chainup.contract.R
import com.chainup.contract.utils.CpBigDecimalUtils
import com.chainup.contract.utils.CpTimeFormatUtils

import org.json.JSONObject

/**
 * Contract asset records
 */
class CpContractAssetRecordAdapter(ctx: Context, data: ArrayList<JSONObject>) : BaseQuickAdapter<JSONObject, BaseViewHolder>(
    R.layout.cp_item_asset_record, data), LoadMoreModule {

    override fun convert(helper: BaseViewHolder, item: JSONObject) {
        helper?.run {
            //Amount
            setText(R.id.tv_amount_value, CpBigDecimalUtils.showSNormal(item.optString("amount"), item.optInt("mMarginCoinPrecision")))
            //Time
            val timeMillis = item.optLong("cTimestamp")
            setText(R.id.tv_time_value, CpTimeFormatUtils.timeStampToDate(timeMillis))
            //Flow Type 1 Transfer-in, 2 Transfer-out, 5 Fund Expense, 8 Allocation
            setText(R.id.tv_type_value, item.optString("type"))
            //Symbol name
            setText(R.id.tv_symbol_name, item.optString("contractName"))
        }
    }
}
