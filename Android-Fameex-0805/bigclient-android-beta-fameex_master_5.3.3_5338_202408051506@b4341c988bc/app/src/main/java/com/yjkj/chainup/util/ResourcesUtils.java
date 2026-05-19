package com.yjkj.chainup.util;

import android.content.Context;

import com.yjkj.chainup.R;

import java.lang.reflect.Field;

public class ResourcesUtils {


    private static final String RES_ID = "id";
    private static final String RES_STRING = "string";
    private static final String RES_DRABLE = "drable";
    private static final String RES_LAYOUT = "layout";
    private static final String RES_STYLE = "style";
    private static final String RES_COLOR = "color";
    private static final String RES_DIMEN = "dimen";
    private static final String RES_ANIM = "anim";
    private static final String RES_MENU = "menu";


    /**
     *Obtain the ID of the resource file
     * @param context
     * @param resName
     * @return
     */
    public static int getId(Context context,String resName){
        return getResId(context,resName,RES_ID);
    }

    /**
     *Obtain the ID of the resource file string
     * @param context
     * @param resName
     * @return
     */
    public static int getStringId(Context context,String resName){
        return getResId(context,resName,RES_STRING);
    }

    /**
     *Obtain the ID of the resource file drain
     * @param context
     * @param resName
     * @return
     */
    public static int getDrableId(Context context,String resName){
        int drawableId = context.getResources().getIdentifier(resName, "drawable", context.getPackageName());
        return drawableId;
    }

    /**
     *Obtain the ID of the resource file layout
     * @param context
     * @param resName
     * @return
     */
    public static int getLayoutId(Context context,String resName){
        return getResId(context,resName,RES_LAYOUT);
    }

    /**
     *Obtain the ID of the resource file style
     * @param context
     * @param resName
     * @return
     */
    public static int getStyleId(Context context,String resName){
        return getResId(context,resName,RES_STYLE);
    }

    /**
     *Obtain the ID of the resource file color
     * @param context
     * @param resName
     * @return
     */
    public static int getColorId(Context context,String resName){
        return getResId(context,resName,RES_COLOR);
    }

    /**
     *Obtain the ID of the resource file dimension
     * @param context
     * @param resName
     * @return
     */
    public static int getDimenId(Context context,String resName){
        return getResId(context,resName,RES_DIMEN);
    }

    /**
     *Obtain the ID of the resource file ainm
     * @param context
     * @param resName
     * @return
     */
    public static int getAnimId(Context context,String resName){
        return getResId(context,resName,RES_ANIM);
    }

    /**
     *Obtain the ID of the resource file menu
     */
    public static int getMenuId(Context context,String resName){
        return getResId(context,resName,RES_MENU);
    }

    /**
     *Obtain resource file ID
     * @param context
     * @param resName
     * @param defType
     * @return
     */
    public static int getResId(Context context, String resName, String defType){
        return context.getResources().getIdentifier(resName, defType, context.getPackageName());
    }

}
