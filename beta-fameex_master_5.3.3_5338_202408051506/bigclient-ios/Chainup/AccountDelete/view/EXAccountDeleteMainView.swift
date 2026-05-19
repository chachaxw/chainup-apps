//
//  EXAccountDeleteMainView.swift
//  Chainup
//
//  Created by cwd on 2023/2/8.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit

class EXAccountDeleteMainView: EXCustomBaseView {

    var deleteBtnClickBlock: EXComVoidBlock?
    override func setSubView() {
        configSubView()
        let tap = UITapGestureRecognizer()
        tap.rx.event
            .filter({ $0.state == .ended })
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.checkBtnClick(btn: self.checkBtn)
        }).disposed(by: disposeBag)
        checkTipLabel.isUserInteractionEnabled = true
        checkTipLabel.addGestureRecognizer(tap)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        stackContainer.roundCorners(corners: .allCorners, radius: 4)
    }
    
    //MARK: action
    @objc func deleteBtnClick(){
        //detection
        self.deleteBtnClickBlock?()
    }
   
    @objc func checkBtnClick(btn: UIButton){
        btn.isSelected = !btn.isSelected
        deleteBtn.isEnabled = btn.isSelected
        
    }
    
    //MARK: Update bottom amount
    func updatebottomTip(money: String){
        let text = "account_destory_text5".localized()
//        let money = "22UST"
        let newText = String(format: text, money)
        
       let attr = newText.attributeString(specalSubStr: money, specailAttri:[
            NSAttributedString.Key.font: UIFont.ThemeFont.getFont(size: 12, aweight: .medium),
            NSAttributedString.Key.foregroundColor: UIColor.ThemeLabel.colorLite],
            commonAttri: [
                NSAttributedString.Key.font: UIFont.ThemeFont.SecondaryMedium,
                NSAttributedString.Key.foregroundColor: UIColor.ThemeLabel.colorMedium
            ])
        checkTipLabel.attributedText = attr
        
    }
    
    //MARK: lazy
    
    func configSubView(){
        self.addSubViews([
            titleLabel,
            waringView,
            stackContainer,
            checkBtn,
            checkTipLabel,
            deleteBtn
        ])
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(20)
            make.height.equalTo(32)
        }

        waringView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
        }
        stackContainer.snp.makeConstraints { make in
            make.top.equalTo(waringView.snp.bottom).offset(16)
            make.right.equalToSuperview().offset(-16)
            make.left.equalToSuperview().offset(16)
        }
       
        let emptyTop = UIView()
        emptyTop.backgroundColor = stackContainer.backgroundColor
        let emptyBottom = UIView()
        emptyBottom.backgroundColor = stackContainer.backgroundColor
        stackContainer.addArrangedSubviews([tipTitleLabel,emptyTop])
        for item in dataList{
            let cell = EXAccounItemCell()
            cell.content = item
            stackContainer.addArrangedSubview(cell)
        }
        
        stackContainer.addArrangedSubview(emptyBottom)
        
        tipTitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(16)
            make.height.equalTo(18)
        }
        emptyTop.snp.makeConstraints { make in
            make.height.equalTo(10)
        }
        emptyBottom.snp.makeConstraints { make in
            make.height.equalTo(16)
        }
        
        deleteBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-(TABBAR_BOTTOM + 36))
            make.height.equalTo(44)
        }
        checkTipLabel.snp.makeConstraints { make in
            make.bottom.equalTo(deleteBtn.snp_top).offset(-12)
            make.left.equalToSuperview().offset(36)
            make.right.equalToSuperview().offset(-16)
        }
        checkBtn.snp.makeConstraints { make in
            make.width.height.equalTo(15)
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(checkTipLabel.snp_top).offset(1)
        }
        checkBtn.setEnlargeEdgeWithTop(20, left: 20, bottom: 20, right: 20)
        
    }
    let newContainer = UIView()
    var dataList:[String] {
       let content = "account_destory_text4".localized()
        if content.contains("\\n") {
            return content.components(separatedBy: "\\n")
        }
        return content.components(separatedBy: "\n")
    }
    lazy var titleLabel: UILabel = {
        let label = UILabel(text:"account_destory_text1".localized(), font: UIFont.ThemeFont.getFont(size: 28, aweight: .medium), textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    //waring
    lazy var waringView: EXWaringView = {
       let v = EXWaringView()
        v.tipLabel.text = "account_destory_text3".localized()
        return v
    }()
    
    lazy var stackContainer: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fill
        stack.spacing = 0
        stack.axis = .vertical
        stack.alignment = .fill
        stack.backgroundColor = UIColor.ThemeView.newbg
        return stack
    }()
    
    ///Name
    lazy var tipTitleLabel: UILabel = {
        let label = UILabel(text:"account_destory_text2".localized(), font: UIFont.ThemeFont.getFont(size: 14, aweight: .medium), textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        label.numberOfLines = 0
        return label
    }()
    
    //confirm
    lazy var checkBtn : UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "public_unselected"), for: .normal)
        btn.setImage(EXKitBundle.svgImage(named: "public_selected_square"), for: .selected)
        btn.addTarget(self, action: #selector(checkBtnClick(btn:)), for: UIControl.Event.touchUpInside)
        return btn
    }()
    
    ///Name
    lazy var checkTipLabel: UILabel = {
        let label = UILabel(text:"", font: UIFont.ThemeFont.SecondaryMedium, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.left)
        label.numberOfLines = 0
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var deleteBtn:EXButton = {
        let btnSell = EXButton()
        btnSell.titleLabel?.font = UIFont.ThemeFont.HeadBold
        btnSell.setTitle("account_destory_text6".localized(), for: .normal)
        btnSell.setTitleColor(UIColor.white, for: .normal)
        btnSell.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .disabled)
        btnSell.isSelected = false
        btnSell.color = UIColor.ThemeView.highlight
        btnSell.layer.cornerRadius = 4
        btnSell.layer.masksToBounds = true
        btnSell.addTarget(self, action: #selector(deleteBtnClick), for: .touchUpInside)
        btnSell.isEnabled = false
        return btnSell
    }()
    
}

