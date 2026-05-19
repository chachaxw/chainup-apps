package com.yjkj.chainup.new_version.adapter

import android.app.Activity
import android.text.SpannableString
import android.text.Spanned
import android.text.style.AbsoluteSizeSpan
import android.text.style.ForegroundColorSpan
import android.widget.TextView
import androidx.core.content.ContextCompat
import com.bumptech.glide.request.RequestOptions
import com.chad.library.adapter.base.BaseDelegateMultiAdapter
import com.chad.library.adapter.base.delegate.BaseMultiTypeDelegate
import com.chad.library.adapter.base.module.LoadMoreModule
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.chainup.contract.view.trade.ContractLoadMoreView
import com.yjkj.chainup.R
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.new_version.view.SpotLoadMoreView
import com.yjkj.chainup.util.DateUtils
import com.yjkj.chainup.util.GlideUtils
import org.json.JSONObject


class RewardDetailAdapter(val type:Int = currentRecord) : BaseDelegateMultiAdapter<JSONObject,BaseViewHolder>(),LoadMoreModule {

    companion object {
        const val currentRecord = 0
        const val rewardRecord = 1
        const val withdrawalRecord = 2
    }
    init {
        setMultiTypeDelegate(object : BaseMultiTypeDelegate<JSONObject>() {
            override fun getItemType(data: List<JSONObject>, position: Int): Int = type
        })
        getMultiTypeDelegate()?.let {
            it.addItemType(currentRecord, R.layout.item_current_reward_record_layout)
            it.addItemType(rewardRecord, R.layout.item_reward_record_layout)
            it.addItemType(withdrawalRecord, R.layout.item_withdrawal_reward_record_layout)
        }

        loadMoreModule.loadMoreView = SpotLoadMoreView()

    }

    override fun convert(holder: BaseViewHolder, item: JSONObject) {
        when(holder.itemViewType){
            currentRecord -> {
                val options = RequestOptions().placeholder(R.mipmap.task_coin).error(R.mipmap.task_coin)
                val symbolPair = PublicInfoDataService.getInstance().getSymbolWithIcon(item.optString("coin"))
                if(!symbolPair.first.isEmpty()){
                    GlideUtils.load(context as Activity,symbolPair.first,holder.getView(R.id.iv_logo),options)
                }
                holder.setText(R.id.tv_symbol,item.optString("coin"))
                holder.setText(R.id.tv_fullsymbol,symbolPair.second)
                holder.setText(R.id.tv_amount,item.optString("unWithdrawAmount"))
                holder.setText(R.id.tv_amount_value,item.optString("usdtAmount")+"USDT")
            }
            rewardRecord -> {
                holder.setText(R.id.tv_title,item.optString("taskName"))
                holder.setText(R.id.tv_amount,"+" + item.optString("amount") + item.optString("coin"))
                val receiveTime = item.optString("receiveTime")
                if(!"".equals(receiveTime)){
                    holder.setText(R.id.tv_date,DateUtils.getYearMonthDayHourMinSecond(receiveTime.toLong()))
                }

            }

            withdrawalRecord -> {
                val options = RequestOptions().placeholder(R.mipmap.task_coin).error(R.mipmap.task_coin)
                val symbolPair = PublicInfoDataService.getInstance().getSymbolWithIcon(item.optString("coin"))
                GlideUtils.load(context as Activity,symbolPair.first,holder.getView(R.id.iv_logo),options)
                formatTextStyle(item.optString("coin"),symbolPair.second,holder.getView(R.id.tv_symbol))
//                holder.setText(R.id.tv_symbol,item.optString("coin"))
                holder.setText(R.id.tv_amount,item.optString("amount"))
                holder.setText(R.id.tv_amount_value,item.optString("usdtAmount")+"USDT")
                holder.setText(R.id.tv_date,DateUtils.getYearMonthDayHourMinSecond(item.optString("withdrawTime").toLong()))
            }
        }
    }

    private fun formatTextStyle(symbol:String,fullSymbol:String,view: TextView) {
        if("".equals(fullSymbol)){
            view.text = symbol
            return
        }
        val value = "$symbol $fullSymbol"
        val spannableString = SpannableString(value)
        val absoluteSizeSpan = AbsoluteSizeSpan(16, true)
        val absoluteSizeSpanFullSymbol = AbsoluteSizeSpan(12, true)
        val foregroundColorSpan = ForegroundColorSpan(ContextCompat.getColor(context,R.color.text_1))
        val foregroundColorSpanFullSymbol = ForegroundColorSpan(ContextCompat.getColor(context,R.color.text_3))
        spannableString.setSpan(absoluteSizeSpan,0,symbol.length, Spanned.SPAN_EXCLUSIVE_INCLUSIVE)
        spannableString.setSpan(foregroundColorSpan,0,symbol.length, Spanned.SPAN_EXCLUSIVE_INCLUSIVE)
        spannableString.setSpan(absoluteSizeSpanFullSymbol,symbol.length,value.length, Spanned.SPAN_EXCLUSIVE_INCLUSIVE)
        spannableString.setSpan(foregroundColorSpanFullSymbol,symbol.length,value.length, Spanned.SPAN_EXCLUSIVE_INCLUSIVE)
        view.setText(spannableString)
    }


}