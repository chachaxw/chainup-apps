package com.yjkj.chainup.securityVerifyRule;

import com.chainup.kit.dialog.security.KKSecurityEnum;
import com.chainup.kit.dialog.security.KKSecurityRule;
import com.yjkj.chainup.db.service.PublicInfoDataService;
import com.yjkj.chainup.db.service.UserDataService;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

/**
 * [Fund pwd] has been set, and only the fund pwd will be verified
 * [Fund pwd] is not set:
 * - Determine whether forced Google verification is enabled, and if so, a pop-up window will be displayed for Google verification;
 * - If it is not enabled, it will be judged whether to bind the phone or Google. If both are bound, both are validated, and if only one is bound, the bound item is validated
 * 已设置【资金密码】，仅进行资金密码验证
 * 未设置【资金密码】：
 * -判断是否开启了强制谷歌验证，如果开启了则弹窗进行谷歌验证；
 * -如果未开启，则判断是否绑定手机、谷歌。如果二者均绑定则均验证，如果只绑定其一，则验证已绑定项
 * */
public class VerifyRule4 implements KKSecurityRule {
    List<KKSecurityEnum> entryList;
    @Override
    public Collection<KKSecurityEnum> makeRule() {
        entryList = new ArrayList<>();
        boolean isSetCapitalPwd = UserDataService.getInstance().getIsCapitalPwordSet() == 1;
        if(isSetCapitalPwd){
            entryList.add(KKSecurityEnum.CAPITALPWD);
            return entryList;
        }

        boolean enforceGoogleAuth = PublicInfoDataService.getInstance().isEnforceGoogleAuth(null);
        if(enforceGoogleAuth){
            entryList.add(KKSecurityEnum.GA);
            return entryList;
        }

        if (UserDataService.getInstance().getIsOpenMobileCheck() == 1) {
            entryList.add(KKSecurityEnum.PHONE);
        }
        if (UserDataService.getInstance().getGoogleStatus() == 1) {
            entryList.add(KKSecurityEnum.GA);
        }

        return entryList;
    }
}
