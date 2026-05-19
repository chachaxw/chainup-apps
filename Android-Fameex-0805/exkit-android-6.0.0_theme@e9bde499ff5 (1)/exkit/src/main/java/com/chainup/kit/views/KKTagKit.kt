package com.chainup.kit.views

import android.content.Context
import android.util.AttributeSet
import androidx.core.content.ContextCompat
import androidx.core.content.res.ResourcesCompat
import com.coorchice.library.SuperTextView
import com.example.chainup_kit.R
import com.warkiz.widget.SizeUtils


enum class AuthState(var state: Int) {
    UNAUTHRZED(0), REVIEW(1), CERTIFIED(2), NOT_THROUGH(3);

    companion object {
        fun valueOf(code: Int): AuthState {
            val var1: Array<AuthState> = AuthState.values()
            val var2 = var1.size
            for (var3 in 0 until var2) {
                val mode = var1[var3]
                if (mode.state == code) {
                    return mode
                }
            }
            return AuthState.UNAUTHRZED
        }
    }
}

enum class KKTagType(var type: Int) {
    none(0), person(1), rise(2), fall(3),
    defi(4), fill(5), level(6), tag_convention(7),
    defi_new(8), rise_zero(9),fill3(10);
}

open class KKTagKit @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null
) : SuperTextView(context, attrs) {

    private var tagType = 0
    private var tagState = AuthState.UNAUTHRZED


    var tagStr: String? = null
        set(value) {
            field = value
            setTagContent(value)
        }

    init {
        val typedArray = context.obtainStyledAttributes(attrs, R.styleable.KKTagView)
        tagStr = typedArray.getString(R.styleable.KKTagView_kk_tag_title_text)
        tagType = typedArray.getInt(R.styleable.KKTagView_kk_tag_type, 4)
        tagState = AuthState.valueOf(typedArray.getInt(R.styleable.KKTagView_kk_tag_state, 0))
        typedArray.recycle()
        initView()
    }

    private fun initView() {
        when (tagType) {
            KKTagType.none.type -> {
                //Other
            }
            KKTagType.person.type -> {
                //Personal Center
                setCorner(SizeUtils.dp2px(context, 20f).toFloat())
                setLeftBottomCornerEnable(true)
                setLeftTopCornerEnable(true)
                setDrawable(R.drawable.ic_person_auth)
                setDrawableHeight(SizeUtils.dp2px(context, 16f).toFloat())
                setDrawableWidth(SizeUtils.dp2px(context, 16f).toFloat())
                setSolid(ContextCompat.getColor(context, R.color.tag_color))
                setDrawablePaddingLeft(SizeUtils.dp2px(context, 12f).toFloat())
                setDrawableTint(ContextCompat.getColor(context, R.color.main_color))
                setTextColor(ContextCompat.getColor(context, R.color.main_color))
                setShowState(true)
                setStateDrawableMode(DrawableMode.LEFT)
                setPadding(
                    SizeUtils.dp2px(context, 34f),
                    SizeUtils.dp2px(context, 8f),
                    SizeUtils.dp2px(context, 12f),
                    SizeUtils.dp2px(context, 8f)
                )
            }
            KKTagType.rise.type -> {
                //Rising
                setCorner(SizeUtils.dp2px(context, 2f).toFloat())
                setSolid(ContextCompat.getColor(context, R.color.main_green_15))
                setTextColor(ContextCompat.getColor(context, R.color.main_green))
                setPadding(
                    SizeUtils.dp2px(context, 4f),
                    SizeUtils.dp2px(context, 0f),
                    SizeUtils.dp2px(context, 4f),
                    SizeUtils.dp2px(context, 0f)
                )
                textSize=12f
                setTypeface(ResourcesCompat.getFont(context, R.font.harmony_medium))
            }
            KKTagType.fall.type -> {
                //Falling
                setCorner(SizeUtils.dp2px(context, 2f).toFloat())
                setSolid(ContextCompat.getColor(context, R.color.fall_3))
                setTextColor(ContextCompat.getColor(context, R.color.main_red))
                setPadding(
                    SizeUtils.dp2px(context, 4f),
                    SizeUtils.dp2px(context, 0f),
                    SizeUtils.dp2px(context, 4f),
                    SizeUtils.dp2px(context, 0f)
                )
                textSize=12f
                setTypeface(ResourcesCompat.getFont(context, R.font.harmony_medium))
            }
            KKTagType.defi.type -> {
                //defi
                setCorner(SizeUtils.dp2px(context, 2f).toFloat())
                setSolid(ContextCompat.getColor(context, R.color.tag_color))
                setTextColor(ContextCompat.getColor(context, R.color.main_color))
                setPadding(
                    SizeUtils.dp2px(context, 4f),
                    SizeUtils.dp2px(context, 0f),
                    SizeUtils.dp2px(context, 4f),
                    SizeUtils.dp2px(context, 0f)
                )
                textSize=12f
                setTypeface(ResourcesCompat.getFont(context, R.font.harmony_medium))
            }
            KKTagType.defi_new.type -> {
                //defi
                setCorner(SizeUtils.dp2px(context, 2f).toFloat())
                setSolid(ContextCompat.getColor(context, R.color.tag_color))
                setTextColor(ContextCompat.getColor(context, R.color.main_4))
                setPadding(
                    SizeUtils.dp2px(context, 4f),
                    SizeUtils.dp2px(context, 0f),
                    SizeUtils.dp2px(context, 4f),
                    SizeUtils.dp2px(context, 0f)
                )
                textSize=12f
                setTypeface(ResourcesCompat.getFont(context, R.font.harmony_medium))
            }
            KKTagType.fill.type -> {
                //fill
                setCorner(SizeUtils.dp2px(context, 2f).toFloat())
                setSolid(ContextCompat.getColor(context, R.color.main_color))
                setTextColor(ContextCompat.getColor(context, R.color.white))
                setPadding(
                    SizeUtils.dp2px(context, 4f),
                    SizeUtils.dp2px(context, 0f),
                    SizeUtils.dp2px(context, 4f),
                    SizeUtils.dp2px(context, 0f)
                )
                setTypeface(ResourcesCompat.getFont(context, R.font.harmony_regular))
            }
            KKTagType.level.type -> {
                //level
                setCorner(SizeUtils.dp2px(context, 2f).toFloat())
                setSolid(ContextCompat.getColor(context, R.color.line_color))
                setTextColor(ContextCompat.getColor(context, R.color.main_color))
                setPadding(
                    SizeUtils.dp2px(context, 2f),
                    SizeUtils.dp2px(context, 0f),
                    SizeUtils.dp2px(context, 2f),
                    SizeUtils.dp2px(context, 0f)
                )
                textSize=12f
                setTypeface(ResourcesCompat.getFont(context, R.font.harmony_medium))
            }
            KKTagType.tag_convention.type -> {
                //tag_convention
                setCorner(SizeUtils.dp2px(context, 2f).toFloat())
                setSolid(ContextCompat.getColor(context, R.color.fill_5))
                setTextColor(ContextCompat.getColor(context, R.color.text_1))
                setPadding(
                    SizeUtils.dp2px(context, 4f),
                    SizeUtils.dp2px(context, 0f),
                    SizeUtils.dp2px(context, 4f),
                    SizeUtils.dp2px(context, 0f)
                )
                textSize=12f
                setTypeface(ResourcesCompat.getFont(context, R.font.harmony_regular))
            }
            KKTagType.rise_zero.type -> {
                // zero 0.00%
                setCorner(SizeUtils.dp2px(context, 2f).toFloat())
                setSolid(ContextCompat.getColor(context, R.color.text_color_2_15))
                setTextColor(ContextCompat.getColor(context, R.color.text_2))
                setPadding(
                    SizeUtils.dp2px(context, 4f),
                    SizeUtils.dp2px(context, 0f),
                    SizeUtils.dp2px(context, 4f),
                    SizeUtils.dp2px(context, 0f)
                )
                textSize=12f
                setTypeface(ResourcesCompat.getFont(context, R.font.harmony_medium))
            }
            KKTagType.fill3.type -> {
                //tag_convention
                setCorner(SizeUtils.dp2px(context, 2f).toFloat())
                setSolid(ContextCompat.getColor(context, R.color.fill_3))
                setTextColor(ContextCompat.getColor(context, R.color.text_1))
                setPadding(
                    SizeUtils.dp2px(context, 4f),
                    SizeUtils.dp2px(context, 0f),
                    SizeUtils.dp2px(context, 4f),
                    SizeUtils.dp2px(context, 0f)
                )
                textSize=12f
                setTypeface(ResourcesCompat.getFont(context, R.font.harmony_regular))
            }
        }
        if(tagType==1){
            setTagState(tagState,tagStr.toString())
        }
    }

    fun setTagContent(agvalue: String? = "") {
        setText(agvalue)
    }

    fun setTagType(type:KKTagType){
        tagType = type.type
        initView()
    }

    fun setTagState(tagState: AuthState,stateStr:String) {
        setText(stateStr)
        when (tagState) {
            AuthState.UNAUTHRZED -> {
                setSolid(ContextCompat.getColor(context, R.color.card_bg_color_2))
                setDrawableTint(ContextCompat.getColor(context, R.color.text_color_2))
                setTextColor(ContextCompat.getColor(context, R.color.text_color_2))
            }
            AuthState.REVIEW -> {
                setSolid(ContextCompat.getColor(context, R.color.bg_dialog_wait_color))
                setDrawableTint(ContextCompat.getColor(context, R.color.certification_color))
                setTextColor(ContextCompat.getColor(context, R.color.certification_color))
            }
            AuthState.CERTIFIED -> {
                setSolid(ContextCompat.getColor(context, R.color.tag_color))
                setDrawableTint(ContextCompat.getColor(context, R.color.main_color))
                setTextColor(ContextCompat.getColor(context, R.color.main_color))
            }
            AuthState.NOT_THROUGH -> {
                setSolid(ContextCompat.getColor(context, R.color.main_red_15))
                setDrawableTint(ContextCompat.getColor(context, R.color.main_red))
                setTextColor(ContextCompat.getColor(context, R.color.main_red))
            }
        }
    }

    override fun setEnabled(enabled: Boolean) {
        super.setEnabled(enabled)
        when(tagType){
            7 -> {
                setTextColor(ContextCompat.getColor(context,
                    if(enabled) R.color.text_1 else R.color.text_2
                ))
            }
        }
    }


}
