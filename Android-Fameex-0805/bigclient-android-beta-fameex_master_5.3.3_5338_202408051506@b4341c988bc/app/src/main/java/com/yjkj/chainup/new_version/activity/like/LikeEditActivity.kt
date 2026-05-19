package com.yjkj.chainup.new_version.activity.like

import android.os.Bundle
import android.view.View
import android.view.WindowManager
import androidx.fragment.app.Fragment
import androidx.viewpager.widget.ViewPager
import com.alibaba.android.arouter.facade.annotation.Autowired
import com.alibaba.android.arouter.facade.annotation.Route
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseActivity
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.service.LikeDataService
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.new_version.adapter.PageAdapter
import com.yjkj.chainup.util.ColorUtil
import com.yjkj.chainup.util.LogUtil
import com.yjkj.chainup.util.setViewPagerFont
import com.yjkj.chainup.util.tr
import kotlinx.android.synthetic.main.activity_edit_like.*
import kotlinx.android.synthetic.main.activity_edit_like.iv_edit
import kotlinx.android.synthetic.main.activity_edit_like.stl_market_type
import kotlinx.android.synthetic.main.activity_edit_like.vp_market
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode
import org.jetbrains.anko.sdk27.coroutines.onClick
import org.json.JSONObject

@Route(path = RoutePath.LikeEditActivity)
class LikeEditActivity : NBaseActivity(), EditDragListener {
    var isLogin = false
    var operationType = 0
    val fragments = arrayListOf<Fragment>()
    val titles = arrayListOf<String>()
    lateinit var currentFragment:Fragment
    var tabPosition=0
    @JvmField
    @Autowired(name = ParamConstant.CUR_TYPE_INDEX)
    var curTypeIndex = 0

    override fun setContentView(): Int {
        return R.layout.activity_edit_like
    }


    override fun onInit(savedInstanceState: Bundle?) {
        super.onInit(savedInstanceState)
        tv_market_title.text = "market_title_edit_like".tr(this)
        iv_search.text = "add".tr(this)
        iv_edit.text = "finish".tr(this)
        isLogin = UserDataService.getInstance().isLogined
        window.navigationBarColor = ColorUtil.getColor(this,R.color.fill_9)
        setBgCardBar()
        var isContract = PublicInfoDataService.getInstance().contractOpen(null)
        fragments.clear()
        titles.clear()
        titles.add(LanguageUtil.getString(this, "mainTab_text_transaction"))
        val like = SpotLikeEditContentFragment()
        var bundle = Bundle()
        bundle.putInt("cur_index", 0)
        like.arguments = bundle
        fragments.add(like)
        currentFragment=like
        if (isContract) {
            titles.add(LanguageUtil.getString(this, "trade_contract_title"))
            val like = ContractLikeEditContentFragment()
            var bundle = Bundle()
            bundle.putInt("cur_index", 1)
            like.arguments = bundle
            fragments.add(like)
        }
        stl_market_type.visibility=if (isContract) View.VISIBLE else View.GONE
        vp_market?.adapter = PageAdapter(supportFragmentManager, titles, fragments)
        vp_market?.offscreenPageLimit = fragments.size
        stl_market_type?.setViewPagerFont(vp_market, titles.toTypedArray())
        vp_market.currentItem=curTypeIndex
        vp_market?.addOnPageChangeListener(object : ViewPager.OnPageChangeListener {
            override fun onPageScrollStateChanged(p0: Int) {

            }
            override fun onPageScrolled(p0: Int, p1: Float, p2: Int) {

            }

            override fun onPageSelected(position: Int) {
                tabPosition=position
                currentFragment=fragments[position]
            }

        })

        iv_edit.onClick {
            finish()
        }
        iv_search.onClick {
            ArouterUtil.greenChannel(RoutePath.CoinMapActivity, Bundle().apply {
                putString("type", ParamConstant.ADD_COIN_MAP)
            })
        }
//        ll_item_all.onClick {
////            adapter?.apply {
////                selectAllCoins()
////                initSelectTools()
////            }
//
//            ( currentFragment as LikeEditContentFragment).selectAllCoins(tabPosition)
//        }
//        ll_item_delete.onClick {
//            ( currentFragment as LikeEditContentFragment).delCoins(tabPosition)
////            adapter?.apply {
////                if (isSelectSymbol()) {
////                    NewDialogUtils.showNormalDialog(this@LikeEditActivity,
////                            LanguageUtil.getString(this@LikeEditActivity, "new_confrim_likes"),
////                            object : NewDialogUtils.DialogBottomListener {
////                                override fun sendConfirm() {
////                                    upload(true)
////                                }
////                            })
////                }
////            }
//        }


    }

