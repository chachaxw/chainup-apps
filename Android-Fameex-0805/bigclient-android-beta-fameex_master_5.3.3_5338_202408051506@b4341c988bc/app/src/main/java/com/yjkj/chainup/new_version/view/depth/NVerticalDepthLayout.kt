package com.yjkj.chainup.new_version.view.depth

import androidx.lifecycle.Observer
import android.content.Context
import android.text.SpannableString
import android.text.TextUtils
import android.text.method.LinkMovementMethod
import android.util.AttributeSet
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.widget.LinearLayout
import android.widget.TextView
import com.chainup.contract.view.dialog.CpTDialog
import com.yjkj.chainup.R
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.ParamConstant.TYPE_LIMIT
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.extra_service.eventbus.EventBusUtil
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.extra_service.eventbus.NLiveDataUtil
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.manager.RateManager
import com.yjkj.chainup.new_version.activity.NewMainActivity
import com.yjkj.chainup.new_version.activity.leverage.NLeverFragment
import com.yjkj.chainup.new_version.activity.leverage.TradeFragment
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.fragment.NCVCTradeFragment
import com.yjkj.chainup.util.*
import kotlinx.android.synthetic.main.depth_etf_layout.view.*
import kotlinx.android.synthetic.main.depth_vertical_layout.view.*
import kotlinx.android.synthetic.main.depth_vertical_layout.view.ll_etf_item
import kotlinx.android.synthetic.main.depth_vertical_layout.view.trade_bottomInformation
import kotlinx.android.synthetic.main.depth_vertical_layout.view.tv_close_price
import kotlinx.android.synthetic.main.depth_vertical_layout.view.tv_converted_close_price
import kotlinx.android.synthetic.main.depth_vertical_layout.view.tv_etf_price
import kotlinx.android.synthetic.main.item_depth_buy.view.*
import kotlinx.android.synthetic.main.item_depth_buy.view.fl_bg_item_for_depth
import kotlinx.android.synthetic.main.item_depth_buy.view.tv_price_item_for_depth
import kotlinx.android.synthetic.main.item_depth_buy.view.tv_quantity_item_for_depth
import kotlinx.android.synthetic.main.item_depth_sell.view.im_sell
import org.jetbrains.anko.*
import org.json.JSONArray
import org.json.JSONObject
import java.math.BigDecimal
import kotlin.collections.ArrayList

/**
 * @Author: Bertking
 * @Date 2023-09-10-17:27
 * @Description:
 */
