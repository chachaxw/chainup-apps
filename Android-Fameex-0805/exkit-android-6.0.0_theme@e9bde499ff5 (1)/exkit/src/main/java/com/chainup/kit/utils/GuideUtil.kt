package com.chainup.kit.utils

import android.app.Activity
import android.view.View
import com.binioter.guideview.GuideBuilder
import com.chainup.kit.views.component.GuideComponent
import com.example.chainup_kit.BuildConfig

class GuideUtil {

    interface GuideListener {
        fun onDismiss()
    }

    class GuideChangeToast(val context: Activity,var position: Int) : GuideBuilder.OnVisibilityChangedListener{
        override fun onShown() { }

        override fun onDismiss() {
            currentGuideList?.run {
                if(position != -1) {
                    if(position < this.size-1) {
                        position += 1
                        showGuide(context, this[position],position)
                    }else{
                        this.clear()
                    }
                }
            }
        }
    }
    data class GuideTargetModel(val target:View,val message: String?,val key:String,val component:GuideComponent?)


    companion object {
        private const val alpha = 0

        const val GUIDE_CESHI1 = "guide_ceshi1"
        const val GUIDE_CESHI2 = "guide_ceshi2"
        const val GUIDE_CESHI3 = "guide_ceshi3"
        const val GUIDE_CESHI4 = "guide_ceshi4"
        var currentGuideList:ArrayList<GuideTargetModel>? = null

        @JvmStatic
        fun showGuide(context: Activity, model:GuideTargetModel,position:Int = -1){
            val isShow = SPUtil.getInstance(context).getSharedInt(model.key,0) == 0 || BuildConfig.DEBUG
            if(!isShow){
                if(position == -1) return
                val nextPosition = position + 1

                currentGuideList?.run {
                    if(size<=0) return
                    if(nextPosition >= size){
                        return
                    }
                    showGuide(context, this[nextPosition],nextPosition)
                }
                return
            }
            val builder = GuideBuilder()
            val component = model.component ?: GuideComponent(model.message?:"")
            val guide = builder.setTargetView(model.target)
                .setAlpha(alpha)
                .setHighTargetPadding(0)
                .setOutsideTouchable(false)
                .setOnVisibilityChangedListener(GuideChangeToast(context,position))
                .addComponent(component)
                .createGuide()
            component.setGuideListener(object : GuideListener {
                override fun onDismiss() {
                    guide.dismiss()
                }
            })
            SPUtil.getInstance(context).putSharedInt(model.key,1)
            guide.show(context)
        }

        @JvmStatic
        fun showMultipleGuide(context: Activity, targetList:ArrayList<GuideTargetModel>){
            if(targetList.size <= 0){
                throw Exception("targetList size is 0!")
            }
            currentGuideList = targetList
            showGuide(context,targetList[0],0)
        }

    }

}
