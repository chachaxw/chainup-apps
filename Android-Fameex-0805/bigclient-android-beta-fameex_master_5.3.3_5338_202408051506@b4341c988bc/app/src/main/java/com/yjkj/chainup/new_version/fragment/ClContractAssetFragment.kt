package com.yjkj.chainup.new_version.fragment


import android.app.Activity
import android.os.Bundle
import android.text.TextUtils
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.LinearLayoutManager
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.listener.OnItemChildClickListener
import com.chainup.contract.utils.CpClLogicContractSetting
import com.chainup.contract.utils.CpPreferenceManager
import com.chainup.contract.utils.setSafeListener
import com.chainup.contract.view.CpNewDialogUtils
import com.chainup.contract.view.CpSlDialogHelper
import com.chainup.contract.view.dialog.listener.OnCpBindViewListener
import com.chainup.kit.KKDialogUtils
import com.chainup.kit.views.KKEmptyViewKit
import com.chainup.talkingdata.AppAnalyticsExt
import com.scwang.smart.refresh.layout.api.RefreshLayout
import com.scwang.smart.refresh.layout.listener.OnRefreshListener
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseFragment
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.constant.WebTypeEnum
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.extra_service.eventbus.EventBusUtil
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.extra_service.eventbus.NLiveDataUtil
import com.yjkj.chainup.manager.CpLanguageUtil
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.net_new.HttpHelper
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_contract.activity.CpContractAssetRecordActivity
import com.yjkj.chainup.new_contract.adapter.ClContractAssetAdapter
import com.yjkj.chainup.new_version.view.NewAssetTopView
import com.yjkj.chainup.util.LogUtil
import com.yjkj.chainup.util.getLineText
import com.yjkj.chainup.util.iterator
import com.yjkj.chainup.util.onLineText
import kotlinx.android.synthetic.main.accet_header_view.view.*
import kotlinx.android.synthetic.main.sl_fragment_contract_asset.rc_contract
import kotlinx.android.synthetic.main.sl_fragment_contract_asset.swipe_refresh
import org.json.JSONArray
import org.json.JSONObject

/**
 * 合约资产类
 */
class ClContractAssetFragment : NBaseFragment() {
    override fun setContentView(): Int {
        return R.layout.sl_fragment_contract_asset
    }
    lateinit var buffJson: JSONObject
    var adapterHoldContract: ClContractAssetAdapter? = null
    val mList = ArrayList<JSONObject>()
    var allAmountUrl =""
    /**
     * 隐藏小额资产
     */
    private var isLittleAssetsShow = false
    private var openContract = 0
    var assetHeadView: NewAssetTopView? = null

