package com.example.viewtest

import android.os.Bundle
import android.os.Handler
import android.util.Log
import android.view.View
import android.view.View.OnClickListener
import android.widget.LinearLayout
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.chainup.kit.KKDialogUtils
import com.chainup.kit.KKDialogUtils.Companion.showBottomSheetList
import com.chainup.kit.bean.KKItemTabInfo
import com.chainup.kit.utils.SkeletonUtil
import com.chainup.kit.views.KKMultiStateView
import com.chainup.kit.views.PublicHeaderKit
import com.ethanhua.skeleton.RecyclerViewSkeletonScreen
import com.ethanhua.skeleton.ViewSkeletonScreen

class MultiStateActivity : AppCompatActivity() {

    private lateinit var mBufferAdapter: BufferAdapter
    private lateinit var mData: ArrayList<String>
    private lateinit var rvLayout: RecyclerView
    private val llContent: KKMultiStateView by lazy { findViewById(R.id.ll_multi_view) }
    private lateinit var mSkeletonMarket: RecyclerViewSkeletonScreen
    private lateinit var mSkeletonHome: ViewSkeletonScreen
    private lateinit var mSkeletonContract: ViewSkeletonScreen

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_multistate)
        llContent.currentState= KKMultiStateView.ViewState.EMPTY
        llContent.retryClickListener = object: OnClickListener{
            override fun onClick(v: View?) {
                Log.d("tag","retry")
            }
        }
        llContent.setMessageText(
            emptyMessage = "自定义空Message",
            exceptionMessage = "自定义异常Message",
            btnMessage = "自定义按钮Message"
        )
        (findViewById<View>(R.id.title_header_kit) as PublicHeaderKit).listener = object :
            PublicHeaderKit.IOnBackClickListener {
            override fun onRightBtn(view: View) {
                val items = java.util.ArrayList<KKItemTabInfo>()
                items.add(KKItemTabInfo("空页面", 0))
                items.add(KKItemTabInfo("加载中-loading", 1))
                items.add(KKItemTabInfo("加载中-骨架加载", 2))
                items.add(KKItemTabInfo("显示内容", 3))
                items.add(KKItemTabInfo("异常", 4))
                showBottomSheetList(
                    this@MultiStateActivity,
                    items,
                    -1,
                    null,
                    object : KKDialogUtils.DialogOnItemClickListener {
                        override fun clickItem(position: Int) {
                            if(position==0){
                                (findViewById<View>(R.id.ll_multi_view) as KKMultiStateView).currentState=
                                    KKMultiStateView.ViewState.EMPTY
                            }else if (position==1){
                                (findViewById<View>(R.id.ll_multi_view) as KKMultiStateView).currentState=
                                    KKMultiStateView.ViewState.LOADING
                                Handler().postDelayed({
                                    (findViewById<View>(R.id.ll_multi_view) as KKMultiStateView).currentState=
                                        KKMultiStateView.ViewState.CONTENT
                                }, 3000)
                            }else if (position==2){
                                mSkeletonHome =
                                    SkeletonUtil.showView(llContent, R.layout.skeleton_home_view)
                                        .show()
                                Handler().postDelayed({
                                    SkeletonUtil.hideSkeleton(mSkeletonHome)
                                }, 3000)
                            }else if (position==3){
                                (findViewById<View>(R.id.ll_multi_view) as KKMultiStateView).currentState=
                                    KKMultiStateView.ViewState.CONTENT
                            }else if (position==4){
                                (findViewById<View>(R.id.ll_multi_view) as KKMultiStateView).currentState=
                                    KKMultiStateView.ViewState.NET_ERROR
                            }
                        }
                    })
            }
        }


    }
}