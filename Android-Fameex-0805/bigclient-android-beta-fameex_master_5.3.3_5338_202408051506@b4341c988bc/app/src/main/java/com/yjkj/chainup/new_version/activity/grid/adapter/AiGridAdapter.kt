package com.yjkj.chainup.new_version.activity.grid.adapter

import android.Manifest
import android.app.Activity
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.util.Log
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.module.LoadMoreModule
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.chainup.contract.utils.CpPermissionUtil
import com.chainup.contract.utils.CpShareToolUtil
import com.chainup.kit.utils.ToastUtils
import com.chainup.kit.views.KKButtonKit
import com.fengniao.news.util.DateUtil
import com.tbruyelle.rxpermissions2.RxPermissions
import com.yjkj.chainup.R
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.new_version.activity.grid.GridStopStrategyListener
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.util.*
import com.yjkj.chainup.wedegit.GridTextView
import com.yjkj.chainup.wedegit.GridVTextView
import org.json.JSONObject
import java.lang.Exception
import java.util.*

/**
 * @Author lianshangljl
 * @Date 2023/2/3-3:56 PM
 * @Email buptjinlong@163.com
 * @description
 */
class AiGridAdapter(
    data: ArrayList<JSONObject>,
    var listener: GridStopStrategyListener?,
    var isHistory: Boolean
) : BaseQuickAdapter<JSONObject,
        BaseViewHolder>(R.layout.item_grid_adapter, data), LoadMoreModule {
    override fun convert(helper: BaseViewHolder, item: JSONObject) {
        item?.run {
//            helper.setText(R.id.im_check_share, "contract_share_label".tr(context))
//            helper.setText(R.id.termination_network,"quant_stop_strategy".tr(context))
//            helper.setText(R.id.tv_check_details, "quant_view_detail".tr(context))
            var ctime = optString("ctime")
            var symbol = optString("symbol")

            var coinBase = symbol.split("/")[0]
            var coinQuote = symbol.split("/")[1]

            var name = NCoinManager.getMarket4Name((coinBase + coinQuote).toLowerCase())
            var pricePrecision = name.optInt("price")
            var volumePrecision = name.optInt("volume")

            val sum = optString("totalProfitTimes", "0")
            val annualizedYield = optString("annualizedYield", "0")
            val totalProfit = optString("totalProfit", "0")


            val runTime = this.getQuaintTime(context, isHistory)
//            helper.setText(R.id.tv_running_time, LanguageUtil.getString(context, "quant_run_time") + " " + runTime)

            helper?.getView<GridTextView>(R.id.gt_running_time).setContentTextInterval(runTime)
            helper?.getView<GridTextView>(R.id.gt_running_time)
                .setTitleContent("quant_run_time".tr(context))

            var updateTime2 = ""
            var updateTime1 = ""
            if (StringUtil.checkStr(ctime) && BigDecimalUtils.compareTo(ctime, "0") != 0) {
                updateTime1 = DateUtil.longToString("yyyy/MM/dd HH:mm", ctime.toLong())
                updateTime2 = DateUtil.longToString("yyyy/MM/dd HH:mm:ss", ctime.toLong())
            } else {
                ""
            }


            var configParamMap = optJSONObject("configParamMap")

            /*High price range*/
            var highestPrice = configParamMap.optString("highestPrice")
            /*Low price range*/
            var lowestPrice = configParamMap.optString("lowestPrice")
            var gridLineType = configParamMap.optString("gridLineType")
            var totalQuoteAmount = configParamMap.optString("totalQuoteAmount")
            var totalBaseAmount = configParamMap.optString("totalBaseAmount")
            var gridNumber = configParamMap.optString("gridNumber")
            val coin = NCoinManager.getShowMarket(coinQuote)

            val coinTotal = BigDecimalUtils.divForDown(optString("totalProfit"), 6).toPlainString()
            val coinRate = BigDecimalUtils.divForDown(optString("annualizedYield"), 2).toPlainString()

            val coinName = NCoinManager.getShowMarketName(symbol)
            helper?.setText(R.id.tv_symbol, coinName)

            helper?.getView<GridVTextView>(R.id.gt_grid_profits)
                .setTitleContent("${LanguageUtil.getString(context, "quant_grid_profit")}(${coin})")
            helper?.getView<GridVTextView>(R.id.gt_grid_profits).setContentText(coinTotal)

            helper?.getView<GridVTextView>(R.id.gt_annual_earnings).setContentText(coinRate, true)
            helper?.getView<GridVTextView>(R.id.gt_annual_earnings)
                .setTitleContent("grid_annualized_yield".tr(context))

            helper?.getView<GridVTextView>(R.id.gt_position_and).setTitleContent(
                "${
                    LanguageUtil.getString(
                        context,
                        "quant_position_profit"
                    )
                }(${coin})"
            )
            helper?.getView<GridVTextView>(R.id.gt_position_and).setContentText(
                BigDecimalUtils.divForDown(
                    optString("positionProfit"),
                    6
                ).toPlainString()
            )

            helper?.getView<GridTextView>(R.id.gt_price_range).setContentTextInterval(
                "${
                    BigDecimalUtils.divForDown(lowestPrice, pricePrecision).toPlainString()
                }~${BigDecimalUtils.divForDown(highestPrice, pricePrecision)}"
            )
            helper?.getView<GridTextView>(R.id.gt_price_range)
                .setTitleContent("quant_price_section".tr(context))

            helper?.getView<GridTextView>(R.id.gt_network_type)
                .setTitleContent("grid_type".tr(context))
            if (gridLineType == "1") {
                helper?.getView<GridTextView>(R.id.gt_network_type)
                    .setContentTextInterval("quant_grid_line_type1".tr(context))
            } else {
                helper?.getView<GridTextView>(R.id.gt_network_type)
                    .setContentTextInterval("quant_grid_line_type2".tr(context))
            }


            helper?.getView<GridTextView>(R.id.gt_investment_assets)
                .setTitleContent("quant_initial_quote_amount".tr(context))
            if (totalBaseAmount.isNotEmpty()) {
                helper?.getView<GridTextView>(R.id.gt_investment_assets).setContentTextInterval(
                    "${
                        BigDecimalUtils.divForDown(
                            totalQuoteAmount,
                            pricePrecision
                        ).toPlainString()
                    } ${NCoinManager.getShowMarket(coinQuote)}+${
                        BigDecimalUtils.divForDown(
                            totalBaseAmount,
                            volumePrecision
                        ).toPlainString()
                    } ${NCoinManager.getShowMarket(coinBase)}"
                )
            } else {
                helper?.getView<GridTextView>(R.id.gt_investment_assets).setContentTextInterval(
                    "${
                        BigDecimalUtils.divForDown(
                            totalQuoteAmount,
                            pricePrecision
                        )
                    } ${NCoinManager.getShowMarket(coinQuote)}"
                )
            }



            helper?.getView<GridTextView>(R.id.gt_grid_number)
                .setContentTextInterval(BigDecimalUtils.divForDown(gridNumber, 0).toPlainString())
            helper?.getView<GridTextView>(R.id.gt_grid_number)
                .setTitleContent("quant_grid_amount".tr(context))

            helper?.getView<GridTextView>(R.id.gt_entrust_time).setContentTextInterval(updateTime2)
            helper?.getView<GridTextView>(R.id.gt_entrust_time)
                .setTitleContent("quant_entrust_date".tr(context))

            helper?.getView<KKButtonKit>(R.id.tv_check_details).apply {
                this.setOnClickListener {
                    ArouterUtil.navigation(RoutePath.GridExecutionDetailsActivity, Bundle().apply {
                        putString(ParamConstant.GIRD_ID, optString("id"))
                        putString(ParamConstant.GIRD_COIN, coinQuote)
                        putString(ParamConstant.symbol, symbol)
                        putString(ParamConstant.GIRD_COIN_INFO, item.toString())
                    })
                }
                this.textContent="quant_view_detail".tr(context)
            }
            helper?.getView<KKButtonKit>(R.id.termination_network).apply {
                this.setOnClickListener {
                    if (listener != null) {
                        Log.e("jinlong", "listener")
                        listener?.stopStrategy(optString("id"))
                    }
                }
                this.textContent="quant_stop_strategy".tr(context)
            }
            var strategyStatus = optString("strategyStatus")
            when (strategyStatus) {
                "0", "1" -> {
                    helper?.setGone(R.id.termination_network, false)
                    helper?.setGone(R.id.im_check_share, false)
                }

                "2", "3" -> {
                    helper?.setGone(R.id.termination_network, true)
                    helper?.setGone(R.id.im_check_share, false)
                }

                else -> helper?.setGone(R.id.termination_network, false)
            }
            helper.setText(R.id.tv_strategy_status, this.getQuaintStatus(context))
            helper.getView<KKButtonKit>(R.id.im_check_share).apply {
                this.setOnClickListener {
                    NewDialogUtils.webGridShare(
                        context,
                        object : NewDialogUtils.DialogWebViewShareListener {
                            override fun webviewSaveImage(view: View) {

                            }

                    override fun confirmShare(view: View) {
                        val rxPermissions = RxPermissions(context as Activity)
                        /**
                         *Obtain read and write permissions
                         */
                        val observable = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            rxPermissions.request(Manifest.permission.READ_MEDIA_IMAGES)
                        }else{
                            rxPermissions.request(Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.READ_EXTERNAL_STORAGE)
                        }
                        observable.subscribe { granted ->
                            if (granted) {
                                var bitmap = ScreenShotUtil.getScreenshotBitmap(view)
                                if (bitmap != null) {
                                    CpShareToolUtil.sendLocalShare(context, bitmap)
                                }else{
                                    ToastUtils.showToast(context,"bitmap is null!")
                                }
                            }else{
                                try {
                                    val activity = context as? Activity
                                    if(activity!=null){
                                        CpPermissionUtil.showOpenPermission(activity)
                                    }else{
                                        ToastUtils.showToast(context,"warn_storage_permission".tr(context))
                                    }
                                }catch (e:Exception){
                                    e.printStackTrace()
                                }

                            }

                        }
                    }
                }, coinTotal, coinRate, runTime, sum.getGridCount(context), coinName, coin)
            }
        }

    }
    }
}

