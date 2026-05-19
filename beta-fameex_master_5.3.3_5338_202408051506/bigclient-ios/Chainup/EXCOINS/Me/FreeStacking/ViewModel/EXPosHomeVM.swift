//
//  EXPosHomeVM.swift
//  Chainup
//
//  Created by lcus on 2023/10/16.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
class EXPosHomeVM: NSObject {

    let disposBag = DisposeBag()
    
    typealias dataCallBack = (_ enity:EXPosHomeTypesEntity)->()
    
    typealias listDataCallBak = (_ data:[EXPosHomeProjectEntity])->()
    
    
    func loadTypesData(callBack:@escaping dataCallBack)  {
        appApi.rx.request(.freeStaking_index).MJObjectMap(EXPosHomeTypesEntity.self).subscribe(onSuccess: { (enity) in
            
            callBack(enity)

        }).disposed(by: disposBag)
        
    }
    func loadProjectList(listCallBack:@escaping listDataCallBak) {
        
        appApi.rx.request(.freeStaking_projectlist(configType: "", status: "")).MJObjectMap(CommonAryModel.self).subscribe(onSuccess: { (enity) in
            
            if enity.dictAry.count > 0 {

                var listData:[EXPosHomeProjectEntity] = []
                for item in enity.dictAry {
                    if let modeleItem = EXPosHomeProjectEntity.mj_object(withKeyValues: item) {
                        listData.append(modeleItem)
                    }
                }
                listCallBack(listData)
                
            }
            
        }).disposed(by: disposBag)
        
    }
    
    func fitterDatas(list:[EXPosHomeProjectEntity],type:String) -> [EXPosHomeProjectEntity] {
        
        let listData = list.filter{$0.configTypes == type || $0.configTypes.contains(type)}
        
        return listData
        
    }

}
