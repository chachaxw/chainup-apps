package com.yjkj.chainup.new_contract.activity

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.view.ViewGroup.MarginLayoutParams
import android.view.WindowManager
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.viewpager.widget.ViewPager
import com.chainup.contract.R
import com.chainup.contract.base.CpNBaseActivity
import com.chainup.contract.bean.ContractListBean
import com.chainup.contract.bean.CpTabInfo
import com.chainup.contract.eventbus.CpEventBusUtil
import com.chainup.contract.eventbus.CpMessageEvent
import com.chainup.contract.ui.activity.CpContractEntrustNewActivity
import com.chainup.contract.ui.fragment.*
import com.chainup.contract.utils.CpClLogicContractSetting
import com.chainup.contract.utils.toDinproMedium
import com.chainup.contract.view.CpNewDialogUtils
import com.chainup.kit.utils.PublicSizeUtil
import com.chainup.contract.view.dialog.CpTDialog
import com.chainup.kit.views.PublicHeaderKit
import com.jaeger.library.StatusBarUtil
import com.yjkj.chainup.manager.CpLanguageUtil
import kotlinx.android.synthetic.main.cp_activity_contract_calculate.*
import kotlinx.android.synthetic.main.cp_activity_contract_detail.mHeaderKit
import kotlinx.android.synthetic.main.cp_activity_contract_detail.sub_tab_layout
import kotlinx.android.synthetic.main.cp_activity_contract_detail.vp_order
import org.json.JSONArray


/**
 *Contract Details
 */
class CpContractDetailActivity : CpNBaseActivity() {
    override fun setContentView(): Int {
        return R.layout.cp_activity_contract_detail
    }

    var isShowContractSelect: Boolean = false
    private var contractId = -1
    private var mFragments: ArrayList<Fragment>? = null
    private var selPosition = 0

