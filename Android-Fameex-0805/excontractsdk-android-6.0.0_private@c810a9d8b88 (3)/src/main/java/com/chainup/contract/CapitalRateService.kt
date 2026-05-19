package com.chainup.contract

import android.app.Service
import android.content.Intent
import android.os.Bundle
import android.os.IBinder
import android.util.Log
import android.widget.TextView
import com.chainup.contract.api.CpContractApiService
import com.chainup.contract.eventbus.CpMessageEvent
import com.chainup.contract.eventbus.CpNLiveDataUtil
import com.chainup.contract.model.CpNewContractModel
import com.chainup.contract.net.CpJSONUtil
import com.chainup.contract.utils.CpBigDecimalUtils
import com.chainup.contract.utils.CpClLogicContractSetting
import com.chainup.contract.utils.CpDateUtils
import io.reactivex.Observable
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import io.reactivex.schedulers.Schedulers
import okhttp3.ResponseBody
import org.json.JSONArray
import org.json.JSONObject
import java.util.concurrent.TimeUnit

class CapitalRateService : Service() {
    private val TAG:String = this::class.java.simpleName
    companion object{
        const val contractId:String = "contractId"
        const val currentTimeMillisParam:String = "currentTimeMillis"
        const val itemContractJson:String = "itemContractJson"
    }
    private var nextCapitalSettTime = 0L
    private var serviceMillTime = 0L

    private val newContractModel: CpNewContractModel by lazy { CpNewContractModel() }

    private var capitalDisposable:Disposable? = null
    private var capitalPublicInfoDisposable:Disposable? = null
    private var serviceMillTimeDisposable:Disposable? = null

    var mContractId:Int = -1
    var mContractJsonObj:JSONObject? = null

    private var nextTimeFormatStr:String = ""// 16:00
    private var diffTimeStr:String = ""// (00:00:00)

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }


    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        mContractId = intent?.getIntExtra(contractId,-1) ?: -1
        val itemContractJsonStr = intent?.getStringExtra(itemContractJson) ?: ""
        val serviceMill = intent?.getStringExtra(currentTimeMillisParam)
        if(!"".equals(itemContractJsonStr)) {
            serviceMillTime = serviceMill!!.toLong()
            mContractJsonObj = JSONObject(itemContractJsonStr)
            mContractJsonObj?.let{
                nextCapitalSettTime = it.optLong("nextCapitalSettTime")
                startServiceMillSecondTime()
                startCapitalTimer()
            }
        }else{
            if(mContractId!=-1) reReqContractPublicInfo()
        }
        return super.onStartCommand(intent, flags, startId)
    }


    fun startCapitalTimer(){
        capitalDisposable?.dispose()
        if(nextCapitalSettTime==0L) return
        val diffTime = CpBigDecimalUtils.sub(nextCapitalSettTime.toString(),serviceMillTime.toString()).toPlainString()
        // 16:00
        nextTimeFormatStr = CpDateUtils.getHourMin(nextCapitalSettTime/1000L)
        if(CpBigDecimalUtils.compareTo(diffTime,"0")<=0) {
            // reReq contract publicInfo to get new nextCapitalSettTime
            capitalPublicInfoDisposable = reReqContractPublicInfo()
        }else{
            capitalDisposable = Observable.interval(0,1000L, TimeUnit.MILLISECONDS)
                .map {
                    return@map diffTime.toLong() - (it * 1000L)
                }
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe {
                    if(it<=0){
                        capitalDisposable?.dispose()
                        capitalPublicInfoDisposable = reReqContractPublicInfo()
                    }else{
                        // (00:00:00)
                        diffTimeStr = CpDateUtils.formatLongToTimeStr(it)
                        Log.d(TAG,"capital timer diffTime=$it,format as $diffTimeStr")
                        if("".equals(diffTimeStr)||"".equals(nextTimeFormatStr)) return@subscribe
                        val messageEvent = CpMessageEvent(CpMessageEvent.sl_contract_capitalRate_event,Bundle().apply {
                            putString("nextTimeFormatStr",nextTimeFormatStr)
                            putString("diffTimeStr",diffTimeStr)
                        })
                        CpNLiveDataUtil.postValue(messageEvent)
                    }
                }



        }
    }

    fun reReqContractPublicInfo(): Disposable {
        capitalPublicInfoDisposable?.dispose()
        return getContractPublicInfoObservable()
            .subscribeOn(Schedulers.io())
            .observeOn(Schedulers.io())
            .subscribe({
                saveContractPublicInfo(it){
                    val contractJson = CpClLogicContractSetting.getContractJsonStrById(this,mContractId)
                    nextCapitalSettTime = contractJson.optLong("nextCapitalSettTime")
                    startServiceMillSecondTime()
                    startCapitalTimer()
                }
            },{
                it.printStackTrace()
            })
    }


    private inline fun saveContractPublicInfo(repBody: ResponseBody, crossinline action:((list: JSONArray) -> Unit)) {
        val jsonObj = CpJSONUtil.parse(repBody, false)
        if (null != jsonObj) {
            val code = jsonObj.optString("code")
            if ("0".equals(code, true)) {
                jsonObj.optJSONObject("data")?.run {
                    serviceMillTime = optLong("currentTimeMillis")
                    val contractList = optJSONArray("contractList")
                    if (contractList.length()==0||contractList==null){
                        return
                    }
                    val marginCoinList = optJSONArray("marginCoinList")
                    CpClLogicContractSetting.setContractInfoUrlStr(this@CapitalRateService, optString("contractProInfo"))
                    CpClLogicContractSetting.setContractJsonListStr(this@CapitalRateService, contractList.toString())
                    CpClLogicContractSetting.setContractMarginCoinListStr(this@CapitalRateService, marginCoinList.toString())
                    action.invoke(contractList)
                }
            }
        }
    }

    private fun getContractPublicInfoObservable(): Observable<ResponseBody> {
        return newContractModel.httpHelper.getContractNewUrlService(CpContractApiService::class.java)
            .getPublicInfo(newContractModel.getBaseReqBody())
    }

    private fun startServiceMillSecondTime(){
        serviceMillTimeDisposable?.dispose()
        if(serviceMillTime==0L) return
        serviceMillTimeDisposable = Observable.interval(0,1000L,TimeUnit.MILLISECONDS)
            .subscribe{
                serviceMillTime += 1000L
                nextTimeFormatStr = CpDateUtils.getHourMin(nextCapitalSettTime/1000L)
                Log.d(TAG,"service current time = $serviceMillTime,format as ${CpDateUtils.getYearMonthDayHourMinSecond(serviceMillTime)}")
            }
    }

    override fun onDestroy() {
        super.onDestroy()
        serviceMillTimeDisposable?.dispose()
        capitalDisposable?.dispose()
        capitalPublicInfoDisposable?.dispose()
    }

}