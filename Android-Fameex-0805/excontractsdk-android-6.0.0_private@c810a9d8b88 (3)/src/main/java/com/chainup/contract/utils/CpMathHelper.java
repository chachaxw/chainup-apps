package com.chainup.contract.utils;

import android.text.TextUtils;

import java.math.BigDecimal;

public class CpMathHelper {

    private static final int DEF_DIV_SCALE = 8;
    private static final double DOUBLE_GWEI = 1000000000;
    public static final long LONG_GWEI = 1000000000;

    private CpMathHelper() {

    }

    /**
     *Provides accurate addition operations.
     *
     * @param v1
     *Addend
     * @param v2
     *Addend
     *@return The sum of two parameters
     */
    public static double add(double v1, double v2) {
        BigDecimal b1 = new BigDecimal(Double.toString(v1));
        BigDecimal b2 = new BigDecimal(Double.toString(v2));
        return b1.add(b2).doubleValue();
    }

    public static double add(String v1, String v2) {
        if (TextUtils.isEmpty(v1) || TextUtils.isEmpty(v2)) {
            return 0;
        }
        BigDecimal b1 = new BigDecimal(v1);
        BigDecimal b2 = new BigDecimal(v2);
        return b1.add(b2).doubleValue();
    }

    public static String add2String(String v1, String v2) {
        if (TextUtils.isEmpty(v1) || TextUtils.isEmpty(v2)) {
            return "0";
        }
        BigDecimal b1 = new BigDecimal(v1);
        BigDecimal b2 = new BigDecimal(v2);
        return b1.add(b2).toString();
    }
    /**
     *Provides accurate subtraction operations.
     *
     * @param v1
     *Subtracted number
     * @param v2
     *Subtraction
     *@return The difference between the two parameters
     */
    public static double sub(double v1, double v2) {
        BigDecimal b1 = new BigDecimal(Double.toString(v1));
        BigDecimal b2 = new BigDecimal(Double.toString(v2));
        return b1.subtract(b2).doubleValue();
    }

    public static double sub(String v1, String v2) {
        if (TextUtils.isEmpty(v1) || TextUtils.isEmpty(v2)) {
            return 0;
        }
        BigDecimal b1 = new BigDecimal(v1);
        BigDecimal b2 = new BigDecimal(v2);
        return b1.subtract(b2).doubleValue();
    }

    /**
     *Provides accurate multiplication operations.
     *
     * @param v1
     *Multiplicand
     * @param v2
     *Multiplier
     *@return The product of two parameters
     */
    public static double mul(double v1, double v2) {
        if (v1 == 0 || v2 == 0) {
            return 0;
        }

        BigDecimal b1 = new BigDecimal(Double.toString(v1));
        BigDecimal b2 = new BigDecimal(Double.toString(v2));
        return b1.multiply(b2).doubleValue();
    }

    public static double mul(String v1, String v2) {
        if (TextUtils.isEmpty(v1) || TextUtils.isEmpty(v2)) {
            return 0;
        }
        BigDecimal b1 = new BigDecimal(v1);
        BigDecimal b2 = new BigDecimal(v2);
        return b1.multiply(b2).doubleValue();
    }
    /**
     *Provide (relatively) accurate division operations. When there is an inexhaustible division, it is accurate to 10 decimal places, and subsequent numbers are rounded off.
     *
     * @param v1
     *Divisor
     * @param v2
     *Divisor
     *@return The quotient of two parameters
     */
    public static double div(double v1, double v2) {
        return div(v1, v2, DEF_DIV_SCALE);
    }
    public static double div(String v1, String v2) {
        return div(v1, v2, DEF_DIV_SCALE);
    }

