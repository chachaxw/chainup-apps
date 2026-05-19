package com.yjkj.chainup.net


import android.text.TextUtils
import com.chainup.contract.app.ContractCloudAgent
import com.fengniao.news.util.DateUtil
import com.google.gson.JsonObject
import com.yjkj.chainup.BuildConfig
import com.yjkj.chainup.app.AppConfig
import com.yjkj.chainup.app.ChainUpApp
import com.yjkj.chainup.bean.*
import com.yjkj.chainup.bean.address.AddressBean
import com.yjkj.chainup.bean.dev.MessageBean
import com.yjkj.chainup.bean.dev.NoticeBean
import com.yjkj.chainup.bean.fund.CashFlowBean
import com.yjkj.chainup.bean.kline.DepthItem
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.extra_service.eventbus.EventBusUtil
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.freestaking.bean.CurrencyBean
import com.yjkj.chainup.freestaking.bean.FreeStakingBean
import com.yjkj.chainup.freestaking.bean.FreeStakingDetailBean
import com.yjkj.chainup.freestaking.bean.MyPosRecordBean
import com.yjkj.chainup.interceptor.NetInterceptor
import com.yjkj.chainup.model.api.ContractApiService
import com.yjkj.chainup.model.api.OTCApiService
import com.yjkj.chainup.model.api.RedPackageApiService
import com.yjkj.chainup.model.api.SpeedApiService
import com.yjkj.chainup.net.api.ApiConstants.*
import com.yjkj.chainup.net.api.ApiService
import com.yjkj.chainup.net.api.HttpResult
import com.yjkj.chainup.net.retrofit.ResponseConverterFactory
import com.yjkj.chainup.net_new.HttpHelper
import com.yjkj.chainup.net_new.JSONUtil
import com.yjkj.chainup.net_new.NetUrl
import com.yjkj.chainup.new_version.bean.*
import com.yjkj.chainup.new_version.home.AdvertModel
import com.yjkj.chainup.new_version.redpackage.bean.*
import com.yjkj.chainup.treaty.bean.*
import com.yjkj.chainup.util.HttpsUtils
import com.yjkj.chainup.util.LogUtil
import com.yjkj.chainup.util.NetworkUtils
import com.yjkj.chainup.util.StringUtil
import com.yjkj.chainup.ws.WsAgentManager
import io.reactivex.Observable
import okhttp3.*
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.RequestBody.Companion.toRequestBody
import okhttp3.logging.HttpLoggingInterceptor
import org.json.JSONObject
import retrofit2.Retrofit
import retrofit2.adapter.rxjava2.RxJava2CallAdapterFactory
import retrofit2.http.Body
import retrofit2.http.POST
import java.io.File
import java.io.IOException
import java.util.*
import java.util.concurrent.TimeUnit


lateinit var originalRequest: Request

class HttpClient private constructor() {
    val TAG = HttpClient::class.java.simpleName

    var mOkHttpClient: OkHttpClient? = null


    private var token: String = ""

    private var apiService: ApiService

    /**
     *OTC off site service
     */
    private var apiOTCService: OTCApiService

    private var contractService: ContractApiService

    private var newContractService: ContractApiService

    private var redPackageService: RedPackageApiService

    private fun getBaseMap(isAddToken: Boolean = false): TreeMap<String, String> {
        val map = TreeMap<String, String>()
        map["time"] = System.currentTimeMillis().toString()
//        if (isAddToken && !TextUtils.isEmpty(token)) {
//            map["token"] = token
//        }

//        map.put("exchange-token", token!!)

        return map
    }


    companion object {

        /**
         *Country code
         */
        const val COUNTRY_CODE = "countryCode"

        /**
         *Mobile phone number
         */
        const val MOBILE_NUMBER = "mobileNumber"

        /**
         *Login password
         */
        const val LOGIN_PWORD = "loginPword"

        /**
         *Verification code
         */
        const val SMS_AUTHCODE = "smsAuthCode"

        /**
         *Invitation code
         */
        const val INVITED_CODE = "invitedCode"

        /**
         *Email
         */
        const val EMAIL = "email"

        /**
         *Email verification code
         */
        const val EMAIL_AUTHCODE = "emailAuthCode"

        /**
         *Type of SMS verification code
         */
        const val OPERATION_TYPE = "operationType"

        /**
         *User nickname
         */
        const val NICKNAME = "nickname"

        /**
         * GoogleKey
         */
        const val GOOGLE_KEY = "googleKey"


        /**
         *Google verification code
         */
        const val GOOGLE_CODE = "googleCode"

        /**
         *Verification type
         */
        const val VERIFICATION_TYPE = "verificationType"

        private var INSTANCE: HttpClient? = null

        val instance: HttpClient
            get() {
                if (INSTANCE == null) {
                    synchronized(HttpClient::class.java) {
                        if (INSTANCE == null) {
                            INSTANCE = HttpClient()
                        }
                    }
                }
                return INSTANCE!!
            }
    }


    init {
        initOkHttpClient()
        apiService = createApi()
        apiOTCService = createOTCApi()
        contractService = createContractApi()
        newContractService = createNewContractApi()
        redPackageService = createRedPackageApi()
    }


    fun refreshApi() {
        apiService = createApi()
        apiOTCService = createOTCApi()
        contractService = createContractApi()
        redPackageService = createRedPackageApi()
        newContractService = createNewContractApi()
    }


    private fun createApi(): ApiService {
        if (!StringUtil.isHttpUrl(BASE_URL))
            BASE_URL = AppConfig.default_host
        val retrofit = Retrofit.Builder()
                .baseUrl(NetUrl.baseUrl())  //Set Server Path
                .client(mOkHttpClient!!)  //Set network requests for OKHTTP
                .addConverterFactory(ResponseConverterFactory.create())//Add conversion library, default to Gson
                .addCallAdapterFactory(RxJava2CallAdapterFactory.create()) //Add callback library using RxJava
//                .addConverterFactory(GsonConverterFactory.create())
                .build()
        return retrofit.create(ApiService::class.java)
    }

    private fun createOTCApi(): OTCApiService {

        if (!StringUtil.isHttpUrl(BASE_OTC_URL))
            BASE_OTC_URL = AppConfig.default_host
        val retrofit = Retrofit.Builder()
                .baseUrl(BASE_OTC_URL)  //Set Server Path
                .client(mOkHttpClient!!)  //Set network requests for OKHTTP
                .addConverterFactory(ResponseConverterFactory.create())//Add conversion library, default to Gson
                .addCallAdapterFactory(RxJava2CallAdapterFactory.create()) //Add callback library using RxJava
//                .addConverterFactory(GsonConverterFactory.create())
                .build()
        return retrofit.create(OTCApiService::class.java)
    }


    private fun createContractApi(): ContractApiService {
        if (!StringUtil.isHttpUrl(CONTRACT_URL))
            CONTRACT_URL = AppConfig.default_host
        val retrofit = Retrofit.Builder()
                .baseUrl(CONTRACT_URL)  //Set Server Path
                .client(mOkHttpClient!!)  //Set network requests for OKHTTP
                .addConverterFactory(ResponseConverterFactory.create())//Add conversion library, default to Gson
                .addCallAdapterFactory(RxJava2CallAdapterFactory.create()) //Add callback library using RxJava
//                .addConverterFactory(GsonConverterFactory.create())
                .build()
        return retrofit.create(ContractApiService::class.java)
    }

    private fun createNewContractApi(): ContractApiService {
        if (!StringUtil.isHttpUrl(NEW_CONTRACT_URL))
            NEW_CONTRACT_URL = AppConfig.default_host
        val retrofit = Retrofit.Builder()
                .baseUrl(NEW_CONTRACT_URL)  //Set Server Path
                .client(mOkHttpClient!!)  //Set network requests for OKHTTP
                .addConverterFactory(ResponseConverterFactory.create())//Add conversion library, default to Gson
                .addCallAdapterFactory(RxJava2CallAdapterFactory.create()) //Add callback library using RxJava
//                .addConverterFactory(GsonConverterFactory.create())
                .build()
        return retrofit.create(ContractApiService::class.java)
    }


    private fun createRedPackageApi(): RedPackageApiService {
        var redPackUrl = NetUrl.getredPackageUrl()
        if (!StringUtil.isHttpUrl(redPackUrl))
            redPackUrl = AppConfig.default_host
        val retrofit = Retrofit.Builder()
                .baseUrl(redPackUrl)  //Set Server Path
                .client(mOkHttpClient!!)  //Set network requests for OKHTTP
                .addConverterFactory(ResponseConverterFactory.create())//Add conversion library, default to Gson
                .addCallAdapterFactory(RxJava2CallAdapterFactory.create()) //Add callback library using RxJava
//                .addConverterFactory(GsonConverterFactory.create())
                .build()
        return retrofit.create(RedPackageApiService::class.java)
    }


    fun setToken(token: String?) {
        if (null != token) {
            this.token = token
            if (token.isNotEmpty()) {
                var messageEvent = MessageEvent(MessageEvent.login_bind_type)
                EventBusUtil.post(messageEvent)
            }
        } else {
            this.token = ""
        }
    }

