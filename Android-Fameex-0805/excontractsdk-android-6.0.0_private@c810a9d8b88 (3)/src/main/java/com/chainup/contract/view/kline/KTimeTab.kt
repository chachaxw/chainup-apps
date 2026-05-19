package com.chainup.contract.view.kline

import android.content.Context
import android.os.Build
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.widget.LinearLayout
import android.widget.TextView
import com.chainup.contract.R
import com.chainup.contract.utils.CpClLogicContractSetting
import com.chainup.contract.utils.CpKLineUtil
import com.google.android.material.tabs.TabLayout
import com.yjkj.chainup.new_contract.bean.CpKlineCtrlBean
import kotlinx.android.synthetic.main.cp_kline_tab_layout.view.*


/**
 *Kline timescale ->>>tab
 * */
class KTimeTab @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null
) : LinearLayout(context, attrs) {
    //Layout view
    private var mRootView:View? = null
    //Timescale data bean
    private var mklineCtrlList = ArrayList<CpKlineCtrlBean>()

    //Arrow button
    private var mArrowBtn: View? = null
    //Title displayed when collapsed
    var mSymbolTitle: TextView? = null
    //Open or not
    private var isOpen:Boolean = true

    private var mBottomBorder:View? = null
    //Event Interface Implementation Class
    var itemTimeClickListener:OnTimeTabItemClick? = null

    init {
        initKlineTab()
        initLayout()

    }

    private fun initLayout() {
        mRootView = LayoutInflater.from(context).inflate(R.layout.cp_kline_tab_layout,this,true)
        initView()
        setViewClick()
    }

    private fun setViewClick() {
        for (i in 0 until tb_time.getTabCount()) {
            val tab: TabLayout.Tab? = tb_time.getTabAt(i)
            if (tab != null) {
                tab.view.isLongClickable = false
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    tab.view.tooltipText = null
                }
            }
        }

        tb_time?.addOnTabSelectedListener(object:TabLayout.OnTabSelectedListener{
            override fun onTabSelected(tab: TabLayout.Tab?) {
                val position = tb_time.selectedTabPosition
                itemTimeClickListener?.itemClick(tab?.view!!,position,mklineCtrlList[position])
            }

            override fun onTabUnselected(tab: TabLayout.Tab?) {

            }

            override fun onTabReselected(tab: TabLayout.Tab?) {

            }

        })


        mArrowBtn?.setOnClickListener {
            toggleSliderView()
        }
        mSymbolTitle?.setOnClickListener{
            toggleSliderView()
        }

    }

    fun setSelectTab(position: Int){
        tb_time.selectTab(tb_time.getTabAt(position))
    }

    //Toggle On Off
    fun toggleSliderView(){
        isOpen = !isOpen

        //0 top 1 bottom
        when(CpClLogicContractSetting.getContractChartPosition(context)){
            0 -> {
                if(isOpen){
                    mArrowBtn?.animate()?.setDuration(300)?.rotation(180f)?.start()
                }else{
                    mArrowBtn?.animate()?.setDuration(300)?.rotation(0f)?.start()
                }
            }
            1 -> {
                if(isOpen){
                    mArrowBtn?.animate()?.setDuration(300)?.rotation(0f)?.start()
                }else{
                    mArrowBtn?.animate()?.setDuration(300)?.rotation(180f)?.start()
                }
            }
        }


        mSymbolTitle?.visibility = if(!isOpen) View.VISIBLE else View.GONE
        tb_time?.visibility = if(isOpen) View.VISIBLE else View.GONE
        itemTimeClickListener?.openToggle(isOpen)
    }

    private fun initView() {
        setTabData()

        mArrowBtn = mRootView?.findViewById(R.id.arrowBtn)

        mSymbolTitle = mRootView?.findViewById(R.id.symbolTitle)

        mBottomBorder = mRootView?.findViewById(R.id.bottom_border)


    }

    //Set tab data
    fun setTabData(){
        val tabDataListIterator = mklineCtrlList.iterator()
        while (tabDataListIterator.hasNext()){
            val itemTabData = tabDataListIterator.next()
            tb_time?.run {
                addTab(
                    newTab().apply {
                        text = CpKLineUtil.getShowKLineScaleName(itemTabData.time,context)
                        tag = itemTabData.time

                    }
                )
            }

        }

        tb_time.tabMode = TabLayout.MODE_SCROLLABLE

    }

    //Initialize tab data
    private fun initKlineTab() {
        mklineCtrlList.add(
            CpKlineCtrlBean(
                "line",
                CpKLineUtil.getCurTime4Index().equals(CpKLineUtil.getKLineScale().indexOf("line")),
                1
            )
        )

        mklineCtrlList.add(CpKlineCtrlBean("1min", CpKLineUtil.getCurTime4Index().equals(
            CpKLineUtil.getKLineScale().indexOf("1min")), 1))

        mklineCtrlList.add(CpKlineCtrlBean("5min", CpKLineUtil.getCurTime4Index().equals(
            CpKLineUtil.getKLineScale().indexOf("5min")), 1))


        mklineCtrlList.add(CpKlineCtrlBean("15min", CpKLineUtil.getCurTime4Index().equals(
            CpKLineUtil.getKLineScale().indexOf("15min")), 1))

        mklineCtrlList.add(CpKlineCtrlBean("30min", CpKLineUtil.getCurTime4Index().equals(
            CpKLineUtil.getKLineScale().indexOf("30min")), 1))

        mklineCtrlList.add(CpKlineCtrlBean("60min", CpKLineUtil.getCurTime4Index().equals(CpKLineUtil.getKLineScale().indexOf("1h")), 1))

        mklineCtrlList.add(CpKlineCtrlBean("4h", CpKLineUtil.getCurTime4Index().equals(CpKLineUtil.getKLineScale().indexOf("4h")), 1))

        mklineCtrlList.add(CpKlineCtrlBean("1day", CpKLineUtil.getCurTime4Index().equals(CpKLineUtil.getKLineScale().indexOf("1day")), 1))

        mklineCtrlList.add(CpKlineCtrlBean("1week", CpKLineUtil.getCurTime4Index().equals(CpKLineUtil.getKLineScale().indexOf("1week")), 1))

        mklineCtrlList.add(CpKlineCtrlBean("1month", CpKLineUtil.getCurTime4Index().equals(CpKLineUtil.getKLineScale().indexOf("1month")), 1))

    }

    interface OnTimeTabItemClick{
        fun itemClick(view:View,position:Int,dataBean:CpKlineCtrlBean,isNeedAppBarExpanded:Boolean=true)
        fun openToggle(isOpen:Boolean)
    }

    fun getPositionByTime(time:String):Int{
        for(index in mklineCtrlList.indices){
            val currentBean = mklineCtrlList[index]
            if(currentBean.time == time) return index
        }

        return -1
    }

    //Set whether the lower toilet box is displayed
    fun setBottomBorderVisible(isVis: Boolean){
        mBottomBorder?.visibility = if(isVis) View.VISIBLE else View.GONE
    }
}
