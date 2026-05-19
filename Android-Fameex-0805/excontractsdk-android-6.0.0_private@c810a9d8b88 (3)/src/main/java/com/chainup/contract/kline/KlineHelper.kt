package com.chainup.contract.kline

import android.view.View
import com.chainup.contract.view.kline.KTimeTab
import com.yjkj.chainup.kline.view.CpKLineChartView
import com.yjkj.chainup.new_contract.bean.CpKlineCtrlBean
import io.flutter.embedding.android.FlutterView

class KlineHelper private constructor() : KTimeTab.OnTimeTabItemClick{
    var kTimeTab:KTimeTab? = null
    var kline: FlutterView? = null
    var listener:OnKlineReload? = null
    //Whether to display kline
    var isShowKline:Boolean = true


    fun bindEvent(){
        this.kTimeTab?.itemTimeClickListener = this
    }

    companion object {
        //0 top 1 bottom
        var klinePosition:Int = 0

        //Place kTimeTab and kline
        fun init(kTimeTab:KTimeTab,kline:FlutterView) : KlineHelper{
            return KlineHelper().apply {
                this.kTimeTab = kTimeTab
                this.kline    = kline
                //Initialize to a hidden stowed state
                this.kTimeTab?.toggleSliderView()
                this.kline?.visibility = View.GONE
                isShowKline = false
                this.bindEvent()
            }
        }

    }


    override fun itemClick(view: View, position: Int, dataBean: CpKlineCtrlBean,isNeedAppBarExpanded:Boolean) {
        if(klinePosition==0 && isNeedAppBarExpanded){
            listener?.doAppBarExpanded()
        }
        listener?.clickTime(dataBean.time)
    }


    override fun openToggle(isOpen: Boolean) {
        isShowKline = isOpen
        kline?.visibility = if(isOpen) View.VISIBLE else View.GONE
        if(klinePosition==0){
            listener?.doAppBarExpanded()
        }

        listener?.onToggleOpen(isOpen)
    }


    interface OnKlineReload{
        fun reload()
        //External reset appBarlayout
        fun doAppBarExpanded()

        fun clickTime(time:String)
        fun onToggleOpen(isOpen: Boolean)
    }
}
