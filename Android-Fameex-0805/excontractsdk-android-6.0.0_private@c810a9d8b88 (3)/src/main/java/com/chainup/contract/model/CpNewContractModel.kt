package com.chainup.contract.model

import android.text.TextUtils
import android.util.Log
import com.chainup.contract.api.CpContractApiService
import com.chainup.contract.api.CpHttpResult
import com.chainup.contract.bean.CpContractPublicInfoBean
import com.chainup.contract.bean.CpTpslOrderBean
import com.google.gson.Gson
import com.yjkj.chainup.net_new.rxjava.CpNDisposableObserver
import com.yjkj.chainup.new_contract.bean.CpContractPositionBean
import com.yjkj.chainup.new_contract.bean.CpCreateOrderBean
import io.reactivex.Observable
import io.reactivex.disposables.Disposable
import io.reactivex.observers.DisposableObserver
import okhttp3.ResponseBody
import java.util.ArrayList

/**
 * @Author: Bertking
 * @Date：2019-09-04-11:27
 *@ Description: Contract specific request
 */
class CpNewContractModel : CpBaseDataManager() {

    /**
     *Obtain contract public information
     */
    fun getPublicInfo(consumer: DisposableObserver<ResponseBody>): Disposable? {
        return changeIOToMainThread(
            httpHelper.getContractNewUrlService(CpContractApiService::class.java)
                .getPublicInfo(getBaseReqBody()), consumer
        )
    }

    /**
     *Obtain contract user configuration information (margin mode/leverage/trading preferences)
     *@param contractId Contract ID
     */
    fun getUserConfig(
        contractId: String = "",
        consumer: DisposableObserver<ResponseBody>
    ): Disposable? {
        val map = getBaseMaps().apply {
            this["contractId"] = contractId
        }
        return changeIOToMainThread(
            httpHelper.getContractNewUrlService(CpContractApiService::class.java)
                .getUserConfig(getBaseReqBody(map)), consumer
        )
    }

    /**
     *Modify margin mode
     *@param contractId Contract ID
     *@param marginModel Current margin mode: 1 full position, 2 position by position
     */
    fun modifyMarginModel(
        contractId: String = "",
        marginModel: String = "",
        consumer: DisposableObserver<ResponseBody>
    ): Disposable? {
        val map = getBaseMaps().apply {
            this["contractId"] = contractId
            this["marginModel"] = marginModel
        }
        return changeIOToMainThread(
            httpHelper.getContractNewUrlService(CpContractApiService::class.java)
                .modifyMarginModel(getBaseReqBody(map)), consumer
        )
    }

    /**
     *Modify the lever
     *@param contractId Contract ID
     *@param nowLevel Current leverage ratio
     */
    fun modifyLevel(
        contractId: String = "",
        nowLevel: String = "",
        consumer: DisposableObserver<ResponseBody>
    ): Disposable? {
        val map = getBaseMaps().apply {
            this["contractId"] = contractId
            this["nowLevel"] = nowLevel
        }
        return changeIOToMainThread(
            httpHelper.getContractNewUrlService(CpContractApiService::class.java)
                .modifyLevel(getBaseReqBody(map)), consumer
        )
    }

    /**
     *Modify transaction preferences
     *@param contractId Contract ID
     *@param positionModel Position Type 1 Position, 2 Bidirectional Position
     *@param pcSecondConfirm The pop-up confirmation switch before placing an order on the PC page, 0 used, 1 disabled
     *@param coUnit Contract unit 1 Target currency, 2 sheets
     *@param expiredTime The valid time of the condition sheet, in days (fixed enumeration) 1, 7, 14, 30
     *@param priceBasis 0 Latest Price 1 Tag Price
     */
    fun modifyTransactionLike(
        contractId: String,
        positionModel: String,
        pcSecondConfirm: String,
        coUnit: String,
        expiredTime: String,
        priceBasis: String,
        consumer: DisposableObserver<ResponseBody>
    ): Disposable? {
        val map = getBaseMaps().apply {
            this["contractId"] = contractId
            this["positionModel"] = positionModel
            this["pcSecondConfirm"] = pcSecondConfirm
            this["coUnit"] = coUnit
            this["expireTime"] = expiredTime
            this["priceBasis"] = priceBasis
        }
        return changeIOToMainThread(
            httpHelper.getContractNewUrlService(CpContractApiService::class.java)
                .modifyTransactionLike(getBaseReqBody(map)), consumer
        )
    }

