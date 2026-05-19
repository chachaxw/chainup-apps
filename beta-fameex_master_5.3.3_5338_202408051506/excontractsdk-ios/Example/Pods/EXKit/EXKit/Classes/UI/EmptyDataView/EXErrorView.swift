//
//  EXErrorView.swift
//  Chainup
//
//  Created by zq on 2023/3/2.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import SnapKit

public class EXErrorView: UIView {
    
    public let imageView = UIImageView(image: .themeImageNamed(imageName: "public_prompt"))
    public let descLabel = UILabel(text: "common_text_reqeust_failed".localized(), font: .Ex.medium(16), textColor: .ThemeLabel.colorLite, alignment: .center)
    public let tipsLabel = UILabel(text: "common_text_reqeust_retry".localized(), font: .Ex.regular(14), textColor: .ThemeLabel.colorMedium, alignment: .center)
    
    public var buttonAction:(()->Void)?
    
    public lazy var button: UIButton = {
        let button = UIButton(buttonType: .custom, title: "common_text_retry".localized(), titleFont: .ThemeFont.BodyMedium, titleColor: .white)
        button.setBackgroundColor(color: .ThemeView.card2, forState: .normal)
        button.extSetCornerRadius(4)
        button.rx.tap.subscribe(onNext: { [weak self] in
            self?.buttonAction?()
        }).disposed(by: disposeBag)
        return button
    }()
    
    public convenience init(buttonAction:(()->Void)?) {
        self.init(frame: .zero)
        self.buttonAction = buttonAction
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([imageView,descLabel,tipsLabel,button])
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.size.equalTo(CGSize(width: 80, height: 80))
            make.centerX.equalToSuperview()
        }
        descLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(22)
            make.centerX.equalToSuperview()
        }
        tipsLabel.snp.makeConstraints { make in
            make.top.equalTo(descLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        button.snp.makeConstraints { make in
            make.top.equalTo(tipsLabel.snp.bottom).offset(34)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            //
            var size = self.button.titleLabel!.intrinsicContentSize
            size.width += 72
            size.height += 26
            size.width = min(Device_W - 32, size.width)
            make.size.equalTo(size)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
