package com.yjkj.chainup.new_version.activity.asset


import android.app.Activity
import android.content.Intent
import android.graphics.Typeface
import android.os.Bundle
import android.view.Gravity
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.LinearLayoutManager
import com.chad.library.adapter.base.listener.OnLoadMoreListener
import com.chainup.contract.bean.CpTabInfo
import com.chainup.contract.utils.CpClLogicContractSetting
import com.chainup.contract.view.dialog.CpTDialog
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseActivity
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.manager.CpLanguageUtil
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_version.adapter.ClContractAssetRecordAdapter
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.view.EmptyForAdapterView
import com.yjkj.chainup.util.BigDecimalUtils
import com.yjkj.chainup.util.Utils
import kotlinx.android.synthetic.main.cl_activity_coin_detail.*
import org.json.JSONArray
import org.json.JSONObject

/**
 *Contract Currency Details
 */
class ClCoinDetailActivity : NBaseActivity() {
    override fun setContentView(): Int {
        return R.layout.cl_activity_coin_detail
    }

    internal class PageInfo {
        var page = 1
        fun nextPage() {
            page++
        }

        fun reset() {
            page = 1
        }

        val isFirstPage: Boolean
            get() = page == 1
    }

    private val pageInfo = PageInfo()

    var marginCoin = "USDT"
    private lateinit var mAccountList: JSONArray

    //Type
    private var typeList = ArrayList<CpTabInfo>()
    private var mCurrTypeInfo: CpTabInfo? = null
    private var typeDialog:  CpTDialog? = null

    private var assetAdapter: ClContractAssetRecordAdapter? = null
    private val mList = ArrayList<JSONObject>()

    private val mLimit = 0
    private var isLoading = false

    override fun onInit(savedInstanceState: Bundle?) {
        super.onInit(savedInstanceState)
        marginCoin = intent.getStringExtra("marginCoin") ?: "USDT"
        initView()
        initLoadMore()
        loadData()
    }

    override fun initView() {
        initAutoTextView()
        setSupportActionBar(toolbar)
        toolbar?.setNavigationOnClickListener {
            finish()
        }
        collapsing_toolbar?.let {
            it.setCollapsedTitleTextColor(ContextCompat.getColor(mActivity, R.color.text_color))
            it.setExpandedTitleColor(ContextCompat.getColor(mActivity, R.color.text_color))
            it.setExpandedTitleTypeface(Typeface.DEFAULT_BOLD)
            it.expandedTitleGravity = Gravity.TOP
            it.title = NCoinManager.getShowMarket(marginCoin)
        }

//        val transaction = supportFragmentManager!!.beginTransaction()
//        transaction.add(R.id.fragment_container, holdFragment, "0000")
//        transaction.commitAllowingStateLoss()

        //Type
//        typeList.add(TabInfo(getString(R.string.sl_str_order_type_none), 0))
//TypeList. add (TabInfo (getString (R.string. sl_str_transfer_bb2contract), 1))//Transfer in
//TypeList. add (TabInfo (getString (com. hainup. contract. R.string. sl_str_transfer_contract2bb), 2)//Transfer out
//TypeList. add (TabInfo (getString (com. hainup. contract. R.string. cl_founding_fee_str), 5)//Fund expenses
//TypeList. add (TabInfo (getString (com. hainup. contract. R.string. cl_loss_amortization_str), 8)//Allocation


        typeList.add(CpTabInfo(CpLanguageUtil.getString(this,"cp_order_text4"), 0))
        typeList.add(CpTabInfo(CpLanguageUtil.getString(this,"cp_extra_text13"), 1))
        typeList.add(CpTabInfo(CpLanguageUtil.getString(this,"cp_extra_text14"), 2))
        typeList.add(CpTabInfo(CpLanguageUtil.getString(this,"cp_position_text3"), 5))
        typeList.add(CpTabInfo(CpLanguageUtil.getString(this,"cp_position_text5"), 8))
//        typeList.add(TabInfo(CpLanguageUtil.getString(this,"cp_fee_share"), 9))
//        typeList.add(TabInfo(CpLanguageUtil.getString(this,"cp_extra_text15"), 10))
//        typeList.add(TabInfo(CpLanguageUtil.getString(this,"cp_extra_text16"), 11))
        typeList.add(CpTabInfo(CpLanguageUtil.getString(this,"cp_extra_text18"), 6))
        typeList.add(CpTabInfo(CpLanguageUtil.getString(this,"cp_extra_text19"), 7))


        if (mCurrTypeInfo == null) {
            mCurrTypeInfo = typeList[0]
        }

        assetAdapter = ClContractAssetRecordAdapter(this, mList)
        ll_layout.layoutManager = LinearLayoutManager(this)
        ll_layout.adapter = assetAdapter
        assetAdapter?.setEmptyView(EmptyForAdapterView(this))
        ll_layout.adapter = assetAdapter

        //Select Type
        ll_tab_type.setOnClickListener {
            showSelectTypeDialog()
        }
    }

