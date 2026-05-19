//
//  OTCTalkEntity.swift
//  Chainup
//
//  Created by zewu wang on 2023/10/18.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import EXKit

//
class OTCTalkEntity: SuperEntity {
    
    var message : [String : Any] = [:]
    
    var from = ""//Send ID
    
    var to = ""//Receive ID
    
    var content = ""//content
    
    var time = ""//time stamp
    
    var orderId = ""//Transaction Order ID
    
    var type = ""//
    
    var chatId = "0"//
    
    var status = ""//
    
    var cellHeight : CGFloat = 0
    
    override func setEntityWithDict(_ dict: [String : Any]) {
        super.setEntityWithDict(dict)
        if let tmpmessage = dict["message"] as? [String : Any] {
            message = tmpmessage
            setEWD(tmpmessage)
        }
        type = dictContains("type")
        chatId = dictContains("chatId")
    }
    
    func setEWD(_ dict : [String : Any]){
        from = dict.keys.contains("from") ? String(describing:dict["from"]!) : ""
        to = dict.keys.contains("to") ? String(describing:dict["to"]!) : ""
        content = dict.keys.contains("content") ? String(describing:dict["content"]!) : ""
        time = dict.keys.contains("time") ? String(describing:dict["time"]!) : ""
        if time.count > 10{
            time = NSString.init(string: time).dividing(by: "1000", decimals: 0)
        }
        time = DateTools.strToTimeString(time)
        orderId = dict.keys.contains("orderId") ? String(describing:dict["orderId"]!) : ""
        setHeight()
    }
    
    func setUserTalkEntity(_ dict : [String : Any]){
        from = dict.keys.contains("fromId") ? String(describing:dict["fromId"]!) : ""
        to = dict.keys.contains("toId") ? String(describing:dict["toId"]!) : ""
        content = dict.keys.contains("content") ? String(describing:dict["content"]!) : ""
        time = dict.keys.contains("ctime") ? String(describing:dict["ctime"]!) : ""
        if time.count > 10{
            time = NSString.init(string: time).dividing(by: "1000", decimals: 0)
        }
        time = DateTools.strToTimeString(time)
        orderId = dict.keys.contains("orderId") ? String(describing:dict["orderId"]!) : ""
        chatId = dict.keys.contains("chatId") ? String(describing:dict["chatId"]!) : ""
        setHeight()
    }
    
    func setHeight(){
        let font = UIFont.ThemeFont.BodyRegular
        let contentHeight =  content.textSizeWithFont(font, width: SCREEN_WIDTH - 120).height
        cellHeight = contentHeight + 54
    }
}

//Off site appeal
class OTCServiceEntity : SuperEntity{
    
    var id = ""//Questioning ID
    
    var rqId = ""//The ID of the question being pursued
    
    var replayContent = ""//Questioning content
    
    var contentType = ""//Type 1 Text 2 Image
    
    var userType = ""//User Type 1 Background 2 Front End
    
    var ctime = ""//time
    
    var cellHeight : CGFloat = 0
    
    override func setEntityWithDict(_ dict: [String : Any]) {
        super.setEntityWithDict(dict)
        id = dictContains("id")
        rqId = dictContains("rqId")
        replayContent = dictContains("replayContent")
        contentType = dictContains("contentType")
        userType = dictContains("userType")
        ctime = dictContains("ctime")
        if ctime.count > 10{
            ctime = NSString.init(string: ctime).dividing(by: "1000", decimals: 0)
        }
        ctime = DateTools.strToTimeString(ctime)
        setHeight()
    }
    
    func setHeight(){
        if contentType == "1"{
            let font = UIFont.ThemeFont.BodyRegular
            let contentHeight =  replayContent.textSizeWithFont(font, width: SCREEN_WIDTH - 120).height
            cellHeight = contentHeight + 54
        }else{
            cellHeight = 148
        }
    }
    
}

