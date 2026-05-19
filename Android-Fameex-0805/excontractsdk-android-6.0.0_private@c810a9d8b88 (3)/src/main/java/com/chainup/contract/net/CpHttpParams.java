package com.chainup.contract.net;

import java.util.TreeMap;

public class CpHttpParams {

    private TreeMap<String,String> map;

    /**
     *When there are parameters, if you need to define the length, use
     * @param mapLength int
     * @return this
     */
    public static CpHttpParams getInstance(int mapLength){
        return new CpHttpParams(mapLength);
    }

    private CpHttpParams(int mapLength ){
        map = new TreeMap<String,String>();
        map.put("time", String.valueOf(System.currentTimeMillis()));
    }

    public <T> CpHttpParams put(String key, T o){
        map.put(key,o == null ? "" : o.toString());
        return this;
    }

    public TreeMap<String,String> build(){
        return map;
    }

}
