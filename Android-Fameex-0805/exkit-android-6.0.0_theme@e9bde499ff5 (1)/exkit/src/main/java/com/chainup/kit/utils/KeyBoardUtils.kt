package com.chainup.kit.utils

import android.app.Activity
import android.content.Context
import android.util.Log
import android.view.WindowManager
import android.view.inputmethod.InputMethodManager
import android.widget.EditText

/**
 * @Author: Bertking
 * @Date：2019-06-26-16:10
 * @Description:
 */
object KeyBoardUtils {
    /**
     *Not applicable to dialog
     */
    fun closeKeyBoard(context: Context) {
        //Turn off keyboard
        val inputManager = context?.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        Log.d("=isActive=", "=======${inputManager?.isActive}===========")
        inputManager.hideSoftInputFromWindow((context as Activity)?.window?.decorView?.windowToken, 0)
    }

    fun showKeyBoard(context: Context) {
        //Turn off keyboard
        val inputManager = context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        (context as Activity).window.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_VISIBLE)
    }

    fun showKeyBoard(context: Context, editText: EditText) {
        //Turn off keyboard
        val inputManager = context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        inputManager.showSoftInput(editText,InputMethodManager.SHOW_FORCED)
    }
}
