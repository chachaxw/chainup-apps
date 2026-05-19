//
//  RegionVM.swift
//  Chainup
//
//  Created by zewu wang on 2018/8/17.
//  Copyright © 2018年 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import Alamofire

class RegionVM: NSObject {
    
    weak var vc : RegionVC?
    
    func setVC(_ vc : RegionVC){
        self.vc = vc
    }
    
    var arr : [String:[RegionEntity]] = [:]
    
}

//network
extension RegionVM{
    
    func getRegionInfo() -> Observable<[RegionEntity]>{
        
        return Observable.create({ (observer) -> Disposable in
            let time = DateTools.getNowTimeInterval()
            let sign = NetManager.sharedInstance.dealSign(["time" : time])
            let url = NetManager.sharedInstance.url(NetDefine.http_host_url, model: NetDefine.common, action: NetDefine.get_country_info) + "?time=\(time)&sign=\(sign)"
            NetManager.sharedInstance.sendRequest(url, parameters: [:],mothed: .get,encoding : URLEncoding.httpBody, success: { (result, response, entity) in
                var array : [RegionEntity] = []
                if let tmpreslut = result as? [String : Any]{
                    if let data = tmpreslut["data"] as? [String : Any] , let countryList = data["countryList"] as? [[String : Any]]{
                        for item in countryList{
                            let entity = RegionEntity()
                            entity.setEntityWithDict(item)
                            array.append(entity)
                        }
                    }
                }
                
                if self.vc?.choose == true{
                    let entity = RegionEntity()
                    entity.enName = "@"
                    entity.cnName = "@"
                    array.append(entity)
                }
                
                observer.onNext(array)
                observer.onCompleted()
            }, fail: { (state, error , any) in
                observer.onError(error!)
            })
            return Disposables.create()
        })
    }
    
}

//local
extension RegionVM{
    
    //Chinese sorting
    func zh_nameTransForm(_ array : [RegionEntity]) -> [String:[RegionEntity]]{
        for item in array{
            let pinyin = self.transform(item.cnName)
            var type = ""
            if pinyin.count > 0{
                type = pinyin.first!.description
                if type >= "@" && type <= "Z"{
                    self.keyArray(type ,item:item)
                }
            }
        }
        return arr
    }
    
    func keyArray(_ str : String , item : RegionEntity){
        
        if arr[str] != nil{
            arr[str]?.append(item)
        }else{
            let array : [RegionEntity] = []
            arr[str] = array
            arr[str]?.append(item)
        }
    }
    
    func transform(_ chinese : String) -> String{
        let pinyin = NSMutableString.init(string: chinese)
        CFStringTransform(pinyin as CFMutableString, nil, kCFStringTransformMandarinLatin, false)
        CFStringTransform(pinyin as CFMutableString, nil, kCFStringTransformStripCombiningMarks, false)
        return pinyin.uppercased
    }
    
    //English sorting
    func us_nameTransForm(_ array : [RegionEntity]) -> [String:[RegionEntity]]{
        for item in array{
            let pinyin = self.transform(item.enName)
            var type = ""
            if pinyin.count > 0{
                type = pinyin.first!.description
                if type >= "@" && type <= "Z"{
                    self.keyArray(type ,item:item)
                }
            }
        }
        return arr
    }
    
}

