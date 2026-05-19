package com.chainup.kit.utils
import android.text.Editable
import android.text.TextWatcher
import android.widget.EditText
import com.chainup.kit.views.KKEditNumberKit
import java.util.regex.Pattern

class InputLimitTextWatcher(private val editText: EditText, var decimal: Int, var integer: Int) : TextWatcher {

    private var beforeText = ""

    var otherFilter: IListener? = null

    override fun afterTextChanged(s: Editable?) {
        var text = editText.text.toString()
        if(editText is KKEditNumberKit && editText.isLever){
            text = text.replace("X","")
        }
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

            if(StringUtil.isNumeric(split[0])){
                if(BigDecimalUtils.compareTo(split[0],"0")==0 && split[0].length>1){
                    val contentStr = "0."+split[1]
                    editText.setText(contentStr)
                    editText.setSelection(contentStr.length)
                    return
                }
            }



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
            val pattern = Pattern.compile("^0+[1-9]{1,}")

            val isHasZero = pattern.matcher(text).matches()
            if(isHasZero){
                val newContent = text.replace(Regex("^0+"),"")
                editText.setText(newContent)
                editText.setSelection(newContent.length)
                return
            }
        }
        otherFilter?.doThing(editText)
    }

    override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {
        beforeText = editText.text.toString()
    }

    override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}

    interface IListener {
        /**
         *Perform Action
         */
        fun doThing(obj: Any? = null): Boolean

    }
}
