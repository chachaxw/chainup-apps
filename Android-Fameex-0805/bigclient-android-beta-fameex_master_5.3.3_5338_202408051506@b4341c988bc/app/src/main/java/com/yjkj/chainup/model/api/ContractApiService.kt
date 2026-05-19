package com.yjkj.chainup.model.api

import com.yjkj.chainup.bean.fund.CashFlowBean
import com.yjkj.chainup.bean.kline.DepthItem
import com.yjkj.chainup.net.api.HttpResult
import com.yjkj.chainup.treaty.bean.*
import io.reactivex.Observable
import okhttp3.RequestBody
import okhttp3.ResponseBody
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.POST

/**
 * @Author: Bertking
 * @Date 2023-09-03-10:45
 *@description: Contract Interface
 */
interface ContractApiService {

    /**
     *1 Public interface for contracts
     */
    @POST("/contract_public_info_v2")
    fun getPublicInfo4Contract(@Body requestBody: RequestBody): Observable<HttpResult<ContractPublicInfoBean>>


    /**
     *2 Obtain order creation initialization information
     */
    @POST("/init_take_order")
    fun getInitTakeOrderInfo4Contract(@Body requestBody: RequestBody): Observable<HttpResult<InitTakeOrderBean>>


    /**
     *3 Create Order
     */
    @POST("/take_order")
    fun takeOrder4Contract(@Body requestBody: RequestBody): Observable<HttpResult<Any>>

    /**
     *4 Cancel Order
     */
    @POST("/cancel_order")
    fun cancelOrder4Contract(@Body requestBody: RequestBody): Observable<HttpResult<Any>>

    /**
     *7 Tag Price
     */
    @POST("/tag_price")
    fun getTagPrice4Contract(@Body requestBody: RequestBody): Observable<HttpResult<TagPriceBean>>

    /**
     *8 Modify leverage ratio
     */
    @POST("/change_level")
    fun changeLevel4Contract(@Body requestBody: RequestBody): Observable<HttpResult<Any>>

    /**
     *10 User position information:
     */
    @POST("/user_position")
    fun getPosition4Contract(@Body requestBody: RequestBody): Observable<HttpResult<UserPositionBean>>

