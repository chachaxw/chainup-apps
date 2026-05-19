package com.yjkj.chainup.new_contract.activity

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.LinearLayoutManager
import com.blankj.utilcode.util.LogUtils
import com.chad.library.adapter.base.listener.OnLoadMoreListener
import com.chainup.contract.R
import com.chainup.contract.base.CpNBaseActivity
import com.chainup.contract.bean.CpTabInfo
import com.chainup.contract.utils.CpClLogicContractSetting
import com.chainup.contract.view.CpDialogUtil
import com.chainup.contract.view.CpNewDialogUtils
import com.chainup.contract.view.dialog.CpTDialog
import com.chainup.contract.view.trade.ContractLoadMoreView
import com.chainup.kit.views.KKEmptyViewKit
import com.jaeger.library.StatusBarUtil
import com.yjkj.chainup.manager.CpLanguageUtil
import com.yjkj.chainup.net_new.rxjava.CpNDisposableObserver
import com.yjkj.chainup.new_contract.adapter.CpContractAssetRecordAdapter
import kotlinx.android.synthetic.main.cp_activity_asset_record.*
import org.json.JSONArray
import org.json.JSONObject


/**
 *Contract fund records
 */
class CpContractAssetRecordActivity : CpNBaseActivity() {
    override fun setContentView(): Int {
        return R.layout.cp_activity_asset_record
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

    //Contract
    private var contractList = ArrayList<CpTabInfo>()
    private var mCurrContractInfo: CpTabInfo? = null
    private var contractDialog: CpTDialog? = null

    //Type
    private var typeList = ArrayList<CpTabInfo>()
    private var mCurrTypeInfo: CpTabInfo? = null
    private var typeDialog: CpTDialog? = null

    private var assetAdapter: CpContractAssetRecordAdapter? = null
    private val mList = ArrayList<JSONObject>()

    private var isLoading = false


    override fun onInit(savedInstanceState: Bundle?) {
        super.onInit(savedInstanceState)
        loadData()
        initView()
        initLoadMore()
        initClickListener()
    }


    override fun loadData() {
        super.loadData()
        val symbol = intent.getStringExtra("symbol") ?: ""
        val type = intent.getIntExtra("type", 0)
        val mContractMarginCoinListJsonStr = CpClLogicContractSetting.getContractMarginCoinListStr(mActivity)
        if (mContractMarginCoinListJsonStr != null && mContractMarginCoinListJsonStr.isNotEmpty()) {
            val jsonArray = JSONArray(mContractMarginCoinListJsonStr)
            for (i in 0 until jsonArray.length()) {
                val mJSONObject = jsonArray[i] as String
                contractList.add(CpTabInfo(mJSONObject, i,i))
                if (symbol.equals(mJSONObject)) {
                    mCurrContractInfo = CpTabInfo(mJSONObject, i,extras = i)
                }
            }
        } else {
            contractList.add(CpTabInfo("USDT", 0,extras = 0))
        }
        if (mCurrContractInfo == null) {
            mCurrContractInfo = contractList[0]
        }
        updateContractUI()
        //Type 流水类型 1 转入 ,2 转出 ,3 结算多仓 ,4 结算空仓 ,5 资金费用 ,6 开仓手续费 ,7 平仓手续费 ,8 分摊, 9 手续费分成, 10 增金发放, 11 增金回收，13 平仓盈亏
        typeList.add(CpTabInfo(CpLanguageUtil.getString(this,"cp_order_text4"), 0,extras=0))
        typeList.add(CpTabInfo(CpLanguageUtil.getString(this,"cp_extra_text13"), 1,extras=1))
        typeList.add(CpTabInfo(CpLanguageUtil.getString(this,"cp_extra_text14"), 2,extras=2))
        typeList.add(CpTabInfo(CpLanguageUtil.getString(this,"cp_position_text3"), 5,extras=3))
        typeList.add(CpTabInfo(CpLanguageUtil.getString(this,"cp_position_text5"), 8,extras=4))
        typeList.add(CpTabInfo(CpLanguageUtil.getString(this,"cp_fee_share"), 9,extras=5))
        typeList.add(CpTabInfo(CpLanguageUtil.getString(this,"cp_extra_text15"), 10,extras=6))
        typeList.add(CpTabInfo(CpLanguageUtil.getString(this,"cp_extra_text16"), 11,extras=7))
        typeList.add(CpTabInfo(CpLanguageUtil.getString(this,"cp_extra_text18"), 6,extras=8))
        typeList.add(CpTabInfo(CpLanguageUtil.getString(this,"cp_extra_text19"), 7,extras=9))
        typeList.add(CpTabInfo(CpLanguageUtil.getString(this,"cp_close_pnl"), 13,extras=10))
        for (typeItem in typeList) {
            if (typeItem.index == type) {
                mCurrTypeInfo = typeItem
                break
            }
        }
        if (mCurrTypeInfo == null) {
            mCurrTypeInfo = typeList[0]
        }
        updateTypeUI()
        assetAdapter = CpContractAssetRecordAdapter(this, mList)

        loadDataFromNet()

    }


    override fun initView() {
        StatusBarUtil.setColor(this,ContextCompat.getColor(this,R.color.card_bg_color_1),0)
        window.navigationBarColor = ContextCompat.getColor(this,R.color.card_bg_color_1)
        initAutoTextView()


        ll_layout.layoutManager = LinearLayoutManager(this)
        ll_layout.adapter = assetAdapter
        assetAdapter?.setEmptyView(KKEmptyViewKit(this))

        updateContractUI()
        updateTypeUI()

    }

    private fun initAutoTextView() {
        v_header.titleText = CpLanguageUtil.getString(this,"cp_assets_text8")
        tv_amount_label.text = CpLanguageUtil.getString(this,"cp_content_text30")
        tv_type_label.text = CpLanguageUtil.getString(this,"cp_order_text93")
    }

    private fun initClickListener() {
        //Select Contract
        ll_tab_contract.setOnClickListener {
            showSelectContractDialog(it)
        }
        //Select Type
        ll_tab_type.setOnClickListener {
            showSelectTypeDialog(it)
        }
    }

    private fun initLoadMore() {
        assetAdapter?.loadMoreModule?.apply {
            loadMoreView = ContractLoadMoreView()
            setOnLoadMoreListener(object : OnLoadMoreListener {
                override fun onLoadMore() {
                    loadDataFromNet()
                }
            })
            isAutoLoadMore = true
            isEnableLoadMoreIfNotFullPage = false
        }
    }

    private fun showSelectTypeDialog(view: View) {
//        typeDialog = CpNewDialogUtils.showNewBottomListDialog(mActivity, typeList, mCurrTypeInfo!!.index, object : CpNewDialogUtils.DialogOnItemClickListener {
//            override fun clickItem(index: Int) {
//                typeDialog?.dismiss()
//                typeDialog = null
//                mCurrTypeInfo = typeList[index]
//                updateTypeUI()
//                pageInfo.reset()
//                loadDataFromNet()
//            }
//        })

        img_tab_type.animate().setDuration(300).rotation(180f).start()
        LogUtils.e("createTopListPop","|||||"+ mCurrTypeInfo!!.extrasNum)
        CpDialogUtil.createTopListPop(this, mCurrTypeInfo!!.extrasNum!!, typeList, view, object : CpNewDialogUtils.DialogOnSigningItemClickListener {
            override fun clickItem(position: Int, text: String) {
                mCurrTypeInfo = typeList[position]
                LogUtils.e("createTopListPop",position.toString()+"|||||||"+text+"|||||"+ mCurrTypeInfo!!.extrasNum)
                updateTypeUI()
                pageInfo.reset()
                loadDataFromNet()

            }
        }, object : CpNewDialogUtils.DialogOnDismissClickListener {
            override fun clickItem() {
                img_tab_type.animate().setDuration(300).rotation(0f).start()
            }
        })

    }


    private fun showSelectContractDialog(view:View) {
//        contractDialog = CpNewDialogUtils.showNewBottomListDialog(mActivity, contractList, mCurrContractInfo!!.index, object : CpNewDialogUtils.DialogOnItemClickListener {
//            override fun clickItem(index: Int) {
//                contractDialog?.dismiss()
//                contractDialog = null
//                mCurrContractInfo = contractList[index]
//                updateContractUI()
//                pageInfo.reset()
//                loadDataFromNet()
//            }
//        })

        img_tab_contract.animate().setDuration(300).rotation(180f).start()
        CpDialogUtil.createTopListPop(this, mCurrContractInfo!!.extrasNum!!, contractList, view, object : CpNewDialogUtils.DialogOnSigningItemClickListener {
            override fun clickItem(position: Int, text: String) {
                mCurrContractInfo = contractList[position]
                LogUtils.e("createTopListPop",position.toString()+"|||||||"+text+"|||||"+ mCurrTypeInfo!!.extrasNum)
                updateTypeUI()
                pageInfo.reset()
                loadDataFromNet()
                updateContractUI()
            }
        }, object : CpNewDialogUtils.DialogOnDismissClickListener {
            override fun clickItem() {
                img_tab_contract.animate().setDuration(300).rotation(0f).start()
            }
        })
    }

    private fun updateContractUI() {
        tv_tab_contract.text = mCurrContractInfo?.name
        tv_amount_label.text = CpLanguageUtil.getString(this,"cp_content_text30") + "(" + mCurrContractInfo?.name + ")"
    }

    private fun updateTypeUI() {
        tv_tab_type.text = mCurrTypeInfo?.name
    }

    private fun loadDataFromNet() {
        if (pageInfo.isFirstPage) {
            showLoadingDialog()
        }
        clearDisposable()
        var mMarginCoinPrecision = CpClLogicContractSetting.getContractMarginCoinPrecisionByMarginCoin(mActivity, mCurrContractInfo?.name.toString())
        isLoading = true
        var originalCoin="";
        var contractListJson= CpClLogicContractSetting.getContractJsonListStr(mActivity)
        var mContractList = JSONArray(contractListJson)
        for (i in 0..(mContractList.length() - 1)) {
            var obj: JSONObject = mContractList.get(i) as JSONObject
            var marginCoin = obj.getString("marginCoin")
            if (marginCoin.equals(mCurrContractInfo?.name.toString())){
                originalCoin=obj.getString("originalCoin")
            }
        }
        addDisposable(getContractModel().getTransactionList(originalCoin, mCurrTypeInfo?.index.toString(), pageInfo.page.toString(),
                consumer = object : CpNDisposableObserver() {
                    override fun onResponseSuccess(jsonObject: JSONObject?) {
                        jsonObject?.optJSONObject("data")?.run {
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
                                if(mListBuffer.size<=0){
                                    ll_head.visibility = View.GONE
                                }else{
                                    ll_head.visibility = View.VISIBLE
                                }
                                assetAdapter?.setList(mListBuffer)
                            } else {
                                assetAdapter?.addData(mListBuffer)
                            }
                            if (mListBuffer.size < 20) {
                                assetAdapter?.loadMoreModule?.loadMoreEnd()
                            } else {
                                assetAdapter?.loadMoreModule?.loadMoreComplete()
                            }
                            pageInfo.nextPage()
                            closeLoadingDialog()
                        }
                    }

                    override fun onError(e: Throwable) {
                        assetAdapter?.loadMoreModule?.isEnableLoadMore = true
                        assetAdapter?.loadMoreModule?.loadMoreFail();
                        closeLoadingDialog()
                    }
                }))
    }


    companion object {
        fun show(activity: Activity, symbol: String = "USDT", type: Int = 0) {
            val intent = Intent(activity, CpContractAssetRecordActivity::class.java)
            intent.putExtra("symbol", symbol)
            intent.putExtra("type", type)
            activity.startActivity(intent)
        }
    }
}
