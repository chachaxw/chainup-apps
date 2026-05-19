package com.chainup.kit.views

import android.content.Context
import android.graphics.drawable.Drawable
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.util.AttributeSet
import android.view.LayoutInflater
import android.widget.FrameLayout
import androidx.annotation.ColorInt
import androidx.core.content.ContextCompat
import com.chainup.kit.utils.PublicSizeUtil
import com.example.chainup_kit.R
import com.flyco.tablayout.CommonTabLayout
import com.flyco.tablayout.listener.CustomTabEntity
import com.flyco.tablayout.listener.OnTabSelectListener
import org.jetbrains.anko.padding

const val outLinePadding = 2.0f
class KKCommonTabKit @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null
) : FrameLayout(context, attrs),OnTabSelectListener {

    private var tabView:CommonTabLayout? = null
    private var isInitLoad = true
    var listener:OnKKTabSelectListener? = null


    init {
        LayoutInflater.from(context).inflate(R.layout.public_block_tab_layout,this,true)
        initView()
    }

    private fun initView() {
        tabView = findViewById(R.id.ctl_tab)

        padding = PublicSizeUtil.dp2px(context,outLinePadding)
        setStyle()

        tabView?.setOnTabSelectListener(this)


    }

    override fun onWindowFocusChanged(hasWindowFocus: Boolean) {
        super.onWindowFocusChanged(hasWindowFocus)
        if(hasWindowFocus&&isInitLoad) {
            tabView?.run {
                indicatorHeight = PublicSizeUtil.px2dp(context,this@KKCommonTabKit.measuredHeight.toFloat()) - outLinePadding * 2
                setIndicatorMargin(0f,0f,0f,0f)
            }
            isInitLoad = false
        }
    }

    interface OnKKTabSelectListener{
        fun onTabSelect(position: Int)
    }

    override fun onTabSelect(position: Int) {
        listener?.onTabSelect(position)
    }

    override fun onTabReselect(position: Int) {

    }

    fun  setTabData(tabEntitys :ArrayList<CustomTabEntity>) {
        tabView?.setTabData(tabEntitys)
    }

    fun setTabs(arrays: Array<String>) {

        tabView?.run {
            val datas = ArrayList<CustomTabEntity>()
            for(item in arrays){
                datas.add(object : CustomTabEntity {
                    override fun getTabTitle(): String {
                        return item
                    }

                    override fun getTabSelectedIcon(): Int {
                        return 0
                    }

                    override fun getTabUnselectedIcon(): Int {
                        return 0
                    }
                })
            }

            setTabData(datas)

            for (i in 0 until tabCount) if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                getTitleView(i).typeface = context.resources.getFont(R.font.dinpro_medium)
            }
        }

    }

    private fun createBorderDrawable(@ColorInt color:Int):Drawable {
        val drawable = GradientDrawable()
        drawable.cornerRadius = PublicSizeUtil.dp2px(context,4.0f).toFloat()
        drawable.shape = GradientDrawable.RECTANGLE
        drawable.setStroke(1,color)
        return drawable
    }

    private fun createBgDrawable(@ColorInt color:Int):Drawable {
        val drawable = GradientDrawable()
        drawable.cornerRadius = PublicSizeUtil.dp2px(context,4.0f).toFloat()
        drawable.shape = GradientDrawable.RECTANGLE
        drawable.setColor(color)
        return drawable
    }

    fun setOutLineColor(@ColorInt color:Int){
        background = createBorderDrawable(color)
    }

    fun setBlockColor(@ColorInt color:Int){
        tabView?.indicatorColor = color
    }

    fun setPosition(position: Int){
        tabView?.currentTab = position
    }

    fun setStyle(style:Int = 0){
        when(style){
            //default
            0 -> {
                background = createBorderDrawable(ContextCompat.getColor(context,R.color.line_color))
            }

            1 -> {
                background = createBgDrawable(ContextCompat.getColor(context,R.color.main_bg_color))
            }
        }
    }

}
