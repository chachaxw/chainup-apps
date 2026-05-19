package com.yjkj.chainup.new_version.adapter

import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.fengniao.news.util.DateUtil
import com.yjkj.chainup.R
import com.yjkj.chainup.treaty.bean.ContractCashFlowBean
import com.yjkj.chainup.util.BigDecimalUtils

/**
 * @Author lianshangljl
 * @Date 2023/6/21-4:05 PM
 * @Email buptjinlong@163.com
 * @description
 */
class NewVersionContracBillAdapter(var datas: ArrayList<ContractCashFlowBean.Transactions>) : BaseQuickAdapter<ContractCashFlowBean.Transactions,
        BaseViewHolder>(R.layout.item_contract_bill, datas) {


    override fun convert(helper: BaseViewHolder, item: ContractCashFlowBean.Transactions) {

        helper?.setText(R.id.tv_normal_title,"charge_text_date")
        helper?.setText(R.id.tv_lock_title,"journalAccount_text_amount")
        helper?.setText(R.id.tv_lock,"journalAccount_text_contract")
        helper?.setText(R.id.tv_equivalent,"journalAccount_text_contractBalance")

        /**
         *Scenario Type
         */
        helper?.setText(R.id.tv_coin_name, item?.sceneStr)
        /**
         *Amount
         */
        helper?.setText(R.id.tv_lock_balance, BigDecimalUtils.showSNormal(item?.amountStr.toString()) + " BTC")

        /**
         *Date
         */
        helper?.setText(R.id.tv_normal_balance, DateUtil.longToString("yyyy-MM-dd HH:mm:ss", item?.ctimeL
                ?: 0))


        /**
         *Contract
         */
        helper?.setText(R.id.tv_lock_right_content, item?.address)
        /**
         *Account balance
         */
        helper?.setText(R.id.tv_equivalent_content, BigDecimalUtils.showSNormal(item?.accountBalance.toString()))

    }


}