    //是否展示合约购买对话框
    var isShowContractBuyDialog = false
    var isScrollStatus = false
    override fun initView() {
        isShowContractBuyDialog = CpPreferenceManager.getBoolean(mActivity, "isShowContractBuyDialog", true)
        assetHeadView = NewAssetTopView(activity!!, null, 0)
        assetHeadView?.initNorMalView(ParamConstant.CONTRACT_INDEX)
        initHoldContractAdapter()
        NLiveDataUtil.observeData(this, androidx.lifecycle.Observer {
            if (MessageEvent.refresh_trans_type == it?.msg_type) {
                isLittleAssetsShow = !isLittleAssetsShow
                UserDataService.getInstance().saveAssetState(isLittleAssetsShow)
                assetHeadView?.setAssetOrderHide(isLittleAssetsShow)
            } else if (MessageEvent.refresh_local_contract_type == it?.msg_type) {
                LogUtil.d("DEBUG", "刷新合约资产列表2")
                setRefreshAdapter()
            }
        })
        //划转
        assetHeadView?.ll_transfer_layout?.setSafeListener {
//            val list = ContractUserDataAgent.getContractAccounts()
            if (openContract == 0) {
                showOpenContractDialog()
            } else {

                var originCoinName = ""
                val coinJsonStr = CpPreferenceManager.getInstance(requireActivity()).getSharedString("contract#bibi#coin", "")
                val mContractMarginCoinListJsonStr = CpClLogicContractSetting.getContractOriginalMarginCoinListStr(requireActivity())
                if (mContractMarginCoinListJsonStr != null && mContractMarginCoinListJsonStr.isNotEmpty()) {
                    val tempArray = tempCoin(coinJsonStr, mContractMarginCoinListJsonStr)
                    for (element in tempArray) {
                        if(!"EXUSD".equals(element)){
                            originCoinName = element
                            break
                        }
                    }
                }

                ArouterUtil.navigation(RoutePath.NewVersionTransferActivity, Bundle().apply {
                    putString(ParamConstant.TRANSFERSTATUS, ParamConstant.TRANSFER_CONTRACT)
                    putString(ParamConstant.TRANSFERSYMBOL, originCoinName)
                    putString(ParamConstant.TRANSFERORIGINCOIN, originCoinName)
                })
            }
        }
        //资金明细
        assetHeadView?.ll_contract_layout?.setSafeListener {
            if (openContract == 0) {
                showOpenContractDialog()
            } else {
                CpContractAssetRecordActivity.show(context as Activity)
            }
        }
        //合约赠金
        assetHeadView?.ll_contract_coupon_layout?.setSafeListener {
            val httpUrl = PublicInfoDataService.getInstance().getContractCouponUrl(null)
            if (!TextUtils.isEmpty(httpUrl)) {
                var bundle = Bundle()
                bundle.putString(ParamConstant.head_title, getLineText("contract_swap_gift"))
                bundle.putString(ParamConstant.web_url, httpUrl)
                ArouterUtil.greenChannel(RoutePath.ItemDetailActivity, bundle)
            }
        }
        //合约资产分析
        assetHeadView?.img_contract_assets_analysis?.setSafeListener {
            if (openContract == 0) {
                showOpenContractDialog()
            } else {
                AppAnalyticsExt.instance.clickAction(AppAnalyticsExt.CONTRACT_APP_ACTION_16)
                allAmountUrl=HttpHelper.instance.getCoDomain()+"/${LanguageUtil.getSelectLanguage()}/app_operation/coProfitRecord/"
                if (!TextUtils.isEmpty(allAmountUrl)) {
                    var bundle = Bundle()
                    bundle.putString(ParamConstant.head_title,"")
                    bundle.putString(ParamConstant.web_url, allAmountUrl)
                    bundle.putInt(ParamConstant.web_type, WebTypeEnum.CONTRACT_ASSETS_PROFIT.value)
                    ArouterUtil.greenChannel(RoutePath.ItemDetailActivity, bundle)
                }
            }
        }
//        swipe_refresh.setColorSchemeColors(ContextUtil.getColor(R.color.colorPrimary))
        /**
         * 此处刷新
         */
//        swipe_refresh?.setOnRefreshListener {
//            /**
//             * 刷新数据操作
//             */
//            getPositionList()
//        }
        swipe_refresh.setEnableLoadMore(false)
        swipe_refresh.setOnRefreshListener(object : OnRefreshListener {
            override fun onRefresh(refreshLayout: RefreshLayout) {
                getPositionList()
            }
        })
    }

    override fun loadData() {
        openContract = if(CpClLogicContractSetting.isOpenContract()) 1 else 0
//        ContractUserDataAgent.getContractAccounts(true)
        loadContractUserConfig()
    }

    override fun onMessageEvent(event: MessageEvent) {
        super.onMessageEvent(event)
        when(event.msg_type){
            MessageEvent.login_success_event -> {
                loadContractUserConfig()
            }
        }
    }

    private fun tempCoin(coinJsonStr: String, mContractMarginCoinListJsonStr: String): Set<String> {
        if(coinJsonStr.isEmpty()){
            return linkedSetOf()
        }
        val coinListTemp = JSONArray(coinJsonStr)
        val coinListCTemp = JSONArray(mContractMarginCoinListJsonStr)

        val coinList = arrayListOf<String>()
        for (item in coinListTemp.iterator()) {
            coinList.add(item)
        }
        val coinListContract = arrayListOf<String>()
        for (item in coinListCTemp.iterator()) {
            coinListContract.add(item)
        }
        return coinList intersect coinListContract
    }

