package com.chainup.contract.ws;

public enum CpwsLinkType {
    REFRESH(0),//refresh after relink
    LINKED(1);//No type relink(normal relink)
    private int type;
    CpwsLinkType(int num){
        this.type = num;
    }

    public int getType() {
        return type;
    }

    @Override
    public String toString() {
        return "CpwsLinkType{" +
                "type=" + type +
                '}';
    }
}
