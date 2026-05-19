package com.yjkj.chainup.new_version.activity

import android.content.Context
import android.content.Intent
import android.os.Bundle
import androidx.recyclerview.widget.LinearLayoutManager
import android.util.Log
import android.view.View
import com.chainup.kit.views.PublicHeaderKit
import com.yjkj.chainup.R
import com.yjkj.chainup.bean.fund.CashFlowBean
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.net.HttpClient
import com.yjkj.chainup.net.retrofit.NetObserver
import com.yjkj.chainup.new_version.adapter.CashFlow4Adapter
import com.yjkj.chainup.new_version.bean.CashFlowSceneBean
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.view.EmptyForAdapterView
import com.yjkj.chainup.new_version.view.PersonalCenterView
import com.yjkj.chainup.new_version.view.ScreeningPopupWindowView
import com.yjkj.chainup.util.NToastUtil
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.activity_cash_flow4.*


/**
 *@description: Capital Flow (4.0)
 * @author Bertking
 * @Date 2023-5-15 AM
 *
 */

class CashFlow4Activity : NewBaseActivity() {


    var symbolForSelect = ""
    var transactionScene = ""
    var startTime = ""
    var endTime = ""
    var page = 1
    var pageSize = 20
    var adapter: CashFlow4Adapter? = null

    companion object {
        const val TRANSACTIONSCENE = "TRANSACTIONSCENE"
        fun enter2(context: Context, transactionScene: String) {
            val intent = Intent(context, CashFlow4Activity::class.java)
            intent.putExtra(TRANSACTIONSCENE, transactionScene)
            context.startActivity(intent)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_cash_flow4)
        context = this
        statusStr = LanguageUtil.getString(this, "otc_recharge")
        getData()
        if (transactionScene == ParamConstant.TYPE_OTC_TRANSFER) {
            statusStr = LanguageUtil.getString(this, "otc_transfer")
            sceneType = ParamConstant.OTC_TRANSFER_RECORD
            sceneList.add(CashFlowSceneBean.Scene(ParamConstant.OTC_TRANSFER_RECORD, LanguageUtil.getString(this, "transfer_text_otc")))
            spw_layout?.initLineAdaptiveLayout(sceneList)
        } else {
            sceneType = "deposit"
            getCashFlowScene()
        }
        adapter = CashFlow4Adapter(statusStr)
        rv_cash_flow?.adapter = adapter
        adapter?.apply {
            setEmptyView(EmptyForAdapterView(this@CashFlow4Activity))
//            setOnItemClickListener { adapter, view, position ->
//                if (adapter.data.isNotEmpty()) {
//                    val show = adapter.data.get(position) as CashFlowBean.Finance
//                    CashFlowDetailActivity.liveData4CashFlowBean.postValue(show)
////                    CashFlowDetailActivity.enter2(context, sceneType)
//                    CashFlowDetailActivity.enter2(context,transactionScene,statusStr)
//                }
//            }
        }
        swipe_refresh.setOnRefreshListener {
            page = 1
//            adapter?.loadMoreModule?.isEnableLoadMore = false
            getCashFlowList(symbolForSelect, transactionScene, page, startTime, endTime, statusStr,true)
        }
        swipe_refresh.setOnLoadMoreListener {
            getCashFlowList(symbolForSelect, transactionScene, page, startTime, endTime, statusStr,false)
        }
        rv_cash_flow?.layoutManager = LinearLayoutManager(context)
        pcv_title?.setContentTitle(LanguageUtil.getString(this, "assets_action_journalaccount"))
    }

    var isFrist = true
    fun getData() {
        intent ?: return
        transactionScene = intent.getStringExtra(TRANSACTIONSCENE) ?: ""
        pcv_title.listener = object : PublicHeaderKit.IOnBackClickListener {
            override fun onRightBtn(view: View) {
                super.onRightBtn(view)

                if (spw_layout?.visibility == View.GONE) {
                    spw_layout?.visibility = View.VISIBLE
                } else {
                    spw_layout?.visibility = View.GONE
                }
                if (isFrist) {
                    spw_layout?.setMage()
                    isFrist = false
                }
                //这块还没写完，这是新的样式，由于目前没有定稿，等定稿后再做
//                NewDialogUtils.showFlowFliterDialog(this@CashFlow4Activity,sceneList)
            }
        }

        spw_layout?.fundFlowingWaterListenre = object : ScreeningPopupWindowView.OTCFundFlowingWaterListenre {
            override fun returnOTCFundFlowingWater(symbol: String, waterType: String, begin: String, end: String) {
                symbolForSelect = symbol
                page = 1
                transactionScene = waterType
                sceneList.forEach {
                    if (it.key == transactionScene) {
                        statusStr = it.keyText ?: ""
                        sceneType = it.key
                    }
                }
                adapter?.status = statusStr
                getCashFlowList(symbol, transactionScene, page, begin, end, statusStr,true)
            }

        }
    }

