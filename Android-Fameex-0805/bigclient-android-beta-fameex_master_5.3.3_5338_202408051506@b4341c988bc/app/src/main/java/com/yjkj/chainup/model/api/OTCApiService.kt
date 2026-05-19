package com.yjkj.chainup.model.api

import com.google.gson.JsonObject
import com.yjkj.chainup.bean.PersonAdsBean
import com.yjkj.chainup.bean.UserInfo4OTC
import com.yjkj.chainup.net.api.HttpResult
import com.yjkj.chainup.net_new.NetUrl.biki_monitor_appUrl
import com.yjkj.chainup.new_version.bean.BlackListData
import com.yjkj.chainup.new_version.bean.OTCIMMessageBean
import com.yjkj.chainup.new_version.bean.OTCOrderDetailBean
import io.reactivex.Observable
import okhttp3.RequestBody
import okhttp3.ResponseBody
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.POST
import retrofit2.http.QueryMap

/**
 * @Author: Bertking
 * @Date 2023-09-03-11:04
 *@description: OTC Interface
 */
interface OTCApiService {
    /**
     *
     *Advertising Details
     */
    @POST("otc/v4/wanted_detail")
    fun getADDetail4OTC(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *OTC data
     */
    @POST("otc/public_info")
    fun getOTCPublicInfo(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *
     *Order Details Data
     */
    @POST("v4/otc/order_detail")
    fun getOrderDetail4OTC(@Body requestBody: RequestBody): Observable<HttpResult<OTCOrderDetailBean>>

    /**
     *Cancel appeal
     */
    @POST("otc/complain_cancel")
    fun cancelComplain4OTC(@Body requestBody: RequestBody): Observable<HttpResult<Any>>


    /**
     *Cancel Order
     */
    @POST("otc/order_cancel")
    fun cancelOrder4OTC(@Body requestBody: RequestBody): Observable<HttpResult<Any>>

    /**
     *For sellers
     *Confirm Coining
     */
    @POST("otc/confirm_order_v1")
    fun confirmOrder2Seller4OTC(@Body requestBody: RequestBody): Observable<HttpResult<Any>>


    /**
     *For buyers
     *Confirm payment
     */
    @POST("v4/otc/order_payed")
    fun confirmPay2Buyer4OTC(@Body requestBody: RequestBody): Observable<HttpResult<Any>>


    /**
     *Appeal modification order status
     */
    @POST("otc/complain_order")
    fun complain2changeOrderState4OTC(@Body requestBody: RequestBody): Observable<HttpResult<Any>>

    /**
     *Generate Purchase Order (Step 3)
     */
    @POST("v4/otc/buy_order_save")
    fun buyOrderEnd4OTC(@Body requestBody: RequestBody): Observable<HttpResult<JsonObject>>

    /**
     *Generate sales order (Step 3)
     */
    @POST("v5/otc/sell_order_save")
    fun sellOrderEnd4OTC(@Body requestBody: RequestBody): Observable<HttpResult<JsonObject>>


    /**
     *Home page advertisement
     */
    @POST("otc/search")
    fun mainSearch4OTC(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *Get Chat History
     */
    @POST("chatMsg/message")
    fun gethistoryMessage(@Body requestBody: RequestBody): Observable<HttpResult<ArrayList<OTCIMMessageBean>>>


    /**
     *Query user payment method
     */

    @POST("otc/payment/find")
    fun getUserPayment4OTC(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *New payment method
     */
    @POST("otc/payment/add")
    fun addPayment4OTC(@Body requestBody: RequestBody): Observable<HttpResult<Any>>

    /**
     *Delete payment method
     */
    @POST("otc/payment/delete")
    fun removePayment4OTC(@Body requestBody: RequestBody): Observable<HttpResult<Any>>

    /**
     *Payment Method Switch Settings
     */
    @POST("otc/payment/open")
    fun operatePayment4OTC(@Body requestBody: RequestBody): Observable<HttpResult<Any>>

    /**
     *Payment Method Switch Settings
     */
    @POST("otc/payment/update")
    fun updatePayment4OTC(@Body requestBody: RequestBody): Observable<HttpResult<Any>>

    /********OTC payment method ******* END******
     *            *
     *  *                   *
     *
     *  *         *          *
     * ********************************/


    /**
     *Obtain a list
     */
    @POST("otc/person_relationship")
    fun getRelationShip4OTC(@Body requestBody: RequestBody): Observable<HttpResult<BlackListData>>

    /**
     *Block users from joining the blacklist
     */
    @POST("otc/user_contacts")
    fun userContacts4OTC(@Body requestBody: RequestBody): Observable<HttpResult<Any>>

    /***
     *Remove blacklist
     */
    @POST("otc/user_contacts_remove")
    fun removeRelationFromBlack4OTC(@Body requestBody: RequestBody): Observable<HttpResult<Any>>


    /**
     *Withdrawal Withdrawal (4.0app)
     */
    @POST("otc/consider_price_v4")
    fun considerPrice(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Display of basic user information on personal homepage
     */
    @POST("otc/person_home_page")
    fun getPerson4otc(@Body requestBody: RequestBody): Observable<HttpResult<UserInfo4OTC>>


    /**
     *List of advertisements for offline listing and purchase below
     */
    @POST("otc/v4/person_ads")
    fun getPersonAds(@Body requestBody: RequestBody): Observable<HttpResult<PersonAdsBean>>


    /**
     *Verification before purchase and sale (app4.0)
     */
    @POST("otc/validateAdvert_v4")
    fun getValidateAdvert(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *Upload Information (Biki Specialized)
     */
    @GET(biki_monitor_appUrl)
    fun loginInformation(@QueryMap map: Map<String, String>): Observable<ResponseBody>


    /**
     *Set fund password
     */
    @POST("otc/v1/capital_password/set")
    fun capitalPassword4OTC(@Body requestBody: RequestBody): Observable<HttpResult<Any>>

    /**
     *Reset Fund pwd
     */
    @POST("otc/v5/capital_password/reset")
    fun capitalPasswordReset4OTC(@Body requestBody: RequestBody): Observable<HttpResult<Any>>

    @POST("otc/capital_password/unbinding")
    fun capitalPasswordUnbind(@Body requestBody: RequestBody): Observable<HttpResult<Any>>
    @POST("otc/capital_password/forget")
    fun capitalPasswordForget(@Body requestBody: RequestBody): Observable<HttpResult<Any>>

    /******************************OTC New Addition********************/
    @POST("otc/v4/person_ads")
    fun getNewPersonAds(@Body requestBody: RequestBody): Observable<ResponseBody>

    @POST("otc/wanted_save")
    fun setWantedSave(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *Cancel Advertising
     */
    @POST("otc/close_wanted")
    fun cancelWantend(@Body requestBody: RequestBody): Observable<ResponseBody>

    @POST("otc/v4/wanted_detail_check")
    fun getwantedDetailCheck(@Body requestBody: RequestBody): Observable<ResponseBody>


    @POST("otc/withdrawWhiteListFlag")
    fun withdrawWhiteListSwitch(@Body requestBody: RequestBody): Observable<HttpResult<Any>>
}
