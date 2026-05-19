package com.yjkj.chainup.new_version.adapter

import android.text.TextUtils
import android.util.Log
import android.widget.Filter
import android.widget.Filterable
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.yjkj.chainup.R
import com.yjkj.chainup.bean.QuotesData
import com.yjkj.chainup.manager.DataManager
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.util.ColorUtil
import com.yjkj.chainup.util.DecimalUtil
import com.yjkj.chainup.util.setGoneV3

/**
 * @Author: Bertking
 * @Date 2023/4/3-2:48 PM
 *@description: Used for "spot trading" to select currency pairs
 */
class SearchCoinAdapter(var datas: ArrayList<QuotesData.Tick>, var allData: ArrayList<QuotesData.Tick>, var isNeedArea: Boolean = true) :
        BaseQuickAdapter<QuotesData.Tick, BaseViewHolder>(R.layout.item_search_coin, datas), Filterable {
    val TAG = SearchCoinAdapter::class.java.simpleName

    private var filter: MyFilter? = null
    var listener: FilterListener? = null

    override fun convert(helper: BaseViewHolder, tick: QuotesData.Tick) {
        
        tick ?: return
        /**
         * Tick(amount='39.96450966', vol='17.56774781', high='2.30000000', low='2.18970000', rose=0.0, close='2.30000000', open='2.30000000', name='BCH/BTC', symbol='bchbtc')
         */


        var name = ""
        if (tick?.anotherName?.isNotEmpty()) {
            name = tick?.anotherName
        } else {
            name = tick?.name
        }

        if (TextUtils.isEmpty(name) || helper == null) {
            return
        }
        //TODO pending resolution does not include/
        if (!name?.contains("/")!!) return

        val split = name.split("/".toRegex()).dropLastWhile({ it.isEmpty() }).toTypedArray()
        helper?.setText(R.id.tv_coin_name, split[0])
        helper?.setText(R.id.tv_market_name, "/" + split[1])


        val mainArea =  LanguageUtil.getString(context, "transaction_text_mainZone")
        val innovationArea =  LanguageUtil.getString(context, "market_text_innovationZone")
        val observeArea =  LanguageUtil.getString(context,"market_text_observeZone")

        if (isNeedArea) {
            if (helper?.adapterPosition == 0) {
                helper.setGoneV3(R.id.ll_main_area, true)
                helper.setGoneV3(R.id.v_line, true)
                when (tick.type) {
                    0 -> {
                        helper.setText(R.id.ll_title_content, mainArea)
                    }
                    1 -> {
                        helper.setText(R.id.ll_title_content, innovationArea)
                    }
                    2 -> {
                        helper.setText(R.id.ll_title_content, observeArea)
                    }
                }
            } else {
                
                if (data.size <= helper?.adapterPosition ?: 0) return
                if (data[helper?.adapterPosition!!
                                - 1].type != tick.type) {
                    helper.setGoneV3(R.id.ll_main_area, true)
                    helper.setGoneV3(R.id.v_line, true)
                    when (tick.type) {
                        0 -> {
                            helper.setText(R.id.ll_title_content, mainArea)
                        }
                        1 -> {
                            helper.setText(R.id.ll_title_content, innovationArea)
                        }
                        2 -> {
                            helper.setText(R.id.ll_title_content, observeArea)
                        }
                    }
                } else {
                    helper.setGoneV3(R.id.ll_main_area, false)
                    helper.setGoneV3(R.id.v_line, false)
                }
            }
        }


        /**
         *Closing price
         */
        if (TextUtils.isEmpty(tick.close)) {
            helper.setText(R.id.tv_close_price, "--")
        } else {
            helper.setText(R.id.tv_close_price, DecimalUtil.cutValueByPrecision(tick.close, tick.pricePrecision))
        }


        val rose = tick.rose.toDouble()
        helper.setTextColor(R.id.tv_close_price, ColorUtil.getMainColorType(rose >= 0))

//        when {
//            rose > 0 -> {
//                helper?.getView<TextView>(R.id.tv_close_price)?.setTextColor(ColorUtil.getMainColorType())
//            }
//            rose == 0.0 -> {
//                helper?.getView<TextView>(R.id.tv_close_price)?.setTextColor(ColorUtil.getColor(R.color.main_font_color))
//            }
//            else -> {
//                helper?.getView<TextView>(R.id.tv_close_price)?.setTextColor(ColorUtil.getMainColorType(isRise = false))
//            }
//        }

    }


    interface FilterListener {
        fun getFilterData(list: List<QuotesData.Tick>) //Obtain filtered data
    }


    /**
     *Implemented the Filterable interface and rewritten the method
     */
    override fun getFilter(): Filter {
        return filter ?: MyFilter(allData)
    }

    /**
     *Create Inner class to filter data
     */
    internal inner class MyFilter(var originalData: ArrayList<QuotesData.Tick>) : Filter() {

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
                results.count = originalData.size
            } else {
                //Create a collection to save filtered data
                var filteredList = ArrayList<QuotesData.Tick>()
                //Traverse the original data set and filter the data according to the search rules
                for (s in originalData) {
                    //Here is the specific implementation of filtering rules. There are many rules, and you can decide how to implement them yourself
                    val split = s.name.split("/")
                    
                    if (NCoinManager.getShowMarket(split[0]).toLowerCase().contains(constraint.toString().trim().toLowerCase())) {
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
            if (results.values != null) {
                data = results.values as ArrayList<QuotesData.Tick>
            }
            //If the interface object is not empty, then call the method in the interface to obtain the filtered data, and the specific implementation is executed in the method rewritten when the interface is new
            listener?.getFilterData(data)
            
            //Refresh Data Source Display
            notifyDataSetChanged()
        }
    }

}

