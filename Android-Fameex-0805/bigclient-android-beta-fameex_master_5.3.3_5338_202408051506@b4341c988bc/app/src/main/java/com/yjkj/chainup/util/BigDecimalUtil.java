package com.yjkj.chainup.util;

import org.jetbrains.annotations.NotNull;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.text.DecimalFormat;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class BigDecimalUtil {

    /*
     *Addition
     */
    public static @NotNull BigDecimal add(String num1, String num2, int pointNum) {
        BigDecimal bigDecimal1 = null;
        if (!StringUtil.isNumeric(num1)) {
            bigDecimal1 = new BigDecimal("0.0");
        } else {
            bigDecimal1 = new BigDecimal(num1);
        }

        BigDecimal bigDecimal2 = null;
        if (!StringUtil.isNumeric(num2)) {
            bigDecimal2 = new BigDecimal("0.0");
        } else {
            bigDecimal2 = new BigDecimal(num2);
        }

        BigDecimal result = bigDecimal1.add(bigDecimal2);
        if (pointNum > 0) {
            result = result.setScale(pointNum, BigDecimal.ROUND_HALF_UP);
        }
        return result;
    }

    /*
     *Subtraction
     */
    public static @NotNull BigDecimal subtract(String num1, String num2, int pointNum) {
        BigDecimal bigDecimal1 = null;
        if (!StringUtil.isNumeric(num1)) {
            bigDecimal1 = new BigDecimal("0.0");
        } else {
            bigDecimal1 = new BigDecimal(num1);
        }

        BigDecimal bigDecimal2 = null;
        if (!StringUtil.isNumeric(num2)) {
            bigDecimal2 = new BigDecimal("0.0");
        } else {
            bigDecimal2 = new BigDecimal(num2);
        }

        BigDecimal result = bigDecimal1.subtract(bigDecimal2);
        if (pointNum > 0) {
            result = result.setScale(pointNum, BigDecimal.ROUND_HALF_UP);
//            result = result.setScale(pointNum, BigDecimal.ROUND_DOWN);
        }
        return result;
    }

    /*
     *Multiplication,
     *PointNum Keep a few digits after the Decimal separator and round off
     */
    public static @NotNull BigDecimal multiply(String num1, String num2, int pointNum) {
        BigDecimal bigDecimal1 = null;
        if (!StringUtil.isNumeric(num1)) {
            bigDecimal1 = new BigDecimal("0.0");
        } else {
            bigDecimal1 = new BigDecimal(num1);
        }

        BigDecimal bigDecimal2 = null;
        if (!StringUtil.isNumeric(num2)) {
            bigDecimal2 = new BigDecimal("0.0");
        } else {
            bigDecimal2 = new BigDecimal(num2);
        }

        BigDecimal result = bigDecimal1.multiply(bigDecimal2);
        if (pointNum > 0) {
            result = result.setScale(pointNum, BigDecimal.ROUND_HALF_UP);
        }
        return result;
    }

    /*
     *Multiplication,
     *PointNum Keep several digits after the Decimal separator and round down
     */
    public static @NotNull BigDecimal multiply2(String num1, String num2, int pointNum) {
        BigDecimal bigDecimal1 = null;
        if (!StringUtil.isNumeric(num1)) {
            bigDecimal1 = new BigDecimal("0.0");
        } else {
            bigDecimal1 = new BigDecimal(num1);
        }

        BigDecimal bigDecimal2 = null;
        if (!StringUtil.isNumeric(num2)) {
            bigDecimal2 = new BigDecimal("0.0");
        } else {
            bigDecimal2 = new BigDecimal(num2);
        }

        BigDecimal result = bigDecimal1.multiply(bigDecimal2);
        if (pointNum > 0) {
            result = result.setScale(pointNum, BigDecimal.ROUND_DOWN);
        }
        return result;
    }

    /*
     *Division
     */
    public static @NotNull BigDecimal divide(String num1, String num2, int pointNum) {
        BigDecimal bigDecimal1 = null;
        if (!StringUtil.isNumeric(num1)) {
            bigDecimal1 = new BigDecimal("0.0");
        } else {
            bigDecimal1 = new BigDecimal(num1);
        }

        BigDecimal bigDecimal2 = null;
        if (!StringUtil.isNumeric(num2)) {
            bigDecimal2 = new BigDecimal("0.0");
        } else {
            bigDecimal2 = new BigDecimal(num2);
        }

        if (0 == bigDecimal2.compareTo(BigDecimal.ZERO)) {
            return bigDecimal2;
        }
        BigDecimal result = bigDecimal1.divide(bigDecimal2, BigDecimal.ROUND_HALF_UP);
        if (pointNum > 0) {
            result = result.setScale(pointNum, BigDecimal.ROUND_HALF_UP);
        }
        return result;
    }

    /**
     *Round down to retain pointNum decimals
     *
     * @param num1
     * @param num2
     * @param pointNum
     * @return
     */
    public static @NotNull BigDecimal divide2(String num1, String num2, int pointNum) {
        BigDecimal bigDecimal1 = null;
        if (!StringUtil.isNumeric(num1)) {
            bigDecimal1 = new BigDecimal("0.0");
        } else {
            bigDecimal1 = new BigDecimal(num1);
        }

        BigDecimal bigDecimal2 = null;
        if (!StringUtil.isNumeric(num2)) {
            bigDecimal2 = new BigDecimal("0.0");
        } else {
            bigDecimal2 = new BigDecimal(num2);
        }

        if (0 == bigDecimal2.compareTo(BigDecimal.ZERO)) {
            return bigDecimal2;
        }
        BigDecimal result = bigDecimal1.divide(bigDecimal2, BigDecimal.ROUND_DOWN);
        if (pointNum > 0) {
            result = result.setScale(pointNum, BigDecimal.ROUND_DOWN);
        }
        return result;
    }

    /*
     *Keep several decimal places after rounding to Decimal separator
     */
    public static @NotNull String getFixedPointNum(String num, int point) {
        BigDecimal bigDecimal = null;
        if (!StringUtil.isNumeric(num)) {
            bigDecimal = new BigDecimal("0.00");
        } else {
            bigDecimal = new BigDecimal(num);
        }

        if (point > 0) {
            /*if(0 == bigDecimal.compareTo(BigDecimal.ZERO)){
                StringBuilder sb = new StringBuilder();
                for(int i=0;i<point;i++){
                    sb.append("0");
                }
                String pointStr = "0."+sb.toString();
                
                return pointStr;//new BigDecimal(new DecimalFormat(pointStr).format(0.00d));
            }else{
                return bigDecimal.setScale(point,BigDecimal.ROUND_HALF_UP).toPlainString();
            }*/
            return bigDecimal.setScale(point, BigDecimal.ROUND_HALF_UP).toPlainString();
        }
        return bigDecimal.toPlainString();
    }

    public static @NotNull String getPrettyNumber(String num) {
        if (!StringUtil.isNumeric(num)) {
            return "0";
        }
        return BigDecimal.valueOf(Double.parseDouble(num)).stripTrailingZeros().toPlainString();
    }

    /*
     *Two decimal places shall be reserved after rounding off the Decimal separator, and every three decimal places shall be separated by commas. If the point is 0, it will be an integer
     */
    public static @NotNull String getFixedPointNum2(String num, int point) {
        if (!StringUtil.isNumeric(num)) {
            return new BigDecimal("0.00").setScale(point).toPlainString();
        }
        BigDecimal bigDecimal = new BigDecimal(num);
        if (1 == compareSize(num, "-1000") && -1 == compareSize(num, "1000")) {
            return bigDecimal.setScale(point, BigDecimal.ROUND_HALF_UP).toPlainString();
        }

        bigDecimal = bigDecimal.setScale(point, BigDecimal.ROUND_HALF_UP);

        BigDecimal intBigDecimal = bigDecimal.setScale(0, BigDecimal.ROUND_DOWN);
        BigDecimal pointBigDecimal = bigDecimal.subtract(intBigDecimal);

        String format = new DecimalFormat("#,###").format(intBigDecimal.toBigIntegerExact());

        return format + pointBigDecimal.toPlainString().replace("0.", ".");//new BigDecimal().toPlainString();
    }

    /*
     *ROUND_ DOWN Rounds down to a few decimal places after the Decimal separator
     */
    public static @NotNull String getFixedPointNum3(String num, int point) {
        BigDecimal bigDecimal = null;
        if (!StringUtil.isNumeric(num)) {
            
            bigDecimal = new BigDecimal("0.00");
        } else {
            bigDecimal = new BigDecimal(num);
        }

        if (point > 0) {
            return bigDecimal.setScale(point, BigDecimal.ROUND_DOWN).toPlainString();
        }
        return bigDecimal.toPlainString();
    }

    /**
     * @param num1
     * @param num2
     *@return -1 less than 0 equals 1 greater than
     */
    public static int compareSize(String num1, String num2) {
        if (!StringUtil.isNumeric(num1)) {
            num1 = "0";
        }
        if (!StringUtil.isNumeric(num2)) {
            num2 = "0";
        }
        return new BigDecimal(num1).compareTo(new BigDecimal(num2));
    }


}
