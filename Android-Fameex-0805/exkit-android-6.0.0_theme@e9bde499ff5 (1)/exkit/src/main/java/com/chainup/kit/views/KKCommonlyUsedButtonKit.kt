package com.chainup.kit.views

import android.content.Context
import android.text.Html
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.widget.LinearLayout
import androidx.core.content.ContextCompat
import com.chainup.kit.utils.PublicSizeUtil
import com.chainup.kit.utils.Utils
import com.example.chainup_kit.R
import kotlinx.android.synthetic.main.kk_commonly_used_button_old.view.*

/**
 * @property listener
 * @property style
 * @property textContent
 * @property showLoading
 * @property hideLoading
 * @property isEnable
 * @attr kk_textContent string
 * @attr kk_style same @property style
<flag name="main" value="1"/>
<flag name="cancel" value="2"/>
<flag name="green" value="3"/>
<flag name="red" value="4"/>
<flag name="text" value="5"/>
 * @attr kk_textSize
 * @description 6.0 KKCommonlyUsedButtonViewKit
 */
@Deprecated("This is old button kit, You can update it to KKButtonKit", ReplaceWith("KKButtonKit"))
open class KKCommonlyUsedButtonViewKit @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : LinearLayout(context, attrs, defStyleAttr),View.OnClickListener {

    interface OnKKBottonClickListener {
        fun bottonOnClick()
    }
    private var clicked = true
    var listener: OnKKBottonClickListener? = null
    private var textColor = ContextCompat.getColor(context, R.color.white)
    private var layout:View? = null

    var style:Int = 1
        set(value) {
            field = value
            if(layout!=null) updateBotton()
        }

    var textContent = ""
        set(value) {
            field = value
            if(layout!=null) tv_complainCommand_content?.text = Html.fromHtml(field)
        }

    private var textSize = 14.0f

    init {
        attrs.let {
            val typedArray = context.obtainStyledAttributes(attrs, R.styleable.KKCommonlyUsedButtonViewKit)
            textContent = typedArray.getString(R.styleable.KKCommonlyUsedButtonViewKit_kk_textContent).toString()
            style = typedArray.getInt(R.styleable.KKCommonlyUsedButtonViewKit_kk_style,1)
            textSize = typedArray.getDimension(R.styleable.KKCommonlyUsedButtonViewKit_kk_textSize,context.resources.getDimension(R.dimen.sp_14))
            typedArray.recycle()
        }
        initView(context)
    }

    private fun initView(context: Context) {
        layout = LayoutInflater.from(context).inflate(R.layout.kk_commonly_used_button_old, this, true)
        tv_complainCommand_content.text = Html.fromHtml(textContent)
        updateBotton()
        rl_layout.setOnClickListener(this)
    }

    private fun updateBotton(){
        tv_complainCommand_content.paint.textSize = textSize

        when(style){
            1 -> {
                textColor = ContextCompat.getColor(context, R.color.white)
                rl_layout.background = ContextCompat.getDrawable(context,R.drawable.kk_btn_1_bg)
            }
            2 -> {
                textColor = ContextCompat.getColor(context, R.color.text_color_1)
                rl_layout.background = ContextCompat.getDrawable(context,R.drawable.kk_btn_2_bg)
            }
            3 -> {
                textColor = ContextCompat.getColor(context, R.color.white)
                rl_layout.background = ContextCompat.getDrawable(context,R.drawable.kk_btn_3_bg)
            }
            4 -> {
                textColor = ContextCompat.getColor(context, R.color.white)
                rl_layout.background = ContextCompat.getDrawable(context,R.drawable.kk_btn_4_bg)
            }
            5 -> {
                textColor = ContextCompat.getColor(context, R.color.main_color)
                rl_layout.background = null
                tv_complainCommand_content.setTextColor(ContextCompat.getColorStateList(context,R.color.kk_btn_5_color))
                return
            }
        }
        tv_complainCommand_content.setTextColor(textColor)
    }


    /**
     * Clickable or not
     *  @param status true is clickable. false is not clickable
     */
    fun isEnable(status: Boolean) {
        rl_layout.isEnabled = status
        isEnabled = status
        clicked = status

        if(!status){
            tv_complainCommand_content.setTextColor(ContextCompat.getColor(context,R.color.text_color_2))
            return
        }
        if(style == 5) {
            tv_complainCommand_content.setTextColor(ContextCompat.getColorStateList(context,R.color.kk_btn_5_color))
        }else{
            tv_complainCommand_content.setTextColor(textColor)
        }

    }


    /**
     * show loading
     */
    fun showLoading() {
        tv_complainCommand_content?.visibility = View.GONE
        pb_view.visibility = View.VISIBLE
        clicked = false
    }

    /**
     * hide loading
     */
    fun hideLoading() {
        tv_complainCommand_content?.visibility = View.VISIBLE
        pb_view.visibility = View.GONE
        clicked = true
    }


    override fun onClick(v: View?) {
        if (listener != null && clicked) {
            if (!Utils.isFastClick()) {
                listener?.bottonOnClick()
            }
        }
    }


}
