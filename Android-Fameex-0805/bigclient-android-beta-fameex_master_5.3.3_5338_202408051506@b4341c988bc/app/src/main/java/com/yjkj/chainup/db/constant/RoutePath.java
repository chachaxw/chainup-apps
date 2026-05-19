package com.yjkj.chainup.db.constant;

/**
 *@description: Aroute Routing Path Configuration, Format:/Module Name/Class Name
 * @Author: wanghao
 * @CreateDate: 2019-10-22 20:39
 * @UpdateUser: wanghao
 * @UpdateDate 2023-10-22 20:39
 *@ UpdateRemark: Update Description
 */
public class RoutePath {

    /*
     *Homepage NewMainActivity
     */
    public static final String NewMainActivity = "/main/NewMainActivity";


    /*
     *OTC module
     */
    public static final String PaymentMethodActivity = "/otc/PaymentMethodActivity";
    public static final String NewAdvertisingManagementActivity = "/otc/newadvertisingmanagementactivity";
    public static final String NewAdvertisingDetailActivity = "/main/otc/NewAdvertisingDetailActivity";
    public static final String NewReleaseAdvertisingActivity = "/main/otc/NewReleaseAdvertisingActivity";


    /*
     *Personal Center Module
     */
    public static final String PersonalCenterActivity = "/personCenter/PersonalCenterActivity";
    public static final String PersonalInfoActivity = "/personCenter/PersonalInfoActivity";
    public static final String RealNameCertificationActivity = "/personCenter/RealNameCertificationActivity";
    public static final String RealNameCertificaionSuccessActivity = "/personCenter/RealNameCertificaionSuccessActivity";
    public static final String SetOrModifyPwdActivity = "/personCenter/SetOrModifyPwdActivity";
    public static final String SafetySettingActivity = "/personCenter/SafetySettingActivity";
    public static final String NewVerifyActivity = "/personalCenter/NewVerifyActivity";
    public static final String WebviewActivity = "/personalCenter/WebviewActivity";
    public static final String UdeskWebViewActivity = "/personalCenter/UdeskWebViewActivity";
    public static final String ContractAgentActivity = "/personalCenter/ContractAgentActivity";
    public static final String InvitationRewardActivity = "/personalCenter/InvitationRewardActivity";
    public static final String ChangenNetworkActivity = "/personalCenter/ChangenNetworkActivity";

    /*
     *Login Registration Module
     */
    public static final String NewVersionLoginActivity = "/login/NewVersionLoginActivity";
    public static final String GoogleValidationActivity = "/login/GoogleValidationActivity";


    /*
     *Activity module activity
     */
    public static final String InvitFirendsActivity = "/activity/InvitFirendsActivity";
    public static final String CreateRedPackageActivity = "/activity/CreateRedPackageActivity";
    /*
     网格
     */
    public static final String HistoryGridActivity = "/grid/HistoryGridActivity";
    public static final String GridExecutionDetailsActivity = "/grid/GridExecutionDetailsActivity";

    /*
      委托详情
    *  */

    public static final String CurrentEntrustActivity = "/main/CurrentEntrustFragment";
    public static final String EntrustActivity = "/main/EntrustActivity";
    public static final String EntrustDetialsActivity = "/main/EntrustDetialsActivity";
    public static final String HistoryEntrustActivity = "/main/HistoryEntrustFragment";
    public static final String MarketDetail4Activity = "/main/MarketDetail4Activity";
    public static final String HorizonMarketDetailActivity = "/main/HorizonMarketDetailActivity";

    /*Entrustment details*/
    public static final String EntrustDetailActivity = "/main/EntrustDetailActivity";

    /*
     *Contract module
     */
    public static final String B2CCashFlowActivity = "/main/B2CCashFlowActivity";

    public static final String B2CCashFlowDetailActivity = "/main/B2CCashFlowDetailActivity";

    public static final String B2CRechargeActivity = "/main/B2CRechargeActivity";

    public static final String B2CWithdrawAccountListActivity = "/main/B2CWithdrawAccountListActivity";

    /*
     *Asset module
     */
    public static final String NewVersionMyAssetActivity = "/asset/NewVersionMyAssetActivity";
    public static final String CurrencyLendingRecordsActivity = "/asset/CurrencyLendingRecordsActivity";
    public static final String GiveBackActivity = "/asset/GiveBackActivity";
    public static final String B2CWithdrawActivity = "/asset/B2CWithdrawActivity";
    public static final String B2CWithdrawAccountActivity = "/asset/B2CWithdrawAccountActivity";
    public static final String B2CBankListActivity = "/asset/B2CBankListActivity";
    public static final String B2CRecordsActivity = "/asset/B2CRecordsActivity";
    public static final String NewVersionBorrowingActivity = "/asset/NewVersionBorrowingActivity";
    public static final String NewVersionTransferActivity = "/asset/NewVersionTransferActivity";
    public static final String WithdrawActivity = "/asset/WithdrawActivity";
    public static final String SelectCoinActivity = "/asset/SelectCoinActivity";
    public static final String WithdrawSelectCoinActivity = "/asset/WithdrawSelectCoinActivity";
    public static final String IdentityAuthenticationResultActivity = "/asset/IdentityAuthenticationResultActivity";
    public static final String IdentityAuthenticationActivity = "/asset/IdentityAuthenticationActivity";
    public static final String NewVersionOTCActivity = "/home/NewVersionOtcActivity";
    /*
     *Web page
     */
    public static final String ItemDetailActivity = "/web/ItemDetailActivity";

