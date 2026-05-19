
package com.yjkj.chainup.new_version.adapter

import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.coorchice.library.SuperTextView
import com.fengniao.news.util.DateUtil
import com.yjkj.chainup.R
import com.yjkj.chainup.manager.Contract2PublicInfoManager
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.new_version.view.PositionITemView
import com.yjkj.chainup.util.*
import org.jetbrains.anko.textColor
import org.json.JSONObject

/**
 * @Author: Bertking
 * @Date 2023-09-11-20:07
 * @Description:
 */
class NContractCurrentEntrustAdapter(data: ArrayList<JSONObject>) : NBaseAdapter(data = data, layoutId = R.layout.item_current_entrust_contract) {
    override fun convert(helper: BaseViewHolder, item: JSONObject) {

        item?.run {
            val baseSymbol = optString("baseSymbol")
            val quoteSymbol = optString("quoteSymbol")
            val leverageLevel = optString("leverageLevel")
            val contractId = optString("contractId")
            val side = optString("side")
            val action = optString("action")
            val price = optString("price")
            val type = optString("type")
            val pricePrecision = optString("pricePrecision")
            val ctime = optString("ctime")
            val volume = optString("volume")
            val avgPrice = optString("avgPrice")
            val dealVolume = optString("dealVolume")
            val statusText = optString("statusText")
            val symbol = optString("symbol")
            val orderPriceValue = optString("orderPriceValue")
            val undealVolume = optString("undealVolume")
            val status = optString("status")

            if (contractId.toInt() != Contract2PublicInfoManager.currentContract()?.id) {
                return
            }

            helper?.run {
                /**
                 *Market price list hidden button
                 *(1: Limit Order, 2: Market Order)
                 */
                setGoneV3(R.id.tv_status, type != "2")
                addChildClickViewIds(R.id.tv_status)

                /**
                 *Buyer and Seller
                 */
                setTextColor(R.id.tv_side, ColorUtil.getMainColorType(isRise = side == "BUY"))
                if (Contract2PublicInfoManager.isPureHoldPosition()) {
                    val text = if (side == "BUY") {
                         LanguageUtil.getString(context, "contract_text_long")
                    } else {
                         LanguageUtil.getString(context, "contract_text_short")
                    }
                    setText(R.id.tv_side, text)
                } else {
                    if (side == "BUY") {
                        val text = if (action == "OPEN") {
                            //Go long
                             LanguageUtil.getString(context, "contract_action_long")
                        } else {
                            //Pingduo
                             LanguageUtil.getString(context, "contract_balance_more")
                        }
                        setText(R.id.tv_side, text)

                    } else {
                        val text = if (action == "OPEN") {
                            //Short selling
                             LanguageUtil.getString(context, "contract_action_short")
                        } else {
                             LanguageUtil.getString(context, "contract_balance_empty")
                        }
                        setText(R.id.tv_side, text)
                    }
                }

                setText(R.id.tv_contract_symbol, symbol)
                val level = if (!Contract2PublicInfoManager.isPureHoldPosition()) {
                    " (${leverageLevel}X)"
                } else {
                    ""
                }
                setText(R.id.tv_contract_type, Contract2PublicInfoManager.getContractType(context, contractId.toInt()) + level)


                /**
                 *Price (the price on the market price list is "market price")
                 *(1: Limit Order, 2: Market Order)
                 */
                getView<PositionITemView>(R.id.tv_entrust_price)?.run {
                    title =  LanguageUtil.getString(context, "contract_text_trustPrice") + "(${quoteSymbol})"
                    value = if (type == "1") {
                        val price4Precision = Contract2PublicInfoManager.cutValueByPrecision(price.toString(), pricePrecision?.toInt()
                                ?: 4)
                        price4Precision
                    } else {
                        ( LanguageUtil.getString(context, "contract_action_marketPrice"))
                    }
                }


                val createTime = TimeUtil.instance.getTime(ctime)


                /**
                 *Order time
                 */
                getView<PositionITemView>(R.id.tv_date)?.run {
                    title =  LanguageUtil.getString(context, "kline_text_dealTime")
                    value = createTime
                }


                /**
                 *Number of positions (pieces)
                 */
                getView<PositionITemView>(R.id.tv_position_amount)?.run {
                    title =  LanguageUtil.getString(context, "contract_text_positionNumber")
                    value = volume
                    tailValueColor = ColorUtil.getMainColorType(side == "BUY")
                }


                /**
                 *Average transaction price
                 */
                val avgPrice4Precision = Contract2PublicInfoManager.cutValueByPrecision(avgPrice, pricePrecision?.toInt()
                        ?: 4)
                getView<PositionITemView>(R.id.tv_avg_price)?.run {
                    title =  LanguageUtil.getString(context, "contract_text_dealAverage") + "(${quoteSymbol})"
                    value = (avgPrice4Precision)
                }


                /**
                 *Closed
                 */
                getView<PositionITemView>(R.id.tv_deal)?.run {
                    title =  LanguageUtil.getString(context, "contract_text_dealDone") + "(${ LanguageUtil.getString(context, "contract_text_volumeUnit")})"
                    value = dealVolume
                }

                /**
                 *Value
                 */
                getView<PositionITemView>(R.id.tv_entrust_value)?.run {
                    title =  LanguageUtil.getString(context, "contract_text_value") + "(BTC)"
                    value = Contract2PublicInfoManager.cutDespoitByPrecision(orderPriceValue)
                }


                /**
                 *Remaining quantity
                 */
                getView<PositionITemView>(R.id.tv_remain_volume)?.run {
                    title =  LanguageUtil.getString(context, "contract_text_remaining") + "(${ LanguageUtil.getString(context, "contract_text_volumeUnit")})"
                    value = undealVolume
                }


                /**
                 *Order status:
                 *0: Initial status 1: New order 2: Full transaction 3: Partial transaction 4: Canceled 5: Pending cancellation 6: Abandoned 7: Partial transaction has been cancelled (0 1 3 shows the cancellation button
                 */
                getView<SuperTextView>(R.id.tv_status)?.run {
                    when (status) {
                        "0", "1", "3" -> {
                            text =  LanguageUtil.getString(context, "contract_action_cancle")
                            textColor = ColorUtil.getColor(R.color.main_blue)
                        }
                        else -> {
                            text = statusText
                            textColor = ColorUtil.getColor(R.color.normal_text_color)
                        }
                    }

                }

            }

        }


    }
}
