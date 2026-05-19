package com.yjkj.chainup.new_version.activity.leverage.list

import android.graphics.Typeface
import android.os.Bundle
import android.util.TypedValue
import android.view.View
import android.widget.LinearLayout
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.viewpager.widget.ViewPager
import com.alibaba.android.arouter.facade.annotation.Autowired
import com.alibaba.android.arouter.facade.annotation.Route
 import com.chainup.contract.view.dialog.CpTDialog
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseActivity
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.manager.CpLanguageUtil
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.new_version.adapter.NVPagerAdapter
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.view.HistoryScreeningControl
import com.yjkj.chainup.util.LogUtil
import com.yjkj.chainup.util.ViewUtils
import kotlinx.android.synthetic.main.activity_lever.*
import java.util.*
import kotlin.collections.ArrayList

/**
 * @Author lianshangljl
 * @Date 2023-03-10-16:07
 * @Email buptjinlong@163.com
 * @description
 */
@Route(path = RoutePath.LeverActivity)
class LeverActivity : NBaseActivity() {
    override fun setContentView() = R.layout.activity_lever

    private val fragments = arrayListOf<Fragment>()
    private var titles: ArrayList<String> = arrayListOf()

    @JvmField
    @Autowired(name = ParamConstant.CUR_INDEX)
    var currentItem = ParamConstant.CURRENT_TYPE

    @JvmField
    @Autowired(name = ParamConstant.symbol)
    var orderType = ""

    var coinList = arrayListOf<String>()

    override fun onInit(savedInstanceState: Bundle?) {
        super.onInit(savedInstanceState)
        titles.add(LanguageUtil.getString(this, "leverage_current_borrow"))
        titles.add(LanguageUtil.getString(this, "leverage_history_borrow"))
        rb_current?.text = LanguageUtil.getString(this, "leverage_current_borrow")
        rb_history?.text = LanguageUtil.getString(this, "leverage_history_borrow")

        initView()

    }


    override fun initView() {
        fragments.add(CurrentLeverFragment.newInstance(orderType))
        fragments.add(HistoryLeverFragment.newInstance(orderType))



        iv_back?.setOnClickListener { finish() }

        initTab()

        /**
         *Switch current delegation history delegation
         */
        rg_current_history?.setOnCheckedChangeListener { group, checkedId ->
            when (checkedId) {
                R.id.rb_current -> {
                    currentItem = 0
                    (fragments[0] as CurrentLeverFragment).initData()
                    viewPager?.currentItem = 0
                    changeTab()
                }
                R.id.rb_history -> {


                    currentItem = 1
                    (fragments[1] as HistoryLeverFragment).initData()
                    viewPager?.currentItem = 1
                    changeTab()

                }
            }
        }


    }

    override fun onResume() {
        super.onResume()
        if(isFirstInit) return
        if(fragments.size<=0) return
        val cfragment = fragments[currentItem]
        if(cfragment is CurrentLeverFragment) {
            cfragment.initData()
        }else if(cfragment is HistoryLeverFragment) {
            cfragment.initData()
        }
    }

    /**
     *Load fragment
     */
    private var itemWidth = 0
    private fun initTab() {
        itemWidth = (resources.displayMetrics.widthPixels / 4) - (resources.getDimensionPixelOffset(R.dimen.global_divider_width) * 3)
        val otcHomePageAdapter = NVPagerAdapter(supportFragmentManager, titles, fragments)
        viewPager?.adapter = otcHomePageAdapter
        viewPager?.offscreenPageLimit = 2
        viewPager?.currentItem = currentItem
        viewPager?.setPagingEnabled(true)
        sub_tab_layout.setViewPager(viewPager, arrayOf(LanguageUtil.getString(this,"leverage_current_borrow"), LanguageUtil.getString(this,"leverage_history_borrow")), this, fragments)
        changeTab()
    }

    private fun changeTab() {
        if (currentItem == 0) {
            /**
             *Current delegation
             */
            rb_current?.typeface = Typeface.defaultFromStyle(Typeface.BOLD)
            rb_current?.setTextSize(TypedValue.COMPLEX_UNIT_PX, resources.getDimensionPixelSize(R.dimen.sp_28).toFloat())
            rb_current?.setTextColor(ContextCompat.getColor(this, R.color.text_color))


            /**
             *Historical commission
             */
            rb_history?.typeface = Typeface.defaultFromStyle(Typeface.NORMAL)
            rb_history?.setTextSize(TypedValue.COMPLEX_UNIT_PX, resources.getDimensionPixelSize(R.dimen.sp_16).toFloat())
            rb_history?.setTextColor(ContextCompat.getColor(this, R.color.normal_text_color))
            rg_current_history?.check(R.id.rb_current)
        } else {
            /**
             *Current delegation
             */
            rb_current?.typeface = Typeface.defaultFromStyle(Typeface.NORMAL)
            rb_current?.setTextSize(TypedValue.COMPLEX_UNIT_PX, resources.getDimensionPixelSize(R.dimen.sp_16).toFloat())
            rb_current?.setTextColor(ContextCompat.getColor(this, R.color.normal_text_color))
            /**
             *Historical commission
             */
            rb_history?.typeface = Typeface.defaultFromStyle(Typeface.BOLD)
            rb_history?.setTextSize(TypedValue.COMPLEX_UNIT_PX, resources.getDimensionPixelSize(R.dimen.sp_28).toFloat())
            rb_history?.setTextColor(ContextCompat.getColor(this, R.color.text_color))
            rg_current_history?.check(R.id.rb_history)
        }
    }

}
