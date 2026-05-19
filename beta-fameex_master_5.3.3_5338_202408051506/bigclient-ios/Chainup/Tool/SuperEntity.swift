//
//  SuperEntity.swift
//  AppProject
//
//  Created by zewu wang on 2023/8/1.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit

@objcMembers class EXBaseModel : NSObject{

}

@objcMembers class SuperEntity: NSObject {
    
    var dict : [String : Any] = [:]//Saved Dictionary
    
    var key : String = ""//Entity key
    
    var value : String = ""//The value of an entity cannot store composite types of data such as arrays, dictionaries, etc
    
/*Incoming dictionary and attributes that need to be protected, with protected attributes in string form*/
    public func setEntitiyWithDict(_ dict : [String : Any] , _ unsafeEntities : [String] = []) {
        setValueOfDict(dict ,unsafeEntities)
    }

    /**
Obtain the attribute value of the object pair, and return NIL for attributes without pairs
-Parameter property: The property to obtain the value from
-Returns: The value of the attribute
     */
    public func getValueOfProperty(property:String)->AnyObject?{
        
        let allPropertys = self.getAllPropertys()
        
        if(allPropertys.contains(property)){
            return self.value(forKey: property) as AnyObject
        }else{
            return nil
        }
        
    }
    
    /**
Set the value of object properties based on dictionary passing
     */
    public func setValueOfDict(_ dict : [String : Any] , _ unsafeEntities : [String] = []){
        let allPropertys = self.getAllPropertys()
        for key in dict.keys{
            if unsafeEntities.contains(key) == false{
                if(allPropertys.contains(key)){
                    if dict[key] != nil && !(dict[key] is NSNull){//Prevent emptiness
                        let valueStr = "\(dict[key]!)"
                        self.setValue(valueStr, forKey: key)
                    }
                }
            }
        }
    }
    
    
    /**
Set the values of object properties
-Parameter property: property
-Parameter value: value
-Returns: Successfully set
     
     */
    public func setValueOfProperty(_ property:String,_ value:Any)->Bool{
        
        let allPropertys = self.getAllPropertys()
        
        if(allPropertys.contains(property)){
            //Preventing crashes
            let valueStr = String(describing: value)
            self.setValue(valueStr, forKey: property)
            return true
        }else{
            return false
        }
    }
    
    /**
Get all property names of an object
-Returns: Attribute name array
     */
    
    public func getAllPropertys()->[String]{
        
        var result = [String]()
        
        let count = UnsafeMutablePointer<UInt32>.allocate(capacity: 0)
        
        guard let buff = class_copyPropertyList(object_getClass(self), count) else{return []}
        
        let countInt = Int(count[0])
        
        for i in 0..<countInt{
            let temp = buff[i]
            let tempPro = property_getName(temp)
            if let proper = String.init(utf8String: tempPro){
                result.append(proper)
            }
        }
        
        return result
    }
    
}

extension SuperEntity{
    
    open func config(_ dic: [String : Any]) {
        self.setValuesForKeys(dic)
    }
    
    override func setValue(_ value: Any?, forKey key: String) {
        if value is NSNull || value == nil {
            
        } else {
            super.setValue(value, forKey: key)
        }
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {

    }
    
}

extension SuperEntity{
    
    func setEntityWithDict(_ dict : [String : Any]){
        self.dict = dict
    }
    
    //MARK: Set attributes
    func dictContains(_ key : String , defaultStr : String = "") -> String{
        var value = ""
        if self.dict.keys.contains(key) &&
            (dict[key] as? NSNull == nil) &&
            (dict[key] as? String ?? "" != "null"){//The server returned a non null type and is not the string 'null' either
            value = String(describing:dict[key] ?? defaultStr)
        }else {
            value = defaultStr
        }
        return value
    }
    
    func getDicWithKeys(_ dict : [String : Any]) -> [String : Any]{
        
        return [:]
    }
    
    //Get the node keys array of the dictionary
//    func getKeysWithDictKeys(_ dict : [String : Any]){
//        for item in dict{
//            if ((item.value as? [String : Any]) == nil){
//                key = item.key
//                NSLog("keykeykeykeykeykeykeykeykeykeykeykey        \(key)")
//                break
//            }
//        }
//    }
    
}