class EXAccounItemCell: EXCustomBaseView{
    var content :String? {
        didSet{
            if content?.hasPrefix("·") ?? false{
                content?.removeFirst()
            }
            let message = NSMutableAttributedString(string:content ?? "")
            let para = NSMutableParagraphStyle()
            para.minimumLineHeight = 20
            para.lineSpacing = 0
            let color = EXThemeManager.isNight() ? UIColor.ThemeLabel.colorLite : UIColor.ThemeLabel.colorMedium
            message.addAttribute(.foregroundColor, value: color, range: NSRange(location: 0, length: message.length))
            message.addAttribute(.font, value: UIFont.ThemeFont.SecondaryMedium, range: NSRange(location: 0, length: message.length))
            message.addAttribute(.paragraphStyle, value: para, range: NSRange(location: 0, length: message.length))
            contentLabel.attributedText = message
            contentLabel.textAlignment = .left
        }
    }
    override func setSubView() {
   
        self.backgroundColor = UIColor.ThemeView.newbg
        self.addSubViews([titleLabel,contentLabel])
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()//.offset(16)
            make.top.equalToSuperview()
            make.height.equalTo(20)
            make.width.equalTo(5)
            
        }
        contentLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.right).offset(3)
            make.right.equalToSuperview()//.offset(-16)
            make.height.greaterThanOrEqualTo(20)
            make.top.bottom.equalToSuperview()
        }
    }
    ///Name
    lazy var titleLabel: UILabel = {
        let label = UILabel(text:"", font: UIFont.ThemeFont.SecondaryMedium, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        let message = NSMutableAttributedString(string:"·")
        let para = NSMutableParagraphStyle()
        para.minimumLineHeight = 20
        para.lineSpacing = 0
        let color = EXThemeManager.isNight() ? UIColor.ThemeLabel.colorLite : UIColor.ThemeLabel.colorMedium
        message.addAttribute(.foregroundColor, value: color, range: NSRange(location: 0, length: message.length))
        message.addAttribute(.font, value: UIFont.ThemeFont.SecondaryMedium, range: NSRange(location: 0, length: message.length))
        message.addAttribute(.paragraphStyle, value: para, range: NSRange(location: 0, length: message.length))
        label.attributedText = message
        
        return label
    }()
    ///Name
    lazy var contentLabel: UILabel = {
        let label = UILabel(text:"", font: UIFont.ThemeFont.SecondaryMedium, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.left)
        label.numberOfLines = 0
        let color = EXThemeManager.isNight() ? UIColor.ThemeLabel.colorLite : UIColor.ThemeLabel.colorMedium
        label.textColor = color
        label.ext_UseAutoLayout()
        return label
    }()
}

