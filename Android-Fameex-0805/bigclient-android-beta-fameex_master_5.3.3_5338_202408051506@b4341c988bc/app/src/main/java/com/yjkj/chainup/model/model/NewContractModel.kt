package com.yjkj.chainup.model.model

import android.text.TextUtils
import com.chainup.contract.api.CpContractApiService
import com.chainup.contract.bean.CpTpslOrderBean
import com.google.gson.Gson
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.model.NDataHandler
import com.yjkj.chainup.model.api.ContractApiService
import com.yjkj.chainup.model.datamanager.BaseDataManager
import com.yjkj.chainup.net.DataHandler
import com.yjkj.chainup.net.api.HttpResult
import com.yjkj.chainup.net_new.HttpParams
import com.yjkj.chainup.treaty.bean.ActiveOrderListBean
import io.reactivex.Observable
import io.reactivex.disposables.Disposable
import io.reactivex.observers.DisposableObserver
import okhttp3.RequestBody
import okhttp3.ResponseBody

/**
 * @Author: Bertking
 * @Date 2023-09-04-11:27
 *@description: Contract specific request
 */
class NewContractModel : BaseDataManager() {

    /**
     *Obtain contract public information
     */
    fun getPublicInfo(consumer: DisposableObserver<ResponseBody>): Disposable? {
        return changeIOToMainThread(httpHelper.getContractNewUrlService(ContractApiService::class.java).getPublicInfo(getBaseReqBody()), consumer)
    }

