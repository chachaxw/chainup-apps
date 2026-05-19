package com.chainup.kit.views

import android.content.Context
import android.graphics.drawable.Drawable
import android.util.AttributeSet
import android.util.Log
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.widget.PopupWindow
import android.widget.RelativeLayout
import androidx.annotation.StyleRes
import com.chainup.kit.KKDialogUtils
import com.chainup.kit.bean.KKItemTabInfo
import com.chainup.kit.dimAmountValue
import com.chainup.kit.utils.PublicSizeUtil
import com.example.chainup_kit.R
import kotlinx.android.synthetic.main.public_popup_select.view.*

/**
 *Author from the @ property targetView dropdown
 *@ property currentPosition The currently selected position
 *@ property data data source
 *@ property listener event listener
 *Animate @ property animationStyle
 *Does @ property setTipVisible display tip @ attr kk_ Psk_ Show_ Tip_ Icon
 *@ description This control is only used for popWindow dropdown selection
 */
class KKPopupSelectKit @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : RelativeLayout(context, attrs, defStyleAttr), View.OnClickListener, KKDialogUtils.DialogOnSigningItemClickListener {

    private val TAG:String = this::class.java.simpleName
    //Show tip icon
    private var isShowTipIcon:Boolean
    private var textSize:Float? = null
    private var dimValue = dimAmountValue
    private var drawableSelectorBg:Drawable? = null
    private var selectorElevation:Float = 0f
    private var gravity:Int = Gravity.CENTER

    /**
     * Set width is auto fill ? ? ?
     * @attr kk_psk_show_tip_icon.
    * */
    private var mode = 0

    /**
     * popWindow position target
     * */
    var targetView:View

    /**
     *The currently selected item position
     * */
    var currentPosition: Int = 0
        set(value) {
            field = value
            data?.run {
                if(size > 0) initView()
            }
        }

    fun setTextSize(value:Float){
        textSize = value
        tv_trade_order_type.paint.textSize = textSize!!
    }

    fun setDrawableSelectorBg(drawable: Drawable){
        this.drawableSelectorBg = drawable
    }
    fun setSelectorGravity(gravity: Int){
        this.gravity = gravity
    }

    fun setDimValue(value:Float){
        this.dimValue = value
    }

    /**
     *Set PopWindow adapter data source
     * */
    var data:ArrayList<KKItemTabInfo>? = null
        set(value) {
            field = value
            data?.run {
                if(size > 0) initView()
            }
        }

    /**
     *Event listening for this control
     * */
    var listener:OnKKPopupSelectListener? = null
    private var _customClickListener:OnClickListener? = null

    fun setOnCustomClickListener(listener: OnClickListener){
        this._customClickListener = listener
    }

    @StyleRes
    var animationStyle:Int? = null

    var isEqualTargetViewWidth = false

    init {
        LayoutInflater.from(context).inflate(R.layout.public_popup_select, this, true)
        attrs.let {
            val typeArray = context.obtainStyledAttributes(it, R.styleable.KKPopupSelectKit)
            isShowTipIcon = typeArray.getBoolean(R.styleable.KKPopupSelectKit_kk_psk_show_tip_icon,false)
            textSize = typeArray.getDimension(R.styleable.KKPopupSelectKit_kk_psk_text_size,0.0f)
            dimValue = typeArray.getFloat(R.styleable.KKPopupSelectKit_kk_psk_dim_value, dimAmountValue)
            drawableSelectorBg = typeArray.getDrawable(R.styleable.KKPopupSelectKit_kk_psk_selector_drawable)
            selectorElevation = typeArray.getFloat(R.styleable.KKPopupSelectKit_kk_psk_selector_elevation,0f)
            isEqualTargetViewWidth = typeArray.getBoolean(R.styleable.KKPopupSelectKit_kk_psk_width_equal_targetView,false)
            typeArray.recycle()
        }
        initView()

        rl_pid.setOnClickListener(this)
        iv_tip.setOnClickListener(this)

        targetView = this

    }

