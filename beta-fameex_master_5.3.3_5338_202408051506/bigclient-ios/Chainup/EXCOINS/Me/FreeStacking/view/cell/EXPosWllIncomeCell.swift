//
//  EXPosWllIncomeCell.swift
//  Chainup
//
//  Created by lcus on 2023/10/13.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import EXKit

class EXPosWllIncomeCell: UITableViewCell {

 
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var unit: UILabel!
    @IBOutlet weak var content: UILabel!
    
    var cellEnity :EXPosDetailProtocolEnity = EXPosDetailProtocolEnity()
    func setCelleData(enity:EXPosDetailProtocolEnity) {
        self.cellEnity = enity
        self.title.text = "\(enity.lockDay)\("pos_string_twoDaysEarn".localized())"
        self.unit.text = enity.gainCoin
        if XUserDefault.getToken() == nil{
            self.content.text = "--"
        }else{
            
            self.content.text = countWillIncome(inputValue: 0.0)
        }
    
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let notification = Notification.Name(rawValue: "needCaluclation")
        _ = NotificationCenter.default.rx
        .notification(notification)
        .takeUntil(self.rx.deallocated)
            .subscribe(onNext:{ [weak self] notification in
                
            
                let userInfo = notification.userInfo as! [String:Any]
                
                let value = userInfo["inputValue"] as! String
                
                let valueDouble = Double(value) ?? 0.0
            
                let result = self?.countWillIncome(inputValue: valueDouble)
                
                self?.content.text = result
                
                print("textDidChange", value)
                
            })
        
    }
    
    func countWillIncome(inputValue:Double) -> String {
        
         let days = Double(self.cellEnity.lockDay)
         let rate = self.cellEnity.gainRate
        
         let muti = self.cellEnity.currencyExchangeRate
         let userLoacks = self.cellEnity.totalAmount
        
         let toutualInput = userLoacks + inputValue
        
        
         let result = days * muti * toutualInput * rate / 100 / 365
        
        return EXPosDetailServer.sharedInstance.handCoinMonney(coinName: self.cellEnity.gainCoin, number: NSNumber(value: result))
    

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
