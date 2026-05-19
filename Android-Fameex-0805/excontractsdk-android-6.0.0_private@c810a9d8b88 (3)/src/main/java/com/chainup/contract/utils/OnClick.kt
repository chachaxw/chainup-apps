package com.chainup.contract.utils

import android.graphics.Typeface
import android.os.Build
import android.view.View
import android.widget.TextView
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chainup.contract.R


inline fun View.setSafeListener(crossinline action:()->Unit){
    var lastClick=0L
    setOnClickListener {
        val gap = System.currentTimeMillis() - lastClick
        lastClick=System.currentTimeMillis()
        ChainUpLogUtil.e("gap:"+gap)
        if(gap<1000) return@setOnClickListener
        action.invoke()
    }
}

inline fun BaseQuickAdapter<*,*>.setSafeListener(crossinline action:(adapter:BaseQuickAdapter<*,*>, view:View, position:Int)->Unit){
    var lastClick=0L
    setOnItemClickListener { adapter, view, position ->
        val gap = System.currentTimeMillis() - lastClick
        lastClick=System.currentTimeMillis()
        ChainUpLogUtil.e("gap:"+gap)
        if(gap<1000) return@setOnItemClickListener
        action.invoke(adapter,view,position)
    }
}
inline fun BaseQuickAdapter<*,*>.setSafeItemClickListener(crossinline action:(adapter:BaseQuickAdapter<*,*>, view:View, position:Int)->Unit){
    var lastClick=0L
    setOnItemChildClickListener { adapter, view, position ->
        val gap = System.currentTimeMillis() - lastClick
        lastClick=System.currentTimeMillis()
        ChainUpLogUtil.e("gap:"+gap)
        if(gap<1000) return@setOnItemChildClickListener
        action.invoke(adapter,view,position)
    }
}

var _viewClickFlag = false
var _clickRunnable = Runnable { _viewClickFlag = false }
fun View.click(action: (view: View) -> Unit) {
    setOnClickListener {
        if (!_viewClickFlag) {
            _viewClickFlag = true
            action(it)
        }
        removeCallbacks(_clickRunnable)
        postDelayed(_clickRunnable, 500)
    }
}

fun TextView.toDinproMedium(){
    val fontType = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        resources.getFont(R.font.harmony_medium)
    } else {
        Typeface.DEFAULT
    }
    this.typeface = fontType
}

fun TextView.toDinproRegular(){
    val fontType = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        resources.getFont(R.font.harmony_regular)
    } else {
        Typeface.DEFAULT
    }
    this.typeface = fontType
}