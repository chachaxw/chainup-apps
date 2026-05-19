package com.yjkj.chainup.quickBuyCoin

import android.content.Intent
import android.os.Bundle
import android.text.Editable
import android.text.Spannable
import android.text.SpannableString
import android.text.TextUtils
import android.text.TextWatcher
import android.text.style.AbsoluteSizeSpan
import android.text.style.ForegroundColorSpan
import android.text.style.RelativeSizeSpan
import android.view.View
import android.view.View.OnClickListener
import android.widget.EditText
import android.widget.TextView
import androidx.core.content.ContextCompat
import com.alibaba.android.arouter.facade.annotation.Route
import com.chainup.contract.utils.numberFilter
import com.chainup.contract.utils.setSafeListener
import com.chainup.kit.KKDialogUtils
import com.chainup.kit.views.PublicHeaderKit
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseActivity
import com.yjkj.chainup.bean.*
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.LoginManager
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.net.HttpClient
import com.yjkj.chainup.net.retrofit.NetObserver
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.util.*
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.activity_quick_buy_coin_index.*
import kotlinx.android.synthetic.main.activity_quick_buy_coin_index.cbtn_confirm
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode
import org.json.JSONObject
import java.math.BigDecimal

@Route(path = RoutePath.QuickBuyCoinIndexActivity)
class QuickBuyCoinIndexActivity : NBaseActivity() {
    lateinit var coin_list: ArrayList<Coin>
    lateinit var fiat_list: ArrayList<Coin>
    lateinit var rate_list: ArrayList<Rate>
    var coinName = ""
    var mainChainSymbol:String? = ""
    var fiatName = ""
    var limitMin = "0"
    var limitMax = "0"
    var rate = "0"
    private var isBuy:Boolean = true
    private var selectFiat:Coin? = null
    private var selectCoin:Coin? = null
    private val accountBalanceMap:HashMap<String,JSONObject> by lazy { hashMapOf() }
    private var currentCoinBalance:String = ""
    lateinit var buyCoinList:ArrayList<Coin>
    lateinit var sellCoinList:ArrayList<Coin>
    private var isDisableBuy:Boolean = false
    private var isDisableSell:Boolean = false

    override fun setContentView(): Int {
        return R.layout.activity_quick_buy_coin_index
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        initView()
        initData()
        loadData()
    }

    private fun initData() {
        coin_list = ArrayList()
        fiat_list = ArrayList()
        rate_list = ArrayList()
        buyCoinList = ArrayList()
        sellCoinList = ArrayList()
    }

