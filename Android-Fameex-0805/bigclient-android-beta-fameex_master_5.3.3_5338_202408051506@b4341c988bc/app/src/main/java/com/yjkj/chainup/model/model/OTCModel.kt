package com.yjkj.chainup.model.model

import android.provider.Settings
import android.text.TextUtils
import com.yjkj.chainup.app.ChainUpApp
import com.yjkj.chainup.model.api.OTCApiService
import com.yjkj.chainup.model.datamanager.BaseDataManager
import com.yjkj.chainup.util.StringUtil
import com.yjkj.chainup.util.SystemUtils
import com.yjkj.chainup.util.UpdateHelper
import io.reactivex.disposables.Disposable
import io.reactivex.observers.DisposableObserver
import okhttp3.ResponseBody
import org.json.JSONArray
import org.json.JSONObject
import java.util.*

/**
 * @Author lianshangljl
 * @Date 2023-09-04-12:01
 * @Email buptjinlong@163.com
 * @description
 */
class OTCModel : BaseDataManager() {


    /**
     *Obtain OTC big interface
     */
    fun getOTCPublicInfo(consumer: DisposableObserver<ResponseBody>): Disposable? {

        return changeIOToMainThread(httpHelper.getOtcBaseUrlService(OTCApiService::class.java).getOTCPublicInfo(getBaseReqBody()), consumer)
    }

    /**
     *Query user payment method
     *@param isOpen 1/0, do not fill in to query all, fill in to query according to conditions
     */
    fun getUserPayment4OTC(isOpen: String = "", consumer: DisposableObserver<ResponseBody>): Disposable? {
        val paramMaps = getBaseMaps().apply {
            this["isOpen"] = isOpen
        }
        return changeIOToMainThread(httpHelper.getOtcBaseUrlService(OTCApiService::class.java).getUserPayment4OTC(getBaseReqBody(paramMaps)), consumer)
    }

    /**
     *Home page advertisement
     *@param id Payment method id
     *Param side transaction type (sell OR purchase)
     *@param symbol transaction currency
     *@param isBlockTrade: whether it is a Block trade, 0 by default
     *@param payCoin Payment Currency
     *@param payment payment method
     *Sort by @param sort
     *Param numberCode
     *@param pageSize Page size
     *@param price page size
     *Param page number
     */
    fun getmainSearch4OTC(side: String = "", symbol: String = "", isBlockTrade: String = "", payCoin: String = "", payment: String = "",
                          sort: String = "", numberCode: String = "", pageSize: Int = 20, page: Int = 1, price: String = "", consumer: DisposableObserver<ResponseBody>): Disposable? {
        val paramMaps = getBaseMaps().apply {
            if (!TextUtils.isEmpty(side)) {
                this["side"] = side
            }
            this["symbol"] = symbol
            if (!TextUtils.isEmpty(isBlockTrade)) {
                this["isBlockTrade"] = isBlockTrade
            }
            if (!TextUtils.isEmpty(payCoin)) {
                this["payCoin"] = payCoin
            }
            if (!TextUtils.isEmpty(payment)) {
                this["payments"] = payment
            }
            if (!TextUtils.isEmpty(sort)) {
                this["sort"] = sort
            }
            if (!TextUtils.isEmpty(numberCode)) {
                this["numberCode"] = numberCode
            }
            if (pageSize != -1) {
                this["pageSize"] = pageSize.toString()
            }
            if (page != -1) {
                this["page"] = page.toString()
            }
            if (!TextUtils.isEmpty(price)) {
                this["price"] = price
            }
        }


        return changeIOToMainThread(httpHelper.getOtcBaseUrlService(OTCApiService::class.java).mainSearch4OTC(getBaseReqBody(paramMaps)), consumer)
    }

    /**
     *Obtain reference price
     */
    fun considerPrice(baseSymbol: String, coinSymbol: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val paramMaps = getBaseMaps()

        paramMaps["baseSymbol"] = baseSymbol
        paramMaps["coinSymbol"] = coinSymbol

        return changeIOToMainThread(httpHelper.getOtcBaseUrlService(OTCApiService::class.java).considerPrice(getBaseReqBody(paramMaps)), consumer)
    }

    /**
     *Verification before purchase and sale (app4.0)
     */
    fun getValidateAdvert(advertId: String?, advertType: String?, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            if(StringUtil.checkStr(advertId)){
                this["advertId"] = advertId!!
            }
            if(StringUtil.checkStr(advertType)){
                this["advertType"] = advertType!!
            }
        }

