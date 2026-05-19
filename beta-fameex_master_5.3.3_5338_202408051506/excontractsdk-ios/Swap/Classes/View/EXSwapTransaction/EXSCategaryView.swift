//
//  EXSCategaryView.swift
//  Chainup
//
//  Created by cwd on 2022/11/10.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit


class EXSCategaryView: EXCOCustomBaseView{
    
    
    func relayouBtns(){
        for item in container.arrangedSubviews{
            if item.isKind(of: EXSDirectionButton.self){
                let v = item as! EXSDirectionButton
                v.relayout()
                v.container.backgroundColor = UIColor.ThemeView.card1
            }
        }
    }
    
    override func setSubView() {
        self.addSubview(container)
        container.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(9)
            make.right.lessThanOrEqualToSuperview()
            make.top.bottom.equalToSuperview()
        }
        container.addArrangedSubviews([coinBtn,entrustmentBtn,allBtn])
        relayouBtns()
    }
    
    lazy var container: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fill
        stack.spacing = 10
        stack.axis = .horizontal
        stack.alignment = .fill
        return stack
    }()
    
    
    //币对 English: Coin pairs
    lazy var coinBtn: EXSDirectionButton = {
        let btn = EXSDirectionButton()
        btn.titleLabel.text = ""
        btn.titleLabel.textColor = UIColor.ThemeLabel.colorMedium
        btn.titleLabel.secondaryBold()
        return btn
    }()
    
    //委托类型 English: Entrustment type
    lazy var entrustmentBtn: EXSDirectionButton = {
        let btn = EXSDirectionButton()
        btn.titleLabel.text = ""
        btn.titleLabel.textColor = UIColor.ThemeLabel.colorMedium
        btn.titleLabel.secondaryBold()
        return btn
    }()
    
    //盈亏使用 -做多做空方向 English: Profit and loss utilization - long and short positions
    lazy var allBtn: EXSDirectionButton = {
        let btn = EXSDirectionButton()
        btn.titleLabel.text = ""
        btn.titleLabel.textColor = UIColor.ThemeLabel.colorMedium
        btn.titleLabel.secondaryBold()
        return btn
    }()
    
}

