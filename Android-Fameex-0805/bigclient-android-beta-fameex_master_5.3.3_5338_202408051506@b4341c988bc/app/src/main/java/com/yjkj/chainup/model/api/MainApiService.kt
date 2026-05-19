package com.yjkj.chainup.model.api

import com.yjkj.chainup.bean.EquityBean
import com.yjkj.chainup.bean.KycAuthBean
import com.yjkj.chainup.bean.TartCaptchaV2Bean
import com.yjkj.chainup.net.api.HttpResult
import io.reactivex.Observable
import io.reactivex.Single
import okhttp3.RequestBody
import okhttp3.ResponseBody
import retrofit2.http.*

/**
 *

 * @Description:

 * @Author:         wanghao

 * @CreateDate:     2019-08-28 16:42

 * @UpdateUser:     wanghao

 * @UpdateDate 2023-08-28 16:42

 *@ UpdateRemark: Update Description

 */
interface MainApiService {

    @POST("limit_ip_login")
    fun limit_ip_login(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *Obtain information about public interfaces
     */
    @POST("common/public_info_v5")
    fun public_info_v4(@Body requestBody: RequestBody): Observable<ResponseBody>


    @POST("common/user_info")
    fun user_info(@Body requestBody: RequestBody): Observable<ResponseBody>

    @POST("common/user_info")
    fun user_info_entity(@Body requestBody: RequestBody): Observable<HttpResult<Map<String,Any>>>

    /**
     *1 Public interface for contracts
     */
    @POST("/contract_public_info_v2")
    fun contract_public_info_v2(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *13 Account balance information:
     */
    @POST("/account_balance")
    fun account_balance(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *New homepage header currency vs. 24-hour market
     */
    @GET("common/header_symbol")
    fun header_symbol(@QueryMap map: Map<String, String>): Observable<ResponseBody>

    /**
     *Trading account
     */
    @POST("finance/v5/account_balance")
    fun accountBalance(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Get popular currencies
     */
    @POST("common/hot_coin")
    fun getHotcoin(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *New homepage data
     */
    @POST("common/index")
    fun common_index(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Trading account
     */
    @POST("/finance/v4/otc_account_list")
    fun otc_account_list(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *New homepage price list and trading volume list
     */
    @POST("common/trade_list_v6")
    fun trade_list_v4(@Body requestBody: RequestBody): Observable<ResponseBody>

    /****************Spot trading related*******************/

    /**
     *Create an order (in stock)
     *Purchase and sale order
     */
    @POST("order/create")
    fun createOrder(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *Cancel order (in stock)
     */
    @POST("order/cancel")
    fun cancelOrder(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Obtain current commission (spot)
     */
    @POST("order/list/new")
    fun getNewEntrust(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Obtain historical commission (spot)
     */
    @POST("v4/order/entrust_history")
    fun getHistoryEntrust4(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *Historical commission new
     */
    @POST("order/entrust_search")
    fun getNewEntrustSearch(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *Obtain commission details
     */
    @POST("trade/list_by_order")
    fun getEntrustDetail4(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Contract History Entrustment Details
     */
    @POST("lever/trade/list_by_order")
    fun getLeverEntrustDetail4(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Obtain transaction restriction copy
     */
    @POST("order/trade_limit_info")
    fun getTradeLimitInfo(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *Login interface
     */
    @POST("v6/user/login_in")
    fun loginByMobile(@Body requestBody: RequestBody): Observable<ResponseBody>

    @POST("common/tartCaptchaV2")
    fun tartCaptchaV2(@Body requestBody: RequestBody): Observable<HttpResult<TartCaptchaV2Bean>>

    /**
     *Secondary confirmation of login
     */
    @POST("user/confirm_login")
    fun confirmLogin(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Register Step 2
     */
    @POST("user/valid_code")
    fun reg4Step2(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Retrieve Password Step 2
     * old:user/search_step_two
     * new:user/reset_password_step_two
     */
    @POST("user/reset_password_step_two")
    fun findPwdStep2(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Fingerprint or facial recognition - verify local password
     */
    @POST("common/check_native_pwd")
    fun checkLocalPwd(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *Retrieve Password Step 4
     * old:user/search_step_four
     * new:user/reset_password_step_three
     */
    @POST("user/reset_password_step_three")
    fun findPwdStep4(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Register Step 3
     */
    @POST("user/confirm_pwd")
    fun reg4Step3(@Body requestBody: RequestBody): Observable<ResponseBody>

    @POST("cms/info")
    fun getAgreementStr(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Set gesture password
     */
    @POST("auth/app/user/open_hand_two")
    fun setHandPwd(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Step 1 of Setting Gesture Password
     */
    @POST("auth/app/user/open_hand_one")
    fun setHandPwdOne(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *Fingerprint or facial recognition - verify local password
     */
    @POST("/user/open_handPwd_V2")
    fun newOpenHandPwd(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Retrieve Password Step 1
     *
     * old: user/search_step_one
     * new: user/reset_password_step_one
     */
    @POST("user/reset_password_step_one")
    fun findPwdStep1(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Get Currency Introduction
     */
    @POST("common/coinSymbol_introduce")
    fun getCoinIntro(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *Register Step 1
     */
    @POST("user/register")
    fun reg4Step1(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Gesture password login
     */
    @POST("user/login_handPwd")
    fun handPwdLogin(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Obtain user selected currency pairs on the server
     */
    @POST("optional/list_symbol")
    fun getOptionalSymbol(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Add/Remove Self Selection
     */
    @POST("optional/update_symbol")
    fun addOrDeleteSymbol(@Body requestBody: RequestBody): Observable<ResponseBody>

    /*
     *Query exchange rate
     */
    @POST("common/rate")
    fun common_rate(@Body requestBody: RequestBody): Observable<ResponseBody>


    /*******B2C*********/

    /**
     *List of Legal Currency Assets
     */
    @POST("/fiat/balance")
    fun fiatBalance(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Recharge
     */
    @POST("/fiat/deposit")
    fun fiatDeposit(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Recharge Record
     */
    @POST("/fiat/deposit/list")
    fun fiatDepositList(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Recharge cancellation
     */
    @POST("/fiat/cancel_deposit")
    fun fiatCancelDeposit(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Withdrawal
     */
    @POST("/fiat/withdraw")
    fun fiatWithdraw(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Withdrawal records
     */
    @POST("fiat/withdraw/list")
    fun fiatWithdrawList(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Withdrawal cancellation
     */
    @POST("/fiat/cancel_withdraw")
    fun fiatCancelWithdraw(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *User withdrawal bank list
     */
    @POST("/user/bank/user_bank_list")
    fun fiatBankList(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Query user withdrawal bank
     */
    @POST("/user/bank/get")
    fun fiatGetBank(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *New user withdrawal bank
     * NOTE：...
     */
    @POST("/user/bank/add")
    fun fiatAddBank(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Modify user withdrawal bank
     */
    @POST("/user/bank/edit")
    fun fiatEditBank(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Delete user withdrawal bank
     */
    @POST("/user/bank/delete")
    fun fiatDeleteBank(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Query platform recharge bank information
     */
    @POST("/company/bank/info")
    fun fiatBankInfo(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Query platform supports withdrawal bank list
     */
    @POST("/bank/all")
    fun fiatAllBank(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *OSS Upload Image
     *Image temporary token
     */
    @POST("common/get_image_token")
    fun getImageToken(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *Upload on your own server
     *Upload photos
     *Submit using a form
     */
    @POST("common/upload_img")
    fun uploadImg(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *Sell at a markup
     */
    @POST("order/create_overcharge_onekey")
    fun raisePriceSell(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *notice/detail app announcement details page
     */
    @GET("notice/detail")
    fun getNoticeDetail(@QueryMap map: Map<String, String>): Observable<ResponseBody>

    /**
     *Obtain kv configuration
     */
    @GET("common/kv")
    fun getCommonKV(@QueryMap map: Map<String, String>): Observable<ResponseBody>

    /**
     *Obtain App Version Information
     */
    @GET("common/getVersionV1")
    fun getAppVersion(@QueryMap map: Map<String, String>): Observable<ResponseBody>

    /**
     *Download App Version
     */
    @Streaming
    @GET()
    fun downloadAppFile(@Url fileUrl: String): Observable<ResponseBody>

    /**
     *Obtain historical commission (spot)
     */
    @POST("/role/index")
    fun getRoleIndex(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Determine if the user ID matches the gesture password
     */
    @POST("common/gesturePwd")
    fun getGesturePwd(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**********Lever*************/

    /**
     *Cancel Order
     */
    @POST("lever/order/cancel")
    fun cancelOrder4Lever(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Lever ordering interface
     */
    @POST("lever/order/create")
    fun createOrder4Lever(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *Historical commission (leverage)
     */
    @POST("lever/order/history")
    fun historyOrders4Lever(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Current commission (leverage)
     */
    @POST("lever/order/list/new")
    fun newOrders4Lever(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Obtain transaction records based on order number
     */
    @POST("lever/trade/list_by_order")
    fun orderRecords4Lever(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Current Application (Unreturned Records)
     */
    @POST("/lever/borrow/new")
    fun borrowNew(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *Historical application (returned records)
     */
    @POST("/lever/borrow/history")
    fun borrowHistory(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *List of leveraged accounts
     */
    @POST("lever/finance/balance")
    fun getBalanceList(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Return
     */
    @POST("lever/finance/return")
    fun setReturn(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Lending
     */
    @POST("lever/finance/borrow")
    fun setBorrow(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *Obtain account information based on currency pairs
     */
    @POST("lever/finance/symbol/balance")
    fun getBalance4Lever(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *Obtain account information based on currency pairs
     */
    @POST("lever/finance/transfer")
    fun setTransfer4Lever(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Transfer of foreign funds on site
     */
    @POST("finance/otc_transfer")
    fun transher4OTC(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Fund transfer
     */
    @POST("/capital_transfer")
    fun capitalTransfer4Contract(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Obtaining funds during transfer
     */
    @POST("finance/get_account_by_coin")
    fun accountGetCoin4OTC(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *Query Details
     */
    @POST("lever/return/info")
    fun getDetail4Lever(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Query Details
     */
    @POST("lever/finance/transfer/list")
    fun getTransferList(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *Main interface of homepage
     */
    @POST("/finance/v5/total_account_balance")
    fun getTotalAsset(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Query service fees and withdrawal addresses based on currency
     */
    @POST("/cost/Getcost")
    fun getCost(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Withdrawal operation
     */
    @POST("addr/add_withdraw_addr_validate_v4")
    fun addWithdrawAddrValidate(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *Obtain net value of currency to ETF
     */
    @POST("/etfAct/netValue")
    fun getETFValue(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *ETF disclaimer information URL and domain name
     */
    @POST("/etfAct/faqInfo")
    fun getETFInfo(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Obtain the information required for user identity authentication
     */
    @POST("security/get_identity_auth_info")
    fun getIdentityAuthInfo(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Authenticate the user's identity
     */
    @POST("security/identity_auth_info_check")
    fun submitAuthInfoCheck(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Get KOL list
     */
    @GET("out/follow/chainup/kol/list")
    fun getFollowKolList(@QueryMap map: Map<String, String>): Observable<ResponseBody>

    /**
     *Get tracking list
     */
    @GET("out/follow/chainup/follow/list")
    fun getFollowList(@QueryMap map: Map<String, String>): Observable<ResponseBody>


    /**
     *Obtain tracking configuration get
     */
    @GET("out/follow/chainup/follow/options")
    fun getFollowOptions(@QueryMap map: Map<String, String>): Observable<ResponseBody>

    /**
     *Obtain tracking revenue (tracking revenue information on the tracking list)
     */
    @GET("out/follow/chainup/follow/profit")
    fun getFollowProfit(@QueryMap map: Map<String, String>): Observable<ResponseBody>

    /**
     *Obtain tracking details
     */
    @GET("out/follow/chainup/follow/detail")
    fun getFollowDetail(@QueryMap map: Map<String, String>): Observable<ResponseBody>

    /**
     *Obtain tracking revenue trends
     */
    @GET("out/follow/chainup/follow/trend")
    fun getFollowTrend(@QueryMap map: Map<String, String>): Observable<ResponseBody>

    /**
     *Obtain tracking and sharing information
     */
    @GET("out/follow/chainup/follow/share")
    fun getFollowShare(@QueryMap map: Map<String, String>): Observable<ResponseBody>

    /**
     *Start tracking
     */
    @POST("inner/follow/set")
    fun getInnerFollowbegin(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *End tracking
     */
    @POST("inner/follow/stop")
    fun getInnerFollowEnd(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *End tracking
     */
    @POST("app-increment-api/v2/co/agent/index")
    fun getAgentIndex(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *End tracking
     */
    @POST("app-increment-api/common/public")
    fun getNoTokenPublic(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *Add interface fingerprint login
     */
    @POST("app-auth/user/quick_login")
    fun newQuickLogin(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Add interface gesture login
     */
    @POST("app-auth/user/hand_login")
    fun newHandLogin(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Guide page setting phone password
     */
    @POST("auth/app/user/open_hand")
    fun newOpenHand(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *New homepage header currency vs. 24-hour market
     */
    @POST("common/index_v6")
    fun getHome(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Spot broker
     */
    @POST("agentV2/agent_data_query")
    fun getAgentDataQuery(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *Broker display page image link interface
     */
    @POST("app-increment-api/invitation/pageConfig")
    fun getPageConfig(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *My invitation
     */
    @POST("app-increment-api/invitation/myInvitations")
    fun getMyInvitations(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *Invitation rewards
     */
    @POST("app-increment-api/invitation/myInvitationRewards")
    fun getMyInvitationRewards(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *Obtain information about public interfaces
     */
    @POST("common/public_info_market")
    fun publicInfoMarket(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Get popular currencies
     */
    @POST("common/recommend_coin")
    fun getCommonRecommendCoin(@Body map: RequestBody): Observable<ResponseBody>

    /**
     *Obtain kv configuration
     */
    @POST("optional/update_all_symbol")
    fun optionalUploadSymbol(@Body map: RequestBody): Observable<ResponseBody>

    /**
     *Obtain recharge address
     */
    @POST("finance/get_charge_address")
    fun getChargeAddress(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Transfer of spot goods to contracts
     */
//    @POST("app/futures_transfer")
    @POST("app/co_transfer")
    fun futuresTransfer(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *The new version obtains the interface between contract assets and total account assets
     */
    @POST("finance/features/total_account_balance")
    fun getContractTotalAccountBalanceV2(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Query (AI) Configuration
     */
    @POST("app-quant-api/noToken/quant/getAIStrategyInfo")
    fun getAIStrategyInfo(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Save Policy
     */
    @POST("app-quant-api/quant/saveStrategy")
    fun saveStrategy(@Body requestBody: RequestBody): Observable<ResponseBody>

     /**
     *Calculate the total assets invested using base
     */
    @POST("app-quant-api/quant/calBaseAmount")
    fun calBaseAmount(@Body requestBody: RequestBody): Observable<ResponseBody>



    /**
     *Strategic Transaction List
     */
    @POST("app-quant-api/quant/getStrategyList")
    fun getStrategyList(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Querying records of pending orders
     */
    @POST("app-quant-api/quant/getOrderingGridList")
    fun getOrderingGridList(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *The grid has completed the registration record
     */
    @POST("app-quant-api/quant/getFinishGridList")
    fun getFinishGridList(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Stop Policy
     */
    @POST("app-quant-api/quant/stopStrategy")
    fun stopStrategy(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Obtain Asset Details
     */
    @POST("finance/v5/account_balance")
    fun getAccountBalanceByMarginCoin(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *Obtain Asset Details
     */
    @POST("etfAct/checkEtfTrade")
    fun getETFCoin(@Body requestBody: RequestBody): Observable<ResponseBody>

    @POST("etfAct/readStatusEtfWarn")
    fun saveETFStatus(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *Obtain net value of currency to ETF
     */
    @POST("/etfAct/positionRecordList")
    fun getETFPositionRecordList(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *Apply for invitation quota
     */
    @POST("/user/apply_invite_quota")
    fun applyInviteQuota(@Body requestBody: RequestBody): Observable<ResponseBody>



    /**
     *Internal transfer user authentication
     */
    @POST("inner_transfer/user_auth")
    fun innerTransferUserAuth(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *Internal transfer
     */
    @POST("inner_transfer/do_withdraw_v1")
    fun innerTransferDoWithdraw(@Body requestBody: RequestBody): Observable<ResponseBody>

    @POST("common/recommend_symbol")
    fun searchRecommendSymbol(@Body requestBody: RequestBody): Observable<ResponseBody>

    @POST("common/rateV2")
    fun rateV2(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**Verify eligibility for cancellation*/
    @POST("cancellation/verification")
    fun getAccountDestroyVerification(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**Account cancellation*/
    @POST("user/deleteAccount")
    fun destroyAccount(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**Account cancellation display status*/
    @POST("getDeleteAccountStatus")
    fun getAccountDestroyVisibleStatus(@Body requestBody: RequestBody): Observable<ResponseBody>

    @POST("sumsub/getAuthRecord")
    fun getAuthRecord(@Body requestBody: RequestBody): Observable<HttpResult<List<KycAuthBean>>>

    @POST("sumsub/getAccessToken")
    fun getAccessToken(@Body requestBody: RequestBody): Single<HttpResult<String>>

    @POST("sumsub/get_max_level")
    fun getMaxLevel(@Body requestBody: RequestBody): Observable<ResponseBody>

    @POST("sumsub/get_equity")
    fun getEquity(@Body requestBody: RequestBody): Observable<HttpResult<EquityBean>>

    @POST("sumsub/call_back")
    fun doKycSubmitCallback(@Body requestBody: RequestBody): Observable<HttpResult<String?>>

    /**
     * ----------------Reward Center interface-----------------
     * */
    @POST("task_center_index")
    fun getTaskCenterIndex(@Body requestBody: RequestBody): Observable<ResponseBody>
    @POST("user_task_info_list")
    fun getTaskList(@Body requestBody: RequestBody): Observable<ResponseBody>
    @POST("receive_reward")
    fun doReceiveReward(@Body requestBody: RequestBody): Observable<ResponseBody>
    @POST("do_daily_sign_in")
    fun doSignIn(@Body requestBody: RequestBody): Observable<ResponseBody>
    @POST("task_complete_count")
    fun getTaskCompleteCount(@Body requestBody: RequestBody): Observable<ResponseBody>
    @POST("reward_center_info")
    fun getRewardCenterInfo(@Body requestBody: RequestBody): Observable<ResponseBody>
    @POST("user_reward_overall")
    fun getUserRewardOverall(@Body requestBody: RequestBody): Observable<ResponseBody>
    @POST("user_reward_records")
    fun getUserRewardRecords(@Body requestBody: RequestBody): Observable<ResponseBody>
    @POST("user_reward_un_withdraw")
    fun getUserRewardUnWithdraw(@Body requestBody: RequestBody): Observable<ResponseBody>
    @POST("user_withdraw_records")
    fun getUserWithdrawRecords(@Body requestBody: RequestBody): Observable<ResponseBody>
    @POST("do_withdraw_reward_info")
    fun getWithdrawRewardInfo(@Body requestBody: RequestBody): Observable<ResponseBody>
    @POST("do_withdraw_reward")
    fun doWithdrawReward(@Body requestBody: RequestBody): Observable<ResponseBody>
}
