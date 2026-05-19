package com.yjkj.chainup.new_version.bean

/**{
"rewards": ["7",
"2",
"13",
"4",
"5",
"6",
"7"
],
"rewardDetails": [
{
"reward": "7",
"rewardCoin": "USDT"
},
{
"reward": "2",
"rewardCoin": "USDT"
},
{
"reward": "13",
"rewardCoin": "TRX"
},
{
"reward": "4",
"rewardCoin": "USDT"
}
],
"rewardCoin": "USDT",
"isKyc": 1,
"isTwoCheck": 1,
"seriateSignInNum": 4,
"isSignIn": 0,
"resultType": null
}*/
data class SignInInfoBean(
    val isKyc: Int,
    val isSignIn: Int,
    val isTwoCheck: Int,
    val resultType: Any,
    val rewardCoin: String,
    val rewardDetails: List<RewardDetail>?,
    val rewards: List<String>,
    val seriateSignInNum: Int
){
    data class RewardDetail(
        val reward: String,
        val rewardCoin: String
    )
}

