package com.yjkj.chainup.new_version.activity

import android.Manifest
import android.annotation.SuppressLint
import android.annotation.TargetApi
import android.app.Activity
import android.app.AlertDialog
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.net.Uri
import android.net.http.SslError
import android.os.*
import android.provider.MediaStore
import android.util.Log
import android.view.KeyEvent
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import android.webkit.*
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import com.alibaba.android.arouter.facade.annotation.Autowired
import com.alibaba.android.arouter.facade.annotation.Route
import com.chainup.contract.utils.CpShareToolUtil
import com.chainup.contract.view.dialog.CpTDialog
import com.chainup.kit.views.PublicHeaderKit
import com.google.gson.JsonObject
import com.jaeger.library.StatusBarUtil
import com.qmuiteam.qmui.util.QMUIStatusBarHelper
import com.tbruyelle.rxpermissions2.RxPermissions
import com.yjkj.chainup.BuildConfig
import com.yjkj.chainup.R
import com.yjkj.chainup.app.AppConfig
import com.yjkj.chainup.base.NBaseActivity
import com.yjkj.chainup.db.constant.HomeTabMap
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.constant.WebTypeEnum
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.dsbridge.CompletionHandler
import com.yjkj.chainup.dsbridge.DWebView
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.extra_service.eventbus.EventBusUtil
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.LoginManager
import com.yjkj.chainup.manager.RateManager
import com.yjkj.chainup.net.HttpClient
import com.yjkj.chainup.net.retrofit.NetObserver
import com.yjkj.chainup.net_new.NetUrl
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_contract.activity.CpContractAssetRecordActivity
import com.yjkj.chainup.new_version.activity.personalCenter.BindMobileOrEmailActivity
import com.yjkj.chainup.new_version.activity.personalCenter.GoogleValidationActivity
import com.yjkj.chainup.new_version.activity.personalCenter.RealNameCertificationChooseCountriesActivity
import com.yjkj.chainup.new_version.bean.ImageTokenBean
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.view.JsEchoApi
import com.yjkj.chainup.new_version.view.UploadHelper
import com.yjkj.chainup.quickBuyCoin.QuickBuyCoinIndexActivity
import com.yjkj.chainup.util.*
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.activity_item_detail.*
import org.json.JSONException
import org.json.JSONObject
import java.io.File
import java.io.FileInputStream
import java.io.IOException
import java.net.URI
import java.net.URISyntaxException
import java.net.URL
import java.text.SimpleDateFormat
import java.util.*


/**
 *Announcement&Help Center Details
 *This class does not allow the addition of parameter fields
 *  //web_url = "https://www.baidu.com/"
//web_url = "https://www.taobao.com/"
// web_url = "https://m.biki.com/noticeDetail?id=AboutUs&type=cms&isApp=1&lan=zh_CN&au=android"
 */

@Route(path = RoutePath.ItemDetailActivity)
class ItemDetailActivity : NBaseActivity() {

    override fun setContentView() = R.layout.activity_item_detail
    private val FILE_CHOOSER_RESULT_CODE = 10000
    /*
     *Content to load (link URL or HTML content)
     */
    @JvmField
    @Autowired(name = ParamConstant.web_url)
    var web_url = ""

    /**
     *Tools for taking photos
     */
    var imageTool: ImageTools? = null

    val temp = "{\"_dscbstub\":\"routerName\",\"data\":\"{\"routerName\":\"coinmap_trading\"}\"}"

    /*
     *Title displayed in the top head
     */
    @JvmField
    @Autowired(name = ParamConstant.head_title)
    var head_title = ""

    /*
     *Web page type, constant values can be found in the WebTypeEnum class
     */
    @JvmField
    @Autowired(name = ParamConstant.web_type)
    var web_type = 0


    @JvmField
    @Autowired(name = ParamConstant.DIALING_CODE)
    var dialingCode = "86"

    @JvmField
    @Autowired(name = ParamConstant.NUMBER_CODE)
    var numberCode = "156"

    @JvmField
    @Autowired(name = ParamConstant.COUNTRY_NAME)
    var countryName = "中国"

    @JvmField
    @Autowired(name = ParamConstant.SPEED_WEB_API)
    var speedWebApi = ""

    @JvmField
    @Autowired(name = ParamConstant.SPEED_WS_API)
    var speedWsApi = ""

    var loadUrl="";
    override fun onInit(savedInstanceState: Bundle?) {
        super.onInit(savedInstanceState)
        ArouterUtil.inject(this)
        changeTitleStyle()
        v_title?.setTitleContent(head_title)
//        v_title?.apply {
//            setWeb(true)
//            ibBack.setOnClickListener {
//                canFinish()
//            }
//        }
        v_title?.listener=object : PublicHeaderKit.IOnBackClickListener{
            override fun onRightBtn(view: View) {
                super.onRightBtn(view)
                finish()
            }

            override fun onBack(): Boolean {
                canFinish()
                return true
            }
        }
        v_title?.setRightIconGone(true)
        imageTool = ImageTools(this)
        initLoadWebview()
    }


    fun initLoadWebview() {

//        getPermissions(this)
        initWebView()
        when (web_type) {
            WebTypeEnum.Notice.value -> {
                getNoticeDetail(web_url)
            }
            WebTypeEnum.HELP_CENTER.value -> {
                getWK()
            }
            WebTypeEnum.ROLE_INDEX.value -> {
                v_title?.setTitleContent("")
                getRoleIndex(web_url)
            }
            WebTypeEnum.HTML_INDEX.value -> {
                v_title?.setTitleContent("")
                showNoticeDetail(web_url)
            }

            WebTypeEnum.NORMAL_INDEX.value -> {
//Web_ View. loadData (web_url, "text/html; charset=UTF-8", null)//Resolve garbled code issues
                activity_new_video_loading_image?.visibility = View.GONE
//                web_view?.loadUrl(web_url)
                showWeb(web_url)
            }

            WebTypeEnum.SING_PASS.value -> {
                v_title?.setTitleContent("")
//Web_ View. loadData (web_url, "text/html; charset=UTF-8", null)//Resolve garbled code issues
                activity_new_video_loading_image?.visibility = View.GONE
//                web_view?.loadUrl(web_url)
                if (!StringUtil.checkStr(web_url))
                    return
//                http://m.hiup.pro/zh_CN/personal/kycAuth?isApp=1&ua=ios&lan=zh_CN
                LogUtil.d(TAG, "Lan = ${LanguageUtil.getSelectLanguage()}")
                LogUtil.d(TAG, "url:${web_url + "?isApp=1&ua=android&lan=${LanguageUtil.getSelectLanguage()}&country=${numberCode}&countryKeyCode=${dialingCode}"}")
                web_url = getCookieDomain(web_url)
                if (web_url?.contains("?") == true) {
                    loadUrl=web_url + "&isApp=1" + PublicInfoDataService.getInstance().getOldContractUrl(false)
                    web_view?.loadUrl(loadUrl)
                } else {
                    loadUrl=web_url + "?isApp=1&ua=android&lan=${LanguageUtil.getSelectLanguage()}&country=${numberCode}&countryKeyCode=${dialingCode}" + PublicInfoDataService.getInstance().getOldContractUrl(true)
                    web_view?.loadUrl(loadUrl)
                }

            }
            WebTypeEnum.CONTRACT_ASSETS_PROFIT.value -> {
                loadUrl=web_url + "?isApp=1" + PublicInfoDataService.getInstance().getOldContractUrl(true) +"&lang_coin=${RateManager.getCurrencyLang()}"
                web_view?.loadUrl(loadUrl)
            }

            WebTypeEnum.AGREEMENT_USER.value ->{
                getAgreementStr()
            }

            else -> {
                showWeb(web_url)
            }
        }
    }

