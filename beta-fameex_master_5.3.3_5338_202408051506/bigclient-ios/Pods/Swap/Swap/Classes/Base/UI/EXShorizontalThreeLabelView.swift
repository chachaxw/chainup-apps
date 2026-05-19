//
//  EXhorizontalThreeLabelView.swift
//  Chainup
//
//  Created by chainup on 2023/9/2.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit

public enum EXShorizontalThreeLabelViewUser {
    case header
    case cell
}

public class EXShorizontalThreeLabelView: UIView {

    func getLabel(user:EXShorizontalThreeLabelViewUser) -> UILabel {
        let label = UILabel()
        label.ext_UseAutoLayout()
        
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
    
    public init(user:EXShorizontalThreeLabelViewUser) {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.ThemeView.bg

        firstLabel = getLabel(user:user)
        secondLabel = getLabel(user:user)
        secondLabel.textAlignment = .left
        
        thirdLabel =  getLabel(user:user)
        thirdLabel.textAlignment = .right
        
        exs_addSubViews([firstLabel,secondLabel, thirdLabel])
        
        firstLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(15)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(thirdLabel)
        }
        
        secondLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(firstLabel.snp_trailing)
            make.trailing.equalTo(thirdLabel.snp_leading)
            make.width.equalTo(thirdLabel)
        }
        
        thirdLabel.snp.makeConstraints { (make) in
            make.trailing.equalTo(-15)
            make.top.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setLabelsWeight(weight: (Float,Float,Float)) {
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
    
    public func hideMiddleLabel() {
        firstLabel.snp_remakeConstraints { (make) in
            make.leading.equalTo(15)
            make.top.bottom.equalToSuperview()
        }
        secondLabel.isHidden = true
        thirdLabel.snp_remakeConstraints { (make) in
            make.trailing.equalTo(-15)
            make.top.bottom.equalToSuperview()
        }
    }
    
    public func setHighlight(highlight:(Bool, Bool, Bool)) {
    
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
    
    public func setData(left:String, middle:String, right:String) {
        firstLabel.text = left
        secondLabel.text = middle
        thirdLabel.text = right
    }
    
    public func config(titleColor: UIColor, font: UIFont){
        firstLabel.textColor = titleColor
        secondLabel.textColor = titleColor
        thirdLabel.textColor = titleColor
        firstLabel.font = font
        secondLabel.font = font
        thirdLabel.font = font
    }
}

