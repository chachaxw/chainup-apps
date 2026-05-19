//
//  EXLeverTradeTopBar.swift
//  Chainup
//
//  Created by liuxuan on 2023/11/23.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
class EXLeverTradeTopBar: UIView {
    
    typealias TopBarTapAction = ()->()
    var tappedCallback:TopBarTapAction?
    
    var contentInsets: UIEdgeInsets = .init(top: 6, left: 8, bottom: 6, right: 8) {
        didSet {
            guard contentView.superview != nil else { return }
            contentView.snp.updateConstraints { $0.edges.equalToSuperview().inset(contentInsets) }
        }
    }
    
    lazy var contentView:UIView = {
        let v = UIView()
        return v
    }()
    
    lazy var riskRateV:LeverMenuItem = {
        let rsk = LeverMenuItem()
        rsk.titleLabel.text = "leverage_risk".localized().replacingOccurrences(of: "%", with: "")
        rsk.menuIcon.setImage(UIImage.themeImageNamed(imageName: "public_hint").reSizeImage(reSize: CGSize(width: 10, height: 10)), for: .normal)
        rsk.bgTapBtn.addTarget(self, action: #selector(onClickMenuItem), for: .touchUpInside)
        return rsk
    }()
    
    lazy var loseCutV:LeverMenuItem = {
        let lc = LeverMenuItem()
        lc.titleLabel.text = "leverage_text_blowingUp".localized()
        lc.menuIcon.setImage(EXKitBundle.image(named: "public_arrow_down")?.reSizeImage(reSize: .init(width: 10, height: 10)), for: .normal)
        lc.bgTapBtn.addTarget(self, action: #selector(onClickMenuItem), for: .touchUpInside)
        return lc
    }()
    

    lazy var loanBtn:UIButton = {
        let loanTitle = "leverage_borrow".localized() + "/" + "leverage_return".localized()
        let loan = UIButton()
        loan.setTitleColor(UIColor.Ex.main4, for: .normal)
        loan.titleLabel?.font = UIFont.ThemeFont.SecondaryRegular
        loan.setTitle(loanTitle, for: .normal)
        loan.setTitleColor(UIColor.ThemeView.highlight, for: .normal)
        loan.addTarget(self, action: #selector(onClickMenuItem), for: .touchUpInside)

        return loan
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .Ex.fill3
        extSetCornerRadius(4)
        addSubview(contentView)
        contentView.addSubViews([riskRateV,loseCutV,loanBtn])
        contentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(contentInsets)
        }
        
        riskRateV.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(30)
        }
        
        loseCutV.snp.makeConstraints { (make) in
            make.left.greaterThanOrEqualTo(riskRateV.snp.right).offset(4)
            make.centerX.equalToSuperview().priority(.medium)
            make.centerY.equalToSuperview()
            make.height.equalTo(riskRateV.snp.height)
        }
        
        loanBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(loseCutV)
        }
        
        riskRateV.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        loseCutV.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        loanBtn.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    
    @objc func onClickMenuItem() {
        self.tappedCallback?()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class LeverMenuItem:UIView {
    
    lazy var titleLabel:UILabel = {
        let title = UILabel()
        title.font = UIFont.ThemeFont.SecondaryRegular
        title.textColor = UIColor.ThemeLabel.colorMedium
        return title
    }()
    
    lazy var valueLabel:UILabel = {
        let title = UILabel()
        title.font = UIFont.ThemeFont.SecondaryRegular
        title.textColor = UIColor.ThemeLabel.colorLite
        title.lineBreakMode = .byTruncatingTail
        title.text = "--"
        return title
    }()
    
    lazy var bgTapBtn:UIButton = {
        let icon = UIButton.init(type: .custom)
        return icon
    }()
    
    lazy var menuIcon:UIButton = {
        let icon = UIButton.init(type: .custom)
        icon.isUserInteractionEnabled = false 
        return icon
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubViews([titleLabel,valueLabel,bgTapBtn,menuIcon])
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        valueLabel.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel.snp.right).offset(2)
            make.centerY.equalToSuperview()
        }
        
        bgTapBtn.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        menuIcon.snp.makeConstraints { (make) in
            make.width.height.equalTo(12)
            make.left.equalTo(valueLabel.snp.right).offset(2)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        valueLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        menuIcon.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
