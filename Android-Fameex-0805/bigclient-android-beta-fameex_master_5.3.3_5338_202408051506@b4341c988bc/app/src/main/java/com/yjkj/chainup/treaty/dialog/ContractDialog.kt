package com.yjkj.chainup.treaty.dialog

/**
 * @Author lianshangljl
 * @Date 2023/1/29-8:00 PM
 * @Email buptjinlong@163.com
 * @description
 */

import android.content.Context
import androidx.appcompat.app.AppCompatActivity
import android.view.Gravity
 import com.chainup.contract.view.dialog.CpTDialog
import com.chainup.contract.view.dialog.base.CpBindViewHolder
import com.yjkj.chainup.R


class ContractDialog {
    interface ConfirmListener {
        fun onClick()
    }

    companion object {
        /**
         *Popup of NSF
         * @param context
         * @param title
         *Does @param isShowImage display images
         * @param listener
         */
        private fun showDialog(context: Context,
                               title: String,
                               content: String) {
            CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                    .setLayoutRes(R.layout.item_contract_dialog)
                    .setScreenWidthAspect(context, 0.8f)
                    .setGravity(Gravity.CENTER)
                    .setDimAmount(0.8f)
                    .setCancelableOutside(false)
                    .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                        viewHolder?.setText(R.id.tv_title, title)
                        viewHolder?.setText(R.id.tv_content, content)

                    }
                    .addOnClickListener(R.id.tv_cancel)
                    .setOnViewClickListener { viewHolder, view, tDialog ->
                        when (view.id) {
                            R.id.tv_cancel -> {
                                tDialog.dismiss()
                            }
                        }
                    }
                    .create()
                    .show()
        }

        /**
         *Qiangping Price
         */
        fun showDialog4FlatPricer(context: Context) {
            showDialog(context, context.getString(R.string.contract_text_liqPrice), context.getString(R.string.contract_flat_price_content))
        }


        /**
         *Risk assessment
         */
        fun showDialog4Risk(context: Context) {
            showDialog(context, context.getString(R.string.cost), context.getString(R.string.risk_show_tips))
        }


        /**
         *Cost
         */
        fun showDialog4TheCostOf(context: Context) {
            showDialog(context, context.getString(R.string.cost), context.getString(R.string.contract_cost_content))
        }

        /**
         *Tag Price
         */
        fun showDialog4PriceTag(context: Context) {
            showDialog(context, context.getString(R.string.contract_price_tag), context.getString(R.string.contract_price_tag_content))
        }

        /**
         *Margin
         */
        fun showDialog4Margin(context: Context) {
            showDialog(context, context.getString(R.string.contract_margin), context.getString(R.string.contract_margin_content))
        }


        /**
         *Price
         */
        fun showDialog4ThePrice(context: Context) {
            showDialog(context, context.getString(R.string.contract_price_title), context.getString(R.string.index_mark_price))
        }

        /**
         *Account balance
         */
        fun showDialog4AccountBalance(context: Context) {
            showDialog(context, context.getString(R.string.contract_wallet_balance_title), context.getString(R.string.contract_wallet_balance_content))
        }

        /**
         *Market closing
         */
        fun showDialog4MarketPrice(context: Context) {
            showDialog(context, context.getString(R.string.contract_action_marketPrice), context.getString(R.string.contract_market_content))
        }

        /**
         *Account equity
         */
        fun showDialog4AccountRights(context: Context) {
            showDialog(context, context.getString(R.string.contract_assets_account_equity), context.getString(R.string.contracnt_margin_balance_content))
        }

        /**
         *Available balance
         */
        fun showDialog4AvailableBalance(context: Context) {
            showDialog(context, context.getString(R.string.withdraw_text_available), context.getString(R.string.contract_available_balance_content))
        }

        /**
         *Unrealized gains and losses
         */
        fun showDialog4UnrealisedPNL(context: Context) {
            showDialog(context, context.getString(R.string.contract_unrealised_pnl_title), context.getString(R.string.contract_unrealised_pnl_content))
        }

        /**
         *Position margin
         */
        fun showDialog4PositionMarginL(context: Context) {
            showDialog(context, context.getString(R.string.contract_text_positionMargin), context.getString(R.string.contract_position_margin_content))
        }

        /**
         *Entrusted deposit
         */
        fun showDialog4OrderMargin(context: Context) {
            showDialog(context, context.getString(R.string.contract_text_orderMargin), context.getString(R.string.contract_order_margin_content))
        }


    }
}
