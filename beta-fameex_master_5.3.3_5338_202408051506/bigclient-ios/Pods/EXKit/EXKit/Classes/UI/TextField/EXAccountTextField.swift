//
//  EXAccountTextField.swift
//  Chainup
//
//  Created by bradjohn on 2023/10/11.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

public class EXAccountTextField: UIView, EXTextFieldProtocol {
    
    ///
    public var contentInset:UIEdgeInsets = .zero {
        didSet {
            contentView.snp.remakeConstraints { make in
                make.edges.equalTo(contentInset)
            }
        }
    }
    
    public var isSecureEntry: Bool = false {
        didSet {
            basicTextField.isHidden = isSecureEntry
            secureTextField.isHidden = !isSecureEntry
        }
    }
    
    public var textField: UITextField {
        get {
            isSecureEntry ? secureTextField.textField : basicTextField.textField
        }
    }
    
    public var highlightColor:UIColor? {
        didSet {
            secureTextField.highlightColor = highlightColor
            basicTextField.highlightColor  = highlightColor
        }
    }
    
    public lazy var contentView: UIView = {
        let stackView = UIView()
        return stackView
    }()
    
    ///
    public lazy var topLabel: UILabel = {
        let label = UILabel(text: nil, font: .Ex.medium(12), textColor: .Ex.text2, alignment: .left)
        return label
    }()
    
    public let basicTextField: EXBasicTextField = EXBasicTextField()
    public let secureTextField: EXSecureTextField =  EXSecureTextField()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(contentInset)
        }
        contentView.addSubViews([topLabel, basicTextField, secureTextField])
        topLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
        }
        basicTextField.snp.makeConstraints { make in
            make.top.equalTo(topLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(44)
        }
        secureTextField.snp.makeConstraints { make in
            make.edges.equalTo(basicTextField)
        }
        isSecureEntry = false
    }
    ///
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
