//
//  AppAPIEndPoint.swift
//  Chainup
//
//  Created by liuxuan on 2023/1/9.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import Moya
import EXKit
enum AppAPIEndPoint {
    case getAPPValidationConfig
    case getSumSubAccessToken(level:String)
    case getkycList
    case getKycAuthCurrentLevel
    case getKycRightInfo(symbol: String?)
    case sumsubSubmit(level:String)
    case logOut
    case getRegisterInfo
    case userUpdatePhoneOrEmail(keyWord: String,isPhone: Bool) //keyWord sPhone  //1 phone number 0 email
    case credit_card_payList(page: String, pageSize: String)
    case pay_submit(quote_id:String,name:String,coin: String,num:String,base_amount:String,total_amount:String,amount:String,fiat:String,rate:String,transferType: String)//Credit Card Payment Submission Form
    case get_third_support_fiat(transferType: String) //1buy 2sell
    case get_paycard_rate_list(fiat: String,coin: String,transferType: String) //Obtain a list of third-party exchange rates for the selected legal currency and digital currency
    case get_paycard_num(fiat:String,coin: String,num: String,name: String,transferType: String)//Name Third party name
    case limit_ip_login
    case inviteConfig
    case addInvitationedCode(invitedCode: String)
    case myInvitationsApp(pageSize : String , page : String)
    case myInvitationRewardsApp(pageSize : String , page : String)
    case contract_AgentInfo //Contract Broker
    case contract_newAgentInfo //Contract Broker New Version
    case contract_agent_role(uid: Int) //Fit to Role

    case listSymbal //User Recommended Selection List
    case update_symbol(operationType:String,symbols:String) //Optional Add
    case checkVisitStatus //Access restriction check
    case publicInfo
    case headerSymbol
    case publicInfoMarket
    case publicRate(_ fiatSymbol:String = "")
    case getRateDiscout(userId: String?)
    case getInvitationImgs //Get invitation pictures
    case tradeLimitInfo(symbol : String)//Obtain transaction restriction copy
    case loginOne(countryCode: String?, mobileNumber : String , loginPword : String)//First step of login
    case loginTwo(token : String , checkType: String , authCode : String , googleCode:String?,smsCode:String?,emailCode:String?,idCardCode:String?)//Login Step 2
    case quickLogin(quickToken:String)//Biometric login
    case handLogin(quickToken:String ,handPwd:String)//Gesture login
    case handOpen(quickToken:String ,handPwd:String, afterLogin:Bool)//Activate gesture
    case getsmsValidCode(token : String , operationType : String? , countryCode : String , mobile  : String )//Obtain mobile verification code
    case getemailVallidCode(email : String , operationType : String? , token : String)//Obtain email verification code
    