    /*
     *Web page redirection tags
     */
    private var mIsRedirect = false

    private fun initWebView() {
        setCookie()

        //Set WebView properties to execute Javascript scripts
        web_view.settings.javaScriptEnabled = true
        web_view.canGoBack()
        //Do not load images during webpage loading, wait until webpage loading is complete before starting
        //web_view.settings.blockNetworkImage = true
        //Do not use cache
        web_view.settings.cacheMode = WebSettings.LOAD_NO_CACHE //LOAD_NO_CACHE
        web_view.settings.domStorageEnabled = true //Enable local DOM storage to solve the problem of blank pages when loading some links
        web_view.settings.allowContentAccess = true
        //Settings can support scaling
        web_view.settings.setSupportZoom(true)
        //Set the Zoom Tool to appear
        web_view.settings.builtInZoomControls = true
        //Adapt to webview
        web_view.settings.useWideViewPort = true
        web_view.settings.loadWithOverviewMode = true
        web_view.settings.javaScriptCanOpenWindowsAutomatically = true
        //Fix in Android 5.0 and above, mixed content is disabled by default, and the security certificate is not recognized when loading some HTTPS resources
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            web_view.settings.mixedContentMode = WebSettings.MIXED_CONTENT_ALWAYS_ALLOW
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            // chromium, enable hardware acceleration
            web_view.setLayerType(View.LAYER_TYPE_HARDWARE, null);
        } else {
            // older android version, disable hardware acceleration
            web_view.setLayerType(View.LAYER_TYPE_SOFTWARE, null);
        }

        //Accelerate the completion speed of HTML webpage loading
        if (Build.VERSION.SDK_INT >= 19) {
            web_view.settings.loadsImagesAutomatically = true
        } else {
            web_view.settings.loadsImagesAutomatically = false
        }

        //Enable Application H5 Caches function
        DWebView.setWebContentsDebuggingEnabled(true)
        web_view.disableJavascriptDialogBlock(false)
        web_view.setDownloadListener { s, s2, s3, s4, l ->
            LogUtil.e(TAG, "setDownloadListener ${s}")
            if (s.isNotEmpty()) {
                loadImage(s)
            }
        }
        web_view.addJavascriptObject(JsApi(this), null)
        web_view.addJavascriptObject(JsEchoApi(), "exchange")
        //Open built-in browser
        web_view.addJavascriptInterface(jsLoginHandler(this, web_view, this), "jsLoginHandler")
        web_view.setWebViewClient(object : WebViewClient() {
            override fun onPageStarted(view: WebView?, url: String?, favicon: Bitmap?) {
                println("onPageStarted : $url" )
                if(url.equals("about:blank")){
                    v_title?.setRightIconGone(true)
                }else{
                    if(!getPathAndQuery(url.toString()).equals(getPathAndQuery(loadUrl.toString()))){
                        v_title?.setRightIconGone(false)
                    }else{
                        v_title?.setRightIconGone(true)
                    }
                }
                mIsRedirect = false
                super.onPageStarted(view, url, favicon)
                indicator?.start()
            }

            override fun onReceivedSslError(view: WebView?, handler: SslErrorHandler?, error: SslError?) {
                //Ignore certificate errors and continue loading page content without displaying a blank page
                var builder = AlertDialog.Builder(view?.getContext());
                builder.setMessage(LanguageUtil.getString(this@ItemDetailActivity, "base_error_prompt5"))
                builder.setPositiveButton(LanguageUtil.getString(this@ItemDetailActivity, "common_text_btnConfirm")) { dialog, which -> handler?.proceed(); };

                builder.setNegativeButton(LanguageUtil.getString(this@ItemDetailActivity, "common_text_btnCancel")) { dialog, which -> handler?.cancel() };

                var dialog = builder.create()
                dialog.show()
            }

            //To solve the problem of being unable to call and make phone calls, we also need to rewrite the following overloaded function
            override fun shouldOverrideUrlLoading(view: WebView?, url: String?): Boolean {
                Log.i(TAG, "shouldOverrideUrlLoading==url is $url,view is $view")
                if (null == url)
                    return true

                if (url.startsWith("mailto:")) {
                    //Handle mail Urls
                    startActivity(Intent(Intent.ACTION_SENDTO, Uri.parse(url)))
                } else if (url.startsWith("tel:")) {
                    //Handle telephony Urls
                    startActivity(Intent(Intent.ACTION_DIAL, Uri.parse(url)))
                } else {
                    if (StringUtil.isHttpUrl(url)) {
                        mIsRedirect = true
                        view?.loadUrl(url)
                        //WebView loads the Url
                        return false
                    }
                }
////WebView does not load this Url
                return true
            }

            //To solve the problem of being unable to call and make phone calls, we also need to rewrite the following overloaded function
            @TargetApi(Build.VERSION_CODES.LOLLIPOP)
            override fun shouldOverrideUrlLoading(view: WebView?, request: WebResourceRequest?): Boolean {
                var uri = request?.url
                Log.v(TAG, "shouldOverrideUrlLoading==uri is $uri,view is $view")
                if (null == uri)
                    return true
                val path = uri.toString()
                if(path.contains(AppConfig.quickTradeBanxaUrlKey)){
                    val intent = Intent()
                    intent.setClass(this@ItemDetailActivity,QuickBuyCoinIndexActivity::class.java)
                    intent.flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    startActivity(intent)
                    finish()
                    return true
                }
                if (uri.toString().startsWith("mailto:")) {
                    //Handle mail Urls
                    startActivity(Intent(Intent.ACTION_SENDTO, uri))
                } else if (uri.toString().startsWith("tel:")) {
                    //Handle telephony Urls
                    startActivity(Intent(Intent.ACTION_DIAL, uri))
                } else {
                    if (StringUtil.isHttpUrl(uri.toString())) {
                        mIsRedirect = true
                        view?.loadUrl(uri.toString())
                        //WebView loads the Url
                        return false
                    }
                }
                //WebView does not load this Url
                return true
            }


            @TargetApi(Build.VERSION_CODES.M)
            override fun onReceivedError(view: WebView?, request: WebResourceRequest?, error: WebResourceError?) {
                super.onReceivedError(view, request, error)
                LogUtil.d(TAG, "webChromeClient==onReceivedError")
                runOnUiThread {
                    activity_new_video_loading_image.visibility = View.GONE
//                    if (AppConfig.IS_DEBUG) {
//                        var msg = error?.description
//                        NToastUtil.showTopToastNet(this@ItemDetailActivity,false, msg?.toString())
//                    }
                }
            }

            override fun onPageFinished(view: WebView?, url: String?) {
                super.onPageFinished(view, url)
                LogUtil.d(TAG, "webChromeClient==onPageFinished")
                indicator?.complete()
                if (mIsRedirect) {
                    return
                }
                try {
                  //After the HTML tag is loaded, load the image content
                    web_view.settings?.blockNetworkImage = false
                    runOnUiThread {
                        activity_new_video_loading_image?.visibility = View.GONE
                    }
                }catch (e:Exception){

                }
            }

        })

