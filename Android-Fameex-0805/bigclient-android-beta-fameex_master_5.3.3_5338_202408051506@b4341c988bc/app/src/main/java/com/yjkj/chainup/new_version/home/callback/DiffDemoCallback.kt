package com.yjkj.chainup.new_version.home.callback

import androidx.recyclerview.widget.DiffUtil
import org.json.JSONObject

class DiffDemoCallback : DiffUtil.ItemCallback<JSONObject>() {

    /**
     * Determine if it is the same item
     *
     *
     *Determine if it is the same item
     *
     * @param oldItem New data
     * @param newItem old Data
     * @return
     */
    override fun areItemsTheSame(oldItem: JSONObject, newItem: JSONObject): Boolean {
        return oldItem.getString("symbol") === newItem.getString("symbol")
    }

    /**
     * When it is the same item, judge whether the content has changed.
     *
     *
     *When it is the same item, determine whether the content has changed
     *
     * @param oldItem New data
     * @param newItem old Data
     * @return
     */
    override fun areContentsTheSame(oldItem: JSONObject, newItem: JSONObject): Boolean {
        return (oldItem.getString("rose").equals(newItem.getString("rose"))
                && oldItem.getString("close").equals(newItem.getString("close")))
    }

    /**
     * Optional implementation
     * Implement this method if you need to precisely modify the content of a view.
     * If this method is not implemented, or if null is returned, the entire item will be refreshed.
     *
     *Optional implementation
     *If you need to accurately modify the content in a particular view, please implement this method.
     *If this method is not implemented or returns null, the entire item will be refreshed directly.
     *
     * @param oldItem Old data
     * @param newItem New data
     * @return Payload info. if return null, the entire item will be refreshed.
     */
    override fun getChangePayload(oldItem: JSONObject, newItem: JSONObject): Any? {
        return null
    }
}
