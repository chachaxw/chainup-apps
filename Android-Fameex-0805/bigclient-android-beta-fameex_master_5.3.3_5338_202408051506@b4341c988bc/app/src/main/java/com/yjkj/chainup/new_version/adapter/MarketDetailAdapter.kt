package com.yjkj.chainup.new_version.adapter

import android.text.TextUtils
import android.view.View
import android.widget.RelativeLayout
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.DiffUtil
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.chainup.contract.utils.CpClLogicContractSetting
import com.chainup.contract.utils.CpNumberUtil
import com.chainup.kit.utils.AutofitHelper
import com.chainup.kit.utils.ToastUtils
import com.coorchice.library.SuperTextView
import com.yjkj.chainup.R
import com.yjkj.chainup.db.service.LikeDataService
import com.yjkj.chainup.extra_service.eventbus.EventBusUtil
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.manager.RateManager
import com.yjkj.chainup.new_version.dialog.DialogUtil
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.home.callback.MarketTabDiffCallback
import com.yjkj.chainup.new_version.view.CustomTagView
import com.yjkj.chainup.util.BigDecimalUtils
import com.yjkj.chainup.util.ColorUtil
import com.yjkj.chainup.util.DecimalUtil
import com.yjkj.chainup.util.setGoneV3
import com.yjkj.chainup.util.*
import org.jetbrains.anko.doAsync
import org.jetbrains.anko.runOnUiThread
import org.json.JSONObject
import java.util.ArrayList

/**
 * @Author: Bertking
 * @Date 2023/12/10-2:55 PM
 * @Description:
 */

class MarketDetailAdapter : BaseQuickAdapter<JSONObject, BaseViewHolder>(R.layout.item_market_detail_new) {


    val TAG = MarketDetailAdapter::class.java.simpleName
    var isMarketLike = false
    var isMarketSort = false
    var isSel = false
    var selPos = -1
    override fun convert(helper: BaseViewHolder, item: JSONObject) {

        if (null == data || data.size <= 0)
            return

        if (null == item)
            return
        var name = NCoinManager.showAnoterName(item)
        var newcoinFlag = item.optInt("newcoinFlag")
        var vol = item.optString("vol", "")
        var close = item.optString("close", "")
        var price = item.optInt("price", 0)
        var rose = item.optString("rose", "")
        var rateResult = item.optString("rateResult")
        if (TextUtils.isEmpty(rateResult)) {
            try {
                var split = item.optString("name").split("/")
                rateResult = RateManager.getCNYByCoinName(split[1], close)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
        if (!name.contains("/")!!) {
            return
        }

        val split = name.split("/")

        helper?.setText(R.id.tv_coin_name, split[0])
        helper?.setText(R.id.tv_market_name, "/" + split[1])
        vol=BigDecimalUtils.showSNormal(vol,item.optInt("volume"))
        val tempVol = BigDecimalUtils.showDepthVolumeTx(vol)
//        val tempVol = CpNumberUtil().formatNumber(vol,2)
        if (TextUtils.isEmpty(vol)) {
            helper?.setText(R.id.tv_volume, LanguageUtil.getString(context,"common_text_dayVolume") + " --")
        } else {
            helper?.setText(R.id.tv_volume, LanguageUtil.getString(context,"common_text_dayVolume") + " " + tempVol)
        }

        /**
         *Closing price
         */
        if (TextUtils.isEmpty(close)) {
            helper?.setText(R.id.tv_close_price, "--")
            helper.setGoneV3(R.id.tv_close_price_rmb, false)
        } else {
            helper?.setText(R.id.tv_close_price, DecimalUtil.cutValueByPrecision(close, price))
            helper.setGoneV3(R.id.tv_close_price_rmb, true)
            /**
             *Exchange rate conversion results of closing price
             */
            helper?.setText(R.id.tv_close_price_rmb, rateResult + "")
        }
        var tagCoin = NCoinManager.getMarketShowCoinName(item?.optString("name"))
        if (!TextUtils.isEmpty(NCoinManager.getCoinTag4CoinName(tagCoin))) {
            helper?.getView<CustomTagView>(R.id.ctv_content)?.setTextViewContent(NCoinManager.getCoinTag4CoinName(tagCoin))
            helper?.apply {
                setGoneV3(R.id.ctv_content, true)
            }
        } else {
            helper?.apply {
                setGoneV3(R.id.ctv_content, false)
            }
        }
        val hasCollect = LikeDataService.getInstance().hasCollect(item?.optString("symbol"))
        if (!isMarketLike){
            helper.setGone(R.id.img_market_collect,!hasCollect)
        }else{
            helper.setGone(R.id.img_market_collect,true)
        }

        /**
         *Increase
         */
        RateManager.getRoseText(helper.getView<SuperTextView>(R.id.tv_rose), rose)


        val tvRose=  helper?.getView<SuperTextView>(R.id.tv_rose)

        tvRose?.solid = ColorUtil.getMainColorV2Type(context, isRise = RateManager.getRoseTrend(rose))
//        AutofitHelper.create(tvRose);

        if (selPos==helper?.adapterPosition){
            helper?.setBackgroundColor(R.id.layout_marker_item,if (isSel) ContextCompat.getColor(context, R.color.card_bg_color_2) else 0)
        }else{
            helper?.setBackgroundColor(R.id.layout_marker_item,0)
        }

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

    fun modifySelBg(selPos: Int,isSel:Boolean) {
        this.selPos=selPos
        this.isSel=isSel
        notifyItemChanged(selPos)
    }
}

