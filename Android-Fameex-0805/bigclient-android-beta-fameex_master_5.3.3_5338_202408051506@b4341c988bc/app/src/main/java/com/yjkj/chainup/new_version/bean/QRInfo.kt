package com.yjkj.chainup.new_version.bean

import com.google.gson.annotations.SerializedName
import java.io.Serializable

data class QRInfo(
    @SerializedName("ipAddress") val ipAddress: String?, //9
    @SerializedName("equipment") val equipment: String?
): Serializable {


}
