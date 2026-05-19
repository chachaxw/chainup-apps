package com.yjkj.chainup.quickBuyCoin

import android.os.Bundle
import android.os.CountDownTimer
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.RelativeLayout
import android.widget.TextView
import androidx.recyclerview.widget.LinearLayoutManager
import com.alibaba.android.arouter.facade.annotation.Autowired
import com.alibaba.android.arouter.facade.annotation.Route
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.chainup.contract.utils.setSafeItemClickListener
import com.chainup.kit.KKDialogUtils
import com.chainup.kit.utils.PublicSizeUtil
import com.chainup.kit.views.KKEmptyViewKit
import com.yjkj.chainup.R
import com.yjkj.chainup.app.AppConstant
import com.yjkj.chainup.base.NBaseActivity
import com.yjkj.chainup.bean.PayCardBean
import com.yjkj.chainup.bean.Paycard
import com.yjkj.chainup.bean.PaymentSubmitBean
import com.yjkj.chainup.bean.Rate
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.net.HttpClient
import com.yjkj.chainup.net.retrofit.NetObserver
import com.yjkj.chainup.util.GlideUtils
import com.yjkj.chainup.util.NToastUtil
import com.yjkj.chainup.util.ResourcesUtils
import com.yjkj.chainup.util.tr
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.activity_select_service_provider.rv_provider
import kotlinx.android.synthetic.main.activity_select_service_provider.v_header
import kotlinx.android.synthetic.main.layout_view_quick_trade_right.tv_refresh
import org.jetbrains.anko.layoutInflater


const val defCount:Long = 30L
@Route(path = RoutePath.SelectServiceProviderActivity)
class SelectServiceProviderActivity : NBaseActivity() {

    private lateinit var mDataList: ArrayList<Paycard>
    private lateinit var mRateList: ArrayList<Rate>
    private lateinit var mBufferAdapter: BufferAdapter
    var coinName = ""
    var fiatName = ""
    var mainChainSymbol = ""
    var inputNum = ""
    var fiatAliasName= ""
    var coinAliasName= ""
    private var mCountDownTime: CountDownTime? = null

    @JvmField
    @Autowired(name = "transferType")
    var transferType:String = "1"

    @JvmField
    @Autowired(name = "isBuy")
    var isBuy:Boolean = true

    var sourceAmount:String = ""

    var targetAmount:String = ""

    override fun setContentView(): Int {
        return R.layout.activity_select_service_provider
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        loadData()
        initView()
        initData()
    }

    override fun loadData() {
        super.loadData()
        mDataList = ArrayList()
        mRateList = intent.getSerializableExtra("data") as ArrayList<Rate>
        fiatName = intent.getStringExtra("fiatName").toString()
        coinName = intent.getStringExtra("coinName").toString()
        fiatAliasName = intent.getStringExtra("fiatAliasName").toString()
        coinAliasName = intent.getStringExtra("coinAliasName").toString()
        mainChainSymbol = intent.getStringExtra("mainChainSymbol").toString()
        inputNum = intent.getStringExtra("inputNum").toString()

        getPaycardNum(fiatName, coinName, inputNum)
    }

    override fun initView() {
        super.initView()
        v_header.setTitleContent("creditCard_text4".tr(this))
        val rightView = LayoutInflater.from(this).inflate(R.layout.layout_view_quick_trade_right,null)
        v_header.setRightCustomLayout(rightView)

        mBufferAdapter = BufferAdapter(R.layout.item_select_service_provider, mDataList,fiatAliasName)
        mBufferAdapter.setEmptyView(KKEmptyViewKit(this))
        rv_provider.apply {
            layoutManager = LinearLayoutManager(this@SelectServiceProviderActivity)
            adapter = mBufferAdapter
        }
        mBufferAdapter.addChildClickViewIds(R.id.cbtn_confirm,R.id.tv_pay_tip)
        mBufferAdapter.setSafeItemClickListener { adapter, view, position ->
            when(view.id){
                R.id.cbtn_confirm -> {
                    sourceAmount = mDataList[position].sourceAmount ?: return@setSafeItemClickListener
                    targetAmount = mDataList[position].targetAmount ?: return@setSafeItemClickListener
                    paymentSubmit(
                        fiatName,
                        coinName,
                        inputNum,
                        mDataList[position].name,
                        mDataList[position]?.quote_id,
                        mDataList[position]?.base_amount,
                        mDataList[position]?.amount,
                        mDataList[position]?.total_amount,
                        mDataList[position]?.rate
                    )
                }
                R.id.tv_pay_tip -> {
                    KKDialogUtils.showCommonDialog(
                        this,
                        "quick_buy_choose3party_notice".tr(this),
                        "dialog_tip_title".tr(this),
                        listener = null,
                        confrimTitle = "guide_3".tr(this),
                        isShowCancel = false,
                        style = 2
                    )
                }
            }
        }

        tv_refresh.setOnClickListener {
            getPaycardNum(fiatName, coinName, inputNum)
        }
    }

    private fun initData() {
    }


