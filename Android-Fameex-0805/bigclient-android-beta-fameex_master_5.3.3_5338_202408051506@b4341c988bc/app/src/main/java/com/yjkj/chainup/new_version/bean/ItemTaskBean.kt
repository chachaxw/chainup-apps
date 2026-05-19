package com.yjkj.chainup.new_version.bean

data class ItemTaskBean(
    val banner: String,
    val finishedAmount: String,
    val id: Int,
    val logo: String,
    val nightLogo:String,
    val period: Int,
    val remindTime: Long,
    val rewardAmount: String,
    val rewardCoin: String,
    val rewardType: Int,
    val status: Int,
    val statusSortValue: Int,
    val targetCoin: String,
    val targetValue: String,
    val taskCategory: Int,
    val taskCycles: Int,
    val taskName: String,
    val taskType: Int,
    val taskInfo:String
)