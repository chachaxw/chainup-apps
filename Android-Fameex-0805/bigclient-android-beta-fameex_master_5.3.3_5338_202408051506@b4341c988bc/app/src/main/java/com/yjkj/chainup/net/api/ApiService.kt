package com.yjkj.chainup.net.api

import com.google.gson.JsonObject
import com.yjkj.chainup.bean.*
import com.yjkj.chainup.bean.address.AddressBean
import com.yjkj.chainup.bean.coin.InitInfo
import com.yjkj.chainup.bean.coin.RateBean
import com.yjkj.chainup.bean.dev.MessageBean
import com.yjkj.chainup.bean.dev.NoticeBean
import com.yjkj.chainup.bean.fund.CashFlowBean
import com.yjkj.chainup.bean.kline.DepthItem
import com.yjkj.chainup.freestaking.bean.CurrencyBean
import com.yjkj.chainup.freestaking.bean.FreeStakingBean
import com.yjkj.chainup.freestaking.bean.FreeStakingDetailBean
import com.yjkj.chainup.freestaking.bean.MyPosRecordBean
import com.yjkj.chainup.new_version.bean.*
import com.yjkj.chainup.new_version.home.AdvertModel
import io.reactivex.Observable
import okhttp3.MultipartBody
import okhttp3.RequestBody
import okhttp3.ResponseBody
import org.json.JSONObject
import retrofit2.http.*

/**
 * @author Bertking
 * @2018-6-11
 * TODO :
 *1 The login interface is currently indistinguishable on the backend (email, mobile)
 */
interface ApiService {

    /**
     *Mobile registration
     */
    @POST("user/reg_mobile")
    fun regMobile(@Body requestBody: RequestBody): Observable<HttpResult<Any>>


    /**
     *Email registration
     */
    @POST("user/reg_email")
    fun regEmail(@Body requestBody: RequestBody): Observable<HttpResult<Any>>

    /**
     *Mobile SMS verification code
     */
    @POST("v4/common/smsValidCode")
    fun sendMobileVerifyCode(@Body requestBody: RequestBody): Observable<HttpResult<String>>


    /**
     *Email verification code
     */
    @POST("v4/common/emailValidCode")
    fun sendEmailVerifyCode(@Body requestBody: RequestBody): Observable<HttpResult<String>>

    /**
     *Email login
     */
    @POST("user/login_in")
    fun loginByEmail(@Body requestBody: RequestBody): Observable<HttpResult<JsonObject>>

    /**
     *Obtain Public Agreement
     */
    @GET("common/terms")
    fun getCommonTerms(@QueryMap map: Map<String, String>): Observable<HttpResult<List<TermsBean>>>


    /**
     *Forgot password step 2
     */
    @POST("user/reset_password_step_two")
    fun resetPwdStep2(@Body requestBody: RequestBody): Observable<HttpResult<Any>>


    /**
     *Forgot password step 3
     */
    @POST("user/reset_password_step_three")
    fun resetPwdStep3(@Body requestBody: RequestBody): Observable<HttpResult<Any>>


    /**
     *Change login password
     */
    @POST("user/password_update")
    fun changeLoginPwd(@Body requestBody: RequestBody): Observable<HttpResult<Any>>


    /**
     *Obtain initial information
     */
    @POST("common/public_info")
    fun getInitInfo(@Body requestBody: RequestBody): Observable<HttpResult<InitInfo>>


    /**
     *Query exchange rate
     */
    @POST("common/rate")
    fun getRate(@Body requestBody: RequestBody): Observable<HttpResult<RateBean>>


    /**
     *Modify nickname
     */
    @POST("user/nickname_update")
    fun editNickname(@Body requestBody: RequestBody): Observable<HttpResult<Any>>


    /**
     *Log out of login
     */
    @POST("user/login_out")
    fun logout(@Body requestBody: RequestBody): Observable<HttpResult<Any>>

    /**
     *Verification before Google verification: Obtain Google's key
     */
    @POST("user/toopen_google_authenticator")
    fun getGoogleKey(@Body requestBody: RequestBody): Observable<HttpResult<JsonObject>>


