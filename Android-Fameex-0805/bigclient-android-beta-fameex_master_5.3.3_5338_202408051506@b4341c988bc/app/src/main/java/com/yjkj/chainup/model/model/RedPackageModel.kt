package com.yjkj.chainup.model.model

import com.yjkj.chainup.model.api.RedPackageApiService
import com.yjkj.chainup.model.datamanager.BaseDataManager
import io.reactivex.disposables.Disposable
import io.reactivex.observers.DisposableObserver
import okhttp3.ResponseBody

/**
 * @Author: Bertking
 * @Date 2023-09-04-11:14
 *@description: Specific request for red envelope
 */
class RedPackageModel : BaseDataManager() {


    /**
     *1. Initial information on red envelopes
     */
    fun redPackageInitInfo(consumer: DisposableObserver<ResponseBody>): Disposable? {
        return changeIOToMainThread(httpHelper.getRedPackageUrlService(RedPackageApiService::class.java).redPackageInitInfo1(getBaseReqBody()), consumer)
    }


    /**
     *2. Create a red envelope
     *@param type 0. Ordinary red envelope 1. Spelling luck red envelope
     *@param coinSymbol Red envelope currency
     *@param amount Red envelope limit
     *@param count Red Packet Quantity
     *@param tip Red envelope blessings
     *@param onlyNew 1. Only for new users 0. No restrictions
     *
     */
    fun createRedPackage(type: Int = 0, coinSymbol: String, amount: String, count: String, tip: String, onlyNew: Int, consumer: DisposableObserver<ResponseBody>): Disposable? {
        var paramMaps = getBaseMaps()
        paramMaps["type"] = type.toString()
        paramMaps["coinSymbol"] = coinSymbol
        paramMaps["amount"] = amount
        paramMaps["tip"] = tip
        paramMaps["count"] = count
        paramMaps["onlyNew"] = onlyNew.toString()
        return changeIOToMainThread(httpHelper.
                getRedPackageUrlService(RedPackageApiService::class.java).
                createRedPackage1(getBaseReqBody(paramMaps)), consumer)
    }


    /**
     *3. Payment callback for red envelopes
     */
    fun payCallback4redPackage(orderNum: String, googleCode: String, smsAuthCode: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps()
        map["orderNum"] = orderNum
        map["googleCode"] = googleCode
        map["smsAuthCode"] = smsAuthCode
        return changeIOToMainThread(httpHelper.getRedPackageUrlService(RedPackageApiService::class.java).pay4redPackage1(getBaseReqBody(map)), consumer)
    }

}
