package com.chainup.kit.views

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.widget.RadioButton
import android.widget.RelativeLayout
import androidx.core.content.ContextCompat
import com.example.chainup_kit.R
import kotlinx.android.synthetic.main.public_item_layout_percent.view.*
import org.jetbrains.anko.textColor

/**
 * KKPercentKit
 * @property listener:OnKKPercentKitCheckListener
 * @property clearCheck
 * */
open class KKPercentKit @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null
) : RelativeLayout(context, attrs) {
    private val layout:View
    var listener:OnKKPercentKitCheckListener? = null
    init {
        layout = LayoutInflater.from(context).inflate(R.layout.public_item_layout_percent,this,true)
        initView()
    }

    private fun initView() {
        rg_trade.setOnCheckedChangeListener { group, checkedId ->
            var percent = ""

            for (i in 0 until rg_trade.childCount step 2) {
                val radioButton = rg_trade?.getChildAt(i) as RadioButton
                radioButton.setTextColor(ContextCompat.getColor(context,R.color.text_color_2))
            }

            when(checkedId){
                R.id.rb_1st -> {
                    rb_1st.textColor = ContextCompat.getColor(context,R.color.main_color)
                    percent = "0.25"
                }
                R.id.rb_2nd -> {
                    rb_2nd.textColor = ContextCompat.getColor(context,R.color.main_color)
                    percent = "0.50"
                }
                R.id.rb_3rd -> {
                    rb_3rd.textColor = ContextCompat.getColor(context,R.color.main_color)
                    percent = "0.75"
                }
                R.id.rb_4th -> {
                    rb_4th.textColor = ContextCompat.getColor(context,R.color.main_color)
                    percent = "1.0"
                }
            }

            listener?.onCheckedChanged(percent,checkedId)
        }
    }

    fun clearCheck(){
        if(rg_trade.checkedRadioButtonId > -1){
            rg_trade.clearCheck()
        }
    }


    interface OnKKPercentKitCheckListener{
        fun onCheckedChanged(percent:String,checkId:Int)
    }
}
