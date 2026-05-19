package com.example.viewtest

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup.MarginLayoutParams
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.chainup.kit.KKDialogUtils
import com.chainup.kit.KKDialogUtils.Companion.showBottomCardSelectDialog
import com.chainup.kit.KKDialogUtils.Companion.showBottomDialogByLayout
import com.chainup.kit.KKDialogUtils.Companion.showBottomListDialogByAdapter
import com.chainup.kit.KKDialogUtils.Companion.showBottomSheetListV2
import com.chainup.kit.bean.KKItemTabInfo
import com.chainup.kit.dialog.KKTDialog
import com.chainup.kit.dialog.adapter.KKBottomCardListRvAdapter
import com.chainup.kit.dialog.adapter.KKItemCardEntity
import com.chainup.kit.dialog.base.KKBindViewHolder
import com.chainup.kit.utils.PublicSizeUtil
import com.chainup.kit.views.KKButtonKit
import com.chainup.kit.views.base.BaseMaxHeightRecyclerViewKit

class BottomSheetActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_bottom_sheet)

        (findViewById<View>(R.id.kk_btn_1) as KKButtonKit).apply {
            this.setOnClickListener {
                val items = java.util.ArrayList<KKItemTabInfo>()
                for (i in 0..4) {
                    items.add(KKItemTabInfo("第" + i + "个", i, ""))
                }
                showBottomSheetListV2(
                    this@BottomSheetActivity,
                    items,
                    -1,
                    null,
                    listener = object : KKDialogUtils.DialogOnItemClickListener {
                        override fun clickItem(position: Int) {}
                    })
            }
        }
        (findViewById<View>(R.id.kk_btn_4) as KKButtonKit).apply {
            this.setOnClickListener {
                val items = java.util.ArrayList<KKItemTabInfo>()
                for (i in 0..4) {
                    items.add(KKItemTabInfo("第" + i + "个", i, ""))
                }
                showBottomSheetListV2(
                    this@BottomSheetActivity,
                    items,
                    -1,
                    null,
                    canSwipeClose = true,
                    listener = object : KKDialogUtils.DialogOnItemClickListener {
                        override fun clickItem(position: Int) {}
                    })
            }
        }
        (findViewById<View>(R.id.kk_btn_3_1) as KKButtonKit).apply {
            this.setOnClickListener {
                var items = arrayListOf<KKItemCardEntity>()
                for (i in 0..20) {
                    items.add(KKItemCardEntity(1, "356", "5436543"))
                }
                val rvAdapter = KKBottomCardListRvAdapter(items)
                val tDialog = showBottomListDialogByAdapter(
                    context,
                    rvAdapter,
                    "选择币种",
                    "",
                    canSwipeClose = true,
                    visibleHeader = false,
                    canSwipeFoldEnabled = true,
                    maxListHeight = PublicSizeUtil.dp2px(this@BottomSheetActivity,700.0f),
                    peekHeight = PublicSizeUtil.dp2px(this@BottomSheetActivity,300.0f)
                )

                rvAdapter.setOnItemClickListener { adapter, view, position ->
//                    listener?.clickItem(position)
                    Handler(Looper.getMainLooper()).postDelayed(Runnable {
                        tDialog.dismiss()
                    },300L)
                }

                rvAdapter.setOnItemChildClickListener { adapter, view, position ->
                    when(view.id){
                        com.example.chainup_kit.R.id.iv_icon_tip -> {
                            //todo:unfinish
                        }
                    }
                }
            }
        }
        (findViewById<View>(R.id.kk_btn_3_2) as KKButtonKit).apply {
            this.setOnClickListener {
                var items = arrayListOf<KKItemCardEntity>()
                for (i in 0..3) {
                    items.add(KKItemCardEntity(1, "356", "5436543"))
                }
                val rvAdapter = KKBottomCardListRvAdapter(items)
                val tDialog = showBottomListDialogByAdapter(
                    context,
                    rvAdapter,
                    "选择币种",
                    "",
                    canSwipeClose = true,
                    visibleHeader = true,
                    visibleCancel = false,
                    canSwipeFoldEnabled = false,
                    maxListHeight = PublicSizeUtil.dp2px(this@BottomSheetActivity,700.0f)
                ){ holder: KKBindViewHolder, dialog:KKTDialog, recyclerView: BaseMaxHeightRecyclerViewKit ->
                    val lp = recyclerView.layoutParams as MarginLayoutParams
                    lp.topMargin = PublicSizeUtil.dp2px(context,20f)
                    recyclerView.layoutParams = lp
                }

                rvAdapter.setOnItemClickListener { adapter, view, position ->
//                    listener?.clickItem(position)
                    Handler(Looper.getMainLooper()).postDelayed(Runnable {
                        tDialog.dismiss()
                    },300L)
                }

                rvAdapter.setOnItemChildClickListener { adapter, view, position ->
                    when(view.id){
                        com.example.chainup_kit.R.id.iv_icon_tip -> {
                            //todo:unfinish
                        }
                    }
                }
            }
        }
        (findViewById<View>(R.id.kk_btn_3_3) as KKButtonKit).apply {
            this.setOnClickListener {
                var items = arrayListOf<KKItemCardEntity>()
                for (i in 0..20) {
                    items.add(KKItemCardEntity(1, "356", "5436543"))
                }
                val rvAdapter = KKBottomCardListRvAdapter(items)
                val tDialog = showBottomListDialogByAdapter(
                    context,
                    rvAdapter,
                    "选择币种",
                    "",
                    canSwipeClose = false,
                    visibleHeader = true,
                    maxListHeight = PublicSizeUtil.dp2px(this@BottomSheetActivity,700.0f)
                )

                rvAdapter.setOnItemClickListener { adapter, view, position ->
//                    listener?.clickItem(position)
                    Handler(Looper.getMainLooper()).postDelayed(Runnable {
                        tDialog.dismiss()
                    },300L)
                }

                rvAdapter.setOnItemChildClickListener { adapter, view, position ->
                    when(view.id){
                        com.example.chainup_kit.R.id.iv_icon_tip -> {
                            //todo:unfinish
                        }
                    }
                }
            }
        }
        (findViewById<View>(R.id.kk_btn_2) as KKButtonKit).apply {
            this.setOnClickListener {
                val list = ArrayList<KKItemCardEntity>()
                list.add(KKItemCardEntity(KKItemCardEntity.CARD_LAYOUT_TYPE_1, "简体中文", "content1"))
                val englishEntity =
                    KKItemCardEntity(KKItemCardEntity.CARD_LAYOUT_TYPE_1, "English", "content2")
                englishEntity.isSelect = true
                list.add(englishEntity)
                list.add(KKItemCardEntity(KKItemCardEntity.CARD_LAYOUT_TYPE_1, "日本", ""))

                showBottomCardSelectDialog(
                    this@BottomSheetActivity,
                    list,
                    object : KKDialogUtils.DialogOnItemClickListener {
                        override fun clickItem(position: Int) {}
                    },
                    "Choose a language",
                    "Please select the mainnet that is consistent with the withdrawal platform for deposit, otherwise your funds may be lost"
                )
            }
        }
        (findViewById<View>(R.id.kk_btn_3) as KKButtonKit).apply {
            this.setOnClickListener {
                val list = ArrayList<KKItemCardEntity>()
                list.add(KKItemCardEntity(KKItemCardEntity.CARD_LAYOUT_TYPE_1, "简体中文", "content1"))
                val englishEntity = KKItemCardEntity(KKItemCardEntity.CARD_LAYOUT_TYPE_1, "English", "content2")
                englishEntity.isSelect = true
                list.add(englishEntity)
                list.add(KKItemCardEntity(KKItemCardEntity.CARD_LAYOUT_TYPE_1, "日本", ""))
                list.add(KKItemCardEntity(KKItemCardEntity.CARD_LAYOUT_TYPE_1, "日本", ""))
                list.add(KKItemCardEntity(KKItemCardEntity.CARD_LAYOUT_TYPE_1, "日本", ""))
                list.add(KKItemCardEntity(KKItemCardEntity.CARD_LAYOUT_TYPE_1, "日本", ""))
                list.add(KKItemCardEntity(KKItemCardEntity.CARD_LAYOUT_TYPE_1, "日本", ""))
                list.add(KKItemCardEntity(KKItemCardEntity.CARD_LAYOUT_TYPE_1, "日本", ""))
                list.add(KKItemCardEntity(KKItemCardEntity.CARD_LAYOUT_TYPE_1, "日本", ""))
                list.add(KKItemCardEntity(KKItemCardEntity.CARD_LAYOUT_TYPE_1, "日本", ""))
                list.add(KKItemCardEntity(KKItemCardEntity.CARD_LAYOUT_TYPE_1, "日本", ""))
                list.add(KKItemCardEntity(KKItemCardEntity.CARD_LAYOUT_TYPE_1, "日本", ""))
                list.add(KKItemCardEntity(KKItemCardEntity.CARD_LAYOUT_TYPE_1, "日本", ""))
                list.add(KKItemCardEntity(KKItemCardEntity.CARD_LAYOUT_TYPE_1, "日本", ""))
                val adapter = KKBottomCardListRvAdapter(list)
                showBottomListDialogByAdapter(this@BottomSheetActivity,
                    adapter,
                    title = "ceshi",
                    canSwipeClose = false,
                    visibleHeader = false,
                    maxListHeight = PublicSizeUtil.dp2px(this@BottomSheetActivity,300.0f)
                )
            }
        }
        (findViewById<View>(R.id.bottom_layout_dialog) as KKButtonKit).apply {
            this.setOnClickListener {
                showBottomDialogByLayout(
                    this@BottomSheetActivity,
                    layoutRes = R.layout.activity_bottom_sheet,
                    canSwipeClose = true
                ){

                }
            }
        }

        (findViewById<View>(R.id.bottom_layout_dialog2) as KKButtonKit).apply {
            this.setOnClickListener {
                showBottomDialogByLayout(
                    this@BottomSheetActivity,
                    layoutRes = R.layout.layout_test_bottom_sheet,
                    title = "ceshi"
                ){
                    val txTitle = it.getView<TextView>(R.id.test_message)
                    txTitle.text = "(findViewById<View>(R.id.bottom_layout_dialog3) as KKButtonKit)\n\n show \n\n 123"
                }
            }
        }

        (findViewById<View>(R.id.bottom_layout_dialog3) as KKButtonKit).apply {
            this.setOnClickListener {
                var tDialog:KKTDialog? = null
                tDialog = showBottomDialogByLayout(
                    this@BottomSheetActivity,
                    layoutRes = R.layout.cp_item_modify_lever_dialog,
                    canSwipeClose = true,
                    canSwipeFoldEnabled = false
                ){
                    tDialog?.setDialogCanConsumerStatus(false)
                    it.getView<View>(R.id.ll_par).setOnTouchListener(object :View.OnTouchListener{
                        override fun onTouch(v: View?, event: MotionEvent?): Boolean {
                            Log.d("xiaobo","ll_par>>>setOnTouchListener")
                            when(event?.action) {
                                MotionEvent.ACTION_DOWN->{
                                    tDialog?.setDialogCanConsumerStatus(true)
                                }
                                MotionEvent.ACTION_UP,MotionEvent.ACTION_CANCEL -> {
                                    tDialog?.setDialogCanConsumerStatus(false)
                                }
                            }
                            return true
                        }
                    })
                }
            }
        }

    }
}