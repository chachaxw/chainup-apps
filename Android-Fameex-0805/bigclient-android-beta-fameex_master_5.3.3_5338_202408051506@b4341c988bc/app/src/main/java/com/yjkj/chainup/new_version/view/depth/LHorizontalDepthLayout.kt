package com.yjkj.chainup.new_version.view.depth

import androidx.lifecycle.Observer
import android.content.Context
import android.text.TextUtils
import android.util.AttributeSet
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.widget.LinearLayout
import com.chainup.contract.view.dialog.CpTDialog
import com.yjkj.chainup.R
import com.yjkj.chainup.app.AppConstant
import com.yjkj.chainup.bean.coin.CoinMapBean
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.ParamConstant.TYPE_LIMIT
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.extra_service.eventbus.EventBusUtil
import com.yjkj.chainup.extra_service.eventbus.NLiveDataUtil
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.manager.DataManager
import com.yjkj.chainup.manager.RateManager
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.util.ColorUtil
import com.yjkj.chainup.new_version.activity.NewMainActivity
import com.yjkj.chainup.new_version.fragment.NCVCTradeFragment
import com.yjkj.chainup.util.BigDecimalUtils
import com.yjkj.chainup.util.SymbolInterceptUtils
import kotlinx.android.synthetic.main.depth_horizontal_layout_lever.view.*
import kotlinx.android.synthetic.main.item_transaction_detail.view.*
import kotlinx.android.synthetic.main.trade_amount_view.view.*
import org.jetbrains.anko.backgroundColor
import org.jetbrains.anko.layoutInflater
import org.jetbrains.anko.textColor
import org.json.JSONArray
import org.json.JSONObject

/**
 * @Author: Bertking
 * @Date 2023-09-06-11:15
 * @Description:
 */
