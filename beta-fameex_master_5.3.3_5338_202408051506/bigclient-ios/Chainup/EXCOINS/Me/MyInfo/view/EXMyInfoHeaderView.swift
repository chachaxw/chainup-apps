//
//  EXMyInfoHeaderView.swift
//  Chainup
//
//  Created by bradjohn on 2024/5/7.
//  Copyright © 2024 Chainup. All rights reserved.
//

import UIKit
import EXKit

class EXMyInfoHeaderView: UIView {
    
    var updateNikeNameBlock: ((_ nikeName: String?) -> ())?
    
    lazy var avatorImgV: UIImageView = {
        let v = UIImageView()
        v.extUseAutoLayout()
        v.extSetCornerRadius(40)
        v.contentMode = .scaleAspectFit
        v.image = .svgImage(named: "headportrait1")
        return v
    }()
    
    lazy var nickNameLabel: UILabel = {
        let v = UILabel(font: .Ex.medium(18), textColor: .Ex.text1)
        v.extUseAutoLayout()
        v.numberOfLines = 3
        v.text = UserInfoEntity.sharedInstance().nickName
        return v
    }()
    
    lazy var editImgV: UIImageView = {
        let v = UIImageView()
        v.extUseAutoLayout()
        v.contentMode = .scaleAspectFit
        v.image = EXKitBundle.image(named: "quotes_optional")
        v.isUserInteractionEnabled = true
        return v
    }()
    
    private lazy var nickNameContainer: UIView = {
        let v = UIView()
        v.extUseAutoLayout()
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        onCreate()
        onBindViweModel()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        onCreate()
        onBindViweModel()
    }
    
    func onCreate() {
        addSubViews([avatorImgV, nickNameContainer])
        nickNameContainer.addSubViews([nickNameLabel, editImgV])
        avatorImgV.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 80, height: 80))
        }
        nickNameContainer.snp.makeConstraints { make in
            make.top.equalTo(avatorImgV.snp.bottom).offset(20)
            make.centerX.equalTo(avatorImgV)
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.85)
            make.bottom.equalToSuperview().offset(-40)
        }
        nickNameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
        editImgV.snp.makeConstraints { make in
            make.left.equalTo(nickNameLabel.snp.right).offset(4)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
            make.height.lessThanOrEqualToSuperview()
        }
    }
    
    func onBindViweModel() {
        let tap = UITapGestureRecognizer()
        tap.rx.event.filter { $0.state == .ended }.subscribe(onNext: {[weak self] _ in
            guard let self else { return }
            self.updateNikeNameBlock?(self.nickNameLabel.text)
        }).disposed(by: disposeBag)
        nickNameContainer.addGestureRecognizer(tap)
    }
    
    public func updateNickNameIfNeeded(nickName: String?) {
        nickNameLabel.text = nickName
    }
    
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
