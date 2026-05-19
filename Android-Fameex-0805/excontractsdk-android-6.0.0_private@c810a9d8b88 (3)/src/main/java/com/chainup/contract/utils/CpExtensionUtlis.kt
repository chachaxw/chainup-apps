package com.chainup.contract.utils

import android.content.Context
import android.content.res.ColorStateList
import android.os.Build
import androidx.fragment.app.Fragment
import android.text.*
import android.util.Log
import android.view.View
import android.view.animation.Animation
import android.view.animation.AnimationUtils
import android.widget.EditText
import android.widget.ImageView
import android.widget.TextView
import androidx.core.content.ContextCompat
import com.chainup.contract.R
import com.chainup.contract.listener.CpDoListener
import com.chainup.contract.view.CpContractInputTextWatcher
import com.yjkj.chainup.manager.CpLanguageUtil
import kotlinx.android.synthetic.main.cp_trade_amount_view_new.view.*


/**
 *EditText Set editing status
 */
fun EditText.edit(edit: Boolean = true) {
    if (edit) {
        isFocusableInTouchMode = true
        isFocusable = true
        isEnabled = true
        requestFocus()
        if (!TextUtils.isEmpty(text)) {
            setSelection(text.length)
        }

    } else {
        isFocusable = false
        isFocusableInTouchMode = false
        isEnabled = false
        setText("")
        clearFocus()
    }
}

/**
 *Update the background focus. If the view is empty, modify your own background
 */
fun EditText.updateFocusBgListener(pView: View?) {
    setOnFocusChangeListener { v, hasFocus ->
        val bgRes = if (hasFocus) R.drawable.cp_bg_trade_et_focused else R.drawable.cp_bg_trade_et_unfocused
        if (pView == null) {
            setBackgroundResource(bgRes)
        } else {
            pView.setBackgroundResource(bgRes)
        }
    }
}


/**
 *TextView dynamically sets text
 *The key defined in key string.xml
 */
fun TextView.onLineText(key: String) {
    text = CpLanguageUtil.getString(context, key)
}

fun Context.getLineText(key: String): String {
    return CpLanguageUtil.getString(this, key)
}

fun Context.getLineText(key: String, isFormat: Boolean = false): String {
    if (isFormat) {
        if (!TextUtils.isEmpty(key)) {
            return CpLanguageUtil.getString(this, key).replace("\\n", "\n")
        }
    }
    return CpLanguageUtil.getString(this, key)
}

fun Fragment.getLineText(key: String): String {
    return CpLanguageUtil.getString(activity, key)
}

fun Fragment.getLineText(key: String, isFormat: Boolean = false): String {
    if (isFormat) {
        if (!TextUtils.isEmpty(key)) {
            return CpLanguageUtil.getString(activity, key).replace("\\n", "\n")
        }
    }
    return CpLanguageUtil.getString(activity, key)
}

/**
 *Local language
 */
fun String.localized(context: Context): String {
    return CpLanguageUtil.getString(context, this)
}

/**
 *Gets the value of EditText, and returns the string 0 if it is empty
 */
fun EditText.textNull2Zero(): String {
    return if (TextUtils.isEmpty(text.toString())) "0" else text.toString()
}

/**
 *EditText input listening
 */
fun EditText.afterTextChanged(slDoListener: CpDoListener) {
    val editText = this
    addTextChangedListener(object : TextWatcher {
        override fun afterTextChanged(s: Editable?) {
            slDoListener.doThing(editText)
        }

        override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
        override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}
    })
}


/**
 *Limit both decimal and integer digits
 */
fun EditText.numberFilterUnit(pxUnit: String, integer: Int = 9, otherFilter: CpDoListener? = null) {
    var decimal = 0
    if (pxUnit.isNotEmpty() && pxUnit.contains(".")) {
        val split = pxUnit.split(".")
        if (split.size == 2) {
            decimal = split[1].length
        }
    }
    numberFilter(decimal, integer, otherFilter)
}

/**
 *Limit both decimal and integer digits
 */
fun EditText.numberFilter(decimal: Int = 1, integer: Int = 9, otherFilter: CpDoListener? = null) {
    if (tag != null && tag is CpContractInputTextWatcher) {
        val watcher = tag as CpContractInputTextWatcher
        watcher.decimal = decimal
        watcher.integer = integer
        if(otherFilter != null){
            watcher.otherFilter = otherFilter
        }
    } else {
        val textWatcher = CpContractInputTextWatcher(this, decimal, integer)
        textWatcher.otherFilter = otherFilter
        addTextChangedListener(textWatcher)
        tag = textWatcher
    }
}

/**
 *View Animation
 */
fun View.startResAnimation(animRes: Int) {
    if (visibility != View.VISIBLE) {
        return
    }
    val animationTag = getTag(animRes)
    val animation = if (animationTag != null && animationTag is Animation) {
        animationTag
    } else {
        val loadAnimation = AnimationUtils.loadAnimation(context, animRes)
        setTag(animRes, loadAnimation)
        loadAnimation
    }
    startAnimation(animation)
}

fun View.setTransferStatus(classification:Int){
    if(classification == 4){//Simulated contract
        //Scratch icon
        run {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP && this is ImageView) {
                visibility = View.VISIBLE
                imageTintList = ColorStateList.valueOf(ContextCompat.getColor(context,R.color.btn_unclickable_color))
            }else{
                visibility = View.GONE
            }
        }
    }else{
        //Scratch icon
        run{
            visibility = View.VISIBLE
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP && this is ImageView) {
                imageTintList = ColorStateList.valueOf(ContextCompat.getColor(context,R.color.main_color))
            }
        }
    }
}