    override fun initView() {
        super.initView()
        limitMin = "0.0001"
        limitMax = "1000"
        tv_zf_num.numberFilter(8)
        cbtn_confirm.textContent = "cl_lever_text4".tr(this)
        tv_zf_tip.setText(LanguageUtil.getString(this,"creditCard_text10") + " " + limitMin + " - " + limitMax + " " + if(isBuy) fiatName else coinName)
        setCustomHint(tv_zf_num,LanguageUtil.getString(this,"common_text_limitMin") + limitMin + " - " + limitMax)
        tv_zf_num.isEnabled = false
        tv_avl.text = "available_balance".tr(this)+"："
        v_header.setTvRightText("order_records".tr(this))
        v_header.setTitleContent("creditCard_text0".tr(this))
        v_header.listener = object :PublicHeaderKit.IOnBackClickListener{
            override fun onRightBtn(view: View) {
                super.onRightBtn(view)
                if (LoginManager.checkLogin(this@QuickBuyCoinIndexActivity, true)) {
                    startActivity(Intent(this@QuickBuyCoinIndexActivity,QuickBuyCoinOrdersActivity::class.java))
                }
            }
        }
        iv_transform.animate().rotation(90F).start()
        cbtn_confirm.isEnable(false)
        cbtn_confirm?.setOnClickListener(object: OnClickListener{
            override fun onClick(v: View?) {
                if (!LoginManager.checkLogin(this@QuickBuyCoinIndexActivity, true)) {
                    return
                }

                var coin=coinName
                var fiat=fiatName
                for (buff in coin_list){
                    if (!TextUtils.isEmpty(buff.alias)){
                        if (buff.alias.equals(coinName)){
                            coin=buff.name
                        }
                    }
                }
                for (buff in fiat_list){
                    if (!TextUtils.isEmpty(buff.alias)){
                        if (buff.alias.equals(fiatName)){
                            fiat=buff.name
                        }
                    }
                }

                ArouterUtil.greenChannel(RoutePath.SelectServiceProviderActivity,  Bundle().apply {
                    putSerializable("data", rate_list)
                    putString("coinName", coin)
                    putString("fiatName", fiat)
                    putString("coinAliasName", coinName)
                    putString("fiatAliasName", fiatName)
                    putString("mainChainSymbol", mainChainSymbol)
                    putString("inputNum", tv_zf_num.text.toString())
                    putString("transferType", if(isBuy) "1" else "2")
                    putBoolean("isBuy", isBuy)
                })
            }

        })
        ll_rigth_fiat.setOnClickListener {
            ArouterUtil.greenChannel(RoutePath.SelectQuickBuyCoinActivity,getPageBundle(true))
        }
        ll_rigth_coin.setOnClickListener {
            ArouterUtil.greenChannel(RoutePath.SelectQuickBuyCoinActivity, getPageBundle(false))
        }
        tv_zf_num.addTextChangedListener(object :TextWatcher{
            override fun beforeTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {
            }

            override fun onTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {
            }

            override fun afterTextChanged(p0: Editable?) {
                val zfNum = tv_zf_num.text.toString()
                if (TextUtils.isEmpty(zfNum)) {
                    tv_zf_tip.visibility= View.INVISIBLE
                    tv_sd_num.setText("")
                    cbtn_confirm.isEnable(false)
                    return
                }
                if(!StringUtil.isNumeric(zfNum)) return
                if(!"".equals(currentCoinBalance)){
                    if(BigDecimalUtils.compareTo(zfNum,currentCoinBalance) > 0 && !isBuy){
                        tv_zf_tip.text = "quick_buy_avail_check".tr(this@QuickBuyCoinIndexActivity)
                        tv_zf_tip.visibility= View.VISIBLE
                        cbtn_confirm.isEnable(false)
                        return
                    }
                }
                tv_zf_tip.text = LanguageUtil.getString(this@QuickBuyCoinIndexActivity,"creditCard_text10") + " " + limitMin + " - " + limitMax + " " + if(isBuy) fiatName else coinName

                tv_sd_num.setText(BigDecimalUtils.divStr(zfNum,rate,8))
                if (BigDecimalUtils.compareTo(BigDecimal(zfNum), BigDecimal(limitMin))==-1){
                    cbtn_confirm.isEnable(false)
                    tv_zf_tip.visibility= View.VISIBLE
                    return
                }
                if (BigDecimalUtils.compareTo(BigDecimal(limitMax), BigDecimal(zfNum))==-1){
                    cbtn_confirm.isEnable(false)
                    tv_zf_tip.visibility= View.VISIBLE
                    return
                }
                if (BigDecimalUtils.compareTo(BigDecimal(0), BigDecimal(zfNum))==0){
                    cbtn_confirm.isEnable(false)
                    return
                }
                tv_zf_tip.visibility= View.INVISIBLE
                cbtn_confirm.isEnable(true)
            }
        })

        iv_transform.setSafeListener {
            if(isBuy){
                //need sell
                if(isDisableSell){
                    showTip("quick_buy_no_sell".tr(this@QuickBuyCoinIndexActivity))
                    return@setSafeListener
                }
            }else{
                //need buy
                if(isDisableBuy){
                    showTip("quick_buy_no_buy".tr(this@QuickBuyCoinIndexActivity))
                    return@setSafeListener
                }
            }
            isBuy = !isBuy
            selectFiat?.let { changeVisibleCoinWithIcon(true,it) }
            selectCoin?.let { changeVisibleCoinWithIcon(false,it) }
            getThirdSupportFiatData()
        }
    }

