package com.yjkj.chainup.new_version.activity

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Bundle
import androidx.recyclerview.widget.LinearLayoutManager
import android.text.Editable
import android.text.TextUtils
import android.text.TextWatcher
import com.chainup.contract.utils.CpClLogicContractSetting
import com.chainup.contract.utils.CpPreferenceManager
import com.yjkj.chainup.R
import com.yjkj.chainup.app.AppConstant
import com.yjkj.chainup.bean.coin.CoinBean
import com.yjkj.chainup.manager.DataManager
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.new_version.view.EmptyForAdapterView
import com.yjkj.chainup.util.StringUtil
import com.yjkj.chainup.wedegit.SectionDecoration
import kotlinx.android.synthetic.main.activity_coin.*
import org.json.JSONArray

/**
 *@description Currency
 * @author Bertking
 * @Date 2023-6-7
 *
 *Mainly for selecting and searching currency not the CoinMap (currency pair)
 *Entrance:
 *1 Capital flow;
 *2 Recharge, select currency;
 *3 Withdrawal, selection of currency;
 *
 */
class CoinActivity : NewBaseActivity() {

    var coinList = ArrayList<CoinBean>()

    var coinType = ""
    private lateinit var selectedCoin: String
    var cashStatus = false
    private var needHasAll: Boolean = false
    var selectPosition = 0

    companion object {
        const val SELECTED_COIN = "selected_coin"
        const val SELECTED_ID = "selected_id"
        const val SELECTED_STATUS = "selected_status"
        const val SELECTED_TYPE = "SELECTED_TYPE"
        const val HAS_ALL = "has_all"
        const val OTC_TYPE = "OTC_TYPE"
        const val OTC_CONTRACT = "OTC_CONTRACT"
        const val COIN_REQUEST_CODE = 2018

        /**
         *The contract with otcOpen=1 in the @param type currency display value otc is currently only available in btc
         */
        fun enter4Result(context: Context, selectedCoin: String, needHasAll: Boolean, position: Int, cashStatus: Boolean = false, type: String = "") {
            var intent = Intent(context, CoinActivity::class.java)
            intent.putExtra(SELECTED_COIN, selectedCoin)
            intent.putExtra(HAS_ALL, needHasAll)
            intent.putExtra(SELECTED_STATUS, cashStatus)
            intent.putExtra(SELECTED_ID, position)
            intent.putExtra(SELECTED_TYPE, type)
            (context as Activity).startActivityForResult(intent, COIN_REQUEST_CODE)
        }
    }


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        context = this
        setContentView(R.layout.activity_coin)

        tv_cancel?.setOnClickListener { finish() }

        tv_cancel?.text = LanguageUtil.getString(this, "common_text_btnCancel")
        et_search?.hint = LanguageUtil.getString(this, "common_action_searchCoinPair")

        selectedCoin = intent.getStringExtra(SELECTED_COIN) ?: ""
        cashStatus = intent.getBooleanExtra(SELECTED_STATUS, false)
        needHasAll = intent.getBooleanExtra(HAS_ALL, false)
        selectPosition = intent.getIntExtra(SELECTED_ID, selectPosition)
        coinType = intent.getStringExtra(SELECTED_TYPE) ?: ""


        if (coinType.isEmpty()) {
            val tempList = DataManager.getCoinsFromDB()
            coinList.clear()
            coinList.addAll(tempList)

            if (needHasAll) {
                val coinBean = CoinBean(0, "0", LanguageUtil.getString(this, "select_all_coin"), "", 0, false, 0, 0, "", LanguageUtil.getString(this, "select_all_coin"))
                et_search.hint = LanguageUtil.getString(this, "common_action_searchCoinPair")
                coinList.add(0, coinBean)
                coinBean.isSelected = TextUtils.isEmpty(selectedCoin)
            }
        } else {
            when (coinType) {
                OTC_TYPE -> {
                    coinList = DataManager.getCoinsFromDB(true)
                }
                OTC_CONTRACT -> {
//                    val coinBean = CoinBean(0, "0", "BTC", "", 0, true, 0, 0, "", "BTC")
//                    coinList = arrayListOf(coinBean)
                    if (AppConstant.IS_NEW_CONTRACT) {
                        val mContractMarginCoinListJsonStr = CpClLogicContractSetting.getContractMarginCoinListStr(this)
                        if (mContractMarginCoinListJsonStr != null && mContractMarginCoinListJsonStr.isNotEmpty()) {
                            val jsonArray = JSONArray(mContractMarginCoinListJsonStr)
                            for (i in 0 until jsonArray.length()) {
                                val codeName = jsonArray[i] as String
                                val coinBean = CoinBean(0, "0", codeName, "", 0, false, 0, 0, "", codeName)
                                coinList.add(coinBean)
                            }
                        }
                    } else {
                        //Select currency for contract transfer, and the currency list comes from the contract interface
                        val coinJsonStr = CpPreferenceManager.getInstance(this).getSharedString("contract#bibi#coin", "")
                    }
                }
            }
        }

        coinList.forEach {
            if (it.name == selectedCoin) {
                it.isSelected = true
            }
        }
        coinList.sortBy { it.name }

        sb_coin?.setOnTouchingLetterChangedListener { s ->
            for (i in 0 until coinList.size) {
                if (coinList[i].getStickItem().equals(s, true)) {
                    rv_coin?.scrollToPosition(i)
                    break
                }
            }
        }
        initViews()
    }

    fun initViews() {
        rv_coin?.layoutManager = LinearLayoutManager(context)
        val adapter = SelectCoinAdapter(coinList, selectPosition)
        adapter.setEmptyView(EmptyForAdapterView(context))
        rv_coin?.adapter = adapter
        adapter.setOnItemClickListener { adapter, view, position ->
            val intent = Intent()
            if (cashStatus) {
                if (position == 0) {
                    intent.putExtra(SELECTED_COIN, "")
                } else {
                    intent.putExtra(SELECTED_COIN, coinList[position].name)
                }
            } else {
                intent.putExtra(SELECTED_COIN, coinList[position].name)
            }

            intent.putExtra(SELECTED_ID, position)
            setResult(Activity.RESULT_OK, intent)
            finish()
        }


        adapter.setListener { list ->
            /**
             *Get the filtered data here
             */
            /**
             *Get the filtered data here
             */
            
            coinList.clear()
            coinList.addAll(list ?: arrayListOf())
            adapter.setList(list)
        }
        rv_coin?.addItemDecoration(SectionDecoration(this, object : SectionDecoration.DecorationCallback {
            override fun getGroupFirstLine(position: Int): String {
                if (position >= coinList.size) {
                    return ""
                }
                var stick = coinList[position].getStickItem()
                if (StringUtil.checkStr(stick)) {
                    return stick.substring(0, 1).toLowerCase()
                }
                return ""
            }

            override fun getGroupId(position: Int): Long {
                if (coinList.isNotEmpty() && coinList.size > position) {
                    return Character.toUpperCase(coinList[position].getStickItem()[0]).toLong()
                } else {
                    return 0
                }
            }

        }))


        /**
         *Listening search edit box
         */
        et_search?.setSearch()
        et_search?.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(s: Editable?) {

            }

            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {
            }

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
                //If the adapter is not empty, filter the data based on the content in the edit box
                
                adapter.filter?.filter(s)
            }

        })

    }


}
