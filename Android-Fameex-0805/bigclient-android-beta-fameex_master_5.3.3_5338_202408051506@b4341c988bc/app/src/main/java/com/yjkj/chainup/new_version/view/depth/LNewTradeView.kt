package com.yjkj.chainup.new_version.view.depth

import androidx.lifecycle.Observer
import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.widget.LinearLayout
import com.chainup.contract.view.CpTabEntity
 import com.chainup.contract.view.dialog.CpTDialog
import com.flyco.tablayout.listener.CustomTabEntity
import com.flyco.tablayout.listener.OnTabSelectListener
import com.yjkj.chainup.R
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.ParamConstant.*
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.extra_service.eventbus.NLiveDataUtil
import com.yjkj.chainup.manager.CpLanguageUtil
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.LoginManager
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.model.model.MainModel
import com.yjkj.chainup.new_version.activity.NewMainActivity
import com.yjkj.chainup.new_version.activity.leverage.TradeFragment
import com.yjkj.chainup.util.*
import io.reactivex.disposables.CompositeDisposable
import kotlinx.android.synthetic.main.trade_amount_view_new_l.view.*
import org.json.JSONArray
import org.json.JSONObject

/**
 * @Author: Bertking
 * @Date 2023/3/7-5:43 PM
 *@description: View of transaction volume
 */