    fun getPaycardNum(fiat: String, coin: String, num: String) {
        showLoadingDialog()
        HttpClient.instance.getPaycardNum(fiat, coin, num,transferType)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<PayCardBean>() {
                    override fun onHandleSuccess(data: PayCardBean?) {
                        closeLoadingDialog()
                        mDataList.clear()
                        data?.apply {
                            for (buff in this.paycard_list) {
                                buff.coinName = coinName
                                buff.fiatName = fiatName
//                                for (zuff in mRateList){
//                                    if (zuff.name.equals(buff.name)){
//                                        buff.rate=zuff.rate
//                                    }
//                                }
                                mDataList.add(buff)
                            }
                        }
                        mBufferAdapter.setList(mDataList)

                        mCountDownTime?.cancel()
                        mCountDownTime = CountDownTime(defCount * 1000, 1000)
                        mCountDownTime!!.start()
                    }

                    override fun onHandleError(code: Int, msg: String?) {
                        super.onHandleError(code, msg)
                        NToastUtil.showTopToastNet(this@SelectServiceProviderActivity, false, msg)
                        closeLoadingDialog()
                    }
                })
    }

    fun paymentSubmit(fiat: String,
                      coin: String,
                      num: String,
                      name: String,
                      quote_id: String?,
                      base_amount: String?,
                      amount: String?,
                      total_amount: String?,
                      rate: String?) {
        showLoadingDialog()
        HttpClient.instance.paymentSubmit(
            fiat, coin, num, name, quote_id, base_amount, amount, total_amount, rate,if(isBuy) "1" else "2", sourceAmount,targetAmount
        )
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<PaymentSubmitBean>() {
                    override fun onHandleSuccess(data: PaymentSubmitBean?) {
                        closeLoadingDialog()
                        ArouterUtil.greenChannel(RoutePath.JumpServiceProviderActivity, Bundle().apply {
                            putString("urlhtml", if(name == AppConstant.BANXA) data?.data_map?.payment_post_url else data?.html)
                            putString("name", name)
                        })
                    }

                    override fun onHandleError(code: Int, msg: String?) {
                        super.onHandleError(code, msg)
                        NToastUtil.showTopToastNet(this@SelectServiceProviderActivity, false, msg)
                        closeLoadingDialog()
                    }
                })
    }


    inner class BufferAdapter(layoutResId: Int, data: MutableList<Paycard>,fiatAliasName:String) :
            BaseQuickAdapter<Paycard, BaseViewHolder>(layoutResId, data) {
        val fiatAliasName=fiatAliasName
        override fun convert(helper: BaseViewHolder, item: Paycard) {
            helper.setText(R.id.tv_name, item.name)
            helper.setText(R.id.tv_arrival_time, "10-30" + LanguageUtil.getString(context, "sl_str_minutes"))

            helper.setText(R.id.tv_price_label,LanguageUtil.getString(context, "creditCard_text3").dropLast(1))
            if(isBuy){
                helper.setText(R.id.tv_total_amout, item.total_amount + fiatAliasName)
                helper.setText(R.id.tv_amout, item.amount + mainChainSymbol)
                helper.setText(R.id.tv_rate, item.rate + " " + fiatAliasName + "/" + mainChainSymbol)
            }else{
                helper.setText(R.id.tv_total_amout, item.total_amount + mainChainSymbol)
                helper.setText(R.id.tv_amout, item.amount + fiatAliasName)
                helper.setText(R.id.tv_rate, item.rate + " " + mainChainSymbol + "/" + fiatAliasName)
            }
            val tvPayTip = helper.getView<TextView>(R.id.tv_pay_tip)
            tvPayTip.text = "creditCard_text1".tr(context)
            val iconDrawable = this@SelectServiceProviderActivity.getDrawable(R.mipmap.public_hint)
            val leftMargin = PublicSizeUtil.dp2px(context,3.0f)
            val topMargin = 3
            iconDrawable?.setBounds(leftMargin,topMargin,iconDrawable.intrinsicWidth+leftMargin,topMargin+iconDrawable.intrinsicHeight)
            tvPayTip.setCompoundDrawables(null,null,iconDrawable,null)
//            tvPayTip.compoundDrawablePadding = PublicSizeUtil.dp2px(context,3.0f)
            val service_pic = helper.getView<ImageView>(R.id.service_pic)
            item.service_pic?.run {
                if(this.contains("http")){
                    GlideUtils.load(this@SelectServiceProviderActivity,this,service_pic)
                }else{
                    service_pic.setImageResource(ResourcesUtils.getDrableId(context, this))
                }
            }

            val ll_payment= helper.getView<LinearLayout>(R.id.ll_payment)
            ll_payment.removeAllViews()
            for (buff in item.payment_pic.split(",")) {
                val lp1 = RelativeLayout.LayoutParams(
                        ViewGroup.LayoutParams.WRAP_CONTENT,
                        ViewGroup.LayoutParams.WRAP_CONTENT
                )
                lp1.addRule(RelativeLayout.CENTER_IN_PARENT)
                val inflater: LayoutInflater = context.layoutInflater
                val mView: View = inflater.inflate(R.layout.item_ll_payment, null)
                val img_payment_pic = mView.findViewById<ImageView>(R.id.img_payment_pic)
                if(buff.contains("http")){
                    GlideUtils.load(context,buff,img_payment_pic)
                }else{
                    img_payment_pic.setImageResource(ResourcesUtils.getDrableId(context, buff))
                }
                ll_payment.addView(mView)
            }
        }
    }

    internal inner class CountDownTime(millisInFuture: Long, countDownInterval: Long) :
            CountDownTimer(millisInFuture, countDownInterval) {
        override fun onTick(l: Long) {
            var value = ((l/1000).toInt() + 1).toLong()
            if(value > defCount) value = defCount
            tv_refresh.text = "$value"+"S"
        }

        override fun onFinish() {
            getPaycardNum(fiatName, coinName, inputNum)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        mCountDownTime?.cancel()
    }
}
