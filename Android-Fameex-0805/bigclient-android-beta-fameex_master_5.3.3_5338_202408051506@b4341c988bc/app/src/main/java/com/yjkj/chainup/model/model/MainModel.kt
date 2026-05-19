package com.yjkj.chainup.model.model

import android.text.TextUtils
import com.yjkj.chainup.app.AppConstant
import com.yjkj.chainup.bean.EquityBean
import com.yjkj.chainup.bean.KycAuthBean
import com.yjkj.chainup.common.Constants.isGoogleVersion
import com.yjkj.chainup.bean.TartCaptchaV2Bean
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.model.api.ContractApiService
import com.yjkj.chainup.model.api.MainApiService
import com.yjkj.chainup.model.datamanager.BaseDataManager
import com.yjkj.chainup.net.DataHandler
import com.yjkj.chainup.net.HttpClient.Companion.LOGIN_PWORD
import com.yjkj.chainup.net.HttpClient.Companion.MOBILE_NUMBER
import com.yjkj.chainup.net.HttpClient.Companion.VERIFICATION_TYPE
import com.yjkj.chainup.net.api.HttpResult
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.util.StringUtil
import com.yjkj.chainup.util.StringUtils
import com.yjkj.chainup.util.verfitionTypeCheck
import io.reactivex.Observable
import io.reactivex.Single
import io.reactivex.disposables.Disposable
import io.reactivex.observers.DisposableObserver
import okhttp3.ResponseBody
import org.json.JSONObject
import java.math.BigDecimal

/**
 *

 * @Description:

 * @Author:         wanghao

 * @CreateDate:     2019-08-28 16:51

 * @UpdateUser:     wanghao

 * @UpdateDate 2023-08-28 16:51

 *@ UpdateRemark: Update Description

 */
class MainModel : BaseDataManager() {

    val TAG = "MainModel"


