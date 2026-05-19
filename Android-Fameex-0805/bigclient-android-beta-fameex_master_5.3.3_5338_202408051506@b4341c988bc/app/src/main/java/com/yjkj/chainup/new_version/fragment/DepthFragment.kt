package com.yjkj.chainup.new_version.fragment

import android.annotation.SuppressLint
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.Observer
import android.graphics.Color
import android.os.Bundle
import androidx.fragment.app.Fragment
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import com.yjkj.chainup.util.JsonUtils
import com.github.mikephil.charting.components.XAxis
import com.github.mikephil.charting.components.YAxis
import com.github.mikephil.charting.data.Entry
import com.github.mikephil.charting.data.LineData
import com.github.mikephil.charting.data.LineDataSet
import com.github.mikephil.charting.formatter.ValueFormatter
import com.yjkj.chainup.R
import com.yjkj.chainup.app.AppConstant
import com.yjkj.chainup.bean.DepthBean
import com.yjkj.chainup.bean.TransactionData
import com.yjkj.chainup.bean.kline.DepthItem
import com.yjkj.chainup.db.constant.CommonConstant
import com.yjkj.chainup.manager.Contract2PublicInfoManager
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.net.HttpClient
import com.yjkj.chainup.new_version.bean.FlagBean
import com.yjkj.chainup.new_version.view.depth.BBKlineDataDepthHelper
import com.yjkj.chainup.util.*
import com.yjkj.chainup.wedegit.WrapContentViewPager
import kotlinx.android.synthetic.main.depth_chart_com.*
import kotlinx.android.synthetic.main.fragment_depth.*
import kotlinx.android.synthetic.main.item_depth_buy.view.*
import org.jetbrains.anko.backgroundColor
import org.jetbrains.anko.textColor
import org.json.JSONArray
import org.json.JSONObject
import java.net.URI
import java.util.concurrent.TimeUnit
import kotlin.math.max


/**
 * @author Bertking
 *@description "Depth" under market details
 * @Date 2023-3-20
 *
 */

class DepthFragment : Fragment() {
    val TAG = DepthFragment::class.java.simpleName

    private var viewPager: WrapContentViewPager? = null
    private var datas: DepthItem? = null

    /**
     *Selling items
     */
    private var sellViewList = mutableListOf<View>()

    /**
     *Buying items
     */
    private var buyViewList = mutableListOf<View>()

    private var pricePrecision = 2
    private var volumePrecision = 2

    private var riseColor = ColorUtil.getMainColorType(isRise = true)
    private var fallColor = ColorUtil.getMainColorType(isRise = false)

    private val riseMinorColor = ColorUtil.getMinorColorType(isRise = true)
    private val fallMinorColor = ColorUtil.getMinorColorType(isRise = false)
    private var dataHelper = BBKlineDataDepthHelper.instance

    var flagBean: FlagBean? = null

    //Record the last subscribed currency pair
    var lastSymbol: String = ""

    var defaultThreshold = "0.1"

