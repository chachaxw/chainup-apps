//
//  EXDepthEntity.swift
//  Chainup
//
//  Created by zewu wang on 2023/4/3.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXDepthEntity: NSObject {
    
    var price = "--"
    
    var num = "--"
    
    var depth : CGFloat = 0
    
    var pankou = "1"
    
    var color = UIColor.ThemeLabel.colorMedium
    var showOrder:Bool = false
    
    func setEntity(_ xprice : Any ,
                   xnum : Any ,
                   color : UIColor,
                   depthSum : Double ,
                   entityDepth : Int,
                   baseWidth:CGFloat = 0.0,
                   orderAry:[String] = [],
                   type: TransactionPankouType = .defaultPan,
                   volDecimal: Int = 4){
        var orderPrices = [String]()
        if type == .buy { //Round Down
            orderPrices = orderAry.map({
                let new = $0.newNumberFormat(entityDepth,holdZero: true)
//Print (". buy=round down= ($0) keep  (entityDepth) after= (new)")
                return new
            })
           // price = String.init(format: "%.\(entityDepth)f",BasicParameter.handleDouble(xprice))
        }else if type == .sell{ //Round Up
            orderPrices = orderAry.map({
                let new = $0.newNumberFormat(entityDepth,rownDown: false, holdZero: true)
//Print (". sell=round up= ($0) keep  (entityDepth) after= (new)")
                return new
            })
        }else{
            orderPrices = orderAry.map({return String.init(format: "%.\(entityDepth)f",NumberHandler.handleDouble($0))})

        }
        price = String.init(format: "%.\(entityDepth)f",NumberHandler.handleDouble(xprice))
        num = String(describing: xnum)
        num = NumberHandler.dealPanKouVolume(num, precision: volDecimal)
        self.color = color
        if baseWidth > 0 {
            depth = baseWidth * CGFloat(NumberHandler.handleDouble(xnum) / depthSum)
        }else {
            depth = (SCREEN_WIDTH / 2) * CGFloat(NumberHandler.handleDouble(xnum) / depthSum)
        }
        if orderPrices.contains(price) {
            showOrder = true
        }else {
            showOrder = false
        }
        
    }
    
}

class EXETFModel : EXBaseModel {
    var faqUrl = ""
    var domainName = ""
}


class EXETFNetValueModel : EXBaseModel {
    var marketName = "" //Market name (eg. ETH3S-USDT)
    var price = "--" //net worth
    var realLeverValue = "--" //Actual value leverage ratio
    var maxLeverValue = "--"  //Maximum value leverage ratio
}




