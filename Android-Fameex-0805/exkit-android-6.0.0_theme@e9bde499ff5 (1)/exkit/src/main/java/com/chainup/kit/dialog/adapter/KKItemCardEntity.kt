package com.chainup.kit.dialog.adapter

import com.chad.library.adapter.base.entity.MultiItemEntity

open class KKItemCardEntity(val type:Int,val title:String,val content:String?) : MultiItemEntity {
    var arg:Any? = null

    var isSelect:Boolean = false

    override val itemType: Int
        get() = type


    companion object {
        const val CARD_LAYOUT_TYPE_1 = 1
        const val withdraw_address_type = 2
    }

}
