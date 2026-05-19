package com.yjkj.chainup.securityVerifyRule;

import android.text.TextUtils;

import com.chainup.kit.dialog.security.KKSecurityEnum;
import com.chainup.kit.dialog.security.KKSecurityRule;
import com.yjkj.chainup.db.service.UserDataService;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

/**
 *  ex: 【只取其一】
 *  1. 设置资金密码
 2. 修改资金密码
 3. 忘了密码后新设
 1. Set a fund password 2. Change the fund password 3. I forgot my password and set it up

 *  A. 先校验是否绑定谷歌，已绑定谷歌，则展示谷歌验证码验证；
 B. 未绑定谷歌，校验是否绑定手机号，已绑定手机，则展示短信验证码验证；
 C. 未绑定谷歌和手机，则展示邮箱验证码验证。
 A. Verify whether it is bound to Google, and if it is bound to Google, the Google verification code will be displayed.
 B. If Google is not bound, verify whether the mobile phone number is bound and the mobile phone is bound, the SMS verification code will be displayed.
 C. If Google and mobile phone are not bound, the email verification code verification will be displayed.
 * */
public class VerifyRule1 implements KKSecurityRule {
    List<KKSecurityEnum> entryList;
    @Override
    public Collection<KKSecurityEnum> makeRule() {
        entryList = new ArrayList<>();
        if (UserDataService.getInstance().getGoogleStatus() == 1) {
            entryList.add(KKSecurityEnum.GA);
        } else if (UserDataService.getInstance().getIsOpenMobileCheck() == 1) {
            entryList.add(KKSecurityEnum.PHONE);
        } else if (!TextUtils.isEmpty(UserDataService.getInstance().getEmail())) {
            entryList.add(KKSecurityEnum.EMAIL);
        }
        return entryList;
    }
}
