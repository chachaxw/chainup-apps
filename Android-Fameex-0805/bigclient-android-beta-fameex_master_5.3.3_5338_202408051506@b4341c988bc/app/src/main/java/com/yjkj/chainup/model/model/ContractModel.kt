package com.yjkj.chainup.model.model

import android.text.TextUtils
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
class ContractModel : BaseDataManager() {

    /**
     *1 Public interface for contracts
     */
    fun getPublicInfo4Contract(consumer: DisposableObserver<ResponseBody>): Disposable? {
        return changeIOToMainThread(httpHelper.getContractUrlService(ContractApiService::class.java).getPublicInfo4Contract1(getBaseReqBody()), consumer)
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
                                      orderType: Int,
                                      consumer: DisposableObserver<ResponseBody>): Disposable? {

        val map = getBaseMaps()
        map["contractId"] = contractId
        map["volume"] = volume
        map["price"] = price
        if (!TextUtils.isEmpty(level)) {
            map["level"] = level
        }
        map["orderType"] = orderType.toString()
        return changeIOToMainThread(httpHelper.getContractUrlService(ContractApiService::class.java).getInitTakeOrderInfo4Contract1(getBaseReqBody(map)), consumer)
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
                           positionId: String = "",
                           consumer: DisposableObserver<ResponseBody>): Disposable? {

        val map = getBaseMaps()
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
        return changeIOToMainThread(httpHelper.getContractUrlService(ContractApiService::class.java).takeOrder4Contract1(getBaseReqBody(map)), consumer)
    }


