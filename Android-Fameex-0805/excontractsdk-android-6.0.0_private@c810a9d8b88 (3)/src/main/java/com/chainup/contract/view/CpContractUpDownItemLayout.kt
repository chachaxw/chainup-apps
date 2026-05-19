package com.chainup.contract.view

import android.content.Context
import androidx.core.content.ContextCompat
import android.util.AttributeSet
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View.OnClickListener
import android.widget.LinearLayout
import com.chainup.contract.R
import com.chainup.contract.utils.CpSizeUtils
import kotlinx.android.synthetic.main.cp_up_down_item_layout.view.*

/**
 *Contractual generic component packaging (upper and lower structure)
 */
class CpContractUpDownItemLayout : LinearLayout {
    private val layoutInflater: LayoutInflater = LayoutInflater.from(context)

    constructor(context: Context?, attrs: AttributeSet?) : super(context, attrs) {
        initAttrs(attrs)
    }

    private fun initAttrs(attrs: AttributeSet?) {
        attrs?.let {
            var typedArray = context.obtainStyledAttributes(it, R.styleable.SlUpDownItemStyle, 0, 0)
            title = typedArray.getString(R.styleable.SlUpDownItemStyle_sl_itemTitle) ?: ""
            contentGravity = typedArray.getInt(R.styleable.SlUpDownItemStyle_contentGravity, 1)
            showExplain = typedArray.getBoolean(R.styleable.SlUpDownItemStyle_showExplain, false)
            explainText = typedArray.getString(R.styleable.SlUpDownItemStyle_explainText) ?: ""
            contentTextColor = typedArray.getInt(R.styleable.SlUpDownItemStyle_contentGravity, ContextCompat.getColor(context, R.color.text_color))
            typedArray.recycle()
            if (showExplain) {
                setExplainListener(OnClickListener { CpNewDialogUtils.showDialog(context, explainText, true, null, context.getString(R.string.cp_extra_text27), context.getString(R.string.cp_extra_text28)) })
            }
        }
    }

    /**
     *Title
     */
    var title = ""
        set(value) {
            field = value
            tv_title?.text = title
        }
    /**
     *Content
     */
    var content = ""
        set(value) {
            field = value
            tv_value?.text = content
        }
    /**
     *Content Color
     */
    var contentTextColor = ContextCompat.getColor(context, R.color.text_color)
        set(value) {
            field = value
            tv_value?.setTextColor(value)
        }
    /**
     *The layout direction of the content is 1 left 2 right
     */
    var contentGravity = 1
        set(value) {
            field = value
            ll_warp_layout?.gravity = if(contentGravity == 1) Gravity.LEFT else Gravity.RIGHT
        }
    /**
     *Whether to display instructions
     */
    var showExplain = false
        set(value) {
            field = value
            if (showExplain) {
                tv_title?.compoundDrawablePadding = CpSizeUtils.dp2px(3f)
                tv_title?.setCompoundDrawablesWithIntrinsicBounds(null, null, resources.getDrawable(R.drawable.contract_instructions_small), null)
            } else {
                tv_title?.setCompoundDrawablesWithIntrinsicBounds(null, null, null, null)
            }
        }
    /**
     *Description Text
     */
    var explainText = ""


    /**
     *Set Description Click Event
     */
    fun setExplainListener(listener: OnClickListener?) {
        tv_title?.setOnClickListener(listener)
    }

    init {
        layoutInflater.inflate(R.layout.cp_up_down_item_layout, this)
    }

}