    case registGetsmsValidCode(token : String , operationType : String , countryCode : String , mobile  : String)//Obtain registration phone verification code
    case registGetemailVallidCode(email : String , operationType : String , token : String)//Obtain registration email verification code
    case userInfo//Obtain personal information
    case registerOne(email : String , mobile : String, country : String)//First step of registration
    case registerTwo(registerCode : String , numberCode : String)//Registration Step 2
    case registerThree(registerCode : String , loginPword : String , newPassword : String , invitedCode : String)//Registration Step 3
    case forgetPwOne(registerCode : String)//Step 1 of Forgetting Password
    case forgetPwTwo(token : String , numberCode : String)//Forgot Password Step 2
    case forgetPwThree(token : String , certifcateNumber : String , googleCode : String)//Forgot Password Step 3
    case forgetPwFour(token : String , loginPword : String , newPassword : String)//Forgot Password Step 4
    case updateNickname(nickname : String)//Update nickname
    case getAbout//Get information about us
    case getAppMail(messageType : String , pageSize : String , page : String)//Obtain internal messages
    case getNewEntrustList(symbol : String , pageSize : String , page : String, side: String?, type: String?)//Obtain current delegation
    case otcOrderHistory(page:String,type:String?,symbol:String?,currency:String?,status:String?,begin:String?,end:String?,pageSize:String?)//OTC order list
    case getHistoryEntrustList(symbol : String , pageSize : String , page : String , isShowCanceled : String , side : String , type : String , startTime : String , endTime : String,status: String? = nil)//Obtaining Historical Commissions
    case createOrder(side : String , type : String , volume : String , price : String , symbol : String)//Create Coin Order
    case cancelOrder(orderId : String , symbol : String)//Cancel Currency Order
    case changepassword(loginPword : String , newLoginPword : String , smsAuthCode : String , googleCode : String ,IdentificationNumber : String)//Reset login password
    case getGoogle//Get Google Information
    case openGoogle(loginPwd : String , googleCode : String , googleKey : String)//Bind Google Verification
    case closeGoogle(smsValidCode : String ,googleCode : String)//Turn off Google authentication
    case openMoblieValidation//Enable mobile authentication
    case closeMoblie(smsValidCode : String ,googleCode : String)//Turn off mobile verification
    case bindEmail(smsValidCode : String ,googleCode : String ,emailValidCode : String ,email : String )//Bind email
    case updateEmail(emailOldValidCode : String , emailNewValidCode : String ,smsValidCode : String ,googleCode : String ,emailValidCode : String ,email : String )//Modify email
    case updateEmailV6(emailOldValidCode : String , emailNewValidCode : String ,smsValidCode : String ,googleCode : String ,emailValidCode : String ,email : String )//Modify email
    case bindPhone(googleCode : String , countryCode : String , mobileNumber : String , smsAuthCode : String)//Bind phone
    case updatePhone(authenticationCode : String , googleCode : String , countryCode : String , mobileNumber : String , smsAuthCode : String)//Modify phone
    case openGesture(loginPwd : String , smsValidCode : String , googleCode : String , uid : String)//Open gesture
    case closeGesture(loginPwd : String , smsValidCode : String , googleCode : String)//Close gesture
    case openQuick(loginPwd : String , smsValidCode : String , googleCode : String , uid : String)//Open Shortcut
    case getmessageType(messageType : String)//Obtain internal messages
    case createProblem(rqType:String,rqDescribe:String,imageDataStr:String?,rqUnreleased:String?,rqUnpaid:String?)
    case getNotice(page : String,pagesize : String)//Obtain Announcement
    case getNoReadMessageCount//Unread station messages
    case getHelp//Get Help Center
    case financeAccountList//Extralegal account balance
    case authRealname(countryCode : String , certificateType : String ,userName : String ,certificateNumber : String , firstPhoto : String , secondPhoto : String , thirdPhoto : String , familyName : String , name : String,numberCode : String)//Real name authentication
    case coinIntroduce(coinSymbol:String)
    case getHome//Get homepage information
    case accountBalance(coinSymbols:String?)
    case getChargeAddress(symbol:String)
    case transferScene
    case transferList(coinSymbol:String?,transactionScene:String,startTime:String?,endTime:String?,page:String)
    case addressList(coinSymbol:String)
    case addWithdrawAddress(address:String,label:String,smsValidCode:String?,emailValidCode:String?,googleCode:String?,coinSymbol:String,trustOption:Bool)
    case validateWithDrawAddr(address:String,symbol:String)
    case doWithDraw(address:String,trustType:Int?,remark:String,symbol:String,fee:String,amount:String,smsVaildCode:String?,googleValidCode:String?,emailValidCode:String?,addressID:String?,capitalPwd:String?)
    case financeOtcTransfer(fromAccount:String,toAccount:String,amount:String,coinSymbol:String)
    case cancelWithDraw(withDrawId:String)
    case depositCancelWithDraw(withDrawId:String)//B2c recharge cancellation
    case withdrawCancelWithDraw(withDrawId:String)//Withdrawal cancellation of b2c
    case deleteWithDrawAddr(ids:String,googleCode:String?,smsCode:String?,emailAuthCode: String?)
    case messageUpdateStatus(id : String)//Set message as read
    case totalAccountBalance//total assets
    case kycGetToken//Obtain information about KYC
    case kycGetWriting//Obtain information on KYC's manual labor
    case getUpdateVersion//Obtain interface version number
    case getEntrustHistorySearch(page : String , pageSize : String , entrust : String , side : String , symbol : String , orderType : String , status : String , isShowCanceled : String , quote : String , type : String)//Obtaining Historical Commissions
    case create_overcharge_onekey(symbol : String)//Unlock Sell
    case b2cBalance(symbol : String)//B2C Legal Currency Asset List
    case getUserBankList(symbol : String , page : String , pageSize : String)//B2C user withdrawal bank
    case getFiatWithdrawList(symbol : String , page : String , pageSize : String, startTime : String? , endTime : String?)//Obtain the withdrawal list of legal currency
    case getFiatDepoistList(symbol : String , page : String , pageSize : String,startTime : String? , endTime : String?)//Obtain the list of legal currency recharge
    case fiatDeposit(symbol : String , transferVoucher : String , amount : String)//Legal currency recharge
    case getAllBank(symbol : String)//Legal currency query platform supports withdrawal bank list
    case getUserBank(id : String)//Query user withdrawal bank
    case fiatWithdraw(symbol : String ,userWithdrawBankId : String ,amount : String ,smsAuthCode : String ,googleCode : String)//Withdrawal of legal currency
    case getCompanyBankInfo(symbol : String)//Query platform recharge bank information
    case addUserBank(bankId:String,bankSub:String,cardNo:String,name:String,symbol:String,smsAuthCode:String,googleCode:String)//Add user withdrawal bank
    case editUserBank(id:String,bankId:String,bankSub:String,cardNo:String,name:String,symbol:String,smsAuthCode:String,googleCode:String)//Edit User Withdrawal Bank
    case deleteUserBank(id : String)//Delete user withdrawal bank
    case getLeverBalance(symbol : String)//Obtained based on currency pairs
    case getLeverOrderHistory(page : String ,pageSize : String , symbol : String , isShowCanceled : String ,side : String,type : String, status: String)//Obtain leverage historical commission
    case getLeverOrderCurrent(symbol : String , pageSize : String ,page : String)//Obtain the current commission of leverage
    case cancelLeverOrder(orderId : String , symbol : String)//Cancel leveraged orders
    case creatLeverOrder(side : String ,type : String ,volume : String ,price : String ,symbol : String)//Create leveraged orders
    case leverageBalance//List of leveraged accounts
    case leverBorrowHistory(symbol : String,startTime : String?,endTime : String?,page:String,pageSize : String?)//History (Returned Records)
    case leverCurrentBorrow(symbol : String,startTime : String?,endTime : String?,page:String,pageSize : String?)//Current application
    case leverFinanceBorrow(symbol : String, coin : String, amount : String)//Lending
    case leverFinanceReturn(id : String, amount : String)//return
    case leverFinanceSymbolInfo(symbol : String)//Obtain leveraged currency pair information based on currency pairs
    case leverTransferRecord(symbol : String,coinSymbol : String, transactionType : String,page : String,pageSize : String?)//Transfer Record
    case leverFinanceTransfer(fromAccount : String,toAccount : String,amount : String,coinSymbol : String,symbol : String)//Lever transfer
    case leverReturnInfo(id : String,page : String,pageSize : String?)//Return details
    case swapTransfer(type:String,amount:String,bound:String)
    case coinToFuturesTransfer(amount:String,coinSymbol:String,type: String)
    case getCost(symbol:String)
    case etfFaqInfo
    case etfNetValue(base:String,quote:String)//Obtain net etf value
    case etfActRecord(symbol:String,pageSize : Int,page : Int)//Obtain ETF warehouse adjustment records
    case kycConfig
    case getTradeListByOrder(order_id : String,symbol : String,pageSize : String,page : String)//Obtain historical commission details for coin transactions
    case getLeverTradeListByOrder(order_id : String,symbol : String,pageSize : String,page : String)//Obtain historical commission details for leveraged trading
    case securityFaceToken
    case securityAuthInfo
    case securityAuthCheck(idNumber:String,userName:String,withdrawId:String)
    case gameOpenUrl(gameId:String,token:String)
    case follow_set(trade_currency_id:String,total:String,is_stop_deficit:String,stop_deficit:String,is_stop_profit:String,stop_profit:String,symbol:String,follow_immediately:String,currency:String,timestamp:String,trade_currency:String) //Start tracking
    case follow_stop(follow_id:String,timestamp:String) //End tracking
    case coAgentIndex
    case invitationPageData
    case myInvitationRewards(page: String, pageSize: String)
    case myInvitationPersons(page: String, pageSize: String)
    case spotAgentIndex
    case commonPublic
    case saveAppPushDeveice(cid:String)
    case saveAppPushUser(type:String)
    case userPushSwitch
    case followliveInfo(uid:String)
    case depthChart(symbol:String)
    case tradeListV4(type:String)
    case networkUpload(oldLine:String,newLine:String,netWorkJson:String)
    case userResetPasswordStepOne(accountContext: EXAccountContext)
    case userResetPasswordStepTwo(accountContext: EXAccountContext, code: String?, googleCode: String?, certifcateCode: String?)
    case userResetPasswordStepThree(accountContext: EXAccountContext, password: String)
    case totalAccountBalanceV5//total assets
    case totalAccountBalanceInduceFeatures
    case commonHotCoin
    case updateAllSymbol(symbols:String)//Update all selected currency sorting and batch deletion
    case appRecommendCoin//Recommend popular currencies
    case quantCalBaseAmount(symbol:String,lowP:String,highP:String,gridNumber:String,gridLineType:String,fee:String,totalQuoteAmount:String,currentPrice:String)
    case quantGetAIStrategyInfo(symbol: String)//Query AI Policies
    case quantSaveStrategy(symbol: String, quantType: String, gridLineType: String, gridNumber: String, lowestPrice: String, highestPrice: String, stopHighPrice: String, stopLowPrice: String, totalQuoteAmount: String, useOwnBase: String,fee:String,totalBaseAmount:String)//Save Policy
    case quantGetStrategyList(symbol:String,page:String,status:String,pageSize:String)//Strategic Transaction List
    case quantStopStrategy(strategyId: String)//Stop Policy
    //    /quant/getOrderingGridList
    case quantGetOrderingGridList(strategyId: String)//Querying records of pending orders
    //    /quant/getFinishGridList
    case quantGetFinishGridList(strategyId: String,page:String)//The grid has completed the registration record
    case appHomeAd
    case saveInterfaceData(line:String,duration:String,page:String,action:String,errorType:String)
    case checkEtfTrade
    case readStatusEtfWarn
  
    case freeStaking_index
    case freeStaking_projectlist(configType:String,status:String)
    case freeStaking_projectInfo(pojectId:String)
    case freeStaking_myPos(page:String,pageSize:String,projectType:String,baseCoin:String,strTime:String,entTime:String)
    case freeStaking_incrementapply(amount:String,projectId:String)
    case validateWithInternalTransfer(targetAccount:String)
    case doWithInternalTransfer(targetAccount:String, amount:String, fee:String, symbol:String, smsAuthCode:String?, googleCode:String?,emailAuthCode: String?, capitalPwd: String?)
    case updatePcTradeFeeStatus(status: String)
    case recommendSearchSymbol //Recommended currency pairs on search pages
    case getIpByCode(qrid:String)
    case confirmPCLogin(qrid:String)
    //MARK: Account cancellation related
    case cancellationVerification
    case getDeleteAccountStatus //
    case deleteAccount(smsAuthCode: String?,emailAuthCode: String?,googleCode: String?) //

}


extension AppAPIEndPoint : TargetType {
    
    var baseURL: URL {
        return URL.init(string: EXNetworkDoctor.sharedManager.getAppAPIHost())!
        
//        switch self {
//        case .contract_agent_role:
//            return URL(string: "https://yapi.hiotc.pro/mock/50/co/agent/getAgentUser")!
//        default:
//            return URL.init(string: EXNetworkDoctor.sharedManager.getAppAPIHost())!
//        }
        
        
    }
    
