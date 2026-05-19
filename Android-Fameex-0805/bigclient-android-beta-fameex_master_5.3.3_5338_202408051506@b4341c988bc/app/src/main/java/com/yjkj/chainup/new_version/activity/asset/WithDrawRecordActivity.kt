package com.yjkj.chainup.new_version.activity.asset

import android.content.Context
import android.content.Intent
import com.chainup.contract.utils.CpV2DateUtil
import android.os.Bundle
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import android.text.TextUtils
import android.view.Gravity
import android.view.View
import androidx.core.content.ContextCompat
import com.chainup.kit.views.PublicHeaderKit
import com.yjkj.chainup.R
import com.yjkj.chainup.bean.fund.CashFlowBean
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.net.HttpClient
import com.yjkj.chainup.net.retrofit.NetObserver
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_version.activity.CashFlowDetailActivity
import com.yjkj.chainup.new_version.activity.CoinActivity
import com.yjkj.chainup.new_version.activity.CoinActivity.Companion.SELECTED_TYPE
import com.yjkj.chainup.new_version.activity.NewBaseActivity
import com.yjkj.chainup.new_version.adapter.Cash4ContractAdapter
import com.yjkj.chainup.new_version.adapter.CashFlow4Adapter
import com.yjkj.chainup.new_version.adapter.CashFlowAdapter
import com.yjkj.chainup.new_version.bean.CashFlowSceneBean
import com.yjkj.chainup.new_version.view.*
import com.yjkj.chainup.treaty.bean.ContractCashFlowBean
import com.yjkj.chainup.util.DisplayUtil
import com.yjkj.chainup.util.ToastUtils
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.activity_new_version_transfer.*
import kotlinx.android.synthetic.main.activity_withdraw_record.*
import kotlinx.android.synthetic.main.activity_withdraw_record.title_layout
import kotlinx.android.synthetic.main.item_screening_popup_window.view.cub_confirm
import org.json.JSONObject
import java.util.Calendar

import com.scwang.smart.refresh.layout.api.RefreshLayout
import com.scwang.smart.refresh.layout.listener.OnRefreshListener

/**
 * @Author lianshangljl
 * @Date 2023/5/17-12:02 PM
 * @Email buptjinlong@163.com
 *@description Various records
 */
class WithDrawRecordActivity : NewBaseActivity() {
    var selectedCoin: String = ""
    var symbol: String = ""
    var transactionScene: String = ""
    var startTime: String = ""
    var endTime: String = ""
    var adapter: CashFlowAdapter? = null
    var adapter4Deposit: CashFlow4Adapter? = null
    var adapter4Contract: Cash4ContractAdapter? = null
    var adapterContract: CashFlowAdapter? = null
    var page: Int = 1
    var isScrollstatus = true
    var isContract = false
    var recordType = 0

    companion object {
        const val RECORDTYPE = "RecordType"
        const val CONTRACTTYPE = "contractType"


        /**
         *@param selectedCoin Selected Currency
         *@param transactionScene recharge, withdrawal, transfer type key
         *@param type recharge, withdrawal, and transfer records
         */
        fun enter2(context: Context, selectedCoin: String, transactionScene: String, type: Int, symbol: String = "") {
            var intent = Intent()
            intent.setClass(context, WithDrawRecordActivity::class.java)
            intent.putExtra(CoinActivity.SELECTED_COIN, selectedCoin)
            intent.putExtra(SELECTED_TYPE, transactionScene)
            intent.putExtra(ParamConstant.symbol, symbol)
            intent.putExtra(CONTRACTTYPE, false)
            intent.putExtra(RECORDTYPE, type)
            context.startActivity(intent)
        }

        fun enter4Contract(context: Context, selectedCoin: String) {
            var intent = Intent()
            intent.setClass(context, WithDrawRecordActivity::class.java)
            intent.putExtra(CoinActivity.SELECTED_COIN, selectedCoin)
            intent.putExtra(SELECTED_TYPE, "TRANSFER")
            intent.putExtra(CONTRACTTYPE, true)
            intent.putExtra(RECORDTYPE, TRANSFER)
            context.startActivity(intent)
        }

        fun enterContractTransfer(context: Context, selectedCoin: String) {
            var intent = Intent()
            intent.setClass(context, WithDrawRecordActivity::class.java)
            intent.putExtra(CoinActivity.SELECTED_COIN, selectedCoin)
            intent.putExtra(SELECTED_TYPE, ParamConstant.CONTRACT_TRANSFER_RECORD)
            intent.putExtra(CONTRACTTYPE, true)
            intent.putExtra(RECORDTYPE, CONTRACT_TRANSFER_HISTORY)
            context.startActivity(intent)
        }

    }

