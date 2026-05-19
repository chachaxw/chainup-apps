package com.yjkj.chainup.new_version.view

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.widget.RelativeLayout
import com.yjkj.chainup.R
import com.yjkj.chainup.manager.LanguageUtil
import kotlinx.android.synthetic.main.rv_reward_head_layout.view.stv_tip

class RewardHeadView @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null
) : RelativeLayout(context, attrs) {

    init {
        LayoutInflater.from(context).inflate(R.layout.rv_reward_head_layout,this,true)
    }

    fun updateView(rewardReceiveTerm:Int,timeZone:String,taskType:Int,rewardReceiveType:Int){
        when(taskType){
            //everyDay task
            0 -> {
                stv_tip.visibility = View.VISIBLE
                if(rewardReceiveType==0){
                    //system auto
                    stv_tip.text = LanguageUtil.getString(context,"rewardCenter_text24")
                }else{
                    //manual
                    stv_tip.text = String.format(LanguageUtil.getString(context,"rewardCenter_text25"),timeZone)
                }
            }
            //novice task
            1 -> {
                stv_tip.visibility = View.VISIBLE
                if(rewardReceiveType==0){
                    //system auto
                    stv_tip.text = LanguageUtil.getString(context,"rewardCenter_text22")
                }else{
                    //manual
                    stv_tip.text = String.format(LanguageUtil.getString(context,"rewardCenter_text23"),rewardReceiveTerm)
                }
            }
            -1 -> {
                stv_tip.visibility = View.GONE
            }
        }
    }
}