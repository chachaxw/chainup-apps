//
//  EXAuthLevelView.swift
//  EXKit
//
//  Created by cwd on 2023/6/14.
//

import UIKit

public enum EXAuthStatus :CaseIterable{
    case unauthrzed  //未处理
    case inReview //审核中
    case certified   //已认证
    case notThrough //未通过
}

@IBDesignable
public class EXAuthLevelView: UIControl {
    
    lazy var container: UIStackView = {
        let v = UIStackView()
        v.spacing = 4
        v.axis = .horizontal
        v.alignment = .fill
        v.distribution = .fill
        return v
    }()
    
    lazy var iconImage: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        v.isUserInteractionEnabled = true
        return v
    }()
    
    lazy var titleLabel: UILabel = {
        let v = UILabel(font: .Ex.medium(12), textColor: .Ex.text1, alignment: .center)
        return v
    }()
    
    public var authType: EXAuthStatus = .unauthrzed{
        didSet{
            updateAuthIfNeeded(status: authType)
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        onCreate()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        onCreate()
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view == container { return self }
        return view
    }
    
    public func onCreate() {
        addSubview(container)
        container.addArrangedSubviews([iconImage, titleLabel])
        ///
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 9, left: 12, bottom: 9, right: 12))
            make.height.equalTo(14)
        }
        iconImage.snp.makeConstraints { $0.width.equalTo(16) }
        updateMaskedCorners(cornerRadius: 18, maskedCorners: [.topLeft,.bottomLeft])
    }
    
    func updateAuthIfNeeded(status: EXAuthStatus) {
        var image = ""
        var bgColor = UIColor.Ex.fill1
        var titleColor = UIColor.Ex.text1
        var title = ""
        switch status{
        case .unauthrzed:
            bgColor = .Ex.fill3
            titleColor = .Ex.text2
            title = "personal_text_unverified".localized()
            image = "personal_attestation"
        case .inReview:
            bgColor = .Ex.warning2
            titleColor = .Ex.warning1
            title = "noun_login_pending".localized()
            image = "personal_attestation_inthereview"
        case .certified:
            bgColor = .Ex.main3
            titleColor = .Ex.main1
            title = "personal_text_verified".localized()
            image = "personal_attestation_certified"
        case .notThrough:
            bgColor = .Ex.fall3
            titleColor = .Ex.fall1
            title = "personal_text_unverified".localized()
            image = "personal_attestation_notthrough"
        }
        self.backgroundColor = bgColor
        self.iconImage.image = EXKitBundle.image(named: image)
        self.titleLabel.textColor = titleColor
        self.titleLabel.text = title
    }
}
