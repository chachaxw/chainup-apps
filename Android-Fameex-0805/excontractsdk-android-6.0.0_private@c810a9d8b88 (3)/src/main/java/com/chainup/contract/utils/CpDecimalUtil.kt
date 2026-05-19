package com.chainup.contract.utils

import android.text.TextUtils
import com.chainup.contract.utils.CpBigDecimalUtils.showSNormal
import org.json.JSONObject
import java.math.BigDecimal
import java.util.*

/**
 * @Author: Bertking
 * @Date：2019-06-03-11:09
 *@ Description: Process data format
 */

class CpDecimalUtil {

    companion object {
        val TAG = CpDecimalUtil::class.java.simpleName


        /**
         *Determine whether a string is a valid number
         * @param str
         */
        fun isNumeric(str: String): Boolean {
            return try {
                BigDecimal(str).toString()
                true
            } catch (e: Exception) {
                false//The exception description contains non numeric characters.
            }
        }


        /**
         *Compare two numbers accurately
         *
         *@param v1 The first number to be compared
         *@param v2 The second number to be compared
         *@return Returns 0 if the two numbers are the same, 1 if the first number is larger than the second number, and - 1 if the opposite is true
         */
        fun compareTo(v1: String, v2: String): Int {
            return try {
                val b1 = BigDecimal(v1)
                val b2 = BigDecimal(v2)
                b1.compareTo(b2)
            } catch (e: NumberFormatException) {
                e.printStackTrace()
                -1
            }

        }


        fun showDepthVolume(value: String): String {
            return if (compareTo(value, "0.0001") <= 0) {
                "0.000"
            } else if (compareTo(value, "1000") >= 0) {
                formatNumber(value)
            } else {
                if (value.contains(".")) {
                    (value + "00000").substring(0, 5)
                } else {
                    "$value.0000".substring(0, 5)
                }
            }
        }

        /**
         *Temporarily used to solve the trading volume of the "Deal List" on the homepage
         */
        fun formatNumber(str: String, precision: Int = 2): String {
            if (!CpStringUtil.isNumeric(str))
                return "--"
            var number = ""
            val b0 = BigDecimal("1000")
            val b1 = BigDecimal("1000000")
            val b2 = BigDecimal("1000000000")
            val temp = BigDecimal(str)

            val value = BigDecimal(str).toPlainString()
            if (temp < b0) {
                return if (value.contains(".") || value == "0") {
                    CpBigDecimalUtils.divForDown(str, precision).toPlainString()
                } else {
                    value
                }
            } else if ((temp.compareTo(b0) == 0 || temp.compareTo(b0) == 1) && temp.compareTo(b1) == -1) {
                number = temp.divide(b0, 2, BigDecimal.ROUND_DOWN).toString() + "K"
                return number
            } else if (temp >= b1) {
                number = temp.divide(b1, 2, BigDecimal.ROUND_DOWN).toString() + "M"
                return number
            } else if (temp >= b2) {
                number = temp.divide(b1, 2, BigDecimal.ROUND_DOWN).toString() + "B"
                return number
            } else {
                return showSNormal(number)
            }
        }

        /**
         *Specifying precision by the scale parameter (not rounded)
         *
         *Determine whether isNumber (v1) is a legal value
         *Avoid using isNumeric because it produces an additional BigDecimal object
         *
         *@param v1 parameter
         *The @param scale indicates that it needs to be accurate to several decimal places.
         */
        fun cutValueByPrecision(v1: String, scale: Int): String {
            var result: String = "0"
            try {
                var v1 = v1
                if (TextUtils.isEmpty(v1) || v1 == "--" || v1 == "null") {
                    v1 = "0"
                }
                result = BigDecimal(v1).setScale(scale, BigDecimal.ROUND_DOWN).toPlainString()
            } catch (e: Exception) {
                result = "0"
            } finally {
                return result
            }

        }

        /**
         *Sort according to option1, and when option1 is equal, sort according to option2
         *@param option1 Condition to sort 1
         *@param option2 Condition to sort 2
         *@param isRequiredOption2 Is condition 2 required
         */
        @JvmStatic
        fun <T> sortByMultiOptions(list: ArrayList<T>?, option1: String = "sort", option2: String, isRequiredOption2: Boolean = true): ArrayList<T> {
            if (list == null) {
                return arrayListOf()
            }

            if (list.isEmpty()) return list

            list.sortWith(object : Comparator<T> {
                override fun compare(o1: T?, o2: T?): Int {
                    if (o1 is JSONObject? && o2 is JSONObject?) {
                        if (o1?.has(option1) == false) {
                            throw IllegalArgumentException("找不到参数1:$option1")
                        }

                        if (isRequiredOption2) {
                            if (o1?.has(option1) == false) {
                                throw IllegalArgumentException("找不到参数2:$option2")
                            }
                        }

                        val cond1 = o1?.optInt(option1, 0) ?: 0
                        val cond2 = o2?.optInt(option1, 0) ?: 0
                        when {
                            cond1 > cond2 -> {
                                return 1
                            }
                            cond1 < cond2 -> {
                                return -1
                            }
                            else -> {
                                return if (isRequiredOption2) {
                                    val cond11 = o1?.optString(option2) ?: ""
                                    val cond22 = o2?.optString(option2) ?: ""
                                    when {
                                        cond11 > cond22 -> {
                                            1
                                        }
                                        cond11 < cond22 -> {
                                            -1
                                        }
                                        else -> {
                                            0
                                        }
                                    }
                                } else {
                                    0
                                }
                            }
                        }
                    }else{
                        /**
                         *TODO is implemented based on entity classes
                         */
                        return 0
                    }
                }
            })
            return list
        }



}
}
