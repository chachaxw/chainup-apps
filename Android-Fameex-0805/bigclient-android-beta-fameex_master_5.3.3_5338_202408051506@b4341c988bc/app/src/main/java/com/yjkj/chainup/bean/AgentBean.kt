package com.yjkj.chainup.bean


data class AgentBean(
    var activityDesc: String? = "",
    var agentDesc: String? = "",
    var bannerUrl: String? = "",
    var billOneUrl: String? = "",
    var billTwoUrl: String? = "",
    var coAgentDesc: String? = "",
    var faceToFaceUrl: String? = "",
    var languageKey: String? = ""
)

data class AgentInfoBean(
    var scaleReturn: Double? = 0.0,
    var scaleSecond: Double? = 0.0,
//    var scaleSub: Double? = 0.0,
    var countAgent: String? = "",
    var amountTotal: String? = "",
    var roleType: Int,
    var amountYesterday: String? = "",
    var roleName: String? = "",
    var amountBYesterday: String? = ""
)
data class CoAgentInfoBean(
    var scaleInfo: List<ScaleInfoBean>,
    var countAgent: String? = "",
    var amountTotal: String? = "",
    var roleType: Int,
    var amountYesterday: String? = "",
    var roleName: String? = "",
    var amountBYesterday: String? = ""
)
data class ScaleInfoBean(val level:String,val scale:Float)

data class AgentUserBean(
    var uid: String? = "",
    var pid: String? = "",
    var roleId: String? = "",
    var roleName: String? = "",
    var status: String? = ""
)
