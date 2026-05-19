package com.yjkj.chainup.new_version.view

import android.content.Context
import android.graphics.Rect
import android.text.method.ReplacementTransformationMethod
import android.util.AttributeSet
import android.view.MotionEvent
import androidx.appcompat.widget.AppCompatEditText
import com.yjkj.chainup.R
import com.yjkj.chainup.util.ViewUtils


/**
 * @Author: Bertking
 * @Date 2023/3/6-2:39 PM
 *@description: Custom EditText
 */

class CustomizeEditText @JvmOverloads constructor(context: Context,
                                                  attrs: AttributeSet? = null,
                                                  defStyleAttr: Int = 0
) : AppCompatEditText(context, attrs, defStyleAttr) {

    var textContent = ""

    /**
     *Just for compatibility with some of the previous code
     *TODO optimization
     */
    var isShowLine = false
        set(value) {
            field = value
            if (value) {
                setBackgroundResource(R.drawable.et_underline_selector)
            }
        }
    var isErrorLine=false
        set(value) {
            field = value
            if (value) {
                setBackgroundResource(R.drawable.et_underline_focused_error)
            }
        }

    override fun onTextChanged(text: CharSequence?, start: Int, lengthBefore: Int, lengthAfter: Int) {
        super.onTextChanged(text, start, lengthBefore, lengthAfter)
        textContent = text.toString()
        setClearIconVisible(hasFocus() && text?.isNotEmpty() == true)
        if (isShowLine) {
            setBackgroundResource(R.drawable.et_underline_selector)
        }
    }

    var focusedListener = false
    override fun onFocusChanged(focused: Boolean, direction: Int, previouslyFocusedRect: Rect?) {
        super.onFocusChanged(focused, direction, previouslyFocusedRect)
        focusedListener = focused
        if (focusedListener && textContent.isNotEmpty()) {
            if (isShowLine) {
                setBackgroundResource(R.drawable.et_underline_selector)
            }
            setClearIconVisible(true)
        } else {
            if (isShowLine) {
                setBackgroundResource(R.drawable.et_underline_selector)
            }
            setClearIconVisible(false)
        }
    }

    fun setMaxLeng(len:Int){
        ViewUtils.setEditTextLength(this,len);
    }

    /**
     *Clear event
     */
    override fun onTouchEvent(event: MotionEvent?): Boolean {
        if (event?.action == MotionEvent.ACTION_UP) {
            val isClean = event.x > width - totalPaddingRight && event.x < width - paddingRight
            if (isClean) {
                setText("")
            }
        }
        return super.onTouchEvent(event)
    }


    private fun setClearIconVisible(visible: Boolean) {
        if (visible && focusedListener) {
            val clearImg = context.getDrawable(R.mipmap.public_deleteall)
            setCompoundDrawablesWithIntrinsicBounds(null, null, clearImg, null)
        } else {
            setCompoundDrawablesWithIntrinsicBounds(null, null, null, null)
        }
    }


}

class TransInformation : ReplacementTransformationMethod() {
    /**
     *Minuscule originally entered
     */
    override fun getOriginal(): CharArray {
        return charArrayOf('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z')
    }

    /**
     *Replace with uppercase letters
     */
    override fun getReplacement(): CharArray {
        return charArrayOf('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z')
    }
}
