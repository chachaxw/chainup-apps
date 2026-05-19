package com.yjkj.chainup.new_version.adapter

import android.content.Context
import android.graphics.Color
import android.text.SpannableString
import android.text.Spanned
import android.text.style.ForegroundColorSpan
import android.text.style.RelativeSizeSpan
import android.widget.CheckBox
import androidx.core.content.ContextCompat
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.chainup.contract.utils.CpClLogicContractSetting
import com.yjkj.chainup.R
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.util.getCoinFullName
import org.json.JSONObject

class RecommendCoinAdapter(layoutResId: Int, type:String,data: MutableList<JSONObject>) :
    BaseQuickAdapter<JSONObject, BaseViewHolder>(layoutResId, data) {
    var typestr =type
    override fun convert(helper: BaseViewHolder, item: JSONObject) {
        if (typestr.equals("contract")){
            val mShowName =
                CpClLogicContractSetting.getContractShowNameById(context, item.optInt("id"))
            var lastIndex = mShowName.lastIndexOf("-");
            if (lastIndex==-1){
                helper.setText(R.id.tv_coin_name, mShowName)
            }else{
                val sp = SpannableString(mShowName)
                sp.setSpan(RelativeSizeSpan(0.75f), lastIndex,   mShowName.length, Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
                sp.setSpan(
                    ForegroundColorSpan(ContextCompat.getColor(context,R.color.text_color_2)),
                    lastIndex,
                    mShowName.length,
                    Spanned.SPAN_INCLUSIVE_EXCLUSIVE
                )
                helper.setText(R.id.tv_coin_name, sp)
            }
            helper.setGone(R.id.tv_market_name, true)
            helper.setGone(R.id.tv_coin_full_name, true)
        }else{
            var name = NCoinManager.showAnoterName(item)
            if (!name.contains("/")!!) {
                return
            }
            val split = name.split("/")
            helper?.setText(R.id.tv_coin_name, split[0])
            helper?.setText(R.id.tv_market_name, "/" + split[1])
            helper.setGone(R.id.tv_market_name, false)
            helper.setText(R.id.tv_coin_full_name, item.getCoinFullName())
        }
        val cbCoin = helper.getView<CheckBox>(R.id.cb_coin)
        cbCoin.isChecked = item.optBoolean("isSel")
    }
}