    //Guarantee currency
    private var contractList = ArrayList<CpTabInfo>()
    private var mCurrMarginCoinInfo: CpTabInfo? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        initSystemFrame()
        loadData()
        initView()
    }

    private fun initSystemFrame() {
        layoutView?.fitsSystemWindows = false
        StatusBarUtil.setColor(this,ContextCompat.getColor(this,R.color.bg_card_color),0)
        window.navigationBarColor = ContextCompat.getColor(this,R.color.transparent)
        window.addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION)
        val marginLayoutParams = mHeaderKit.layoutParams as MarginLayoutParams
        marginLayoutParams.topMargin = PublicSizeUtil.getStatusBarHeight(this)
        mHeaderKit.layoutParams = marginLayoutParams
    }


    override fun initView() {
        super.initView()

        val mContractMarginCoinListJsonStr = CpClLogicContractSetting.getContractMarginCoinListStr(mActivity)
        if (mContractMarginCoinListJsonStr != null && mContractMarginCoinListJsonStr.isNotEmpty()) {
            val jsonArray = JSONArray(mContractMarginCoinListJsonStr)
            for (i in 0 until jsonArray.length()) {
                val mJSONObject = jsonArray[i] as String
                contractList.add(CpTabInfo(mJSONObject, i))
            }
        } else {
            contractList.add(CpTabInfo("USDT", 0))
        }
        if (mCurrMarginCoinInfo == null) {
            for (buff in contractList) {
                if (buff.name.equals(CpClLogicContractSetting.getContractMarginCoinById(this, contractId))) {
                    mCurrMarginCoinInfo = buff
                }
            }
        }

        mHeaderKit?.run {
            val selectName = CpClLogicContractSetting.getContractShowNameById(mActivity, contractId)

            setFilterTitleContent(selectName)

            listener = object : PublicHeaderKit.IOnBackClickListener{
                override fun onFilterTitle(view: View) {
                    super.onFilterTitle(view)

                    val mContractCoinSearchDialog = CpContractCoinSearchDialog()
                    val bundle = Bundle().apply {
                        putString(
                            "contractList",
                            CpClLogicContractSetting.getContractJsonListStr(mActivity)
                        )
                    }
                    mContractCoinSearchDialog.arguments = bundle
                    mContractCoinSearchDialog.showDialog(supportFragmentManager, "SlContractFragment")


                }
            }

        }

        initTabInfo()


    }

    private fun initTabInfo() {
        mFragments = ArrayList()
        mFragments?.add(CpContractParaFragment.newInstance(contractId))
        mFragments?.add(CpContractPublicFragment.newInstance(contractId))
        mFragments?.add(CpCapitalRateFragment.newInstance(contractId))
        mFragments?.add(CpInsuranceFundFragment.newInstance(contractId))
        vp_order.setNoScroll(false)
        sub_tab_layout.setViewPager(vp_order, arrayOf(
            CpLanguageUtil.getString(this,"cp_contract_info_text2"),
            CpLanguageUtil.getString(this,"LvrgnMg"),
            CpLanguageUtil.getString(this,"cp_contract_info_text3"),
            CpLanguageUtil.getString(this,"cp_contract_info_text4")
        ), this, mFragments)
        for(i in 0 until sub_tab_layout.tabCount){
            sub_tab_layout.getTitleView(i).toDinproMedium()
        }

        vp_order.addOnPageChangeListener(object : ViewPager.OnPageChangeListener {
            override fun onPageScrollStateChanged(state: Int) {
            }

            override fun onPageScrolled(position: Int, positionOffset: Float, positionOffsetPixels: Int) {
            }

            override fun onPageSelected(position: Int) {
                selPosition = position
                if (position == 3) {
                    mHeaderKit?.setFilterTitleContent(mCurrMarginCoinInfo?.name!!)
                    mHeaderKit?.setFilterTitleVisible(false)
                } else {
                    mHeaderKit?.setFilterTitleVisible(true)
                    mHeaderKit?.setFilterTitleContent(CpClLogicContractSetting.getContractShowNameById(mActivity, contractId))
                }
            }
        })
    }


    override fun loadData() {
        super.loadData()
        contractId = intent.getIntExtra("contractId", -1)
    }

    override fun onMessageEvent(event: CpMessageEvent) {
        super.onMessageEvent(event)
        when(event.msg_type){
            CpMessageEvent.sl_contract_left_coin_type -> {
                contractId = event.msg_content as Int
                CpContractEntrustNewActivity.mContractId = contractId
                mHeaderKit.setFilterTitleContent(CpClLogicContractSetting.getContractShowNameById(this@CpContractDetailActivity, contractId))

                val newEvent = CpMessageEvent(CpMessageEvent.sl_contract_calc_switch_contract_event)
                newEvent.msg_content = CpContractEntrustNewActivity.mContractId
                CpEventBusUtil.post(newEvent)
            }
            CpMessageEvent.sl_contract_margin_coin_select -> {
                var contractDialog: CpTDialog? = null
                contractDialog = CpNewDialogUtils.showNewBottomListDialog(mActivity, contractList, mCurrMarginCoinInfo!!.index, object : CpNewDialogUtils.DialogOnItemClickListener {
                    override fun clickItem(index: Int) {
                        contractDialog?.dismiss()
                        mCurrMarginCoinInfo = contractList[index]
                        mHeaderKit.setFilterTitleContent(mCurrMarginCoinInfo?.name?:"")
                        val event = CpMessageEvent(CpMessageEvent.sl_contract_calc_switch_margin_coin_event)
                        event.msg_content = mCurrMarginCoinInfo?.name
                        CpEventBusUtil.post(event)
                    }
                })
            }
        }
    }

    companion object {
        fun show(activity: Activity, contractId: Int = 0) {
            val intent = Intent(activity, CpContractDetailActivity::class.java)
            intent.putExtra("contractId", contractId)
            activity.startActivity(intent)
        }
    }


}
