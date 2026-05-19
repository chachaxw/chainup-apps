package com.chainup.kit.utils;

import android.util.Log;

import java.math.BigDecimal;
import java.text.DecimalFormat;

public class BigDecimalUtils {
    //Default division precision
    private static final int DEF_DIV_SCALE = 10;

    /**
     *Provides accurate addition operations.
     *
     *@param v1 addend
     *@param v2 addend
     *@return The sum of two parameters
     */
    public static BigDecimal add(String v1, String v2) {
        if (!StringUtil.isNumeric(v1))
            v1 = "0";

        if (!StringUtil.isNumeric(v2)) {
            v2 = "0";
        }
        return new BigDecimal(v1).add(new BigDecimal(v2));
    }


    /**
     *Provides accurate subtraction operations.
     *
     *@param v1 Subtracted
     *Subtract @param v2
     *@return The difference between the two parameters
     */
    public static BigDecimal sub(String v1, String v2) {

        if (!StringUtil.isNumeric(v1))
            v1 = "0";

        if (!StringUtil.isNumeric(v2)) {
            v2 = "0";
        }
        return new BigDecimal(v1).subtract(new BigDecimal(v2));
    }

    public static String fmtMicrometer(String text) {
        DecimalFormat df = null;
        if (text.indexOf(".") > 0) {
            int i = text.length() - text.indexOf(".") - 1;
            if (i == 0) {
                df = new DecimalFormat("###,##0.");
            } else if (i == 1) {
                df = new DecimalFormat("###,##0.0");
            } else {
                Log.e("fmtMicrometer","fmtMicrometer "+text + " ] " +i);
                StringBuilder zero   = new StringBuilder("");
                for (int j = 0; j< i;j++){
                    zero.append("0");
                }
                df = new DecimalFormat("###,##0."+zero.toString());
            }
        } else {
            df = new DecimalFormat("###,##0");
        }
        double number = 0.0;
        try {
            number = Double.parseDouble(text);
        } catch (Exception e) {
            number = 0.0;
        }
        return df.format(number);
    }

    /**
     *Accurately comparing two numbers
     *
     *The first number to be compared for @param v1
     *The second number to be compared for @param v2
     *@return returns 0 if two numbers are the same, 1 if the first number is greater than the second number, and -1 if the other is greater
     */
    public static int compareTo(String v1, String v2) {

        if (!StringUtil.isNumeric(v1))
            v1 = "0";

        if (!StringUtil.isNumeric(v2)) {
            v2 = "0";
        }
        return new BigDecimal(v1).compareTo(new BigDecimal(v2));

    }

    public static String subZeroAndDot(String s) {
        if (!StringUtil.isNumeric(s))
            return "0";

        if (s.indexOf(".") > 0) {
            s = s.replaceAll("0+?$", "");//Remove redundant 0
            s = s.replaceAll("[.]$", "");//Remove if the last digit is
        }
        return s;
    }

    /**
     *Disable Scientific notation
     * <p>
     *Supplement: toPlainString()
     * No scientific notation is used. This methods adds zeros where necessary.
     * return: a string representation of {@code this} without exponent part
     * <p>
     *IAW, the returned string does not have an exponential form
     *
     *@return Returns the double type
     */
    public static String showSNormal(String data) {
        if (!StringUtil.checkStr(data)) {
            return "";
        }

        if (data.contains("\"")) {
            data = stringReplace(data);
        }
        if (!StringUtil.isNumeric(data)) {
            data = "0";
        }
        String plainString = new BigDecimal(data).toPlainString();
        return subZeroAndDot(plainString);
    }

    /**
     *Remove double quotes
     *
     * @param wifiInfo
     * @return
     */
    public static String stringReplace(String wifiInfo) {
        String str = wifiInfo.replace("\"", "");
        return str;
    }

    public static String showSNormal(String data, int scale) {
        if (!StringUtil.checkStr(data)) {
            return "";
        }

        if (data.contains("\"")) {
            data = stringReplace(data);
        }
        if (!StringUtil.isNumeric(data)) {
            data = "0";
        }
        String plainString = new BigDecimal(data).setScale(scale, BigDecimal.ROUND_DOWN).toPlainString();
        return plainString;
    }
    public static String showSNormalSubZero(String data, int scale) {
        return subZeroAndDot(showSNormal(data,scale));
    }
}

