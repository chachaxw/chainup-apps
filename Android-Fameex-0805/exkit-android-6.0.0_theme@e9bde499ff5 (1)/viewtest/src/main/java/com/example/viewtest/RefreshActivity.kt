package com.example.viewtest

import android.os.Bundle
import android.os.Handler
import android.text.TextUtils
import android.view.View
import androidx.annotation.NonNull
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.scwang.smart.refresh.layout.api.RefreshLayout
import com.scwang.smart.refresh.layout.listener.OnLoadMoreListener
import com.scwang.smart.refresh.layout.listener.OnRefreshListener

class RefreshActivity : AppCompatActivity() {
    private lateinit var mBufferAdapter: BufferAdapter
    private lateinit var mData: ArrayList<String>
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_refresh)

        mData = ArrayList()
        for (i in 0..20){
            mData.add("")
        }
        mBufferAdapter = BufferAdapter(R.layout.item_test_rv, mData)
        (findViewById<View>(R.id.rv_layout) as RecyclerView).apply {
            layoutManager = LinearLayoutManager(this@RefreshActivity)
            adapter = mBufferAdapter
        }

        val mRefreshLayout: RefreshLayout = findViewById(R.id.refreshLayout)
        mRefreshLayout.setOnRefreshListener(object : OnRefreshListener {
            override fun onRefresh(refreshLayout: RefreshLayout) {
                Handler().postDelayed({
                    mRefreshLayout.finishRefresh(true);
                }, 2000)
            }
        })

        mRefreshLayout.setOnLoadMoreListener(object :OnLoadMoreListener{
            override fun onLoadMore(refreshLayout: RefreshLayout) {
                Handler().postDelayed({
                    mRefreshLayout.finishLoadMore(true);
                }, 2000)
            }
        })
    }


}