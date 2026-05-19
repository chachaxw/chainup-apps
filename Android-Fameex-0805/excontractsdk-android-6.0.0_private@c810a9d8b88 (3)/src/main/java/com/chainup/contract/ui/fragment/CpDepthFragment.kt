package com.yjkj.chainup.new_contract.fragment


import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.Observer
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.FrameLayout
import androidx.viewpager.widget.ViewPager
import com.chainup.contract.R
import com.chainup.contract.base.CpNBaseFragment
import com.chainup.contract.bean.CpFlagBean
import com.chainup.contract.bean.CpTransactionData
import com.chainup.contract.utils.*
import com.chainup.contract.view.CpBBKlineDataDepthHelper
import com.yjkj.chainup.bean.kline.cp.DepthItem
import io.reactivex.disposables.Disposable
import kotlinx.android.synthetic.main.cp_fragment_depth.*
import kotlinx.android.synthetic.main.cp_depth_chart_com.*
import kotlinx.android.synthetic.main.cp_item_depth_sell.view.*
import org.jetbrains.anko.backgroundColor
import org.json.JSONArray
import org.json.JSONObject


/**
 * @author Bertking
 *@ description "Depth" under Market Details
 * @date 2019-3-20
 *
 */

class CpDepthFragment : CpNBaseFragment() {
//    val TAG = ClDepthFragment::class.java.simpleName

    private var viewPager: ViewPager? = null
    private var datas: DepthItem? = null

    private var contractId: Int = -1
    private var symbol: String = ""
    private var wsData: String? = null

    /**
     *Item sold
     */
    private var sellViewList = mutableListOf<View>()

    /**
     *Buying item
     */
    private var buyViewList = mutableListOf<View>()

    private var pricePrecision = 2
    private var volumePrecision = 2

    private var riseColor = CpColorUtil.getMainColorType(isRise = true)
    private var fallColor = CpColorUtil.getMainColorType(isRise = false)

    private val riseMinorColor = CpColorUtil.getMinorColorType(isRise = true)
    private val fallMinorColor = CpColorUtil.getMinorColorType(isRise = false)

    var flagBean: CpFlagBean? = null

    //Record the last subscribed currency pair
    var lastSymbol: String = ""

    var defaultThreshold = "0.1"

    override fun setContentView(): Int {
        return R.layout.cp_fragment_depth
    }


    override fun initView() {
//        if (viewPager != null) {
//            viewPager?.setObjectForPosition(view, 0)
//        }
    }

    companion object {

        val liveData = MutableLiveData<CpFlagBean>()
        var liveData4closePrice: MutableLiveData<List<String>> = MutableLiveData()

        @JvmStatic
        fun newInstance(viewPager: ViewPager, contractId: Int, symbol: String, wsData: String?) =
                CpDepthFragment().apply {
                    this.viewPager = viewPager
                    this.contractId = contractId
                    this.symbol = symbol
                    this.wsData = wsData
                    arguments = Bundle().apply {
                        //                        putString(ARG_PARAM1, param1)
                    }
                }
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        initDepthView()
        liveData.observe(this, Observer {
            this.symbol = it.symbol
            this.contractId = it.contractId.toInt()
            if (it == null || flagBean?.symbol == it.symbol) {
                return@Observer
            }

            activity?.runOnUiThread {
                clearDepthView()
            }

            flagBean = it
            /**
             *Accuracy
             */
            pricePrecision = it.pricePrecision
            volumePrecision = it.volumePrecision

            if(wsData?.isEmpty() == false){
                activity?.runOnUiThread {
                    refreshDepthView(JSONObject(wsData))
                }
            }
        })

    }


    fun cancelProgressDialog() {
        prb_loading?.visibility = View.GONE
        tv_loading?.visibility = View.GONE
        ll_depth?.visibility = View.VISIBLE
    }