        web_view.setWebChromeClient(object : WebChromeClient() {
            override fun onConsoleMessage(cm: ConsoleMessage): Boolean {
                return super.onConsoleMessage(cm)
            }

            override fun onJsAlert(view: WebView, url: String, message: String, result: JsResult): Boolean {
                return super.onJsAlert(view, url, message, result)
            }


            override fun onReceivedTitle(view: WebView?, title: String?) {
                super.onReceivedTitle(view, title)
            }

            override fun onProgressChanged(view: WebView?, newProgress: Int) {
                super.onProgressChanged(view, newProgress)
            }

            // Work on Android 4.4.2 Zenfone 5
            fun showFileChooser(filePathCallback: ValueCallback<Array<String>>,
                                acceptType: String, paramBoolean: Boolean) {


                // TODO Auto-generated method stub
            }

            //for  Android 4.0+
            fun openFileChooser(uploadMsg: ValueCallback<Uri>, acceptType: String, capture: String) {

                if (nFilePathCallback != null) {
                    nFilePathCallback?.onReceiveValue(null)
                }
                nFilePathCallback = uploadMsg
                if ("image/*" == acceptType) {
                    var takePictureIntent: Intent? = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
                    if (takePictureIntent!!.resolveActivity(packageManager) != null) {
                        var photoFile: File? = null
                        try {
                            photoFile = createImageFile()
                            takePictureIntent.putExtra("PhotoPath", mCameraPhotoPath)
                        } catch (ex: IOException) {
                            Log.e("TAG", "Unable to create Image File", ex)
                        }

                        if (photoFile != null) {
                            mCameraPhotoPath = "file:" + photoFile.absolutePath
                            takePictureIntent.putExtra(MediaStore.EXTRA_OUTPUT,
                                    Uri.fromFile(photoFile))
                        } else {
                            takePictureIntent = null
                        }
                    }
                    startActivityForResult(takePictureIntent, INPUT_FILE_REQUEST_CODE)
                } else if ("video/*" == acceptType) {
                    val takeVideoIntent = Intent(MediaStore.ACTION_VIDEO_CAPTURE)
                    if (takeVideoIntent.resolveActivity(packageManager) != null) {
                        startActivityForResult(takeVideoIntent, INPUT_VIDEO_CODE)
                    }
                }
            }

//            override fun onShowFileChooser(webView: WebView?, filePathCallback: ValueCallback<Array<Uri>>?, fileChooserParams: FileChooserParams?): Boolean {
//                val i = Intent(Intent.ACTION_GET_CONTENT)
//                i.addCategory(Intent.CATEGORY_OPENABLE)
//                i.type = "image/*"
//                startActivityForResult(Intent.createChooser(i, "Image Chooser"), INPUT_FILE_REQUEST_CODE)
//                return true
//
//            }

            @SuppressLint("CheckResult")
            override fun onShowFileChooser(webView: WebView?, filePathCallback: ValueCallback<Array<Uri>>?, fileChooserParams: FileChooserParams?): Boolean {

                if (mFilePathCallback != null) {
                    mFilePathCallback?.onReceiveValue(null)
                    return true
                }

                if(ContextCompat.checkSelfPermission(this@ItemDetailActivity,
                        Manifest.permission.READ_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED){
                    val rxPermissions = RxPermissions(this@ItemDetailActivity)
                    /**
                     *Obtain read permission
                     */
                    rxPermissions.request(Manifest.permission.READ_EXTERNAL_STORAGE)
                        .subscribe { granted ->
                            if (granted) {
                                doFileCooser(filePathCallback,fileChooserParams)
                            }
                        }

                }else{
                    doFileCooser(filePathCallback,fileChooserParams)
                }

                return true


            }



            fun doFileCooser(filePathCallback:ValueCallback<Array<Uri>>?,fileChooserParams: FileChooserParams?){
                if (mFilePathCallback != null) {
                    mFilePathCallback?.onReceiveValue(null)
                }
                mFilePathCallback = filePathCallback
                val acceptTypes = fileChooserParams!!.acceptTypes
                if (acceptTypes[0] == "image/*") {
                    var takePictureIntent: Intent? = Intent().apply {
                        action = Intent.ACTION_PICK
                        setDataAndType(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, "image/*")
                    }
                    if (takePictureIntent!!.resolveActivity(packageManager) != null) {
                        var photoFile: File? = null
                        try {
                            photoFile = createImageFile()
                            takePictureIntent!!.putExtra("PhotoPath", mCameraPhotoPath)
                        } catch (ex: IOException) {
                            Log.e("TAG", "Unable to create Image File", ex)
                        }

                        //Adaptation 7.0
                        if (Build.VERSION.SDK_INT > Build.VERSION_CODES.M) {
                            if (photoFile != null) {
                                photoURI = FileProvider.getUriForFile(this@ItemDetailActivity,
                                    BuildConfig.APPLICATION_ID + ".fileProvider", photoFile!!)
                                takePictureIntent!!.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                                takePictureIntent!!.putExtra(MediaStore.EXTRA_OUTPUT, photoURI)
                            }
                        } else {
                            if (photoFile != null) {
                                mCameraPhotoPath = "file:" + photoFile!!.absolutePath
                                takePictureIntent!!.putExtra(MediaStore.EXTRA_OUTPUT,
                                    Uri.fromFile(photoFile))
                            } else {
                                takePictureIntent = null
                            }
                        }
                    }
                    startActivityForResult(takePictureIntent, INPUT_FILE_REQUEST_CODE)
                } else if (acceptTypes[0] == "video/*") {
                    val takeVideoIntent = Intent(MediaStore.ACTION_VIDEO_CAPTURE)
                    if (takeVideoIntent.resolveActivity(packageManager) != null) {
                        startActivityForResult(takeVideoIntent, INPUT_VIDEO_CODE)
                    }
                }else{
                    val i = Intent(Intent.ACTION_GET_CONTENT)
                    i.addCategory(Intent.CATEGORY_OPENABLE)
                    i.type = "*/*"
                    startActivityForResult(i, INPUT_OTHER_CODE)
                }
            }

        })
    }


    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    private fun setCookie() {
        if (!StringUtil.checkStr(web_url)) {
            return
        }


        CookieSyncManager.createInstance(this)
        var cookie: CookieManager = CookieManager.getInstance()
        cookie.removeSessionCookie()
        cookie.setAcceptCookie(true)
        val baseApi = getDomain()
        syncCookie(baseApi, cookie)
        CookieSyncManager.getInstance().sync()

    }

