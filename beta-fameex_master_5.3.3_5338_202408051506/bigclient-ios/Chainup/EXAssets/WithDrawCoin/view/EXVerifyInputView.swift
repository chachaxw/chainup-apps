//
//  EXVerifyInputView.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/17.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXVerifyInputView: NibBaseView {
    @IBOutlet var infoTextView: EXTextField!
    var maxLenth = 50
    
    override func onCreate() {
        infoTextView.input.delegate = self
    }
    
    func updateInfo(title:String,placeHolder:String) {
        infoTextView.enableTitleModel = true
        infoTextView.setTitle(title: title)
        infoTextView.setPlaceHolder(placeHolder: placeHolder)
    }
    
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
}

extension EXVerifyInputView : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let nsString = textField.text as NSString?
        let newString = nsString? .replacingCharacters(in: range, with: string)
        if let newStr = newString {
            if newStr.count > maxLenth {
                return false
            }
        }
        return true
    }
}
