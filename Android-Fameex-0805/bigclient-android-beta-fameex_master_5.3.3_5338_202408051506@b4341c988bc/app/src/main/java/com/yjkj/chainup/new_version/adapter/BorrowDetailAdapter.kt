package com.yjkj.chainup.new_version.adapter

import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.fengniao.news.util.DateUtil
import com.yjkj.chainup.R
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.util.BigDecimalUtils
import com.yjkj.chainup.util.tr
import org.json.JSONObject
import java.util.ArrayList

/**
 * @Author: Bertking
 * @Date 2023-11-13-17:27
 *@description: Loan Record Details
 */
class BorrowDetailAdapter(data: ArrayList<JSONObject>) : NBaseAdapter(data, R.layout.item_borrow_detail) {
    override fun convert(helper: BaseViewHolder, item: JSONObject) {
        item?.run {
            val coin = optString("coin", "")
            val type = optString("type", "")
            val returnMoney = optString("returnMoney", "0")
            val repaymentTime = optString("repaymentTime", "0")
            var precision = NCoinManager.getCoinShowPrecision(coin)



            helper?.run {

                setText(R.id.tv_volume_title,"charge_text_volume".tr(context))
                setText(R.id.tv_rate_title,"contract_text_type".tr(context))
                setText(R.id.tv_coin_name, NCoinManager.getShowMarket(coin))
                /**
                 *Date yyyy MM dd HH: mm: ss
                 */
                setText(R.id.tv_date, DateUtil.longToString("yyyy/MM/dd HH:mm:ss", repaymentTime.toLong()))

                setText(R.id.tv_volume, BigDecimalUtils.showNormal(BigDecimalUtils.divForDown(returnMoney, 8).toPlainString()))

                /**
                 *Return type: 1 principal, 2 interest, 3 principal+interest
                 */
                val typeText = when (type) {
                    "1" -> {
                         LanguageUtil.getString(context, "leverage_principal")
                    }

                    "2" -> {
                         LanguageUtil.getString(context,"leverage_interest")
                    }

                    else -> {
                        "${ LanguageUtil.getString(context, "leverage_principal")}+${ LanguageUtil.getString(context, "leverage_interest")}"
                    }
                }
                setText(R.id.tv_rate, typeText)

            }

        }
    }
}
