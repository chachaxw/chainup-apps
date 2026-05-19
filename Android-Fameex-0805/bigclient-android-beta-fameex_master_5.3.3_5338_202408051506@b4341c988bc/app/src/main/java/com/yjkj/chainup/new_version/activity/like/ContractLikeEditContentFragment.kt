package com.yjkj.chainup.new_version.activity.like

import android.os.Bundle
import android.os.Handler
import android.text.TextUtils
import androidx.recyclerview.widget.DefaultItemAnimator
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import android.view.View
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.viewpager.widget.ViewPager
import com.chainup.contract.utils.CpClLogicContractSetting
import com.chainup.kit.KKDialogUtils
import com.chainup.kit.views.KKEmptyViewKit
import com.google.gson.Gson
import com.google.gson.JsonObject
import com.loopeer.itemtouchhelperextension.ItemTouchHelperExtension
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseFragment
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.service.LikeDataService
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.extra_service.eventbus.EventBusUtil
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.LoginManager
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.manager.SymbolWsData
import com.yjkj.chainup.model.model.MainModel
import com.yjkj.chainup.net_new.JSONUtil
import com.yjkj.chainup.net_new.rxjava.CpNDisposableObserver
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_version.adapter.MarketDetailAdapter
import com.yjkj.chainup.new_version.adapter.PageAdapter
import com.yjkj.chainup.new_version.adapter.RecommendCoinAdapter
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.home.callback.MarketTabDiffCallback
import com.yjkj.chainup.new_version.home.homeToast
import com.yjkj.chainup.new_version.view.EmptyMarketForAdapterView
import com.yjkj.chainup.util.*
import com.yjkj.chainup.wedegit.item.SpacesItemDecoration
import kotlinx.android.synthetic.main.fragment_like_conent.*
import kotlinx.android.synthetic.main.fragment_spot_likes.*
import kotlinx.android.synthetic.main.fragment_spot_likes.rv_market_detail
import kotlinx.android.synthetic.main.include_edit_coin_bottom.*
import kotlinx.android.synthetic.main.include_market_sort.*
import org.jetbrains.anko.doAsync
import org.jetbrains.anko.imageResource
import org.json.JSONArray
import org.json.JSONObject
import java.util.HashMap


class ContractLikeEditContentFragment : NBaseFragment(), EditDragListener {


    var mContractMarketEditAdapter: ContractMarketEditAdapter? = null
    private var normalTickList = arrayListOf<JSONObject>()
    override fun setContentView() = R.layout.fragment_like_conent

    override fun loadData() {
        super.loadData()
    }

    override fun initView() {
        tv_all.text = "otc_all".tr(mActivity!!)
        tv_name.text = "common_text_coinsymbol".tr(mActivity!!)
        tv_new_price.text = "market_edit_like_type_top".tr(mActivity!!)
        tv_limit.text = "market_edit_like_type_drag".tr(mActivity!!)
        rv_market_detail?.apply {
            layoutManager = LinearLayoutManager(requireActivity())
            addItemDecoration(SpacesItemDecoration())
        }
        initContractAdapter()

        ll_item_all.setOnClickListener {
            mContractMarketEditAdapter?.apply {
                selectAllCoins()
                initSelectTools()
            }
        }

        ll_item_delete.setOnClickListener {
            mContractMarketEditAdapter?.apply {
                if (isSelectSymbol()) {
                    NewDialogUtils.showNormalDialog(requireContext(),
                      title =   LanguageUtil.getString(requireContext(), "new_confrim_likes"),
                      listener =   object : NewDialogUtils.DialogBottomListener {
                            override fun sendConfirm() {
                                val selectIds = mContractMarketEditAdapter?.selectMap?.keys
                                if(selectIds!=null){
                                    //Filter data with selected id (delete)
                                    var groupData = CpClLogicContractSetting.getContractJsonCollectListArr(mActivity)
                                    groupData = groupData.filter{
                                        !selectIds.contains(it.optString("id"))
                                    } as java.util.ArrayList<JSONObject>

                                    val jsonStr = JsonUtils.listToJson(groupData)
                                    CpClLogicContractSetting.setContractJsonCollectListStr(requireContext(),jsonStr)
                                }else{
                                    CpClLogicContractSetting.setContractJsonCollectListStr(requireContext(),"")
                                }


                                upload(true)
                            }
                        })
                }
            }
        }
        check_select_all.isChecked = false
    }