    private fun syncCookie(domain: String, cookieManager: CookieManager) {
        try {
            val url = URL(domain)
            var host =  url.host
            if(!StringUtil.isDoMainIPUrl(host)){
                host = "." + host
            }
            val cookieDomain = "; Max-Age=3600; Domain=$host; Path = /"
            val cookie = "ex_token=" + UserDataService.getInstance().token + cookieDomain
            cookieManager.setCookie(domain, cookie)
            val cookieExLan = "exchange_lan=" + LanguageUtil.getSelectLanguage() + cookieDomain
            cookieManager.setCookie(domain, cookieExLan)
            val cookietoken = "exchange_token=" + UserDataService.getInstance().token + cookieDomain
            cookieManager.setCookie(domain, cookietoken)

            val cookietoken2 = "token=" + UserDataService.getInstance().token + cookieDomain
            cookieManager.setCookie(domain, cookietoken2)

            val cookieLan = "lan=" + LanguageUtil.getSelectLanguage() + cookieDomain
            cookieManager.setCookie(domain, cookieLan)

            val uuid = SystemUtils.getUUID()
            val cookie1 = "device=" + uuid + cookieDomain
            cookieManager.setCookie(domain, cookie1)

            val cookie11 = "UUID-CU=" + uuid + cookieDomain
            cookieManager.setCookie(domain, cookie11)

            val cookieModel = "Mobile-Model-CU=" + SystemUtils.getSystemModel() + cookieDomain
            cookieManager.setCookie(domain, cookieModel)

            val cookieBuild = "Build-CU=" + PackageUtil.getVersionCode() + cookieDomain
            cookieManager.setCookie(domain, cookieBuild)

            val cookieNetwork = "Network-CU=" + NetworkUtils.getNetType() + cookieDomain
            cookieManager.setCookie(domain, cookieNetwork)

            val cookieVersionCode = "haveCallback=" + PackageUtil.getVersionCode() + cookieDomain
            cookieManager.setCookie(domain, cookieVersionCode)

            if (speedWsApi.isNotEmpty()) {
                val cookieWsApi = "WsSpeed=" + speedWsApi + cookieDomain
                cookieManager.setCookie(domain, cookieWsApi)
            }
            if (speedWebApi.isNotEmpty()) {
                val cookieWebApi = "ApiSpeed=" + speedWebApi + cookieDomain
                cookieManager.setCookie(domain, cookieWebApi)
            }


        } catch (e: Exception) {
            e.printStackTrace()
        }
    }


    private fun showWeb(url: String?) {
        println("web_url = ${web_url}")
        if (!StringUtil.checkStr(url))
            return
        var tempUrl = getCookieDomain(url!!)
        tempUrl = replaceLanguagePath(tempUrl)
        if (tempUrl.contains("baidu") == true) {
            loadUrl=tempUrl
            web_view?.loadUrl(loadUrl)
            return
        } else if (tempUrl.contains("?") == true) {
            tempUrl = tempUrl + "&isApp=1&lan=" + LanguageUtil.getSelectLanguage() + PublicInfoDataService.getInstance().getOldContractUrl(true)
        } else {
            tempUrl = tempUrl + "?isApp=1&lan=" + LanguageUtil.getSelectLanguage() + PublicInfoDataService.getInstance().getOldContractUrl(true)
        }
        loadUrl=tempUrl
        web_view?.loadUrl(loadUrl)

    }


    fun replaceLanguagePath(path:String) : String{
        var newPath = path
        val supportLan = PublicInfoDataService.getInstance().getLocalesList(null)
        for(i in 0 until supportLan.length()){
            val itemObj = supportLan.optJSONObject(i)
            val itemLanKey = itemObj.optString("langKey")
            if(path.contains(itemLanKey,true)){
                newPath = path.replace(itemLanKey,LanguageUtil.getSelectLanguage())
                return newPath
            }
        }
        return newPath
    }
    /**
     *Help Center
     */
    private fun getWK() {
        var disposabl = getMainModel().getCommonKV(null, MyNDisposableObserver(common_kv_type))
        addDisposable(disposabl)
    }


    /**
     *Obtain announcement details
     */
    private fun getNoticeDetail(id: String) {
        var disposabl = getMainModel().getNoticeDetail(id, MyNDisposableObserver(notice_detail_type))
        addDisposable(disposabl)
    }

    fun getAgreementStr(){
        addDisposable(getMainModel().getAgreementStr(consumer = object :NDisposableObserver(){
            override fun onResponseSuccess(jsonObject: JSONObject) {
                val obj = jsonObject.optJSONObject("data")
                if(obj==null) return
                val agreementStr = obj.optString("content")
                val agreementTitle = obj.optString("title")
                if (StringUtil.checkStr(agreementStr)) {
                    v_title?.setTitleContent(agreementTitle)
                    loadUrl=""
                    web_view.loadDataWithBaseURL(null, agreementStr, "text/html", "utf-8", null)//Resolve garbled code issues
                }
            }

        }))

    }

    /**
     *User system homepage
     */
    private fun getRoleIndex(id: String) {
        var disposabl = getMainModel().getRoleIndex(MyNDisposableObserver(role_index_type))
        addDisposable(disposabl)
    }


    val notice_detail_type = 1
    val common_kv_type = 2
    val role_index_type = 3

    private inner class MyNDisposableObserver(type: Int) : NDisposableObserver() {

        val reqType = type
        override fun onResponseSuccess(jsonObject: JSONObject) {
            LogUtil.d(TAG, "getNoticeDetail==jsonObject is $jsonObject")

            if (notice_detail_type == reqType) {
                activity_new_video_loading_image?.visibility = View.GONE
                showNoticeDetail(jsonObject)
            } else if (role_index_type == reqType) {
                activity_new_video_loading_image?.visibility = View.GONE
                showNoticeDetail(jsonObject)
            }else if (common_kv_type == reqType) {
                showCommonKV(jsonObject)

        }
        }

        override fun onResponseFailure(code: Int, msg: String?) {
            super.onResponseFailure(code, msg)
            activity_new_video_loading_image?.visibility = View.GONE
        }
    }

    private fun showNoticeDetail(jsonObject: JSONObject) {
        var data = jsonObject.optJSONObject("data")
        if (null == data || data.length() <= 0)
            return

        var html = data.optString("html")
        if (StringUtil.checkStr(html)) {
            loadUrl=""
            web_view.loadDataWithBaseURL(null, html, "text/html", "utf-8", null)//Resolve garbled code issues
        }
    }

