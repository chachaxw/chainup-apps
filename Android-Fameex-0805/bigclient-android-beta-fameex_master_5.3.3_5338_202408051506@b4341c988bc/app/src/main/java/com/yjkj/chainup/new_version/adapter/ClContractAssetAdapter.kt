package com.yjkj.chainup.new_contract.adapter

import android.app.Activity
import android.widget.LinearLayout
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.chainup.contract.utils.CpBigDecimalUtils
import com.chainup.contract.utils.CpClLogicContractSetting
import com.chainup.contract.utils.CpColorUtil
import com.yjkj.chainup.R
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.manager.CpLanguageUtil
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.new_contract.activity.CpCoinDetailActivity
import com.yjkj.chainup.util.BigDecimalUtils
import com.yjkj.chainup.util.Utils
import org.json.JSONObject

class ClContractAssetAdapter(data: ArrayList<JSONObject>) : BaseQuickAdapter<JSONObject, BaseViewHolder>(R.layout.cl_item_contract_asset, data) {

    init {
        addChildClickViewIds(R.id.tv_margin_balance_label)
        addChildClickViewIds(R.id.tv_wallet_balance_label)
        addChildClickViewIds(R.id.tv_unrealized_label)
    }
    override fun convert(helper: BaseViewHolder, item: JSONObject) {
        item.let { it ->
            //币种名称
            helper.setText(R.id.tv_coin_name, it.optString("symbol"))
            helper.setText(R.id.tv_margin_balance_label, CpLanguageUtil.getString(context,"cp_total_balance1"))
            helper.setText(R.id.tv_wallet_balance_label, CpLanguageUtil.getString(context,"cp_wallet_balance1"))
            helper.setText(R.id.tv_account_equity_label, LanguageUtil.getString(context,"contract_assets_account_equity"))
            helper.setText(R.id.tv_unrealized_label, CpLanguageUtil.getString(context,"cp_roi_6"))
            val isShowAssets = UserDataService.getInstance().isShowAssets
            val precision = CpClLogicContractSetting.getContractMarginCoinPrecisionByMarginCoin(context,item.optString("originalCoin"))
            val unRealizedAmount = it.optString("unRealizedAmount")?:"0"
            //账户权益 可用资产
            Utils.assetsHideShow(isShowAssets, helper.getView(R.id.tv_normal_balance),BigDecimalUtils.divForDown(it.optString("canUseAmount"),precision).toPlainString())
            //总资产
            Utils.assetsHideShow(isShowAssets, helper.getView(R.id.tv_margin_balance_value),  BigDecimalUtils.divForDown(it.optString("totalAmount"), precision).toPlainString())
            //未实现盈亏
            val unRealizedAmountValue = BigDecimalUtils.divForDown(unRealizedAmount, precision).toPlainString()
            Utils.assetsHideShow(isShowAssets, helper.getView(R.id.tv_unrealized_value), CpBigDecimalUtils.formatNumberWithLogo(unRealizedAmountValue))
            helper.setTextColor(R.id.tv_unrealized_value,
                CpColorUtil.getMainColorType(CpBigDecimalUtils.compareTo(unRealizedAmount,"0")>0,CpBigDecimalUtils.compareTo(unRealizedAmount,"0")==0))
//            钱包余额
            Utils.assetsHideShow(isShowAssets, helper.getView(R.id.tv_available_value), BigDecimalUtils.divForDown(it.optString("walletBalance"), precision).toPlainString())
            //总资产
//            Utils.assetsHideShow(isShowAssets, helper?.getView(R.id.tv_margin_balance_value), dfDefault.format(MathHelper.round(availableVol, index)))
            //跳转到币种详情
            helper.getView<LinearLayout>(R.id.rl_header_layout).setOnClickListener {
                CpCoinDetailActivity.show(context as Activity, item.optString("originalCoin"),item.optString("symbol"))
            }
        }
    }
}
