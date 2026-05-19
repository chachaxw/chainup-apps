package com.yjkj.chainup.treaty.fragment

import androidx.lifecycle.MutableLiveData
import android.os.Bundle
import androidx.fragment.app.Fragment
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.LinearLayoutManager
import android.text.Editable
import android.text.TextUtils
import android.text.TextWatcher
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.yjkj.chainup.util.JsonUtils
 import com.chainup.contract.view.dialog.CpTDialog
import com.yjkj.chainup.R
import com.yjkj.chainup.app.ChainUpApp
import com.yjkj.chainup.bean.EntrustBean
import com.yjkj.chainup.bean.QuotesData
import com.yjkj.chainup.bean.TransactionData
import com.yjkj.chainup.manager.Contract2PublicInfoManager
import com.yjkj.chainup.manager.LoginManager
import com.yjkj.chainup.net.HttpClient
import com.yjkj.chainup.net.api.ApiConstants
import com.yjkj.chainup.net.retrofit.NetObserver
import com.yjkj.chainup.util.DecimalDigitsInputFilter
import com.yjkj.chainup.new_version.dialog.DialogUtil
import com.yjkj.chainup.new_version.view.EmptyForAdapterView
import com.yjkj.chainup.treaty.*
import com.yjkj.chainup.treaty.adapter.ContractCurrentEntrustOrderAdapter
import com.yjkj.chainup.treaty.bean.*
import com.yjkj.chainup.treaty.dialog.ContractDialog
import com.yjkj.chainup.util.*
import io.reactivex.Observable
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.observers.DisposableObserver
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.fragment_entrust_deal.*
import kotlinx.android.synthetic.main.item_active_entrust_dealt.view.*
import kotlinx.android.synthetic.main.item_depth_contract.view.*
import kotlinx.android.synthetic.main.layout_entrust_orders_treaty.*
import kotlinx.android.synthetic.main.layout_trade_treaty.*
import org.greenrobot.eventbus.EventBus
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode
import org.java_websocket.client.WebSocketClient
import org.java_websocket.handshake.ServerHandshake
import org.jetbrains.anko.doAsync
import org.jetbrains.anko.support.v4.toast
import org.jetbrains.anko.textColor
import org.jetbrains.anko.uiThread
import org.json.JSONObject
import java.net.URI
import java.nio.ByteBuffer
import java.util.concurrent.TimeUnit

/**
 * @author Bertking
 *@description "Entrusted transaction" of the contract
 * @Date 2023-1-10
 *
 *The TODO cost, available balance, and so on are currently fixed in accuracy and may need to be modified to be dynamic in the future
 */
class EntrustDealFragment : Fragment(), DialogUtil.ConfirmListener {
    val TAG = EntrustDealFragment::class.java.simpleName

    var tDialog:  CpTDialog? = null
    private var contractId = 0
    private var currentLevel = ""

    private var currentSymbol = ""

    lateinit var currentContract: ContractBean

    private var marketType = LIMIT_TRADE
    /**
     *Buying and selling direction
     */
    private var side = BUY_SIDE

    private lateinit var mSocketClient: WebSocketClient

    private val red = ContextCompat.getColor(ChainUpApp.appContext, R.color.red)
    private val green = ContextCompat.getColor(ChainUpApp.appContext, R.color.green)
    private val mainFontColor = ContextCompat.getColor(ChainUpApp.appContext, R.color.main_font_color)

    /**
     *Marking
     */
    private var isEditMode = false


    /**
     *Selling items
     */
    private var sellViewList = mutableListOf<View>()
    /**
     *Buying items
     */
    private var buyViewList = mutableListOf<View>()

    /**
     *Adapter for activity delegation
     */
    var adapter = ContractCurrentEntrustOrderAdapter(arrayListOf())


    var initOrderPrice = ""


    private var chooseLevelViewList = lazy {
        arrayListOf(tv_lever, iv_lever, stv_select_level)
    }


    override fun click(pos: Int) {
        tDialog?.dismissAllowingStateLoss()
        changeLevel(pos)
    }


    // TODO: Rename and change types of parameters
    private val CONTRACT_ID = "contract_id"

    private var disposables = CompositeDisposable()

    /**
     *TODO post optimization
     */
    private var disposables4OrderList = CompositeDisposable()


    companion object {
        @JvmStatic
        fun newInstance(contractId: Int = 0) =
                EntrustDealFragment().apply {
                    arguments = Bundle().apply {
                        putInt(CONTRACT_ID, contractId)
                    }
                }

        var liveData: MutableLiveData<String> = MutableLiveData()

        /**
         *Limit trading
         */
        const val LIMIT_TRADE = 1
        /**
         *Market value trading
         */
        const val MARKET_TRADE = 2

        /**
         *Buy/Long
         */
        const val SELL_SIDE = "SELL"
        /**
         *Sell/Short
         */
        const val BUY_SIDE = "BUY"

    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        arguments?.let {
            contractId = it.getInt(CONTRACT_ID, 0)
        }

    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?,
                              savedInstanceState: Bundle?): View? {
        // Inflate the layout for this fragment
//        contractId = arguments?.getInt(ChangeTreatyActivity.CONTRACT)!!
        var mainView = inflater.inflate(R.layout.fragment_entrust_deal, container, false)
        if (!EventBus.getDefault().isRegistered(this)) {
            EventBus.getDefault().register(this)
        }
        return mainView
    }

