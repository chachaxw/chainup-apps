package com.yjkj.chainup.new_version.activity

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.text.Editable
import android.text.TextUtils
import android.text.TextWatcher
import android.view.inputmethod.InputMethodManager
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.LinearLayoutManager
import com.alibaba.android.arouter.facade.annotation.Autowired
import com.alibaba.android.arouter.facade.annotation.Route
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseActivity
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.service.LikeDataService
import com.yjkj.chainup.db.service.SearchDataService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.LoginManager
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.model.model.MainModel
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_version.activity.like.view.SearchTopView
import com.yjkj.chainup.new_version.adapter.CoinMapAdapter
import com.yjkj.chainup.new_version.home.homeMarketRecommend
import com.yjkj.chainup.new_version.view.EmptyForAdapterView
import com.yjkj.chainup.util.NToastUtil
import kotlinx.android.synthetic.main.activity_coin_map_select.*
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode
import org.json.JSONException
import org.json.JSONObject


/**
 * @Date 2023-5-28
 *@description Search&Add Coin Pairs
 *
 *
 * UI :
 */
@Route(path = RoutePath.CoinMapSelectActivity)
class CoinMapSelectActivity : NBaseActivity() {
    override fun setContentView() = R.layout.activity_coin_map_select

    var markList = ArrayList<JSONObject>()
    var searchHistroylist = ArrayList<JSONObject>()
    var likeList = ArrayList<JSONObject>()

    var adapter: CoinMapAdapter? = null

    @JvmField
    @Autowired(name = ParamConstant.TYPE)
    var type = ""

    @JvmField
    @Autowired(name = ParamConstant.IS_NOTICE)
    var isCross = false

    @JvmField
    @Autowired(name = ParamConstant.CUR_INDEX)
    var actionType = 0

    var isSearch = false

    @JvmField
    @Autowired(name = ParamConstant.SEARCH_COIN_MAP_FOR_LEVER)
    var leverStatus = false

    @JvmField
    @Autowired(name = ParamConstant.SEARCH_COIN_MAP_FOR_LEVER_UNREFRESH)
    var refreshLever = false


    @JvmField
    @Autowired(name = ParamConstant.SEARCH_COIN_MAP_FOR_LEVER_INTO_TRANSFER)
    var intoTransfer = false

    lateinit var searchView: SearchTopView

    override fun onInit(savedInstanceState: Bundle?) {
        super.onInit(savedInstanceState)
        ArouterUtil.inject(this)
        setBgSearchBar()
        window.navigationBarColor = ContextCompat.getColor(this,R.color.bg_search_color)
        isSearch = (type == ParamConstant.SEARCH_COIN_MAP)
        adapter = CoinMapAdapter()
        tv_cancel?.text = LanguageUtil.getString(this, "common_text_btnCancel")
        et_search?.hint = LanguageUtil.getString(this, "assets_action_search")
        adapter?.headerWithEmptyEnable = true
        initOnClickListener()

        if (leverStatus) {
            getBalanceList()
            return
        }
        initViews()

    }

    /**
     *Obtain a list of leveraged accounts
     */
    fun getBalanceList() {
        addDisposable(getMainModel().getBalanceList(object : NDisposableObserver() {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                val json = jsonObject.optJSONObject("data")
                val jsonLeverMap = json?.optJSONObject("leverMap")
                searchHistroylist.clear()
                searchHistroylist.addAll(NCoinManager.getLeverMapList(jsonLeverMap)
                    ?: arrayListOf())
                searchHistroylist.sortBy { it.optInt("sort") }
                markList.clear()
                markList.addAll(searchHistroylist)
                initViews()
            }
        }))
    }


    private fun initOnClickListener() {
        /**
         *Add hidden soft keyboard
         */
        tv_cancel?.setOnClickListener {
            val imm: InputMethodManager = getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
            imm.hideSoftInputFromWindow(et_search.windowToken, 0)
            finish()
        }
    }


    fun initViews() {
        rv_coinmap.layoutManager = LinearLayoutManager(mActivity)
        adapter?.setList(searchHistroylist)
        /**
         *Add Action
         *
         */
        adapter?.addChildClickViewIds(R.id.ib_add)
        /**
         *Jump ->Transaction Details
         */
        adapter?.setOnItemClickListener { adapter, view, position ->

            var obj = adapter.data[position] as JSONObject
            var symbol = obj.optString("symbol")
            if (leverStatus) {
                if (refreshLever) {
                    if (intoTransfer) {
                        ArouterUtil.navigation(RoutePath.NewVersionTransferActivity, Bundle().apply {
                            putString(ParamConstant.TRANSFERSTATUS, ParamConstant.LEVER_INDEX)
                            putString(ParamConstant.TRANSFERSYMBOL, "")
                            putString(ParamConstant.TRANSFERCURRENCY, symbol)
                        })
                    } else {
                        ArouterUtil.navigation(RoutePath.NewVersionBorrowingActivity, Bundle().apply {
                            putString(ParamConstant.symbol, symbol)
                        })
                    }
                } else {
                    val newIntent = Intent()
                    newIntent.putExtra(ParamConstant.symbol, symbol)
                    setResult(Activity.RESULT_OK, newIntent)
                    finish()
                }
            }

        }

        rv_coinmap?.adapter = adapter
        adapter?.setSearch(isSearch)
        adapter?.setLeverStatus(leverStatus)

        /**
         *Listening search edit box
         */
        et_search?.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(s: Editable?) {
                var resultList = getSearchMatchList(s.toString())
                if (TextUtils.isEmpty(s.toString())) {
                    adapter?.setList(searchHistroylist)
                } else {
                    if (null == resultList || resultList.size <= 0) {
                        adapter?.setList(null)
                        adapter?.setEmptyView(EmptyForAdapterView(this@CoinMapSelectActivity))
                    } else {
                        adapter?.setList(resultList)
                    }
                }

            }

            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {
            }

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
            }

        })
    }

    /*
     *Local Search
     */
    private fun getSearchMatchList(input: String?): ArrayList<JSONObject>? {

        if (null == input || input.trim().isEmpty() || markList.size <= 0) {
            return null
        }

        val temp = ArrayList<JSONObject>()
        markList.forEach {
            var name = NCoinManager.showAnoterName(it)
            if (null != name) {
                if (name.contains(input.toUpperCase()) || name.contains(input.toLowerCase()) || name.contains(input)) {
                    temp.add(it)
                }
            }
        }
        return temp

    }


    @Subscribe(threadMode = ThreadMode.MAIN)
    override fun onMessageEvent(event: MessageEvent) {
        super.onMessageEvent(event)
        if (MessageEvent.symbol_switch_type == event.msg_type) {
            finish()
        }
    }


}