    private fun toRequestBody(params: Map<String, String>): RequestBody {
        return JSONObject(params).toString().toRequestBody("application/json;charset=utf-8".toMediaTypeOrNull())
    }


    /**
     *Change login password
     */
    fun changeLoginPwd(smsAuthCode: String = "", loginPwd: String, newLoginPwd: String,
                       googleCode: String = "", identificationNumber: String? = ""): Observable<HttpResult<Any>> {
        val map = getBaseMap()
        map["smsAuthCode"] = smsAuthCode
        map[LOGIN_PWORD] = loginPwd
        map["newLoginPword"] = newLoginPwd
        map["googleCode"] = googleCode
        if (identificationNumber != null && identificationNumber.isNotEmpty()) {
            map["IdentificationNumber"] = identificationNumber
        }
        return apiService.changeLoginPwdV4(toRequestBody(DataHandler.encryptParams(map)))

    }


    /**
     *User nickname modification
     */
    fun editNickname(nickName: String): Observable<HttpResult<Any>> {
        val map = getBaseMap()
        map[NICKNAME] = nickName
        return apiService.editNickname(toRequestBody(DataHandler.encryptParams(map)))
    }


    /**
     *Log out of login
     */
    fun logout(): Observable<HttpResult<Any>> {
        val map = getBaseMap(false)
        return apiService.logout(toRequestBody(DataHandler.encryptParams(map)))
    }


    /*******Google certification related * START*******/

