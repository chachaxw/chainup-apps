package com.yjkj.chainup.new_version.adapter

import android.text.TextUtils
import android.util.Log
import android.widget.Filter
import android.widget.Filterable
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.yjkj.chainup.R
import com.yjkj.chainup.bean.CountryInfo
import com.yjkj.chainup.new_version.activity.SelectAreaActivity
import java.util.*

/**
 * @Author lianshangljl
 * @Date 2023/5/31-9:24 AM
 * @Email buptjinlong@163.com
 * @description
 */
class AreaAdapter(var datas: ArrayList<CountryInfo>,var contextm: SelectAreaActivity) : BaseQuickAdapter<CountryInfo, BaseViewHolder>(R.layout.item_list_counrty_code, datas), Filterable {

    val selectDate: ArrayList<CountryInfo> = datas

    override fun convert(helper: BaseViewHolder, item: CountryInfo) {
        val language = Locale.getDefault().language
        if (language.contains("zh")) {
            helper?.setText(R.id.tv_area_name, item?.cnName)

        } else {
            helper?.setText(R.id.tv_area_name, item?.enName)

        }
        helper?.setText(R.id.tv_area_code, item?.dialingCode)
    }

     val TAG:String = AreaAdapter::class.java.simpleName

    private var filter: MyFilter? = null
    var listener: FilterListener? = null


    interface FilterListener {
        fun getFilterData(list: ArrayList<CountryInfo>) //Obtain filtered data
    }


    /**
     *Implemented the Filterable interface and rewritten the method
     */
    override fun getFilter(): Filter {
        return filter ?: MyFilter(datas)
    }

    /**
     *Create Inner class to filter data
     */
    internal inner class MyFilter(var originalData: ArrayList<CountryInfo>) : Filter() {
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
                results.values = contextm?.countryListNormal
                results.count = contextm?.countryListNormal?.size
            } else {
                //Create a collection to save filtered data
                val filteredList = ArrayList<CountryInfo>()
                //Traverse the original data set and filter the data according to the search rules
                for (s in contextm.countryListNormal) {
                    //Here is the specific implementation of filtering rules. There are many rules, and you can decide how to implement them yourself
                    if (s.cnName.toLowerCase().contains(constraint.toString().trim().toLowerCase()) || s.enName.toLowerCase().contains(constraint.toString().trim().toLowerCase()) || s.dialingCode.contains(constraint.toString().trim().toLowerCase())) {
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
               val  datas = results.values as ArrayList<CountryInfo>
                //If the interface object is not empty, then call the method in the interface to obtain the filtered data, and the specific implementation is executed in the method rewritten when the interface is new
                listener?.getFilterData(datas)
                
            }
            //Refresh Data Source Display
            notifyDataSetChanged()
        }
    }
}
