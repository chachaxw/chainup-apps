package com.yjkj.chainup.new_version.home.adapter

import android.content.Context
import android.view.ViewGroup
import android.widget.ImageView
import androidx.core.content.ContextCompat
import com.bumptech.glide.Glide
import com.yjkj.chainup.R
import com.yjkj.chainup.new_version.home.viewholder.ImageHolder
import com.youth.banner.adapter.BannerAdapter
import com.youth.banner.util.BannerUtils


class ImageNetAdapter(mDatas: List<String>) : BannerAdapter<String, ImageHolder>(mDatas) {
    var mContext: Context? = null
    override fun onCreateHolder(parent: ViewGroup, viewType: Int): ImageHolder {
        val imageView: ImageView = BannerUtils.getView(parent, R.layout.banner_image) as ImageView
        return ImageHolder(imageView)
    }

    override fun onBindView(holder: ImageHolder, data: String, position: Int, size: Int) {
        //By using an image loader to achieve rounded corners, you can also use the rounded image view yourself. There are many ways to achieve rounded corners, so try it yourself
        val drawable =
            mContext?.let { ContextCompat.getDrawable(it, R.mipmap.home_pic_banner_occupationmap) }
        Glide.with(holder.itemView)
            .load(data).error(drawable).placeholder(drawable)
            .into(holder.imageView)
    }
}
