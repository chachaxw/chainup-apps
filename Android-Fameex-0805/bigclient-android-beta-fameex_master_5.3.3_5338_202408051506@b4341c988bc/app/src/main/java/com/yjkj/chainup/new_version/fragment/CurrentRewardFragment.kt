package com.yjkj.chainup.new_version.fragment

import android.util.Log
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.LinearLayoutManager
import com.chainup.kit.views.KKEmptyViewKit
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseFragment
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.net_new.JSONUtil
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_version.activity.MyRewardActivity
import com.yjkj.chainup.new_version.adapter.RewardDetailAdapter
import com.yjkj.chainup.util.PageInfo
import kotlinx.android.synthetic.main.fragment_reward_list.rv_listview
import org.json.JSONObject


/**
 * A simple [Fragment] subclass.
 * Use the [CurrentRewardFragment.newInstance] factory method to
 * create an instance of this fragment.
 */
class CurrentRewardFragment : NBaseFragment() {
    private val pageSize = 15
    private val adapter by lazy { RewardDetailAdapter(RewardDetailAdapter.currentRecord) }
    val pageInfo by lazy { PageInfo() }
    override fun initView() {
        rv_listview.layoutManager = LinearLayoutManager(mActivity,LinearLayoutManager.VERTICAL,false)
        rv_listview.adapter = adapter.apply {
            setEmptyView(KKEmptyViewKit(mActivity!!))
        }

        adapter.loadMoreModule.run{
            setOnLoadMoreListener {
                if(isLoading) return@setOnLoadMoreListener
                pageInfo.nextPage()
                loadData()
            }
            isAutoLoadMore = true
            isEnableLoadMoreIfNotFullPage = false
        }

    }

    override fun setContentView(): Int = R.layout.fragment_reward_list

    override fun loadData() {
        addDisposable(getMainModel().getUserRewardUnWithdraw(pageInfo.page,pageSize,consumer = object: NDisposableObserver(){
            override fun onResponseSuccess(jsonObject: JSONObject) {
                if(jsonObject.isNull("data")) {
                    adapter.loadMoreModule.loadMoreEnd()
                    return
                }
                val data = jsonObject.getJSONObject("data")
                val optJSONArray = data.optJSONArray("unWithdrawList")
                val usdtAmount = data.optString("usdtAmount")
                val myRewardActivity = activity as MyRewardActivity
                myRewardActivity.updateUSDTAmount(usdtAmount)
                if(optJSONArray==null){
                    adapter.loadMoreModule.loadMoreEnd()
                    return
                }
                val arrayToList = JSONUtil.arrayToList(optJSONArray)
                if(pageInfo.isFirstPage){
                    adapter.setList(arrayToList)
                }else{
                    adapter.addData(arrayToList)
                }



                if(optJSONArray.length()<=0 || optJSONArray.length()<pageSize){
                    adapter.loadMoreModule.loadMoreEnd()
                }else{
                    adapter.loadMoreModule.loadMoreComplete()
                }


            }

        }))
    }

    override fun onMessageEvent(event: MessageEvent) {
        super.onMessageEvent(event)
        when(event.msg_type){
            MessageEvent.refresh_reward_detail -> {
                if(mActivity==null) return
                pageInfo.reset()
                loadData()
            }
        }
    }

    companion object {

        @JvmStatic
        fun newInstance() = CurrentRewardFragment()
    }
}