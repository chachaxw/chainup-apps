package com.chainup.contract.view.material
import android.content.Context
import android.graphics.Rect
import android.os.Build
import android.util.AttributeSet
import android.view.Gravity
import android.view.MotionEvent
import androidx.appcompat.widget.AppCompatEditText
import com.chainup.contract.R


/**
 * @Author: Bertking
 * @Date：2019/3/6-2:39 PM
 *@ Description: Customize EditText
 */

class CpCustomizeEditText @JvmOverloads constructor(context: Context,
                                                  attrs: AttributeSet? = null,
                                                  defStyleAttr: Int = 0
) : AppCompatEditText(context, attrs, defStyleAttr) {

    var textContent = ""

    init {
        gravity = Gravity.CENTER_VERTICAL
    }

    override fun onTextChanged(text: CharSequence?, start: Int, lengthBefore: Int, lengthAfter: Int) {
        super.onTextChanged(text, start, lengthBefore, lengthAfter)
        textContent = text.toString()
        setClearIconVisible(hasFocus() && text?.isNotEmpty() == true)
    }

    var focusedListener = false
    override fun onFocusChanged(focused: Boolean, direction: Int, previouslyFocusedRect: Rect?) {
        super.onFocusChanged(focused, direction, previouslyFocusedRect)
        focusedListener = focused
        if (focusedListener && textContent.isNotEmpty()) {
            setClearIconVisible(true)
        } else {
            setClearIconVisible(false)
        }
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
            val clearImg = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                context.getDrawable(R.mipmap.public_deleteall)
            } else {
                null
            }
            setCompoundDrawablesWithIntrinsicBounds(null, null, clearImg, null)
        } else {
            setCompoundDrawablesWithIntrinsicBounds(null, null, null, null)
        }
    }

}