    override fun fragmentVisibile(isVisibleToUser: Boolean) {
        super.fragmentVisibile(isVisibleToUser)
        if (isVisibleToUser && userVisibleHint && requireParentFragment().isVisible) {
            if(openContract==0){
                showOpenContractDialog()
                return
            }
//            loadContractPublicInfo()
//            loadContractUserConfig()
            getTotalAccountBalance()
//            val list = ContractUserDataAgent.getContractAccounts()
//            if (list.size >= 0) {
//                if (isShowContractBuyDialog) {
//                    isShowContractBuyDialog = false
//                    PreferenceManager.putBoolean(mActivity, "isShowContractBuyDialog", isShowContractBuyDialog)
//                    val totalBalance = ContractUtils.calculateTotalBalance("USDT")
//                    if (totalBalance == 0.0) {
//                        showBuyContractDialog()
//                    }
//                }
//            }


        }
    }

    private fun getPositionList() {
        if (!UserDataService.getInstance().isLogined) return
        if (openContract == 0) {
            swipe_refresh?.finishRefresh()
            return
        }
//        mList.clear()
        addDisposable(getContractModel().getPositionAssetsList(
            consumer = object : NDisposableObserver(isScrollStatus) {
                override fun onResponseSuccess(jsonObject: JSONObject) {
                    jsonObject.optJSONObject("data")?.run {
                        if (!isNull("accountList")) {
                            val mAccountListJson = optJSONArray("accountList")
                            mList.clear()
                            for (i in 0..(mAccountListJson.length() - 1)) {
                                mList.add(mAccountListJson.get(i) as JSONObject)
                                LogUtil.e(TAG, "------------------------------------")
                            }
                        }
                        adapterHoldContract?.notifyDataSetChanged()
                    }
                    swipe_refresh?.finishRefresh(true)
                }

                override fun onResponseFailure(code: Int, msg: String?) {
                    super.onResponseFailure(code, msg)
                    swipe_refresh?.finishRefresh(true)
                }
            }))
    }

    private fun loadContractPublicInfo() {
        addDisposable(getContractModel().getPublicInfo(
            consumer = object : NDisposableObserver(mActivity, true,isLoad = false) {
                override fun onResponseSuccess(jsonObject: JSONObject) {
                    jsonObject.optJSONObject("data").run {
//                         allAmountUrl = optString("allAmountUrl")
//                        if (TextUtils.isEmpty(allAmountUrl)){
//                            assetHeadView?.img_contract_assets_analysis?.visibility= View.GONE
//                        }else{
//                            assetHeadView?.img_contract_assets_analysis?.visibility= View.VISIBLE
//                        }
                    }
                }
            }))

    }

    private fun getTotalAccountBalance() {
        if (!UserDataService.getInstance().isLogined) return
        addDisposable(getMainModel().contractTotalAccountBalanceV2(
            consumer = object : NDisposableObserver(mActivity, true,isLoad = false) {
                override fun onResponseSuccess(jsonObject: JSONObject) {
                    jsonObject.optJSONObject("data")?.run {
                        buffJson = this
                        assetHeadView?.setContractHeadData(this)
                    }
                }
            }))
    }

    private fun loadContractUserConfig() {
        //如果合约ID传0则获取默认的数据，此处主要就是获取是否开通合约
        if (!UserDataService.getInstance().isLogined) return
        addDisposable(getContractModel().getUserConfig("0",
            consumer = object : NDisposableObserver(requireActivity(),true,isLoad = false) {
                override fun onResponseSuccess(jsonObject: JSONObject) {
                    jsonObject.optJSONObject("data").run {
                        //  1已开通, 0未开通
                        openContract = optInt("openContract")
                        CpClLogicContractSetting.setContractIsOpen(context,openContract)
                        getPositionList()
                    }
                }
            }))
    }


