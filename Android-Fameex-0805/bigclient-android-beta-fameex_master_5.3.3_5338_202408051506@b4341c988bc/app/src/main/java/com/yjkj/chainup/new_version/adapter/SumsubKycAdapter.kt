package com.yjkj.chainup.new_version.adapter

import android.view.View
import android.view.ViewGroup.MarginLayoutParams
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.chainup.kit.utils.PublicSizeUtil
import com.chainup.kit.views.KKButtonKit
import com.yjkj.chainup.R
import com.yjkj.chainup.bean.KycAuthBean
import com.yjkj.chainup.db.constant.KycRequirements
import com.yjkj.chainup.util.BigDecimalUtils
import com.yjkj.chainup.util.tr
import java.lang.StringBuilder

class SumsubKycAdapter(val list: ArrayList<KycAuthBean>) : BaseQuickAdapter<KycAuthBean,BaseViewHolder>(R.layout.sumsub_kyc_item_layout,list) {
    init {
        addChildClickViewIds(R.id.btn_auth)
    }
    override fun convert(holder: BaseViewHolder, item: KycAuthBean) {
        if(holder.adapterPosition==0){
            val marginLayoutParams = holder.itemView.layoutParams as MarginLayoutParams
            marginLayoutParams.topMargin = PublicSizeUtil.dp2px(context,16.0f)
            holder.itemView.layoutParams = marginLayoutParams
        }


        holder.setText(R.id.tv_level_name,item.showName)
        holder.setGone(R.id.tv_current_flag,item.current==0)
        holder.setText(R.id.tv_current_flag,"kyc_page_current".tr(context))
        holder.setText(R.id.tv_equity,"kyc_page_benefits".tr(context))
        holder.setText(R.id.tv_equity1_label,"kyc_page_benefits_withdrawal".tr(context))
        holder.setText(R.id.tv_equity2_label,"kyc_page_benefits_deposit".tr(context))
        holder.setText(R.id.tv_equity3_label,"kyc_page_benefits_P2P".tr(context))
        holder.setText(R.id.tv_demand,"kyc_page_require".tr(context))
        holder.setText(R.id.tv_equity1_value,if(item.withdrawAmount!=null && !"".equals(item.withdrawAmount) && BigDecimalUtils.compareTo(item.withdrawAmount,"0")==1) BigDecimalUtils.showSNormal(item.withdrawAmount.toString())+"kyc_page_benefits_amount".tr(context) else "kyc_page_benefits_state_limit".tr(context))
        holder.setText(R.id.tv_equity2_value,if(item.depositStatus==0) "kyc_page_benefits_state_limit".tr(context) else "kyc_page_benefits_state_nolimit".tr(context))
        holder.setText(R.id.tv_equity3_value,if(item.c2cStatus==0) "kyc_page_benefits_state_limit".tr(context) else "kyc_page_benefits_state_nolimit".tr(context))
        val btn = holder.getView<KKButtonKit>(R.id.btn_auth)
        changeBtnStatus(btn,item)

        val requirements = item.requirementsReference.split(",")
        val sb = StringBuilder()
        for(stringItem in requirements.withIndex()){
            val name = stringItem.value
            val isLast = stringItem.index == requirements.lastIndex
            val kycRequirements = KycRequirements.valueOf(name)
            val realContent = kycRequirements.getText(context)
            sb.append(realContent)
            if(!isLast) sb.append("\n")
        }
        holder.setText(R.id.tv_demand_content,sb.toString())
    }

    private fun changeBtnStatus(btn:KKButtonKit,item:KycAuthBean) {
        if(item.authConfigId==0) {
            btn.visibility = View.GONE
            return
        }
        btn.visibility = View.VISIBLE
        btn.isEnable(item.status==0 && item.current!=1)
        if(!"".equals(item.preLevelName) && item.preLevelName!=null) {
            btn.textContent = String.format("kyc_page_button_more".tr(context),item.preLevelName)
            btn.isEnable(false)
            return
        }
        when(item.status){
            0 -> {
                btn.textContent = "kyc_page_button_verify".tr(context)
            }
            1 -> {
                btn.textContent = "kyc_page_button_verified".tr(context)
            }
            2 -> {
                btn.textContent = "kyc_page_button_verifying".tr(context)
            }
        }
    }
}