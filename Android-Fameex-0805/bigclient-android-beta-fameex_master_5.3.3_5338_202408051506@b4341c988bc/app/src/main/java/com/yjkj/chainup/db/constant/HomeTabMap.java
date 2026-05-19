package com.yjkj.chainup.db.constant;

import com.yjkj.chainup.db.service.PublicInfoDataService;
import com.yjkj.chainup.net.api.ApiConstants;

import org.json.JSONObject;

import java.util.HashMap;

/**
 *@description: The constant values of the 5 tab types at the bottom of the homepage
 * @Author: wanghao
 * @CreateDate: 2019-10-25 20:38
 * @UpdateUser: wanghao
 * @UpdateDate 2023-10-25 20:38
 *@ UpdateRemark: Update Description
 */
public class HomeTabMap {

    public static final HashMap<String, Integer> maps = new HashMap<>();
    public static final String homeTab = "homeTab"; //Homepage
    public static final String marketTab = "marketTab"; //Market tab
    public static final String coinTradeTab = "coinTradeTab"; //Spot trading
    public static final String otccoinTradeTab = "otccoinTradeTab"; //Legal currency transactions
    public static final String contractTab = "contractTab"; //Contract
    public static final String assetsTab = "assetsTab"; //Assets

    public static void initMaps(JSONObject data) {
        maps.clear();
        boolean contractOpen = PublicInfoDataService.getInstance().contractOpen(data);
        maps.put(homeTab, 0);
        if (ApiConstants.HOME_VIEW_STATUS.equals(ParamConstant.CONTRACT_HOME_PAGE)) {
            maps.put(contractTab, 1);
            maps.put(assetsTab, 2);
        } else {
            maps.put(marketTab, 1);
            maps.put(coinTradeTab, 2);
            if (contractOpen) {
                maps.put(contractTab, 3);
                maps.put(assetsTab, 4);
            } else {
                maps.put(assetsTab, 3);
            }
        }

    }
}
