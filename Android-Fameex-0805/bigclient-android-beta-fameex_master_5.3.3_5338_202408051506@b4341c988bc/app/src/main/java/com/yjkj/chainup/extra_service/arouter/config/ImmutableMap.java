package com.yjkj.chainup.extra_service.arouter.config;

import java.util.HashMap;
import java.util.Map;

/**
 *Author: Li Weijie Ziran on April 13, 2017
 *Email: liweijie@linghit.com
 * description：
 * update by:
 * update day:
 */
public class ImmutableMap {

    private Map<String, String> mPaths;

    public ImmutableMap() {
        mPaths = new HashMap<>();
    }

    public void add(String key, String value) {
        if (null==key || null==value) return;
        mPaths.put(key, value);
    }

    public void add(Map<String, String> mPaths) {
        if (mPaths == null) return;
        this.mPaths.putAll(mPaths);
    }

    public boolean containsKey(String key) {
        return mPaths.containsKey(key);
    }

    public String get(String key) {
        return mPaths.get(key);
    }
}
