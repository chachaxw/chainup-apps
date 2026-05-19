package com.yjkj.chainup.new_version.view.depth

import com.yjkj.chainup.bean.DepthBean
import com.yjkj.chainup.bean.KlineDepth
import org.json.JSONObject

/**
 * @Author lianshangljl
 * @Date 2023-03-31-11:45
 * @Email buptjinlong@163.com
 * @description
 */
class BBKlineDataDepthHelper {


    private val listeners = ArrayList<DepthKlineDataUpdateListener>()


    /**
     *Initialize deep data source
     * @param data
     */
    @Synchronized
    fun initSourceDepth(depth: KlineDepth?) {
        if (depth != null) {
            mSourceBuys.clear()
            mSourceSells.clear()
            mSourceBuys.addAll(depth.bids)
            mSourceSells.addAll(depth.asks)
        }
    }


    /**
     *Refresh interval frequency
     */
    val intervalFrequency = 100
    var lastTime = 0L


    fun clearData() {
        mSourceBuys.clear()
        mSourceSells.clear()
    }


    fun bindDepthBeanUpdateListener(listener: DepthKlineDataUpdateListener) {
        if (listener != null) {
            listeners.add(listener)
        }
    }

    fun unBindDepthBeanUpdateListener(listener: DepthKlineDataUpdateListener) {
        if (listener != null && listeners.contains(listener)) {
            listeners.remove(listener)
        }
    }

    /**
     *Deep raw data
     */
    var mSourceBuys = ArrayList<DepthBean>()
        @Synchronized
        get() {
            if (field == null) {
                field = ArrayList()
            }
            return field
        }
    var mSourceSells = ArrayList<DepthBean>()
        @Synchronized
        get() {
            if (field == null) {
                field = ArrayList()
            }
            return field
        }


    /**
     *Update deep data
     */
    @Synchronized
    fun updateDepthByType(jsonObject: JSONObject) {
        val dataObj = jsonObject.optJSONObject("tick") ?: return
        try {
            val depth = KlineDepth()
            depth.fromJson(dataObj)
            var bindList: ArrayList<DepthBean> = depth.bids as ArrayList<DepthBean>
            var sellList: ArrayList<DepthBean> = depth.asks as ArrayList<DepthBean>

            mSourceSells.clear()
            mSourceBuys.clear()
            mSourceSells.addAll(sellList)
            mSourceBuys.addAll(bindList)
            //Sort required
            doSourceSort()
            //Add UI refresh frequency limit
            val nowTime = System.currentTimeMillis()
            if (nowTime - lastTime < intervalFrequency) {
                return
            }
            lastTime = nowTime
            listeners.forEach {
                it.onUpdateComplete()
            }

        } catch (e: Exception) {
            e.printStackTrace()

        }
    }
    /**
     *Original data sorting
     */
    private fun doSourceSort() {
        //Buy in descending order
        mSourceBuys.sortByDescending { it.price.toDouble() }
        //Sell in ascending order
        mSourceSells.sortBy { it.price.toDouble() }
    }



    interface DepthKlineDataUpdateListener {
        fun onUpdateComplete()
    }

    companion object {
        @Volatile
        private var mSingleton: BBKlineDataDepthHelper? = null

        val instance: BBKlineDataDepthHelper?
            get() {
                if (mSingleton == null) {
                    synchronized(BBKlineDataDepthHelper::class.java) {
                        if (mSingleton == null) {
                            mSingleton = BBKlineDataDepthHelper()
                        }
                    }
                }
                return mSingleton
            }
    }

}
