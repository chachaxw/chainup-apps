package com.chainup.contract.utils;


import android.content.Context;
import android.text.TextUtils;
import android.util.Log;


import com.blankj.utilcode.util.LogUtils;
import com.chainup.contract.app.CpMyApp;
import com.yjkj.chainup.manager.CpLanguageUtil;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.Locale;

public class CpBigDecimalUtils {

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
        if (!CpStringUtil.isNumeric(v1))
            v1 = "0";

        if (!CpStringUtil.isNumeric(v2)) {
            v2 = "0";
        }
        return new BigDecimal(v1).add(new BigDecimal(v2));
    }

    public static String addStr(String v1, String v2, int scale) {
        if (!CpStringUtil.isNumeric(v1))
            v1 = "0";

        if (!CpStringUtil.isNumeric(v2)) {
            v2 = "0";
        }
        if (scale < 0)
            scale = 0;
        return new BigDecimal(v1).add(new BigDecimal(v2)).setScale(scale, BigDecimal.ROUND_DOWN).toPlainString();
    }

    /**
     *Provides accurate subtraction operations.
     *
     *@param v1 Subtracted
     *Subtract @param v2
     *@return The difference between the two parameters
     */
    public static BigDecimal sub(String v1, String v2) {

        if (!CpStringUtil.isNumeric(v1))
            v1 = "0";

        if (!CpStringUtil.isNumeric(v2)) {
            v2 = "0";
        }
        return new BigDecimal(v1).subtract(new BigDecimal(v2));
    }

    public static String subStr(String v1, String v2, int scale) {

        if (!CpStringUtil.isNumeric(v1))
            v1 = "0";

        if (!CpStringUtil.isNumeric(v2)) {
            v2 = "0";
        }
        if (scale < 0)
            scale = 0;

        return new BigDecimal(v1).subtract(new BigDecimal(v2)).setScale(scale, BigDecimal.ROUND_DOWN).toPlainString();
    }

    /**
     *Provides accurate multiplication operations.
     *
     *@param v1 multiplicand
     *@param v2 multiplier
     *@return The product of two parameters
     */
    public static BigDecimal mul(String v1, String v2) {
        if (!CpStringUtil.isNumeric(v1))
            v1 = "0";

        if (!CpStringUtil.isNumeric(v2)) {
            v2 = "0";
        }
        return new BigDecimal(v1).multiply(new BigDecimal(v2));

    }

    public static String mulStr(String v1, String v2, int scale) {

        if (!CpStringUtil.isNumeric(v1))
            v1 = "0";

        if (!CpStringUtil.isNumeric(v2)) {
            v2 = "0";
        }
        if (scale < 0)
            scale = 0;
        return new BigDecimal(v1).multiply(new BigDecimal(v2)).setScale(scale, BigDecimal.ROUND_DOWN).toPlainString();

    }

    public static String mulStrRoundUp(String v1, String v2, int scale) {

        if (!CpStringUtil.isNumeric(v1))
            v1 = "0";

        if (!CpStringUtil.isNumeric(v2)) {
            v2 = "0";
        }
        if (scale < 0)
            scale = 0;
        return new BigDecimal(v1).multiply(new BigDecimal(v2)).setScale(scale, BigDecimal.ROUND_UP).toPlainString();

    }

    /**
     *Provides accurate multiplication operations. (TODO rounding)
     *
     *@param v1 multiplicand
     *@param v2 multiplier
     *@return The product of two parameters
     */
    public static BigDecimal mul(String v1, String v2, int scale) {

        if (!CpStringUtil.isNumeric(v1))
            v1 = "0";

        if (!CpStringUtil.isNumeric(v2)) {
            v2 = "0";
        }
        if (scale < 0)
            scale = 0;
        return new BigDecimal(v1).multiply(new BigDecimal(v2)).setScale(scale, BigDecimal.ROUND_DOWN);

    }


    /**
     *Provide (relatively) accurate division operations, which are accurate to
     *Ten decimal places after the decimal point, and subsequent numbers are rounded off.
     *
     *@param v1 dividend
     *@param v2 divisor
     *@return The quotient of two parameters
     */
    public static BigDecimal div(String v1, String v2) {
        return div(v1, v2, DEF_DIV_SCALE);
    }

    /**
     *Provides (relatively) accurate division operations. When an inexhaustible division occurs, the scale parameter refers to
     *Fixed precision, subsequent digits rounded off.
     *
     *@param v1 dividend
     *@param v2 divisor
     *The @param scale indicates that it needs to be accurate to several decimal places.
     *@return The quotient of two parameters
     */
    public static BigDecimal div(String v1, String v2, int scale) {
        if (!CpStringUtil.isNumeric(v1))
            v1 = "0";

        if (!CpStringUtil.isNumeric(v2)) {
            v2 = "0";
        }

        if (0 == compareTo(v2, "0"))
            return new BigDecimal(v1);

        if (scale < 0) {
            scale = 0;
        }
        BigDecimal b1 = new BigDecimal(v1);
        BigDecimal b2 = new BigDecimal(v2);
        return b1.divide(b2, scale, BigDecimal.ROUND_DOWN);
    }

    public static String div(BigDecimal v1, BigDecimal v2, int scale) {
        return v1.divide(v2, scale, BigDecimal.ROUND_DOWN).toPlainString();
    }

    /**
     *This method does not round
     *Provides (relatively) accurate division operations. When an inexhaustible division occurs, the scale parameter refers to
     *Fixed accuracy.
     *
     *@param v1 parameter
     *The @param scale indicates that it needs to be accurate to several decimal places.
     *@return The quotient of two parameters
     */
    public static BigDecimal divForDown(String v1, int scale) {
        if (!CpStringUtil.checkStr(v1)) {
            v1 = "0";
        }
        if (!CpStringUtil.isNumeric(v1)) {
            v1 = "0";
        }
        if (scale < 0)
            scale = 0;
        return new BigDecimal(v1).setScale(scale, BigDecimal.ROUND_DOWN);
    }


    /**
     *This method is rounded
     *Provides (relatively) accurate division operations. When an inexhaustible division occurs, the scale parameter refers to
     *Fixed accuracy.
     *
     *@param v1 parameter
     *The @param scale indicates that it needs to be accurate to several decimal places.
     *@return The quotient of two parameters
     */
    public static BigDecimal divForUp(String v1, int scale) {
        if (!CpStringUtil.isNumeric(v1)) {
            v1 = "0";
        }
        if (scale < 0)
            scale = 0;

        return new BigDecimal(v1).setScale(scale, BigDecimal.ROUND_UP);
    }

    public static String scaleStr(String v1, int scale) {

        if (!CpStringUtil.isNumeric(v1)) {
            v1 = "0";
        }
        if (scale < 0)
            scale = 0;

        return new BigDecimal(v1).setScale(scale, BigDecimal.ROUND_FLOOR).toPlainString();
    }

    /**
     *Intercept Numbers
     *Rounding
     *
     * @param v1
     *The @param scale indicates that it needs to be accurate to several decimal places.
     * @return
     */
    public static BigDecimal intercept(String v1, int scale) {

        if (!CpStringUtil.isNumeric(v1)) {
            v1 = "0";
        }
        if (scale < 0)
            scale = 0;

        return new BigDecimal(v1).setScale(scale, BigDecimal.ROUND_HALF_UP);
    }


    /**
     *Compare two numbers accurately
     *
     *@param v1 The first number to be compared
     *@param v2 The second number to be compared
     *@return Returns 0 if the two numbers are the same, 1 if the first number is larger than the second number, and - 1 if the opposite is true
     */
    public static int compareTo(String v1, String v2) {

        if (!CpStringUtil.isNumeric(v1))
            v1 = "0";

        if (!CpStringUtil.isNumeric(v2)) {
            v2 = "0";
        }
        return new BigDecimal(v1).compareTo(new BigDecimal(v2));

    }

    public static String divStr(String v1, String v2, int scale) {
        if (!CpStringUtil.isNumeric(v1))
            v1 = "0";

        if (!CpStringUtil.isNumeric(v2)) {
            v2 = "0";
        }

        if (0 == compareTo(v2, "0"))
            return new BigDecimal(v1).toPlainString();

        if (scale < 0) {
            scale = 0;
        }
        BigDecimal b1 = new BigDecimal(v1);
        BigDecimal b2 = new BigDecimal(v2);
        return b1.divide(b2, scale, BigDecimal.ROUND_DOWN).toPlainString();
    }

    /**
     *Disable Scientific notation
     *
     *@return Returns the double type
     */
    public static double showDNormal(Double data) {
        return Double.valueOf(showSNormal(data));
    }

    /**
     *Disable Scientific notation
     *
     *@return Returns the double type
     */
    public static String showSNormal(Double data) {
        try {
            BigDecimal bigDecimal = new BigDecimal(String.valueOf(data));
            String plainString = bigDecimal.toPlainString();
            return subZeroAndDot(plainString);
        } catch (NumberFormatException e) {
            e.printStackTrace();
            return "0.0";
        }

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
        if (!CpStringUtil.checkStr(data)) {
            return "";
        }

        if (data.contains("\"")) {
            data = stringReplace(data);
        }
        if (!CpStringUtil.isNumeric(data)) {
            data = "0";
        }
        String plainString = new BigDecimal(data).toPlainString();
        return subZeroAndDot(plainString);
    }

    public static String showSNormal(String data, int scale) {
        if (!CpStringUtil.checkStr(data)) {
            return "";
        }

        if (data.contains("\"")) {
            data = stringReplace(data);
        }
        if (!CpStringUtil.isNumeric(data)) {
            data = "0";
        }
        String plainString = new BigDecimal(data).setScale(scale, BigDecimal.ROUND_DOWN).toPlainString();
//        return subZeroAndDot(plainString);
        return plainString;
    }

    public static String showSNormalUp(String data, int scale) {
        if (!CpStringUtil.checkStr(data)) {
            return "";
        }

        if (data.contains("\"")) {
            data = stringReplace(data);
        }
        if (!CpStringUtil.isNumeric(data)) {
            data = "0";
        }
        String plainString = new BigDecimal(data).setScale(scale, BigDecimal.ROUND_UP).toPlainString();
//        return subZeroAndDot(plainString);
        return plainString;
    }

    public static String showSNormalNew(String data, int scale) {
        if (!CpStringUtil.checkStr(data)) {
            return "--";
        }

        if (data.contains("\"")) {
            data = stringReplace(data);
        }
        if (!CpStringUtil.isNumeric(data)) {
            data = "0";
        }
        String plainString = new BigDecimal(data).setScale(scale, BigDecimal.ROUND_DOWN).toPlainString();
//        return subZeroAndDot(plainString);
        return plainString;
    }

    public static String showSNormalNew(String data) {
        if (!CpStringUtil.checkStr(data)) {
            return "";
        }

        if (data.contains("\"")) {
            data = stringReplace(data);
        }
        if (!CpStringUtil.isNumeric(data)) {
            data = "0";
        }
        String plainString = new BigDecimal(data).toPlainString();
        return plainString;
    }


    public static String showNormal(String data) {
        if (!CpStringUtil.isNumeric(data)) {
            return "0";
        }
        return new BigDecimal(data).toPlainString();
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

    /**
     *Using Java regular expressions to remove redundant. and 0
     *
     * @param s
     * @return
     */
    public static String subZeroAndDot(String s) {
        if (!CpStringUtil.isNumeric(s))
            return "0";

        if (s.indexOf(".") > 0) {
            s = s.replaceAll("0+?$", "");//Remove redundant 0
            s = s.replaceAll("[.]$", "");//Remove if the last digit is
        }
        return s;
    }


    public static String showDepthVolume(Context context,String value,int symbolPricePrecision) {
        if (!CpStringUtil.isNumeric(value))
            value = "0";

        String temp = new BigDecimal(value).toPlainString();
        if (compareTo(temp, "0.0001") <= 0) {
            return "0";
            // if (compareTo(temp, "1000") >= 0)
        } else {
            boolean iszh = CpLocalManageUtil.getSetLanguageLocale() == Locale.CHINA || CpLocalManageUtil.getSetLanguageLocale() == Locale.TAIWAN;
            if(iszh){
                return newFormatValueZh(context,value,symbolPricePrecision,true);
            }
            return newFormatValue(context,value,symbolPricePrecision,true);
        }
//        else {
//            if (temp.contains(".")) {
//                return (temp + "00000").substring(0, 5);
//            } else {
//                String substring = (temp + ".0000").substring(0, 4);
//                if (substring.endsWith(".")) {
//                    return substring.substring(0, 3);
//                } else {
//                    return substring;
//                }
//            }
//        }
    }

    public static String showDepthAmount(Context context,String amount,int symbolPricePrecision){
        boolean iszh = CpLocalManageUtil.getSetLanguageLocale() == Locale.CHINA || CpLocalManageUtil.getSetLanguageLocale() == Locale.TAIWAN;
        if(iszh){
            return newFormatValueZh(context,amount,symbolPricePrecision,false);
        }
        return newFormatValue(context,amount,symbolPricePrecision,false);
    }

    /**
     *@ description Transaction volume display (new languages other than Simplified Chinese and Traditional Chinese)
     *Original value of @param amount
     *@param context Context
     *@param symbolPricePrecision Pricing currency configuration precision
     *@param isNeedUnit: Does it need to determine Zhang Heyuan
     * */
    public static String newFormatValue(Context context,String amount,int symbolPricePrecision,boolean isNeedUnit){
        if(!CpStringUtil.isNumeric(amount)) return "--";
        BigDecimal b1 = new BigDecimal("1000000");
        BigDecimal b2 = new BigDecimal("1000000000");

        //24-hour turnover
        BigDecimal bgAmount = new BigDecimal(amount);
        //0 pieces and 1 coin
        int coUnit = CpClLogicContractSetting.getContractUint(context);

        //If yes, no accuracy No, 2-bit accuracy
        int precision = 2;
        int symbolPrecision = coUnit==0&&isNeedUnit ? 0 : symbolPricePrecision;

        //0<=24-hour turnover<1000000
        boolean case1 = bgAmount.compareTo(BigDecimal.ZERO) >= 0 && bgAmount.compareTo(b1) < 0;
        //1000000<=24h trading volume<1000000000
        boolean case2 = bgAmount.compareTo(b1) >= 0 && bgAmount.compareTo(b2) < 0;
        //1000000000<=24-hour trading volume
        boolean case3 = bgAmount.compareTo(b2) >= 0;

        String defVal = bgAmount.setScale(symbolPrecision,BigDecimal.ROUND_DOWN).toPlainString();

        if(case1){
            //The maximum accuracy is the configuration accuracy of the pricing currency, such as 999876.0987
            return defVal;
        }else if(case2){
            //The display unit is M, the maximum accuracy is 2, and the displayed value=original value/1000000. For example, 22230000 is displayed as 22.23M
            return div(bgAmount,b1,precision) + "M";
        }else if(case3){
            //Display unit is B, maximum accuracy is 2, display value=original value/1000000000, such as 2223000000, display is 22.23B
            return div(bgAmount,b2,precision) + "B";
        }
        return defVal;
    }


    /**
     *@ description Transaction volume display (new simplified Chinese and traditional Chinese)
     *Original value of @param amount
     *@param context Context
     *@param symbolPricePrecision Pricing currency configuration precision
     *@param isNeedUnit: Does it need to determine Zhang Heyuan
     * */
    public static String newFormatValueZh(Context context,String amount,int symbolPricePrecision,boolean isNeedUnit){
        if(!CpStringUtil.isNumeric(amount)) return "--";
        BigDecimal b1 = new BigDecimal("10000");
        BigDecimal b2 = new BigDecimal("100000000");

        //24-hour turnover
        BigDecimal bgAmount = new BigDecimal(amount);
        //0 pieces and 1 coin
        int coUnit = CpClLogicContractSetting.getContractUint(context);

        //If yes, no accuracy No, 2-bit accuracy
        int precision = 2;
        int symbolPrecision = coUnit==0&&isNeedUnit ? 0 : symbolPricePrecision;

        //0<=24-hour turnover<10000
        boolean case1 = bgAmount.compareTo(BigDecimal.ZERO) >= 0 && bgAmount.compareTo(b1) < 0;
        //10000<=24h trading volume<100000000
        boolean case2 = bgAmount.compareTo(b1) >= 0 && bgAmount.compareTo(b2) < 0;
        //100000000<=24h trading volume
        boolean case3 = bgAmount.compareTo(b2) >= 0;

        String defVal = bgAmount.setScale(symbolPrecision,BigDecimal.ROUND_DOWN).toPlainString();

        if(case1){
            //The maximum accuracy is the configuration accuracy of the pricing currency, such as 999876.0987
            return defVal;
        }else if(case2){
            //The display unit is M, the maximum accuracy is 2, and the displayed value=the original value/10000. For example, 222300 is displayed as 222300
            return div(bgAmount,b1,precision) + "万";
        }else if(case3){
            //Display unit is B, maximum accuracy is 2, display value=original value/100000000, such as 2223000000, display value is 2.223 billion
            return div(bgAmount,b2,precision) + "亿";
        }
        return defVal;
    }

//    public static String showDepthContractVolume(String value) {
//        if (!CpStringUtil.isNumeric(value))
//            value = "0";
//
//        String temp = new BigDecimal(value).toPlainString();
//        if (compareTo(temp, "1000") >= 0) {
//            return formatNumber(temp);
//        } else {
//            return temp;
//        }
//    }

    public static String formatNumber(String str) {
        Log.d("==111=", "" + str);
        if (!CpStringUtil.isNumeric(str))
            return "--";
        String number = "";
        BigDecimal b0 = new BigDecimal("1000");
        BigDecimal b1 = new BigDecimal("1000000");
        BigDecimal b2 = new BigDecimal("1000000000");
        BigDecimal temp = new BigDecimal(str);
        if (temp.compareTo(b0) == -1) {
            number = str;
            return showSNormal(number);
        } else if ((temp.compareTo(b0) == 0 || temp.compareTo(b0) == 1) && temp.compareTo(b1) == -1) {
            String substring = temp.divide(b0, 2, BigDecimal.ROUND_DOWN).toString().substring(0, 4);
            if (substring.endsWith(".")) {
                number = substring.substring(0, 3);
            } else {
                number = substring;
            }
            return number + "K";
        } else if (temp.compareTo(b1) >= 0 && temp.compareTo(b2) < 0) {
            Log.d("==111=", "M" + str);
            String substring = temp.divide(b1, 2, BigDecimal.ROUND_DOWN).toString().substring(0, 4);
            if (substring.endsWith(".")) {
                number = substring.substring(0, 3);
            } else {
                number = substring;
            }
            return number + "M";
        } else if (temp.compareTo(b2) >= 0) {
            Log.d("==111=", "B" + str);
            String substring = temp.divide(b2, 2, BigDecimal.ROUND_DOWN).toString().substring(0, 4);
            if (substring.endsWith(".")) {
                number = substring.substring(0, 3);
            } else {
                number = substring;
            }
            return number + "B";
        } else {
            return showSNormal(number);
        }
    }

    public static int compareToDraw(String v1, String v2) {
        if (!CpStringUtil.isNumeric(v1))
            v1 = "0";

        if (v1.equals("0")) {
            return -1;
        }
        return compareTo(v1, v2);
    }


    /**
     *Determine whether num1 is greater than num2
     *
     * @param num1
     * @param num2
     *@return num1 greater than num2 returns true
     */
    public static boolean greaterThan(String num1, String num2) {
        BigDecimal b1 = new BigDecimal(num1);
        BigDecimal b2 = new BigDecimal(num2);
        return b1.compareTo(b2) == 1;
    }

    /**
     *Calculate the quantity available for purchase and sale
     *
     * @return
     */
    public static String canBuyStr(boolean isOpen, boolean isLimit, boolean isForward, String price, String parValue, String canUseAmount, String canCloseVolume, String nowLevel, String rate, int scale, String unit) {

        String defaultStr = "0" + " " + unit;
        if (CpClLogicContractSetting.getContractUint(CpMyApp.Companion.instance()) != 0) {
            defaultStr = "0.00" + " " + unit;
        } else {
            defaultStr = "0" + " " + unit;
        }
        ChainUpLogUtil.e("是否属于只减仓", isOpen + "");
        BigDecimal parValueBig = new BigDecimal(parValue);
        BigDecimal canCloseVolumeBig = new BigDecimal(canCloseVolume);
        BigDecimal buff;
        if (!CpClLogicContractSetting.isLogin()) {
            return defaultStr;
        }
        if (!isOpen) {
            if (CpClLogicContractSetting.getContractUint(CpMyApp.Companion.instance()) == 0) {
                return canCloseVolumeBig.setScale(0, BigDecimal.ROUND_DOWN).toPlainString() + " " + unit;
            } else {
                return parValueBig.multiply(canCloseVolumeBig).setScale(scale, BigDecimal.ROUND_DOWN).toPlainString() + " " + unit;
            }
        }
        if (compareTo(price, "0") == 0 || compareTo(rate, "0") == 0) {
            return defaultStr;
        }
        BigDecimal priceBig = new BigDecimal(price);
        BigDecimal canUseAmountBig = new BigDecimal(canUseAmount);
        BigDecimal nowLevelBig = new BigDecimal(nowLevel);
        BigDecimal rateBig = new BigDecimal(rate);
        ChainUpLogUtil.e("parValueBig", parValueBig.toPlainString());
        ChainUpLogUtil.e("canCloseVolumeBig", canCloseVolumeBig.toPlainString());
        ChainUpLogUtil.e("priceBig", priceBig.toPlainString());
        ChainUpLogUtil.e("canUseAmountBig", canUseAmountBig.toPlainString());
        ChainUpLogUtil.e("nowLevelBig", nowLevelBig.toPlainString());
        ChainUpLogUtil.e("rateBig", rateBig.toPlainString());

        if (isForward) {
            buff = canUseAmountBig.multiply(nowLevelBig).divide(priceBig, scale, BigDecimal.ROUND_DOWN).divide(rateBig, scale, BigDecimal.ROUND_DOWN);
        } else {
            buff = canUseAmountBig.multiply(nowLevelBig).multiply(priceBig).divide(rateBig, scale, BigDecimal.ROUND_DOWN);
        }
        if (CpClLogicContractSetting.getContractUint(CpMyApp.Companion.instance()) == 0) {
            scale = 0;
            buff = buff.divide(parValueBig, scale, BigDecimal.ROUND_DOWN);
        }
        return buff.setScale(scale, BigDecimal.ROUND_DOWN).toPlainString() + " " + unit;
    }

    /**
     *Calculate the quantity that can be opened
     * <p>
     * <p>
     *Maximum openable number/quantity=min {openable number for risk limit calculation, openable number for margin calculation}
     * <p>
     *Calculation of opening number for risk limit calculation:
     *Forward direction: Maximum opening amount=(Maximum opening limit of current contract - Value of positions held in the same direction of current contract - Value of outstanding consignments in the same direction of current contract) * Exchange rate/(Price * Face value)
     *Reverse: Maximum number of open positions=(Maximum number of open positions for the current contract - Value of open positions in the same direction of the current contract - Value of outstanding consignments in the same direction of the current contract) * Price/face value
     *Forward direction: Maximum openable amount=(Maximum openable amount of current contract - Value of open positions in the same direction of current contract - Value of outstanding consignments in the same direction of current contract) * Exchange rate/price
     *Reverse: Maximum openable amount=(Maximum openable amount of current contract - Value of open positions in the same direction of current contract - Value of outstanding consignments in the same direction of current contract) * Price
     * <p>
     *Calculation of position value:
     *Positive direction: position value=average position price * position quantity * contract face value * exchange rate
     *Reverse: position value=position quantity * contract face value/average position price
     *Calculation of entrusted value:
     *Forward direction: Consignment value=Consignment price * Opening consignment quantity * Contract face value * Exchange rate
     *Reverse: Consignment Value=Opening Consignment Quantity * Contract Face Value/Consignment Price
     *
     * @return
     */
    public static String canOpenStr(boolean isForward, boolean isLimit, String price, String maxOpenLimit, String positionValue, String entrustedValue, String parValue, String rate, int scale, String unit) {
        String defaultStr = "0" + " " + unit;
        if (CpClLogicContractSetting.getContractUint(CpMyApp.Companion.instance()) != 0) {
            defaultStr = "0.00" + " " + unit;
        } else {
            defaultStr = "0" + " " + unit;
        }
        if (TextUtils.isEmpty(parValue)) parValue = "0";
        if (TextUtils.isEmpty(price)) price = "0";
        if (TextUtils.isEmpty(maxOpenLimit)) maxOpenLimit = "0";
        if (TextUtils.isEmpty(positionValue)) positionValue = "0";
        if (TextUtils.isEmpty(entrustedValue)) entrustedValue = "0";
        BigDecimal parValueBig = new BigDecimal(parValue);
        BigDecimal priceBig = new BigDecimal(price);
        BigDecimal rateBig = new BigDecimal(rate);
        BigDecimal maxOpenLimitBig = new BigDecimal(maxOpenLimit);//（币的单位）
        BigDecimal positionValueBig = new BigDecimal(positionValue);//（币的单位）
        BigDecimal entrustedValueBig = new BigDecimal(entrustedValue);//（币的单位）
        ChainUpLogUtil.e("ClContractTradeFragment", "parValue:" + parValueBig.toPlainString());
        ChainUpLogUtil.e("ClContractTradeFragment", "price:" + priceBig.toPlainString());
        ChainUpLogUtil.e("ClContractTradeFragment", "rate:" + rateBig.toPlainString());
        ChainUpLogUtil.e("ClContractTradeFragment", "maxOpenLimit:" + maxOpenLimitBig.toPlainString());
        ChainUpLogUtil.e("ClContractTradeFragment", "positionValue:" + positionValueBig.toPlainString());
        ChainUpLogUtil.e("ClContractTradeFragment", "entrustedValue:" + entrustedValueBig.toPlainString());
        BigDecimal buff;
        if (compareTo(price, "0") == 0) {
            return defaultStr;
        }
        //Zhang
        //Nominal value
        //Reverse * Price/face value
        //Coins
        //Forward/Price
        //Reverse * Price
        if (CpClLogicContractSetting.getContractUint(CpMyApp.Companion.instance()) == 0) {
            if (isForward) {
                if (isLimit) {
                    buff = (maxOpenLimitBig.subtract(positionValueBig).subtract(entrustedValueBig)).divide((priceBig.multiply(parValueBig)), scale, BigDecimal.ROUND_DOWN);
                } else {
                    buff = (maxOpenLimitBig.subtract(positionValueBig).subtract(entrustedValueBig)).multiply(rateBig).divide((priceBig.multiply(parValueBig)), scale, BigDecimal.ROUND_DOWN);
                }
            } else {
                if (isLimit) {
                    buff = (maxOpenLimitBig.subtract(positionValueBig).subtract(entrustedValueBig)).multiply(priceBig).divide(parValueBig, scale, BigDecimal.ROUND_DOWN);
                } else {
                    try{
                        buff = (maxOpenLimitBig.subtract(positionValueBig).subtract(entrustedValueBig)).multiply(priceBig).divide(parValueBig, scale, BigDecimal.ROUND_DOWN);
                    }catch (Exception e){
                        e.printStackTrace();
                        buff = new BigDecimal(0);
                    }

                }
            }
            return buff.setScale(0, BigDecimal.ROUND_DOWN).toPlainString() + " " + unit;
        } else {
            if (isForward) {
                if (isLimit) {
                    buff = (maxOpenLimitBig.subtract(positionValueBig).subtract(entrustedValueBig)).divide(priceBig, scale, BigDecimal.ROUND_DOWN);
                } else {
                    buff = (maxOpenLimitBig.subtract(positionValueBig).subtract(entrustedValueBig)).multiply(rateBig).divide(priceBig, scale, BigDecimal.ROUND_DOWN);
                }
            } else {
                if (isLimit) {
                    buff = (maxOpenLimitBig.subtract(positionValueBig).subtract(entrustedValueBig)).multiply(priceBig);
                } else {
                    buff = (maxOpenLimitBig.subtract(positionValueBig).subtract(entrustedValueBig)).multiply(priceBig);
                }
            }
            return buff.setScale(scale, BigDecimal.ROUND_DOWN).toPlainString() + " " + unit;
        }
    }


    /**
     * 合约最大可开价值计算
     * 1）根据风险限额计算的最大可开：
     * 正向&反向：最大可开价值 = 当前合约最大可开额度-当前合约所有持仓仓位价值-当前合约所有未成交开仓委托价值
     * */
    public static String calcMaxValueByRisk(String maxOpenLimit, String positionValue, String entrustedValue) {
        BigDecimal maxOpenLimitBig = new BigDecimal(maxOpenLimit);
        BigDecimal positionValueBig = new BigDecimal(positionValue);
        BigDecimal entrustedValueBig = new BigDecimal(entrustedValue);
        BigDecimal resultValue = maxOpenLimitBig.subtract(positionValueBig).subtract(entrustedValueBig);
        return resultValue.toPlainString().trim();
    }

    /**
     * 2）根据可用余额计算的最大可开
     * 根据可用余额计算的最大可开（价值）：
     * 正向&反向：最大可开 = 可用余额 *杠杆
     * */
    public static String calcMaxValueByMarginCoinAmount(String canUseAmount, String nowLevel){
        BigDecimal canUseAmountBig = new BigDecimal(canUseAmount);
        BigDecimal nowLevelBig = new BigDecimal(nowLevel);
        BigDecimal resultValue = canUseAmountBig.multiply(nowLevelBig);
        return resultValue.toPlainString().trim();
    }

    /**
     * 最大可开价值 = min{风险限额计算的可开价值，保证金计算的可开价值}
     *
     * */
    public static String getMaxCanOpenValue(String maxValueByRisk,String maxValueByMarginCoinAmount){
        return min(maxValueByRisk,maxValueByMarginCoinAmount).trim();
    }

    public static String getUIMaxOpen(boolean isForward,boolean isOpen,String multiplier,String price,String maxValue,String canCloseVolume,int scale,String unit){

        String value = canUSDTPositionStr(isForward,maxValue,price,scale,unit);
        String tempValue = value.split(" ")[0];
        BigDecimal bgCanCloseVolume = new BigDecimal(canCloseVolume);

        boolean isZhang = CpClLogicContractSetting.getContractUint(CpMyApp.Companion.instance()) == 0;
        if (!isOpen) {

            if (isZhang) {
                return bgCanCloseVolume.setScale(0, BigDecimal.ROUND_DOWN).toPlainString().trim();
            } else {
                return mulStr(multiplier,canCloseVolume,scale).trim();
            }
        }

        if(isZhang){
            return divStr(tempValue,multiplier,0).trim();
        }else{
            return divForDown(tempValue.trim(),scale).toPlainString();
        }
    }


    /**
     *Calculate position value
     *Positive direction: position value=average position price * position quantity * contract face value * exchange rate
     *Reverse: position value=position quantity * contract face value/average position price
     *
     * @return
     */
    public static String calcPositionValue(boolean isForward, String positionNum, String positionAveragePrice, String parValue, String rate, int scale) {
        if (TextUtils.isEmpty(positionNum)) positionNum = "0";
        if (TextUtils.isEmpty(positionAveragePrice)) positionAveragePrice = "0";
        if (TextUtils.isEmpty(parValue)) parValue = "0";
        BigDecimal positionNumBig = new BigDecimal(positionNum);
        BigDecimal parValueBig = new BigDecimal(parValue);
        BigDecimal positionAveragePriceBig = new BigDecimal(positionAveragePrice);
        BigDecimal rateBig = new BigDecimal(rate);

        if (isForward) {
            //Position value=Average position price * Number of positions * face value of contract * exchange rate
            return positionAveragePriceBig.multiply(positionNumBig).multiply(parValueBig).multiply(rateBig).setScale(scale, BigDecimal.ROUND_HALF_DOWN).toPlainString();
        } else {
            //Reverse: Position value=Position quantity * Contract face value/coverage position price
            return positionNumBig.multiply(parValueBig).divide(positionAveragePriceBig, scale, BigDecimal.ROUND_HALF_DOWN).toPlainString();
        }
    }

    /**
     *Calculate commission value
     *Forward direction: Consignment value=Consignment price * Opening consignment quantity * Contract face value * Exchange rate
     *Reverse: Consignment Value=Opening Consignment Quantity * Contract Face Value/Consignment Price
     *
     * @return
     */
    public static String calcEntrustedValue(boolean isForward, String entrustedPrice, String openEntrustedNum, String parValue, String rate, int scale) {
        if (TextUtils.isEmpty(entrustedPrice)) entrustedPrice = "0";
        if (TextUtils.isEmpty(parValue)) parValue = "0";
        if (TextUtils.isEmpty(openEntrustedNum)) openEntrustedNum = "0";
        BigDecimal entrustedPriceBig = new BigDecimal(entrustedPrice);
        BigDecimal parValueBig = new BigDecimal(parValue);
        BigDecimal openEntrustedNumBig = new BigDecimal(openEntrustedNum);
        BigDecimal rateBig = new BigDecimal(rate);
        if (isForward) {
            //Entrustment value=Entrustment price * Opening signature quantity * contract face value * exchange rate
            return entrustedPriceBig.multiply(openEntrustedNumBig).multiply(parValueBig).multiply(rateBig).setScale(scale, BigDecimal.ROUND_HALF_DOWN).toPlainString();
        } else {
            //Entrustment value=quantity of opening entrustment * Contract face value/commitment price
            return openEntrustedNumBig.multiply(parValueBig).divide(entrustedPriceBig, scale, BigDecimal.ROUND_HALF_DOWN).toPlainString();
        }
    }


    /**
     *Calculate estimated cost price
     *
     * @param orderType
     * @param price
     * @param position
     * @param nowLevel
     * @param rate
     * @param scale
     * @param unit
     * @return
     */
    public static String canCostStr(boolean isOpen, boolean isForward, int orderType, String price, String position, String parValue, String nowLevel, String rate, int scale, String unit) {
        Log.d("canCostStr","计算预估成本价 position=" + position);
        String defaultStr = "0" + " " + unit;
//        if (CpClLogicContractSetting.getContractUint(CpMyApp.Companion.instance()) != 0) {
//            defaultStr = "0.00" + " " + unit;
//        } else {
//            defaultStr = "0" + " " + unit;
//        }
        if (!isOpen) {
            return "0" + " " + unit;
        }
        if (TextUtils.isEmpty(position)) {
            return defaultStr;
        }
        String sheets = "0";

        if (CpClLogicContractSetting.getContractUint(CpMyApp.Companion.instance()) == 0) {
            sheets = position;
        } else {
            sheets = divStr(position, parValue, 0);
        }

        BigDecimal positionBig = new BigDecimal(position);
        BigDecimal sheetsBig = new BigDecimal(sheets);
        BigDecimal nowLevelBig = new BigDecimal(nowLevel);
        BigDecimal parValueBig = new BigDecimal(parValue);
        BigDecimal rateBig = new BigDecimal(rate);

        BigDecimal buff = null;

        if (orderType == 1 || orderType == 4 || orderType == 5 || orderType == 6) { //Limit Order, PostOnly, IOC, FOK
            if (TextUtils.isEmpty(price)) {
                return defaultStr;
            }
            if (compareTo(price, "0") != 1) {
                return defaultStr;
            }
            BigDecimal priceBig = new BigDecimal(price);
            if (isForward) {
                buff = sheetsBig.multiply(parValueBig).multiply(priceBig).divide(nowLevelBig, scale, BigDecimal.ROUND_HALF_DOWN).multiply(rateBig);
            } else {
                buff = sheetsBig.multiply(parValueBig).divide(priceBig, scale, BigDecimal.ROUND_HALF_DOWN).divide(nowLevelBig, scale, BigDecimal.ROUND_HALF_DOWN).multiply(rateBig);
            }
        } else if (orderType == 2) {//Market Price List
            buff = positionBig.divide(nowLevelBig, scale, BigDecimal.ROUND_HALF_DOWN).multiply(rateBig);
        } else if (orderType == 3) {//Condition sheet
            //0 Limit Price 1 Market Price
            if (CpClLogicContractSetting.getExecution(CpMyApp.Companion.instance()) == 1) {
                //Conditional Market Price List
                buff = positionBig.divide(nowLevelBig, scale, BigDecimal.ROUND_HALF_DOWN).multiply(rateBig);
            } else {
                //Conditional price limit list
                if (TextUtils.isEmpty(price)) {
                    return defaultStr;
                }
                if (compareTo(price, "0") != 1) {
                    return defaultStr;
                }
                BigDecimal priceBig = new BigDecimal(price);
                if (isForward) {
                    buff = sheetsBig.multiply(parValueBig).multiply(priceBig).divide(nowLevelBig, scale, BigDecimal.ROUND_HALF_DOWN).multiply(rateBig);
                } else {
                    buff = sheetsBig.multiply(parValueBig).divide(priceBig, scale, BigDecimal.ROUND_HALF_DOWN).divide(nowLevelBig, scale, BigDecimal.ROUND_HALF_DOWN).multiply(rateBig);
                }
            }
        } else {
            return "0" + " " + unit;
        }
        return buff.setScale(scale, BigDecimal.ROUND_HALF_DOWN).stripTrailingZeros().toPlainString() + " " + unit;
    }

    /**
     *Calculation quantity conversion display
     *
     * @param position
     * @param parValue
     * @param scale
     * @param unit
     * @return
     */
    public static String canPositionStr(String position, String parValue, int scale, String unit) {
        String defaultStr = "";
        if (CpClLogicContractSetting.getContractUint(CpMyApp.Companion.instance()) != 0) {
            defaultStr = "0.00" + " " + unit;
        } else {
            defaultStr = "0" + " " + unit;
        }
        //0 pieces and 1 coin
        if (TextUtils.isEmpty(position)) {
            return defaultStr;
        }
        if (CpClLogicContractSetting.getContractUint(CpMyApp.Companion.instance()) == 0) {
            //Quantity=Number of sheets * Nominal value
            return mulStr(position, parValue, scale) + " " + unit;
        } else {
            //Sheet=quantity/face value
            return divStr(position, parValue, 0) + " " + unit;

        }
    }

    /**
     *Data display of calculated market price list/conditional market price list
     *
     *@param openValue Opening Value
     *@param price The latest price on this exchange
     *@param scale precision
     *@param unit
     *@param isForward Whether to enter a forward contract
     *@param marginRate Margin exchange rate
     * @return
     */
    public static String canPositionMarketStr(boolean isForward, String marginRate, String parValue, String openValue, String price, int scale, String unit,boolean isMarketOrder) {
        String defaultStr = "";
        if (CpClLogicContractSetting.getContractUint(CpMyApp.Companion.instance()) != 0) {
            defaultStr = "0.00" + " " + unit;
        } else {
            defaultStr = "0" + " " + unit;
        }
        if (TextUtils.isEmpty(openValue)) {
            return defaultStr;
        }
        if (TextUtils.isEmpty(price) || price.equals("0") || !CpStringUtil.isNumeric(price)) {
            return defaultStr;
        }
        /**
         *Forward contract
         *≈ Opening Value/Latest Exchange Price {Coin}
         *≈ Opening value/Latest price of this exchange/Nominal value {pieces}
         *
         *Reverse contract
         *≈ Opening Value * Latest Exchange Price {Coin}
         *≈ Opening value * Latest price/face value of this exchange {pieces}
         */
        BigDecimal openValueBig = new BigDecimal(openValue);
        BigDecimal priceBig = new BigDecimal(price);
        BigDecimal marginRateBig = new BigDecimal(marginRate);
        BigDecimal parValueBig = new BigDecimal(parValue);

        BigDecimal buff;
        if (isForward) {
            buff = openValueBig.divide(priceBig, scale, BigDecimal.ROUND_DOWN);
        } else {
            buff = openValueBig.multiply(priceBig);
        }
        if(isMarketOrder){
            if (CpClLogicContractSetting.getContractUint(CpMyApp.Companion.instance()) == 0) {
                return buff.divide(parValueBig, 0, BigDecimal.ROUND_DOWN).toPlainString() + " " + unit;
            } else {
                return buff.setScale(scale, BigDecimal.ROUND_DOWN).toPlainString() + " " + unit;

            }
        }else{
            if (CpClLogicContractSetting.getContractUint(CpMyApp.Companion.instance()) == 0) {
                return buff.setScale(scale, BigDecimal.ROUND_HALF_DOWN).toPlainString() + " " + unit;
            } else {
                return buff.divide(parValueBig, 0, BigDecimal.ROUND_HALF_DOWN).toPlainString() + " " + unit;
            }
        }

    }

    /**
     *Calculate Median
     *
     * @param buyOne
     * @param sellOne
     * @param latestPrice
     * @return
     */
    public static String median(String buyOne, String sellOne, String latestPrice) {
        if (compareTo(buyOne, "0") == 0 && compareTo(sellOne, "0") == 0) {
            if (compareTo(latestPrice, "0") == 0) {
                return "0";
            } else {
                return latestPrice;
            }
        }
        String[] arr = {buyOne, sellOne, latestPrice};
        Arrays.sort(arr);
        return arr[1];
    }

    public static String min(String oneStr, String towStr) {
        if (compareTo(oneStr, towStr) == -1) {
            return oneStr;
        }
        return towStr;
    }

    /**
     *Minimum Quantity Verification for Ordering
     *
     * @param minNum unit:xxx cont.
     * @param inputNum unit: CpClLogicContractSetting.getContractUint(CpMyApp.Companion.instance()) ==0 ?
     * @return
     */
    public static boolean orderNumMinCheck(String inputNum, String minNum, String multiplier) {
        int ret;
        if (CpClLogicContractSetting.getContractUint(CpMyApp.Companion.instance()) == 0) {
            ret = compareTo(minNum, inputNum);
        } else {
            BigDecimal multiplierBig = new BigDecimal(multiplier);
            BigDecimal minNumBig = new BigDecimal(minNum);
            String minVal = minNumBig.multiply(multiplierBig).toPlainString();
            ret = compareTo(minVal, inputNum);
        }
        //"If the two numbers are the same, 0 is returned. If the first number is larger than the second number, 1 is returned. Otherwise, - 1 is returned."
        return ret == 1;
    }

    /**
     *Verification of the maximum number of orders placed
     * @param inputNum unit: CpClLogicContractSetting.getContractUint(CpMyApp.Companion.instance()) ==0 ?
     * @param maxNum unit:xxx cont.
     * @return
     */
    public static boolean orderNumMaxCheck(String inputNum, String maxNum, String multiplier) {
        int ret = 0;
        if (CpClLogicContractSetting.getContractUint(CpMyApp.Companion.instance()) == 0) {
            ret = compareTo(inputNum, maxNum);
        } else {
            BigDecimal multiplierBig = new BigDecimal(multiplier);
            BigDecimal maxNumBig = new BigDecimal(maxNum);
            String maxVal = maxNumBig.multiply(multiplierBig).toPlainString();
            ret = compareTo(inputNum, maxVal);
        }
        //"If the two numbers are the same, 0 is returned. If the first number is larger than the second number, 1 is returned. Otherwise, - 1 is returned."
        return ret == 1;
    }

    /**
     *Verification of minimum amount for placing an order
     *
     * @param inputNum
     * @return
     */
    public static boolean orderMoneyMinCheck(String inputNum, String minNum, String multiplier) {
        int ret = 0;
        ret = compareTo(minNum, inputNum);
        //"If the two numbers are the same, 0 is returned. If the first number is larger than the second number, 1 is returned. Otherwise, - 1 is returned."
        return ret == 1;
    }

    /**
     *Verification of maximum amount for placing an order
     *
     * @param inputNum
     * @return
     */
    public static boolean orderMoneyMaxCheck(String inputNum, String maxNum, String multiplier) {
        int ret = 0;
        ret = compareTo(inputNum, maxNum);
        //"If the two numbers are the same, 0 is returned. If the first number is larger than the second number, 1 is returned. Otherwise, - 1 is returned."
        return ret == 1;
    }

    /**
     *Calculate the order quantity (currency converted to pieces)
     *
     * @param inputNum
     * @param multiplier
     * @return
     */
    public static String getOrderNum(boolean isOpen, String inputNum, String multiplier, int orderType) {
        if (orderType == 2) {//Market Price List
            if (isOpen) {
                return inputNum;
            }
        } else if (orderType == 3) {//Condition sheet
            //0 Limit Price 1 Market Price
            if (CpClLogicContractSetting.getExecution(CpMyApp.Companion.instance()) == 1) {
                //Conditional Market Price List
                if (isOpen) {
                    return inputNum;
                }
            }
        }
        if (CpClLogicContractSetting.getContractUint(CpMyApp.Companion.instance()) == 0) {
            return new BigDecimal(inputNum).setScale(0, BigDecimal.ROUND_DOWN).toPlainString();
        } else {
            BigDecimal multiplierBig = new BigDecimal(multiplier);
            BigDecimal inputNumBig = new BigDecimal(inputNum);
            return inputNumBig.divide(multiplierBig, 0, BigDecimal.ROUND_DOWN).toPlainString();
        }
    }

    public static String getOrderLossNum(String inputNum, String multiplier) {
        if (TextUtils.isEmpty(inputNum)) {
            inputNum = "0";
        }
        if (CpClLogicContractSetting.getContractUint(CpMyApp.Companion.instance()) == 0) {
            return new BigDecimal(inputNum).setScale(0, BigDecimal.ROUND_FLOOR).toPlainString();
        } else {
            BigDecimal multiplierBig = new BigDecimal(multiplier);
            BigDecimal inputNumBig = new BigDecimal(inputNum);
            return inputNumBig.divide(multiplierBig, 0, BigDecimal.ROUND_HALF_DOWN).toPlainString();
        }
    }

    /**
     *Calculate warehouse by warehouse equity
     *
     *@param positionMargin
     *@param realizedAmount realized profit and loss
     *@param unRealizedAmount Unrealized profit/loss
     *@return Position margin+realized gains and losses+unrealized gains and losses
     */

    public static String calcPositionEquity(String positionMargin, String realizedAmount, String unRealizedAmount, int scale) {
        BigDecimal positionMarginBig = new BigDecimal(positionMargin);
        BigDecimal realizedAmountBig = new BigDecimal(realizedAmount);
        BigDecimal unRealizedAmountBig = new BigDecimal(unRealizedAmount);
        return positionMarginBig.add(realizedAmountBig).add(unRealizedAmountBig).setScale(scale, BigDecimal.ROUND_HALF_DOWN).toPlainString();
    }

    /**
     *Calculate Qiangping Price
     *
     *@param positionEquity
     *@param marginRate Margin exchange rate
     *@param positionVolume Number of positions
     *@param positionDirection Position direction
     *@param markPrice Tag Price
     *@param keepMarginRate Maintain margin rate
     *@param feeRate
     *@param scale Configuration progress of pricing currency symbolPricePrecision
     *@return Strong leveling price (positive contract)=(position by position equity/margin exchange rate - position quantity * position direction * marked price)/(maintain margin rate+commission rate) * position quantity - position * position direction)
     *Qiangping Price (Reverse Contract)=((Maintain Margin Rate+Handling Rate) * Position Quantity+Position * Position Direction)/(Position by Position Equity/Margin Exchange Rate+Position Quantity * Position Direction/Mark Price)
     */
    public static String calcForcedPrice(boolean isForward, String positionEquity, String positionVolume, String positionDirection, String markPrice, String keepMarginRate, String feeRate, int scale) {
        final int defScale = 16;
        BigDecimal positionEquityBig = new BigDecimal(positionEquity);
        BigDecimal positionVolumeBig = new BigDecimal(positionVolume);
        BigDecimal markPriceBig = new BigDecimal(markPrice);
        BigDecimal keepMarginRateBig = new BigDecimal(keepMarginRate);
        BigDecimal feeRateBig = new BigDecimal(feeRate);
        final boolean openMore = "1".equals(positionDirection);
        BigDecimal resultBg;
        if (isForward) {
            if(openMore){
                // 多头：强平价格 = （仓位数量 * 标价价格 - 逐仓保证金权益 ） / （（1 - 维持保证金率 - 手续费率）* 仓位数量）
                resultBg = (positionVolumeBig.multiply(markPriceBig).subtract(positionEquityBig))
                        .divide(
                                (BigDecimal.ONE.subtract(keepMarginRateBig).subtract(feeRateBig)).multiply(positionVolumeBig),
                                scale,BigDecimal.ROUND_DOWN
                        );
            }else{
                // 空头：强平价格 = （仓位数量 * 标价价格 + 逐仓保证金权益 ） / （（1 + 维持保证金率 + 手续费率）* 仓位数量）
                resultBg = (positionVolumeBig.multiply(markPriceBig).add(positionEquityBig))
                        .divide(
                                (BigDecimal.ONE.add(keepMarginRateBig).add(feeRateBig)).multiply(positionVolumeBig),
                                scale,BigDecimal.ROUND_DOWN
                        );
            }

        } else {
            // 多头：强平价格 = （1 + 维持保证金率 + 手续费率）* 仓位数量 /（（仓位数量/标价价格）+ 逐仓保证金权益）
            if(openMore){
                resultBg =
                    ((BigDecimal.ONE.add(keepMarginRateBig).add(feeRateBig)).multiply(positionVolumeBig)).divide(
                    (
                        (positionVolumeBig.divide(markPriceBig,defScale,BigDecimal.ROUND_HALF_DOWN))
                                .add(positionEquityBig)
                    )
                    ,scale,BigDecimal.ROUND_DOWN);

            }else{
                // 空头：强平价格 = （1 - 维持保证金率 - 手续费率）* 仓位数量 /（（仓位数量/持标价价格）- 逐仓保证金权益）
                resultBg =
                    ((BigDecimal.ONE.subtract(keepMarginRateBig).subtract(feeRateBig)).multiply(positionVolumeBig)).divide(
                        (
                            (positionVolumeBig.divide(markPriceBig,defScale,BigDecimal.ROUND_HALF_DOWN))
                                    .subtract(positionEquityBig)
                        )
                    ,scale,BigDecimal.ROUND_DOWN);
            }
        }
        return resultBg.toPlainString();

    }

    /**
     *Calculate opening margin
     *
     * @param amount
     * @param openingPrice
     * @param lever
     * @param marginRate
     * @param scale
     * @return
     */
    public static String calcMarginValue(boolean isForward, String amount, String openingPrice, String lever, String marginRate, int scale) {

        BigDecimal amountBig = new BigDecimal(amount);
        BigDecimal openingPriceBig = new BigDecimal(openingPrice);
        BigDecimal leverBig = new BigDecimal(lever);
        BigDecimal marginRateBig = new BigDecimal(marginRate);

        if (isForward) {
            //Forward contract: required margin=initial margin=quantity * Opening price/level/target exchange rate
            return amountBig.multiply(openingPriceBig).divide(leverBig, scale, BigDecimal.ROUND_DOWN).divide(marginRateBig, scale, BigDecimal.ROUND_DOWN).setScale(scale, BigDecimal.ROUND_DOWN).toPlainString();
        } else {
            //Reverse contract: required margin=initial margin=quantity/opening price/leverage/margin exchange rate
            return amountBig.divide(openingPriceBig, scale, BigDecimal.ROUND_DOWN).divide(leverBig, scale, BigDecimal.ROUND_DOWN).divide(marginRateBig, scale, BigDecimal.ROUND_DOWN).setScale(scale, BigDecimal.ROUND_DOWN).toPlainString();
        }
    }

    /**
     *Calculate income
     *
     *Is @param isForward a forward contract
     *@param direction 0 more 1 empty
     *@param amount quantity
     *@param openingPrice
     *@param closePrice Closing Price
     *@param marginRate Margin exchange rate
     *@param scale precision
     * @return
     */
    public static String calcIncomeValue(boolean isForward, int direction, String amount, String openingPrice, String closePrice, String marginRate, int scale) {

        BigDecimal amountBig = new BigDecimal(amount);
        BigDecimal openingPriceBig = new BigDecimal(openingPrice);
        BigDecimal closePriceBig = new BigDecimal(closePrice);
        BigDecimal marginRateBig = new BigDecimal(marginRate);
        /**
         *Income (Unit: Guarantee Currency)
         *Forward contract:
         *Return on long buying=(closing price - average opening price) * quantity/margin exchange rate
         *Proceeds from short selling=(closing price - average opening price) * quantity/margin exchange rate * - 1
         *
         *Reverse contract:
         *Return on long buying=(1/closing price - 1/average opening price) * quantity/margin exchange rate * - 1
         *Proceeds from short selling=(1/closing price - 1/average opening price) * quantity/margin exchange rate
         */
        String buff = "";
        if (isForward) {
            BigDecimal buff1 = closePriceBig.subtract(openingPriceBig);
            if (direction == 0) {
                //Buy long
                buff = buff1.multiply(amountBig).divide(marginRateBig, scale, BigDecimal.ROUND_DOWN).setScale(scale, BigDecimal.ROUND_DOWN).toPlainString();
            } else {
                //Selling short
                buff = buff1.multiply(amountBig).divide(marginRateBig, scale, BigDecimal.ROUND_DOWN).multiply(new BigDecimal("-1")).setScale(scale, BigDecimal.ROUND_DOWN).toPlainString();
            }
        } else {
            BigDecimal buff1 = BigDecimal.ONE.divide(closePriceBig, scale, BigDecimal.ROUND_DOWN);
            BigDecimal buff2 = BigDecimal.ONE.divide(openingPriceBig, scale, BigDecimal.ROUND_DOWN);
            BigDecimal buff3 = buff1.subtract(buff2);
            if (direction == 0) {
                //Buy long
                buff = buff3.multiply(amountBig).divide(marginRateBig, scale, BigDecimal.ROUND_DOWN).multiply(new BigDecimal("-1")).setScale(scale, BigDecimal.ROUND_DOWN).toPlainString();
            } else {
                //Selling short
                buff = buff3.multiply(amountBig).divide(marginRateBig, scale, BigDecimal.ROUND_DOWN).setScale(scale, BigDecimal.ROUND_DOWN).toPlainString();
            }
        }
        return buff;
    }

    /**
     *Calculate closing price
     *@param isForward a forward contract
     *@param direction 0 more 1 empty
     *@param amount rate of return
     *@param openingPrice
     *@param lever
     *@param scale precision
     *@return Closing Price
     */
    public static String calcClosePriceValue(boolean isForward, int direction, String amount, String openingPrice, String lever, int scale) {

        BigDecimal amountBig = CpBigDecimalUtils.div(amount, "100", 5);
        BigDecimal openingPriceBig = new BigDecimal(openingPrice);
        BigDecimal leverBig = new BigDecimal(lever);
        /**
         Closing price (in quote currency)
         Forward contract:
         Buy Long Close Price = Open Price *(Leverage+Return)/Leverage
         Sell Short Close Price = Open Price * (Leverage Return)/Leverage

         Reverse contract:
         Buy Long Close Price = Open Price *Leverage/(Leverage Return)
         Sell Short Close Price = Open Price *Leverage/(Leverage+Return)
         */
        String buff = "";
        if (isForward) {
            BigDecimal buff1 = leverBig.add(amountBig);
            BigDecimal buff2 = leverBig.subtract(amountBig);
            if (direction == 0) {
                //Buy long
                buff = openingPriceBig.multiply(buff1).divide(leverBig, scale, BigDecimal.ROUND_DOWN).setScale(scale, BigDecimal.ROUND_DOWN).toPlainString();
            } else {
                //Selling short
                buff = openingPriceBig.multiply(buff2).divide(leverBig, scale, BigDecimal.ROUND_DOWN).setScale(scale, BigDecimal.ROUND_DOWN).toPlainString();
            }
        } else {

            BigDecimal buff1 = leverBig.subtract(amountBig);
            BigDecimal buff2 = leverBig.add(amountBig);
            if (buff1.compareTo(BigDecimal.ZERO) == 0) {
                return "-1";
            }
            if (direction == 0) {
                //Buy long
                buff = openingPriceBig.multiply(leverBig).divide(buff1, scale, BigDecimal.ROUND_DOWN).setScale(scale, BigDecimal.ROUND_DOWN).toPlainString();
            } else {
                //Selling short
                buff = openingPriceBig.multiply(leverBig).divide(buff2, scale, BigDecimal.ROUND_DOWN).setScale(scale, BigDecimal.ROUND_DOWN).toPlainString();
            }
        }
        return buff;
    }

    /**
     *Calculate Force Close Price
     *@param isForward forward contract
     *@param direction 0 more 1 empty
     *@param marginAmount Amount of margin
     *@param positionAmount Position quantity
     *@param openingPrice
     *@param keepMarginRate Maintain margin rate
     *@param marginRate Margin exchange rate
     *@param scale precision
     *@return Force Close Price
     */
    public static String calcForceClosePriceValue(boolean isForward, int direction, String marginAmount, String positionAmount, String openingPrice, String keepMarginRate, String marginRate, int scale) {

        BigDecimal marginAmountBig = new BigDecimal(marginAmount);//Amount of deposit
        BigDecimal openingPriceBig = new BigDecimal(openingPrice);//Opening price
        BigDecimal positionAmountBig = new BigDecimal(positionAmount);//Number of positions
        BigDecimal marginRateBig = new BigDecimal(marginRate);//Margin exchange rate
        BigDecimal keepMarginRateBig = new BigDecimal(keepMarginRate);//Maintain margin ratio
        BigDecimal feeRateBig = new BigDecimal("0.00075");//Fee rate
        /**
         *Qiangping Price (Unit: Pricing Currency)
         *Forward contract:
         *Multi position strong leveling price=(margin quantity/margin exchange rate - position quantity * opening price)/(maintain margin rate+commission rate - 1) * position quantity)
         *Short position forced leveling price=(margin quantity/margin exchange rate+position quantity * opening price)/(maintain margin rate+commission rate+1) * position quantity)
         *
         *Reverse contract:
         *Multi position strong leveling price=((maintain margin rate+commission rate+1) * position quantity)/(margin quantity/margin exchange rate+position quantity/opening price)
         *Short position forced leveling price=((maintain margin rate+commission rate - 1) * position quantity)/(margin quantity/margin exchange rate - position quantity/opening price)
         *
         *Maintenance margin ratio=Maintenance margin ratio of the level in which (position quantity * marked price) is located
         *Handling fee=0.075%
         */
        String buff = "";
        if (isForward) {
            BigDecimal buff1 = marginAmountBig.divide(marginRateBig, scale, BigDecimal.ROUND_DOWN);
            BigDecimal buff2 = positionAmountBig.multiply(openingPriceBig);
            if (direction == 0) {
                //Buy long
                BigDecimal buff3 = buff1.subtract(buff2);
                BigDecimal buff4 = keepMarginRateBig.add(feeRateBig).subtract(BigDecimal.ONE);
                BigDecimal buff5 = buff4.multiply(positionAmountBig);
                buff = buff3.divide(buff5, scale, BigDecimal.ROUND_DOWN).setScale(scale, BigDecimal.ROUND_DOWN).toPlainString();
            } else {
                //Selling short
                BigDecimal buff3 = buff1.add(buff2);
                BigDecimal buff4 = keepMarginRateBig.add(feeRateBig).add(BigDecimal.ONE);
                BigDecimal buff5 = buff4.multiply(positionAmountBig);
                buff = buff3.divide(buff5, scale, BigDecimal.ROUND_DOWN).setScale(scale, BigDecimal.ROUND_DOWN).toPlainString();
            }
        } else {
            BigDecimal buff1 = marginAmountBig.divide(marginRateBig, scale, BigDecimal.ROUND_DOWN);
            BigDecimal buff2 = positionAmountBig.divide(openingPriceBig, scale, BigDecimal.ROUND_DOWN);
            if (direction == 0) {
                //Buy long
                BigDecimal buff3 = keepMarginRateBig.add(feeRateBig).add(BigDecimal.ONE);
                BigDecimal buff4 = buff3.multiply(positionAmountBig);
                return buff4.divide(buff1.add(buff2), scale, BigDecimal.ROUND_DOWN).setScale(scale, BigDecimal.ROUND_DOWN).toPlainString();
            } else {
                //Selling short
                BigDecimal buff3 = keepMarginRateBig.add(feeRateBig).subtract(BigDecimal.ONE);
                BigDecimal buff4 = buff3.multiply(positionAmountBig);
                return buff4.divide(buff1.subtract(buff2), scale, BigDecimal.ROUND_DOWN).setScale(scale, BigDecimal.ROUND_DOWN).toPlainString();
            }
        }
        return buff;
    }


    /**
     * @param isForward a forward contract
     * @param direction 0 more 1 empty
     * @param levelValue level
     * @param positionAmount Position quantity
     * @param openingPrice open price
     * @param keepMarginRate Maintain margin rate
     * @param marginRate Margin exchange rate
     * @param scale precision
     * @return [Isolated] Force close price
     */
    public static String calcForceClosePriceForIsolated(boolean isForward, int direction,String levelValue, String positionAmount, String openingPrice, String keepMarginRate, String marginRate, int scale) {
        Log.d("calcForIsolated","isForward="+isForward+", direction="+direction+", levelValue="+levelValue+", positionAmount="+positionAmount+", openingPrice="+openingPrice+", keepMarginRate="+keepMarginRate+", marginRate="+marginRate+", scale="+scale);
        int defScale = 12;
        BigDecimal openingPriceBig = new BigDecimal(openingPrice);//Opening price
        BigDecimal positionAmountBig = new BigDecimal(positionAmount);//Number of positions
        BigDecimal marginRateBig = new BigDecimal(marginRate);//Margin exchange rate
        BigDecimal keepMarginRateBig = new BigDecimal(keepMarginRate);//Maintain margin ratio
        BigDecimal feeRateBig = new BigDecimal("0.00075");//Fee rate
        String forcePrice;

        BigDecimal valueSub = new BigDecimal("1").subtract(keepMarginRateBig).subtract(feeRateBig);
        BigDecimal valueAdd = new BigDecimal("1").add(keepMarginRateBig).add(feeRateBig);
        BigDecimal openMargin = new BigDecimal(calcOpenMargin(isForward,levelValue,positionAmount,openingPrice,defScale));
        if(isForward){
            /*
             Forward contract:
             Opening margin = Open price, number of positions, leverage
             Long: Liquidation Price = (Number of Positions * Opening Price - Opening Margin / Margin Exchange Rate ) / ((1 - Maintenance Margin Rate - Fee Rate) * Number of Positions)
             Short: Liquidation Price = (Number of Positions * Opening Price + Opening Margin / Margin Exchange Rate ) / ((1 + Maintenance Margin Rate + Commission Rate) * Number of Positions)
             **/
            if (direction == 0) {
                //Buy long
                BigDecimal value1 = positionAmountBig.multiply(openingPriceBig);
                BigDecimal value2 = openMargin.divide(marginRateBig, defScale, BigDecimal.ROUND_DOWN);
                BigDecimal value3 = value1.subtract(value2);
                BigDecimal value5 = valueSub.multiply(positionAmountBig);

                forcePrice = value3.divide(value5,scale,BigDecimal.ROUND_DOWN).toPlainString();

            }else{
                //Selling short
                BigDecimal value1 = positionAmountBig.multiply(openingPriceBig);
                BigDecimal value2 = openMargin.divide(marginRateBig, defScale, BigDecimal.ROUND_DOWN);
                BigDecimal value3 = value1.add(value2);
                BigDecimal value5 = valueAdd.multiply(positionAmountBig);

                forcePrice = value3.divide(value5,scale,BigDecimal.ROUND_DOWN).toPlainString();
            }
        }else{
            //  Reverse contract:
            //  Opening Margin = Number of Positions / (Opening Price * Leverage Multiple)
            //  Long: Liquidation Price = (1 + Maintenance Margin Rate + Commission Rate) * Number of Positions / ((Number of Positions / Opening Price) + Opening Margin / Margin Exchange Rate)
            //  Short: Liquidation Price = (1 - Maintenance Margin Rate - Commission Rate) * Number of Positions / ((Number of Positions / Opening Price) - Opening Margin / Margin Rate)
            if (direction == 0) {
                //Buy long
                BigDecimal value1 = valueAdd.multiply(positionAmountBig);

                BigDecimal value2 = positionAmountBig.divide(openingPriceBig, defScale, BigDecimal.ROUND_DOWN);
                BigDecimal value3 = openMargin.divide(marginRateBig, defScale, BigDecimal.ROUND_DOWN);
                BigDecimal value4 = value2.add(value3);

                forcePrice = value1.divide(value4,scale, BigDecimal.ROUND_DOWN).toPlainString();

            }else{
                //Selling short
                BigDecimal value1 = valueSub.multiply(positionAmountBig);

                BigDecimal value2 = positionAmountBig.divide(openingPriceBig, defScale, BigDecimal.ROUND_DOWN);
                BigDecimal value3 = openMargin.divide(marginRateBig, defScale, BigDecimal.ROUND_DOWN);
                BigDecimal value4 = value2.subtract(value3);

                forcePrice = value1.divide(value4,scale, BigDecimal.ROUND_DOWN).toPlainString();

            }
        }


        return forcePrice;
    }

    /**
     * @param isForward is Forward contract?
     * @param levelValue level
     * @param positionAmount position amount
     * @param openingPrice open price
     * Positive: Margin for opening = openPrice * positionAmount / leverage
     * Inverse: OpenMargin = positionAmount / (openPrice * leverage)
     * @return OpenMargin
     * */
    public static String calcOpenMargin(boolean isForward,String levelValue, String positionAmount, String openingPrice,int scale){
        Log.d("calcOpenMargin","isForward="+isForward+", levelValue="+levelValue+", positionAmount="+positionAmount+", openingPrice="+openingPrice+", scale="+scale);
        String openMargin;
        BigDecimal openingPriceBig = new BigDecimal(openingPrice);//Opening price
        BigDecimal positionAmountBig = new BigDecimal(positionAmount);//Number of positions
        BigDecimal levelBig = new BigDecimal(levelValue);//level
        BigDecimal value;
        if(isForward){
            value = openingPriceBig.multiply(positionAmountBig).divide(levelBig,scale,BigDecimal.ROUND_DOWN);
        }else{
            BigDecimal value1 = openingPriceBig.multiply(levelBig);
            value = positionAmountBig.divide(value1,scale,BigDecimal.ROUND_DOWN);
        }
        openMargin = value.toPlainString();
        Log.d("calcOpenMargin",openMargin);
        return openMargin;
    }

    /**
     *Stop Profit and Loss Calculation Estimated Profit and Loss
     *
     *Is @param isForward a forward contract
     *@param direction 0 more 1 empty
     *@param isLimit Enter a price limit order
     *@param openPrice Average opening price
     *@param triggerPrice
     *@param commissionPrice
     *@param positionAmount Number of positions (pcs.)
     *@param parValue par value
     *@param marginRate Margin exchange rate
     * @param scale
     * @return
     */

    public static String calcEstimatedProfitLoss(boolean isForward, int direction, boolean isLimit, String openPrice, String triggerPrice, String commissionPrice, String positionAmount, String parValue, String marginRate, int scale) {
        if (TextUtils.isEmpty(positionAmount)) positionAmount = "0";
        if (TextUtils.isEmpty(openPrice)) openPrice = "0";
        if (TextUtils.isEmpty(triggerPrice)) triggerPrice = "0";
        if (TextUtils.isEmpty(commissionPrice)) commissionPrice = "0";

        BigDecimal positionAmountBig = new BigDecimal(positionAmount);
        BigDecimal openingPriceBig = new BigDecimal(openPrice);
        BigDecimal parValueBig = new BigDecimal(parValue);
        BigDecimal marginRateBig = new BigDecimal(marginRate);
        BigDecimal triggerPriceBig = new BigDecimal(triggerPrice);
        BigDecimal commissionPriceBig = new BigDecimal(commissionPrice);

        Log.e("-------isForward:", isForward + "");
        Log.e("-------direction:", direction + "");
        Log.e("-------position:", positionAmount);
        Log.e("-------openPrice:", openPrice);
        Log.e("-------parValue面值:", parValue);
        Log.e("-------marginRate保证金汇率:", marginRate);
        Log.e("-------triggerPrice触发价:", triggerPrice);
        Log.e("-------commission:", commissionPrice);
        /**
         *Estimated Profit and Loss (Unit: Guarantee Currency)
         *Forward contract:
         *Estimated profit/loss (market price - multiple positions)=(trigger price - average opening price) * number of positions * face value/margin exchange rate
         *Estimated profit/loss (market price short position)=(trigger price average opening price) * number of positions * face value/margin exchange rate * - 1
         *Estimated profit and loss (limit price - multiple positions)=(commission price - average opening price) * number of positions * face value/margin exchange rate
         *Estimated profit and loss (price limit short position)=(commission price average opening price) * number of positions * face value/margin exchange rate * - 1
         *
         *Reverse contract:
         *Estimated profit/loss (market price - multiple positions)=(1/average opening price - 1/trigger price) * number of positions * face value/margin exchange rate
         *Estimated profit/loss (market price short position)=(1/average opening price - 1/trigger price) * number of positions * face value/margin exchange rate * - 1
         *Estimated profit/loss (limit price - multiple positions)=(1/average opening price - 1/commission price) * number of positions * face value/margin exchange rate
         *Estimated profit/loss (limit price - short position)=(1/average opening price - 1/commission price) * number of positions * face value/margin exchange rate * - 1
         */
        BigDecimal resultBig = BigDecimal.ZERO;
        if (isForward) {
            if (isLimit) {
                //Price limit
                if (direction == 0) {
                    //Multi warehouse
                    BigDecimal buff = commissionPriceBig.subtract(openingPriceBig);
                    resultBig = buff.multiply(positionAmountBig).multiply(parValueBig).divide(marginRateBig, scale, BigDecimal.ROUND_HALF_DOWN);
                } else {
                    //Short positions
                    BigDecimal buff = commissionPriceBig.subtract(openingPriceBig);
                    resultBig = buff.multiply(positionAmountBig).multiply(parValueBig).divide(marginRateBig, scale, BigDecimal.ROUND_HALF_DOWN).multiply(new BigDecimal("-1"));
                }
            } else {
                //Market price
                if (direction == 0) {
                    //Multi warehouse
                    BigDecimal buff = triggerPriceBig.subtract(openingPriceBig);
                    resultBig = buff.multiply(positionAmountBig).multiply(parValueBig).divide(marginRateBig, scale, BigDecimal.ROUND_HALF_DOWN);
                } else {
                    //Short positions
                    BigDecimal buff = triggerPriceBig.subtract(openingPriceBig);
                    resultBig = buff.multiply(positionAmountBig).multiply(parValueBig).divide(marginRateBig, scale, BigDecimal.ROUND_HALF_DOWN).multiply(new BigDecimal("-1"));
                }
            }
        } else {
            if (!isLimit) {
                if (triggerPriceBig.compareTo(BigDecimal.ZERO) == 0) {
                    return "0";
                }
                //Price limit
                if (direction == 0) {
                    //Multi warehouse
                    BigDecimal buff1 = BigDecimal.ONE.divide(openingPriceBig, scale, BigDecimal.ROUND_HALF_DOWN);
                    BigDecimal buff2 = BigDecimal.ONE.divide(triggerPriceBig, scale, BigDecimal.ROUND_HALF_DOWN);
                    BigDecimal buff3 = buff1.subtract(buff2);
                    resultBig = buff3.multiply(positionAmountBig).multiply(parValueBig).divide(marginRateBig, scale, BigDecimal.ROUND_HALF_DOWN);
                } else {
                    //Short positions
                    BigDecimal buff1 = BigDecimal.ONE.divide(openingPriceBig, scale, BigDecimal.ROUND_HALF_DOWN);
                    BigDecimal buff2 = BigDecimal.ONE.divide(triggerPriceBig, scale, BigDecimal.ROUND_HALF_DOWN);
                    BigDecimal buff3 = buff1.subtract(buff2);
                    resultBig = buff3.multiply(positionAmountBig).multiply(parValueBig).divide(marginRateBig, scale, BigDecimal.ROUND_HALF_DOWN).multiply(new BigDecimal("-1"));
                }
            } else {
                if (commissionPriceBig.compareTo(BigDecimal.ZERO) == 0) {
                    return "0";
                }
                //Market price
                if (direction == 0) {
                    //Multi warehouse
                    BigDecimal buff1 = BigDecimal.ONE.divide(openingPriceBig, scale, BigDecimal.ROUND_HALF_DOWN);
                    BigDecimal buff2 = BigDecimal.ONE.divide(commissionPriceBig, scale, BigDecimal.ROUND_HALF_DOWN);
                    BigDecimal buff3 = buff1.subtract(buff2);
                    resultBig = buff3.multiply(positionAmountBig).multiply(parValueBig).divide(marginRateBig, scale, BigDecimal.ROUND_HALF_DOWN);
                } else {
                    //Short positions
                    BigDecimal buff1 = BigDecimal.ONE.divide(openingPriceBig, scale, BigDecimal.ROUND_HALF_DOWN);
                    BigDecimal buff2 = BigDecimal.ONE.divide(commissionPriceBig, scale, BigDecimal.ROUND_HALF_DOWN);
                    BigDecimal buff3 = buff1.subtract(buff2);
                    resultBig = buff3.multiply(positionAmountBig).multiply(parValueBig).divide(marginRateBig, scale, BigDecimal.ROUND_HALF_DOWN).multiply(new BigDecimal("-1"));
                }
            }
        }
        return resultBig.setScale(scale, BigDecimal.ROUND_HALF_DOWN).toPlainString();
    }

    /**
     *@ description Profit and loss calculation
     *@ apiNote Market Price&Opponent's Best&Flash Close:
     *Forward contract multiple positions: Estimated profit/loss=(Buy 1 - Average opening price) * Quantity * Face value * Exchange rate
     *Forward contract short position: estimated profit/loss=(average opening price - sell 1) * quantity * face value * exchange rate
     *Currency based contract multiple positions: estimated profit/loss=quantity * face value/average opening price - quantity * face value/buy 1
     *Currency based contract short position: estimated profit/loss=quantity * face value/counterparty level 1 - quantity * face value/sell 1
     *
     *Our best:
     *Forward contract multiple positions: Estimated profit/loss=(sell 1 - average opening price) * Quantity * Face value * Exchange rate
     *Forward contract short position: estimated profit/loss=(average opening price - buy 1) * quantity * face value * exchange rate
     *Currency based contract multiple positions: estimated profit/loss=quantity * face value/average opening price - quantity * face value/sell 1
     *Currency based contract short position: estimated profit/loss=quantity * face value/buy 1 - quantity * face value/average opening price
     *
     *Price limit:
     *Forward contract multiple positions: Estimated profit/loss=(set price - average opening price) * Quantity * Face value * Exchange rate
     *Forward contract short position: estimated profit/loss=(average opening price - set price) * quantity * face value * exchange rate
     *Currency based contract multiple positions: estimated profit/loss=quantity * face value/average opening price - quantity * face value/set price
     *Currency based contract multiple positions: estimated profit/loss=quantity * face value/set price - quantity * face value/average opening price
     *
     *Is @param isForward a forward contract
     *@param direction 0 more 1 empty
     *@param tagPrice Tag Price
     *@param openingAveragePrice
     *@param parValue par value
     *@param amount quantity
     *@param marginRate
     *@param bond deposit
     *@param scale precision
     *@param checkContractUnit is need check contract unit?  when it is true -> [if it is coin ,it not need multiply multiplier, if it is zhang, it need multiply multiplier.]
     *@return Estimated profit and loss
     */
    public static String calcPositionProfit(boolean isForward, int direction, String tagPrice, String openingAveragePrice, String parValue, String amount, String marginRate,  String bond, int scale,boolean checkContractUnit) {
        if("0".equals(tagPrice)) return "--";
        final String TAG = "calcPositionProfit";
        LogUtils.e("tagPrice:::"+tagPrice.toString());
        if(checkContractUnit){
            int contractUint = CpClLogicContractSetting.getContractUint(CpMyApp.Companion.instance());
            if(contractUint==1) parValue = "1";//If it's currency, don't multiply it by its face value
        }
        BigDecimal amountBig = new BigDecimal(amount);
        BigDecimal openingPriceBig = new BigDecimal(openingAveragePrice);
        BigDecimal tagPriceBig = new BigDecimal(tagPrice);
        BigDecimal marginRateBig = new BigDecimal(marginRate);
        BigDecimal parValueBig = new BigDecimal(parValue);
        BigDecimal bondValueBig = new BigDecimal(bond);

        String buff = "";
        if (isForward) {
            if (direction == 0) {
                //Buy long
                Log.d(TAG,"正向合约 - 多仓");
                Log.d(TAG,"("+tagPriceBig+"-"+openingPriceBig+")*"+amountBig+"*"+parValueBig+"*"+marginRateBig);
                buff = tagPriceBig.subtract(openingPriceBig).multiply(amountBig).multiply(parValueBig).multiply(marginRateBig).setScale(scale, BigDecimal.ROUND_HALF_DOWN).toPlainString();
                Log.d(TAG,"result = " + buff);
            } else {
                //Selling short
                Log.d(TAG,"正向合约 - 空仓");
                Log.d(TAG,"("+openingPriceBig+"-"+tagPriceBig+")*"+amountBig+"*"+parValueBig+"*"+marginRateBig);
                buff = openingPriceBig.subtract(tagPriceBig).multiply(amountBig).multiply(parValueBig).multiply(marginRateBig).setScale(scale, BigDecimal.ROUND_HALF_DOWN).toPlainString();
                Log.d(TAG,"result = " + buff);
            }
        } else {
            if (direction == 0) {
                //Buy long
                Log.d(TAG,"反向合约 - 多仓");
                Log.d(TAG,amountBig+"*"+parValueBig+"/"+openingPriceBig+"-"+amountBig+"*"+parValueBig+"/"+tagPriceBig);
                BigDecimal divide1 = amountBig.multiply(parValueBig).divide(openingPriceBig, scale, BigDecimal.ROUND_HALF_DOWN);
                BigDecimal divide2 = amountBig.multiply(parValueBig).divide(tagPriceBig, scale, BigDecimal.ROUND_HALF_DOWN);
                buff = divide1.subtract(divide2).setScale(scale, BigDecimal.ROUND_HALF_DOWN).toPlainString();
                Log.d(TAG,"result = " + buff);
            } else {
                //Selling short
                Log.d(TAG,"反向合约 - 空仓");
                Log.d(TAG,amountBig+"*"+parValueBig+"/"+tagPriceBig + "-" + amountBig+"*"+parValueBig+"/"+openingPriceBig);
                BigDecimal divide1 = amountBig.multiply(parValueBig).divide(openingPriceBig, scale, BigDecimal.ROUND_HALF_DOWN);
                BigDecimal divide2 = amountBig.multiply(parValueBig).divide(tagPriceBig, scale, BigDecimal.ROUND_HALF_DOWN);
                buff = divide2.subtract(divide1).setScale(scale, BigDecimal.ROUND_HALF_DOWN).toPlainString();
                Log.d(TAG,"result = " + buff);
            }
        }
        return buff;
    }


    public static BigDecimal calcPositionProfitBig(boolean isForward, int direction, String tagPrice, String openingAveragePrice, String parValue, String amount, String marginRate,  String bond, int scale) {
        if("0".equals(tagPrice)) return BigDecimal.ZERO;
        LogUtils.e("tagPrice:::"+tagPrice.toString());
        BigDecimal amountBig = new BigDecimal(amount);
        BigDecimal openingPriceBig = new BigDecimal(openingAveragePrice);
        BigDecimal tagPriceBig = new BigDecimal(tagPrice);
        BigDecimal marginRateBig = new BigDecimal(marginRate);
        BigDecimal parValueBig = new BigDecimal(parValue);
        BigDecimal bondValueBig = new BigDecimal(bond);
        /**
         *
         ------盈亏额计算------
         正向合约：
         - 多仓
         盈亏额：(标记价格-开仓均价)*Quantity * face value * exchange rate
         - 空仓
         盈亏额：(开仓均价-标记价格)*Quantity * face value * exchange rate
         反向合约：
         - 多仓
         盈亏额：数量*Nominal Value/Average Opening Price - Quantity * Nominal Value/Tag Price
         - 空仓
         盈亏额：数量*Nominal Value/Tag Price - Quantity * Nominal Value/Average Opening Price
         ------回报率计算------
         回报率：盈亏额/保证金*100%
         */
        BigDecimal buff = BigDecimal.ZERO;
        if (isForward) {
            if (direction == 0) {
                //Buy long
                buff = tagPriceBig.subtract(openingPriceBig).multiply(amountBig).multiply(parValueBig).multiply(marginRateBig);
            } else {
                //Selling short
                buff = openingPriceBig.subtract(tagPriceBig).multiply(amountBig).multiply(parValueBig).multiply(marginRateBig);
            }
        } else {
            if (direction == 0) {
                //Buy long
                BigDecimal divide1 = amountBig.multiply(parValueBig).divide(openingPriceBig, 16, BigDecimal.ROUND_HALF_DOWN);
                BigDecimal divide2 = amountBig.multiply(parValueBig).divide(tagPriceBig, 16, BigDecimal.ROUND_HALF_DOWN);
                buff = divide1.subtract(divide2);
            } else {
                //Selling short
                BigDecimal divide1 = amountBig.multiply(parValueBig).divide(openingPriceBig, 16, BigDecimal.ROUND_HALF_DOWN);
                BigDecimal divide2 = amountBig.multiply(parValueBig).divide(tagPriceBig, 16, BigDecimal.ROUND_HALF_DOWN);
                buff = divide2.subtract(divide1);
            }
        }
        return buff;
    }


    public static String showDepthVolumeNew(String value,int coUnit,int multiplierPrecision) {
        if (!CpStringUtil.isNumeric(value))
            value = "0";

        if(coUnit==1){//When the unit is currency, the decimal precision is the precision of the contract face value. If it is insufficient, it is necessary to add 0
            return new BigDecimal(value).setScale(multiplierPrecision).toPlainString();
        }

        String temp = new BigDecimal(value).toPlainString();
        if (compareTo(temp, "0.0001") < 0) {
            return "0.0000";
        } else if (compareTo(temp, "1000") >= 0) {
            return formatNumber(temp);
        } else {
            if (temp.contains(".")) {
                return (temp + "00000").substring(0, 6);
            } else {
                String substring = (temp + ".0000").substring(0, 4);
                if (substring.endsWith(".")) {
                    return substring.substring(0, 3);
                } else if (substring.endsWith(".0") || substring.endsWith(".00")) {
                    return CpBigDecimalUtils.showSNormal(substring, 0);
                } else {
                    return substring;
                }
            }
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
    public static String cutValueByPrecision(String v1, int scale) {
        String result = "0";
        try {
            if (TextUtils.isEmpty(v1) || v1 == "--" || v1 == "null") {
                v1 = "0";
            }
            result = new BigDecimal(v1).setScale(scale, BigDecimal.ROUND_DOWN).toPlainString();
        } catch (Exception e) {
            result = "0";
        } finally {
            return result;
        }

    }


    /**
     *  minimum value：
     *  The precision is retained as the precision of the "minimum order amount" returned by the back end. In the carry system, if the calculation result is 5.06U and the precision of the minimum order amount is 1, the final value is 5.1
     *  Forward contract: Minimum = minimum order quantity (sheet) * par * order price
     *  Reverse contract: Minimum = minimum order quantity (sheet) * par/order price
     * @param  isForward  Whether it is a positive contract
     * @param  price      order price
     * @param  multiplier contract multiplier
     * @param  minValue   Minimum order quantity (zhang)
     * @param  scale      precision
     * @param  inputValue Value of input
     * @return If the minimum order value is null, do not indicate that the minimum order limit is met
     * */
    public static String getOrderNumMinValue(boolean isForward,String minValue,String inputValue,String price,String multiplier,int scale){
        final String tag = "getOrderNumMinValue";
        Log.d(tag,"into params:isForward="+isForward+",minValue="+minValue+",inputValue="+inputValue+",price="+price+",multiplier="+multiplier+",scale="+scale);
        BigDecimal result;
        BigDecimal s = mul(minValue, multiplier);
        BigDecimal bgInputValue = new BigDecimal(inputValue);
        BigDecimal bgPrice = new BigDecimal(price);
        if(isForward){
            result = s.multiply(bgPrice).setScale(scale,BigDecimal.ROUND_UP);
        }else{
            result = s.divide(bgPrice,scale,BigDecimal.ROUND_UP);
        }
        Log.d(tag,"minimum value>>>"+result);
        boolean isOk = bgInputValue.compareTo(result) >= 0;
        if(isOk){
            return null;
        }else{
            return result.stripTrailingZeros().toPlainString();
        }
    }

    /**
     *  maximum value：
     *  The precision is reserved as the precision of "minimum order amount" returned by the back-end. In rounding system, if the calculation result is 50000.06 U and the precision of the minimum order amount is 1, the final value is 50000
     *  Forward contract: Maximum = maximum order (sheet) * face value * order price
     *  Reverse contract: Maximum = maximum order quantity (sheet) * par/order price
     * @param  isForward  Whether it is a positive contract
     * @param  price      order price
     * @param  multiplier contract multiplier
     * @param  maxValue   Maximum order quantity (zhang)
     * @param  scale      precision
     * @param  inputValue Value of input
     * @return If the maximum order value is null, do not indicate that the maximum order limit is met
     * */
    public static String getOrderNumMaxValue(boolean isForward,String maxValue,String inputValue,String price,String multiplier,int scale){
        final String tag = "getOrderNumMaxValue";
        Log.d(tag,"into params:isForward="+isForward+",maxValue="+maxValue+",inputValue="+inputValue+",price="+price+",multiplier="+multiplier+",scale="+scale);
        BigDecimal result;
        BigDecimal s = mul(maxValue, multiplier);
        BigDecimal bgInputValue = new BigDecimal(inputValue);
        BigDecimal bgPrice = new BigDecimal(price);
        if(isForward){
            result = s.multiply(bgPrice).setScale(scale,BigDecimal.ROUND_DOWN);
        }else{
            result = s.divide(bgPrice,scale,BigDecimal.ROUND_DOWN);
        }
        Log.d(tag,"maximum value>>>"+result);
        boolean isOk = bgInputValue.compareTo(result) <= 0;
        if(isOk){
            return null;
        }else{
            return result.stripTrailingZeros().toPlainString();
        }
    }


    public static int getPrecisionByPrice(String price){
        if(price.contains(".")){
            price = new BigDecimal(price).stripTrailingZeros().toPlainString();
            String[] strings = price.split("\\.");
            return strings[1].length();
        }else{
            return 0;
        }
    }

    /**
     * Order quantity calculation：
     * Forward contract: Order quantity (sheet) = order value/order price/contract face value
     * Reverse contract: Order quantity (sheet) = order value * order price/contract face value
     * @param isForward Whether it is a positive contract
     * @param inputValue Value of input
     * @param multiplier contract multiplier
     * @param price order price
     * @return quantity (zhang)
     * */
    public static String getOrderVolumeByValue(boolean isForward,String inputValue,String price,String multiplier){
        final String tag = "getOrderVolumeByValue";
        Log.d(tag,"into params:isForward="+isForward+",inputValue="+inputValue+",price="+price+",multiplier="+multiplier);
        if("0".equals(price)||price.isEmpty()) return "0";
        if(!CpStringUtil.isNumeric(inputValue)) return "0";
        BigDecimal bgInputValue = new BigDecimal(inputValue);
        BigDecimal bgPrice = new BigDecimal(price);
        BigDecimal bgMultiplier = new BigDecimal(multiplier);
        String result;
        if(isForward) result = bgInputValue.divide(bgPrice,8,BigDecimal.ROUND_DOWN).divide(bgMultiplier,0,BigDecimal.ROUND_DOWN).toPlainString();
        else result = bgInputValue.multiply(bgPrice).divide(bgMultiplier,0,BigDecimal.ROUND_DOWN).toPlainString();
        Log.d(tag,"quantity (zhang)>>>"+result);
        return result;
    }

    /**
     * Convert coins by value
     *     The display unit of "quantity" in the secondary pop-up box is currency：
     *     Quantity (coins) = Quantity ordered (sheets) * par value of contract
     * @param multiplier contract multiplier
     * @param value value
     * @param scale precision
     * @return Quantity (currency)
     * */
    public static String getCoinByValue(String value,String multiplier,int scale){
        final String tag = "getCoinByValue";
        Log.d(tag,"into params:value="+value+",multiplier="+multiplier);
        BigDecimal bgValue = new BigDecimal(value);
        BigDecimal bgMultiplier = new BigDecimal(multiplier);
        String plainString = bgValue.multiply(bgMultiplier).setScale(scale,BigDecimal.ROUND_DOWN).toPlainString();
        Log.d(tag,"return:plainString="+plainString);
        return plainString;
    }


    /**
     * Conversion of quantity when placing order in valuation currency (limit list, limit condition List)
     * Forward contract: Order quantity (currency) = order value / order price
     * Reverse contract: order quantity (currency) = order value * order price
     * @param isForward Positive or negative contract
     * @param value order value
     * @param price order price
     * @return quantity (currency)
     * */
    public static String canUSDTPositionStr(boolean isForward,String value,String price,int scale,String unit){
        final String tag = "canUSDTPositionStr";
        Log.d(tag,"into params:isForward="+isForward+",value="+value+",price="+price+",scale="+scale+",unit="+unit);
        if(!CpStringUtil.isNumeric(value) || !CpStringUtil.isNumeric(price)) return "0"+unit;
        BigDecimal bgValue = new BigDecimal(value);
        BigDecimal bgPrice = new BigDecimal(price);
        String result;

        if(bgPrice.compareTo(BigDecimal.ZERO)==0||bgValue.compareTo(BigDecimal.ZERO)==0)
            result = BigDecimal.ZERO.setScale(scale,BigDecimal.ROUND_DOWN).toPlainString();
        else
            if(isForward){
                result = bgValue.divide(bgPrice,scale,BigDecimal.ROUND_DOWN).toPlainString();
            }else{
                result = bgValue.multiply(bgPrice).setScale(scale,BigDecimal.ROUND_DOWN).toPlainString();
            }
        Log.d(tag,"return:"+result);
        return result + " " + unit;
    }

    //+1.0000 -1.000
    public static String formatNumberWithLogo(String value){
        String prefix = CpBigDecimalUtils.compareTo(value,"0")==-1 ? "" : "+";
        prefix = CpBigDecimalUtils.compareTo(value,"0")==0 ? "" : prefix;
        return prefix+value;
    }
}
