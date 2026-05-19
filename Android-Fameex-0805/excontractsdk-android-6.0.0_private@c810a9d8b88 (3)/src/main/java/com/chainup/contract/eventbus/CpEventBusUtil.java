package com.chainup.contract.eventbus;


import com.chainup.contract.app.CpAppConfig;

import org.greenrobot.eventbus.EventBus;

/**
 * Created by wanghao on 2018/5/3.
 */

public class CpEventBusUtil {

    public static void throwSubscriberException(){
        EventBus.builder().throwSubscriberException(CpAppConfig.IS_DEBUG);
    }

    /*
     * registerSubscriber
     */
    public static void register(Object obj){
        if(!EventBus.getDefault().isRegistered(obj)){
            EventBus.getDefault().register(obj);
        }
    }

    /*
     * unregisterSubscriber
     */
    public static void unregister(Object obj){
        EventBus.getDefault().unregister(obj);
    }

    /*
     *  publishOrdinaryEvents
     */
    public static void post(CpMessageEvent event){
        EventBus.getDefault().post(event);
    }

    /*
     *  publishStickyEvents
     */
    public static void postSticky(CpMessageEvent event){
        CpMessageEvent messageEvent = EventBus.getDefault().getStickyEvent(CpMessageEvent.class);
        if(null!=messageEvent){
            EventBus.getDefault().removeStickyEvent(event);
        }
        EventBus.getDefault().postSticky(event);
    }

    /*
     *  removeStickyEvents
     */
    public static void removeStickyEvent(CpMessageEvent event){
        if(null == event){
            return;
        }
        EventBus.getDefault().removeStickyEvent(event);
    }

    public static void removeAllStickyEvents(){
        EventBus.getDefault().removeAllStickyEvents();
    }
}
