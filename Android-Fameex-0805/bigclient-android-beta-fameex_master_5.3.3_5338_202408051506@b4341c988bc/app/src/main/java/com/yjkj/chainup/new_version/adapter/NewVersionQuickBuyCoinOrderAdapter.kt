package com.yjkj.chainup.new_version.adapter

import android.widget.TextView
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.fengniao.news.util.DateUtil
import com.yjkj.chainup.R
import com.yjkj.chainup.bean.OTCOrderBean
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.manager.RateManager
import com.yjkj.chainup.util.BigDecimalUtils
import com.yjkj.chainup.util.ColorUtil
import com.yjkj.chainup.util.StringUtil

/**
 * @Author lianshangljl
 * @Date 2023/4/26-6:39 PM
 * @Email buptjinlong@163.com
 * @description
 */
class NewVersionQuickBuyCoinOrderAdapter(data: ArrayList<OTCOrderBean.Order>) :
        BaseQuickAdapter<OTCOrderBean.Order, BaseViewHolder>(R.layout.item_new_quick_otc_order, data) {


    override fun convert(helper: BaseViewHolder, item: OTCOrderBean.Order) {
        /**
         *Buy or sell
         */
//        if (item?.side == "BUY") {
//            helper?.setText(R.id.tv_title_pay_type,  LanguageUtil.getString(context, "otc_text_tradeObjectBuy"))
//        } else {
//            helper?.setText(R.id.tv_title_pay_type,  LanguageUtil.getString(context, "otc_text_tradeObjectSell"))
//        }

        helper?.setText(R.id.tv_title_pay_type, item?.type)
        helper?.getView<TextView>(R.id.tv_title_pay_type)?.setTextColor(ColorUtil.getMainColorType(isRise = item.originType==1))

        /**
         *Purchase Currency
         */
        helper?.setText(R.id.tv_payment_coin, NCoinManager.getShowMarket(item?.coinSymbol))
        /**
         *Status
         */
        helper?.setText(R.id.tv_status, item?.statusText)
        /**
         *Creation time
         */
        helper?.setText(R.id.tv_pay_time, DateUtil.longToString("MM/dd HH:mm", item?.ctime
                ?: 0L))
        /**
         *Unit price title and content
         */
        helper?.setText(R.id.tv_price_title,  LanguageUtil.getString(context, "quick_buy_coin_text2") + "(${item?.payCoin})")

        var paySymbol = item?.paySymbol
        var price = item?.price
        if(StringUtil.checkStr(paySymbol)){
            if(StringUtil.checkStr(price) && price!!.contains(paySymbol!!)){
                price = price.replace(paySymbol,"")
            }
        }

        /**
         *Quantity
         */
        helper?.setText(R.id.tv_otc_amount_title, LanguageUtil.getString(context, "quick_buy_coin_text3")+ "(${item?.coinSymbol})")

        /**
         *Total amount
         */
        helper?.setText(R.id.tv_total_title,  LanguageUtil.getString(context, "quick_buy_coin_text4") + "(${item?.payCoin})")

        //helper?.setText(R.id.tv_total_content, BigDecimalUtils.divForDown(item?.totalPrice, RateManager.getRatesByPayCoin(item?.paySymbol).toInt()).toPlainString())

//        helper?.setVisible(R.id.iv_enter,false)

        helper.setText(R.id.tv_realName,item?.realName)
        helper.setText(R.id.tv_order_id,item?.sequence)

        helper.setText(R.id.tv_order_id_title,LanguageUtil.getString(context, "quick_buy_coin_text5"))
        helper.setText(R.id.tv_realName_title,LanguageUtil.getString(context, "quick_buy_coin_text6"))
        helper.setText(R.id.tv_price,item.price)
        helper.setText(R.id.tv_total_content,item.totalPrice)
        helper.setText(R.id.tv_otc_amount,item.volume)
    }


}
