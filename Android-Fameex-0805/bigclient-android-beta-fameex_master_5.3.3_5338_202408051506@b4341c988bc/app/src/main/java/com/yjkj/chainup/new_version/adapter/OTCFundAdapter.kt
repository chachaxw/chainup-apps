package com.yjkj.chainup.new_version.adapter

import android.text.TextUtils
import android.view.View
import android.widget.Filter
import android.widget.Filterable
import android.widget.ImageView
import android.widget.TextView
import com.alibaba.fastjson.JSON
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.yjkj.chainup.R
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.manager.RateManager
import com.yjkj.chainup.util.BigDecimalUtils
import com.yjkj.chainup.util.Utils
import org.json.JSONObject

/**
 * @Author lianshangljl
 *@ Date 2018/10/26-11:07 AM
 * @Email buptjinlong@163.com
 * @description
 */
open class OTCFundAdapter(var datas: ArrayList<JSONObject>) :
        BaseQuickAdapter<JSONObject, BaseViewHolder>(R.layout.item_new_asset_otc, datas), Filterable {


    private var filter: MyFilter? = null
    private var listener: FilterListener? = null

    fun setListener(listener: FilterListener) {
        this.listener = listener
    }

    interface FilterListener {
        fun getFilterData(list: List<JSONObject>) //Obtain filtered data
    }

    override fun getFilter(): Filter {
        var coinList = arrayListOf<JSONObject>()
        coinList.addAll(datas)
        if (filter == null) {
            filter = MyFilter(coinList)
        }
        return filter ?: MyFilter(coinList)
    }

    /**
     *Create Inner class to filter data
     */
    internal inner class MyFilter(originalData: ArrayList<JSONObject>) : Filter() {
        private var originalData = java.util.ArrayList<JSONObject>()

        init {
            this.originalData = originalData
        }

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
             *
             */
            if (TextUtils.isEmpty(constraint)) {
                results.values = originalData
                results.count = originalData.size
            } else {
                //Create a collection to save filtered data
                val filteredList = java.util.ArrayList<JSONObject>()
                //Traverse the original data set and filter the data according to the search rules
                for (s in originalData) {
                    //Here is the specific implementation of filtering rules. There are many rules, and you can decide how to implement them yourself
                    if (NCoinManager.getShowMarket(s?.optString("coinName")).toLowerCase().contains(constraint.toString().trim { it <= ' ' }.toLowerCase())) {
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
                data = results.values as ArrayList<JSONObject>
            }
            //If the interface object is not empty, then call the method in the interface to obtain the filtered data, and the specific implementation is executed in the method rewritten when the interface is new
            if (listener != null) {
                listener?.getFilterData(data)
            }
            //Refresh Data Source Display
            notifyDataSetChanged()
            notifyItemRangeChanged(0, data.size)
        }
    }

    override fun convert(helper: BaseViewHolder, item: JSONObject) {
        /**
         *Currency
         */
        helper?.setText(R.id.tv_coin_name, NCoinManager.getShowMarket(item?.optString("coinName")
                ?: ""))


        var bean = NCoinManager.getCoinObj(item?.optString("coinName"))

        helper?.setText(R.id.tv_1st_title,LanguageUtil.getString(context,"assets_text_available"))
        helper?.setText(R.id.tv_2nd_title,LanguageUtil.getString(context,"assets_text_freeze"))
        helper?.setText(R.id.tv_3rd_title,LanguageUtil.getString(context,"assets_text_lockup"))
        helper?.setText(R.id.tv_4th_title,LanguageUtil.getString(context,"assets_text_equivalence"))
        helper?.setText(R.id.tv_5th_title,LanguageUtil.getString(context,"assets_text_equivalence"))
        helper?.setText(R.id.tv_4th_title,  LanguageUtil.getString(context, "assets_text_equivalence") + "(${RateManager.getCurrencyLang()})")


        /**
         *Available assets
         */
        var mnormal_balance = BigDecimalUtils.divForDown(item?.optString("normal_balance"), NCoinManager.getCoinShowPrecision(item?.optString("coinName")
                ?: "")).toPlainString()
        val normalBalanceTitle =  LanguageUtil.getString(context,"assets_text_available")
        /**
         *Lock the warehouse
         */
        var mlock_grant_divided_balance = BigDecimalUtils.divForDown(item?.optString("lock_grant_divided_balance"), NCoinManager.getCoinShowPrecision(item?.optString("coinName")
                ?: "")).toPlainString()
        val lockedBalanceTitle =  LanguageUtil.getString(context, "assets_text_lockup")

        /**
         *Freeze
         */
        var mlock_balance = BigDecimalUtils.divForDown(item?.optString("lock_balance"), NCoinManager.getCoinShowPrecision(item?.optString("coinName")
                ?: "")).toPlainString()
        val frozenBalanceTitle =  LanguageUtil.getString(context, "assets_text_freeze")

        /**
         *Equivalent
         */
        val result = RateManager.getCNYByCoinName("BTC", item?.optString("allBtcValuatin")
                ?: "0", isOnlyResult = true)

        val convertBTCTitle =  LanguageUtil.getString(context, "assets_text_equivalence")+ "(${RateManager.getCurrencyLang()})"

        var isShowAssets = UserDataService.getInstance().isShowAssets


        /**
         *Price increase available
         */
        val overChargeBalance = BigDecimalUtils.divForDown(item?.optString("overcharge_balance")
                ?: "0", NCoinManager.getCoinShowPrecision(item?.optString("coinName")
                ?: "")).toPlainString()
        val overChargeBalanceTitle =  LanguageUtil.getString(context, "common_text_limitAvailable")


        val pairs = ArrayList<Pair<String, String>>(5)
        pairs.add(Pair(normalBalanceTitle, mnormal_balance))
        pairs.add(Pair(frozenBalanceTitle, mlock_balance))
        pairs.add(Pair(lockedBalanceTitle, mlock_grant_divided_balance))
        pairs.add(Pair(convertBTCTitle, result))

        val views = ArrayList<Pair<TextView?, TextView?>>(5)
        views.add(Pair(helper?.getView<TextView>(R.id.tv_1st_title), helper?.getView<TextView>(R.id.tv_1st_value)))
        views.add(Pair(helper?.getView<TextView>(R.id.tv_2nd_title), helper?.getView<TextView>(R.id.tv_2nd_value)))
        views.add(Pair(helper?.getView<TextView>(R.id.tv_3rd_title), helper?.getView<TextView>(R.id.tv_3rd_value)))
        views.add(Pair(helper?.getView<TextView>(R.id.tv_4th_title), helper?.getView<TextView>(R.id.tv_4th_value)))
        views.add(Pair(helper?.getView<TextView>(R.id.tv_5th_title), helper?.getView<TextView>(R.id.tv_5th_value)))

        if (bean?.optInt("isOvercharge") == 1) {
            pairs.add(1, Pair(overChargeBalanceTitle, overChargeBalance))
            views.last().first?.visibility = View.VISIBLE
            views.last().second?.visibility = View.VISIBLE
        } else {
            views.last().first?.visibility = View.GONE
            views.last().second?.visibility = View.GONE
        }

        pairs.forEachIndexed { index, pair ->
            views[index].first?.text = pair.first
            views[index].second?.text = pair.second
        }

        if (!isShowAssets) {
            Utils.assetsHideShow(isShowAssets, helper?.getView(R.id.tv_1st_value), mnormal_balance)
            Utils.assetsHideShow(isShowAssets, helper?.getView(R.id.tv_2nd_value), mlock_balance)
            Utils.assetsHideShow(isShowAssets, helper?.getView(R.id.tv_3rd_value), mlock_grant_divided_balance)
            Utils.assetsHideShow(isShowAssets, helper?.getView(R.id.tv_4th_value), result)
            Utils.assetsHideShow(isShowAssets, helper?.getView(R.id.tv_5th_value), result)
        }

        val imgCoinTip = helper?.getView<ImageView>(R.id.img_coin_tip)
        val isDeposit = (item?.optInt("depositOpen") == 1)
        val isWithdraw = (item?.optInt("withdrawOpen") == 1)
        imgCoinTip?.visibility=if(!isDeposit||!isWithdraw) View.VISIBLE else View.GONE
        addChildClickViewIds(R.id.img_coin_tip)
    }

}
