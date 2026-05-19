//
//  EXChargeHistoryCell.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/5.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import SnapKit
import EXKit
class EXChargeHistoryCell: EXBaseCell {
    

    
    func bindListData(_ fianceItem:FinanceItem){
//        dateLabel.text = fianceItem.createdAtTime
//        volumeLabel.text = fianceItem.amount.formatAmount(fianceItem.coinSymbol)
//        stateLabel.text = fianceItem.status_text
        leftValueLabel.text =  fianceItem.createdAtTime
        middleTitleLabel.text = "charge_text_volume".localized() + "(\(fianceItem.coinSymbol))"
        middleValueLabel.text = fianceItem.amount.formatAmount(fianceItem.coinSymbol)
        rightValueLabel.text = fianceItem.status_text
    }
    ///Name
    lazy var titleLabel: UILabel = {
        let label = UILabel(text:"assets_action_withdraw".localized(), font: .Ex.bold(16), textColor: .Ex.text1, alignment: .left)
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var arrowImg : UIImageView = {
        let arrowImmg = UIImageView()
//        arrowImmg.contentMode = .scaleAspectFit
//        arrowImmg.image = UIImage.themeImageNamed(imageName: "coins_arrow")
        return arrowImmg
    }()
    
    lazy var leftTitleLabel: UILabel = {
        let label = UILabel(text:"charge_text_date".localized(), font: .Ex.regular(10), textColor: .Ex.text2, alignment: .left)
        label.ext_UseAutoLayout()
        return label
    }()
    lazy var leftValueLabel: UILabel = {
        let label = UILabel(text:"", font: .Ex.medium(14), textColor: .Ex.text1, alignment: .left)
        label.numberOfLines = 0
        label.ext_UseAutoLayout()
        return label
    }()
    lazy var middleTitleLabel: UILabel = {
        let label = UILabel(text:"", font: .Ex.regular(10), textColor: .Ex.text2, alignment: .left)
        label.ext_UseAutoLayout()
        return label
    }()
    lazy var middleValueLabel: UILabel = {
        let label = UILabel(text:"", font: .Ex.medium(14), textColor: .Ex.text1, alignment: .left)
        label.ext_UseAutoLayout()
        label.numberOfLines = 0
        return label
    }()
    lazy var rightTitleLabel: UILabel = {
        let label = UILabel(text:"contract_text_type".localized(), font: .Ex.regular(10), textColor: .Ex.text2, alignment: .right)
        label.ext_UseAutoLayout()
        return label
    }()
    lazy var rightValueLabel: UILabel = {
        let label = UILabel(text:"", font: .Ex.medium(14), textColor: .Ex.text1, alignment: .right)
        label.ext_UseAutoLayout()
        label.numberOfLines = 0
        return label
    }()
    

    
    
    
    
    lazy var line: UIView = {
        let v = UIView()
        v.backgroundColor = .Ex.fill4
        return v
    }()
    
    override func setUpView() {
        self.contentView.addSubViews([
        titleLabel,arrowImg,
        leftTitleLabel,middleTitleLabel,rightTitleLabel,
        leftValueLabel,middleValueLabel,rightValueLabel,
        line
        ])
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(16)
        }
        arrowImg.snp.makeConstraints { make in
            make.height.width.equalTo(10)
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(titleLabel)
        }
        
       
        let w = (SCREEN_WIDTH - 16 * 2 - 5 * 2)
        let leftW =  w * 0.40
        let middleW = w * 0.30
        let rightW =  w * 0.30
        leftTitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.height.equalTo(15)
            make.width.equalTo(leftW)
           
        }
        
        leftValueLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(leftTitleLabel.snp.bottom).offset(5)
            make.width.equalTo(leftW)
            make.bottom.lessThanOrEqualToSuperview().offset(-16).priority(.high)
        }
        
        middleTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(leftTitleLabel.snp.right).offset(5)
            make.top.equalTo(leftTitleLabel.snp.top)
            make.height.equalTo(15)
            make.width.equalTo(middleW)
        }
        middleValueLabel.snp.makeConstraints { make in
            make.left.equalTo(middleTitleLabel.snp.left)
            make.top.equalTo(middleTitleLabel.snp.bottom).offset(5)
            make.width.equalTo(middleW)
            make.bottom.lessThanOrEqualToSuperview().offset(-16).priority(.medium)
        }
        
        rightTitleLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(leftTitleLabel.snp.top)
            make.width.equalTo(rightW)
        }
        rightValueLabel.snp.makeConstraints { make in
            make.top.equalTo(rightTitleLabel.snp.bottom).offset(5)
            make.width.equalTo(rightW)
            make.right.equalToSuperview().offset(-16)
            make.bottom.lessThanOrEqualToSuperview().offset(-16).priority(.required)
        }
        
        line.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
    }
    
    
}

