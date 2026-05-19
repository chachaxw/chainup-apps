package com.chainup.contract.utils;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class CpMD5Util {

    public static final String salt = "jys20170921";
	/**
     *Get the MD5 value of String
     *
     *@param info string
     *@return The MD5 value of this string
     */
    public static String getMD5(String info) {
        try {
            //Obtain the MessageDigest object with a parameter of MD5 string, indicating that this is an MD5 algorithm (other algorithms include SHA1 algorithm, etc.):
            MessageDigest md5 = MessageDigest.getInstance("MD5");
            //Update (byte []) method, input the original data
            //Similar to the append() method of a StringBuilder object, the append mode is a cumulative change process
            md5.update(info.getBytes(StandardCharsets.UTF_8));
            //After digest () is called, the MessageDigest object is reset, which means that the method cannot be continuously called again to calculate the MD5 value of the original data. You can manually call the reset () method to reset the input source.
            //Digest () returns a hash value with a length of 16 bits, which is taken over by byte []
            byte[] md5Array = md5.digest();
            //Byte [] is usually converted to a 32-bit hexadecimal string for use. This article will introduce three commonly used conversion methods
            return bytesToHex(md5Array);
        } catch (NoSuchAlgorithmException e) {
            return "";
        }
    }

    private static String bytesToHex(byte[] md5Array) {
        StringBuilder strBuilder = new StringBuilder();
        for (int i = 0; i < md5Array.length; i++) {
            int temp = 0xff & md5Array[i];//TODO: Why add 0xff&here?
            String hexString = Integer.toHexString(temp);
            if (hexString.length() == 1) {//If it is a hexadecimal 0f, only f is displayed by default, and 0 should be added at this time
                strBuilder.append("0").append(hexString);
            } else {
                strBuilder.append(hexString);
            }
        }
        return strBuilder.toString();
    }
    
	public static void main(String[] args) {
		System.out.println(CpMD5Util.getMD5("123456789aaa"));
	}
}