    var isfrist = true

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_withdraw_record)
        setBgFill2()
        title_layout?.listener = object : PublicHeaderKit.IOnBackClickListener{
            override fun onRightBtn(view: View) {
                super.onRightBtn(view)
                if (spw_layout?.visibility == View.VISIBLE) {
                    spw_layout?.visibility = View.GONE
                } else {
                    spw_layout?.cub_confirm?.isEnable(true)
                    spw_layout?.visibility = View.VISIBLE
                    if (isfrist) {
                        isfrist = false
//                        spw_layout?.setMage()
                    }
                }
            }
        }

        tv_number_title?.text = LanguageUtil.getString(this, "charge_text_volume")
        getData()
        initRecordView()
        initRefresh()
    }

    fun getData() {
        if (intent != null) {
            selectedCoin = intent.getStringExtra(CoinActivity.SELECTED_COIN) ?: ""
            isContract = intent.getBooleanExtra(CONTRACTTYPE, false)
            transactionScene = intent.getStringExtra(SELECTED_TYPE) ?: ""
            symbol = intent.getStringExtra(ParamConstant.symbol) ?: ""
            recordType = intent.getIntExtra(RECORDTYPE, 0)
            if (TextUtils.isEmpty(symbol)) {
                symbol = selectedCoin
            }
        }
    }

    fun initRecordView() {
        when (recordType) {
            /**
             *Recharge Record
             */
            ASSETTOPUP -> {
                title_layout?.setContentTitle(LanguageUtil.getString(this, "charge_action_chargeHistory"))
//                title_layout?.setRightVisible(false)
                title_layout?.mIsShowRightBtn = true
                spw_layout?.setInitView(ASSETTOPUP)
                tv_number_title?.text = LanguageUtil.getString(context, "charge_text_volume")
                spw_layout?.assetTopUpListener = object : ScreeningPopupWindowView.AssetTopUpListener {
                    override fun returnAssetTopUpTime(startTime: String, end: String) {
                        this@WithDrawRecordActivity.startTime=startTime
                        this@WithDrawRecordActivity.endTime=end
                        getOtherRecord(symbol, ParamConstant.TRANSFER_DEPOSIT_RECORD, startTime, end, true)
                        spw_layout?.visibility = View.GONE
                    }
                }
            }
            /**
             *Cash withdrawal records
             */
            WITHDRAWTYPE -> {
                spw_layout?.setInitView(WITHDRAWTYPE)
//                collapsing_toolbar?.title = NCoinManager.getShowMarket(selectedCoin) + " " + LanguageUtil.getString(context, "withdraw_action_withdrawHistory")
                title_layout?.setContentTitle(LanguageUtil.getString(this, "withdraw_action_withdrawHistory"))
//                title_layout?.setRightVisible(false)
                title_layout?.mIsShowRightBtn = true
                tv_number_title?.text = LanguageUtil.getString(context, "charge_text_volume")
                spw_layout?.widthDrawListener = object : ScreeningPopupWindowView.WithDrawListener {
                    override fun returnWithDrawTime(startTime: String, end: String, type: Int) {
                        this@WithDrawRecordActivity.startTime=startTime
                        this@WithDrawRecordActivity.endTime=end
                        withdrawTypeMain = type
                        getOtherRecord(symbol, ParamConstant.TRANSFER_WITHDRAW_RECORD, startTime, end, true)
                        spw_layout?.visibility = View.GONE
                    }
                }
            }
            /**
             *Transfer Record
             */
            TRANSFER -> {
                title_layout?.setContentTitle(NCoinManager.getShowMarket(selectedCoin) + " " + LanguageUtil.getString(context, "transfer_text_record"))
                tv_number_title?.text = LanguageUtil.getString(context, "charge_text_volume")
                if (isContract) {
//                    title_layout?.setRightVisible(false)
                    title_layout?.mIsShowRightBtn = true
                } else {
                    spw_layout?.setInitView(TRANSFER)
                    spw_layout?.setShowTransfer(true)
                    spw_layout?.transferListener = object : ScreeningPopupWindowView.TransferListener {
                        override fun returnTransfer(transferType: Int, begin: String, end: String) {
                            this@WithDrawRecordActivity.startTime=begin
                            this@WithDrawRecordActivity.endTime=end
                            transferTypeMain = transferType
                            getOtherRecord(symbol, ParamConstant.OTC_TRANSFER_RECORD, begin, end, true)
                            spw_layout?.visibility = View.GONE
                        }
                    }
                }
            }
            /**
             *Contract transfer
             */
            CONTRACT_TRANSFER_HISTORY -> {
                title_layout?.setContentTitle(NCoinManager.getShowMarket(selectedCoin) + " " + LanguageUtil.getString(context, "transfer_text_record"))
                tv_number_title?.text = LanguageUtil.getString(context, "charge_text_volume")
                spw_layout?.setInitView(CONTRACT_TRANSFER_HISTORY)
                spw_layout?.setShowTransfer(true)
                spw_layout?.transferListener = object : ScreeningPopupWindowView.TransferListener {
                    override fun returnTransfer(transferType: Int, begin: String, end: String) {
                        this@WithDrawRecordActivity.startTime=begin
                        this@WithDrawRecordActivity.endTime=end
                        transferTypeMain = transferType
                        getOtherRecord(selectedCoin, ParamConstant.CONTRACT_TRANSFER_RECORD, begin, end, true)
                        spw_layout?.visibility = View.GONE
                    }
                }
            }

            /**
             *Transfer records
             */
            TRANSFER_RECORD -> {
                title_layout?.setContentTitle(LanguageUtil.getString(context, "transfer_records_internal"))
                tv_number_title?.text = LanguageUtil.getString(context, "charge_text_volume")
                spw_layout?.setInitView(TRANSFER)
                spw_layout?.setShowTransfer(true)
                spw_layout?.transferListener = object : ScreeningPopupWindowView.TransferListener {
                    override fun returnTransfer(transferType: Int, begin: String, end: String) {
                        this@WithDrawRecordActivity.startTime=begin
                        this@WithDrawRecordActivity.endTime=end
                        transferTypeMain = transferType
                        getOtherRecord(symbol, ParamConstant.DIRECTLY_WITHDRAW_TYPE, begin, end, true)
                        spw_layout?.visibility = View.GONE
                    }
                }


            }
        }
    }

    var transferTypeMain = 0
    var withdrawTypeMain = 0

    override fun onResume() {
        super.onResume()
        if (recordType == TRANSFER && isContract) {
            getBusinessTransferList(startTime, endTime, true)
        } else {
            getOtherRecord(symbol, transactionScene, startTime, endTime, true)
        }
    }

    fun initRefresh() {
        spw_layout?.assetTopUpListener = object : ScreeningPopupWindowView.AssetTopUpListener {

            override fun returnAssetTopUpTime(startTime: String, end: String) {
                endTime = end
                this@WithDrawRecordActivity.startTime = startTime
                page = 1

                if (recordType == TRANSFER && isContract) {
                    getBusinessTransferList(startTime, end, true)
                } else {
                    getOtherRecord(symbol, transactionScene, startTime, end, true)
                }

            }


        }

        /**
         *This is the refresh page
         */
        swipe_refresh?.setOnRefreshListener(object : OnRefreshListener {
            override fun onRefresh(refreshLayout: RefreshLayout) {
                page = 1
                isScrollstatus = true
                getOtherRecord(symbol, transactionScene, startTime, endTime, true)
            }
        })

        swipe_refresh?.setOnLoadMoreListener {

            page += 1
            if (recordType == TRANSFER && isContract) {
                getBusinessTransferList(startTime, endTime, false)
            } else {
                getOtherRecord(symbol, transactionScene, startTime, endTime, false)
            }
        }


//        recycler_view?.setOnScrollListener(object : RecyclerView.OnScrollListener() {
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
//                    if (recordType == TRANSFER && isContract) {
//                        getBusinessTransferList(startTime, endTime, false)
//                    } else {
//                        getOtherRecord(symbol, transactionScene, startTime, endTime, false)
//                    }
//
//                }
//            }
//
//        })
    }

    var list: ArrayList<CashFlowBean.Finance> = arrayListOf()
    var contractList: ArrayList<ContractCashFlowBean.Transactions> = arrayListOf()

    fun refreshView(bean: ArrayList<CashFlowBean.Finance>) {
        if (bean.isEmpty()) {
            return
        }
        list.addAll(bean)
        adapter?.notifyDataSetChanged()
        adapter4Deposit?.notifyDataSetChanged()
    }

    fun refreshView4Contract(contractList: ArrayList<ContractCashFlowBean.Transactions>) {
        if (contractList.isEmpty()) {
            return
        }
        contractList.addAll(contractList)
        adapter4Contract?.notifyDataSetChanged()
    }


    fun initView4Contract() {
        if (recycler_view != null) {
            recycler_view.layoutManager = LinearLayoutManager(this@WithDrawRecordActivity)
            adapter4Contract = Cash4ContractAdapter(contractList)
            adapter4Contract?.setEmptyView(EmptyForAdapterView(this))
            recycler_view.adapter = adapter4Contract
        }
    }

    fun initView() {
        if (recycler_view != null) {
            recycler_view.layoutManager = LinearLayoutManager(this@WithDrawRecordActivity)
            when (recordType) {
                /**
                 *Recharge Record
                 */
                ASSETTOPUP -> {
                    adapter4Deposit = CashFlow4Adapter(LanguageUtil.getString(this, "assets_action_chargeCoin"))
                    adapter4Deposit?.setEmptyView(EmptyForAdapterView(this))
                    recycler_view.adapter = adapter4Deposit
                    adapter4Deposit?.setOnItemClickListener { adapter, view, position ->
                        CashFlowDetailActivity.liveData4CashFlowBean.postValue(list[position])
                        CashFlowDetailActivity.enter2(this@WithDrawRecordActivity, ParamConstant.TRANSFER_DEPOSIT_RECORD)
                    }
                    adapter4Deposit?.setList(list)
                }
                /**
                 *Cash withdrawal records
                 */
                WITHDRAWTYPE -> {
                    adapter4Deposit = CashFlow4Adapter(LanguageUtil.getString(this, "assets_action_withdraw"))
                    adapter4Deposit?.setEmptyView(EmptyForAdapterView(this))
                    recycler_view.adapter = adapter4Deposit
                    adapter4Deposit?.setOnItemClickListener { adapter, view, position ->
                        CashFlowDetailActivity.liveData4CashFlowBean.postValue(list[position])
                        CashFlowDetailActivity.enter2(this@WithDrawRecordActivity, ParamConstant.TRANSFER_WITHDRAW_RECORD)
                    }
                    adapter4Deposit?.setList(list)
                }
                /**
                 *Transfer Record
                 */
                TRANSFER -> {

                    adapter4Deposit = CashFlow4Adapter(LanguageUtil.getString(this, "assets_action_transfer"))
                    adapter4Deposit?.setEmptyView(EmptyForAdapterView(this))
                    recycler_view.adapter = adapter4Deposit
//                    adapter4Deposit?.setOnItemClickListener { adapter, view, position ->
//                        CashFlowDetailActivity.liveData4CashFlowBean.postValue(list[position])
//                        CashFlowDetailActivity.enter2(this@WithDrawRecordActivity, ParamConstant.OTC_TRANSFER_RECORD, typeStr = list[position].statusText)
//                    }
                    adapter4Deposit?.setList(list)
                }
                /**
                 *Contract transfer record
                 */
                CONTRACT_TRANSFER_HISTORY -> {

                    adapterContract = CashFlowAdapter(list)
                    adapterContract?.index = OTHER_INDEX
                    adapterContract?.setEmptyView(EmptyForAdapterView(this))
                    recycler_view.adapter = adapterContract
//                    adapter4Deposit?.setOnItemClickListener { adapter, view, position ->
//                        CashFlowDetailActivity.liveData4CashFlowBean.postValue(list[position])
//                        CashFlowDetailActivity.enter2(this@WithDrawRecordActivity,ParamConstant.OTC_TRANSFER_RECORD)
//                    }
                    adapterContract?.setList(list)
                }

                /**
                 *Transfer Record Details
                 */
                TRANSFER_RECORD -> {
                    adapterContract = CashFlowAdapter(list)
                    adapterContract?.setEmptyView(EmptyForAdapterView(this))
                    recycler_view.adapter = adapterContract
                    adapterContract?.setOnItemClickListener { adapter, view, position ->
                        CashFlowDetailActivity.liveData4CashFlowBean.postValue(list[position])
                        CashFlowDetailActivity.enter2(this@WithDrawRecordActivity, ParamConstant.DIRECTLY_WITHDRAW_TYPE)
                    }
                    adapterContract?.setList(list)
                }
            }
        }
    }

    /**
     *Obtain other records
     */
    fun getOtherRecord(symbol: String, transactionScene: String, startTime: String, endTime: String, refresh: Boolean) {
        if (!UserDataService.getInstance().isLogined) {
            return
        }
        if ("contract_transfer".equals(transactionScene)) {
            val newEndTime:String;val newStartTime:String
            if(!"".equals(startTime)){
                this.startTime = startTime
                newStartTime=CpV2DateUtil.getDateByFormat(startTime,CpV2DateUtil.dateFormatYMD).time.toString()
            }else{
                this.startTime = ""
                newStartTime = ""
            }
            if(!"".equals(endTime)){
                this.endTime = endTime
                //2020-01-01 00:00:00 - 2024-01-01 23:59:59
                val endDate = CpV2DateUtil.getDateByFormat(endTime,CpV2DateUtil.dateFormatYMD)
                val calendar = Calendar.getInstance()
                calendar.timeInMillis = endDate.time
                calendar.add(Calendar.HOUR,23)
                calendar.add(Calendar.MINUTE,59)
                calendar.add(Calendar.SECOND,59)
                newEndTime = calendar.timeInMillis.toString()
            }else{
                this.endTime = ""
                newEndTime = ""
            }

            HttpClient.instance.getTransferRecord(symbol, transactionScene, newStartTime, newEndTime, page = page.toString())
                    .subscribeOn(Schedulers.io())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(object : NetObserver<CashFlowBean>() {
                        override fun onHandleSuccess(t: CashFlowBean?) {
                            t ?: return
                            if (t?.financeList.isEmpty()) {
                                swipe_refresh?.finishRefresh(true)
                            }
                            if (t?.financeList != null) {
                                if (t.financeList.size < 20) {
//                                    isScrollstatus = false
                                }

                                var beans: ArrayList<CashFlowBean.Finance> = arrayListOf()
                                if (refresh) {
                                    when (transactionScene) {
                                        /**
                                         *Contract transfer
                                         */
                                        ParamConstant.CONTRACT_TRANSFER_RECORD -> {
                                            when (transferTypeMain) {
                                                0 -> {
                                                    setListData(t.financeList as ArrayList<CashFlowBean.Finance>)
                                                    initView()
                                                }
                                                1 -> {
                                                    t.financeList.forEach {
                                                        if (it.status == 1) {
                                                            beans.add(it)
                                                        }
                                                    }
                                                    setListData(beans)
                                                    initView()

                                                }
                                                2 -> {
                                                    t.financeList.forEach {
                                                        if (it.status == 2) {
                                                            beans.add(it)
                                                        }
                                                    }
                                                    setListData(beans)
                                                    initView()
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    refreshView(t.financeList as ArrayList<CashFlowBean.Finance>)
                                }
                            }
//                            swipe_refresh?.finishRefresh(true)
                            if(refresh){
                                swipe_refresh?.finishRefresh(100,true,t.financeList.size < 20)
                            }else{
                                swipe_refresh?.finishLoadMore(100,true,t.financeList.size < 20)
                            }
                        }

                        override fun onHandleError(code: Int, msg: String?) {
                            super.onHandleError(code, msg)
                            DisplayUtil.showSnackBar(window?.decorView, msg, isSuc = false)
                            if(refresh){
                                swipe_refresh?.finishRefresh(true)
                            }else{
                                swipe_refresh?.finishLoadMore(true)
                            }
                        }
                    })
        } else {

            HttpClient.instance.otherTransList4V2(symbol, transactionScene, startTime, endTime, page = page.toString())
                    .subscribeOn(Schedulers.io())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(object : NetObserver<CashFlowBean>() {
                        override fun onHandleSuccess(t: CashFlowBean?) {
                            t ?: return
                            if (t?.financeList.isEmpty()) {
                                swipe_refresh?.finishRefresh(true)
                            }
                            if (t?.financeList != null) {
                                if (t.financeList.size < 20) {
//                                    isScrollstatus = false
                                }

                                var beans: ArrayList<CashFlowBean.Finance> = arrayListOf()
                                if (refresh) {
                                    when (transactionScene) {
                                        /**
                                         *Transfer
                                         */
                                        ParamConstant.OTC_TRANSFER_RECORD , ParamConstant.DIRECTLY_WITHDRAW_TYPE  -> {
                                            setListData(t.financeList as ArrayList<CashFlowBean.Finance>)
                                            initView()
                                        }
                                        /**
                                         *Withdrawal
                                         */
                                        ParamConstant.TRANSFER_WITHDRAW_RECORD -> {
                                            when (withdrawTypeMain) {
                                                0 -> {
                                                    setListData(t.financeList as ArrayList<CashFlowBean.Finance>)
                                                    initView()
                                                }
                                                1 -> {
                                                    t.financeList.forEach {
                                                        if (it.status == 0) {
                                                            beans.add(it)
                                                        }
                                                    }
                                                    setListData(beans)
                                                    initView()

                                                }
                                                2 -> {
                                                    t.financeList.forEach {
                                                        if (it.status != 0) {
                                                            beans.add(it)
                                                        }
                                                    }
                                                    setListData(beans)
                                                    initView()
                                                }
                                            }
                                        }
                                        /**
                                         *Recharge
                                         */
                                        ParamConstant.TRANSFER_DEPOSIT_RECORD -> {
                                            setListData(t.financeList as ArrayList<CashFlowBean.Finance>)
                                            initView()
                                        }
                                        /**
                                         *Contract transfer
                                         */
                                        ParamConstant.CONTRACT_TRANSFER_RECORD -> {
                                            when (transferTypeMain) {
                                                0 -> {
                                                    setListData(t.financeList as ArrayList<CashFlowBean.Finance>)
                                                    initView()
                                                }
                                                1 -> {
                                                    t.financeList.forEach {
                                                        if (it.status == 1) {
                                                            beans.add(it)
                                                        }
                                                    }
                                                    setListData(beans)
                                                    initView()

                                                }
                                                2 -> {
                                                    t.financeList.forEach {
                                                        if (it.status == 2) {
                                                            beans.add(it)
                                                        }
                                                    }
                                                    setListData(beans)
                                                    initView()
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    refreshView(t.financeList as ArrayList<CashFlowBean.Finance>)
                                }
                            }
                            if(refresh){
                                swipe_refresh?.finishRefresh(100,true,t.financeList.size < 20)
                            }else{
                                swipe_refresh?.finishLoadMore(100,true,t.financeList.size < 20)
                            }
                        }

                        override fun onHandleError(code: Int, msg: String?) {
                            super.onHandleError(code, msg)
                            DisplayUtil.showSnackBar(window?.decorView, msg, isSuc = false)
                            if(refresh){
                                swipe_refresh?.finishRefresh(true)
                            }else{
                                swipe_refresh?.finishLoadMore(true)
                            }
                        }
                    })
        }

    }

    /**
     *Load data
     */
    fun setListData(financeList: ArrayList<CashFlowBean.Finance>) {
        list.clear()
        list.addAll(financeList)
    }


    fun getBusinessTransferList(startTime: String = "", endTime: String = "", refresh: Boolean) {
        if (!UserDataService.getInstance().isLogined) {
            return
        }
        HttpClient.instance.getBusinessTransferList("TRANSFER", "", "", "", page)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<ContractCashFlowBean>() {
                    override fun onHandleSuccess(t: ContractCashFlowBean?) {
                        t ?: return
                        contractList = t?.transactionsList as ArrayList<ContractCashFlowBean.Transactions>?
                                ?: return
                        if (refresh) {
                            initView4Contract()
                        } else {
                            refreshView4Contract(t?.transactionsList as ArrayList<ContractCashFlowBean.Transactions>)
                        }
                    }

                    override fun onHandleError(code: Int, msg: String?) {
                        super.onHandleError(code, msg)
                        DisplayUtil.showSnackBar(window?.decorView, msg, isSuc = false)
                    }
                })
    }


}
