package com.yjkj.chainup.new_version.bean

import com.google.gson.annotations.SerializedName

/**
 * @Author lianshangljl
 *@ Date 2018/10/23-11:06 AM
 * @Email buptjinlong@163.com
 * @description
 */
data class OTCIMDetailsProblemBean(
        @SerializedName("rqInfo") val rqInfo: RqInfo, //Problem Details Data
        @SerializedName("rqReplyList") val rqReplyList: ArrayList<RqReplyList> = arrayListOf() //Historical messages ->Append problem list
) {
    data class RqInfo(
            @SerializedName("id") val id: Int, //Question ID
            @SerializedName("rqDescribe") val rqDescribe: String = "", //Problem Description
            @SerializedName("rqTypeName") val rqTypeName: String = "", //Problem Type
            @SerializedName("rqStatusName") val rqStatusName: String = "", //Problem Status
            @SerializedName("ctime") val ctime: Long = 0L, //Submission time
            @SerializedName("imageDataStr") val imageDataStr: String = "" //Attachment Information
    )

    data class RqReplyList(
            @SerializedName("id") val id: Int, //Question ID
            @SerializedName("rqId") val rqId: Int, //Question ID being pursued
            @SerializedName("replayContent") val replayContent: String = "", //Questioning content
            @SerializedName("contentType") val contentType: String = "", //1- Text Content 2- Image URL (New)
            @SerializedName("userType") val userType: String = "", //User type: 1- backend user 2- front-end user
            @SerializedName("ctime") val ctime: Long = 0L //Submission time
    )
}
