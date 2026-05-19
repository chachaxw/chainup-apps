package com.chainup.kit.views

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.widget.LinearLayout
import com.chainup.kit.utils.PublicSizeUtil
import com.example.chainup_kit.R
import kotlinx.android.synthetic.main.public_layout_empty_data.view.*

/**
 * @Author lianshangljl
 * @Date 2020-03-30-12:44
 * @Email buptjinlong@163.com
 * @description
 */
open class KKEmptyViewKit @JvmOverloads constructor(
        context: Context,
        attrs: AttributeSet? = null,
        defStyleAttr: Int = 0
    ) : LinearLayout(context, attrs, defStyleAttr) {

    init {
        initView(context)
    }


    private fun initView(context: Context) {
        LayoutInflater.from(context).inflate(R.layout.public_layout_empty_data, this, true)
        tv_empty_title?.text = context.getString(R.string.kk_string_empty_data_message)
    }

    fun setMessage(message:String) {
        tv_empty_title?.text = message
    }

    open fun setImageViewTop(dpTop:Float){
        val lp = im_nodata.layoutParams as MarginLayoutParams
        lp.topMargin = PublicSizeUtil.dp2px(context,dpTop)
        im_nodata.layoutParams = lp
    }


}
