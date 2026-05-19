package com.chainup.kit.views

import android.content.Context
import android.graphics.drawable.Drawable
import android.graphics.drawable.GradientDrawable
import android.graphics.drawable.StateListDrawable
import android.text.InputFilter
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.widget.EditText
import android.widget.LinearLayout
import androidx.annotation.ColorInt
import androidx.core.content.ContextCompat
import androidx.core.widget.addTextChangedListener
import com.chainup.kit.utils.PublicSizeUtil
import com.chainup.kit.views.base.BaseEditTextKit
import com.example.chainup_kit.R
import kotlinx.android.synthetic.main.public_layout_edit_formgroup.view.*
import org.jetbrains.anko.textColor

/**
 * KKEditFormGroupKit
 * @attr kk_title         = title
 * @attr kk_action1       = action1
 * @attr kk_action2       = action2
 * @attr kk_efg_fillColor   bgColor
 * @attr kk_hint          = hint
 * @attr kk_input_type
 *
 * @property title top label | title
 * @property action1 default left action
 * @property action2 default right action
 * @property hint editText hint
 *
 * @property getRealEditText return EditText
 * @property getText  editText text.toString
 * @property listener event
 * */
open class KKEditFormGroupKit @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null
) : LinearLayout(context, attrs) {
    private val layout: View
    var action1:String = ""
        set(value) {
            field = value
            setUIAction()
        }
    var action2:String = ""
        set(value) {
            field = value
            setUIAction()
        }
    var title:String = ""
        set(value) {
            field = value
            setUITitle()
        }
    var filters:Array<InputFilter>? = null
        set(value) {
            field = value
            bet_text.filters = value
        }
    private var inputType:Int
    var hint:String = ""
        set(value) {
            field = value
            bet_text.hint = hint
        }
    @ColorInt
    private var backgroundColor:Int = -1

    @ColorInt
    private var actionColor:Int = -1

    private var isErrorMode = false
    private var isActionLine = false
    var listener: BaseEditTextKit.OnKKBaseListener? = null
        set(value) {
            field = value
            if(bet_text.listener==null) bet_text.listener = field
        }
    init {
        layout = LayoutInflater.from(context).inflate(R.layout.public_layout_edit_formgroup,this,true)
        val typedArray = context.obtainStyledAttributes(attrs,R.styleable.KKEditFormGroupKit)
        //default action
        action1 = typedArray.getString(R.styleable.KKEditFormGroupKit_kk_action1) ?: ""
        action2 = typedArray.getString(R.styleable.KKEditFormGroupKit_kk_action2) ?: ""
        if("".equals(action1) && "".equals(action2)){
            ll_action.visibility = View.GONE
        }
        isActionLine = typedArray.getBoolean(R.styleable.KKEditFormGroupKit_kk_action_line,false)
        view_line.visibility = if(isActionLine) View.VISIBLE else View.GONE
        title = typedArray.getString(R.styleable.KKEditFormGroupKit_kk_title) ?: ""
        backgroundColor = typedArray.getColor(R.styleable.KKEditFormGroupKit_kk_efg_fillColor,ContextCompat.getColor(context,R.color.search_bg_color))
        actionColor = typedArray.getColor(R.styleable.KKEditFormGroupKit_kk_action_textColor ,ContextCompat.getColor(context,R.color.text_color_1))
        inputType = typedArray.getInt(R.styleable.KKEditFormGroupKit_kk_input_type, 0x00000001)
        hint = typedArray.getString(R.styleable.KKEditFormGroupKit_kk_hint) ?: ""
        typedArray.recycle()
        initView()
    }

    private fun initView() {

        bet_text.setOnFocusChangeListener { v, hasFocus ->
            initBg(hasFocus)
            ll_et_text.isSelected = hasFocus
            changeStatusModeUI()
        }
        bet_text.addTextChangedListener {
            changeStatusModeUI()
        }

        tv_action1.setOnClickListener {
            listener?.actionClick(bet_text,tv_action1)
        }
        tv_action2.setOnClickListener {
            listener?.actionClick(bet_text,tv_action2)
        }

        initBg()
        tv_action1?.textColor =  actionColor

        bet_text.inputType=inputType
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//            bet_text.typeface = resources.getFont(R.font.harmony_medium)
//        }
    }

    private fun setUITitle(){
        tv_title.visibility = if(!"".equals(title)) {
            tv_title.text = title
            View.VISIBLE
        } else {
            View.GONE
        }
    }

    private fun setUIAction(){
        tv_action1.visibility = if(!"".equals(action1)) {
            tv_action1.text = action1
            View.VISIBLE
        } else View.GONE

        tv_action2.visibility = if(!"".equals(action2)){
            tv_action2.text = action2
            View.VISIBLE
        } else View.GONE

        ll_action?.visibility=if("".equals(action1)&&"".equals(action2))View.GONE else View.VISIBLE
    }

    private fun initBg(focus:Boolean = hasFocus()){
        if(isErrorMode && focus){
            ll_et_text.background = createDrawable(backgroundColor, radius = 4.0f, borderColor = ContextCompat.getColor(context,R.color.main_red), border = 2)
            return
        }
        //public_et_bg_selector
        ll_et_text.background = createEditTextDrawable(backgroundColor)
    }



    private fun createDrawable(@ColorInt color:Int, border:Int = 0, radius:Float = 0.0f, @ColorInt borderColor:Int? = null): Drawable {
        val drawable = GradientDrawable()
        drawable.cornerRadius = PublicSizeUtil.dp2px(context,radius).toFloat()
        drawable.shape = GradientDrawable.RECTANGLE
        drawable.setColor(color)
        if(borderColor!=null){
            drawable.setStroke(border,borderColor)
        }
        return drawable
    }


    private fun createEditTextDrawable(@ColorInt color:Int): Drawable {
        val drawable = StateListDrawable()

        val defDrawable = createDrawable(color, radius = 4.0f)
        val focusedDrawable = createDrawable(color, radius = 4.0f, borderColor = ContextCompat.getColor(context,R.color.main_color), border = 2)

        drawable.addState(intArrayOf(android.R.attr.state_focused),focusedDrawable)
        drawable.addState(intArrayOf(android.R.attr.state_selected),focusedDrawable)
        drawable.addState(intArrayOf(),defDrawable)
        return drawable
    }

    private fun changeStatusModeUI(){
        listener?.let {
            val rule = it.rules()?:return@let
            if(!rule) {
                setErrorMode()
            }else{
                clearErrorMode()
            }
        }
    }

    fun setErrorMode(){
        if(bet_text.hasFocus()){
            isErrorMode = true
            initBg()
            listener?.statusChange(isErrorMode)
        }
    }

    fun getErrorMode():Boolean{
        return isErrorMode
    }
    fun clearErrorMode(){
        isErrorMode = false
        initBg()
        listener?.statusChange(isErrorMode)
    }

    fun setInputMaxLength(max: Int) {
        bet_text.filters = arrayOf<InputFilter>(InputFilter.LengthFilter(max))
    }


    fun addCustomAction(view: View){
        ll_action.removeAllViews()
        ll_action.addView(view)
    }

    fun addCustomActionBefore(view: View){
        fl_prev_action.removeAllViews()
        fl_prev_action.addView(view)
    }

    fun removeCustomActionBefore(){
        fl_prev_action.removeAllViews()
    }

    /**
     * @return EditText
     * */
    fun getRealEditText(): EditText {
        return bet_text
    }

    /**
     * @return EditText.text.toString
     * */
    fun getText():String{
        return getRealEditText().text.toString()
    }

    fun setText(text: String) {
        getRealEditText().setText(text)
    }

    fun editEnable(isEnable:Boolean = true){
       if(isEnable){
           ll_et_text.background = createEditTextDrawable(backgroundColor)
           bet_text?.isEnabled = true
       } else {
           ll_et_text.background = createEditTextDrawable(ContextCompat.getColor(context,R.color.fill_5))
           bet_text?.isEnabled = false
       }
        //public_et_bg_selector
    }
}
