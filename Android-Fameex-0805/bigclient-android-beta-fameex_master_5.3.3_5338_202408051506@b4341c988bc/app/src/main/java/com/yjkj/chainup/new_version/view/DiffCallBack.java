package com.yjkj.chainup.new_version.view;

import androidx.annotation.Nullable;
import androidx.recyclerview.widget.DiffUtil;

import androidx.recyclerview.widget.RecyclerView;

import org.json.JSONObject;

import java.util.List;

/**
 *Introduction: The core class is used to determine whether new and old items are equal
 *Author: zhangxutong
 *Email: zhangxutong@imcoming.com
 *Time: September 12, 2016
 */

public class DiffCallBack extends DiffUtil.Callback {
    private List<JSONObject> mOldDatas, mNewDatas;//Look at the name

    public DiffCallBack(List<JSONObject> mOldDatas, List<JSONObject> mNewDatas) {
        this.mOldDatas = mOldDatas;
        this.mNewDatas = mNewDatas;
    }

    //Old dataset size
    @Override
    public int getOldListSize() {
        return mOldDatas != null ? mOldDatas.size() : 0;
    }

    //New dataset size
    @Override
    public int getNewListSize() {
        return mNewDatas != null ? mNewDatas.size() : 0;
    }

    /**
     * Called by the DiffUtil to decide whether two object represent the same Item.
     *Called by DiffUtil to determine whether two objects are the same Item.
     * For example, if your items have unique ids, this method should check their id equality.
     *For example, if your Item has a unique ID field, this method determines whether the IDs are equal.
     *This example determines whether the name field is consistent
     *
     * @param oldItemPosition The position of the item in the old list
     * @param newItemPosition The position of the item in the new list
     * @return True if the two items represent the same object or false if they are different.
     */
    @Override
    public boolean areItemsTheSame(int oldItemPosition, int newItemPosition) {
        return mOldDatas.get(oldItemPosition).optString("symbol").equals(mNewDatas.get(newItemPosition).optString("symbol"));
    }

    /**
     * Called by the DiffUtil when it wants to check whether two items have the same data.
     *Called by DiffUtil to check if two items contain the same data
     * DiffUtil uses this information to detect if the contents of an item has changed.
     *DiffUtil uses the returned information (true or false) to detect whether the content of the current item has changed
     * DiffUtil uses this method to check equality instead of {@link Object#equals(Object)}
     *DiffUtil uses this method instead of the equals method to check for equality.
     * so that you can change its behavior depending on your UI.
     *So you can change its return value based on your UI
     * For example, if you are using DiffUtil with a
     * {@link RecyclerView.Adapter RecyclerView.Adapter}, you should
     * return whether the items' visual representations are the same.
     *For example, if you use RecyclerView.Adapter with DiffUtil, you need to return whether the visual representation of the item is the same.
     * This method is called only if {@link #areItemsTheSame(int, int)} returns
     * {@code true} for these items.
     *This method is only called when areItemsTheSame() returns true.
     *
     * @param oldItemPosition The position of the item in the old list
     * @param newItemPosition The position of the item in the new list which replaces the
     *                        oldItem
     * @return True if the contents of the items are the same or false if they are different.
     */
    @Override
    public boolean areContentsTheSame(int oldItemPosition, int newItemPosition) {
        JSONObject beanOld = mOldDatas.get(oldItemPosition);
        JSONObject beanNew = mNewDatas.get(newItemPosition);
        if (!beanOld.optString("close").equals(beanNew.optString("close"))) {
            return false;//If the content is different, return false
        }
        if (beanOld.optString("vol") != beanNew.optString("vol")) {
            return false;//If the content is different, return false
        }
        return true; //By default, the two data contents are the same



    }
    //This call is quite fancy and requires a lot of requirements. It requires areItemsTheSame() to return true, indicating that it is the same piece of data
    //But we also need areContentsTheSame() to return false, telling you that although we are the same piece of data, we also have different
    //It returns an Object object, and here I am returning a Boolean object. I will tell you how to use this object later
    //Of course, you can also return any object and change it when the time comes.

    @Nullable
    @Override
    public Object getChangePayload(int oldItemPosition, int newItemPosition) {
        JSONObject newJsonObject = mNewDatas.get(newItemPosition);
        JSONObject oldJsonObject = mNewDatas.get(newItemPosition);
        return oldJsonObject.optString("close").equals(newJsonObject.optString("close")) ||oldJsonObject.optString("vol").equals(newJsonObject.optString("vol"));
    }
}

