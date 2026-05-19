package com.yjkj.chainup.new_version.activity

import android.graphics.Typeface
import android.os.Bundle
import android.util.TypedValue
import android.view.View
import android.widget.LinearLayout
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.viewpager.widget.ViewPager
import com.alibaba.android.arouter.facade.annotation.Autowired
import com.alibaba.android.arouter.facade.annotation.Route
 import com.chainup.contract.view.dialog.CpTDialog
import com.google.android.material.tabs.TabLayout
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseActivity
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.new_version.adapter.NVPagerAdapter
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.view.HistoryScreeningControl
import com.yjkj.chainup.util.ColorUtil
import com.yjkj.chainup.util.LogUtil
import com.yjkj.chainup.util.ViewUtils
import kotlinx.android.synthetic.main.activity_entrust.*
import kotlinx.android.synthetic.main.activity_new_version_otc_buy.rb_amount_buy
import kotlinx.android.synthetic.main.activity_new_version_otc_buy.rb_price_buy
import kotlinx.android.synthetic.main.activity_new_version_otc_buy.stl_market_type
import kotlinx.android.synthetic.main.item_otc_buy_or_sell_detail.cet_total_money
import kotlinx.android.synthetic.main.item_otc_buy_or_sell_detail.tv_market_price
import kotlinx.android.synthetic.main.item_otc_buy_or_sell_detail.tv_total_money
import kotlinx.android.synthetic.main.item_otc_buy_or_sell_detail.v_line
import kotlinx.android.synthetic.main.trade_amount_view_new.view.*
import java.util.*
import kotlin.collections.ArrayList

/**
 * @Author lianshangljl
 * @Date 2023-03-10-16:07
 * @Email buptjinlong@163.com
 * @description
 */
@Route(path = RoutePath.EntrustActivity)
class EntrustActivity : NBaseActivity() {
    override fun setContentView() = R.layout.activity_entrust

    private val fragments = arrayListOf<Fragment>()
    private var titles: ArrayList<String> = arrayListOf()


    @JvmField
    @Autowired(name = ParamConstant.TYPE)
    var orderType = ParamConstant.BIBI_INDEX


    @JvmField
    @Autowired(name = "coinName")
    var coinName = ""

    var isFirst = true
    var currentItem = 0

    var coinList = arrayListOf<String>()

    override fun onInit(savedInstanceState: Bundle?) {
        super.onInit(savedInstanceState)
        titles.add(LanguageUtil.getString(this, "contract_text_currentEntrust"))
        titles.add(LanguageUtil.getString(this, "contract_text_historyCommision"))
        rb_current?.text = LanguageUtil.getString(this, "contract_text_currentEntrust")
        rb_history?.text = LanguageUtil.getString(this, "contract_text_historyCommision")
        tv_type2?.text = LanguageUtil.getString(this, "common_action_sendall")
        tv_type3?.text = LanguageUtil.getString(this, "common_action_alltypes")
        tv_type4?.text = LanguageUtil.getString(this, "common_action_allstatus")
        tv_type1.setText(coinName)
        initView()

    }


