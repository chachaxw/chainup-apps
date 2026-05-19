package com.yjkj.chainup.new_version.adapter

import android.R.attr.height
import android.R.attr.width
import android.app.Activity
import android.widget.LinearLayout
import android.widget.RelativeLayout
import com.blankj.utilcode.util.SizeUtils
import com.bumptech.glide.request.RequestOptions
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.chainup.kit.views.KKButtonKit
import com.yjkj.chainup.R
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.LoginManager
import com.yjkj.chainup.new_version.bean.ItemTaskBean
import com.yjkj.chainup.util.GlideUtils
import com.yjkj.chainup.util.TimeUtil


class RewardListAdapter : BaseQuickAdapter<ItemTaskBean,BaseViewHolder>(R.layout.item_taskcenter_layout){

    init {
        addChildClickViewIds(R.id.btn_action1)
    }
    override fun convert(holder: BaseViewHolder, item: ItemTaskBean) {
        val options = RequestOptions().placeholder(R.mipmap.task_img_currency).error(R.mipmap.task_img_currency)
        val themeMode = PublicInfoDataService.getInstance().getThemeModeNew()
        if("night".equals(themeMode)&&!item.nightLogo.isEmpty()){
            GlideUtils.load(context as Activity, item.nightLogo,holder.getView(R.id.iv_logo),options)
        }
        if(!"night".equals(themeMode)&&!item.logo.isEmpty()){
            GlideUtils.load(context as Activity, item.logo,holder.getView(R.id.iv_logo),options)
        }

        holder.setText(R.id.stv_reward_amount,item.rewardAmount+item.rewardCoin)
        holder.setText(R.id.stv_reward_type,if(item.rewardType==0){
            LanguageUtil.getString(context,"rewardCenter_text26")
        }else{""})
        holder.setText(R.id.tv_title,item.taskName)
        holder.setText(R.id.tv_tip,item.taskInfo)
        if(item.taskInfo!=null){
            println("item.taskInfo--${item.taskInfo}--")
            holder.setGone(R.id.tv_tip,(item.taskInfo.length==0))
        }else{
            holder.setGone(R.id.tv_tip,true)
        }
        holder.setGone(R.id.ll_time,item.taskType!=1)
       var ll_btn= holder.getView<LinearLayout>(R.id.ll_btn)
        val llBtn = ll_btn.layoutParams as LinearLayout.LayoutParams
        llBtn.topMargin=if(item.taskType!=1)  SizeUtils.dp2px(24f) else SizeUtils.dp2px(12f)
//        llBtn.topMargin=SizeUtils.dp2px(12f)
        // In progress 0 Not claimed, 1 Mission expired, 2 claimed, 4 In progress (unclaimed and not expired), 5 Reward expired
        if (item.status.toString() == "0" || item.status.toString() == "5") {
            // deadline for collection
            holder.setText(R.id.tv_timeLabel,LanguageUtil.getString(context,"rewardCenter_text28"))
        }
        if (item.status.toString() == "1" || item.status.toString() == "4") {
            // expiration time
            holder.setText(R.id.tv_timeLabel,LanguageUtil.getString(context,"rewardCenter_text27"))
        }
        if (item.status.toString() == "2") {
            // pick up time
            holder.setText(R.id.tv_timeLabel,LanguageUtil.getString(context,"rewardCenter_text29"))
        }

        if(LoginManager.isLogin(context)){
            holder.setText(R.id.tv_time_value,TimeUtil.instance.convertTimestampToTimezone(item.remindTime))
        }else{
            holder.setText(R.id.tv_time_value,"--")
        }

        holder.getView<KKButtonKit>(R.id.btn_action1).run {
            when(item.status){
                0 -> {//Get Reward
                    isEnable(true)
                    textContent = LanguageUtil.getString(context,"rewardCenter_text32")
                }
                1 -> {//Expired
                    isEnable(false)
                    textContent = LanguageUtil.getString(context,"rewardCenter_text35")
                }
                2 -> {//Rewarded
                    isEnable(false)
                    textContent = LanguageUtil.getString(context,"rewardCenter_text33")
                }
                4 -> {//Go
                    isEnable(true)
                    textContent = LanguageUtil.getString(context,"rewardCenter_text31")
                }
                5 -> {//Reward Expired
                    isEnable(false)
                    textContent = LanguageUtil.getString(context,"rewardCenter_text36")
                }
            }


        }

    }

}