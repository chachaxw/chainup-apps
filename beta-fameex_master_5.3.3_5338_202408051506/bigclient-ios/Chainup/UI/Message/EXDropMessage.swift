//
//  EXDropMessage.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/9.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit 

class EXDropMessage: NibBaseView {
    
    @IBOutlet private var messageLabel: UILabel!
    @IBOutlet var bgView: UIView!
    
    
    var messageType:DropMessageType = .success {
        didSet {
            switch messageType {
            case .success:
                bgView.backgroundColor = UIColor.ThemeState.normal80
                break
            case .fail:
                bgView.backgroundColor = UIColor.ThemeState.fail80
                break
            case .warning:
                bgView.backgroundColor = UIColor.ThemeState.warning80
                break
            }
        }
    }
    
    var message:String = ""{
        didSet {
            messageLabel.text = message
        }
    }
    
    override func onCreate() {
        
    }
    
}