    /**
     *Opening contract transactions
     *@param mobileNumber Exchange login user's mobile phone number (desensitization)
     *@param email Exchange email (desensitization)
     *@param uid Exchange User ID
     */
    fun createContract(consumer: DisposableObserver<ResponseBody>): Disposable? {
//        val map = getBaseMaps().apply {
//            if (!TextUtils.isEmpty(UserDataService.getInstance().mobileNumber)) {
//                this["mobileNumber"] = UserDataService.getInstance().mobileNumber
//            }
//            if (!TextUtils.isEmpty(UserDataService.getInstance().email)) {
//                this["email"] = UserDataService.getInstance().email
//            }
//            this["uid"] = UserDataService.getInstance().userInfo4UserId
//        }
        return changeIOToMainThread(
            httpHelper.getContractNewUrlService(CpContractApiService::class.java)
                .createContract(getBaseReqBody()), consumer
        )
    }

    /**
     *Public real-time information at the front desk
     *@param symbol Contract currency pair name, for example: BTC-USDT
     *@param contractId Contract ID
     */
    fun getMarkertInfo(
        symbol: String,
        contractId: String,
        consumer: DisposableObserver<ResponseBody>
    ): Disposable? {
        val map = getBaseMaps().apply {
            this["symbol"] = symbol
            this["contractId"] = contractId
        }
        return changeIOToMainThread(
            httpHelper.getContractNewUrlService(CpContractApiService::class.java)
                .getMarkertInfo(getBaseReqBody(map)), consumer
        )
    }

