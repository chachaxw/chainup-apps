//
//  JSONExtension.swift
//  EXKit
//
//  Created by liuxuan on 2022/7/18.
//

import UIKit

public extension JSONSerialization{
    
    //将字典转成json字符串
    class func jsonDataFromDictToString(_ dict : [String : Any]) -> String{
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.prettyPrinted)
            if let jsonStr = String.init(data: jsonData, encoding: String.Encoding.utf8){
                return jsonStr
            }
        }catch _ {
            
        }
        return ""
    }
    
}
