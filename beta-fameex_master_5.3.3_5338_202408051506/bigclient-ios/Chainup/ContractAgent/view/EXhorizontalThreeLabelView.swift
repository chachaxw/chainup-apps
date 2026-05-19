//
//  EXhorizontalThreeLabelView.swift
//  Chainup
//
//  Created by chainup on 2023/9/2.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit

enum EXhorizontalThreeLabelViewUser {
    case header
    case cell
}

class EXhorizontalThreeLabelView: UIView {

    func getLabel(user:EXhorizontalThreeLabelViewUser) -> UILabel {
        let label = UILabel()
        label.extUseAutoLayout()
        
        label.textColor = UIColor.ThemeLabel.colorMedium
        
        switch user {
            
        case .header:
            label.font = UIFont.ThemeFont.SecondaryRegular
            
        case .cell:
            label.font = UIFont.ThemeFont.BodyRegular
        }
        return label
    }
    
    var firstLabel = UILabel()
    var secondLabel = UILabel()
    var thirdLabel = UILabel()
    
    init(user:EXhorizontalThreeLabelViewUser) {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.ThemeView.bg

        firstLabel = getLabel(user:user)
        secondLabel = getLabel(user:user)
        secondLabel.textAlignment = .center
        
        thirdLabel =  getLabel(user:user)
        thirdLabel.textAlignment = .right
        
        addSubViews([firstLabel,secondLabel, thirdLabel])
        
        firstLabel.snp_makeConstraints { (make) in
            make.leading.equalTo(15)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(thirdLabel)
        }
        
        secondLabel.snp_makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(firstLabel.snp_trailing)
            make.trailing.equalTo(thirdLabel.snp_leading)
            make.width.equalTo(thirdLabel)
        }
        
        thirdLabel.snp_makeConstraints { (make) in
            make.trailing.equalTo(-15)
            make.top.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setLabelsWeight(weight: (Float,Float,Float)) {
        let all = weight.0 + weight.1 + weight.2
        firstLabel.snp.remakeConstraints { (make) in
            make.leading.equalTo(15)
            make.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(weight.0 / all)
        }
        
        secondLabel.snp.remakeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(firstLabel.snp_trailing)
            make.trailing.equalTo(thirdLabel.snp_leading)
            make.width.equalToSuperview().multipliedBy(weight.1 / all)
        }
        
        thirdLabel.snp.remakeConstraints { (make) in
            make.trailing.equalTo(-15)
            make.width.equalToSuperview().multipliedBy(weight.1 / all)
            make.top.bottom.equalToSuperview()
        }
    }
    
    func setHighlight(highlight:(Bool, Bool, Bool)) {
    
        if highlight.0 {
            
            firstLabel.textColor = UIColor.ThemeLabel.colorLite
        }
        
        if highlight.1 {
            secondLabel.textColor = UIColor.ThemeLabel.colorLite
        }
        
        if highlight.2 {
            thirdLabel.textColor = UIColor.ThemeLabel.colorLite
        }
    }
    
    func setData(left:String, middle:String, right:String) {
        firstLabel.text = left
        secondLabel.text = middle
        thirdLabel.text = right
    }
}
