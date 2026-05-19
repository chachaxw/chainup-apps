package com.yjkj.chainup.new_version.activity.leverage

import android.app.Activity
import android.content.Intent
import android.graphics.Typeface
import android.os.Bundle
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import android.view.Gravity
import android.view.View
import com.alibaba.android.arouter.facade.annotation.Route
import com.chainup.kit.views.KKEmptyViewKit
import com.chainup.kit.views.PublicHeaderKit
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseActivity
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.net_new.JSONUtil
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_version.adapter.LeverRecordAdapter
import com.yjkj.chainup.new_version.view.EmptyForAdapterView
import com.yjkj.chainup.new_version.view.ScreeningPopupWindowView
import kotlinx.android.synthetic.main.activity_lever_record.*
import kotlinx.android.synthetic.main.activity_withdraw_record.swipe_refresh
import org.json.JSONObject

/**
 * @Author lianshangljl
 * @Date 2023-11-15-00:48
 * @Email buptjinlong@163.com
 *@description Leveraged Funds Flow Page
 */
@Route(path = RoutePath.LeverDrawRecordActivity)
class LeverDrawRecordActivity : NBaseActivity() {

    override fun setContentView() = R.layout.activity_lever_record


    var symbol = ""
    val list = arrayListOf<JSONObject>()
    var adapter = LeverRecordAdapter(list)

    var page = 1
    var isScrollStatus = true
    override fun onInit(savedInstanceState: Bundle?) {
        super.onInit(savedInstanceState)
        initView()
    }

    var refreshData = ParamConstant.THE_CURRENT_LENDING

    override fun initView() {
//        setSupportActionBar(toolbar)
//        toolbar?.setNavigationOnClickListener {
//            finish()
//        }

//        collapsing_toolbar?.run {
//            setCollapsedTitleTextColor(ContextCompat.getColor(mActivity, R.color.text_color))
//            collapsing_toolbar?.setExpandedTitleColor(ContextCompat.getColor(mActivity, R.color.text_color))
//            collapsing_toolbar?.setExpandedTitleTypeface(Typeface.DEFAULT_BOLD)
//            collapsing_toolbar?.expandedTitleGravity = Gravity.BOTTOM
//        }
        ly_appbar?.setContentTitle(LanguageUtil.getString(this,"assets_action_journalaccount"))
        refreshData4Sevive(true)
        ly_appbar?.listener=object : PublicHeaderKit.IOnBackClickListener {
            override fun onRightBtn(view: View) {
                super.onRightBtn(view)
                if (spw_layout?.visibility == View.GONE) {
                    spw_layout?.visibility = View.VISIBLE
                }
            }
        }
        spw_layout?.leverAssetCashFlowListener = object : ScreeningPopupWindowView.LeverAssetCashFlowScreeningListener {
            override fun onclickSymbolSelect() {
                ArouterUtil.navigation4Result(RoutePath.CoinMapSelectActivity, Bundle().apply {
                    putBoolean(ParamConstant.SEARCH_COIN_MAP_FOR_LEVER, true)
                }, mActivity, ParamConstant.BORROW_TYPE)
            }

            override fun confirmLeverAssetCashFlowScreening(leverSymbol: String, leverAssetCashFlowType: Int) {
                symbol = leverSymbol
                refreshData = leverAssetCashFlowType
                page = 1
                isScrollStatus = true
                adapter?.status = refreshData
                refreshData4Sevive(true)
            }
        }

        rv_history_loan?.layoutManager = LinearLayoutManager(mActivity)

        adapter.setEmptyView(KKEmptyViewKit(this ))
        when (refreshData) {
            ParamConstant.THE_CURRENT_LENDING -> {
                adapter?.status = ParamConstant.CURRENT_TYPE
            }
            ParamConstant.APPLY_FOR_LOAN -> {
                adapter?.status = ParamConstant.HISTORY_TYPE
            }
            ParamConstant.RETURN_THE_BORROWING -> {
                adapter?.status = ParamConstant.TRANSFER_TYPE
            }
        }
        rv_history_loan?.adapter = adapter


        /**
         *This is the refresh page
         */
        swipe_refresh?.setOnRefreshListener {
            page = 1
            isScrollStatus = true
            refreshData4Sevive(true)
        }
        swipe_refresh?.setOnLoadMoreListener {
            page += 1
            refreshData4Sevive(false)
        }
//        rv_history_loan?.setOnScrollListener(object : RecyclerView.OnScrollListener() {
//
//            var lastVisibleItem = 0
//            override fun onScrolled(recyclerView: RecyclerView, dx: Int, dy: Int) {
//                super.onScrolled(recyclerView, dx, dy)
//
//                var layoutManager: LinearLayoutManager = recyclerView?.layoutManager as LinearLayoutManager
//                lastVisibleItem = layoutManager.findLastVisibleItemPosition()
//
//            }
//
//            override fun onScrollStateChanged(recyclerView: RecyclerView, newState: Int) {
//                super.onScrollStateChanged(recyclerView, newState)
//                if (newState == RecyclerView.SCROLL_STATE_IDLE && lastVisibleItem + 1 == adapter?.itemCount && isScrollStatus) {
//                    page += 1
//                    refreshData4Sevive(false)
//                }
//            }
//
//        })
    }