    /**
     * 开通合约对话框
     */
    private fun showOpenContractDialog() {
        CpSlDialogHelper.showSimpleCreateContractDialog(mActivity!!, OnCpBindViewListener { viewHolder ->
            viewHolder?.let {
                it.getView<TextView>(R.id.tv_cancel_btn).onLineText("common_text_btnCancel")
                it.setImageResource(R.id.iv_logo, R.drawable.sl_create_contract)
                it.setText(R.id.tv_text, getLineText("sl_str_open_contract_tips"))
                it.setText(R.id.tv_confirm_btn, getLineText("sl_str_to_open"))
            }

        }, object : CpNewDialogUtils.DialogBottomListener {
            override fun sendConfirm() {
//                addDisposable(getContractModel().createContract(
//                        consumer = object : NDisposableObserver(true) {
//                            override fun onResponseSuccess(jsonObject: JSONObject) {
//                                NToastUtil.showTopToastNet(this.mActivity,true, getLineText("sl_str_account_created_successfully"))
//                                loadContractUserConfig()
//                            }
//                        }))
                var messageEvent = MessageEvent(MessageEvent.contract_switch_type)
                EventBusUtil.post(messageEvent)
            }

        })
    }


    fun setRefreshAdapter() {
        if(!this::buffJson.isInitialized){
            return
        }
        assetHeadView?.setRefreshAdapter()
        assetHeadView?.setContractHeadData(buffJson)
        refreshViewData()
        getPositionList()
    }


    private fun refreshViewData() {
//        val contractAccounts: List<ContractAccount>? = ContractUserDataAgent.getContractAccounts()
//        mList.clear()
//        if (contractAccounts != null) {
//            mList.addAll(contractAccounts)
//        }
//        adapterHoldContract?.notifyDataSetChanged()
        assetHeadView?.setRefreshViewData()
    }


    /**
     * 合约未平仓合约
     */
    private fun initHoldContractAdapter() {
        adapterHoldContract = ClContractAssetAdapter(mList)
        if (assetHeadView?.parent != null) {
            (assetHeadView?.parent as ViewGroup).removeAllViews()
        }
        adapterHoldContract?.setHeaderView(assetHeadView!!)

        rc_contract?.layoutManager = LinearLayoutManager(context)
        rc_contract.adapter = adapterHoldContract
//        adapterHoldContract?.bindToRecyclerView(rc_contract ?: return)
        adapterHoldContract?.setEmptyView(KKEmptyViewKit(context ?: return))
        adapterHoldContract?.headerWithEmptyEnable = true
        rc_contract?.adapter = adapterHoldContract
        adapterHoldContract?.setOnItemChildClickListener(object : OnItemChildClickListener{
            override fun onItemChildClick(
                adapter: BaseQuickAdapter<*, *>,
                view: View,
                position: Int
            ) {
                when(view.id) {
                    R.id.tv_margin_balance_label -> {
                        KKDialogUtils.showCommonDialog(
                            mActivity!!,
                            title=(view as TextView).text.toString(),
                            style = 2,
                            isShowCancel = false,
                            confrimTitle = CpLanguageUtil.getString(mActivity,"cp_extra_text28"),
                            listener = null,
                            content = CpLanguageUtil.getString(mActivity,"cp_total_balance2"),
                        )
                    }
                    R.id.tv_wallet_balance_label -> {
                        KKDialogUtils.showCommonDialog(
                            mActivity!!,
                            title=(view as TextView).text.toString(),
                            style = 2,
                            isShowCancel = false,
                            confrimTitle = CpLanguageUtil.getString(mActivity,"cp_extra_text28"),
                            listener = null,
                            content = CpLanguageUtil.getString(mActivity,"cp_wallet_balance2")
                        )
                    }
                    R.id.tv_unrealized_label -> {
                        KKDialogUtils.showCommonDialog(
                            mActivity!!,
                            title=(view as TextView).text.toString(),
                            style = 2,
                            isShowCancel = false,
                            confrimTitle = CpLanguageUtil.getString(mActivity,"cp_extra_text28"),
                            listener = null,
                            content = CpLanguageUtil.getString(mActivity,"cp_upnl_balance")
                        )
                    }
                }
            }

        })
    }

}