    /*
     *Search module
     */
    public static final String CoinMapActivity = "/search/CoinMapActivity";
    public static final String CoinMapSelectActivity = "/search/CoinMapSelectActivity";
    public static final String NewCoinMapActivity = "/search/NewCoinMapActivity";

    /**
     *Lever
     */
    public static final String HistoryLoanActivity = "/lever/HistoryLoanActivity";
    public static final String CurrentLoanActivity = "/lever/CurrentLoanActivity";
    public static final String BorrowRecordsActivity = "/lever/BorrowRecordsActivity";
    public static final String LeverDrawRecordActivity = "/lever/LeverDrawRecordActivity";
    public static final String LeverTransferRecordActivity = "/lever/LeverTransferRecordActivity";


    /*
     *Order
     */
    public static final String NewOTCOrdersActivity = "/order/NewOTCOrdersActivity";

    public static final String NewVersionCodeActivity = "/login/codeVerification";

    public static final String LikeEditActivity = "/search/EditActivity";

    public static final String LeverActivity = "/lever/LeverActivity";
    public static final String TradeETFQuestionActivity = "/lever/TradeETFQuestionActivity";

    public static final String FinanceHomeActivity = "/asset/FinanceHomeActivity";

    public static final String FinanceBuyActivity = "/asset/finance/FinanceBuyActivity";
    public static final String FinanceBuyStatusActivity = "/asset/finance/FinanceBuyStatusActivity";
    public static final String FinancePoolActivity = "/asset/finance/FinancePoolActivity";

    public static final String FinanceRedemActivity = "/asset/finance/FinanceRedemActivity";
    public static final String FinanceRedemSuccessActivity = "/asset/finance/FinanceRedemSuccessActivity";

    public static final String FinancePoolHistoryActivity = "/asset/finance/FinancePoolHistoryActivity";

    public static final String FiatAddressActivity = "/personCenter/FiatAddressActivity";
    public static final String FiatWithdrawActivity = "/asset/FiatWithdrawActivity";
    public static final String FiatBankActivity = "/asset/FiatBankActivity";

    public static final String FiatWithdrawInfoActivity = "/asset/FiatInfoActivity";
    public static final String FiatDepositHistoryActivity = "/asset/finance/FiatDepositHistoryActivity";

    public static final String FiatWithActivity = "/asset/FiatWithActivity";

    public static final String FiatWithInfoActivity = "/asset/FiatWithInfoActivity";

    public static final String FiatWithHistoryActivity = "/asset/finance/FiatWithHistoryActivity";


    public static final String FastHomeActivity = "/fast/FastHomeActivity";

    /**
     *Third party orders
     */
    public static final String NewOTCOrdersOtherActivity = "/order/NewOTCOrdersOtherActivity";

    public static final String FastOtherInfoActivity = "/asset/FastOtherInfoActivity";

    public static final String KycValidationActivity = "/personCenter/KycValidationActivity";

    public static final String KycToBValidationActivity = "/personCenter/KycToBValidationActivity";

    public static final String QRLoginActivity = "/personCenter/QRLoginActivity";


    /**
     * freeStaking
     */
    public static final String FreeStakingActivity = "/freestaking/FreeStakingActivity";
    public static final String IncomeDetailActivity = "/freestaking/IncomeDetailActivity";
    public static final String PosDetailsActivity = "/freestaking/PosDetailsActivity";
    public static final String PositionRecordActivity = "/freestaking/PositionRecordActivity";
    public static final String ProjectDescriptionActivity = "/freestaking/ProjectDescriptionActivity";
    public static final String DirectlyWithdrawActivity = "/asset/DirectlyWithdrawActivity";

    public static final String QuickBuyCoinIndexActivity = "/quickBuyCoin/QuickBuyCoinIndexActivity";
    public static final String JumpServiceProviderActivity = "/quickBuyCoin/JumpServiceProviderActivity";
    public static final String SelectServiceProviderActivity = "/quickBuyCoin/SelectServiceProviderActivity";
    public static final String SelectQuickBuyCoinActivity = "/quickBuyCoin/SelectCoinActivity";

    /**Account cancellation*/
    public static final String AccountDestroyActivity = "/accountdestroy/AccountDestroyActivity";
    public static final String KycActivity = "/kyc/KycActivity";

}