    private fun showSelectTypeDialog() {
        typeDialog = NewDialogUtils.showNewBottomListDialog(mActivity, typeList, mCurrTypeInfo!!.index, object : NewDialogUtils.DialogOnItemClickListener {
            override fun clickItem(index: Int) {
                mCurrTypeInfo = typeList[index]
                typeDialog?.dismiss()
                typeDialog = null
                updateTypeUI()
                pageInfo.reset()
                loadDataFromNet()
            }
        })
    }

    private fun updateTypeUI() {
        tv_tab_type.text = mCurrTypeInfo?.name
    }

    private fun initAutoTextView() {
//        tv_account_equity_label.apply {
//            onLineText("contract_assets_account_equity")
//            onClick {
//                ContractDialog.showDialog4AccountRights(this@SlCoinDetailActivity)
//            }
//        }

        tv_account_equity_label.setText(CpLanguageUtil.getString(this,"cp_total_asset_str"))
        tv_all_margin_balance.setText(CpLanguageUtil.getString(this,"cp_cross_balance_str"))
        tv_small_margin_balance.setText(CpLanguageUtil.getString(this,"cp_isolated_balance_str"))
        tv_available_balance.setText(CpLanguageUtil.getString(this,"cp_calculator_text43"))
        tv_floating_gains_label.setText(CpLanguageUtil.getString(this,"cp_coaccount_lockmargin"))
        tv_coin_title.setText(CpLanguageUtil.getString(this,"cp_extra_text143"))
        tv_tab_type.setText(CpLanguageUtil.getString(this,"cp_order_text4"))
    }

    override fun loadData() {
        super.loadData()
        mMarginCoinPrecision = CpClLogicContractSetting.getContractMarginCoinPrecisionByMarginCoin(mActivity, marginCoin)
        getAccountBalanceByMarginCoin()
        loadDataFromNet()
    }

