//
//  EXPrivacyAlertView.swift
//  EXKit
//
//  Created by zq on 2024/2/21.
//

import UIKit
import SnapKit
import YYText

public class EXPrivacyAlertView: UIView {
    ///
    private static let key = "app.startup.privacy"
    private static var didAgreeValue:Bool = UserDefaults.standard.bool(forKey: key)
    ///
    public private(set) static var didAgree: Bool {
        get { didAgreeValue }
        set {
            didAgreeValue = newValue
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
    ///
    public class func showIfNeeded(privacyAction: @escaping ()->Void,agreeAction: @escaping (Bool)->Void) {
        guard !EXPrivacyAlertView.didAgree else { return }
        let alertView = EXPrivacyAlertView(privacyAction: privacyAction, agreeAction: {
            if $0 { EXKitAlert.dismiss() }
            agreeAction($0)
        })
        EXKitAlert.showAlert(alertView: alertView, offset: EXPrivacyAlertView.horizontalEdgeOffset, windowLevel: .statusBar)
    }
    
    ///
    private static let horizontalEdgeOffset:CGFloat = 32
    ///
    let maxHeight = Device_H - 116 * 2
    let maxTextWidth = Device_W - 32 * 2 - 20 * 2
    let contentEdgeInset = UIEdgeInsets(top: 24, left: 20, bottom: 20, right: 20)
    ///
    let privacyAction: ()->Void
    let agreeAction: (Bool)->Void
    ///
    public required init(privacyAction: @escaping ()->Void,agreeAction: @escaping (Bool)->Void) {
        self.privacyAction = privacyAction
        self.agreeAction = agreeAction
        super.init(frame: .zero)
        corneradius = 12
        backgroundColor = .Ex.fill6
        ///
        let contentTitleLabel = UILabel(text: String(format: "privacy_tips_content1".localized(), EXKitStanders.getAppName()) ,font: .Ex.regular(14), textColor: .Ex.text1, numberOfLines: 0, preferredMaxLayoutWidth: maxTextWidth)
        contentTitleLabel.attributedText = contentTitleLabel.ex_NSAttributedString()?.ex_mutableCopy().ex_lineHeight(20)
        ///
        let contentLabel = UILabel(text: "privacy_tips_content2".localized() ,font: .Ex.regular(14), textColor: .Ex.text1, numberOfLines: 0, preferredMaxLayoutWidth: maxTextWidth)
        contentLabel.attributedText = contentLabel.ex_NSAttributedString()?.ex_mutableCopy().ex_lineHeight(20)
        ///
        let contentView = UIView()
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(contentEdgeInset)
        }
        ///
        let disagreeButton = UIButton(backgroundColor: .Ex.fill3, title: "privacy_tips_action_disagree".localized(), titleFont: .Ex.medium(14), titleColor: .Ex.text1) { [weak self] in self?.agreeAction(false); exit(0) }
        disagreeButton.corneradius = 4
        let agreeButton = UIButton(backgroundColor: .Ex.main1, title: "privacy_tips_action_agree".localized(), titleFont: .Ex.medium(14), titleColor: .Ex.text4) { [weak self] in EXPrivacyAlertView.didAgree = true; self?.agreeAction(true) }
        agreeButton.corneradius = 4
        ///
        let titleLabel = UILabel(text: "privacy_tips_title".localized() ,font: .Ex.medium(16), textColor: .Ex.text1, alignment: .center)
        let scrollView = UIScrollView()
        ///
        let scrollContentView = UIView()
        scrollContentView.addSubViews([contentTitleLabel,contentLabel])
        scrollView.addSubview(scrollContentView)
        scrollContentView.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
        }
        contentTitleLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(contentTitleLabel.snp.bottom).offset(12)
            make.left.right.bottom.equalToSuperview()
        }
        ///
        let privacyLabel = YYLabel()
        privacyLabel.numberOfLines = 0
        privacyLabel.preferredMaxLayoutWidth = maxTextWidth
        privacyLabel.attributedText = {
            let linkText = "privacy_tips_link".localized()
            let privacyText = String(format: "privacy_tips_option".localized(), linkText)
            let linkRange = (privacyText as NSString).range(of: linkText)
            let attributedText = privacyText.ex_toNSAttributedString(font: .Ex.regular(14), textColor: .Ex.text2)
            if linkRange.location != NSNotFound {
                attributedText.ex_textColor(.Ex.main1, range: linkRange)
                attributedText.ex_setYYHighlight(.init(textColor: .Ex.main1, tapAction: {[weak self] _, _, _, _ in
                    self?.privacyAction()
                }), range: linkRange)
            }
            attributedText.ex_lineHeight(20)
            return attributedText
        }()
        ///
        let actionView = UIStackView(axis: .horizontal, distribution: .fillEqually , spacing: 16, arrangedSubviews: [disagreeButton,agreeButton])
        contentView.addSubViews([titleLabel, scrollView, privacyLabel, actionView])
        ///
        let scrollViewMaxHeight = maxHeight - contentEdgeInset.top - titleLabel.intrinsicContentSize.height - 16 - 16 - privacyLabel.intrinsicContentSize.height - 56 - contentEdgeInset.bottom
        let scrollViewHeight = min(contentTitleLabel.intrinsicContentSize.height + 12 + contentLabel.intrinsicContentSize.height, scrollViewMaxHeight)
        ///
        titleLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
            make.height.equalTo(scrollViewHeight)
        }
        privacyLabel.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
        }
        actionView.snp.makeConstraints { make in
            make.top.equalTo(privacyLabel.snp.bottom).offset(12)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(44)
        }
    }
    ///
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
