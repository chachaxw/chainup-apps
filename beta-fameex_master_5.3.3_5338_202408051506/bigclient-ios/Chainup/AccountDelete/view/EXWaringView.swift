//
//  EXWaringView.swift
//  Chainup
//
//  Created by cwd on 2023/2/8.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import Swap
class EXWaringView: EXCustomBaseView{
    
    override func setSubView() {
        configSubView()
    }
    func configSubView(){
        self.addSubview(container)
        self.addSubview(contentView)
        self.insertSubview(contentView, at: 0)
        contentView.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(1)
            make.bottom.right.equalToSuperview().offset(-1)
        }
        contentView.backgroundColor = UIColor.ThemeState.warning.withAlphaComponent(0.15)
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.ThemeState.warning.cgColor
        contentView.layer.cornerRadius = 4
        contentView.layer.masksToBounds = true
//        container.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(8)
//            make.left.equalToSuperview().offset(16)
//            make.right.equalToSuperview().offset(-16)
//            make.height.equalTo(30)
//        }
        self.addSubview(imageIV)
        container.addArrangedSubview(tipLabel)
        imageIV.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.width.height.equalTo(10)
            make.centerY.equalToSuperview()
        }
        container.snp.makeConstraints { make in
            make.left.equalTo(imageIV.snp.right).offset(8)
            make.top.equalToSuperview().offset(6)
            make.bottom.equalToSuperview().offset(-4)
            make.right.equalToSuperview().offset(-5)
        }

    }
    let contentView = UIView()
    lazy var container: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        return stack
    }()
    lazy var imageIV : UIImageView = {
        let arrowImmg = UIImageView()
        arrowImmg.image = UIImage.exs_themeImageNamed(imageName: "public_prompt")
        return arrowImmg
    }()
    ///Warning content
    lazy var tipLabel: UILabel = {
        let label = UILabel(text:"", font: UIFont.ThemeFont.getFont(size: 12, aweight: .medium), textColor: UIColor.ThemeState.warning, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        label.numberOfLines = 0
        return label
    }()
  
}



