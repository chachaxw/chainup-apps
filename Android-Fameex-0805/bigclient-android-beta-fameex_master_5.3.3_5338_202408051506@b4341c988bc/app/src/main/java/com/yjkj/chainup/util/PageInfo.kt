package com.yjkj.chainup.util

class PageInfo {
    var page = 1
    fun nextPage() {
        page++
    }

    fun reset() {
        page = 1
    }

    val isFirstPage: Boolean
        get() = page == 1

}