//
//  EXTradeAvailableView.swift
//  Chainup
//
//  Created by bradjohn on 2024/1/2.
//  Copyright © 2024 Chainup. All rights reserved.
//

import UIKit
import EXKit

class EXTradeAvailableView: UIView {
    
    var isCanTransfer: Bool = true {
        didSet {
            updateLayou(with: isCanTransfer)
        }
    }
    
    var transferBlock: EXComVoidBlock?
    
    lazy var leftLabel: UILabel = {
        let v = UILabel()
        v.font = .Ex.regular(12)
        v.textColor = .Ex.text2
        v.text = "assets_text_available".localized()
        return v
    }()
    
    lazy var balanceLabel: UILabel = {
        let v = UILabel()
        v.font = .Ex.regular(12)
        v.textColor = .Ex.text1
        v.text = "--"
        return v
    }()
    
    lazy var transferBtn:UIButton = {
        let v = UIButton(type: .custom)
        v.setEnlargeEdgeWithTop(6, left: 6, bottom: 6, right: 6)
        v.imageView?.contentMode = .scaleAspectFit
        v.setImage(EXKitBundle.svgImage(named: "public_increase"), for: .normal)
        v.addTarget(self, action: #selector(transferAction), for: .touchUpInside)
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
        addSubViews([leftLabel, balanceLabel, transferBtn])
        leftLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.height.equalToSuperview()
        }
        balanceLabel.snp.makeConstraints { make in
            make.left.greaterThanOrEqualTo(leftLabel.snp.right)
            make.centerY.height.equalToSuperview()
        }
        transferBtn.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.height.equalToSuperview()
            make.left.equalTo(balanceLabel.snp.right).offset(4)
        }
        balanceLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        transferBtn.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
   private func updateLayou(with isCanTransfer: Bool) {
        transferBtn.isHidden = !isCanTransfer
       if isCanTransfer {
           balanceLabel.snp.remakeConstraints { make in
               make.left.greaterThanOrEqualTo(leftLabel.snp.right)
               make.centerY.height.equalToSuperview()
           }
           transferBtn.snp.remakeConstraints { make in
               make.right.equalToSuperview()
               make.centerY.height.equalToSuperview()
               make.left.equalTo(balanceLabel.snp.right).offset(4)
               make.size.equalTo(CGSize(width: 14, height: 14))
           }
        } else {
            balanceLabel.snp.remakeConstraints { make in
                make.left.greaterThanOrEqualTo(leftLabel.snp.right)
                make.centerY.height.equalToSuperview()
                make.right.equalToSuperview()
            }
        }
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

// MARK: -- transferAction
extension EXTradeAvailableView {
    
    @objc func transferAction() {
        self.transferBlock?()
    }
    
}