class LHorizontalDepthLayout @JvmOverloads constructor(context: Context,
                                                       attrs: AttributeSet? = null,
                                                       defStyleAttr: Int = 0
) : LinearLayout(context, attrs, defStyleAttr) {

    val TAG = LHorizontalDepthLayout::class.java.simpleName


    var dialog: CpTDialog? = null

    var tapeDialog: CpTDialog? = null

    var tapeLevel: Int = 0

    var depth_level = 0

    val depthLevels = arrayListOf<String>()

    var transactionData: JSONObject? = null


    var coinMapBean: CoinMapBean = DataManager.getCoinMapBySymbol(PublicInfoDataService.getInstance().currentSymbol)
        set(value) {
            field = value
            trade_amount_view?.coinMapBean = value
            trade_amount_view?.setPrice()
        }

    /**
     *Selling items
     */
    private var sellViewList = mutableListOf<View>()

    /**
     *Buying items
     */
    private var buyViewList = mutableListOf<View>()


    init {

        /**
         *The value here must be: True
         */
        LayoutInflater.from(context).inflate(R.layout.depth_horizontal_layout_lever, this, true)

//        val coinMapData = PublicInfoManager.instance.getCurrentCoinMap()
        val depths = coinMapBean.depth.split(",")

        if (depths.isNotEmpty()) {
            depths.forEach {
                val depth = if (it.contains(".")) {
                    it.replace("0.", "").length.toString()
                } else {
                    "0"
                }
                depthLevels.add(depth)
            }
        }
        depth_level = depthLevels[NCVCTradeFragment.curDepthIndex].toInt()
        tv_change_depth?.text = context.getString(R.string.kline_action_depth) + depth_level

        NLiveDataUtil.observeData((this.context as NewMainActivity), Observer<MessageEvent> {
            if (null == it || !it.isLever) {
                return@Observer
            }
            when (it.msg_type) {
                MessageEvent.symbol_switch_type -> {
                    val symbol = it.msg_content as String
                    if (symbol != coinMapBean.symbol) {
                        depthLevels.clear()
                        coinMapBean = DataManager.getCoinMapBySymbol(symbol)
                        val depths = coinMapBean?.depth?.split(",") ?: return@Observer

                        if (depths.isNotEmpty()) {
                            depths.forEach {
                                val depth = if (it.contains(".")) {
                                    it.replace("0.", "").length.toString()
                                } else {
                                    "0"
                                }
                                depthLevels.add(depth)
                            }
                        }

                        depth_level = depthLevels[NCVCTradeFragment.curDepthIndex].toInt()
                        tv_change_depth?.text = context.getString(R.string.kline_action_depth) + depth_level
                    }
                }

                MessageEvent.DEPTH_DATA_TYPE -> {
                    if (null != it.msg_content) {
                        val jsonObject = it.msg_content as JSONObject
                        transactionData = jsonObject
                        refreshDepthView(jsonObject)
                    }
                }
            }
        })

        /**
         *Select Depth
         */
        tv_change_depth?.setOnClickListener {
            dialog = NewDialogUtils.showBottomListDialog(context, depthLevels, depthLevels.indexOf(depth_level.toString()), object : NewDialogUtils.DialogOnclickListener {
                override fun clickItem(data: ArrayList<String>, item: Int) {
                    dialog?.dismiss()

                    
                    if (NCVCTradeFragment.curDepthIndex != item) {
                        tv_change_depth?.text = context.getString(R.string.kline_action_depth) + data[item]
                        depth_level = data[item].toInt()
                        /**
                         *Remember: Here, only the subscripts need to be passed to the backend, and there are three dimensions of depth: 0, 1, and 2
                         *Details: http://wiki.365os.com/pages/viewpage.action?pageId=2261055
                         *It's time for the zoo
                         */
                        NLiveDataUtil.postValue(MessageEvent(MessageEvent.DEPTH_LEVEL_TYPE, item, true))
                        EventBusUtil.post(MessageEvent(MessageEvent.DEPTH_LEVEL_TYPE, item, true))
                    }
                }

                override fun onDismiss() {

                }
            })

        }


        initDetailView()

        /**
         *Change the style of the disc opening
         */
        ib_tape?.setOnClickListener {
            tapeDialog = NewDialogUtils.showBottomListDialog(context, arrayListOf(context.getString(R.string.contract_text_defaultMarket), context.getString(R.string.contract_text_buyMarket), context.getString(R.string.contract_text_sellMarket)), tapeLevel, object : NewDialogUtils.DialogOnclickListener {
                override fun clickItem(data: ArrayList<String>, item: Int) {
                    tapeDialog?.dismiss()
                    tapeLevel = item
                    changeTape(item)
                }

                override fun onDismiss() {

                }
            })
        }

    }

    fun changeTape(item: Int, needData: Boolean = true) {
        when (item) {
            AppConstant.DEFAULT_TAPE -> {
                ll_buy_price?.visibility = View.VISIBLE
                ll_sell_price?.visibility = View.VISIBLE
                v_tape_line?.visibility = View.VISIBLE
                ColorUtil.setTapeIcon(ib_tape, AppConstant.DEFAULT_TAPE)
                initDetailView()
            }

            AppConstant.BUY_TAPE -> {
                ll_buy_price?.visibility = View.VISIBLE
                ll_sell_price?.visibility = View.GONE
                v_tape_line?.visibility = View.GONE
                ColorUtil.setTapeIcon(ib_tape, AppConstant.BUY_TAPE)
                initDetailView(10)
            }

            AppConstant.SELL_TAPE -> {
                ll_buy_price?.visibility = View.GONE
                v_tape_line?.visibility = View.GONE
                ll_sell_price?.visibility = View.VISIBLE
                ColorUtil.setTapeIcon(ib_tape, AppConstant.SELL_TAPE)
                initDetailView(10)
            }
        }
        if (needData) {
            refreshDepthView(transactionData)
        }
    }

    /**
     *Buying and selling order
     *
     *Initialize transaction details record view
     */
    fun initDetailView(items: Int = 5) {
        sellViewList.clear()
        buyViewList.clear()

        if (ll_buy_price?.childCount ?: 0 > 0) {
            (ll_buy_price as LinearLayout).removeAllViews()
        }

        if (ll_sell_price?.childCount ?: 0 > 0) {
            (ll_sell_price as LinearLayout).removeAllViews()
        }

        for (i in 0 until items) {
            /**
             *Selling orders
             */
            val sell_layout: View = context.layoutInflater.inflate(R.layout.item_transaction_detail, null)

            sell_layout.tv_price_item?.textColor = ColorUtil.getMainColorType(isRise = false)
            NLiveDataUtil.observeForeverData {
                if (null != it && MessageEvent.color_rise_fall_type == it.msg_type) {
                    sell_layout.tv_price_item?.textColor = ColorUtil.getMainColorType(isRise = false)
                }
            }

            sell_layout.setOnClickListener {
                val result = sell_layout.tv_price_item?.text.toString()
                if (!TextUtils.isEmpty(result) && result != "--" && result != "null") {
                    if (trade_amount_view.priceType == TYPE_LIMIT) {
                        
                        
                        et_price?.setText(BigDecimalUtils.divForDown(result, coinMapBean.price).toPlainString())
//                        tv_convert_price?.text = RateManager.getCNYByCoinMap(PublicInfoManager.instance.getCurrentCoinMap(), result)
                    }
                }
            }
            sellViewList.add(sell_layout)

            /**
             *Buying
             */
            val buy_layout: View = context.layoutInflater.inflate(R.layout.item_transaction_detail, null)

            buy_layout.tv_price_item?.textColor = ColorUtil.getMainColorType()
            NLiveDataUtil.observeForeverData {
                if (null != it && MessageEvent.color_rise_fall_type == it.msg_type) {
                    buy_layout.tv_price_item?.textColor = ColorUtil.getMainColorType()
                }
            }

            buy_layout.setOnClickListener {
                val result = buy_layout.tv_price_item?.text.toString()
                if (!TextUtils.isEmpty(result) && result != "--" && result != "null") {
                    if (trade_amount_view.priceType == TYPE_LIMIT) {
                        
                        
                        et_price?.setText(BigDecimalUtils.divForDown(result, coinMapBean.price).toPlainString())
                        tv_convert_price?.text = RateManager.getCNYByCoinMap(DataManager.getCoinMapBySymbol(PublicInfoDataService.getInstance().currentSymbol), result)
                    }
                }
            }
            buyViewList.add(buy_layout)
        }


        buyViewList.forEach {
            ll_buy_price?.addView(it)
        }

        sellViewList.forEach {
            ll_sell_price?.addView(it)
        }
    }

    /**
     *Update data for purchase and sale orders
     */
    fun refreshDepthView(data: JSONObject?) {
        data?.run {
            val tick = this.optJSONObject("tick")
            /**
             *The largest selling volume
             */
            val askList = arrayListOf<JSONArray>()
            val asks = tick.optJSONArray("asks")
            for (i in 0 until asks.length()) {
                askList.add(asks.optJSONArray(i))
            }

            val askMaxVolJson = askList.maxByOrNull {
                it.optDouble(1)
            }
            val askMaxVol = askMaxVolJson?.optDouble(1)?.toFloat() ?: 1f
            

            /**
             *The largest buying volume
             */
            val buyList = arrayListOf<JSONArray>()
            val buys = tick.optJSONArray("buys")
            for (i in 0 until buys.length()) {
                buyList.add(buys.optJSONArray(i))
            }

            /**
             *The largest buying volume
             */
            val buyMaxVolJson = buyList.maxByOrNull {
                it.optDouble(1)
            }
            val buyMaxVol = buyMaxVolJson?.optDouble(1)?.toFloat() ?: 1f
            

            val maxVol = Math.max(askMaxVol, buyMaxVol)

            

            sellTape(askList, maxVol)
            buyTape(buyList, maxVol)
        }


    }

    /**
     *Selling orders
     */
    private fun sellTape(list: ArrayList<JSONArray>, maxVol: Float) {
        list.sortByDescending {
            it.optDouble(0)
        }

        for (i in 0 until sellViewList.size) {
            /**
             *Selling orders
             */
            if (list.size > sellViewList.size) {
                val subList = list.subList(list.size - sellViewList.size, list.size)

                /*****Deep background color START****/
                sellViewList[i].fl_bg_item.backgroundColor = ColorUtil.getMinorColorType(isRise = false)
                val layoutParams = sellViewList[i].fl_bg_item.layoutParams
                val width = (subList[i].optDouble(1).toFloat() / maxVol) * measuredWidth / 2
                
                layoutParams.width = width.toInt()
                sellViewList[i].fl_bg_item.layoutParams = layoutParams
                /*****Deep background color END****/
                sellViewList[i].tv_price_item.text = SymbolInterceptUtils.interceptData(
                        subList[i].optString(0).replace("\"", "").trim(),
                        depth_level,
                        "price")
                sellViewList[i].tv_quantity_item.text = BigDecimalUtils.showDepthVolume(subList[i].optString(1))

            } else {
                
                val temp = sellViewList.size - list.size
                sellViewList[i].tv_price_item.text = "--"
                sellViewList[i].tv_quantity_item.text = "--"
                if (i >= temp) {
                    /*****Deep background color START****/
                    sellViewList[i].fl_bg_item.backgroundColor = ColorUtil.getMinorColorType(isRise = false)
                    val layoutParams = sellViewList[i].fl_bg_item.layoutParams
                    val width = (list[i - temp].optDouble(1).toFloat() / maxVol) * measuredWidth / 2
                    layoutParams.width = width.toInt()
                    sellViewList[i].fl_bg_item.layoutParams = layoutParams
                    /*****Deep background color END****/
                    sellViewList[i].tv_price_item.text = SymbolInterceptUtils.interceptData(
                            list[i - temp].optString(0).replace("\"", "").trim(),
                            depth_level,
                            "price")
                    sellViewList[i].tv_quantity_item.text = BigDecimalUtils.showDepthVolume(list[i - temp].optString(1))

                }
            }


        }
    }

    /**
     *Buying
     */
    private fun buyTape(list: ArrayList<JSONArray>, maxVol: Float) {

        /**
         *Buying for maximum
         */
        list.sortByDescending {
            it.optDouble(0)
        }

        for (i in 0 until buyViewList.size) {
            /**
             *Buying
             */
            if (list.size > i) {
                /*****Deep background color START****/
                buyViewList[i].fl_bg_item.backgroundColor = ColorUtil.getMinorColorType()
                val layoutParams = buyViewList[i].fl_bg_item.layoutParams
                val width = (list[i].optDouble(1).toFloat() / maxVol) * measuredWidth / 2
                layoutParams.width = width.toInt()
                buyViewList[i].fl_bg_item.layoutParams = layoutParams

                /*****Deep background color END****/
                buyViewList[i].tv_price_item.text =
                        SymbolInterceptUtils.interceptData(
                                list[i].optString(0).replace("\"", "").trim(),
                                depth_level,
                                "price")
                buyViewList[i].tv_quantity_item.text = BigDecimalUtils.showDepthVolume(list[i].optString(1).trim())
            } else {
                buyViewList[i].run {
                    tv_price_item.text = "--"
                    tv_quantity_item.text = "--"
                    fl_bg_item.setBackgroundResource(R.color.transparent)
                }

            }
        }
    }


    override fun onVisibilityChanged(changedView: View, visibility: Int) {
        super.onVisibilityChanged(changedView, visibility)
        if (visibility == View.VISIBLE) {
            
            depth_level = depthLevels[NCVCTradeFragment.curDepthIndex].toInt()
            tv_change_depth?.text = context.getString(R.string.kline_action_depth) + depth_level

        }
    }
}
