package com.chainup.contract.utils

import android.app.Activity
import android.os.Handler
import android.view.View
import com.binioter.guideview.GuideBuilder
import com.chainup.contract.view.CpToastComponent
import com.yjkj.chainup.manager.CpLanguageUtil

class CpGuideUtil {

    interface GuideListener {
        fun onDismiss()
    }

    class GuideChangeToast(view: View,message: String) : GuideBuilder.OnVisibilityChangedListener{
        override fun onShown() {

        }

        override fun onDismiss() {

        }

    }


    companion object{
        private val highCorner = CpSizeUtils.dp2px(4f)
        private const val alpha = 0

        const val CONTRACT_ORDER_VALUE_GUIDE = "cp_order_select_guide"
        fun showGuide(context: Activity?, view: View, message: String){
            val flag = CpClLogicContractSetting.getGuideFlag(context)
            if(flag==1) return

            val builder = GuideBuilder()
            builder.setTargetView(view)
                .setAlpha(alpha)
                .setHighTargetCorner(highCorner)
                .setHighTargetPadding(0)
                .setOutsideTouchable(false)
            builder.setOnVisibilityChangedListener(GuideChangeToast(view,message))
            val component = CpToastComponent(CpLanguageUtil.getString(context, message))
            builder.addComponent(component)
            val guide = builder.createGuide()
            component.guideListener = object : GuideListener {
                override fun onDismiss() {
                    guide.dismiss()
                }
            }
            Handler().postDelayed({
                CpClLogicContractSetting.setGuideFlag(context,1)
                guide.show(context)
            }, 600)
        }
    }
}
