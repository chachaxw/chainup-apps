package com.yjkj.chainup.util;


import android.text.TextUtils;
import android.util.Log;


import java.math.BigDecimal;
import java.util.Arrays;

public class BigDecimalUtils {

    //Default Division Precision
    private static final int DEF_DIV_SCALE = 10;

    /**
     *Provide precise addition operations.
     *
     *@param v1 addend
     *@param v2 addend
     *The sum of @return two parameters
     */
    public static BigDecimal add(String v1, String v2) {
        if (!StringUtil.isNumeric(v1))
            v1 = "0";

        if (!StringUtil.isNumeric(v2)) {
            v2 = "0";
        }
        return new BigDecimal(v1).add(new BigDecimal(v2));
    }

    public static String addStr(String v1, String v2, int scale) {
        if (!StringUtil.isNumeric(v1))
            v1 = "0";

        if (!StringUtil.isNumeric(v2)) {
            v2 = "0";
        }
        if (scale < 0)
            scale = 0;
        return new BigDecimal(v1).add(new BigDecimal(v2)).setScale(scale, BigDecimal.ROUND_DOWN).toPlainString();
    }

    /**
     *Provide precise subtraction operations.
     *
     *@param v1 subtracted
     *@param v2 Subtraction
     *@return The difference between two parameters
     */
    public static BigDecimal sub(String v1, String v2) {

        if (!StringUtil.isNumeric(v1))
            v1 = "0";

        if (!StringUtil.isNumeric(v2)) {
            v2 = "0";
        }
        return new BigDecimal(v1).subtract(new BigDecimal(v2));
    }

    public static String subStr(String v1, String v2, int scale) {

        if (!StringUtil.isNumeric(v1))
            v1 = "0";

        if (!StringUtil.isNumeric(v2)) {
            v2 = "0";
        }
        if (scale < 0)
            scale = 0;

        return new BigDecimal(v1).subtract(new BigDecimal(v2)).setScale(scale, BigDecimal.ROUND_DOWN).toPlainString();
    }

    /**
     *Provide precise multiplication operations.
     *
     *@param v1 multiplicand
     *@param v2 multiplier
     *@return The product of two parameters
     */
    public static BigDecimal mul(String v1, String v2) {
        if (!StringUtil.isNumeric(v1))
            v1 = "0";

        if (!StringUtil.isNumeric(v2)) {
            v2 = "0";
        }
        return new BigDecimal(v1).multiply(new BigDecimal(v2));

    }

    public static String mulStr(String v1, String v2, int scale) {

        if (!StringUtil.isNumeric(v1))
            v1 = "0";

        if (!StringUtil.isNumeric(v2)) {
            v2 = "0";
        }
        if (scale < 0)
            scale = 0;
        return new BigDecimal(v1).multiply(new BigDecimal(v2)).setScale(scale, BigDecimal.ROUND_DOWN).toPlainString();

    }

    /**
     *Provide precise multiplication operations. (TODO rounding)
     *
     *@param v1 multiplicand
     *@param v2 multiplier
     *@return The product of two parameters
     */
    public static BigDecimal mul(String v1, String v2, int scale) {

        if (!StringUtil.isNumeric(v1))
            v1 = "0";

        if (!StringUtil.isNumeric(v2)) {
            v2 = "0";
        }
        if (scale < 0)
            scale = 0;
        return new BigDecimal(v1).multiply(new BigDecimal(v2)).setScale(scale, BigDecimal.ROUND_DOWN);

    }


    /**
     *Provide (relatively) accurate division operations, accurate to
     *10 digits after the Decimal separator, and the subsequent figures are rounded off.
     *
     *@param v1 dividend
     *@param v2 divisor
     *@return The quotient of two parameters
     */
    public static BigDecimal div(String v1, String v2) {
        return div(v1, v2, DEF_DIV_SCALE);
    }

