package com.chainup.kit.utils;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;

public final class SPUtil {

    private static volatile SPUtil sInstance;
    private final SharedPreferences mPreferences;
    private final static String sp_name = "chain_kit_sp";

    private SPUtil(Context context) {
        mPreferences = context.getSharedPreferences(sp_name,Context.MODE_PRIVATE);
    }

    public static SPUtil getInstance(Context context) {
        if (sInstance == null) {
            synchronized (SPUtil.class) {
                if (sInstance == null) {
                    sInstance = new SPUtil(context.getApplicationContext());
                }
            }
        }
        return sInstance;
    }

    public String getSharedString(final String key, final String defValue) {
        return mPreferences.getString(key, defValue);
    }

    public void putSharedString(final String key, final String value) {
        mPreferences.edit().putString(key, value).commit();
    }


    public int getSharedInt(final String key, final int defValue) {
        return mPreferences.getInt(key, defValue);
    }

    public void putSharedInt(final String key, final int value) {
        mPreferences.edit().putInt(key, value).commit();
    }

    public long getSharedLong(final String key, final long defValue) {
        return mPreferences.getLong(key, defValue);
    }

    public void putSharedLong(final String key, final long value) {
        mPreferences.edit().putLong(key, value).commit();
    }


    public boolean getSharedBoolean(final String key, final boolean defValue){
        return mPreferences.getBoolean(key, defValue);
    }

    public void putSharedBoolean(final String key, final boolean value) {
        mPreferences.edit().putBoolean(key, value).commit();
    }

    public void removeShare(final String... keys) {
        Editor editor = mPreferences.edit();
        for (String key : keys) {
            editor.remove(key);
        }
        editor.commit();
    }

    public static void remove(final Activity ac, final String... keys) {
        Editor editor = ac.getPreferences(Context.MODE_PRIVATE).edit();
        for (String key : keys) {
            editor.remove(key);
        }
        editor.commit();
    }



    public static boolean getBoolean(final Activity ac, final String key, final boolean defValue) {
        return ac.getPreferences(Context.MODE_PRIVATE)
                .getBoolean(key, defValue);
    }

    public static void putBoolean(final Activity ac, final String key,
                                  final boolean value) {
        SharedPreferences sp = ac.getPreferences(Context.MODE_PRIVATE);
        sp.edit().putBoolean(key, value).commit();
    }


    public static long getLong(final Activity ac, final String key, final long defValue) {
        return ac.getPreferences(Context.MODE_PRIVATE)
                .getLong(key, defValue);
    }


    public static int getInt(final Activity ac, final String key, final int defValue) {
        if(ac == null){
            return defValue;
        }
        return ac.getPreferences(Context.MODE_PRIVATE)
                .getInt(key, defValue);
    }

    public static void putInt(final Activity ac, final String key, final int value) {
        SharedPreferences sp = ac.getPreferences(Context.MODE_PRIVATE);
        sp.edit().putInt(key, value).commit();
    }


    public static String getString(final Activity ac, final String key, final String defValue) {
        return ac.getPreferences(Context.MODE_PRIVATE)
                .getString(key, defValue);
    }
}