    override fun initView() {
        changeOrderTypeByPosition(0)
        stl_market_type?.apply {
            addTab(
                newTab().apply {
                    text = LanguageUtil.getString(this@EntrustActivity,"contract_text_currentEntrust")
                }
            )
            addTab(
                newTab().apply {
                    text = LanguageUtil.getString(this@EntrustActivity,"contract_text_historyCommision")
                }
            )
        }

        stl_market_type?.addOnTabSelectedListener(object: TabLayout.OnTabSelectedListener{
            override fun onTabSelected(tab: TabLayout.Tab?) {
                val position = stl_market_type.selectedTabPosition
                when(position){
                    0 -> {
                        /**
                         *Current delegation
                         */
                        rb_current?.typeface = Typeface.defaultFromStyle(Typeface.BOLD)
                        rb_current?.setTextSize(TypedValue.COMPLEX_UNIT_PX, resources.getDimensionPixelSize(R.dimen.sp_28).toFloat())
                        rb_current?.setTextColor(ContextCompat.getColor(this@EntrustActivity, R.color.text_color))

                        /**
                         *Historical commission
                         */
                        rb_history?.typeface = Typeface.defaultFromStyle(Typeface.NORMAL)
                        rb_history?.setTextSize(TypedValue.COMPLEX_UNIT_PX, resources.getDimensionPixelSize(R.dimen.sp_16).toFloat())
                        rb_history?.setTextColor(ContextCompat.getColor(this@EntrustActivity, R.color.normal_text_color))

                        currentItem = 0
                        (fragments[0] as CurrentEntrustFragment).initData()
                        viewPager?.currentItem = 0
                    }
                    1 -> {
                        /**
                         *Current delegation
                         */
                        rb_current?.typeface = Typeface.defaultFromStyle(Typeface.NORMAL)
                        rb_current?.setTextSize(TypedValue.COMPLEX_UNIT_PX, resources.getDimensionPixelSize(R.dimen.sp_16).toFloat())
                        rb_current?.setTextColor(ContextCompat.getColor(this@EntrustActivity, R.color.normal_text_color))
                        /**
                         *Historical commission
                         */
                        rb_history?.typeface = Typeface.defaultFromStyle(Typeface.BOLD)
                        rb_history?.setTextSize(TypedValue.COMPLEX_UNIT_PX, resources.getDimensionPixelSize(R.dimen.sp_28).toFloat())
                        rb_history?.setTextColor(ContextCompat.getColor(this@EntrustActivity, R.color.text_color))

                        currentItem = 1
                        (fragments[1] as HistoryEntrustFragment).initData()
                        viewPager?.currentItem = 1
                    }
                }
            }

            override fun onTabUnselected(tab: TabLayout.Tab?) {

            }

            override fun onTabReselected(tab: TabLayout.Tab?) {

            }

        })

        fragments.add(CurrentEntrustFragment.newInstance(orderType))
        fragments.add(HistoryEntrustFragment.newInstance(orderType))
        iv_back?.setOnClickListener { finish() }

        initTab()

        /**
         *Switch current delegation history delegation
         */
        rg_current_history?.setOnCheckedChangeListener { group, checkedId ->
            when (checkedId) {
                R.id.rb_current -> {
                    /**
                     *Current delegation
                     */
                    rb_current?.typeface = Typeface.defaultFromStyle(Typeface.BOLD)
                    rb_current?.setTextSize(TypedValue.COMPLEX_UNIT_PX, resources.getDimensionPixelSize(R.dimen.sp_28).toFloat())
                    rb_current?.setTextColor(ContextCompat.getColor(this, R.color.text_color))

                    /**
                     *Historical commission
                     */
                    rb_history?.typeface = Typeface.defaultFromStyle(Typeface.NORMAL)
                    rb_history?.setTextSize(TypedValue.COMPLEX_UNIT_PX, resources.getDimensionPixelSize(R.dimen.sp_16).toFloat())
                    rb_history?.setTextColor(ContextCompat.getColor(this, R.color.normal_text_color))

                    currentItem = 0
                    (fragments[0] as CurrentEntrustFragment).initData()
                    viewPager?.currentItem = 0
                }
                R.id.rb_history -> {
                    /**
                     *Current delegation
                     */
                    rb_current?.typeface = Typeface.defaultFromStyle(Typeface.NORMAL)
                    rb_current?.setTextSize(TypedValue.COMPLEX_UNIT_PX, resources.getDimensionPixelSize(R.dimen.sp_16).toFloat())
                    rb_current?.setTextColor(ContextCompat.getColor(this, R.color.normal_text_color))
                    /**
                     *Historical commission
                     */
                    rb_history?.typeface = Typeface.defaultFromStyle(Typeface.BOLD)
                    rb_history?.setTextSize(TypedValue.COMPLEX_UNIT_PX, resources.getDimensionPixelSize(R.dimen.sp_28).toFloat())
                    rb_history?.setTextColor(ContextCompat.getColor(this, R.color.text_color))

                    currentItem = 1
                    (fragments[1] as HistoryEntrustFragment).initData()
                    viewPager?.currentItem = 1

                }
            }
        }



        priceList.add(LanguageUtil.getString(this, "common_action_sendall"))
        priceList.add(LanguageUtil.getString(this, "exchange_order_normal_entrusts"))
        priceList.add(LanguageUtil.getString(this, "exchange_order_price_entrusts"))

        statusList.add(LanguageUtil.getString(this, "common_action_sendall"))
        statusList.add(LanguageUtil.getString(this, "contract_completely_clinch_deal"))
        statusList.add(LanguageUtil.getString(this, "contract_text_orderCancel"))


        tradeList.add(LanguageUtil.getString(this, "common_action_alltypes"))
        tradeList.add(LanguageUtil.getString(this, "contract_action_buy"))
        tradeList.add(LanguageUtil.getString(this, "contract_action_sell"))


        fl_type1.setOnClickListener {
            showBottomDialog(0)
        }
        fl_type2.setOnClickListener {
            showBottomDialog(1)
        }
        fl_type3.setOnClickListener {
            showBottomDialog(2)
        }
        fl_type4.setOnClickListener {
            showBottomDialog(3)
        }

    }

