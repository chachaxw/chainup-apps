package com.chainup.contract.bean

data class LeverMarginInfo(
    val level: String,
    val maxLever: String,
    val maxPositionValue: String,
    val minMarginRate: String,
    val minPositionValue: String
)