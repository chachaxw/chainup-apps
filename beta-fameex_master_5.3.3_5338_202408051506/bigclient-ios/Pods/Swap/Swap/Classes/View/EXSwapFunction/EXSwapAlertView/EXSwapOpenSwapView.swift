//
//  EXSwapOpenSwapView.swift
//  Chainup
//
//  Created by ZYJ on 2023/12/1.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
//import MapKit
//开通合约弹框 English: Activate contract pop-up
class EXSwapOpenSwapView: UIView {

    typealias AlertCallback = (Int64) -> ()
    var alertCallback : AlertCallback?
    

    //MARK: lifecycle
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: 0, width: EXSCREEN_WIDTH, height: EXS_SCREEN_HEIGHT))
        self.backgroundColor =  UIColor.ThemeView.mask
        mainView.exs_addSubViews([titleLabel,tipsView,openContractBtn,cancelButton])
        setupUI()
        tipsView.setContentOffset(CGPoint.zero, animated: false)
        self.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(dismiss))
        self.addGestureRecognizer(tap)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mainView.exs_roundCorners(corners: .allCorners, radius: 12)
    }
    @objc func dismiss(){
        self.removeFromSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK:- 事件 English: MARK: - Event
    func show() {
        UIApplication.shared.keyWindow?.addSubview(self)
    }
    static func dismiss(v: UIView) {
        for view in UIApplication.shared.keyWindow!.subviews {
            if view is EXSwapOpenSwapView {
                v.removeFromSuperview()
                break
            }
        }
    }
    /// 点击取消 English: /Click to cancel
    @objc func clickCancelButton() {
        dismiss()
    }
    
    @objc func clickOpenContractBtn(_ btn : UIButton){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
            self.alertCallback?(0)
        }
        EXSwapOpenSwapView.dismiss(v: self)
    }
    
    
    func setupUI() {
        mainView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(32)
            make.right.equalToSuperview().offset(-32)
            make.top.equalToSuperview().offset(99)
            make.bottom.equalToSuperview().offset(-99)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(20)
        }
       
        tipsView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalTo(openContractBtn.snp.top).offset(-20)
        }
        openContractBtn.snp.makeConstraints { (make) in
            make.height.equalTo(44)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            
        }
        
        cancelButton.snp.makeConstraints { (make) in
            make.top.equalTo(openContractBtn.snp.bottom).offset(12)
            make.height.equalTo(18)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    // MARK:- lazy

    lazy var mainView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.ThemeView.alertBg
        self.addSubview(view)
        return view
    }()
   
    lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.ext_UseAutoLayout()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont.ThemeFont.H3Bold
        label.text = "cp_content_text18".ex_localized()
        return label
    }()
    
    lazy var tipsView : UITextView = {
        let textView = UITextView(frame: CGRect.init(x: 20, y: 57, width: self.frame.width - 64 - 40, height: 423))
        textView.ext_UseAutoLayout()
        
        textView.backgroundColor = UIColor.ThemeView.alertBg
        textView.textColor = UIColor.ThemeLabel.colorLite
        textView.isScrollEnabled = true
        let message = NSMutableAttributedString(string: "cp_extra_text117".ex_localized())
        let para = NSMutableParagraphStyle()
        para.lineSpacing = 5
        para.paragraphSpacing = 20
        message.addAttribute(.foregroundColor, value: UIColor.ThemeLabel.colorMedium, range: NSRange(location: 0, length: message.length))
        message.addAttribute(.font, value: UIFont.ThemeFont.BodyRegular, range: NSRange(location: 0, length: message.length))
        message.addAttribute(.paragraphStyle, value: para, range: NSRange(location: 0, length: message.length))
        textView.attributedText = message
        textView.textAlignment = .left
        textView.isEditable = false
        textView.isScrollEnabled = true
        return textView
    }()
    
    lazy var openContractBtn : EXSButton = {
        let btn = EXSButton()
        btn.ext_UseAutoLayout()
        btn.clearColors()
        btn.titleLabel?.numberOfLines = 2
        btn.titleLabel?.textColor = UIColor.ThemeLabel.colorLite
        btn.titleLabel?.font = UIFont.ThemeFont.BodyMedium
        btn.ext_SetAddTarget(self, #selector(clickOpenContractBtn))
        btn.setTitle("cp_overview_text66".ex_localized(), for: .normal)
        btn.color = UIColor.ThemeBtn.highlight
        return btn
    }()
    /// 取消 English: /Cancel
    lazy var cancelButton: UIButton = {
        let button = UIButton(buttonType: .custom, title: "cp_overview_text56".ex_localized(), titleFont: UIFont.ThemeFont.BodyMedium, titleColor: UIColor.ThemeLabel.colorHighlight)
        button.ext_SetAddTarget(self, #selector(clickCancelButton))
        return button
    }()
}