    private fun initContractAdapter() {
        mContractMarketEditAdapter = ContractMarketEditAdapter(normalTickList)
        mContractMarketEditAdapter?.addChildClickViewIds(R.id.layout_check_item)
        mContractMarketEditAdapter?.editDragListener = this
        rv_market_detail?.adapter = mContractMarketEditAdapter
        rv_market_detail?.setHasFixedSize(true)
        val emptyForAdapterView = KKEmptyViewKit(requireContext())
        mContractMarketEditAdapter?.setEmptyView(emptyForAdapterView)
        mContractMarketEditAdapter?.emptyLayout?.findViewById<LinearLayout>(R.id.layout_add_like)
            ?.setOnClickListener {
                ArouterUtil.greenChannel(RoutePath.CoinMapActivity, Bundle().apply {
                    putString(ParamConstant.TYPE, ParamConstant.ADD_COIN_MAP)
                })
            }
        mContractMarketEditAdapter?.setOnItemChildClickListener { mAdapter, view, position ->
            mContractMarketEditAdapter?.apply {
                selectCurrent(position)
                initSelectTools()
            }
        }
        (rv_market_detail.itemAnimator as DefaultItemAnimator).supportsChangeAnimations = false
        val itemTouchCallback = ContractCoinsManageTouchHelperCallback(mContractMarketEditAdapter!!)
        val itemTouchHelper = ItemTouchHelperExtension(itemTouchCallback)
        mContractMarketEditAdapter?.itemTouchHelperExtension = itemTouchHelper
        itemTouchHelper.attachToRecyclerView(rv_market_detail)
        val items = getCollecData()
        normalTickList.clear()
        if (items != null) {
            normalTickList.addAll(items)
        }
        mContractMarketEditAdapter?.setList(normalTickList)
    }


    override fun onResume() {
        super.onResume()
        val items = getCollecData()
        normalTickList.clear()
        if (items != null) {
            normalTickList.addAll(items)
        }
        mContractMarketEditAdapter?.setList(normalTickList)
        initSelectTools()
    }
    private fun getCollecData(): ArrayList<JSONObject>? {
        if (arguments?.getInt("cur_index") == 0) {
            return LikeDataService.getInstance().getCollecData(false)
        }
        return CpClLogicContractSetting.getContractJsonCollectListArr(requireActivity())
    }

    override fun onDragListener() {
        CpClLogicContractSetting.setContractJsonCollectListStr(
            requireContext(),
            normalTickList.toString()
        )
        mContractMarketEditAdapter?.resetSelect()
        mContractMarketEditAdapter?.notifyDataSetChanged()
        initSelectTools()
        delOrChangeCollect()
    }

    private fun delOrChangeCollect() {
        if (!LoginManager.isLogin(requireContext())) {
            return
        }
        var mContractIds = StringBuffer()
        var mCollectListStr =
            CpClLogicContractSetting.getContractJsonCollectListStr(requireContext())
        if (!TextUtils.isEmpty(mCollectListStr)) {
            val jsonArray = JSONArray(mCollectListStr)
            for (i in 0 until jsonArray.length()) {
                val mJSONObject = jsonArray[i] as JSONObject
                mContractIds.append(mJSONObject.optInt("id"))
                mContractIds.append(",")
            }
        }
        addDisposable(
            getContractModel().setOptionalList(
                if (TextUtils.isEmpty(mContractIds)) "" else  mContractIds.substring(0,mContractIds.length-1),
                consumer = object : CpNDisposableObserver(mActivity, true) {
                    override fun onResponseSuccess(jsonObject: JSONObject?) {

                    }
                }
            )
        )
    }

    private fun initSelectTools() {
        mContractMarketEditAdapter?.apply {
            check_select_all.isChecked = isSelectAllSymbol()
            tv_delete.isEnabled = isSelectSymbol()
            tv_delete.text=LanguageUtil.getString(requireContext(),"delete")+(if (this.getSelectSymbolNum() != 0) "(${this.getSelectSymbolNum()})" else "")
            tv_delete.setTextColor(if (isSelectSymbol()) ContextCompat.getColor(requireContext(),R.color.main_color) else ContextCompat.getColor(requireContext(),R.color.text_color_2))
            tv_all.setTextColor(if (isSelectAllSymbol()) ContextCompat.getColor(requireContext(),R.color.main_color) else ContextCompat.getColor(requireContext(),R.color.text_1))
            type_sort.visibility = (data.size != 0).getVisible()
            iv_delete.imageResource = if (isSelectSymbol()) R.drawable.ic_public_delete_highlight
            else R.mipmap.public_delete_default
        }
    }


    private fun upload(isDelete: Boolean = false) {
        delete(isDelete, false)
        delOrChangeCollect()
//        for (buff in normalTickList){
//            LogUtil.e("-----",)
//        }
//        showLoadingDialog()
//        MainModel().likesCoinsUpload(symbols, object : NDisposableObserver() {
//            override fun onResponseSuccess(jsonObject: JSONObject) {
//                closeLoadingDialog()
//                delete(isDelete)
//            }
//
//            override fun onResponseFailure(code: Int, msg: String?) {
//                super.onResponseFailure(code, msg)
//                closeLoadingDialog()
//            }
//        })
    }

    private fun delete(isDelete: Boolean, isLogin: Boolean = true) {
        if (isDelete) {
            //Delete Object
            mContractMarketEditAdapter?.apply {
                val newAll = getNewSymbolsInvert()
                replaceData(newAll)
                resetSelect()
//                    LikeDataService.getInstance().clearAllCollect()
//                    if (newAll.size != 0) {
//                        LikeDataService.getInstance().saveCollecData(newAll)
//                    }
            }
            initSelectTools()

            EventBusUtil.post(MessageEvent(MessageEvent.market_updateList))
        }
    }

}