    /**
     *Obtain contract user configuration information (margin mode/leverage/trading preferences)
     *@param contractId Contract ID
     */
    fun getUserConfig(contractId: String = "", consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["contractId"] = contractId
        }
        return changeIOToMainThread(httpHelper.getContractNewUrlService(ContractApiService::class.java).getUserConfig(getBaseReqBody(map)), consumer)
    }

    /**
     *Modify margin mode
     *@param contractId Contract ID
     *@param marginModel: The current margin mode is 1 full position, 2 position by position
     */
    fun modifyMarginModel(contractId: String = "", marginModel: String = "", consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["contractId"] = contractId
            this["marginModel"] = marginModel
        }
        return changeIOToMainThread(httpHelper.getContractNewUrlService(ContractApiService::class.java).modifyMarginModel(getBaseReqBody(map)), consumer)
    }

    /**
     *Modify lever
     *@param contractId Contract ID
     *@param nowLevel Current leverage ratio
     */
    fun modifyLevel(contractId: String = "", nowLevel: String = "", consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["contractId"] = contractId
            this["nowLevel"] = nowLevel
        }
        return changeIOToMainThread(httpHelper.getContractNewUrlService(ContractApiService::class.java).modifyLevel(getBaseReqBody(map)), consumer)
    }

    /**
     *Modify transaction preferences
     *@param contractId Contract ID
     *@param positionModel Position Type 1 Position, 2 Bidirectional Position
     *@param pcSecondConfirm PC page pop-up confirmation switch before placing an order, 0 used, 1 disabled
     *@param coUnit Contract Unit 1 Target Currency, 2 sheets
     */
    fun modifyTransactionLike(contractId: String, positionModel: String, pcSecondConfirm: String, coUnit: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["contractId"] = contractId
            this["positionModel"] = positionModel
            this["pcSecondConfirm"] = pcSecondConfirm
            this["coUnit"] = coUnit
        }
        return changeIOToMainThread(httpHelper.getContractNewUrlService(ContractApiService::class.java).modifyTransactionLike(getBaseReqBody(map)), consumer)
    }

    /**
     *Opening contract transactions
     *@param mobileNumber Exchange login user's phone number (desensitization)
     *@param email Exchange email (desensitization)
     *@param uid Exchange User ID
     */
    fun createContract(consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            if (!TextUtils.isEmpty(UserDataService.getInstance().mobileNumber)) {
                this["mobileNumber"] = UserDataService.getInstance().mobileNumber
            }
            if (!TextUtils.isEmpty(UserDataService.getInstance().email)) {
                this["email"] = UserDataService.getInstance().email
            }
            this["uid"] = UserDataService.getInstance().userInfo4UserId
        }
        return changeIOToMainThread(httpHelper.getContractNewUrlService(ContractApiService::class.java).createContract(getBaseReqBody(map)), consumer)
    }

    /**
     *Public real-time information at the front desk
     *@param symbol Contract currency pair name, for example: BTC-USDT
     *@param contractId Contract ID
     */
    fun getMarkertInfo(symbol: String, contractId: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["symbol"] = symbol
            this["contractId"] = contractId
        }
        return changeIOToMainThread(httpHelper.getContractNewUrlService(ContractApiService::class.java).getMarkertInfo(getBaseReqBody(map)), consumer)
    }

    /**
     *Submit Delegation
     *@param symbol Contract currency pair name, for example: BTC-USDT
     *@param contractId Contract ID
     *@param positionType Position type (1 full position, 2 positions one by one)
     *@param open direction for opening and closing positions (OPEN position, Close position)
     *@param side buying and selling direction (BUY buying, SELL selling)
     *@param type order type (1 limit, 2 market, 3 IOC, 4 FOK, 5 POST ONLY)
     *Param leverageLevel
     *Place an order at @param price (transfer market price to 0)
     *@param volume Order quantity (opening market price order: amount)
     *Is @param isConditionOrder a condition order
     *@param triggerPrice triggers the price
     */
    fun createOrder(contractId: Int, positionType: String, open: String, side: String, type: Int, leverageLevel: Int, price: String, volume: String, isConditionOrder: Boolean, triggerPrice: String, expireTime: Int, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMapsV2().apply {
            this["contractId"] = contractId
            this["positionType"] = positionType
            this["open"] = open
            this["side"] = side
            this["type"] = type
            this["leverageLevel"] = leverageLevel
            this["price"] = price
            this["volume"] = volume
            this["isConditionOrder"] = isConditionOrder
            this["triggerPrice"] = triggerPrice
            this["expireTime"] = expireTime
        }
        return changeIOToMainThread(httpHelper.getContractNewUrlService(ContractApiService::class.java).createOrder(getBaseReqBodyV1(map)), consumer)
    }

    /**
     *Submit commission (stop profit/stop loss)
     *@param contractId Contract ID
     *@param positionType Position type (1 full position, 2 positions one by one)
     *@param side buying and selling direction (BUY buying, SELL selling)
     *Param leverageLevel
     *@param orderList Order List
     *TriggerType Stop Loss Stop Loss Order Type (3 Stop Loss, 4 Stop Loss) Fixed Enumeration
     *| price Place order price (market price to be transferred to 0)
     *| Volume Order Quantity (Opening Market Price Order: Amount)
     *Trigger Price
     *| type Order type (1 limit, 2 markets)
     */
    fun createTpslOrder(contractId: Int, positionType: String, side: String, leverageLevel: Int, mTpslOrderList: List<CpTpslOrderBean>, consumer: DisposableObserver<ResponseBody>): Disposable? {
        var sideBuff = ""
        if (side.equals("BUY")) {
            sideBuff = "SELL"
        } else {
            sideBuff = "BUY"
        }
        val map = getBaseMapsV2().apply {
            this["contractId"] = contractId
            this["positionType"] = positionType
            this["side"] = sideBuff
            this["leverageLevel"] = leverageLevel
            this["orderListStr"] = Gson().toJson(mTpslOrderList)
        }
        return changeIOToMainThread(httpHelper.getContractNewUrlService(ContractApiService::class.java).createTpslOrder(getBaseReqBodyV1(map)), consumer)
    }

    /**
     *Cancellation of orders
     *@param contractId Contract ID
     *@param orderId Order ID
     */
    fun orderCancel(contractId: String, orderId: String, isConditionOrder: Boolean, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["contractId"] = contractId
            this["isConditionOrder"] = isConditionOrder.toString()
            if (!TextUtils.isEmpty(orderId)) {
                this["orderId"] = orderId
            }
        }
        return changeIOToMainThread(httpHelper.getContractNewUrlService(ContractApiService::class.java).orderCancel(getBaseReqBody(map)), consumer)
    }

    /**
     *Adjust the margin for each warehouse position
     *@param type adjustment type; 1. Increase margin, 2. Reduce margin
     *@param contractId Contract ID
     *@param amount adjustment amount
     */
    fun modifyPositionMargin(contractId: String, positionId: String, type: String, amount: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["contractId"] = contractId
            this["type"] = type
            this["amount"] = amount
            this["positionId"] = positionId
        }
        return changeIOToMainThread(httpHelper.getContractNewUrlService(ContractApiService::class.java).modifyPositionMargin(getBaseReqBody(map)), consumer)
    }

    /**
     *Position List
     *@param contractId Contract ID
     */
    fun getPositionList(contractId: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["contractId"] = contractId
        }
        return changeIOToMainThread(httpHelper.getContractNewUrlService(ContractApiService::class.java).getPositionList(getBaseReqBody(map)), consumer)
    }

    /**
     *Current delegation
     *@param contractId Contract ID
     *@param status Order status: 0 init, 1 new, 2 filled, 3 part_ Filled, 4 cancelled, 5 pending_ Cancel, 6 expired (default query status 0, 1, 3, 5 is not passed)
     */
    fun getCurrentOrderList(contractId: String, status: Int, page: Int, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["contractId"] = contractId
            if (status != 0) this["type"] = status.toString()
            this["page"] = page.toString()
            this["limit"] = "20"
        }
        return changeIOToMainThread(httpHelper.getContractNewUrlService(ContractApiService::class.java).getCurrentOrderList(getBaseReqBody(map)), consumer)
    }

    /**
     *Current plan delegation
     *@param contractId Contract ID
     *@param status Order status: 0 init, 1 new, 2 filled, 3 part_ Filled, 4 cancelled, 5 pending_ Cancel, 6 expired (default query status 0, 1, 3, 5 is not passed)
     */
    fun getCurrentPlanOrderList(contractId: String, status: Int, page: Int, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["contractId"] = contractId
            if (status != 0) this["type"] = status.toString()
            this["page"] = page.toString()
            this["limit"] = "20"
        }
        return changeIOToMainThread(httpHelper.getContractNewUrlService(ContractApiService::class.java).getCurrentPlanOrderList(getBaseReqBody(map)), consumer)
    }


    /**
     *Historical commission
     *@param contractId Contract ID
     *@param status Order status: 0 init, 1 new, 2 filled, 3 part_ Filled, 4 cancelled, 5 pending_ Cancel, 6 expired (do not pass default query types 2 and 4)
     */
    fun getHistoryOrderList(contractId: String, status: Int, page: Int, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["contractId"] = contractId
            if (status != 0) this["type"] = status.toString()
            this["page"] = page.toString()
            this["limit"] = "20"
        }
        return changeIOToMainThread(httpHelper.getContractNewUrlService(ContractApiService::class.java).getHistoryOrderList(getBaseReqBody(map)), consumer)
    }

    /**
     *Historical Plan Delegation
     *@param contractId Contract ID
     *@param status Order status: 0 init, 1 new, 2 filled, 3 part_ Filled, 4 cancelled, 5 pending_ Cancel, 6 expired (do not pass default query types 2 and 4)
     */
    fun getHistoryPlanOrderList(contractId: String, status: Int, page: Int, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["contractId"] = contractId
            if (status != 0) this["type"] = status.toString()
            this["page"] = page.toString()
            this["limit"] = "20"
        }
        return changeIOToMainThread(httpHelper.getContractNewUrlService(ContractApiService::class.java).getHistoryPlanOrderList(getBaseReqBody(map)), consumer)
    }


    /**
     *Obtain position list and asset list
     *@param marginCoin guarantees currency types, does not transfer to query all currencies
     *@param onlyAccount 1 only returns asset information, 0 returns positions and assets
     */
    fun getPositionAssetsList(consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["onlyAccount"] = "0"
        }
        return changeIOToMainThread(httpHelper.getContractNewUrlService(ContractApiService::class.java).getPositionAssetsList(getBaseReqBody(map)), consumer)
    }

    /**
     *Obtain position list and asset list
     * @param contractId contractId
     */
    fun getLadderInfo(contractId: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["contractId"] = contractId
        }
        return changeIOToMainThread(httpHelper.getContractNewUrlService(ContractApiService::class.java).getLadderInfo(getBaseReqBody(map)), consumer)
    }

    /**
     *Obtaining contract fund flow
     *@param symbol Query currency
     *@param type: flow type 1 transfer in, 2 transfer out, 5 fund expenses, 8 allocation
     *Param page
     */
    fun getTransactionList(symbol: String, type: String, page: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["symbol"] = symbol
            if (!type.equals("0")){
                this["type"] = type
            }
            this["page"] = page
            this["limit"] = "20"
        }
        return changeIOToMainThread(httpHelper.getContractNewUrlService(ContractApiService::class.java).getTransactionList(getBaseReqBody(map)), consumer)
    }

    /**
     *Obtain Asset Details
     *@param marginCoin Guaranteed Gold Coins
     */
    fun getAccountBalanceByMarginCoin(marginCoin: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["marginCoin"] = marginCoin
        }
        return changeIOToMainThread(httpHelper.getContractNewUrlService(ContractApiService::class.java).getPositionAssetsList(getBaseReqBody(map)), consumer)
    }

    /**
     *Obtain a stop loss and stop loss list
     *@param contractId Contract ID
     *@param orderSide Position Direction BUY Long, Sell Short (Fixed Enumeration)
     */
    fun getTakeProfitStopLoss(contractId: String, orderSide: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["contractId"] = contractId
            this["orderSide"] = orderSide
        }
        return changeIOToMainThread(httpHelper.getContractNewUrlService(ContractApiService::class.java).getTakeProfitStopLoss(getBaseReqBody(map)), consumer)
    }

    /**
     *Cancel order - stop profit and stop loss
     *@param contractId Contract ID
     *@param orderIds Order ID, separated by multiple English half width commas
     */
    fun cancelOrderTpsl(contractId: String, orderIds: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["contractId"] = contractId
            this["orderIds"] = orderIds
        }
        return changeIOToMainThread(httpHelper.getContractNewUrlService(ContractApiService::class.java).cancelOrderTpsl(getBaseReqBody(map)), consumer)
    }

    /**
     *Transfer of spot goods to contracts
     *@param uid user id
     *@param coinSymbol Transfer currency, such as USDT
     *@param amount Transfer amount
     */
