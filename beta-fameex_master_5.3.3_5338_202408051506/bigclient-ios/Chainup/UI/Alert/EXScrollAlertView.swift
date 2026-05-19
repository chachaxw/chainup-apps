//
//  EXScrollAlertView.swift
//  Chainup
//
//  Created by liuxuan on 2023/11/6.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit

class EXScrollAlertView: UIView {
    
    typealias AlertCallback = (Int) -> ()
    var alertCallback : AlertCallback?
    
    lazy var mainView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.ThemeView.bg
        return view
    }()
    
    lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textAlignment = .left
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont.ThemeFont.HeadBold
        label.text = "customSetting_coAlert_title".localized()
        return label
    }()
    
    lazy var tipsView : UITextView = {
        let textView = UITextView(frame: CGRect.zero)
        textView.extUseAutoLayout()
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 2
        style.paragraphSpacing = 20
        let attributes = [NSAttributedString.Key.paragraphStyle : style,
                          .foregroundColor:UIColor.ThemeLabel.colorLite,
                          .font:UIFont.ThemeFont.BodyRegular]
        textView.backgroundColor = UIColor.ThemeView.bg;
        textView.isScrollEnabled = true
        textView.attributedText = NSAttributedString(string: "customSetting_coAlert_desc".localized(),
                                            attributes: attributes)
        textView.textAlignment = .left
        textView.isEditable = false
        textView.isScrollEnabled = true
        return textView
    }()
    
    lazy var actionBtn : EXButton = {
        let btn = EXButton()
        btn.extUseAutoLayout()
        btn.extSetAddTarget(self, #selector(clickActionBtn))
        btn.setTitle("alert_common_i_understand".localized(), for: UIControl.State.normal)
        btn.color = UIColor.ThemeBtn.highlight
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame:.zero)
        self.backgroundColor = UIColor.ThemeView.bg
        mainView.layer.cornerRadius = 4
        mainView.layer.masksToBounds = true
//        self.addSubview(mainView)
        self.addSubViews([titleLabel,tipsView,actionBtn])
//        mainView.addSubViews([titleLabel,tipsView,actionBtn])
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        let tmpHeight:CGFloat = TABBAR_CONTENTVIEW_HEIGHT - 74 - 57
        
        titleLabel.snp.makeConstraints { (make) in
            make.height.equalTo(22)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(18)
        }

        tipsView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(17)
            make.bottom.equalTo(actionBtn.snp.top).offset(-15)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(tmpHeight)
        }
//        tipsView.snp.makeConstraints { (make) in
//            make.bottom.equalToSuperview().offset(-74)
//            make.left.equalToSuperview().offset(20)
//            make.right.equalToSuperview().offset(-20)
//            make.top.equalToSuperview().offset(57)
//        }
        actionBtn.snp.makeConstraints { (make) in
            make.height.equalTo(44)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-15)
        }
    }
    
    @objc func clickActionBtn(_ btn : UIButton){
        EXAlert.dismissEnd {
            self.alertCallback?(0)
        }
    }

}