    private fun showNoticeDetail(htmlStr: String) {
        if (StringUtil.checkStr(htmlStr)) {
            loadUrl=""
            web_view.loadDataWithBaseURL(null, htmlStr, "text/html", "utf-8", null)//Resolve garbled code issues
        }
    }

//    private fun showCommonKV(jsonObject: JSONObject) {
//        var data = jsonObject.optJSONObject("data")
//        if (null == data || data.length() <= 0)
//            return
//
//        var h5_url = data.optString("h5_url")
//        if (StringUtil.checkStr(h5_url)) {
//            showWeb(h5_url.getHelpUrl(web_url))
//        }
//    }

    private fun showCommonKV(jsonObject: JSONObject) {
        var data = jsonObject.optJSONObject("data")
        if (null == data || data.length() <= 0)
            return

        var h5_url = data.optString("h5_url")
        if (StringUtil.checkStr(h5_url)) {
            showWeb(h5_url + "/noticeDetail?id=${web_url}" + "&type=cms&isApp=1&lan=" + LanguageUtil.getSelectLanguage() + "&au=android")
        }
    }

    override fun onDestroy() {
        clearWebview()
        super.onDestroy()

    }

    private fun clearWebview() {
        try {
            web_view?.apply {
                if (web_view != null) {
                    //If the destroy () method is called first, it will hit the if (isDestroyed()) return; This line of code requires onDetachedFromWindow() first, and then
                    // destory()
                    val parent = web_view.getParent()
                    if (parent != null) {
                        (parent as ViewGroup).removeView(web_view)
                    }
                    web_view.stopLoading()
                    //Call this method on exit to remove the bound service, otherwise certain specific systems may report errors
                    web_view.getSettings().setJavaScriptEnabled(false)
                    web_view.clearHistory()
                    web_view.clearView()
                    web_view.removeAllViews()
                    web_view.destroy()
                }
            }
        }catch (e:Exception){

        }
    }


    class JsApi(var mContext: ItemDetailActivity) {
        companion object {
            var handlers: CompletionHandler<String>? = null
            var uploadExchangeHandlers: CompletionHandler<String>? = null
        }

        @JavascriptInterface
        fun exchangeInfo(args: Any, handler: CompletionHandler<String>) {
            try {
                val jsonObject = JSONObject()
                jsonObject.put("exchange_token", UserDataService.getInstance().token)
                jsonObject.put("exchange_lan", JsonUtils.getLanguage())
                jsonObject.put("exchange_skin", PublicInfoDataService.getInstance().themeModeNew)
                handler.complete(jsonObject.toString())
            } catch (e: JSONException) {
                e.printStackTrace()
            }

        }


        @JavascriptInterface
        fun exchangeRouter(args: Any) {
            try {
                val jsonObject = JSONObject(args.toString())
                val routerName = jsonObject.optString("routerName")
                val symbol = jsonObject.optString("symbol")
                val type = jsonObject.optInt("type")
                val profitRate = jsonObject.optDouble("profit_rate")
                val winRateWeek = jsonObject.optDouble("win_rate_week")
                val winRate = jsonObject.optDouble("win_rate")
                val labe = jsonObject.optString("labe")
                val userName = jsonObject.optString("user_name")
                val instrumentId = jsonObject.optString("instrument_id")
                val side = jsonObject.optString("side")
                val kol_name = jsonObject.optString("kol_name")
                val avg_cost_px = jsonObject.optString("avg_cost_px")
                val rate = jsonObject.optString("rate")

                mContext.enter2Activity(routerName, symbol, type, profitRate, winRateWeek, winRate, labe, userName, instrumentId, side, kol_name, avg_cost_px, rate)
            } catch (e: JSONException) {
                e.printStackTrace()
            }

        }

        /**
         *Upload images
         */
        @JavascriptInterface
        fun exchangeUploadInfo(args: Any, handler: CompletionHandler<String>) {
            try {
                val jsonObject = JSONObject(args.toString())
                val routerName = jsonObject.optString("routerName")
                when (routerName) {
                    //Upload photos
                    "uploadImg" -> {
                        LogUtil.d("exchangeUploadInfo:", "======上传图片:$args===")
                        mContext.showBottomMenu(jsonObject.optString("index"))
                    }
                }

                handlers = handler
            } catch (e: JSONException) {
                e.printStackTrace()
            }
        }

        @JavascriptInterface
        fun uploadExchange(args: Any, handler: CompletionHandler<String>) {
            LogUtil.d("uploadExchange", "========")
            try {
                val jsonObject = JSONObject(args.toString())
                val routerName = jsonObject.optString("routerName")
                when (routerName) {
                    //Upload photos
                    "uploadImg" -> {
                        LogUtil.d("uploadExchange:", "======上传:$args===")
                    }
                }
                uploadExchangeHandlers = handler
            } catch (e: JSONException) {
                e.printStackTrace()
            }
        }
    }


