package com.yjkj.chainup.net_new

import android.app.DownloadManager
import android.content.IntentFilter
import android.net.Uri
import androidx.appcompat.app.AppCompatActivity
import android.text.TextUtils
import android.util.Log
import android.webkit.MimeTypeMap
import com.yjkj.chainup.app.AppConfig
import com.yjkj.chainup.app.ChainUpApp
import com.yjkj.chainup.app.GlobalAppComponent
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.interceptor.NetInterceptor
import com.yjkj.chainup.net.api.ApiConstants
import com.yjkj.chainup.util.*
import com.yjkj.chainup.util.HttpsUtils
import com.yjkj.chainup.wedegit.DownLoadReceiver
import okhttp3.Cache
import okhttp3.OkHttpClient
import okhttp3.Protocol
import okhttp3.logging.HttpLoggingInterceptor
import org.json.JSONArray
import org.json.JSONObject
import retrofit2.Retrofit
import retrofit2.adapter.rxjava2.RxJava2CallAdapterFactory
import retrofit2.converter.gson.GsonConverterFactory
import java.io.File
import java.io.InputStream
import java.util.*

import java.util.concurrent.TimeUnit

/**
 *The HTTP helper is responsible for creating ApiService instances
 */
class HttpHelper {
    public val mServiceMap = HashMap<String, Any>()//: HashMap<String, Any>?=null

    private var mOkHttpClient: OkHttpClient? = null

    init {
        initOkHttpClient()
    }

    fun clearServiceMap() {
        mServiceMap?.clear()
    }

    private fun initOkHttpClient() {
        val buidler = OkHttpClient.Builder()

        var certString = "cert.cer"
        var array = arrayListOf<InputStream>()
        if (AssetsUtil.isExist(certString)) {
            array.add(ChainUpApp.appContext.resources.assets.open(certString))

        }
        val links = PublicInfoDataService.getInstance().links
        if ((ApiConstants.APP_SWITCH_SAAS != "0" || PublicInfoDataService.getInstance().androidOnline) && !TextUtils.isEmpty(links)) {
            var linksArray = JSONUtil.arrayToList(JSONArray(links))

            if (null != linksArray) {
                for (num in 0 until linksArray.size) {
                    if (AssetsUtil.isExist("${linksArray[num].optString("hostFileName")}.cer")) {
                        array.add(ChainUpApp.appContext.resources.assets.open("${linksArray[num].optString("hostFileName")}.cer"))
                    }
                }
            }
        }


        val sslParams = HttpsUtils.getSslSocketFactory(null, null, null)

        buidler.protocols(Collections.singletonList(Protocol.HTTP_1_1))
        buidler.sslSocketFactory(sslParams.sSLSocketFactory, sslParams.trustManager)


        buidler.readTimeout(AppConfig.read_time, TimeUnit.MILLISECONDS)
        buidler.writeTimeout(AppConfig.write_time, TimeUnit.MILLISECONDS)
        buidler.connectTimeout(AppConfig.connect_time, TimeUnit.MILLISECONDS)
        buidler.addInterceptor(NetInterceptor())
        buidler.retryOnConnectionFailure(true)
        buidler.cache(cache)
        if (AppConfig.IS_DEBUG) {
            val loggingInterceptor = HttpLoggingInterceptor().setLevel(HttpLoggingInterceptor.Level.BODY)
            buidler.addInterceptor(loggingInterceptor)
        }
        mOkHttpClient = buidler.build()
        Thread(Runnable {
            try {
                var jsonFile = Utils.getJSONLastNews()
                PublicInfoDataService.getInstance().saveCetData(jsonFile)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }).start()
    }

    fun downPciture(mDownLoadPath: String) {
        //Create download task
        var request = DownloadManager.Request(Uri.parse(mDownLoadPath))
        //Can roaming networks be downloaded
        request.setAllowedOverRoaming(false)

        //Set the file type to automatically open the file after the download is completed
        var mimeTypeMap = MimeTypeMap.getSingleton()
        var mimeString = mimeTypeMap.getMimeTypeFromExtension(MimeTypeMap.getFileExtensionFromUrl(mDownLoadPath))
        request.setMimeType(mimeString)

        //Displayed in the notification bar, default to displayed
        request.setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE);
        request.setVisibleInDownloadsUi(true);

        //The download folder in the sdcard directory must be set
        request.setDestinationInExternalPublicDir(ChainUpApp.appContext.getPackageName()
                + File.separator + "cer" + File.separator, ParamConstant.MFILENAME)
        //Request. setDestinationInExternalFilesDir(), or you can customize the download path yourself

        //Add download requests to the download queue
        var downloadManager = ChainUpApp.appContext.getSystemService(AppCompatActivity.DOWNLOAD_SERVICE) as DownloadManager
        //After joining the download queue, a long type ID will be returned for the task,
        //By using this ID, tasks can be cancelled, restarted, and so on
        var taskId = downloadManager.enqueue(request)

        //Register a broadcast receiver and listen for download status
        var downLoadReceiver = DownLoadReceiver(ChainUpApp.appContext, downloadManager, taskId, ParamConstant.MFILENAME)
        ChainUpApp.appContext.registerReceiver(downLoadReceiver, IntentFilter(DownloadManager.ACTION_DOWNLOAD_COMPLETE))
    }


