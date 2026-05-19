package com.yjkj.chainup.bean

data class TartCaptchaV2Bean(
    val geetest:GeetestBean?,
    val cloudflare:CloudflareBean?
)
data class GeetestBean(
    val challenge: String,
    val gt: String,
    val new_captcha: String,
    val success: Int
)
data class CloudflareBean(
    val siteKey: String,
    val domain: String?
)
