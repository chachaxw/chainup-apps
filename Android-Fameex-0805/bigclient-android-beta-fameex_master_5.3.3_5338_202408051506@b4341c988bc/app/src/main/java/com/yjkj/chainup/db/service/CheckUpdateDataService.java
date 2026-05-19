package com.yjkj.chainup.db.service;

import com.yjkj.chainup.db.MMKVDb;

/**
 *@description: Color Settings for Up and Down Range
 * @Author: wanghao
 * @CreateDate: 2019-09-30 19:49
 * @UpdateUser: wanghao
 * @UpdateDate 2023-09-30 19:49
 *@ UpdateRemark: Update Description
 */
public class CheckUpdateDataService {

    private MMKVDb mMMKVDb;

    public static final int hideDialog = 1;
    private static final String checkupdate = "checkupdate";
    private static final String checkUpdateVersion = "checkUpdateVersion";

    private CheckUpdateDataService() {
        mMMKVDb = new MMKVDb();
    }

    private static CheckUpdateDataService mCheckUpdateDataService;

    public static CheckUpdateDataService getInstance() {
        if (null == mCheckUpdateDataService)
            mCheckUpdateDataService = new CheckUpdateDataService();
        return mCheckUpdateDataService;
    }

    public void saveData(int value) {
        mMMKVDb.saveIntData(checkupdate, value);
    }

    public boolean hideDialog() {
        return hideDialog == mMMKVDb.getIntData(checkupdate, 0);
    }

    public void saveHideVersion(int value) {
        mMMKVDb.saveIntData(checkUpdateVersion, value);
    }

    public int hideVersion() {
        return mMMKVDb.getIntData(checkUpdateVersion, -1);
    }

    /**
     *Ignore upgrade
     */
    public boolean isHideUpdate(int version) {
        boolean isHide = hideDialog();
        //Not clicked to cancel the upgrade prompt
        if (!isHide) {
            return false;
        }
        int preVersion = hideVersion();
        //Old version not marked with default prompt for upgrade
        if (preVersion == -1) {
            return false;
        }
        if (preVersion < version) {
            return false;
        }
        //The local version is smaller than the new version
        return true;

    }

    public void saveUpdateData(int value, int version) {
        saveData(value);
        if (version != 0) {
            saveHideVersion(version);
        }
    }

    public void clearUpdateData() {
        mMMKVDb.removeValueForKey(checkupdate);
        mMMKVDb.removeValueForKey(checkUpdateVersion);
    }

}
