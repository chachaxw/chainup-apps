package com.yjkj.chainup.model.model

import com.yjkj.chainup.model.api.AssetApiService
import com.yjkj.chainup.model.datamanager.BaseDataManager
import io.reactivex.disposables.Disposable
import io.reactivex.observers.DisposableObserver
import okhttp3.ResponseBody

/**
 * @Author lianshangljl
 * @Date 2023-09-12-14:09
 * @Email buptjinlong@163.com
 * @description
 */
class AssetModel : BaseDataManager() {

    /**
     *Trading account
     */
    fun accountBalance(consumer: DisposableObserver<ResponseBody>): Disposable? {
        return changeIOToMainThread(httpHelper.getBaseUrlService(AssetApiService::class.java).accountBalance(getBaseReqBody()), consumer)
    }






}