    /**
     *Provides (relatively) accurate division operations. When an inexhaustible division occurs, the scale parameter specifies the precision, and subsequent numbers are rounded off.
     *
     * @param v1
     *Divisor
     * @param v2
     *Divisor
     * @param scale
     *Represents the need to be accurate to several decimal places.
     *@return The quotient of two parameters
     */
    public static double div(double v1, double v2, int scale) {
        if (scale < 0) {
            throw new IllegalArgumentException(
                    "The scale must be a positive integer or zero");
        }

        if (v2 == 0.0) {
            return 0.0;
        }
        BigDecimal b1 = new BigDecimal(Double.toString(v1));
        BigDecimal b2 = new BigDecimal(Double.toString(v2));
        return b1.divide(b2, scale, BigDecimal.ROUND_DOWN).doubleValue();
    }

    public static double div(String v1, String v2, int scale) {
        if (TextUtils.isEmpty(v1) || TextUtils.isEmpty(v2)) {
            return 0;
        }

        if (scale < 0) {
            throw new IllegalArgumentException(
                    "The scale must be a positive integer or zero");
        }

        if (Double.parseDouble(v2) == 0.0) {
            return 0.0;
        }

        BigDecimal b1 = new BigDecimal(v1);
        BigDecimal b2 = new BigDecimal(v2);
        return b1.divide(b2, scale, BigDecimal.ROUND_DOWN).doubleValue();
    }

    /**
     *Provide accurate decimal rounding processing.
     *
     * @param v
     *Numbers that need to be rounded
     * @param scale
     *How many digits after the decimal point
     *@return Rounded result
     */
    public static double round(double v, int scale) {
        if (scale < 0) {
            throw new IllegalArgumentException(
                    "The scale must be a positive integer or zero");
        }
        BigDecimal b = new BigDecimal(Double.toString(v));
        BigDecimal one = new BigDecimal("1");
        return b.divide(one, scale, BigDecimal.ROUND_DOWN).doubleValue();
    }

    public static double round(String v, int scale) {
        if (TextUtils.isEmpty(v)) {
            return 0;
        }

        if (scale < 0) {
            throw new IllegalArgumentException(
                    "The scale must be a positive integer or zero");
        }
        BigDecimal b = new BigDecimal(v);
        BigDecimal one = new BigDecimal("1");
        return b.divide(one, scale, BigDecimal.ROUND_DOWN).doubleValue();
    }

    public static double roundUp(String v, int scale) {
        if (TextUtils.isEmpty(v)) {
            return 0;
        }

        if (scale < 0) {
            throw new IllegalArgumentException(
                    "The scale must be a positive integer or zero");
        }
        BigDecimal b = new BigDecimal(v);
        BigDecimal one = new BigDecimal("1");
        return b.divide(one, scale, BigDecimal.ROUND_UP).doubleValue();
    }

    public static double roundUp(Double v, int scale) {
        if (scale < 0) {
            throw new IllegalArgumentException(
                    "The scale must be a positive integer or zero");
        }
        BigDecimal b = new BigDecimal(v);
        BigDecimal one = new BigDecimal("1");
        return b.divide(one, scale, BigDecimal.ROUND_UP).doubleValue();
    }

    public static double round(String v) {
        if (TextUtils.isEmpty(v)) {
            return 0;
        }
        BigDecimal b = new BigDecimal(v);
        BigDecimal one = new BigDecimal("1");
        return b.divide(one, 8, BigDecimal.ROUND_DOWN).doubleValue();
    }

    public static String Long2RDoubleString(long l, int scale) {
        if (scale < 0) {
            throw new IllegalArgumentException(
                    "The scale must be a positive integer or zero");
        }

        double v = (double)l;
        double r = round(div(v, DOUBLE_GWEI), scale);
        return Double.toString(r);
    }

    public static double Long2RDouble(long l, int scale) {
        if (scale < 0) {
            throw new IllegalArgumentException(
                    "The scale must be a positive integer or zero");
        }

        double v = (double)l;
        double r = round(div(v, DOUBLE_GWEI), scale);
        return r;
    }


}
