package com.yjkj.chainup.freestaking

import android.os.Bundle
import android.view.View
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.alibaba.android.arouter.facade.annotation.Route
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chainup.kit.views.KKEmptyViewKit
import com.google.android.material.appbar.AppBarLayout
import com.jaeger.library.StatusBarUtil
import com.yjkj.chainup.R
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.freestaking.bean.MyPosRecordBean
import com.yjkj.chainup.net.HttpClient
import com.yjkj.chainup.net.retrofit.NetObserver
import com.yjkj.chainup.new_version.activity.NewBaseActivity
import com.yjkj.chainup.new_version.adapter.PositionPosRecordRecyclerAdapter
import com.yjkj.chainup.new_version.adapter.ProtocolPosRecordRecyclerAdapter
import com.yjkj.chainup.new_version.view.PersonalCenterView
import com.yjkj.chainup.new_version.view.ScreeningPopupWindowView
import com.yjkj.chainup.util.DisplayUtil
import com.yjkj.chainup.util.tr
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.activity_cash_flow4.swipe_refresh
import kotlinx.android.synthetic.main.activity_positionpos_record.*

/**
 *My PoS records
 */
@Route(path = RoutePath.PositionRecordActivity)
class PositionRecordActivity : NewBaseActivity() {

    lateinit var protocolAdapter: ProtocolPosRecordRecyclerAdapter
    lateinit var positionAdapter: PositionPosRecordRecyclerAdapter
    lateinit var layoutManager: LinearLayoutManager
    var startTimeNow = ""
    var endNow = ""
    var isScrollstatus = true
    var page = 1
    var projectType = 0
    var symbol = ""
    var pageSize: Int = 20
    var isfrist = true
    var miningTypeList = arrayListOf<String>()
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_positionpos_record)
        StatusBarUtil.setColor(this, ContextCompat.getColor(this,R.color.bg_card_color),0)
        window.navigationBarColor = ContextCompat.getColor(this,R.color.bg_card_color)
        projectType = intent.getIntExtra(PROJECT_TYPE, 0)

        title_layout.listener = object: PersonalCenterView.MyProfileListener{
            override fun onclickHead() {

            }

            override fun onclickRightIcon() {
                if (spw_layout?.visibility == View.VISIBLE) {
                    spw_layout?.visibility = View.GONE
                } else {
                    spw_layout?.visibility = View.VISIBLE
                    if (isfrist) {
                        isfrist = false
                        spw_layout?.setMage()
                    }

                }
            }

            override fun onclickName() {

            }

            override fun onRealNameCertificat() {

            }

        }
        initRefresh()
    }


    override fun onResume() {
        super.onResume()
        getData(true, page, pageSize, projectType, symbol, startTimeNow, endNow)

    }


    private fun initRefresh() {
        spw_layout.posRecordListener = object : ScreeningPopupWindowView.PosRecordListener {
            override fun returnPosRecord(symbol: String, miningType: Int, begin: String, end: String) {
                this@PositionRecordActivity.symbol = symbol
                projectType = miningType
                startTimeNow = begin
                endNow = end
                getData(true, page, pageSize, projectType, symbol, startTimeNow, endNow)

            }


        }

        swipe_refresh?.setOnRefreshListener {
            page = 1
            isScrollstatus = true
            getData(true, page, pageSize, projectType, symbol, startTimeNow, endNow)
        }
        swipe_refresh?.setOnLoadMoreListener {
            page += 1
            getData(false, page, pageSize, projectType, symbol, startTimeNow, endNow)
        }


//        rv_record?.addOnScrollListener(object : RecyclerView.OnScrollListener() {
//
//            var lastVisibleItem = 0
//            override fun onScrolled(recyclerView: RecyclerView, dx: Int, dy: Int) {
//                super.onScrolled(recyclerView, dx, dy)
//
//                layoutManager = recyclerView?.layoutManager as LinearLayoutManager
//                lastVisibleItem = layoutManager.findLastVisibleItemPosition()
//
//            }
//
//            override fun onScrollStateChanged(recyclerView: RecyclerView, newState: Int) {
//                super.onScrollStateChanged(recyclerView, newState)
//                if (newState == RecyclerView.SCROLL_STATE_IDLE && lastVisibleItem == layoutManager.itemCount - 1 && isScrollstatus) {
//
//                }
//            }
//
//        })
    }

    var list: ArrayList<MyPosRecordBean.PosListBean> = arrayListOf()

    fun refreshView(bean: ArrayList<MyPosRecordBean.PosListBean>) {
        list.addAll(bean)
        if (projectType == 1) {
            positionAdapter.notifyDataSetChanged()
        } else if (projectType == 3) {
            protocolAdapter.notifyDataSetChanged()

        }
    }

    fun initView(t: ArrayList<MyPosRecordBean.PosListBean>) {
        if (isFinishing || isDestroyed || t == null) {
            return
        }

        val emptyView = KKEmptyViewKit(this)

        if (rv_record != null) {
            rv_record.layoutManager = LinearLayoutManager(this)
            val divider = DividerItemDecoration(this, DividerItemDecoration.VERTICAL)
            divider.setDrawable(resources.getDrawable(R.drawable.item_decoration_shape))
            rv_record.addItemDecoration(divider)
            if (projectType == 1) {
                positionAdapter = PositionPosRecordRecyclerAdapter(list)
                rv_record.adapter = positionAdapter
//                positionAdapter.bindToRecyclerView(rv_record)
                positionAdapter.setEmptyView(emptyView)
            } else if (projectType == 3) {
                protocolAdapter = ProtocolPosRecordRecyclerAdapter(list)

                protocolAdapter.addChildClickViewIds(R.id.tv_current_income)
                rv_record.adapter = protocolAdapter
//                protocolAdapter.bindToRecyclerView(rv_record)
                protocolAdapter.setEmptyView(emptyView)
                protocolAdapter.setOnItemChildClickListener { adapter, view, position ->
                    when (view?.id) {
                        R.id.tv_current_income -> {
                            var bundle = Bundle()
                            bundle.putParcelableArrayList("userGainList", t[position].userGainList)
                            bundle.putString("baseCoin", t[position].baseCoin)
                            ArouterUtil.greenChannel(RoutePath.IncomeDetailActivity, bundle)
                        }

                    }
                }

            }
//            rv_record.adapter = adapter
//            adapter?.bindToRecyclerView(rv_record)
//            adapter?.setEmptyView(R.layout.ly_empty_withdraw_address)

        }

    }


    fun getData(refresh: Boolean, page: Int, pageSize: Int, projectType: Int, baseCoin: String = "", strTime: String = "", entTime: String = "") {

        HttpClient.instance.getMyPosRecord(page, pageSize, projectType, baseCoin, strTime, entTime)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<MyPosRecordBean>() {
                    override fun onHandleSuccess(t: MyPosRecordBean?) {
                        t ?: return
                        title_layout.title = t.tipMine ?: ""
                        miningTypeList.clear()
                        miningTypeList.add(t.tipLock!!)
                        miningTypeList.add(t.tipNormal!!)
                        spw_layout.initPosRecordLineLayout(t.tipStatus?:"pos_type_staking".tr(this@PositionRecordActivity),miningTypeList)
                        if (t.posList == null) {

                        } else {
                            if (t.posList.size < 20) {
                                isScrollstatus = false
                            }
                            if (refresh) {
                                list.clear()
                                list.addAll(t.posList)
                                initView(list)
                                swipe_refresh?.finishRefresh(100,true,t.posList.size < 20)
                            } else {
                                refreshView(t.posList)
                                swipe_refresh?.finishLoadMore(100,true,t.posList.size < 20)
                            }
                        }

                    }

                    override fun onHandleError(code: Int, msg: String?) {
                        super.onHandleError(code, msg)
                        DisplayUtil.showSnackBar(window?.decorView, msg, isSuc = false)
                        if(refresh){
                            swipe_refresh?.finishRefresh(100,true,true)
                        }else{
                            swipe_refresh?.finishLoadMore(100,true,true)
                        }
                    }

                })
    }

}
