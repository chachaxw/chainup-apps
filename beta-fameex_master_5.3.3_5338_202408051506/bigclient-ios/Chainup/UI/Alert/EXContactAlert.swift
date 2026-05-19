//
//  EXContractAlert.swift
//  Chainup
//
//  Created by liuxuan on 2023/7/11.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXContactAlert: NibBaseView {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var contractPhone: EXContactRowView!
    @IBOutlet var contractEmail: EXContactRowView!
    @IBOutlet var cancelBtn: UIButton!
    
    @IBOutlet weak var containerBg: UIStackView!
    override func onCreate() {
        self.backgroundColor = .Ex.fill6
        self.containerBg.backgroundColor = .Ex.fill6
        self.contractPhone.backgroundColor = .Ex.fill6
        self.contractEmail.backgroundColor = .Ex.fill6
        titleLabel.text = "common_text_contactTitle".localized()
        titleLabel.font = UIFont.ThemeFont.HeadBold
        titleLabel.textColor = UIColor.ThemeLabel.colorLite
        
        cancelBtn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
        cancelBtn.setTitle("common_text_btnCancel".localized(), for: .normal)
    }
    
    func configAlert(phoneNumber:String,mail:String) {
        if phoneNumber.isEmpty {
            contractPhone.isHidden = true
        }else {
            contractPhone.isHidden = false
            let modelPhone = EXRowModel()
            modelPhone.title = "personal_text_phoneNumber".localized()
            modelPhone.action = phoneNumber
            modelPhone.actionColor = UIColor.ThemeLabel.colorHighlight
            modelPhone.actionFont = self.themeHNFont(size: 14)
            let trimmedPhoneNumber = phoneNumber.replacingOccurrences(of:" ", with:"")
            contractPhone.actionCallback = {[weak self] in
                self?.callPhone(number:trimmedPhoneNumber)
            }
            contractPhone.configRows(modelPhone)
        }
        
        if mail.isEmpty {
            contractEmail.isHidden = true
        }else {
            contractEmail.isHidden = false
            let modelEmail = EXRowModel()
            modelEmail.title = "register_text_mail".localized()
            modelEmail.action = mail
            modelEmail.actionColor = UIColor.ThemeLabel.colorLite
            modelEmail.actionFont = self.themeHNFont(size: 14)
            contractEmail.configRows(modelEmail)
     
        }
    }
    
    func callPhone(number:String) {
        guard let num = URL(string: "tel://" + number) else { return }
        UIApplication.shared.open(num, options: [:], completionHandler: nil)
    }

    @IBAction func cancelAlert(_ sender: Any) {
        EXAlert.dismiss()
    }
}
