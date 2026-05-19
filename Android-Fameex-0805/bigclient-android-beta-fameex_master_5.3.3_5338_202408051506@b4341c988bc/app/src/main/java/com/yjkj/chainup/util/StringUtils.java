package com.yjkj.chainup.util;


import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.style.AbsoluteSizeSpan;

import com.yjkj.chainup.R;
import com.yjkj.chainup.app.ChainUpApp;

import java.nio.ByteBuffer;
import java.nio.CharBuffer;
import java.nio.charset.Charset;
import java.nio.charset.CharsetDecoder;
import java.nio.charset.StandardCharsets;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.Hashtable;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class StringUtils {


    /**
     *Obtain SpannableString for setting prompts with different font sizes from the input box
     *
     *Param hint prompt
     * @return
     */
    public static SpannableString getEditHintString(String hint) {
        SpannableString s = new SpannableString(hint);
        AbsoluteSizeSpan textSize = new AbsoluteSizeSpan(12, true);
        s.setSpan(textSize, 0, s.length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        return s;
    }

    public static String bytesToHexString(byte[] src) {

        StringBuilder stringBuilder = new StringBuilder();
        if (src == null || src.length <= 0) {
            return null;
        }
        for (int i = 0; i < src.length; i++) {
            int v = src[i] & 0xFF;
            String hv = Integer.toHexString(v);
            if (hv.length() < 2) {
                stringBuilder.append(0);
            }
            stringBuilder.append(hv);
        }

        return stringBuilder.toString();

    }

    /**
     *Hexadecimal conversion string
     *
     *@param hexStr Byte string (no separator between Bytes, such as [616C6B])
     *The string corresponding to @return String
     */
    public static String hexStr2Str(String hexStr) {
        String str = "0123456789ABCDEF";
        char[] hexs = hexStr.toCharArray();
        byte[] bytes = new byte[hexStr.length() / 2];
        int n;

        for (int i = 0; i < bytes.length; i++) {
            n = str.indexOf(hexs[2 * i]) * 16;
            n += str.indexOf(hexs[2 * i + 1]);
            bytes[i] = (byte) (n & 0xff);
        }
        return new String(bytes);
    }


    public static String byteBufferToString(ByteBuffer buffer) {
//        CharBuffer charBuffer = null;
//        try {
//            Charset charset = Charset.forName("utf-8");
//            CharsetDecoder decoder = charset.newDecoder();
//            char[] chars = charset.decode(buffer).array();
//            String result = new String(chars);
//            buffer.flip();
//            return new String(result.getBytes("utf-8"));
//        } catch (Exception ex) {
//            ex.printStackTrace();
//            return null;
//        }
        byte[] bytes = buffer.array();

        buffer.flip();
        String result = new String(bytes, StandardCharsets.UTF_8);
        return result;
    }


    /**
     *ByteBuffer Conversion String
     *
     * @param buffer
     * @return
     */
    public static String getString(ByteBuffer buffer) {

        Charset charset = null;

        CharsetDecoder decoder = null;

        CharBuffer charBuffer = null;

        try {

            charset = Charset.forName("GBK");

            decoder = charset.newDecoder();

            //If you use this, you can only output the result once, and the second time it will be displayed as empty

// charBuffer = decoder.decode(buffer);

            charBuffer = decoder.decode(buffer.asReadOnlyBuffer());

            return charBuffer.toString();

        } catch (Exception ex) {

            ex.printStackTrace();

            return "error";

        }

    }


    /**
     *Verify password, limited to 8-20 digits in length, including at least letters and numbers
     *
     * @param pass
     * @return
     */
    public static boolean checkPass(String pass) {
        if (TextUtils.isEmpty(pass)) {
//            UIUtils.showToast(getString(R.string.toast_no_pass));
            return false;
        }
        String regex = "^(?=.*\\d)(?=.*[a-zA-Z]).{8,20}$";
        //            UIUtils.showToast(getString(R.string.toast_new_pass_format_error));
        return pass.matches(regex);
    }


    /**
     *Verify the fund password, with a limit of 8-16 digits, digits+digits
     *
     * @param pass
     * @return
     */
    public static boolean checkAssetsPass(String pass) {
        if (TextUtils.isEmpty(pass)) {
            UIUtils.showToast(StringUtils.getString(R.string.register_tip_inputPassword));
            return false;
        }
        String regex = "^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z~!@#$%^&*()]{8,16}$";
        if (!pass.matches(regex)) {
            UIUtils.showToast(getString(R.string.toast_asset_pass_format_error));
            return false;
        }
        return true;
    }


    public static String getString(int resId) {
        return ChainUpApp.appContext.getString(resId);
    }


    /**
     *Verify phone number
     *
     *@param phoneNumber Mobile number
     * @return boolean
     */
    public static boolean checkPhoneNumber(String phoneNumber) {
        Pattern pattern = Pattern.compile("^1[0-9]{10}$");
        Matcher matcher = pattern.matcher(phoneNumber);
        return matcher.matches();
    }


    //Determine if the email format is correct
    public static boolean checkEmail(String email) {
        String str = "^[a-zA-Z0-9_.-]+@[a-zA-Z0-9-]+(\\\\.[a-zA-Z0-9-]+)*\\.[a-zA-Z0-9]{2,6}$";
        Pattern p = Pattern.compile(str);
        Matcher m = p.matcher(email);

        return m.matches();
    }


    /**
     *Function: Effective verification of ID card
     *
     *@param IDstr ID number
     *@return valid: returns' 'invalid: returns String information
     * @throws ParseException
     */
    public static boolean IDCardValidate(String IDStr) throws ParseException {
        String errorInfo = "";//Record error information
        String[] ValCodeArr = {"1", "0", "x", "9", "8", "7", "6", "5", "4",
                "3", "2"};
        String[] Wi = {"7", "9", "10", "5", "8", "4", "2", "1", "6", "3", "7",
                "9", "10", "5", "8", "4", "2"};
        String Ai = "";
        // ================ 号码的长度 15位或18位 ================
        if (IDStr.length() != 15 && IDStr.length() != 18) {
            errorInfo = "身份证号码长度应该为15位或18位。";
            return false;
        }
        // =======================(end)========================

        // ================ 数字 除最后以为都为数字 ================
        if (IDStr.length() == 18) {
            Ai = IDStr.substring(0, 17);
        } else if (IDStr.length() == 15) {
            Ai = IDStr.substring(0, 6) + "19" + IDStr.substring(6, 15);
        }
        if (isNumeric(Ai) == false) {
            errorInfo = "身份证15位号码都应为数字 ; 18位号码除最后一位外，都应为数字。";
            return false;
        }
        // =======================(end)========================

        // ================ 出生年月是否有效 ================
        String strYear = Ai.substring(6, 10);//Year
        String strMonth = Ai.substring(10, 12);//Month
        String strDay = Ai.substring(12, 14);//Month
        if (isDataFormat(strYear + "-" + strMonth + "-" + strDay) == false) {
            errorInfo = "身份证生日无效。";
            return false;
        }
        GregorianCalendar gc = new GregorianCalendar();
        SimpleDateFormat s = new SimpleDateFormat("yyyy-MM-dd");
        try {
            if ((gc.get(Calendar.YEAR) - Integer.parseInt(strYear)) > 150
                    || (gc.getTime().getTime() - s.parse(
                    strYear + "-" + strMonth + "-" + strDay).getTime()) < 0) {
                errorInfo = "身份证生日不在有效范围。";
                return false;
            }
        } catch (NumberFormatException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } catch (ParseException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        if (Integer.parseInt(strMonth) > 12 || Integer.parseInt(strMonth) == 0) {
            errorInfo = "身份证月份无效";
            return false;
        }
        if (Integer.parseInt(strDay) > 31 || Integer.parseInt(strDay) == 0) {
            errorInfo = "身份证日期无效";
            return false;
        }
        // =====================(end)=====================

        // ================ 地区码时候有效 ================
        Hashtable h = GetAreaCode();
        if (h.get(Ai.substring(0, 2)) == null) {
            errorInfo = "身份证地区编码错误。";
            return false;
        }
        // ==============================================

        // ================ 判断最后一位的值 ================
        int TotalmulAiWi = 0;
        for (int i = 0; i < 17; i++) {
            TotalmulAiWi = TotalmulAiWi
                    + Integer.parseInt(String.valueOf(Ai.charAt(i)))
                    * Integer.parseInt(Wi[i]);
        }
        int modValue = TotalmulAiWi % 11;
        String strVerifyCode = ValCodeArr[modValue];
        Ai = Ai + strVerifyCode;

        if (IDStr.length() == 18) {
            if (Ai.equals(IDStr) == false) {
                errorInfo = "身份证无效，不是合法的身份证号码";
                return false;
            }
        } else {
            return true;
        }
        // =====================(end)=====================
        return true;
    }

    /**
     *Function: Determine whether a string is a number
     *
     * @param str
     * @return
     */
    public static boolean isNumeric(String str) {
        Pattern pattern = Pattern.compile("[0-9]*");
        Matcher isNum = pattern.matcher(str.trim());
        return isNum.matches();
    }

    /**
     *Function: Set region code
     *
     *@return Hashtable object
     */
    @SuppressWarnings({"rawtypes", "unchecked"})
    private static Hashtable GetAreaCode() {
        Hashtable hashtable = new Hashtable();
        hashtable.put("11", "北京");
        hashtable.put("12", "天津");
        hashtable.put("13", "河北");
        hashtable.put("14", "山西");
        hashtable.put("15", "内蒙古");
        hashtable.put("21", "辽宁");
        hashtable.put("22", "吉林");
        hashtable.put("23", "黑龙江");
        hashtable.put("31", "上海");
        hashtable.put("32", "江苏");
        hashtable.put("33", "浙江");
        hashtable.put("34", "安徽");
        hashtable.put("35", "福建");
        hashtable.put("36", "江西");
        hashtable.put("37", "山东");
        hashtable.put("41", "河南");
        hashtable.put("42", "湖北");
        hashtable.put("43", "湖南");
        hashtable.put("44", "广东");
        hashtable.put("45", "广西");
        hashtable.put("46", "海南");
        hashtable.put("50", "重庆");
        hashtable.put("51", "四川");
        hashtable.put("52", "贵州");
        hashtable.put("53", "云南");
        hashtable.put("54", "西藏");
        hashtable.put("61", "陕西");
        hashtable.put("62", "甘肃");
        hashtable.put("63", "青海");
        hashtable.put("64", "宁夏");
        hashtable.put("65", "新疆");
        hashtable.put("71", "台湾");
        hashtable.put("81", "香港");
        hashtable.put("82", "澳门");
        hashtable.put("91", "国外");
        return hashtable;
    }

    /**
     *Verify if the date string is in YYYY-MM-DD format
     *
     * @param str
     * @return
     */
    private static boolean isDataFormat(String str) {
        boolean flag = false;
        // String
        // regxStr="[1-9][0-9]{3}-[0-1][0-2]-((0[1-9])|([12][0-9])|(3[01]))";
        String regxStr = "^((\\d{2}(([02468][048])|([13579][26]))[\\-\\/\\s]?((((0?[13578])|(1[02]))[\\-\\/\\s]?((0?[1-9])|([1-2][0-9])|(3[01])))|(((0?[469])|(11))[\\-\\/\\s]?((0?[1-9])|([1-2][0-9])|(30)))|(0?2[\\-\\/\\s]?((0?[1-9])|([1-2][0-9])))))|(\\d{2}(([02468][1235679])|([13579][01345789]))[\\-\\/\\s]?((((0?[13578])|(1[02]))[\\-\\/\\s]?((0?[1-9])|([1-2][0-9])|(3[01])))|(((0?[469])|(11))[\\-\\/\\s]?((0?[1-9])|([1-2][0-9])|(30)))|(0?2[\\-\\/\\s]?((0?[1-9])|(1[0-9])|(2[0-8]))))))(\\s(((0?[0-9])|([1-2][0-3]))\\:([0-5]?[0-9])((\\s)|(\\:([0-5]?[0-9])))))?$";
        Pattern pattern1 = Pattern.compile(regxStr);
        Matcher isNo = pattern1.matcher(str);
        if (isNo.matches()) {
            flag = true;
        }
        return flag;
    }

    /**
     *Hide the middle 4 digits of your phone number
     * @param string
     * @return
     */
    public static String hideMoible(String string){
        return string.replaceAll("(\\d{3})\\d{4}(\\d{4})","$1****$2");
    }


    /**
     *Determine whether a string is a number
     */
    public static boolean isNumber(String value) {
        return isInteger(value) || isDouble(value);
    }
    /**
     *Determine whether a string is an integer
     */
    public static boolean isInteger(String value) {
        try {
            Integer.parseInt(value);
            return true;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    /**
     *Judge whether the string is a Floating-point arithmetic number
     */
    public static boolean isDouble(String value) {
        try {
            Double.parseDouble(value);
            if (value.contains("."))
                return true;
            return false;
        } catch (NumberFormatException e) {
            return false;
        }
    }

}
