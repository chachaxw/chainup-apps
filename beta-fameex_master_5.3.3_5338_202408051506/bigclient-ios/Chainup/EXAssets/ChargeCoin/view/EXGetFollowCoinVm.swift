//
//  EXGetFollowCoinVm.swift
//  Chainup
//
//  Created by ljw on 2023/12/23.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
class EXGetFollowCoinVm: NSObject {
    static let shareInstance : EXGetFollowCoinVm = EXGetFollowCoinVm()
    let disposeBag = DisposeBag()
    typealias EXChargeAddressModelCallback = (EXFollowCoinModel?) -> ()
    func getCost(symbol:String,Callback :@escaping EXChargeAddressModelCallback) {
       appApi.rx.request(.getCost(symbol: symbol))
        .MJObjectMap(EXFollowCoinModel.self)
        .subscribe{event in
            switch event {
            case .success(let model):
                Callback(model)
                break
            case .failure(_):
                Callback(nil)
                break
            }
        }.disposed(by: self.disposeBag)
    }
}
