package com.yjkj.chainup.new_version.activity.like

import android.os.Bundle
import android.os.Handler
import android.text.TextUtils
import android.util.Log
import android.view.Gravity
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
import com.timmy.tdialog.TDialog
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
import kotlinx.android.synthetic.main.item_register_tab.*
import org.jetbrains.anko.doAsync
import org.jetbrains.anko.imageResource
import org.json.JSONArray
import org.json.JSONObject
import java.util.HashMap


class SpotLikeEditContentFragment : NBaseFragment(), EditDragListener {


    var adapter: MarketEditAdapter? = null
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
        initSpotAdapter()
        ll_item_all.setOnClickListener {
            adapter?.apply {
                selectAllCoins()
                initSelectTools()
            }
        }

        ll_item_delete.setOnClickListener { adapter?.apply {
            if (isSelectSymbol()) {
                showDelete()
            }
        }
        }
        check_select_all.isChecked=false
    }


    private fun initSpotAdapter() {
        adapter = MarketEditAdapter(normalTickList)
        adapter?.addChildClickViewIds(R.id.layout_check_item)
        adapter?.editDragListener = this
        rv_market_detail?.adapter = adapter
        rv_market_detail?.setHasFixedSize(true)
        val emptyForAdapterView = KKEmptyViewKit(requireContext())
        adapter?.setEmptyView(emptyForAdapterView)
        adapter?.emptyLayout?.findViewById<LinearLayout>(R.id.layout_add_like)?.setOnClickListener {
            ArouterUtil.greenChannel(RoutePath.CoinMapActivity, Bundle().apply {
                putString(ParamConstant.TYPE, ParamConstant.ADD_COIN_MAP)
            })
        }
        adapter?.setOnItemChildClickListener { mAdapter, view, position ->
            adapter?.apply {
                selectCurrent(position)
                initSelectTools()
            }
        }
        (rv_market_detail.itemAnimator as DefaultItemAnimator).supportsChangeAnimations = false
        val itemTouchCallback = CoinsManageTouchHelperCallback(adapter!!)
        val itemTouchHelper = ItemTouchHelperExtension(itemTouchCallback)
        adapter?.itemTouchHelperExtension = itemTouchHelper
        itemTouchHelper.attachToRecyclerView(rv_market_detail)
        val items = getCollecData()
        normalTickList.clear()
        if (items != null) {
            normalTickList.addAll(items)
        }
        adapter?.setList(normalTickList)
    }
    override fun onResume() {
        super.onResume()
        val items = getCollecData()
        normalTickList.clear()
        if (items != null) {
            normalTickList.addAll(items)
        }
        adapter?.setList(normalTickList)
        initSelectTools()
    }
    private fun getCollecData(): ArrayList<JSONObject>? {
        return LikeDataService.getInstance().getCollecData(false)
    }

    override fun onDragListener() {
        LogUtil.e(TAG, "onDrag()")
        LikeDataService.getInstance().apply {
            clearAllCollect()
            //Update local cache
            saveCollecData(normalTickList)
            upload()
        }
        adapter?.resetSelect()
        adapter?.notifyDataSetChanged()
        initSelectTools()
    }


    fun delCoins(tabPosition: Int) {
        if (tabPosition == 0) {
            adapter?.apply {
                if (isSelectSymbol()) {
                    showDelete()
                }
            }
        }
    }

    private fun initSelectTools() {
        adapter?.apply {
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
        if (!LoginManager.isLogin(requireContext())) {
            delete(isDelete, false)
            return
        }
        val symbols = when (isDelete) {
            true -> adapter?.getSelectSymbolsInvert()!!
            else -> normalTickList.getSymbols()
        }
        MainModel().likesCoinsUpload(symbols, object : NDisposableObserver() {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                delete(isDelete)
            }

            override fun onResponseFailure(code: Int, msg: String?) {
                super.onResponseFailure(code, msg)
            }
        })
    }

    private fun delete(isDelete: Boolean, isLogin: Boolean = true) {
        if (isDelete) {
            //Delete Object
            adapter?.apply {
                val newAll = getNewSymbolsInvert()
                replaceData(newAll)
                resetSelect()
                LikeDataService.getInstance().clearAllCollect()
                if (newAll.size != 0) {
                    LikeDataService.getInstance().saveCollecData(newAll)
                }
            }
            initSelectTools()
            EventBusUtil.post(MessageEvent(MessageEvent.market_updateList))
        }
    }

    private fun showDelete(){
        NewDialogUtils.showNormalDialog(requireContext(),
            "",
            object : NewDialogUtils.DialogBottomListener {
                override fun sendConfirm() {
                    upload(true)
                }
            },LanguageUtil.getString(requireContext(), "new_confrim_likes"))
    }

}
