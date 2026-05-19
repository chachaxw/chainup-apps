package com.chainup.kit.dialog.adapter

import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.FragmentStatePagerAdapter

class KKViewPagerAdapter(fm:FragmentManager,val fragments:ArrayList<Fragment>) :  FragmentStatePagerAdapter(fm, BEHAVIOR_SET_USER_VISIBLE_HINT){

    override fun getCount(): Int = fragments.size

    override fun getItem(position: Int): Fragment {
        return fragments[position]
    }

}
