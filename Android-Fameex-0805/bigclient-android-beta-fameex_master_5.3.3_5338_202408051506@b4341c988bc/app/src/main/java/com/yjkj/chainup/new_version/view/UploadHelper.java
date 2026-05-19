package com.yjkj.chainup.new_version.view;

import android.text.format.DateFormat;
import android.util.Log;

import com.alibaba.sdk.android.oss.ClientConfiguration;
import com.alibaba.sdk.android.oss.OSS;
import com.alibaba.sdk.android.oss.OSSClient;
import com.alibaba.sdk.android.oss.common.auth.OSSCredentialProvider;
import com.alibaba.sdk.android.oss.common.auth.OSSStsTokenCredentialProvider;
import com.alibaba.sdk.android.oss.model.PutObjectRequest;
import com.alibaba.sdk.android.oss.model.PutObjectResult;
import com.yjkj.chainup.app.ChainUpApp;
import com.yjkj.chainup.util.HashUtil;

import java.io.File;
import java.util.Date;

/**
 * @Author lianshangljl
 * @Date 2023/1/25-4:02 PM
 * @Email buptjinlong@163.com
 * @description
 */
public class UploadHelper {
    //Related to personal storage areas
    //Upload warehouse name


    private static OSS getOSSClient(String keyId, String keySecret, String endpoint, String keyToken) {
        OSSCredentialProvider credentialProvider = new OSSStsTokenCredentialProvider(keyId, keySecret, keyToken);
        ClientConfiguration conf = new ClientConfiguration();
        conf.setConnectionTimeout(15 *1000);// Connection timeout, default to 15 seconds
        conf.setSocketTimeout(15 *1000);// Socket timeout, default to 15 seconds
        conf.setMaxConcurrentRequest(8); //Maximum concurrent requests, default to 5
        conf.setMaxErrorRetry(2); //Maximum number of retries after failure, default to 2
        return new OSSClient(ChainUpApp.appContext, endpoint, credentialProvider, conf);


    }


    public UploadHelper() {

    }

    /**
     *Upload method
     *
     *@param objectKey identification
     *@param path Path to upload files
     *@return Path for external network access
     */
    private static String upload(String objectKey, String path, String keyId, String keySecret, String bucketname, String endpoint, String keyToken) {
        //Construct upload request
        PutObjectRequest request =
                new PutObjectRequest(bucketname,
                        objectKey, path);
        try {
            //Get client
            OSS client = getOSSClient(keyId, keySecret, endpoint, keyToken);
            //Upload to obtain results
            PutObjectResult result = client.putObject(request);
            //Obtain accessible URLs
            String url = client.presignPublicObjectURL(bucketname, objectKey);
            //Format Printout
            Log.e("PublicObjectURL:%s", url);
            return url;
        } catch (Exception e) {
            e.printStackTrace();
            return "";
        }

    }

    /**
     *Upload regular images
     *
     *@param path local address
     *@return Server Address
     */
    public static String uploadImage(String path, String keyId, String keySecret, String bucketname, String endpoint, String keyToken, String ossPath) {
        String key = getObjectImageKey(path, ossPath);
        return upload(key, path, keyId, keySecret, bucketname, endpoint, keyToken);
    }

    /**
     *Upload avatar
     *
     *@param path local address
     *@return Server Address
     */
    public static String uploadPortrait(String path, String keyId, String keySecret, String bucketname, String endpoint, String keyToken) {
        String key = getObjectPortraitKey(path);
        return upload(key, path, keyId, keySecret, bucketname, endpoint, keyToken);
    }

    /**
     *Upload audio
     *
     *@param path local address
     *@return Server Address
     */
    public static String uploadAudio(String path, String keyId, String keySecret, String bucketname, String endpoint, String keyToken) {
        String key = getObjectAudioKey(path);
        return upload(key, path, keyId, keySecret, bucketname, endpoint, keyToken);
    }


    /**
     *Get Time
     *
     *@return timestamp Example: 201805
     */
    private static String getDateString() {
        return DateFormat.format("yyyyMM", new Date()).toString();
    }

    /**
     *Return key
     *
     *@param path Local path
     * @return key
     */
    //Format: image/201805/sfdsgfsdvsdfdsfs.jpg
    private static String getObjectImageKey(String path, String ossPath) {
        String fileMd5 = HashUtil.getMD5String(new File(path));
        return String.format(ossPath + "%s.jpg", fileMd5);
    }

    //Format: portal/201805/sfdsgfsdvsdfdsfs.jpg
    private static String getObjectPortraitKey(String path) {
        String fileMd5 = HashUtil.getMD5String(new File(path));
        String dateString = getDateString();
        return String.format("portrait/%s.jpg", dateString, fileMd5);
    }

    //Format: audio/201805/sfdsgfsdvsdfdsfs.mp3
    private static String getObjectAudioKey(String path) {
        String fileMd5 = HashUtil.getMD5String(new File(path));
        String dateString = getDateString();
        return String.format("audio/%s/%s.mp3", dateString, fileMd5);
    }

}
