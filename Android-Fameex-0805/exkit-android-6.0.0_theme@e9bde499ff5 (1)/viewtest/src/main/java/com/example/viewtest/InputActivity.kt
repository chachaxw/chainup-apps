package com.example.viewtest

import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.View.OnClickListener
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.chainup.kit.utils.PublicSizeUtil
import com.chainup.kit.views.*
import com.chainup.kit.views.base.BaseEditTextKit

class InputActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_input)

        //自定义action
        val etFormGroup = (findViewById<View>(R.id.kk_edt_group_1) as KKEditFormGroupKit)
        etFormGroup.apply {
            this.title = "title1"
            this.listener = object : BaseEditTextKit.OnKKBaseListener {
                override fun textChange(text: String) {
                    Log.d("BaseEditTextKit","text:$text")
                }

                override fun rules(): Boolean {
                    val contentStr = etFormGroup.getText()
                    return contentStr.equals("12345")
                }

            }

        }
        val actionView = LayoutInflater.from(this).inflate(R.layout.layout_custom_action,null)
        actionView.findViewById<View>(R.id.ib_action1).setOnClickListener {
            Toast.makeText(this,"ib_action1点击",Toast.LENGTH_SHORT).show()
        }
        actionView.findViewById<View>(R.id.ib_action2).setOnClickListener {
            Toast.makeText(this,"ib_action2点击",Toast.LENGTH_SHORT).show()
        }
        actionView.findViewById<View>(R.id.ib_action3).setOnClickListener {
            Toast.makeText(this,"ib_action3点击",Toast.LENGTH_SHORT).show()
        }
        etFormGroup.addCustomAction(actionView)

        val phoneView = findViewById<KKEditFormGroupKit>(R.id.kk_phone_area)
        val beforeView = ImageView(this)
        beforeView.setImageResource(R.mipmap.phonebefore)
        beforeView.layoutParams = FrameLayout.LayoutParams(PublicSizeUtil.dp2px(this,80.0f),ViewGroup.LayoutParams.MATCH_PARENT)
        beforeView.scaleType = ImageView.ScaleType.FIT_XY
        phoneView.addCustomActionBefore(beforeView)

        val iconView = findViewById<KKEditFormGroupKit>(R.id.kk_constom_icon)

        val editShow = findViewById<KKEditFormGroupKit>(R.id.testShow)
        editShow.editEnable(false)

        val actionView2 = LayoutInflater.from(this).inflate(R.layout.layout_custom_action,null)
        actionView2.findViewById<View>(R.id.ib_action1).setOnClickListener {
            Toast.makeText(this,"ib_action1点击",Toast.LENGTH_SHORT).show()
        }
        actionView2.findViewById<View>(R.id.ib_action2).setOnClickListener {
            Toast.makeText(this,"ib_action2点击",Toast.LENGTH_SHORT).show()
        }
        actionView2.findViewById<View>(R.id.ib_action3).setOnClickListener {
            Toast.makeText(this,"ib_action3点击",Toast.LENGTH_SHORT).show()
        }
        iconView.addCustomAction(actionView2)



        val edt2 = (findViewById<View>(R.id.edt_2) as BaseEditTextKit)
        edt2.listener = object: BaseEditTextKit.OnKKBaseListener{
            override fun textChange(text: String) {
                Log.d("edt2","当前输入 -> $text")
            }

            //制定自己的规则， 返回 true 代表正确 返回false 代表错误  不实现rules的话，始终都是true
            override fun rules(): Boolean {
                val contentStr = edt2.text.toString()
                return contentStr.length < 3
            }

            override fun statusChange(status: Boolean) {
                super.statusChange(status)
                Toast.makeText(this@InputActivity,"错误状态："+edt2.getErrorMode(),Toast.LENGTH_SHORT).show()
            }

        }



        findViewById<KKEditNumberKit>(R.id.kitView).listener = object :
            BaseEditTextKit.OnKKBaseListener{
            override fun textChange(text: String) {
                Log.d("KKEditNumberKit","text:$text")
            }

        }
        findViewById<KKEditNumberKit>(R.id.kitView).setPrecision(4)


    }
}