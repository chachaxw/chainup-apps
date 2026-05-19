package com.chainup.kit.views

import android.R.attr.button
import android.content.Context
import android.content.res.ColorStateList
import android.content.res.Resources
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.widget.LinearLayout
import android.widget.RelativeLayout
import android.widget.TextView
import androidx.core.content.ContextCompat
import com.chainup.kit.utils.PublicSizeUtil
import com.coorchice.library.utils.LogUtils
import com.example.chainup_kit.R
import org.jetbrains.anko.textColor


/**
 *@ property setRadios Set ratio data Array<Float>
 *@ property resetViewColor Reset all colors
 *@ property selectRadioByPosition dynamic selection
 *@ description Progress Selection Control (UI Design) Contract Selection Ratio
 * */
class KKSelectRatioViewKit @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null
) : LinearLayout(context, attrs) {

    private val itemRadioMarginRight = PublicSizeUtil.dp2px(context,4f)

    private val viewLists:ArrayList<View> = arrayListOf()

    //Click on location
    var position:Int = -1
    var isCancel = true
    init {
        orientation = HORIZONTAL
    }
    //Set Scale
    fun setRadios(data:Array<Float>,initSelectPosition:Int? = null,callback:KKVolListener? = null,type:Int = 0,horType:Int = 0,color:Int? = R.color.main_1) {
        if(data.isEmpty()) return
        removeAllViews()
        viewLists.clear()
        LogUtils.d("setRadios ${data.size}")
        val inflater = LayoutInflater.from(context)
        post(object : Runnable{
            override fun run() {
                val tempWidth = when(type){
                    1 -> {
                        val mWidth = screenWidth()
                        val top = dpToPx(16f)
                        val topStart = dpToPx(7f)
                        val tradeItem = if(horType == 2) (mWidth  -  top * 2) / 2  - topStart else mWidth * 0.65 - top * 3
                        tradeItem.toInt()
                    }
                    else -> measuredWidth

                }
                val itemWidth = ((tempWidth - (data.size-1) * itemRadioMarginRight) / data.size)
                for(i in 0 until data.size){
                    val itemRatioLayout = inflater.inflate(R.layout.public_item_select_ratio_layout,null)
                    val layoutParams = RelativeLayout.LayoutParams(itemWidth, LayoutParams.WRAP_CONTENT)

                    val labelView = itemRatioLayout.findViewById<TextView>(R.id.item_text)
                    val ratioView = itemRatioLayout.findViewById<View>(R.id.item_ratio)
                    val colorStateList = ColorStateList(
                        arrayOf<IntArray>(
                            intArrayOf(android.R.attr.state_selected),
                            intArrayOf()
                        ), intArrayOf(
                            ContextCompat.getColor(context, color!!),
                            ContextCompat.getColor(context,R.color.special_2)
                        )
                    )
                    ratioView.setBackgroundTintList(colorStateList)

                    layoutParams.rightMargin = if(i==data.size-1) 0 else itemRadioMarginRight
                    itemRatioLayout.layoutParams = layoutParams

                    labelView.text = (data[i] * 100).toInt().toString()+"%"


                    itemRatioLayout.setOnClickListener(object : OnClickListener{
                        override fun onClick(p0: View?) {
                            if(position==i){
                                //Repeated clicks
                                if(isCancel){
                                    resetViewColor()
                                    position = -1
                                    callback?.result(data[i],-1,p0)
                                }

                            }else{
                                position = i
                                resetViewColor()
                                selectViewByPosition(i)
                                callback?.result(data[i],i,p0)
                            }

                        }
                    })
                    viewLists.add(itemRatioLayout)
                    this@KKSelectRatioViewKit.addView(itemRatioLayout)
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
     *@ description dynamically selects through location
     * @sample selectRadioByPosition(0)
     * */
    fun selectRadioByPosition(position: Int){
        resetViewColor()
        selectViewByPosition(position)
        this.position = position
    }


    fun clearCheck(){
        resetViewColor()
        position = -1
    }


    interface KKVolListener{
        fun result(value:Float,position:Int,view:View?)
    }

    fun screenWidth() = Resources.getSystem().displayMetrics.widthPixels

    fun dpToPx(dp: Float): Int {
        val density = Resources.getSystem().displayMetrics.density
        return (dp * density + 0.5f).toInt()
    }

}