//    fun coTransferEx(uid: String, coinSymbol: String, amount: String, transferType: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
//        val map = getBaseMaps().apply {
//            this["coinSymbol"] = coinSymbol
//            this["amount"] = amount
//            this["transferType"] = transferType
//        }
//        return changeIOToMainThread(httpHelper.getContractNewUrlService(ContractApiService::class.java).coTransferEx(getBaseReqBody(map)), consumer)
//    }

    /**
     *Obtain historical transaction records of entrusted orders
     *@param orderId Order ID
     *@param contractId Contract ID
     */
    fun getHistoryTradeList(contractId: String, orderId: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["contractId"] = contractId
            this["orderId"] = orderId
        }
        return changeIOToMainThread(httpHelper.getContractNewUrlService(ContractApiService::class.java).getHisTradeList(getBaseReqBody(map)), consumer)
    }

    /**
     *Receive simulation contract experience fee
     */
    fun receiveCoupon( consumer: DisposableObserver<ResponseBody>): Disposable? {
        return changeIOToMainThread(httpHelper.getContractNewUrlService(ContractApiService::class.java).receiveCoupon(getBaseReqBody()), consumer)
    }


    /**
     *Obtain position/profit and loss records
     *Param page
     *@param contractId Contract ID
     */
    fun getHistoryPositionList(contractId: String, page: String, side: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["contractId"] = contractId
            this["page"] = page
            this["limit"] = "20"
            if (!TextUtils.isEmpty(side)){
                this["side"] =side
            }
        }
        return changeIOToMainThread(httpHelper.getContractNewUrlService(ContractApiService::class.java).getHistoryPositionList(getBaseReqBody(map)), consumer)
    }


    /**
     *Obtain contract selection list
     */
    fun getOptionalList(consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps()
        return changeIOToMainThread(httpHelper.getContractNewUrlService(CpContractApiService::class.java).getOptionalList(getBaseReqBody(map)), consumer)
    }
    /**
     *Save Contract Selection List
     *ContractOptionalList: Contract ID optional list, String type (example: '1,2,3,4,5,6,7')
     */
    fun setOptionalList(contractOptionalList: String,consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps()
        map.put("contractOptionalList",contractOptionalList)
        return changeIOToMainThread(httpHelper.getContractNewUrlService(CpContractApiService::class.java).setOptionalList(getBaseReqBody(map)), consumer)
    }


    /**
     *Exchange rate list query
     */
    fun getSymbolRateList(consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps()
        return changeIOToMainThread(httpHelper.getContractNewUrlService(CpContractApiService::class.java).getSymbolRateList(getBaseReqBody(map)), consumer)
    }


}