    fun refreshData4Sevive(status: Boolean) {
        when (refreshData) {
            ParamConstant.THE_CURRENT_LENDING -> {
                getCurrent(status)
            }
            ParamConstant.APPLY_FOR_LOAN -> {
                getHistory(status)
            }
            ParamConstant.RETURN_THE_BORROWING -> {
                getTransferList(status)
            }
        }

    }


    /**
     *Historical lending
     */
    private fun getHistory(refresh: Boolean) {

        addDisposable(getMainModel().borrowHistory(symbol = symbol, startTime = "", endTime = "",
                consumer = object : NDisposableObserver() {
                    override fun onResponseSuccess(jsonObject: JSONObject) {
                        if (refresh) {
                            list.clear()
                        }
                        jsonObject.optJSONObject("data").run {
                            val orderJsonArray = optJSONArray("financeList")
                            var jsonList = JSONUtil.arrayToList(orderJsonArray)
                            if (null != jsonList && jsonList.size != 0) {
                                list?.addAll(jsonList)
                                if (jsonList.size < 20) {
                                    isScrollStatus = false
                                }
                            } else {
                                isScrollStatus = false
                            }

                            adapter.setList(list)
                            if(refresh){
                                swipe_refresh?.finishRefresh(100,true,null == jsonList ||jsonList.size < 20)
                            }else{
                                swipe_refresh?.finishLoadMore(100,true,null == jsonList ||jsonList.size < 20)
                            }
                        }
                    }

                    override fun onResponseFailure(code: Int, msg: String?) {
                        super.onResponseFailure(code, msg)
                        if(refresh){
                            swipe_refresh?.finishRefresh(false)
                        }else{
                            swipe_refresh?.finishLoadMore(false)
                        }
                    }
                }, page = page.toString()))
    }

    /**
     *Obtain current loan
     */
    private fun getCurrent(refresh: Boolean) {
        addDisposable(getMainModel().borrowNew(symbol,
                consumer = object : NDisposableObserver() {
                    override fun onResponseSuccess(jsonObject: JSONObject) {
                        if (refresh) {
                            list.clear()

                        }
                        jsonObject.optJSONObject("data").run {
                            val orderJsonArray = optJSONArray("financeList")
                            var jsonList = JSONUtil.arrayToList(orderJsonArray)
                            if (null != jsonList && jsonList.size != 0) {
                                list?.addAll(jsonList)
                                if (jsonList.size < 20) {
                                    isScrollStatus = false
                                }
                            } else {
                                isScrollStatus = false
                            }

                            adapter.setList(list)
                            if(refresh){
                                swipe_refresh?.finishRefresh(100,true,null == jsonList ||jsonList.size < 20)
                            }else{
                                swipe_refresh?.finishLoadMore(100,true,null == jsonList ||jsonList.size < 20)
                            }
                        }
                    }

                    override fun onResponseFailure(code: Int, msg: String?) {
                        super.onResponseFailure(code, msg)
                        if(refresh){
                            swipe_refresh?.finishRefresh(false)
                        }else{
                            swipe_refresh?.finishLoadMore(false)
                        }
                    }
                }, page = page.toString()))
    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (resultCode == Activity.RESULT_OK) {
            when (requestCode) {
                /**Currency*/
                ParamConstant.BORROW_TYPE -> {
                    symbol = data?.getStringExtra(ParamConstant.symbol) ?: ""
                    spw_layout?.setLever4AssetCashFlowSymbol(symbol)
                }

            }
        }
    }

    var transactionType = ""

    /**
     *Transfer Record
     */
    private fun getTransferList(refresh: Boolean) {
        addDisposable(getMainModel().getTransferList(symbol, transactionType, "", page.toString(), consumer = object : NDisposableObserver() {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                if (refresh) {
                    list.clear()
                }
                val json = jsonObject.optJSONObject("data")
                json?.optJSONArray("financeList").run {
                    val jsonlist = JSONUtil.arrayToList(this)
                    if (null != jsonlist && jsonlist.size != 0) {
                        list?.addAll(jsonlist)
                        if (jsonlist.size < 20) {
                            isScrollStatus = false
                        }
                    } else {
                        isScrollStatus = false
                    }
                    adapter.setList(list)
                    if(refresh){
                        swipe_refresh?.finishRefresh(100,true,null == jsonlist ||jsonlist.size < 20)
                    }else{
                        swipe_refresh?.finishLoadMore(100,true,null == jsonlist ||jsonlist.size < 20)
                    }
                }
            }

            override fun onResponseFailure(code: Int, msg: String?) {
                super.onResponseFailure(code, msg)
                if(refresh){
                    swipe_refresh?.finishRefresh(false)
                }else{
                    swipe_refresh?.finishLoadMore(false)
                }
            }
        }))
    }

}
