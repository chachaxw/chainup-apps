package com.chainup.kit.utils

import android.view.View
import android.widget.EditText
import com.jakewharton.rxbinding2.view.RxView
import java.util.concurrent.TimeUnit

fun EditText.numberFilter(decimal: Int = 1, integer: Int = 9, otherFilter: InputLimitTextWatcher.IListener? = null) {
    if (tag != null && tag is InputLimitTextWatcher) {
        val watcher = tag as InputLimitTextWatcher
        watcher.decimal = decimal
        watcher.integer = integer
        if(otherFilter != null){
            watcher.otherFilter = otherFilter
        }
    } else {
        val textWatcher = InputLimitTextWatcher(this, decimal, integer)
        textWatcher.otherFilter = otherFilter
        addTextChangedListener(textWatcher)
        tag = textWatcher
    }
}

inline fun View.setSafeListener(crossinline block:() -> Unit) {
    RxView.clicks(this)
        .throttleFirst(1, TimeUnit.SECONDS)
        .subscribe({
            block.invoke()
        },{
            it.printStackTrace()
        })
}