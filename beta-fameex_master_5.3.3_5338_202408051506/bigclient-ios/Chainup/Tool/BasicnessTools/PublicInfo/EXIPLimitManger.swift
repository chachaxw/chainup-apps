//
//  EXIPLimitManger.swift
//  Chainup
//
//  Created by 柴伟东 on 2023/10/12.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import RxSwift
class EXIPLimitManger {
    let disposeBag = DisposeBag()
    var alertShow: Bool = false //It has already been displayed
    static let shared: EXIPLimitManger = {
        return EXIPLimitManger()
    }()

    func work(){
        let timer = Observable<Int>.interval(.seconds(5), scheduler: MainScheduler.instance)
        timer.subscribe { [weak self] num in
            print(num)
            self?.ipLimitRequest()
        }.disposed(by: disposeBag)
    }
    
    private func ipLimitRequest(){
        appApi.hideAutoLoading()
        appApi.rx.request(.limit_ip_login)
            .MJObjectMap(EXVoidModel.self,false)
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func limitAlertShow(result: [String: Any]){
        if let msg = result["msg"] as? String {
            if self.alertShow {
                return
            }
            self.alertShow = true
            self.alert(msg: msg)
        }
    }
    func alert(msg: String){
        let alert = EXLimitUserAlert()
        alert.setForbidCountry(msg)
        EXAlert.showAlert(alertView: alert, offset: 0)
    }
    //IpRegisterLimit ("109108", "ipRegisterLimit", "IP Restricted Registration"),
    //IpLoginLimit ("109109", "ipLoginLimit", "IP Restricted Login"),
    
}

