package com.chainup.contract.view.trade

import android.content.Context
import android.graphics.Rect
import android.util.AttributeSet
import android.util.Log
import android.view.MotionEvent
import androidx.appcompat.widget.AppCompatEditText
import com.chainup.contract.R
import com.chainup.contract.utils.CpBigDecimalUtils
import com.chainup.contract.utils.CpDisplayUtils
import com.chainup.contract.utils.CpSoftKeyboardUtil
import com.chainup.contract.utils.CpStringUtil
import com.chainup.contract.view.CpContractInputTextWatcher
import io.reactivex.Observable
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import io.reactivex.schedulers.Schedulers
import org.jetbrains.anko.doAsync
import org.jetbrains.anko.uiThread
import java.math.BigDecimal
import java.util.*
import java.util.concurrent.TimeUnit

/**
 * EditText with increase/decrease control
 * @property setCtrlGone set increase/decrease control is visible???
 * @property step Stepping
 * @property minValue min
 * */
class EditNumberView @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null
) : AppCompatEditText(context, attrs) {
    private val TAG:String = this::class.java.simpleName
    var listener:IEditNumberViewListener? = null
    var mEditNumberViewCase:IEditNumberViewCase? = null
    var step:String = "1.0"
    var minValue = "0"

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
    private var longDisposable:Disposable? = null

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
        setCtrlGone()
    }
    //0 decrease 1 increase
    private fun changeValue(type:Int = 0){
        if(isFocused){
            clearFocus()
            CpSoftKeyboardUtil.hideSoftKeyboard(this)
        }

        var textValue = text.toString().trim()
        if("".equals(textValue)){
            if(type==0) {
                textValue = "0"
                setText(textValue)
                return
            }
            if(type==1) textValue = "0"
        }
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
            listener?.toValue(newVal)
        }else if(CpStringUtil.isNumeric(textValue)){
            var newVal = if(type==0){
                CpBigDecimalUtils.sub(textValue,step)
            }else{
                CpBigDecimalUtils.add(textValue,step)
            }
            if(newVal.compareTo(BigDecimal.ZERO)==-1||newVal.compareTo(BigDecimal.ZERO)==0) newVal = BigDecimal(minValue)
            setText(newVal.toPlainString())
            listener?.toValue(newVal.toFloat())
        }else{
            setText("")
        }
    }


    interface IEditNumberViewListener{
        fun toValue(value:Int)
        fun toValue(value:Float)
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
            val icLeft = resources.getDrawable(R.drawable.ic_baseline_remove_24)
            val icRight = resources.getDrawable(R.drawable.ic_baseline_add_24)
            setCompoundDrawablesWithIntrinsicBounds(icLeft,null,icRight,null)
        }

    }

    private fun isSubClickBtn(x:Int,y:Int):Boolean {
        val lRect = Rect(0,0, CpDisplayUtils.dip2px(context,35.0f),measuredHeight)
        return lRect.contains(x,y)
    }
    private fun isAddClickBtn(x:Int,y:Int):Boolean {
        val rRect = Rect(measuredWidth - CpDisplayUtils.dip2px(context,35.0f),0, measuredWidth,measuredHeight)
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

    //Obtain the precision through the tag
    private fun getPrecisionByTag():Int {
        if(tag!=null && tag is CpContractInputTextWatcher){
            val watcher = tag as CpContractInputTextWatcher
            return watcher.decimal
        }

        return 1

    }

    override fun setText(text: CharSequence?, type: BufferType?) {
        val precision = getPrecisionByTag()
        if(text is String){
            val content = text.trim()
            if("".equals(content)) {
                super.setText(content, type)
                return
            }
            if(CpStringUtil.isNumeric(content)){
                val newText = BigDecimal(content).setScale(precision).toPlainString()
                super.setText(newText, type)
                return
            }
        }
        super.setText(text, type)

    }
}
