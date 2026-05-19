package com.yjkj.chainup.new_version.activity.like.view

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.widget.LinearLayout
import androidx.recyclerview.widget.GridLayoutManager
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.google.android.flexbox.*
import com.yjkj.chainup.R
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.util.getVisible
import com.yjkj.chainup.wedegit.ViewUtil
import com.yjkj.chainup.wedegit.item.GridItemDecoration
import com.yjkj.chainup.wedegit.item.SpaceItemDecoration
import kotlinx.android.synthetic.main.include_search_hot.view.*
import org.jetbrains.anko.sdk27.coroutines.onClick

/**
 * @Author lianshangljl
 * @Date 2023-03-30-12:44
 * @Email buptjinlong@163.com
 * @description
 */
class SearchTopView @JvmOverloads constructor(context: Context,
                                              attrs: AttributeSet? = null,
                                              defStyleAttr: Int = 0) : LinearLayout(context, attrs, defStyleAttr) {

    var searchViewListener: SearchViewListener? = null
    private lateinit var mHotCoinAdapter: HotCoinAdapter
    var dataList: ArrayList<String> = arrayListOf()

    init {
        initView(context)
    }


    fun initView(context: Context) {
        LayoutInflater.from(context).inflate(R.layout.include_search_hot, this, true)
        iv_delete_history.onClick {
            searchViewListener?.apply {
                clearSearch()
                initItems(false)
            }
        }
        tv_search_hot_title?.text = LanguageUtil.getString(context,"common_action_history")
        mHotCoinAdapter = HotCoinAdapter(R.layout.item_hot_coin_search, dataList)
        mHotCoinAdapter.setOnItemClickListener { adapter, view, position ->
            searchViewListener?.apply {
                val symbol = NCoinManager.getShowMarket(adapter.getItem(position) as String)
                hotItemClick(symbol)
            }
        }
    }

    fun initItems(isShow: Boolean) {
        rl_history_title.visibility = isShow.getVisible()
        layout_hot.visibility = isShow.getVisible()
    }

    fun initTopView(symbols: String) {
        layout_hot.visibility = symbols.isNotEmpty().getVisible()
        if (symbols.isNotEmpty()) {
            val dataList = symbols.split(",")
            mHotCoinAdapter.setList(dataList)
            rv_hot_coin.apply {
                layoutManager = ViewUtil.getFlowManager(context)
                adapter = mHotCoinAdapter
            }
        }
    }

    fun initTopView(data: ArrayList<String>) {
        layout_hot.visibility = data.isNotEmpty().getVisible()
        if (data.isNotEmpty()) {
            mHotCoinAdapter.setList(data)
            rv_hot_coin.apply {
                layoutManager = ViewUtil.getFlowManager(context)
                adapter = mHotCoinAdapter
            }
        }
    }

    fun getItemView(): View {
        return layout_hot
    }

    class HotCoinAdapter(layoutResId: Int, data: ArrayList<String>) :
        BaseQuickAdapter<String, BaseViewHolder>(layoutResId, data) {
        override fun convert(helper: BaseViewHolder, item: String) {
            val name = NCoinManager.getShowMarket(item)
            helper.setText(R.id.tv_title, name)
        }
    }

    interface SearchViewListener {
        fun clearSearch()
        fun hotItemClick(name: String)
    }


}
