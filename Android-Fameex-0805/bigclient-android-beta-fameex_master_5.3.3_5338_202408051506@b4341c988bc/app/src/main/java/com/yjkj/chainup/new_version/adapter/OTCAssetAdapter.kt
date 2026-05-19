package com.yjkj.chainup.new_version.adapter

import android.text.TextUtils
import android.util.Log
import android.widget.Filter
import android.widget.Filterable
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.yjkj.chainup.R
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.manager.RateManager
import com.yjkj.chainup.util.BigDecimalUtils
import com.yjkj.chainup.util.LogUtil
import com.yjkj.chainup.util.Utils
import com.yjkj.chainup.util.setGoneV3
import org.json.JSONObject

/**
 * Created by $USER_NAME on 2018/10/15.
 *
 */
open class OTCAssetAdapter(var datas: ArrayList<JSONObject>) :
        BaseQuickAdapter<JSONObject, BaseViewHolder>(R.layout.item_asset_otc, datas), Filterable {
    private var filter: MyFilter? = null
    private var listener: FilterListener? = null
    var equivalent_all=""
    var assetState: String = ParamConstant.FABI_INDEX

    fun setType(type: String) {
        assetState = type
    }

    interface FilterListener {
        fun getFilterData(list: ArrayList<JSONObject>) //Obtain filtered data
    }

    fun setListener(listener: FilterListener) {
        this.listener = listener
    }

    override fun getFilter(): Filter {
        if (filter == null) {
            filter = MyFilter(datas)
        }
        return filter ?: MyFilter(datas)
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

                    when (assetState) {
                        ParamConstant.LEVER_INDEX -> {
                            if (null != s.optString("name") && NCoinManager.getShowMarket(s.optString("name")).toLowerCase().contains(constraint.toString().trim { it <= ' ' }.toLowerCase())) {
                                //If the rules match, add the data to the set
                                filteredList.add(s)
                            }
                        }
                        ParamConstant.FABI_INDEX -> {
                            if (null != s.optString("coinSymbol") && NCoinManager.getShowMarket(s.optString("coinSymbol")).toLowerCase().contains(constraint.toString().trim { it <= ' ' }.toLowerCase())) {
                                //If the rules match, add the data to the set
                                filteredList.add(s)
                            }
                        }
                        ParamConstant.B2C_INDEX -> {
                            if (null != s.optString("symbol") && NCoinManager.getShowMarket(s.optString("symbol")).toLowerCase().contains(constraint.toString().trim { it <= ' ' }.toLowerCase())) {
                                //If the rules match, add the data to the set
                                filteredList.add(s)
                            }
                        }
                    }

                }
                results.values = filteredList
                results.count = filteredList.size
            }
            LogUtil.e("-------resultsresults",  results.count.toString())
            //Returns the FilterResults object
            return results
        }

        /**
         *This method is used to refresh the user interface and redisplay the list based on filtered data
         */
        override fun publishResults(constraint: CharSequence, results: Filter.FilterResults) {
            LogUtil.e("++++++++resultsresults",  results.count.toString())

            //Obtain filtered data
            if (null != results.values) {
                data = results.values as ArrayList<JSONObject>
            }
            LogUtil.e("++++++++resultsresults",  data.size.toString())
            //If the interface object is not empty, then call the method in the interface to obtain the filtered data, and the specific implementation is executed in the method rewritten when the interface is new
//            if (listener != null) {
//                listener?.getFilterData(data as ArrayList<JSONObject>)
//            }
            LogUtil.e("++++++++resultsresults",  data.size.toString())
            //Refresh Data Source Display
            notifyDataSetChanged()
            notifyItemRangeChanged(0, data.size)
        }
    }

    override fun convert(helper: BaseViewHolder, item: JSONObject) {
        var mnormal = ""
        var mlock = ""
        var result = ""

        var secondNormal = ""
        var secondmlock = ""
        var secondresult = ""
        helper?.setText(R.id.tv_coin_title,LanguageUtil.getString(context,"assets_text_available"))
        helper?.setText(R.id.tv_canUse_title,LanguageUtil.getString(context,"assets_text_freeze"))
        helper?.setText(R.id.tv_equivalent,LanguageUtil.getString(context,"assets_text_equivalence"))
        when (assetState) {
            ParamConstant.FABI_INDEX -> {
                helper?.setText(R.id.tv_coin_name, NCoinManager.getShowMarket(item?.optString("coinSymbol")))

                helper?.setText(R.id.tv_equivalent,  LanguageUtil.getString(context, "assets_text_equivalence") + "(${RateManager.getCurrencyLang()})")
               val mnormalBuff= BigDecimalUtils.divForDown(item?.optString("normal")
                    ?: "0", NCoinManager.getCoinShowPrecision(item?.optString("coinSymbol")) ?: 1).toPlainString()
               val lockBuff= BigDecimalUtils.divForDown(item?.optString("lock")
                    ?: "0", NCoinManager.getCoinShowPrecision(item?.optString("coinSymbol")) ?: 1).toPlainString()
                mnormal =mnormalBuff
                mlock = lockBuff
                result = RateManager.getCNYByCoinName("BTC", item?.optString("btcValuation"), isOnlyResult = true)


            }

            ParamConstant.B2C_INDEX -> {
                helper?.setText(R.id.tv_equivalent,  LanguageUtil.getString(context, "otc_text_orderTotal"))


                mnormal = BigDecimalUtils.divForDown(item?.optString("normalBalance")
                        ?: "0", item?.optInt("showPrecision", 1) ?: 1).toPlainString()
                mlock = BigDecimalUtils.divForDown(item?.optString("lockBalance")
                        ?: "0", item?.optInt("showPrecision", 1) ?: 1).toPlainString()
                result = RateManager.getCNYByCoinName("BTC", item?.optString("totalBalance"), isOnlyResult = true)

                helper?.setText(R.id.tv_coin_name, NCoinManager.getShowMarket(item?.optString("symbol")))

            }
            ParamConstant.LEVER_INDEX -> {
                helper?.apply {
                    setText(R.id.tv_coin_title,  LanguageUtil.getString(context, "common_text_coinsymbol"))
                    setText(R.id.tv_canUse_title,  LanguageUtil.getString(context, "assets_text_available"))
                    setText(R.id.tv_equivalent,  LanguageUtil.getString(context, "leverage_have_borrowed"))
                }
                helper.setGoneV3(R.id.ll_second_layout, true)
                helper.setGoneV3(R.id.tv_equivalent_all, true)

                mnormal = NCoinManager.getShowMarket(item?.optString("baseCoin"))
                mlock = BigDecimalUtils.divForDown(item?.optString("baseNormalBalance"), ParamConstant.NORMAL_PRECISION).toPlainString()
                result = BigDecimalUtils.divForDown(item?.optString("baseBorrowBalance"), ParamConstant.NORMAL_PRECISION).toPlainString()


                secondNormal = NCoinManager.getShowMarket(item?.optString("quoteCoin"))
                secondmlock = BigDecimalUtils.divForDown(item?.optString("quoteNormalBalance"), ParamConstant.NORMAL_PRECISION).toPlainString()
                secondresult = BigDecimalUtils.divForDown(item?.optString("quoteBorrowBalance"), ParamConstant.NORMAL_PRECISION).toPlainString()
                /**
                 *Currency name
                 */
                helper?.setText(R.id.tv_coin_name, NCoinManager.getShowMarketName(item?.optString("name")))

                /**
                 *Equivalent
                 */
                val result = RateManager.getCNYByCoinName("BTC", item?.optString("symbolBalance"), true, true)
                equivalent_all=LanguageUtil.getString(context, "assets_text_equivalence") + " " + result + RateManager.getCurrencyLang()
                helper?.setText(R.id.tv_equivalent_all, equivalent_all )
            }

        }

        var isShowAssets = UserDataService.getInstance().isShowAssets

        /**
         *Do you want to hide assets
         */
        if (!assetState.equals( ParamConstant.LEVER_INDEX)){
            Utils.assetsHideShow(isShowAssets, helper?.getView(R.id.tv_normal_balance), mnormal)
            Utils.assetsHideShow(isShowAssets, helper?.getView(R.id.tv_normal_second_balance), secondNormal)
        }else{
            Utils.assetsHideShow(true, helper?.getView(R.id.tv_normal_balance), mnormal)
            Utils.assetsHideShow(true, helper?.getView(R.id.tv_normal_second_balance), secondNormal)
        }

        Utils.assetsHideShow(isShowAssets, helper?.getView(R.id.tv_lock_balance), mlock)
        Utils.assetsHideShow(isShowAssets, helper?.getView(R.id.tv_equivalent_content), result)
        Utils.assetsHideShow(isShowAssets, helper?.getView(R.id.tv_equivalent_all), equivalent_all)


        Utils.assetsHideShow(isShowAssets, helper?.getView(R.id.tv_lock_second_balance), secondmlock)
        Utils.assetsHideShow(isShowAssets, helper?.getView(R.id.tv_equivalent_second_content), secondresult)


    }
}