    override fun onResume() {
        super.onResume()
//        val items = getCollecData()
//        normalTickList.clear()
//        if (items != null) {
//            normalTickList.addAll(items)
//        }
//        adapter?.setList(normalTickList)
//        initSelectTools()

    }

//    private fun initRecylerView() {
//        rv_market_detail?.apply {
//            layoutManager = LinearLayoutManager(this@LikeEditActivity)
//            addItemDecoration(SpacesItemDecoration())
//        }
//
//    }
//
//    private fun initAdapter() {
//        adapter = MarketEditAdapter(normalTickList)
//        adapter?.addChildClickViewIds(R.id.layout_check_item)
//        adapter?.editDragListener = this
//        rv_market_detail?.adapter = adapter
//        rv_market_detail?.setHasFixedSize(true)
//        val emptyForAdapterView = EmptyMarketForAdapterView(this)
//        adapter?.setEmptyView(emptyForAdapterView)
//        adapter?.emptyLayout?.findViewById<LinearLayout>(R.id.layout_add_like)?.setOnClickListener {
//            ArouterUtil.greenChannel(RoutePath.CoinMapActivity, Bundle().apply {
//                putString(ParamConstant.TYPE, ParamConstant.ADD_COIN_MAP)
//            })
//        }
//        adapter?.setOnItemChildClickListener { mAdapter, view, position ->
//            adapter?.apply {
//                selectCurrent(position)
//                initSelectTools()
//            }
//        }
//        (rv_market_detail.itemAnimator as DefaultItemAnimator).supportsChangeAnimations = false
//        val itemTouchCallback = CoinsManageTouchHelperCallback(adapter!!)
//        val itemTouchHelper = ItemTouchHelperExtension(itemTouchCallback)
//        adapter?.itemTouchHelperExtension = itemTouchHelper
//        itemTouchHelper.attachToRecyclerView(rv_market_detail)
//    }

    private fun addOrDeleteSymbol(symbols: String?) {
        if (symbols != null) {

        }
    }

    private fun removeLocalCollect(symbol: String) {

    }

    private fun getCollecData(): ArrayList<JSONObject>? {
        return LikeDataService.getInstance().getCollecData(false)
    }

    override fun onDragListener() {
        LogUtil.e(TAG, "onDrag()")
//        LikeDataService.getInstance().apply {
//            clearAllCollect()
////Update local cache
//            saveCollecData(normalTickList)
//            upload()
//        }
    }

    private fun initSelectTools() {
//        adapter?.apply {
//            check_select.isChecked = isSelectAllSymbol()
//            tv_delete.isEnabled = isSelectSymbol()
//            type_sort.visibility = (data.size != 0).getVisible()
//            iv_delete.imageResource = if (isSelectSymbol()) R.mipmap.favorites_delete_highlight
//            else R.mipmap.favorites_delete
//        }
    }

    private fun upload(isDelete: Boolean = false) {
//        if (!LoginManager.isLogin(this)) {
//            delete(isDelete, false)
//            return
//        }
//        val symbols = when (isDelete) {
//            true -> adapter?.getSelectSymbolsInvert()!!
//            else -> normalTickList.getSymbols()
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
//        if (isDelete) {
////Delete object
//            adapter?.apply {
//                val newAll = getNewSymbolsInvert()
//                replaceData(newAll)
//                resetSelect()
//                LikeDataService.getInstance().clearAllCollect()
//                if (newAll.size != 0) {
//                    LikeDataService.getInstance().saveCollecData(newAll)
//                }
//
//            }
//            initSelectTools()
//        }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    override fun onMessageEvent(event: MessageEvent) {
        super.onMessageEvent(event)
        if (MessageEvent.symbol_switch_type == event.msg_type) {
            finish()
        }
    }

}
