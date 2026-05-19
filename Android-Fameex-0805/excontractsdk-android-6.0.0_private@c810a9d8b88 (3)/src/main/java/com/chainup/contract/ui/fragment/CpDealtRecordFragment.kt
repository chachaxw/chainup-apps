package com.yjkj.chainup.new_contract.fragment

import androidx.lifecycle.Observer
import android.os.Bundle
import androidx.fragment.app.Fragment
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.viewpager.widget.ViewPager
import com.chainup.contract.R
import com.chainup.contract.bean.CpFlagBean
import com.chainup.contract.utils.*
import kotlinx.android.synthetic.main.cp_fragment_dealt_record.*
import kotlinx.android.synthetic.main.cp_item_dealt_record.view.*
import org.jetbrains.anko.doAsync
import org.jetbrains.anko.uiThread
import org.json.JSONObject


/**
 * @author Bertking
 *"Transaction Record" under Market Details
 * @date 2019-3-19
 * DONE
 */
class CpDealtRecordFragment : Fragment() {
    val TAG = CpDealtRecordFragment::class.java.simpleName

    private var viewPager: ViewPager? = null

    /**
     *Closed order
     */
    private var newTransactions = arrayListOf<JSONObject>()

    /**
     *Transaction item collection
     */
    private var tradeDealViewList = arrayListOf<View>()

    var flagBean: CpFlagBean? = null


    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?,
                              savedInstanceState: Bundle?): View? {
        val view = inflater.inflate(R.layout.cp_fragment_dealt_record, container, false)
//        if (viewPager != null) {
//            viewPager?.setObjectForPosition(view, 1)
//        }
        return view
    }

    companion object {
        @JvmStatic
        fun newInstance(viewPager: ViewPager) =
                CpDealtRecordFragment().apply {
                    this.viewPager = viewPager
                    arguments = Bundle().apply {
                    }
                }
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        initDealRecordView()

        CpDepthFragment.liveData.observe(this, Observer {

            if (it == null || flagBean?.symbol == it?.symbol) {
                return@Observer
            }

            if (flagBean?.symbol != it?.symbol) {
                clearDealRecordView()
            }


            flagBean = it


        })
    }

    /**
     *Initialize the "Deal" section View
     */
    private fun initDealRecordView() {
        for (i in 0 until 20) {
            val view: View = layoutInflater.inflate(R.layout.cp_item_dealt_record, null)
            ll_dealt_record?.addView(view)
            tradeDealViewList.add(view)
        }

    }

    /**
     *Clear the "Deal" view
     */
    private fun clearDealRecordView() {
        for (i in 0 until 20) {
            tradeDealViewList[i].run {
                tv_time?.text = "--"
                tv_price?.text = "--"
                tv_amount?.text = "--"
            }
        }
    }

    /**
     *Processing data
     */
    fun handleData(string: String) {
        try {
            val json = JSONObject(string)

            /**
             *Latest transaction
             */
            val channel = json.getString("channel")
            if (!json.isNull("tick")) {
                if (channel == CpWsLinkUtils.getDealNewLink(flagBean?.symbol ?: "").channel) {
                    parseDealData(json.optJSONObject("tick"))
                }
            }

            /**
             *Request (req) -->Historical Volume
             *That is, the historical data of the latest transaction list below
             * channel ---> "channel": "market_ltcusdt_trade_ticker
             */
            if (!json.isNull("data")) {
                if (channel == CpWsLinkUtils.getDealHistoryLink(flagBean?.symbol ?: "").channel) {
                    parseDealData(json)
                }
            }

        } catch (e: java.lang.Exception) {
            e.printStackTrace()
            Log.e(TAG, "msg:${e.message}")
        }

    }

    private fun parseDealData(json: JSONObject) {
        doAsync {
            val dataJSONArray = json.optJSONArray("data")
            val list = arrayListOf<JSONObject>()
            for (i in 0 until dataJSONArray.length()) {
                list.add(dataJSONArray.optJSONObject(i))
            }
            uiThread {
                refreshDealRecordView(list)
            }
        }
    }


    /**
     *Update the "Closing" section
     */
    private fun refreshDealRecordView(data: List<JSONObject>) {

        if (data.isEmpty()) {
            return
        }

        newTransactions.addAll(0, data)
        if (newTransactions.size > 20) {
            newTransactions = ArrayList(newTransactions.subList(0, 20))
        }
        if (newTransactions.isEmpty()) return


        newTransactions.indices.forEach {

            val view = tradeDealViewList[it]
            val jsonObject = newTransactions[it]

            val ds = jsonObject.optLong("ts")
            val price = jsonObject.optString("price")
            val side = jsonObject.optString("side")
            val vol = jsonObject.optString("vol")


            /**
             *Time
             */
            view.tv_time?.text = CpDateUtils.getDayHourMinSecond(ds)
            /**
             *Price
             */
            view.tv_price?.text =
                CpDecimalUtil.cutValueByPrecision(price, flagBean?.pricePrecision ?: 0)


            /**
             *Buying and selling direction
             */
            view.tv_price?.setTextColor(CpColorUtil.getMainColorType(side == "BUY"))

            /**
             *Quantity
             */
            view.tv_amount?.text =
                    if (flagBean?.isContract == true) {
                        if (!flagBean?.mMultiplier.equals("0")) {
                            if (flagBean?.coUnit == 0) vol else CpBigDecimalUtils.mulStr(vol, flagBean?.mMultiplier, flagBean?.volumePrecision!!)
                        } else {
                            vol
                        }
                    } else {
                        CpDecimalUtil.cutValueByPrecision(vol, flagBean?.volumePrecision ?: 0)
                    }
        }

    }


    override fun onDestroy() {
        super.onDestroy()
    }

    override fun onDestroyView() {
        super.onDestroyView()
    }

    fun onCallback(json: String) {
        handleData(json)
    }

}
