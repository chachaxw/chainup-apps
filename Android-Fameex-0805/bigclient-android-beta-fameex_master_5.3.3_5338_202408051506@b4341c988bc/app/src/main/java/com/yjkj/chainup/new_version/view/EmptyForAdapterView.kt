package com.yjkj.chainup.new_version.view

import android.content.Context
import android.util.AttributeSet
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.widget.LinearLayout
import androidx.core.view.marginTop
import com.yjkj.chainup.util.ColorUtil
import com.yjkj.chainup.R
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.util.ViewUtils
import com.yjkj.chainup.wedegit.ViewUtil
import kotlinx.android.synthetic.main.item_new_empty.view.*
import org.jetbrains.anko.imageResource
import org.jetbrains.anko.textColor

/**
 * @Author lianshangljl
 * @Date 2023-03-30-12:44
 * @Email buptjinlong@163.com
 * @description
 */
class EmptyForAdapterView @JvmOverloads constructor(context: Context,
                                                    attrs: AttributeSet? = null,
                                                    defStyleAttr: Int = 0,
                                                    isblack: Boolean = false) : LinearLayout(context, attrs, defStyleAttr) {


    var black:Boolean = false
    init {
        black = isblack
        initView(context)

    }


    fun initView(context: Context) {
        LayoutInflater.from(context).inflate(R.layout.item_new_empty, this, true)
        tv_empty_title?.text = LanguageUtil.getString(context, "common_tip_nodata")
        if (black){
            im_nodata.imageResource = R.mipmap.public_nocontentyet
            tv_empty_title.textColor = ColorUtil.getColor(R.color.normal_text_color_kline_night)
        }
    }

    fun initType(emptyType: EmptyType = EmptyType.NOR) {
        when(emptyType){
            EmptyType.NOR -> {
                empty_layout?.gravity = Gravity.CENTER
            }
            EmptyType.MAIN_120 -> {
                empty_layout?.gravity = Gravity.CENTER_HORIZONTAL
                val layoutParams = empty_layout?.layoutParams as LinearLayout.LayoutParams
                layoutParams.topMargin =  ViewUtil.dpToPx(120f)
                empty_layout?.layoutParams = layoutParams
            }
            EmptyType.LEFT_PAGE_100 -> {
                empty_layout?.gravity = Gravity.CENTER_HORIZONTAL
                val layoutParams = empty_layout?.layoutParams as LinearLayout.LayoutParams
                layoutParams.topMargin =  ViewUtil.dpToPx(100f)
                empty_layout?.layoutParams = layoutParams
            }
        }
    }


}

enum class EmptyType {
    MAIN_120,LEFT_PAGE_100,NOR
}
