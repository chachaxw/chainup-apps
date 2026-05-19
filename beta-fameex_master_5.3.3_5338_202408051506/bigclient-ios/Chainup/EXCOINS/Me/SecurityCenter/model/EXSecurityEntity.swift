//
//  EXSecurityEntity.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/27.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXSecurityEntity: NSObject {

    var name = ""//name
    var desc = ""
    var info = ""//default
    var showUnbind = false
    var switchOn = false
    
    var type: EXSecurityEntityTyep = .phone
}

enum EXSecurityEntityTyep: Int{
    case phone
    case mail
    case gooleAuth
    case loginPassWord
    case moneyPassWord
    case gestureLogin
    case FingerprintOrFaceLogin //Fingerprints or facial features
    case acountDelete
    case whiteList
}
@objcMembers class EXGuestureEntity : NSObject {
    var token = ""//
}

@objcMembers class EXFaceOrTouch: NSObject {
    var isPass = ""//Passed or not
}

