//
//  EXTopIconBtn.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/28.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXSCoTopIconBtn: EXSNibBaseView {
    
    @IBOutlet var topIcon: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    lazy var newLabel : UILabel = {
        let object = UILabel.init(text: "NEW", font: UIFont.ThemeFont.MinimumRegular, textColor: UIColor.ThemeLabel.white, alignment: .center)
        object.backgroundColor = UIColor.ThemeLabel.colorHighlight
        object.isHidden = true
        object.extSetCornerRadius(1.5)
        return object
    }()
    typealias TappedGesture = ()->()
    var onTapGesture:TappedGesture?
    
    
    lazy var coverbtn : RepeatButton = {
        let btn = RepeatButton()
        btn.interval = 2
        btn.backgroundColor = .clear
        btn.addTarget(self, action: #selector(clickBtn), for: UIControl.Event.touchUpInside)
        return btn
    }()
    
    
    override func onCreate() {
        self.addSubview(newLabel)
        newLabel.snp.makeConstraints { (make) in
            make.left.equalTo(topIcon.snp.right).offset(-5)
            make.bottom.equalTo(topIcon.snp.top).offset(8)
            make.width.equalTo(30)
            make.height.equalTo(12)
        }
        self.addSubview(coverbtn)
        coverbtn.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @IBAction func tapAction(_ sender: Any) {
        
    }
    
    @objc func clickBtn(){
        self.onTapGesture?()
    }
}
