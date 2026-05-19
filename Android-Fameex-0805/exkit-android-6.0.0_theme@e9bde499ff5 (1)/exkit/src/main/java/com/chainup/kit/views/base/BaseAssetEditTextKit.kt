package com.chainup.kit.views.base

import android.content.Context
import android.graphics.Rect
import android.graphics.drawable.Drawable
import android.graphics.drawable.GradientDrawable
import android.graphics.drawable.LayerDrawable
import android.graphics.drawable.StateListDrawable
import android.os.Build
import android.text.Editable
import android.text.InputType
import android.text.TextWatcher
import android.text.method.HideReturnsTransformationMethod
import android.text.method.PasswordTransformationMethod
import android.util.AttributeSet
import android.util.Log
import android.view.MotionEvent
import android.view.View
import android.widget.EditText
import android.widget.TextView
import androidx.annotation.ColorInt
import androidx.appcompat.widget.AppCompatEditText
import androidx.core.content.ContextCompat
import com.chainup.kit.utils.KeyBoardUtils
import com.chainup.kit.utils.PublicSizeUtil
import com.example.chainup_kit.R
import org.jetbrains.anko.hintTextColor
import org.jetbrains.anko.textColor

/**
 * BaseEditTextKit
 * @property clearIconVisible is show clear icon?
 * @property searchIconVisible is show search icon?
 * @property setErrorMode
 * @property clearErrorMode
 * @property getErrorMode isErrorMode -> true error | false right
 * @property listener
 * @property isNotNeedIcon
 * @property isSearch
 * */
