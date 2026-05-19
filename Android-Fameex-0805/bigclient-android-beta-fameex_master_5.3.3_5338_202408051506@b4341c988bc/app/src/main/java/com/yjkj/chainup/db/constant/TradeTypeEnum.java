package com.yjkj.chainup.db.constant;

/**
 *@description: Transaction Type Enumeration Class
 * @Author: wanghao
 * @CreateDate: 2019-11-14 13:24
 * @UpdateUser: wanghao
 * @UpdateDate 2023-11-14 13:24
 *@ UpdateRemark: Update Description
 */
public enum TradeTypeEnum {


    COIN_TRADE("现货交易",0), //Default
    CONTRACT_TRADE("合约交易",1),
    LEVER_TRADE("杠杆交易",2),
    GRID_TRADE("网格交易",3);

    private String name;
    private int value;

    TradeTypeEnum(String name,int value){
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
