package com.yjkj.chainup.new_version.adapter

import android.util.Log
import android.widget.ImageView
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.yjkj.chainup.R
import com.yjkj.chainup.manager.Contract2PublicInfoManager
import com.yjkj.chainup.new_version.dialog.DialogUtil
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.new_version.view.PositionITemView
import com.yjkj.chainup.util.BigDecimalUtils
import com.yjkj.chainup.util.ColorUtil
import com.yjkj.chainup.util.StringUtil
import com.yjkj.chainup.util.setGoneV3
import org.json.JSONObject
import java.math.BigDecimal

/**
 * @Author: Bertking
 * @Date 2023-09-11-20:32
 * @Description:
 */
class NPositionAdapter(data: ArrayList<JSONObject>) : NBaseAdapter(data = data, layoutId = R.layout.item_hold_position) {
    override fun convert(helper: BaseViewHolder, item: JSONObject) {

        item?.run {
            val baseSymbol = optString("baseSymbol")
            val quoteSymbol = optString("quoteSymbol")
            val leverageLevel = optString("leverageLevel")
            val contractId = optString("contractId")
            val pricePrecision = optString("pricePrecision").toIntOrNull() ?: 2
            val valuePrecision = optString("valuePrecision").toIntOrNull() ?: 4
            val side = optString("side")
            val id = optString("id")
            val liquidationPrice = optString("liquidationPrice")
            val realisedAmountHistory = optString("realisedAmountHistory")
            val holdAmount = optString("holdAmount")
            val unrealisedAmountIndex = optString("unrealisedAmountIndex")
            val avgPrice = optString("avgPrice")
            val volume = optString("volume")
            //Value
            val indexPrice = optString("indexPrice")
            //Tag Price
            val priceValue = optString("priceValue")
            //Return rate
            var unrealisedRateIndex = optString("unrealisedRateIndex")





            helper?.run {


                /**
                 *Order direction
                 */
                setTextColor(R.id.tv_side, ColorUtil.getMainColorType(side == "BUY"))
                val orderSide = if (side == "BUY") {
                     LanguageUtil.getString(context, "contract_text_long")
                } else {
                     LanguageUtil.getString(context, "contract_text_short")
                }
                setText(R.id.tv_side, orderSide)


                /**
                 *Contract Currency Pair Name
                 */
                setText(R.id.tv_coin_name, baseSymbol + quoteSymbol)

                val level = if (Contract2PublicInfoManager.isPureHoldPosition()) {
                    ""
                } else {
                    "(" + leverageLevel + "X)"
                }
                setText(R.id.tv_contract_type, Contract2PublicInfoManager.getContractType(context, contractId.toInt()) + " $level")

                /**
                 *Contract ID
                 *Warehouse division mode: display
                 *Net position: hidden
                 */
                if (Contract2PublicInfoManager.isPureHoldPosition()) {
                    setGoneV3(R.id.tv_position_id, false)
                } else {
                    setGoneV3(R.id.tv_position_id, true)
                    renderData(helper,
                            R.id.tv_position_id,
                             LanguageUtil.getString(context, "contract_position_id"),
                            id
                    )
                }

                
                addChildClickViewIds(R.id.tv_deposit,R.id.btn_adjust_lever,R.id.btn_take_order)

                /**
                 *Qiangping Price
                 */
                val liquidationPriceByPrecision = Contract2PublicInfoManager.cutValueByPrecision(liquidationPrice, pricePrecision)
                renderData(helper,
                        R.id.tv_liquidation_price,
                         LanguageUtil.getString(context, "contract_text_liqPrice") + "(${quoteSymbol})",
                        liquidationPriceByPrecision
                )


                /**
                 *Tag Price
                 */
                val indexPriceByPrecision = Contract2PublicInfoManager.cutValueByPrecision(indexPrice, pricePrecision)
                renderData(helper,
                        R.id.tv_index_price,
                         LanguageUtil.getString(context, "contract_text_liqPrice") + "(${quoteSymbol})",
                        indexPriceByPrecision
                )

                /**
                 *Value
                 */
                val priceValueByPrecision = Contract2PublicInfoManager.cutValueByPrecision(priceValue, pricePrecision)
                renderData(helper,
                        R.id.tv_price_value,
                         LanguageUtil.getString(context,"contract_text_value") + "(BTC)",
                        priceValueByPrecision
                )


                /**
                 *Realized profit and loss (historical profit and loss)
                 */
                var realisedAmountCurrByPrecision = Contract2PublicInfoManager.cutDespoitByPrecision(realisedAmountHistory)
                if (!realisedAmountCurrByPrecision.contains("-")) {
                    realisedAmountCurrByPrecision = "+$realisedAmountCurrByPrecision"
                }
                renderData(helper,
                        R.id.tv_realised_profit,
                         LanguageUtil.getString(context, "contract_text_realisedPNL"),
                        realisedAmountCurrByPrecision
                )


                /**
                 *Unrealized profit and loss (rate of return)
                 */
                var unrealisedAmountIndexByPrecision = Contract2PublicInfoManager.cutDespoitByPrecision(unrealisedAmountIndex)


                
                unrealisedRateIndex = if (StringUtil.checkStr(unrealisedAmountIndex)) {
                    BigDecimal(unrealisedRateIndex).setScale(2, BigDecimal.ROUND_HALF_DOWN).toPlainString()
                } else {
                    "0.00"
                }
                //Return rate
                


                if (!unrealisedAmountIndexByPrecision.contains("-")) {
                    unrealisedAmountIndexByPrecision = "+$unrealisedAmountIndexByPrecision"
                }

                renderData(helper,
                        R.id.tv_unrealised_profit,
                         LanguageUtil.getString(context,"contract_text_unrealisedPNL") + "(${ LanguageUtil.getString(context, "contract_text_returnRateUnit")})",
                        unrealisedAmountIndexByPrecision + ("($unrealisedRateIndex%)")
                )


                /**
                 *Deposit=holdAmount+unrealizedAmountIndex
                 */
                val realHoldAmount = BigDecimalUtils.add(holdAmount.toString(), unrealisedAmountIndex)
                val holdAmountByPrecision = Contract2PublicInfoManager.cutValueByPrecision(realHoldAmount.toString(), valuePrecision)
                renderData(helper,
                        R.id.tv_deposit,
                         LanguageUtil.getString(context, "contract_text_margin"),
                        holdAmountByPrecision + "BTC"
                )

                /**
                 *Average opening price
                 */
                val avgPriceByPrecision = Contract2PublicInfoManager.cutValueByPrecision(avgPrice.toString(), pricePrecision)
                renderData(helper,
                        R.id.tv_avg_price,
                         LanguageUtil.getString(context, "contract_text_openAveragePrice") + "(${quoteSymbol})",
                        avgPriceByPrecision
                )

                /**
                 *Number of positions (pieces)
                 */
                getView<PositionITemView>(R.id.tv_volume)?.run {
                    title =  LanguageUtil.getString(context, "contract_text_positionNumber")
                    value = "${volume}"
                    tailValueColor = ColorUtil.getMainColorType(side == "BUY")
                }


                if (Contract2PublicInfoManager.isPureHoldPosition()) {
                    /**
                     *Adjusting the lever (25x)
                     */
                    setText(R.id.btn_adjust_lever,  LanguageUtil.getString(context, "contract_action_editLever") + "(" + leverageLevel + "x)")
                } else {
                    setText(R.id.btn_adjust_lever,  LanguageUtil.getString(context, "contract_text_limitPositions"))
                }


                /**
                 *Adjust margin
                 */

                getView<PositionITemView>(R.id.tv_deposit)?.tailValueColor = ColorUtil.getColor(R.color.main_blue)
                /**
                 *Sharing function
                 */
                getView<ImageView>(R.id.btn_share).setOnClickListener {
                    DialogUtil.showPositionShareDialog(context ?: return@setOnClickListener,item)
                }

            }


        }


    }


    private fun renderData(helper: BaseViewHolder?, viedId: Int, string: String, values: String) {
        helper?.getView<PositionITemView>(viedId)?.run {
            title = string
            value = values
        }

    }
}