class NVerticalDepthLayout @JvmOverloads constructor(context: Context,
                                                     attrs: AttributeSet? = null,
                                                     defStyleAttr: Int = 0
) : LinearLayout(context, attrs, defStyleAttr) {
    val TAG = NVerticalDepthLayout::class.java.simpleName
    var dialog: CpTDialog? = null

    var depth_level = 0
    val depthLevels = arrayListOf<String>()

    var transactionData: JSONObject? = null

    var depthPos=0
    val depthLevelsBuff = arrayListOf<String>()

    /**
     *Selling items
     */
    private var sellViewList = mutableListOf<View>()

    /**
     *Buying items
     */
    private var buyViewList = mutableListOf<View>()

    var orderList = mutableListOf<JSONObject>()

    var coinMapData: JSONObject? = NCoinManager.getSymbolObj(PublicInfoDataService.getInstance().currentSymbol)
        set(value) {
            field = value
            judgeDepthLevel(isInited = true)
            setDepth(context)

        }


    init {
        /**
         *The value here must be: True
         */
        LayoutInflater.from(context).inflate(R.layout.depth_vertical_layout, this, true)

        setDepth(context)

        TradeFragment.liveData4DepthData.observe((this.context as NewMainActivity), Observer<MessageEvent> {
            if (null == it) {
                return@Observer
            }

            if (TradeFragment.currentIndex == ParamConstant.CVC_INDEX_TAB) {
                if (it.isLever) {
                    return@Observer
                }
            } else {
                if (!it.isLever) {
                    return@Observer
                }
            }
            when (it.msg_type) {
                MessageEvent.DEPTH_DATA_TYPE -> {
                    if (null != it.msg_content) {
                        val symbol = coinMapData?.optString("symbol")
                        if (symbol == it.msg_content_data as String) {
                            transactionData = it.msg_content as JSONObject
                            refreshDepthView(transactionData)
                        }
                    }
                }
            }
        })


        ll_etf_item?.setOnClickListener {
            NewDialogUtils.showSingleDialog(context, LanguageUtil.getString(context, "etf_text_networthPrompt"), null,
                    "", LanguageUtil.getString(context, "alert_common_iknow"), false)
        }

        NLiveDataUtil.observeData((this.context as NewMainActivity), Observer<MessageEvent> {
            if (null == it) {
                return@Observer
            }

            if (TradeFragment.currentIndex == ParamConstant.CVC_INDEX_TAB) {
                if (it.isLever) {
                    return@Observer
                }
            } else {
                if (!it.isLever) {
                    return@Observer
                }
            }


            when (it.msg_type) {
                MessageEvent.TAB_TYPE -> {
                    coinMapData = if (it.isLever) {
                        NCoinManager.getSymbolObj(PublicInfoDataService.getInstance().currentSymbol4Lever)
                    } else {
                        NCoinManager.getSymbolObj(PublicInfoDataService.getInstance().currentSymbol)
                    }
                    setDepth(context)
                    clearDepthView()
                }

                //Switch Currency
                MessageEvent.symbol_switch_type -> {
                    if (null != it.msg_content) {
                        var symbol = it.msg_content as String
                        if (symbol != coinMapData?.optString("symbol")) {
                            coinMapData = NCoinManager.getSymbolObj(symbol)
                            judgeDepthLevel(isInited = true)
                            setDepth(context)
                        }
                    }
                }

            }

        })

        /**
         *Select Depth
         */
        tv_change_depth?.setOnClickListener {
            dialog = NewDialogUtils.showBottomListDialog(context, depthLevelsBuff, depthPos, object : NewDialogUtils.DialogOnclickListener {
                override fun clickItem(data: ArrayList<String>, item: Int) {
                    dialog?.dismiss()
                    if (judgeDepthLevel() != item) {
//                        tv_change_depth?.text = LanguageUtil.getString(context, "kline_action_depth") + " " + data[item]
                        (tv_change_depth.getChildAt(0) as TextView)?.text = depthLevelsBuff[item]
//                        depth_level = data[item].toInt()
                        depth_level = depthLevels[item].toInt()
                        depthPos=item;

                        if (TradeFragment.currentIndex == ParamConstant.LEVER_INDEX_TAB) {
                            NLeverFragment.curDepthIndex = item
                        } else {
                            NCVCTradeFragment.curDepthIndex = item
                        }

                        /**
                         *Remember: Here, only the subscripts need to be passed to the backend, and there are three dimensions of depth: 0, 1, and 2
                         *Details: http://wiki.365os.com/pages/viewpage.action?pageId=2261055
                         *It's time for the zoo
                         */
                        var isLever = TradeFragment.currentIndex == ParamConstant.LEVER_INDEX_TAB
                        LogUtil.d(TAG, "tv_change_depth==isLever is $isLever,item is $item")
                        NLiveDataUtil.postValue(MessageEvent(MessageEvent.DEPTH_LEVEL_TYPE, item, isLever))
                        EventBusUtil.post(MessageEvent(MessageEvent.DEPTH_LEVEL_TYPE, item, isLever))
                    }
                }

                override fun onDismiss() {

                }
            })

        }

        initDepthView()

    }


    /**
     *Buying and selling order
     *Initialize transaction details record view
     */
    private fun initDepthView() {

        for (i in 1..6) {
            /**
             *Selling orders
             */
            val view: View = context.layoutInflater.inflate(R.layout.item_depth_sell, null)
            view.tv_price_item_for_depth.setTextColor(ColorUtil.getMainColorType(false))
            view.im_sell?.backgroundResource = ColorUtil.getMainTickColorType(false)
            NLiveDataUtil.observeForeverData {
                if (null != it && MessageEvent.color_rise_fall_type == it.msg_type) {
                    view.tv_price_item_for_depth.setTextColor(ColorUtil.getMainColorType(false))
                }
            }

            view.setOnClickListener {
                val result = view.tv_price_item_for_depth?.text.toString()
                click2Data(result)
            }

            ll_sell.addView(view)
            sellViewList.add(view)

            /***********/

            /**
             *Buying
             */
            val view1: View = context.layoutInflater.inflate(R.layout.item_depth_buy, null)
            view1.im_buy?.backgroundResource = ColorUtil.getMainTickColorType(true)
            view1.tv_price_item_for_depth.setTextColor(ColorUtil.getMainColorType())
            NLiveDataUtil.observeForeverData {
                if (null != it && MessageEvent.color_rise_fall_type == it.msg_type) {
                    view1.tv_price_item_for_depth.setTextColor(ColorUtil.getMainColorType())
                }
            }

            view1.setOnClickListener {
                val result = view1.tv_price_item_for_depth?.text.toString()
                click2Data(result)
            }
            ll_buy.addView(view1)
            buyViewList.add(view1)
        }
    }


    /**
     *Reset the data of the order
     */
    fun clearDepthView() {
        if (sellViewList.isEmpty()) return
        if (buyViewList.isEmpty()) return

        for (i in 0 until 6) {
            sellViewList[i].run {
                tv_price_item_for_depth.text = "--"
                tv_quantity_item_for_depth.text = "--"
                fl_bg_item_for_depth.setBackgroundResource(R.color.transparent)
            }

            buyViewList[i].run {
                tv_price_item_for_depth.text = "--"
                tv_quantity_item_for_depth.text = "--"
                fl_bg_item_for_depth.setBackgroundResource(R.color.transparent)
            }
        }
        tv_close_price?.text = "--"
        tv_converted_close_price?.text = "--"
    }

    private fun click2Data(result: String) {
        if (!TextUtils.isEmpty(result) && result != "--" && result != "null") {
            if (trade_amount_view_l.priceType == TYPE_LIMIT) {
                val pricePrecision = coinMapData?.optInt("price", 2) ?: 2
                val tempPrice = BigDecimalUtils.divForDown(result, pricePrecision).toPlainString()
//                et_price?.setText(BigDecimalUtils.divForDown(result, pricePrecision).toPlainString())
//                tv_convert_price?.text = RateManager.getCNYByCoinMap(DataManager.getCoinMapBySymbol(PublicInfoDataService.getInstance().currentSymbol), result)
                trade_amount_view_l.initClickData(tempPrice)
            }
        }
    }


    /**
     *The largest buying volume
     */


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
            val asks = tick.optJSONArray("asks") ?: return
            if (asks.length() != 0) {
                val item = asks.optJSONArray(0)
                trade_amount_view_l.initTick(item, false, depth_level)
            }
            for (i in (asks.length() - 1).downTo(0)) {
                askList.add(asks.optJSONArray(i))
            }

            val askMaxVolJson = askList.maxByOrNull {
                it.optDouble(1)
            }
            val askMaxVol = askMaxVolJson?.optDouble(1) ?: 1.0
            

            /**
             *The largest buying volume
             */
            val buyList = arrayListOf<JSONArray>()
            val buys = tick.optJSONArray("buys")
            if (buys.length() != 0) {
                val item = buys.optJSONArray(0)
                trade_amount_view_l.initTick(item, true, depth_level)
            }
            for (i in 0 until buys.length()) {
                buyList.add(buys.optJSONArray(i))
            }

            val buyMaxVolJson = buyList.maxByOrNull {
                it.optDouble(1)
            }
            val buyMaxVol = buyMaxVolJson?.optDouble(1) ?: 1.0
            LogUtil.d(TAG, "========buyMAX:$buyMaxVol=======")

            val maxVol = Math.max(askMaxVol, buyMaxVol)

            LogUtil.d(TAG, "========maxVol:$maxVol=========")


            for (i in 0 until sellViewList.size) {
                /**
                 *Selling orders
                 */
                if (askList.size > sellViewList.size) {
                    val subList = askList.subList(askList.size - sellViewList.size, askList.size).reversed()
                    val maxVolJson = subList.maxByOrNull {
                        it.optDouble(1)
                    }

                    val newMaxVol = maxVolJson?.optDouble(1) ?: 1.0
                    if (subList.isNotEmpty()) {
                        /**
                         *Remove large values
                         */
                        /*****Deep background color START****/
                        sellViewList[i].fl_bg_item_for_depth?.backgroundColor = ColorUtil.getMinorColorType(isRise = false)

                        val layoutParams = sellViewList[i].fl_bg_item_for_depth?.layoutParams
                        val width = (subList[i].optDouble(1) / newMaxVol) * (measuredWidth / 2)
                        layoutParams?.width = width.toInt()
                        LogUtil.d(TAG, "====1111=width:${width.toInt()}=======")

                        sellViewList[i].run {
                            fl_bg_item_for_depth?.layoutParams = layoutParams
                            val price = SymbolInterceptUtils.interceptData(
                                    subList[i].optString(0).trim(),
                                    depth_level,
                                    "price")
                            /*****Deep background color END****/
                            tv_price_item_for_depth?.text = price

                            val order = orderList.filter {
                                val isSell = it.optString("side") == "SELL"
                                var orderPrice = it.getPriceSplitZero()
                                if(isSell){
                                    orderPrice = BigDecimal(orderPrice).setScale(depth_level, BigDecimal.ROUND_UP).toPlainString()
                                }else{
                                    orderPrice = BigDecimal(orderPrice).setScale(depth_level, BigDecimal.ROUND_DOWN).toPlainString()
                                }
                                isSell && orderPrice.equals(price)
                            }
                            
                            im_sell.visibility = order.isNotEmpty().visiable()
                            tv_quantity_item_for_depth?.text =
                                    BigDecimalUtils.showDepthVolumeNew(subList[i].optString(1).trim())
                        }
                    }
                } else {
                    val maxVolJson = askList.maxByOrNull {
                        it.optDouble(1)
                    }

                    val newMaxVol = maxVolJson?.optDouble(1) ?: 1.0
                    sellViewList[i].run {
                        tv_price_item_for_depth?.text = "--"
                        tv_quantity_item_for_depth?.text = "--"
                        im_sell.visibility = View.INVISIBLE
                        sellViewList[i].fl_bg_item_for_depth?.backgroundColor = ColorUtil.getColor(R.color.transparent)

                    }

                    if (i < askList.size) {
                        /*****Deep background color START****/
                        sellViewList[i].fl_bg_item_for_depth?.backgroundColor = ColorUtil.getMinorColorType(isRise = false)
                        val layoutParams = sellViewList[i].fl_bg_item_for_depth?.layoutParams
                        val width = (askList.reversed()[i].optDouble(1) / newMaxVol) * (measuredWidth / 2)
                        layoutParams?.width = width.toInt()
                        LogUtil.d(TAG, "====1111=width:${width.toInt()}=======")
                        sellViewList[i].fl_bg_item_for_depth?.layoutParams = layoutParams

                        /*****Deep background color END****/
                        val price4DepthSell = askList.reversed()[i].optString(0).trim()

                        sellViewList[i].run {
                            val price = SymbolInterceptUtils.interceptData(
                                    price4DepthSell,
                                    depth_level,
                                    "price")
                            tv_price_item_for_depth?.text = price

                            val order = orderList.filter {
                                val isSell = it.optString("side") == "SELL"
                                var orderPrice = it.getPriceSplitZero()
                                if(isSell){
                                    orderPrice = BigDecimal(orderPrice).setScale(depth_level,BigDecimal.ROUND_UP).toPlainString()
                                }else{
                                    orderPrice = BigDecimal(orderPrice).setScale(depth_level,BigDecimal.ROUND_DOWN).toPlainString()
                                }
                                isSell && orderPrice.equals(price)
                            }
                            
                            im_sell.visibility = order.isNotEmpty().visiable()
                            tv_quantity_item_for_depth?.text =
                                    BigDecimalUtils.showDepthVolumeNew(askList.reversed()[i].optString(1).trim())
                        }

                    }
                }

                /**
                 *Buying
                 */
                if (buyList.size > i) {

                    val maxVolJson = askList.maxByOrNull {
                        it.optDouble(1)
                    }

                    val newMaxVol = maxVolJson?.optDouble(1) ?: 1.0
                    /*****Deep background color START****/
                    buyViewList[i].fl_bg_item_for_depth?.backgroundColor = ColorUtil.getMinorColorType()

                    val layoutParams = buyViewList[i].fl_bg_item_for_depth.layoutParams
                    val width = (buyList[i].optDouble(1) / newMaxVol) * (measuredWidth / 2)
                    layoutParams.width = width.toInt()
                    LogUtil.d(TAG, "==buy==1111=width:${width.toInt()}=======")
                    buyViewList[i].fl_bg_item_for_depth?.layoutParams = layoutParams
                    /*****Deep background color END****/
                    val price4DepthBuy = buyList[i].optString(0).trim()

                    
                    buyViewList[i].run {
                        val price = SymbolInterceptUtils.interceptData(
                                price4DepthBuy,
                                depth_level,
                                "price")
                        tv_price_item_for_depth?.text = price
                        val order = orderList.filter {
                            val isBuy =  it.optString("side") == "BUY"
                            var orderPrice = it.getPriceSplitZero()
                            if(!isBuy){
                                orderPrice = BigDecimal(orderPrice).setScale(depth_level,BigDecimal.ROUND_UP).toPlainString()
                            }else{
                                orderPrice = BigDecimal(orderPrice).setScale(depth_level,BigDecimal.ROUND_DOWN).toPlainString()
                            }
                            isBuy && orderPrice.equals(price)
                        }
                        
                        im_buy.visibility = order.isNotEmpty().visiable()
                        tv_quantity_item_for_depth?.text =
                                BigDecimalUtils.showDepthVolumeNew(buyList[i].optString(1).trim())
                    }
                } else {
                    buyViewList[i].run {
                        tv_price_item_for_depth?.text = "--"
                        tv_quantity_item_for_depth?.text = "--"
                        im_buy.visibility = View.INVISIBLE
                        fl_bg_item_for_depth?.setBackgroundResource(R.color.transparent)
                    }
                }
            }
        }
    }

    //Multiple ratio
    private fun setHeadetLeve(context: Context) {

        if (isLevel) {
            tradev_bottomInformationview.visibility = View.GONE
            tradev_top.visibility = View.GONE
            return
        }
        var topview = findViewById<LinearLayout>(R.id.tradev_top)
        topview?.setVisibility(View.VISIBLE)


        var topviewright = findViewById<LinearLayout>(R.id.tradev_topright)
        topviewright?.setVisibility(View.VISIBLE)


        var etfUpAndDown = coinMapData?.optJSONArray("etfUpAndDown")
        if (etfUpAndDown?.length() == 2) {
            val coinLeft = NCoinManager.getMarketCoinObj(etfUpAndDown.getString(0))
            changeCoinUpOrDown(true, coinLeft)
            val coinRight = NCoinManager.getMarketCoinObj(etfUpAndDown.getString(1))
            changeCoinUpOrDown(false, coinRight)
            if (coinLeft != null || coinRight != null) {
                topview?.visibility = View.VISIBLE
            } else {
                topview?.visibility = View.GONE
            }
        } else if (etfUpAndDown?.length() == 1) {
            val coinLeft = NCoinManager.getMarketCoinObj(etfUpAndDown.getString(0))
            changeCoinUpOrDown(false, coinLeft)
        } else {
            topview?.setVisibility(View.GONE)
        }

        var bottomview = findViewById<LinearLayout>(R.id.tradev_bottomInformationview)

        if (coinMapData?.getInt("etfOpen") == 1) {

            val name = coinMapData?.optString("etfBase") + coinMapData?.optString("etfMultiple") + coinMapData?.optString("etfSide")
            val base = coinMapData?.getString("etfBase")
            val upDown = getUpdown(coinMapData?.getString("etfSide"), coinMapData?.getString("etfMultiple"))
            val hrefItem = LanguageUtil.getString(context,"etf_notes_explain_info")
            val span = LanguageUtil.getString(context, "etf_notes_explain").format(name, base, upDown,hrefItem)
            val spanable = SpannableString(span)
            trade_bottomInformation?.apply {
                text = spanable
            }
            bottomview?.visibility = View.VISIBLE
        } else {
            bottomview?.visibility = View.GONE
        }


    }

    private fun setDepth(context: Context) {
        try {
            setHeadetLeve(context)
        } catch (e: Exception) {
            e.printStackTrace()
        }
        depthLevels.clear()
        val depth = coinMapData?.optString("depth")
        if (!TextUtils.isEmpty(depth)) {
            val depths = depth?.split(",") ?: emptyList()
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
            depthLevelsBuff.clear()
            for (i in 0 until depthLevels?.size) {
                val obj = depthLevels[i] as String
                if (obj.toInt() == 0) {
                    depthLevelsBuff.add("1")
                } else {
                    var buff = StringBuffer("0")
                    buff.append(".")
                    for (x in 0 until obj.toInt() - 1) {
                        buff.append("0")
                    }
                    buff.append("1")
                    depthLevelsBuff.add(buff.toString())
                }
            }
        }
        val curDepthLevel = judgeDepthLevel()

        if (depthLevels.size > curDepthLevel) {
            depth_level = depthLevels[curDepthLevel].toInt()
        }
//        tv_change_depth?.text = LanguageUtil.getString(context, "kline_action_depth") + " " + depth_level
        if (depthLevelsBuff.size>depthPos){
            (tv_change_depth.getChildAt(0) as TextView)?.text =depthLevelsBuff[depthPos]
        }
    }


    private fun judgeDepthLevel(isInited: Boolean = false): Int {
        return if (TradeFragment.currentIndex == ParamConstant.LEVER_INDEX_TAB) {
            if (isInited) {
                0
            } else {
                NLeverFragment.curDepthIndex
            }
        } else {
            if (isInited) {
                0
            } else {
                NCVCTradeFragment.curDepthIndex
            }
        }
    }

    fun changeData(data: JSONObject?) {
        if (data != null) {
            trade_amount_view_l.changeSellOrBuyData(data)
        }
    }

    override fun onVisibilityChanged(changedView: View, visibility: Int) {
        super.onVisibilityChanged(changedView, visibility)
        if (visibility == View.VISIBLE) {
            setDepth(context)
        }
    }

    fun coinSwitch(coinSymbol: String) {
        val symbol = coinSymbol
        if (symbol != coinMapData?.optString("symbol")) {
            coinMapData = NCoinManager.getSymbolObj(symbol)
            judgeDepthLevel(isInited = true)
            setDepth(context)
            val pricePrecision = coinMapData?.optString("price", "4")?.toInt() ?: 4
            tv_close_price?.run {
                textColor = ColorUtil.getMainColorType(isRise = RateManager.getRoseTrend("0") >= 0)
                text = DecimalUtil.cutValueByPrecision("0", pricePrecision)
            }
            val marketName = NCoinManager.getMarketName(coinMapData?.optString("name", ""))
            tv_converted_close_price?.text = RateManager.getCNYByCoinName(marketName, "0")
        }
        resetPrice()
    }


    fun changeTickData(tick: JSONObject) {
        val rose = tick.optString("rose")
        val close = tick.optString("close")
        val pricePrecision = coinMapData?.optString("price", "4")?.toInt() ?: 4

        tv_close_price?.run {
            textColor = ColorUtil.getMainColorType(isRise = RateManager.getRoseTrend(rose) >= 0)
            text = DecimalUtil.cutValueByPrecision(close, pricePrecision)
        }
        val marketName = NCoinManager.getMarketName(coinMapData?.optString("name", ""))
        tv_converted_close_price?.text = RateManager.getCNYByCoinName(marketName, close)
    }

    fun resetPrice() {
        trade_amount_view_l.resetPrice()
        tv_close_price?.text = "--"
        tv_converted_close_price?.text = "--"
    }

    fun resetEtf(isGone: Boolean = true) {
        tv_etf_price?.text = "--"
        if (isGone) {
            ll_etf_item.visibility = View.GONE
        }
        val isETF = coinMapData?.coinIsEtf() ?: false
        trade_etf_l.visibility = isETF.getVisible()
        if (isETF) {
            tv_etf_tips.text = coinMapData?.coinEtfTips(context)
        }
    }

    fun changeEtf(data: JSONObject?) {
        ll_etf_item.visibility = View.VISIBLE
        val price = data?.optJSONObject("data")?.optString("price") ?: "--"
        tv_etf_price?.text = price
    }

    fun changeOrder(mData: ArrayList<JSONObject>) {
        orderList.clear()
        orderList.addAll(mData)
        refreshDepthView(transactionData)
    }

    fun loginSwitch() {
        trade_amount_view_l.loginStatusView()
    }

    private var isLevel = false
    fun initCoinSymbol(symbols: String?, isLevel: Boolean = false) {
        if (symbols != null && symbols.isNotEmpty()) {
            this.isLevel = isLevel
            var symbol = ""
            if (isLevel) {
                symbol = symbols.split(" ")[0]
            } else {
                symbol = symbols
            }
            val result = symbol.split("/")
            if (result.size == 2) {
                tv_buy_volume.text = coinBySplit(false, result[0])
                tv_price.text = coinBySplit(true, result[1])
                tv_sell_volume.text = coinBySplit(false, result[0])
            }
        }
    }

    private fun coinBySplit(isPrice: Boolean, value: String): String {
        val first = LanguageUtil.getString(context, if (isPrice) "contract_text_price" else "charge_text_volume")
        val message = StringBuffer(first)
        return message.append("(").append(value).append(")").toString()
    }

    fun getCoinSymbol(symbols: String?, isLevel: Boolean = true): String {
        var symbol = ""
        if (symbols != null && symbols.isNotEmpty()) {
            if (isLevel) {
                symbol = symbols.split(" ")[0]
            } else {
                symbol = symbols
            }
        }
        return symbol
    }

    private fun changeCoinUpOrDown(isLeft: Boolean, item: JSONObject?) {
        if (item != null) {
            if (isLeft) {
                tradev_topleft_coin?.text = item.optString("etfBase") + item.optString("etfMultiple") + item.optString("etfSide")
                tradev_topleft_coinleve?.text = "[" + item?.optString("etfMultiple") + getMultstring(item.optString("etfSide")) + "]"
                tradev_topleft_coinleve?.textColor = getMulcolor(item.optString("etfSide"))
                tradev_topleft?.visibility = View.VISIBLE
            } else {
                tradev_topright_coin?.text = item.optString("etfBase") + item.optString("etfMultiple") + item.optString("etfSide")
                tradev_topright_coinleve?.text = "[" + item?.optString("etfMultiple") + getMultstring(item.optString("etfSide")) + "]"
                tradev_topright_coinleve?.textColor = getMulcolor(item.optString("etfSide"))
                tradev_topright?.visibility = View.VISIBLE
            }
        } else {
            if (isLeft) {
                tradev_topleft?.visibility = View.GONE
            } else {
                tradev_topright?.visibility = View.GONE
            }
        }
    }

    fun getMultstring(etfMultiple: String): String {
        if (etfMultiple.equals("L")) {
            return LanguageUtil.getString(context, "etf_multipleL")
        } else {
            return LanguageUtil.getString(context, "etf_multipleS")
        }
    }

    fun getUpdown(etfSide: String?, etfmultiple: String?): String {
        if (etfSide.equals("L")) {
            return LanguageUtil.getString(context, "etf_notes_multipleL").format(etfmultiple)
        } else {
            return LanguageUtil.getString(context, "etf_notes_multipleS").format(etfmultiple)
        }
    }

    fun getMulcolor(etfMultiple: String): Int {
        if (etfMultiple.equals("L")) {
            return ColorUtil.getMainColorType()
        } else {
            return ColorUtil.getMainColorType(false)
        }

    }

    fun changeEtfInfo(data: JSONObject?) {
        trade_amount_view_l.changeETFInfo(data)
    }

    fun initVolView(){
        trade_amount_view_l?.initVolView()
        (tv_change_depth.getChildAt(0) as TextView)?.text =depthLevelsBuff[judgeDepthLevel()]
    }
}
