package com.yjkj.chainup.db.constant;

import android.content.Context;

import com.yjkj.chainup.manager.LanguageUtil;

public enum KycRequirements {
    APPLICANT_DATA("Applicant data","申请人资料","kyc_page_require_basicinfo"),
    IDENTITY_DOCUMENT("Identity Document","身份证件","kyc_page_require_identity"),
    SELFIE("Selfie","自拍","kyc_page_require_selfie"),
    TWO_SELFIE("2nd selfie","第二张自拍","kyc_page_require_selfie2"),
    PROOF_OF_RESIDENCE("Proof of residence","居住证明","kyc_page_require_address"),
    TWO_PROOF_OF_RESIDENCE("2nd proof of residence","第二份居住证明","kyc_page_require_address2"),
    QUESTIONNAIRE("Questionnaire","问卷","kyc_page_require_questionnaires"),
    PHONE_VERIFICATION("Phone verification","电话验证","kyc_page_require_phone"),
    EMAIL_VERIFICATION("Email verification","电子邮件验证","kyc_page_require_email"),
    FACE_RECOGNITION("Face recognition","人脸识别","kyc_page_require_facial"),
    REGISTRATION_SUCCESSFUL("Registration successful","注册成功","kyc_page_require_unverified");

    private String id;
    private String decription;
    private String other;

    KycRequirements(String id,String decription,String other){
        this.id = id;
        this.decription = decription;
        this.other = other;
    }

    public String getDecription() {
        return decription;
    }

    public String getId() {
        return id;
    }

    public String getOther() {
        return other;
    }

    public String getText(Context context){
        return LanguageUtil.getString(context,other);
    }

}