    var path: String {
        switch self {
        case .getAPPValidationConfig:
            return "common/tartCaptchaV2"
        case .sumsubSubmit:
            return "sumsub/call_back"
        case .getKycRightInfo:
            return "sumsub/get_equity"
        case .getKycAuthCurrentLevel:
            return "sumsub/get_max_level"
        case .getkycList:
            return "sumsub/getAuthRecord"
        case .getSumSubAccessToken:
            return "sumsub/getAccessToken"
        case .logOut:
            return "user/login_out"
        case .getRegisterInfo:
            return "cms/info"
        case .cancellationVerification:
            return "cancellation/verification"
        case .deleteAccount:
            return "user/deleteAccount"
        case .getDeleteAccountStatus:
            return "getDeleteAccountStatus"
        case .userUpdatePhoneOrEmail:
            return "user/verify_keyWord"
        case .updatePcTradeFeeStatus:
            return "user/updatePcTradeFeeStatus"
        case .credit_card_payList:
            return "order/otc/credit_card"
        case .pay_submit:
            return "payment_submit"
        case .get_third_support_fiat:
            return "get_third_support_fiat_v2"
        case .get_paycard_rate_list:
            return "get_paycard_rate_list"
        case .get_paycard_num:
            return "get_paycard_num"
        case .limit_ip_login:
            return "limit_ip_login"
        case .inviteConfig:
            return "invitation/publicConfig"
//         return "co/agent/getInviteConfig"
        case .addInvitationedCode:
            return "invitation/addInvitationedCode"
        case .myInvitationsApp:
            return "invitation/myInvitations"
        case .myInvitationRewardsApp:
            return "invitation/myInvitationRewards"
        case .contract_AgentInfo:
            return "co/agent/getAgentInfo"
        case .contract_newAgentInfo:
            return "co/agent/getCoAgentInfo"
        case .contract_agent_role:
            return "co/agent/getAgentUser"
        case.freeStaking_index:
            return "increment/index"
        case .freeStaking_projectlist:
            return "increment/project_list"
        case.freeStaking_projectInfo:
            return "increment/project_info"
        case.freeStaking_myPos:
            return "increment/my_pos"
        case.freeStaking_incrementapply:
            return "increment/project/apply"
            
        case .checkVisitStatus:
            return "common/checkVisitStatus"
        case .publicInfo:
            return "common/public_info_v5"
        case .publicInfoMarket:
            return "common/public_info_market"
        case .publicRate:
            return "common/rate"
        case .listSymbal:
            return "optional/list_symbol"
        case .headerSymbol:
            return "common/header_symbol"
        case.update_symbol:
            return "optional/update_symbol"
        case .getInvitationImgs:
            return "common/getInvitationImgs"
        case .tradeLimitInfo:
            return "order/trade_limit_info"
        case .loginOne:
            return "/v6/user/login_in"
        case .loginTwo:
            return "user/confirm_login"
        case .quickLogin:
            return "app-auth/user/quick_login"
        case .handLogin:
            return "app-auth/user/hand_login"
        case .handOpen(_,_,let afterLogin):
            if afterLogin {
                
                return "auth/app/user/open_hand"
            }else {
                return "auth/app/user/open_hand_two"
            }
        case .getsmsValidCode:
            return "v4/common/smsValidCode"
        //            return "common/smsValidCode"
        case .registGetsmsValidCode:
            return "v4/common/smsValidCode"
        case .getemailVallidCode:
            return "v4/common/emailValidCode"
        //            return "common/emailValidCode"
        case .registGetemailVallidCode:
            return "v4/common/emailValidCode"
        case .userInfo:
            return "common/user_info"
        case .registerOne:
            return "user/register"
        case .registerTwo:
            return "user/valid_code"
        case .registerThree:
            return "user/confirm_pwd"
        case .forgetPwOne:
            return "user/search_step_one"
        case .forgetPwTwo:
            return "user/search_step_two"
        case .forgetPwThree:
            return "user/search_step_three"
        case .forgetPwFour:
            return "user/search_step_four"
        case .updateNickname:
            return "user/nickname_update"
        case .getAbout:
            return "common/aboutUS"
        case .getAppMail:
            return "message/user_message"
        case .getNewEntrustList:
            return "order/list/new"
        case .otcOrderHistory:
            return "order/otc/bystatus_v4"
        case .getHistoryEntrustList:
            return "v4/order/entrust_history"
        case .createOrder:
            return "order/create"
        case .cancelOrder:
            return "order/cancel"
        case .changepassword:
            return "user/password_update_v4"
        case .getGoogle:
            return "user/toopen_google_authenticator"
        case .openGoogle:
            return "user/google_verify"
        case .closeGoogle:
            return "user/close_google_verify"
        case .openMoblieValidation:
            return "user/open_mobile_verify"
        case .closeMoblie:
            return "user/close_mobile_verify"
        case .bindEmail:
            return "user/email_bind_save"
        case .updateEmail:
            return "user/email_update"
        case .updateEmailV6:
            return "user/v6/email_update"
        case .bindPhone:
            return "user/mobile_bind_save"
        case .updatePhone:
            return "user/mobile_update"
        case .openGesture:
            return "auth/app/user/open_hand_one"
        case .closeGesture:
            return "auth/app/user/close_hand"
        case .getmessageType:
            return "message/user_message"
        case .createProblem:
            return "question/create_problem"
        case .getNotice:
            return "notice/notice_info_list"
        case .authRealname:
            return "user/v4/auth_realname"
        case .getNoReadMessageCount:
            return "message/get_no_read_message_count"
        case .getHelp:
            return "cms/list"
        case .financeAccountList:
            return "finance/v4/otc_account_list"
        case .coinIntroduce:
            return "common/coinSymbol_introduce"
        case .getHome:
            return "common/index_v6"
        case .accountBalance:
            return "finance/v5/account_balance"
        case .getChargeAddress:
            return "finance/get_charge_address"
        case .transferScene:
            return "record/ex_transfer_scene_v4"
        case .transferList:
            return "record/ex_transfer_list_v4"
        case .addressList:
            return "addr/address_list"
        case .addWithdrawAddress:
            return "addr/add_withdraw_addr_v5"
        case .doWithDraw:
            return "finance/do_withdraw_v5"
        case .validateWithDrawAddr:
            return "addr/add_withdraw_addr_validate_v4"
        case .financeOtcTransfer:
            return "finance/otc_transfer"
        case .cancelWithDraw:
            return "finance/cancel_withdraw"
        case .depositCancelWithDraw:
            return "fiat/cancel_deposit"
        case .withdrawCancelWithDraw:
            return  "fiat/cancel_withdraw"
        case .deleteWithDrawAddr:
            return "addr/delete_withdraw_addr_v1"
        case .openQuick:
            return "common/check_native_pwd"
        case .messageUpdateStatus:
            return "message/message_update_status"
        case .totalAccountBalance:
            return "finance/total_account_balance"
        case .kycGetToken:
            return "kyc/Api/getToken"
        case .kycGetWriting:
            return "kyc/Api/getUploadImgCopywriting"
        case .getUpdateVersion:
            return "common/getUpdateVersion"
        case .getEntrustHistorySearch:
//            return "order/entrust_search"
        return "lever/order/list/new"
        case .create_overcharge_onekey:
            return "order/create_overcharge_onekey"
        case .b2cBalance:
            return "fiat/balance"
        case .getUserBankList:
            return "user/bank/user_bank_list"
        case .getFiatWithdrawList:
            return "fiat/withdraw/list"
        case .getFiatDepoistList:
            return "fiat/deposit/list"
        case .fiatDeposit:
            return "fiat/deposit"
        case .getAllBank:
            return "bank/all"
        case .getUserBank:
            return "user/bank/get"
        case .fiatWithdraw:
            return "fiat/withdraw"
        case .getCompanyBankInfo:
            return "company/bank/info"
        case .addUserBank:
            return "user/bank/add"
        case .editUserBank:
            return "user/bank/edit"
        case .deleteUserBank:
            return "user/bank/delete"
        case .getLeverBalance:
            return "lever/finance/symbol/balance"
        case .getLeverOrderHistory:
            return "lever/order/history"
        case .getLeverOrderCurrent:
            return "lever/order/list/new"
        case .cancelLeverOrder:
            return "lever/order/cancel"
        case .creatLeverOrder:
            return "lever/order/create"
        case .leverageBalance:
            return "lever/finance/balance"
        case .leverBorrowHistory:
            return "lever/borrow/history"
        case .leverCurrentBorrow:
            return "lever/borrow/new"
        case .leverFinanceBorrow:
            return "lever/finance/borrow"
        case .leverFinanceReturn:
            return "lever/finance/return"
        case .leverFinanceSymbolInfo:
            return "lever/finance/symbol/balance"
        case .leverTransferRecord:
            return "lever/finance/transfer/list"
        case .leverFinanceTransfer:
            return "lever/finance/transfer"
        case .leverReturnInfo:
            return "lever/return/info"
        case .swapTransfer:
            return "app/co_transfer"
        case .coinToFuturesTransfer:
            return "app/co_transfer"
            
        case .getCost:
            return "cost/Getcost"
        case .etfFaqInfo:
            return "etfAct/faqInfo"
        case .etfNetValue:
            return "etfAct/netValue"
        case .etfActRecord:
            return "etfAct/positionRecordList"
        case .kycConfig:
            return "kyc/config"
        case .getTradeListByOrder:
            return "trade/list_by_order"
        case .getLeverTradeListByOrder:
            return "lever/trade/list_by_order"
        case .securityFaceToken:
            return "security/get_face_token"
        case .securityAuthInfo:
            return "security/get_identity_auth_info"
        case .securityAuthCheck:
            return "security/identity_auth_info_check"
        case .gameOpenUrl:
            return "game/appplay"
        case .follow_set:
            return "inner/follow/set"
        case .follow_stop:
            return "inner/follow/stop"
        case .commonPublic:
            return "app-increment-api/common/public"
        case .coAgentIndex:
            if EXAppConfigManager.sharedInstance.getContractVersion() == .new {
                return "app-increment-api/v2/co/agent/index"
            }else {
                return "app-increment-api/co/agent/index"
            }
        case .spotAgentIndex:
            return "agentV2/agent_data_query"
        case .invitationPageData:
            return "app-increment-api/invitation/pageConfig"
        case .myInvitationRewards:
            return "app-increment-api/invitation/myInvitationRewards"
        case .myInvitationPersons:
            return "app-increment-api/invitation/myInvitations"
        case .saveAppPushDeveice:
            return "appPush/saveAppPushDevice"
        case .userPushSwitch:
            return "appPush/userPushSwitch"
        case .saveAppPushUser:
            return "appPush/saveAppPushUser"
        case .followliveInfo:
            return "app-increment-api/co/trade/income_info"
        case .depthChart:
            return "common/depth_map"
        case .tradeListV4:
            return "common/trade_list_v6"
        case .networkUpload:
            return "appNetwork/upload"
        case .userResetPasswordStepOne(_):
            return "user/reset_password_step_one"
        case .userResetPasswordStepTwo:
            return "user/reset_password_step_two"
        case .userResetPasswordStepThree:
            return "user/reset_password_step_three"
        case .totalAccountBalanceV5:
            return "finance/v5/total_account_balance"
        case .totalAccountBalanceInduceFeatures:
            return "finance/features/total_account_balance"
        case .commonHotCoin:
            return "common/hot_coin"
        case .updateAllSymbol:
            return "optional/update_all_symbol"
        case .appRecommendCoin:
            return "common/recommend_coin"
        case .quantCalBaseAmount:
            return "app-quant-api/quant/calBaseAmount"
        case .quantGetAIStrategyInfo:
            return "app-quant-api/noToken/quant/getAIStrategyInfo"
        case .quantSaveStrategy:
            return "app-quant-api/quant/saveStrategy"
        case .quantStopStrategy:
            return "app-quant-api/quant/stopStrategy"
        case .quantGetOrderingGridList:
            return "app-quant-api/quant/getOrderingGridList"
        case .quantGetFinishGridList:
            return "app-quant-api/quant/getFinishGridList"
        case .quantGetStrategyList:
            return "app-quant-api/quant/getStrategyList"
        case .appHomeAd:
            return "homepage_Elastic_Layer"
        case .saveInterfaceData:
            return "save_interface_data"
        case .checkEtfTrade:
            return "etfAct/checkEtfTrade"
        case .readStatusEtfWarn:
            return "etfAct/readStatusEtfWarn"
        case .validateWithInternalTransfer:
            return "inner_transfer/user_auth"
        case .doWithInternalTransfer:
            return "/inner_transfer/do_withdraw_v1"
        case .getRateDiscout:
            return "user/pc_banner"
        case .recommendSearchSymbol:
            return "common/recommend_symbol"
        case .getIpByCode:
            return "get_ip_by_qrcode"
        case .confirmPCLogin:
            return "confirm_pc_login"
        }
    }
    
