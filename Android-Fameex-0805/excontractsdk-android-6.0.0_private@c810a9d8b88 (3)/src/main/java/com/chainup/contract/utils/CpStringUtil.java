package com.chainup.contract.utils;

import android.text.TextUtils;

import org.json.JSONObject;

import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class CpStringUtil {

    public static boolean isNickName(String str) {
        String regExp = "^[\\u4E00-\\u9FA5\\uF900-\\uFA2D\\w]{1,12}$";

        Pattern p = Pattern.compile(regExp);

        Matcher m = p.matcher(str);

        return m.find();
    }

    //How to convert national standard code and location code?
    static final int GB_SP_DIFF = 160;
    //National standard for storage? Starting location codes for different pronunciations of Chinese characters
    static final int[] secPosValueList = {1601, 1637, 1833, 2078, 2274, 2302,
            2433, 2594, 2787, 3106, 3212, 3472, 3635, 3722, 3730, 3858, 4027,
            4086, 4390, 4558, 4684, 4925, 5249, 5600};
    //National standard for storage? The starting location code corresponding to the pronunciation of different pronunciations of Chinese characters
    static final char[] firstLetter = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h',
            'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'w', 'x',
            'y', 'z'};

    //Get? The pinyin of a string?
    public static String getFirstLetter(String oriStr) {
        String str = oriStr.toLowerCase();
        StringBuffer buffer = new StringBuffer();
        char ch;
        char[] temp;
        for (int i = 0; i < str.length(); i++) { //Process each word in str sequentially?
            ch = str.charAt(i);
            temp = new char[]{ch};
            byte[] uniCode = new String(temp).getBytes();
            if (uniCode[0] < 128 && uniCode[0] > 0) { //Non Han?
                buffer.append(temp);
            } else {
                buffer.append(convert(uniCode));
            }
        }
        return buffer.toString();
    }

    /**
     *Get? The first letter of a Chinese character? Two bytes of the GB code are subtracted respectively? 60, converted to a combination of decimal codes to obtain the location?
     *For example, the GB code of the Chinese character "you" is 0xC4/0xE3, minus? xA0�? 60) Right? x24/0x43
     *0x24 is converted to 10, which is 36? x43�? 7, so its location code is 3667. What is the pronunciation in the comparison table? n�?
     */
    static char convert(byte[] bytes) {
        char result = '-';
        int secPosValue = 0;
        int i;
        for (i = 0; i < bytes.length; i++) {
            bytes[i] -= GB_SP_DIFF;
        }
        secPosValue = bytes[0] * 100 + bytes[1];
        for (i = 0; i < 23; i++) {
            if (secPosValue >= secPosValueList[i]
                    && secPosValue < secPosValueList[i + 1]) {
                result = firstLetter[i];
                break;
            }
        }
        return result;
    }

    /*
     *Verify the legality of the string
     *True: Valid
     *False: Invalid
     */
    public static boolean checkStr(String str) {
        if (null == str)
            return false;

        if ("null".equalsIgnoreCase(str) || "nul".equalsIgnoreCase(str)) {
            return false;
        }

        return str.trim().length() > 0;
    }


    //Determine whether the phone number format is correct
    public static boolean isMobileNO(String mobiles) {
        if (!checkStr(mobiles) || mobiles.length() != 11)
            return false;
        return isNumeric(mobiles) & mobiles.startsWith("1");

    }

    /*
     *Determining whether a string contains numbers
     */
    public static boolean isContainsNum(String content) {
        if (!checkStr(content))
            return false;
        boolean isDigit = false;
        for (int i = 0; i < content.length(); i++) { //Loop through a string
            if (Character.isDigit(content.charAt(i))) { //Judge each character using the method of judging numbers in the char packaging class
                isDigit = true;
            }
            if (Character.isLetter(content.charAt(i))) { //Judge each character using the method of judging letters in the char packaging class
                // isLetter = true;
            }
        }
        return isDigit;
    }

    /*
     *Is it a Chinese character
     */
    public static boolean isChineseChar(String str) {
        if (!checkStr(str))
            return false;
        boolean temp = false;
        Pattern p = Pattern.compile("[\u4e00-\u9fa5]");
        Matcher m = p.matcher(str);
        if (m.find()) {
            temp = true;
        }
        return temp;
    }

    public static String formatMoney(String s) {// , int len
        if (!checkStr(s))
            return "";
        int len = s.length();
        NumberFormat formater = null;
        double num = Double.parseDouble(s);
        if (len == 0) {
            formater = new DecimalFormat("###,###");

        } else {
            StringBuffer buff = new StringBuffer();
            buff.append("###,###.");
            for (int i = 0; i < len; i++) {
                buff.append("#");
            }
            formater = new DecimalFormat(buff.toString());
        }
        String result = formater.format(num);
        /*
         * if (result.indexOf(".") == -1) { result = "￥" + result + ".00"; }
         * else { result = "￥" + result; }
         */
        return result;
    }

    /*
     *Check for decimals
     */
    public static boolean isPointNum(String value) {
        if (!checkStr(value))
            return false;
        try {
            Double.parseDouble(value);
        } catch (NumberFormatException e) {
            return false;
        }
        return true;
    }

    /*
     *Check whether it is an integer number
     */
    public static boolean isIntNum(String value) {
        if (!checkStr(value))
            return false;
        try {
            Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return false;
        }
        return true;
    }

    /*
     *Check if there are numbers
     */
    public static boolean isDoubleNum(String value) {
        if (!checkStr(value))
            return false;
        try {
            Double.parseDouble(value);
        } catch (NumberFormatException e) {
            return false;
        }
        return true;
    }

    public static String getStringsByList(ArrayList<String> list) {
        if (null == list || list.size() <= 0)
            return null;
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < list.size(); i++) {
            sb.append(list.get(i) + ",");
        }
        return sb.toString();
    }

    public static boolean isHttpUrl(String url) {
        if (!checkStr(url))
            return false;
        return url.startsWith("http");
    }

    /*
     * "[{\"1\":12.7},{\"3\":13.8},{\"60\":14.8}]",
     */
    public static String getJSONObjectStr(JSONObject obj) {
        if (null == obj)
            return "";
        Iterator<String> iterator = obj.keys();
        StringBuilder sb = new StringBuilder();
        while (iterator.hasNext()) {
            String key = iterator.next();
            Object value = obj.opt(key);
            String bb = key + "个月" + value + "%";
            sb.append(bb + "、");
        }
        if (sb.length() > 0) {
            sb = sb.deleteCharAt(sb.lastIndexOf("、"));
        }
        return sb.toString();
    }

    public static boolean checkEmail(String email) {
        if (null == email) {
            return false;
        }
        return email.contains("@") && email.contains(".");
    }


    public static String[] split(String str, String regex) {
        if (str.contains(regex)) {
            return str.split(regex);
        }
        return null;
    }

    /*
     *The general judgment is whether it is a number, including regular verifications such as, 0.000000070000,1.0., 888hhhh, etc
     * https://blog.csdn.net/u013066244/article/details/53197756
     */
    public static boolean isNumeric(String str) {
        if (!checkStr(str))
            return false;
        //This regular expression can match all numbers, including negative numbers
        Pattern pattern = Pattern.compile("-?[0-9]+(\\.[0-9]+)?");
        String bigStr;
        try {
            bigStr = new BigDecimal(str).toPlainString();
        } catch (Exception e) {
            System.out.println("Exception==" + e.getMessage());
            return false;//The exception description contains non numeric characters.
        }
        Matcher isNum = pattern.matcher(bigStr); //Matcher is a full match
        if (!isNum.matches()) {
            return false;
        }
        return true;
    }

    public static int getPointStep(String str) {
        if (!isNumeric(str) || !str.contains(".")) {
            return 0;
        }
        str = str.substring(str.indexOf(".") + 1);
        System.out.println("str is " + str);
        return null != str ? str.length() : 0;//ss[1].length();
    }

    public static boolean isNumericAndroidLenght(String str) {
        if (str != null && str.trim().length() <= 6) {
            return true;
        }
        return false;
    }

    /*
     *Is it a Chinese character
     */
    public static boolean isDoMainUrl(String str) {
        if (!checkStr(str))
            return false;
        boolean temp = false;
        Pattern p = Pattern.compile("\\d{7,}");
        Matcher m = p.matcher(str);
        if (m.find()) {
            temp = true;
        }
        return temp;
    }

    /**
     *Replace the middle 4 bits with *
     * @param phone
     * @return
     */
    public static String midleReplaceStar(String phone){
        String result=null;
        if (!TextUtils.isEmpty(phone)){
            if (phone.length()<7){
                result=phone;
            }else{
                String start = phone.substring(0,3);
                String end = phone.substring(phone.length()-4,phone.length());
                StringBuilder sb=new StringBuilder();
                sb.append(start).append("****").append(end);
                result=sb.toString();
            }
        }
        return result;
    }

    /**
     *Regular Replacement Strong Leveling Detail Time
     * @param str
     * @return
     */
    public static String liqPositionTime(String str,String timeLong) {
        str = str.replace("\\n","<br/>");
        String ss="([0-9]{3}[1-9]|[0-9]{2}[1-9][0-9]{1}|[0-9]{1}[1-9][0-9]{2}|[1-9][0-9]{3})-(((0[13578]|1[02])-(0[1-9]|[12][0-9]|3[01]))|((0[469]|11)-(0[1-9]|[12][0-9]|30))|(02-(0[1-9]|[1][0-9]|2[0-8])))([ ])([0-1]?[0-9]|2[0-3]):([0-5][0-9]):([0-5][0-9])";
        Pattern pattern = Pattern.compile(ss);
        Matcher matcher = pattern.matcher(str);
        String timeStr=  CpTimeFormatUtils.timeStampToDate(Long.parseLong(timeLong), "yyyy-MM-dd  HH:mm:ss");
        String newStr = matcher.replaceFirst(timeStr);
        return newStr.replaceAll("@","");
    }

}