    /**
     *Bind Google authentication
     */
    @POST("user/google_verify")
    fun bindGoogleVerify(@Body requestBody: RequestBody): Observable<HttpResult<Any>>

    /**
     *Turn off Google authentication
     */
    @POST("user/close_google_verify")
    fun unbindGoogleVerify(@Body requestBody: RequestBody): Observable<HttpResult<Any>>


    /**
     *Turn off mobile authentication
     */
    @POST("user/close_mobile_verify")
    fun unbindMobileVerify(@Body requestBody: RequestBody): Observable<HttpResult<Any>>


    /**
     *Turn off mobile authentication
     */
    @POST("user/open_mobile_verify")
    fun openMobileVerify(@Body requestBody: RequestBody): Observable<HttpResult<Any>>

    /************Certification related ****** END*********/


    /**
     *Modify phone number
     */
    @POST("user/mobile_update")
    fun changeMobile(@Body requestBody: RequestBody): Observable<HttpResult<Any>>

    //Determining whether the email or phone number is the same as the old one is not allowed to be modified for modifying phone numbers and email addresses
    @POST("user/verify_keyWord")
    fun checkOldMobileOrMail(@Body requestBody: RequestBody):Observable<HttpResult<Any>>


    /**
     *Modify email
     */
    @POST("user/v6/email_update")
    fun changeEmail(@Body requestBody: RequestBody): Observable<HttpResult<EditEmailBean?>>


    /**
     *Bind email
     */
    @POST("user/email_bind_save")
    fun bindEmail(@Body requestBody: RequestBody): Observable<HttpResult<Any>>


    /**
     *Bind phone
     */
    @POST("user/mobile_bind_save")
    fun bindMobile(@Body requestBody: RequestBody): Observable<HttpResult<Any>>


    /**
     *Obtain recharge address
     */
    @POST("finance/get_charge_address")
    fun getChargeAddress(@Body requestBody: RequestBody): Observable<HttpResult<JsonObject>>


    /**
     *Withdrawal operation
     */
    @POST("finance/do_withdraw_v5")
    fun doWithdraw(@Body requestBody: RequestBody): Observable<HttpResult<AuthBean>>


    /**
     *Wallet address list addr/address_ List
     */
    @POST("addr/address_list")
    fun getAddressList(@Body requestBody: RequestBody): Observable<HttpResult<AddressBean>>

    /**
     *Add address addr/add_ With draw_ Addr
     */
    @POST("addr/add_withdraw_addr_v5")
    fun addWithdrawAddress(@Body requestBody: RequestBody): Observable<HttpResult<Any>>

    /**
     *Delete wallet address addr/delete_ With draw_ Addr
     */
    @POST("addr/delete_withdraw_addr_v1")
    fun delWithdrawAddress(@Body requestBody: RequestBody): Observable<HttpResult<Any>>

    /**
     *Get Message (Message Center)
     */
    @POST("message/user_message")
    fun getMessages(@Body requestBody: RequestBody): Observable<HttpResult<MessageBean>>

    /**
     *Obtain Announcement
     */
    @POST("notice/notice_info_list")
    fun getNotices(@Body requestBody: RequestBody): Observable<HttpResult<NoticeBean>>

    /**
     *Upload photos
     *Submit using a form
     */
    @POST("common/upload_img")
    fun uploadImg(@Body requestBody: RequestBody): Observable<HttpResult<JsonObject>>

    /**
     *Real name authentication
     */
    @POST("user/v4/auth_realname")
    fun authVerify(@Body requestBody: RequestBody): Observable<HttpResult<Any>>

    /**
     *Enable gesture password: Step 1
     */
    @POST("auth/app/user/open_hand_one")
    fun openHandPwd(@Body requestBody: RequestBody): Observable<HttpResult<JsonObject>>


    /**
     *Turn off gesture password
     */
    @POST("auth/app/user/close_hand")
    fun closeHandPwd(@Body requestBody: RequestBody): Observable<HttpResult<Any>>

    /**
     *Obtain user information
     */
    @POST("common/user_info")
    fun getUserInfo(@Body requestBody: RequestBody): Observable<HttpResult<UserInfoData>>


