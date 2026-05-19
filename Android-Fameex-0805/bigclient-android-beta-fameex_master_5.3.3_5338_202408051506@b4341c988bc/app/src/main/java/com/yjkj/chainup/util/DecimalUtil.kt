package com.yjkj.chainup.util

import android.text.TextUtils
import com.yjkj.chainup.util.BigDecimalUtils.showSNormal
import org.json.JSONObject
import java.math.BigDecimal
import java.util.*

/**
 * @Author: Bertking
 * @Date 2023-06-03-11:09
 *@description: Process data format
 */

class DecimalUtil {

    companion object {
        val TAG = DecimalUtil::class.java.simpleName


        /**
         *Judge whether the string is a Significant figures
         * @param str
         */
        fun isNumeric(str: String): Boolean {
            return try {
                BigDecimal(str).toString()
                true
            } catch (e: Exception) {
                false//The exception description contains non numbers.
            }
        }


        /**
         *Accurately comparing two numbers
         *
         *The first number to be compared for @param v1
         *The second number to be compared for @param v2
         *@return returns 0 if two numbers are the same, 1 if the first number is greater than the second number, and -1 if the other is greater
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
         *Temporarily used to solve the trading volume of the "transaction list" on the homepage
         */
        fun formatNumber(str: String, precision: Int = 2): String {
            if (!StringUtil.isNumeric(str))
                return "--"
            var number = ""
            val b0 = BigDecimal("1000")
            val b1 = BigDecimal("1000000")
            val b2 = BigDecimal("1000000000")
            val temp = BigDecimal(str)

            val value = BigDecimal(str).toPlainString()
            if (temp < b0) {
                return if (value.contains(".") || value == "0") {
                    BigDecimalUtils.divForDown(str, precision).toPlainString()
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
         *Specify precision by the scale parameter (not rounded)
         *
         *Determine whether isNumber (v1) is a legal value
         *Avoid using isNumeric as it will generate an additional BigDecimal object
         *
         *@param v1 parameter
         *@param scale indicates that it needs to be accurate to several digits after the Decimal separator.
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
         *Sort according to option 1, and when option 1 is equal, sort according to option 2
         *@param option1 Condition 1 to sort
         *@param option2 Condition 2 to sort
         *@param isRequiredOption2 Is condition 2 mandatory
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

        /**
         *Specify precision by the scale parameter (not rounded)
         *
         *Determine whether isNumber (v1) is a legal value
         *Avoid using isNumeric as it will generate an additional BigDecimal object
         *
         *@param v1 parameter
         *@param scale indicates that it needs to be accurate to several digits after the Decimal separator.
         */
        fun cutValueByPrecisionBig(v1: String, scale: Int): BigDecimal {
            var result: BigDecimal = BigDecimal("0")
            try {
                var v1 = v1
                if (TextUtils.isEmpty(v1) || v1 == "--" || v1 == "null") {
                    v1 = "0"
                }
                result = BigDecimal(v1).setScale(scale, BigDecimal.ROUND_DOWN)
            } catch (e: Exception) {
                e.printStackTrace()
            } finally {
                return result
            }

        }



}
}
