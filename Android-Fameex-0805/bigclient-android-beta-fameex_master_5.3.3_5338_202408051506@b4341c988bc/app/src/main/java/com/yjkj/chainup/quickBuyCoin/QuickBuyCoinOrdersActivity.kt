package com.yjkj.chainup.quickBuyCoin

import android.os.Bundle
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.yjkj.chainup.R
import com.yjkj.chainup.bean.OTCOrderBean
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.net.HttpClient
import com.yjkj.chainup.net.retrofit.NetObserver
import com.yjkj.chainup.util.DisplayUtil
import com.yjkj.chainup.new_version.view.ScreeningPopupWindowView
import com.yjkj.chainup.new_version.activity.NewBaseActivity
import com.yjkj.chainup.new_version.adapter.NewVersionQuickBuyCoinOrderAdapter
import com.yjkj.chainup.new_version.view.EmptyForAdapterView
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.activity_new_otc_orders.*

/**
 * @Author lianshangljl
 * @Date 2023/4/9-11:34 AM
 * @Email buptjinlong@163.com
 *@description My order
 */
class QuickBuyCoinOrdersActivity : NewBaseActivity() {
    var status = ""
    var adapter: NewVersionQuickBuyCoinOrderAdapter? = null
    var payCoinNow = ""
    var coinSymbolNow = ""
    var orderStatusNow = ""
    var startTimeNow = ""
    var tradingNew = ""
    var endNow = ""

    var isScrollstatus = true

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_new_otc_orders)
//        listener = object : TitleShowListener {
//            override fun TopAndBottom(status: Boolean) {
//                title_layout.slidingShowTitle(status)
//            }
//        }
        initRefresh()
        setTextContent()
    }

    fun setTextContent() {
        title_layout?.setContentTitle(getStringContent("otc_text_myOrder"))
    }

    fun getStringContent(contentId: String): String {
        return LanguageUtil.getString(this, contentId)
    }

    override fun onResume() {
        super.onResume()
        getData(true)

    }

    var page: Int = 1
    var pageSize: Int = 20
    var isfrist = true

    fun initRefresh() {
        spw_layout.otcOrderListener = object : ScreeningPopupWindowView.OTCOrderListener {
            override fun returnScreeningOrderStatus(trading: String, payCoin: String, coinSymbol: String, orderStatus: String, startTime: String, end: String) {
                page = 1
                payCoinNow = payCoin
                coinSymbolNow = coinSymbol
                orderStatusNow = orderStatus
                tradingNew = trading
                startTimeNow = startTime
                endNow = end
                getData(true)
            }

        }
        title_layout?.mIsShowRightBtn=false
//        title_layout?.listener = object : PersonalCenterView.MyProfileListener {
//            override fun onRealNameCertificat() {
//
//            }
//
//            override fun onclickHead() {
//
//            }
//
//            override fun onclickRightIcon() {
//                if (spw_layout?.visibility == View.VISIBLE) {
//                    spw_layout?.visibility = View.GONE
//                } else {
//                    spw_layout?.visibility = View.VISIBLE
//                    if (isfrist) {
//                        isfrist = false
//                        spw_layout?.setMage()
//                    }
//
//                }
//            }
//
//            override fun onclickName() {
//            }
//
//        }

        /**
         *This is the refresh page
         */
        swipe_refresh?.setOnRefreshListener {
            page = 1
            isScrollstatus = true
            getData(true)
        }

        swipe_refresh?.setOnLoadMoreListener {
            page += 1
            getData(false)
        }
//        rv_order_otc?.setOnScrollListener(object : RecyclerView.OnScrollListener() {
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
//                if (newState == RecyclerView.SCROLL_STATE_IDLE && lastVisibleItem + 1 == adapter?.itemCount && isScrollstatus) {
//                    page += 1
//                    getData(false)
//                }
//            }
//
//        })
    }

    var list: ArrayList<OTCOrderBean.Order> = arrayListOf()

    fun refreshView(bean: ArrayList<OTCOrderBean.Order>) {
        list.addAll(bean)
        adapter?.notifyDataSetChanged()
    }

    fun initView(t: ArrayList<OTCOrderBean.Order>) {
        adapter = NewVersionQuickBuyCoinOrderAdapter(list)
        if (rv_order_otc != null) {
            rv_order_otc.layoutManager = LinearLayoutManager(this)
            adapter?.setEmptyView(EmptyForAdapterView(this))
            rv_order_otc.adapter = adapter

        }

    }


    fun getData(refresh: Boolean) {
        if (!UserDataService.getInstance().isLogined) {
            return
        }
        HttpClient.instance.creditCard( pageSize, page)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<OTCOrderBean>() {
                    override fun onHandleSuccess(t: OTCOrderBean?) {
                        t ?: return


                        if (t.orderList.size < 20) {
                            isScrollstatus = false
                        }
                        if (refresh) {
                            list.clear()
                            list = t.orderList
                            initView(list)
                            swipe_refresh?.finishRefresh(100,true,t.orderList.size < 20)
                        } else {
                            refreshView(t.orderList)
                            swipe_refresh?.finishLoadMore(100,true,t.orderList.size < 20)
                        }
                    }

                    override fun onHandleError(code: Int, msg: String?) {
                        super.onHandleError(code, msg)
                        DisplayUtil.showSnackBar(window?.decorView, msg, isSuc = false)
                        if (refresh) {
                            swipe_refresh?.finishRefresh(true)
                        }else{
                            swipe_refresh?.finishLoadMore(true)
                        }
                    }

                })
    }

}
