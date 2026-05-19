package com.example.viewtest

import android.os.Bundle
import android.os.Handler
import android.view.View
import android.widget.LinearLayout
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.chainup.kit.KKDialogUtils
import com.chainup.kit.KKDialogUtils.Companion.showBottomSheetList
import com.chainup.kit.bean.KKItemTabInfo
import com.chainup.kit.utils.SkeletonUtil
import com.chainup.kit.views.PublicHeaderKit
import com.ethanhua.skeleton.RecyclerViewSkeletonScreen
import com.ethanhua.skeleton.ViewSkeletonScreen

class SkeletonActivity : AppCompatActivity() {

    private lateinit var mBufferAdapter: BufferAdapter
    private lateinit var mData: ArrayList<String>
    private lateinit var rvLayout: RecyclerView
    private lateinit var llContent: LinearLayout
    private lateinit var mSkeletonMarket: RecyclerViewSkeletonScreen
    private lateinit var mSkeletonHome: ViewSkeletonScreen
    private lateinit var mSkeletonAsset: ViewSkeletonScreen
    private lateinit var mSkeletonContract: ViewSkeletonScreen

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_skeleton)

        (findViewById<View>(R.id.title_header_kit) as PublicHeaderKit).listener = object :
            PublicHeaderKit.IOnBackClickListener {
            override fun onRightBtn(view: View) {
                val items = java.util.ArrayList<KKItemTabInfo>()
                items.add(KKItemTabInfo("首页骨架", 0))
                items.add(KKItemTabInfo("行情骨架", 1))
                items.add(KKItemTabInfo("现货骨架", 2))
                items.add(KKItemTabInfo("合约骨架", 3))
                items.add(KKItemTabInfo("资产骨架", 4))
                showBottomSheetList(
                    this@SkeletonActivity,
                    items,
                    -1,
                    null,
                    object : KKDialogUtils.DialogOnItemClickListener {
                        override fun clickItem(position: Int) {
                            if(position==0){
                                mSkeletonHome =
                                    SkeletonUtil.showView(llContent, R.layout.skeleton_home_view)
                                        .show()
                                Handler().postDelayed({
                                    SkeletonUtil.hideSkeleton(mSkeletonHome)
                                }, 3000)

                            }else if (position==1){
                                mSkeletonMarket =
                                    SkeletonUtil.showRv(rvLayout, R.layout.skeleton_item_market)
                                        .adapter(mBufferAdapter)
                                        .show()
                                Handler().postDelayed({
                                    for (i in 0..20) {
                                        mData.add("")
                                    }
                                    mBufferAdapter.notifyDataSetChanged()
                                    SkeletonUtil.hideSkeleton(mSkeletonMarket)
                                }, 3000)
                            }else if (position==3){
                                mSkeletonContract = SkeletonUtil.showView(llContent, R.layout.skeleton_contract_view)
                                    .show()
                                Handler().postDelayed({
                                    SkeletonUtil.hideSkeleton(mSkeletonContract)
                                }, 3000)
                            }else if (position==4){
                                mSkeletonAsset = SkeletonUtil.showView(llContent, R.layout.skeleton_asset_view_total)
                                    .show()
                                Handler().postDelayed({
                                    SkeletonUtil.hideSkeleton(mSkeletonAsset)
                                }, 3000)
                            }
                        }
                    })
            }
        }


        mData = ArrayList()

        rvLayout = findViewById<View>(R.id.rv_layout) as RecyclerView
        llContent = findViewById<View>(R.id.ll_content) as LinearLayout
        mBufferAdapter = BufferAdapter(R.layout.item_test_rv, mData)
        rvLayout.apply {
            layoutManager = LinearLayoutManager(this@SkeletonActivity)
            adapter = mBufferAdapter
        }

        mSkeletonHome =
            SkeletonUtil.showView(llContent, R.layout.skeleton_home_view)
                .show()
        Handler().postDelayed({
            SkeletonUtil.hideSkeleton(mSkeletonHome)
        }, 3000)

    }
}