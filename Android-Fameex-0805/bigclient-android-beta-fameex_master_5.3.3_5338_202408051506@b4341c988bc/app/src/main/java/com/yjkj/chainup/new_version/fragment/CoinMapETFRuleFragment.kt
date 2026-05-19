package com.yjkj.chainup.new_version.fragment


import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.databinding.ViewDataBinding
import androidx.fragment.app.Fragment
import androidx.lifecycle.Observer
import androidx.recyclerview.widget.LinearLayoutManager
import com.chainup.contract.view.CpEmptyForAdapterView
import com.chainup.kit.views.KKEmptyViewKit
import com.jaeger.library.StatusBarUtil
import com.yjkj.chainup.R
import com.yjkj.chainup.databinding.FragmentCoinMapEtfBinding
import com.yjkj.chainup.databinding.FragmentCoinMapEtfRuleBinding
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.extra_service.eventbus.NLiveDataUtil
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.model.model.MainModel
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.util.ClipboardUtil
import com.yjkj.chainup.util.DisplayUtil
import com.yjkj.chainup.util.LogUtil
import com.yjkj.chainup.wedegit.WrapContentViewPager
import io.reactivex.disposables.CompositeDisposable
import org.jetbrains.anko.sdk27.coroutines.onClick
import org.json.JSONObject
import com.yjkj.chainup.databinding.FragmentCoinMapIntroBinding
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.new_version.adapter.LevertAdapter
import com.yjkj.chainup.util.toList
import kotlinx.android.synthetic.main.fragment_coin_map_etf.*
import kotlinx.android.synthetic.main.fragment_coin_map_etf.tv_block
import kotlinx.android.synthetic.main.fragment_coin_map_etf.tv_official_web
import kotlinx.android.synthetic.main.fragment_coin_map_etf.tv_publish_total_amount
import kotlinx.android.synthetic.main.fragment_coin_map_etf.tv_web
import kotlinx.android.synthetic.main.fragment_coin_map_etf_rule.*


/**
 *@description: Currency Introduction
 * @Date 2023-4-15
 * @author Bertking
 *
 */
class CoinMapETFRuleFragment : Fragment() {
    val TAG = CoinMapETFRuleFragment::class.java.simpleName

    private var viewPager: WrapContentViewPager? = null

    private val items = ArrayList<JSONObject>()
    private var mLevertAdapter:LevertAdapter? = null

    private var symbol = "btcusdt"
    private var index = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        arguments?.let {
            symbol = it.getString(ParamConstant.symbol) ?: "btcusdt"
            index = it.getInt(ParamConstant.CUR_INDEX)
        }
    }
    lateinit var binding: FragmentCoinMapEtfRuleBinding

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?,
                              savedInstanceState: Bundle?): View? {
        binding = DataBindingUtil.inflate(inflater, R.layout.fragment_coin_map_etf_rule, container, false);

        var view = binding.root
        if (viewPager != null) {
            viewPager?.setObjectForPosition(view, index)
        }
        if (PublicInfoDataService.getInstance().klineThemeMode == 1) {
            binding.isblack = true
        }
        rb_info?.setOnClickListener {

        }
        binding.rgLayout.setOnCheckedChangeListener { radioGroup, i ->
            when (i) {
                R.id.rb_info -> {
                    layout_info?.visibility = View.VISIBLE
                    layout_info_list?.visibility = View.GONE
                }
                R.id.rb_list -> {
                    layout_info_list?.visibility = View.VISIBLE
                    layout_info?.visibility = View.GONE
                }
            }
        }
        return view
    }


    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        tv_publish_total_amount?.text = LanguageUtil.getString(context, "etf_notes_lever_next_if")
        tv_currentTotal?.text = LanguageUtil.getString(context, "market_text_currentTotal")
        tv_web?.text = LanguageUtil.getString(context, "etf_notes_lever_manual")
        tv_block?.text = LanguageUtil.getString(context, "etf_notes_lever_auto")

        NLiveDataUtil.observeData(this, Observer {
            if (null != it && MessageEvent.symbol_switch_type == it.msg_type) {
                if (null != it.msg_content) {
                    symbol = it.msg_content as String
                    fetchCoinIntro()
                }
            }
        })
        binding.rcvDynamicList.layoutManager = LinearLayoutManager(context)
        mLevertAdapter = LevertAdapter(items)
        mLevertAdapter?.setEmptyView(KKEmptyViewKit(requireContext()))
        mLevertAdapter?.isBlack = PublicInfoDataService.getInstance().klineThemeMode == 1
        binding.rcvDynamicList.adapter = mLevertAdapter
        fetchCoinIntro()
    }

    private fun fetchCoinIntro() {
        getCoinIntro(symbol)
    }

    companion object {
        fun newInstance(viewPager: WrapContentViewPager, symbol: String?, index: Int = 0) =
                CoinMapETFRuleFragment().apply {
                    this.viewPager = viewPager
                    arguments = Bundle().apply {
                        putString(ParamConstant.symbol, symbol)
                        putInt(ParamConstant.CUR_INDEX, index)
                    }
                }
    }


    private fun initView(jsonObject: JSONObject) {
        jsonObject.run {
            val price = optString("price") ?: "--"
            val topNum = optString("maxLeverValue", "--")

            tv_official_web?.text = "${LanguageUtil.getString(context, "etf_text_networth_current")}: $price"
            tv_web?.text = LanguageUtil.getString(context, "etf_notes_lever_manual").format(topNum)
        }
    }

    /**
     *Get Currency Introduction
     */
    private fun getCoinIntro(coinName: String) {
        CompositeDisposable().add(MainModel().getETFPositionRecordList(symbol = coinName, consumer = object : NDisposableObserver() {
            override fun onResponseSuccess(data: JSONObject) {
                LogUtil.d(TAG, "getCoinIntro==data is " + data)
                val date = data.optJSONObject("data")
                date?.apply {
                    val datas = optJSONArray("etfPositionRecordList")
                    if (datas != null && datas.length() != 0){
                        items.clear()
                        items.addAll(datas.toList())
                        mLevertAdapter?.notifyDataSetChanged()
                    }
                }

            }

            override fun onResponseFailure(code: Int, msg: String?) {
                super.onResponseFailure(code, msg)

            }

        })!!)
    }

    fun changeETF(jsonObject: JSONObject?) {
        //Current net value
        jsonObject?.apply {
            initView(this)
        }
    }

}
