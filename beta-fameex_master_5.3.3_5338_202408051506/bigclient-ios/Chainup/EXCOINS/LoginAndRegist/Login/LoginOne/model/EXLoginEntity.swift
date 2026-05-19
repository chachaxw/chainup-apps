//
//  EXLoginEntity.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/19.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXLoginEntity: EXBaseModel {
    var token = ""
    var googleAuth = ""
    var typeList = ""
    var type = ""
    
//    func getSecureTyeps() ->[EXLoginSecureType] {
//        let types:[String] = typeList.components(separatedBy: ",")
//        var secureTypes:[EXLoginSecureType] = []
//        for type in types  {
//            if type == EXLoginSecureType.google.rawValue {
//                secureTypes.append(.google)
//            }else if type == EXLoginSecureType.phone.rawValue {
//                secureTypes.append(.phone)
//            }else if type == EXLoginSecureType.mail.rawValue {
//                secureTypes.append(.mail)
//            }else if type == EXLoginSecureType.idCard.rawValue {
//                secureTypes.append(.idCard)
//            }
//        }
//        return secureTypes
//    }
}
