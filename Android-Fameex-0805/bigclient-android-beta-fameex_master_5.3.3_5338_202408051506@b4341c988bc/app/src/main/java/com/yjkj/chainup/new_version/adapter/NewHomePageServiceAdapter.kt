package com.yjkj.chainup.new_version.adapter

import android.content.Context
import android.widget.ImageView
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.yjkj.chainup.R
import com.yjkj.chainup.app.ChainUpApp
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.util.GlideUtils
import org.jetbrains.anko.imageResource
import org.json.JSONObject

/**
 * @Author lianshangljl
 * @Date 2023/11/16-4:03 PM
 * @Email buptjinlong@163.com
 *@description Home Page Function Service
 */
open class NewHomePageServiceAdapter(val mContext: Context, data: ArrayList<JSONObject>) : BaseQuickAdapter<JSONObject, BaseViewHolder>(R.layout.item_new_homepage_service_dapter, data) {


    override fun convert(helper: BaseViewHolder, item: JSONObject) {
        /**
         *Load Picture
         */
        val imageUrl = item?.optString("imageUrl")
        val icLogo = helper?.getView<ImageView>(R.id.iv_service_4_network)
        if(imageUrl.isNotEmpty()){
            GlideUtils.loadImage4HomepageService(mContext, item?.optString("imageUrl"), icLogo)
        } else {
            val isMore:Boolean = item.optString("title").equals(LanguageUtil.getString(mContext,"common_action_showMore"))

            icLogo.imageResource = if(isMore){
                R.drawable.home_service_more
            }else{
                R.drawable.icon_send_image
            }
        }

        /**
         * title
         */
        var name = item?.optString("title")
        helper?.setText(R.id.tv_service_title, name)

    }

}