    /**
     *Help Center
     */
    @POST("cms/list")
    fun getHelpCenterList(@Body requestBody: RequestBody): Observable<HttpResult<ArrayList<HelpCenterBean>>>

    /**
     *Obtain kv configuration
     */
    @GET("common/kv")
    fun getCommonKV(@QueryMap map: Map<String, String>): Observable<HttpResult<JsonObject>>

    /**
     *Clear user gesture password
     */
    @POST("user/clean_handPwd")
    fun cleanGesturePwd(@Body requestBody: RequestBody): Observable<HttpResult<Any>>

    /**
     *About us
     */
    @GET("common/aboutUS")
    fun getAboutUs(@QueryMap map: Map<String, String>): Observable<HttpResult<ArrayList<AboutUSBean>>>


    @GET("api/getVersion")
    fun checkVersion(@Query("time") time: String): Observable<HttpResult<VersionData>>

    @FormUrlEncoded
    @POST("api/rq_info_add_submit")
    fun feedback(@FieldMap map: Map<String, String>): Observable<HttpResult<String>>

    /**
     *Upload QR code
     */
    @POST("common/upload_img_base64")
    fun uploadImg4OTC(@Body requestBody: RequestBody): Observable<HttpResult<JsonObject>>


    /**
     *Transfer of foreign funds on site
     */
    @POST("finance/otc_transfer")
    fun transher4OTC(@Body requestBody: RequestBody): Observable<HttpResult<Any>>

    /**
     *Obtaining funds during transfer
     */
    @POST("finance/get_account_by_coin")
    fun accountGetCoin4OTC(@Body requestBody: RequestBody): Observable<HttpResult<OTCGetCoinBean>>

    /**
     *Initiate off-site appeals for questioning
     */
    @POST("/question/create_problem")
    fun createProblem4OTC(@Body requestBody: RequestBody): Observable<HttpResult<JsonObject>>

    /**
     *Query off site orders based on order status
     */
    @POST("order/otc/bystatus_v4")
    fun byStatus4OTC(@Body requestBody: RequestBody): Observable<HttpResult<OTCOrderBean>>

    /**
     *Credit card deposit and withdrawal
     */
    @POST("order/otc/credit_card")
    fun creditCard(@Body requestBody: RequestBody): Observable<HttpResult<OTCOrderBean>>


    /**
     *Question Details Page
     */
    @POST("question/details_problem")
    fun getDetailsProblem(@Body requestBody: RequestBody): Observable<HttpResult<OTCIMDetailsProblemBean>>


    /**
     *Additional questions and human service chat
     */
    @POST("question/reply_create")
    fun getReplyCreate(@Body requestBody: RequestBody): Observable<HttpResult<Any>>

    /**
     *New capital flow and other transactions
     */
    @POST("record/ex_transfer_list_v4")
    fun otherTransList4V2(@Body requestBody: RequestBody): Observable<HttpResult<CashFlowBean>>

    /**
     *Retrieve Password Step 3
     */
    @POST("user/search_step_three")
    fun findPwdStep3(@Body requestBody: RequestBody): Observable<HttpResult<Any>>

    /**
     *Fingerprint or facial recognition - login
     */
    @POST("user/login_AI")
    fun quickLogin(@Body requestBody: RequestBody): Observable<HttpResult<JsonObject>>


    /**
     *Add facial fingerprint
     */
    @POST("app-auth/user/quick_login")
    fun newQuickLogin(@Body requestBody: RequestBody): Observable<HttpResult<JsonObject>>

    /**
     *Obtaining Extreme Verification
     */
    @POST("common/tartCaptcha")
    fun getTartCaptcha(@Body requestBody: RequestBody): Observable<HttpResult<String>>

    /**
     *Image temporary token
     */
    @POST("common/get_image_token")
    fun getImageToken(@Body requestBody: RequestBody): Observable<HttpResult<ImageTokenBean>>

    /**
     *On site fund flow - scenario list
     */
    @POST("record/ex_transfer_scene_v4")
    fun getCashFlowScene(@Body requestBody: RequestBody): Observable<HttpResult<CashFlowSceneBean>>