    /**
     *Obtain Google Key
     */
    fun getGoogleKey(): Observable<HttpResult<JsonObject>> {
        val map = getBaseMap(false)
        return apiService.getGoogleKey(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Bind Google authentication
     */
    fun bindGoogleVerify(googleKey: String, loginPwd: String, googleCode: String): Observable<HttpResult<Any>> {
        val map = getBaseMap(false)
        map[GOOGLE_KEY] = googleKey
        map["loginPwd"] = loginPwd
        map[GOOGLE_CODE] = googleCode
        return apiService.bindGoogleVerify(toRequestBody(DataHandler.encryptParams(map)))
    }


    /**
     *Turn off Google verification
     */
    fun unbindGoogleVerify(smsValidCode: String, googleCode: String): Observable<HttpResult<Any>> {
        val map = getBaseMap()
        map["smsValidCode"] = smsValidCode
        map["googleCode"] = googleCode
        return apiService.unbindGoogleVerify(toRequestBody(DataHandler.encryptParams(map)))

    }


    /**
     *Turn off mobile verification
     */
    fun unbindMobileVerify(smsValidCode: String, googleCode: String): Observable<HttpResult<Any>> {
        val map = getBaseMap()
        map["smsValidCode"] = smsValidCode
        map["googleCode"] = googleCode
        return apiService.unbindMobileVerify(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Enable mobile verification
     */
    fun openMobileVerify(): Observable<HttpResult<Any>> {
        val map = getBaseMap()
        return apiService.openMobileVerify(toRequestBody(DataHandler.encryptParams(map)))
    }


    /*******Certification related * END*******/


    /**
     *Modify mobile phone number
     */

    fun changeMobile(newSmsCode: String, originalSmsCode: String, country: String, newMobile: String, googleCode: String = ""): Observable<HttpResult<Any>> {
        val map = getBaseMap()
        map["authenticationCode"] = originalSmsCode
        map["countryCode"] = country
        map["mobileNumber"] = newMobile
        map["googleCode"] = googleCode
        map["smsAuthCode"] = newSmsCode
        return apiService.changeMobile(toRequestBody(DataHandler.encryptParams(map)))
    }

    //Determining whether the email or phone number is the same as the old one is not allowed to be modified for modifying phone numbers and email addresses
    fun checkOldMobileOrMail(keyWord:String,isPhone:String):Observable<HttpResult<Any>>{
        val map = getBaseMap()
        map["keyWord"] = keyWord
        map["isPhone"] = isPhone
        return apiService.checkOldMobileOrMail(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Modify email
     */
    fun changeEmail(oldEmailCode: String, newEmail: String, newEmailCode: String, smsCode: String = "", googleCode: String = ""): Observable<HttpResult<EditEmailBean?>> {
        val map = getBaseMap()
        map["emailOldValidCode"] = oldEmailCode
        map["email"] = newEmail
        map["emailNewValidCode"] = newEmailCode
        map["smsValidCode"] = smsCode
        map["googleCode"] = googleCode
        return apiService.changeEmail(toRequestBody(DataHandler.encryptParams(map)))
    }


    /**
     *Bind email
     */
    fun bindEmail(email: String, emailCode: String, smsCode: String = "", googleCode: String = ""): Observable<HttpResult<Any>> {
        val map = getBaseMap()
        map["email"] = email
        map["emailValidCode"] = emailCode
        map["smsValidCode"] = smsCode
        map["googleCode"] = googleCode
        return apiService.bindEmail(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Bind phone
     */
    fun bindMobile(country: String, mobile: String, smsCode: String, googleCode: String = ""): Observable<HttpResult<Any>> {
        val map = getBaseMap()
        map[COUNTRY_CODE] = country
        map[MOBILE_NUMBER] = mobile
        map[SMS_AUTHCODE] = smsCode
        map[GOOGLE_CODE] = googleCode
        return apiService.bindMobile(toRequestBody(DataHandler.encryptParams(map)))
    }


    /**
     *Obtain recharge address
     */
    fun getChargeAddress(symbol: String): Observable<HttpResult<JsonObject>> {
        val map = getBaseMap()
        map["symbol"] = symbol
        return apiService.getChargeAddress(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Withdrawal operation
     *@ amount withdrawal amount (excluding handling fees)
     *@ symbol currency
     */
    fun doWithdraw(addressId: String = "", fee: String = "", smsCode: String = "", googleCode: String = "", amount: String = "", symbol: String? = "",
                   address: String = "", label: String = "", trustType: String = "", emailValidCode: String = "",capitalPwd:String?): Observable<HttpResult<AuthBean>> {
        val map = getBaseMap()
        if (addressId.isNotEmpty()) {
            map["addressId"] = addressId
        }
        if (address.isNotEmpty()) {
            map["address"] = address
        }
        if (label.isNotEmpty()) {
            map["label"] = label
        }
        if (trustType.isNotEmpty()) {
            map["trustType"] = trustType
        }


        map["fee"] = fee
        map["amount"] = amount

        if (null != symbol) {
            map["symbol"] = symbol
        }

        if (emailValidCode.isNotEmpty()) {
            map["emailValidCode"] = emailValidCode
        }

        if (googleCode.isNotEmpty()) {
            map["googleCode"] = googleCode
        }

        if (smsCode.isNotEmpty()) {
            map["smsValidCode"] = smsCode
        }
        if (capitalPwd!=null && capitalPwd.isNotEmpty()) {
            map["capitalPassword"] = capitalPwd
        }
        return apiService.doWithdraw(toRequestBody(DataHandler.encryptParams(map)))
    }

    /***********Address Management ****** START********/
    /**
     *Wallet Address List
     */
    fun getAddressList(symbol: String = ""): Observable<HttpResult<AddressBean>> {
        val map = getBaseMap()
        map["coinSymbol"] = symbol
        return apiService.getAddressList(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Add Address
     */
    fun addWithdrawAddress(symbol: String, address: String, smsCode: String = "", label: String, googleCode: String = "", trustType: String = "0", emailValidCode: String = ""): Observable<HttpResult<Any>> {
        val map = getBaseMap()
        map["coinSymbol"] = symbol
        map["address"] = address
        if(!"".equals(smsCode)) {
            map["smsValidCode"] = smsCode
        }
        map["label"] = label
        if(!"".equals(googleCode)){
            map["googleValidCode"] = googleCode
        }

        map["trustType"] = trustType
        if (emailValidCode.isNotEmpty()) {
            map["emailValidCode"] = emailValidCode
        }
        return apiService.addWithdrawAddress(toRequestBody(DataHandler.encryptParams(map)))
    }


    /**
     *Delete wallet address
     */
    fun delWithdrawAddress(id: String, smsCode: String = "",emailAuthCode: String = "", googleCode: String = ""): Observable<HttpResult<Any>> {
        val map = getBaseMap()
        map["ids"] = id
        if(!TextUtils.isEmpty(smsCode)) map["smsValidCode"] = smsCode
        if(!TextUtils.isEmpty(emailAuthCode)) map["emailAuthCode"] = emailAuthCode
        if(!TextUtils.isEmpty(googleCode)) map["googleCode"] = googleCode
        return apiService.delWithdrawAddress(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Message Center
     */
    fun getMessages(type: Int, page: Int = 1, pageSize: Int = 1000): Observable<HttpResult<MessageBean>> {
        val map = getBaseMap()
        map["messageType"] = type.toString()
        map["page"] = page.toString()
        map.put("pageSize", pageSize.toString())
        return apiService.getMessages(toRequestBody(DataHandler.encryptParams(map)))
    }


    /**
     *Announcement List
     */
    fun getNotices(page: Int = 1, pageSize: Int = 1000): Observable<HttpResult<NoticeBean>> {
        val map = getBaseMap()
//        map["page"] = page.toString()
        map.put("pageSize", pageSize.toString())
        return apiService.getNotices(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Upload photos
     */
    fun uploadImg(imgBase64: String, name: String = ""): Observable<HttpResult<JsonObject>> {
        val map = getBaseMap()
        if (name.isNotEmpty()) {
            map["name"] = name
        }
        map["imageData"] = imgBase64
//        val body = RequestBody.create(MediaType.parse("form-data"), JSONObject(DataHandler.encryptParams(map)).toString())

        return apiService.uploadImg(toRequestBody(DataHandler.encryptParams(map)))
    }


    /**
     *Obtain KYC configuration
     */
    fun getKYCConfig(): Observable<HttpResult<KYCBean>> {
        val map = getBaseMap(false)
        return apiService.getKYCConfig(toRequestBody(DataHandler.encryptParams(map)))
    }


    /**
     *Fund transfer
     */
    fun doAssetExchange(coinSymbol: String, amount: String, transferType: String): Observable<HttpResult<Any>> {
        //FuturesType 0 Privatization 1 Contract Cloud
        //Interface app/co for spot ->contract spot_ Transfer

        //Contract ->Spot
        //0: Interface app/co for stock_ Transfer
        //1: Contract interface: assets/saas_ Trans/co_ To_ Ex
        val map = getBaseMap()
        map["coinSymbol"] = coinSymbol
        map["amount"] = amount
        map["transferType"] = transferType

        if (transferType.equals(ContractCloudAgent.WALLET_TO_CONTRACT)) {
            //Spot ->Contract
            return apiService.doAssetExchange(toRequestBody(DataHandler.encryptParams(map)))
        } else {
            //Contract ->Spot
            val futuresType = PublicInfoDataService.getInstance().getfuturesType(null);
            if (futuresType.equals("0")) {
                //Privatization
                return apiService.doAssetExchange(toRequestBody(DataHandler.encryptParams(map)))
            } else {
                //Contract Cloud
                return contractService.coTransferEx(toRequestBody(DataHandler.encryptParams(map)))
            }
        }


    }


    /**
     *Real name authentication
     */
    fun authVerify(countryCode: String,
                   certType: Int,
                   certNum: String,
                   userName: String,//Last Name
                   firstPhoto: String,
                   secondPhoto: String,
                   thirdPhoto: String,
                   familyName: String,
                   name: String,
                   numberCode: String
    ): Observable<HttpResult<Any>> {
        val map = getBaseMap()
        map["countryCode"] = countryCode
        map["certificateType"] = certType.toString()
        map["certificateNumber"] = certNum
        map["userName"] = userName
        map["firstPhoto"] = firstPhoto
        map["secondPhoto"] = secondPhoto
        map["thirdPhoto"] = thirdPhoto
        map["familyName"] = familyName
        map["name"] = name
        map["numberCode"] = numberCode


        return apiService.authVerify(toRequestBody(DataHandler.encryptParams(map)))
    }


    /**
     *Enable gesture password
     *@param loginPwd is required
     *@param smsCode is required (when enabling mobile verification)
     *@param googleCode is required (when enabling Google verification)
     */
    fun openHandPwd(loginPwd: String, smsCode: String = "", googleCode: String = ""): Observable<HttpResult<JsonObject>> {
        val map = getBaseMap()
        map["loginPwd"] = loginPwd
        map["smsValidCode"] = smsCode
        map["googleCode"] = googleCode
        return apiService.openHandPwd(toRequestBody(DataHandler.encryptParams(map)))
    }


    /**
     *Turn off gesture password
     *@param loginPwd is required
     *@param smsCode is required (when enabling mobile verification)
     *@param googleCode is required (when enabling Google verification)
     */
    fun closeHandPwd(loginPwd: String, smsCode: String = "", googleCode: String = ""): Observable<HttpResult<Any>> {
        val map = getBaseMap()
        map["loginPwd"] = loginPwd
        map["smsValidCode"] = smsCode
        map["googleCode"] = googleCode
        return apiService.closeHandPwd(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**common/emailValidCode
     *Obtain user information
     */
    fun getUserInfo(): Observable<HttpResult<UserInfoData>> {
        return apiService.getUserInfo(toRequestBody(DataHandler.encryptParams(getBaseMap())))
    }


    /**
     *Help Center List
     */
    fun getHelpCenterList(): Observable<HttpResult<ArrayList<HelpCenterBean>>> {
        val map = getBaseMap()
        return apiService.getHelpCenterList(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Obtain the domain name of H5
     */
    fun getCommonKV(key: String = "h5_url"): Observable<HttpResult<JsonObject>> {
        val map = getBaseMap()
        map["key"] = key
        return apiService.getCommonKV(DataHandler.encryptParams(map))
    }


    /**
     *Clear user gesture password
     */
    fun cleanGesturePwd(uid: String): Observable<HttpResult<Any>> {
        val map = getBaseMap()
        map["uid"] = uid
        return apiService.cleanGesturePwd(toRequestBody(DataHandler.encryptParams(map)))
    }


    /**
     *About us
     */
    fun getAboutUs(): Observable<HttpResult<ArrayList<AboutUSBean>>> {
        val map = getBaseMap()
        return apiService.getAboutUs(DataHandler.encryptParams(map))
    }

    /**
     *Obtain a list of third-party exchange rates for the selected legal currency and digital currency
     */
    fun getPaycardRateList(fiat: String, coin: String,transferType:String): Observable<HttpResult<RateListBean>> {
        val map = getBaseMap()
        map["fiat"] = fiat
        map["coin"] = coin
        map["transferType"] = transferType
        return apiService.get_paycard_rate_list(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Display the number of digital currencies that can be exchanged by entering the legal currency quantity after selecting a third party
     */
    fun getPaycardNum(fiat: String, coin: String, num: String,transferType:String): Observable<HttpResult<PayCardBean>> {
        val map = getBaseMap()
        map["fiat"] = fiat
        map["coin"] = coin
        map["num"] = num
        map["transferType"] = transferType
        return apiService.get_paycard_num(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Obtain a list of legal and digital currencies for kv configuration
     */
    fun getThirdSupportFiat(transferType:String): Observable<HttpResult<QuickBuyCoinBean>> {
        val map = getBaseMap()
        map["transferType"] = transferType
        return apiService.get_third_support_fiat(toRequestBody(DataHandler.encryptParams(map)))
    }


    /**
     *Submit the form after selecting a third party
     */
    fun paymentSubmit(fiat: String,
                      coin: String,
                      num: String,
                      name: String,
                      quote_id: String?,
                      base_amount: String?,
                      amount: String?,
                      total_amount: String?,
                      rate: String?,
                      transferType:String,
                      sourceAmount:String,
                      targetAmount:String
    ): Observable<HttpResult<PaymentSubmitBean>> {
        val map = getBaseMap()
        map["fiat"] = fiat
        map["coin"] = coin
        map["num"] = num
        map["name"] = name
        if(quote_id!=null){
            map["quote_id"] = quote_id
        }
        if(base_amount!=null){
            map["base_amount"] = base_amount
        }
        if(total_amount!=null){
            map["total_amount"] = total_amount
        }
        if(amount!=null){
            map["amount"] = amount
        }
        if(rate!=null){
            map["rate"] = rate
        }
        map["transferType"] = transferType
        map["sourceAmount"] = sourceAmount
        map["targetAmount"] = targetAmount
        map["successUrl"] = AppConfig.quickTradeBanxaSuccessfulUrl
        map["failUrl"] = AppConfig.quickTradeBanxaFailedUrl
        return apiService.payment_submit(toRequestBody(DataHandler.encryptParams(map)))
    }
    /*****************OTC*************************/


    /***
     *Remove blacklist
     */
    fun removeRelationFromBlack(friendId: Int): Observable<HttpResult<Any>> {
        val map = getBaseMap()
        map["friendId"] = friendId.toString()
        return apiOTCService.removeRelationFromBlack4OTC(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Transfer to homepage
     */
    fun transher4OTC(fromAccount: String, toAccount: String, amount: String, coinSymbol: String?): Observable<HttpResult<Any>> {
        val map = getBaseMap()
        map["fromAccount"] = fromAccount
        map["toAccount"] = toAccount
        map["amount"] = amount
        if (null != coinSymbol) {
            map["coinSymbol"] = coinSymbol
        }
        return apiService.transher4OTC(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Obtain a transaction account for a certain currency
     */
    fun accountGetCoin4OTC(coin: String?): Observable<HttpResult<OTCGetCoinBean>> {
        val map = getBaseMap()
        if (null != coin) {
            map["coin"] = coin
        }
        return apiService.accountGetCoin4OTC(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Appeal page
     */
    fun createProblem4OTC(rqDescribe: String, rqType: String, rqUnreleased: String, rqUnpaid: String, imageDataStr: String): Observable<HttpResult<JsonObject>> {
        val map = getBaseMap()
        map["rqDescribe"] = rqDescribe
        map["rqType"] = rqType
        if (!TextUtils.isEmpty(rqUnreleased)) {
            map["rqUnreleased"] = rqUnreleased
        }
        if (!TextUtils.isEmpty(rqUnpaid)) {
            map["rqUnpaid"] = rqUnpaid
        }
        if (!TextUtils.isEmpty(imageDataStr)) {
            map["imageDataStr"] = imageDataStr
        }
        return apiService.createProblem4OTC(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Get my order
     */
    fun byStatus4OTC(status: String? = "", payCoin: String = "", startTime: String = "", endTime: String = "", pageSize: Int = 20, page: Int = 1, coinSymbol: String = "", tradeType: String = ""): Observable<HttpResult<OTCOrderBean>> {
        val map = getBaseMap()
        if (!TextUtils.isEmpty(status)) {
            map["status"] = status!!
        }
        if (!TextUtils.isEmpty(tradeType)) {
            map["tradeType"] = tradeType
        }
        if (!TextUtils.isEmpty(startTime)) {
            map["startTimeMillis"] = startTime
        }
        if (!TextUtils.isEmpty(endTime)) {
            map["endTimeMillis"] = endTime
        }
        if (!TextUtils.isEmpty(payCoin)) {
            map["payCoin"] = payCoin
        }
        if (!TextUtils.isEmpty(coinSymbol)) {
            map["coinSymbol"] = coinSymbol
        }
        map["pageSize"] = pageSize.toString()
        map["page"] = page.toString()

        return apiService.byStatus4OTC(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Credit card deposit and withdrawal·
     */
    fun creditCard( pageSize: Int = 20, page: Int = 1 ): Observable<HttpResult<OTCOrderBean>> {
        val map = getBaseMap()
        map["pageSize"] = pageSize.toString()
        map["page"] = page.toString()
        return apiService.creditCard(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Join blacklist
     */
    fun userContacts4OTC(otherUid: String): Observable<HttpResult<Any>> {
        val map = getBaseMap()
        map["otherUid"] = otherUid.toString()
        map["relationType"] = "BLACKLIST"
        return apiOTCService.userContacts4OTC(toRequestBody(DataHandler.encryptParams(map)))
    }


    /**
     *Get chat history messages
     */
    fun gethistoryMessage(fromId: Int, orderId: String, toId: Int): Observable<HttpResult<ArrayList<OTCIMMessageBean>>> {
        val map = getBaseMap()
        map["fromId"] = fromId.toString()
        map["orderId"] = orderId
        map["toId"] = toId.toString()
        map["uaTime"] = DateUtil.longToString("yyyy-MM-dd HH:mm:ss", System.currentTimeMillis())
        return apiOTCService.gethistoryMessage(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Question Details Page Customer Service Chat
     */
    fun getDetailsProblem(id: Int): Observable<HttpResult<OTCIMDetailsProblemBean>> {
        val map = getBaseMap()
        map["id"] = id.toString()
        return apiService.getDetailsProblem(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Send a message on the issue details page
     */
    fun getReplyCreate(rqId: Int, rqReplyContent: String, contentType: String): Observable<HttpResult<Any>> {
        val map = getBaseMap()
        map["rqId"] = rqId.toString()
        map["rqReplyContent"] = rqReplyContent
        map["contentType"] = contentType
        return apiService.getReplyCreate(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Other transaction records/other_ Transfer_ List
     */
    fun otherTransList4V2(symbol: String = "", transactionScene: String = "", startTime: String = "", endTime: String = "", pageSize: String = "20", page: String = "1"): Observable<HttpResult<CashFlowBean>> {
        val map = getBaseMap()
        map["coinSymbol"] = symbol
        map["transactionScene"] = transactionScene
        map["startTimeMillis"] = startTime
        map["endTimeMillis"] = endTime
        map["pageSize"] = pageSize
        map["page"] = page
        return apiService.otherTransList4V2(toRequestBody(DataHandler.encryptParams(map)))
    }

    fun getTransferRecord(symbol: String = "", transactionScene: String = "", startTime: String = "", endTime: String = "", pageSize: String = "20", page: String = "1"): Observable<HttpResult<CashFlowBean>> {
        val map = getBaseMap()
        map["coinSymbol"] = symbol
        map["transactionScene"] = transactionScene
        map["startTimeMillis"] = startTime
        map["endTimeMillis"] = endTime
        map["pageSize"] = pageSize
        map["page"] = page
        return newContractService.getTransferRecord(toRequestBody(DataHandler.encryptParams(map)))
    }


    /**
     *New payment method
     *@param payment payment method key
     *@param userName Name
     *@param account account information, except for Western Union remittance, others are required
     *@param qrcodeImg base64 image
     *@param bankname Opening bank
     *@param bankOfDeposit Account Opening Branch
     *@param ifscCode IFSC Code
     *Param RemittanceInformation Remittance Information
     *@param smsAuthCode Choose between mobile verification code, SMS verification code, and Google verification code
     *Choose between @param googleCode, Google verification code, SMS verification code, and Google verification code
     *
     */
    fun addPayment4OTC(payment: String,
                       userName: String,
                       account: String,
                       qrcodeImg: String,
                       bankName: String,
                       bankOfDeposit: String,
                       ifscCode: String,
                       remittanceInformation: String,
                       smsAuthCode: String,
                       googleCode: String
    ): Observable<HttpResult<Any>> {
        val map = getBaseMap()
        map["payment"] = payment
        map["userName"] = userName
        map["account"] = account
        map["qrcodeImg"] = qrcodeImg
        map["bankName"] = bankName
        map["bankOfDeposit"] = bankOfDeposit
        map["ifscCode"] = ifscCode
        map["remittanceInformation"] = remittanceInformation
        map["smsAuthCode"] = smsAuthCode
        map["googleCode"] = googleCode
        return apiOTCService.addPayment4OTC(toRequestBody(DataHandler.encryptParams(map)))
    }


    /**
     *Delete payment method
     *@param id Payment method id
     *@param smsAuthCode Choose between mobile verification code, SMS verification code, and Google verification code
     *Choose between @param googleCode, Google verification code, SMS verification code, and Google verification code
     */
    fun removePayment4OTC(id: String, smsAuthCode: String = "", googleCode: String = ""): Observable<HttpResult<Any>> {
        val map = getBaseMap()
        map["id"] = id
        map["smsAuthCode"] = smsAuthCode
        map["googleCode"] = googleCode
        return apiOTCService.removePayment4OTC(toRequestBody(DataHandler.encryptParams(map)))
    }


    /**
     *Payment Method Switch Settings
     *@param id Payment method id
     * @param isOpen 1/0
     */
    fun operatePayment4OTC(id: String, isOpen: String): Observable<HttpResult<Any>> {
        val map = getBaseMap()
        map["id"] = id
        map["isOpen"] = isOpen
        return apiOTCService.operatePayment4OTC(toRequestBody(DataHandler.encryptParams(map)))
    }


    /**
     *Modify payment method
     *@param id Payment method id
     *@param payment payment method key - Prohibit modification
     *@param userName Name
     *@param account account information, except for Western Union remittance, others are required
     *@param qrcodeImg base64 image
     *@param bankname Opening bank
     *@param bankOfDeposit Account Opening Branch
     *@param ifscCode IFSC Code
     *Param RemittanceInformation Remittance Information
     *@param smsAuthCode Choose between mobile verification code, SMS verification code, and Google verification code
     *Choose between @param googleCode, Google verification code, SMS verification code, and Google verification code
     *
     */
    fun updatePayment4OTC(
            id: String,
            payment: String,
            userName: String,
            account: String,
            qrcodeImg: String,
            bankName: String,
            bankOfDeposit: String,
            ifscCode: String,
            remittanceInformation: String,
            smsAuthCode: String,
            googleCode: String
    ): Observable<HttpResult<Any>> {
        val map = getBaseMap()
        map["id"] = id
        map["payment"] = payment
        map["userName"] = userName
        map["account"] = account
        map["qrcodeImg"] = qrcodeImg
        map["bankName"] = bankName
        map["bankOfDeposit"] = bankOfDeposit
        map["ifscCode"] = ifscCode
        map["remittanceInformation"] = remittanceInformation
        map["smsAuthCode"] = smsAuthCode
        map["googleCode"] = googleCode
        return apiOTCService.updatePayment4OTC(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Upload photo 4 OTC
     */
    fun uploadImg4OTC(imgBase64: String): Observable<HttpResult<JsonObject>> {
        val map = getBaseMap()
        map["imageData"] = imgBase64
//        val body = RequestBody.create(MediaType.parse("form-data"), JSONObject(DataHandler.encryptParams(map)).toString())

        return apiService.uploadImg4OTC(toRequestBody(DataHandler.encryptParams(map)))
    }


    /**
     *
     *Order Details Data
     *Param sequence order number
     */
    fun getOrderDetail4OTC(sequence: String): Observable<HttpResult<OTCOrderDetailBean>> {
        val map = getBaseMap()
        map["sequence"] = sequence
        return apiOTCService.getOrderDetail4OTC(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *
     *Cancel Order
     *Param sequence order number
     */
    fun cancelOrder4OTC(sequence: String): Observable<HttpResult<Any>> {
        val map = getBaseMap()
        map["sequence"] = sequence
        return apiOTCService.cancelOrder4OTC(toRequestBody(DataHandler.encryptParams(map)))
    }


    /**
     *For sellers
     *Confirm Coining
     *Param sequence order number
     */
    fun confirmOrder2Seller4OTC(sequence: String, capitalPword: String,smsAuthCode: String?=null,googleCode: String?=null): Observable<HttpResult<Any>> {
        val map = getBaseMap()
        map["sequence"] = sequence
        if(capitalPword!=null && !TextUtils.isEmpty(capitalPword)) map["capitalPword"] = capitalPword
        if(smsAuthCode!=null && !TextUtils.isEmpty(smsAuthCode)) map["smsAuthCode"] = smsAuthCode
        if(googleCode!=null && !TextUtils.isEmpty(googleCode)) map["googleCode"] = googleCode
        return apiOTCService.confirmOrder2Seller4OTC(toRequestBody(DataHandler.encryptParams(map)))
    }


    /**
     *For buyers
     *Confirm payment
     *Param sequence order number
     */
    fun confirmPay2Buyer4OTC(sequence: String, payment: String = ""): Observable<HttpResult<Any>> {
        val map = getBaseMap()
        map["sequence"] = sequence
        map["payment"] = payment
        return apiOTCService.confirmPay2Buyer4OTC(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Appeal modification order status
     *Param sequence order number
     *@param complinId Work Order ID
     */
    fun complain2changeOrderState4OTC(sequence: String, complainId: String): Observable<HttpResult<Any>> {
        val map = getBaseMap()
        map["sequence"] = sequence
        map["complainId"] = complainId
        return apiOTCService.complain2changeOrderState4OTC(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Cancel appeal
     *@param sequence Order ID
     */
    fun cancelComplain4OTC(sequence: String): Observable<HttpResult<Any>> {
        val map = getBaseMap()
        map["sequence"] = sequence
        return apiOTCService.cancelComplain4OTC(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Generate Purchase Order (Step 3)
     */
    /**
     *Newly generated purchase order (Step 1)
     *@param advertId Advertising ID
     *@param volume quantity
     *@param price unit price
     *@param totalPrice Total Price
     *@param payment payment method key
     *@param description Order note (optional)
     *@param type based on price or quantity price/volume
     */
    fun buyOrderEnd4OTC(advertId: String,
                        volume: String,
                        price: String,
                        totalPrice: String,
                        description: String = "",
                        type: String
    ): Observable<HttpResult<JsonObject>> {
        val map = getBaseMap()
        map["advertId"] = advertId
        map["volume"] = volume
        map["price"] = price
        map["totalPrice"] = totalPrice
        map["description"] = description
        map["type"] = type
        return apiOTCService.buyOrderEnd4OTC(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Generate sales order (Step 3)
     *@param advertId Advertising ID
     *@param volume quantity
     *@param price unit price
     *@param totalPrice Total Price
     *@param payment payment method key
     *@param description Order note (topic)
     *@param capitalPword Fund Password
     *@param type based on price or quantity price/volume
     */
    fun sellOrderEnd4OTC(advertId: String,
                         volume: String,
                         price: String,
                         totalPrice: String,
                         description: String = "",
                         capitalPword: String,
                         type: String,
                         googleCode: String? = null,
                         smsAuthCode: String? = null
    ): Observable<HttpResult<JsonObject>> {
        val map = getBaseMap()
        map["advertId"] = advertId
        map["volume"] = volume
        map["price"] = price
        map["totalPrice"] = totalPrice
        map["description"] = description
        map["capitalPword"] = capitalPword
        map["type"] = type
        if(googleCode!=null && !TextUtils.isEmpty(googleCode)) map["googleCode"] = googleCode
        if(smsAuthCode!=null && !TextUtils.isEmpty(smsAuthCode)) map["smsAuthCode"] = smsAuthCode
        return apiOTCService.sellOrderEnd4OTC(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Send mobile verification code
     */
    fun sendMobileCode(countryCode: String = "", mobile: String = "", otype: Int, token: String = "")
            : Observable<HttpResult<String>> {
        val map = getBaseMap(false)

        if (TextUtils.isEmpty(token)) {
            map["countryCode"] = countryCode
            map["mobile"] = mobile
        } else {
            map["token"] = token
        }
        map[OPERATION_TYPE] = otype.toString()
        return apiService.sendMobileVerifyCode(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Send email verification code
     */
    fun sendEmailCode(email: String = "", otype: Int, token: String = ""): Observable<HttpResult<String>> {
        val map = getBaseMap(false)
        if (TextUtils.isEmpty(token)) {
            map[EMAIL] = email
        } else {
            map["token"] = token
        }
        map[OPERATION_TYPE] = otype.toString()
        return apiService.sendEmailVerifyCode(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Retrieve Password Step 3
     */
    fun findPwdStep3(token: String, certifcateNumber: String, googleCode: String): Observable<HttpResult<Any>> {
        val map = getBaseMap(false)
        map["token"] = token
        map["certifcateNumber"] = certifcateNumber
        map["googleCode"] = googleCode
        return apiService.findPwdStep3(toRequestBody(DataHandler.encryptParams(map)))
    }


    /**
     *Fingerprint or facial recognition
     */
    fun quickLogin(countryCode: String, mobileNumber: String, loginPword: String): Observable<HttpResult<JsonObject>> {
        val map = getBaseMap(false)
        map["countryCode"] = countryCode
        map["mobileNumber"] = mobileNumber
        map["loginPword"] = loginPword
        return apiService.quickLogin(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Fingerprint or facial recognition
     */
    fun newQuickLogin(quicktoken: String): Observable<HttpResult<JsonObject>> {
        val map = getBaseMap(false)
        map["quicktoken"] = quicktoken
        return apiService.newQuickLogin(toRequestBody(DataHandler.encryptParams(map)))
    }


    /**
     *1 Public interface for contracts
     */
    fun getPublicInfo4Contract(): Observable<HttpResult<ContractPublicInfoBean>> {
        val map = getBaseMap(false)
        return contractService.getPublicInfo4Contract(toRequestBody(DataHandler.encryptParams(map)))
    }


    /**
     *
     *2 Obtain initialization information for creating an order (need login)
     *
     *@param contractId Contract ID
     *@param volume User input quantity (default to 1 if not entered)
     *@param price: The user enters the price (if not entered, the latest transaction price will be used by default. If the latest transaction price is blank, the opening price will be calculated in currency)
     *Param level leverage multiple (required only when selecting leverage)
     *@param orderType 1: Price limit 2: Market price
     *
     */
    fun getInitTakeOrderInfo4Contract(contractId: String,
                                      volume: String = "1",
                                      price: String,
                                      level: String = "",
                                      orderType: Int): Observable<HttpResult<InitTakeOrderBean>> {
        val map = getBaseMap(false)
        map["contractId"] = contractId
        map["volume"] = volume
        map["price"] = price
        if (!TextUtils.isEmpty(level)) {
            map["level"] = level
        }
        map["orderType"] = orderType.toString()
        return contractService.getInitTakeOrderInfo4Contract(toRequestBody(DataHandler.encryptParams(map)))
    }


    /**
     *3 Create Order
     *
     *@param contractId Contract ID
     *@param volume Order quantity
     *Place an order at @param price
     *Param orderType (1: Limit Order 2: Market Order)
     *@param copType (1: full warehouse 2: warehouse by warehouse) This parameter is not passed when closing positions
     *Param side (BUY: Buy Sell: Sell)
     *@param closeType (0: warehouse receipt, 1: closing order)
     *Param level leverage multiple
     *
     */
    fun takeOrder4Contract(contractId: String,
                           volume: String,
                           price: String,
                           orderType: Int,
                           copType: String = "2",
                           side: String,
                           closeType: String = "0",
                           level: String,
                           positionId: String = ""
    ): Observable<HttpResult<Any>> {
        val map = getBaseMap(false)
        map["contractId"] = contractId
        map["volume"] = volume
        map["price"] = price
        map["orderType"] = orderType.toString()
        map["copType"] = copType
        map["side"] = side
        map["closeType"] = closeType
        map["level"] = level
        if (!TextUtils.isEmpty(positionId)) {
            map["positionId"] = positionId
        }
        return contractService.takeOrder4Contract(toRequestBody(DataHandler.encryptParams(map)))
    }


    /**
     *4 Cancel Order
     *@param orderId Order ID
     *@param contractId Contract ID
     */
    @POST("/cancel_order")
    fun cancelOrder4Contract(orderId: String,
                             contractId: String
    ): Observable<HttpResult<Any>> {
        val map = getBaseMap(false)
        map["orderId"] = orderId
        map["contractId"] = contractId
        return contractService.cancelOrder4Contract(toRequestBody(DataHandler.encryptParams(map)))
    }


    /**
     *7 Tag Price (Unneeded Login)
     *@param contractId Contract ID
     */
    fun getTagPrice4Contract(contractId: String): Observable<HttpResult<TagPriceBean>> {
        val map = getBaseMap(false)
        map["contractId"] = contractId
        return contractService.getTagPrice4Contract(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *8 Modify leverage ratio
     */
    fun changeLevel4Contract(contractId: String, newLevel: String): Observable<HttpResult<Any>> {
        val map = getBaseMap(false)
        map["contractId"] = contractId
        map["leverageLevel"] = newLevel
        return contractService.changeLevel4Contract(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *10 User position information:
     *
     *If the contract ID is not filled in and queried, it is a warehouse list
     *5s refresh
     */
    fun getPosition4Contract(contractId: String = ""): Observable<HttpResult<UserPositionBean>> {
        val map = getBaseMap(false)
        map["contractId"] = contractId
        return contractService.getPosition4Contract(toRequestBody(DataHandler.encryptParams(map)))
    }


    /**
     *12 Fund transfer:
     *
     *@param from Type Transfer out account type
     *@param toType transferred to account type
     *@param amount Transfer amount
     *@param bond guarantee gold coins
     *
     */

    /**
     *15. Risk Assessment (Need Login)
     */
    fun getRiskLiquidationRate(contractId: String = ""): Observable<HttpResult<LiquidationRateBean>> {
        val map = getBaseMap(false)
        map["contractId"] = contractId
        return contractService.getRiskLiquidationRate(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *16. Contract Fund Flow (Need Login)
     *
     *@param item flow type
     *@param childItem child flow type
     *@param startTime
     *@param endTime End Time
     *@param page number of pages
     *@param pageSize How many items per page
     *
     */
    fun getBusinessTransferList(item: String = "", childItem: String = "", startTime: String = "", endTime: String = "", page: Int = 1, pageSize: Int = 1000): Observable<HttpResult<ContractCashFlowBean>> {
        val map = getBaseMap(false)
        map["item"] = item
        map["childItem"] = childItem
        map["startTimeMillis"] = startTime
        map["endTimeMillis"] = endTime
        map["page"] = page.toString()
        map["pageSize"] = pageSize.toString()
        return contractService.getBusinessTransferList(toRequestBody(DataHandler.encryptParams(map)))
    }

    /********Contract END********/


    //Check for updates
    fun checkVersion(time: String): Observable<HttpResult<VersionData>> {
        return apiService.checkVersion(time)
    }

    //Feedback
    fun feedback(rqDescribe: String, imageData: String): Observable<HttpResult<String>> {
        val map = getBaseMap()
        map.put("rqDescribe", rqDescribe)
        DataHandler.encryptParams(map)
        if (!TextUtils.isEmpty(imageData)) {
            map["imageData"] = imageData
        }
        return apiService.feedback(map)
    }


    /**
     *Initialize OKHttpClient, set cache, set timeout, print logs, and set UA interceptor
     */
    private fun initOkHttpClient() {



        if (mOkHttpClient == null) {

            val cache = Cache(File(ChainUpApp.appContext.cacheDir, "HttpCache"), (1024 * 1024 * 10).toLong())
            var builder = OkHttpClient.Builder()
                    .protocols(Collections.singletonList(Protocol.HTTP_1_1))
                    .cache(cache)
                    .addInterceptor(NetInterceptor())
                    .addNetworkInterceptor(CacheInterceptor())
                    .retryOnConnectionFailure(true)
                    .connectTimeout(60, TimeUnit.SECONDS)
                    .writeTimeout(60, TimeUnit.SECONDS)
                    .readTimeout(60, TimeUnit.SECONDS)
            if(BuildConfig.DEBUG){
                val interceptor = HttpLoggingInterceptor()
                interceptor.level = HttpLoggingInterceptor.Level.BODY
                builder.addInterceptor(interceptor)
            }
            var array = arrayOf(ChainUpApp.appContext.resources.assets.open("cert.cer"))
            val sslParams = HttpsUtils.getSslSocketFactory(array, null, null)
            if (null != sslParams) {
                builder.sslSocketFactory(sslParams.sSLSocketFactory, sslParams.trustManager)
            }
            mOkHttpClient = builder.build()
        }
    }

    fun refresh() {
        mOkHttpClient = OkHttpClient.Builder()
                .protocols(Collections.singletonList(Protocol.HTTP_1_1))
                .addInterceptor(NetInterceptor())
                .addNetworkInterceptor(CacheInterceptor())
                .retryOnConnectionFailure(true)
                .connectTimeout(60, TimeUnit.SECONDS)
                .writeTimeout(60, TimeUnit.SECONDS)
                .readTimeout(60, TimeUnit.SECONDS)
                .build()
    }

    /**
     *Add caching for okhttp, considering that the server does not support caching, in order to enable okhttp to support caching
     */
    private inner class CacheInterceptor : Interceptor {
        @Throws(IOException::class)
        override fun intercept(chain: Interceptor.Chain): Response {
            //Set cache timeout of 1 hour when there is a network
            val maxAge = 60 * 60
            //When there is no network, set the timeout to 1 day
            val maxStale = 60 * 60 * 24
            var request = chain.request()
            request = if (NetworkUtils.isNetworkAvailable(ChainUpApp.appContext)) {
                //Only obtain from the network when there is one
                request.newBuilder().cacheControl(CacheControl.FORCE_NETWORK).build()
            } else {
                //Only read from cache when there is no network
                request.newBuilder().cacheControl(CacheControl.FORCE_CACHE).build()
            }


            var response = chain.proceed(request)
            response = if (NetworkUtils.isNetworkAvailable(ChainUpApp.appContext)) {
                response.newBuilder()
                        .removeHeader("Pragma")
                        .header("Cache-Control", "public, max-age=" + maxAge)
                        .build()
            } else {
                response.newBuilder()
                        .removeHeader("Pragma")
                        .header("Cache-Control", "public, only-if-cached, max-stale=" + maxStale)
                        .build()
            }
            return response
        }
    }


    //Add header
    /*private inner class HeaderInterceptor : Interceptor {

        override fun intercept(chain: Interceptor.Chain): Response {

            var originalRequest: Request

            val packageManager = ChainUpApp.appContext.packageManager
            val packInfo = packageManager.getPackageInfo(ChainUpApp.appContext.packageName, 0)
            if (UserDataService.getInstance().isLogined) {
                if (token == null) {
                    token = UserDataService.getInstance().token
                }

                originalRequest = chain.request()
                        .newBuilder()
                        .header("Content-Type", "application/json;charset=utf-8")
                        .header("Build-CU", packInfo.versionCode.toString())
                        .header("SysVersion-CU", SystemUtils.getSystemVersion())
                        .header("SysSDK-CU", Build.VERSION.SDK_INT.toString())
                        .header("Channel-CU", "")
                        .header("Mobile-Model-CU", SystemUtils.getSystemModel())
                        .header("UUID-CU:APP", Settings.System.getString(ChainUpApp.appContext.contentResolver, Settings.System.ANDROID_ID)
                                ?: "")
                        .header("Platform-CU", "android")
                        .header("Network-CU", NetworkUtils.getNetType())
                        .header("exchange-language", NLanguageUtil.getLanguage())
                        .header("exchange-token", token)
                        .header("exchange-client", "app")
                        .build()
            } else {
                originalRequest = chain.request()
                        .newBuilder()
                        .header("Content-Type", "application/json;charset=utf-8")
                        .header("Build-CU", packInfo.versionCode.toString())
                        .header("SysVersion-CU", SystemUtils.getSystemVersion())
                        .header("SysSDK-CU", Build.VERSION.SDK_INT.toString())
                        .header("Channel-CU", "")
                        .header("Mobile-Model-CU", SystemUtils.getSystemModel())
                        .header("UUID-CU:APP", Settings.System.getString(ChainUpApp.appContext.contentResolver, Settings.System.ANDROID_ID)
                                ?: "")
                        .header("Platform-CU", "android")
                        .header("Network-CU", NetworkUtils.getNetType())
                        .header("exchange-language", NLanguageUtil.getLanguage())
                        .header("exchange-client", "app")
                        .build()
            }

            return chain.proceed(originalRequest)
        }
    }*/


    /**
     *Get Pictures
     */
    fun getImageToken(operate_type: String = "1"): Observable<HttpResult<ImageTokenBean>> {
        val map = getBaseMap(false)
        map["operate_type"] = operate_type
        return apiService.getImageToken(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Real name authentication interface
     */
    fun AccountCertification(): Observable<HttpResult<AccountCertificationBean>> {
        val map = getBaseMap(false)
        return apiService.AccountCertification(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Real name authentication
     */
    fun AccountCertificationLanguage(): Observable<HttpResult<AccountCertificationLanguageBean>> {
        val map = getBaseMap(false)
        return apiService.AccountCertificationLanguage(toRequestBody(DataHandler.encryptParams(map)))
    }


    /**
     *List of on-site fund flow scenarios
     */
    fun getCashFlowScene(): Observable<HttpResult<CashFlowSceneBean>> {
        val map = getBaseMap()
        return apiService.getCashFlowScene(toRequestBody(DataHandler.encryptParams(map)))
    }


    /**
     *Capital flow list
     *@param coinSymbol Currency Type
     * @param pageSize default 10
     * @param page  default 1
     *@param transactionScene Stream Type
     * @param startTime
     * @param endTime
     */
    fun getCashFlowList(symbol: String,
                        transactionScene: String = "1",
                        startTime: String = "",
                        endTime: String = "",
                        pageSize: String = "100",
                        page: String = "1"
    ): Observable<HttpResult<CashFlowBean>> {
        val map = getBaseMap()
        map["coinSymbol"] = symbol
        map["transactionScene"] = transactionScene
        map["startTimeMillis"] = startTime
        map["endTimeMillis"] = endTime
        map["pageSize"] = pageSize
        map["page"] = page
        return apiService.getCashFlowList(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Withdrawal withdrawal
     */
    fun cancelWithdraw(withdrawId: String): Observable<HttpResult<Any>> {
        val map = getBaseMap()
        map["withdrawId"] = withdrawId
        return apiService.cancelWithdraw(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Display of basic user information on personal homepage
     */
    fun getPerson4otc(uid: String): Observable<HttpResult<UserInfo4OTC>> {
        val map = getBaseMap()
        map["uid"] = uid
        return apiOTCService.getPerson4otc(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Display of basic user information on personal homepage
     */
    fun getPersonAds(uid: String, pageSize: String = "20", page: String = "1", adType: String = ""): Observable<HttpResult<PersonAdsBean>> {
        val map = getBaseMap()
        map["uid"] = uid
        map["pageSize"] = pageSize
        map["page"] = page
        map["adType"] = adType
        return apiOTCService.getPersonAds(toRequestBody(DataHandler.encryptParams(map)))
    }


    /**
     *Obtain the number of unread information for the current user
     */
    fun getReadMessageCount(): Observable<HttpResult<ReadMessageCountBean>> {
        val map = getBaseMap()
        return apiService.getReadMessageCount(toRequestBody(DataHandler.encryptParams(map)))
    }


    /**
     *Obtain Personal Center Vice Banner
     */
    fun getPcBanner(): Observable<HttpResult<PcBannerBean>> {
        val map = getBaseMap()
        //userId
        if(!"".equals(UserDataService.getInstance().userInfo4UserId)){
            map["userId"] = UserDataService.getInstance().userInfo4UserId
        }
        return apiService.getPcBanner(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Rate discount switch status
     */
    fun updatePcTradeFeeStatus(status: String): Observable<HttpResult<Any>> {
        val map = getBaseMap()
        map["status"] = status
        return apiService.updatePcTradeFeeStatus(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Update and view all internal messages
     */
    fun updateMessageStatus(): Observable<HttpResult<Any>> {
        val map = getBaseMap()
        map["id"] = "0"
        return apiService.updateMessageStatus(toRequestBody(DataHandler.encryptParams(map)))
    }


    /**
     *Get blacklist
     *@param relationType default blacklist for friend relationships
     * @param pageSize
     * @param page
     */
    fun getRelationShip(relationType: String = "BLACKLIST", pageSize: Int = 10000, page: Int = 1): Observable<HttpResult<BlackListData>> {
        val map = getBaseMap()
        map["relationType"] = relationType
        map["pageSize"] = pageSize.toString()
        map["page"] = page.toString()
        return apiOTCService.getRelationShip4OTC(toRequestBody(DataHandler.encryptParams(map)))
    }


    /**
     *Red envelope============================================================
     */


    /**
     *Initial information on red envelopes
     */
    fun redPackageInitInfo(): Observable<HttpResult<RedPackageInitInfo>> {
        val map = getBaseMap()
        return redPackageService.redPackageInitInfo(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Create a red envelope
     *@param type 0. Ordinary red envelope 1. Spelling luck red envelope
     *@param coinSymbol Red envelope currency
     *@param amount Red envelope limit
     *@param count Red Packet Quantity
     *@param tip Red envelope blessings
     *@param onlyNew 1. Only for new users 0. No restrictions
     *
     */
    fun createRedPackage(type: Int = 0, coinSymbol: String, amount: String, count: String, tip: String, onlyNew: Int): Observable<HttpResult<CreatePackageBean>> {
        val map = getBaseMap()
        map["type"] = type.toString()
        map["coinSymbol"] = coinSymbol
        map["amount"] = amount
        map["tip"] = tip
        map["count"] = count
        map["onlyNew"] = onlyNew.toString()
        return redPackageService.createRedPackage(toRequestBody(DataHandler.encryptParams(map)))
    }


    /**
     *Payment of red envelopes
     *@param order number
     */
    fun pay4redPackage(orderNum: String, googleCode: String, smsAuthCode: String): Observable<HttpResult<Any>> {
        val map = getBaseMap()
        map["orderNum"] = orderNum
        map["googleCode"] = googleCode
        map["smsAuthCode"] = smsAuthCode
        return redPackageService.pay4redPackage(toRequestBody(DataHandler.encryptParams(map)))
    }


    /**
     *Statistical information on red packets sent by users
     */
    fun getGrantRedPackageInfo(): Observable<HttpResult<GrantRedPackageInfo>> {
        val map = getBaseMap()
        return redPackageService.getGrantRedPackageInfo(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *List of red envelopes sent by users
     */
    fun grantRedPackageList(pageNum: Int = 1, pageSize: Int = 10): Observable<HttpResult<GrantRedPackageListBean>> {
        val map = getBaseMap()
        map["pageNum"] = pageNum.toString()
        map["pageSize"] = pageSize.toString()
        return redPackageService.grantRedPackageList(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Details of red envelopes sent/received by users
     *@param packetSn red packet number
     */
    fun getRedPackageDetail(packetSn: String): Observable<HttpResult<RedPackageDetailBean>> {
        val map = getBaseMap()
        map["packetSn"] = packetSn
        return redPackageService.getRedPackageDetail(toRequestBody(DataHandler.encryptParams(map)))
    }


    /**
     *Statistical information of users receiving red envelopes
     */
    fun getReceiveRedPackageInfo(): Observable<HttpResult<ReceiveRedPackageInfoBean>> {
        val map = getBaseMap()
        return redPackageService.getReceiveRedPackageInfo(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Set fund password
     */
    fun capitalPassword4OTC(capitalPwd: String, smsAuthCode: String, emailAuthCode:String,googleCode: String): Observable<HttpResult<Any>> {
        val map = getBaseMap()
        map["capitalPwd"] = capitalPwd
        if (!TextUtils.isEmpty(smsAuthCode))
            map["smsAuthCode"] = smsAuthCode
        if (!TextUtils.isEmpty(googleCode))
            map["googleCode"] = googleCode
        if (!TextUtils.isEmpty(emailAuthCode))
            map["emailAuthCode"] = emailAuthCode
        return apiOTCService.capitalPassword4OTC(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     * Reset Fund pwd
     */
    fun capitalPasswordReset4OTC(oldCapitalPwd: String?,newCapitalPwd: String,checkOldFlag:String="1",smsAuthCode: String, googleCode: String,emailCode:String): Observable<HttpResult<Any>> {
        val map = getBaseMap()
        if(oldCapitalPwd!=null && !TextUtils.isEmpty(oldCapitalPwd)){
            map["capitalPwd"] = oldCapitalPwd
        }
        map["newCapitalPwd"] = newCapitalPwd
        map["checkOldFlag"] = checkOldFlag
        if (!TextUtils.isEmpty(smsAuthCode))
            map["smsAuthCode"] = smsAuthCode
        if (!TextUtils.isEmpty(googleCode))
            map["googleCode"] = googleCode
        if (!TextUtils.isEmpty(emailCode))
            map["emailAuthCode"] = emailCode

        return apiOTCService.capitalPasswordReset4OTC(toRequestBody(DataHandler.encryptParams(map)))
    }

    fun capitalPasswordUnBind(smsAuthCode: String, googleCode: String,emailAuthCode:String): Observable<HttpResult<Any>> {
        val map = getBaseMap()
        if (!TextUtils.isEmpty(smsAuthCode))
            map["smsAuthCode"] = smsAuthCode
        if (!TextUtils.isEmpty(googleCode))
            map["googleCode"] = googleCode
        if (!TextUtils.isEmpty(emailAuthCode))
            map["emailAuthCode"] = emailAuthCode
        return apiOTCService.capitalPasswordUnbind(toRequestBody(DataHandler.encryptParams(map)))
    }

    fun capitalPasswordForget(smsAuthCode: String, googleCode: String,emailAuthCode:String): Observable<HttpResult<Any>> {
        val map = getBaseMap()
        if (!TextUtils.isEmpty(smsAuthCode))
            map["smsAuthCode"] = smsAuthCode
        if (!TextUtils.isEmpty(googleCode))
            map["googleCode"] = googleCode
        if (!TextUtils.isEmpty(emailAuthCode))
            map["emailAuthCode"] = emailAuthCode
        return apiOTCService.capitalPasswordForget(toRequestBody(DataHandler.encryptParams(map)))
    }


    /**
     *User Received Red Packet List
     */
    fun receiveRedPackageList(pageNum: Int = 1, pageSize: Int = 10): Observable<HttpResult<ReceiveRedPackageListBean>> {
        val map = getBaseMap()
        map["pageNum"] = pageNum.toString()
        map["pageSize"] = pageSize.toString()
        return redPackageService.receiveRedPackageList(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Obtain backend update currency version number
     */
    fun getInvitationImg(): Observable<HttpResult<InvitationImgBean>> {
        val map = getBaseMap()
        return apiService.getInvitationImg(toRequestBody(DataHandler.encryptParams(map)))
    }


    /**
     *Game Authorization
     */
    fun getGameAuth(gameId: String, gameToken: String): Observable<HttpResult<Any>> {
        val map = getBaseMap()
        map["gameId"] = gameId
        map["token"] = gameToken
        return apiService.getGameAuth(toRequestBody(DataHandler.encryptParams(map)))
    }


//    /**
//     *Contract app asset information
//     */
//    fun doAcocuntNormal(coinSymbol: String, amount: String, transferType: String): Observable<HttpResult<Any>> {
//        val map = getBaseMap()
//        map["coin"] = coinSymbol
//        return contractService.doAcocuntNormal(toRequestBody(DataHandler.encryptParams(map)))
//    }
    /**
     *About us
     */
    fun getPushSettings(): Observable<HttpResult<PushItem>> {
        val map = getBaseMap()
        return apiService.getPush(DataHandler.encryptParams(map))
    }

    fun bindToken(clientID: String): Observable<HttpResult<Any>> {
        val map = getBaseMap()
        map["cid"] = clientID
        return apiService.bindToken(toRequestBody(DataHandler.encryptParams(map)))
    }

    fun savePushType(pushType: String): Observable<HttpResult<Any>> {
        val map = getBaseMap()
        map["type"] = pushType
        return apiService.saveAppPushU(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Upload photos
     */
    fun uploadZip(name: File): Observable<HttpResult<Any>> {
        return apiService.uploadZip(toRequestFileBody(name))
    }

    private fun toRequestFileBody(file: File): MultipartBody.Part {
        val type = MultipartBody.FORM
        val requestFile = RequestBody.create(type, file)
        val filePart = MultipartBody.Part.createFormData("file", file.getName(), requestFile)
        return filePart
    }

    /**
     *Upload photos
     */
    fun getCoinDepth(symbol: String, contractId: String): Observable<HttpResult<DepthItem>> {
        val map = getBaseMap()
        map["symbol"] = symbol
        if (TextUtils.isEmpty(contractId)) {
            return apiService.getCoinDepth(toRequestBody(DataHandler.encryptParams(map)))
        } else {
            map["contractId"] = contractId
            return newContractService.getCoinDepth(toRequestBody(DataHandler.encryptParams(map)))
        }
    }


    fun changeNetwork(serverUrl: String, isWs: Boolean = false) {
        if (isWs) {
            PublicInfoDataService.getInstance().saveNewWorkWSURL(serverUrl)
            WsAgentManager.instance.stopWs(NetUrl.getsocketAddress(), true)
//            ContractSDKAgent.httpConfig?.let {
//                it.contractUrl = NetUrl.getcontractUrl() + "fe-cov2-api/swap/"
//                it.reConfigWsUrl(NetUrl.getContractSocketUrl())
//            }
        } else {
            PublicInfoDataService.getInstance().saveNewWorkURL(serverUrl)
            HttpHelper.instance.clearServiceMap()
            refreshApi()
        }
    }


    //Check for updates
    fun checkNetworkLine(serverUrl: String): Observable<ResponseBody> {
        val map = getBaseMap()
        return HttpHelper.instance.getspeedUrlService(serverUrl, SpeedApiService::class.java).getHealth(DataHandler.encryptParams(map))
    }

    //Network reporting
    fun uploadNetWorkLog(oldLine: String, newLine: String, network_line_json: String): Observable<ResponseBody> {
        val map = getBaseMap()
        map["oldLine"] = oldLine
        map["newLine"] = newLine
        map["network_line_json"] = network_line_json
        return apiService.uploadAppNetwork(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Upload photos
     */
    fun getHomeAdvert(): Observable<HttpResult<AdvertModel>> {
        val map = getBaseMap()
        map["terminalType"] = "1"
        return apiService.getHomeAdvert(toRequestBody(DataHandler.encryptParams(map)))
    }

    //Network information reporting
    fun uploadNetWorkInfoLog(line: String, errorType: Int = 0, page: String, action: String, duration: Long?): Observable<ResponseBody> {
        val map = getBaseMap()
        map["line"] = line
        map["errorType"] = errorType.toString()
        if (errorType == 0) {
            map["duration"] = duration.toString() ?: "0"
        }
        map["page"] = page
        map["action"] = action
        return apiService.uploadAppNetworkInfo(toRequestBody(DataHandler.encryptParams(map)))
    }


    /**
     *Request for FreeStaking homepage
     */
    fun getFreeStakingData(): Observable<HttpResult<FreeStakingBean>> {
        val map = getBaseMap()
        return apiService.getFreeStakingData(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *FreeStaking homepage project list
     */
    fun getFreeStakingList(): Observable<HttpResult<java.util.ArrayList<CurrencyBean>>> {
        val map = getBaseMap()
        return apiService.getFreeStakingList(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *FreeStaking Project Details
     */
    fun getProjectDetail(itemId: String): Observable<HttpResult<FreeStakingDetailBean>> {
        val map = getBaseMap()
        map["id"] = itemId
        return apiService.getProjectDetail(toRequestBody(DataHandler.encryptParams(map)))


    }

    /**
     *My PoS Record - Open PoS
     */
    fun getMyPosRecord(page: Int, pageSize: Int, projectType: Int, baseCoin: String = "", strTime: String = "", entTime: String = ""): Observable<HttpResult<MyPosRecordBean>> {
        val map = getBaseMap()
        map["page"] = page.toString()
        map["pageSize"] = pageSize.toString()
        map["projectType"] = projectType.toString()
        map["baseCoin"] = baseCoin
        map["strTimeMillis"] = strTime
        map["entTimeMillis"] = entTime
        return apiService.getMyPosRecord(toRequestBody(DataHandler.encryptParams(map)))

    }

    /**
     *FreeStaking project subscription
     */
    fun requestToBuy(amount: String, projectId: Int): Observable<HttpResult<Any>> {
        val map = getBaseMap()
        map["amount"] = amount
        map["projectId"] = projectId.toString()
        return apiService.requestToBuy(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Obtain contract broker invitation configuration
     */
    fun getInviteConfig(): Observable<HttpResult<AgentBean>> {
        val map = getBaseMap()
        return apiService.getInviteConfig(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Obtain contract broker invitation configuration
     */
    fun getAgentUser(): Observable<HttpResult<AgentUserBean>> {
        val map = getBaseMap()
        return apiService.getAgentUser(toRequestBody(DataHandler.encryptParams(map)))
    }

    /**
     *Obtain contract broker invitation configuration
     */
    fun getAgentInfo(): Observable<HttpResult<AgentInfoBean>> {
        val map = getBaseMap()
        return apiService.getAgentInfo(toRequestBody(DataHandler.encryptParams(map)))
    }

    fun getCoAgentInfo(): Observable<HttpResult<CoAgentInfoBean>> {
        val map = getBaseMap()
        return apiService.getCoAgentInfo(toRequestBody(DataHandler.encryptParams(map)))
    }

    fun getPCLoginInfo(qrMsg: String): Observable<HttpResult<QRInfo>> {
        val map = getBaseMap()
        map["qrcodeId"] = qrMsg
        return apiService.getPCLoginInfo(toRequestBody(DataHandler.encryptParams(map)))
    }


    fun getPcLogin(qrMsg: String): Observable<HttpResult<Any>> {
        val map = getBaseMap()
        map["qrcodeId"] = qrMsg
        return apiService.getPcLogin(toRequestBody(DataHandler.encryptParams(map)))
    }


    fun withdrawWhiteListSwitch(smsAuthCode: String?,googleCode:String?,emailAuthCode:String?,status:String): Observable<HttpResult<Any>> {
        val map = getBaseMap()
        if(!"".equals(smsAuthCode) && smsAuthCode!=null) map["smsAuthCode"] = smsAuthCode
        if(!"".equals(googleCode) && googleCode!=null) map["googleCode"] = googleCode
        if(!"".equals(emailAuthCode) && emailAuthCode!=null) map["emailAuthCode"] = emailAuthCode
        map["flag"] = status
        return apiOTCService.withdrawWhiteListSwitch(toRequestBody(DataHandler.encryptParams(map)))
    }


    fun addInvitationedCode(invitedCode: String): Observable<HttpResult<Any>> {
        val map = getBaseMap()
        map["invitedCode"] = invitedCode
        return apiService.addInvitationedCode(toRequestBody(DataHandler.encryptParams(map)))
    }

    fun getInvitationPublicConfig(): Observable<HttpResult<InviteConfig>> {
        val map = getBaseMap()
        return apiService.getInvitationPublicConfig(toRequestBody(DataHandler.encryptParams(map)))
    }

    fun getMyInvitations(page: Int = 1, pageSize: Int = 20): Observable<HttpResult<InvitationsList>> {
        val map = getBaseMap()
        map["page"] = page.toString()
        map["pageSize"] = pageSize.toString()
        return apiService.getMyInvitations(toRequestBody(DataHandler.encryptParams(map)))
    }

    fun getMyInvitationsRewards(page: Int = 1, pageSize: Int = 20): Observable<HttpResult<InvitationsList>> {
        val map = getBaseMap()
        map["page"] = page.toString()
        map["pageSize"] = pageSize.toString()
        return apiService.getMyInvitationsRewards(toRequestBody(DataHandler.encryptParams(map)))
    }

    fun commonSwitch(): Observable<HttpResult<SwitchVoBean>> {
        val map = getBaseMap()
        return apiService.commonSwitch(DataHandler.encryptParams(map))
    }
}