    /**
     *Order
     *Initialize transaction details record view
     */
    private fun initDepthView() {
        for (i in 1..20) {
            /**
             *Selling offer
             */
            val view: View = layoutInflater.inflate(R.layout.cp_item_depth_sell, null)
            val layout = view.findViewById<FrameLayout>(R.id.fl_bg_item)
            view.tv_price_item_for_depth?.setTextColor(fallColor)
            ll_sell?.addView(view)
            sellViewList.add(view)
            /***********/

            /**
             *Buying
             */
            val view1: View = layoutInflater.inflate(R.layout.cp_item_depth_buy, null)
            view1.tv_price_item_for_depth.setTextColor(riseColor)
            ll_buy?.addView(view1)
            buyViewList.add(view1)
        }

    }


    /**
     *Reset order data
     */
    private fun clearDepthView() {
        clearDepthChart()

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
     *Cleaning depth
     */
    fun clearDepthChart() {
        depth_chart?.clear()
        depth_chart?.notifyDataSetChanged()
        depth_chart?.invalidate()
    }



    /**
     *Processing data
     */
    fun handleData(data: String,symbol: String = "") {
        val json = JSONObject(data)
        /**
         *Depth
         *There are ticks, which need to be judged based on the channel field
         */
        if (!json.isNull("tick")) {
            /**
             *Depth
             */
            val channel = json.optString("channel")
            if (channel == CpWsLinkUtils.getDepthLink(
                            flagBean?.symbol
                                    ?: symbol
                    ).channel
            ) {
//Log. d (TAG, "=======Depth: $data")

                CpBBKlineDataDepthHelper.instance?.updateDepthByType(json)


                val transactionData =
                        CpJsonUtils.jsonToBean(json.toString(), CpTransactionData::class.java)
                /**
                 *Minimum selling order
                 */
                if (null != transactionData.tick) {
                    val tick = transactionData.tick
                    tick.asks.sortByDescending { it.get(0).asDouble }
                    /**
                     *Buy to take maximum
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
     *Update data for orders
     */
    private fun refreshDepthView(jsonObject: JSONObject) {
        val tickJSONObject = jsonObject.optJSONObject("tick")

        val buys = tickJSONObject.optJSONArray("buys")
        val buysList = arrayListOf<JSONArray>()

        val asks = tickJSONObject.optJSONArray("asks")
        val asksList = arrayListOf<JSONArray>()
        /**
         *Buy to take maximum
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
         *Minimum selling order
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
             *Selling offer
             */
            if (asksList.size > sellViewList.size) {
                /**
                 *Remove Large Values
                 */
                /*****Deep Background Color START****/
                sellViewList[0].ll_item_layout.post {
                    sellViewList[i].fl_bg_item_for_depth?.backgroundColor = fallMinorColor
                    val layoutParams = sellViewList[i].fl_bg_item_for_depth?.layoutParams
                    var curSellVolumeSum = 0.0
                    for (x in 0..i) {
                        curSellVolumeSum += subList[x].optDouble(1)
                    }
                    val width =
                            (curSellVolumeSum / sellVolumeSum) * CpDisplayUtil.getScreenWidth() * 0.5
                    layoutParams?.width = width.toInt()
                    sellViewList[i].fl_bg_item_for_depth?.layoutParams = layoutParams
                }

                /*****Deep background color END****/
                sellViewList[i].tv_price_item_for_depth?.text = CpDecimalUtil.cutValueByPrecision(
                        subList[i].get(0).toString().trim(),
                        pricePrecision
                )
                val vol = subList[i].get(1).toString()
                sellViewList[i].tv_quantity_item_for_depth?.text =
                        if (flagBean?.isContract == true) {
                            if (!flagBean?.mMultiplier.equals("0")) {
                                if (flagBean?.coUnit == 0) vol else CpBigDecimalUtils.mulStr(
                                        vol,
                                        flagBean?.mMultiplier,
                                        flagBean?.volumePrecision!!
                                )
                            } else {
                                vol
                            }
                        } else {
                            CpDecimalUtil.cutValueByPrecision(
                                    subList[i].get(1).toString(),
                                    volumePrecision
                            )
                        }

            } else {
                sellViewList[i].run {
                    tv_price_item_for_depth?.text = "--"
                    tv_quantity_item_for_depth?.text = "--"
                }

                if (i < asksList.size) {
                    /*****Deep Background Color START****/
                    sellViewList[i].fl_bg_item_for_depth?.backgroundColor = fallMinorColor
                    val layoutParams = sellViewList[i].fl_bg_item_for_depth?.layoutParams
                    var curSellVolumeSum = 0.0
                    for (x in 0..i) {
                        curSellVolumeSum += asksList[x].optDouble(1)
                    }
                    val width =
                            (curSellVolumeSum / sellVolumeSum) * CpDisplayUtil.getScreenWidth() * 0.5
                    layoutParams?.width = width.toInt()
                    sellViewList[i].fl_bg_item_for_depth?.layoutParams = layoutParams

                    /*****Deep background color END****/
                    val price4DepthSell = asksList[i].optString(0).trim()
                    sellViewList[i].tv_price_item_for_depth?.text =
                            CpDecimalUtil.cutValueByPrecision(price4DepthSell, pricePrecision)

                    var vol = asksList[i].get(1).toString().trim()
                    sellViewList[i].tv_quantity_item_for_depth?.text =
                            if (flagBean?.isContract == true) {
                                if (!flagBean?.mMultiplier.equals("0")) {
                                    if (flagBean?.coUnit == 0) vol else CpBigDecimalUtils.mulStr(
                                            vol,
                                            flagBean?.mMultiplier,
                                            flagBean?.volumePrecision!!
                                    )
                                } else {
                                    vol
                                }
                            } else {
                                CpDecimalUtil.cutValueByPrecision(
                                        asksList[i].optString(1).trim(),
                                        volumePrecision
                                )
                            }
                }
            }

            /**
             *Buying
             */
            if (buysList.size > i) {
                /*****Deep Background Color START****/
                buyViewList[i].fl_bg_item_for_depth?.backgroundColor = riseMinorColor
                val layoutParams = buyViewList[i].fl_bg_item_for_depth?.layoutParams
                var curBuyVolumeSum = 0.0
                for (x in 0..i) {
                    curBuyVolumeSum += buysList[x].optDouble(1)
                }

                val width = (curBuyVolumeSum / buyVolumeSum) * CpDisplayUtil.getScreenWidth() * 0.5
//                Log.d(TAG, "=====buy======${DisplayUtil.getScreenWidth() * 0.5}=======")
                layoutParams?.width = width.toInt()
                buyViewList[i].fl_bg_item_for_depth?.layoutParams = layoutParams

                /*****Deep background color END****/
                val price4DepthBuy = buysList[i].optString(0).trim()

//                Log.d(TAG, "=======price4Depth:$price4DepthBuy===")
                buyViewList[i].tv_price_item_for_depth?.text =
                        CpDecimalUtil.cutValueByPrecision(price4DepthBuy, pricePrecision)
                val vol = buysList[i].get(1).toString().trim()
                buyViewList[i].tv_quantity_item_for_depth?.text =
                        if (flagBean?.isContract == true) {
                            if (!flagBean?.mMultiplier.equals("0")) {
                                if (flagBean?.coUnit == 0) vol else CpBigDecimalUtils.mulStr(
                                        vol,
                                        flagBean?.mMultiplier,
                                        flagBean?.volumePrecision!!
                                )
                            } else {
                                vol
                            }
                        } else {
                            CpDecimalUtil.cutValueByPrecision(
                                    buysList[i].optString(1).trim(),
                                    volumePrecision
                            )
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

    override fun onDestroyView() {
        super.onDestroyView()
        Log.e("LogUtils", "ClDepthFragment onDestroyView()")
        restart()

    }

    override fun onStop() {
        super.onStop()
        Log.e("LogUtils", "ClDepthFragment onStop()")
    }


    override fun onDestroy() {
        super.onDestroy()
        Log.e("LogUtils", "ClDepthFragment onDestroy()")
    }

    fun onClDepthFragment(json: String) {
        ChainUpLogUtil.e(TAG, json)
        handleData(json)
    }

    var subscribe: Disposable? = null//Save Subscriber

    /**
     *End the timer and start again
     */
    fun restart() {
        Log.e("LogUtils", "dispose ClDepthFragment ${subscribe}")
        if (subscribe != null) {
            subscribe?.dispose()//Unsubscribe
            Log.e("LogUtils", "dispose ClDepthFragment time")
        }
    }

    override fun onPause() {
        super.onPause()
        restart()
    }

}
