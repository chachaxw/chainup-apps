package com.yjkj.chainup.new_version.adapter

import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.lifecycle.Lifecycle
import androidx.viewpager2.adapter.FragmentStateAdapter


//ViewPager2 Rewrite Adapter
class PageAdapter2(
    fragmentManger:FragmentManager,
    mLifecycle: Lifecycle, val titles:ArrayList<String>, val fragments:List<Fragment>) : FragmentStateAdapter(fragmentManger,mLifecycle) {

    companion object{
        val TAG = "PageAdapter2"
    }


    override fun getItemCount(): Int {
        return fragments.size
    }

    override fun createFragment(position: Int): Fragment {
        return fragments.get(position)
    }

}
