package com.chainup.contract.ui.fragment

import android.view.View
import com.chainup.contract.R
import com.chainup.contract.base.CpNBaseFragment
import kotlinx.android.synthetic.main.cp_fragment_ordertype_tip_layout.*

class CpOrderTypeTipFragment(val content:String,val title:String?=null) : CpNBaseFragment() {

    override fun initView() {
        tv_tip_content.text = content
        tv_tip_title.text = title
        tv_tip_title.visibility = if(title==null) View.GONE else View.VISIBLE
    }

    override fun setContentView(): Int {
        return R.layout.cp_fragment_ordertype_tip_layout
    }
}
