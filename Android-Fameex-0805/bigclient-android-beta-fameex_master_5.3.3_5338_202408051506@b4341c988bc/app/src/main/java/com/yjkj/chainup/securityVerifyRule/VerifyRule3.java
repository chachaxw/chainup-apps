package com.yjkj.chainup.securityVerifyRule;

import android.text.TextUtils;

import com.chainup.kit.dialog.security.KKSecurityEnum;
import com.chainup.kit.dialog.security.KKSecurityRule;
import com.yjkj.chainup.db.service.PublicInfoDataService;
import com.yjkj.chainup.db.service.UserDataService;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

/**
 * withdraw SecurityDialog dialog
 * Determine whether to enable mandatory Google verification:
 * - If it is enabled, a pop-up window will be used to verify Google
 * - If it is not enabled, as shown in Figure 2.5
 * 判断是否开启强制谷歌验证：
 -若开启，则弹窗验证谷歌
 -若未开启，如图2.5所示

 A. Check whether the mobile phone number and email address are bound, both are bound or the mobile phone number is not bound to the mailbox, SMS verification is used, if the mobile phone is not bound, the email verification is used;
 B. Check whether it is bound to Google, and if it is not bound, it will be verified, and if it is not bound, it will not be verified;
 C. Whether the transaction capital password is set, it is verified, and if it is not set, it is not verified.
 A.校验是否绑定手机号和邮箱，两者均绑定或绑定手机号没绑定邮箱则使用短信验证，如没绑定手机，则使用邮箱验证；
 B.校验是否绑定谷歌，绑定则验证，没绑定则不验证；
 C.交易资金密码是否设置，已设置则验证，未设置则不验证。
 按顺序判断
 * */
public class VerifyRule3 implements KKSecurityRule {
    List<KKSecurityEnum> entryList;
    @Override
    public Collection<KKSecurityEnum> makeRule() {
        entryList = new ArrayList<>();
        boolean enforceGoogleAuth = PublicInfoDataService.getInstance().isEnforceGoogleAuth(null);
        if(enforceGoogleAuth){
            entryList.add(KKSecurityEnum.GA);
        }else{
            if (UserDataService.getInstance().getIsOpenMobileCheck() == 1) {
                entryList.add(KKSecurityEnum.PHONE);
            }else if (!TextUtils.isEmpty(UserDataService.getInstance().getEmail())) {
                entryList.add(KKSecurityEnum.EMAIL);
            }
            if (UserDataService.getInstance().getGoogleStatus() == 1) {
                entryList.add(KKSecurityEnum.GA);
            }
            if(UserDataService.getInstance().getIsCapitalPwordSet()!=0){
                entryList.add(KKSecurityEnum.CAPITALPWD);
            }
        }
        return entryList;
    }
}
