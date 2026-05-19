package com.yjkj.chainup.util

import android.content.Context
import androidx.fragment.app.Fragment
import android.text.*
import android.view.View
import android.view.animation.Animation
import android.view.animation.AnimationUtils
import android.widget.EditText
import android.widget.TextView
import com.yjkj.chainup.R
import com.yjkj.chainup.manager.LanguageUtil


/**
 *EditText setting editing status
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
 *Update the background focus, if view is empty, modify the own background
 */
fun EditText.updateFocusBgListener(pView: View?) {
    setOnFocusChangeListener { v, hasFocus ->
        val bgRes = if (hasFocus) R.drawable.bg_trade_et_focused else R.drawable.bg_trade_et_unfocused
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
    text = LanguageUtil.getString(context, key)
}

fun Context.getLineText(key: String): String {
    return LanguageUtil.getString(this, key)
}

fun Context.getLineText(key: String, isFormat: Boolean = false): String {
    if (isFormat) {
        if (!TextUtils.isEmpty(key)) {
            return LanguageUtil.getString(this, key).replace("\\n", "\n")
        }
    }
    return LanguageUtil.getString(this, key)
}

fun Fragment.getLineText(key: String): String {
    return LanguageUtil.getString(activity, key)
}

fun Fragment.getLineText(key: String, isFormat: Boolean = false): String {
    if (isFormat) {
        if (!TextUtils.isEmpty(key)) {
            return LanguageUtil.getString(activity, key).replace("\\n", "\n")
        }
    }
    return LanguageUtil.getString(activity, key)
}

/**
 *Local language
 */
fun String.localized(context: Context): String {
    return LanguageUtil.getString(context, this)
}

/**
 *Get the value of EditText, return the string 0 if it is empty
 */
fun EditText.textNull2Zero(): String {
    return if (TextUtils.isEmpty(text.toString())) "0" else text.toString()
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