    /**
     *Submit Delegation
     *@param symbol Contract currency pair name, for example: BTC-USDT
     *@param contractId Contract ID
     *@param positionType Position type (1 full position, 2 position by position)
     *@param open Open position direction (OPEN position, CLOSE position)
     *@param side buying and selling direction (BUY buying, SELL selling)
     *@param type Order type (1 limit, 2 market, 3 IOC, 4 FOK, 5 POST_ONLY)
     *@param leverageLevel Leverage multiple
     *@param price Place an order price (transfer the market price list to 0)
     *@param volume Order quantity (opening market price order: amount)
     *Whether the @param isConditionOrder is a condition sheet
     *@param triggerPrice Trigger Price
     *@param priceType Opponent optimal 0 Our optimal 1 is blank, which means normal order placement
     */
    fun createOrder(
        contractId: Int,
        positionType: String,
        open: String,
        side: String,
        type: Int,
        leverageLevel: Int,
        price: String,
        volume: String,
        isConditionOrder: Boolean,
        triggerPrice: String,
        expireTime: Int,
        isOto: Boolean,
        takerProfitTrigger: String,
        stopLossTrigger: String,
        priceType: String,
        orderUnit:Int?,
        consumer: DisposableObserver<ResponseBody>
    ): Disposable? {
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
            this["isOto"] = isOto //OTO order or not
            this["takerProfitTrigger"] = takerProfitTrigger //Stop Profit Trigger Price
            this["takerProfitPrice"] = "0" //Entrusted price for closing profit
            this["takerProfitType"] = "2" //Stop Gain Type
            this["stopLossTrigger"] = stopLossTrigger //Stop Loss Trigger Price
            this["stopLossPrice"] = "0" //Stop loss commission price
            this["stopLossType"] = "2" //Stop Loss Type
            this["priceType"] = priceType
            if(orderUnit!=null){
                this["orderUnit"] = orderUnit
            }
        }
        return changeIOToMainThread(
            httpHelper.getContractNewUrlService(CpContractApiService::class.java)
                .createOrder(getBaseReqBodyV1(map)), consumer
        )
    }
    fun createOrder(
        data: CpCreateOrderBean,
        consumer: DisposableObserver<ResponseBody>
    ): Disposable? {
        val map = getBaseMapsV2().apply {
            this["contractId"] = data.contractId
            this["positionType"] = data.positionType
            this["open"] = data.open
            this["side"] = data.side
            this["type"] = data.type
            this["leverageLevel"] = data.leverageLevel
            this["price"] = data.price
            this["volume"] = data.volume
            this["isConditionOrder"] = data.isConditionOrder
            this["triggerPrice"] = data.triggerPrice
            this["expireTime"] = data.expireTime
            this["isOto"] = data.isOto //OTO order or not
            this["takerProfitTrigger"] = data.takerProfitTrigger //Stop Profit Trigger Price
            this["takerProfitPrice"] = "0" //Entrusted price for closing profit
            this["takerProfitType"] = "2" //Stop Gain Type
            this["stopLossTrigger"] = data.stopLossTrigger //Stop Loss Trigger Price
            this["stopLossPrice"] = "0" //Stop loss commission price
            this["stopLossType"] = "2" //Stop Loss Type
//            this["isIgnoreLiq"] = data.isIgnoreLiq!!
            this["isCheckLiq"] = data.isCheckLiq!!
            if(data.orderUnit!=null){
                this["orderUnit"] = data.orderUnit
            }
        }
        return changeIOToMainThread(
            httpHelper.getContractNewUrlService(CpContractApiService::class.java)
                .createOrder(getBaseReqBodyV1(map)), consumer
        )
    }

    /**
     *Submit commission (stop profit/stop loss)
     *@param contractId Contract ID
     *@param positionType Position type (1 full position, 2 position by position)
     *@param side buying and selling direction (BUY buying, SELL selling)
     *@param leverageLevel Leverage multiple
     *@param orderList Order List
     *| triggerType Stop Gain Stop Loss Order Type (3 Stop Loss, 4 Stop Gain) Fixed Enumeration
     *| price Place an order price (transfer the market price list to 0)
     *| volume Order quantity (opening market price order: amount)
     *| triggerPrice Trigger Price
     *| type Order type (1 limit, 2 market)
     */
    fun createTpslOrder(
        contractId: Int,
        positionId: Int,
        positionType: String,
        side: String,
        leverageLevel: Int,
        mTpslOrderList: List<CpTpslOrderBean>,
        orderUnit:Int,
        consumer: DisposableObserver<ResponseBody>
    ): Disposable? {
        var sideBuff = ""
        if (side.equals("BUY")) {
            sideBuff = "SELL"
        } else {
            sideBuff = "BUY"
        }
        val map = getBaseMapsV2().apply {
            this["contractId"] = contractId
            this["positionId"] = positionId
            this["positionType"] = positionType
            this["side"] = sideBuff
            this["leverageLevel"] = leverageLevel
            this["orderListStr"] = Gson().toJson(mTpslOrderList)
            this["orderUnit"] = orderUnit
        }
        return changeIOToMainThread(
            httpHelper.getContractNewUrlService(CpContractApiService::class.java)
                .createTpslOrder(getBaseReqBodyV1(map)), consumer
        )
    }

    /**
     *Cancellation
     *@param contractId Contract ID
     *@param orderId Order ID
     */
    fun orderCancel(
        contractId: String,
        orderId: String,
        isConditionOrder: Boolean,
        type: Int? = null,
        consumer: DisposableObserver<ResponseBody>
    ): Disposable? {
        val map = getBaseMaps().apply {
            this["contractId"] = contractId
            this["isConditionOrder"] = isConditionOrder.toString()
            if (!TextUtils.isEmpty(orderId)) {
                this["orderId"] = orderId
            }
            if(null != type) {
                this["type"] = type.toString()
            }
        }
        return changeIOToMainThread(
            httpHelper.getContractNewUrlService(CpContractApiService::class.java)
                .orderCancel(getBaseReqBody(map)), consumer
        )
    }

    /**
     *Adjust position by position margin
     *@param type adjustment type; 1 Increase margin, 2 Decrease margin
     *@param contractId Contract ID
     *@param amount Adjustment amount
     */
    fun modifyPositionMargin(
        contractId: String,
        positionId: String,
        type: String,
        amount: String,
        consumer: DisposableObserver<ResponseBody>
    ): Disposable? {
        val map = getBaseMaps().apply {
            this["contractId"] = contractId
            this["type"] = type
            this["amount"] = amount
            this["positionId"] = positionId
        }
        return changeIOToMainThread(
            httpHelper.getContractNewUrlService(CpContractApiService::class.java)
                .modifyPositionMargin(getBaseReqBody(map)), consumer
        )
    }

    /**
     *Position List
     *@param contractId Contract ID
     */
    fun getPositionList(
        contractId: String,
        consumer: DisposableObserver<ResponseBody>
    ): Disposable? {
        val map = getBaseMaps().apply {
            this["contractId"] = contractId
        }
        return changeIOToMainThread(
            httpHelper.getContractNewUrlService(CpContractApiService::class.java)
                .getPositionList(getBaseReqBody(map)), consumer
        )
    }

    /**
     *Current Delegation
     *@param contractId Contract ID
     *@param status Order status: 0 init, 1 new, 2 filled, 3 part_ filled，4 canceled，5 pending_ Cancel, 6 expired (do not transfer the default query status of 0, 1, 3, 5)
     */
    fun getCurrentOrderList(
        contractId: String,
        status: Int,
        page: Int,
        limit:Int? = 20,
        consumer: DisposableObserver<ResponseBody>
    ): Disposable? {
        val map = getBaseMaps().apply {
            this["contractId"] = contractId
            if (status != 0) this["type"] = status.toString()
            this["page"] = page.toString()
            this["limit"] = limit.toString()
        }
        return changeIOToMainThread(
            httpHelper.getContractNewUrlService(CpContractApiService::class.java)
                .getCurrentOrderList(getBaseReqBody(map)), consumer
        )
    }

    /**
     *Current Plan Delegation
     *@param contractId Contract ID
     *@param status Order status: 0 init, 1 new, 2 filled, 3 part_ filled，4 canceled，5 pending_ Cancel, 6 expired (do not transfer the default query status of 0, 1, 3, 5)
     */
    fun getCurrentPlanOrderList(
        contractId: String,
        status: Int,
        page: Int,
        limit: Int? = 20,
        consumer: DisposableObserver<ResponseBody>
    ): Disposable? {
        val map = getBaseMaps().apply {
            this["contractId"] = contractId
            if (status != 0) this["type"] = status.toString()
            this["page"] = page.toString()
            this["limit"] = limit.toString()
        }
        return changeIOToMainThread(
            httpHelper.getContractNewUrlService(CpContractApiService::class.java)
                .getCurrentPlanOrderList(getBaseReqBody(map)), consumer
        )
    }


    /**
     *Historical entrustment
     *@param contractId Contract ID
     *@param status Order status: 0 init, 1 new, 2 filled, 3 part_ filled，4 canceled，5 pending_ Cancel, 6 expired (do not pass default query types 2 and 4)
     */
    fun getHistoryOrderList(
        contractId: String,
        status: Int,
        page: Int,
        pageSize: Int?=20,
        isKline: Int?=0,
        isV6: Int?=0,
        consumer: DisposableObserver<ResponseBody>
    ): Disposable? {
        val map = getBaseMapsV2().apply {
            this["contractId"] = contractId
            if (status != 0) this["type"] = status.toString()
            this["page"] = page.toString()
            this["limit"] = pageSize.toString()
            this["isKline"] = isKline.toString()
//            this["isV6"] = isV6.toString()
        }
        return changeIOToMainThread(
            httpHelper.getContractNewUrlService(CpContractApiService::class.java)
                .getHistoryOrderList(getBaseReqBodyV1(map)), consumer
        )
    }

    /**
     *Historical Plan Delegation
     *@param contractId Contract ID
     *@param status Order status: 0 init, 1 new, 2 filled, 3 part_ filled，4 canceled，5 pending_ Cancel, 6 expired (do not pass default query types 2 and 4)
     */
    fun getHistoryPlanOrderList(
        contractId: String,
        status: Int,
        page: Int,
        consumer: DisposableObserver<ResponseBody>
    ): Disposable? {
        val map = getBaseMaps().apply {
            this["contractId"] = contractId
            if (status != 0) this["type"] = status.toString()
            this["page"] = page.toString()
            this["limit"] = "20"
        }
        return changeIOToMainThread(
            httpHelper.getContractNewUrlService(CpContractApiService::class.java)
                .getHistoryPlanOrderList(getBaseReqBody(map)), consumer
        )
    }


    /**
     *Obtain the position list and asset list
     *@param marginCoin Guarantee gold currency, not transferred to query all currencies
     *@param onlyAccount 1 only returns asset information, 0 returns positions and assets
     */
    fun getPositionAssetsList(consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["onlyAccount"] = "0"
        }
        return changeIOToMainThread(
            httpHelper.getContractNewUrlService(CpContractApiService::class.java)
                .getPositionAssetsList(getBaseReqBody(map)), consumer
        )
    }

    fun getPositionAssetsListv2(): Observable<CpHttpResult<ArrayList<CpContractPositionBean>>> {
        val map = getBaseMaps().apply {
            this["onlyAccount"] = "0"
        }
        return httpHelper.getContractNewUrlService(CpContractApiService::class.java).getPositionAssetsListv2(getBaseReqBody(map))
    }

    /**
     *Obtain the position list and asset list
     * @param contractId contractId
     */
    fun getLadderInfo(contractId: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["contractId"] = contractId
        }
        return changeIOToMainThread(
            httpHelper.getContractNewUrlService(CpContractApiService::class.java)
                .getLadderInfo(getBaseReqBody(map)), consumer
        )
    }

    /**
     *Obtain contract fund flow
     *@param symbol Query currency
     *@param type: 流水类型 1 转入 ,2 转出 ,3 结算多仓 ,4 结算空仓 ,5 资金费用 ,6 开仓手续费 ,7 平仓手续费 ,8 分摊, 9 手续费分成, 10 增金发放, 11 增金回收，13 平仓盈亏
     *@param page Page
     */
    fun getTransactionList(
        symbol: String,
        type: String,
        page: String,
        consumer: DisposableObserver<ResponseBody>
    ): Disposable? {
        val map = getBaseMaps().apply {
            this["symbol"] = symbol
            if (!type.equals("0")) {
                this["type"] = type
            }
            this["page"] = page
            this["limit"] = "20"
        }
        return changeIOToMainThread(
            httpHelper.getContractNewUrlService(CpContractApiService::class.java)
                .getTransactionList(getBaseReqBody(map)), consumer
        )
    }

    /**
     *Obtain asset details
     *@param marginCoin Guaranteed Gold Coin
     */
    fun getAccountBalanceByMarginCoin(
        marginCoin: String,
        consumer: DisposableObserver<ResponseBody>
    ): Disposable? {
        val map = getBaseMaps().apply {
            this["marginCoin"] = marginCoin
        }
        return changeIOToMainThread(
            httpHelper.getContractNewUrlService(CpContractApiService::class.java)
                .getPositionAssetsList(getBaseReqBody(map)), consumer
        )
    }

    /**
     *Obtain batch tag prices and the latest prices
     */
    fun getPriceList(
        consumer: DisposableObserver<ResponseBody>
    ): Disposable? {
        val map = getBaseMaps().apply {}
        return changeIOToMainThread(
            httpHelper.getContractNewUrlService(CpContractApiService::class.java)
                .getPriceList(getBaseReqBody(map)), consumer
        )
    }

    /**
     *Obtain the stop profit and stop loss list
     *@param contractId Contract ID
     *@param orderSide Position Direction BUY Multiple Positions, Sell Short Positions (Fixed Enumeration)
     */
    fun getTakeProfitStopLoss(
        contractId: String,
        orderSide: String,
        consumer: DisposableObserver<ResponseBody>
    ): Disposable? {
        val map = getBaseMaps().apply {
            this["contractId"] = contractId
            this["orderSide"] = orderSide
        }
        return changeIOToMainThread(
            httpHelper.getContractNewUrlService(CpContractApiService::class.java)
                .getTakeProfitStopLoss(getBaseReqBody(map)), consumer
        )
    }

    /**
     *Cancel Order - Stop Profit and Stop Loss
     *@param contractId Contract ID
     *@param orderIds Order ID, multiple English semicolons separated by commas
     */
    fun cancelOrderTpsl(
        contractId: String,
        orderIds: String,
        consumer: DisposableObserver<ResponseBody>
    ): Disposable? {
        val map = getBaseMaps().apply {
            this["contractId"] = contractId
            this["orderIds"] = orderIds
        }
        return changeIOToMainThread(
            httpHelper.getContractNewUrlService(CpContractApiService::class.java)
                .cancelOrderTpsl(getBaseReqBody(map)), consumer
        )
    }

    /**
     *Currency transfer to contract
     *@param uid user id
     *@param coinSymbol Transfer currency, such as USDT
     *@param amount Transfer amount
     */
    fun coTransferEx(
        uid: String,
        coinSymbol: String,
        amount: String,
        consumer: DisposableObserver<ResponseBody>
    ): Disposable? {
        val map = getBaseMaps().apply {
            this["coinSymbol"] = coinSymbol
            this["amount"] = amount
        }
        return changeIOToMainThread(
            httpHelper.getContractNewUrlService(CpContractApiService::class.java)
                .coTransferEx(getBaseReqBody(map)), consumer
        )
    }

    /**
     *Obtain historical transaction records of entrusted orders
     *@param orderId Order ID
     *@param contractId Contract ID
     */
    fun getHistoryTradeList(
        contractId: String,
        orderId: String,
        consumer: DisposableObserver<ResponseBody>
    ): Disposable? {
        val map = getBaseMaps().apply {
            this["contractId"] = contractId
            this["orderId"] = orderId
        }
        return changeIOToMainThread(
            httpHelper.getContractNewUrlService(CpContractApiService::class.java)
                .getHisTradeList(getBaseReqBody(map)), consumer
        )
    }

    /**
     *Receive simulation contract experience fee
     */
    fun receiveCoupon(consumer: DisposableObserver<ResponseBody>): Disposable? {
        return changeIOToMainThread(
            httpHelper.getContractNewUrlService(CpContractApiService::class.java)
                .receiveCoupon(getBaseReqBody()), consumer
        )
    }

    /**
     *Get depth data
     */
    fun getCoinDepth(contractId:Int,symbol:String,consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["contractId"] = contractId.toString()
            this["symbol"] = symbol
        }
        return changeIOToMainThread(
            httpHelper.getContractNewUrlService(CpContractApiService::class.java)
                .getCoinDepth(getBaseReqBody(map)), consumer
        )
    }


    /**
     *Obtain position/profit and loss records
     *@param page Page
     *@param contractId Contract ID
     */
    fun getHistoryPositionList(
        contractId: String,
        page: String,
        side: String,
        consumer: DisposableObserver<ResponseBody>
    ): Disposable? {
        val map = getBaseMaps().apply {
            if (!contractId.equals("-2")){
                this["contractId"] = contractId
            }
            this["page"] = page
            this["limit"] = "20"
            if (!TextUtils.isEmpty(side)) {
                this["side"] = side
            }
        }
        return changeIOToMainThread(
            httpHelper.getContractNewUrlService(CpContractApiService::class.java)
                .getHistoryPositionList(getBaseReqBody(map)), consumer
        )
    }

    /**
     *Lightning liquidation
     */
    fun lightClose(
        contractId: String,
        open: String,
        side: String,
        positionType: String,
        consumer: DisposableObserver<ResponseBody>
    ): Disposable? {
        val map = getBaseMaps().apply {
            this["contractId"] = contractId
            this["open"] = open
            this["side"] = side
            this["positionType"] = positionType
        }
        return changeIOToMainThread(
            httpHelper.getContractNewUrlService(CpContractApiService::class.java)
                .lightClose(getBaseReqBody(map)), consumer
        )
    }

    /**
     *Obtain line chart/history of contract insurance fund balance
     *@param symbol Query currency
     *@param page Page
     */
    fun riskBalanceList(symbol: String, page: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["symbol"] = symbol
            this["page"] = page
            this["limit"] = "20"
        }
        return changeIOToMainThread(httpHelper.getContractNewUrlService(CpContractApiService::class.java).riskBalanceList(getBaseReqBody(map)), consumer)
    }

    /**
     *Obtain contract fund rate line chart/history
     *@param contractId Contract ID
     *@param page Page
     */
    fun fundingRateList(contractId: String, page: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["contractId"] = contractId
            this["page"] = page
            this["limit"] = "20"
        }
        return changeIOToMainThread(httpHelper.getContractNewUrlService(CpContractApiService::class.java).fundingRateList(getBaseReqBody(map)), consumer)
    }

    /**
     *Obtain insurance fund balance
     *@param coinSymbol Guaranteed Gold Coins
     */
    fun getRiskAccount(coinSymbol: String, consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps().apply {
            this["coinSymbol"] = coinSymbol
        }
        return changeIOToMainThread(httpHelper.getContractNewUrlService(CpContractApiService::class.java).getRiskAccount(getBaseReqBody(map)), consumer)
    }

    /**
     *Obtain the bin list (this interface cannot poll)
     */
    fun getPosition(consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps()
        return changeIOToMainThread(httpHelper.getContractNewUrlService(CpContractApiService::class.java).getposition(getBaseReqBody(map)), consumer)
    }

    /**
     *One key full flush
     */
    fun closeAllPosition(contractIds: String,consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps()
        if (!TextUtils.isEmpty(contractIds)){
            map.put("contractId",contractIds)
        }
        return changeIOToMainThread(httpHelper.getContractNewUrlService(CpContractApiService::class.java).closeAllPosition(getBaseReqBody(map)), consumer)
    }

    /**
     *Obtain the contract optional list
     */
    fun getOptionalList(consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps()
        return changeIOToMainThread(httpHelper.getContractNewUrlService(CpContractApiService::class.java).getOptionalList(getBaseReqBody(map)), consumer)
    }

    /**
     *Save contract selection list
     *ContractOptionalList: contract id optional list, String type (example: '1,2,3,4,5,6,7')
     */
    fun setOptionalList(contractOptionalList: String,consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps()
        map.put("contractOptionalList",contractOptionalList)
        return changeIOToMainThread(httpHelper.getContractNewUrlService(CpContractApiService::class.java).setOptionalList(getBaseReqBody(map)), consumer)
    }

    /**
     *Exchange Rate List Query
     */
    fun getSymbolRateList(consumer: DisposableObserver<ResponseBody>): Disposable? {
        val map = getBaseMaps()
        return changeIOToMainThread(httpHelper.getContractNewUrlService(CpContractApiService::class.java).getSymbolRateList(getBaseReqBody(map)), consumer)
    }

    /**
     * contract public page info
     * @param contractId
     * */
    fun getPublicContractInfo(contractId: Int,consumer: DisposableObserver<ResponseBody>): Disposable?{
        val map = getBaseMaps()
        map["contractId"] = contractId.toString()
        return changeIOToMainThread(httpHelper.getContractNewUrlService(CpContractApiService::class.java).getPublicContractInfo(getBaseReqBody(map)), consumer)
    }

    /**
     * Get Announcement
     * @param isLogin loginStatus 0 Not login，1 Login
     * @param consumer observer
     * @see <a href="https://yapi.dw2nn.com/project/514/interface/api/47413">/get_bulletin_info</a>
     * */
    fun getAnnouncement(isLogin:Byte,consumer: DisposableObserver<ResponseBody>) : Disposable?{
        val map = getBaseMaps()
        map["login"] = isLogin.toString()
        return changeIOToMainThread(httpHelper.getContractNewUrlService(CpContractApiService::class.java).getBulletinInfo(getBaseReqBody(map)),consumer)
    }
    fun getCommonAnnouncement(isLogin:Byte,consumer: DisposableObserver<ResponseBody>) : Disposable?{
        val map = getBaseMaps()
        map["login"] = isLogin.toString()
        return changeIOToMainThread(httpHelper.getContractNewUrlService(CpContractApiService::class.java).getCommonBulletinInfo(getBaseReqBody(map)),consumer)
    }

    /**
     * Close Announcement
     * @param consumer observer
     * @see <a href="https://yapi.dw2nn.com/project/514/interface/api/47416">/confirm_bulletin</a>
     * */
    fun closeAnnouncement(consumer: DisposableObserver<ResponseBody>) : Disposable?{
        val map = getBaseMaps()
        return changeIOToMainThread(httpHelper.getContractNewUrlService(CpContractApiService::class.java).doConfirmBullectin(getBaseReqBody(map)),consumer)
    }

}