open class BaseAssetEditTextKit @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null
) : AppCompatEditText(context, attrs) {
    private lateinit var icClearImg:Drawable
    private lateinit var icSearchImg:Drawable
    private lateinit var icEyesClose:Drawable
    private lateinit var icEyesOpen:Drawable
    var isNotNeedIcon = false
    var clearIconVisible: Boolean = true

    var pwdVisible:Boolean = false
        set(value) {
            field = value
            visiblePassword(field)
        }
    @ColorInt
    private var backgroundColor:Int = -1

    var searchIconVisible: Boolean = false
        set(value) {
            field = value
            updateIconVisible(hasFocus() && text!!.length > 0 && clearIconVisible)
        }

    var isSearch:Boolean = false
        set(value) {
            field = value
            searchIconVisible = value
        }
    private var isHasBackground:Boolean

    private var isErrorMode = false// isErrorMode -> true error | false right
    var listener:OnKKBaseListener? = null


    init {
        val typedArray = context.obtainStyledAttributes(attrs, R.styleable.BaseEditTextKit)
        isSearch = typedArray.getBoolean(R.styleable.BaseEditTextKit_kk_isSearch,false)
        isHasBackground = typedArray.getBoolean(R.styleable.BaseEditTextKit_kk_isHasBackground,true)
        backgroundColor = typedArray.getColor(R.styleable.BaseEditTextKit_kk_et_fillColor,ContextCompat.getColor(context,R.color.search_bg_color))
        typedArray.recycle()
        initIcon()
        initView()
    }

    private fun initView() {

//        textSize = resources.getDimensionPixelSize(R.dimen.sp_5).toFloat()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            typeface = context.resources.getFont(R.font.harmony_medium)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            textCursorDrawable = ContextCompat.getDrawable(context,R.drawable.public_et_cursor_color)
        }

        hintTextColor = ContextCompat.getColor(context,R.color.text_color_3)
        textColor = ContextCompat.getColor(context,R.color.text_color_1)
//        setPadding(PublicSizeUtil.dp2px(context,16.0f),0,PublicSizeUtil.dp2px(context,16.0f),0)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            importantForAutofill = IMPORTANT_FOR_AUTOFILL_NO
        }
        initBg()


    }

    private fun initIcon(){
        icClearImg = ContextCompat.getDrawable(context,R.drawable.public_deleteall_16)!!
        icSearchImg = ContextCompat.getDrawable(context,R.drawable.public_search_16)!!
        icEyesClose = ContextCompat.getDrawable(context,R.mipmap.login_eyeoff)!!
        icEyesOpen = ContextCompat.getDrawable(context,R.mipmap.login_eyeon)!!
        val iconSize = PublicSizeUtil.dp2px(context,16.0f)
        val icClearSize = PublicSizeUtil.dp2px(context,16.0f)
        icClearImg.setBounds(0, 0, icClearSize, icClearSize)
        icSearchImg.setBounds(0, 0, iconSize, iconSize)
        icEyesClose.setBounds(0, 0, iconSize, iconSize - PublicSizeUtil.dp2px(context,2.0f))
        icEyesOpen.setBounds(0, 0, iconSize, iconSize - PublicSizeUtil.dp2px(context,2.0f))
    }
    private fun getIconDrawable(visibleClearIcon:Boolean,visibleIcon:Boolean):Drawable?{
        try {
            initIcon()
            if(!visibleIcon){
                return null
            }

            if(isPasswordType()){
                val icEyes = if(pwdVisible) icEyesOpen else icEyesClose
                if(!visibleClearIcon){
                    return icEyes
                }
                val iconSize = PublicSizeUtil.dp2px(context,20.0f)
                val paddingLeft = PublicSizeUtil.dp2px(context,16.0f)
                val finalDrawable = LayerDrawable(arrayOf(icClearImg , icEyes))
                finalDrawable.setLayerInset(0, 0, PublicSizeUtil.dp2px(context,2.0f), iconSize + PublicSizeUtil.dp2px(context,4.0f) + paddingLeft, PublicSizeUtil.dp2px(context,2.0f))
                finalDrawable.setLayerInset(1, iconSize + paddingLeft, PublicSizeUtil.dp2px(context,1.0f), 0, PublicSizeUtil.dp2px(context,1.0f))
                finalDrawable.setBounds(0, 0, iconSize * 2 + paddingLeft, iconSize)
                return finalDrawable
            }else{
                return if(visibleClearIcon) icClearImg else null
            }
        }catch (e:java.lang.Exception){
            e.printStackTrace()
            return null
        }

    }

    override fun onTextChanged(
        text: CharSequence?,
        start: Int,
        lengthBefore: Int,
        lengthAfter: Int
    ) {
        Log.d("onTextChanged","text:$text")
        super.onTextChanged(text, start, lengthBefore, lengthAfter)
        updateIconVisible(hasFocus() && text!!.length > 0 && clearIconVisible,true)
        changeStatusModeUI()
        listener?.textChange(text.toString())
    }

    override fun onFocusChanged(focused: Boolean, direction: Int, previouslyFocusedRect: Rect?) {
        super.onFocusChanged(focused, direction, previouslyFocusedRect)
        updateIconVisible(hasFocus() && text!!.length > 0 && clearIconVisible,focused)
        initBg(focused)
        changeStatusModeUI()
    }

    private fun updateIconVisible(iconClearVisible: Boolean,visibleIcon:Boolean = false) {
        if(isNotNeedIcon) return
        setCompoundDrawables(if(searchIconVisible) icSearchImg else null, null, getIconDrawable(iconClearVisible,visibleIcon), null)
        compoundDrawablePadding = PublicSizeUtil.dp2px(context,4.0f)
    }

    override fun onTouchEvent(event: MotionEvent?): Boolean {

        if(isNotNeedIcon) return super.onTouchEvent(event)
        if (event?.action == MotionEvent.ACTION_UP) {
            var isClearAction = false
            var isEyesAction = false
            if(isPasswordType()){
                if(text!!.isNotEmpty() && clearIconVisible){
                    isClearAction = event.x > width - totalPaddingRight && event.x < width - totalPaddingRight/2
                    isEyesAction  = event.x > width - totalPaddingRight/2 && event.x < width - paddingRight
                }else{
                    isEyesAction  = event.x > width - totalPaddingRight && event.x < width - paddingRight
                }

            }else{
                isClearAction = event.x > width - totalPaddingRight && event.x < width - paddingRight
            }

            if (isClearAction) {
                setText("")
                clearErrorMode()
                listener?.clear()
                return super.onTouchEvent(event)
            }

            if(isEyesAction){
                pwdVisible = !pwdVisible
                return super.onTouchEvent(event)
            }

        }
        return super.onTouchEvent(event)
    }

    fun visiblePassword(visible:Boolean){

        updateIconVisible(hasFocus() && text!!.length > 0 && clearIconVisible,true)
        if(visible){
            setTransformationMethod(HideReturnsTransformationMethod.getInstance())
        }else{
            setTransformationMethod(PasswordTransformationMethod.getInstance())
        }
    }

    private fun changeStatusModeUI(){
        listener?.let {
            val rule = it.rules()
            if(!rule) {
                setErrorMode()
            }else{
                clearErrorMode()
            }
        }
    }
    fun setErrorMode(){
        if(hasFocus() && !isSearch && isHasBackground){
            isErrorMode = true
            background = createDrawable(backgroundColor, radius = 4.0f, borderColor = ContextCompat.getColor(context,R.color.main_red), border = 2)
            listener?.statusChange(isErrorMode)
        }
    }

    // isErrorMode -> true error | false right
    fun getErrorMode():Boolean{
        return isErrorMode
    }
    fun clearErrorMode(){
        isErrorMode = false
        initBg()
        listener?.statusChange(isErrorMode)
    }

    private fun initBg(focused: Boolean = hasFocus()){
        if(isErrorMode && focused){
            setErrorMode()
            return
        }
        background = if(isHasBackground){
            if(isSearch){
                createDrawable(backgroundColor, radius = 57.0f)
            }else{
                //public_et_bg_selector
                createEditTextDrawable(backgroundColor)
            }
        } else null
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


    private fun createEditTextDrawable(@ColorInt color:Int):Drawable{
        val drawable = StateListDrawable()

        val defDrawable = createDrawable(color, radius = 4.0f)
        val focusedDrawable = createDrawable(color, radius = 4.0f, borderColor = ContextCompat.getColor(context,R.color.main_color), border = 2)

        drawable.addState(intArrayOf(android.R.attr.state_focused),focusedDrawable)
        drawable.addState(intArrayOf(android.R.attr.state_selected),focusedDrawable)
        drawable.addState(intArrayOf(),defDrawable)
        return drawable
    }


    interface OnKKBaseListener{
        fun textChange(text:String)
        fun clear(){}
        fun actionClick(targetView: EditText,actionView: View){}
        // rule -> true right | false error
        fun rules():Boolean = true
        fun statusChange(status:Boolean){}
    }


    private fun isPasswordType():Boolean {
        return when(inputType) {
            InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_VARIATION_PASSWORD,
            InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_VARIATION_VISIBLE_PASSWORD,
            InputType.TYPE_CLASS_NUMBER or InputType.TYPE_NUMBER_VARIATION_PASSWORD -> true
            else -> false
        }
    }


}
