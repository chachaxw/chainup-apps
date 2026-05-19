//
//  ContractWs24HourModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/1/24.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class PriceTick:NSObject {
    @objc var amount:String = ""
    @objc var open:String = ""
    @objc var high:String = ""
    @objc var vol:String = ""
    @objc var holdVolume:String = ""
    @objc var holdAmount:String = ""
    @objc var rose:String = ""
    @objc var close:String = ""
    {
        didSet{
            if let rose1 = Float(rose){
                if rose1 >= 0{
                    rose_Color = UIColor.ThemekLine.up
                }else if rose1 < 0{
                    rose_Color = UIColor.ThemekLine.down
                }
            }
        }
    }
    var rose_Color = UIColor.ThemekLine.up
    
}

class ContractWs24HourModel: NSObject {
    @objc var channel:String = ""
    @objc var tick:PriceTick?
}
