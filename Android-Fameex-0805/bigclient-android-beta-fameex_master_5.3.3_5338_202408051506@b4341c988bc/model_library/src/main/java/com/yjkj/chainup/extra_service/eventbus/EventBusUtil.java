package com.yjkj.chainup.extra_service.eventbus;

import com.chainup.model.BuildConfig;

import org.greenrobot.eventbus.EventBus;

/**
 * Created by wanghao on 2018/5/3.
 */

public class EventBusUtil {

    public static void throwSubscriberException(){
        EventBus.builder().throwSubscriberException(BuildConfig.DEBUG);
    }

    /*
     *Registered subscribers
     */
    public static void register(Object obj){
        if(!EventBus.getDefault().isRegistered(obj)){
            EventBus.getDefault().register(obj);
        }
    }

    /*
     *Unregister subscriber
     */
    public static void unregister(Object obj){
        EventBus.getDefault().unregister(obj);
    }

    /*
     *Publish ordinary events
     */
    public static void post(MessageEvent event){
        EventBus.getDefault().post(event);
    }

    /*
     *Post sticky events
     */
    public static void postSticky(MessageEvent event){
        MessageEvent messageEvent = EventBus.getDefault().getStickyEvent(MessageEvent.class);
        if(null!=messageEvent){
            EventBus.getDefault().removeStickyEvent(event);
        }
        EventBus.getDefault().postSticky(event);
    }

    /*
     *Remove sticky events
     */
    public static void removeStickyEvent(MessageEvent event){
        if(null == event){
            return;
        }
        EventBus.getDefault().removeStickyEvent(event);
    }

    public static void removeAllStickyEvents(){
        EventBus.getDefault().removeAllStickyEvents();
    }
}
