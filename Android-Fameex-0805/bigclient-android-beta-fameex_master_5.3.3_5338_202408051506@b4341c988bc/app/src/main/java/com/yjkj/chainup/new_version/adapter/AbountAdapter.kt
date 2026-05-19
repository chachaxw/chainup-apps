package com.yjkj.chainup.new_version.adapter

import android.widget.TextView
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.chainup.kit.utils.PublicSizeUtil
import com.yjkj.chainup.R
import com.yjkj.chainup.bean.AboutUSBean
import java.util.ArrayList


/**
 * Created by Bertking on 2018/9/14.
 */

class AbountAdapter : BaseQuickAdapter<AboutUSBean, BaseViewHolder>(R.layout.item_about_us) {
    override fun convert(helper: BaseViewHolder, item: AboutUSBean) {
        helper.setText(R.id.tv_title, item?.title ?: "")

        if(helper.adapterPosition==0){
            helper.setText(R.id.tv_content, item?.content ?: "")
            helper.setGone(R.id.iv_copy,true)
        }else{
            var oldContentStr = item.content
            oldContentStr = if(oldContentStr.length<30){
                oldContentStr
            }else if(oldContentStr.length>30 && oldContentStr.length<60){
                val firstStr = oldContentStr.substring(0,30)
                val secendStr = oldContentStr.substring(30,oldContentStr.length)
                firstStr+"\n"+secendStr
            }else{
                val firstStr = oldContentStr.substring(0,30)
                val secendStr = oldContentStr.substring(30,60)
                firstStr+"\n"+secendStr+"..."
            }
            helper.setGone(R.id.iv_copy,false)
            helper.setText(R.id.tv_content, oldContentStr)

        }


    }
}
