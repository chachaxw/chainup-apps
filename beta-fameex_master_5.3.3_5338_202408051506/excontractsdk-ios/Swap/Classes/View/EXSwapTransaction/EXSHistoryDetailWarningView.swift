//
//  EXSHistoryDetailWarningView.swift
//  Chainup
//
//  Created by cwd on 2022/11/12.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit

/// 顶部提示 English: /Top tip
class EXSHistoryDetailWarningViewCell: EXBaseTableViewCell{
    override func setUpView() {
        configSubView()
    }
    func configSubView(){
        self.contentView.addSubview(container)
        container.backgroundColor = UIColor.ThemeState.warning.withAlphaComponent(0.15)
        container.layer.borderWidth = 0.5
        container.layer.borderColor = UIColor.ThemeState.warning.cgColor
        container.layer.cornerRadius = 4
        container.layer.masksToBounds = true
        container.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-1)
//            make.height.equalTo(28)
        }
        container.addSubview(imageIV)
        container.addSubview(tipLabel)
        imageIV.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.width.height.equalTo(15)
            make.centerY.equalToSuperview()
        }
        tipLabel.snp.makeConstraints { make in
            make.left.equalTo(imageIV.snp.right).offset(8)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-6)
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
        }
    }
    
    let  container = UIView()
    lazy var imageIV : UIImageView = {
        let arrowImmg = UIImageView()
//        arrowImmg.contentMode = .scaleAspectFit
        arrowImmg.image = UIImage.exs_themeImageNamed(imageName: "public_prompt")
        return arrowImmg
    }()
    /// 警示内容 English: /Warning content
    lazy var tipLabel: UILabel = {
        let label = UILabel(text:"", font: UIFont.ThemeFont.SecondaryBold, textColor: UIColor.ThemeState.warning, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        label.numberOfLines = 0
        label.font = UIFont.ThemeFont.SecondaryBold
        return label
    }()
}



