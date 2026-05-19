package com.yjkj.chainup.util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class MD5Util {

    public static final String salt = "jys20170921";
	/**
     *Obtain the MD5 value of String
     *
     *@param info string
     *@return The MD5 value of this string
     */
    public static String getMD5(String info) {
        try {
            //Obtain the Message Digest object with an MD5 string as the parameter, indicating that this is an MD5 algorithm (other algorithms include SHA1 algorithm, etc.):
            MessageDigest md5 = MessageDigest.getInstance("MD5");
            //Update (byte []) method, input the original data
            //Similar to append() method of StringBuilder object, append mode is a cumulative change process
            md5.update(info.getBytes(StandardCharsets.UTF_8));
            //After digest () is called, the Message Digest object is reset, meaning that the method cannot be continuously called again to calculate the MD5 value of the original data. You can manually call the reset() method to reset the input source.
            //Digest () returns a hash value of 16 bits in length, taken over by byte []
            byte[] md5Array = md5.digest();
            //Byte [] is usually converted to hexadecimal 32-bit string for use. This article will introduce three common conversion methods
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
            if (hexString.length() == 1) {//If it is hexadecimal 0f, only f is displayed by default, and 0 should be added at this time
                strBuilder.append("0").append(hexString);
            } else {
                strBuilder.append(hexString);
            }
        }
        return strBuilder.toString();
    }
    
	public static void main(String[] args) {
		
	}
}
