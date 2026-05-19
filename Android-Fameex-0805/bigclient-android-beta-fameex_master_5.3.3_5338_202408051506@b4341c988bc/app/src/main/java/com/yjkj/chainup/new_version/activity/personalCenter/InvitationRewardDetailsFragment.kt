package com.yjkj.chainup.new_version.activity.personalCenter

import android.os.Bundle
import androidx.recyclerview.widget.LinearLayoutManager
import com.chainup.kit.utils.ToastUtils
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseFragment
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.net.HttpClient
import com.yjkj.chainup.net.retrofit.NetObserver
import com.yjkj.chainup.net_new.JSONUtil
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_version.adapter.InvitationAdapter
import com.yjkj.chainup.new_version.bean.InvitationsList
import com.yjkj.chainup.new_version.bean.InviteConfig
import com.yjkj.chainup.new_version.bean.MyInvitationRewardsListBean
import com.yjkj.chainup.new_version.bean.MyInvitationsListBean
import com.yjkj.chainup.new_version.view.EmptyForAdapterView
import com.yjkj.chainup.util.NToastUtil
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.fragment_invitation_details.*
import org.json.JSONObject

/**
 * @Author lianshangljl
 * @Date 2023-08-28-15:27
 * @Email buptjinlong@163.com
 * @description
 */
class InvitationRewardDetailsFragment : NBaseFragment() {


    companion object {

        @JvmStatic
        fun newInstance(orderType: String) =
                InvitationRewardDetailsFragment().apply {
                    arguments = Bundle().apply {
                        putString(ParamConstant.TYPE, orderType)

                    }
                }
    }

    var type = ParamConstant.MY_INVITATION

    override fun loadData() {
        arguments.let {
            type = it?.getString(ParamConstant.TYPE, ParamConstant.MY_INVITATION)
                    ?: ParamConstant.MY_INVITATION
        }
    }

    var adapter: InvitationAdapter? = null
    var invitationList: ArrayList<MyInvitationsListBean> = arrayListOf()

    override fun initView() {
        when (type) {
            ParamConstant.MY_INVITATION -> {
                tv_title_1?.text = LanguageUtil.getString(context, "UID")
                tv_title_2?.text = LanguageUtil.getString(context, "registered_account")
                tv_title_3?.text = LanguageUtil.getString(context, "registration_date")
                getMyInvitations()
            }
            ParamConstant.INVITE_REWARDS -> {
                tv_title_1?.text = LanguageUtil.getString(context, "release_time")
                tv_title_2?.text = LanguageUtil.getString(context, "registered_account")
                tv_title_3?.text = LanguageUtil.getString(context, "rewards_amount") + "(USDT)"
                getMyInvitationRewards(true)
            }
        }

        val layoutManager = LinearLayoutManager(activity)
        layoutManager.setOrientation(LinearLayoutManager.VERTICAL)
        rv_invitation_reward_detail.setLayoutManager(layoutManager)
        adapter = InvitationAdapter(invitationList)
        adapter?.type = type
        rv_invitation_reward_detail?.adapter = adapter
        adapter?.setEmptyView(EmptyForAdapterView(context ?: return))
        adapter?.loadMoreModule?.isEnableLoadMore = false

        initListener()
    }

    val pageSize = 20

    fun initData(isMoreRef: Boolean, list: ArrayList<JSONObject>) {
        if (activity?.isFinishing ?: return || activity?.isDestroyed ?: return || !isAdded) {
            return
        }
//        if (list.isNotEmpty()) {
//            if (isMoreRef) {
//                adapter?.setList(list)
//            } else {
//                adapter?.addData(list)
//            }
//            val isMore = list.size == pageSize
//            if (isMore) page += 1
//            adapter?.apply {
//                loadMoreModule.let {
//                    it.isEnableLoadMore = true
//                    if (!isMore) {
//                        it.loadMoreEnd(isMoreRef)
//                    } else {
//                        it.loadMoreComplete()
//                    }
//                }
//            }
//
//        } else {
//            if (isMoreRef) adapter?.setList(null)
//            if (isMoreRef) adapter?.setEmptyView(EmptyForAdapterView(context ?: return))
//            adapter?.loadMoreModule?.loadMoreEnd(!isMoreRef)
//        }
//        refresh_layout?.finishRefresh(true)
    }

