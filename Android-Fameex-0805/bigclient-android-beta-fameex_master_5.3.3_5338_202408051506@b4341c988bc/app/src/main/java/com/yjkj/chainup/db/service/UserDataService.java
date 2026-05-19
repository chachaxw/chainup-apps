package com.yjkj.chainup.db.service;

import android.text.TextUtils;

import com.chainup.contract.app.ContractCloudAgent;
import com.chainup.contract.utils.CpClLogicContractSetting;
import com.yjkj.chainup.db.MMKVDb;
import com.yjkj.chainup.extra_service.eventbus.EventBusUtil;
import com.yjkj.chainup.extra_service.eventbus.MessageEvent;
import com.yjkj.chainup.manager.LoginManager;
import com.yjkj.chainup.util.StringUtil;

import org.json.JSONException;
import org.json.JSONObject;

/**
 * @Description:
 * @Author: wanghao
 * @CreateDate: 2019-08-12 15:43
 * @UpdateUser: wanghao
 * @UpdateDate 2023-08-12 15:43
 *@ UpdateRemark: Update Description
 */
public class UserDataService {

    private static final String userDataKey = "userData";
    private static final String SP_GESTURE_PASS = "sp_gesture_pass";
    private static final String userTokenKey = "userToken";
    private static final String quicktoken = "QUICKTOKEN";
    private static final String showAssets = "showAssets";
    private static final String show_little_assets = "show_little_assets";//Hide small assets
    private static final String home_data = "home_data";//Homepage data

    private static String LOGIN_TOKEN = "";
    private MMKVDb mMMKVDb;

    private boolean isNetworkCheckIng = false;
    private int withdrawWhitelistFlag = -1;

    private UserDataService() {
        mMMKVDb = new MMKVDb();
    }

    private static UserDataService mUserDataService;

    public static UserDataService getInstance() {
        if (null == mUserDataService)
            mUserDataService = new UserDataService();
        return mUserDataService;

    }

    public void saveData(JSONObject data) {
        if (null != data) {
            mMMKVDb.saveData(userDataKey, data.toString());
        }

        //After Google verifies login, only token without ID cannot create a contract sub account. After obtaining user information, it is necessary to notify the contract to be created again
//        if (ContractCloudAgent.INSTANCE.isCloudOpen()) {
//            ContractCloudAgent.INSTANCE.init(getUserInfo4UserId(), null);
//        }
    }

