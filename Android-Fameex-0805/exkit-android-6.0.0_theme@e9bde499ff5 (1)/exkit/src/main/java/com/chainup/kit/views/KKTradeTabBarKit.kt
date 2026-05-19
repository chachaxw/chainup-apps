package com.chainup.kit.views

import android.content.Context
import android.content.res.ColorStateList
import android.graphics.Color
import android.graphics.drawable.Drawable
import android.graphics.drawable.StateListDrawable
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.widget.LinearLayout
import androidx.annotation.ColorInt
import androidx.core.content.ContextCompat
import com.example.chainup_kit.R
import kotlinx.android.synthetic.main.public_trade_tab_bar_layout.view.*

class KKTradeTabBarKit @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null
) : LinearLayout(context, attrs), View.OnClickListener {

    var cSelectPosition:Int = 0
        set(value) {
            field = value
            selectTabByPosition(value)
        }

    var tvTabText1:String = "Open"
        set(value) {
            field = value
            tv_tab1?.text = value
        }

    var tvTabText2:String = "Close"
        set(value) {
            field = value
            tv_tab2?.text = value
        }
    @ColorInt
    private var tabSelectColor1:Int? = null
    @ColorInt
    private var tabSelectColor2:Int? = null

    @ColorInt
    private var tabUnSelectColor:Int? = null

    var listener:OnKKTradeTabChangeListener? = null

    init {
        initAttr(attrs)
        LayoutInflater.from(context).inflate(R.layout.public_trade_tab_bar_layout,this,true)
        initView()
        setViewClick()
    }

    private fun initView() {

        with(tv_tab1){
            text = tvTabText1
            setTextColor(createTextColor())
            tabSelectColor1?.let {
                background = createTabDrawableWithSelector(it,true)
            }
            isSelected = cSelectPosition==0
        }
        with(tv_tab2){
            text = tvTabText2
            setTextColor(createTextColor())
            tabSelectColor2?.let {
                background = createTabDrawableWithSelector(it,false)
            }
            isSelected = cSelectPosition==1
        }
    }

    private fun setViewClick(){
        tv_tab1.setOnClickListener(this)
        tv_tab2.setOnClickListener(this)
    }

    private fun initAttr(attrs: AttributeSet?) {
        val typedArray = context.obtainStyledAttributes(attrs,R.styleable.KKTradeTabBarKit)
        tvTabText1 = typedArray.getString(R.styleable.KKTradeTabBarKit_kk_tradeTabBar_text1) ?: "Open"
        tvTabText2 = typedArray.getString(R.styleable.KKTradeTabBarKit_kk_tradeTabBar_text2) ?: "Close"
        tabSelectColor1 = typedArray.getColor(R.styleable.KKTradeTabBarKit_kk_tradeTabBar_selectColor1,ContextCompat.getColor(context,R.color.main_color))
        tabSelectColor2 = typedArray.getColor(R.styleable.KKTradeTabBarKit_kk_tradeTabBar_selectColor2,ContextCompat.getColor(context,R.color.main_color))
        tabUnSelectColor = typedArray.getColor(R.styleable.KKTradeTabBarKit_kk_tradeTabBar_unSelectColor,ContextCompat.getColor(context,R.color.special_2))
        typedArray.recycle()
    }

    private fun createTabDrawableWithSelector(@ColorInt color:Int, isFirst:Boolean): Drawable {
        val stateListDrawable = StateListDrawable()

        val selectDrawable:Drawable? = if(isFirst) {
            ContextCompat.getDrawable(context,R.drawable.ic_contract_openpositions_hover)
        }else{
            ContextCompat.getDrawable(context,R.drawable.ic_contract_unwind_hover)
        }
        selectDrawable?.setTint(color)


        val unSelectDrawable:Drawable? = if(isFirst) {
            ContextCompat.getDrawable(context,R.drawable.ic_contract_openpositions)
        }else{
            ContextCompat.getDrawable(context,R.drawable.ic_contract_unwind)
        }
        unSelectDrawable?.setTint(tabUnSelectColor ?: ContextCompat.getColor(context,R.color.special_2))

        stateListDrawable.addState(intArrayOf(android.R.attr.state_selected),selectDrawable)
        stateListDrawable.addState(intArrayOf(),unSelectDrawable)

        return stateListDrawable
    }


    //set text color
    private fun createTextColor():ColorStateList {
        return ColorStateList(arrayOf(
                intArrayOf(android.R.attr.state_selected),
                intArrayOf()
            ), intArrayOf(
                ContextCompat.getColor(context,R.color.text_4),
                ContextCompat.getColor(context,R.color.text_color_2)
            )
        )
    }

    override fun onClick(v: View?) {
        v?.run {
            when(id){
                R.id.tv_tab1 -> {
                    if(cSelectPosition==0) return@run
                    cSelectPosition = 0
                }
                R.id.tv_tab2 -> {
                    if(cSelectPosition==1) return@run
                    cSelectPosition = 1
                }
            }
        }

    }

    private fun selectTabByPosition(position: Int){
        when(position){
            0 -> {
                tv_tab1.isSelected = true
                tv_tab2.isSelected = false
            }
            1 -> {
                tv_tab1.isSelected = false
                tv_tab2.isSelected = true
            }
        }
        listener?.onChange(cSelectPosition)
    }

    fun setTabSelectColor(@ColorInt select1:Int,@ColorInt select2:Int){
        tabSelectColor1 = select1
        tabSelectColor2 = select2
        initView()
    }

    fun setTabUnSelectColor(@ColorInt select2:Int){
        tabUnSelectColor = select2
        initView()
    }

    fun setSelectPosition(position: Int){
        cSelectPosition = position
    }
    interface OnKKTradeTabChangeListener {
        fun onChange(position:Int)
    }
}