class LNewTradeView @JvmOverloads constructor(context: Context,
                                              attrs: AttributeSet? = null,
                                              defStyleAttr: Int = 0) : LinearLayout(context, attrs, defStyleAttr) {

    val TAG = LNewTradeView::class.java.simpleName


    private val delayTime = 100L

    //Transaction type
    var transactionType = ParamConstant.TYPE_BUY
    var isLever = false

    //Price Type
    var priceType = 0


    var priceScale = 2
    var volumeScale = 2
    var disposable: CompositeDisposable? = null
    var mainModel: MainModel? = null

    var dialog:  CpTDialog? = null
    var coinMapData: JSONObject? = NCoinManager.getSymbolObj(PublicInfoDataService.getInstance().currentSymbol)
        set(value) {
            
            field = value
            synchronized(this) {
                priceScale = value?.optInt("price", 2) ?: 2
                volumeScale = value?.optInt("volume", 2) ?: 2
            }

        }


    fun setPrice() {

        synchronized(this) {
            priceScale = coinMapData?.optInt("price", 2) ?: 2
            volumeScale = coinMapData?.optInt("volume", 2) ?: 2
        }

    }

    private fun showAnoterName(jsonObject: JSONObject?): String {
        return NCoinManager.showAnoterName(jsonObject)
    }

    /**
     *Obtain available balance
     */

    fun getAvailableBalance() {

        if (!LoginManager.checkLogin(context, false)) {
            /**
             *Available balance
             */
            //
            return
        }


    }

    fun setTextContent() {
//        tv_order_type?.textContent = LanguageUtil.getString(context, "contract_action_limitPrice")

    }

    init {
        attrs?.let {
            val typedArray = context.obtainStyledAttributes(it, R.styleable.ComVerifyView, 0, 0)
            typedArray.recycle()
        }


        LogUtil.d(TAG, "TradeView==init==priceScale is $priceScale,volumeScale is $volumeScale")
        /**
         *The value here must be: True
         */
        LayoutInflater.from(context).inflate(R.layout.trade_amount_view_new_l, this, true)

        setTextContent()

        observeData()

        NLiveDataUtil.observeData(this.context as NewMainActivity, Observer {
            if (it == null) return@Observer
            if (MessageEvent.login_operation_type == it.msg_type) {
                operator4PriceVolume(context)
            }
        })
        tab_order_type?.apply {
            var type= arrayOf(LanguageUtil.getString(context,"contract_action_limitPrice"),LanguageUtil.getString(context,"contract_action_marketPrice"))
            val typeList = arrayListOf<CustomTabEntity>()
            type.forEach {
                typeList.add(CpTabEntity(it,0,0))
            }
            this.setTabDataFont(typeList)
            this.currentTab=0
            this.setOnTabSelectListener(object : OnTabSelectListener{
                override fun onTabSelect(position: Int) {
                    priceType = position
                    this@LNewTradeView.trade_amount_view_buy_l?.changePriceTypeL(position)
                    this@LNewTradeView.trade_amount_view_sell_l?.changePriceTypeL(position)
                }

                override fun onTabReselect(position: Int) {
                }
            })
        }
        getAvailableBalance()
        operator4PriceVolume(context)

        addTextListener()
        loginStatusView()
        ktn_login?.isEnable(true)
        ktn_login?.setOnClickListener {
            if (!LoginManager.checkLogin(context, true)) return@setOnClickListener
        }

        this@LNewTradeView.trade_amount_view_buy_l?.transactionType=ParamConstant.TYPE_BUY
        this@LNewTradeView.trade_amount_view_sell_l?.transactionType=ParamConstant.TYPE_SELL
    }

    /**
     *Dealing with the relationship between price and volume events and login status
     */
    private fun operator4PriceVolume(context: Context) {
        priceScale = coinMapData?.optInt("price", 2) ?: 2
        volumeScale = coinMapData?.optInt("volume", 2) ?: 2
        setPrice()

    }


    private fun addTextListener() {

    }

    private fun observeData() {

        NLiveDataUtil.observeData((this.context as NewMainActivity), Observer<MessageEvent> {
            if (null == it)
                return@Observer

            if (TradeFragment.currentIndex == CVC_INDEX_TAB) {
                if (it.isLever) {
                    return@Observer
                }
            } else {
                if (!it.isLever) {
                    return@Observer
                }
            }

            when (it.msg_type) {
                MessageEvent.TAB_TYPE -> {
                    coinMapData = if (it.isLever) {
                        NCoinManager.getSymbolObj(PublicInfoDataService.getInstance().currentSymbol4Lever)
                    } else {
                        NCoinManager.getSymbolObj(PublicInfoDataService.getInstance().currentSymbol)
                    }

                    if (it.isLever) {
                        buyOrSell(0, it.isLever)
                    } else {
                        buyOrSell(0, it.isLever)
                    }

                }

                MessageEvent.symbol_switch_type -> {
                    if (null != it.msg_content) {
                        val symbol = it.msg_content as String
                        if (symbol != coinMapData?.optString("symbol", "")) {
                            coinMapData = NCoinManager.getSymbolObj(symbol)
                            getAvailableBalance()
                        }
                    }
                }

            }
        })
    }

    private fun showCoinName(): String? {
        return NCoinManager.getMarketShowCoinName(showAnoterName(coinMapData))
    }

    private fun showMarket(): String? {
        return NCoinManager.getMarketName(showAnoterName(coinMapData))
    }

    /**
     *Buy&Sell
     */
    fun buyOrSell(transferType: Int, isLever: Boolean = false) {
        this.isLever = isLever
        this@LNewTradeView.trade_amount_view_buy_l?.verticalDepth(true, true, isLever)
        this@LNewTradeView.trade_amount_view_sell_l?.verticalDepth(true, false, isLever)
    }


    private fun showBalanceData() {

    }

    fun editPriceIsNull(): Boolean {
        return false
    }

    fun initTick(tick: JSONArray, isBuy: Boolean = true, depthLevel: Int = 2) {
        LogUtil.e(TAG,"initTick  isBuy ${isBuy}")
        if (!isBuy) {
            if (isFirstSetValue(!isBuy)) {
                this@LNewTradeView.trade_amount_view_buy_l?.initTick(tick, depthLevel)
            }
        } else {
            if (isFirstSetValue(!isBuy)) {
                this@LNewTradeView.trade_amount_view_sell_l?.initTick(tick, depthLevel)
            }
        }

    }


    /**
     *In the case of price limit, the default price is: closing price
     */
    fun isFirstSetValue(isBuy: Boolean = true): Boolean {
        if (isBuy) {
            return   this@LNewTradeView.trade_amount_view_buy_l.editPriceIsNull()
        } else {
            return   this@LNewTradeView.trade_amount_view_sell_l.editPriceIsNull()
        }
    }

    fun resetPrice() {
        this@LNewTradeView.trade_amount_view_buy_l?.resetPrice()
        this@LNewTradeView.trade_amount_view_sell_l?.resetPrice()
    }

    fun changeSellOrBuyData(data: JSONObject?) {
        if (data != null) {
            this@LNewTradeView.trade_amount_view_buy_l?.changeSellOrBuyData(data)
            this@LNewTradeView.trade_amount_view_sell_l?.changeSellOrBuyData(data)
        }
    }

    fun loginStatusView() {
        val isLogin = UserDataService.getInstance().isLogined
        if (isLogin) {
            ktn_login.visibility = View.GONE
        } else {
            ktn_login.visibility = View.VISIBLE
        }
//        println("ktn_loginktn_loginktn_login = ${isLogin}")
        this@LNewTradeView.trade_amount_view_buy_l?.notLoginLayout(isLogin)
        this@LNewTradeView.trade_amount_view_sell_l?.notLoginLayout(isLogin)
    }

    fun changeETFInfo(data: JSONObject?){
        this@LNewTradeView.trade_amount_view_buy_l?.etfInfo = data
        this@LNewTradeView.trade_amount_view_sell_l?.etfInfo = data
    }

    fun initVolView(){
        this@LNewTradeView.trade_amount_view_buy_l?.initVolView()
        this@LNewTradeView.trade_amount_view_sell_l?.initVolView()
    }

    fun initClickData(tempPrice: String) {
        this@LNewTradeView.trade_amount_view_buy_l?.initClickData(tempPrice)
        this@LNewTradeView.trade_amount_view_sell_l?.initClickData(tempPrice)
    }

}




