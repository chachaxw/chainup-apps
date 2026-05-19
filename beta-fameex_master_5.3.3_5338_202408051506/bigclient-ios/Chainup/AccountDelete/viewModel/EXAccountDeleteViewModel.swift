//
//  EXAccountDeleteViewModel.swift
//  Chainup
//
//  Created by cwd on 2023/2/8.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import RxSwift
import EXKit

class EXAccountDeleteViewModel: EXViewModel {
    let disposeBag = DisposeBag()
    var result = EXDeleteAccountResult()
    var open = EXDeleteAccountOpenResult()
    func getCancelVerfication(success: @escaping EXComVoidBlock,errorBlock: @escaping EXComVoidBlock){        
        appApi.rx.request(.cancellationVerification)
            .customObjectMap(EXDeleteAccountResult.self,false)
            .subscribe(onSuccess: {[weak self] (entity) in
                guard let mySelf = self else{return}
                mySelf.result = entity
                success()
            }) { [weak self] (error) in
                errorBlock()
        }.disposed(by: disposeBag)
    }
    
    func queryOpenDeleteAccount(success: @escaping EXComVoidBlock,errorBlock: @escaping EXComVoidBlock){
        
        appApi.hideAutoLoading()
        appApi.rx.request(.getDeleteAccountStatus)
            .customObjectMap(EXDeleteAccountOpenResult.self,false)
            .subscribe(onSuccess: {[weak self] (entity) in
                guard let mySelf = self else{return}
                mySelf.open = entity
                success()
            }) { [weak self] (error) in
                guard let mySelf = self else{return}
                errorBlock()
        }.disposed(by: disposeBag)
    }
    
    func deleteAccountRequset(smsAuthCode:String?,emailAuthCode:String?,googleCode: String?, success: @escaping EXComVoidBlock,errorBlock: @escaping EXComVoidBlock,  successMsg: @escaping EXComStringBlock){
        
        appApi.hideAutoLoading()
        appApi.rx.request(.deleteAccount(smsAuthCode: smsAuthCode, emailAuthCode: emailAuthCode, googleCode: googleCode))
            .MJObjectMap(EXVoidModel.self,successMsg: { str in
                successMsg(str)
            })
            .subscribe(onSuccess: {(entity) in
                success()
            }) { (error) in
                errorBlock()
        }.disposed(by: disposeBag)
    }
    
}
