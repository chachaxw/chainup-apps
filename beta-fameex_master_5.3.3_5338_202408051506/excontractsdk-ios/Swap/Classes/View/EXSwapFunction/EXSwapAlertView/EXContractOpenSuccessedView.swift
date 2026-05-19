//
//  EXContractOpenSuccessedView.swift
//  Chainup
//
//  Created by cwd on 2022/12/5.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import EXKit
//合约开通成功的弹框 English: Pop ups indicating successful contract activation
class EXContractOpenSuccessedView: EXCOCustomBaseView{
    typealias AlertCallback = (Int) -> ()
    var alertCallback : AlertCallback?
    
    static let titleTop: CGFloat = 20
    static let contentTop: CGFloat = 16
    static let bottomViewTop: CGFloat = 20
    static let bottomViewBottom: CGFloat = 20
    
    lazy var container: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.backgroundColor = UIColor.ThemeView.bg
        view.distribution = .fill
        return view
    }()
    ///标题 English: /Title
    lazy var titleContainer = UIView()
    lazy var titleLabel: UILabel = {
        let label = UILabel(text: nil, font: UIFont.Ex.medium(18), textColor: UIColor.Ex.text1, alignment: NSTextAlignment.center)
        label.numberOfLines = 0
        label.ext_UseAutoLayout()
        return label
    }()
    ///内容 English: /Content
    lazy var contentContainer = UIView()
    lazy var contentLabel: UILabel = {
        let label = UILabel(text: nil, font: UIFont.Ex.medium(12), textColor: UIColor.Ex.text2, alignment: NSTextAlignment.left)
        label.numberOfLines = 0
        label.ext_UseAutoLayout()
        return label
    }()
    
    //图片 English: picture
    lazy var imageView: UIImageView = {
        let arrowImmg = UIImageView()
        arrowImmg.contentMode = .scaleAspectFit
        arrowImmg.image = UIImage.svg_themeImageNamed(imageName: "public_opened")
        return arrowImmg
    }()
    
    ///底部 English: /Bottom
    lazy var bottomContainer = UIView()
    
    lazy var surebtn:UIButton = {
        let btn = EXSButton()
        btn.extUseAutoLayout()
        btn.extSetCornerRadius(4)
        btn.backgroundColor = UIColor.ThemeView.bg
        btn.setTitleColor(UIColor.white, for:.normal)
        btn.tag = 1
        btn.setTitle("cp_contract_opened_dialog_btn1".ex_localized(), for: .normal)
        btn.titleLabel?.font = UIFont.ThemeFont.BodyMedium
        btn.extSetAddTarget(self, #selector(btnClick(btn:)))
        return btn
    }()
    
    //合约指南 English: Contract Guidelines
    lazy var guideBtn : UIButton = {
        let btn = EXSButton()
        btn.extUseAutoLayout()
        btn.extSetCornerRadius(4)
        btn.clearColors()
        btn.tag = 2
        btn.backgroundColor = UIColor.ThemeView.card2
        btn.setTitle("cp_contract_opened_dialog_btn2".ex_localized(), for: .normal)
        btn.setTitleColor(UIColor.ThemeLabel.colorLite, for:.normal)
        btn.titleLabel?.font = UIFont.ThemeFont.BodyMedium
        btn.extSetAddTarget(self, #selector(btnClick(btn:)))
        return btn
    }()
    
    
    //发送按钮 English: Send button
    lazy var cancelbtn : UIButton = {
        let btn = EXSButton()
        btn.clearColors()
        btn.backgroundColor = UIColor.ThemeView.bg
        btn.setTitle("cp_overview_text56".ex_localized(), for: .normal)
        btn.setTitleColor(UIColor.ThemeBtn.highlight, for:.normal)
        btn.titleLabel?.font = UIFont.ThemeFont.BodyMedium
        btn.extSetAddTarget(self, #selector(btnClick(btn:)))
        btn.tag = 3
        return btn
    }()
    
    override func setSubView() {
        self.backgroundColor = UIColor.ThemeView.alertBg
        self.addSubview(container)
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        container.addArrangedSubviews([titleContainer,contentContainer,bottomContainer])
        titleContainer.addSubview(titleLabel)
        contentContainer.addSubViews([imageView,contentLabel])
        bottomContainer.addSubViews([surebtn,guideBtn,cancelbtn])
       
    }
    override func layoutSubviews(){
        roundCorners(corners: [.allCorners], radius: 20)
    }

    

    @objc func btnClick(btn: UIButton){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
            self.alertCallback?(btn.tag)
        }
        EXAlert.dismiss()
    }
    


    func configAlert(title:String?,
                     titleFont:UIFont? = UIFont.Ex.medium(18),
                     image: UIImage? = nil,
                     message:String?,
                     messageFont:UIFont? = UIFont.Ex.medium(12))
    {

        titleLabel.text = title
        titleLabel.font = titleFont
        if image != nil{
            imageView.image = image
        }
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.28
        paragraphStyle.minimumLineHeight = 18
        contentLabel.attributedText = NSMutableAttributedString(string: message ?? "", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle, NSAttributedString.Key.font: messageFont!])
        let titleTop = EXContractOpenSuccessedView.titleTop
        let contentTop = EXContractOpenSuccessedView.contentTop
        let bottomTop = EXContractOpenSuccessedView.bottomViewTop
        let bottomBottom = EXContractOpenSuccessedView.bottomViewBottom
        self.layViews(titleTop: titleTop, contentTop: contentTop, bottomTop: bottomTop, bottomBottom: bottomBottom)
       
    }
    func layViews(titleTop: CGFloat,contentTop: CGFloat, bottomTop: CGFloat, bottomBottom: CGFloat){
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(titleTop)
            make.left.equalToSuperview().offset(21)
            make.right.equalToSuperview().offset(-21)
            make.bottom.equalToSuperview()
        }
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(contentTop)
            make.width.height.equalTo(140)
            make.centerX.equalToSuperview()
            
        }
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(contentTop)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview()
        }
        surebtn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(bottomTop)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }
        guideBtn.snp.makeConstraints { make in
            make.top.equalTo(surebtn.snp.bottom).offset(12)
            make.width.equalTo(surebtn)
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
        }
        cancelbtn.snp.makeConstraints { make in
            make.top.equalTo(guideBtn.snp.bottom).offset(12)
            make.width.equalTo(surebtn)
            make.centerX.equalToSuperview()
            make.height.equalTo(18)
            make.bottom.equalToSuperview().offset(-bottomBottom)
        }
    }
}

