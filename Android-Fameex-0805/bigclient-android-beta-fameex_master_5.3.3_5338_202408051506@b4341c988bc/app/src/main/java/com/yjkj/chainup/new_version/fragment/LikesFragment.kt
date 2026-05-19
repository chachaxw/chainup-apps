package com.yjkj.chainup.new_version.fragment

import android.os.Bundle
import android.os.Handler
import android.util.Log
import androidx.recyclerview.widget.DefaultItemAnimator
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import android.view.View
import android.widget.LinearLayout
import android.widget.TextView
import androidx.fragment.app.Fragment
import androidx.viewpager.widget.ViewPager
import com.google.gson.Gson
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseFragment
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.service.LikeDataService
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.extra_service.eventbus.EventBusUtil
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.manager.SymbolWsData
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_version.adapter.MarketDetailAdapter
import com.yjkj.chainup.new_version.adapter.PageAdapter
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.home.callback.MarketTabDiffCallback
import com.yjkj.chainup.new_version.home.homeToast
import com.yjkj.chainup.new_version.view.EmptyMarketForAdapterView
import com.yjkj.chainup.util.*
import kotlinx.android.synthetic.main.fragment_likes.*
import org.jetbrains.anko.doAsync
import org.jetbrains.anko.imageResource
import org.json.JSONObject
import java.util.HashMap


/**
 *@description: The self selected page of the market
 * @Date 2023-1- 5
 * @author Bertking
 *
 *PS: Although this fragment is similar to the MarketFragment, it is handled separately
 *1 Improve code readability;
 *2 Improve performance
 */
class LikesFragment : NBaseFragment() {

    var isScrollPageVp:Boolean = false
    private var isFirst:Boolean = true

    override fun setContentView() = R.layout.fragment_likes

    var adapter: MarketDetailAdapter? = null
    private var curIndex = 0
    var isScrollStatus = false
    lateinit var currentFragment:Fragment


    override fun loadData() {
        super.loadData()
        curIndex = arguments?.getInt(CUR_INDEX) ?: 0
    }

    fun setEditIconGone(isGone:Boolean){
        iv_edit.visibility = if(isGone) View.GONE else View.VISIBLE
    }

    override fun initView() {
        if(isFirst){
            val collecData = LikeDataService.getInstance().getCollecData(false)
            val isHasCollect = collecData!=null && collecData.size>0
            if(isHasCollect && isFirstInflater){
                showVP()
                isFirstInflater = false
            }
        }
        iv_edit?.setOnClickListener {
            var bundle = Bundle()
            bundle.putInt(ParamConstant.CUR_TYPE_INDEX, curIndex)
            ArouterUtil.greenChannel(RoutePath.LikeEditActivity, bundle)
        }
    }

    override fun fragmentVisibile(isVisibleToUser: Boolean) {
        super.fragmentVisibile(isVisibleToUser)

        if(isVisibleToUser && isFirstInflater){
            showVP()
            isFirstInflater = false
        }

    }


    val fragments = arrayListOf<Fragment>()
    private fun showVP() {
        var isContract = PublicInfoDataService.getInstance().contractOpen(null)
        fragments.clear()
        val titles = arrayListOf<String>()
        titles.add(LanguageUtil.getString(context, "mainTab_text_transaction"))
        val like = SpotLikesFragment()
        var bundle = Bundle()
        bundle.putInt("cur_index", 0)
        like.arguments = bundle
        fragments.add(like)
        currentFragment=like
        if (isContract) {
            titles.add(LanguageUtil.getString(context, "trade_contract_title"))
            fragments.add(ContractLikesFragment())
            stl_market_type.visibility = View.VISIBLE
        }else{
            stl_market_type.visibility = View.GONE
        }
        rl_stl_market_type.visibility=if (isContract) View.VISIBLE else View.GONE
        vp_market?.adapter = PageAdapter(childFragmentManager, titles, fragments)
        vp_market?.offscreenPageLimit = 3
        stl_market_type?.setViewPagerFont(vp_market, titles.toTypedArray())
        vp_market?.addOnPageChangeListener(object : ViewPager.OnPageChangeListener {
            override fun onPageScrollStateChanged(p0: Int) {
                Log.e(TAG+"vpScroll","vp滚动结束")
                isScrollPageVp = false
            }

            override fun onPageScrolled(p0: Int, p1: Float, p2: Int) {
                Log.e(TAG+"vpScroll","vp正在滚动...")
                if(!isFirst) isScrollPageVp = true else isFirst = false
            }

            override fun onPageSelected(position: Int) {
                currentFragment=fragments[position]
                curIndex=position
            }

        })
    }
    fun startInit() {
        if(this::currentFragment.isInitialized){
            if (currentFragment is SpotLikesFragment){
                (currentFragment as SpotLikesFragment)?.startInit()
            }
        }
    }
    fun handleData(data: String) {
        if(isScrollPageVp) return
        if (currentFragment is SpotLikesFragment){
            (currentFragment as SpotLikesFragment)?.handleData(data)
        }
    }
    fun handleData(items: HashMap<String, JSONObject>) {
        if(isScrollPageVp) return
        if (currentFragment is SpotLikesFragment){
            (currentFragment as SpotLikesFragment)?.handleData(items)
        }
    }
}