    private fun initLoadMore() {
        swipe_refresh?.setOnRefreshListener {
            pageInfo.reset()
            loadDataFromNet()
        }
        swipe_refresh?.setOnLoadMoreListener {
            loadDataFromNet()
        }
//        assetAdapter?.loadMoreModule?.apply {
//            setOnLoadMoreListener(object : OnLoadMoreListener {
//                override fun onLoadMore() {
//                    loadDataFromNet()
//                }
//            })
//            isAutoLoadMore = true
//            isEnableLoadMoreIfNotFullPage = false
//        }
    }
    var mMarginCoinPrecision =0
    private fun loadDataFromNet() {
        if (pageInfo.isFirstPage) {
            showLoadingDialog()
        }
        isLoading = true
        addDisposable(getContractModel().getTransactionList(marginCoin, mCurrTypeInfo?.index.toString(), pageInfo.page.toString(),
            consumer = object : NDisposableObserver() {
                override fun onResponseSuccess(jsonObject: JSONObject) {
                    jsonObject.optJSONObject("data").run {
                        val mLadderList = optJSONArray("transList")
                        val mListBuffer = ArrayList<JSONObject>()
                        if (mLadderList.length() != 0) {
                            for (i in 0..(mLadderList.length() - 1)) {
                                var obj: JSONObject = mLadderList.get(i) as JSONObject
                                obj.put("mMarginCoinPrecision", mMarginCoinPrecision)
                                mListBuffer.add(obj)
                            }
                        }
                        if (pageInfo.isFirstPage) {
                            assetAdapter?.setList(mListBuffer)
                        } else {
                            assetAdapter?.addData(mListBuffer)
                        }
                        if (mListBuffer.size < 20) {
//                            assetAdapter?.loadMoreModule?.loadMoreEnd()
                            swipe_refresh?.finishLoadMoreWithNoMoreData()
                        } else {
//                            assetAdapter?.loadMoreModule?.loadMoreComplete()
                            swipe_refresh?.finishLoadMore()
                        }
                        pageInfo.nextPage()
                        closeLoadingDialog()
                        swipe_refresh?.finishRefresh()
//                            val mLadderList = optJSONArray("transList")
//                            isLoading = false
//                            if (mOffset == 1) {
//                                mList.clear()
//                            }
//                            if (mLadderList.length() != 0) {
//                                for (i in 0..(mLadderList.length() - 1)) {
//                                    var obj: JSONObject = mLadderList.get(i) as JSONObject
//                                    obj.put("mMarginCoinPrecision", mMarginCoinPrecision)
//                                    mList.add(obj)
//                                }
//                                assetAdapter?.notifyDataSetChanged()
////                                assetAdapter?.setEnableLoadMore(true)
////                                assetAdapter?.loadMoreComplete()
//                            } else {
////                                assetAdapter?.loadMoreEnd()
//                            }
//                            assetAdapter?.notifyDataSetChanged()
//                            assetAdapter?.disableLoadMoreIfNotFullPage()
                    }
                }

                override fun onError(e: Throwable) {
                    super.onError(e)
//                    assetAdapter?.loadMoreModule?.isEnableLoadMore = true
//                    assetAdapter?.loadMoreModule?.loadMoreFail();
                    closeLoadingDialog()
                    swipe_refresh?.finishRefresh()
                    swipe_refresh?.finishLoadMore()

                }
            }))
    }

    private fun getAccountBalanceByMarginCoin() {
        addDisposable(getContractModel().getAccountBalanceByMarginCoin(marginCoin,
            consumer = object : NDisposableObserver() {
                override fun onResponseSuccess(jsonObject: JSONObject) {
                    jsonObject.optJSONObject("data").run {
                        mAccountList = optJSONArray("accountList")
                        var isShowAssets = UserDataService.getInstance().isShowAssets
                        for (i in 0..(mAccountList.length() - 1)) {
                            var obj = mAccountList.getJSONObject(i)
                            var symbol = obj.getString("symbol")
                            if (symbol.equals(marginCoin)) {
                                Utils.assetsHideShow(isShowAssets, tv_total_balance, BigDecimalUtils.showSNormal(obj.getString("totalAmount"), mMarginCoinPrecision))
                                Utils.assetsHideShow(isShowAssets, tv_all_margin_balance_value, BigDecimalUtils.showSNormal(obj.getString("totalMargin"), mMarginCoinPrecision))
                                Utils.assetsHideShow(isShowAssets, tv_small_margin_balance_value, BigDecimalUtils.showSNormal(obj.getString("isolateMargin"), mMarginCoinPrecision))
                                Utils.assetsHideShow(isShowAssets, tv_freeze_margin, BigDecimalUtils.showSNormal(obj.getString("lockAmount"), mMarginCoinPrecision))
//                                    Utils.assetsHideShow(isShowAssets, tv_realized, BigDecimalUtils.showSNormal(obj.getString("realizedAmount"), mMarginCoinPrecision))
//                                    Utils.assetsHideShow(isShowAssets, tv_un_realized, BigDecimalUtils.showSNormal(obj.getString("unRealizedAmount"), mMarginCoinPrecision))
                                Utils.assetsHideShow(isShowAssets, tv_canuse_balance, BigDecimalUtils.showSNormal(obj.getString("canUseAmount"), mMarginCoinPrecision))
                            }
                        }
                    }
                }
            }))
    }


    companion object {
        fun show(activity: Activity, marginCoin: String) {
            val intent = Intent(activity, ClCoinDetailActivity::class.java)
            intent.putExtra("marginCoin", marginCoin)
            activity.startActivity(intent)
        }
    }


}