    fun initListener() {
//        adapter?.loadMoreModule?.setOnLoadMoreListener { loadMore() }
        refresh_layout?.setOnRefreshListener {
            page = 1
            if(type.equals(ParamConstant.MY_INVITATION)){
                getMyInvitations()
            }else{
                getMyInvitationRewards()
            }

        }
        refresh_layout?.setOnLoadMoreListener {
            page += 1
            if(type.equals(ParamConstant.MY_INVITATION)){
                getMyInvitations(false)
            }else{
                getMyInvitationRewards(false)
            }
        }
    }

    override fun setContentView() = R.layout.fragment_invitation_details

    private var page = 1


    fun refresh() {
        page = 1
        requestInterface(true)
    }

    fun loadMore() {
        requestInterface(false)
    }

    fun requestInterface(status: Boolean) {
        when (type) {
            ParamConstant.MY_INVITATION -> {
//                getMyInvitations(status)
                getMyInvitations();
            }
            ParamConstant.INVITE_REWARDS -> {
                getMyInvitationRewards(status)
            }
        }
    }

    fun setChangeItem(type: String) {
        adapter?.type = type
    }

    /**
     *My invitation
     */
//    fun getMyInvitations(status: Boolean) {
//        addDisposable(getMainModel().getMyInvitations(page.toString(), object : NDisposableObserver() {
//            override fun onResponseSuccess(jsonObject: JSONObject) {
//                var data = jsonObject.optJSONObject("data") ?: return
//                var invitationJSONArray = data?.optJSONArray("invitationList") ?: return
//                var invitatList = JSONUtil.arrayToList(invitationJSONArray) ?: return
//                initData(status, invitatList)
//            }
//
//            override fun onResponseFailure(code: Int, msg: String?) {
//                super.onResponseFailure(code, msg)
//                refresh_layout?.finishRefresh(true)
//                invitationList.clear()
//                adapter?.notifyDataSetChanged()
//                NToastUtil.showTopToastNet(this.mActivity,false, msg)
//            }
//        }))
//    }

    private fun getMyInvitations(isRefresh:Boolean?=true){
        HttpClient.instance.getMyInvitations(page)
            .subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(object: NetObserver<InvitationsList>(){
                override fun onHandleSuccess(t: InvitationsList?) {
                    if(isRefresh==true){
                        invitationList.clear()
                        refresh_layout?.finishRefresh(100,true, t?.invitationList?.size!! < 20)
                    }else{
                        refresh_layout?.finishLoadMore(100,true, t?.invitationList?.size!! < 20)
                    }
                    t?.let { invitationList.addAll(it.invitationList) }
                    adapter?.notifyDataSetChanged()
                }

                override fun onHandleError(code: Int, msg: String?) {
                    if(isRefresh==true){
                        refresh_layout?.finishRefresh(false)
                    }else{
                        refresh_layout?.finishLoadMore(false)
                    }
                }
            })
    }

    /**
     *Invitation rewards
     */
    fun getMyInvitationRewards(isRefresh:Boolean?=true) {
        HttpClient.instance.getMyInvitationsRewards(page)
            .subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(object: NetObserver<InvitationsList>(){
                override fun onHandleSuccess(t: InvitationsList?) {
                    if(isRefresh==true){
                        invitationList.clear()
                        refresh_layout?.finishRefresh(100,true, t?.rewardList?.size!! < 20)
                    }else{
                        refresh_layout?.finishLoadMore(100,true, t?.rewardList?.size!! < 20)
                    }
                    t?.let { invitationList.addAll(it.rewardList) }
                    adapter?.notifyDataSetChanged()
                }

                override fun onHandleError(code: Int, msg: String?) {
                    if(isRefresh==true){
                        refresh_layout?.finishRefresh(false)
                    }else{
                        refresh_layout?.finishLoadMore(false)
                    }
                }
            })
//        addDisposable(getMainModel().getMyInvitationRewards(page.toString(), object : NDisposableObserver() {
//            override fun onResponseSuccess(jsonObject: JSONObject) {
//                var data = jsonObject.optJSONObject("data")
//                var rewardJSONArray = data?.optJSONArray("rewardList")
//                var rewardList = JSONUtil.arrayToList(rewardJSONArray) ?: return
//                initData(status, rewardList)
//            }
//
//            override fun onResponseFailure(code: Int, msg: String?) {
//                super.onResponseFailure(code, msg)
//                refresh_layout?.finishRefresh(true)
//                invitationList.clear()
//                adapter?.notifyDataSetChanged()
//                NToastUtil.showTopToastNet(this.mActivity,false, msg)
//            }
//        }))
    }


}
