package com.yjkj.chainup.wedegit

import android.content.Context
import android.graphics.Rect
import android.graphics.drawable.Drawable
import androidx.core.content.ContextCompat
import android.util.AttributeSet
import android.view.MotionEvent
import android.widget.EditText
import com.yjkj.chainup.R

//Input box with clear function
class ClearEditText : EditText {

    private lateinit var clearImg: Drawable
    var searchImg: Drawable? = null


    constructor(context: Context?) : super(context) {
        init()
    }


    constructor(context: Context?, attrs: AttributeSet?) : super(context, attrs) {
        init()
    }

    constructor(context: Context?, attrs: AttributeSet?, defStyleAttr: Int)
            : super(context, attrs, defStyleAttr) {
        init()
    }


    override fun onTextChanged(text: CharSequence?, start: Int, lengthBefore: Int, lengthAfter: Int) {
        super.onTextChanged(text, start, lengthBefore, lengthAfter)
        setClearIconVisible(hasFocus() && text!!.length > 0)
    }


    private fun init() {
        clearImg = context.getDrawable(R.mipmap.public_deleteall)!!
        searchImg = context.getDrawable(R.mipmap.public_search)!!
    }

    var searchBoolean: Boolean = false

    fun setSearch() {
        setCompoundDrawablesWithIntrinsicBounds(searchImg, null, null, null)
        searchBoolean = true
    }

    //Set listening events for images
    override fun onTouchEvent(event: MotionEvent?): Boolean {
        if (event?.action == MotionEvent.ACTION_UP) {
//            val eventX = event.rawX
//            val eventY = event.rawY
//            val rect = Rect()
////Get visible range
//            getGlobalVisibleRect(rect)
//            rect.left = rect.right - 100 - paddingEnd
//            rect.right = rect.right - paddingEnd
//            if (rect.contains(eventX.toInt(), eventY.toInt())) {
//                setText("")
//            }
            val isClean = event.x > width - totalPaddingRight && event.x < width - paddingRight
            if (isClean) {
                setText("")
            }
        }
        return super.onTouchEvent(event)
    }

    override fun onFocusChanged(focused: Boolean, direction: Int, previouslyFocusedRect: Rect?) {
        super.onFocusChanged(focused, direction, previouslyFocusedRect)
        setClearIconVisible(focused && length() > 0)
    }


    fun setClearIconVisible(visible: Boolean) {
        if (visible) {
            setCompoundDrawablesWithIntrinsicBounds(null, null, clearImg, null)
        } else {
            if (searchBoolean) {
                setCompoundDrawablesWithIntrinsicBounds(searchImg, null, null, null)
            } else {
                setCompoundDrawablesWithIntrinsicBounds(null, null, null, null)
            }
        }
    }


}