    @Deprecated("this name is wrong,please replace setTextContent!", replaceWith = ReplaceWith("setTextContent(textString)"))
    fun setTextContext(textString:String) {
        tv_trade_order_type?.text = textString
        updateView()
    }
    //force set select popup text content
    fun setTextContent(textString:String) {
        tv_trade_order_type?.text = textString
        updateView()
    }

    fun initView() {
        if(textSize!=0.0f && textSize!=null){
            tv_trade_order_type.paint.textSize = textSize!!
        }
        data?.run {
            tv_trade_order_type?.text = get(currentPosition).name
        }
        setTipVisible(isShowTipIcon)
        updateView()
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec)
        mode = MeasureSpec.getMode(widthMeasureSpec)
//        Log.d(TAG,"当前测量模式>>>>"+(mode == MeasureSpec.UNSPECIFIED))
        updateView()
    }

    fun updateView(){
        var textWidth = 0
        if(data==null){
            textWidth = tv_trade_order_type?.let { it.paint.measureText(tv_trade_order_type.text.toString()).toInt() } ?: 0
        }else{
            data?.run {
                textWidth = tv_trade_order_type?.let { it.paint.measureText(get(currentPosition).name).toInt() } ?: 0
            }
        }


        rl_pid?.let {
            when(mode){
                MeasureSpec.EXACTLY -> {
                    val layoutParams = it.layoutParams as? LayoutParams
                    layoutParams?.width = measuredWidth
                    it.layoutParams = layoutParams
                }
                MeasureSpec.UNSPECIFIED -> {
                    val parentLayoutParams = layoutParams as? android.widget.LinearLayout.LayoutParams
                    if(parentLayoutParams!=null){
                        val layoutParams = it.layoutParams as? android.widget.RelativeLayout.LayoutParams
                        layoutParams?.width = parentLayoutParams.width
                        it.layoutParams = layoutParams
                    }
                }
                MeasureSpec.AT_MOST -> {
                    val layoutParams = it.layoutParams as? LayoutParams
                    layoutParams?.width = PublicSizeUtil.dp2px(context,(if(isShowTipIcon) 16.0f + 6.0f else 0f) + 8.0f + 6.0f) + textWidth
                    it.layoutParams = layoutParams
                }
            }
        }
    }

    //Set the visibility of the icon tip
    fun setTipVisible(isVisible:Boolean){
        isShowTipIcon = isVisible
        iv_tip.visibility = if(isVisible) View.VISIBLE else View.GONE
    }

    override fun onClick(v: View?) {
        v?.run {
            when(this.id){
                R.id.rl_pid -> {
                    if(_customClickListener!=null){
                        _customClickListener!!.onClick(v)
                        return@run
                    }
                    if(data==null) return@run
                    tv_tag.animate().setDuration(200).rotation(180f).start()
                    KKDialogUtils.createSelectPop(
                        context,currentPosition,data!!,
                        targetView,
                        this@KKPopupSelectKit,
                        object: KKDialogUtils.DialogOnSigningItemClickListener {
                            override fun clickItem(position: Int, text: String) {
                                listener?.onPopTipClick(position)
                            }

                        },
                        ams = animationStyle,
                        dimValue = dimValue,
                        drawableSelectorBg = drawableSelectorBg,
                        selectTextSize = if(textSize==0.0f) null else textSize,
                        elevation = selectorElevation,
                        gravity = gravity,
                        dismissListener = object : PopupWindow.OnDismissListener{
                            override fun onDismiss() {
                                tv_tag.animate().setDuration(200).rotation(0f).start()
                            }
                        },
                        dropDownSelectWidth = if(isEqualTargetViewWidth){
                            targetView.width
                        }else{
                            null
                        }
                    )
                }

                R.id.iv_tip -> {
                    listener?.onSelectTipClick()
                }

            }
        }

    }

    override fun clickItem(position: Int, text: String) {
        if(currentPosition != position){
            currentPosition = position
            listener?.onChangeSelect(position)
        }
    }

    interface OnKKPopupSelectListener {
        fun onChangeSelect(position: Int)
        fun onPopTipClick(position: Int)
        fun onSelectTipClick()
    }
}
