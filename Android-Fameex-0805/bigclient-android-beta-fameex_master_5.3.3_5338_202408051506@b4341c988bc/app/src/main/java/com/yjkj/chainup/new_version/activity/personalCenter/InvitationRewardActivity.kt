package com.yjkj.chainup.new_version.activity.personalCenter

import android.graphics.Typeface
import android.os.Bundle
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.core.content.ContextCompat
import androidx.viewpager.widget.ViewPager
import android.view.Gravity
import android.view.View
import com.alibaba.android.arouter.facade.annotation.Autowired
import com.alibaba.android.arouter.facade.annotation.Route
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseActivity
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.new_version.adapter.NVPagerAdapter
import kotlinx.android.synthetic.main.activity_invitation_reward.*

/**
 * @Author lianshangljl
 * @Date 2023-08-28-14:55
 * @Email buptjinlong@163.com
 * @description
 */
@Route(path = RoutePath.InvitationRewardActivity)
class InvitationRewardActivity : NBaseActivity() {

    override fun setContentView() = R.layout.activity_invitation_reward

    @JvmField
    @Autowired(name = ParamConstant.TYPE)
    var statusType = ParamConstant.MY_INVITATION

    override fun onInit(savedInstanceState: Bundle?) {
        super.onInit(savedInstanceState)
        v_header?.setContentTitle(LanguageUtil.getString(this, "referral_inviteRewards_title"))
        ArouterUtil.inject(this)
        initView()
    }

    private var fragmentList = arrayListOf<Fragment>()

    private var titles = ArrayList<String>()

    override fun initView() {
        titles?.add(LanguageUtil.getString(this, "referral_inviteRewards_invitation"))
        titles?.add(LanguageUtil.getString(this, "referral_inviteRewards_reward"))

        fragmentList.add(InvitationRewardDetailsFragment.newInstance(ParamConstant.MY_INVITATION))
        fragmentList.add(InvitationRewardDetailsFragment.newInstance(ParamConstant.INVITE_REWARDS))
        initTab()
        stl_invitation_loop?.setViewPager(vp_invitation, titles?.toTypedArray())
        if (statusType == ParamConstant.INVITE_REWARDS) {
            vp_invitation?.currentItem = 1
        }
        vp_invitation.setPagingEnabled(true)
    }

    fun initTab() {
        val invitationPageAdapter = NVPagerAdapter(supportFragmentManager, titles, fragmentList)
        vp_invitation?.adapter = invitationPageAdapter
        vp_invitation?.offscreenPageLimit = 2
        vp_invitation?.addOnPageChangeListener(object : ViewPager.OnPageChangeListener {
            override fun onPageScrollStateChanged(p0: Int) {

            }

            override fun onPageScrolled(p0: Int, p1: Float, p2: Int) {

            }

            override fun onPageSelected(p0: Int) {

                for (num in 0 until fragmentList.size) {
                    if (fragmentList[num] is InvitationRewardDetailsFragment) {
                        if (p0 == 0) {
                            (fragmentList[num] as InvitationRewardDetailsFragment).setChangeItem(ParamConstant.MY_INVITATION)
                        } else {
                            (fragmentList[num] as InvitationRewardDetailsFragment).setChangeItem(ParamConstant.INVITE_REWARDS)
                        }

                    }
                }
            }
        })
    }

}
