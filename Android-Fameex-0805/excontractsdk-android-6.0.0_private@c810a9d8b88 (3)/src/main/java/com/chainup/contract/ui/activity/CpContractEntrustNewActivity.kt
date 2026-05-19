package com.chainup.contract.ui.activity

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.view.Gravity
import android.view.View
import android.widget.EditText
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.core.widget.addTextChangedListener
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.viewpager.widget.ViewPager
import com.chainup.contract.R
import com.chainup.contract.adapter.CpPageAdapter
import com.chainup.contract.base.CpNBaseActivity
import com.chainup.contract.bean.ContractListBean
import com.chainup.contract.bean.CpTabInfo
import com.chainup.contract.eventbus.CpEventBusUtil
import com.chainup.contract.eventbus.CpMessageEvent
import com.chainup.contract.listener.OnTDBindViewListener
import com.chainup.contract.ui.fragment.CpContractEntrustNewFragment
import com.chainup.contract.ui.fragment.CpContractHistoryEntrustNewFragment
import com.chainup.contract.ui.fragment.CpContractPLRecordFragment
import com.chainup.contract.ui.fragment.DialogSymbolFragment
import com.chainup.contract.utils.CpClLogicContractSetting
import com.chainup.contract.utils.CpPreferenceManager
import com.chainup.contract.utils.CpNToastUtil
import com.chainup.contract.utils.getLineText
import com.chainup.contract.utils.setSafeListener
import com.chainup.contract.utils.toDinproMedium
import com.chainup.contract.view.CpDialogUtil
import com.chainup.contract.view.CpNewDialogUtils
import com.chainup.contract.view.dialog.CpTDialog
import com.chainup.kit.views.PublicHeaderKit
import com.chainup.talkingdata.AppAnalyticsExt
import com.flyco.tablayout.SlidingTabLayout
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.jaeger.library.StatusBarUtil
import com.timmy.tdialog.TDialog
import com.timmy.tdialog.base.BindViewHolder
import com.timmy.tdialog.listener.OnBindViewListener
import com.yjkj.chainup.manager.CpLanguageUtil
import com.yjkj.chainup.net_new.rxjava.CpNDisposableObserver
import com.yjkj.chainup.new_contract.bean.CpCurrentOrderBean
import kotlinx.android.synthetic.main.cp_activity_contract_entrust.*
import kotlinx.android.synthetic.main.cp_activity_contract_entrust_new.*
import kotlinx.android.synthetic.main.cp_activity_contract_entrust_new.sub_tab_layout
import org.json.JSONObject

/**
 *Contract current/historical entrustment/profit and loss records
 */
class CpContractEntrustNewActivity : CpNBaseActivity() {
    override fun setContentView() = R.layout.cp_activity_contract_entrust_new

    //The currently selected currency pair
    private var mCurrContractInfo: CpTabInfo? = null

    //Price limit and plan entrustment
    private var entrustList = ArrayList<CpTabInfo>()
    private var mCurrEntrustInfo: CpTabInfo? = null


    //Contract Order Type
    private var typeList = ArrayList<CpTabInfo>()
    private var mCurrTypeInfo: CpTabInfo? = null

    private var viewPagePosition: Int = 0

    //The above tab switches the text array
    private var tabTitles =  arrayOfNulls<String>(3)
    private var isAllCoins = false