    fun enter2Activity(routerName: String, symbol: String, type: Int, profitRate: Double = 0.0, winRateWeek: Double = 0.0, winRate: Double = 0.0,
                       labe: String = "", userName: String = "", instrumentId: String = "", side: String = "", kol_name: String = "", avg_cost_px: String = "", rate: String = "") {
        when (routerName) {
            "login" -> {
                /**
                 *Login
                 */
                UserDataService.getInstance().clearToken()
                LoginManager.checkLogin(mContext, true)
            }
            "bindGoogle" -> {
                /**
                 *Bind Google
                 */
                startActivity(Intent(mContext, GoogleValidationActivity::class.java))

            }
            "bindPhone" -> {
                /**
                 *Bind phone
                 */
                var intent = Intent()
                intent.setClass(this, BindMobileOrEmailActivity::class.java)
                intent.putExtra(BindMobileOrEmailActivity.VERIFY_TYPE, BindMobileOrEmailActivity.MOBILE_TYPE)
                intent.putExtra(BindMobileOrEmailActivity.BIND_OR_CHANGE, BindMobileOrEmailActivity.VALIDATION_BIND)
                startActivity(intent)
            }
            //Singpass not authorized
            "singpasscancel" -> {
                NToastUtil.showTopToastNet(this@ItemDetailActivity, false, LanguageUtil.getString(this, "common_text_cancelkyc"))
            }
            //KYC Complete Certification
            "kyccomplete" -> {
                ArouterUtil.greenChannel(RoutePath.RealNameCertificaionSuccessActivity, null)
            }
            //Template 1
            "choosekycfirst" -> {
                RealNameCertificationChooseCountriesActivity.enter(this, "+${dialingCode}", countryName, numberCode)
            }
            "idAuth" -> {
                /**
                 *Real name authentication
                 */
                ArouterUtil.navigation(RoutePath.KycActivity, null)
            }
            "setUp" -> {
                /**
                 *Add payment method
                 */
                var intent = Intent(this, OTCChangePaymentActivity::class.java)
                intent.putExtra(CHOOSE_PAYMENT, 3)
                intent.putExtra(SYMBOL_OPEN, 0)
                intent.putExtra(CHOOSE_PAYMENT_LIST, arrayListOf<String>())
                startActivity(intent)
            }
            "modifySettings" -> {
                /**
                 *Fund password
                 */
                ArouterUtil.forwardModifyPwdPage(ParamConstant.SET_PWD, ParamConstant.FROM_OTC)
            }
            "personal_information" -> {
                /**
                 *Personal information
                 */
                if (LoginManager.checkLogin(this, true)) {
                    ArouterUtil.greenChannel(RoutePath.PersonalInfoActivity, null)
                }
            }
            "safe_set" -> {
                /**
                 *Security Settings
                 */
                if (LoginManager.checkLogin(this, true)) {
                    ArouterUtil.navigation(RoutePath.SafetySettingActivity, null)
                }
            }
            "contract_transaction" -> {
                /**
                 *Go to the contract trading page
                 */
                forwardContractTab()
                finish()
            }
            "contract_record" -> {
                /**
                 *Contract fund records
                 */
                CpContractAssetRecordActivity.show(this, symbol, type)
                finish()
            }
            "personal" -> {
                /**
                 *Personal Center
                 */
                ArouterUtil.navigation(RoutePath.PersonalCenterActivity, null)
                finish()
            }

            "coinmap_trading" -> {
                /**
                 *Currency pair transaction page
                 */
                var tabType = HomeTabMap.maps[HomeTabMap.coinTradeTab]
                homeTabSwitch(tabType, type, symbol)
                finish()
            }
            "real_name" -> {
                /**
                 *Real name authentication
                 */
                if (LoginManager.checkLogin(this, true)) {
                    //Certification status 0. Under review, 1. Passed, 2. Not passed, 3. Not certified
                    when (UserDataService.getInstance().authLevel) {
                        0 -> {
                            ArouterUtil.navigation(RoutePath.KycActivity, null)
                        }
                        1 -> {
                            NToastUtil.showTopToastNet(this@ItemDetailActivity, true, LanguageUtil.getString(this, "personal_text_verified"))
                        }

                    }
                }
            }
            "native_close" -> {
                finish()
            }
            "market_etf" -> {
                LogUtil.e(TAG, "market_etf")
                var tabType = HomeTabMap.maps[HomeTabMap.marketTab]
                homeTabSwitch(tabType, 0, "")
                var messageEvent = MessageEvent(MessageEvent.market_switch_type)
                messageEvent.msg_content = "ETF"
                EventBusUtil.post(messageEvent)
                finish()
            }
            "personal_invitation" -> {
                LogUtil.e(TAG, "personal_invitation")
                if (!LoginManager.checkLogin(this, true)) {
                    return
                }
                ArouterUtil.navigation(RoutePath.ContractAgentActivity, null)
                finish()
            }
            "kolShare_dialog" -> {
                kolDialog = NewDialogUtils.webShare(this, object : NewDialogUtils.DialogWebViewShareListener {
                    override fun webviewSaveImage(view: View) {
                        val rxPermissions: RxPermissions = RxPermissions(this@ItemDetailActivity)
                        /**
                         *Obtain read and write permissions
                         */
                        rxPermissions.request(android.Manifest.permission.WRITE_EXTERNAL_STORAGE)
                                .subscribe { granted ->
                                    if (granted) {
                                        var bitmap = ScreenShotUtil.getScreenshotBitmap(view
                                                ?: return@subscribe)
                                        if (bitmap != null) {
                                            val saveImageToGallery = ImageTools.saveImageToGallery(this@ItemDetailActivity, bitmap)
                                            if (saveImageToGallery) {
                                                DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this@ItemDetailActivity, "common_tip_saveImgSuccess"), true)
                                            } else {
                                                DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this@ItemDetailActivity, "common_tip_saveImgFail"), false)
                                            }
                                        } else {
                                            DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this@ItemDetailActivity, "common_tip_saveImgFail"), false)
                                        }
                                    } else {
                                        DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this@ItemDetailActivity, "common_tip_saveImgFail"), false)
                                    }

                                }
                        kolDialog?.dismiss()
                    }

                    override fun confirmShare(view: View) {
                        val rxPermissions: RxPermissions = RxPermissions(this@ItemDetailActivity)
                        /**
                         *Obtain read and write permissions
                         */
                        rxPermissions.request(android.Manifest.permission.WRITE_EXTERNAL_STORAGE)
                                .subscribe { granted ->
                                    if (granted) {
                                        var bitmap = ScreenShotUtil.getScreenshotBitmap(view
                                                ?: return@subscribe)
                                        if (bitmap != null) {
                                            CpShareToolUtil.sendLocalShare(mActivity, bitmap)
                                        }
                                    }

                                }
                        kolDialog?.dismiss()
                    }

                }, profitRate, winRateWeek, winRate, labe, userName)
            }
            "share_dialog" -> {
                getPositionList(side, kol_name, avg_cost_px, rate, symbol)
            }
        }
    }

    var kolDialog:  CpTDialog? = null

    private fun getPositionList(side: String = "", kol_name: String = "", avg_cost_px: String = "", rate: String = "", symbol: String = "") {
        KolShareActivity.show(this, side, kol_name, avg_cost_px, rate, symbol)
    }


    /*
   *Handling of tab jumps at the bottom of the homepage
   */
    private fun homeTabSwitch(tabType: Int?, buyOrSell: Int = 0, symbol: String = "") {
        var msgEvent = MessageEvent(MessageEvent.hometab_switch_type)
        var bundle = Bundle()
        bundle.putInt(ParamConstant.homeTabType, tabType ?: 0)
        if (symbol.isNotEmpty()) {
            bundle.putInt(ParamConstant.transferType, buyOrSell)
            bundle.putString(ParamConstant.symbol, symbol)
        }
        msgEvent.msg_content = bundle
        EventBusUtil.post(msgEvent)
    }

    private fun forwardContractTab() {
        var messageEvent = MessageEvent(MessageEvent.contract_switch_type)
        EventBusUtil.post(messageEvent)
    }


    /**
     *Photo Location
     */
    var imageMenuDialog: CpTDialog? = null
    var indexList: ArrayList<String> = arrayListOf()

    fun showBottomMenu(index: String) {
        imageMenuDialog = NewDialogUtils.showBottomListDialog(this, arrayListOf(LanguageUtil.getString(this, "noun_camera_takeAlbum"), LanguageUtil.getString(this, "noun_camera_takephoto")), 0
                , object : NewDialogUtils.DialogOnclickListener {
            override fun clickItem(data: ArrayList<String>, item: Int) {
                indexList.add(index)
                when (item) {
                    0 -> {
                        imageTool?.openGallery(index)
                    }
                    1 -> {
                        imageTool?.openCamera(index)
                    }
                }
                imageMenuDialog?.dismiss()
            }

                override fun onDismiss() {

                }

            })
    }

    fun getFileSize(file: File): Int {
        var size = 0
        if (file.exists()) {
            var fis: FileInputStream? = null
            fis = FileInputStream(file)
            size = fis.available()
        }
        return size
    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == INPUT_OTHER_CODE){
            var results: Array<Uri>? = null
            var mUri: Uri? = null
            mUri = data?.getData()
            results = arrayOf(mUri!!)
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
                nFilePathCallback?.onReceiveValue(mUri)
                nFilePathCallback = null
                return
            } else {
                if (mFilePathCallback == null) {
                    return
                }
                mFilePathCallback?.onReceiveValue(results)
                mFilePathCallback = null
                return
            }
            return
        }
        if (requestCode != INPUT_FILE_REQUEST_CODE && requestCode != INPUT_VIDEO_CODE) {
            var index = indexList[0]
            indexList.removeAt(0)
            imageTool?.onAcitvityResult(requestCode, resultCode, data
            ) { bitmap, path ->
                val jsonObject = JSONObject()
                jsonObject.put("index", index)
                JsApi.uploadExchangeHandlers?.complete(jsonObject.toString())

                /**
                 *The default image is ARGB -8888, accounting for 4B
                 * byteCount
                 * allocationByteCount
                 *None of them are accurate
                 *Width, height, and depth of field are not good either
                 */
                LogUtil.d(TAG, "====getFileSize:${getFileSize(File(path)) / 1024f}=====")

                if (getFileSize(File(path)) / 1024f / 1024f > 8) {
                    NToastUtil.showTopToastNet(this@ItemDetailActivity, false, LanguageUtil.getString(this, "upload_image_limit"))
                    val jsonObject = JSONObject().apply {
                        put("code", "-1")
                        put("msg", "")
                        put("index", index)
                    }
                    JsApi.handlers?.complete(jsonObject.toString())
                    return@onAcitvityResult
                }

                if (PublicInfoDataService.getInstance().getUploadImgType(null) == "1") {
                    getImageToken(operate_type = "1")
                    LogUtil.d(TAG, "=====上传图片:阿里云======")
                    val uploadHelper = UploadHelper.uploadImage(path, imageTokenBean.AccessKeyId, imageTokenBean.AccessKeySecret, imageTokenBean.bucketName,
                            imageTokenBean.ossUrl, imageTokenBean.SecurityToken, imageTokenBean.catalog)
                    val substring = uploadHelper.substring(uploadHelper.indexOf(imageTokenBean.catalog))

                    val jsonObject = JSONObject().apply {
                        put("filename", substring)
                        /**
                         *Provide H5 with a complete path
                         */
                        put("filenameStr", uploadHelper.indexOf(imageTokenBean.catalog))
                        put("index", index)

                    }
                    JsApi.handlers?.complete(jsonObject.toString())
                } else {
                    LogUtil.d(TAG, "=====上传图片:服务器======")
                    val bitmap2Base64 = imageTool?.bitmap2Base64(bitmap)
                    uploadImg(bitmap2Base64 ?: return@onAcitvityResult, index)
                }
            }
            return
        } else {
            var results: Array<Uri>? = null
            var mUri: Uri? = null
            if (resultCode == Activity.RESULT_OK && requestCode == INPUT_FILE_REQUEST_CODE) {
                if (data == null) {
                    val intentData = handerOpenCamera()
                    results = intentData.first
                    mUri = intentData.second
                } else {
                    val nUri = data.data
                    if (nUri != null) {
                        mUri = nUri
                        results = arrayOf(nUri)
                    } else {
                        val intentData = handerOpenCamera()
                        results = intentData.first
                        mUri = intentData.second
                    }
                }
            } else if (resultCode == Activity.RESULT_OK && requestCode == INPUT_VIDEO_CODE) {
                mUri = data?.getData()
                results = arrayOf(mUri!!)
            }
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
                nFilePathCallback?.onReceiveValue(mUri)
                nFilePathCallback = null
                return
            } else {
                if (mFilePathCallback == null) {
                    return
                }
                mFilePathCallback?.onReceiveValue(results)
                mFilePathCallback = null
                return
            }
        }

    }


    /**
     *New interface to obtain token images
     */
    var imageTokenBean: ImageTokenBean = ImageTokenBean()

    fun getImageToken(operate_type: String = "1") {
        HttpClient.instance.getImageToken(operate_type)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<ImageTokenBean>() {
                    override fun onHandleSuccess(t: ImageTokenBean?) {
                        t ?: return
                        imageTokenBean = t

                    }

                    override fun onHandleError(code: Int, msg: String?) {
                        super.onHandleError(code, msg)
                        DisplayUtil.showSnackBar(window?.decorView, msg, isSuc = false)
                    }

                })


    }


    override fun onMessageEvent(event: MessageEvent) {
        super.onMessageEvent(event)
        if (MessageEvent.webview_refresh_type == event.msg_type) {
            initLoadWebview()
        }

    }


    /**
     *Old interface for uploading photos
     */
    fun uploadImg(imageBase: String, index: String): String {
        var jsonObject: JSONObject? = null
        HttpClient.instance.uploadImg(imgBase64 = imageBase, name = index)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<JsonObject>() {
                    override fun onHandleSuccess(t: JsonObject?) {
                        DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this@ItemDetailActivity, "toast_upload_pic_suc"), isSuc = true)
                        if (t == null) return
                        val jsonObject = JSONObject(t.toString())
                        JsApi.handlers?.complete(jsonObject.toString())
                        LogUtil.d(TAG, "===上传成功:${t}==")
                    }

                    override fun onHandleError(code: Int, msg: String?) {
                        super.onHandleError(code, msg)
                        
                        jsonObject = JSONObject()
                        jsonObject?.put("code", code.toString())
                        jsonObject?.put("msg", msg)
                        jsonObject?.put("index", index)
                        JsApi.handlers?.complete(jsonObject.toString())
                        DisplayUtil.showSnackBar(window?.decorView, msg, isSuc = false)
                    }
                })
        return jsonObject?.toString() ?: ""

    }

    private var mFilePathCallback: ValueCallback<Array<Uri>>? = null
    private var nFilePathCallback: ValueCallback<Uri>? = null
    private var mCameraPhotoPath: String? = null
    val INPUT_FILE_REQUEST_CODE = 1
    val INPUT_VIDEO_CODE = 2
    val INPUT_OTHER_CODE = 4
    val FILECHOOSER_RESULTCODE = 3
    private val REQUEST_CAMERA_CODE = 1
    private var photoURI: Uri? = null
    private fun getPermissions(activity: Activity) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (ContextCompat.checkSelfPermission(this,
                            Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
                //Make permission requests
                ActivityCompat.requestPermissions(this,
                        arrayOf(Manifest.permission.CAMERA),
                        REQUEST_CAMERA_CODE)
            }
        }
    }

    @Throws(IOException::class)
    private fun createImageFile(): File? {
        val timeStamp = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.CHINA).format(Date())
        val imageFileName = "JPEG_" + timeStamp + "_"
        val storageDir = getExternalFilesDir(Environment.DIRECTORY_PICTURES)
        val image = File.createTempFile(
                imageFileName, /*Prefix*/
                ".jpg", /*Suffix*/
                storageDir      /*Folder*/
        )
        mCameraPhotoPath = image.absolutePath
        return image
    }

    fun selected() {

        var takePictureIntent: Intent? = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
        if (takePictureIntent!!.resolveActivity(packageManager) != null) {
            // Create the File where the photo should go
            var photoFile: File? = null
            try {
                photoFile = createImageFile()
                takePictureIntent.putExtra("PhotoPath", mCameraPhotoPath)
            } catch (ex: IOException) {
                // Error occurred while creating the File
                Log.e("TAG", "Unable to create Image File", ex)
            }

            // Continue only if the File was successfully created
            if (photoFile != null) {
                mCameraPhotoPath = "file:" + photoFile.absolutePath
                takePictureIntent.putExtra(MediaStore.EXTRA_OUTPUT,
                        Uri.fromFile(photoFile))
            } else {
                takePictureIntent = null
            }
        }
    }

    fun getCookieDomain(webUrl: String): String {
        val domain = webUrl.getDoMainByUrl()
        val newDomain = PublicInfoDataService.getInstance().newWorkURL
        
        if (StringUtil.isDoMainUrl(domain)) {
            //Accelerating domain name replacement
            val newWebUrl = Utils.returnSpeedUrlV2(newDomain,webUrl)
            
            return newWebUrl
        }
        return webUrl
    }

    fun getDomain(): String {
        val domain = NetUrl.baseUrl()
        val newDomain = PublicInfoDataService.getInstance().getDomainPage(null)
        
        if (StringUtil.isDoMainUrl(web_url)) {
            //Accelerating domain name replacement
            val newUrl = PublicInfoDataService.getInstance().newWorkURL.getHostByPublicUrl()
            
            return newUrl
        } else {
            if (newDomain.isNotEmpty()) {
                val newUrl = newDomain.getHostByPublicUrl()
                return newUrl
            } else {
                val newUrl = domain.getHostByUrl()
                return newUrl
            }
        }
    }

    fun canFinish() {
        if (cmdFinish()) {
            val isKolTraderMyOrderNew = web_view.url?.contains("kolTraderMyOrderNew")?:false
            if(isKolTraderMyOrderNew){
                web_view.callHandler("kolTraderMyOrderNewBack", arrayOf<Any>())
                return
            }
            web_view.goBack()
        } else {
            finish()
        }
    }

    private fun cmdFinish(): Boolean {
        return web_view.canGoBack()
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        Log.e("jinlong", "keyCode:${keyCode}")
        if (keyCode != KeyEvent.KEYCODE_VOLUME_UP && keyCode != KeyEvent.KEYCODE_VOLUME_DOWN) {
            if (keyCode == KeyEvent.KEYCODE_BACK && cmdFinish()) {
                val isKolTraderMyOrderNew = web_view.url?.contains("kolTraderMyOrderNew")?:false
                if(isKolTraderMyOrderNew){
                    web_view.callHandler("kolTraderMyOrderNewBack", arrayOf<Any>())
                    return true
                }
                web_view.goBack()
                return true
            } else {
                finish()
            }
        }
        return super.onKeyDown(keyCode, event)
    }

    private fun loadImage(dataImage: String) {
        showLoadingDialog()
        val rxPermissions = RxPermissions(this)
        /**
         *Obtain read and write permissions
         */
        rxPermissions.request(android.Manifest.permission.WRITE_EXTERNAL_STORAGE)
                .subscribe { granted ->
                    if (granted) {
                        Thread(Runnable {
                            mHandler.obtainMessage(SAVE_BEGIN).sendToTarget()
                            val bitmap = SystemUtils.base64ToPicture(dataImage)
                            if (bitmap != null) {
                                SystemV2Utils.saveImageToPhotos(this, bitmap, mHandler)
                            }
                        }).start()
                    }
                }

    }

    private val SAVE_SUCCESS = 0//Successfully saved image
    private val SAVE_FAILURE = 1//Failed to save image
    private val SAVE_BEGIN = 2//Start saving pictures
    private val mHandler = object : Handler() {
        override fun handleMessage(msg: Message) {
            when (msg.what) {
                SAVE_BEGIN -> {

                }
                SAVE_SUCCESS -> {
                    closeLoadingDialog()
                    ToastUtils.showToast(LanguageUtil.getString(this@ItemDetailActivity, "common_tip_saveImgSuccess"))
                }
                SAVE_FAILURE -> {
                    closeLoadingDialog()
                    ToastUtils.showToast(LanguageUtil.getString(this@ItemDetailActivity, "common_tip_saveImgFail"))
                }
            }
        }
    }

    private fun handerOpenCamera(): Pair<Array<Uri>?, Uri?> {
        var results: Array<Uri>? = null
        var mUri: Uri? = null
        try {
            if (Build.VERSION.SDK_INT > Build.VERSION_CODES.M) {
                mUri = photoURI
                results = arrayOf<Uri>(mUri!!)
            } else {
                if (mCameraPhotoPath != null) {
                    mUri = Uri.parse(mCameraPhotoPath)
                    results = arrayOf(Uri.parse(mCameraPhotoPath))
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return Pair(results, mUri)
    }

    private fun showFullScreen() {
        val params = window.attributes
        params.flags = WindowManager.LayoutParams.FLAG_FULLSCREEN;
        window.attributes = params;
        window.addFlags(WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS);
    }

    private fun changeStatusBarStyle() {
        StatusBarUtil.setColorNoTranslucent(this, ColorUtil.getColor(R.color.white))
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            layoutView?.fitsSystemWindows = false
            window.decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR
        }
    }

    private fun changeTitleStyle() {
        if("".equals(web_url)) return
        val url = Uri.parse(web_url)
        val isNaStyle = url.getQueryParameter("navi_style")
        if (isNaStyle != null && isNaStyle == "transparent") {
            layout_na_back.visibility = View.VISIBLE
            v_title.visibility = View.GONE
            changeStatusBarStyle()
            QMUIStatusBarHelper.translucent(this)
            QMUIStatusBarHelper.setStatusBarDarkMode(this)
            val isTitle = url.getQueryParameter("navi_titleHide")
            if (isTitle != null && isTitle == "1") {
                na_tv_title.visibility = View.GONE
                na_tv_title?.text = ""
            } else {
                na_tv_title?.text = head_title
            }
        } else {
            layout_na_back.visibility = View.GONE
            v_title.visibility = View.VISIBLE
        }
    }

    private fun getPathAndQuery(url: String): String? {
        return try {
            val uri = URI(url)
            var path = uri.path
            if (path.endsWith("/")) {
                path = path.substring(0, path.length - 1)
            }
            path + if (uri.query != null) "?" + uri.query else ""
        } catch (e: URISyntaxException) {
            e.printStackTrace()
            url
        }
    }


}


