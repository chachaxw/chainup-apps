//
//  EXAppealReasonItem.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/16.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXAppealReasonItem: UIView {
    
    typealias ReasonValueChanged = (Bool) -> ()
    
    var reasonCallback : ReasonValueChanged?
    
    lazy var checkbox: EXCheckBox = {
        let v = EXCheckBox()
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        onCreate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onCreate() {
        addSubview(checkbox)
        checkbox.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(32)
        }
        checkbox.checkCallback = {[weak self] checked in
            guard let self else { return }
            self.handleCheck(isCheck: checked)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        return size
    }
    
    func setChecked(checked:Bool) {
        self.checkbox.checked(check: checked)
    }
    
    private func handleCheck(isCheck:Bool) {
        self.reasonCallback?(isCheck)
    }
    
    func setReason(reason:String) {
        checkbox.text(content: reason)
    }
    
    func selectedDesc()->String {
        return checkbox.checkLabel.text ?? ""
    }

}
