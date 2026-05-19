package com.yjkj.chainup.new_version.fragment

import android.os.Bundle
import android.text.TextUtils
import android.util.Log
import android.view.View
import androidx.fragment.app.Fragment
import androidx.lifecycle.Observer
import androidx.viewpager.widget.ViewPager
import com.chainup.contract.eventbus.CpMessageEvent
import com.chainup.contract.utils.CpClLogicContractSetting
import com.chainup.contract.utils.CpJsonUtils
import com.chainup.contract.ws.CpWsContractAgentManager
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseFragment
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.service.LikeDataService
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.extra_service.eventbus.EventBusUtil
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.extra_service.eventbus.NLiveDataUtil
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.new_version.activity.NewMainActivity
import com.yjkj.chainup.new_version.adapter.PageAdapter
import com.yjkj.chainup.new_version.home.NetworkDataService
import com.yjkj.chainup.new_version.home.homeMarketContract
import com.yjkj.chainup.new_version.home.homeMarketEdit
import com.yjkj.chainup.new_version.home.sendWsHomepage
import com.yjkj.chainup.util.*
import com.yjkj.chainup.ws.WsAgentManager
import kotlinx.android.synthetic.main.fragment_cvctrade.*
import kotlinx.android.synthetic.main.fragment_likes.*
import kotlinx.android.synthetic.main.fragment_market_type.*
import kotlinx.android.synthetic.main.fragment_market_type.iv_edit
import kotlinx.android.synthetic.main.fragment_market_type.stl_market_type
import kotlinx.android.synthetic.main.fragment_market_type.vp_market
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import org.json.JSONArray
import org.json.JSONObject
import java.util.*
import kotlin.collections.ArrayList


/**
 * @Author lianshangljl
 * @Date 2023/3/15-4:10 PM
 * @Email buptjinlong@163.com
 *@description New version market page
 */
class MarketFragment : NBaseFragment(), WsAgentManager.WsResultCallback,CpWsContractAgentManager.WsResultCallback {


    override fun setContentView(): Int {
        return R.layout.fragment_market_type
    }

