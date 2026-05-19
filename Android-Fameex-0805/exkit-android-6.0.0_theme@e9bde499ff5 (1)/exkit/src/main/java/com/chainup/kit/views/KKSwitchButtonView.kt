package com.chainup.kit.views

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.RectF
import android.util.AttributeSet
import android.view.MotionEvent
import android.view.View
import androidx.core.content.ContextCompat
import com.example.chainup_kit.R

/**
 *Imitation iOS switch
 */
class SwitchButtonView(context: Context, attributeSet: AttributeSet): View(context,attributeSet) {
     var listener: OnKKSwitchListener? = null

    interface OnKKSwitchListener {
        fun onSwitch(b: Boolean)
    }


    //Background rounded rectangle drawing area
    private val rect = RectF()
    //Control width
    private var mWidth = 0f
    //Control height
    private var mHeight = 0f
    //Rounded rectangular radius
    private var rRectRadius = 0f
    //Distance between rounded rectangle and white circle
    private var rRRadiusMargin =  6f
    //Switch status
    private var isSwitchOn = false
    //Switch text
    private var switchStatus = ""
    //On Status - Background Color
    private var switchOnColor = ContextCompat.getColor(context,R.color.main_color)
    //Off Status - Background Color
    private var switchOffColor = ContextCompat.getColor(context,R.color.text_color_3)

    /**
     *Background brush
     */
    private var mPaint = Paint().apply {
        style = Paint.Style.FILL
        color = switchOffColor
        strokeCap = Paint.Cap.BUTT
        isAntiAlias = true
        isDither = true
    }

    init {
        val ta = context.obtainStyledAttributes(attributeSet,R.styleable.SwitchButtonView)
        ta.apply {
            switchOnColor = getColor(R.styleable.SwitchButtonView_switch_on_color,resources.getColor(R.color.main_color))
            switchOffColor = getColor(R.styleable.SwitchButtonView_switch_off_color,resources.getColor(R.color.text_color_3))
            isSwitchOn = getBoolean(R.styleable.SwitchButtonView_status,false)
//            switchStatus =  if(isSwitchOn) context.getString(R.string.main_color) else context.getString(R.string.text_color_3)
            recycle()
        }
    }

    override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
        super.onSizeChanged(w, h, oldw, oldh)
        //Control width
        mWidth = w.toFloat()
        //Control height
        mHeight = h.toFloat()
        rect.apply {
            left = 0f
            top = 0f
            right = mWidth
            bottom = mHeight
        }
        //Take half of the minimum values of width and height as the radius of the rounded rectangle
        rRectRadius = mWidth.coerceAtMost(mHeight) / 2
        //Calculate text position
//        calculateTextPos()
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        drawSwitch(canvas)
    }


    /**
     *Draw switch
     */
    private fun drawSwitch(canvas: Canvas) {
        if(isSwitchOn){
            canvas.apply {
                mPaint.color = switchOnColor
                drawRoundRect(rect, rRectRadius, rRectRadius, mPaint)
                mPaint.color = ContextCompat.getColor(context,R.color.white)
                drawCircle(mWidth - rRectRadius, rRectRadius, rRectRadius - rRRadiusMargin, mPaint)
            }
        }else {
            canvas.apply {
                mPaint.color = switchOffColor
                drawRoundRect(rect, rRectRadius, rRectRadius, mPaint)
                mPaint.color = ContextCompat.getColor(context,R.color.fill_3)
                drawCircle(rRectRadius, rRectRadius, rRectRadius - rRRadiusMargin, mPaint)
            }
        }
    }

    @SuppressLint("ClickableViewAccessibility")
    override fun onTouchEvent(event: MotionEvent): Boolean {
        when(event.action){
            MotionEvent.ACTION_UP ->{
                isSwitchOn = !isSwitchOn
//                updateSwitchText()
                listener?.onSwitch(isSwitchOn)
                invalidate()
            }
        }
        return true
    }

    /**
     *External interface setting switch status
     */
    fun setSwitchStatus(isOn:Boolean){
        isSwitchOn = isOn
        invalidate()
    }

    /**
     *External interface obtains the current switch status
     */
    fun getSwitchStatus():Boolean{
        return isSwitchOn
    }

    /**
     *Update switch status corresponding text
     */
//    private fun updateSwitchText(){
//        switchStatus =  if(isSwitchOn) context.getString(R.string.switch_on) else context.getString(R.string.switch_off)
//    }

}

