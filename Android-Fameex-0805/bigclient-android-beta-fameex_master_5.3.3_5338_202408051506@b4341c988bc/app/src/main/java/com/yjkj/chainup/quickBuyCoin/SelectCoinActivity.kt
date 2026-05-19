package com.yjkj.chainup.quickBuyCoin

import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.os.Bundle
import android.text.Editable
import android.text.TextUtils
import android.text.TextWatcher
import android.widget.Filter
import android.widget.Filterable
import android.widget.ImageView
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import com.alibaba.android.arouter.facade.annotation.Route
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseActivity
import com.yjkj.chainup.bean.Coin
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.extra_service.eventbus.EventBusUtil
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.new_version.adapter.QuickSelectCoinAdapter
import com.yjkj.chainup.new_version.adapter.SelectCoinAdapter
import com.yjkj.chainup.util.ResourcesUtils
import com.yjkj.chainup.util.tr
import kotlinx.android.synthetic.main.activity_search_coin.*
import kotlinx.android.synthetic.main.activity_select_coin.*
import kotlinx.android.synthetic.main.activity_select_coin.et_search
import kotlinx.android.synthetic.main.activity_select_coin.tv_cancel
import org.json.JSONObject


@Route(path = RoutePath.SelectQuickBuyCoinActivity)
class SelectCoinActivity : NBaseActivity() {

    private lateinit var mDataList: ArrayList<Coin>
    private lateinit var mBufferAdapter: QuickSelectCoinAdapter
    var type = ""
    lateinit var coin_list: ArrayList<Coin>
    override fun setContentView(): Int {
        return R.layout.activity_select_coin
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        et_search.hint = "cl_market_text8".tr(this)
        type = intent.getStringExtra("type").toString()
        coin_list = intent.getSerializableExtra("data") as ArrayList<Coin>
        mDataList = ArrayList()
        mDataList.addAll(coin_list)
        mBufferAdapter = QuickSelectCoinAdapter(mDataList)
        rv_coinmap.apply {
            layoutManager = LinearLayoutManager(this@SelectCoinActivity)
            adapter = mBufferAdapter
        }
        mBufferAdapter.setOnItemClickListener { adapter, view, position ->
            if (type.equals("fiat")) {
                val message = MessageEvent(MessageEvent.sel_fiat_change)
                message.msg_content = mDataList[position]
                EventBusUtil.post(message)
            } else {
                val message = MessageEvent(MessageEvent.sel_coin_change)
                message.msg_content = mDataList[position]
                EventBusUtil.post(message)
            }
            finish()
        }
        et_search?.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(s: Editable?) {

            }
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {
            }

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
                if(TextUtils.isEmpty(s)) {
                    mBufferAdapter.showAll(coin_list);
                } else {
                     var mSearchList: ArrayList<Coin> = ArrayList<Coin>()
                    for (buff in coin_list){
                        if (TextUtils.isEmpty(buff.alias)){
                            if (buff.name.toLowerCase().contains(et_search.text.toString().toLowerCase())){
                                mSearchList.add(buff)
                            }
                        }else{
                            if (buff.alias.toLowerCase().contains(et_search.text.toString().toLowerCase())){
                                mSearchList.add(buff)
                            }
                        }
                    }
                    mBufferAdapter.showAll(mSearchList);
                }
            }
        })

        tv_cancel.setOnClickListener { finish() }
    }

}
