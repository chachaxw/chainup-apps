package com.yjkj.chainup.new_version.kline.data

import android.database.DataSetObserver

/**
 * @Author: Bertking
 * @Date：2019/3/11-10:41 AM
 *@ Description: Data Adapter
 */
interface CpIAdapter {
    /**
     *Get the number of points
     *
     * @return
     */
    fun getCount(): Int

    /**
     *Obtain item by serial number
     *
     *The serial number corresponding to @param position
     *@return Data Entity
     */
    fun getItem(position: Int): Any

    /**
     *Obtain time by serial number
     *
     * @param position
     * @return
     */
    fun getDate(position: Int): String


    fun getDateLong(position: Int): Long

    /**
     *Register a data observer
     *
     *Param observer
     */
    fun registerDataSetObserver(observer: DataSetObserver)

    /**
     *Remove a data observer
     *
     *Param observer
     */
    fun unregisterDataSetObserver(observer: DataSetObserver)

    /**
     *Called when data changes
     */
    fun notifyDataSetChanged()
}
