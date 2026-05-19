//
//  EXAppMailEntity.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/27.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit


@objcMembers class EXAppMailAllEntity : NSObject {
    
    var typeList : [EXMessageTypesEntity] = []
    
    var userMessageList : [EXAppMailEntity] = []
    
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.typeList = EXMessageTypesEntity.mj_objectArray(withKeyValuesArray: self.typeList).copy() as! [EXMessageTypesEntity]
        self.userMessageList = EXAppMailEntity.mj_objectArray(withKeyValuesArray: self.userMessageList).copy() as! [EXAppMailEntity]
    }
}

@objcMembers class EXAppMailEntity: NSObject {

    var ctime = ""//time
    {
        didSet{
            ctime = DateTools.strToTimeString(ctime)
        }
    }
    
    var id = ""//id
    
    var messageContent = ""//Message content
    
    var messageType = ""//Message Type
    
    var messageTitle = ""//title
    
    var receiveUid = ""//Message receiving user
    
    var status = ""//1 unread 2 read
    
}

//MARK: Sidebar
@objcMembers class EXMessageTypesEntity:SuperEntity{
    var tid = ""
    
    var title = ""
}

