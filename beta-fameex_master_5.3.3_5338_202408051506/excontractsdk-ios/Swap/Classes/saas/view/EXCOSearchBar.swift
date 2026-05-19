//
//  EXSearchBar.swift
//  EXKit_Example
//
//  Created by cwd on 2022/7/13.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import EXKit

public class EXCOCustomBaseView: UIView{
    class var viewHeight: CGFloat{
        return 0
    }
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
        setSubView()
        setData()
    }
}
public class EXCOSearchBar: EXCOCustomBaseView {
    
    var canbtnBlock: EXComVoidBlock?
    public var showCancelBtn: Bool = true {
        didSet{
            canceBtn.isHidden = !showCancelBtn
        }
    }
    public var placeHoder: String = "" {
        didSet{
            textField.setPlaceHolder(placeHolder:placeHoder)
        }
    }
    //输入框的背景色 English: The background color of the input box
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
        arrowImmg.image = UIImage.exs_themeImageNamed(imageName: "public_search")
        return arrowImmg
    }()

    lazy var textField : EXSTextField = {
        let text = EXSTextField()
        text.backgroundColor =  UIColor.ThemeView.bg
        text.extUseAutoLayout()
        text.enableTitleModel = false
        text.enablePrivacyModel = false
        text.baseLine.isHidden = true
        text.setPlaceHolder(placeHolder: "assets_action_search".ex_localized())
        text.titleLabel.font = UIFont.ThemeFont.BodyRegular
        text.titleLabel.textColor = UIColor.ThemeLabel.colorDark
        text.input.returnKeyType = .search
//        text.textfieldValueChangeBlock = {[weak self]str in
//            print(str)
//            self?.textfieldValueChangeBlock?()
//        }
//        text.input.returnKeyType = .go
        return text
    }()
    
    
    lazy var canceBtn: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(UIColor.ThemeLabel.colorLite, for: .normal)
        btn.titleLabel?.font = UIFont.ThemeFont.BodyRegular
        btn.addTarget(self, action: #selector(clickBtn), for: UIControl.Event.touchUpInside)
        btn.setTitle("cp_overview_text56".ex_localized(), for: .normal)
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
            make.width.equalTo(60)
            make.height.equalToSuperview()
        }
        self.addSubview(coverBtn)
        coverBtn.isHidden = true
        coverBtn.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @objc func clickBtn(){
//        //print("cancel")
        self.canbtnBlock?()
    }
    @objc func coverBtnClick(){
//        EXNavigationHandler.sharedHandler.commonJumpCommand(EXRouterActionKey.appSearch.rawValue)
    }
}

