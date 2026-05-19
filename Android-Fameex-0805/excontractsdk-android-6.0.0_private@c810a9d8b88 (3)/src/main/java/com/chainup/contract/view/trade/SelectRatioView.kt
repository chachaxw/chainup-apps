package com.chainup.contract.view.trade

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.widget.LinearLayout
import android.widget.RelativeLayout
import android.widget.TextView
import androidx.core.content.ContextCompat
import com.chainup.contract.R
import com.chainup.contract.utils.CpSizeUtils
import org.jetbrains.anko.textColor

/**
 *@ property setRadios Set ratio data Array<Float>
 *@ property resetViewColor Reset all colors
 *@ property selectRadioByPosition Dynamic selection
 *@ description Progress selection control (ui design) contract selection ratio
 * */
class SelectRatioView @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null
) : LinearLayout(context, attrs) {

    private val itemRadioMarginRight = CpSizeUtils.dp2px(4f)

    private val viewLists:ArrayList<View> = arrayListOf()

    //Click Location
    private var position:Int = -1

    init {
        orientation = HORIZONTAL
    }
    //Set Scale
    fun setRadios(data:Array<Float>,initSelectPosition:Int? = null,callback:((value:Float,position:Int,view:View?)->Unit)? = null) {
        if(data.isEmpty()) return
        removeAllViews()
        viewLists.clear()
        val inflater = LayoutInflater.from(context)
        post(object : Runnable{
            override fun run() {
                val itemWidth = ((measuredWidth - (data.size-1) * itemRadioMarginRight) / data.size)
                for(i in 0 until data.size){
                    val itemRatioLayout = inflater.inflate(R.layout.item_select_ratio_layout,null)
                    val layoutParams = RelativeLayout.LayoutParams(itemWidth, LayoutParams.WRAP_CONTENT)

                    val labelView = itemRatioLayout.findViewById<TextView>(R.id.item_text)
                    val ratioView = itemRatioLayout.findViewById<View>(R.id.item_ratio)

                    layoutParams.rightMargin = if(i==data.size-1) 0 else itemRadioMarginRight
                    itemRatioLayout.layoutParams = layoutParams

                    labelView.text = (data[i] * 100).toInt().toString()+"%"


                    itemRatioLayout.setOnClickListener(object : OnClickListener{
                        override fun onClick(p0: View?) {
                            if(position==i){
                                //Repeat click
                                resetViewColor()
                                position = -1
                                callback?.invoke(data[i],-1,p0)
                            }else{
                                position = i
                                resetViewColor()
                                selectViewByPosition(i)
                                callback?.invoke(data[i],i,p0)
                            }

                        }
                    })
                    viewLists.add(itemRatioLayout)
                    this@SelectRatioView.addView(itemRatioLayout)
                }
                if(initSelectPosition!=null) selectRadioByPosition(initSelectPosition)
            }
        })
    }

    private fun selectViewByPosition(position: Int) {
        //Select all view colors before this position as the main color
        for(index in 0 until (position+1)){
            val itemView = viewLists[index]
            val ratioView = itemView.findViewById<View>(R.id.item_ratio)
            ratioView.isSelected = true
        }
        //Set the selected label color
        val currentView = viewLists[position]
        val labelView = currentView.findViewById<TextView>(R.id.item_text)
        labelView.textColor = ContextCompat.getColor(context,R.color.text_color_1)
    }

    //Reset All Colors
    fun resetViewColor(){
        for(index in 0 until viewLists.size){
            val itemView = viewLists[index]
            val labelView = itemView.findViewById<TextView>(R.id.item_text)
            val ratioView = itemView.findViewById<View>(R.id.item_ratio)
            ratioView.isSelected = false
            labelView.textColor = ContextCompat.getColor(context,R.color.text_color_2)
        }
    }


    /**
     *@param position Selected position
     *@ description Dynamic selection by location
     * @sample selectRadioByPosition(0)
     * */
    fun selectRadioByPosition(position: Int){
        resetViewColor()
        selectViewByPosition(position)
        this.position = position
    }

}
