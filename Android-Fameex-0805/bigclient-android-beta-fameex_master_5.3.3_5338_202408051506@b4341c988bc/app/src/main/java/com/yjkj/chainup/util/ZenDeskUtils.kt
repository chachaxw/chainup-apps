package com.yjkj.chainup.util

import android.content.Context
import com.yjkj.chainup.net.api.ApiConstants
import zendesk.android.FailureCallback
import zendesk.android.SuccessCallback
import zendesk.android.Zendesk
import zendesk.messaging.android.DefaultMessagingFactory


object ZenDeskUtils {

    fun initialize(context: Context,isShowMsg:Boolean?=false) {
        Zendesk.initialize(context, ApiConstants.ZENDESK_KEY,object :
            SuccessCallback<Zendesk> {
            override fun onSuccess(value: Zendesk) {
                LogUtil.e("Zendesk","onSuccess")
                if(isShowMsg==true){
                    showMessaging(context);
                }
            }

        },object : FailureCallback<Throwable> {
            override fun onFailure(error: Throwable) {
                LogUtil.e("Zendesk","onFailure"+error.message)
            }

        }, DefaultMessagingFactory())
    }

    fun showMessaging(context: Context) {
       if( Zendesk.instance==null){
           initialize(context)
       }else{
           Zendesk.instance.messaging.showMessaging(context)
       }
    }
}
