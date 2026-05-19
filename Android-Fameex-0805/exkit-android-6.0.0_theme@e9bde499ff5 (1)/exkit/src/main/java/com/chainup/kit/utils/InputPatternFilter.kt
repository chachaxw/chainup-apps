package com.chainup.kit.utils
import android.text.InputFilter
import android.text.Spanned
import java.util.regex.Pattern

/**
 * @param pattern 匹配特殊字符的正则
 * */
class InputPatternFilter(var pattern:String,var isFilter:Boolean?=true) : InputFilter {

    override fun filter(
        source: CharSequence?,//即将要输入的字符串
        start: Int,//source的start
        end: Int,//source的end
        dest: Spanned?,//输入框中原来的内容
        dstart: Int,//光标所在位置
        dend: Int//光标终止位置
    ): CharSequence {
        val compile = Pattern.compile(pattern)
        val resultInput = source.toString()
        val matches = compile.matcher(resultInput).matches()
        if(isFilter == true){
            return if(!matches){
                resultInput
            }else{
                ""
            }
        }else{
            return if(matches){
                resultInput
            }else{
                ""
            }
        }

    }
}
