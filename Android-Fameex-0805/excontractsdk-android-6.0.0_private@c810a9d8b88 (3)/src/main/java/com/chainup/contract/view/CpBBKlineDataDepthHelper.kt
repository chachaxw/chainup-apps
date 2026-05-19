package com.chainup.contract.view

import com.chainup.contract.bean.CpDepthBean
import com.chainup.contract.utils.CpKlineDepth
import org.json.JSONObject

/**
 * @Author lianshangljl
 * @Date 2020-03-31-11:45
 * @Email buptjinlong@163.com
 * @description
 */
class CpBBKlineDataDepthHelper {


    private val listeners = ArrayList<DepthKlineDataUpdateListener>()


    /**
     *Initialize deep data source
     * @param data
     */
    @Synchronized
    fun initSourceDepth(depth: CpKlineDepth?) {
        if (depth != null) {
            mSourceBuys.clear()
            mSourceSells.clear()
            mSourceBuys.addAll(depth.bids)
            mSourceSells.addAll(depth.asks)
        }
    }


    /**
     *Refresh Interval Frequency
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
     *Depth raw data
     */
    var mSourceBuys = ArrayList<CpDepthBean>()
        @Synchronized
        get() {
            if (field == null) {
                field = ArrayList()
            }
            return field
        }
    var mSourceSells = ArrayList<CpDepthBean>()
        @Synchronized
        get() {
            if (field == null) {
                field = ArrayList()
            }
            return field
        }


    /**
     *Update depth data
     */
    @Synchronized
    fun updateDepthByType(jsonObject: JSONObject) {
        val dataObj = jsonObject.optJSONObject("tick") ?: return
        try {
            val depth = CpKlineDepth()
            depth.fromJson(dataObj)
            var bindList: ArrayList<CpDepthBean> = depth.bids as ArrayList<CpDepthBean>
            var sellList: ArrayList<CpDepthBean> = depth.asks as ArrayList<CpDepthBean>

            mSourceSells.clear()
            mSourceBuys.clear()
            mSourceSells.addAll(sellList)
            mSourceBuys.addAll(bindList)
            //Sort Required
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
        private var mSingleton: CpBBKlineDataDepthHelper? = null

        val instance: CpBBKlineDataDepthHelper?
            get() {
                if (mSingleton == null) {
                    synchronized(CpBBKlineDataDepthHelper::class.java) {
                        if (mSingleton == null) {
                            mSingleton = CpBBKlineDataDepthHelper()
                        }
                    }
                }
                return mSingleton
            }
    }

}