    /**
     *List of Funds Flow on the Market
     */
    @POST("record/ex_transfer_list_v4")
    fun getCashFlowList(@Body requestBody: RequestBody): Observable<HttpResult<CashFlowBean>>


    /**
     *Withdrawal Withdrawal (4.0app)
     */
    @POST("finance/cancel_withdraw")
    fun cancelWithdraw(@Body requestBody: RequestBody): Observable<HttpResult<Any>>


    /**
     *Interface for unread messages within the station
     */
    @POST("message/get_no_read_message_count")
    fun getReadMessageCount(@Body requestBody: RequestBody): Observable<HttpResult<ReadMessageCountBean>>

    /**
     *Obtain personal center banner
     */
    @POST("user/pc_banner")
    fun getPcBanner(@Body requestBody: RequestBody): Observable<HttpResult<PcBannerBean>>

    /**
     *Rate discount switch status
     */
    @POST("/user/updatePcTradeFeeStatus")
    fun updatePcTradeFeeStatus(@Body requestBody: RequestBody): Observable<HttpResult<Any>>

    /**
     *Confirm Read
     */
    @POST("message/message_update_status")
    fun updateMessageStatus(@Body requestBody: RequestBody): Observable<HttpResult<Any>>


    /**
     *Real name authentication interface
     */
    @POST("kyc/Api/getToken")
    fun AccountCertification(@Body requestBody: RequestBody): Observable<HttpResult<AccountCertificationBean>>


    /**
     *Obtain KYC configuration
     */
    @POST("kyc/config")
    fun getKYCConfig(@Body requestBody: RequestBody): Observable<HttpResult<KYCBean>>

    /**
     *The fourth copy of real name authentication
     */
    @POST("kyc/Api/getUploadImgCopywriting")
    fun AccountCertificationLanguage(@Body requestBody: RequestBody): Observable<HttpResult<AccountCertificationLanguageBean>>

    /**
     *Get sharing friends page
     */
    @POST("common/getInvitationImgs")
    fun getInvitationImg(@Body requestBody: RequestBody): Observable<HttpResult<InvitationImgBean>>

    /**
     *Fund transfer interface
     */
    @POST("app/co_transfer")
    fun doAssetExchange(@Body requestBody: RequestBody): Observable<HttpResult<Any>>


    /**
     *Game Authorization
     */
    @POST("/game/appplay")
    fun getGameAuth(@Body requestBody: RequestBody): Observable<HttpResult<Any>>

    /**
     *Change login password V4
     */
    @POST("user/password_update_v4")
    fun changeLoginPwdV4(@Body requestBody: RequestBody): Observable<HttpResult<Any>>

    /**
     *Upload photos
     *Submit using a form
     */
    @Multipart
    @POST("uploadFile")
    fun uploadZip(@Part file: MultipartBody.Part): Observable<HttpResult<Any>>

    @POST("appPush/userPushSwitch")
    fun getPush(@QueryMap map: Map<String, String>): Observable<HttpResult<PushItem>>

    @POST("appPush/saveAppPushDevice")
    fun bindToken(@Body requestBody: RequestBody): Observable<HttpResult<Any>>

    @POST("appPush/saveAppPushUser")
    fun saveAppPushU(@Body requestBody: RequestBody): Observable<HttpResult<Any>>

    /**
     *Get Currency Introduction
     */
    @POST("common/depth_map")
    fun getCoinDepth(@Body requestBody: RequestBody): Observable<HttpResult<DepthItem>>

    /**
     *Obtain whether the interface is connected
     */
    @GET("/health_check")
    fun getHealth(@QueryMap map: Map<String, String>): Observable<HttpResult<Any>>

    /**
     *Obtain whether the interface is connected
     */
    @POST("appNetwork/upload")
    fun uploadAppNetwork(@Body requestBody: RequestBody): Observable<ResponseBody>


    /**
     *Get Currency Introduction
     */
    @POST("homepage_Elastic_Layer")
    fun getHomeAdvert(@Body requestBody: RequestBody): Observable<HttpResult<AdvertModel>>

