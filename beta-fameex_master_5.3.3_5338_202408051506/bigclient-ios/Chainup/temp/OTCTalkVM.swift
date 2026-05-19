//
//  OTCTalkVM.swift
//  Chainup
//
//  Created by zewu wang on 2023/10/23.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift

class OTCTalkVM: NSObject {

}

extension OTCTalkVM{
    
    //Obtain complaint history Chat log
    func getServiceHistoryRecord(_ params : [String : Any]) -> Observable<[String : Any]>{
        
        return Observable.create({ (observer) -> Disposable in
            
            let param = NetManager.sharedInstance.handleParamter(params)
            let url = NetManager.sharedInstance.url(EXNetworkDoctor.sharedManager.getAppAPIHost(), model: NetDefine.question, action: NetDefine.details_problem)

//            let url = NetManager.sharedInstance.url(NetDefine.http_host_url, model: NetDefine.question, action: NetDefine.details_problem)
            NetManager.sharedInstance.sendRequest(url, parameters: param,isShowLoading : false , success: { (result, response, nil) in
                
                if let result = result as? [String : Any]{
                    observer.onNext(result)
                }
                observer.onCompleted()
            }, fail: { (state , error, nil) in
                
            })
            
            return Disposables.create()
        })
        
    }
    
    //Get user history Chat log
    func getsUserHistoryRecord(_ params : [String : Any]) -> Observable<[String : Any]>{
        
        return Observable.create({ (observer) -> Disposable in
            
            let param = NetManager.sharedInstance.handleParamter(params)
            let url = NetManager.sharedInstance.url(EXNetworkDoctor.sharedManager.getOtcAPIHost(), model: NetDefine.chatMsg, action: NetDefine.otcmessage)

//            let url = NetManager.sharedInstance.url(NetDefine.http_host_url_otc, model: NetDefine.chatMsg, action: NetDefine.otcmessage)
            NetManager.sharedInstance.sendRequest(url, parameters: param, success: { (result, response, nil) in
                
                if let result = result as? [String : Any]{
                    observer.onNext(result)
                }
                observer.onCompleted()
            }, fail: { (state , error, nil) in
                
            })
            
            return Disposables.create()
        })
        
    }
    
    //Additional questions
    func replyCreate(_ params : [String : Any]) -> Observable<[String : Any]>{
        
        return Observable.create({ (observer) -> Disposable in
            
            let param = NetManager.sharedInstance.handleParamter(params)
            let url = NetManager.sharedInstance.url(EXNetworkDoctor.sharedManager.getAppAPIHost(), model: NetDefine.question, action: NetDefine.reply_create)

//            let url = NetManager.sharedInstance.url(NetDefine.http_host_url, model: NetDefine.question, action: NetDefine.reply_create)
            NetManager.sharedInstance.sendRequest(url, parameters: param, success: { (result, response, nil) in
                
                if let result = result as? [String : Any]{
                    observer.onNext(result)
                }
                observer.onCompleted()
            }, fail: { (state , error, nil) in
                
            })
            
            return Disposables.create()
        })
        
    }

    
}

