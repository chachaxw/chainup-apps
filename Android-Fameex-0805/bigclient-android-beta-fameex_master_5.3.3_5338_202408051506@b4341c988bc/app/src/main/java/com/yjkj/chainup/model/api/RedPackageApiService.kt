package com.yjkj.chainup.model.api

import com.yjkj.chainup.net.api.HttpResult
import com.yjkj.chainup.new_version.redpackage.bean.*
import io.reactivex.Observable
import okhttp3.RequestBody
import okhttp3.ResponseBody
import org.json.JSONObject
import retrofit2.http.Body
import retrofit2.http.POST

/**
 * @Author: Bertking
 * @Date 2023-09-03-10:51
 *@description: Red envelope interface
 */
interface RedPackageApiService {
    /**
     *Initial information on red envelopes
     */
    @POST("red_packet/index")
    fun redPackageInitInfo(@Body requestBody: RequestBody): Observable<HttpResult<RedPackageInitInfo>>

    /**
     *Create a red envelope
     */
    @POST("red_packet/create_new")
    fun createRedPackage(@Body requestBody: RequestBody): Observable<HttpResult<CreatePackageBean>>

    /**
     *Payment callback for red envelopes
     */
    @POST("red_packet/toPay")
    fun pay4redPackage(@Body requestBody: RequestBody): Observable<HttpResult<Any>>

    /**
     *Statistical information on red packets sent by users
     */
    @POST("red_packet/grant_record")
    fun getGrantRedPackageInfo(@Body requestBody: RequestBody): Observable<HttpResult<GrantRedPackageInfo>>

    /**
     *List of red envelopes sent by users
     */
    @POST("red_packet/grant_record_list")
    fun grantRedPackageList(@Body requestBody: RequestBody): Observable<HttpResult<GrantRedPackageListBean>>

    /**
     *Details of red envelopes sent by users
     */
    @POST("red_packet/grant_record_info")
    fun getRedPackageDetail(@Body requestBody: RequestBody): Observable<HttpResult<RedPackageDetailBean>>


    /**
     *Statistical information of users receiving red envelopes
     */
    @POST("red_packet/receive_record")
    fun getReceiveRedPackageInfo(@Body requestBody: RequestBody): Observable<HttpResult<ReceiveRedPackageInfoBean>>


    /**
     *User Received Red Packet List
     */
    @POST("red_packet/receive_record_list")
    fun receiveRedPackageList(@Body requestBody: RequestBody): Observable<HttpResult<ReceiveRedPackageListBean>>

    /***************************************/
    /**
     *1. Initial information on red envelopes
     */
    @POST("red_packet/index")
    fun redPackageInitInfo1(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *2. Create a red envelope
     */
    @POST("red_packet/create_new")
    fun createRedPackage1(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *3. Red envelope payment
     */
    @POST("red_packet/toPay")
    fun pay4redPackage1(@Body requestBody: RequestBody): Observable<ResponseBody>


}
