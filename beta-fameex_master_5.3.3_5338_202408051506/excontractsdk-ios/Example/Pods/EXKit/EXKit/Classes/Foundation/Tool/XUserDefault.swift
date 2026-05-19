//
//  XUserDefault.swift
//  Pods
//
//  Created by zq on 2023/3/28.
//

import Foundation

public class XUserDefault: NSObject {

    //设置并同步
    public class func setValueForKey(_ value : Any? , key : String){
        if value == nil || value is NSNull{//容错
            return
        }
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    //获取，如没有返回空字符串
    public class func getVauleForKey(key : String) -> Any{
        return UserDefaults.standard.object(forKey: key) ?? ""
    }
    
    //移除
    public class func removeKey(key : String){
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
    //清楚本地的合约语言包
    public class func clearLocalLanguageDefaultsData(){
        let userDefaults = UserDefaults.standard
        let list = userDefaults.dictionaryRepresentation()
        for dic in list {
            let key = dic.key
            let prefix = "dl_"
            if key.starts(with: prefix){
                userDefaults.removeObject(forKey: key)
                userDefaults.synchronize()
            }
        }
    }
}
