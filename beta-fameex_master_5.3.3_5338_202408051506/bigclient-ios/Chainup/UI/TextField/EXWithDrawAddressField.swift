//
//  EXWithDrawAddressField.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/8.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXWithDrawAddressField: EXBaseField {
    var addressListPopBack: EXComVoidBlock?
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var scanBtn: UIButton!
    @IBOutlet var addressBtn: UIButton!
    @IBOutlet var seperatorLine: UIView!
    @IBOutlet var baseLine: UIView!
    
    @IBOutlet var input: UITextField!
    let style = EXTextFieldStyle.commonStyle
   
    lazy var coverbtn : RepeatButton = {
        let btn = RepeatButton()
        btn.addTarget(self, action: #selector(clickBtn), for: UIControl.Event.touchUpInside)
        btn.isHidden = true
        return btn
    }()
    fileprivate lazy var presenter : EXTextFieldPresenter = {
        return EXTextFieldPresenter.init(presenter: self)
    }()

    override func onCreate() {
        super.onCreate()
        style.bindHighlight(textField: input, effectView: baseLine)
        presenter.configWithTextField(input: input)
        scanBtn.imageView?.contentMode = .scaleAspectFit
        scanBtn.setImage(UIImage.themeImageNamed(imageName: "home_scancode"), for: .normal)
        addressBtn.imageView?.contentMode = .scaleAspectFit
        addressBtn.setImage(UIImage.themeImageNamed(imageName: "assets_withdrawaladdress"), for: .normal)
        addressBtn.setTitle("", for: .normal)
        
        self.addSubview(coverbtn)
        coverbtn.snp.makeConstraints { make in
            make.edges.equalTo(input)
        }
    }
    
    func switchWhiteAddressListMode(){
        self.input.isUserInteractionEnabled = false
        scanBtn.isHidden = true
        coverbtn.isHidden = false
        
    }
    
    @objc func clickBtn(){
        self.addressListPopBack?()
    }
    
    
    override func setPlaceHolder(placeHolder: String , font : CGFloat = 14) {
        input.setPlaceHolderAtt(placeHolder, color: UIColor.ThemeLabel.colorDark, font: font)
    }
    
    override func setText(text: String) {
        input.text = text
        input.sendActions(for: .valueChanged)
    }
    
    override func setTitle(title: String) {
        titleLabel.text = title
    }
    
    func onlyScan() {
        addressBtn.isHidden = true
        seperatorLine.isHidden = true 
    }
}

extension EXWithDrawAddressField : EXTextFieldPresenterProtocol {
    
    func textValueChanged(value: String) {
        self.textfieldValueChangeBlock?(value)
    }
    
    func inputDidBeginEditing() {
        self.hideError(input)
        self.textfieldDidBeginBlock?()
    }
    
    func inputDidEndEditing() {
        self.textfieldDidEndBlock?()
    }
}

extension EXWithDrawAddressField : EXTextFieldConfigurable {
    
    var baseField: UITextField {
        return self.input
    }
    
    var baseHighlight: UIView {
        return self.baseLine
    }
}
