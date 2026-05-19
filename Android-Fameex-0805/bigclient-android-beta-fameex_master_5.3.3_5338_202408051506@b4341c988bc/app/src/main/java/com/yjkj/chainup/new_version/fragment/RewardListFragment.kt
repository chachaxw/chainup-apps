package com.yjkj.chainup.new_version.fragment

import android.content.Intent
import android.content.Intent.FLAG_ACTIVITY_CLEAR_TOP
import android.content.Intent.FLAG_ACTIVITY_SINGLE_TOP
import android.os.Bundle
import android.util.Log
import androidx.recyclerview.widget.LinearLayoutManager
import com.blankj.utilcode.util.GsonUtils
import com.chainup.kit.utils.ToastUtils
import com.chainup.kit.views.KKEmptyViewKit
import com.google.gson.reflect.TypeToken
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseFragment
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.extra_service.eventbus.EventBusUtil
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.LoginManager
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_version.activity.NewMainActivity
import com.yjkj.chainup.new_version.activity.RewardCenterActivity
import com.yjkj.chainup.new_version.activity.asset.DepositActivity
import com.yjkj.chainup.new_version.adapter.RewardListAdapter
import com.yjkj.chainup.new_version.bean.ItemTaskBean
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.view.RewardHeadView
import com.yjkj.chainup.wedegit.item.SpacesItemDecoration
import kotlinx.android.synthetic.main.fragment_reward_list.rv_listview
import org.json.JSONObject


/**
 * task center bottom fragment
 */
class RewardListFragment : NBaseFragment() {

    private var pActivity:RewardCenterActivity? = null
    private val adapter by lazy { RewardListAdapter() }
    var type = -1

    val headView by lazy { RewardHeadView(mActivity!!) }
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        arguments?.run {
            this@RewardListFragment.type = getInt(typeParam)
        }
        Log.d(TAG,"type=$type")
    }
    override fun initView() {
        pActivity = mActivity as? RewardCenterActivity
        rv_listview?.run {
            layoutManager = LinearLayoutManager(mActivity,LinearLayoutManager.VERTICAL,false)
            adapter = this@RewardListFragment.adapter.apply {
                setHeaderView(headView)
               var mEmptyView= KKEmptyViewKit(requireContext())
                mEmptyView.setMessage(LanguageUtil.getString(mActivity,"rewardCenter_text20")+"\n"+LanguageUtil.getString(mActivity,"rewardCenter_text21"))
                setEmptyView(mEmptyView)
            }
        }

        pActivity?.let {
            updateHeadView(it.rewardReceiveTerm,it.rewardReceiveType)
        }

        adapter.setOnItemChildClickListener { adapter, view, position ->
            if(view.id == R.id.btn_action1){
                if(!LoginManager.checkLogin(mActivity,true)) return@setOnItemChildClickListener
                val model = adapter.data[position] as ItemTaskBean
                when(model.status){
                    0 -> {//Get Reward
                        addDisposable(getMainModel().doReceiveReward(model.id, consumer = object :NDisposableObserver(){
                            override fun onResponseSuccess(jsonObject: JSONObject) {
                                val data = jsonObject.optJSONObject("data")
                                loadData()
                                data?.let {
                                    val resultType = it.optString("resultType")
                                    if("Success".equals(resultType)) {
                                        NewDialogUtils.showSignSuccessDialog(requireContext(),model.rewardAmount,model.rewardCoin,message = LanguageUtil.getString(mActivity,LanguageUtil.getString(mActivity,"rewardCenter_text37")))
                                    }else{
                                        ToastUtils.showToast(context,resultType)
                                    }
                                }

                            }
                        }))
                    }
                    4 -> {//Go

                        when(model.taskCategory){// 0spot，1lever，3contract，4 exchange
                            0 -> {
                                val event = MessageEvent(MessageEvent.hometab_switch_type)
                                event.msg_content = Bundle().apply {
                                    putInt(ParamConstant.homeTabType,2)
                                    putInt(ParamConstant.COIN_TRADE_TAB_INDEX,0)
                                }
                                EventBusUtil.post(event)
                                backHomeActivity()
                            }
                            1 -> {
                                val event = MessageEvent(MessageEvent.hometab_switch_type)
                                event.msg_content = Bundle().apply {
                                    putInt(ParamConstant.homeTabType,2)
                                    putInt(ParamConstant.COIN_TRADE_TAB_INDEX,1)
                                }
                                EventBusUtil.post(event)
                                backHomeActivity()
                            }
                            3 -> {
                                val event = MessageEvent(MessageEvent.contract_switch_type)
                                EventBusUtil.post(event)
                                backHomeActivity()
                            }
                            4 -> {
                                DepositActivity.enter2(mActivity!!,"USDT")
                            }
                        }


                    }
                }
            }
        }


    }

    private fun backHomeActivity(){
        val intent = Intent()
        intent.setClass(requireContext(),NewMainActivity::class.java)
        intent.flags = FLAG_ACTIVITY_SINGLE_TOP or FLAG_ACTIVITY_CLEAR_TOP
        startActivity(intent)
    }

    override fun loadData() {
        super.loadData()
        addDisposable(getMainModel().getTaskList(scene = type.toString(),
            consumer = object: NDisposableObserver(){
                override fun onResponseSuccess(jsonObject: JSONObject) {
                    val dataStr = jsonObject.optString("data")
                    if("".equals(dataStr)) return
                    val listData = GsonUtils.fromJson<ArrayList<ItemTaskBean>>(dataStr,
                        object : TypeToken<ArrayList<ItemTaskBean>>() {}.type)
                    Log.d(TAG,listData.size.toString())
                    adapter.setList(listData)
                }
            })
        )
    }

    override fun setContentView(): Int  = R.layout.fragment_reward_list

    fun updateHeadView(rewardReceiveTerm:Int,rewardReceiveType:Int) {
        headView.updateView(rewardReceiveTerm,PublicInfoDataService.getInstance().serviceTimeZone,type,rewardReceiveType)
    }

    companion object {
        const val typeParam = "type"
        @JvmStatic
        fun newInstance(type:Int = -1) = RewardListFragment().apply {
            val bundle = Bundle().apply {
                putInt(typeParam,type)
            }
            arguments = bundle
        }
    }
}