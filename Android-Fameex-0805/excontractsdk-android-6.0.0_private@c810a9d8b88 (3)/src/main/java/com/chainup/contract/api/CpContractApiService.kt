package com.chainup.contract.api


import com.chainup.contract.bean.CpCashFlowBean
import com.chainup.contract.bean.CpContractPublicInfoBean
import com.yjkj.chainup.new_contract.bean.CpContractPositionBean
import io.reactivex.Observable
import okhttp3.RequestBody
import okhttp3.ResponseBody
import org.json.JSONObject
import retrofit2.http.Body
import retrofit2.http.POST

/**
 * @Author: Bertking
 * @Date：2019-09-03-10:45
 * @Description: contractApi
 */
interface CpContractApiService {

    //-------------------------------------------------------------------------------------//
    //                                      Api START
    //-------------------------------------------------------------------------------------//
    /**
     *  Get front end user configuration (margin mode leverage trading preferences)
     */
    @POST("user/get_user_config")
    fun getUserConfig(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *  openContractTransaction
     */
    @POST("user/create_co_id")
    fun createContract(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *  modifyMarginMode
     */
    @POST("user/margin_model_edit")
    fun modifyMarginModel(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *  modifyTransactionPreferences
     */
    @POST("user/edit_user_page_config")
    fun modifyTransactionLike(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *  modifyLever
     */
    @POST("user/level_edit")
    fun modifyLevel(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *  getContractPublicInformation
     */
    @POST("common/public_info")
    fun getPublicInfo(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *  Get the public real-time information of the contract and return the marked price, capital rate and index price
     */
    @POST("common/public_market_info")
    fun getMarkertInfo(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *  Submit entrustment (place order)
     */
    @POST("order/order_create")
    fun createOrder(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *  Submit entrustment (stop profit and stop loss)
     */
    @POST("order/condition_create")
    fun createTpslOrder(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *  cancelTheOrder
     */
    @POST("order/order_cancel")
    fun orderCancel(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *  historicalEntrustmentOrder
     */
    @POST("order/history_order_list_V2")
    fun getHistoryOrderList(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *  historicalPlannedCommissionedOrders
     */
    @POST("order/history_trigger_order_list_V2")
    fun getHistoryPlanOrderList(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *  currentDelegatedOrder
     */
    @POST("order/current_order_list_V2")
    fun getCurrentOrderList(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *  currentPlannedOrder
     */
    @POST("order/trigger_order_list_V2")
    fun getCurrentPlanOrderList(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *  positionList
     */
    @POST("position/get_position_list")
    fun getPositionList(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *  adjustPositionMarginByPosition
     */
    @POST("position/change_position_margin")
    fun modifyPositionMargin(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *  getThePositionListAndAssetList
     */
    @POST("position/get_assets_list")
    fun getPositionAssetsList(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *  getTheBatchTagPriceAndTheLatestPrice
     */
    @POST("common/price_list")
    fun getPriceList(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *  getThePositionListAndAssetList
     */
    @POST("position/get_assets_list")
    fun getPositionAssetsListv2(@Body requestBody: RequestBody): Observable<CpHttpResult<ArrayList<CpContractPositionBean>>>


    /**
     *  getLeverLadderConfiguration
     */
    @POST("common/get_ladder_info")
    fun getLadderInfo(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *  obtainingCapitalFlow
     */
    @POST("record/get_transaction_list")
    fun getTransactionList(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *  getAssetDetails
     */
    @POST("account/account_balance")
    fun getAccountBalanceByMarginCoin(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *  Obtain the list of stop profit and stop loss orders
     */
    @POST("order/take_profit_stop_loss")
    fun getTakeProfitStopLoss(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *  Cancel order -- stop profit and stop loss
     */
    @POST("order/order_tpsl_cancel")
    fun cancelOrderTpsl(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *  Obtain the transaction record of the consignment order
     */
    @POST("order/get_trade_info")
    fun getHisTradeList(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *  contractTransferToCurrency
     */
    @POST("assets/saas_trans/co_to_ex")
    fun coTransferEx(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *  positionProfitAndLossRecord
     */
    @POST("position/history_position_list")
    fun getHistoryPositionList(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *  capitalFlow
     */
    @POST("record/get_transfer_record")
    fun getTransferRecord(@Body requestBody: RequestBody): Observable<CpHttpResult<CpCashFlowBean>>

    /**
     * getDepthMap
     */
    @POST("common/depth_map")
    fun getCoinDepth(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *  receiveSimulationContractExperienceFee
     */
    @POST("user/receive_coupon")
    fun receiveCoupon(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *  flashClosing
     */
    @POST("order/light_close")
    fun lightClose(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *  Obtain the history of contract insurance fund balance line chart
     */
    @POST("common/risk_balance_list")
    fun riskBalanceList(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *  Obtain the history of contract fund rate line chart
     */
    @POST("common/funding_rate_list")
    fun fundingRateList(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *  obtainInsuranceFundBalance
     */
    @POST("common/get_risk_account")
    fun getRiskAccount(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *  Get the bin list (this interface cannot poll)
     */
    @POST("position/close_or_open_position")
    fun getposition(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *  oneKeyFullFlat
     */
    @POST("order/close_all_position")
    fun closeAllPosition(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *  getContractOptionalList
     */
    @POST("contract_optional_list")
    fun getOptionalList(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *  saveContractSelectionList
     */
    @POST("contract_optional_set")
    fun setOptionalList(@Body requestBody: RequestBody): Observable<ResponseBody>



    /**
     *  exchangeRateListQuery
     */
    @POST("common/symbol_rate_list")
    fun getSymbolRateList(@Body requestBody: RequestBody): Observable<ResponseBody>


    @POST("common/public_futures_contract_info")
    fun getPublicContractInfo(@Body requestBody: RequestBody) : Observable<ResponseBody>

    /**
     * get announcement
     * @see <a href="https://yapi.dw2nn.com/project/514/interface/api/47413">/get_bulletin_info</a>
     * */
    @POST("get_bulletin_info")
    fun getBulletinInfo(@Body requestBody: RequestBody) : Observable<ResponseBody>
    @POST("common/get_bulletin_info")//not login in
    fun getCommonBulletinInfo(@Body requestBody: RequestBody) : Observable<ResponseBody>

    /**
     * close announcement
     * @see <a href="https://yapi.dw2nn.com/project/514/interface/api/47416">/confirm_bulletin</a>
     * */
    @POST("confirm_bulletin")
    fun doConfirmBullectin(@Body requestBody: RequestBody) : Observable<ResponseBody>

    //-------------------------------------------------------------------------------------//
    //                                      Api end
    //-------------------------------------------------------------------------------------//
}