    /**
     *Load fragment
     */
    private var itemWidth = 0
    fun initTab() {
        itemWidth = (resources.displayMetrics.widthPixels / 4) - (resources.getDimensionPixelOffset(R.dimen.global_divider_width) * 3)
        val otcHomePageAdapter = NVPagerAdapter(supportFragmentManager, titles, fragments)
        viewPager?.adapter = otcHomePageAdapter
        viewPager?.offscreenPageLimit = 2
        viewPager?.addOnPageChangeListener(object : ViewPager.OnPageChangeListener {
            override fun onPageScrollStateChanged(state: Int) {

            }

            override fun onPageScrolled(i2: Int, positionOffset: Float, positionOffsetPixels: Int) {
                var f4: Float = 0f
                var f3: Float = 0f
                if (positionOffset == 0.0f) {
                    f4 = if (i2 == 0) 0.0f else itemWidth.toFloat()
                    f3 = 1.0f
                } else {
                    f4 = itemWidth.toFloat() * positionOffset
                    f3 = positionOffset
                }
                if (i2 == 0) {
                    changeItem(f4.toInt())
                    changeStatus(f3, i2)
                } else if (i2 == 1 && positionOffset > 0.0f) {
                    changeItem((itemWidth - f4).toInt())
                    changeStatus(1.0f - f3, i2)
                }
            }

            override fun onPageSelected(position: Int) {
                changeOrderTypeByPosition(position)

            }
        })
    }
    private fun changeOrderTypeByPosition(position:Int){
        if(position==0){
            fl_type2.isEnabled = false
            tv_type2.text = LanguageUtil.getString(this@EntrustActivity, "exchange_order_normal_entrusts")
//            tv_type2.setCompoundDrawablesWithIntrinsicBounds(null,null,null,null)
            img_type2.visibility=View.GONE
        }else{
            fl_type2.isEnabled = true
            tv_type2.text = priceList[priceType]
//            val drawable = this@EntrustActivity.getDrawable(R.mipmap.exchange_dropdown)
//            tv_type2.setCompoundDrawablesWithIntrinsicBounds(null,null,drawable,null)
            img_type2.visibility=View.VISIBLE
        }
    }

    private fun changeItem(i2: Int) {
        val showStatus = currentItem == 1
        val params = fl_type4.layoutParams
        if (params is LinearLayout.LayoutParams) {
            params.width = i2
            fl_type4.layoutParams = params
        }
//        ViewUtils.a(findViewById(R.id.v_line3), showStatus)
    }

    private fun changeStatus(f2: Float, i2: Int) {
        this.v_line3.alpha = f2
        this.tv_type4.alpha = f2
    }

    private var priceType = 0
    private var tradingType = 0
    private var statusType = 0


    private var symbolCoin = ""
    private var symbolAndUnit = ""

    private var priceList = arrayListOf<String>()
    private var statusList = arrayListOf<String>()
    private var tradeList = arrayListOf<String>()
    var dialogType: CpTDialog? = null
    private fun showBottomDialog(viewType: Int = 1) {
        if (viewType == 0) {
            img_type1.animate().setDuration(200).rotation(180f).start()
            val dialog = NewDialogUtils.showCoinBottomDialog(this, symbolCoin, symbolAndUnit, orderType == ParamConstant.LEVER_INDEX, object : NewDialogUtils.DialogBottomCoinListener {
                override fun returnTypeCode(phone: String?, mail: String?) {
                    symbolCoin = phone ?: ""
                    symbolAndUnit = mail ?: ""
                    val value = if (symbolAndUnit.isNotEmpty()) {
                        StringBuffer(symbolCoin).append("/").append(symbolAndUnit).toString()
                    } else {
                        if (symbolCoin.isNotEmpty()) symbolCoin else LanguageUtil.getString(mActivity, "common_action_allTradingPairs")
                    }
                    tv_type1.text = value
                    changePriceType()
                }

                override fun onDismiss() {
                    img_type1.animate().setDuration(200).rotation(0f).start()
                }
            })
        } else {
            val list = when (viewType) {
                1 -> priceList
                2 -> tradeList
                else -> statusList
            }
            val statusTypeTemp = when (viewType) {
                1 -> priceType
                2 -> tradingType
                else -> statusType
            }

            when (viewType){
                1 ->    img_type2.animate().setDuration(200).rotation(180f).start()
                2 ->    img_type3.animate().setDuration(200).rotation(180f).start()
                else -> img_type4.animate().setDuration(200).rotation(180f).start()
            }
            dialogType = NewDialogUtils.showBottomListDialog(this, list, statusTypeTemp, object : NewDialogUtils.DialogOnclickListener {
                override fun clickItem(data: ArrayList<String>, item: Int) {
//                    tv_order_type?.textContent = data[item]
//                    changePriceType(item)
                    dialogType?.dismiss()
                    when (viewType) {
                        1 -> {
                            tv_type2.text = data[item]
                            priceType = item
                        }
                        2 -> {
                            tv_type3.text = data[item]
                            tradingType = item
                        }
                        else -> {
                            tv_type4.text = data[item]
                            statusType = item
                        }
                    }
                    changePriceType()
                }

                override fun onDismiss() {
                    img_type2.animate().setDuration(200).rotation(0f).start()
                    img_type3.animate().setDuration(200).rotation(0f).start()
                    img_type4.animate().setDuration(200).rotation(0f).start()
                }
            })
        }

    }

    private fun changePriceType() {
        val status = if (currentItem == 0) false else statusType == 0
        HistoryScreeningControl.getInstance().updateListener(status, statusType, symbolCoin, symbolAndUnit, tradingType, priceType, "", "")
    }

}
