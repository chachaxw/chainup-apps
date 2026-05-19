package com.yjkj.chainup.securityVerifyRule;

import android.text.TextUtils;

import com.chainup.kit.dialog.security.KKSecurityEnum;
import com.chainup.kit.dialog.security.KKSecurityRule;
import com.yjkj.chainup.db.service.UserDataService;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;


/**
 *  1. 忘了密码？
 2. 解绑资金密码
 3. 提币白名单开关验证
 4. 添加地址
 5. 删除地址
 1. Forgot your password?
 2. Unbind the fund password
 3. Withdrawal Whitelist Switch Verification
 4. Add an address
 5. Delete the address

 *  A.校验是否绑定手机和邮箱，两者均绑定或绑定手机号没绑定邮箱则使用短信验证，如没绑定手机，则使用邮箱验证；
 B.校验是否绑定谷歌,若绑定则验证，若没绑定则不验证。
 A. Check whether the mobile phone and email are bound, both are bound or the mobile phone number is not bound to the mailbox, then SMS verification is used, if the mobile phone is not bound, the email verification is used;
 B. Check whether it is bound to Google, if it is bound, it will be verified, if it is not bound, it will not be verified.
 * */
public class VerifyRule2 implements KKSecurityRule {
    List<KKSecurityEnum> entryList;
    @Override
    public Collection<KKSecurityEnum> makeRule() {
        entryList = new ArrayList<>();
        if (UserDataService.getInstance().getGoogleStatus() == 1) {
            entryList.add(KKSecurityEnum.GA);
        }

        if (UserDataService.getInstance().getIsOpenMobileCheck() == 1) {
            entryList.add(KKSecurityEnum.PHONE);
        }else if (!TextUtils.isEmpty(UserDataService.getInstance().getEmail())) {
            entryList.add(KKSecurityEnum.EMAIL);
        }

        return entryList;
    }
}