    fun inSpecialList(domain: String): Boolean {
        var list = PublicInfoDataService.getInstance().specialList
        if (null == list) {
            return false
        } else {
            for (json in list) {
                if (null != json && json.length() > 0) {
                    if (json.optString("host") == domain) {
                        return true
                    }
                }
            }
        }
        return false
    }


    /*
     * return baseUrl ApiService
     */
    fun <S> getBaseUrlService(serviceClass: Class<S>): S {
        return createService(NetUrl.baseUrl(), serviceClass)
    }

    /**
     *Service for speed measurement
     */
    fun <S> getspeedUrlService(url: String, serviceClass: Class<S>): S {
        return createService(url, serviceClass)
    }


    /*
     * return otcBaseUrl ApiService
     */
    fun <S> getOtcBaseUrlService(serviceClass: Class<S>): S {
        return createService(NetUrl.getotcBaseUrl(), serviceClass)
    }

    /*
     * return contractUrl ApiService
     */
    fun <S> getContractUrlService(serviceClass: Class<S>): S {
        return createService(NetUrl.getcontractUrl(), serviceClass)
    }

    /*
    * return contractUrl ApiService
    */
    fun <S> getContractNewUrlService(serviceClass: Class<S>): S {
        return createService(NetUrl.getContractNewUrl(), serviceClass)
    }

    /*
     * return redPackageUrl ApiService
     */
    fun <S> getRedPackageUrlService(serviceClass: Class<S>): S {
        return createService(NetUrl.getredPackageUrl(), serviceClass)
    }


    private fun <S> createService(url: String, serviceClass: Class<S>): S {
        if (mServiceMap.containsKey(serviceClass.name)) {
            return mServiceMap.get(serviceClass.name) as S
        } else {
            var obj = createRetrofit(url).create(serviceClass) //as S//createService(baseUrl,serviceClass);
            if (serviceClass.name != "com.yjkj.chainup.model.api.SpeedApiService") {
                mServiceMap.put(serviceClass.name, obj as Any)
            }
            return obj
        }
    }


    private fun createRetrofit(baseUrl: String?): Retrofit {
        var url = baseUrl
        if (!StringUtil.isHttpUrl(url))
            url = AppConfig.default_host //Fault tolerant processing
        if (!url!!.endsWith("/"))
            url += "/"
        return Retrofit.Builder()
                .client(mOkHttpClient)
                .baseUrl(url)
                .addCallAdapterFactory(RxJava2CallAdapterFactory.create())
                .addConverterFactory(GsonConverterFactory.create()).build()
    }

    companion object {
        private val cache = Cache(GlobalAppComponent.getContext().cacheDir, (1024 * 1024 * 10).toLong())
        private var mHttpHelper: HttpHelper? = null

        val instance: HttpHelper
            @Synchronized get() {
                if (null == mHttpHelper) {
                    mHttpHelper = HttpHelper()
                }
                return mHttpHelper!!
            }
    }


    fun getCoDomain(): String {
        val domain = NetUrl.baseUrl()
        val newUrl = domain.getCoHostByUrl()
        return newUrl
    }
}
