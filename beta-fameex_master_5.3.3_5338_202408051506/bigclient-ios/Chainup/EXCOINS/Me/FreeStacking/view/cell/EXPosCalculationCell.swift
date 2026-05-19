//
//  EXPosCalculationCell.swift
//  Chainup
//
//  Created by lcus on 2023/10/11.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXPosCalculationCell: UITableViewCell {

    
    var dataEnity:EXPosDetailProtocolEnity?
    
    lazy var textField: EXCoinTextField = {
        let v = EXCoinTextField()
        v.contentView.spacing = 8
        v.topLabel.numberOfLines = 3
        v.topLabel.textColor = .Ex.text2
        v.bottomLabel.textColor = .Ex.text2
        v.topLabel.font = .Ex.regular(12)
        return v
    }()
    
    private var input:UITextField { textField.textField }
    
    let notificationName = Notification.Name(rawValue: "needCaluclation")
    
    func setPorotolCellData(enity:EXPosDetailProtocolEnity) {
        
        textField.topLabel.text = "\("pos_string_lockNumber".localized()):\n(\("pos_string_minLimit".localized()): \(enity.buyAmountMin)\(enity.shortName)\("pos_string_maxlockNumber".localized()):\(enity.buyAmountMax) \(enity.shortName))"
        
         let balance = EXPosDetailServer.sharedInstance.handCoinMonney(coinName: enity.shortName, number: NSNumber(value: enity.balance))
        textField.bottomLabel.text = "\("pos_string_available".localized()) \(balance) \(enity.shortName)"
        self.input.text = nil
        EXPosDetailServer.sharedInstance.inputValue = nil
        self.dataEnity = enity
        
    }
    @objc func textFieldDidChange(){
        
      let detailServer = EXPosDetailServer.sharedInstance
          detailServer.inputValue = input.text
        
        NotificationCenter.default.post(name: notificationName, object: self,
                                        userInfo: ["inputValue":input.text ?? ""])
      
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contentView.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15))
        }
        textField.basicTextField.snp.makeConstraints { $0.height.equalTo(44) }
        textField.placeholder = "pos_string_inputLockNumber".localized()
        self.input.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.allButton.setTitle("pos_string_all".localized(), for: .normal)
        textField.allButton.setTitle("pos_string_all".localized(), for: .selected)
        textField.maxButtonAction = {[weak self] _ in self?.didClickButton() }
    }
    
    @objc func didClickButton(){
    
        self.input.text = "\(self.dataEnity?.balance ?? 0.0)"
        EXPosDetailServer.sharedInstance.inputValue = self.input.text
        if self.input.text != "0.0" {
            
            NotificationCenter.default.post(name: notificationName, object: self,
                                            userInfo: ["inputValue":input.text ?? ""])
        }
    
        
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}


