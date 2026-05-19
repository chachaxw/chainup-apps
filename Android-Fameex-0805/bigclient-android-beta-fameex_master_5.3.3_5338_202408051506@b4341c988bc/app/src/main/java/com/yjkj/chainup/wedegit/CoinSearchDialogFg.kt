package com.yjkj.chainup.wedegit

import android.graphics.drawable.ColorDrawable
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.LinearLayout
import androidx.databinding.DataBindingUtil
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.lifecycle.Observer
import androidx.viewpager.widget.ViewPager
import com.chainup.contract.eventbus.CpMessageEvent
import com.chainup.contract.eventbus.CpNLiveDataUtil
import com.chainup.contract.utils.CpDisplayUtils
import com.chainup.contract.utils.CpSizeUtils
import com.flyco.tablayout.SlidingTabLayout
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseLeftDialogFragment
import com.yjkj.chainup.databinding.DialogfgCoinSearchBinding
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.TradeTypeEnum
import com.yjkj.chainup.db.service.LikeDataService
import com.yjkj.chainup.extra_service.eventbus.EventBusUtil
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.extra_service.eventbus.NLiveDataUtil
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.LanguageUtil.getString
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.new_version.adapter.PageAdapter
import com.yjkj.chainup.new_version.fragment.NSearchLikeFragment
import com.yjkj.chainup.util.JsonUtils
import com.yjkj.chainup.util.LogUtil
import com.yjkj.chainup.ws.WsAgentManager
import com.yjkj.chainup.ws.WsAgentManager.Companion.instance
import com.yjkj.chainup.ws.WsAgentManager.WsResultCallback
import kotlinx.android.synthetic.main.dialogfg_coin_search.tv_coin_map
import kotlinx.android.synthetic.main.dialogfg_coin_search.vp_market_aa
import kotlinx.android.synthetic.main.fragment_search_coin.et_search
import org.json.JSONObject

/**
 * @Description:
 * @Author: wanghao
 * @CreateDate: 2019-11-01 14:52
 * @UpdateUser: wanghao
 * @UpdateDate 2023-11-01 14:52
 *@ UpdateRemark: Update Description
 */