    /**
     *Obtain whether the interface is connected
     */
    @POST("save_interface_data")
    fun uploadAppNetworkInfo(@Body requestBody: RequestBody): Observable<ResponseBody>

    /**
     *FreeStaking project subscription
     */
    @POST("increment/project/apply")
    fun requestToBuy(@Body requestBody: RequestBody): Observable<HttpResult<Any>>

    /**
     *FreeStaking homepage public interface
     */
    @POST("increment/index")
    fun getFreeStakingData(@Body requestBody: RequestBody): Observable<HttpResult<FreeStakingBean>>

    /**
     *Project list on FreeStacking homepage
     */
    @POST("increment/project_list")
    fun getFreeStakingList(@Body requestBody: RequestBody): Observable<HttpResult<ArrayList<CurrencyBean>>>

    /**
     *FreeStaking Project Details
     */
    @POST("increment/project_info")
    fun getProjectDetail(@Body requestBody: RequestBody): Observable<HttpResult<FreeStakingDetailBean>>

    /**
     *My PoS records_ Lock holding PoS
     */
    @POST("increment/my_pos")
    fun getMyPosRecord(@Body requestBody: RequestBody): Observable<HttpResult<MyPosRecordBean>>


    /**
     *Obtain contract broker invitation configuration
     */
    @POST("co/agent/getInviteConfig")
    fun getInviteConfig(@Body requestBody: RequestBody): Observable<HttpResult<AgentBean>>



    /**
     *Search contract broker based on UID
     */
    @POST("co/agent/getAgentUser")
    fun getAgentUser(@Body requestBody: RequestBody): Observable<HttpResult<AgentUserBean>>




    /**
     *Contract broker commission rebate income inquiry
     */
    @POST("co/agent/getAgentInfo")
    fun getAgentInfo(@Body requestBody: RequestBody): Observable<HttpResult<AgentInfoBean>>
    @POST("co/agent/getCoAgentInfo")
    fun getCoAgentInfo(@Body requestBody: RequestBody): Observable<HttpResult<CoAgentInfoBean>>



    /**
     *Obtain a list of third-party exchange rates for the selected legal currency and digital currency
     */
    @POST("get_paycard_rate_list")
    fun get_paycard_rate_list(@Body requestBody: RequestBody): Observable<HttpResult<RateListBean>>


    /**
     *Obtain a list of third-party exchange rates for the selected legal currency and digital currency
     */
    @POST("get_paycard_num")
    fun get_paycard_num(@Body requestBody: RequestBody): Observable<HttpResult<PayCardBean>>


    /**
     *Submit
     */
    @POST("payment_submit")
    fun payment_submit(@Body requestBody: RequestBody): Observable<HttpResult<PaymentSubmitBean>>



    /**
     *Obtain a list of legal and digital currencies for kv configuration
     */
    @POST("get_third_support_fiat_v2")
    fun get_third_support_fiat(@Body requestBody: RequestBody): Observable<HttpResult<QuickBuyCoinBean>>


    @POST("confirm_pc_login")
    fun getPcLogin(@Body requestBody: RequestBody): Observable<HttpResult<Any>>

    @POST("get_ip_by_qrcode")
    fun getPCLoginInfo(@Body requestBody: RequestBody): Observable<HttpResult<QRInfo>>

    @POST("invitation/addInvitationedCode")
    fun addInvitationedCode(@Body requestBody: RequestBody): Observable<HttpResult<Any>>

    @POST("invitation/publicConfig")
    fun getInvitationPublicConfig(@Body requestBody: RequestBody): Observable<HttpResult<InviteConfig>>

    @POST("invitation/myInvitations")
    fun getMyInvitations(@Body requestBody: RequestBody): Observable<HttpResult<InvitationsList>>


    @POST("invitation/myInvitationRewards")
    fun getMyInvitationsRewards(@Body requestBody: RequestBody): Observable<HttpResult<InvitationsList>>


    @GET("common/switch")
    fun commonSwitch(@QueryMap map: Map<String, String>): Observable<HttpResult<SwitchVoBean>>

}

