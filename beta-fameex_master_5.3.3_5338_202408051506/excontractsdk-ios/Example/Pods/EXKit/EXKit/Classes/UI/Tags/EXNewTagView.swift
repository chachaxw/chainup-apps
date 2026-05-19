//
//  EXTagView.swift
//  EXKit
//
//  Created by cwd on 2023/6/14.
//

import UIKit



public enum AuthStatus :CaseIterable{
    case Unauthrzed  //未处理
    case InTheReview //审核中
    case Certified   //已认证
    case NotThrough //未通过
    
}

public class EXNewTagView: EXBaseView {
    public var authType :AuthStatus = .Unauthrzed{
        didSet{
            var image = ""
            var bgColor = UIColor.Ex.fill1
            var titleColor = UIColor.Ex.text1
            var title = ""
            switch authType{
            case .Unauthrzed:
                bgColor = .Ex.fill3
                titleColor = .Ex.text2
                title = "Unauthrzed"
                image = "personal_attestation"
            case .InTheReview:
                bgColor = .Ex.warning2
                titleColor = .Ex.warning1
                title = "In The Review"
                image = "personal_attestation_inthereview"
            case .Certified:
                bgColor = .Ex.main3
                titleColor = .Ex.main1
                title = "Certified"
                image = "personal_attestation_certified"
            case .NotThrough:
                bgColor = .Ex.fall3
                titleColor = .Ex.fall1
                title = "Not Through"
                image = "personal_attestation_notthrough"
            }
            self.backgroundColor = bgColor
            self.iconImage.image = EXKitBundle.image(named: image)
            self.titleLabel.textColor = titleColor
            self.titleLabel.text = title
        }
    }
    
    public override func setSubView() {
        addSubview(container)
        container.addArrangedSubview(iconImage)
        container.addArrangedSubview(titleLabel)
        container.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.top.equalToSuperview().offset(9)
            make.height.equalTo(14)
            make.bottom.equalToSuperview().offset(-9)
        }
        
        iconImage.snp.makeConstraints { make in
            make.width.equalTo(16)
        }
        updateMaskedCorners(cornerRadius: 18, maskedCorners: [.topLeft,.bottomLeft])
    }
    
    
    lazy var container: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fill
        stack.spacing = 4
        stack.axis = .horizontal
        stack.alignment = .fill
        return stack
    }()
    lazy var iconImage : UIImageView = {
        let arrowImmg = UIImageView()
        arrowImmg.contentMode = .scaleAspectFit
        return arrowImmg
    }()
    lazy var titleLabel: UILabel = {
        let label = UILabel(text:"", font: .Ex.Harmony(size: 12, weight: .medium), textColor: .Ex.text1, alignment: .center)
        return label
    }()
    
}
