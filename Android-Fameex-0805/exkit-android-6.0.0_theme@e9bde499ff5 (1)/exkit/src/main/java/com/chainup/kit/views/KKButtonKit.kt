package com.chainup.kit.views

import android.content.Context
import android.graphics.Color
import android.text.Html
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import androidx.core.content.ContextCompat
import com.example.chainup_kit.R
import com.qmuiteam.qmui.layout.QMUILinearLayout
import com.warkiz.widget.SizeUtils
import kotlinx.android.synthetic.main.kk_commonly_used_button.view.*
import org.jetbrains.anko.backgroundColor

enum class KKButtonStyleEnum(val value:Int){
    MAIN(1),
    CANCEL(2),
    GREEN(3),
    RED(4),
    TEXT(5),
    OTHER(6),
    OTHER_ENABLE(7),
}
/**
 * @attr kk_buttonText string
 * @attr kk_buttonTextSize string
 * @attr kk_buttonStyle same @property style
 *  <flag name="main" value="1"/>
<flag name="cancel" value="2"/>
<flag name="green" value="3"/>
<flag name="red" value="4"/>
<flag name="text" value="5"/>
 *
 * @property style 1,2,3,4,5
 * @property textContent button text
 * @property showLoading show load status
 * @property isEnable is can click
 * @property hideLoading hide load status
 * ```
Example:
 *   <com.chainup.kit.views.KKButtonKit
 *       android:id="@+id/lodingbtn"
 *       android:layout_width="343dp"
 *       android:layout_height="@dimen/dp_44"
 *       android:layout_marginTop="10dp"
 *App: kk_ ButtonText="Style-1 click loading"
 *   />
 * ```
 * @description 6.0 KKButtonKit
 */
open class KKButtonKit @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : QMUILinearLayout(context, attrs, defStyleAttr) {

    public var isLoading = true
    private var textColor = ContextCompat.getColor(context, R.color.white)
    private var layout:View? = null
    var style:Int = 1
        set(value) {
            field = value
            if(layout!=null) updateButton()
        }

    var textContent = ""
        set(value) {
            field = value
            if(layout!=null) tv_complainCommand_content?.text = Html.fromHtml(field)
        }

    private var textSize = 14.0f

    init {
        attrs.let {
            val typedArray = context.obtainStyledAttributes(attrs, R.styleable.KKButtonKitAttr)
            textContent = typedArray.getString(R.styleable.KKButtonKitAttr_kk_buttonText).toString()
            style = typedArray.getInt(R.styleable.KKButtonKitAttr_kk_buttonStyle,1)
            textSize = typedArray.getDimension(R.styleable.KKButtonKitAttr_kk_buttonTextSize,context.resources.getDimension(R.dimen.sp_14))
            typedArray.recycle()
        }
        initView(context)
    }

    private fun initView(context: Context) {
        setRadius(SizeUtils.dp2px(context,4f))
        layout = LayoutInflater.from(context).inflate(R.layout.kk_commonly_used_button, this, true)
        tv_complainCommand_content.text = Html.fromHtml(textContent)
        updateButton()
    }

    private fun updateButton(){
        tv_complainCommand_content.paint.textSize = textSize

        when(style){
            KKButtonStyleEnum.MAIN.value -> {
                textColor = ContextCompat.getColor(context, R.color.text_4)
                background = ContextCompat.getDrawable(context,R.drawable.kk_btn_1_bg)
            }
            KKButtonStyleEnum.CANCEL.value -> {
                textColor = ContextCompat.getColor(context, R.color.text_color_1)
                background = ContextCompat.getDrawable(context,R.drawable.kk_btn_2_bg)
            }
            KKButtonStyleEnum.GREEN.value -> {
                textColor = ContextCompat.getColor(context, R.color.white)
                background = ContextCompat.getDrawable(context,R.drawable.kk_btn_3_bg)
            }
            KKButtonStyleEnum.RED.value -> {
                textColor = ContextCompat.getColor(context, R.color.white)
                background = ContextCompat.getDrawable(context,R.drawable.kk_btn_4_bg)
            }
            KKButtonStyleEnum.TEXT.value -> {
                textColor = ContextCompat.getColor(context, R.color.main_color)
                background = null
                tv_complainCommand_content.setTextColor(ContextCompat.getColorStateList(context,R.color.kk_btn_5_color))
                return
            }
            KKButtonStyleEnum.OTHER.value -> {
                textColor = ContextCompat.getColor(context, R.color.text_color_1)
                background = ContextCompat.getDrawable(context,R.drawable.kk_btn_6_bg)
            }
            KKButtonStyleEnum.OTHER_ENABLE.value -> {
                textColor = ContextCompat.getColor(context, R.color.text_color_1)
                background = ContextCompat.getDrawable(context,R.drawable.kk_btn_7_bg)
            }
        }
        tv_complainCommand_content.setTextColor(textColor)
    }


    fun setBgColor(mColor: Int) {
        backgroundColor = mColor
    }
    override fun setEnabled(enabled: Boolean) {
        super.setEnabled(enabled)
        if(!enabled){
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
     * Clickable or not
     *  @param status true is clickable. false is not clickable
     */
    fun isEnable(status: Boolean) {
        isEnabled = status
    }


    /**
     * show loading
     */
    fun showLoading() {
        tv_complainCommand_content?.visibility = View.GONE
        pb_view.visibility = View.VISIBLE
        isLoading = true
    }

    /**
     * hide loading
     */
    fun hideLoading() {
        tv_complainCommand_content?.visibility = View.VISIBLE
        pb_view.visibility = View.GONE
        isLoading = false
    }
}