    override fun onResume() {
        super.onResume()
        contractId = Contract2PublicInfoManager.currentContractId()
        currentContract = Contract2PublicInfoManager.currentContract() ?: return
        isEditMode = false

        loopPriceRiskPosition()

        if (!LoginManager.checkLogin(context, false)) {
            et_price?.isFocusableInTouchMode = false
            et_position?.isFocusableInTouchMode = false
            currentLevel = currentContract.maxLeverageLevel.toString()
            stv_select_level?.text = currentLevel + "x"
            tv_lever?.text = StringUtils.getString(R.string.title_lever) + currentLevel + "x"
        } else {
            getInitOrderInfo()
            if (et_position?.isFocusableInTouchMode?.not() == true) {
                et_position?.isFocusable = true
                et_position?.isFocusableInTouchMode = true
                et_position?.requestFocus()
                et_position?.findFocus()
            }
            if (et_price?.isFocusableInTouchMode?.not() == true) {
                et_price?.isFocusable = true
                et_price?.isFocusableInTouchMode = true
                et_price?.requestFocus()
                et_price?.findFocus()
            }
        }

        et_price?.filters = arrayOf(DecimalDigitsInputFilter(currentContract.pricePrecision
                ?: 4))
        loopOrderList4Contract()

        tv_limit_contract_name?.text = currentContract.quoteSymbol
        tv_market_contract_name?.text = currentContract.quoteSymbol

        val contractType = when (currentContract.contractType) {
            1 -> StringUtils.getString(R.string.week_of_contract)
            2 -> StringUtils.getString(R.string.In_the_contract)
            else -> {
                StringUtils.getString(R.string.contract_sustainable)
            }
        }

        tv_choose_contract?.text = currentContract.baseSymbol + "*" + contractType + "(" + currentContract.maxLeverageLevel + "x" + ")"


        

        
        if (::mSocketClient.isInitialized) {
            
            subCurrentContractMsg()
        } else {
            
            initSocket()
        }
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        initCostAndBalance()

        rv_active_orders?.setHasFixedSize(true)
        rv_active_orders?.layoutManager = LinearLayoutManager(context)
        rv_active_orders?.adapter = adapter
        adapter.setEmptyView(EmptyForAdapterView(context ?: return))
        adapter.setOnItemChildClickListener { adapter, view, position ->
            view.tv_order_status?.setOnClickListener {
                //ToastUtils. showToast ("TEST Cancel Order")
                if (adapter?.data?.isNotEmpty() == true) {
                    try {
                        var item = adapter.data.get(position) as ActiveOrderListBean.Order?
                        when (item?.status) {
                            0, 1, 3 -> {
                                cancelOrder(item.orderId.toString(), item.contractId.toString(), position)
                            }
                        }
                    } catch (e: java.lang.Exception) {
                        e.printStackTrace()
                    }
                }
            }
        }

        /**
         *Historical commission
         */
        iv_entrust_record?.setOnClickListener {
            if (!LoginManager.checkLogin(activity, true)) return@setOnClickListener
//            ContractHistoryEntrustActivity.enter2(context!!)
        }

        et_price.setOnFocusChangeListener { v, hasFocus ->
            val resource = if (hasFocus) R.drawable.new_item_bg_focus else R.drawable.new_item_bg_unfocus
            ll_contract_price?.setBackgroundResource(resource)
        }

        et_position.setOnFocusChangeListener { v, hasFocus ->
            val resource = if (hasFocus) R.drawable.new_item_bg_focus else R.drawable.new_item_bg_unfocus
            ll_position.setBackgroundResource(resource)
        }


        initDepthView()

        onTipsClick()

        et_position?.setText("1")
        et_position?.setSelection(1)

        rg_trade_type?.setOnCheckedChangeListener { group, checkedId ->
            when (checkedId) {
                /**
                 *Price limit
                 */
                R.id.rb_limit -> {
                    marketType = LIMIT_TRADE
                    ll_contract_price?.visibility = View.VISIBLE
                    tv_market_trade_tip?.visibility = View.GONE
                    var volume = et_position?.text.toString()
                    
                    getInitOrderInfo(volume, currentLevel)
                }
                /**
                 *Market price
                 */
                R.id.rb_market -> {
                    marketType = MARKET_TRADE
                    ll_contract_price?.visibility = View.GONE
                    tv_market_trade_tip?.visibility = View.VISIBLE
                    var volume = et_position?.text.toString()
                    
                    getInitOrderInfo(volume, currentLevel)
                }
            }
        }


        /**
         *Select lever
         */
        chooseLevelViewList.value.forEach {
            it.setOnClickListener {
                if (!LoginManager.checkLogin(activity, true)) return@setOnClickListener
                tDialog = DialogUtil.showSelectLevelDialog(context!!, contractId, currentLevel, this)
                tDialog?.show()
            }
        }


        /**
         *Switch contracts
         */
        tv_choose_contract?.setOnClickListener {
        }

        /**
         *Kaiduo
         */
        tv_open_more?.setOnClickListener {
            tv_open_more?.textColor = green
            tv_open_empty?.textColor = mainFontColor
            tv_open_empty?.setCompoundDrawablesRelativeWithIntrinsicBounds(0, 0, 0, 0)
            tv_open_more?.setCompoundDrawablesRelativeWithIntrinsicBounds(0, 0, 0, R.drawable.bg_buy_line)
            tv_place_order?.solid = green
            tv_place_order?.text = StringUtils.getString(R.string.contract_action_buy)
            side = BUY_SIDE
        }

        /**
         *Open air
         */
        tv_open_empty?.setOnClickListener {
            tv_open_empty?.textColor = red
            tv_open_more?.textColor = mainFontColor
            tv_open_more?.setCompoundDrawablesRelativeWithIntrinsicBounds(0, 0, 0, 0)
            tv_open_empty?.setCompoundDrawablesRelativeWithIntrinsicBounds(0, 0, 0, R.drawable.bg_sell_line)
            tv_place_order?.solid = red
            side = SELL_SIDE
            tv_place_order?.text = StringUtils.getString(R.string.contract_action_sell)
        }

        /**
         *Place an order
         *If it is a 'market price list', 'price' uses init_ Take_ The price field returned by the order interface
         */
        tv_place_order?.setOnClickListener {
            if (!LoginManager.checkLogin(activity, true)) return@setOnClickListener
            if (marketType == LIMIT_TRADE) {
                if (TextUtils.isEmpty(et_position?.text)) {
                    toast(StringUtils.getString(R.string.contract_tip_pleaseInputPosition))
                    return@setOnClickListener
                }

                if (TextUtils.isEmpty(et_price?.text)) {
                    toast(StringUtils.getString(R.string.contract_tip_pleaseInputPrice))
                    return@setOnClickListener
                }

                takeOrder(et_position?.text.toString(), et_price?.text.toString())
            } else {
                if (TextUtils.isEmpty(et_position.text)) {
                    toast(StringUtils.getString(R.string.contract_tip_pleaseInputPosition))
                    return@setOnClickListener
                }
                takeOrder(et_position?.text.toString(), initOrderPrice)
            }
        }


        et_price?.setOnClickListener {
            LoginManager.checkLogin(activity, true)
        }
        et_position?.setOnClickListener {
            LoginManager.checkLogin(activity, true)
        }


        /**
         *Monitor Bin Input Box
         */

        et_position?.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(s: Editable?) {
                if (TextUtils.isEmpty(s)) {
                    initCostAndBalance()
                } else {
                    getInitOrderInfo(s.toString(), currentLevel)
                }
            }

            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {

            }

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {

            }

        })


        /**
         *Listening to the price limit input box
         */
        et_price?.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(s: Editable?) {
                getInitOrderInfo(et_position?.text.toString(), currentLevel)
            }

            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {

            }

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
                isEditMode = true
            }

        })


    }

    private fun initCostAndBalance() {
        tv_entrust_value?.text = StringUtils.getString(R.string.contract_text_entrustValue) + ": --"
        tv_can_use_balance?.text = StringUtils.getString(R.string.subtitle_available_balance) + ": --"
        tv_cost?.text = StringUtils.getString(R.string.cost) + ": --"
    }


    /**
     *Call the interface every 5 seconds
     */
    private fun loopPriceRiskPosition() {
        disposables.add(Observable.interval(0, 5, TimeUnit.SECONDS).subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribeWith(getObserver()))
    }

    private fun getObserver(): DisposableObserver<Long> {
        return object : DisposableObserver<Long>() {
            override fun onComplete() {
            }

            override fun onNext(t: Long) {
                loopTagPrice()
                loopRiskFactor()
                loopPosition4Contract()
            }

            override fun onError(e: Throwable) {
            }
        }

    }


    /**
     *Polling Mark Price Interface
     */
    fun loopTagPrice() {
        HttpClient.instance
                .getTagPrice4Contract(contractId = contractId.toString())
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<TagPriceBean>() {
                    override fun onHandleSuccess(bean: TagPriceBean?) {
                        tv_tag_price?.text = bean?.indexPrice.toString() + "/" + bean?.tagPrice

                        /**
                         *Price Default: Tag Price
                         */
                        if (!isEditMode) {
                            et_price?.setText(bean?.tagPrice.toString())
                            et_price?.setSelection(bean?.tagPrice.toString().length)
                        }
                    }

                    override fun onHandleError(code: Int, msg: String?) {
                        super.onHandleError(code, msg)
                        
                    }
                })
    }

    /**
     *Polling risk coefficient interface
     */
    fun loopRiskFactor() {
        if (!LoginManager.checkLogin(activity, false)) {
            initCostAndBalance()
            return
        }
        HttpClient.instance
                .getRiskLiquidationRate(contractId = contractId.toString())
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<LiquidationRateBean>() {
                    override fun onHandleSuccess(bean: LiquidationRateBean?) {
                        
                        csrv_risk?.liveData?.postValue(bean?.liquidationRate?.toFloat())
                    }

                    override fun onHandleError(code: Int, msg: String?) {
                        
                    }
                })
    }

    /**
     *Polling user position information
     */
    private fun loopPosition4Contract() {
        if (!LoginManager.checkLogin(activity, false)) {
            tv_contract_id?.setBottom("--")
            tv_realised_rate?.setBottom("--")
            tv_open_position_price?.setBottom("--")
            tv_liquidation_price?.setBottom("--")
            return
        }

        HttpClient.instance
                .getPosition4Contract(contractId = contractId.toString())
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<UserPositionBean>() {
                    override fun onHandleSuccess(bean: UserPositionBean?) {
                        

                        val positions = bean?.positions


                        if (positions?.isNotEmpty() == true) {
                            val position = positions[0]

                            /**
                             *Contract price accuracy (price accuracy is based on this truncation)
                             */
                            val pricePrecision = position?.pricePrecision ?: 2

                            /**
                             *The value is intercepted based on this
                             */
                            val valuePrecision = position?.valuePrecision ?: 4

                            
                            tv_contract_id?.setBottom(position?.volume.toString())
                            tv_realised_rate?.setBottom(position?.unrealisedRateMarket.toString() + "%")

                            /**
                             *Opening price
                             */
                            val avgPriceByPrecision = Contract2PublicInfoManager.cutValueByPrecision(position?.avgPrice.toString(), pricePrecision)
                            tv_open_position_price?.setBottom(avgPriceByPrecision)
                            /**
                             *Qiangping Price
                             */
                            val liquidationPriceByPrecision = Contract2PublicInfoManager.cutValueByPrecision(position?.liquidationPrice.toString(), pricePrecision)
                            tv_liquidation_price?.setBottom(liquidationPriceByPrecision)
                        } else {
                            tv_contract_id?.setBottom("--")
                            tv_realised_rate?.setBottom("--")
                            tv_open_position_price?.setBottom("--")
                            tv_liquidation_price?.setBottom("--")
                        }

                    }

                    override fun onHandleError(code: Int, msg: String?) {
//                        ToastUtils.showToast(msg)
                        
                        tv_contract_id?.setBottom("--")
                        tv_realised_rate?.setBottom("--")
                        tv_open_position_price?.setBottom("--")
                        tv_liquidation_price?.setBottom("--")

                    }
                })
    }


    /**
     *Modify lever
     */
    private fun changeLevel(position: Int) {
        if (!LoginManager.checkLogin(activity, false)) return
        HttpClient.instance
                .changeLevel4Contract(contractId = contractId.toString(), newLevel = Contract2PublicInfoManager.getLevelsByContractId(contractId)[position])
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<Any>() {
                    override fun onHandleSuccess(bean: Any?) {
                        currentLevel = Contract2PublicInfoManager.getLevelsByContractId(contractId)[position]
                        stv_select_level?.text = currentLevel + "x"
                        tv_lever?.text = StringUtils.getString(R.string.title_lever) + currentLevel + "x"
                        

                        
                        getInitOrderInfo(et_position?.text.toString(), currentLevel)
                    }

                    override fun onHandleError(code: Int, msg: String?) {
                        ToastUtils.showToast(msg)
                        
                    }
                })
    }

    /**
     *Order initialization information
     */
    fun getInitOrderInfo(volume: String = et_position?.text.toString(), lever: String = "") {

        var price = if (marketType == LIMIT_TRADE) {
            et_price?.text.toString()
        } else {
            ""
        }
        HttpClient.instance
                .getInitTakeOrderInfo4Contract(contractId = contractId.toString()
                        , volume = volume,
                        price = price,
                        level = lever,
                        orderType = marketType)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<InitTakeOrderBean>() {
                    override fun onHandleSuccess(bean: InitTakeOrderBean?) {
                        

                        initOrderPrice = bean?.price ?: ""

                        currentLevel = bean?.level.toString()
                        stv_select_level?.text = currentLevel + "x"
                        tv_lever?.text = StringUtils.getString(R.string.title_lever) + currentLevel + "x"
                        val contractType = when (currentContract.contractType) {
                            1 -> StringUtils.getString(R.string.week_of_contract)
                            2 -> StringUtils.getString(R.string.In_the_contract)
                            else -> {
                                StringUtils.getString(R.string.contract_sustainable)
                            }
                        }

                        tv_choose_contract?.text = currentContract.baseSymbol + "*" + contractType + "(" + currentLevel + "x" + ")"

                        /**
                         *Entrustment value
                         */
                        val orderPriceValueByPrecision = Contract2PublicInfoManager.cutValueByPrecision(bean?.orderPriceValue.toString(), 4)
                        tv_entrust_value?.text = StringUtils.getString(R.string.contract_text_entrustValue) + ": $orderPriceValueByPrecision"

                        /**
                         *Available balance
                         */
                        val canUseBalanceByPrecision = Contract2PublicInfoManager.cutValueByPrecision(bean?.canUseBalance.toString(), 4)
                        tv_can_use_balance?.text =
                                StringUtils.getString(R.string.withdraw_text_available) + ": $canUseBalanceByPrecision"

                        if (side == SELL_SIDE) {
                            val sellOrderCostByPrecision = Contract2PublicInfoManager.cutValueByPrecision(bean?.sellOrderCost.toString(), 4)
                            tv_cost?.text = StringUtils.getString(R.string.cost) + ": $sellOrderCostByPrecision"
                        } else {
                            val bugOrderCostByPrecision = Contract2PublicInfoManager.cutValueByPrecision(bean?.buyOrderCost.toString(), 4)
                            tv_cost?.text = StringUtils.getString(R.string.cost) + ": $bugOrderCostByPrecision"
                        }

                    }

                    override fun onHandleError(code: Int, msg: String?) {
                        
                    }
                })
    }

    /**
     *Place an order
     */
    private fun takeOrder(volume: String = "1", price: String) {
        HttpClient.instance
                .takeOrder4Contract(contractId = contractId.toString()
                        , volume = volume,
                        price = price,
                        orderType = marketType,
                        side = side,
                        level = currentLevel
                )
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<Any>() {
                    override fun onHandleSuccess(bean: Any?) {
                        
                        et_price?.setText("")
                        ToastUtils.showToast(context?.getString(R.string.contract_tip_submitSuccess))
                        getOrderList4Contract()
                        getInitOrderInfo(currentLevel)
                    }

                    override fun onHandleError(code: Int, msg: String?) {
                        ToastUtils.showToast(msg)
                        
                    }
                })
    }

    /**
     *Activity Delegation List
     */
    private fun getOrderList4Contract() {
        if (!LoginManager.checkLogin(activity, false)) return
//        HttpClient.instance
//                .getOrderList4Contract()
//                .subscribeOn(Schedulers.io())
//                .observeOn(AndroidSchedulers.mainThread())
//                .subscribe(object : NetObserver<ActiveOrderListBean>() {
//                    override fun onHandleSuccess(bean: ActiveOrderListBean?) {
//                        
//                        if (bean?.orderList?.isNotEmpty() == true) {
//                            adapter.replaceData(bean.orderList)
//                            loopOrder()
//                        } else {
//                            adapter.replaceData(arrayListOf())
//                            disposables4OrderList.clear()
//                            disposables4OrderList.dispose()
//                        }
//                    }
//
//                    override fun onHandleError(code: Int, msg: String?) {
//                        disposables4OrderList.clear()
//                        disposables4OrderList.dispose()
//                        
//                    }
//                })
    }

    /**
     *Activity Delegation List
     */
    private fun loopOrderList4Contract() {
        if (!LoginManager.checkLogin(activity, false)) return
//        HttpClient.instance
//                .getOrderList4Contract()
//                .subscribeOn(Schedulers.io())
//                .observeOn(AndroidSchedulers.mainThread())
//                .subscribe(object : NetObserver<ActiveOrderListBean>() {
//                    override fun onHandleSuccess(bean: ActiveOrderListBean?) {
//                        
//                        if (bean?.orderList?.isNotEmpty() == true) {
//                            adapter.replaceData(bean.orderList)
//                        } else {
//Log. d (TAG, "==" Order is empty==")
//                            adapter.replaceData(arrayListOf())
//                            disposables4OrderList.clear()
//                            disposables4OrderList.dispose()
//                        }
//                    }
//
//                    override fun onHandleError(code: Int, msg: String?) {
//                        disposables4OrderList.clear()
//                        disposables4OrderList.dispose()
//                        
//                    }
//                })
    }


    /**
     *Call the interface every 5 seconds
     */
    private fun loopOrder() {
        disposables.add(Observable.interval(0, 5, TimeUnit.SECONDS).subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribeWith(getOrderObserver()))
    }

    private fun getOrderObserver(): DisposableObserver<Long> {
        return object : DisposableObserver<Long>() {
            override fun onComplete() {
            }

            override fun onNext(t: Long) {
                loopOrderList4Contract()
            }

            override fun onError(e: Throwable) {
            }
        }

    }


    override fun onDestroy() {
        super.onDestroy()
        disposables.clear()
        disposables4OrderList.clear()
    }


    private fun initSocket() {
        Log.d("======", "==initSocket===")
        mSocketClient = object : WebSocketClient(URI(ApiConstants.SOCKET_CONTRACT_ADDRESS)) {
            override fun onOpen(handshakedata: ServerHandshake?) {
                Log.i(TAG, "onOpen")
                subCurrentContractMsg()
            }

            override fun onClose(code: Int, reason: String?, remote: Boolean) {
                Log.i(TAG, "onClose$reason")
            }


            override fun onMessage(bytes: ByteBuffer?) {
                super.onMessage(bytes)
                if (bytes == null) return
                val data = GZIPUtils.uncompressToString(bytes.array())
                if (!data.isNullOrBlank()) {
                    if (data.contains("ping")) {
                        val replace = data.replace("ping", "pong")
                        
                        mSocketClient.send(replace)
                    } else {
                        handleData(data)
                    }
                }
            }

            override fun onMessage(message: String?) {
                Log.i(TAG, "onMessage")
            }

            override fun onError(ex: Exception?) {
                Log.i(TAG, "onError" + ex?.printStackTrace())
            }

        }
        mSocketClient.connect()
    }


    /**
     *Subscribe to the current contract's 24-hour market and depth
     */
    fun subCurrentContractMsg() {
        
        val contract = Contract2PublicInfoManager.currentContract(lastSymbol = currentSymbol)
                ?: return
        

        val lastSymbol = contract.lastSymbol
        

        if (!::mSocketClient.isInitialized || !mSocketClient.isOpen) {
            initSocket()
        }
        currentSymbol = Contract2PublicInfoManager.currentContract()?.symbol ?: ""

        
        if (currentSymbol == lastSymbol) {

            return
        } else {
            if (mSocketClient.isOpen) {
                
                if (!contract.lastSymbol.isNullOrBlank()) {
                    mSocketClient.send(WsLinkUtils.tickerFor24HLink(contract.lastSymbol?.toLowerCase()!!, false))
                    mSocketClient.send(WsLinkUtils.getDepthLink(contract.lastSymbol?.toLowerCase()!!, false).json)
                    clearDepthView()
                }
                mSocketClient.send(WsLinkUtils.tickerFor24HLink(currentSymbol.toLowerCase()))
                mSocketClient.send(WsLinkUtils.getDepthLink(currentSymbol.toLowerCase()).json)
            } else {
                initSocket()
            }

        }
    }

    fun handleData(data: String) {
        
        doAsync {
            val json = JSONObject(data)
            val tickJson = json.optJSONObject("tick") ?: return@doAsync
            if (tickJson.has("buys")) {
                
                /**
                 *Depth
                 */
                var transactionData = JsonUtils.jsonToBean(data, TransactionData::class.java)
                /**
                 *Minimum selling price
                 */
                transactionData.tick?.asks?.sortByDescending { it.get(0).asDouble }
                /**
                 *Buying for maximum
                 */
                transactionData.tick?.buys?.sortByDescending { it.get(0).asDouble }
                

                uiThread {
                    refreshDepthView(transactionData)
                }
            } else {
                
                /**
                 * 24H
                 */
                val tick = JsonUtils.jsonToBean(tickJson.toString(), QuotesData.Tick::class.java)
                if (TextUtils.isEmpty(tick.vol)) return@doAsync
                uiThread {
                    tv_new_price?.text = "--"
                    render24H(tick)
                }
            }


        }
    }

    var lastClosePrice = ""

    /**
     *Rendering 24-hour market data
     */
    private fun render24H(tick: QuotesData.Tick) {
        if (lastClosePrice == "") {
            tv_price?.setTextColor(mainFontColor)
            tv_new_price?.setTextColor(mainFontColor)
            tv_price?.text = Contract2PublicInfoManager.cutValueByPrecision(tick.close)
            tv_new_price?.text = Contract2PublicInfoManager.cutValueByPrecision(tick.close)

            iv_price_trend?.setImageResource(R.drawable.ic_price_descend)
            iv_price_trend?.visibility = View.INVISIBLE
            lastClosePrice = tick.close
        } else {
            when (BigDecimalUtils.compareTo(tick.close, lastClosePrice)) {
                0 -> {
                    tv_price?.setTextColor(mainFontColor)
                    tv_new_price?.setTextColor(mainFontColor)
                    tv_price?.text = Contract2PublicInfoManager.cutValueByPrecision(tick.close)
                    tv_new_price?.text = Contract2PublicInfoManager.cutValueByPrecision(tick.close)
                    iv_price_trend?.setImageResource(R.drawable.ic_price_descend)
                    iv_price_trend?.visibility = View.INVISIBLE

                }

                1 -> {
                    tv_price?.setTextColor(green)
                    tv_new_price?.setTextColor(green)
                    tv_price?.text = Contract2PublicInfoManager.cutValueByPrecision(tick.close)
                    tv_new_price?.text = Contract2PublicInfoManager.cutValueByPrecision(tick.close)

                    iv_price_trend?.setImageResource(R.drawable.ic_price_ascend)
                    iv_price_trend?.visibility = View.VISIBLE
                }

                -1 -> {
                    tv_price?.setTextColor(red)
                    tv_new_price?.setTextColor(red)
                    tv_price?.text = Contract2PublicInfoManager.cutValueByPrecision(tick.close)
                    tv_new_price?.text = Contract2PublicInfoManager.cutValueByPrecision(tick.close)

                    iv_price_trend?.setImageResource(R.drawable.ic_price_descend)
                    iv_price_trend?.visibility = View.VISIBLE
                }
            }
            lastClosePrice = tick.close

        }

    }

    /**
     *Buying and selling order
     *
     *Initialize transaction details record view
     */
    private fun initDepthView() {
        for (i in 0 until 5) {
            /**
             *Selling orders
             */
            val view: View = layoutInflater.inflate(R.layout.item_depth_contract, null)

            view.tv_price?.setTextColor(red)
            view.tv_position?.setTextColor(red)
            view.tv_amount?.setTextColor(red)
            /**
             *Click on the buying and selling order to display the price in the "buying price"
             */
            view.setOnClickListener {
                buyOrSellItemClick(view)
            }
            ll_sell_price?.addView(view)
            sellViewList.add(view)

            /***********/


            /**
             *Buying
             */
            val view1: View = layoutInflater.inflate(R.layout.item_depth_contract, null)

            view1.tv_price?.setTextColor(green)
            view1.tv_position?.setTextColor(green)
            view1.tv_amount?.setTextColor(green)
            view1.setOnClickListener {
                buyOrSellItemClick(view1)
            }
            ll_buy_price?.addView(view1)
            buyViewList.add(view1)
        }
    }


    /**
     *Handling click events for 'buy and sell orders'
     */
    private fun buyOrSellItemClick(view1: View) {
        val result = view1.tv_price?.text.toString()
        if (result != "--" && marketType == LIMIT_TRADE) {
            et_price?.setText(result)
            et_price?.setSelection(result.length)
        }
    }


    /**
     *Update data for purchase and sale orders
     */
    private fun refreshDepthView(transactionData: TransactionData) {
        val tick: TransactionData.Tick = transactionData.tick ?: return
        /**
         *The largest selling volume
         */
        val askMaxVolJson = tick.asks.maxByOrNull { it.get(1).asDouble }
        val askMaxVol = askMaxVolJson?.get(1)?.asDouble

        /**
         *The largest buying volume
         */
        val buyMaxVolJson = tick.buys.maxByOrNull { it.get(1).asDouble }
        val buyMaxVol = buyMaxVolJson?.get(1)?.asDouble

        for (i in 0 until sellViewList.size) {
            /**
             *Selling orders
             */
            if (tick.asks.size > sellViewList.size) {
                /**
                 *Remove large values
                 */
                val subList = tick.asks.subList(tick.asks.size - sellViewList.size, tick.asks.size)

                /*****Deep background color START****/
                sellViewList[0].ll_item.post {
                    val measuredWidth = sellViewList[0].ll_item.measuredWidth
                    sellViewList[i].fl_bg_item.setBackgroundResource(R.color.entrust_sell_color)
                    val layoutParams = sellViewList[i].fl_bg_item.layoutParams
                    val width = (subList[i].get(1).asDouble / askMaxVol!!) * measuredWidth
                    layoutParams.width = width.toInt()
                    
                    sellViewList[i].fl_bg_item.layoutParams = layoutParams
                }

                /*****Deep background color END****/

                sellViewList[i].tv_price.text =
                        Contract2PublicInfoManager.cutValueByPrecision(subList[i].get(0).asString)



                sellViewList[i].tv_position.text = BigDecimalUtils.formatNumber(subList[i].get(1).toString())


                /**
                 *Total amount
                 */
                val sumByDouble = ArrayList(subList.asReversed().subList(0, i + 1)).sumByDouble {
                    it[1].asDouble
                }

                sellViewList[sellViewList.lastIndex - i].tv_amount?.text = sumByDouble.toInt().toString()


            } else {

                val temp = sellViewList.size - tick.asks.size
                sellViewList[i].tv_price?.text = "--"
                sellViewList[i].tv_position?.text = "--"
                if (i >= temp) {
                    /*****Deep background color START****/
                    sellViewList[0].ll_item.post {
                        val measuredWidth = sellViewList[0].ll_item.measuredWidth
                        sellViewList[i].fl_bg_item.setBackgroundResource(R.color.entrust_sell_color)
                        val layoutParams = sellViewList[i].fl_bg_item.layoutParams
                        val width = (tick.asks[i - temp].get(1).asDouble / askMaxVol!!) * measuredWidth
                        
                        layoutParams.width = width.toInt()
                        
                        sellViewList[i].fl_bg_item.layoutParams = layoutParams
                    }

                    /*****Deep background color END****/

                    /**
                     *Price
                     */
                    sellViewList[i].tv_price?.text = Contract2PublicInfoManager.cutValueByPrecision(tick.asks[i - temp].get(0).asString)


                    /**
                     *Bin
                     */
                    sellViewList[i].tv_position?.text = BigDecimalUtils.formatNumber(tick.asks[i - temp].get(1).asString)


                    /**
                     *Total amount
                     */
                    val sumByDouble = ArrayList(tick.asks.reversed().subList(0, i - temp + 1)).sumByDouble {
                        it[1].asDouble
                    }
                    sellViewList[4 - i + temp].tv_amount?.text = sumByDouble.toInt().toString()

                } else {
                    clearDepthView(SELL_SIDE)
                }
            }

            /**
             *Buying
             */
            if (tick.buys.size > i) {
                /*****Deep background color START****/
                buyViewList[i].ll_item.post {
                    var llWidth = buyViewList[0].ll_item.measuredWidth

                    buyViewList[i].fl_bg_item.setBackgroundResource(R.color.entrust_buy_color)
                    val layoutParams = buyViewList[i].fl_bg_item.layoutParams
                    val width = (tick.buys[i].get(1).asDouble / buyMaxVol!!) * llWidth
                    
                    layoutParams.width = width.toInt()
                    
                    buyViewList[i].fl_bg_item.layoutParams = layoutParams
                }


                /*****Deep background color END****/

                
                val price4DepthBuy = tick.buys[i].get(0).asString

                

                buyViewList[i].tv_price?.text = Contract2PublicInfoManager.cutValueByPrecision(price4DepthBuy)

                buyViewList[i].tv_position?.text = BigDecimalUtils.formatNumber(tick.buys[i].get(1).asString)

                /**
                 *Total amount
                 */
                val sumByDouble = ArrayList(tick.buys.subList(0, i + 1)).sumByDouble {
                    it[1].asDouble
                }

                buyViewList[i].tv_amount?.text = sumByDouble.toInt().toString()

            } else {
                buyViewList[i].tv_price.text = "--"
                buyViewList[i].tv_position.text = "--"
                buyViewList[i].tv_amount.text = "--"
                buyViewList[i].fl_bg_item.setBackgroundResource(R.color.transparent)
            }
        }
    }


    private fun onTipsClick() {
        /**
         *Risk Assessment Tips
         */
        csrv_risk?.setOnClickListener {
            ContractDialog.showDialog4Risk(context!!)
        }

        /**
         *Indicative price
         */
        tv_tag_price?.setOnClickListener {
            ContractDialog.showDialog4ThePrice(context!!)
        }


        /**
         *Cost
         */
        tv_cost?.setOnClickListener {
            ContractDialog.showDialog4TheCostOf(context!!)
        }

        /**
         *Qiangping Price
         */
        tv_liquidation_price?.onTipsListener = object : ComTitleValueView.OnTipsListener {
            override fun onClick() {
                ContractDialog.showDialog4FlatPricer(context!!)
            }

        }


    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun onMessageEvent(event: EntrustBean) {
        if (event.position == 0) {
            //Kaiduo
            tv_open_more?.textColor = green
            tv_open_empty?.textColor = mainFontColor
            tv_open_empty?.setCompoundDrawablesRelativeWithIntrinsicBounds(0, 0, 0, 0)
            tv_open_more?.setCompoundDrawablesRelativeWithIntrinsicBounds(0, 0, 0, R.drawable.bg_buy_line)
            tv_place_order?.solid = green
            tv_place_order?.text = StringUtils.getString(R.string.contract_action_buy)
            side = BUY_SIDE
        } else {
            //Open air
            tv_open_empty?.textColor = red
            tv_open_more?.textColor = mainFontColor
            tv_open_more?.setCompoundDrawablesRelativeWithIntrinsicBounds(0, 0, 0, 0)
            tv_open_empty?.setCompoundDrawablesRelativeWithIntrinsicBounds(0, 0, 0, R.drawable.bg_sell_line)
            tv_place_order?.solid = red
            side = SELL_SIDE
            tv_place_order?.text = StringUtils.getString(R.string.contract_action_sell)
        }

    }

    /**
     *Cancel Order
     */
    private fun cancelOrder(orderId: String, contractId: String, pos: Int) {
        HttpClient.instance
                .cancelOrder4Contract(
                        contractId = contractId,
                        orderId = orderId
                )
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<Any>() {
                    override fun onHandleSuccess(bean: Any?) {
                        getInitOrderInfo(currentLevel)
                    }

                    override fun onHandleError(code: Int, msg: String?) {
                    }
                })
    }

    override fun setUserVisibleHint(isVisibleToUser: Boolean) {
        super.setUserVisibleHint(isVisibleToUser)
        if (isVisibleToUser) {
            getInitOrderInfo()
        }
    }

    /**
     *Reset the data of the order
     */
    fun clearDepthView(side: String = "") {
        when (side) {
            SELL_SIDE -> {
                sellViewList.forEach {
                    clearDepthItem(it)
                }
            }

            BUY_SIDE -> {
                buyViewList.forEach {
                    clearDepthItem(it)
                }
            }

            else -> {
                sellViewList.forEach {
                    clearDepthItem(it)
                }
                buyViewList.forEach {
                    clearDepthItem(it)
                }
            }
        }


    }

    private fun clearDepthItem(it: View) {
        it.tv_position?.text = "--"
        it.tv_amount?.text = "--"
        it.tv_price?.text = "--"
        it.fl_bg_item?.setBackgroundResource(R.color.transparent)
    }


}
