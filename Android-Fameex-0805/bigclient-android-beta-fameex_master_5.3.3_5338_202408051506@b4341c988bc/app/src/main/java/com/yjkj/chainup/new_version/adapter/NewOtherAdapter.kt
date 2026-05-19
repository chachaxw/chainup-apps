package com.yjkj.chainup.new_version.adapter

import android.text.TextUtils
import android.util.Log
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.content.ContextCompat
import com.bumptech.glide.Glide
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.makeramen.roundedimageview.RoundedImageView
import com.yjkj.chainup.R
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.manager.RateManager
import com.yjkj.chainup.manager.TAG
import com.yjkj.chainup.new_version.view.CustomTagView
import com.yjkj.chainup.util.*
import com.yjkj.chainup.wedegit.ViewUtil
import org.json.JSONObject

/**
 * @Author lianshangljl
 * @Date 2023/11/8-10:20 AM
 * @Email buptjinlong@163.com
 *@description New homepage rise and fall rate
 *
 * data: ArrayList<JSONObject>
 */
open class NewOtherAdapter : BaseQuickAdapter<JSONObject, BaseViewHolder>(R.layout.other_image) {

    var isDouble = false
    override fun convert(helper: BaseViewHolder, item: JSONObject) {


        val imageView = helper.getView<RoundedImageView>(R.id.image)
        val layoutParams = imageView.layoutParams
        if(data.size == 1){
            layoutParams.width = ViewGroup.LayoutParams.MATCH_PARENT
        } else {
            layoutParams.width = (ViewUtil.screenWidth() -  ViewUtil.dpToPx(10f) - ViewUtil.dpToPx(32f)) / 2
        }
        val temp = ContextCompat.getDrawable(context,if(data.size == 1) R.mipmap.home_pic_smallbanner_1_occupationmap
        else R.mipmap.home_pic_smallbanner_2_occupationmap)
//        imageView.layoutParams = layoutParams
        Glide.with(helper.itemView)
            .load(item.optString("imageUrl")).error(temp).placeholder(temp)
            .into(imageView)
    }

}
