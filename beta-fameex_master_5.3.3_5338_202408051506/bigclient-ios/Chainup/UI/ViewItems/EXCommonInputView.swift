//
//  EXCommonInputView.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/16.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXCommonInputView: NibBaseView {

    @IBOutlet var input: EXTextField!
    
    func disableTouch() {
        input.isUserInteractionEnabled = false
    }

    override func onCreate() {
        input.enableTitleModel = true
    }
    
    func setTitle(_ text:String) {
        input.setTitle(title: text)
    }
    
    func setContent(_ content:String) {
        input.setText(text:content)
    }
    
    func setPlaceHolder(_ placeHoloder:String ) {
        input.setPlaceHolder(placeHolder: placeHoloder)
    }
    
}
