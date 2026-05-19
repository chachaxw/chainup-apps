package com.yjkj.chainup.new_version.adapter

import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.fengniao.news.util.DateUtil
import com.yjkj.chainup.R
import com.yjkj.chainup.freestaking.bean.MyPosRecordBean
import com.yjkj.chainup.util.tr

class PositionPosRecordRecyclerAdapter(data: ArrayList<MyPosRecordBean.PosListBean>)
    :BaseQuickAdapter<MyPosRecordBean.PosListBean, BaseViewHolder>(R.layout.item_positionpos_record,data) {
    override fun convert(helper: BaseViewHolder, item: MyPosRecordBean.PosListBean) {
        helper?.setText(R.id.tv_name, item?.baseCoin)
        item.revenueTimeMillis?.let {
            helper.setText(R.id.tv_income_time, DateUtil.longToString(DateUtil.ymdFormat,it.toLong()))
        }
        helper?.setText(R.id.tv_number, item?.baseAmount?.toPlainString())
        helper?.setText(R.id.tv_income, item?.gainRate+"%")
        helper?.setText(R.id.tv_current_income, item?.gainAmount?.toPlainString())

        helper.setText(R.id.tv_startTime,"pos_string_timeEarn".tr(context))
        helper.setText(R.id.tv_principal,"pos_string_principal".tr(context))
        helper.setText(R.id.tv_annualized_income,"pos_string_interestRate".tr(context))
        helper.setText(R.id.tv_qy,"pos_string_earnNumber".tr(context)+"(${item?.gainCoin})")
    }
}