    /**
     *Provide (relatively) accurate division operations. When an inexhaustible division occurs, the scale parameter refers to
     *Fixed precision, rounding off future numbers.
     *
     *@param v1 dividend
     *@param v2 divisor
     *@param scale indicates that it needs to be accurate to several digits after the Decimal separator.
     *@return The quotient of two parameters
     */
    public static BigDecimal div(String v1, String v2, int scale) {
        if (!StringUtil.isNumeric(v1))
            v1 = "0";

        if (!StringUtil.isNumeric(v2)) {
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
     *Provide (relatively) accurate division operations. When an inexhaustible division occurs, the scale parameter refers to
     *Fixed accuracy.
     *
     *@param v1 parameter
     *@param scale indicates that it needs to be accurate to several digits after the Decimal separator.
     *@return The quotient of two parameters
     */
    public static BigDecimal divForDown(String v1, int scale) {
        if (!StringUtil.checkStr(v1)) {
            v1 = "0";
        }
        if (!StringUtil.isNumeric(v1)) {
            v1 = "0";
        }
        if (scale < 0)
            scale = 0;
        return new BigDecimal(v1).setScale(scale, BigDecimal.ROUND_DOWN);
    }

    public static String divForDownV2(String v1, int scale) {
        if (!StringUtil.checkStr(v1)) {
            v1 = "0";
        }
        if (!StringUtil.isNumeric(v1)) {
            v1 = "0";
        }
        if (scale < 0)
            scale = 0;
        return new BigDecimal(v1).setScale(scale, BigDecimal.ROUND_DOWN).toPlainString();
    }


    /**
     *This method rounding
     *Provide (relatively) accurate division operations. When an inexhaustible division occurs, the scale parameter refers to
     *Fixed accuracy.
     *
     *@param v1 parameter
     *@param scale indicates that it needs to be accurate to several digits after the Decimal separator.
     *@return The quotient of two parameters
     */
    public static BigDecimal divForUp(String v1, int scale) {
        if (!StringUtil.isNumeric(v1)) {
            v1 = "0";
        }
        if (scale < 0)
            scale = 0;

        return new BigDecimal(v1).setScale(scale, BigDecimal.ROUND_UP);
    }

    public static String scaleStr(String v1, int scale) {

        if (!StringUtil.isNumeric(v1)) {
            v1 = "0";
        }
        if (scale < 0)
            scale = 0;

        return new BigDecimal(v1).setScale(scale, BigDecimal.ROUND_FLOOR).toPlainString();
    }

    /**
     *Intercept numbers
     *Rounding
     *
     * @param v1
     *@param scale indicates that it needs to be accurate to several digits after the Decimal separator.
     * @return
     */
    public static BigDecimal intercept(String v1, int scale) {

        if (!StringUtil.isNumeric(v1)) {
            v1 = "0";
        }
        if (scale < 0)
            scale = 0;

        return new BigDecimal(v1).setScale(scale, BigDecimal.ROUND_HALF_UP);
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

    public static String divStr(String v1, String v2, int scale) {
        if (!StringUtil.isNumeric(v1))
            v1 = "0";

        if (!StringUtil.isNumeric(v2)) {
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
     *@return returns the double type
     */
    public static double showDNormal(Double data) {
        return Double.valueOf(showSNormal(data));
    }

    /**
     *Disable Scientific notation
     *
     *@return returns the double type
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
     *IAW, the returned string will not have an exponential form
     *
     *@return returns the double type
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
//        return subZeroAndDot(plainString);
        return plainString;
    }

    public static String showSNormal(String data, int scale,boolean isSubZero) {
        if (!StringUtil.checkStr(data)) {
            return "--";
        }

        if (data.contains("\"")) {
            data = stringReplace(data);
        }
        if (!StringUtil.isNumeric(data)) {
            data = "0";
        }
        String plainString = new BigDecimal(data).setScale(scale, BigDecimal.ROUND_DOWN).toPlainString();
        if(isSubZero){
            return subZeroAndDot(plainString);
        }
        return plainString;
    }

    public static String showSNormalNew(String data) {
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
        return plainString;
    }


    public static String showNormal(String data) {
        if (!StringUtil.isNumeric(data)) {
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
     *Using Java regular expressions to remove excess. and 0
     *
     * @param s
     * @return
     */
    public static String subZeroAndDot(String s) {
        if (!StringUtil.isNumeric(s))
            return "0";

        if (s.indexOf(".") > 0) {
            s = s.replaceAll("0+?$", "");//Remove excess 0
            s = s.replaceAll("[.]$", "");//If the last digit is., remove it
        }
        return s;
    }


    public static String showDepthVolume(String value) {
        if (!StringUtil.isNumeric(value))
            value = "0";

        String temp = new BigDecimal(value).toPlainString();
        if (compareTo(temp, "0.0001") <= 0) {
            return "0.000";
        } else if (compareTo(temp, "1000") >= 0) {
            return formatNumber(temp);
        } else {
            if (temp.contains(".")) {
                return (temp + "00000").substring(0, 5);
            } else {
                String substring = (temp + ".0000").substring(0, 4);
                if (substring.endsWith(".")) {
                    return substring.substring(0, 3);
                } else {
                    return substring;
                }
            }
        }
    }

    public static String showDepthVolumeTx(String value) {
        if (!StringUtil.isNumeric(value))
            value = "0";

        String temp = new BigDecimal(value).toPlainString();
        if (compareTo(temp, "1000") >= 0) {
            return formatNumber(temp);
        }else {
            return temp;
        }
    }

    public static String showDepthContractVolume(String value) {
        if (!StringUtil.isNumeric(value))
            value = "0";

        String temp = new BigDecimal(value).toPlainString();
        if (compareTo(temp, "1000") >= 0) {
            return formatNumber(temp);
        } else {
            return temp;
        }
    }

    /**
     * K表示千（1,000）
     *
     * M表示百万（1,000,000）
     * B表示十亿（1,000,000,000）
     *
     * 数字<1K的（小数点前的位数<4）正常显示，精度取后台配置的该币对的数量精度，小数点后的0不需要处理，如精度是4，则显示12.3400而不是12.34
     *
     * 1K <数字<1M之间（4≤小数点前的位数<7），数字除以1000，单位K，精度保留2位（截取，不用四舍五入）
     * 1M<数字<1B之间（7≤小数点前的位数<10），数字除以1000000，单位M，精度保留2位（截取，不用四舍五入）
     * 1B<数字（10≤小数点前的位数），数字除以1000000000，单位B，精度保留2位（截取，不用四舍五入）
     */
    public static String formatNumber(String str) {
        Log.d("==111=", "" + str);
        if (!StringUtil.isNumeric(str))
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
            String substring = temp.divide(b0, 2, BigDecimal.ROUND_DOWN).toString();
//            if (substring.endsWith(".")) {
//                number = substring.substring(0, 3);
//            } else {
//                number = substring;
//            }
            return substring + "K";
        } else if (temp.compareTo(b1) >= 0 && temp.compareTo(b2) < 0) {
            Log.d("==111=", "M" + str);
            String substring = temp.divide(b1, 2, BigDecimal.ROUND_DOWN).toString();
//            if (substring.endsWith(".")) {
//                number = substring.substring(0, 3);
//            } else {
//                number = substring;
//            }
            return substring + "M";
        } else if (temp.compareTo(b2) >= 0) {
            Log.d("==111=", "B" + str);
            String substring = temp.divide(b2, 2, BigDecimal.ROUND_DOWN).toString();
//            if (substring.endsWith(".")) {
//                number = substring.substring(0, 3);
//            } else {
//                number = substring;
//            }
            return substring + "B";
        } else {
            return showSNormal(number);
        }
    }

    public static int compareToDraw(String v1, String v2) {
        if (!StringUtil.isNumeric(v1))
            v1 = "0";

        if (v1.equals("0")) {
            return -1;
        }
        return compareTo(v1, v2);
    }


    /**
     *Determine if num1 is greater than num2
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
     *Calculate the available quantity for purchase and sale
     *
     * @return
     */

    /**
     *Calculate commission value
     *Positive: commission value=commission price * opening commission quantity * contract face value * exchange rate
     *Reverse: commission value=opening commission quantity * contract face value/commission price
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
            //Entrustment value=Entrustment price * Number of opening orders * Contract face value * Exchange rate
            return entrustedPriceBig.multiply(openEntrustedNumBig).multiply(parValueBig).multiply(rateBig).setScale(scale, BigDecimal.ROUND_HALF_DOWN).toPlainString();
        } else {
            //Commission value=number of opening commissions * Contract face value/commission price
            return openEntrustedNumBig.multiply(parValueBig).divide(entrustedPriceBig, scale, BigDecimal.ROUND_HALF_DOWN).toPlainString();
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
     *Verification of minimum order amount
     *
     * @param inputNum
     * @return
     */
    public static boolean orderMoneyMinCheck(String inputNum, String minNum, String multiplier) {
        int ret = 0;
        ret = compareTo(minNum, inputNum);
        //If two numbers are the same, return 0; if the first number is larger than the second number, return 1; otherwise, return -1
        return ret == 1;
    }

    /**
     *Verification of maximum order amount
     *
     * @param inputNum
     * @return
     */
    public static boolean orderMoneyMaxCheck(String inputNum, String maxNum, String multiplier) {
        int ret = 0;
        ret = compareTo(inputNum, maxNum);
        //If two numbers are the same, return 0; if the first number is larger than the second number, return 1; otherwise, return -1
        return ret == 1;
    }

    /**
     *Calculate warehouse by warehouse equity
     *
     *@param positionMargin
     *@param realizedAmount has achieved profit and loss
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
     *Param fee rate
     *@return Strong flat price (positive contract)=(per position equity/margin exchange rate - position quantity * position direction * marked price)/(maintain margin rate+handling rate) * position quantity - position * position direction)
     *Qiangping Price (Reverse Contract)=(Maintain Margin Rate+Handling Rate) * Number of Positions+Positions * Position Direction)/(Per Position Equity/Margin Exchange Rate+Number of Positions * Position Direction/Mark Price)
     */
    public static String calcForcedPrice(boolean isForward, String positionEquity, String marginRate, String positionVolume, String positionDirection, String markPrice, String keepMarginRate, String feeRate, int scale) {
        BigDecimal positionEquityBig = new BigDecimal(positionEquity);
        BigDecimal marginRateBig = new BigDecimal(marginRate);
        BigDecimal positionVolumeBig = new BigDecimal(positionVolume);
        BigDecimal positionDirectionBig = new BigDecimal(positionDirection);
        BigDecimal markPriceBig = new BigDecimal(markPrice);
        BigDecimal keepMarginRateBig = new BigDecimal(keepMarginRate);
        BigDecimal feeRateBig = new BigDecimal(feeRate);

        if (isForward) {
            BigDecimal buff1 = positionEquityBig.divide(marginRateBig, scale, BigDecimal.ROUND_HALF_DOWN);
            BigDecimal buff2 = positionVolumeBig.multiply(positionDirectionBig).multiply(markPriceBig);
            BigDecimal buff3 = buff1.subtract(buff2);
            BigDecimal buff4 = keepMarginRateBig.add(feeRateBig);
            BigDecimal buff5 = buff4.multiply(positionVolumeBig);
            BigDecimal buff6 = positionVolumeBig.multiply(positionDirectionBig);
            BigDecimal buff7 = buff5.subtract(buff6);
            return buff3.divide(buff7, scale, BigDecimal.ROUND_HALF_DOWN).toPlainString();
        } else {
            BigDecimal buff1 = keepMarginRateBig.add(feeRateBig);
            BigDecimal buff2 = buff1.multiply(positionVolumeBig);
            BigDecimal buff3 = positionVolumeBig.multiply(positionDirectionBig);
            BigDecimal buff4 = buff2.add(buff3);

            BigDecimal buff5 = positionEquityBig.divide(marginRateBig, scale, BigDecimal.ROUND_HALF_DOWN);
            BigDecimal buff6 = positionVolumeBig.multiply(positionDirectionBig).divide(markPriceBig, scale, BigDecimal.ROUND_HALF_DOWN);
            BigDecimal buff7 = buff5.add(buff6);
            return buff4.divide(buff7, scale, BigDecimal.ROUND_HALF_DOWN).toPlainString();
        }


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
            return amountBig.multiply(openingPriceBig).divide(leverBig, scale, BigDecimal.ROUND_HALF_DOWN).divide(marginRateBig, scale, BigDecimal.ROUND_HALF_DOWN).setScale(scale, BigDecimal.ROUND_HALF_DOWN).toPlainString();
        } else {
            //Reverse contract: required margin=initial margin=quantity/opening price/leverage/margin exchange rate
            return amountBig.divide(openingPriceBig, scale, BigDecimal.ROUND_HALF_DOWN).divide(leverBig, scale, BigDecimal.ROUND_HALF_DOWN).divide(marginRateBig, scale, BigDecimal.ROUND_HALF_DOWN).setScale(scale, BigDecimal.ROUND_HALF_DOWN).toPlainString();
        }
    }

    /**
     *Calculate revenue
     *
     *Is @param isForward a forward contract
     *@param direction 0 extra 1 empty
     *@param amount quantity
     *@param openingPrice Opening Price
     *@param closePrice Closing Price
     *@param marginRate Margin exchange rate
     *Param scale accuracy
     * @return
     */
    public static String calcIncomeValue(boolean isForward, int direction, String amount, String openingPrice, String closePrice, String marginRate, int scale) {

        BigDecimal amountBig = new BigDecimal(amount);
        BigDecimal openingPriceBig = new BigDecimal(openingPrice);
        BigDecimal closePriceBig = new BigDecimal(closePrice);
        BigDecimal marginRateBig = new BigDecimal(marginRate);
        /**
         *Income amount (unit: guarantee currency)
         *Forward contract:
         *Buying long yield=(closing price - average opening price) * quantity/margin exchange rate
         *Return on short selling=(closing price - average opening price) * quantity/margin exchange rate * -1
         *
         *Reverse contract:
         *Buying long yield=(1/closing price -1/average opening price) * quantity/margin exchange rate * -1
         *Return on short selling=(1/closing price -1/average opening price) * quantity/margin exchange rate
         */
        String buff = "";
        if (isForward) {
            BigDecimal buff1 = closePriceBig.subtract(openingPriceBig);
            if (direction == 0) {
                //Buy long
                buff = buff1.multiply(amountBig).divide(marginRateBig, scale, BigDecimal.ROUND_HALF_DOWN).setScale(scale, BigDecimal.ROUND_HALF_DOWN).toPlainString();
            } else {
                //Selling short
                buff = buff1.multiply(amountBig).divide(marginRateBig, scale, BigDecimal.ROUND_HALF_DOWN).multiply(new BigDecimal("-1")).setScale(scale, BigDecimal.ROUND_HALF_DOWN).toPlainString();
            }
        } else {
            BigDecimal buff1 = BigDecimal.ONE.divide(closePriceBig, scale, BigDecimal.ROUND_HALF_DOWN);
            BigDecimal buff2 = BigDecimal.ONE.divide(openingPriceBig, scale, BigDecimal.ROUND_HALF_DOWN);
            BigDecimal buff3 = buff1.subtract(buff2);
            if (direction == 0) {
                //Buy long
                buff = buff3.multiply(amountBig).divide(marginRateBig, scale, BigDecimal.ROUND_HALF_DOWN).multiply(new BigDecimal("-1")).setScale(scale, BigDecimal.ROUND_HALF_DOWN).toPlainString();
            } else {
                //Selling short
                buff = buff3.multiply(amountBig).divide(marginRateBig, scale, BigDecimal.ROUND_HALF_DOWN).setScale(scale, BigDecimal.ROUND_HALF_DOWN).toPlainString();
            }
        }
        return buff;
    }

    /**
     *Calculate closing price
     *
     *Is @param isForward a forward contract
     *@param direction 0 extra 1 empty
     *@param amount return rate
     *@param openingPrice Opening Price
     *Param lever
     *Param scale accuracy
     *@return Closing Price
     */
    public static String calcClosePriceValue(boolean isForward, int direction, String amount, String openingPrice, String lever, int scale) {

        BigDecimal amountBig = BigDecimalUtils.div(amount, "100", 5);
        BigDecimal openingPriceBig = new BigDecimal(openingPrice);
        BigDecimal leverBig = new BigDecimal(lever);
        /**
         平仓价格（单位：计价货币）
         正向合约：
         买入做多 平仓价格 = 开仓价格 *(Leverage+Return)/Leverage
         卖出做空 平仓价格 = 开仓价格 *(Leverage Return)/Leverage

         反向合约：
         买入做多 平仓价格 = 开仓价格 *Leverage/(Leverage Return)
         卖出做空 平仓价格 = 开仓价格 *Leverage/(leverage+return)
         */
        String buff = "";
        if (isForward) {
            BigDecimal buff1 = leverBig.add(amountBig);
            BigDecimal buff2 = leverBig.subtract(amountBig);
            if (direction == 0) {
                //Buy long
                buff = openingPriceBig.multiply(buff1).divide(leverBig, scale, BigDecimal.ROUND_HALF_DOWN).setScale(scale, BigDecimal.ROUND_HALF_DOWN).toPlainString();
            } else {
                //Selling short
                buff = openingPriceBig.multiply(buff2).divide(leverBig, scale, BigDecimal.ROUND_HALF_DOWN).setScale(scale, BigDecimal.ROUND_HALF_DOWN).toPlainString();
            }
        } else {

            BigDecimal buff1 = leverBig.subtract(amountBig);
            BigDecimal buff2 = leverBig.add(amountBig);
            if (buff1.compareTo(BigDecimal.ZERO) == 0) {
                return "-1";
            }
            if (direction == 0) {
                //Buy long
                buff = openingPriceBig.multiply(leverBig).divide(buff1, scale, BigDecimal.ROUND_HALF_DOWN).setScale(scale, BigDecimal.ROUND_HALF_DOWN).toPlainString();
            } else {
                //Selling short
                buff = openingPriceBig.multiply(leverBig).divide(buff2, scale, BigDecimal.ROUND_HALF_DOWN).setScale(scale, BigDecimal.ROUND_HALF_DOWN).toPlainString();
            }
        }
        return buff;
    }

    /**
     *Calculate Qiangping Price
     *
     *Is @param isForward a forward contract
     *@param direction 0 extra 1 empty
     *@param marginAmount Margin quantity
     *@param positionAmount Number of positions
     *@param openingPrice Opening Price
     *@param keepMarginRate Maintain margin rate
     *@param marginRate Margin exchange rate
     *Param scale accuracy
     *@return Qiangping Price
     */
    public static String calcForceClosePriceValue(boolean isForward, int direction, String marginAmount, String positionAmount, String openingPrice, String keepMarginRate, String marginRate, int scale) {

        BigDecimal marginAmountBig = new BigDecimal(marginAmount);//Deposit quantity
        BigDecimal openingPriceBig = new BigDecimal(openingPrice);//Opening price
        BigDecimal positionAmountBig = new BigDecimal(positionAmount);//Number of positions
        BigDecimal marginRateBig = new BigDecimal(marginRate);//Margin exchange rate
        BigDecimal keepMarginRateBig = new BigDecimal(keepMarginRate);//Maintain margin ratio
        BigDecimal feeRateBig = new BigDecimal("0.00075");//Handling rate
        /**
         *Qiangping Price (Unit: Valuation Currency)
         *Forward contract:
         *Multi position Strong Leveling Price=(Margin Quantity/Margin Exchange Rate - Number of Positions * Opening Price)/(Maintain Margin Rate+Handling Rate -1) * Number of Positions)
         *Short position strong leveling price=(margin quantity/margin exchange rate+number of positions * opening price)/(maintain margin rate+handling rate+1) * number of positions)
         *
         *Reverse contract:
         *Multi position strong leveling price=((maintain margin ratio+handling rate+1) * number of positions)/(margin quantity/margin exchange rate+number of positions/opening price)
         *Short position strong leveling price=((maintain margin ratio+handling rate -1) * number of positions)/(margin quantity/margin exchange rate - number of positions/opening price)
         *
         *Maintain margin ratio=(number of positions * marked price) Maintain margin ratio of the position in which it is located
         *Handling fee=0.075%
         */
        String buff = "";
        if (isForward) {
            BigDecimal buff1 = marginAmountBig.divide(marginRateBig, scale, BigDecimal.ROUND_HALF_DOWN);
            BigDecimal buff2 = positionAmountBig.multiply(openingPriceBig);
            if (direction == 0) {
                //Buy long
                BigDecimal buff3 = buff1.subtract(buff2);
                BigDecimal buff4 = keepMarginRateBig.add(feeRateBig).subtract(BigDecimal.ONE);
                BigDecimal buff5 = buff4.multiply(positionAmountBig);
                buff = buff3.divide(buff5, scale, BigDecimal.ROUND_HALF_DOWN).setScale(scale, BigDecimal.ROUND_HALF_DOWN).toPlainString();
            } else {
                //Selling short
                BigDecimal buff3 = buff1.add(buff2);
                BigDecimal buff4 = keepMarginRateBig.add(feeRateBig).add(BigDecimal.ONE);
                BigDecimal buff5 = buff4.multiply(positionAmountBig);
                buff = buff3.divide(buff5, scale, BigDecimal.ROUND_HALF_DOWN).setScale(scale, BigDecimal.ROUND_HALF_DOWN).toPlainString();
            }
        } else {
            BigDecimal buff1 = marginAmountBig.divide(marginRateBig, scale, BigDecimal.ROUND_HALF_DOWN);
            BigDecimal buff2 = positionAmountBig.divide(openingPriceBig, scale, BigDecimal.ROUND_HALF_DOWN);
            if (direction == 0) {
                //Buy long
                BigDecimal buff3 = keepMarginRateBig.add(feeRateBig).add(BigDecimal.ONE);
                BigDecimal buff4 = buff3.multiply(positionAmountBig);
                return buff4.divide(buff1.add(buff2), scale, BigDecimal.ROUND_HALF_DOWN).setScale(scale, BigDecimal.ROUND_HALF_DOWN).toPlainString();
            } else {
                //Selling short
                BigDecimal buff3 = keepMarginRateBig.add(feeRateBig).subtract(BigDecimal.ONE);
                BigDecimal buff4 = buff3.multiply(positionAmountBig);
                return buff4.divide(buff1.subtract(buff2), scale, BigDecimal.ROUND_HALF_DOWN).setScale(scale, BigDecimal.ROUND_HALF_DOWN).toPlainString();
            }
        }
        return buff;
    }

    public static String subAndDot(String s) {
        if (!StringUtil.isNumeric(s))
            return "0";

        if (s.indexOf(".") > 0) {
            s = s.replaceAll("[.]$", "");//If the last digit is., remove it
        }
        return s;
    }

    public static String showDepthVolumeNew(String value) {
        if (!StringUtil.isNumeric(value))
            value = "0";

        String temp = new BigDecimal(value).toPlainString();
        if (compareTo(temp, "1000") >= 0) {
            return formatNumber(temp);
        }else {
            return temp;
        }

//        if (compareTo(temp, "0.0001") < 0) {
//            return "0.0000";
//        } else if (compareTo(temp, "1000") >= 0) {
//            return formatNumber(temp);
//        } else {
////            if (temp.contains(".")) {
////                return (temp + "00000").substring(0, 6);
////            } else {
////                String substring = (temp + ".0000").substring(0, 4);
////                if (substring.endsWith(".")) {
////                    return substring.substring(0, 3);
////                } else {
////                    return substring;
////                }
////            }
//            return temp;
//        }
    }

    /**
     *Accurately comparing two numbers
     *
     *The first number to be compared for @param v1
     *The second number to be compared for @param v2
     *@return returns 0 if two numbers are the same, 1 if the first number is greater than the second number, and -1 if the other is greater
     */
    public static int compareTo(BigDecimal v1, BigDecimal v2) {
        return v1.compareTo(v2);

    }

    public static int compareTo(String v1, String v2, int scale) {
        BigDecimal bN1 = divForDown(v1, scale);
        BigDecimal bN2 = divForDown(v2, scale);
        return compareTo(bN1, bN2);
    }

    public static String formatPercent(String value) {
        return new BigDecimal(value).multiply(new BigDecimal(100)).setScale(2,BigDecimal.ROUND_HALF_DOWN).toPlainString() + "%";
    }

}
