package com.yjkj.chainup.bean


import com.google.gson.annotations.SerializedName

/**
 *Bin mode, 1-split. 0 net position
 */
data class ContractMode(
        @SerializedName("is_more_position")
        val isMorePosition: String? = "0" // 1
)
