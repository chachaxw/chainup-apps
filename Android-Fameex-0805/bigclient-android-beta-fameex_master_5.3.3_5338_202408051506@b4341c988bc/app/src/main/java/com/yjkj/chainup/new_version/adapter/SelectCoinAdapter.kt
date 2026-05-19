package com.yjkj.chainup.new_version.adapter

import android.text.TextUtils
import android.util.Log
import android.view.View
import android.widget.Filter
import android.widget.Filterable
import android.widget.TextView
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.yjkj.chainup.R
import com.yjkj.chainup.manager.DataManager
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.util.setGoneV3
import org.json.JSONObject

/**
 * @Author: Bertking
 * @Date 2023/4/16-4:19 PM
 * @Description:
 */
class SelectCoinAdapter(val datas: ArrayList<JSONObject>, var allCoin: ArrayList<JSONObject>) : BaseQuickAdapter<JSONObject, BaseViewHolder>(R.layout.item_search_coin, datas), Filterable {

    val TAG = SelectCoinAdapter::class.java.simpleName

    var beanData: ArrayList<JSONObject> = arrayListOf()


    fun setBean(data: ArrayList<JSONObject>) {
        beanData = data
        notifyDataSetChanged()
    }

    private var filter: MyFilter? = null
    var listener: FilterListener? = null

    override fun convert(helper: BaseViewHolder, item: JSONObject) {
        helper?.setText(R.id.tv_coin_name, NCoinManager.getShowMarket(item?.optString("coinName")))
        helper?.getView<TextView>(R.id.tv_coin_name)?.textSize = 14f

        helper?.getView<View>(R.id.tv_market_name)?.visibility = View.GONE

        if (item?.has("depositOpen")!!) {
            //DepositOpen 0 pauses charging 1 allows charging
            helper?.setGone(R.id.tv_close_price, item?.optInt("depositOpen") != 1)
            helper?.setText(R.id.tv_close_price, if (item?.optInt("depositOpen") != 1) LanguageUtil.getString(context,"assets_suspend_deposit") else "")
        } else if (item?.has("withdrawOpen")!!) {
            //WithdrawOpen 0 Pause withdrawal 1 Allow withdrawal
            helper?.setGone(R.id.tv_close_price, item?.optInt("withdrawOpen") != 1)
            helper?.setText(R.id.tv_close_price, if (item?.optInt("withdrawOpen") != 1) LanguageUtil.getString(context,"assets_suspend_withdraw") else "")
        }else if (item?.has("withdrawOpen")!! && item?.has("depositOpen")!!){
            helper?.setText(R.id.tv_close_price, if (item?.optInt("withdrawOpen") != 1) LanguageUtil.getString(context,"assets_suspend_deposit") else "")
        }

        helper?.getView<View>(R.id.tv_close_price)?.visibility = View.GONE
        helper.setGoneV3(R.id.ctv_content, false)
        helper.setGoneV3(R.id.item_view_market_line, false)

    }


    interface FilterListener {
        fun getFilterData(list: ArrayList<JSONObject>) //Obtain filtered data
    }


    /**
     *Implemented the Filterable interface and rewritten the method
     */
    override fun getFilter(): Filter {
        return filter ?: MyFilter(beanData)
    }

    /**
     *Create Inner class to filter data
     */
    internal inner class MyFilter(var originalData: ArrayList<JSONObject>) : Filter() {
        /**
         *This method returns search filtered data
         *
         * @param constraint
         * @return
         */
        override fun performFiltering(constraint: CharSequence): Filter.FilterResults {
            val results = Filter.FilterResults()
            /**
             *If there is no search content, assign the value and size of the original data to results
             *If the search is performed, filter according to the search rules, and finally assign the value and size of the filtered data to the results
             */

            
            
            
            

            if (TextUtils.isEmpty(constraint)) {
                results.values = originalData
                results.count = originalData?.size
            } else {
                //Create a collection to save filtered data
                val filteredList = ArrayList<JSONObject>()
                //Traverse the original data set and filter the data according to the search rules
                for (s in originalData) {
                    //Here is the specific implementation of filtering rules. There are many rules, and you can decide how to implement them yourself
                    if (null != s.optString("coinName") && NCoinManager.getShowMarket(s.optString("coinName")).toLowerCase().contains(constraint.toString().trim().toLowerCase())) {
                        //If the rules match, add the data to the set
                        filteredList.add(s)
                    }
                }
                results.values = filteredList
                results.count = filteredList.size
            }

            //Returns the FilterResults object
            return results
        }

        /**
         *This method is used to refresh the user interface and redisplay the list based on filtered data
         */
        override fun publishResults(constraint: CharSequence, results: Filter.FilterResults) {

            //Obtain filtered data
            try {
                val beanDatas = results.values as ArrayList<JSONObject>
                //If the interface object is not empty, then call the method in the interface to obtain the filtered data, and the specific implementation is executed in the method rewritten when the interface is new
                listener?.getFilterData(beanDatas)
                
                //Refresh Data Source Display
                notifyDataSetChanged()
            } catch (e: Exception) {
                e.printStackTrace()
            }

        }
    }


}
