package com.chainup.contract.view.trade

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.widget.RelativeLayout
import com.chainup.contract.R
import com.chainup.contract.utils.ChainUpLogUtil
import com.chainup.contract.view.CpNewDialogUtils
import com.yjkj.chainup.manager.CpLanguageUtil
import kotlinx.android.synthetic.main.cp_item_price_type_button.view.*

/**
 * @Author lianshangljl
 * @Date 2019/3/7-2:14 PM
 * @Email buptjinlong@163.com
 *@ description Unit price limit
 */
class CpPriceTypeButton @JvmOverloads constructor(
        context: Context,
        attrs: AttributeSet? = null,
        defStyleAttr: Int = 0
) : RelativeLayout(context, attrs, defStyleAttr) {

    //Show tip icon
    private var isShowTipIcon:Boolean

    private var mTipDialogContent:TipDialogContent? = null

    var textContent = ""
        set(value) {
            field = value
            tv_trade_order_type?.text = value
            ChainUpLogUtil.e("LogUtils","textContent ${tv_trade_order_type}")
        }

    init {

        attrs.let {
            val typeArray = context.obtainStyledAttributes(it, R.styleable.CpPriceTypeButton)
            isShowTipIcon = typeArray.getBoolean(R.styleable.CpPriceTypeButton_show_tip_icon,false)
            typeArray.recycle()
        }
        initView(context)
    }

    fun initView(context: Context) {
        LayoutInflater.from(context).inflate(R.layout.cp_item_price_type_button, this, true)
        tv_trade_order_type.text= CpLanguageUtil.getString(context, "cp_overview_text3")
        setTipIconVisible(isShowTipIcon)
    }

    fun setContent(content: String) {
        tv_trade_order_type?.text = content
    }

    fun stratAnim() {
        tv_tag.animate().setDuration(200).rotation(180f).start()
    }

    fun stopAnim() {
        tv_tag.animate().setDuration(200).rotation(0f).start()
    }

    //Set the visibility of the icon tip
    fun setTipIconVisible(isVisible:Boolean){
        ic_tip.visibility = if(isVisible) View.VISIBLE else View.GONE
    }

    //Set Content
    fun setTipDialogContent(data:TipDialogContent){
        mTipDialogContent = data
    }

    fun showTipDialog(){
        if(mTipDialogContent!= null){
            CpNewDialogUtils.showDialogNew(
                context,
                content = mTipDialogContent?.content!!,
                true,
                title = mTipDialogContent?.title!!,
                cancelTitle = CpLanguageUtil.getString(context, "cp_extra_text28"),
                listener = null
            )
        }else{
            throw Exception("Not method setTipDialogContent!")
        }
    }


    data class TipDialogContent(val title:String,val content:String)
}
