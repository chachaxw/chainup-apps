package com.yjkj.chainup.freestaking

import android.os.Bundle
import android.view.View
import androidx.recyclerview.widget.LinearLayoutManager
import com.alibaba.android.arouter.facade.annotation.Route
import com.google.android.material.appbar.AppBarLayout
import com.yjkj.chainup.R
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.freestaking.adapter.IncomeRecyclerAdapter
import com.yjkj.chainup.freestaking.bean.UserGainListBean
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.new_version.activity.NewBaseActivity
import kotlinx.android.synthetic.main.activity_income_detail.*
import kotlinx.android.synthetic.main.activity_income_detail.anim_toolbar
import kotlinx.android.synthetic.main.activity_income_detail.iv_back
import kotlinx.android.synthetic.main.activity_income_detail.ly_appbar
import kotlinx.android.synthetic.main.activity_income_detail.tv_sub_title
import kotlinx.android.synthetic.main.activity_income_detail.tv_title

/**
 *Revenue Details
 */
@Route(path = RoutePath.IncomeDetailActivity)
class IncomeDetailActivity : NewBaseActivity() {
    var userGainList=ArrayList<UserGainListBean>()
    lateinit var adapter: IncomeRecyclerAdapter
    var baseCoin: String="";
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_income_detail)
        val bundle = intent.extras
        val list = bundle?.getParcelableArrayList<UserGainListBean>("userGainList")
        baseCoin = bundle?.getString("baseCoin","").toString()
        userGainList.clear()
        userGainList.addAll(list!!)
        if(userGainList.isEmpty()) rl_head.visibility = View.GONE
        initView()
        initClick()



    }

    private fun initClick() {
        iv_back?.setOnClickListener {
            finish()
        }
    }

    private fun initView() {
        setSupportActionBar(anim_toolbar)

        ly_appbar.addOnOffsetChangedListener(object : AppBarLayout.OnOffsetChangedListener{
            override fun onOffsetChanged(appBarLayout: AppBarLayout?, verticalOffset: Int) {
                if (Math.abs(verticalOffset) >= 140) {
                    tv_title?.visibility = View.VISIBLE
                    tv_sub_title?.visibility = View.GONE
                } else {
                    tv_title?.visibility = View.GONE
                    tv_sub_title?.visibility = View.VISIBLE
                }
            }

        })

        val layoutManager = LinearLayoutManager(this, LinearLayoutManager.VERTICAL, false)
        rv_income.layoutManager=layoutManager
        adapter= IncomeRecyclerAdapter(userGainList)
        rv_income.adapter=adapter
//        adapter.bindToRecyclerView(rv_income)
        adapter.setEmptyView(R.layout.item_new_empty)

        tv_sub_title.setText(LanguageUtil.getString(this,"pos_string_earnDetail"))
        tv_income_time.setText(LanguageUtil.getString(this,"pos_string_timeEarn"))
        tv_income_number.setText(LanguageUtil.getString(this,"pos_string_earnNumber")+"(${baseCoin})")
    }


}
