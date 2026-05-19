package com.yjkj.chainup.new_version.adapter

import android.text.TextUtils
import android.util.Log
import android.view.ViewGroup.MarginLayoutParams
import android.widget.LinearLayout
import android.widget.TextView
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.coorchice.library.SuperTextView
import com.yjkj.chainup.R
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.manager.RateManager
import com.yjkj.chainup.manager.TAG
import com.yjkj.chainup.new_version.view.CustomTagView
import com.yjkj.chainup.util.*
import org.json.JSONObject

/**
 * @Author lianshangljl
 * @Date 2023/11/8-10:20 AM
 * @Email buptjinlong@163.com
 *@description New homepage rise and fall rate
 *
 * data: ArrayList<JSONObject>
 */
open class NewhomepageTradeListAdapter : BaseQuickAdapter<JSONObject, BaseViewHolder>(R.layout.item_new_home_page_trade) {

    override fun convert(helper: BaseViewHolder, item: JSONObject) {
        val layout = helper.getView<LinearLayout>(R.id.layout_symbol_context)
        val layoutParams = layout.layoutParams
        val width = (DisplayUtil.getScreenWidth(context) - DisplayUtil.dip2px(32)) / 3
        layoutParams.width = width
        layout.layoutParams = layoutParams
        val name = NCoinManager.showAnoterName(item)
        if (StringUtil.checkStr(name) && name.contains("/")) {
            val split = name.split("/")
            helper?.setText(R.id.item_new_home_page_trade_symbol, split[0])
            helper?.setText(R.id.item_new_home_page_trade_market, "/" + split[1])
        }
        /**
         *Price tick. optInt ("price")
         */
        var close = item?.optString("close")
//        val close = tick.optString("close")
        if (TextUtils.isEmpty(close)) {
            helper.setText(R.id.item_new_home_page_trade_assets, "--")
        } else {
            helper.setText(R.id.item_new_home_page_trade_assets, BigDecimalUtils.divForDown(close, item.optInt("price")).toPlainString())
            helper?.setText(R.id.item_new_home_page_trade_assets, BigDecimalUtils.divForDown(close, item.optInt("price")).toPlainString())
        }
        /**
         *Increase
         */
        var rose = item?.optString("rose") ?: ""
//        if (TextUtils.isEmpty(close)) {
//            helper?.setText(R.id.item_new_home_page_trade_assets, "--")
//        } else {
//            helper?.setText(R.id.item_new_home_page_trade_assets, BigDecimalUtils.showNormal(close))
//        }
        helper.setTextColor(R.id.item_new_home_page_trade_assets, ColorUtil.getMainColorType(isRise = RateManager.getRoseTrend(rose) >= 0))
        /**
         *Exchange rate for closing price
         */
        var marketName = NCoinManager.getMarketName(item?.optString("name", ""))
        val result = RateManager.getHomeCNYByCoinName(marketName, close)
        helper?.setText(R.id.item_new_home_page_trade_value, result)



        RateManager.getRoseText(helper?.getView<TextView>(R.id.item_new_home_page_trade_gains), rose)
        var colorRiseType = ColorUtil.getColorType()
//        helper.getView<SuperTextView>(R.id.tv_rose).solid = ColorUtil.getMainColorV2Type(colorRiseType, isRise = RateManager.getRoseTrend(rose))
        helper?.setTextColor(R.id.item_new_home_page_trade_gains, ColorUtil.getMainColorV2Type(colorRiseType, isRise = RateManager.getRoseTrend(rose)))
//        helper?.setTextColor(R.id.item_new_home_page_trade_gains, ColorUtil.getMainColorType(isRise = RateManager.getRoseTrend(rose) >= 0))
    }

}
