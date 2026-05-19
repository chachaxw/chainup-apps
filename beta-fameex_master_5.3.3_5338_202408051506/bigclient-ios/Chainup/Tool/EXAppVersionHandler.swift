//
//  EXAppVersionHandler.swift
//  Chainup
//
//  Created by liuxuan on 2022/7/18.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import RxSwift
import EXKit
class EXVersionModel : EXBaseModel{
    var updateVersion = ""
}


class EXAppVersionHandler: NSObject {
    static let dispose = DisposeBag()
    
    //Obtain version number and request publicinfo
    class func getVersionForPublicInfo(){
        
        appApi.hideAutoLoading()
        appApi.rx.request(.getUpdateVersion)
            .MJObjectMap(EXVersionModel.self,false)
            .subscribe(onSuccess: { (model) in
                //Returns false when not saved. The first request for updateversion should not request public again_ Info
                let hasVersion = XUserDefault.getVauleForKey(key: XUserDefault.updateVersion) as? String
                if hasVersion == nil {
                    XUserDefault.setValueForKey(model.updateVersion, key: XUserDefault.updateVersion)
                }else {
                    if XUserDefault.setUpdateVersion(model.updateVersion) == true{
                        EXAppMarketManager.sharedInstance.fetchMarket()
                    }
                }
            }) { (error) in
                
        }.disposed(by: EXAppVersionHandler.dispose)
    }
}

