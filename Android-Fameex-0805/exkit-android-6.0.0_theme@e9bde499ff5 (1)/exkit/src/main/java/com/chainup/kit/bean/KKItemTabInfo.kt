package com.chainup.kit.bean

import com.flyco.tablayout.listener.CustomTabEntity

data class KKItemTabInfo(
    var name: String,
    var index:Int? = 0,
    var extras: Any? = null
):CustomTabEntity {
    override fun getTabTitle(): String {
       return name
    }

    override fun getTabSelectedIcon(): Int {
      return 0
    }

    override fun getTabUnselectedIcon(): Int {
        return 0
    }
}
