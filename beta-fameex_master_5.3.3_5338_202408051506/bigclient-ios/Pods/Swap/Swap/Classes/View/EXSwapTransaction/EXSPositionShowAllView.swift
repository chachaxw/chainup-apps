//
//  EXSPositionShowAllView.swift
//  Chainup
//
//  Created by ZYJ on 2023/5/6.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit

class EXSPositionShowAllView: UIView {
    var onlyShowCurrentContract: EXComBoolBlock?
    var closeAllPositionCallback: (() -> ())?
    //MARK: action
    @objc func closeAll() {
        self.closeAllPositionCallback?()
    }
    @objc func switchOnClick() {
        switchButton.isSelected = !switchButton.isSelected
        self.onlyShowCurrentContract?(switchButton.isSelected)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.ThemeView.card1
        exs_addSubViews([label,switchButton,allCloseButton,line])
        switchButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
           // make.top.bottom.equalToSuperview()
//            make.width.equalTo(26)
//            make.height.equalTo(14)
        }
        label.snp.makeConstraints { (make) in
            make.left.equalTo(switchButton.snp.right).offset(6)
            make.centerY.equalToSuperview()
        }
        let size = allCloseButton.titleResizeSize()

        allCloseButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.size.equalTo(size)
//            make.width.equalTo(w)
//            make.height.equalTo(20)
        }
        
        line.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    //MARK: lazy
    lazy var label:UILabel = {
       let retV = UILabel()
        retV.textColor = UIColor.ThemeLabel.colorMedium
        retV.font = UIFont.ThemeFont.SecondaryMedium
        retV.text = "cl_close_1".ex_localized()
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(switchOnClick))
        retV.addGestureRecognizer(tap)
        retV.isUserInteractionEnabled = true
        return retV
    }()
    
    lazy var switchButton:RepeatButton = {
        let retV = RepeatButton(type: .custom)
        retV.setImage(UIImage.exs_themeImageNamed(imageName: "trade_switch_close"), for: .normal)
        retV.setImage(UIImage.svg_themeImageNamed(imageName:  "trade_switch_open"), for: .selected)
        retV.addTarget(self, action: #selector(switchOnClick), for: .touchUpInside)
        return retV
    }()
    lazy var allCloseButton:EXButton = {
        let retV = EXButton(type: .custom)
        retV.selectStyle = .defultColorBlueLine
        retV.setTitle("cl_close_2".ex_localized(), for: .normal)
        retV.titleLabel!.font = UIFont.Ex.regular(12)
        retV.addTarget(self, action: #selector(closeAll), for: .touchUpInside)
        retV.cornerRadius = 0
        return retV
    }()
    
    lazy var line: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.ThemeView.seperator
        return v
    }()
    
    override func layoutSubviews(){
        super.layoutSubviews()
        allCloseButton.roundCorners(corners: .allCorners, radius: 2)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class EXSPositionBottomTipView: EXCOCustomBaseView {
    lazy var contentLabel: UILabel = {
        let label = UILabel(text:"orderlist_text1".ex_localized(), font: UIFont.ThemeFont.SecondaryBold, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.center)
        label.ext_UseAutoLayout()
        return label
    }()
    override func setSubView() {
        self.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
