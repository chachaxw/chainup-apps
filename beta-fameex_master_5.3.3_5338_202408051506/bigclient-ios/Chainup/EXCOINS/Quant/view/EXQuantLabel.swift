//
//  EXQuantLabel.swift
//  Chainup
//
//  Created by bradjohn on 2024/1/1.
//  Copyright © 2024 Chainup. All rights reserved.
//

import UIKit
import EXKit

class EXQuantLabel: UIView {
    
    var left: String? {
        didSet {
            leftLabel.text = left
        }
    }
    
    var right: String? {
        didSet {
            rightLabel.text = right
        }
    }
    
    var rightColor: UIColor? = .Ex.text1 {
        didSet {
            rightLabel.textColor = rightColor
        }
    }
    
    var leftView: UIView? {
        didSet {
            updateLayoutOfLeft(with: leftView)
        }
    }
    
    private var innerLeftView: UIView = UIView()
    
    var rightView: UIView? {
        didSet {
            updateLayoutOfRight(with: rightView)
        }
    }
    
    private var innerRightView: UIView = UIView()
    
    
    private lazy var leftLabel: UILabel = {
        let v = UILabel(font: .Ex.regular(14), textColor: .Ex.text2)
        return v
    }()
    
    private lazy var rightLabel: UILabel = {
        let v = UILabel(font: .Ex.medium(14), textColor: .Ex.text1)
        return v
    }()
    
    convenience public init(left: String? = nil, leftFont: UIFont? = .Ex.regular(14), leftColor: UIColor? = .Ex.text2,
                            right: String? = nil, rightFont: UIFont? = .Ex.medium(14), rightColor: UIColor? = .Ex.text1) {
        self.init()
        self.leftLabel.text = left
        self.leftLabel.font = leftFont
        self.leftLabel.textColor = leftColor
        self.rightLabel.text = right
        self.rightLabel.font = rightFont
        self.rightLabel.textColor = rightColor
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        onCreate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onCreate() {
        addSubViews([leftLabel, rightLabel])
        leftLabel.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
        }
        rightLabel.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.height.equalTo(leftLabel)
            make.left.greaterThanOrEqualTo(leftLabel.snp.right)
        }
        rightLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        innerLeftView = leftLabel
        innerRightView = rightLabel
    }
    
    
    private func updateLayoutOfLeft(with view: UIView?) {
        guard let view = view else { return }
        if innerLeftView.superview != nil {
            innerLeftView.removeFromSuperview()
        }
        addSubview(view)
        view.snp.remakeConstraints { make in
            make.left.top.bottom.equalToSuperview()
        }
        innerRightView.snp.remakeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.height.equalTo(view)
            make.left.greaterThanOrEqualTo(view.snp.right)
        }
        innerLeftView = view
    }
    
    
    private func updateLayoutOfRight(with view: UIView?) {
        guard let view = view else { return }
        if innerRightView.superview != nil {
            innerRightView.removeFromSuperview()
        }
        addSubview(view)
        innerLeftView.snp.remakeConstraints { make in
            make.left.top.bottom.equalToSuperview()
        }
        view.snp.remakeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.height.equalTo(innerLeftView)
            make.left.greaterThanOrEqualTo(innerLeftView.snp.right)
        }
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        innerRightView = view
    }
    
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