    private val currentEntrustFragment:CpContractEntrustNewFragment by lazy { CpContractEntrustNewFragment() }
//    private var tabTitles = arrayOf(CpLanguageUtil.getString(this,"cp_order_text51"), CpLanguageUtil.getString(this,"cp_order_text72"), CpLanguageUtil.getString(this,"cp_order_text73"))

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        StatusBarUtil.setColor(this,ContextCompat.getColor(this,R.color.bg_card_color),0)
        loadData()
        initView()
    }

    override fun loadData() {
        tabTitles.set(0,CpLanguageUtil.getString(this,"cp_order_text51"))
        tabTitles.set(1,CpLanguageUtil.getString(this,"cp_order_text72"))
        tabTitles.set(2,CpLanguageUtil.getString(this,"cp_order_text73"))
        mContractId = intent.getIntExtra("contractId", -1)
        //Price limit/plan entrustment
        entrustList.add(CpTabInfo(CpLanguageUtil.getString(this,"cp_extra_text20"), 0))
        entrustList.add(CpTabInfo(CpLanguageUtil.getString(this,"cp_order_text61"), 1))
        mCurrEntrustInfo = entrustList[0]

        //Contract Order Type
        typeList.add(CpTabInfo(CpLanguageUtil.getString(this,"OpenOrder_text2"), 0))
        typeList.add(CpTabInfo(CpLanguageUtil.getString(this,"cp_overview_text3"), 1))
        typeList.add(CpTabInfo(CpLanguageUtil.getString(this,"cp_extra_text149"), 5))
        mCurrTypeInfo = typeList[0]

        mCurrContractInfo = CpTabInfo("", 0)

    }

    override fun initView() {
        tv_entrust_type.text=getLineText("cp_extra_text20")
        tv_order_type.text=getLineText("OpenOrder_text2")
        tv_contract_direction.text=getLineText("cp_order_text98")

        val isCheckCurrentContract = CpPreferenceManager.getInstance(mActivity).getSharedBoolean(CpPreferenceManager.PREF_SHOW_CURRENT_CONTRACT_CurrentEntrust, false)
        tv_coins_name.text = if(isCheckCurrentContract){
            isAllCoins = false
            CpClLogicContractSetting.getContractShowNameById(this, mContractId)
        }else{
            isAllCoins = true
            CpLanguageUtil.getString(mActivity,"OpenOrder_text1")
        }

        mHeaderKit?.run {
            listener = object: PublicHeaderKit.IOnBackClickListener{
                override fun onRightBtn(view: View) {
                    super.onRightBtn(view)
                    AppAnalyticsExt.instance.clickAction(AppAnalyticsExt.APP_FUTURES_ORDERS_CANCEL_ALL)
                    cancelOrder()
                }
            }
        }

        initTabInfo()

        //Select a contract currency pair
        ll_sel_coins.setOnClickListener {
            //New Version
            CpNewDialogUtils.createBottomSearchVpDialog(this, if(isAllCoins) -2 else mContractId,
                listener = object: CpNewDialogUtils.DialogOnSigningItemClickListener{
                    override fun clickItem(position: Int, text: String) {
                        //Here, EventBus: sl is sent internally_ contract_ record_ switch_ contract_ Event to the fg in the current vp
                        mContractId = position
                        isAllCoins  = mContractId == -2
                        tv_coins_name.setText(CpClLogicContractSetting.getContractShowNameById(this@CpContractEntrustNewActivity, mContractId))
                    }
                },
                isHasAll = true
            )
        }

        //Select Delegate Type
        ll_entrust_type.setOnClickListener {
            var dialog: CpTDialog? = null
            dialog = CpNewDialogUtils.showNewBottomListDialog(
                this,entrustList,
                if(mCurrEntrustInfo==null) 0 else mCurrEntrustInfo!!.index,
                listener = object:CpNewDialogUtils.DialogOnItemClickListener{
                    override fun clickItem(position: Int) {
                        mCurrEntrustInfo = entrustList[position]
                        updateTypeList()
                        //Set display text
                        tv_entrust_type.setText(mCurrEntrustInfo?.name)

                        //Reset the contract order type to all every time the delegation type is updated
                        mCurrTypeInfo = typeList[0]
                        tv_order_type.text = mCurrTypeInfo?.name

                        val event = CpMessageEvent(CpMessageEvent.sl_contract_record_switch_entrust_type_event)
                        val bundle = Bundle().apply {
                            putBoolean("isCommonEntrust",position == 0)
                            putInt("orderType",mCurrTypeInfo!!.index)
                        }
                        event.msg_content = (bundle)
                        CpEventBusUtil.post(event)


                        dialog?.dismiss()
                    }
                }
            )
        }

        //Select contract order type
        ll_contract_type.setOnClickListener {
            var dialog:CpTDialog? = null
            dialog = CpNewDialogUtils.showNewBottomListDialog(
                this,typeList,
                if(mCurrTypeInfo==null) 0 else mCurrTypeInfo!!.index,
                listener = object:CpNewDialogUtils.DialogOnItemClickListener{
                    override fun clickItem(position: Int) {

                        mCurrTypeInfo = typeList[position]
                        tv_order_type.setText(mCurrTypeInfo?.name)

                        val event = CpMessageEvent(CpMessageEvent.sl_contract_record_switch_order_type_event)
                        event.msg_content = mCurrTypeInfo!!.index
                        CpEventBusUtil.post(event)
                        dialog?.dismiss()
                    }

                }
            )

        }

    }




    private var mFragments: ArrayList<Fragment>? = null
    private fun initTabInfo() {
        mFragments = ArrayList()
        mFragments?.add(currentEntrustFragment)
        mFragments?.add(CpContractHistoryEntrustNewFragment())
        mFragments?.add(CpContractPLRecordFragment())
        sub_tab_layout.setViewPager(vp_order,tabTitles, this, mFragments)
        for(i in 0 until sub_tab_layout.tabCount){
            sub_tab_layout.getTitleView(i).toDinproMedium()
        }

        vp_order.addOnPageChangeListener(object : ViewPager.OnPageChangeListener {
            override fun onPageScrollStateChanged(state: Int) {
            }

            override fun onPageScrolled(position: Int, positionOffset: Float, positionOffsetPixels: Int) {
            }

            override fun onPageSelected(position: Int) {
//                mHeaderKit?.titleText = tabTitles[position]
                //If the filter on the profit and loss activity is not displayed
                ll_sel_ctrl.visibility = if(position==2) View.GONE else View.VISIBLE
                viewPagePosition = position

                updateTypeList()
                if (position == 0) {
                    getListToRightTv()
                } else {
                    mHeaderKit?.mIsShowRightBtn = false
                }

            }
        })
    }

    //
    fun updateTypeList(){
        typeList.clear()
        if (viewPagePosition == 0) {
            if(mCurrEntrustInfo?.index==0){
                //General entrustment
                typeList.add(CpTabInfo(CpLanguageUtil.getString(this@CpContractEntrustNewActivity,"OpenOrder_text2"), 0))
                typeList.add(CpTabInfo(CpLanguageUtil.getString(this@CpContractEntrustNewActivity,"cp_overview_text3"), 1))
                typeList.add(CpTabInfo(CpLanguageUtil.getString(this@CpContractEntrustNewActivity,"cp_extra_text149"), 5))
            }else{
                //Plan Delegation
                typeList.add(CpTabInfo(CpLanguageUtil.getString(this@CpContractEntrustNewActivity,"OpenOrder_text2"), 0))
                typeList.add(CpTabInfo(CpLanguageUtil.getString(this@CpContractEntrustNewActivity,"cp_overview_text3"), 1))
                typeList.add(CpTabInfo(CpLanguageUtil.getString(this@CpContractEntrustNewActivity,"cp_overview_text4"), 2))
            }

        } else {//Historical entrustment
            if(mCurrEntrustInfo?.index == 0){
                //General entrustment
                typeList.add(CpTabInfo(CpLanguageUtil.getString(this@CpContractEntrustNewActivity,"OpenOrder_text2"), 0))
                typeList.add(CpTabInfo(CpLanguageUtil.getString(this@CpContractEntrustNewActivity,"cp_overview_text3"), 1))
                typeList.add(CpTabInfo(CpLanguageUtil.getString(this@CpContractEntrustNewActivity,"cp_overview_text4"), 2))
                typeList.add(CpTabInfo(CpLanguageUtil.getString(this@CpContractEntrustNewActivity,"cp_extra_text149"), 5))
                typeList.add(CpTabInfo(CpLanguageUtil.getString(this@CpContractEntrustNewActivity,"cp_extra_text161"), 3))
                typeList.add(CpTabInfo(CpLanguageUtil.getString(this@CpContractEntrustNewActivity,"cp_extra_text160"), 4))
            }else{
                //Plan Delegation
                typeList.add(CpTabInfo(CpLanguageUtil.getString(this@CpContractEntrustNewActivity,"OpenOrder_text2"), 0))
                typeList.add(CpTabInfo(CpLanguageUtil.getString(this@CpContractEntrustNewActivity,"cp_overview_text3"), 1))
                typeList.add(CpTabInfo(CpLanguageUtil.getString(this@CpContractEntrustNewActivity,"cp_overview_text4"), 2))
            }

        }
    }


    fun getListToRightTv() {
        mHeaderKit?.mIsShowRightBtn = false
        if(viewPagePosition!=0) return
        val fg = mFragments?.get(0) as CpContractEntrustNewFragment
        fg.adapter?.run{
            if(data.size>0){
                mHeaderKit?.mIsShowRightBtn = true
                mHeaderKit?.setTvRightText(CpLanguageUtil.getString(this@CpContractEntrustNewActivity,"cp_order_text52"))
            }
        }
    }


    private fun cancelOrder() {
        val contractId = if(currentEntrustFragment.mContractId==-2) "" else mContractId.toString()

        CpNewDialogUtils.showDialogNew(
            mActivity,
            CpLanguageUtil.getString(this,"cp_overview_text58"),
            false,
            object : CpNewDialogUtils.DialogBottomListener {
                override fun sendConfirm() {
                    //get select type
                    val sType = mCurrTypeInfo?.let {
                        if(it.index == 0) null else it.index
                    }

                    addDisposable(
                        getContractModel().orderCancel(
                            contractId,
                            "",
                            mCurrEntrustInfo?.index == 1,
                            type = sType,
                            consumer = object : CpNDisposableObserver(mActivity, true) {
                                override fun onResponseSuccess(jsonObject: JSONObject?) {
                                    CpNToastUtil.showTopToast(false, CpLanguageUtil.getString(this@CpContractEntrustNewActivity,"cp_content_text3"))
                                    val event = CpMessageEvent(CpMessageEvent.sl_contract_record_switch_entrust_type_event)
                                    event.msg_content = (mCurrEntrustInfo?.index == 0)
                                    CpEventBusUtil.post(event)

                                }
                            })
                    )
                }
            },
            cancelTitle = CpLanguageUtil.getString(this,"cp_overview_text56"),
            confrimTitle = CpLanguageUtil.getString(this,"cp_calculator_text16"),
            contentGravity = Gravity.CENTER
        )

    }


    companion object {
        fun show(activity: Activity, contractId: Int = 0, contractName: String) {
            val intent = Intent(activity, CpContractEntrustNewActivity::class.java)
            val bundle = Bundle()
            bundle.putInt("contractId", contractId)
            bundle.putString("contractName", contractName)
            intent.putExtras(bundle)
            activity.startActivity(intent)
        }

        var mContractId = -1
    }
}