    private fun getPageBundle(isTop:Boolean):Bundle{
        return if(isTop){
            if(isBuy){
                Bundle().apply {
                    putSerializable("type", "fiat")
                    putSerializable("data", fiat_list)
                }
            }else{
                Bundle().apply {
                    putSerializable("type", "coin")
                    putSerializable("data", coin_list)
                }
            }
        }else{
            if(isBuy){
                Bundle().apply {
                    putSerializable("type", "coin")
                    putSerializable("data", coin_list)
                }

            }else{
                Bundle().apply {
                    putSerializable("type", "fiat")
                    putSerializable("data", fiat_list)
                }
            }
        }

    }


    override fun loadData() {
        super.loadData()
        getThirdSupportFiat(true)
        getThirdSupportFiat(false)
        getBalance()
    }

    private fun showTip(message:String){
        KKDialogUtils.showCommonDialog(
            this@QuickBuyCoinIndexActivity,
            message,
            "dialog_tip_title".tr(this@QuickBuyCoinIndexActivity),
            listener = null,
            confrimTitle = "guide_3".tr(this@QuickBuyCoinIndexActivity),
            isShowCancel = false,
            style = 2
        )
    }

    private fun getThirdSupportFiat(isBuy:Boolean) {
        if(isBuy) showLoadingDialog()
        HttpClient.instance.getThirdSupportFiat(if(isBuy) "1" else "2")
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<QuickBuyCoinBean>() {
                    override fun onHandleSuccess(data: QuickBuyCoinBean?) {
                        if(isBuy) closeLoadingDialog()
                        data?.let {
                            it.coin_list?.let {_coinIt->
                                if(isBuy) buyCoinList.addAll(_coinIt)
                                else sellCoinList.addAll(_coinIt)
                            }
                            it.fiat_list?.let {_fiatIt->
                                fiat_list.addAll(_fiatIt)
                            }
                            if(isBuy){
                                getThirdSupportFiatData()
                                isDisableBuy = it.status==0
                                if(it.status==0){
                                    showTip("quick_buy_no_buy".tr(this@QuickBuyCoinIndexActivity))
                                }
                            }else{
                                isDisableSell = it.status==0
                            }
                        }
                    }
                    override fun onHandleError(code: Int, msg: String?) {
                        super.onHandleError(code, msg)
                        NToastUtil.showTopToastNet(this@QuickBuyCoinIndexActivity, false, msg)
                        if(isBuy) closeLoadingDialog()
                    }
                })
    }

    fun getThirdSupportFiatData(){
        coin_list.clear()
        if(isBuy){
            coin_list.addAll(buyCoinList)
        }else{
            coin_list.addAll(sellCoinList)
        }

        fiat_list.apply {
            if (this.size > 0) {
                val findItem = this.find {
                    it.name == selectFiat?.name
                }
                if(findItem!=null && selectFiat!=null){
                    return@apply
                }
                selectFiat = this[0]
                changeVisibleCoinWithIcon(true,selectFiat!!)
            }
        }
        coin_list.apply {
            if (this.size > 0) {
                val findItem = this.find {
                    it.name == selectCoin?.name
                }
                if(findItem!=null && selectCoin!=null){
                    return@apply
                }
                selectCoin = this[0]
                changeVisibleCoinWithIcon(false,selectCoin!!)
            }
        }
        if("".equals(fiatName)||"".equals(coinName)) return
        getPaycardRateList(fiatName, coinName)
    }

    fun getPaycardRateList(fiatBuff: String, coinBuff: String) {
        setCurrentBalance()
        showLoadingDialog()
        var coin=coinBuff
        var fiat=fiatBuff
        for (buff in coin_list){
            if (!TextUtils.isEmpty(buff.alias)){
                if (buff.alias.equals(coinBuff)){
                    coin=buff.name
                }
            }
        }
        for (buff in fiat_list){
            if (!TextUtils.isEmpty(buff.alias)){
                if (buff.alias.equals(fiatBuff)){
                    fiat=buff.name
                }
            }
        }

        HttpClient.instance.getPaycardRateList(fiat, coin,if(isBuy) "1" else "2")
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<RateListBean>() {
                    override fun onHandleSuccess(list: RateListBean?) {
                        closeLoadingDialog()
                        ll_avl.visibility = if(isBuy) View.GONE else View.VISIBLE
                        if(list!=null){
                            rate_list = list.rate_list
                            if (rate_list.size > 0) {
                                rate = rate_list[0].rate
                                limitMin = list.min
                                limitMax = list.max
                                tv_zf_tip.setText(LanguageUtil.getString(this@QuickBuyCoinIndexActivity,"creditCard_text10") + " " + limitMin + " - " + limitMax + " " + if(isBuy) fiatName else coinName)
                                val coinUnit = if("".equals(mainChainSymbol) || mainChainSymbol==null) selectCoin?.name else mainChainSymbol
                                val rateContent:SpannableString =
                                        if(isBuy){
                                            getSpannableString(rate_list[0].rate,
                                                " $fiatBuff/$coinUnit"
                                            )
                                        }else{
                                            getSpannableString(rate_list[0].rate,
                                                " $coinUnit/$fiatBuff"
                                            )
                                        }
                                tv_rate.text = rateContent
                                if(isBuy){
                                    setCustomHint(tv_zf_num,LanguageUtil.getString(this@QuickBuyCoinIndexActivity,"common_text_limitMin") + BigDecimalUtils.showSNormal(limitMin) + " - " + BigDecimalUtils.showSNormal(limitMax))
                                    setCustomHint(tv_sd_num,"${list.targetMin} - ${list.targetMax}")
                                }else{
                                    setCustomHint(tv_zf_num,LanguageUtil.getString(this@QuickBuyCoinIndexActivity,"common_text_limitMin") + limitMin + " - " + limitMax)
                                    setCustomHint(tv_sd_num,"${BigDecimalUtils.showSNormal(list.targetMin)} - ${BigDecimalUtils.showSNormal(list.targetMax)}")
                                }

                                tv_zf_num.isEnabled = true
                                tv_zf_num.setText("")
                                tv_sd_num.setText("")

                            } else {
                                setErrorViewStatus()
                            }
                        }else{
                            setErrorViewStatus()
                        }
                    }
                    override fun onHandleError(code: Int, msg: String?) {
                        super.onHandleError(code, msg)
//                        NToastUtil.showTopToastNet(this@QuickBuyCoinIndexActivity, false, msg)
                        closeLoadingDialog()
                        setErrorViewStatus()
                    }
                })
    }


    /**
     *Credit card deposit requirements
     *There are two situations in total:
        1、 get_paycard_rate_list 接口返回 rate_list 为空
        2、get_paycard_rate_list 接口返回 非200 错误
        按照上图修改。
        调试环境 wuyj
     * */
    fun setErrorViewStatus(){
        limitMin = "0.0001"
        limitMax = "1000"
        tv_zf_num.setText("")
        setCustomHint(tv_zf_num,LanguageUtil.getString(this,"common_text_limitMin") + limitMin + " - " + limitMax)
        tv_sd_num.setText("")
        tv_sd_num.hint = ""
        //There is currently no service provider available
        tv_rate.text = LanguageUtil.getString(this@QuickBuyCoinIndexActivity,"quick_buy_coin_text1")
        //Not inputtable
        tv_zf_num.isEnabled = false
        //The button is not clickable
        cbtn_confirm.isEnable(false)
    }

    private fun changeVisibleCoinWithIcon(isFiat:Boolean,mCoin:Coin){

        if(isFiat){
            fiatName =  if(TextUtils.isEmpty(mCoin.alias)) mCoin.name else mCoin.alias
            if(isBuy){
                tv_fiat_name.setText(fiatName)
                GlideUtils.load(this@QuickBuyCoinIndexActivity, mCoin.iconUrl, img_fiat_pic)
            }else{
                tv_coin_name.setText(fiatName)
                GlideUtils.load(this@QuickBuyCoinIndexActivity, mCoin.iconUrl, img_coin_pic)
            }

        }else{
            coinName = if(TextUtils.isEmpty(mCoin.alias)) mCoin.name else mCoin.alias
            mainChainSymbol = mCoin.mainChainSymbol
            if(isBuy){
                tv_coin_name.setText(coinName)
                GlideUtils.load(this@QuickBuyCoinIndexActivity, mCoin.iconUrl, img_coin_pic)
            }else{
                tv_fiat_name.setText(coinName)
                GlideUtils.load(this@QuickBuyCoinIndexActivity, mCoin.iconUrl, img_fiat_pic)
            }
        }



    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    override fun onMessageEvent(event: MessageEvent) {
        super.onMessageEvent(event)
        if (event.msg_type == MessageEvent.sel_fiat_change) {
            val mCoin: Coin = event.msg_content as Coin
            selectFiat = mCoin

            changeVisibleCoinWithIcon(true,mCoin)
            getPaycardRateList(fiatName, coinName)
        }
        if (event.msg_type == MessageEvent.sel_coin_change) {
            val mCoin: Coin = event.msg_content as Coin
            selectCoin = mCoin
            changeVisibleCoinWithIcon(false,mCoin)
            getPaycardRateList(fiatName, coinName)
            setCurrentBalance()
        }
    }

    private fun setCurrentBalance(){
        if(accountBalanceMap.isNotEmpty() && selectCoin!=null){
            val coinSymbol = selectCoin?.mainChainSymbol ?: selectCoin?.name
            tv_avl_amount.text = "0.00 $coinSymbol"
            if(accountBalanceMap.containsKey(coinSymbol)){
                val balanceObj = accountBalanceMap[coinSymbol]
                val balance = balanceObj?.optString("normal_balance") ?: "0"
                val coinName = balanceObj?.optString("coinName") ?: ""
                val showName = NCoinManager.getShowMarket(coinName)
                currentCoinBalance = BigDecimalUtils.showSNormal(balance,NCoinManager.getCoinShowPrecision(coinName))
                val avlAmountContent = getSpannableString(currentCoinBalance,
                    " $showName"
                )
                tv_avl_amount.text = avlAmountContent
            }

        }
    }
    private fun getBalance(){
        addDisposable(getMainModel().accountBalance(
            consumer = object :NDisposableObserver(){
                override fun onResponseSuccess(jsonObject: JSONObject) {
                    val data = jsonObject.optJSONObject("data")
                    data?.let {
                        val allCoinMap = it.optJSONObject("allCoinMap")
                        if(allCoinMap!=null){
                            val keys = allCoinMap.keys()
                            while (keys.hasNext()){
                                val key = keys.next()
                                accountBalanceMap[key] = allCoinMap.getJSONObject(key)
                            }
                        }
                    }
                }
            }
        ))
    }

    private fun getSpannableString(value:String,extStr:String):SpannableString{

        val decStr = SpannableString(value+extStr)
        try {
            decStr.setSpan(ForegroundColorSpan(ContextCompat.getColor(this,R.color.text_1)), 0, value.length, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)
        }catch (e:Exception){
            e.printStackTrace()
        }
        return decStr
    }

    private fun setCustomHint(textView: TextView, hint:String){
        val spannableString = SpannableString(hint)
        val absoluteSizeSpan = AbsoluteSizeSpan(16,true)
        spannableString.setSpan(absoluteSizeSpan,0,spannableString.length,Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)
        textView.hint = spannableString
    }
}
