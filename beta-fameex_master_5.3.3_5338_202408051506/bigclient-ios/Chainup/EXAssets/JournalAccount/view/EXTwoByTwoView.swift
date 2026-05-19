//
//  EXTwoByTwoView.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/18.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXTwoByTwoView: NibBaseView {
    @IBOutlet var leftTopLabel: UILabel!
    @IBOutlet var leftBottomLabel: UILabel!
    @IBOutlet var rightTopLabel: UILabel!
    @IBOutlet var rightBottomLabel: UILabel!
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var leftView: UIView!
    
    typealias EXTwoByTwoViewClickBlock = ()->()
    var leftViewClickBlock:EXTwoByTwoViewClickBlock?
    var rightViewClickBlock:EXTwoByTwoViewClickBlock?
    override func onCreate() {
      
    }
    
    func enableLeftRightTaps() {
        let leftTap = UITapGestureRecognizer()
        let rightTap = UITapGestureRecognizer()
        leftTap.rx.event.asObservable().subscribe(onNext: { (recognizer) in
            
            self.leftViewClickBlock?()
        }).disposed(by: disposeBag)
        
        rightTap.rx.event.asObservable().subscribe(onNext: { (recognizer) in
            self.rightViewClickBlock?()
        }).disposed(by: disposeBag)
            
            leftView.addGestureRecognizer(leftTap)
            
            rightView.addGestureRecognizer(rightTap)
    }
    
    func bindModel(_ model:EXTwoByTwoItemModel) {
        leftTopLabel.text = model.ltitle
        leftBottomLabel.text = model.lcontent
        rightTopLabel.text = model.rtitle
        rightBottomLabel.text = model.rcontent
        leftTopLabel.textColor = model.ltitleColor
        leftBottomLabel.textColor = model.lcontentColor
        rightTopLabel.textColor = model.rtitleColor
        rightBottomLabel.textColor = model.rcontentColor
        
        rightTopLabel.textAlignment = model.rightAlignment
        rightBottomLabel.textAlignment = model.rightAlignment
    }
    
    

}