        return changeIOToMainThread(httpHelper.getOtcBaseUrlService(OTCApiService::class.java).getValidateAdvert(getBaseReqBody(map)), consumer)
    }

    private fun getMonitorMap(): TreeMap<String, String> {
        val map = TreeMap<String, String>()
        map["timestamp"] = System.currentTimeMillis().toString()
        return map

    }

    /**
     *Upload Information (Biki Specialized)
     */
    fun loginInformation(newToken: String = "", consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getMonitorMap()
        map["org"] = "4be77ac8-7f9d-4940-b438-0203cfad37ca"
        if (!TextUtils.isEmpty(newToken)) {
            map["identity"] = newToken
        }
        if (!TextUtils.isEmpty(Settings.System.getString(ChainUpApp.appContext.contentResolver, Settings.System.ANDROID_ID))) {
            map["device"] = Settings.System.getString(ChainUpApp.appContext.contentResolver, Settings.System.ANDROID_ID)
        }

        map["language"] = SystemUtils.getSystemLanguage()
        map["appVersion"] = UpdateHelper.getLocalVersion(ChainUpApp.appContext).toString()
        map["os"] = "ADNROID"
        map["osVersion"] = SystemUtils.getSystemVersion()
        map["deviceType"] = SystemUtils.getSystemModel()
        map["acceptLanguage"] = SystemUtils.getSystemLanguage()
        map["channel"] = "AppStore"
        map["network"] = SystemUtils.getAPNType(ChainUpApp.appContext)
        var tokenmap = map
        map["token"] = SystemUtils.requestSign(tokenmap, "18w7WMAPMykEx9RwvWWYtAYeuj1sKckJeH")
        return changeIOToMainThread(httpHelper.getOtcBaseUrlService(OTCApiService::class.java).loginInformation(map), consumer)
    }

    /**
     *Cancel Advertising
     */
    fun cancelWantend(advertId: String = "0", consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["advertId"] = advertId
        }
        return changeIOToMainThread(httpHelper.getOtcBaseUrlService(OTCApiService::class.java).cancelWantend(getBaseReqBody(map)), consumer)
    }

    /**
     *Advertising
     */
    fun setWantedSave(coin: String = "", side: String = "", payCoin: String = "", volume: String = "",
                      price: String = "", priceRate: String = "", priceRateType: String = "",
                      minTrade: String = "", maxTrade: String = "", limitTime: String = "", dealVolume: String = "",
                      days: String = "", payments: ArrayList<JSONObject> = arrayListOf(),
                      description: String = "", autoReply: String = "",consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["coin"] = coin
            this["side"] = side
            this["payCoin"] = payCoin
            this["volume"] = volume
            this["price"] = price
            this["priceRate"] = priceRate
            this["priceRateType"] = priceRateType
            this["minTrade"] = minTrade
            this["maxTrade"] = maxTrade
            this["limitTime"] = limitTime
            this["dealVolume"] = dealVolume
            this["days"] = days
            this["description"] = description
            this["autoReply"] = autoReply
            var jsonArray = JSONArray()
            if (payments.size > 0) {
                payments.forEach {
                    jsonArray.put(it)
                }
                this["payments"] = jsonArray.toString()
            } else {
                this["payments"] = ""
            }
        }


        return changeIOToMainThread(httpHelper.getOtcBaseUrlService(OTCApiService::class.java).setWantedSave(getBaseReqBody(map)),consumer)
    }


    /**
     *Pre release judgment
     */
    fun getwantedDetailCheck(consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps()
        return changeIOToMainThread(httpHelper.getOtcBaseUrlService(OTCApiService::class.java).getwantedDetailCheck(getBaseReqBody(map)), consumer)
    }


    /**
     *Obtain user selected currency pairs on the server
     * @param uid
     *@param adType advertising type, do not fill in default buy
     *@param closeHide displays all by default without filling in, 0 displays all, 1 hides and closes advertisements
     */
    fun getNewPersonalAds(uid: String, adType: String = "", closeHide: String = "", page: String = "1", pageSize: String = "1000", consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["uid"] = uid
            if (!TextUtils.isEmpty(adType)) {
                this["adType"] = adType
            }
            if (!TextUtils.isEmpty(closeHide)) {
                this["closeHide"] = closeHide
            }
            this["page"] = page
            this["pageSize"] = pageSize
        }

        return changeIOToMainThread(httpHelper.getOtcBaseUrlService(OTCApiService::class.java).getNewPersonAds(getBaseReqBody(map)), consumer)
    }

    /**
     *Advertising Details
     *@param advertId Advertising ID
     */
    fun getADDetail4OTC(advertId: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["advertId"] = advertId
        }

        return changeIOToMainThread(httpHelper.getOtcBaseUrlService(OTCApiService::class.java).getADDetail4OTC(getBaseReqBody(map)), consumer)
    }
}