    var method: Moya.Method {        
        switch self {
        case .getAbout:
            return .get
        default:
            return .post
        }
    }
    
    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    var task: Task {
        var parameters: [String: Any] = [:]
        switch self {
        case .sumsubSubmit(let level):
            parameters["sumsubLevel"] = level
        case .getKycRightInfo(let symbol):
            parameters["symbol"] = symbol
        case .getSumSubAccessToken(let level):
            parameters["sumsubLevel"] = level
        case .getRegisterInfo:
            parameters["fileName"] = "agreement"
        case .getDeleteAccountStatus:
            break
        case .deleteAccount(let phone, let email, let ga):
            if phone != nil{
                parameters["smsAuthCode"] = phone
            }
            if email != nil{
                parameters["emailAuthCode"] = email
            }
            if ga != nil{
                parameters["googleCode"] = ga
            }
            break
        case .userUpdatePhoneOrEmail(let keyword,let isPhone):
            let pa = isPhone ? "1" : "0"
            parameters["keyWord"] = keyword
            parameters["isPhone"] = pa
        case .getRateDiscout(let userId):
            if userId != nil {
                parameters["userId"] = userId
            }
        case .updatePcTradeFeeStatus(let status):
            parameters["status"] = status
        case .credit_card_payList(let page, let pageSize):
            parameters["page"] = page
            parameters["pageSize"] = pageSize
            break
        case .pay_submit(let quote_id, let name, let coin, let num, let base_amount, let total_amount, let amount,let fiat,let rate,let transferType):
            parameters["quote_id"] = quote_id
            parameters["name"] = name
            parameters["coin"] = coin
            parameters["num"] = num
            parameters["base_amount"] = base_amount
            parameters["sourceAmount"] = total_amount
            parameters["targetAmount"] = amount
            parameters["total_amount"] = total_amount
            parameters["amount"] = amount
            parameters["fiat"] = fiat
            parameters["rate"] = rate
            parameters["transferType"] = transferType
            parameters["successUrl"] = quickTradeBanxaSuccessfulUrl
            parameters["failUrl"] = quickTradeBanxaFailedUrl
            break
        case .get_third_support_fiat(let transferType):
            parameters["transferType"] = transferType
        case .get_paycard_rate_list(let fiat, let coin,let transferType):
            parameters["fiat"] = fiat
            parameters["coin"] = coin
            parameters["transferType"] = transferType
            break
        case .get_paycard_num(let fiat,let coin, let num,let name,let transferType):
            parameters["fiat"] = fiat
            parameters["coin"] = coin
            parameters["num"] = num
            parameters["name"] = name
            parameters["transferType"] = transferType
            break
        case .contract_agent_role(let uid):
            parameters["uid"] = uid
        case .inviteConfig:
            break
        case .addInvitationedCode(let invitedCode):
            parameters["invitedCode"] = invitedCode
            break
        case .myInvitationsApp(let pageSize, let page):
            parameters["pageSize"] = pageSize
            parameters["page"] = page
            break
        case .myInvitationRewardsApp(let pageSize, let page):
            parameters["pageSize"] = pageSize
            parameters["page"] = page
            break
        case .checkVisitStatus:
            break
        case .publicInfo:
            break
        case .publicInfoMarket:
            break
        case .publicRate(let symbol):
            if symbol.count > 0 {
                parameters["fiat"] = symbol
            }
            break
        case .listSymbal:
            break
        case .headerSymbol:
            break
        case.update_symbol(let operationType, let symbols):
            parameters["operationType"] = operationType
            parameters["symbols"] = symbols
        case .getInvitationImgs:
            break
        case .tradeLimitInfo(let symbol):
            parameters["symbol"] = symbol
        case .loginOne(let countryCode,let mobileNumber, let loginPword):
            parameters["countryCode"] = countryCode
            parameters["mobileNumber"] = mobileNumber
            parameters["loginPword"] = loginPword
            parameters = self.appendCaptchaInfo(original: parameters)
        case .loginTwo(let token , let checkType , let authCode, let googleCode, let smsCode, let emailCode, let idCardCode):
            parameters["token"] = token
            parameters["checkType"] = checkType
            parameters["authCode"] = authCode
            if let gCode = googleCode {
                parameters["googleCode"] = gCode
            }
            if let sCode = smsCode {
                parameters["smsCode"] = sCode
            }
            if let eCode = emailCode {
                parameters["emailCode"] = eCode
            }
            if let idCode = idCardCode {
                parameters["idCardCode"] = idCode
            }
        case .quickLogin(let quickToken):
            parameters["quicktoken"] = quickToken
        case .handLogin(let quickToken ,let handPwd):
            parameters["quicktoken"] = quickToken
            parameters["handPwd"] = handPwd
        case .handOpen(let quickToken ,let handPwd, let afterLogin):
            if afterLogin {
                parameters["quicktoken"] = quickToken
                
            }else {
                parameters["token"] = quickToken
            }
            parameters["handPwd"] = handPwd
        case .getsmsValidCode(let token , let operationType , let countryCode , let mobile):
            if token != ""{
                parameters["token"] = token
            }
            if countryCode != ""{
                parameters["countryCode"] = countryCode
            }
            if mobile != ""{
                parameters["mobile"] = mobile
            }
            parameters["operationType"] = operationType
        case .registGetsmsValidCode(let token ,let operationType ,let countryCode ,let mobile):
            if token != ""{
                parameters["token"] = token
            }
            if countryCode != ""{
                parameters["countryCode"] = countryCode
            }
            if mobile != ""{
                parameters["mobile"] = mobile
            }
            parameters["operationType"] = operationType
            
        case .registGetemailVallidCode(let email,let operationType,let token):
            if email != ""{
                parameters["email"] = email
            }
            parameters["operationType"] = operationType
            if token != ""{
                parameters["token"] = token
            }
        case .getemailVallidCode(let email , let operationType , let token):
            if email != ""{
                parameters["email"] = email
            }
            parameters["operationType"] = operationType
            if token != ""{
                parameters["token"] = token
            }
        case .userInfo:
            break
        case .registerOne(let  email  ,let  mobile ,let  country ):
            if email != ""{
                parameters["email"] = email
            }
            if mobile != ""{
                parameters["mobile"] = mobile
            }
            if country != ""{
                parameters["country"] = country
            }
            parameters = self.appendCaptchaInfo(original: parameters)
        case .registerTwo(let registerCode , let numberCode):
            parameters["registerCode"] = registerCode
            parameters["numberCode"] = numberCode
        case .registerThree(let registerCode ,let loginPword ,let newPassword ,let invitedCode):
            parameters["registerCode"] = registerCode
            parameters["loginPword"] = loginPword
            parameters["newPassword"] = newPassword
            parameters["invitedCode"] = invitedCode
        case .forgetPwOne(let registerCode):
            parameters["registerCode"] = registerCode
            parameters = self.appendCaptchaInfo(original: parameters)
        case .forgetPwTwo(let token ,let numberCode):
            parameters["token"] = token
            parameters["numberCode"] = numberCode
        case .forgetPwThree(let token ,let certifcateNumber ,let googleCode):
            parameters["token"] = token
            if certifcateNumber != ""{
                parameters["certifcateNumber"] = certifcateNumber
            }
            if googleCode != ""{
                parameters["googleCode"] = googleCode
            }
        case .forgetPwFour(let token ,let loginPword ,let newPassword ):
            parameters["token"] = token
            parameters["loginPword"] = loginPword
            parameters["newPassword"] = newPassword
        case .updateNickname(let nickname):
            parameters["nickname"] = nickname
        case .getAbout:
            break
        case .getAppMail(let messageType ,let pageSize ,let page):
            parameters["messageType"] = messageType
            parameters["pageSize"] = pageSize
            parameters["page"] = page
        case .getNewEntrustList(let symbol, let pageSize , let page, let side, let type):
            parameters["symbol"] = symbol
            parameters["pageSize"] = pageSize
            parameters["page"] = page
            parameters["side"] = side
            parameters["type"] = type
        case .otcOrderHistory(let page,let type, let symbol, let currency,let status,let begin,let end,let pageSize):
            parameters["page"] = page
            if let size = pageSize {
                parameters["pageSize"] = size
            }else {
                parameters["pageSize"] = "20"
            }
            
            if let symbol = symbol,!symbol.isEmpty {
                parameters["coinSymbol"] = symbol
            }
            if let currency = currency, currency != "ALL",currency.count > 0 {
                parameters["payCoin"] = currency
            }
            if let status = status, status != "ALL" {
                parameters["status"] = status
            }
            if let tradeType = type, tradeType != "ALL" {
                parameters["tradeType"] = tradeType
            }
//            if let startTime = begin, let endTime = end,startTime.count > 0, endTime.count > 0 {
//                parameters["startTimeMillis"] = startTime
//                parameters["endTImeMillis"] = endTime
//            }
            parameters["startTimeMillis"] = begin ?? ""
            parameters["endTImeMillis"] = end ?? ""
            break
        case .getHistoryEntrustList(let symbol, let pageSize , let page ,let isShowCanceled ,let side ,let type ,let startTime ,let endTime, let status):
            parameters["symbol"] = symbol
            parameters["pageSize"] = pageSize
            parameters["page"] = page
            parameters["isShowCanceled"] = isShowCanceled
            parameters["side"] = side
            parameters["type"] = type
            parameters["startTimeMillis"] = startTime
            parameters["endTImeMillis"] = endTime
            parameters["status"] = status
        case .createOrder(let side ,let type ,let volume ,let price ,let symbol):
            parameters["side"] = side
            parameters["type"] = type
            parameters["volume"] = volume
            parameters["price"] = price
            parameters["symbol"] = symbol
        case .cancelOrder(let orderId ,let symbol):
            parameters["orderId"] = orderId
            parameters["symbol"] = symbol
        case .changepassword(let loginPword ,let newLoginPword ,let smsAuthCode ,let googleCode , let IdentificationNumber):
            parameters["loginPword"] = loginPword
            parameters["newLoginPword"] = newLoginPword
            parameters["smsAuthCode"] = smsAuthCode
            parameters["googleCode"] = googleCode
            if IdentificationNumber != ""{
                parameters["IdentificationNumber"] = IdentificationNumber
            }
        case .getGoogle:
            break
        case .openGoogle(let loginPwd ,let googleCode ,let googleKey):
            parameters["loginPwd"] = loginPwd
            parameters["googleCode"] = googleCode
            parameters["googleKey"] = googleKey
        case .closeGoogle(let smsValidCode ,let googleCode):
            parameters["smsValidCode"] = smsValidCode
            parameters["googleCode"] = googleCode
        case .openMoblieValidation:
            break
        case .closeMoblie(let smsValidCode ,let googleCode):
            parameters["smsValidCode"] = smsValidCode
            parameters["googleCode"] = googleCode
        case .bindEmail(let smsValidCode,let googleCode,let emailValidCode,let email):
            parameters["smsValidCode"] = smsValidCode
            parameters["googleCode"] = googleCode
            parameters["emailValidCode"] = emailValidCode
            parameters["email"] = email
        case .updateEmail(let emailOldValidCode,let emailNewValidCode,let smsValidCode,let googleCode,let emailValidCode,let email):
            parameters["emailOldValidCode"] = emailOldValidCode
            parameters["emailNewValidCode"] = emailNewValidCode
            parameters["smsValidCode"] = smsValidCode
            parameters["googleCode"] = googleCode
            parameters["emailValidCode"] = emailValidCode
            parameters["email"] = email
            
        case .updateEmailV6(let emailOldValidCode,let emailNewValidCode,let smsValidCode,let googleCode,let emailValidCode,let email):
            parameters["emailOldValidCode"] = emailOldValidCode
            parameters["emailNewValidCode"] = emailNewValidCode
            parameters["smsValidCode"] = smsValidCode
            parameters["googleCode"] = googleCode
//            parameters["emailValidCode"] = emailValidCode
            parameters["email"] = email
        case .bindPhone(let googleCode ,let countryCode ,let mobileNumber ,let smsAuthCode):
            if googleCode != ""{
                parameters["googleCode"] = googleCode
            }
            parameters["countryCode"] = countryCode
            parameters["mobileNumber"] = mobileNumber
            parameters["smsAuthCode"] = smsAuthCode
        case .updatePhone(let authenticationCode ,let googleCode ,let countryCode ,let mobileNumber ,let smsAuthCode):
            parameters["googleCode"] = googleCode
            parameters["countryCode"] = countryCode
            parameters["mobileNumber"] = mobileNumber
            parameters["smsAuthCode"] = smsAuthCode
            parameters["authenticationCode"] = authenticationCode
        case .openGesture(let loginPwd,let smsValidCode,let googleCode , let uid):
            parameters["loginPwd"] = loginPwd
            if smsValidCode != ""{
                parameters["smsValidCode"] = smsValidCode
            }
            if googleCode != ""{
                parameters["googleCode"] = googleCode
            }
            parameters["uid"] = uid
            parameters["nativePwd"] = loginPwd
        case .closeGesture(let loginPwd,let smsValidCode,let googleCode):
            parameters["loginPwd"] = loginPwd
            parameters["smsValidCode"] = smsValidCode
            parameters["googleCode"] = googleCode
        case .getmessageType(let messageType):
            parameters["messageType"] = messageType
        case .createProblem(let rqType, let rqDescribe, let imageDataStr, let rqUnreleased, let rqUnpaid):
            parameters["rqType"] = rqType
            parameters["rqDescribe"] = rqDescribe
            if let imgUrl = imageDataStr {
                parameters["imageDataStr"] = imgUrl
            }
            if let unreleased = rqUnreleased {
                parameters["rqUnreleased"] = unreleased
            }
            if let unpaid = rqUnpaid {
                parameters["rqUnpaid"] = unpaid
            }
        case .getNotice(let page,let pagesize):
            parameters["page"] = page
            parameters["pagesize"] = pagesize
        case .authRealname(let countryCode ,let certificateType ,let userName ,let certificateNumber ,let firstPhoto ,let secondPhoto ,let thirdPhoto , let familyName , let name , let numberCode):
            parameters["countryCode"] = countryCode
            parameters["certificateType"] = certificateType
            if userName != ""{
                parameters["userName"] = userName
            }
            if familyName != ""{
                parameters["familyName"] = familyName
            }
            if name != ""{
                parameters["name"] = name
            }
            parameters["certificateNumber"] = certificateNumber
            parameters["firstPhoto"] = firstPhoto
            parameters["secondPhoto"] = secondPhoto
            parameters["thirdPhoto"] = thirdPhoto
            parameters["numberCode"] = numberCode
        case .getNoReadMessageCount:
            break
        case .getHelp:
            break
        case .financeAccountList:
            break
        case .coinIntroduce(let coinSymbol):
            parameters["coinSymbol"] = coinSymbol
        case .getHome:
            if EXHomeViewModel.isContractStatus() {
                parameters["type"] = "2"
            }
            
            if EXAppConfigManager.sharedInstance.getContractVersion() == .new {
                parameters["coVersion"] = "1"
            }
            if EXThemeManager.isNight() {
                parameters["timeType"] = "2"
            }else {
                parameters["timeType"] = "1"
            }
            break
        case .accountBalance(let coinsymbols):
            if let symbol = coinsymbols {
                parameters["coinSymbols"] = symbol
            }
            break
        case .getChargeAddress(let symbol):
            parameters["symbol"] = symbol
        case .transferScene:
            break
        case .transferList(let coinSymbol, let transactionScene, let startTime, let endTime, let page):
            parameters["transactionScene"] = transactionScene
            parameters["page"] = page
            parameters["pageSize"] = "20"
            if let begin = startTime, let end = endTime {
                parameters["startTimeMillis"] = begin
                parameters["endTImeMillis"] = end
            }
            if let symbol = coinSymbol {
                parameters["coinSymbol"] = symbol
            }
        case .addressList(let coinSymbol):
            parameters["coinSymbol"] = coinSymbol
        case .addWithdrawAddress(let address, let label, let smsValidCode,let emailValidCode, let googleCode, let coinSymbol, let trust):
            parameters["address"] = address
            parameters["coinSymbol"] = coinSymbol
            parameters["label"] = label
            parameters["trustType"] = trust ? "1" : "0"
            if let sms = smsValidCode {
                parameters["smsValidCode"] = sms
            }
            if let emailCode = emailValidCode {
                parameters["emailValidCode"] = emailCode
            }
            if let google = googleCode {
                parameters["googleValidCode"] = google
            }
        case .doWithDraw(let address, let trustType, let remark, let symbol, let fee,let amount,let smsVaildCode, let googleValidCode, let emailValidCode, let addressID,let capitalPwd):
            parameters["address"] = address
            parameters["label"] = remark
            parameters["symbol"] = symbol
            parameters["fee"] = fee
            parameters["amount"] = amount
            parameters["capitalPassword"] = capitalPwd
            if let trust = trustType {
                parameters["trustType"] = trust
            }
            if let sms = smsVaildCode {
                parameters["smsValidCode"] = sms
            }
            if let emailCode = emailValidCode {
                parameters["emailValidCode"] = emailCode
            }
            if let google = googleValidCode {
                parameters["googleCode"] = google
            }
            if let addressid = addressID,addressid.count > 0 {
                parameters["addressId"] = addressid
            }
        case .validateWithDrawAddr(let address, let symbol):
            parameters["address"] = address
            parameters["coinSymbol"] = symbol
        case .financeOtcTransfer(let fromAccount, let toAccount, let amount, let coinSymbol):
            parameters["fromAccount"] = fromAccount
            parameters["toAccount"] = toAccount
            parameters["amount"] = amount
            parameters["coinSymbol"] = coinSymbol
        case .cancelWithDraw(let withDrawId):
            parameters["withdrawId"] = withDrawId
        case .depositCancelWithDraw(let withDrawId):
            parameters["id"] = withDrawId
        case .withdrawCancelWithDraw(let withDrawId):
            parameters["id"] = withDrawId
        case .deleteWithDrawAddr(let ids, let googleCode, let smsCode,let emailCode):
            parameters["ids"] = ids
            parameters["googleCode"] = googleCode
            parameters["smsValidCode"] = smsCode
            parameters["emailAuthCode"] = emailCode
        case .openQuick(let loginPwd,let smsValidCode,let googleCode , let uid):
            parameters["loginPwd"] = loginPwd
            if smsValidCode != ""{
                parameters["smsValidCode"] = smsValidCode
            }
            if googleCode != ""{
                parameters["googleCode"] = googleCode
            }
            parameters["uid"] = uid
            parameters["nativePwd"] = loginPwd
        case .messageUpdateStatus(let id):
            parameters["id"] = id
        case .totalAccountBalance, .totalAccountBalanceV5, .totalAccountBalanceInduceFeatures:
            break
        case .kycGetToken:
            break
        case .kycGetWriting:
            break
        case .getUpdateVersion:
            break
        case .getEntrustHistorySearch(let page ,let pageSize ,let entrust ,let side ,let symbol ,let orderType ,let status ,let isShowCanceled ,let quote ,let type):
            parameters["page"] = page
            parameters["pageSize"] = pageSize
            parameters["entrust"] = entrust
            parameters["orderType"] = orderType
            
            if side != ""{
                parameters["side"] = side
            }
            if symbol != ""{
                parameters["symbol"] = symbol
            }
            if status != ""{
                parameters["status"] = status
            }
            if isShowCanceled != ""{
                parameters["isShowCanceled"] = isShowCanceled
            }
            if quote != ""{
                parameters["quote"] = quote
            }
            if type != ""{
                parameters["type"] = type
            }
        case .create_overcharge_onekey(let symbol):
            parameters["symbol"] = symbol
        case .b2cBalance(let symbol) :
            if symbol != ""{
                parameters["symbol"] = symbol
            }
        case .getUserBankList(let symbol, let page, let pageSize):
            parameters["symbol"] = symbol
            parameters["page"] = page
            parameters["pageSize"] = pageSize
        case .getFiatWithdrawList(let symbol ,let page ,let pageSize,let startTime ,let endTime):
            parameters["symbol"] = symbol
            parameters["page"] = page
            parameters["pageSize"] = pageSize
            if let startTime = startTime,startTime.count > 0{
                parameters["startTimeMillis"] = startTime
            }
            if let endTime = endTime, endTime.count > 0 {
                parameters["endTImeMillis"] = endTime
            }
        case .getFiatDepoistList(let symbol ,let page ,let pageSize,let startTime ,let endTime):
            parameters["symbol"] = symbol
            parameters["page"] = page
            parameters["pageSize"] = pageSize
            if let startTime = startTime,startTime.count > 0{
                parameters["startTimeMillis"] = startTime
            }
            if let endTime = endTime, endTime.count > 0 {
                parameters["endTImeMillis"] = endTime
            }
        case .fiatDeposit(let symbol ,let transferVoucher ,let amount):
            parameters["symbol"] = symbol
            parameters["transferVoucher"] = transferVoucher
            parameters["amount"] = amount
        case .getAllBank(let symbol):
            parameters["symbol"] = symbol
        case .getUserBank(let id):
            parameters["id"] = id
        case .fiatWithdraw(let symbol,let userWithdrawBankId ,let amount ,let smsAuthCode ,let googleCode):
            parameters["symbol"] = symbol
            parameters["userWithdrawBankId"] = userWithdrawBankId
            parameters["amount"] = amount
            if smsAuthCode != ""{
                parameters["smsAuthCode"] = smsAuthCode
            }
            if googleCode != ""{
                parameters["googleCode"] = googleCode
            }
        case .getCompanyBankInfo(let symbol):
            parameters["symbol"] = symbol
        case .addUserBank(let bankId,let bankSub,let cardNo,let name,let symbol,let smsAuthCode,let googleCode):
            parameters["bankId"] = bankId
            parameters["bankSub"] = bankSub
            parameters["cardNo"] = cardNo
            parameters["name"] = name
            parameters["symbol"] = symbol
            if smsAuthCode != ""{
                parameters["smsAuthCode"] = smsAuthCode
            }
            if googleCode != ""{
                parameters["googleCode"] = googleCode
            }
        case .editUserBank(let id,let bankId,let bankSub,let cardNo,let name,let symbol,let smsAuthCode,let googleCode):
            parameters["id"] = id
            parameters["bankId"] = bankId
            parameters["bankSub"] = bankSub
            parameters["cardNo"] = cardNo
            parameters["name"] = name
            parameters["symbol"] = symbol
            if smsAuthCode != ""{
                parameters["smsAuthCode"] = smsAuthCode
            }
            if googleCode != ""{
                parameters["googleCode"] = googleCode
            }
        case .deleteUserBank(let id):
            parameters["id"] = id
        case .getLeverBalance(let symbol):
            parameters["symbol"] = symbol
        case .getLeverOrderHistory(let page ,let pageSize ,let symbol ,let isShowCanceled ,let side , let type, let status):
            parameters["page"] = page
            parameters["pageSize"] = pageSize
            parameters["symbol"] = symbol
            if isShowCanceled != ""{
                parameters["isShowCanceled"] = isShowCanceled
            }
            if side != ""{
                parameters["side"] = side
            }
            if type != ""{
                parameters["type"] = type
            }
            parameters["status"] = status
        case .getLeverOrderCurrent(let symbol ,let pageSize ,let page):
            parameters["page"] = page
            parameters["pageSize"] = pageSize
            parameters["symbol"] = symbol
        case .cancelLeverOrder(let orderId ,let symbol):
            parameters["orderId"] = orderId
            parameters["symbol"] = symbol
        case .creatLeverOrder(let side ,let type ,let volume ,let price ,let symbol):
            parameters["side"] = side
            parameters["type"] = type
            parameters["volume"] = volume
            parameters["price"] = price
            parameters["symbol"] = symbol
        case .leverageBalance:
            break
        case let .leverBorrowHistory(symbol, startTime, endTime, page, pageSize):
            parameters["symbol"] = symbol
            parameters["page"] = page
            if let startTime = startTime,let endTime = endTime,startTime.count > 0, endTime.count > 0 {
                parameters["startTimeMillis"] = startTime
                parameters["endTImeMillis"] = endTime
            }
            if let pageSize = pageSize {
                parameters["pageSize"] = pageSize
            }else {
                parameters["pageSize"] = "20"//default
            }
        case let .leverCurrentBorrow(symbol, startTime, endTime, page, pageSize):
            parameters["symbol"] = symbol
            parameters["page"] = page
            if let startTime = startTime,let endTime = endTime,startTime.count > 0, endTime.count > 0 {
                parameters["startTimeMillis"] = startTime
                parameters["endTImeMillis"] = endTime
            }
            if let pageSize = pageSize {
                parameters["pageSize"] = pageSize
            }else {
                parameters["pageSize"] = "20"//default
            }
        case let .leverFinanceBorrow(symbol, coin, amount):
            parameters["symbol"] = symbol
            parameters["coin"] = coin
            parameters["amount"] = amount
        case let .leverFinanceReturn(id, amount):
            parameters["id"] = id
            parameters["amount"] = amount
        case let .leverFinanceSymbolInfo(symbol):
            parameters["symbol"] = symbol
        case let .leverTransferRecord(symbol,coinSymbol, transactionType, page, pageSize):
            parameters["symbol"] = symbol
            parameters["coinSymbol"] = coinSymbol
            parameters["transactionType"] = transactionType
            parameters["page"] = page
            if let pageSize = pageSize {
                parameters["pageSize"] = pageSize
            }
        case let .leverFinanceTransfer(fromAccount, toAccount, amount, coinSymbol, symbol):
            parameters["fromAccount"] = fromAccount
            parameters["toAccount"] = toAccount
            parameters["amount"] = amount
            parameters["coinSymbol"] = coinSymbol
            parameters["symbol"] = symbol
        case let .leverReturnInfo(id, page, pageSize):
            parameters["id"] = id
            parameters["page"] = page
            if let pageSize = pageSize {
                parameters["pageSize"] = pageSize
            }
        case let .swapTransfer(type, amount, bound):
            parameters["transferType"] = type
            parameters["amount"] = amount
            parameters["coinSymbol"] = bound
            break
        case .coinToFuturesTransfer( let amount, let coinSymbol,let type):
            parameters["amount"] = amount
            parameters["coinSymbol"] = coinSymbol
            parameters["transferType"] = type
        case let .getCost(symbol):
            parameters["symbol"] = symbol
        case .etfFaqInfo:
            break
        case .etfNetValue(let base , let quote):
            parameters["base"] = base
            parameters["quote"] = quote
        case .etfActRecord(let symbol, let pageSize,let page):
            parameters["symbol"] = symbol
            parameters["pageSize"] = pageSize
            parameters["page"] = page
        case .kycConfig:
            break
        case .getTradeListByOrder(let order_id,let symbol ,let pageSize ,let page):
            parameters["order_id"] = order_id
            parameters["symbol"] = symbol
            parameters["pageSize"] = pageSize
            parameters["page"] = page
        case .getLeverTradeListByOrder(let order_id,let symbol ,let pageSize ,let page):
            parameters["order_id"] = order_id
            parameters["symbol"] = symbol
            parameters["pageSize"] = pageSize
            parameters["page"] = page
        case .securityAuthInfo:
            break
        case .securityFaceToken:
            break
        case .securityAuthCheck(let idNumber, let userName, let withdrawId):
            parameters["idNumber"] = idNumber
            parameters["userName"] = userName
            parameters["withdrawId"] = withdrawId
            break
        case let .gameOpenUrl(gameId,token):
            parameters["gameId"] = gameId
            parameters["token"] = token
            break
        case .follow_set(let trade_currency_id,let  total,let  is_stop_deficit, let  stop_deficit,let  is_stop_profit,let  stop_profit,let  symbol, let  follow_immediately, let currency, let timestamp, let trade_currency):
            parameters["trade_currency_id"] = trade_currency_id
            parameters["total"] = total
            parameters["is_stop_deficit"] = is_stop_deficit
            parameters["stop_deficit"] = stop_deficit
            parameters["is_stop_profit"] = is_stop_profit
            parameters["stop_profit"] = stop_profit
            parameters["symbol"] = symbol
            parameters["follow_immediately"] = follow_immediately
            parameters["currency"] = currency
            parameters["timestamp"] = timestamp
            parameters["trade_currency"] = trade_currency
            break
        case .follow_stop(let follow_id, let timestamp):
            parameters["follow_id"] = follow_id
            parameters["timestamp"] = timestamp
            break
        case .coAgentIndex:
            break
        case .spotAgentIndex:
            parameters["coinName"] = "USDT"
            break;
        case .invitationPageData:
            
            break
        case .myInvitationRewards(let page, let pageSize):
            parameters["pageSize"] = pageSize
            parameters["page"] = page
            break
        case .myInvitationPersons(let page, let pageSize):
            parameters["pageSize"] = pageSize
            parameters["page"] = page
            break
        case .commonPublic:
            break
        case .saveAppPushDeveice(let cid):
            parameters["cid"] = cid
        case .userPushSwitch:
            break
        case .saveAppPushUser(let type):
            parameters["type"] = type
            break
        case .followliveInfo(let uid):
            parameters["uid"] = uid
            break
        case .depthChart(let symbol):
            parameters["symbol"] = symbol
        case .tradeListV4(let type):
            parameters["type"] = type
        case .networkUpload(let oldLine, let newLine, let netWorkJson):
            parameters["oldLine"] = oldLine
            parameters["newLine"] = newLine
            parameters["network_line_json"] = netWorkJson
        case .updateAllSymbol(let symbols):
            parameters["symbols"] = symbols
        case .appRecommendCoin:
            break
        case .userResetPasswordStepOne(accountContext: let accountContext):
            
            if accountContext.account.isEmail() {
                parameters["email"] = accountContext.account
            }
            else if accountContext.account.isPhone() {
                parameters["mobileNumber"] = accountContext.account
                
                if accountContext.countryCode.isEmpty == false{
                    parameters["countryCode"] = accountContext.countryCode
                }
            }
            
            parameters = appendCaptchaInfo(original: parameters)
        case .userResetPasswordStepTwo(accountContext: let accountContext, code: let code, googleCode: let googleCode, certifcateCode: let certifacateCode):
            if accountContext.account.isEmail() {
                parameters["emailCode"] = code
                parameters["email"] = accountContext.account
            }
            else if accountContext.account.isPhone() {
                parameters["smsCode"] = code
                parameters["mobileNumber"] = accountContext.account
            }
            if certifacateCode != nil && certifacateCode!.count > 0  {
                parameters["certifcateNumber"] = certifacateCode
            }
            if googleCode != nil && googleCode!.count > 0 {
                parameters["googleCode"] = googleCode
            }
            parameters["token"] = accountContext.token
        case .userResetPasswordStepThree(accountContext: let accountContext, password: let password):
            parameters["token"] = accountContext.token
            parameters["loginPword"] = password
        case .commonHotCoin:
            break
        case .quantGetAIStrategyInfo(let symbol):
            parameters["symbol"] = symbol
        case .quantCalBaseAmount(let symbol, let lowP, let highP, let gridNumber, let gridLineType, let fee, let totalQuoteAmount, let currentPrice):
            parameters["symbol"] = symbol
            parameters["gridLineType"] = gridLineType
            parameters["gridNumber"] = gridNumber
            parameters["lowestPrice"] = lowP
            parameters["highestPrice"] = highP
            parameters["totalQuoteAmount"] = totalQuoteAmount
            parameters["currentPrice"] = currentPrice
            parameters["fee"] = fee
        case .quantSaveStrategy(let symbol, let quantType, let gridLineType, let gridNumber, let lowestPrice, let highestPrice, let stopHighPrice, let stopLowPrice, let totalQuoteAmount, let useOwnBase,let fee,let totalBaseAmount):
            parameters["symbol"] = symbol
            parameters["quantType"] = quantType
            parameters["gridLineType"] = gridLineType
            parameters["gridNumber"] = gridNumber
            parameters["lowestPrice"] = lowestPrice
            parameters["highestPrice"] = highestPrice
            parameters["totalQuoteAmount"] = totalQuoteAmount
            parameters["useOwnBase"] = useOwnBase
            parameters["fee"] = fee
            parameters["totalBaseAmount"] = totalBaseAmount
            if stopHighPrice.count > 0 {
                parameters["stopHighPrice"] = stopHighPrice
            }else {
                parameters["stopHighPrice"] = "0"
            }
            
            if stopLowPrice.count > 0 {
                parameters["stopLowPrice"] = stopLowPrice
            }else {
                parameters["stopLowPrice"] = "0"
            }
        case .quantStopStrategy(let strategyId):
            parameters["strategyId"] = strategyId
        case .quantGetOrderingGridList(let strategyId):
            parameters["strategyId"] = strategyId
        case .quantGetFinishGridList(let strategyId,let page):
            parameters["strategyId"] = strategyId
            parameters["page"] = page
            parameters["pageSize"] = "20"
        case .quantGetStrategyList(let symbol,let page,let status,let pageSize):
            parameters["symbol"] = symbol
            parameters["page"] = page
            parameters["pageSize"] = pageSize
            parameters["status"] = status
        case .appHomeAd:
            parameters["terminalType"] = "2"
            break
        case .saveInterfaceData(let line, let duration, let page, let action, let errorType):
            parameters["line"] = line
            parameters["duration"] = duration
            parameters["page"] = page
            parameters["action"] = action
            parameters["errorType"] = errorType
            break
        case .checkEtfTrade:
            break
        case .readStatusEtfWarn:
            break
        case .freeStaking_index:
            break
        case.freeStaking_projectlist(let configType,let status):
            parameters["configType"] = configType
            parameters["status"] = status
        case.freeStaking_projectInfo(let projecctId):
            parameters["id"] = projecctId
        case .freeStaking_myPos(let page, let pageSize, let projectType,let
                                    baseCoin, let strTime, let entTime):
            parameters["page"] = page
            parameters["pageSize"] = pageSize
            parameters["projectType"] = projectType
            parameters["baseCoin"] = baseCoin
            parameters["strTimeMills"] = strTime
            parameters["entTimeMills"] = entTime
        case .freeStaking_incrementapply(let amount, let projectId):
            parameters["amount"] = amount
            parameters["projectId"] = projectId
        case .validateWithInternalTransfer(let account):
            parameters["transferUid"] = account
        case .doWithInternalTransfer(let account, let amount, let fee, let symbol, let smsVaildCode, let googleValidCode,let emailAuthCode, let capitalPwd):
            parameters["transferUid"] = account
            parameters["amount"] = amount
            parameters["fee"] = fee
            parameters["symbol"] = symbol
            parameters["smsAuthCode"] = smsVaildCode
            parameters["googleCode"] = googleValidCode
            parameters["emailAuthCode"] = emailAuthCode
            parameters["capitalPassword"] = capitalPwd
        case .recommendSearchSymbol:
            break
        case .getIpByCode(let qrid):
            parameters["qrcodeId"] = qrid
            break
        case .confirmPCLogin(let qrid):
            parameters["qrcodeId"] = qrid
            break
        default:

            break
        }
        
        
        if self.method == .post {
            return .requestParameters(parameters: NetManager.sharedInstance.handleParamter(parameters), encoding: JSONEncoding.default)
        }else {
            switch self {
            case .getAbout:
                return .requestParameters(parameters: NetManager.sharedInstance.handleParamter(parameters), encoding:URLEncoding.queryString )
            default:
                return .requestParameters(parameters: NetManager.sharedInstance.handleParamter(parameters), encoding:URLEncoding.httpBody )
            }
        }
    }
    
    var headers: [String : String]? {
        let header = NetManager.sharedInstance.getHeaderParams()
        return header
    }
    
    func appendCaptchaInfo(original:[String:Any]) -> [String:Any] {
        var parameters = original
        let verificationType:String = EXCaptchaMananger.shared.captchaType()
        if verificationType != ""{
            parameters["verificationType"] = verificationType
        }
        parameters["clouldflareVerification"] = "1"
        let captchaInfo = EXCaptchaMananger.shared.getCaptchaInfo()
        if captchaInfo.count > 0 {
            for (k,v) in captchaInfo {
                parameters[k] = v
            }
        }
        return parameters
    }
    
}

