package com.yjkj.chainup.new_version.adapter

import android.text.TextUtils
import android.view.View
import android.widget.TextView
import androidx.databinding.DataBindingUtil
import androidx.databinding.ViewDataBinding
import androidx.recyclerview.widget.DiffUtil
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseDataBindingHolder
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.chainup.contract.utils.CpBigDecimalUtils
import com.chainup.contract.utils.CpColorUtil
import com.chainup.contract.utils.CpNumberUtil
import com.chainup.kit.views.KKTagKit
import com.yjkj.chainup.R
import com.yjkj.chainup.databinding.ItemSearchCoinBinding
import com.yjkj.chainup.db.service.LikeDataService
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.new_version.home.callback.MarketTabDiffCallback
import com.yjkj.chainup.new_version.view.CustomTagView
import com.yjkj.chainup.util.*
import org.json.JSONObject
import java.util.ArrayList

/**
 * @Author: Bertking
 * @Date 2023-09-26-11:02
 * @Description:
 */
class NSearchCoinAdapter : BaseQuickAdapter<JSONObject, BaseDataBindingHolder<ItemSearchCoinBinding>>(R.layout.item_search_coin) {

    var isSelfData = false
    var isMarketLike = false
    public fun setParams(isSelfData: Boolean) {
        this.isSelfData = isSelfData
    }

    var isShowLever: Boolean = false
    var isblack = false


    override fun convert(helper: BaseDataBindingHolder<ItemSearchCoinBinding>, item: JSONObject) {

        if (null == helper || null == item)
            return
        var binding: ItemSearchCoinBinding? = helper.dataBinding
        binding?.isblack = isblack
        binding?.executePendingBindings()

        if (isShowLever) {
            val multiple = item.optString("multiple", "")
            helper.setGoneV3(R.id.tv_lever, !TextUtils.isEmpty(multiple))
            helper?.getView<KKTagKit>(R.id.tv_lever)?.setText("%sX".format(multiple))
        } else {
            helper.setGoneV3(R.id.tv_lever, false)
        }

        var name = NCoinManager.showAnoterName(item)//item.optString("name")
        var newcoinFlag = item.optInt("newcoinFlag")
        var vol = item.optString("vol")
        var close = item.optString("close")
        var price = item.optInt("price")
        var rose = item.optDouble("rose")



        var tagCoin = NCoinManager.getMarketShowCoinName(item?.optString("name"))
        if (!TextUtils.isEmpty(NCoinManager.getCoinTag4CoinName(tagCoin))) {
            helper?.getView<KKTagKit>(R.id.ctv_content)?.setText(NCoinManager.getCoinTag4CoinName(tagCoin))
            helper?.apply {
                setGoneV3(R.id.ctv_content, true)
            }
        } else {
            helper?.apply {
                setGoneV3(R.id.ctv_content, false)
            }
        }
        if (isMarketLike) {
            helper.setGoneV3(R.id.ll_main_area, true)
            helper.setGoneV3(R.id.v_line, true)
            helper.setText(R.id.ll_title_content, newcoinFlag.byMarketGroupTypeGetName(context))
        } else {
            helper.setGoneV3(R.id.ll_main_area, false)
            helper.setGoneV3(R.id.v_line, false)
        }

        if (null != name && name.contains("/")) {
            val split = name.split("/")

            helper?.setText(R.id.tv_coin_name, split[0])
            helper?.setText(R.id.tv_market_name, "/" + split[1])
        }
        LogUtil.e("NSearchCoinAdapter","dropListsAdapter adapter ${helper.adapterPosition} ${close}")
        /**
         *Closing price
         */
        if (TextUtils.isEmpty(close)) {
            helper?.setText(R.id.tv_close_price, "--")
        } else {
            helper?.setText(R.id.tv_close_price, DecimalUtil.cutValueByPrecision(close, price))
        }
        val chg = CpBigDecimalUtils.mul(rose.toString(), "100", 2).toDouble()

        val tvRose=helper?.getView<TextView>(R.id.tv_rose)
        val dfRate = CpNumberUtil().getDecimal(2)
        tvRose?.run {
            if (!StringUtil.isNumeric(rose.toString())) {
                text = "--"
            }else{
                text = if (chg >= 0) "+" + dfRate.format(chg) + "%" else dfRate.format(chg) + "%"
            }
            setTextColor( CpColorUtil.getMainColorType(chg >= 0,!StringUtil.isNumeric(rose.toString())))
        }
        helper.setTextColor(R.id.tv_close_price, ColorUtil.getMainColorType(rose >= 0,!StringUtil.isNumeric(rose.toString())))

        val hasCollect = LikeDataService.getInstance().hasCollect(item.optString("symbol"))
        val isShow = hasCollect && !isSelfData
        helper.setGone(R.id.ic_collect_like,!isShow)
    }
    fun setDiffData(diffCallback: MarketTabDiffCallback) {
        if (emptyLayout!=null &&  emptyLayout?.childCount == 1) {
            setList(diffCallback.getNewData())
            return
        }
        val diffResult = DiffUtil.calculateDiff(diffCallback, true)
        data = diffCallback.getNewData() as ArrayList<JSONObject>
        diffResult.dispatchUpdatesTo(this)
    }
}