    /**
     *4 Cancel Order
     *@param orderId Order ID
     *@param contractId Contract ID
     */
    fun cancelOrder4Contract(orderId: String,
                             contractId: String,
                             consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["orderId"] = orderId
            this["contractId"] = contractId
        }
        return changeIOToMainThread(httpHelper.getContractUrlService(ContractApiService::class.java).cancelOrder4Contract1(getBaseReqBody(map)), consumer)

    }


    /**
     *5 Obtain a list of contract orders
     * @param consumer
     * @return
     */
    fun getOrderList4Contract(contractId: String, page: String = "1", pageSize: String = "100", side: String = "", consumer: DisposableObserver<ResponseBody>): Disposable? {
        var paramMaps = getBaseMaps()
        paramMaps["contractId"] = contractId
        paramMaps["page"] = page
        paramMaps["pageSize"] = pageSize
        paramMaps["side"] = side
        return changeIOToMainThread(httpHelper.getContractUrlService(ContractApiService::class.java).getOrderList4Contract1(getBaseReqBody(paramMaps)), consumer)
    }


    /**
     *7 Tag price (needless login)
     *@param contractId Contract ID
     */
    fun getTagPrice4Contract(contractId: String,
                             consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["contractId"] = contractId
        }
        return changeIOToMainThread(httpHelper.getContractUrlService(ContractApiService::class.java).getTagPrice4Contract1(getBaseReqBody(map)), consumer)
    }

    /**
     *8 Modify leverage ratio
     */
    fun changeLevel4Contract(contractId: String, newLevel: String,
                             consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["contractId"] = contractId
            this["leverageLevel"] = newLevel
        }
        return changeIOToMainThread(httpHelper.getContractUrlService(ContractApiService::class.java).changeLevel4Contract1(getBaseReqBody(map)), consumer)
    }


    /**
     *9 Additional margin:
     *@param contractId Contract ID
     *Additional quantity for @param amount (transferred out as negative)
     */
    fun transferMargin4Contract(positionId: String,
                                contractId: String,
                                amount: String,
                                consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["contractId"] = contractId
            this["amount"] = amount
            this["positionId"] = positionId
        }
        return changeIOToMainThread(httpHelper.getContractUrlService(ContractApiService::class.java).transferMargin4Contract1(getBaseReqBody(map)), consumer)
    }

    /**
     *10 User position information:
     *
     *If the contract ID is not filled in and queried, it is a warehouse list
     *5s refresh
     */
    fun getPosition4Contract(contractId: String = "",
                             consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["contractId"] = contractId
        }
        return changeIOToMainThread(httpHelper.getContractUrlService(ContractApiService::class.java).getPosition4Contract1(getBaseReqBody(map)), consumer)
    }


    /**
     *11 User Open Position Contracts:
     *Page 20s request
     */
    fun holdContractList4Contract(consumer: DisposableObserver<ResponseBody>): Disposable? {
        return changeIOToMainThread(httpHelper.getContractUrlService(ContractApiService::class.java).holdContractList4Contract1(getBaseReqBody()), consumer)
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
                                 bond: String?,
                                 consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps()
        map["fromType"] = fromType
        map["toType"] = toType
        map["amount"] = amount
        if (null != bond) {
            map["bond"] = bond!!

        }
        return changeIOToMainThread(httpHelper.getContractUrlService(ContractApiService::class.java).capitalTransfer4Contract1(getBaseReqBody(map)), consumer)
    }


    /**
     *13 Account balance:
     */
    fun getAccountBalance4Contract(
            consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps()
        return changeIOToMainThread(httpHelper.getContractUrlService(ContractApiService::class.java).getAccountBalance4Contract1(getBaseReqBody(map)), consumer)
    }

    /**
     *15. Risk Assessment (Need Login)
     */
    fun getRiskLiquidationRate(contractId: String = "",
                               consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps()
        map["contractId"] = contractId
        return changeIOToMainThread(httpHelper.getContractUrlService(ContractApiService::class.java).getRiskLiquidationRate1(getBaseReqBody(map)), consumer)
    }

    /**
     *Obtaining Historical Commissions (Contracts)
     *@param symbol contract series
     *@param contractType contract type (0 perpetual contract, 1 week contract, 2 weekly contracts, 3 month contract, 4 quarter contract)
     * @param pageSize default 5
     * @param page  default 1
     *@param side commission direction, BUY buy sell sell sell, do not transmit all
     *Does @param isShowCanceled display cancelled orders? 0 indicates no display, 1 indicates display, default to 1
     *@param startTime, month, day, year, year. Input of hours, minutes, and seconds is prohibited: April 22, 2019
     *@param endTime, month, day, year, year. Input of hours, minutes, and seconds is prohibited: April 22, 2019
     *Param action
     */
    fun getHistoryEntrust4Contract(symbol: String,
                                   contractType: String,
                                   pageSize: String = "5",
                                   page: String = "1",
                                   isShowCanceled: String = "1",
                                   side: String = "",
                                   orderType: String = "",
                                   startTime: String = "",
                                   endTime: String = "",
                                   action: String = "",
                                   consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps()
        map["symbol"] = symbol
        map["pageSize"] = pageSize
        map["page"] = page
        map["isShowCanceled"] = isShowCanceled

        if (!TextUtils.isEmpty(side)) {
            map["side"] = side
        }

        if (!TextUtils.isEmpty(orderType)) {
            map["orderType"] = orderType
        }

        map["contractType"] = contractType

        if (!TextUtils.isEmpty(startTime)) {
            map["startTimeMillis"] = startTime
        }

        if (!TextUtils.isEmpty(endTime)) {
            map["endTimeMillis"] = endTime
        }
        if (!TextUtils.isEmpty(action)) {
            map["action"] = action
        }
        return changeIOToMainThread(httpHelper.getContractUrlService(ContractApiService::class.java).getHistoryEntrust4Contract1(getBaseReqBody(map)), consumer)
    }




    fun getPublicInfo(consumer: DisposableObserver<ResponseBody>): Disposable? {
        return changeIOToMainThread(httpHelper.getContractUrlService(ContractApiService::class.java).getPublicInfo(getBaseReqBody()), consumer)
    }


    fun getUserConfig(contractId: String = "", consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["contractId"] = contractId
        }
        return changeIOToMainThread(httpHelper.getContractUrlService(ContractApiService::class.java).getUserConfig(getBaseReqBody(map)), consumer)
    }


    fun modifyMarginModel(contractId: String = "", marginModel: String = "", consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["contractId"] = contractId
            this["marginModel"] = marginModel
        }
        return changeIOToMainThread(httpHelper.getContractUrlService(ContractApiService::class.java).modifyMarginModel(getBaseReqBody(map)), consumer)
    }


    fun modifyLevel(contractId: String = "", nowLevel: String = "", consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["contractId"] = contractId
            this["nowLevel"] = nowLevel
        }
        return changeIOToMainThread(httpHelper.getContractUrlService(ContractApiService::class.java).modifyLevel(getBaseReqBody(map)), consumer)
    }


    fun modifyTransactionLike(contractId: String, positionModel: String, pcSecondConfirm: String, coUnit: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["contractId"] = contractId
            this["positionModel"] = positionModel
            this["pcSecondConfirm"] = pcSecondConfirm
            this["coUnit"] = coUnit
        }
        return changeIOToMainThread(httpHelper.getContractUrlService(ContractApiService::class.java).modifyTransactionLike(getBaseReqBody(map)), consumer)
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
        return changeIOToMainThread(httpHelper.getContractUrlService(ContractApiService::class.java).createContract(getBaseReqBody(map)), consumer)
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
        return changeIOToMainThread(httpHelper.getContractUrlService(ContractApiService::class.java).getMarkertInfo(getBaseReqBody(map)), consumer)
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
        return changeIOToMainThread(httpHelper.getContractUrlService(ContractApiService::class.java).createOrder(getBaseReqBodyV1(map)), consumer)
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
        return changeIOToMainThread(httpHelper.getContractUrlService(ContractApiService::class.java).createTpslOrder(getBaseReqBodyV1(map)), consumer)
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
        return changeIOToMainThread(httpHelper.getContractUrlService(ContractApiService::class.java).orderCancel(getBaseReqBody(map)), consumer)
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
        return changeIOToMainThread(httpHelper.getContractUrlService(ContractApiService::class.java).modifyPositionMargin(getBaseReqBody(map)), consumer)
    }

    /**
     *Position List
     *@param contractId Contract ID
     */
    fun getPositionList(contractId: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["contractId"] = contractId
        }
        return changeIOToMainThread(httpHelper.getContractUrlService(ContractApiService::class.java).getPositionList(getBaseReqBody(map)), consumer)
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
        return changeIOToMainThread(httpHelper.getContractUrlService(ContractApiService::class.java).getCurrentOrderList(getBaseReqBody(map)), consumer)
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
        return changeIOToMainThread(httpHelper.getContractUrlService(ContractApiService::class.java).getCurrentPlanOrderList(getBaseReqBody(map)), consumer)
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
        return changeIOToMainThread(httpHelper.getContractUrlService(ContractApiService::class.java).getHistoryOrderList(getBaseReqBody(map)), consumer)
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
        return changeIOToMainThread(httpHelper.getContractUrlService(ContractApiService::class.java).getHistoryPlanOrderList(getBaseReqBody(map)), consumer)
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
        return changeIOToMainThread(httpHelper.getContractUrlService(ContractApiService::class.java).getPositionAssetsList(getBaseReqBody(map)), consumer)
    }

    /**
     *Obtain position list and asset list
     * @param contractId contractId
     */
    fun getLadderInfo(contractId: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["contractId"] = contractId
        }
        return changeIOToMainThread(httpHelper.getContractUrlService(ContractApiService::class.java).getLadderInfo(getBaseReqBody(map)), consumer)
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
        return changeIOToMainThread(httpHelper.getContractUrlService(ContractApiService::class.java).getTransactionList(getBaseReqBody(map)), consumer)
    }

    /**
     *Obtain Asset Details
     *@param marginCoin Guaranteed Gold Coins
     */
    fun getAccountBalanceByMarginCoin(marginCoin: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["marginCoin"] = marginCoin
        }
        return changeIOToMainThread(httpHelper.getContractUrlService(ContractApiService::class.java).getPositionAssetsList(getBaseReqBody(map)), consumer)
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
        return changeIOToMainThread(httpHelper.getContractUrlService(ContractApiService::class.java).getTakeProfitStopLoss(getBaseReqBody(map)), consumer)
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
        return changeIOToMainThread(httpHelper.getContractUrlService(ContractApiService::class.java).cancelOrderTpsl(getBaseReqBody(map)), consumer)
    }

    /**
     *Transfer of spot goods to contracts
     *@param uid user id
     *@param coinSymbol Transfer currency, such as USDT
     *@param amount Transfer amount
     */