    var sceneType = ""


    var statusStr = "充值"

    override fun onResume() {
        super.onResume()
        getCashFlowList(symbolForSelect, transactionScene, page, startTime, endTime, statusStr,true)
    }

    var sceneList: ArrayList<CashFlowSceneBean.Scene> = arrayListOf()

    /**
     *List of scenarios for obtaining fund flow
     */
    private fun getCashFlowScene() {
        if (!UserDataService.getInstance().isLogined) {
            return
        }
        HttpClient.instance.getCashFlowScene()
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<CashFlowSceneBean>() {
                    override fun onHandleSuccess(t: CashFlowSceneBean?) {
                        
                        t ?: return
                        if (t.sceneList.isEmpty()) {
                            return
                        }
                        /**
                         *TODO selection scenario sends corresponding values
                         */
                        sceneList.clear()
                        sceneList.addAll(t.sceneList)
                        spw_layout?.initLineAdaptiveLayout(t.sceneList)
                    }

                    override fun onHandleError(code: Int, msg: String?) {
                        super.onHandleError(code, msg)
                        //DisplayUtil.showSnackBar(window?.decorView, msg, isSuc = false)
                        NToastUtil.showTopToastNet(this@CashFlow4Activity, false, msg)
                        
                    }
                })
    }


    /**
     *Capital flow list
     *@param transactionScene default scene is' recharge '
     */
    private fun getCashFlowList(symbol: String,
                                transactionScene: String,
                                page: Int,
                                startTime: String,
                                endTime: String,
                                status: String = "",
                                refresh: Boolean
    ) {
        if (!UserDataService.getInstance().isLogined) {
            return
        }

        HttpClient.instance.getCashFlowList(
                symbol = NCoinManager.setShowNameGetName(symbol),
                transactionScene = transactionScene,
                startTime = startTime,
                endTime = endTime,
                page = page.toString(), pageSize = pageSize.toString()
        )
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<CashFlowBean>() {
                    override fun onHandleSuccess(t: CashFlowBean?) {
                        
                        initData(refresh, t)
                    }

                    override fun onHandleError(code: Int, msg: String?) {
                        super.onHandleError(code, msg)
                        NToastUtil.showTopToastNet(this@CashFlow4Activity, false, msg)
                        
                        initData(refresh, null)
                    }
                })
    }

    fun initData(isRefresh: Boolean, bean: CashFlowBean?) {
        val list = bean?.financeList
        if (isFinishing || isDestroyed) {
            return
        }
        if (list != null && list.isNotEmpty()) {
            if (isRefresh) {
                adapter?.setList(list)
            } else {
                adapter?.addData(list)
            }
            val isMore = list.size == pageSize
            if (isMore) page++
//            if (!isMore) {
//                swipe_refresh?.finishRefreshWithNoMoreData()
//            }else{
//                swipe_refresh?.finishLoadMore()
//            }
            if(isRefresh){
                swipe_refresh?.finishRefresh(100,true,list.size < 20)
            }else{
                swipe_refresh?.finishLoadMore(100,true,list.size < 20)
            }
//            adapter?.apply {
//                loadMoreModule.let {
//                    it.isEnableLoadMore = true
//                    if (!isMore) {
//                        it.loadMoreEnd(!isMoreRef)
//                    } else {
//                        it.loadMoreComplete()
//                    }
//                }
//            }

        } else {
            if (isRefresh) {
                adapter?.setList(null)
                adapter?.setEmptyView(EmptyForAdapterView(context))
            }
            if(isRefresh){
                swipe_refresh?.finishRefresh(100,true,true)
            }else{
                swipe_refresh?.finishLoadMore(100,true,true)
            }
        }

    }


}