    /**
     *12 Fund transfer:
     */
    @POST("/capital_transfer")
    fun capitalTransfer4Contract(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *15. Risk assessment
     */
    @POST("/get_liquidation_rate")
    fun getRiskLiquidationRate(@Body requestBody: RequestBody): Observable<HttpResult<LiquidationRateBean>>

    /**
     *17 Contract flow
     */
    @POST("/business_transaction_list_v2")
    fun getBusinessTransferList(@Body requestBody: RequestBody): Observable<HttpResult<ContractCashFlowBean>>


    /**********************************Contract Revision Interface**************************************************/

    /**
     *1 Public interface for contracts
     */
    @POST("/contract_public_info_v2")
    fun getPublicInfo4Contract1(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *2 Obtain order creation initialization information
     */
    @POST("/init_take_order")
    fun getInitTakeOrderInfo4Contract1(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *3 Create an order (any)
     */
    @POST("/take_order")
    fun takeOrder4Contract1(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *4 Cancel order (any)
     */
    @POST("/cancel_order")
    fun cancelOrder4Contract1(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *5 Order List (Current Contract Delegation)
     */
    @POST("/order_list_new")
    fun getOrderList4Contract1(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *7 Tag Price
     */
    @POST("/tag_price")
    fun getTagPrice4Contract1(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *8 Modify leverage ratio (any)
     */
    @POST("/change_level")
    fun changeLevel4Contract1(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *9 Additional margin (any)
     */
    @POST("/transfer_margin")
    fun transferMargin4Contract1(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *10 User position information (any)
     */
    @POST("/user_position")
    fun getPosition4Contract1(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *11 User Open Position Contracts:
     */
    @POST("/hold_contract_list")
    fun holdContractList4Contract1(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *12 Fund transfer (any)
     */
    @POST("/capital_transfer")
    fun capitalTransfer4Contract1(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *13 Account balance information:
     */
    @POST("/account_balance")
    fun getAccountBalance4Contract1(@Body requestBody: RequestBody):Observable<ResponseBody>


    /**
     *15. Risk assessment
     */
    @POST("/get_liquidation_rate")
    fun getRiskLiquidationRate1(@Body requestBody: RequestBody):Observable<ResponseBody>


    /**
     *16 Obtaining Historical Commissions (Contracts)
     */
    @POST("/order_list_history")
    fun getHistoryEntrust4Contract1(@Body requestBody: RequestBody): Observable<ResponseBody>



    /**
     *Fund transfer interface
     */
    @POST("app/co_transfer")
    fun doAssetExchange(@Body requestBody: RequestBody): Observable<HttpResult<Any>>

//    /**
//     *App Asset Information
//     */
//    @GET("acocunt/normal")
//    fun doAcocuntNormal(@Body requestBody: RequestBody): Observable<HttpResult<Any>>


    //-------------------------------------------------------------------------------------//
    //New version contract interface start
    //-------------------------------------------------------------------------------------//
    /**
     *Obtain front-end user configuration (margin mode/leverage/trading preferences)
     */
    @POST("user/get_user_config")
    fun getUserConfig(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Opening contract transactions
     */
    @POST("user/create_co_id")
    fun createContract(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Modify margin mode
     */
    @POST("user/margin_model_edit")
    fun modifyMarginModel(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Modify transaction preferences settings
     */
    @POST("user/edit_user_page_config")
    fun modifyTransactionLike(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Modify lever
     */
    @POST("user/level_edit")
    fun modifyLevel(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Obtain contract public information
     */
    @POST("common/public_info")
    fun getPublicInfo(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Obtain public real-time information of contracts and return marked prices, fund rates, and index prices
     */
    @POST("common/public_market_info")
    fun getMarkertInfo(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *Submit commission (place order)
     */
    @POST("order/order_create")
    fun createOrder(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *Submit commission (stop profit/stop loss)
     */
    @POST("order/order_tpsl_create")
    fun createTpslOrder(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Cancellation of orders
     */
    @POST("order/order_cancel")
    fun orderCancel(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *Historical commissioned orders
     */
    @POST("order/history_order_list")
    fun getHistoryOrderList(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Historical Planned Commissioned Orders
     */
    @POST("order/history_trigger_order_list")
    fun getHistoryPlanOrderList(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *Current entrusted order
     */
    @POST("order/current_order_list")
    fun getCurrentOrderList(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *Current Planned Order
     */
    @POST("order/trigger_order_list")
    fun getCurrentPlanOrderList(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *Position List
     */
    @POST("position/get_position_list")
    fun getPositionList(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *Adjust the margin for each warehouse position
     */
    @POST("position/change_position_margin")
    fun modifyPositionMargin(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *Obtain position list and asset list
     */
    @POST("position/get_assets_list")
    fun getPositionAssetsList(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *Obtain lever ladder configuration
     */
    @POST("common/get_ladder_info")
    fun getLadderInfo(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *Obtaining fund flow
     */
    @POST("record/get_transaction_list")
    fun getTransactionList(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Obtain Asset Details
     */
    @POST("account/account_balance")
    fun getAccountBalanceByMarginCoin(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Obtain a list of stop profit and stop loss orders
     */
    @POST("order/take_profit_stop_loss")
    fun getTakeProfitStopLoss(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *Cancel order - stop profit and stop loss
     */
    @POST("order/order_tpsl_cancel")
    fun cancelOrderTpsl(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Obtain transaction records of entrusted orders
     */
    @POST("order/get_trade_info")
    fun getHisTradeList(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Contract transfer to spot
     */
    @POST("assets/saas_trans/co_to_ex")
    fun coTransferEx(@Body requestBody: RequestBody): Observable<HttpResult<Any>>

    /**
     *Position/profit and loss records
     */
    @POST("position/history_position_list")
    fun getHistoryPositionList(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Capital flow
     */
    @POST("record/get_transfer_record")
    fun getTransferRecord(@Body requestBody: RequestBody): Observable<HttpResult<CashFlowBean>>

    /**
     *Obtain depth map
     */
    @POST("common/depth_map")
    fun getCoinDepth(@Body requestBody: RequestBody): Observable<HttpResult<DepthItem>>


    /**
     *Receive simulation contract experience fee
     */
    @POST("user/receive_coupon")
    fun receiveCoupon(@Body requestBody: RequestBody): Observable<ResponseBody>

    //-------------------------------------------------------------------------------------//
    //New version contract interface end
    //-------------------------------------------------------------------------------------//
}
