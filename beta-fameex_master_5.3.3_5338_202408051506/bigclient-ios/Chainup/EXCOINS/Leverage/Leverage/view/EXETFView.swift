//
//  EXETFView.swift
//  Chainup
//
//  Created by zewu wang on 2023/2/9.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

//Disclaimer
class EXETFDisclaimerView : UIView , UITextViewDelegate{
    typealias AlertCallback = (Bool) -> ()
    var alertCallback : AlertCallback?
    lazy var backView : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.bg
        view.extSetCornerRadius(1.5)
        return view
    }()
    
    lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorLite
        label.text = "etf_text_disclaimer".localized()
        label.font = UIFont.ThemeFont.HeadMedium
        return label
    }()
    
    lazy var textView : UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor.ThemeView.bg 
        textView.extUseAutoLayout()
        textView.textColor = UIColor.ThemeLabel.colorLite
        textView.font = UIFont.ThemeFont.BodyRegular
        textView.isEditable = false
        textView.delegate = self
        return textView
    }()
    
    lazy var confirmBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.setTitle("etf_text_knowRisk".localized(), for: UIControl.State.normal)
        btn.setTitleColor(UIColor.ThemeLabel.white, for: UIControl.State.normal)
        btn.extSetCornerRadius(1.5)
        btn.backgroundColor = UIColor.ThemeBtn.highlight
        btn.titleLabel?.font = UIFont.ThemeFont.HeadBold
        btn.addTarget(self, action: #selector(clickConfirmBtn), for: UIControl.Event.touchUpInside)
        return btn
    }()
    
    lazy var cancelBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.setTitle("etf_agreement_deny".localized(), for: UIControl.State.normal)
        btn.setTitleColor(UIColor.ThemeLabel.white, for: UIControl.State.normal)
        btn.extSetCornerRadius(1.5)
        btn.backgroundColor = UIColor.ThemeBtn.highlight
        btn.titleLabel?.font = UIFont.ThemeFont.HeadBold
        btn.addTarget(self, action: #selector(clickCancelBtn), for: UIControl.Event.touchUpInside)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        addSubview(backView)
        backView.addSubViews([titleLabel,textView,confirmBtn,cancelBtn])
        let height = SCREEN_HEIGHT - 100
        backView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.lessThanOrEqualTo(height)
            make.bottom.equalTo(cancelBtn).offset(15)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(18)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(22)
        }
        textView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(titleLabel.snp.bottom).offset(17)
            make.height.equalTo(0)
        }
        confirmBtn.snp.makeConstraints { (make) in
            make.height.equalTo(44)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(textView.snp.bottom).offset(30)
        }
        
        cancelBtn.snp.makeConstraints { (make) in
            make.height.equalTo(44)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(confirmBtn.snp.bottom).offset(10)
        }
    }
    
    //Click on the confirm button
    @objc func clickConfirmBtn(){
        alertCallback?(true)
        self.removeFromSuperview()
    }
    
    @objc func clickCancelBtn() {
        alertCallback?(false)
        self.removeFromSuperview()
    }
    
    func setTextView(_ text : String){
        let detail1 = "etf_text_disclaimerDetail1".localized().replacingOccurrences(of: "\\n", with: "\n")
        let detail2 = "etf_text_disclaimerDetail2".localized().replacingOccurrences(of: "\\n", with: "\n")
        let detail3 = "etf_text_disclaimerDetail3".localized().replacingOccurrences(of: "\\n", with: "\n")

        let str = String(format:detail1,text) + String(format:detail2,"etf_text_faq".localized()) + String(format:detail3)
        textView.appendLinkString(string: str, increaseStr: "",withURLString: "etf_text_faq".localized(), lineSpacing: 2)
        
        //The height of the entire pop-up window - (height of 2 buttons+title height+top and bottom margins)
        let textViewHeight = SCREEN_HEIGHT - 308
        textView.snp.remakeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(titleLabel.snp.bottom).offset(17)
            make.height.equalTo(textViewHeight)
        }
    }
    
    var faqUrl = ""
    
    func show(){
        guard let appDelegate  = UIApplication.shared.delegate else {
            return
        }
        if appDelegate.window != nil   {
            appDelegate.window??.rootViewController?.view.addSubview(self)
            appDelegate.window??.rootViewController?.view.bringSubviewToFront(self)
            self.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        appApi.rx.request(AppAPIEndPoint.etfFaqInfo).MJObjectMap(EXETFModel.self,false).subscribe(onSuccess: {[weak self] (model) in
            self?.faqUrl = model.faqUrl
            self?.setTextView(model.domainName)
        }) { (error) in
            
        }.disposed(by: disposeBag)
    }
    
    func clickUrl(){
        guard let appDelegate = UIApplication.shared.delegate else {
            return
        }
        let vc = WebVC()
        vc.missBlock = {
            self.isHidden = false
        }
        self.isHidden = true
        vc.modalPresentationStyle = .fullScreen
        vc.loadUrl(faqUrl)
        appDelegate.window??.rootViewController?.present(vc, animated: true, completion: nil)
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        clickUrl()
        return true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension UITextView {

    ///Add link text (when the link is empty, it represents normal text), and the guidance string can be increased (default font=13)
    ///
    /// - Parameters:
    ///- string: text
    ///- incrementStr: The string that needs to be increased
    ///- with URLString: link
    ///- lineSpacing: Line spacing
    func appendLinkString(string:String,
                          increaseStr:String?,
                          withURLString:String?,
                          lineSpacing:CGFloat) {
        //Original text content
        let attrString:NSMutableAttributedString = NSMutableAttributedString()
        attrString.append(self.attributedText)

        //New text content (using default font style)
        let attrs = [NSAttributedString.Key.font : self.font ?? UIFont.ThemeFont.BodyRegular,
            NSAttributedString.Key.foregroundColor : self.textColor ?? UIColor.black]
        let appendString = NSMutableAttributedString(string: string, attributes:attrs)
//        let range:NSRange = NSMakeRange(0, appendString.length)
        //Determine if it is link text
        if let urlStr = withURLString {
            let srange = string.positionOf(sub:urlStr)
            if srange >= 0 {
                let urlStrRange : NSRange = NSRange.init(location: srange, length: urlStr.count)
                if urlStrRange.location != NSNotFound {
                    appendString.addAttribute(NSAttributedString.Key.link, value: "", range: urlStrRange)
                    appendString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.ThemeLabel.colorHighlight, range: urlStrRange)
                }
            }
        }

        //Set merged text
        self.attributedText = appendString
    }
}

