//
//  EXShieldEntity.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/26.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXShieldEntity: EXBaseModel {

    var relationshipList : [EXRelationShip] = []
    
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.relationshipList = EXRelationShip.mj_objectArray(withKeyValuesArray: self.relationshipList).copy() as! [EXRelationShip]
    }
    
}

class EXRelationShip: EXBaseModel {
    
    //     "userId": "10001", //User ID
    //     "otcNickName": "153****6666", //User nickname
    //     "creditGrade": 1, //Credit rating
    //     "completeOrders": 4 //Number of transactions
    
    var userId = ""
    var otcNickName = ""
    var creditGrade = ""
    var completeOrders = ""
    var image = ""
//    override func setEntityWithDict(_ dict: [String : Any]) {
//        super.setEntityWithDict(dict)
//        userId = dictContains("userId")
//        otcNickName = dictContains("otcNickName")
//        creditGrade = dictContains("creditGrade")
//        completeOrders = dictContains("completeOrders")
//        image = dictContains("image")
//    }
}

