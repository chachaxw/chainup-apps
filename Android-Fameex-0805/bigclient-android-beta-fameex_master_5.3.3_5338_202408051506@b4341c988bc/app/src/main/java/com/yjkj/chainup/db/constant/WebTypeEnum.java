package com.yjkj.chainup.db.constant;

/**
 *@description: web type
 * @Author: wanghao
 * @CreateDate: 2019-10-28 20:20
 * @UpdateUser: wanghao
 * @UpdateDate 2023-10-28 20:20
 *@ UpdateRemark: Update Description
 */
public enum WebTypeEnum {

    COMMON_WEB("默认web(完整链接)",0), //Default
    HELP_CENTER("帮助中心",1),
    Notice("公告/通知",2),
    ROLE_INDEX("",3),
    NORMAL_INDEX("",4),
    SING_PASS("",5),
    HTML_INDEX("",6),
    CONTRACT_ASSETS_PROFIT("合约资产收益h5",7),
    AGREEMENT_USER("user agreement",8);


    private String name;
    private int value;
    private WebTypeEnum(String name,int value){
        this.name = name;
        this.value = value;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getValue() {
        return value;
    }

    public void setValue(int value) {
        this.value = value;
    }
}