    public JSONObject getUserData() {
        String data = mMMKVDb.getData(userDataKey);
        if (StringUtil.checkStr(data)) {
            try {
                return new JSONObject(data);
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
        return null;
    }

    public void saveQuickToken(String token) {
        mMMKVDb.saveData(quicktoken, token);
    }

    public String getQuickToken() {
        return mMMKVDb.getData(quicktoken);
    }


    public String getToken() {
        if (LOGIN_TOKEN.isEmpty()) {
            LOGIN_TOKEN = getTokenData();
            return LOGIN_TOKEN;
        }
        return LOGIN_TOKEN;
    }

    public void saveToken(String token) {
        LOGIN_TOKEN = token;
        setToken(token);
        CpClLogicContractSetting.setToken(LOGIN_TOKEN);
        notifyContractLoginStatusListener();
        MessageEvent messageEvent = new MessageEvent(MessageEvent.login_success_event);
        messageEvent.setMsg_content(LOGIN_TOKEN);
        EventBusUtil.postSticky(messageEvent);
    }

    public void clearToken() {
        LOGIN_TOKEN = "";
        setToken("");
        CpClLogicContractSetting.cleanToken();
        notifyContractLoginStatusListener();
    }

    public void clearTokenByContract() {
        LOGIN_TOKEN = "";
        setToken("");
    }

    /**
     *Contract business requires listening for login callbacks
     */
    public void notifyContractLoginStatusListener() {
        if (TextUtils.isEmpty(LOGIN_TOKEN)) {
//            ContractSDKAgent.INSTANCE.exitLogin();
            CpClLogicContractSetting.cleanToken();
        } else {
            CpClLogicContractSetting.setToken(LOGIN_TOKEN);
//            if (ContractCloudAgent.INSTANCE.isCloudOpen()) {
//                ContractCloudAgent.INSTANCE.init(getUserInfo4UserId(), null);
//            } else {
//                try {
//                    ContractUser contractUser = new ContractUser();
//                    contractUser.setToken(LOGIN_TOKEN);
//                    ContractSDKAgent.INSTANCE.setUser(contractUser);
//                } catch (Exception e) {
////                    LogUtil.e("ContractSDKAgent.INSTANCE.setUser", e.getMessage());
//                }
//            }
        }
    }

    public void saveGesturePass(String pass) {
        mMMKVDb.saveData(SP_GESTURE_PASS, pass);
        LoginManager.getInstance().saveGesturePwdErrorTimes(5);
    }

    public String getGesturePass() {
        return mMMKVDb.getData(SP_GESTURE_PASS);
    }

    public void clearLoginState() {
        LOGIN_TOKEN = "";
        saveData(new JSONObject());
        notifyContractLoginStatusListener();
    }

    public String getGesturePwd() {
        JSONObject data = getUserData();
        if (null != data)
            return data.optString("gesturePwd");
        return "";
    }

    public String getNickName() {
        JSONObject data = getUserData();
        if (null != data)
            return data.optString("nickName");
        return "";

    }

    public String getCountryCode() {
        JSONObject data = getUserData();
        if (null != data)
            return data.optString("countryCode");
        return "";

    }

    public String getEmail() {
        JSONObject data = getUserData();
        if (null != data)
            return data.optString("email");
        return "";
    }

    public String getInviteCode() {
        JSONObject data = getUserData();
        if (null != data)
            return data.optString("inviteCode");
        return "";
    }

    public String getInviteUrl() {
        JSONObject data = getUserData();
        if (null != data)
            return data.optString("inviteUrl");
        return "";
    }

    public String getInviteLeftQuota() {
        JSONObject data = getUserData();
        if (null != data)
            return data.optString("inviteLeftQuota");
        return "";
    }

    public String getMobileNumber() {
        JSONObject data = getUserData();
        if (null != data)
            return data.optString("mobileNumber");
        return "";
    }
    //true 表示 不限制场外交易，false 表示限制场外交易。
    //True indicates no restrictions on over-the-counter trading, while false indicates restrictions on over-the-counter trading.
    public Boolean getC2cStatus() {
        JSONObject data = getUserData();
        if (null != data)
            return data.optBoolean("c2cStatus");
        return false;
    }
    //1表示平台认证，2表式sumsub认证
    //1 represents platform authentication, and 2 represents table based sumsub authentication
    public int getAuthType() {
        JSONObject data = getUserData();
        if (null != data)
            return data.optInt("authType");
        return 1;
    }

    public String getRealName() {
        JSONObject data = getUserData();
        if (null != data)
            return data.optString("realName");
        return "";
    }

    //0 pass 1 not pass
    public int getAuthLevel() {
        JSONObject data = getUserData();
        if (null != data)
            return data.optInt("authLevel");
        return 0;
    }

    public int getGoogleStatus() {
        JSONObject data = getUserData();
        if (null != data)
            return data.optInt("googleStatus");
        return 0;

    }

    public int getIsOpenMobileCheck() {
        JSONObject data = getUserData();
        if (null != data)
            return data.optInt("isOpenMobileCheck");
        return 0;
    }

    public int getIsCapitalPwordSet() {
        JSONObject data = getUserData();
        if (null != data)
            return data.optInt("isCapitalPwordSet");
        return 0;
    }

    public int getAccountStatus() {
        JSONObject data = getUserData();
        if (null != data)
            return data.optInt("accountStatus");
        return 0;

    }

    public int getAgentStatus() {
        JSONObject data = getUserData();
        if (null != data)
            return data.optInt("agentStatus");
        return 0;

    }

    public boolean isLogined() {
        return StringUtil.checkStr(getToken());
    }


    public String getUserInfo4UserId() {
        JSONObject data = getUserData();
        if (null != data)
            return data.optString("id");
        return "";
    }

    public String getUserAccount() {
        JSONObject data = getUserData();
        if (null != data)
            return data.optString("userAccount");
        return "";
    }


    /*
     *Hiding and Displaying Assets
     */
    public void setShowAssetStatus(boolean isShowAssets) {
        mMMKVDb.saveBooleanData(showAssets, isShowAssets);
    }

    public boolean isShowAssets() {
        return mMMKVDb.getBooleanData(showAssets, true);
    }


    /**
     *Whether to hide 'small assets'
     */
    public boolean getAssetState() {
        return mMMKVDb.getBooleanData(show_little_assets, false);
    }

    public void saveAssetState(boolean isHide) {
        mMMKVDb.saveBooleanData(show_little_assets, isHide);
    }

    private void setByKey(String key, String object) {
        if (null != object) {
            mMMKVDb.saveData(key, object);
        }
    }

    private String getKeyByKey(String key) {
        if (null != mMMKVDb) {
            return mMMKVDb.getData(key);
        }
        return "";
    }

    private void setToken(String tokenData) {
        setByKey(userTokenKey, tokenData);
    }

    private String getTokenData() {
        return getKeyByKey(userTokenKey);
    }

    public boolean isNetworkCheckIng() {
        return isNetworkCheckIng;
    }

    public void setNetworkCheckIng(boolean networkCheckIng) {
        isNetworkCheckIng = networkCheckIng;
    }

    /**
     *Whether to enable ETF
     *
     * @return
     */
    public boolean getUserIsOpenEtf() {
        JSONObject data = getUserData();
        if (null != data)
            return data.optInt("useEtf",0) == 1;
        return false;
    }

    public boolean getETFIsLimit() {
        JSONObject data = getUserData();
        if (null != data)
            return data.optInt("etfLocalLimit") == 1;
        return false;
    }

    public void saveETFOpen() {
        JSONObject data = getUserData();
        if (null != data) {
            try {
                data.put("useEtf", 1);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    //withdrawWhitelistFlag 0关闭 1开启
    public int getWithdrawWhitelistFlag(){
        if(withdrawWhitelistFlag==-1){
            JSONObject data = getUserData();
            if (null != data) withdrawWhitelistFlag = data.optInt("withdrawWhitelistFlag",0);
        }
        return withdrawWhitelistFlag;
    }

    public void setWithdrawWhitelistFlag(boolean isOpen){
        withdrawWhitelistFlag = isOpen ? 1 : 0;
    }
    //为0则不存在上级邀请人，否则返回上级uid
    //If it is 0, there is no superior inviter, otherwise return to the superior uid
    public Boolean ableToAddPid(){
        JSONObject data = getUserData();
        Boolean ableToAddPid=false;
        if (null != data) ableToAddPid = data.optBoolean("ableToAddPid",false);
        return ableToAddPid;
    }

}