//    fun coTransferEx(uid: String, coinSymbol: String, amount: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
//        val map = getBaseMaps().apply {
//            this["coinSymbol"] = coinSymbol
//            this["amount"] = amount
//        }
//        return changeIOToMainThread(httpHelper.getContractUrlService(ContractApiService::class.java).coTransferEx(getBaseReqBody(map)), consumer)
//    }

    /**
     *Obtain contract currency to fund flow
     *@param coinSymbol coin pair
     *@param startTime
     *@param endTime End Time
     *Param page
     *@param pageSize Number of entries
     *Param transactionScene transfer type
     */
//    fun getTransferRecord(coinSymbol: String, startTime: String, endTime: String, page: String, pageSize: String, transactionScene: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
//        val map = getBaseMaps().apply {
//            this["coinSymbol"] = coinSymbol
//            this["startTime"] = startTime
//            this["endTime"] = endTime
//            this["page"] = page
//            this["pageSize"] = pageSize
//            this["transactionScene"] = transactionScene
//        }
//        return changeIOToMainThread(httpHelper.getContractUrlService(ContractApiService::class.java).getTransferRecord(getBaseReqBody(map)), consumer)
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
        return changeIOToMainThread(httpHelper.getContractUrlService(ContractApiService::class.java).getHisTradeList(getBaseReqBody(map)), consumer)
    }


}
