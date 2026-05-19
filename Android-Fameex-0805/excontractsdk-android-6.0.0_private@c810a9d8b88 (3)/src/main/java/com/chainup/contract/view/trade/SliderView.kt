package com.chainup.contract.view.trade

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.widget.ImageButton
import android.widget.RelativeLayout
import androidx.core.content.ContextCompat
import com.chainup.contract.R
import com.chainup.contract.utils.CpSizeUtils
import com.coorchice.library.SuperTextView
import com.zyyoona7.popup.EasyPopup
import com.zyyoona7.popup.XGravity
import com.zyyoona7.popup.YGravity
import org.jetbrains.anko.alignParentLeft
import org.jetbrains.anko.backgroundColor
import org.jetbrains.anko.centerVertically
import java.math.BigDecimal

/**
 *@ description Slideable view
 * @property setSliderValue (0-100:Int)
 * @property OnSliderValueChange OnSliderValueChange.toValue(rate:String(0-100),value:Int)
 **/
class SliderView @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null
) : RelativeLayout(context, attrs),View.OnTouchListener {
    private val TAG:String = this::class.java.simpleName
    //Progress inside
    private var mPgView: View? = null
    //Outside
    private var mParentPgView:View? = null
    //Sliding button
    private var mSliderBtn:ImageButton? = null

    private var mprogressContainer:RelativeLayout? =null

    //Floating view
    private var mFloatPopView:SuperTextView? = null

    private var rate:BigDecimal = BigDecimal(0)

    private var childBlockAry:Array<Int> = arrayOf(0,25,50,75,100)

    private var childBlockViewAry:ArrayList<View> = arrayListOf()

    var listener: OnSliderValueChange? = null

    //Maximum sliding distance
    private var maxValue:Int = 0

    //Current sliding distance
    private var currentValue:Int = 0

    //The x-axis distance from the current control to the screen
    private var parentX:Int = 0

    /**Style Properties*/
    //Width of slider
    private var blockWidth:Float = 0f
    //Height of slider
    private var blockHeight:Float = 0f
    //Drawable slider
    private var blockBackground:Int
    //Whether to display childBlock
    private var isShowChildBlock:Boolean
    //Whether to display floating prompt view
    private var isShowTopFloatView:Boolean
    //Color of selected progress
    private var selectedProgressColor:Int
    //Color for progress not selected
    private var unselectProgressColor:Int
    //ChildBlock size
    private var childBlockSize:Float
    //Selected childblock color
    private var selectChildBlockColor:Int
    //Unselected childBlock color
    private var unSelectChildBlockColor:Int
    /**Style Properties*/

    private var bubbleTip:EasyPopup? = null


    init {
        val obtainStyledAttributes = context.obtainStyledAttributes(attrs, R.styleable.SliderView)
        blockWidth = obtainStyledAttributes.getDimension(R.styleable.SliderView_block_width,CpSizeUtils.dp2px(12f).toFloat())
        blockHeight = obtainStyledAttributes.getDimension(R.styleable.SliderView_block_height,CpSizeUtils.dp2px(16f).toFloat())
        blockBackground = obtainStyledAttributes.getResourceId(R.styleable.SliderView_block_background,0)
        isShowChildBlock = obtainStyledAttributes.getBoolean(R.styleable.SliderView_show_child_block,true)
        isShowTopFloatView = obtainStyledAttributes.getBoolean(R.styleable.SliderView_show_top_float_view,true)
        selectedProgressColor = obtainStyledAttributes.getColor(R.styleable.SliderView_select_progress_color,ContextCompat.getColor(context,R.color.main_color))
        unselectProgressColor = obtainStyledAttributes.getColor(R.styleable.SliderView_unselect_progress_color,ContextCompat.getColor(context,R.color.card_bg_color_2))
        childBlockSize = obtainStyledAttributes.getDimension(R.styleable.SliderView_child_block_size,CpSizeUtils.dp2px(10f).toFloat())
        selectChildBlockColor = obtainStyledAttributes.getColor(R.styleable.SliderView_select_child_block_color,ContextCompat.getColor(context,R.color.main_color))
        unSelectChildBlockColor = obtainStyledAttributes.getColor(R.styleable.SliderView_unselect_child_block_color,ContextCompat.getColor(context,R.color.card_bg_color_2))

        obtainStyledAttributes.recycle()

        LayoutInflater.from(context).inflate(R.layout.slider_view_layout,this,true).also {
            mPgView = it.findViewById<View>(R.id.pgressView)
            mParentPgView = it.findViewById(R.id.pPgressView)
            mSliderBtn = it.findViewById(R.id.mSliderBtn)
            mprogressContainer = it.findViewById(R.id.progressContainer)
        }

        initConf()

        setViewClick()

    }

    private fun initView() {
        maxValue = width - blockWidth.toInt()
        val currentViewlocalAry = IntArray(2)

        getLocationInWindow(currentViewlocalAry)
        parentX = currentViewlocalAry[0]

        mFloatPopView?.visibility = View.GONE

        createPopupDialog()

        post{
            setChildBlockView()
        }

    }

    //Create a popup and obtain mFloatPopView
    fun createPopupDialog(){
        bubbleTip = EasyPopup.create()
                .setContentView(context, R.layout.popup_tip_bubble)
                .setFocusAndOutsideEnable(true)
                .setBackgroundDimEnable(true)
                .setWidth(ViewGroup.LayoutParams.WRAP_CONTENT)
                .setDimValue(0f)
                .setHeight(ViewGroup.LayoutParams.WRAP_CONTENT)
                .apply()

        mFloatPopView = bubbleTip?.findViewById(R.id.floatPopView)
    }

    override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
        super.onSizeChanged(w, h, oldw, oldh)
        initView()
        listener?.doMeasureLoaded()
    }

    private fun initConf() {
        mFloatPopView?.visibility = if(isShowTopFloatView){
            View.VISIBLE
        }else{
            View.GONE
        }
        //Configure slider Btn slider size
        val sliderBtnParams = mSliderBtn?.layoutParams
        sliderBtnParams?.width = blockWidth.toInt()
        sliderBtnParams?.height = blockHeight.toInt()
        mSliderBtn?.layoutParams = sliderBtnParams
        if(blockBackground!=0){//Set slider background image
            mSliderBtn?.background = ContextCompat.getDrawable(context,blockBackground)
        }


        mPgView?.setBackgroundColor(selectedProgressColor)
        mParentPgView?.setBackgroundColor(unselectProgressColor)

        setSliderValue(0)
    }

    //Call this method externally to set childBlock
    fun setConfChildBlock(ary:Array<Int>){
        childBlockAry = ary
        setChildBlockView()
    }

    //0-100
    fun setSliderValue(value:Int){
        currentValue = ((value/100f) * maxValue).toInt()
        doSliderHandler()
    }

    private fun setChildBlockView(){
        if(!isShowChildBlock) return
        //If there is a view in the list, delete it from the layout and clear it for external calls to set the childBlock
        if(childBlockViewAry.size>0){
            for(itemView in childBlockViewAry){
                mprogressContainer?.removeView(itemView)
            }
        }
        childBlockViewAry.clear()

        //--put dot view---/
        if(childBlockAry.size>0){
            for(value in childBlockAry){
                val view = View(context)
                val params = RelativeLayout.LayoutParams(childBlockSize.toInt(),childBlockSize.toInt())
                params.alignWithParent = true
                params.centerVertically()
                params.alignParentLeft()

                //Gap difference filling gap
                val diffVal:Int = if(value==100){
                    (blockWidth-childBlockSize).toInt()
                }else{
                    0
                }
                params.leftMargin = (((value/100f) * maxValue) + diffVal).toInt()
                view.backgroundColor = unSelectChildBlockColor
                view.layoutParams = params
                view.visibility = View.VISIBLE
                //ChildBlock click callback
                view.setOnClickListener {
                    listener?.childBlockClick(it,value,childBlockAry.indexOf(value))
                }
                childBlockViewAry.add(view)
                mprogressContainer?.addView(view)
            }
        }


    }

    private fun setViewClick() {
        mSliderBtn?.setOnTouchListener(this)
    }

    override fun onTouch(p0: View?, p1: MotionEvent?): Boolean {
        when(p1?.action){

            MotionEvent.ACTION_DOWN -> {
                parent.requestDisallowInterceptTouchEvent(true)
                if(isShowTopFloatView){
                    bubbleTip?.showAtAnchorView(mSliderBtn!!, YGravity.ALIGN_TOP, XGravity.CENTER, 0, -(blockHeight.toInt()+CpSizeUtils.dp2px(10f)))
                }
            }
            MotionEvent.ACTION_MOVE -> {
                val cx = p1.rawX
                cx?.let {
                    //Set Current Value
                    currentValue = (it - parentX).toInt()
                    if(currentValue > maxValue) currentValue = maxValue
                    if(currentValue <= 0) currentValue = 0
                    doSliderHandler()

                    listener?.toValue(rate.toPlainString(),currentValue)
                }
            }
            MotionEvent.ACTION_UP -> {
                parent.requestDisallowInterceptTouchEvent(false)
                if(isShowTopFloatView){
                    bubbleTip?.dismiss()
                }
                listener?.toUp(rate.toPlainString())
            }
        }

        return true
    }

    //Internal change layout method
    private fun doSliderHandler(){
        //Set the margin left distance of the slider
        val params = mSliderBtn?.layoutParams as LayoutParams
        params.leftMargin = currentValue
        mSliderBtn?.layoutParams = params

        setProgressViewWidth()

        setFloatViewValue()

        checkChildBlockView()
    }

    private fun checkChildBlockView() {
        if(!isShowChildBlock) return
        if(childBlockViewAry.size<=0) return
        for(obj in childBlockAry.withIndex()){

            val value = (obj.value/100f) * maxValue
            if(currentValue >= value){
                //You can change color after passing by
                childBlockViewAry[obj.index].backgroundColor = selectChildBlockColor
            }else{
                childBlockViewAry[obj.index].backgroundColor = unSelectChildBlockColor
            }
        }
    }

    //Set floating view display val
    private fun setFloatViewValue() {
        if(currentValue!=0){
            rate = (currentValue.toFloat() / maxValue.toFloat())
                .toBigDecimal()
                .setScale(2,BigDecimal.ROUND_HALF_UP)
                .multiply(BigDecimal(100))
                .setScale(0,BigDecimal.ROUND_HALF_UP)
        }else{
            rate = BigDecimal(0)
        }

        if(!isShowTopFloatView) return
        mFloatPopView?.text = "${rate.toPlainString()}%"
    }

    //Set progress changes for the progress view
    private fun setProgressViewWidth(){
        mPgView?.let{
            val layoutParams = it.layoutParams as RelativeLayout.LayoutParams
            layoutParams.width = currentValue
            it.layoutParams = layoutParams
        }
    }



    //Sliding interface
    public interface OnSliderValueChange{
        fun toValue(rate:String,value:Int)
        //Finger lift
        fun toUp(rate:String)
        //Click on the unnecessary implementation of childBlock
        fun childBlockClick(view:View,rate:Int,position:Int){

        }
        //The width height can be obtained correctly after measurement
        fun doMeasureLoaded(){

        }
    }
}
