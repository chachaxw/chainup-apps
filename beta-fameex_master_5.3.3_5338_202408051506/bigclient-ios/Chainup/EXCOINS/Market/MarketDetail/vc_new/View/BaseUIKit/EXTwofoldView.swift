//
//  EXTwofoldView.swift
//  Chainup
//
//  Created by youbin on 2023/6/9.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit


enum EXTwofoldViewType {
    case single //Single UILabel
    case left //Left
    case right //Right
    case average //Equipartition
    case justifyAlign //Align Both Ends
}

class EXTwofoldView: UIView {
    
    var didClickedCallback:(() -> Void)?
    
    lazy var titleLabel: UILabel = {
        let v = UILabel()
        v.extUseAutoLayout()
        v.textColor = UIColor.ThemeLabel.colorMedium
        v.font = UIFont.ThemeFont.BodyMedium
        return v
    }()
    
    lazy var subtitleLabel: UILabel = {
        let v = UILabel()
        v.extUseAutoLayout()
        v.textColor = UIColor.ThemeLabel.colorLite
        v.font = UIFont.ThemeFont.BodyMedium
        return v
    }()
    
    var spacing: CGFloat = 4.0
    
    lazy var topLine: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.ThemeView.seperator
        v.isHidden = true
        return v
    }()
    
    var isTopLine = false {
        didSet {
            self.topLine.isHidden = !isTopLine
        }
    }
    var topLineColor = UIColor.ThemeView.seperator {
        didSet {
            self.topLine.backgroundColor = topLineColor
        }
    }
    var topLineHeigth = 0.5
    
    lazy var bottomLine: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.ThemeView.seperator
        return v
    }()
    
    var isBottomLine = true {
        didSet {
            self.bottomLine.isHidden = !isBottomLine
        }
    }
    var bottomLineColor = UIColor.ThemeView.seperator {
        didSet {
            self.bottomLine.backgroundColor = bottomLineColor
        }
    }
    var bottomLineHeigth = 0.5
    
    var type: EXTwofoldViewType = .left{
        didSet{
            self.reLayout(type: type)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([titleLabel, subtitleLabel, bottomLine, topLine])
        type = .left
        bringSubviewToFront(bottomLine)
        bottomLine.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(bottomLineHeigth)
        }
        bringSubviewToFront(topLine)
        topLine.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(topLineHeigth)
        }
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        subtitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        self.addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc func tapAction(_ sender: UITapGestureRecognizer) {
        didClickedCallback?()
    }
    
    func reLayout(type: EXTwofoldViewType) {
        if type == .single {
            titleLabel.isHidden = false
            subtitleLabel.isHidden = true
        } else {
            titleLabel.isHidden   = false
            subtitleLabel.isHidden = false
        }
        switch type {
        case .left:
            titleLabel.snp.remakeConstraints { (make) in
                make.left.equalToSuperview()
                make.centerY.equalToSuperview()
                make.height.lessThanOrEqualToSuperview()
            }
            subtitleLabel.snp.makeConstraints { (make) in
                make.left.equalTo(titleLabel.snp.right).offset(spacing)
                make.right.lessThanOrEqualToSuperview()
                make.height.lessThanOrEqualToSuperview()
                make.centerY.equalToSuperview()
            }
        case .average:
            titleLabel.snp.remakeConstraints { (make) in
                make.left.equalToSuperview()
                make.centerY.equalToSuperview()
                make.height.lessThanOrEqualToSuperview()
            }
            subtitleLabel.snp.remakeConstraints { (make) in
                make.left.equalTo(titleLabel.snp.right).offset(spacing)
                make.right.equalToSuperview()
                make.centerY.equalToSuperview()
                make.height.lessThanOrEqualToSuperview()
                make.width.equalTo(titleLabel.snp.width)
            }
        case .right:
            subtitleLabel.snp.remakeConstraints { (make) in
                make.right.equalToSuperview()
                make.height.lessThanOrEqualToSuperview()
                make.centerY.equalToSuperview()
            }
            titleLabel.snp.remakeConstraints { (make) in
                make.right.equalTo(subtitleLabel.snp.left).offset(-spacing)
                make.height.lessThanOrEqualToSuperview()
                make.centerY.equalToSuperview()
                make.left.greaterThanOrEqualToSuperview()
            }
        case .justifyAlign:
            titleLabel.snp.remakeConstraints { (make) in
                make.left.equalToSuperview()
                make.centerY.equalToSuperview()
                make.height.lessThanOrEqualToSuperview()
            }
            subtitleLabel.snp.remakeConstraints { (make) in
                make.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(spacing)
                make.right.equalToSuperview()
                make.height.lessThanOrEqualToSuperview()
                make.centerY.equalToSuperview()
            }
        case .single:
            titleLabel.snp.remakeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            subtitleLabel.snp.removeConstraints()
        }
    }
    
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}

