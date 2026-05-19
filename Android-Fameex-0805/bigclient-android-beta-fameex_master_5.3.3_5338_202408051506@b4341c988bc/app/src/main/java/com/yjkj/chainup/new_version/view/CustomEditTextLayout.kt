package com.yjkj.chainup.new_version.view

import android.content.Context
import android.graphics.drawable.ColorDrawable
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.widget.LinearLayout
import androidx.core.content.ContextCompat
import androidx.core.widget.addTextChangedListener
import com.yjkj.chainup.R
import kotlinx.android.synthetic.main.layout_custom_edittext.view.*

class CustomEditTextLayout @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null
) : LinearLayout(context, attrs) {
    var listener:ICustomEditTextLayoutListener? = null
    init {
        LayoutInflater.from(context).inflate(R.layout.layout_custom_edittext,this,true)
        initView()
    }

    private fun initView() {
        et_view.isEnabled = true
        et_view.isFocusableInTouchMode = true
        et_view.isShowLine = false
        et_view.addTextChangedListener {
            listener?.textChange(et_view.text.toString())
        }
        et_view.setOnFocusChangeListener { v, hasFocus ->
            v_bottom_line.background = ColorDrawable(
                if(hasFocus){
                    ContextCompat.getColor(context,R.color.main_color)
                }else{
                    ContextCompat.getColor(context,R.color.new_edit_line_color)
                }
            )
        }
    }

    fun setHint(hintText:String){
        et_view.hint = hintText
    }
    fun setTextContent(textContent:String){
        et_view.setText(textContent)
    }

    fun showLeftCustomLayout(view: View) {
        rl_layout.visibility = View.VISIBLE
        if(rl_layout.childCount<=0) {
            rl_layout.removeAllViews()
            rl_layout.addView(view)
        }
    }

    fun hideLeftCustomLayout(){
        rl_layout.visibility = View.GONE
    }

    interface ICustomEditTextLayoutListener {
        fun textChange(text:String)

    }
}