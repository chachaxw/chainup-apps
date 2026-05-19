package com.yjkj.chainup.new_version.activity.personalCenter

import android.os.Bundle
import android.view.View
import androidx.recyclerview.widget.LinearLayoutManager
import com.chainup.kit.utils.ToastUtils
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseActivity
import com.yjkj.chainup.bean.AboutUSBean
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.net.HttpClient
import com.yjkj.chainup.net.api.ApiConstants
import com.yjkj.chainup.net.retrofit.NetObserver
import com.yjkj.chainup.new_version.adapter.AbountAdapter
import com.yjkj.chainup.new_version.view.CommonlyUsedButton
import com.yjkj.chainup.util.CheckUpdateUtil
import com.yjkj.chainup.util.PackageInfoUtils
import com.yjkj.chainup.util.Utils
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.activity_about.*

/**
 *About
 */
class AboutActivity : NBaseActivity() {
    val adapter:AbountAdapter by lazy { AbountAdapter() }
    var dataList:ArrayList<AboutUSBean> = arrayListOf()
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }
    override fun setContentView(): Int {
        return R.layout.activity_about
    }


    override fun onInit(savedInstanceState: Bundle?) {
        super.onInit(savedInstanceState)
        initView()
        loadData()
    }


    override fun initView() {
        if (!ApiConstants.isGooglePlay()) {
            cub_submit?.visibility = View.GONE
        }
        cub_submit.isEnable(true)
        cub_submit.listener = object : CommonlyUsedButton.OnBottonListener {
            override fun bottonOnClick() {
                CheckUpdateUtil.update(mActivity, false)
            }
        }
        v_title?.setContentTitle(LanguageUtil.getString(this, "personal_text_aboutus"))
        cub_submit?.setBottomTextContent(LanguageUtil.getString(this, "personal_action_checkUpdate"))

        val linearLayoutManager = LinearLayoutManager(this@AboutActivity,LinearLayoutManager.VERTICAL,false)
        rv_about.layoutManager = linearLayoutManager
        rv_about.adapter = adapter

        adapter.setOnItemClickListener { adapter, view, position ->
            if (position != 0) {
                val iBean = dataList[position]
                Utils.copyString(iBean.content)
                ToastUtils.showToast(
                    this@AboutActivity,
                    LanguageUtil.getString(this@AboutActivity, "common_tip_copySuccess")
                )
            }
        }
    }

    /**
     *Get information about us
     */
    override fun loadData() {
        super.loadData()
        HttpClient.instance.getAboutUs()
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<ArrayList<AboutUSBean>>() {
                    override fun onHandleSuccess(list: ArrayList<AboutUSBean>?) {
                        dataList.clear()
                        if (list == null) return
                        list.add(0, AboutUSBean(LanguageUtil.getString(this@AboutActivity, "common_text_versionCode"), PackageInfoUtils.packageNameOrCode(this@AboutActivity)))
                        dataList.addAll(list)
                        adapter.setList(dataList)
                    }
                })
    }

}
