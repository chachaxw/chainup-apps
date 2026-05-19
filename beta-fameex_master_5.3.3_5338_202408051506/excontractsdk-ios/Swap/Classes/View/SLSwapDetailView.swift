//
//  SLSwapDetailView.swift
//  Chainup
//
//  Created by KarlLichterVonRandoll on 2023/12/31.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

/// 两个左右分布的 label English: /Two left and right distributed labels
class SLSwapHorDetailView : UIView {
    typealias ClickMiddleBtnBlock = () -> ()
    var clickMiddleBtnBlock : ClickMiddleBtnBlock?
    var showDashline: Bool = false{
        didSet{
            self.dashlineLabel.isHidden = !showDashline
        }
    }
    var showTipBtn: Bool = false{
        didSet{
            if showTipBtn == true{
                self.rightButton.isHidden = !showTipBtn
                self.rightLabel.snp.updateConstraints({ make in
                    make.right.equalToSuperview().offset(-34)
                })
                self.rightButton.snp.remakeConstraints { (make) in
                    make.width.height.equalTo(15)
                    make.right.equalToSuperview().offset(-15)
                    make.centerY.equalTo(self.rightLabel)
                }
            }else{
                self.rightButton.isHidden = true
            }
        }
    }
    
    var showTipBtnInLeft: Bool = false{
        didSet{
            if showTipBtnInLeft == true{
                self.rightButton.isHidden = false
                self.rightButton.snp.remakeConstraints { (make) in
                    make.width.height.equalTo(15)
                    make.left.equalTo(self.leftLabel.snp.right) //.offset(5)
                    make.centerY.equalTo(self.leftLabel)
                }
            }else{
                self.rightButton.isHidden = true
            }
        }
    }
    
    lazy var rightButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage.exs_themeImageNamed(imageName: "public_instructions"), for: .normal)
        button.isHidden = true
        self.addSubview(button)
        button.ext_SetAddTarget(self, #selector(clickTipButton))
        button.setEnlargeEdgeWithTop(10, left: 20, bottom: 10, right: 20)
        return button
    }()

    lazy var leftLabel: UILabel = {
        let label = UILabel()
        label.ext_UseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont.ThemeFont.BodyRegular
        return label
    }()
    
    lazy var rightLabel: UILabel = {
        let label = UILabel()
        label.ext_UseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont.ThemeFont.BodyMedium
        label.textAlignment = .right
        return label
    }()
    lazy var dashlineLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.exs_addSubViews([leftLabel, rightLabel,dashlineLabel,rightButton])
        self.initLayout()
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(clickTipButton))
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
    }
    override func layoutSubviews(){
        super.layoutSubviews()
        self.dashlineLabel.drawDashLine()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initLayout() {
        self.leftLabel.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.right.lessThanOrEqualTo(self.snp.centerX)
            
            make.centerY.equalToSuperview()
        }
        self.rightLabel.snp.makeConstraints { (make) in
            make.left.lessThanOrEqualTo(self.snp.centerX)
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
        }
        dashlineLabel.snp.makeConstraints { make in
            make.top.equalTo(self.leftLabel.snp.bottom).offset(2)
            make.left.equalTo(self.leftLabel)
            make.width.equalTo(self.leftLabel)
        }
    }
    
    
    func setLeftText(_ text: String) {
        self.leftLabel.text = text
    }
    
    func setRightText(_ text: String) {
        self.rightLabel.text = text
    }
    
    @objc func clickTipButton(_ btn : UIButton) {
        if self.showDashline || self.showTipBtn || self.showTipBtnInLeft {
            clickMiddleBtnBlock?()
        }
    }
}

/// 两个上下分布的 label English: /Two labels with upper and lower distributions
public class SLSwapVerDetailView : UIView {
    public typealias ClickMiddleBtnBlock = () -> ()
    public var clickMiddleBtnBlock : ClickMiddleBtnBlock?
    //底部下划线可点击 English: Bottom underline can be clicked
    public  var showDashline: Bool = false{
        didSet{
            self.dashlineLabel.isHidden = !showDashline
        }
    }
    public var contentAlignment: NSTextAlignment = .left {
        didSet {
            self.topLabel.textAlignment = contentAlignment
            self.bottomLabel.textAlignment = contentAlignment
            if contentAlignment == .right{
                self.topLabel.snp.remakeConstraints { (make) in
                    make.right.equalToSuperview()
                    make.top.equalToSuperview()
                }
                self.bottomLabel.snp.remakeConstraints { (make) in
                    make.right.equalToSuperview()
//                    make.top.equalTo(topLabel.snp.bottom).offset(4)
                    make.bottom.equalToSuperview()
                }
            }else if contentAlignment == .center{
                self.topLabel.snp.remakeConstraints { (make) in
                    make.centerX.equalToSuperview()
                    make.top.equalToSuperview()
                }
                self.bottomLabel.snp.remakeConstraints { (make) in
                    make.centerX.equalToSuperview()
                    make.top.equalTo(topLabel.snp.bottom).offset(4)
                    make.bottom.equalToSuperview()
                }
            }
        }
    }
    
    public lazy var topLabel: UILabel = {
        let label = UILabel()
        label.ext_UseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont.ThemeFont.SecondaryRegular
        return label
    }()
    
    lazy var dashlineLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        return label
    }()

    public lazy var bottomLabel: UILabel = {
        let label = UILabel()
        label.ext_UseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont.ThemeFont.BodyRegular
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.exs_addSubViews([topLabel,bottomLabel,dashlineLabel])
        self.initLayout()
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(clickTipButton))
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initLayout() {
        
        self.topLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
        }
        self.bottomLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
//            make.top.equalTo(topLabel.snp.bottom).offset(4)
            make.bottom.equalToSuperview()
        }
        dashlineLabel.snp.makeConstraints { make in
            make.top.equalTo(self.topLabel.snp.bottom).offset(0.8)
            make.left.equalTo(self.topLabel).offset(1.5)
            make.right.equalTo(self.topLabel).offset(-1.5)
//            make.width.equalTo(self.topLabel)
        }
        
    }
    public override func layoutSubviews(){
        super.layoutSubviews()
        self.dashlineLabel.drawDashLine()
    }

    public func setTopText(_ text: String) {
        self.topLabel.text = text
    }
    
    public func setBottomText(_ text: String) {
        
        self.bottomLabel.text = text
    }
    
    @objc func clickTipButton(_ btn : UIButton) {
        if self.showDashline  {
            clickMiddleBtnBlock?()
        }
    }
}


extension String{
    //文字添加虚线 间距太近 English: The spacing between the dotted lines added to the text is too close
    func addDashLine(color: UIColor = UIColor.ThemeLabel.colorLite) -> NSMutableAttributedString {
        let attriStr = NSMutableAttributedString(string: self)
        let range: NSRange = NSRange(location: 0, length: self.count)
        let underLineColor: UIColor = .red
        let underLineStyle = NSUnderlineStyle.patternDash.rawValue | NSUnderlineStyle.single.rawValue
        let atributes:[NSAttributedString.Key : Any]  = [
            NSAttributedString.Key.underlineStyle: underLineStyle,
            NSAttributedString.Key.underlineColor: underLineColor
        ]
        attriStr.addAttributes(atributes,range: range)
        return attriStr
        
    }
}


