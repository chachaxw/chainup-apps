//
//  EXContractMarketReqVm.swift
//  Chainup
//
//  Created by cwd on 2023/5/18.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public class EXContractMarketReqVm: NSObject {
    
    var currentReviewData:[String:Any] = [:]
    let disposeBag = DisposeBag()
    var rx_wsReviewData = BehaviorRelay<[String:Any]>(value:[:])
    var wsReviewData :[String:Any] {
        get {
            return rx_wsReviewData.value
        }
        set {
            rx_wsReviewData.accept(newValue)
        }
    }
    private static var _sharedInstance:EXContractMarketReqVm?
    //销毁单例对象 English: Destroy singleton objects
    class func destroy() {
        _sharedInstance = nil
    }
    
    static let `manager` = EXContractMarketReqVm()

    open class func shared() -> EXContractMarketReqVm {
        guard let instance = _sharedInstance else {
            _sharedInstance = EXContractMarketReqVm()
            return _sharedInstance!
        }
        return instance
    }
    
    public func registerPubLicInfoSignal() {
//        //print("进入publicInfoSignal") English: Print ("Enter publicInfoSignal")
        self.fetchReqV2()
    }
    
    func retryFetchReqV2() {
        fetchReqV2()
    }
    
    private func fetchReqV2() {
        if self.wsReviewData.count > 0 {
            return
        }
        
        do {
            var json:[String:Any] = [:]
            let cid = "" //EXSwapPrivateConfig.shared.companyId
            if cid.isEmpty {
                json = ["event":"req","params":["channel":"review"]]
            }else {
                json = ["event":"req","params":["channel":"review","cid":cid]]
            }
            let jsonData = try JSONSerialization.data(withJSONObject:json, options: JSONSerialization.WritingOptions.prettyPrinted)
            if let jsonStr = String.init(data: jsonData, encoding: String.Encoding.utf8) {
                EXSwapSocketManager.shared.addwsTaskReq(task: jsonStr)
            }
        } catch _ {
            
        }
    }
}

