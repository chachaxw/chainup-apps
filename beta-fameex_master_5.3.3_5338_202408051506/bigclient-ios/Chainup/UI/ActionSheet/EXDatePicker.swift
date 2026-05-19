//
//  EXDatePicker.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/11.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXDatePicker: NibBaseView {

    @IBOutlet var cancelBtn: UIButton!
    @IBOutlet var confirmBtn: UIButton!
    @IBOutlet var datePickerView: UIDatePicker!
    typealias DateConfirmedBlock = (Date) -> ()
    var dateConfirmCallback : DateConfirmedBlock?
    typealias DateCanceledBlock = () -> ()
    var dateCancelCallback : DateCanceledBlock?
    @IBOutlet var iphonexBottom: NSLayoutConstraint!
    
    override func onCreate() {
        backgroundColor = .ThemeView.bg
    
        datePickerView.locale = Locale(identifier: LanguageTools.getPhoneLanguage(ignoreServer: true))

        datePickerView.tintColor = UIColor.ThemeLabel.colorLite
        if #available(iOS 13.4, *) {
            datePickerView.locale =  Locale(identifier: LanguageTools.getPhoneLanguage(ignoreServer: true))
            datePickerView.preferredDatePickerStyle = .wheels
            datePickerView.setValue(UIColor.ThemeLabel.colorLite, forKeyPath: "textColor")
        } else {
            // Fallback on earlier versions
            datePickerView.setValue(false, forKeyPath: "highlightsToday")
        }
        cancelBtn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
        cancelBtn.setTitle("common_text_btnCancel".localized(), for: .normal)
        confirmBtn.setTitleColor(UIColor.ThemeLabel.colorLite, for: .normal)
        confirmBtn.setTitle("common_text_btnConfirm".localized(), for: .normal)
        iphonexBottom.constant = isiPhoneX ? 34 : 0
    }
    
    func setDatePickerMode(mode:UIDatePicker.Mode) {
        datePickerView.datePickerMode = mode
    }
    
    
    @IBAction func btnCancelAction(_ sender: Any) {
        EXAlert.dismiss()
        dateCancelCallback?()
    }
    
    @IBAction func confirmBtnAction(_ sender: Any) {
        EXAlert.dismiss()
        dateConfirmCallback?(datePickerView.date)
    }
    
}
