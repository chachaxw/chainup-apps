//
//  EXPosProjectDetailVM.swift
//  Chainup
//
//  Created by lcus on 2023/10/11.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import EXKit
enum DetailCellConfig:String {
    
    case coinInfo = "coinInfo"
    case projectInfo = "projectInfo"
    case header = "header"
    case NumberLock = "NumberLock"
    case incomeTitle = "incomeTitle"
    case setp = "setp"
    case income = "income"
    case empty = "empty"
    case progress = "progress"
    case calculation = "calculation"
    case willicome = "willicome"
}
let cellKey = "cellKey"

class EXPosProjectDetailVM: NSObject {


    
    typealias dataCallBack = (_ enity:EXBaseModel)->()
    typealias resultCallBack = ()->()
    let disposBag = DisposeBag()
    
    func getProjectInfo(projectId:String,MapType:EXBaseModel.Type,callBack:@escaping dataCallBack){
        
        appApi.rx.request(.freeStaking_projectInfo(pojectId: projectId)).MJObjectMap(MapType).subscribe(onSuccess: { (enity) in
            
            callBack(enity)
           
        }).disposed(by: disposBag)
    }
    func incrementApply(callBcak:@escaping resultCallBack)  {
        
        
        let inputValue = EXPosDetailServer.sharedInstance.inputValue
        let projectID = EXPosDetailServer.sharedInstance.projectId
        if let value = inputValue {
            
            appApi.rx.request(.freeStaking_incrementapply(amount: value, projectId: projectID)).MJObjectMap(CommonStringModel.self).subscribe(onSuccess: { (enity) in
                
                callBcak()
                
            }).disposed(by: disposBag)
        
        }
        
    }
    
    
    
    func packgeCellData(enity:EXPosDetailPostionEnity) -> [[String:String]] {
        
        
    
        var toutuls = [
            ["cellKey":"coinInfo"],
            ["cellKey":"projectInfo"],
            ["cellKey":"header","title":"pos_string_process".localized()],
            ["cellKey":"NumberLock"],
            
        ]
        if XUserDefault.getToken() == nil { return toutuls }
        
        toutuls.append( ["cellKey":"header","title":LanguageTools.getString(key: "pos_string_earnDetail"),"actionName":LanguageTools.getString(key: "common_action_sendall")])
        
    
        if enity.userGainList.count > 0 {
            
            toutuls.append(["cellKey":"incomeTitle","title":LanguageTools.getString(key: "pos_string_timeEarn"),"tail":LanguageTools.getString(key: "pos_string_earnNumber")])
            //Display up to 5 items
            let count = enity.userGainList.count > 5 ? 5 : enity.userGainList.count
            
            for index in 0..<count {
                
                let item = enity.userGainList[index]
                
                 toutuls.append(["cellKey":"income","amount":item.gainAmount,"time":item.timeShow])
            }
            
        }else{
            
            toutuls.append(["cellKey":"empty"])
        }
        
        return toutuls
    }
    
    
    func packageProtocolCellData(enity:EXPosDetailProtocolEnity) ->[[String:String]] {
        
        
        
        var toutuls = [
            ["cellKey":"coinInfo"],
            ["cellKey":"projectInfo"],
            ["cellKey":"header","title":"pos_string_process".localized()],
            ["cellKey":"setp"],
            ["cellKey":"progress"],
           
        ]
        
        switch enity.activeStatus {
        case 1:
            
            if XUserDefault.getToken() == nil{
                
                toutuls.append(["cellKey":"NumberLock","title":"pos_state_locked".localized(),"type":"lock"])
                toutuls.append(["cellKey":"calculation"])
                
            }else {
                toutuls.append(["cellKey":"NumberLock","title":"pos_state_locked".localized(),"type":"lock"])
                if enity.isShowBuy == 1 {
                    
                    toutuls.append(["cellKey":"calculation"])
                }
            }
            toutuls.append( ["cellKey":"willicome"])
            
        case 2,6:
           
             toutuls.append(["cellKey":"NumberLock","title":"pos_state_locked".localized(),"type":"lock"])
             toutuls.append( ["cellKey":"willicome"])
            
        case 3,4,5:
            
            toutuls.append(["cellKey":"NumberLock","title":"pos_state_locked".localized(),"sectitle":LanguageTools.getString(key: "pos_string_allEarn"),"type":"lock"])
            toutuls.append(["cellKey":"NumberLock","title":"pos_string_myEarn".localized(),"type":"earn"])
            if XUserDefault.getToken() == nil {
                
            }else{
               
                  toutuls.append( ["cellKey":"header","title":LanguageTools.getString(key: "pos_string_earnDetail"),"actionName":LanguageTools.getString(key: "common_action_sendall")])
                
                
                if enity.userGainList.count > 0 {
 
                    
                     toutuls.append(["cellKey":"incomeTitle","title":LanguageTools.getString(key: "pos_string_timeEarn"),"tail":LanguageTools.getString(key: "pos_string_earnNumber")])
                    let count = enity.userGainList.count > 5 ? 5 : enity.userGainList.count
                    
                    for index in 0..<count {
                        
                        let item = enity.userGainList[index]
                        
                        toutuls.append(["cellKey":"income","amount":item.gainAmount,"time":item.timeShow])
                    }
                }else {
                    
                    
                    toutuls.append(["cellKey":"empty"])
                    
                }
                
            }

            
        default:
            break
        }
        
        return toutuls
}
    
    
    
    
}

