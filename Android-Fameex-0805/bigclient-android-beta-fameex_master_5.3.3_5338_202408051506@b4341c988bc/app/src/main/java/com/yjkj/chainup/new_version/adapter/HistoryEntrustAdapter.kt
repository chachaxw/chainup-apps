package com.yjkj.chainup.new_version.adapter

import android.widget.TextView
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.fengniao.news.util.DateUtil
import com.yjkj.chainup.R
import com.yjkj.chainup.bean.trade.Order
import com.yjkj.chainup.manager.DataManager
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.util.ColorUtil
import com.yjkj.chainup.util.BigDecimalUtils
import org.jetbrains.anko.textColor
import java.util.ArrayList

/**
 * @Author: Bertking
 * @Date 2023/4/8-8:33 PM
 * @Description:
 */
class HistoryEntrustAdapter(data: ArrayList<Order>) : BaseQuickAdapter<Order, BaseViewHolder>(R.layout.item_history_entrust, data) {

    val TAG = HistoryEntrustAdapter::class.java.simpleName

    override fun convert(helper: BaseViewHolder, order: Order) {

        val side = order.side
        if (side.equals("BUY", ignoreCase = true)) {
            helper.setText(R.id.tv_side,  LanguageUtil.getString(context, "otc_text_tradeObjectBuy"))
            helper.getView<TextView>(R.id.tv_side).textColor = ColorUtil.getMainColorType()
        } else {
            helper.setText(R.id.tv_side,  LanguageUtil.getString(context, "otc_text_tradeObjectSell"))
            helper.getView<TextView>(R.id.tv_side).textColor = ColorUtil.getMainColorType(isRise = false)
        }

        /**
         *Currency pair
         */
        var pair = NCoinManager.getShowName(order.baseCoin ?: "", order.countCoin ?: "")

        helper?.setText(R.id.tv_coin_name, pair.first)
        helper?.setText(R.id.tv_market_name, "/" + pair.second)


        /**
         *Date yyyy MM dd HH: mm: ss
         */
        helper.setText(R.id.tv_date, DateUtil.longToString("yyyy/MM/dd HH:mm", order.timeLong))


        /**
         *NIT (0, "Initial order, not closed but not entered into trading"),
         *NEW_ (1, "New orders, no transactions entered trading"),
         *FILLED (2, "Complete transaction"),
         *PART_ Filled (3, "Partial transaction"),
         *CANCELED (4, "Cancelled"),
         *PENDING_ CANCEL (5, "Pending Cancellation"),
         *EXPIRED (6, "Abnormal Orders");
         */


        val status = order.status
        helper.setText(R.id.tv_status, order.statusText)
        when (status) {
            0, 1, 3 -> {
            }

            2 -> {
                /**
                 *Full transaction entry details
                 */
//                helper.getView<TextView>(R.id.tv_status).setOnClickListener { v -> OrderDetailsActivity.enter2(mContext, order) }
                helper.setText(R.id.tv_status,  LanguageUtil.getString(context, "contract_text_orderComplete"))
//                helper.getView<TextView>(R.id.tv_status).setCompoundDrawablesRelativeWithIntrinsicBounds(0, 0, R.drawable.ic_white_arrow, 0)
            }

            4 -> helper.setText(R.id.tv_status,  LanguageUtil.getString(context, "contract_text_orderCancel"))
            else -> {
            }
        }


        /**
         *Number of Commissions
         */
        helper.setText(R.id.tv_volume, BigDecimalUtils.showSNormal(order.volume))
        helper.setText(R.id.tv_volume_title,  LanguageUtil.getString(context, "charge_text_volume") + "(" + pair.first + ")")

        /**
         *Commission price
         *1 Limit Order 2 Market Order
         *
         *There is no commission price on the market price list
         */
        if (order.type == 2) {
            helper.setText(R.id.tv_price,  LanguageUtil.getString(context, "contract_text_typeMarket"))
        } else {
            helper.setText(R.id.tv_price, BigDecimalUtils.showSNormal(order.price))
        }
        helper.setText(R.id.tv_price_title,  LanguageUtil.getString(context, "contract_text_trustPrice") + "(" + pair.second + ")")

        /**
         *Not closed
         */
        helper.setText(R.id.tv_unsettled, BigDecimalUtils.showSNormal(order.remainVolume))
        helper.setText(R.id.tv_unsettled_title,  LanguageUtil.getString(context, "transaction_text_orderUnsettled") + "(" + pair.first + ")")

        /**
         *Actual transaction
         */
        helper.setText(R.id.tv_deal_volume, BigDecimalUtils.showSNormal(order.dealVolume))
        helper.setText(R.id.tv_deal_volume_title,  LanguageUtil.getString(context, "transaction_text_tradeValue") + "(" + pair.first + ")")

        /**
         *Average transaction price
         */
        helper.setText(R.id.tv_avg_price, BigDecimalUtils.showSNormal(order.avgPrice))
        helper.setText(R.id.tv_avg_price_title,  LanguageUtil.getString(context, "contract_text_dealAverage") + "(" + pair.second + ")")
    }
}
