package com.yjkj.chainup.model.model

import com.yjkj.chainup.model.api.SpeedApiService
import com.yjkj.chainup.model.datamanager.BaseDataManager
import io.reactivex.disposables.Disposable
import io.reactivex.observers.DisposableObserver
import okhttp3.ResponseBody

/**
 * @Author lianshangljl
 * @Date 2023-06-18-17:57
 * @Email buptjinlong@163.com
 * @description
 */
class SpeedModel : BaseDataManager() {
    /**
     *Check if the environment is connected
     */
    fun getHealth(url: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        return changeIOToMainThread(httpHelper.getspeedUrlService(url, SpeedApiService::class.java).getHealth(getBaseMaps()), consumer)
    }
}
