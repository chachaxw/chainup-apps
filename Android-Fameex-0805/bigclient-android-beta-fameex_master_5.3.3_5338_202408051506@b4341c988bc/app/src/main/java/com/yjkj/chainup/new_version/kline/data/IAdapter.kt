package com.yjkj.chainup.new_version.kline.data

import android.database.DataSetObserver

/**
 * @Author: Bertking
 * @Date 2023/3/11-10:41 AM
 *@description: Data Adapter
 */
interface IAdapter {
    /**
     *Obtain the number of points
     *
     * @return
     */
    fun getCount(): Int

    /**
     *Obtain item by serial number
     *
     *The serial number corresponding to @param position
     *@return data entity
     */
    fun getItem(position: Int): Any

    /**
     *Obtain time by serial number
     *
     * @param position
     * @return
     */
    fun getDate(position: Int): String

    /**
     *Register a data observer
     *
     *Param observer data observer
     */
    fun registerDataSetObserver(observer: DataSetObserver)

    /**
     *Remove a data observer
     *
     *Param observer data observer
     */
    fun unregisterDataSetObserver(observer: DataSetObserver)

    /**
     *Called when data changes
     */
    fun notifyDataSetChanged()
}
