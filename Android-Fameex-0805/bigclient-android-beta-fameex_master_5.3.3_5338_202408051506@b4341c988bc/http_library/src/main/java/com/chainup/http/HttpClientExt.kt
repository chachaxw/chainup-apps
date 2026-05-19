package com.chainup.http

import com.google.gson.JsonObject
import com.chainup.net.ApiExService
import com.chainup.net.DataHandler
import com.chainup.net.api.HttpResult
import com.chainup.net.retrofit.ResponseConverterFactory
import io.reactivex.Observable
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.OkHttpClient
import okhttp3.RequestBody
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import retrofit2.Retrofit
import retrofit2.adapter.rxjava2.RxJava2CallAdapterFactory
import java.util.*

class HttpClientExt private constructor() {
    val TAG = HttpClientExt::class.java.simpleName

    var mOkHttpClient: OkHttpClient? = null
    private var apiExService: ApiExService? = null

    companion object {
        private var INSTANCE: HttpClientExt? = null

        val instance: HttpClientExt
            get() {
                if (INSTANCE == null) {
                    synchronized(HttpClientExt::class.java) {
                        if (INSTANCE == null) {
                            INSTANCE = HttpClientExt()
                        }
                    }
                }
                return INSTANCE!!
            }
    }

    init {

    }

    private fun createApi(url: String): ApiExService {
        var BASE_URL = url
        val retrofit = Retrofit.Builder()
                .baseUrl(BASE_URL)  //Set Server Path
                .client(mOkHttpClient!!)  //Set network requests for OKHTTP
                .addConverterFactory(ResponseConverterFactory.create())//Add conversion library, default to Gson
                .addCallAdapterFactory(RxJava2CallAdapterFactory.create()) //Add callback library using RxJava
                .build()
        return retrofit.create(ApiExService::class.java)
    }

    fun initClient(mOkHttpClient: OkHttpClient, url: String) {
        this.mOkHttpClient = mOkHttpClient
        apiExService = createApi(url)
    }

    private fun getBaseMap(isAddToken: Boolean = false): TreeMap<String, String> {
        val map = TreeMap<String, String>()
        map["time"] = System.currentTimeMillis().toString()
        return map
    }


    fun getLiveInfo(kolID: String): Observable<HttpResult<JsonObject>>? {
        val map = getBaseMap()
        map["uid"] = kolID
        return apiExService?.getLiveInfo(toRequestBody(DataHandler.encryptParams(map)))
    }
    private fun toRequestBody(params: Map<String, String>): RequestBody {
        return JSONObject(params).toString().toRequestBody("application/json;charset=utf-8".toMediaTypeOrNull())
    }
}
