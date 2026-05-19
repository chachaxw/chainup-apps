package com.yjkj.chainup.new_version.adapter

import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.fengniao.news.util.DateUtil
import com.yjkj.chainup.R
import com.yjkj.chainup.freestaking.bean.MyPosRecordBean
import com.yjkj.chainup.freestaking.formatAmount
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.util.tr

class ProtocolPosRecordRecyclerAdapter(data: ArrayList<MyPosRecordBean.PosListBean>)
    :BaseQuickAdapter<MyPosRecordBean.PosListBean, BaseViewHolder>(R.layout.item_protocolpos_record,data) {
    override fun convert(helper: BaseViewHolder, item: MyPosRecordBean.PosListBean) {
        helper?.setText(R.id.tv_name, item?.baseCoin)
        when(item?.projectStatus){
            "0"->{
                helper?.setText(R.id.tv_status, "pos_state_start".tr(context))

            }
            "1"->{
                helper?.setText(R.id.tv_status,"pos_state_buying".tr(context))

            }
            "2"->{
                helper?.setText(R.id.tv_status, "pos_state_waitInterest".tr(context))
            }
            "3"->{
                helper?.setText(R.id.tv_status, "pos_state_InterestIng".tr(context))
            }
            "4"->{
                helper?.setText(R.id.tv_status, "pos_state_InterestEnd".tr(context))
            }
            "5"->{
                helper?.setText(R.id.tv_status, "pos_state_release".tr(context))

            }
            "6"->{
                helper?.setText(R.id.tv_status, "pos_state_fulled".tr(context))

            }
        }
        item.ltimeMillis?.let {
            helper.setText(R.id.tv_stime, DateUtil.longToString(DateUtil.ymdFormat,it.toLong()))
        }
        helper?.setText(R.id.tv_number, item?.totalAmount?.formatAmount(NCoinManager.getCoinShowPrecision(item?.baseCoin.toString()))?.toPlainString())
        helper?.setText(R.id.tv_income, item?.gainRate+"%")
        helper?.setText(R.id.tv_current_income, item?.totalUserGainAmount?.toPlainString())
//        helper?.addOnClickListener(R.id.tv_current_income)

        helper.setText(R.id.tv_startTime,"pos_string_lockBeginTime".tr(context))
        helper.setText(R.id.tv_lockNumber,"pos_string_lockNumber".tr(context))
        helper.setText(R.id.tv_annualized_income,"pos_string_interestRate".tr(context))
        helper.setText(R.id.tv_qy,"pos_string_earnNumber".tr(context)+"(${item?.baseCoin})")
    }
}
