package com.chainup.contract.utils


/**
 * @author ZhongWei
 * @time 2020/7/1 17:37
 *@ description Contract to buy or sell data auxiliary class temporarily
 **/
class CpContractBuyOrSellHelper {

    companion object {

        /**
         *Price limit
         */
        const val CONTRACT_ORDER_LIMIT = 0

        /**
         *Market price
         */
        const val CONTRACT_ORDER_MARKET = 1

        /**
         *Plan
         */
        const val CONTRACT_ORDER_PLAN = 2

        /**
         *Buy a price
         */
        const val CONTRACT_ORDER_BID_PRICE = 3

        /**
         *Sell for a price
         */
        const val CONTRACT_ORDER_ASK_PRICE = 4

        /**
         *Price limit (senior entrustment)
         */
        const val CONTRACT_ORDER_ADVANCED_LIMIT = 5

        /**
         *Only stop earning conditions
         */
        const val CONDITIONCOMMISSIONORDER_TYPE_PROFIT = 1

        /**
         *Only stop loss conditions
         */
        const val CONDITIONCOMMISSIONORDER_TYPE_LOSS = 2

        /**
         *Stop profit and stop loss
         */
        const val CONDITIONCOMMISSIONORDER_TYPE_ALL = 3
    }

    /**
     *True buy
     *False sell
     */
    var isBuy: Boolean = true

    /**
     *0 Open Position
     *Closing position
     */
    var tradeType: Int = 0

    var orderType: Int = 1

    var isOpen: Boolean = true
    var isOneWayPosition: Boolean = false
    var isOto: Boolean = false


    var rivalPricePosition: Int = 0




    /**
     *Price Type
     */
    var priceType: Int = 0


    /**
     *Counterparty Price Type
     */
    var rivalPriceType: Int = 0

    /**
     *Buy and sell for one price
     */
    var priceDisplay: String = ""

    /**
     *Enter Quantity
     */
    var etPrice: String? = null

    /**
     *Enter Quantity
     */
    var etPosition: String? = null

    /**
     *Whether to display stop profit and stop loss
     */
    var showRateAndLoss: Boolean = false

    /**
     * tagPrice
     */
    var tagPrice = "0.00"


}
