package com.chainup.contract.app


/**
 * @author ZhongWei
 * @time 2020/8/18 17:37
 * @description 合约云业务辅助类
 **/
object ContractCloudAgent {

    /**
     * 合约云是否打开
     */
    var isCloudOpen = false

    /**
     * 划转到合约云子账户
     */
    const val WALLET_TO_CONTRACT = "wallet_to_contract"

    /**
     * 合约云子账户划出
     */
    const val CONTRACT_TO_WALLET = "contract_to_wallet"


}