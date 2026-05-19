package com.yjkj.chainup.freestaking.adapter

import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.fengniao.news.util.DateUtil
import com.yjkj.chainup.R
import com.yjkj.chainup.freestaking.bean.UserGainListBean
import com.yjkj.chainup.freestaking.formatAmount
import com.yjkj.chainup.manager.NCoinManager

/**
 *Adapter for revenue details
 */
class IncomeRecyclerAdapter(data:ArrayList<UserGainListBean>?):BaseQuickAdapter<UserGainListBean,BaseViewHolder>(R.layout.item_income_layout,data) {
    override fun convert(helper: BaseViewHolder, item: UserGainListBean) {
        item.gainTimeMillis?.let {
            helper.setText(R.id.tv_income_time, DateUtil.longToString(DateUtil.ymdFormat,it.toLong()))
        }
        helper?.setText(R.id.tv_income_number, item?.gainAmount?.formatAmount(NCoinManager.getCoinShowPrecision(item?.gainCoin.toString()))?.toPlainString())
    }

}
