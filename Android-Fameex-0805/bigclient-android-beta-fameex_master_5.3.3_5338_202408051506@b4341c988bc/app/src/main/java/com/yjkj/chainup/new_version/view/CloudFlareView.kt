package com.yjkj.chainup.new_version.view

import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.AttributeSet
import android.util.Log
import android.view.MotionEvent
import android.view.View
import android.webkit.JavascriptInterface
import android.webkit.WebResourceRequest
import android.webkit.WebSettings
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.core.content.ContextCompat
import com.yjkj.chainup.BuildConfig
import com.yjkj.chainup.R
import com.yjkj.chainup.app.AppConfig
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.dsbridge.CompletionHandler
import com.yjkj.chainup.dsbridge.DWebView
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.quickBuyCoin.QuickBuyCoinIndexActivity
import com.yjkj.chainup.util.DisplayUtil
import com.yjkj.chainup.util.JsonUtils
import com.yjkj.chainup.wedegit.DisplayUtils
import org.jetbrains.anko.backgroundColor
import org.json.JSONException
import org.json.JSONObject
import java.lang.StringBuilder

private const val fileUri = "/ex/zh_CN/cloudflare"
class CloudFlareView @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null
) : DWebView(context, attrs) {
    private val TAG:String = this::class.java.simpleName
    private var sitekey = ""
    var listener:OnCloudFlareListener? = null
    private var isNoClick = false
    init {
        settings.javaScriptEnabled = true
        settings.cacheMode = WebSettings.LOAD_DEFAULT //LOAD_NO_CACHE
        settings.domStorageEnabled = true //Enable local DOM storage to solve the problem of blank pages when loading some links
        settings.allowContentAccess = true
        //Settings can support scaling
        settings.setSupportZoom(false)
        //Set the Zoom Tool to appear
        settings.builtInZoomControls = false
        //Adapt to webview
        settings.useWideViewPort = true
        settings.loadWithOverviewMode = true
        settings.javaScriptCanOpenWindowsAutomatically = true
        //Fix in Android 5.0 and above, mixed content is disabled by default, and the security certificate is not recognized when loading some HTTPS resources
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            settings.mixedContentMode = WebSettings.MIXED_CONTENT_ALWAYS_ALLOW
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            // chromium, enable hardware acceleration
            setLayerType(View.LAYER_TYPE_HARDWARE, null)
        } else {
            // older android version, disable hardware acceleration
            setLayerType(View.LAYER_TYPE_SOFTWARE, null)
        }

        //Accelerate the completion speed of HTML webpage loading
        if (Build.VERSION.SDK_INT >= 19) {
            settings.loadsImagesAutomatically = true
        } else {
            settings.loadsImagesAutomatically = false
        }
        setScrollContainer(false)
        setVerticalScrollBarEnabled(false)
        setHorizontalScrollBarEnabled(false)
        //Open built-in browser
        addJavascriptObject(JsApi(), null)

        webViewClient = object: WebViewClient(){
            override fun shouldOverrideUrlLoading(view: WebView?, url: String?): Boolean {
                url?.let{
                    view?.loadUrl(it)
                }
                return true
            }

            override fun shouldOverrideUrlLoading(
                view: WebView?,
                request: WebResourceRequest?
            ): Boolean {
                val uri = request?.url
                Log.v(TAG, "shouldOverrideUrlLoading==uri is $uri,view is $view")
                if (null == uri) return true
                val path = uri.toString()
                if(!path.contains(fileUri)){
                    return true
                }
                return super.shouldOverrideUrlLoading(view, request)
            }
        }

        this.backgroundColor = ContextCompat.getColor(context, R.color.card_bg_color_1)

    }
    private fun createUri(domain:String?) :String {
        val urlSb = StringBuilder()
        if(BuildConfig.DEBUG){
            //WORK_TODO 调试代码
            urlSb.append("http://192.168.111.164:8081$fileUri")
        }else{
            //WORK_TODO 调试代码
            urlSb.append(if(domain?.contains("wuyj") == true) "http://" else "https://")
            urlSb.append(domain?.let { domain+fileUri }?:fileUri)
        }
        urlSb.append("?isapp=1&")
        val isNight = PublicInfoDataService.getInstance().themeMode == PublicInfoDataService.THEME_MODE_NIGHT
        val map = hashMapOf<String,Any>(
            "key" to sitekey,
            "isDark" to isNight,
            "lan" to LanguageUtil.getSelectLanguage(),
            "width" to DisplayUtils.px2dip(context,((DisplayUtil.getScreenWidth(context)*0.8) - DisplayUtil.dip2px(15)*2).toFloat()),
            "height" to "65",
        )
        for(item in map){
            urlSb.append(item.key)
            urlSb.append("=")
            urlSb.append(item.value)
            urlSb.append("&")
        }

        return urlSb.toString().dropLast(1)
    }

    fun initCloudFlare(sitekey:String,domain:String?){
        if("".equals(sitekey)) return
        this.sitekey = sitekey
        loadUrl(createUri(domain))
    }


    private inner class JsApi {
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
                val code = jsonObject.optString("code","-1")
                val result = jsonObject.optString("result","")
                if("0".equals(code) && !"".equals(result)){
                    listener?.onComplete(result)
                }else{
                    isNoClick = true
                    listener?.onError(result)
                }
            } catch (e: JSONException) {
                e.printStackTrace()
            }

        }
    }

    interface OnCloudFlareListener{
        fun onComplete(token:String)
        fun onError(message:String)
    }

    override fun dispatchTouchEvent(ev: MotionEvent?): Boolean {
        if(isNoClick) return true
        return super.dispatchTouchEvent(ev)
    }
}