    var adapterScroll = true
    var adapterReq = false
    var isContract =false;
    override fun initView() {
        /**
         *Search
         */
//        val hint = PublicInfoDataService.getInstance().contractOpen(null).getSearchHint(mActivity)
        et_search?.hint = LanguageUtil.getString(context,"market_search_ex")
        et_search?.setOnClickListener {
            ArouterUtil.greenChannel(RoutePath.CoinMapActivity, Bundle().apply {
                putString("type", ParamConstant.ADD_COIN_MAP)
                if(vp_market.currentItem==2){
                    putInt("position",1)
                }
            })
        }

        NLiveDataUtil.observeData(this, Observer<MessageEvent> {
            if (null != it) {
                if (MessageEvent.home_event_page_market_type == it.msg_type) {
                    LogUtil.v(TAG, "MessageEvent 处理market ${it}")
                    if (fragments.size == 0) {
                        showVP()
                    }
                }
            }
        })

        iv_edit?.setOnClickListener {
            ArouterUtil.greenChannel(RoutePath.LikeEditActivity, Bundle())
        }
        showVP()
        WsAgentManager.instance.addWsCallback(this)
        CpWsContractAgentManager.instance.addWsCallback(this)
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
        } else if (MessageEvent.market_event_page_symbol_type == event.msg_type) {
            val mainActivity = activity
            if (mainActivity is NewMainActivity) {
                if (mainActivity.curPosition != 1) {
                    return
                }
            }
            val map = event.msg_content as HashMap<String, Array<String>>
            val curIndex = map.get("curIndex") as Int
            if (viewpagePosotion != curIndex) {
                return
            }
            val bind = map.get("bind") as Boolean
            if (bind) {
                initReq()
                wsNetworkChange(viewpagePosotion)
                WsAgentManager.instance.sendMessage(hashMapOf("bind" to bind, "symbols" to JsonUtils.gson.toJson(map.get("symbols"))), this)
            }
        }
    }

    val fragments = arrayListOf<Fragment>()
    private fun showVP() {
        isContract = PublicInfoDataService.getInstance().contractOpen(null)
        fragments.clear()
        val titles = arrayListOf<String>()

        titles.add(LanguageUtil.getString(context, "market_text_customZone"))
        titles.add(LanguageUtil.getString(context, "mainTab_text_transaction"))
        val like = LikesFragment()
        var bundle = Bundle()
        bundle.putInt("cur_index", 0)
        like.arguments = bundle
        fragments.add(like)
        fragments.add(NewVersionMarketFragment())
        if (isContract) {
            titles.add(LanguageUtil.getString(context, "trade_contract_title"))
            fragments.add(MarketContractFragment())
        }
        var collecData = LikeDataService.getInstance().getCollecData(false)
        vp_market?.adapter = PageAdapter(childFragmentManager, titles, fragments)
        vp_market?.offscreenPageLimit = 2
        /**
         *When there is no data in the selection, the default market is the first one
         *Otherwise - optional
         */
        if (null == collecData || collecData.size <= 0) {
            viewpagePosotion = 1
        } else {
            viewpagePosotion = 0
        }

        stl_market_type?.setViewPagerFont(vp_market, titles.toTypedArray())
        stl_market_type.visibility = View.VISIBLE
        vp_market?.addOnPageChangeListener(object : ViewPager.OnPageChangeListener {
            override fun onPageScrollStateChanged(p0: Int) {

            }

            override fun onPageScrolled(p0: Int, p1: Float, p2: Int) {

            }

            override fun onPageSelected(position: Int) {
                viewpagePosotion = position
                clickTabItem()
            }

        })
        vp_market?.currentItem = viewpagePosotion
    }

    var viewpagePosotion = 0


    override fun fragmentVisibile(isVisibleToUser: Boolean) {
        super.fragmentVisibile(isVisibleToUser)
        sendWS(isVisibleToUser&&isCanShowing)
        if (isVisibleToUser&&isCanShowing) {
            SubContractWs()
        } else {
            CpWsContractAgentManager.instance.unbind(this, true)
        }
    }


    private fun SubContractWs() {

        if (isContract) {
            homeMarketContract(requireActivity(),stl_market_type.getTitleView(2))
            val symbolsName = arrayListOf<String>()
            var mContractObj = CpClLogicContractSetting.getContractJsonListStr(mActivity)
            if (!TextUtils.isEmpty(mContractObj)){
                var mContractList = JSONArray(mContractObj)
                for (i in 0..(mContractList.length() - 1)) {
                    var obj: JSONObject = mContractList.get(i) as JSONObject
                    val currentSymbolBuff = (obj.getString("contractType") + "_" + obj.getString("symbol")
                        .replace("-", "")).lowercase(
                        Locale.getDefault()
                    )
                    symbolsName.add(currentSymbolBuff)
                }
                val rmap = java.util.HashMap<String, Any>()
                rmap["bind"] = true
                rmap["symbols"] = CpJsonUtils.gson.toJson(symbolsName)
                CpWsContractAgentManager.instance.sendMessage(rmap,this)
            }
        }
    }

    private fun sendWS(isVisibleToUser: Boolean) {
        var mainActivity = activity
        if (mainActivity is NewMainActivity) {
            if (fragments.size <= viewpagePosotion) return
            if (isVisibleToUser) {
                clickTabItem()
            } else {
                WsAgentManager.instance.unbind(this, true)
            }
        }
    }

    private var repJson = ""
    override fun onWsMessage(json: String) {

        if (json.contains("review")) {
            repJson = json
            LogUtil.d(TAG, "onWsMessage==jsonObject review is $json")
            val count = fragments.size - 1
            for (index in 0..count) {
                val temp = fragments[index]
                if (temp is NewVersionMarketFragment) {
                    temp.handleData(json)
                }
                if (temp is LikesFragment) {
                    temp.handleData(json)
                }
            }
        } else {
            val dataDiff = callDataDiff(JSONObject(json))
            if (dataDiff != null) {
                val items = dataDiff.second
                LogUtil.d(TAG, "onWsMessage==jsonObject tick is ${items.size}")
                var fragment = fragments[viewpagePosotion]
                if (fragment is NewVersionMarketFragment) {
                    fragment.handleData(items)
                } else if (fragment is LikesFragment) {
                    fragment.handleData(items)
                }
                wsArrayTempList.clear()
                wsArrayMap.clear()
            }

        }

    }

    private fun clickTabItem() {
        if (fragments.size == 0) {
            return
        }
        if (!isContract){
            iv_edit?.visibility = (viewpagePosotion == 0).getVisibleIN()
        }
        var fragment = fragments[viewpagePosotion]
        if (fragment is NewVersionMarketFragment) {
            fragment.clickTabItem()
        } else if (fragment is LikesFragment) {
            fragment.startInit()
//            homeMarketEdit(mActivity, iv_edit)
        } else if (fragment is MarketContractFragment) {
            WsAgentManager.instance.unbind(this, true)
        }
    }

    var isSending = false

    private fun wsNetworkChange(currentItem: Int = 0) {
        if(isSending){
            return
        }
        GlobalScope.launch {
            isSending = true
            LogUtil.e(TAG, "行情页面网络统计 start ws状态 " + WsAgentManager.instance.isConnection())
            delay(3000L)
            val marketCoins = marketCoins()
            val isResult = marketCoins.isNotEmpty()
            val isCurrent = currentItem == viewpagePosotion && mIsVisibleToUser
            val time = WsAgentManager.instance.pageSubWsTime(this@MarketFragment)
            LogUtil.e(TAG, "行情页面网络统计 end ws状态 " + WsAgentManager.instance.isConnection() + " ${marketCoins.size} k线数据 ${isResult} " + " time ${time} isCurrent ${isCurrent}")
            val statusType = marketCoins.getKlineByType(WsAgentManager.instance.pageSubWs(this@MarketFragment))
            sendWsHomepage(isCurrent, statusType, NetworkDataService.KEY_PAGE_MARKET, NetworkDataService.KEY_SUB_MARKET_BATCH, time)
            isSending = false
        }
    }

    private fun marketCoins(): ArrayList<Any> {
        if (fragments.size == 0) {
            return arrayListOf()
        }
        val lists = arrayListOf<Any>()
        val fragment = fragments[viewpagePosotion]
        if (fragment is NewVersionMarketFragment) {
            val marketCoin = fragment.getCoins()
            if (marketCoin != null) {
                lists.addAll(marketCoin)
            }
        } else if (fragment is LikesFragment) {
//            lists.addAll(fragment.getCoins())
        }
        return lists
    }

    private fun initReq() {
        if (repJson.isNotEmpty() && !adapterReq) {
            adapterReq = true
        }
    }

    private fun marketCoinsTime(): Long {
        if (fragments.size == 0) {
            return 0
        }
        val fragment = fragments[viewpagePosotion]
        if (fragment is NewVersionMarketFragment) {
            val marketCoin = fragment.getCoins()
            if (marketCoin != null) {
                return 0
            }
        } else if (fragment is LikesFragment) {
            return 0
        }
        return 0
    }

    private val wsArrayTempList: ArrayList<JSONObject> = arrayListOf()
    private val wsArrayMap = hashMapOf<String, JSONObject>()
    private var wsTimeFirst: Long = 0L

    @Synchronized
    private fun callDataDiff(jsonObject: JSONObject): Pair<ArrayList<JSONObject>, HashMap<String, JSONObject>>? {
        if (System.currentTimeMillis() - wsTimeFirst >= 2000L && wsTimeFirst != 0L) {
            //Greater than one second
            wsTimeFirst = 0L
            if (wsArrayMap.size != 0) {
                return Pair(wsArrayTempList, wsArrayMap)
            }
        } else {
            if (wsTimeFirst == 0L) {
                wsTimeFirst = System.currentTimeMillis()
            }
            wsArrayTempList.add(jsonObject)
            wsArrayMap.put(jsonObject.optString("channel", ""), jsonObject)
        }
        return null
    }

    override fun onCpWsMessage(json: String) {
        LogUtil.e(TAG, "合约行情： ${json} ")
//        val jsonObject = JSONObject(json)
        if(isContract){
            val fg = fragments.get(0) as LikesFragment
            val fg2 = fragments.get(2) as MarketContractFragment
            if(fg.isScrollPageVp || fg2.isScrollPageVp){
                return
            }
        }
        val messageEvent = MessageEvent(CpMessageEvent.sl_contract_market_event)
        messageEvent.msg_content = json
        EventBusUtil.post(messageEvent)
    }
}