    fun limit_ip_login(consumer: DisposableObserver<ResponseBody>): Disposable? {

        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).limit_ip_login(getBaseReqBody()), consumer)
    }


    /**
     *Obtain user information
     * @return Observable
     */
    fun getUserInfoObservable(): Observable<HttpResult<Map<String,Any>>> {
        return httpHelper.getBaseUrlService(MainApiService::class.java).user_info_entity(getBaseReqBody())
    }

    /**
     *Get public_ Info_ V4
     * @param consumer
     * @return
     */
    fun public_info_v4(consumer: DisposableObserver<ResponseBody>): Disposable? {

        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).public_info_v4(getBaseReqBody()), consumer)
    }


    /**
     *13 Account balance:
     */
    fun account_balance(consumer: DisposableObserver<ResponseBody>): Disposable? {

        return changeIOToMainThread(httpHelper.getContractUrlService(ContractApiService::class.java).getAccountBalance4Contract1(getBaseReqBody()), consumer)
    }

    /**
     *Trading account
     */
    fun accountBalance(consumer: DisposableObserver<ResponseBody>): Disposable? {

        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).accountBalance(getBaseReqBody()), consumer)
    }

    /**
     *Get popular currencies
     */
    fun getHotcoin(consumer: DisposableObserver<ResponseBody>): Disposable? {

        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getHotcoin(getBaseReqBody()), consumer)
    }

    /**
     *13 Account balance:
     */
    fun getAccountBalance4Contract(consumer: DisposableObserver<ResponseBody>): Disposable? {

        return changeIOToMainThread(httpHelper.getContractUrlService(ContractApiService::class.java).getAccountBalance4Contract1(getBaseReqBody()), consumer)
    }

    /**
     *New homepage header currency vs. 24-hour market
     */
    fun header_symbol(consumer: DisposableObserver<ResponseBody>): Disposable? {
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).header_symbol(getBaseMaps()), consumer)
    }

    /**
     *New homepage
     */
    fun common_index(consumer: DisposableObserver<ResponseBody>): Disposable? {
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).common_index(getBaseReqBody()), consumer)
    }

    /**
     *My funds
     */
    fun otc_account_list(consumer: DisposableObserver<ResponseBody>): Disposable? {
        return changeIOToMainThread(httpHelper.getOtcBaseUrlService(MainApiService::class.java).otc_account_list(getBaseReqBody()), consumer)
    }

    /**
     *New homepage price list and trading volume list
     *
     *Type: rasing: Rising chart falling: Falling chart final: Trading volume chart
     */
    fun trade_list_v4(type: String?, consumer: DisposableObserver<ResponseBody>): Disposable? {
        var params = getBaseMaps()//HttpParams.getInstance(1).build()
        if (null != type) {
            params["type"] = type
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).trade_list_v4(getBaseReqBody(params)), consumer)
    }


    /**********Spot trading START*******************/
    /**
     *1. Create an order (in stock)
     *@param side buying and selling direction BUY, SELL
     *@param type: order type, 1: limit order, 2: market order
     *@param volume type=1: represents the number of transactions, type=2: represents the total price when buying, and represents the total number of transactions when selling
     *@param price commission unit price: type=2: This parameter is not required
     *@param symbol market marker, ethbtc
     *Is @param isLever a lever
     */
    fun createOrder(side: String, type: Int, volume: String,
                    price: String, symbol: String, isLever: Boolean = false, consumer: DisposableObserver<ResponseBody>): Disposable? {

        val hashMap = getBaseMaps().apply {
            this["side"] = side
            this["type"] = type.toString()
            this["volume"] = volume
            if (type == 2)
                this["price"] = ""
            else
                this["price"] = price
            this["symbol"] = symbol
        }
        val mainApiService = httpHelper.getBaseUrlService(MainApiService::class.java)
        return if (isLever) {
            changeIOToMainThread(mainApiService.createOrder4Lever(getBaseReqBody(hashMap)), consumer)
        } else {
            changeIOToMainThread(mainApiService.createOrder(getBaseReqBody(hashMap)), consumer)
        }
    }


    /**
     *2. Cancel order (in stock)
     *Is @param isLever a lever
     */
    fun cancelOrder(order_id: String, symbol: String, isLever: Boolean = false, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val hashMap = getBaseMaps().apply {
            this["orderId"] = order_id
            this["symbol"] = symbol
        }
        val mainApiService = httpHelper.getBaseUrlService(MainApiService::class.java)
        return if (isLever) {
            changeIOToMainThread(mainApiService.cancelOrder4Lever(getBaseReqBody(hashMap)), consumer)
        } else {
            changeIOToMainThread(mainApiService.cancelOrder(getBaseReqBody(hashMap)), consumer)
        }
    }


    /**
     *3. Obtain current commission (spot)
     */
    fun getNewEntrust(symbol: String,type:String="",side:String="", isLever: Boolean = false, isOnly20: Boolean = true, consumer: DisposableObserver<ResponseBody>): Disposable? {
        if (!UserDataService.getInstance().isLogined) return null
        val hashMap = getBaseMaps().apply {
            this["symbol"] = symbol
            this["page"] = "1"
            this["pageSize"] = if (isOnly20) "50" else "200"
            this["type"] = type
            this["side"] = side
        }
        val mainApiService = httpHelper.getBaseUrlService(MainApiService::class.java)
        return if (isLever) {
            changeIOToMainThread(mainApiService.newOrders4Lever(getBaseReqBody(hashMap)), consumer)
        } else {
            changeIOToMainThread(mainApiService.getNewEntrust(getBaseReqBody(hashMap)), consumer)
        }
    }


    /**
     *4. Obtain historical commission (spot)
     * @param symbol
     * @param pageSize default 10
     * @param page  default 1
     *Does @param isShowCanceled display cancelled orders? 0 indicates no display, 1 indicates display, default to 1
     *@param side order buying and selling direction, BUY buy sell, do not transfer all
     *@param type Delegate type: 1 limit, 2 market, do not pass all
     *@param startTime, month, day, year, year. Input of hours, minutes, and seconds is prohibited: April 22, 2019
     *@param endTime, month, day, year, year. Input of hours, minutes, and seconds is prohibited: April 22, 2019
     */
    fun getHistoryEntrust4(symbol: String,
                           pageSize: String = "10",
                           page: String = "1",
                           isShowCanceled: String = "1",
                           side: String = "",
                           type: String = "",
                           statusType: String = "",
                           isLever: Boolean = false,
                           consumer: DisposableObserver<ResponseBody>): Disposable? {
        val hashMap = getBaseMaps().apply {
            this["symbol"] = symbol
            this["pageSize"] = pageSize
            this["page"] = page
            this["isShowCanceled"] = isShowCanceled
            this["side"] = side
            this["type"] = type
            this["status"] = statusType
        }
        val mainApiService = httpHelper.getBaseUrlService(MainApiService::class.java)
        return if (isLever) {
            changeIOToMainThread(mainApiService.historyOrders4Lever(getBaseReqBody(hashMap)), consumer)
        } else {
            changeIOToMainThread(mainApiService.getHistoryEntrust4(getBaseReqBody(hashMap)), consumer)
        }
    }


    /**
     *Obtaining Historical Commissions
     *@param entrustment 1: current entrustment, 2: historical entrustment
     *Param side BUY: buy, Sell: sell
     *@param symbol currency pair
     *@param orderType Order Type 1: Regular Order, 2: Leveraged Order
     *@param status Order status: 1 New order, 2 Completed, 3 Partial transactions, 4 Cancelled, 5 Pending cancellation, 6 Abnormal orders
     *@param isShowCanceled 0: Do not display cancelled orders, default to displaying cancelled orders for others
     *@param quote is located in the trading area (USDT...)
     *@param page pagination
     *@param pageSize Page size
     */
    fun getNewEntrustSearch(side: String = "", symbol: String = "",
                            isShowCanceled: String = "1", statusType: Int = 0, type: String = "", page: String = "1",
                            pageSize: String = "100", isLever: Boolean = false, entrust: String = "2", consumer: DisposableObserver<ResponseBody>): Disposable? {

        val map = getBaseMaps().apply {
            this["entrust"] = entrust
            this["side"] = side
            this["symbol"] = symbol
            this["orderType"] = if (isLever) "2" else "1"
            this["isShowCanceled"] = isShowCanceled
            if (type != "0") {
                this["type"] = type
            }
            this["page"] = page
            this["pageSize"] = pageSize
            if (statusType != 0) {
                this["status"] = when (statusType) {
                    1 -> "2"
                    else -> "4"
                }
            }
        }

        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getNewEntrustSearch(getBaseReqBody(map)), consumer)
    }

    /**
     *Obtaining Historical Commissions
     *@param entrustment 1: current entrustment, 2: historical entrustment
     *Param side BUY: buy, Sell: sell
     *@param symbol currency pair
     *@param orderType Order Type 1: Regular Order, 2: Leveraged Order
     *@param status Order status: 1 New order, 2 Completed, 3 Partial transactions, 4 Cancelled, 5 Pending cancellation, 6 Abnormal orders
     *@param isShowCanceled 0: Do not display cancelled orders, default to displaying cancelled orders for others
     *@param quote is located in the trading area (USDT...)
     *@param page pagination
     *@param pageSize Page size
     */
    fun getNewCurrentEntrustSearch(side: String = "", symbol: String = "",
                                   isShowCanceled: String = "0", type: String = "", page: String = "1",
                                   pageSize: String = "100", isLever: Boolean = false, entrust: String = "1", consumer: DisposableObserver<ResponseBody>): Disposable? {

        val map = getBaseMaps().apply {
            this["entrust"] = entrust
            this["side"] = side
            this["symbol"] = symbol
            this["orderType"] = if (isLever) "2" else "1"
            this["isShowCanceled"] = isShowCanceled
            if (type.isNotEmpty()) {
                this["type"] = type
            }
            this["page"] = page
            this["pageSize"] = pageSize
        }

        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getNewEntrustSearch(getBaseReqBody(map)), consumer)
    }


    /**
     *Entrustment details
     *@param needOrder 0: No order 1: No order
     */
    fun getEntrustDetail4(id: String, symbol: String, pageSize: String = "10",
                          page: String = "1", consumer: DisposableObserver<ResponseBody>): Disposable? {
        val hashMap = getBaseMaps().apply {
            this["order_id"] = id
            this["symbol"] = symbol
            this["needOrder"] = "1"
            this["pageSize"] = pageSize
            this["page"] = page
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getEntrustDetail4(getBaseReqBody(hashMap)), consumer)
    }

    /**
     *Entrustment details
     *@param needOrder 0: No order 1: No order
     */
    fun getLeverEntrustDetail4(id: String, symbol: String, pageSize: String = "10",
                               page: String = "1", consumer: DisposableObserver<ResponseBody>): Disposable? {
        val hashMap = getBaseMaps().apply {
            this["order_id"] = id
            this["symbol"] = symbol
            this["pageSize"] = pageSize
            this["page"] = page
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getLeverEntrustDetail4(getBaseReqBody(hashMap)), consumer)
    }


    /**
     *5. Obtain transaction restriction copy
     */
    fun getTradeLimitInfo(symbol: String?, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val hashMap = getBaseMaps().apply {
            this["symbol"] = symbol ?: ""
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getTradeLimitInfo(getBaseReqBody(hashMap)), consumer)
    }

    /**********Spot trading END*******************/


    /**
     *Get Currency Introduction (app4.0)
     */
    fun getCoinIntro(coin: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val hashMap = getBaseMaps().apply {
            this["coinSymbol"] = coin
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getCoinIntro(getBaseReqBody(hashMap)), consumer)
    }

    /*************Login Registration***************/
    /**
     *Mobile login&email login
     *Unified use
     */
    fun getLoginByMobile(account: String = "", password: String = "",countryCode:String?,verificationType: Int = 0,safeVerifyDataMap:Map<String,String>, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val hashMap = getBaseMaps().apply {
            this[MOBILE_NUMBER] = account
            this[LOGIN_PWORD] = password
            this[VERIFICATION_TYPE] = verificationType.toString()
            this["clouldflareVerification"] = "1"
            if(countryCode!=null){
                this["countryCode"] = countryCode
            }

            val entry = safeVerifyDataMap.entries
            val iterator = entry.iterator()
            while (iterator.hasNext()){
                val next = iterator.next()
                this[next.key] = next.value
            }

        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).loginByMobile(getBaseReqBody(hashMap)), consumer)
    }

    fun getTartCaptchaV2(consumer: DisposableObserver<HttpResult<TartCaptchaV2Bean>>): Disposable?{
        val hashMap = getBaseMaps()
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).tartCaptchaV2(getBaseReqBody(hashMap)), consumer)
    }

    /**
     *Login confirmation
     *@param authCode verification code
     *@param 1 Google verification, 2 SMS verification, 3 email verification
     */
    fun confirmLogin(authCode: String, checkType: String = "1", token: String = "", consumer: DisposableObserver<ResponseBody>): Disposable? {
        val hashMap = getBaseMaps().apply {
            this["authCode"] = authCode
            this["checkType"] = checkType
            this["token"] = token
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).confirmLogin(getBaseReqBody(hashMap)), consumer)
    }


    /**
     *Registration (Step 2)
     *Mobile&email
     *@param registerCode Fill in your phone number or email address
     *@param numberCode email or SMS verification code
     */
    fun reg4Step2(registerCode: String, numberCode: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val hashMap = getBaseMaps().apply {
            this["registerCode"] = registerCode
            this["numberCode"] = numberCode
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).reg4Step2(getBaseReqBody(hashMap)), consumer)
    }

    /**
     *Retrieve Password Step 2
     */
    fun findPwdStep2(token: String, smsCode: String, mobileNumber: String, emailCode: String, email: String, certifcateNumber: String, googleCode: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val hashMap = getBaseMaps().apply {
            this["token"] = token
            if (!TextUtils.isEmpty(mobileNumber)) {
                this["smsCode"] = smsCode
                this["mobileNumber"] = mobileNumber
            }
            if (!TextUtils.isEmpty(email)) {
                this["emailCode"] = emailCode
                this["email"] = email
            }
            if (!TextUtils.isEmpty(certifcateNumber)) {
                this["certifcateNumber"] = certifcateNumber
            }
            if (!TextUtils.isEmpty(googleCode)) {
                this["googleCode"] = googleCode
            }
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).findPwdStep2(getBaseReqBody(hashMap)), consumer)
    }

    /**
     *Obtain user information
     */
    fun getUserInfo(consumer: DisposableObserver<ResponseBody>): Disposable? {
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).user_info(getBaseReqBody()), consumer)
    }

    fun saveUserInfo() {
        var consumer: DisposableObserver<ResponseBody> = object : NDisposableObserver() {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                var json = jsonObject.optJSONObject("data")
                UserDataService.getInstance().saveData(json)
            }
        }
        changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).user_info(getBaseReqBody()), consumer)
    }

    /**
     *Fingerprint or facial recognition
     */
    fun checkLocalPwd(uid: String, loginPword: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["uid"] = uid
            this["nativePwd"] = loginPword

        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).checkLocalPwd(getBaseReqBody(map)), consumer)
    }

    /**
     *Retrieve Password Step 4
     */
    fun findPwdStep4(token: String, loginPword: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["token"] = token
            this["loginPword"] = loginPword
//            this["newPassword"] = loginPword
        }

        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).findPwdStep4(getBaseReqBody(map)), consumer)
    }

    /**
     *Registration (Step 3)
     *Mobile&email
     *@param registerCode Mobile or email verification code
     *@param loginPword login password
     *@param newPassword Confirm Password
     *@param invitedCode Invitation Code
     */
    fun reg4Step3(registerCode: String,
                  loginPword: String,
                  newPassword: String,
                  invitedCode: String = "", consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["registerCode"] = registerCode
            this["loginPword"] = loginPword
            this["newPassword"] = newPassword
            this["invitedCode"] = invitedCode
        }

        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).reg4Step3(getBaseReqBody(map)), consumer)
    }

    fun getAgreementStr(consumer: DisposableObserver<ResponseBody>): Disposable?{
        val map = getBaseMaps().apply {
            this["fileName"] = "agreement"
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getAgreementStr(getBaseReqBody(map)), consumer)
    }

    /**
     *Set gesture password
     *@param token: The string returned when the first step of opening a gesture password is successful (required)
     */
    fun setHandPwd(token: String, handPwd: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["handPwd"] = handPwd
            this["token"] = token
        }

        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).setHandPwd(getBaseReqBody(map)), consumer)
    }


    /**
     *Set gesture password
     *@param token: The string returned when the first step of opening a gesture password is successful (required)
     */
    fun setHandPwdOne(token: String, handPwd: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["handPwd"] = handPwd
            this["token"] = token
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).setHandPwdOne(getBaseReqBody(map)), consumer)
    }


    /**
     *Fingerprint or facial recognition
     */
    fun newOpenHandPwd(token: String, loginPword: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["handPwd"] = loginPword
            this["token"] = token
        }

        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).newOpenHandPwd(getBaseReqBody(map)), consumer)
    }


    /**
     *Retrieve Password Step 1
     */
    fun findPwdStep1(mobileNumber: String,
                     email: String,
                     countryCode:String?,
                     verificationType: Int = 0,
                     safeVerifyDataMap:Map<String, String>,
                     consumer: DisposableObserver<ResponseBody>
    ): Disposable? {
        val map = getBaseMaps().apply {
            if (!TextUtils.isEmpty(mobileNumber)) {
                this["mobileNumber"] = mobileNumber
            }
            if (!TextUtils.isEmpty(email)) {
                this["email"] = email
            }
            if(countryCode!=null){
                this["countryCode"] = countryCode
            }
            this["verificationType"] = verificationType.toString()
            this["clouldflareVerification"] = "1"
            val entry = safeVerifyDataMap.entries
            val iterator = entry.iterator()
            while (iterator.hasNext()){
                val next = iterator.next()
                this[next.key] = next.value
            }
        }

        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).findPwdStep1(getBaseReqBody(map)), consumer)
    }

    /**
     *Registration (Step 1)
     *Mobile&email
     */
    fun reg4Step1(country: String = "86",
                  mobile: String = "",
                  verificationType: Int,
                  safeVerifyDataMap: Map<String, String>,
                  consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["country"] = country
            if (StringUtils.isNumeric(mobile)) {
                this["mobile"] = mobile
                this["email"] = ""
            } else {
                this["mobile"] = ""
                this["email"] = mobile
            }

            this["verificationType"] = verificationType.toString()
            this["clouldflareVerification"] = "1"
            val entry = safeVerifyDataMap.entries
            val iterator = entry.iterator()
            while (iterator.hasNext()){
                val next = iterator.next()
                this[next.key] = next.value
            }
        }

        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).reg4Step1(getBaseReqBody(map)), consumer)
    }


    /**
     *Gesture password login
     */
    fun handPwdLogin(account: String, loginPwd: String, handPwd: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["mobileNumber"] = account
            this["handPwd"] = handPwd
            this["loginPwd"] = loginPwd
        }

        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).handPwdLogin(getBaseReqBody(map)), consumer)
    }


    /*************Login and register END***************/

    /*
     *Obtain user selected currency pairs on the server
     */
    fun getOptionalSymbol(consumer: DisposableObserver<ResponseBody>): Disposable? {
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getOptionalSymbol(getBaseReqBody()), consumer)
    }

    /*
     *Obtain user selected currency pairs on the server
     */
    fun addOrDeleteSymbol(type: Int = 0, list: ArrayList<String>?, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["operationType"] = type.toString()

            if (null != list && list.size > 0) {
                var builder = StringBuilder()
                list.forEach {
                    builder.append(it)
                    builder.append(",")
                }
                this["symbols"] = builder.substring(0, builder.length - 1)
            } else {
                this["symbols"] = ""
            }

        }

        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).addOrDeleteSymbol(getBaseReqBody(map)), consumer)
    }

    /*
     *  common_rate
     */
    fun common_rate(consumer: DisposableObserver<ResponseBody>): Disposable? {
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).common_rate(getBaseReqBody()), consumer)
    }


    /******B2c****/
    /**
     *List of Legal Currency Assets
     */
    fun fiatBalance(symbol: String = "", consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["symbol"] = symbol
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).fiatBalance(getBaseReqBody(map)), consumer)
    }

    /**
     *Recharge
     *@param symbol Currency
     *@param transferVoucher transfer voucher
     *@param amount Transfer amount
     */
    fun fiatDeposit(symbol: String, transferVoucher: String, amount: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["symbol"] = symbol
            this["transferVoucher"] = transferVoucher
            this["amount"] = amount
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).fiatDeposit(getBaseReqBody(map)), consumer)
    }

    /**
     *Recharge Record
     */
    fun fiatDepositList(symbol: String, page: String = "1", pageSize: String = "100", startTime: String = "", endTime: String = "", consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["symbol"] = symbol
            this["page"] = page
            this["pageSize"] = pageSize
            this["startTimeMillis"] = startTime
            this["endTimeMillis"] = endTime
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).fiatDepositList(getBaseReqBody(map)), consumer)
    }

    /**
     *Recharge cancellation
     */
    fun fiatCancelDeposit(id: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["id"] = id
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).fiatCancelDeposit(getBaseReqBody(map)), consumer)
    }

    /**
     *Withdrawal
     *@param symbol Currency
     *@param userWithdrawBankId User withdrawal bank ID
     *@param amount Transfer amount
     */
    fun fiatWithdraw(symbol: String, userWithdrawBankId: String, amount: String, smsAuthCode: String, googleCode: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["symbol"] = symbol
            this["userWithdrawBankId"] = userWithdrawBankId
            this["amount"] = amount
            this["smsAuthCode"] = smsAuthCode
            this["googleCode"] = googleCode
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).fiatWithdraw(getBaseReqBody(map)), consumer)
    }

    /**
     *Withdrawal records
     */
    fun fiatWithdrawList(symbol: String, startTime: String = "", endTime: String = "", consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["symbol"] = symbol
            this["startTimeMillis"] = startTime
            this["endTimeMillis"] = endTime
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).fiatWithdrawList(getBaseReqBody(map)), consumer)
    }


    /**
     *Withdrawal cancellation
     */
    fun fiatCancelWithdraw(id: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["id"] = id
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).fiatCancelWithdraw(getBaseReqBody(map)), consumer)
    }


    /**
     *User withdrawal bank list
     */
    fun fiatBankList(symbol: String, page: String = "1", pageSize: String = "10", consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["symbol"] = symbol
            this["page"] = page
            this["pageSize"] = pageSize
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).fiatBankList(getBaseReqBody(map)), consumer)
    }

    /**
     *Query user withdrawal bank
     */
    fun fiatGetBank(id: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["id"] = id
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).fiatGetBank(getBaseReqBody(map)), consumer)
    }


    /**
     *New user withdrawal bank
     *@param bankId Bank ID
     *@param bankSub Branch
     *@param cardNo card number
     *@param name person name
     *@param symbol Currency
     *@param smsAuthCode SMS verification code
     *@param googleCode Google Verification Code
     */
    fun fiatAddBank(bankId: String,
                    bankSub: String,
                    cardNo: String,
                    name: String,
                    symbol: String,
                    smsAuthCode: String,
                    googleCode: String,
                    consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["bankId"] = bankId
            this["bankSub"] = bankSub
            this["cardNo"] = cardNo
            this["name"] = name
            this["symbol"] = symbol
            this["smsAuthCode"] = smsAuthCode
            this["googleCode"] = googleCode
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).fiatAddBank(getBaseReqBody(map)), consumer)
    }

    /**
     *Modify user withdrawal bank
     */
    fun fiatEditBank(id: String,
                     bankId: String,
                     bankSub: String,
                     cardNo: String,
                     name: String,
                     symbol: String,
                     smsAuthCode: String,
                     googleCode: String,
                     consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["id"] = id
            this["bankId"] = bankId
            this["bankSub"] = bankSub
            this["cardNo"] = cardNo
            this["name"] = name
            this["symbol"] = symbol
            this["smsAuthCode"] = smsAuthCode
            this["googleCode"] = googleCode
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).fiatEditBank(getBaseReqBody(map)), consumer)
    }


    /**
     *Delete user withdrawal bank
     */
    fun fiatDeleteBank(id: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["id"] = id
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).fiatDeleteBank(getBaseReqBody(map)), consumer)
    }

    /**
     *Query platform recharge bank information
     */
    fun fiatBankInfo(symbol: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["symbol"] = symbol
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).fiatBankInfo(getBaseReqBody(map)), consumer)
    }

    /**
     *Query platform supports withdrawal bank list
     */
    fun fiatAllBank(symbol: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["symbol"] = symbol
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).fiatAllBank(getBaseReqBody(map)), consumer)
    }


    /**
     *Image temporary token
     *@param operation_ Type 1 Real name authentication 2 Other
     */
    fun getImageToken(operate_type: String = "1", consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["operate_type"] = operate_type
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getImageToken(getBaseReqBody(map)), consumer)
    }

    /**
     *Upload photos
     */
    fun uploadImg(imgBase64: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["imageData"] = imgBase64
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).uploadImg(getBaseReqBody(map)), consumer)
    }


    /**
     *App Announcement Details Page
     */
    fun getNoticeDetail(id: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            if (StringUtil.checkStr(id)) {
                this["id"] = id
            }
            this["dayType"] = PublicInfoDataService.getInstance().themeMode.toString()
            this["lan"] = LanguageUtil.getSelectLanguage()
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getNoticeDetail(map), consumer)
    }


    /**
     *Sell at a markup
     */
    fun raisePriceSell(symbol: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["symbol"] = symbol
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).raisePriceSell(getBaseReqBody(map)), consumer)
    }


    /**
     *Obtain the domain name of H5
     */
    fun getCommonKV(param: String? = "h5_url", consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps()
        if (StringUtil.checkStr(param)) {
            map["key"] = param!!
        } else {
            map["key"] = "h5_url"
        }

        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getCommonKV(map), consumer)
    }

    /**
     *Get App Version
     */
    fun getAppVersion(consumer: DisposableObserver<ResponseBody>): Disposable? {
//        val map = getBaseMaps()
//        map["Platform-CU-Num"] = if (isGoogleVersion()) "2" else "3"
//        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getAppVersion(DataHandler.encryptParams(map)), consumer)
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getAppVersion(DataHandler.encryptParams(getBaseMaps())), consumer)
    }

    /**
     *User system homepage
     */
    fun getRoleIndex(consumer: DisposableObserver<ResponseBody>): Disposable? {
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getRoleIndex(getBaseReqBody()), consumer)
    }

    /*
     *Gesture password
     */
    fun getGesturePwd(uid: String, gesturePwd: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps()
        if (StringUtil.checkStr(uid)) {
            map["uid"] = uid
        }
        if (StringUtil.checkStr(gesturePwd)) {
            map["gesturePwd"] = gesturePwd
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getGesturePwd(getBaseReqBody(map)), consumer)
    }


    /**********Lever*************/
    /**
     *Current Application (Unreturned Records)
     */
    fun borrowNew(symbol: String, startTime: String = "", endTime: String = "", page: String = "1", pageSize: String = "20", consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps()
        map.apply {
            this["symbol"] = symbol
            if (!TextUtils.isEmpty(startTime)) {
                this["startTime"] = startTime
            }
            if (!TextUtils.isEmpty(endTime)) {
                this["endTime"] = endTime
            }
            this["page"] = page
            this["pageSize"] = pageSize
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).borrowNew(getBaseReqBody(map)), consumer)
    }


    /**
     *Historical application (returned records)
     */
    fun borrowHistory(symbol: String, startTime: String = "", endTime: String = "", page: String = "1", pageSize: String = "20", consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps()
        map.apply {
            this["symbol"] = symbol
            if (!TextUtils.isEmpty(startTime)) {
                this["startTimeMillis"] = startTime
            }
            if (!TextUtils.isEmpty(endTime)) {
                this["endTimeMillis"] = endTime
            }
            this["page"] = page
            this["pageSize"] = pageSize
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).borrowHistory(getBaseReqBody(map)), consumer)
    }


    /**
     *List of leveraged accounts
     */

    fun getBalanceList(consumer: DisposableObserver<ResponseBody>): Disposable? {
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getBalanceList(getBaseReqBody()), consumer)
    }

    /**
     *Return
     */
    fun setReturn(id: String, amount: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        var map = getBaseMaps().apply {
            this["id"] = id
            this["amount"] = amount
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).setReturn(getBaseReqBody(map)), consumer)
    }

    /**
     *Lending
     */
    fun setBorrow(symbol: String, coin: String, amount: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        var map = getBaseMaps().apply {
            this["symbol"] = symbol
            this["coin"] = coin
            this["amount"] = amount
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).setBorrow(getBaseReqBody(map)), consumer)
    }


    /**
     *Obtain account information based on currency pairs
     */
    fun getBalance4Lever(symbol: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        if (!UserDataService.getInstance().isLogined) return null
        val map = getBaseMaps().apply {
            this["symbol"] = symbol
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getBalance4Lever(getBaseReqBody(map)), consumer)
    }


    /**
     *Obtain account information based on currency pairs
     */
    fun setTransfer4Lever(fromAccount: String, toAccount: String, amount: String, coinSymbol: String, symbol: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["fromAccount"] = fromAccount
            this["toAccount"] = toAccount
            this["amount"] = amount
            this["coinSymbol"] = coinSymbol
            this["symbol"] = symbol
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).setTransfer4Lever(getBaseReqBody(map)), consumer)
    }

    /**
     *Transfer to homepage
     */
    fun transher4OTC(fromAccount: String, toAccount: String, amount: String, coinSymbol: String?, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["fromAccount"] = fromAccount
            this["toAccount"] = toAccount
            this["amount"] = amount
            if (null != coinSymbol) {
                this["coinSymbol"] = coinSymbol!!
            }
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).transher4OTC(getBaseReqBody(map)), consumer)
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
    fun capitalTransfer4Contract(fromType: String,
                                 toType: String,
                                 amount: String,
                                 bond: String?, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["fromType"] = fromType
            this["toType"] = toType
            this["amount"] = amount
            if (null != bond) {
                this["bond"] = bond!!
            }
        }
        return changeIOToMainThread(httpHelper.getContractUrlService(ContractApiService::class.java).capitalTransfer4Contract(getBaseReqBody(map)), consumer)
    }


    /**
     *Obtain a transaction account for a certain currency
     */
    fun accountGetCoin4OTC(coin: String?, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            if (null != coin) {
                this["coin"] = coin!!
            }
        }

        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).accountGetCoin4OTC(getBaseReqBody(map)), consumer)
    }


    /**
     *Obtain details
     */
    fun getDetail4Lever(id: String, page: String = "1", pageSize: String = "20", consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["id"] = id
            this["page"] = page
            this["pageSize"] = pageSize
        }

        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getDetail4Lever(getBaseReqBody(map)), consumer)
    }

    /**
     *Obtain details
     */
    fun getTransferList(symbol: String = "", transactionType: String = "", coinSymbol: String = "", page: String = "1", pageSize: String = "20", consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["coinSymbol"] = coinSymbol
            this["symbol"] = symbol
            this["transactionType"] = transactionType
            this["page"] = page
            this["pageSize"] = pageSize
        }

        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getTransferList(getBaseReqBody(map)), consumer)
    }


    /**
     *Used to obtain the homepage of total assets
     */
    fun getTotalAsset(consumer: DisposableObserver<ResponseBody>): Disposable? {
        var isNewOldContract: Boolean
        val mContractMode = PublicInfoDataService.getInstance().getContractMode()
        if (mContractMode == 0 || mContractMode == -1) {
            //Old version contract
            isNewOldContract = false
        } else {
            //New contract
            isNewOldContract = true
        }
        AppConstant.IS_NEW_CONTRACT = isNewOldContract
        if (AppConstant.IS_NEW_CONTRACT) {
            return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getContractTotalAccountBalanceV2(getBaseReqBody()), consumer)
        } else {
            return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getTotalAsset(getBaseReqBody()), consumer)
        }
    }

    /**
     *Obtain handling fees and withdrawal addresses based on currency
     */
    fun getCost(symbol: String = "", consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["symbol"] = symbol
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getCost(getBaseReqBody(map)), consumer)
    }

    /**
     *Obtain handling fees and withdrawal addresses based on currency
     */
    fun addWithdrawAddrValidate(symbol: String = "", address: String = "", consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["coinSymbol"] = symbol
            this["address"] = address
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).addWithdrawAddrValidate(getBaseReqBody(map)), consumer)
    }


    /**
     *Obtain net value of currency to ETF
     *@param base Base Currency
     *@param quote pricing currency
     */
    fun getETFValue(base: String, quote: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["base"] = base
            this["quote"] = quote
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getETFValue(getBaseReqBody(map)), consumer)
    }

    /**
     *ETF disclaimer information URL and domain name
     */
    fun getETFInfo(consumer: DisposableObserver<ResponseBody>): Disposable? {
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getETFInfo(getBaseReqBody()), consumer)
    }


    /**
     *Start tracking
     * @param trade_currency_id
     * @param total
     * @param is_stop_deficit
     * @param stop_deficit
     * @param is_stop_profit
     * @param stop_profit
     * @param coin_symbol
     */
    fun getInnerFollowbegin(trade_currency_id: String, total: String, is_stop_deficit: String, stop_deficit: String, is_stop_profit: String, stop_profit: String, symbol: String, currency: String, trade_currency: String, follow_immediately: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["trade_currency_id"] = trade_currency_id
            this["total"] = total
            this["is_stop_deficit"] = is_stop_deficit
            this["stop_deficit"] = stop_deficit
            this["is_stop_profit"] = is_stop_profit
            this["stop_profit"] = stop_profit
            this["symbol"] = symbol
            this["currency"] = currency
            this["trade_currency"] = trade_currency
            this["follow_immediately"] = follow_immediately
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getInnerFollowbegin(getBaseReqBody(map)), consumer)
    }

    /**
     *End tracking
     * @param follow_id
     */
    fun getInnerFollowEnd(follow_id: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["follow_id"] = follow_id
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getInnerFollowEnd(getBaseReqBody(map)), consumer)
    }

    /**
     *Obtain account balance information
     */
    fun getAccountBalance(coinSymbols: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["coinSymbols"] = coinSymbols
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).accountBalance(getBaseReqBody(map)), consumer)
    }

    /**
     *Obtain account balance information
     */
    fun getAgentIndex(consumer: DisposableObserver<ResponseBody>): Disposable? {
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getAgentIndex(getBaseReqBody()), consumer)
    }

    /**
     *Obtain account balance information
     */
    fun getNoTokenPublic(consumer: DisposableObserver<ResponseBody>): Disposable? {
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getNoTokenPublic(getBaseReqBody()), consumer)
    }


    /**
     *Fingerprint login new
     */
    fun newQuickLogin(quicktoken: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["quicktoken"] = quicktoken
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).newQuickLogin(getBaseReqBody(map)), consumer)
    }


    /**
     *Sign in new with gestures
     */
    fun newHandLogin(quicktoken: String, handPwd: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["quicktoken"] = quicktoken
            this["handPwd"] = handPwd
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).newHandLogin(getBaseReqBody(map)), consumer)
    }

    /**
     *Gesture opening guide page new
     */
    fun newOpenHand(quicktoken: String, handPwd: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["quicktoken"] = quicktoken
            this["handPwd"] = handPwd
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).newOpenHand(getBaseReqBody(map)), consumer)
    }

    /**
     *Obtain the information required for user identity authentication
     */
    fun getIdentityAuthInfo(consumer: DisposableObserver<ResponseBody>): Disposable? {
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getIdentityAuthInfo(getBaseReqBody()), consumer)
    }

    /**
     *Obtain net value of currency to ETF
     *@param base Base Currency
     *@param quote pricing currency
     */
    fun submitAuthInfoCheck(idNumber: String, userName: String, withdrawId: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["idNumber"] = idNumber
            this["userName"] = userName
            this["withdrawId"] = withdrawId
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).submitAuthInfoCheck(getBaseReqBody(map)), consumer)
    }

    /**
     *Login confirmation
     *@param authCode verification code
     *@param 1 Google verification, 2 SMS verification, 3 email verification
     */
    fun confirmLoginV2(array: Map<String, String>, token: String = "", consumer: DisposableObserver<ResponseBody>): Disposable? {
        val hashMap = getBaseMaps().apply {
            for ((key, value) in array) {
                this[key.verfitionTypeCheck()] = value
            }
            this["token"] = token
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).confirmLogin(getBaseReqBody(hashMap)), consumer)
    }

    /**
     *Obtain spot brokers
     */
    fun getAgentDataQuery(coinName: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["coinName"] = coinName
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getAgentDataQuery(getBaseReqBody(map)), consumer)
    }

    /**
     *Obtain spot brokers
     */
    fun getPageConfig(consumer: DisposableObserver<ResponseBody>): Disposable? {
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getPageConfig(getBaseReqBody()), consumer)
    }

    /**
     *My invitation
     */
    fun getMyInvitations(page: String = "1", consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["page"] = page
            this["pageSize"] = "20"
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getMyInvitations(getBaseReqBody(map)), consumer)
    }

    /**
     *Invitation rewards
     */
    fun getMyInvitationRewards(page: String = "1", consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["page"] = page
            this["pageSize"] = "20"
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getMyInvitationRewards(getBaseReqBody(map)), consumer)
    }

    /**
     *Get homepage data
     */
    fun getHomeData(type: String = "", consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["type"] = type
            this["timeType"] = PublicInfoDataService.getInstance().themeModeByApi
            if (AppConstant.IS_NEW_CONTRACT){
                this["coVersion"] = "1"
            }else{
                this["coVersion"] ="0"
            }
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getHome(getBaseReqBody(map)), consumer)
    }

    /**
     *Get homepage data
     */
    fun getChargeAddress(symbol: String = "", consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["symbol"] = symbol
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getChargeAddress(getBaseReqBody(map)), consumer)
    }

    /**
     *Obtain publicInfoMarket
     * @param consumer
     * @return
     */
    fun publicInfoMarket(consumer: DisposableObserver<ResponseBody>): Disposable? {

        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).publicInfoMarket(getBaseReqBody()), consumer)
    }

    /**
     *
     * @param consumer
     * @return
     */
    fun getCommonRecommendCoin(consumer: DisposableObserver<ResponseBody>): Disposable? {
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getCommonRecommendCoin(getBaseReqBody(null)), consumer)
    }

    /**
     *
     * @param consumer
     * @return
     */
    fun likesCoinsUpload(symbols: String = "", consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            if (symbols.isNotEmpty()) {
                this["symbols"] = symbols
            }
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).optionalUploadSymbol(getBaseReqBody(map)), consumer)
    }


    /**
     *Transfer of spot goods to contracts
     */
    fun futuresTransfer(uid: String = "", coinSymbol: String = "", amount: String = "",transferType: String = "", consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["coinSymbol"] = coinSymbol
            this["amount"] = amount
            this["transferType"] = transferType
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).futuresTransfer(getBaseReqBody(map)), consumer)
    }

    /**
     *New version acquisition contract total asset interface
     */
    fun contractTotalAccountBalanceV2(consumer: DisposableObserver<ResponseBody>): Disposable? {
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getContractTotalAccountBalanceV2(getBaseReqBody()), consumer)
    }

    /**
     *Query (AI) Configuration
     * @return
     */
    fun getAIStrategyInfo(symbol: String = "", consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["symbol"] = symbol
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getAIStrategyInfo(getBaseReqBody(map)), consumer)
    }


    /**
     *Save Policy
     *@param symbol currency to BTC/USDT
     *@param quantType Quantitative Transaction Type 1: Grid
     *@param gridLineType Grid Type 1: Equal Difference 2: Equal Ratio
     *@param gridNumber Number of grids
     *@param lowestPrice grid lower limit
     *@param highestPrice grid upper limit
     *@param stopHighPrice Stop grid upper limit
     *@param stopLowPrice Stop grid lower limit
     *@param totalQuoteAmount User Input Assets
     *@param useOwnBase: Use Base asset 0: Do not use 1: Use
     * @return
     */
    fun saveStrategy(symbol: String, quantType: String, gridLineType: String, gridNumber: String,
                     lowestPrice: String, highestPrice: String, stopHighPrice: String, stopLowPrice: String,
                     totalQuoteAmount: String, useOwnBase: String, fee: String, totalBaseAmount: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["symbol"] = symbol
            this["quantType"] = quantType
            this["gridLineType"] = gridLineType
            this["gridNumber"] = gridNumber
            this["lowestPrice"] = lowestPrice
            this["highestPrice"] = highestPrice
            if (stopHighPrice.isEmpty()) {
                this["stopHighPrice"] = "0"
            } else {
                this["stopHighPrice"] = stopHighPrice
            }
            if (stopLowPrice.isEmpty()) {
                this["stopLowPrice"] = "0"
            } else {
                this["stopLowPrice"] = stopLowPrice
            }

            this["totalQuoteAmount"] = totalQuoteAmount
            this["useOwnBase"] = useOwnBase
            this["fee"] = BigDecimal(fee).toPlainString()
            this["totalBaseAmount"] = totalBaseAmount

        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).saveStrategy(getBaseReqBody(map)), consumer)
    }


    /**
     *Calculate the total assets invested using base
     *@param symbol currency to BTC/USDT
     *@param gridLineType Grid Type 1: Equal Difference 2: Equal Ratio
     *@param gridNumber Number of grids
     *@param lowestPrice grid lower limit
     *@param highestPrice grid upper limit
     *@param totalQuoteAmount User Input Assets
     *@param currentPrice Current price
     * @return
     */
    fun calBaseAmount(symbol: String, lowestPrice: String, highestPrice: String, gridNumber: String, gridLineType: String,
                      totalQuoteAmount: String, currentPrice: String, fee: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["symbol"] = symbol
            this["lowestPrice"] = lowestPrice
            this["highestPrice"] = highestPrice
            this["gridNumber"] = gridNumber
            this["gridLineType"] = gridLineType
            this["fee"] = fee
            this["totalQuoteAmount"] = totalQuoteAmount
            this["currentPrice"] = currentPrice

        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).calBaseAmount(getBaseReqBody(map)), consumer)
    }


    /**
     *Strategic Transaction List (Details)
     * @return
     */
    fun getStrategyList(isHideOtherSymbol: Boolean = false, symbols: String = "", status: String = "1", page: String = "", pageSize: String = "20", consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            if (symbols.isNotEmpty()) {
                if (isHideOtherSymbol) {
                    this["symbol"] = symbols
                }
                this["status"] = status
                this["page"] = page
                this["pageSize"] = pageSize

            }
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getStrategyList(getBaseReqBody(map)), consumer)
    }


    fun getStrategyList(symbols: String = "", status: String = "1", page: String = "",pageSize: String="20", consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            if (symbols.isNotEmpty()) {
                this["symbol"] = symbols
                this["status"] = status
                this["page"] = page
                this["pageSize"] = pageSize

            }
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getStrategyList(getBaseReqBody(map)), consumer)
    }

    /**
     *Querying records of pending orders
     * @return
     */
    fun getOrderingGridList(strategyId: String = "", consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            if (strategyId.isNotEmpty()) {
                this["strategyId"] = strategyId
            }
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getOrderingGridList(getBaseReqBody(map)), consumer)
    }


    /**
     *The grid has completed the registration record
     * @return
     */
    fun getFinishGridList(strategyId: String = "", page: String = "", consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            if (strategyId.isNotEmpty()) {
                this["strategyId"] = strategyId
                this["page"] = page
                this["pageSize"] = "20"
            }
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getFinishGridList(getBaseReqBody(map)), consumer)
    }

    /**
     *Stop Policy
     * @return
     */
    fun stopStrategy(strategyId: String = "", consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            if (strategyId.isNotEmpty()) {
                this["strategyId"] = strategyId
            }
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).stopStrategy(getBaseReqBody(map)), consumer)
    }

    /**
     *Obtain Asset Details
     * @return
     */
    fun getAccountBalanceByMarginCoin(symbols: String = "", consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["coinSymbols"] = symbols
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getAccountBalanceByMarginCoin(getBaseReqBody(map)), consumer)
    }

    /**
     *Obtain Asset Details
     * @return
     */
    fun getETFCoin(consumer: NDisposableObserver): Disposable? {
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getETFCoin(getBaseReqBody(null)), consumer)
    }

    /**
     *Read
     * @return
     */
    fun saveETFStatus(consumer: NDisposableObserver): Disposable? {
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).saveETFStatus(getBaseReqBody(null)), consumer)
    }

    /**
     *Get Currency Introduction (app4.0)
     */
    fun getETFPositionRecordList(symbol: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val hashMap = getBaseMaps().apply {
            this["symbol"] = symbol
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getETFPositionRecordList(getBaseReqBody(hashMap)), consumer)
    }

    /**
     *Save Configuration
     */
    fun savePublicInfo() {
        val consumer: DisposableObserver<ResponseBody> = object : NDisposableObserver() {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                val json = jsonObject.optJSONObject("data")
                PublicInfoDataService.getInstance().saveData(json)
            }
        }
        changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).public_info_v4(getBaseReqBody()), consumer)
    }
    /**
     *Apply for invitation quota
     */
    fun applyInviteQuota( applyQuota:String, applyDesc:String,consumer: NDisposableObserver): Disposable? {
        val hashMap = getBaseMaps().apply {
            this["applyQuota"] = applyQuota
            this["applyDesc"] = applyDesc
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).applyInviteQuota(getBaseReqBody(hashMap)), consumer)
    }

    /**
     *Internal transfer user authentication
     */
    fun innerTransferUserAuth(transferUid: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["transferUid"] = transferUid
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).innerTransferUserAuth(getBaseReqBody(map)), consumer)
    }


    /**
     *Internal transfer
     */
    fun innerTransferDoWithdraw(transferUid: String, amount: String, fee: String, symbol: String, smsAuthCode: String, googleCode: String,emailAuthCode:String,capitalPwd:String?=null, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["transferUid"] = transferUid
            this["amount"] = amount
            this["fee"] = fee
            this["symbol"] = symbol
            if(!"".equals(smsAuthCode)){
                this["smsAuthCode"] = smsAuthCode
            }
            if(!"".equals(emailAuthCode)) this["emailAuthCode"] = emailAuthCode
            if(!"".equals(googleCode)) this["googleCode"] = googleCode
            if (capitalPwd!=null && capitalPwd.isNotEmpty()) {
                this["capitalPassword"] = capitalPwd
            }
        }
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).innerTransferDoWithdraw(getBaseReqBody(map)), consumer)
    }

    fun searchRecommendSymbol(consumer: DisposableObserver<ResponseBody>): Disposable? {
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).searchRecommendSymbol(getBaseReqBody()), consumer)
    }


    //Verify eligibility for cancellation
    fun getAccountDestroyVerification(consumer: DisposableObserver<ResponseBody>): Disposable?{
        val map = getBaseMaps()
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getAccountDestroyVerification(getBaseReqBody(map)),consumer)
    }

    //Account cancellation
    fun destroyAccount(smsAuthCode:String="", emailAuthCode:String="", googleCode:String="", consumer: DisposableObserver<ResponseBody>): Disposable?{
        val map = getBaseMaps()
        if(smsAuthCode.isNotEmpty()) map["smsAuthCode"] = smsAuthCode
        if(emailAuthCode.isNotEmpty()) map["emailAuthCode"] = emailAuthCode
        if(googleCode.isNotEmpty()) map["googleCode"] = googleCode
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).destroyAccount(getBaseReqBody(map)),consumer)
    }

    //Account cancellation display status
    fun getAccountDestroyVisibleStatus(consumer: DisposableObserver<ResponseBody>): Disposable?{
        val map = getBaseMaps()
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getAccountDestroyVisibleStatus(getBaseReqBody(map)),consumer)
    }

    fun getAccessToken(sumsubLevel:String): Single<HttpResult<String>> {
        val map = getBaseMaps()
        map["sumsubLevel"] = sumsubLevel
        return httpHelper.getBaseUrlService(MainApiService::class.java).getAccessToken(getBaseReqBody(map))
    }

    fun getAuthRecord(consumer: DisposableObserver<HttpResult<List<KycAuthBean>>>): Disposable? {
        val map = getBaseMaps()
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getAuthRecord(getBaseReqBody(map)),consumer)
    }
    fun getTaskCenterIndex(consumer: DisposableObserver<ResponseBody>): Disposable?{
        val map = getBaseMaps()
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getTaskCenterIndex(getBaseReqBody(map)),consumer)
    }

    fun doSignIn(consumer: DisposableObserver<ResponseBody>): Disposable?{
        val map = getBaseMaps()
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).doSignIn(getBaseReqBody(map)),consumer)
    }
    /**
     * @param scene reward 0 Daily task 1 Beginner's task  3 sign
     * */
    fun getTaskList(scene:String,consumer: DisposableObserver<ResponseBody>): Disposable?{
        val map = getBaseMaps()
        if(!"-1".equals(scene)) map["type"] = scene
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getTaskList(getBaseReqBody(map)),consumer)
    }

    fun doReceiveReward(id:Int,consumer: DisposableObserver<ResponseBody>): Disposable?{
        val map = getBaseMaps()
        map["taskId"] = id.toString()
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).doReceiveReward(getBaseReqBody(map)),consumer)
    }

    fun getUserRewardOverall(consumer: DisposableObserver<ResponseBody>): Disposable?{
        val map = getBaseMaps()
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getUserRewardOverall(getBaseReqBody(map)),consumer)
    }

    fun getWithdrawRewardInfo(consumer: DisposableObserver<ResponseBody>): Disposable?{
        val map = getBaseMaps()
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getWithdrawRewardInfo(getBaseReqBody(map)),consumer)
    }

    fun getUserRewardUnWithdraw(page:Int? = null,pageSize:Int? = null,consumer: DisposableObserver<ResponseBody>): Disposable?{
        val map = getBaseMaps()
        if(page!=null) map["page"] = page.toString()
        if(pageSize!=null) map["pageSize"] = pageSize.toString()
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getUserRewardUnWithdraw(getBaseReqBody(map)),consumer)
    }
    fun getUserRewardRecords(page:Int? = null,pageSize:Int? = null,consumer: DisposableObserver<ResponseBody>): Disposable?{
        val map = getBaseMaps()
        if(page!=null) map["page"] = page.toString()
        if(pageSize!=null) map["pageSize"] = pageSize.toString()
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getUserRewardRecords(getBaseReqBody(map)),consumer)
    }
    fun getUserWithdrawRecords(page:Int? = null,pageSize:Int? = null,consumer: DisposableObserver<ResponseBody>): Disposable?{
        val map = getBaseMaps()
        if(page!=null) map["page"] = page.toString()
        if(pageSize!=null) map["pageSize"] = pageSize.toString()
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getUserWithdrawRecords(getBaseReqBody(map)),consumer)
    }

    fun doWithdrawReward(consumer: DisposableObserver<ResponseBody>): Disposable?{
        val map = getBaseMaps()
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).doWithdrawReward(getBaseReqBody(map)),consumer)
    }

    fun getRewardCenterInfo(consumer: DisposableObserver<ResponseBody>): Disposable?{
        val map = getBaseMaps()
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getRewardCenterInfo(getBaseReqBody(map)),consumer)
    }

    fun getTaskCompleteCount(consumer: DisposableObserver<ResponseBody>): Disposable?{
        val map = getBaseMaps()
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getTaskCompleteCount(getBaseReqBody(map)),consumer)
    }



    fun getMaxLevel(consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps()
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getMaxLevel(getBaseReqBody(map)), consumer)
    }

    fun getEquity(symbol:String?,consumer: DisposableObserver<HttpResult<EquityBean>>): Disposable? {
        val map = getBaseMaps()
        if(symbol!=null) map["symbol"] = symbol
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).getEquity(getBaseReqBody(map)), consumer)
    }

    fun doKycSubmitCallback(sumsubLevel:String,consumer: DisposableObserver<HttpResult<String?>>): Disposable? {
        val map = getBaseMaps()
        map["sumsubLevel"] = sumsubLevel
        return changeIOToMainThread(httpHelper.getBaseUrlService(MainApiService::class.java).doKycSubmitCallback(getBaseReqBody(map)), consumer)
    }
}