    /**
     *Calculate the percentage of buying and selling orders
     */


    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?,
                              savedInstanceState: Bundle?): View? {
        // Inflate the layout for this fragment
        val view = inflater.inflate(R.layout.fragment_depth, container, false)
        if (viewPager != null) {
            viewPager?.setObjectForPosition(view, 0)
        }
        return view
    }

    companion object {

        val liveData = MutableLiveData<FlagBean>()
        var liveData4closePrice: MutableLiveData<List<String>> = MutableLiveData()

        @JvmStatic
        fun newInstance(viewPager: WrapContentViewPager) =
                DepthFragment().apply {
                    this.viewPager = viewPager
                    arguments = Bundle().apply {
                        //                        putString(ARG_PARAM1, param1)
                    }
                }
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        initDepthView()
        liveData.observe(this, Observer {
            if (it == null || flagBean?.symbol == it.symbol) {
                return@Observer
            }

            activity?.runOnUiThread {
                clearDepthView()
            }

            //un sub last symbol 's depth
            if (flagBean != null) {
                sendMessage(WsLinkUtils.getDepthLink(flagBean?.symbol ?: "", false).json)
            }
            flagBean = it
            /**
             *Accuracy
             */
            pricePrecision = it.pricePrecision
            volumePrecision = it.volumePrecision

            val priceUnit = if (flagBean?.isContract == true) {
                ""
            } else {
                "(${flagBean?.quotesSymbol})"
            }

            tv_price_title?.text =LanguageUtil.getString(context,"contract_text_price") + priceUnit

            val amountUnit = if (flagBean?.isContract == true) {
//                "(张)"
                ""
            } else {
                "(${flagBean?.baseSymbol})"
            }
            tv_buy_volume_title?.text =LanguageUtil.getString(context,"charge_text_volume") + amountUnit
            tv_sell_volume_title?.text = LanguageUtil.getString(context,"charge_text_volume")+ amountUnit


            if (flagBean?.isContract == true) {
                tv_buy_tape_title?.text =LanguageUtil.getString(context,"contract_text_buyMarket")
                tv_sell_tape_title?.text = LanguageUtil.getString(context,"contract_text_sellMarket")
            } else {
                tv_buy_tape_title?.text = LanguageUtil.getString(context,"contract_text_buyMarket")
                tv_sell_tape_title?.text =LanguageUtil.getString(context,"contract_text_sellMarket")
            }

            defaultThreshold = NCoinManager.getDefaultThresholdForSort(flagBean?.symbol)
            showProgressDialog("")
            initSocket(URI(""))
        })

    }

    fun showProgressDialog(msg: String) {

        prb_loading?.visibility = View.VISIBLE
        tv_loading?.visibility = View.VISIBLE

        ll_depth?.visibility = View.GONE
        ll_depth_title?.visibility = View.GONE

    }

    fun cancelProgressDialog() {
        prb_loading?.visibility = View.GONE
        tv_loading?.visibility = View.GONE

        ll_depth?.visibility = View.VISIBLE
        ll_depth_title?.visibility = View.VISIBLE

    }


    /**
     *Buying and selling order
     *Initialize transaction details record view
     */
    private fun initDepthView() {
        for (i in 1..20) {
            /**
             *Selling orders
             */
            val view: View = layoutInflater.inflate(R.layout.item_depth_sell, null)
            val layout = view.findViewById<FrameLayout>(R.id.fl_bg_item)
            view.tv_price_item_for_depth?.setTextColor(fallColor)
            ll_sell?.addView(view)
            sellViewList.add(view)
            /***********/

            /**
             *Buying
             */
            val view1: View = layoutInflater.inflate(R.layout.item_depth_buy, null)
            view1.tv_price_item_for_depth.setTextColor(riseColor)
            ll_buy?.addView(view1)
            buyViewList.add(view1)
        }

    }


    private fun initSocket(uri: URI) {
        sendMessage(WsLinkUtils.getDepthLink(flagBean?.symbol ?: "").json)
    }

    /**
     *WebSocket sends messages
     */
    private fun sendMessage(msg: String) {

    }


    /**
     *Reset the data of the order
     */
    private fun clearDepthView() {

        if (sellViewList.isEmpty()) return
        if (buyViewList.isEmpty()) return

        for (i in 0 until 20) {
            sellViewList[i].run {
                tv_price_item_for_depth?.text = "--"
                tv_quantity_item_for_depth?.text = "--"
                fl_bg_item_for_depth?.setBackgroundResource(R.color.transparent)
            }
            buyViewList[i].run {
                tv_price_item_for_depth?.text = "--"
                tv_quantity_item_for_depth?.text = "--"
                fl_bg_item_for_depth?.setBackgroundResource(R.color.transparent)
            }
        }
    }


    /**
     *Processing data
     */
    fun handleData(data: String) {
        val json = JSONObject(data)
        /**
         *Depth
         *There are ticks that need to be determined based on the channel field
         */
        if (!json.isNull("tick")) {
            /**
             *Depth
             */
            val channel = json.optString("channel")
            if (channel == WsLinkUtils.getDepthLink(flagBean?.symbol
                            ?: "").channel) {
//Log. d (TAG, depth: $data)

                BBKlineDataDepthHelper.instance?.updateDepthByType(json)


                val transactionData = JsonUtils.jsonToBean(json.toString(), TransactionData::class.java)
                /**
                 *Minimum selling price
                 */
                if (null != transactionData.tick) {
                    val tick = transactionData.tick
                    tick.asks.sortByDescending { it.get(0).asDouble }
                    /**
                     *Buying for maximum
                     */
                    tick.buys.sortByDescending { it.get(0).asDouble }
                }

                if (isAdded && activity != null) {
                    //Depth map
                    activity?.runOnUiThread {
                        refreshDepthView(json)
                    }
                }
            }
        }
    }


    /**
     *Update data for purchase and sale orders
     */
    private fun refreshDepthView(jsonObject: JSONObject) {
        val tickJSONObject = jsonObject.optJSONObject("tick")

        val buys = tickJSONObject.optJSONArray("buys")
        val buysList = arrayListOf<JSONArray>()

        val asks = tickJSONObject.optJSONArray("asks")
        val asksList = arrayListOf<JSONArray>()
        /**
         *Buying for maximum
         */
        if (buys.length() != 0) {
            for (i in 0 until buys.length()) {
                buysList.add(buys.optJSONArray(i))
            }
            buysList.sortByDescending {
                it.optDouble(0)
            }
        }

        /**
         *Minimum selling price
         */
        if (asks.length() != 0) {
            for (i in 0 until asks.length()) {
                asksList.add(asks.optJSONArray(i))
            }

            asksList.sortByDescending {
                it.optDouble(0)
            }
        }


        var subList = mutableListOf<JSONArray>()
        subList = if (asksList.size >= 20) {
            if (asksList.size - sellViewList.size < 0) {
                asksList
            } else {
                asksList.subList(asksList.size - sellViewList.size, asksList.size)
            }

        } else {
            asksList
        }
        subList.sortBy {
            it.optDouble(0)
        }

        var sellVolumeSum = 0.0
        for (sell in subList) {
            sellVolumeSum += sell.optDouble(1)
        }


        var buySubList = mutableListOf<JSONArray>()
        buySubList = if (buysList.size >= 20) {
            buysList.subList(0, 20)
        } else {
            buysList
        }
        var buyVolumeSum = 0.0
        for (buy in buySubList) {
            buyVolumeSum += buy.optDouble(1)
        }


        for (i in 0 until sellViewList.size) {
            /**
             *Selling orders
             */
            if (asksList.size > sellViewList.size) {
                /**
                 *Remove large values
                 */
                /*****Deep background color START****/
                sellViewList[0].ll_item_layout.post {
                    sellViewList[i].fl_bg_item_for_depth?.backgroundColor = fallMinorColor
                    val layoutParams = sellViewList[i].fl_bg_item_for_depth?.layoutParams
                    var curSellVolumeSum = 0.0
                    for (x in 0..i) {
                        curSellVolumeSum += subList[x].optDouble(1)
                    }
                    val width = (curSellVolumeSum / sellVolumeSum) * DisplayUtil.getScreenWidth() * 0.5
                    layoutParams?.width = width.toInt()
                    sellViewList[i].fl_bg_item_for_depth?.layoutParams = layoutParams
                }

                /*****Deep background color END****/
                sellViewList[i].tv_price_item_for_depth?.text =
                        if (flagBean?.isContract == true) {
                            Contract2PublicInfoManager.cutValueByPrecision(subList[i].get(0).toString().trim(), pricePrecision)
                        } else {
                            DecimalUtil.cutValueByPrecision(subList[i].get(0).toString().trim(), pricePrecision)
                        }
                val vol = subList[i].get(1).toString()
                sellViewList[i].tv_quantity_item_for_depth?.text =
                        if (flagBean?.isContract == true) {
                            if (!flagBean?.mMultiplier.equals("0")) {
                                if (flagBean?.coUnit == 0) vol else BigDecimalUtils.mulStr(vol, flagBean?.mMultiplier, flagBean?.volumePrecision!!)
                            } else {
                                vol
                            }
                        } else {
                            DecimalUtil.cutValueByPrecision(subList[i].get(1).toString(), volumePrecision)
                        }

            } else {
                sellViewList[i].run {
                    tv_price_item_for_depth?.text = "--"
                    tv_quantity_item_for_depth?.text = "--"
                }

                if (i < asksList.size) {
                    /*****Deep background color START****/
                    sellViewList[i].fl_bg_item_for_depth?.backgroundColor = fallMinorColor
                    val layoutParams = sellViewList[i].fl_bg_item_for_depth?.layoutParams
                    var curSellVolumeSum = 0.0
                    for (x in 0..i) {
                        curSellVolumeSum += asksList[x].optDouble(1)
                    }
                    val width = (curSellVolumeSum / sellVolumeSum) * DisplayUtil.getScreenWidth() * 0.5
                    layoutParams?.width = width.toInt()
                    sellViewList[i].fl_bg_item_for_depth?.layoutParams = layoutParams

                    /*****Deep background color END****/
                    val price4DepthSell = asksList[i].optString(0).trim()
                    sellViewList[i].tv_price_item_for_depth?.text =
                            if (flagBean?.isContract == true) {
                                Contract2PublicInfoManager.cutValueByPrecision(price4DepthSell, pricePrecision)
                            } else {
                                DecimalUtil.cutValueByPrecision(price4DepthSell, pricePrecision)
                            }

                    var vol = asksList[i].get(1).toString().trim()
                    sellViewList[i].tv_quantity_item_for_depth?.text =
                            if (flagBean?.isContract == true) {
                                if (!flagBean?.mMultiplier.equals("0")) {
                                    if (flagBean?.coUnit == 0) vol else BigDecimalUtils.mulStr(vol, flagBean?.mMultiplier, flagBean?.volumePrecision!!)
                                } else {
                                    vol
                                }
                            } else {
                                DecimalUtil.cutValueByPrecision(asksList[i].optString(1).trim(), volumePrecision)
                            }
                }
            }

            /**
             *Buying
             */
            if (buysList.size > i) {
                /*****Deep background color START****/
                buyViewList[i].fl_bg_item_for_depth?.backgroundColor = riseMinorColor
                val layoutParams = buyViewList[i].fl_bg_item_for_depth?.layoutParams
                var curBuyVolumeSum = 0.0
                for (x in 0..i) {
                    curBuyVolumeSum += buysList[x].optDouble(1)
                }

                val width = (curBuyVolumeSum / buyVolumeSum) * DisplayUtil.getScreenWidth() * 0.5
//
                layoutParams?.width = width.toInt()
                buyViewList[i].fl_bg_item_for_depth?.layoutParams = layoutParams

                /*****Deep background color END****/
                val price4DepthBuy = buysList[i].optString(0).trim()

//
                buyViewList[i].tv_price_item_for_depth?.text =
                        if (flagBean?.isContract == true) {
                            Contract2PublicInfoManager.cutValueByPrecision(price4DepthBuy, pricePrecision)
                        } else {
                            DecimalUtil.cutValueByPrecision(price4DepthBuy, pricePrecision)
                        }
                val vol = buysList[i].get(1).toString().trim()
                buyViewList[i].tv_quantity_item_for_depth?.text =
                        if (flagBean?.isContract == true) {
                            if (!flagBean?.mMultiplier.equals("0")) {
                                if (flagBean?.coUnit == 0) vol else BigDecimalUtils.mulStr(vol, flagBean?.mMultiplier, flagBean?.volumePrecision!!)
                            } else {
                                vol
                            }
                        } else {
                            DecimalUtil.cutValueByPrecision(buysList[i].optString(1).trim(), volumePrecision)
                        }

            } else {
                buyViewList[i].run {
                    tv_price_item_for_depth?.text = "--"
                    tv_quantity_item_for_depth?.text = "--"
                    fl_bg_item_for_depth?.setBackgroundResource(R.color.transparent)
                }
            }
            cancelProgressDialog()
        }
    }


    override fun onStop() {
        super.onStop()
        Log.e("LogUtils", "DepthFragment onStop()")
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.e("LogUtils", "DepthFragment onDestroy()")
    }

    fun onDepthFragment(json: String) {
        handleData(json)
    }



}

