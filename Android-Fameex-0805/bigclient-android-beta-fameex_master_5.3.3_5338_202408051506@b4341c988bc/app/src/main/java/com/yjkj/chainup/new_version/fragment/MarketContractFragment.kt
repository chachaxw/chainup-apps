package com.yjkj.chainup.new_version.fragment

import android.os.Bundle
import android.text.TextUtils
import android.view.View
import androidx.fragment.app.Fragment
import androidx.viewpager.widget.ViewPager
import com.chainup.contract.utils.CpClLogicContractSetting
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseFragment
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.manager.CpLanguageUtil
import com.yjkj.chainup.manager.CpLanguageUtil.getString
import com.yjkj.chainup.new_version.adapter.PageAdapter
import com.yjkj.chainup.util.LogUtil
import com.yjkj.chainup.util.setViewPagerFont
import kotlinx.android.synthetic.main.fragment_new_version_market.*
import org.json.JSONArray
import org.json.JSONObject
import java.util.*


/**
 * @Author lianshangljl
 * @Date 2023/3/15-4:10 PM
 * @Email buptjinlong@163.com
 *@description New Version Market Page - Contract
 */
class MarketContractFragment : NBaseFragment() {

    var isScrollPageVp:Boolean = false
    private var isFirst:Boolean = true
    override fun setContentView(): Int {
        return R.layout.fragment_new_version_market
    }
    private var tabList: ArrayList<Map<String, String>> = ArrayList()
    val titles = arrayListOf<String>()
    val symbolsName = arrayListOf<String>()

    var adapterScroll = true
    override fun initView() { }

    override fun loadData() {
        super.loadData()
    }

    override fun onMessageEvent(event: MessageEvent) {
        super.onMessageEvent(event)
        if (MessageEvent.market_switch_type == event.msg_type) {
            var coin = event.msg_content as String
            var marketSort = PublicInfoDataService.getInstance().getMarketSort(null)
            if (null == marketSort || marketSort.length() <= 0)
                return
            for (i in 0 until marketSort.length()) {
                if (coin == marketSort.optString(i)) {
                    vp_market?.currentItem = i + 1
                }
            }
        }
    }

    val fragments = arrayListOf<Fragment>()
    private fun showVP() {
        var mContractObj = CpClLogicContractSetting.getContractJsonListStr(mActivity)
        var isExist=false
        if (TextUtils.isEmpty(mContractObj)){
            return
        }
        var mContractList = JSONArray(mContractObj)
        for (i in 0..(mContractList.length() - 1)) {
            var obj: JSONObject = mContractList.get(i) as JSONObject
            val classification = obj.getString("classification")
            val contractShowType = obj.getString("contractShowType")
            val currentSymbolBuff = (obj.getString("contractType") + "_" + obj.getString("symbol")
                .replace("-", "")).lowercase(
                Locale.getDefault()
            )
            symbolsName.add(currentSymbolBuff)
            val map: MutableMap<String,String> = HashMap<String,String>()

            val name=when(classification){
                "1" ->getString(context, "cp_contract_data_text13")
                "2" ->getString(context, "cp_contract_data_text10")
                "3" ->getString(context, "cp_contract_data_text12")
                "4" ->getString(context, "cp_contract_data_text11")
                else ->""
            }
            map.put("name",name)
            map.put("classification",classification)
            isExist=false
            for (i in 0 until tabList.size) {
                if (tabList[i]["classification"].toString().equals(classification)){
                    isExist=true
                }
                LogUtil.e("---------",tabList[i]["classification"]+"||"+classification+"||"+isExist)
            }
            if (!isExist){
                LogUtil.e("---------++",classification+"||"+isExist)
                tabList.add(map)
            }
            tabList.sortBy { it.get("classification") }
        }

//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
//            tabList = tabList.stream().distinct().collect(Collectors.toList())
//        }
//        for (i in 0 until tabList.size - 1) {
//            for (j in 1 until tabList.size - i) {
//                var a: Map<String?, Any?>
//                val one = tabList[j - 1]["classification"] as Int
//                val tow = tabList[j]["classification"] as Int
//                if (one > tow) {
//                    a = tabList[j - 1]
//                    tabList[j - 1] = tabList[j]
//                    tabList[j] = a
//                }
//            }
//        }
        for (i in tabList.indices) {
            titles.add(tabList[i]["name"].toString())

            var marketTrendFragment = MarketContractTrendFragment()
            var bundle = Bundle()
            bundle.putString("classification", tabList[i]["classification"].toString())
            bundle.putInt("cur_index", i + 1)
            marketTrendFragment.arguments = bundle

            fragments.add(marketTrendFragment)
        }

        vp_market?.adapter = PageAdapter(childFragmentManager, titles, fragments)
        var limitSize = fragments?.size
        vp_market?.offscreenPageLimit = 3

        stl_market_loop?.setViewPagerFont(vp_market, titles.toTypedArray())
        stl_market_loop.visibility = View.VISIBLE

        vp_market?.addOnPageChangeListener(object : ViewPager.OnPageChangeListener {
            override fun onPageScrollStateChanged(p0: Int) {
                isScrollPageVp = false
            }

            override fun onPageScrolled(p0: Int, p1: Float, p2: Int) {
                if(!isFirst){
                    isScrollPageVp = true
                }else{
                    isFirst = false
                }

            }

            override fun onPageSelected(position: Int) {
                viewpagePosotion = position
//                clickTabItem()
            }

        })

//        val rmap = java.util.HashMap<String, Any>()
//        rmap["bind"] = true
//        rmap["symbols"] = CpJsonUtils.gson.toJson(symbolsName)
//        instance.sendMessage(rmap, this)
    }

    var viewpagePosotion = 0

    override fun fragmentVisibile(isVisibleToUser: Boolean) {
        super.fragmentVisibile(isVisibleToUser)
        if(isVisibleToUser && isFirstInflater){
            showVP()
            isFirstInflater = false
        }
    }

    override fun onVisibleChanged(isVisible: Boolean) {
        super.onVisibleChanged(isVisible)
        LogUtil.e(TAG, "onVisibleChanged==NewVersionMarketFragment ${isVisible} ")
    }


}
