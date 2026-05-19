package com.chainup.contract.view

import android.text.Editable
import android.text.TextWatcher
import android.widget.EditText
import com.chainup.contract.listener.CpDoListener

/**
 * @author ZhongWei
 * @time 2020/8/19 19:07
 *@ description EditText simultaneously restricts the number of digits of integer and decimal input, without interfering with each other
 **/
class CpContractInputTextWatcher(private val editText: EditText, var decimal: Int, var integer: Int) : TextWatcher {

    private var beforeText = ""

    var otherFilter: CpDoListener? = null

    override fun afterTextChanged(s: Editable?) {
        val text = editText.text.toString()
        if (text.startsWith(".")) {
            if(decimal == 0){
                editText.setText("")
                return
            }
            editText.setText("0.")
            editText.setSelection(2)
            return
        } else if (text.contains(".")) {
            if(decimal == 0){
                var replace = text.replace(".", "")
                if(replace.length > integer){
                    replace = replace.substring(0,integer)
                }
                if(replace.length>=2){
                    replace = replace.replace(Regex("^0"),"")
                }

                editText.setText(replace)
                editText.setSelection(replace.length)
                return
            }
            val split = text.split(".")
            if (split[0].length > integer) {
                editText.setText(beforeText)
                val index = beforeText.length - 1
                val ctextLength = editText.text.length
                if(index!=-1 && ctextLength>=index){
                    editText.setSelection(index)
                }

                return
            }
            if (split.size == 2 && split[1].length > decimal) {
                editText.setText(beforeText)
                val index = beforeText.length - 1
                val ctextLength = editText.text.length
                if(index!=-1 && ctextLength>=index){
                    editText.setSelection(index)
                }
                return
            }
        } else {
            if (text.length > integer) {
                editText.setText(beforeText)
                val index = beforeText.length - 1
                val ctextLength = editText.text.length
                if(index!=-1 && ctextLength>=index){
                    editText.setSelection(index)
                }
                return
            }
        }
        otherFilter?.doThing(editText)
    }

    override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {
        beforeText = editText.text.toString()
    }

    override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}

}
