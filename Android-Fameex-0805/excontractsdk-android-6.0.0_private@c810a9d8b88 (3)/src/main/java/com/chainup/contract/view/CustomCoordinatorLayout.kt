package com.chainup.contract.view

import android.content.Context
import android.util.AttributeSet
import android.view.MotionEvent
import androidx.coordinatorlayout.widget.CoordinatorLayout

class CustomCoordinatorLayout @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null
) : CoordinatorLayout(context, attrs) {
    var isKlineDrag = false
    override fun onInterceptTouchEvent(ev: MotionEvent?): Boolean {
        if(ev?.action == MotionEvent.ACTION_MOVE){
            if(isKlineDrag){
                return false
            }
        }
        return super.onInterceptTouchEvent(ev)
    }
}