class CoinSearchDialogFg : NBaseLeftDialogFragment(), WsResultCallback {
    var isblack = false
    var showCoins = hashMapOf<Int, Array<String?>>()
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setStyle(STYLE_NORMAL, com.chainup.contract.R.style.leftContractCoinSearchDialogStyle)
        instance.addWsCallback(this)

    }

    override fun setContentView(): Int {
        return R.layout.dialogfg_coin_search
    }

    override fun initView() {
        val rootView = findViewById<LinearLayout>(R.id.root_view)
        CpDisplayUtils.requestDisplayBar(
            dialog!!.window
        ) { statusBar, navigationBar -> rootView!!.setPadding(0, statusBar, 0, navigationBar) }
        initTab()
        findViewById<View>(R.id.alpha_ll)?.setOnClickListener(this)
        observeData()
        et_search?.setHint(LanguageUtil.getString(context, "assets_action_search"))
        et_search?.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence, start: Int, before: Int, count: Int) {}
            override fun afterTextChanged(s: Editable) {
                var content = ""
                if (null != s) {
                    content = s.toString()
                }
                val msgEvent = CpMessageEvent(CpMessageEvent.coinSearchType)
                msgEvent.msg_content = content
                CpNLiveDataUtil.postValue(msgEvent)
            }
        })
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        super.onCreateView(inflater, container, savedInstanceState)
        var binding:DialogfgCoinSearchBinding = DataBindingUtil.inflate(inflater, R.layout.dialogfg_coin_search, container, false);
        layoutView = binding.root
        loadData()
        binding.isblack = isblack
        return layoutView
    }
    /*
     *Grouping to meet leverage needs
     */
    private var type = 0
    private var currentSymbol: String? = ""
    override fun loadData() {
        val bundle = arguments
        if (null != bundle) {
            type = bundle.getInt(ParamConstant.TYPE)
            currentSymbol = bundle.getString(ParamConstant.COIN_SYMBOL)
            isblack = bundle.getBoolean(ParamConstant.ISBLACK)
        }
    }

    private fun observeData() {
        NLiveDataUtil.observeData(this, Observer { messageEvent ->
            if (MessageEvent.closeLeftCoinSearchType == messageEvent!!.msg_type) {
                dismissDialog()
            }
        })
    }


    private fun initTab() {
        val titles = ArrayList<String>()
        val showTitles = ArrayList<String>()
        val fragments = ArrayList<Fragment>()
        val marketZone = getString(context, "market_text_customZone")
        titles.add(marketZone)
        showTitles.add(marketZone)
        fragments.add(getFg(0, marketZone))
        addCoinList(0, marketZone)
        var titleContent = ""
        var marketTitles: ArrayList<String>? = null
        when (type) {
            TradeTypeEnum.LEVER_TRADE.value -> {
                titleContent = getString(context, "title_lever")
                marketTitles = NCoinManager.getLeverGroup()
            }
            TradeTypeEnum.COIN_TRADE.value -> {
                titleContent = getString(context, "trade_bb_titile")
                marketTitles = NCoinManager.getMarketSortList()
            }
            TradeTypeEnum.GRID_TRADE.value -> {
                titleContent = getString(context, "quant_grid_title")
                marketTitles = NCoinManager.getGridGroup()
            }
        }

        tv_coin_map.text = titleContent

        if (null != marketTitles && marketTitles.size > 0) {
            for (i in marketTitles.indices) {
                val titleName = marketTitles[i]
                val marktName = NCoinManager.getShowMarket(marketTitles[i])
                titles.add(marktName)
                if (TradeTypeEnum.LEVER_TRADE.value == type || TradeTypeEnum.GRID_TRADE.value == type) {
                    showTitles.add(marktName)
                } else {
                    showTitles.add(NCoinManager.getShowMarket(marktName))
                }
                fragments.add(getFg(i + 1, titleName))
                addCoinList(i + 1, titleName)
            }
        }
        val vp_market_aa = findViewById<ViewPager>(R.id.vp_market_aa)
        val marketPageAdapter = PageAdapter(childFragmentManager, titles, fragments)
        val symbolList = LikeDataService.getInstance().symbols
        vp_market_aa?.adapter = marketPageAdapter
        vp_market_aa?.offscreenPageLimit = fragments.size
        val tl_market_aa = findViewById<SlidingTabLayout>(R.id.tl_market_aa)
        val showTitlesArray = arrayOfNulls<String>(showTitles.size)
        for (j in showTitles.indices) {
            showTitlesArray[j] = showTitles[j]
        }
        val title = titles.toArray(arrayOf<String>())
        tl_market_aa?.setViewPager(vp_market_aa, title)
//        if (isblack){
//            tl_market_aa?.textSelectColor = ColorUtil.getColor(R.color.main_blue)
//            tl_market_aa?.textUnselectColor = ColorUtil.getColor(R.color.normal_text_color_kline_night)
//        }else{
//            tl_market_aa?.textSelectColor = ColorUtil.getColor(R.color.main_blue)
//            tl_market_aa?.textUnselectColor = ColorUtil.getColor(R.color.normal_text_color)
//        }

        if (symbolList == null || symbolList.length() <= 0) {
            vp_market_aa?.currentItem = 1
        } else {
            vp_market_aa?.currentItem = 0
        }
        vp_market_aa?.currentItem?.let { sendWs(it) }
        vp_market_aa?.addOnPageChangeListener(object : ViewPager.OnPageChangeListener {
            override fun onPageScrollStateChanged(p0: Int) {

            }

            override fun onPageScrolled(p0: Int, p1: Float, p2: Int) {

            }

            override fun onPageSelected(position: Int) {
                sendWs(position)
            }

        })
    }

    private fun getFg(index: Int, marketName: String): NSearchLikeFragment {
        val fg = NSearchLikeFragment()
        val bundle = Bundle()
        bundle.putInt(ParamConstant.TYPE, type)
        bundle.putInt(ParamConstant.CUR_INDEX, index)
        bundle.putString(ParamConstant.MARKET_NAME, marketName)
        bundle.putBoolean(ParamConstant.ISBLACK, isblack)
        fg.arguments = bundle
        return fg
    }

    override fun dismissDialog() {
        super.dismissDialog()
        LogUtil.d(TAG, "dismissDialog==")
    }

    override fun showDialog(manager: FragmentManager?, tag: String?) {
        super.showDialog(manager, tag)
        EventBusUtil.postSticky(MessageEvent(MessageEvent.collect_data_type))
    }

    override fun onWsMessage(json: String) {
        vp_market_aa?.apply {
            val adapter = adapter as PageAdapter
            val currentFragment = adapter.getItem(vp_market_aa.currentItem)
            if (currentFragment is NSearchLikeFragment) {
                currentFragment.handleData(json)
            }
        }
    }

    companion object {
        private const val TAG = "CoinSearchDialogFg"
    }

    private fun addCoinList(position: Int, marketName: String) {
        val tempArray = arrayListOf<JSONObject>()
        if (position == 0) {
            var localData = LikeDataService.getInstance().getCollecData(TradeTypeEnum.LEVER_TRADE.value == type)
            if (null != localData) {
                if (TradeTypeEnum.GRID_TRADE.value == type) {
                    var listGrid = arrayListOf<JSONObject>()
                    for (temp in localData) {
                        if (temp.optInt("is_grid_open") == 1) {
                            listGrid.add(temp)
                        }
                    }
                    localData.clear()
                    localData.addAll(listGrid)
                }
                tempArray.addAll(localData)
            }
        } else {
            var oriSymbols: ArrayList<JSONObject>? = if (TradeTypeEnum.LEVER_TRADE.value == type) {
                NCoinManager.getLeverGroupList(marketName)
            } else if (TradeTypeEnum.COIN_TRADE.value == type) {
                NCoinManager.getMarketByName(marketName)
            } else {
                NCoinManager.getGridCroupList(marketName)
            }
            if (null != oriSymbols) {
                tempArray.addAll(oriSymbols)
            }
        }
        val arrays = arrayOfNulls<String>(tempArray.size)
        for ((index, item) in tempArray.withIndex()) {
            val itemSymbol = item.getString("symbol")
//            if (currentSymbol != itemSymbol) {
                arrays.set(index, itemSymbol)
//            }
        }
        showCoins.put(position, arrays)


    }

    private fun sendWs(position: Int) {
        if (showCoins.containsKey(position)) {
            val array = showCoins.get(position)
            if (array != null && array.isNotEmpty()) {
                WsAgentManager.instance.sendMessage(hashMapOf("bind" to true, "symbols" to JsonUtils.gson.toJson(showCoins.get(position))), this)
            }
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        WsAgentManager.instance.unbind(this, true)
    }

    override fun onPause() {
        super.onPause()
        WsAgentManager.instance.unbind(this, true)
    }

    override fun onResume() {
        super.onResume()
        vp_market_aa?.currentItem?.let { sendWs(it) }
    }

    override fun onDestroy() {
        super.onDestroy()
    }

    override fun onStart() {
        super.onStart()
        val window = this.dialog!!.window
        //Remove the default padding from the dialog
        //Remove the default padding from the dialog
        window!!.decorView.setPadding(0, 0, 0, 0)
        val lp = window!!.attributes
        lp.width = CpSizeUtils.dp2px(280.0f)
        lp.height = WindowManager.LayoutParams.MATCH_PARENT
        lp.gravity = Gravity.LEFT
        //Animating the dialog
        //Animating the dialog
        lp.windowAnimations = R.style.leftin_rightout_DialogFg_animstyle_buff
        window!!.attributes = lp
        window!!.setBackgroundDrawable(ColorDrawable())
        dialog!!.setCancelable(true)
        dialog!!.setCanceledOnTouchOutside(true)
    }
}
