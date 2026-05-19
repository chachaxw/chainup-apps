package com.yjkj.chainup.new_version.activity.like

import android.graphics.Canvas
import android.graphics.Color
import android.view.MotionEvent
import android.view.View
import android.widget.CheckBox
import android.widget.ImageView
import androidx.core.view.MotionEventCompat
import androidx.recyclerview.widget.ItemTouchHelper
import androidx.recyclerview.widget.RecyclerView
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.chainup.contract.utils.CpClLogicContractSetting
import com.loopeer.itemtouchhelperextension.ItemTouchHelperExtension
import com.yjkj.chainup.R
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.util.*
import org.jetbrains.anko.backgroundDrawable
import org.jetbrains.anko.sdk27.coroutines.onClick
import org.json.JSONObject
import java.util.*
import kotlin.collections.ArrayList

/**
 * @Author: Bertking
 * @Date 2023/12/10-2:55 PM
 * @Description:
 */

class ContractMarketEditAdapter(data: ArrayList<JSONObject>, var itemTouchHelperExtension: ItemTouchHelperExtension? = null) : BaseQuickAdapter<JSONObject, BaseViewHolder>(R.layout.item_market_edit_contract, data) {
    var editDragListener: EditDragListener? = null
    var selectMap = hashMapOf<String, Boolean>()
    override fun convert(helper: BaseViewHolder, item: JSONObject) {
//        var name = NCoinManager.showAnoterName(item)
        var name = CpClLogicContractSetting.getContractShowNameById(context,item.optInt("id"))
//        val split = name.split("/")
        helper.setText(R.id.tv_coin_name, name)
//        helper.setText(R.id.tv_market_name, "/" + split[1])
        val checkBox = helper.getView<CheckBox>(R.id.check_select)
        checkBox.isChecked = selectMap.containsKey(item?.getString("id"))
        helper.getView<ImageView>(R.id.iv_topping).onClick {
            val itemIndex = helper.adapterPosition
            if (itemIndex == 0) {
                return@onClick
            }
            editDragListener?.apply {
                val topIndex = 0
                Collections.swap(data, itemIndex, topIndex)
                notifyItemMoved(itemIndex, topIndex)
                onDragListener()
            }
        }
        helper.getView<ImageView>(R.id.tv_drag).setOnTouchListener { v, event ->
            if (MotionEventCompat.getActionMasked(event) == MotionEvent.ACTION_DOWN) {
                itemTouchHelperExtension?.startDrag(helper)
            }
            return@setOnTouchListener true
        }
    }

    fun getSelectSymbol(): String {
        return selectMap.getSymbols()
    }

    fun isSelectSymbol(): Boolean {
        return selectMap.size > 0
    }

    fun getSelectSymbolNum(): Int {
        return selectMap.size
    }

    fun isSelectAllSymbol(): Boolean {
        return selectMap.size == data.size && selectMap.size != 0
    }

    fun selectAllCoins() {
        val isAll = isSelectAllSymbol()
        data.forEach {
            val key = it.optString("id")
            if (isAll) {
                selectMap.remove(key)
            } else {
                selectMap.put(key, true)
            }
        }
        this.notifyDataSetChanged()
    }

    fun selectCurrent(position: Int) {
        val key = getItem(position)?.optString("id")
        if (selectMap.containsKey(key)) {
            selectMap.remove(key)
        } else {
            selectMap.put(key!!, true)
        }
        this.notifyItemChanged(position)
    }

    /**
     *Get the currently selected inverse set
     */
    fun getSelectSymbolsInvert(): String {
        if (isSelectAllSymbol()) {
            return ""
        }
        val allCoins = (data as ArrayList).getContractId()
        val selectCoins = getSelectSymbol()
        val updateCoins = allCoins.split(",").subtract(selectCoins.split(","))
        return updateCoins.getArraysSymbols()
    }

    /**
     *Generate a new list after deleting the selected item
     */
    fun getNewSymbolsInvert(): ArrayList<JSONObject> {
        val allCoins = data.filter {
            !selectMap.keys.contains(it.optString("id"))
        }
        return allCoins as ArrayList<JSONObject>
    }

    fun resetSelect() {
        selectMap.clear()
    }

}

interface ContractEditDragListener {
    fun onContractDragListener()
}

class ContractCoinsManageTouchHelperCallback constructor(var adapter: ContractMarketEditAdapter) : ItemTouchHelperExtension.Callback() {

    override fun getMovementFlags(recyclerView: RecyclerView?, viewHolder: RecyclerView.ViewHolder?): Int {
        return makeMovementFlags(ItemTouchHelper.UP or ItemTouchHelper.DOWN, 0)
    }

    override fun onMove(recyclerView: RecyclerView?, viewHolder: RecyclerView.ViewHolder?, target: RecyclerView.ViewHolder?): Boolean {
        //Notify the adapter to update data and views
        Collections.swap(adapter.data, viewHolder!!.adapterPosition, target!!.adapterPosition)
        adapter.notifyItemMoved(viewHolder.adapterPosition, target.adapterPosition)
        //If false is returned, it indicates that drag and drop is not supported
        return true
    }

    override fun onSwiped(viewHolder: RecyclerView.ViewHolder?, direction: Int) {

    }

    override fun isLongPressDragEnabled(): Boolean {
        return false
    }

    override fun isItemViewSwipeEnabled(): Boolean {
        return true
    }

    override fun onSelectedChanged(viewHolder: RecyclerView.ViewHolder?, actionState: Int) {
        super.onSelectedChanged(viewHolder, actionState)
        if (actionState == ItemTouchHelper.ACTION_STATE_DRAG && viewHolder != null) {//This method is to call back when the event is triggered by long pressing. Here, we change the transparency or background color of the selected item
            (viewHolder as? BaseViewHolder)?.setBackgroundColor(R.id.content, ColorUtil.getColor(viewHolder.itemView.context,R.color.fill_3))
        }
    }

    override fun clearView(recyclerView: RecyclerView?, viewHolder: RecyclerView.ViewHolder?) {
        try {
            super.clearView(recyclerView, viewHolder)//Correspondingly, we need to restore the state of the view in the following method to prevent incorrect state caused by list reuse issues.
            (viewHolder as? BaseViewHolder)?.apply {
                getView<View>(R.id.content)?.apply {
                    translationX = 0f
                    backgroundDrawable = null
                }
                adapter.apply {
                    editDragListener?.apply {
                        onDragListener()
                    }
                }
            }
        }catch (e:Exception){
            LogUtil.e("---",e.message.toString())
        }
    }

    override fun onChildDraw(c: Canvas?, recyclerView: RecyclerView?, viewHolder: RecyclerView.ViewHolder?, dX: Float, dY: Float, actionState: Int, isCurrentlyActive: Boolean) {
        if (dY != 0f && dX == 0f) {
            super.onChildDraw(c, recyclerView, viewHolder, dX, dY, actionState, isCurrentlyActive)
        }

    }

}

