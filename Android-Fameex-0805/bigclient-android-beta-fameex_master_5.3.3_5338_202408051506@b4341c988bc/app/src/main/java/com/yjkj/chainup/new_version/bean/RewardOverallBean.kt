package com.yjkj.chainup.new_version.bean

data class RewardOverallBean(
    val coin:String,
    val rewardAmount:String,
    val withdrewAmount:String,
    val unWithdrawAmount:String,
    val unWithdrawUsdtAmount:String
)
data class WithdrawRewardInfoBean(
    val totalWithdrawnUsdt:String,
    val withdrawPendingUsdt:String,
    val leftWithdrawPendingUsdt:String
)
