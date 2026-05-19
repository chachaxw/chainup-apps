package com.yjkj.chainup.new_version.bean

data class InviteConfig(
    val config: Config,
    val inviteCode: String,
    val inviteQECode: String,
    val inviteRewardUsdtSum: String,
    val inviteUrl: String,
    val inviteUserDirectCount: Int,
    val inviteUserSubOneCount: Int,
    val inviteUserSubTwoCount: Int,
    val topReferrerRewardAmount: String
)

data class Config(
    val appBannerImg: String,
    val brokerId: Int,
    val ctime: Long,
    val faceToFaceImg: String,
    val headingText: String,
    val id: Int,
    val invitationRuleUrl: String,
    val langKey: String,
    val mtime: Long,
    val `operator`: Int,
    val pcHeaderIndexImg: String,
    val posterOneImg: String,
    val posterTwoImg: String,
    val subheadingText: String
)


data class InvitationsList(
    val invitationList: List<MyInvitationsListBean>,
    val rewardList: List<MyInvitationsListBean>,
)
data class MyInvitationsListBean(
    val config: String,
    val inviteCode: String,
    val inviteUrl: String,
    val levelOneInvitationAccount: String,
    val levelOneInvitationUid: String,
    val levelStr: String,
    val levelZeroRegisterAccount: String,
    val levelZeroRegisterUid: String,
    val registerTime: String,
    val conversionAmount: String,
    val rewardAmount: Double,
    val rewardCoin: Any,
    val rewardUid: Int,
    val sendTime: Long,
    val userAccountNum: String
)

data class MyInvitationRewardsListBean(
    val conversionAmount: Double,
    val rewardAmount: Double,
    val rewardCoin: Any,
    val rewardUid: Int,
    val sendTime: Long,
    val userAccountNum: String
)