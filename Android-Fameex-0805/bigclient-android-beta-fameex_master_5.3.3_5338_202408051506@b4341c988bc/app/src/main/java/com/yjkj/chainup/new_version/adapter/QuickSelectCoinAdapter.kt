package com.yjkj.chainup.new_version.adapter

import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.text.TextUtils
import android.widget.Filter
import android.widget.Filterable
import android.widget.ImageView
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.yjkj.chainup.R
import com.yjkj.chainup.bean.Coin
import com.yjkj.chainup.util.GlideUtils
import com.yjkj.chainup.util.ResourcesUtils
import kotlinx.android.synthetic.main.activity_quick_buy_coin_index.*

/**
 * @Author: Bertking
 * @Date 2023/4/16-4:19 PM
 * @Description:
 */
class QuickSelectCoinAdapter(val datas: ArrayList<Coin>) : BaseQuickAdapter<Coin, BaseViewHolder>(R.layout.item_quick_search_coin, datas) {

    val TAG = QuickSelectCoinAdapter::class.java.simpleName

    private var mSearchList: ArrayList<Coin>? = datas



    override fun convert(helper: BaseViewHolder, item: Coin) {
        helper.setText(R.id.tv_coin_name, if(TextUtils.isEmpty(item.alias)) item.name else item.alias)
//        helper.setText(R.id.tv_coin, item.iconContent)
        val coin_pic = helper.getView<ImageView>(R.id.img_coin_pic)
        GlideUtils.load(context, item.iconUrl, coin_pic)

    }

     fun showAll(sist: ArrayList<Coin>) {
         mSearchList?.clear()
         mSearchList?.addAll(sist)
         notifyDataSetChanged()
    }

//    override fun getFilter()=object :Filter(){
//        override fun performFiltering(p0: CharSequence?): FilterResults {
//            val results =  FilterResults();
//           val constraint=p0.toString().toLowerCase()
//            if (TextUtils.isEmpty(constraint)) {
//                results.values = mList
//                results.count = mList?.size!!
//            } else {
//                val filteredList = ArrayList<Coin>()
//                for (s in mList!!) {
//                    if (TextUtils.isEmpty(s.alias)){
//                        if (s.name.toLowerCase().contains(constraint.toString().trim().toLowerCase())){
//                            filteredList.add(s)
//                        }
//                    }else{
//                        if (s.alias.toLowerCase().contains(constraint.toString().trim().toLowerCase())){
//                            filteredList.add(s)
//                        }
//                    }
//                }
//                results.values = filteredList
//                results.count = filteredList.size
//            }
//            return results;
//        }
//
//        override fun publishResults(p0: CharSequence?, p1: FilterResults?) {
//            mSearchList?.clear()
//            mSearchList?.addAll(p1?.values as Collection<Coin>)
//            if (p1?.count!! > 0) {
//                notifyDataSetChanged();
//            }
//        }
//
//    }

}
