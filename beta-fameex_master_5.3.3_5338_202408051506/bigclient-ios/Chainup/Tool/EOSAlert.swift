//
//  EOSAlert.swift
//  Chainup
//
//  Created by xue on 2023/11/19.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EOSAlert: UIView {

    @IBOutlet weak var contentL: UILabel!
    @IBOutlet weak var cancel: CMLocalizedButton!
    static func newInstance() -> EOSAlert?{
        let nibView = Bundle.main.loadNibNamed("EOSAlert", owner: nil, options: nil)
        if let view = nibView?.first as? EOSAlert {

            let text = LanguageTools.getString(key: "eos_tips")
            let attributeText = NSMutableAttributedString.init(string: text)
            let count = text.ch_length
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 5
            attributeText.addAttributes([kCTFontAttributeName as NSAttributedString.Key: UIFont.systemFont(ofSize: 16)], range: NSMakeRange(0, count))
            attributeText.addAttributes([NSAttributedString.Key.foregroundColor as NSAttributedString.Key: UIColor.ThemeLabel.colorMedium], range: NSMakeRange(0, count))
            

            view.contentL.attributedText = attributeText
        
            return view
        }
        
        return nil
    }
    
    @IBAction func clickCancel(_ sender: UIButton) {
        self.removeFromSuperview()

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.removeFromSuperview()
    }
}
