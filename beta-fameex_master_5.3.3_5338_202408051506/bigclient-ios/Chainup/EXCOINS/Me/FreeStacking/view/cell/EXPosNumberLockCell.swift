//
//  EXPosNumberLockCell.swift
//  Chainup
//
//  Created by lcus on 2023/10/11.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXPosNumberLockCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var secTitle: UILabel!
    @IBOutlet weak var numbe: UILabel!
    @IBOutlet weak var unit: UILabel!
    @IBOutlet weak var secNumbe: UILabel!
    @IBOutlet weak var secunit: UILabel!
    
    func setPostionCellData(enity:EXPosDetailPostionEnity)  {
        
//        position
        
        self.title.text = "pos_string_allEarn".localized()
        self.title.numberOfLines = 2
        self.secTitle.text = "pos_string_myEarn".localized() + "pos_string_myEarn".localized()
        self.secTitle.numberOfLines = 2
        self.numbe.text = EXPosDetailServer.sharedInstance.handCoinMonney(coinName: enity.gainCoin, number: NSNumber(value: enity.totalGainAmount))
        self.secNumbe.text = EXPosDetailServer.sharedInstance.handCoinMonney(coinName: enity.gainCoin, number: NSNumber(value: enity.totalUserGainAmount))
        self.unit.text = enity.gainCoin
        self.secunit.text = enity.gainCoin
        
        if XUserDefault.getToken() == nil {
            
            self.numbe.text = "--"
            self.secNumbe.text = "--"
        }
    }
    
    func setProtocol(enity:EXPosDetailProtocolEnity,dataConfig:[String:String])  {
        
//        earn lock
        //Clear second button status
        clearStatus()
        let type = dataConfig["type"]!
        
        switch type {
        case "lock":
             setLockTypeCell(enity: enity, dataConfig: dataConfig)
        case "earn":
             setEarnTypeCell(enity: enity, dataConfig: dataConfig)
        default:
            break
        }
    }
    
   private func setLockTypeCell(enity:EXPosDetailProtocolEnity,dataConfig:[String:String])  {
        //Accumulated distribution of locked warehouse platforms
        self.title.text = dataConfig["title"]
        self.unit.text = enity.shortName
    
        if XUserDefault.getToken() == nil {
            if dataConfig["sectitle"] != nil{
                self.secTitle.text = dataConfig["sectitle"]
                self.secNumbe.text = "--"
                self.secunit.text = enity.gainCoin
            }
            self.numbe.text = "--"
            
        }else {
            if dataConfig["sectitle"] != nil{
                self.secTitle.text = dataConfig["sectitle"]
                self.secNumbe.text = EXPosDetailServer.sharedInstance.handCoinMonney(coinName: enity.gainCoin, number: NSNumber(value: enity.totalGainAmount))
                self.secunit.text = enity.gainCoin
            }
            self.numbe.text = EXPosDetailServer.sharedInstance.handCoinMonney(coinName: enity.gainCoin, number: NSNumber(value: enity.totalAmount))
        }
    }
    
   private func setEarnTypeCell(enity:EXPosDetailProtocolEnity,dataConfig:[String:String]) {
    
        //Obtained
        self.title.text = dataConfig["title"]
        self.unit.text = enity.gainCoin
        if XUserDefault.getToken() == nil {
            self.numbe.text = "--"
        }else {
            
            self.numbe.text = EXPosDetailServer.sharedInstance.handCoinMonney(coinName: enity.gainCoin, number: NSNumber(value: enity.totalUserGainAmount))
        }
    }
    

    
   private func clearStatus()  {
        self.secTitle.text = nil
        self.secNumbe.text = nil
        self.secunit.text = nil
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
         self.selectionStyle = .none
    }

}


