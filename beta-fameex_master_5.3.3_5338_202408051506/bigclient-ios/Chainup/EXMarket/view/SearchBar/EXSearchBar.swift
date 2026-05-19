//
//  EXSearchBar.swift
//  EXKit_Example
//
//  Created by cwd on 2022/7/13.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import EXKit

public class EXCustomBaseView: UIView{
    override init(frame: CGRect){
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeView.bg
        setSubView()
        setData()
    }
    
    func setSubView(){
        
    }
    func setData(){
        
    }
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
//        fatalError("init(coder:) has not been implemented")
        setSubView()
        setData()
    }
}
public class EXSearchBar: EXCustomBaseView {
    public var toContract = false
    public var showCancelBtn: Bool = true {
        didSet{
            canceBtn.isHidden = true
        }
    }
    public var placeHoder: String = "" {
        didSet{
            textField.setPlaceHolder(placeHolder:placeHoder)
        }
    }
    //The background color of the input box
    public var bgColor: UIColor? {
        didSet{
            guard let bgColor = bgColor else {
                return
            }
            searchBarContainer.backgroundColor = bgColor
            textField.backgroundColor = bgColor
            textField.input.backgroundColor = bgColor
        }
    }
    public var enableSearch: Bool = true {
        didSet{
            coverBtn.isHidden = enableSearch
        }
    }
    
    
    lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fill
        stack.spacing = 16
        stack.axis = .horizontal
        stack.alignment = .fill
        return stack
    }()
    
    lazy var searchBarContainer: UIView = {
        let v = UIView()
        v.extSetCornerRadius(15)
        return v
    }()
    lazy var searchImg : UIImageView = {
        let arrowImmg = UIImageView()
        arrowImmg.contentMode = .scaleAspectFit
        arrowImmg.image = UIImage.themeImageNamed(imageName: "public_search")
        return arrowImmg
    }()

    lazy var textField : EXTextField = {
        let text = EXTextField()
        text.backgroundColor =  UIColor.ThemeView.bg
        text.extUseAutoLayout()
        text.enableTitleModel = false
        text.enablePrivacyModel = false
        text.baseLine.isHidden = true
//        text.extraLabel.text = "xxx-btc"
        text.setPlaceHolder(placeHolder: "filter_Input_placeholder".localized())
        text.titleLabel.font = UIFont.ThemeFont.BodyRegular
        text.titleLabel.textColor = UIColor.ThemeLabel.colorDark
//        text.textfieldValueChangeBlock = {[weak self]str in
//            print(str)
//            self?.textfieldValueChangeBlock?()
//        }
        return text
    }()
    
    
    lazy var canceBtn: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(UIColor.ThemeLabel.colorLite, for: .normal)
        btn.addTarget(self, action: #selector(clickBtn), for: UIControl.Event.touchUpInside)
        btn.setTitle("common_text_btnCancel".localized(), for: .normal)
        return btn
    }()
    
    lazy var coverBtn: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(coverBtnClick), for: UIControl.Event.touchUpInside)
        return btn
    }()
    
    
     override func setSubView(){
        self.backgroundColor = UIColor.ThemeView.bg
        self.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
          
        }
        searchBarContainer.addSubViews([searchImg, textField])
        searchImg.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        textField.snp.makeConstraints { make in
            make.left.equalTo(searchImg.snp.right).offset(5)
            make.right.equalToSuperview()
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
//            make.height.equalTo(35)
        }
        
        
        stack.addArrangedSubview(searchBarContainer)
        stack.addArrangedSubview(canceBtn)
        canceBtn.snp.makeConstraints { make in
            make.width.equalTo(40)
            make.height.equalToSuperview()
        }
        self.addSubview(coverBtn)
        coverBtn.isHidden = true
        coverBtn.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @objc func clickBtn(){
    }
    @objc func coverBtnClick(){
        if self.toContract == true {
            EXNavigationHandler.sharedHandler.commonJumpCommand(EXRouterActionKey.appSearch.rawValue,"contract")
        }else{
            EXNavigationHandler.sharedHandler.commonJumpCommand(EXRouterActionKey.appSearch.rawValue)
        }
        
    }
}

