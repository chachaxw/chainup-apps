package com.chainup.kit.views

import android.content.Context
import android.graphics.Rect
import android.text.InputType
import android.util.AttributeSet
import android.util.Log
import android.view.Gravity
import android.view.MotionEvent
import androidx.core.content.ContextCompat
import com.chainup.kit.utils.BigDecimalUtils
import com.chainup.kit.utils.InputLimitTextWatcher
import com.chainup.kit.utils.PublicSizeUtil
import com.chainup.kit.utils.SoftKeyboardUtil
import com.chainup.kit.utils.StringUtil
import com.chainup.kit.utils.numberFilter
import com.chainup.kit.views.base.BaseEditTextKit
import com.example.chainup_kit.R
import io.reactivex.disposables.Disposable
import java.math.BigDecimal
import java.util.concurrent.TimeUnit
import io.reactivex.Observable
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import org.jetbrains.anko.doAsync
import org.jetbrains.anko.uiThread

/**
 * EditText with increase/decrease control
 * @property setCtrlGone set increase/decrease control is visible???
 * @property step Stepping
 * @property minValue min
 * @property setPrecision set precision Note:By numberFilter can set any EditText precision
 * @property isLever is use lever switch? def is false. this is public attribute
 * */
open class KKEditNumberKit @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null
) : BaseEditTextKit(context, attrs) {
    private val TAG:String = this::class.java.simpleName

    var mEditNumberViewCase:IEditNumberViewCase? = null
    var step:String = "1.0"
    var minValue = "0"
    // is lever?
    var isLever = false

    /**
     *  Whether the left and right can be clicked
     * */
    private var iconClickable:Boolean = true

    /**
     *  Whether to press or not
     * */
    private var isLongPressing = false

    /**
     * Long press observer: Disposable Object
     * */
    private var longDisposable: Disposable? = null

    /**
     * Trigger speed after long press
     * */
    private val speedTime = 30L

    /**
     * Hold down the trigger time
     * */
    private val longPressActionTime = 1000L

    /**
     * Whether to enable the long press
     * */
    var isLongPressClickable = true

    init {
        initView()
    }

    private fun initView() {
        gravity = Gravity.CENTER
        inputType = InputType.TYPE_CLASS_NUMBER or InputType.TYPE_NUMBER_FLAG_DECIMAL
        searchIconVisible = false
        clearIconVisible = false
        isNotNeedIcon = true
        setCtrlGone()
    }
    //0 decrease 1 increase
    private fun changeValue(type:Int = 0){
        if(isFocused){
            clearFocus()
            SoftKeyboardUtil.hideSoftKeyboard(this)
        }

        var textValue = text.toString().trim()
        if("".equals(textValue)) textValue = "0"
        if(isLever) textValue = textValue.replace("X","")

        if(textValue.indexOf("%")!=-1){
            textValue = textValue.substring(0,textValue.length-1)
            Log.d(TAG,"截取后value:"+textValue)
            var newVal = if(type==0){
                textValue.toInt() - 1
            }else{
                textValue.toInt() + 1
            }
            if(newVal<0) newVal = 0
            setText("$newVal%")

        }else if(StringUtil.isNumeric(textValue)){
            var newVal = if(type==0){
                BigDecimalUtils.sub(textValue,step)
            }else{
                BigDecimalUtils.add(textValue,step)
            }
            if(newVal.compareTo(BigDecimal(minValue))==-1) newVal = BigDecimal(minValue)

            val showText = if(isLever) {
                BigDecimalUtils.subZeroAndDot(newVal.setScale(getPrecisionByTag()).toPlainString())
            }else{
                newVal.setScale(getPrecisionByTag()).toPlainString()
            }
            setText(showText + if(isLever) "X" else "")

        }else{
            setText("")
        }
    }


    interface IEditNumberViewCase{
        fun intercept():Boolean{
            return false
        }
    }


    //Sets whether the controller is displayed
    fun setCtrlGone(isGone:Boolean = false){
        if(isGone){
            iconClickable = false
            setCompoundDrawablesWithIntrinsicBounds(null,null,null,null)
        }else{
            iconClickable = true
            val icLeft = ContextCompat.getDrawable(context,R.drawable.ic_baseline_remove_24)
            val icRight = ContextCompat.getDrawable(context,R.drawable.ic_baseline_add_24)
            setCompoundDrawablesWithIntrinsicBounds(icLeft,null,icRight,null)
        }

    }

    private fun isSubClickBtn(x:Int,y:Int):Boolean {
        val lRect = Rect(0,0, PublicSizeUtil.dp2px(context,35.0f),measuredHeight)
        return lRect.contains(x,y)
    }
    private fun isAddClickBtn(x:Int,y:Int):Boolean {
        val rRect = Rect(measuredWidth - PublicSizeUtil.dp2px(context,35.0f),0, measuredWidth,measuredHeight)
        return rRect.contains(x,y)
    }


    @Synchronized
    private fun longClick(flag:Int){
        doAsync {
            while (isLongPressing){
                Thread.sleep(speedTime)
                uiThread {
                    changeValue(flag)
                }
            }
        }
    }

    private fun setLongPressStatus(flag:Int){
        if(!isLongPressClickable) return
        resetLongPressStatus()
        longDisposable = Observable.timer(longPressActionTime,TimeUnit.MILLISECONDS)
            .observeOn(AndroidSchedulers.mainThread())
            .subscribeOn(Schedulers.io())
            .subscribe {
                isLongPressing = true
                longClick(flag)
            }
    }

    private fun resetLongPressStatus(){
        isLongPressing = false
        longDisposable?.run { if(!isDisposed) dispose() }
    }


    override fun dispatchTouchEvent(event: MotionEvent?): Boolean {
        Log.d(TAG,"dispatchTouchEvent x->${event?.x} y->${event?.y}")
        event?.run {
            when(event.action){
                MotionEvent.ACTION_DOWN -> {
                    if(isSubClickBtn(x.toInt(),y.toInt())){
                        Log.d(TAG,"dispatchTouchEvent isSubClickBtn")
                        if(!iconClickable) {
                            requestFocus()
                            return@dispatchTouchEvent super.dispatchTouchEvent(event)
                        }
                        mEditNumberViewCase?.run {
                            if(intercept()){
                                return@dispatchTouchEvent super.dispatchTouchEvent(event)
                            }
                        }
                        changeValue(0)
                        if(!isLongPressing) setLongPressStatus(0)
                        return@dispatchTouchEvent true
                    }else if(isAddClickBtn(x.toInt(),y.toInt())){
                        Log.d(TAG,"dispatchTouchEvent isAddClickBtn")
                        if(!iconClickable) {
                            requestFocus()
                            return@dispatchTouchEvent super.dispatchTouchEvent(event)
                        }
                        mEditNumberViewCase?.run {
                            if(intercept()){
                                return@dispatchTouchEvent super.dispatchTouchEvent(event)
                            }
                        }
                        changeValue(1)
                        if(!isLongPressing) setLongPressStatus(1)
                        return@dispatchTouchEvent true
                    }
                }
                MotionEvent.ACTION_MOVE -> { }
                MotionEvent.ACTION_UP,MotionEvent.ACTION_CANCEL -> resetLongPressStatus()
            }

            Log.d(TAG,"dispatchTouchEvent editText click")
            return@dispatchTouchEvent super.dispatchTouchEvent(event)
        }
        return super.dispatchTouchEvent(event)
    }

    fun setPrecision(precision:Int) {
        this.numberFilter(decimal = precision)
    }

    private fun getPrecisionByTag():Int {
        if(tag!=null && tag is InputLimitTextWatcher){
            val watcher = tag as InputLimitTextWatcher
            return watcher.decimal
        }
        return 0
    }
}
