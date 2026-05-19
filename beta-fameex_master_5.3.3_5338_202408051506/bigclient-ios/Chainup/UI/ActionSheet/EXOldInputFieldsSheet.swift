//
//  EXInputFieldsSheet.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/8.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXOldInputFieldsSheet :NibBaseView {
    var rxField:UITextField?
    typealias SheetBtnCallback = (String) -> ()
    var sheetTapCallback : SheetBtnCallback?
    var inputItem = EXTextField()
    var smsCodeField = EXCountField()
    var pasteField = EXPasteField()
    private var model:EXOldInputSheetModel?
    lazy var errorTipLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeState.fail
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.textAlignment = .left
        label.layoutIfNeeded()
        label.isHidden = true
        return label
    }()
    var modelKey:String?
    var modelValue:String?
    
    @IBOutlet var container: UIView!
    
    override func onCreate() {
        
    }
    func autoSendMeg(){
        if self.model?.type == .sms{
            if let v = self.container.subviews.first{
                if let sub  = v as? EXCountField{
                    sub.justFire()
                }
            }
        }
    }
    
    func updateError(model:EXOldInputSheetModel){
        let color: UIColor = model.errorTipShow ? .red : .Ex.fill4
        var v = UIView()
        switch model.type {
        case .sms:
            v = smsCodeField
            self.smsCodeField.baseLine.backgroundColor = color
        case .paste:
            v = pasteField
            self.pasteField.baseLine.backgroundColor = color
        default:
            break
        }
        errorTipLabel.isHidden = !model.errorTipShow
        errorTipLabel.text = model.errorTip
        let height = model.errorTipShow ? 15 : 0
        let top = model.errorTipShow ? 5 : 0
        errorTipLabel.snp.updateConstraints { make in
            make.top.equalTo(v.snp.bottom).offset(top)
            make.height.equalTo(height)
        }
    }
    
    func hideError(model:EXOldInputSheetModel){
        let color: UIColor = .Ex.main1
        var v = UIView()
        switch model.type {
        case .sms:
            v = smsCodeField
            self.smsCodeField.baseLine.backgroundColor = color
        case .paste:
            v = pasteField
            self.pasteField.baseLine.backgroundColor = color
        default:
            break
        }
        errorTipLabel.isHidden = true
//        errorTipLabel.text = model.errorTip
//        let height = model.errorTipShow ? 15 : 0
//        let top = model.errorTipShow ? 5 : 0
//        errorTipLabel.snp.updateConstraints { make in
//            make.top.equalTo(v.snp.bottom).offset(top)
//            make.height.equalTo(height)
//        }
    }
    
    func configItemModel(model:EXOldInputSheetModel) {
        for item in self.container.subviews {
            item.removeFromSuperview()
        }
        self.model = model
        self.modelKey = model.key
        if model.inputText.count > 0 {
            self.modelValue = model.inputText
        }
        switch model.type {
        case .input:
            let input = EXTextField()
            input.enableTitleModel = model.enableTitleMode
            input.input.keyboardType = model.keyboard
            input.enablePrivacyModel = model.enablePrivacy
            input.setText(text: model.inputText)
            input.enableTitleModel = model.title.count > 0
            input.setTitle(title: model.title)
            input.setPlaceHolder(placeHolder: model.inputPlaceHoloder)
            container.addSubview(input)
            input.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            input.textfieldValueChangeBlock = {[weak self] text in
                self?.valueChanged(text: text)
            }
            input.setExtraText(model.unit)
            
            if model.errorTipShow == true {
                errorTipLabel.text = model.errorTip
                container.addSubview(errorTipLabel)
                input.snp.remakeConstraints { (make) in
                    make.top.left.right.equalToSuperview()
                }
                
                errorTipLabel.snp.makeConstraints { make in
                    make.top.equalTo(input.snp.bottom).offset(5)
                    make.left.right.bottom.equalToSuperview()
                    make.height.equalTo(15)
                }
            }
            input.titleLabel.textColor = UIColor.ThemeLabel.colorLite
            self.rxField = input.input
            self.inputItem = input
            break
        case .sms:
            let smsCount = EXCountField()
            smsCount.supportVoiceCode = false
            smsCount.setText(text: model.inputText)
            smsCount.enableTitleModel = model.title.count > 0
            smsCount.setTitle(title: model.title)
            smsCount.input.keyboardType = model.keyboard
            smsCount.tapAction.titleLabel?.font = UIFont.Ex.medium(14)
            smsCount.setPlaceHolder(placeHolder: model.inputPlaceHoloder)
            smsCount.titleLabel.textColor = UIColor.ThemeLabel.colorLite
            smsCount.titleLabel.font = UIFont.ThemeFont.BodyBold
            smsCount.timeLabel.font = UIFont.ThemeFont.BodyBold
            container.addSubview(smsCount)
            smsCount.resendCallback = {[weak self] _ in
                self?.sheetTapCallback?(model.key)
            }

            smsCount.textfieldValueChangeBlock = {[weak self] text in
                self?.valueChanged(text: text)
            }
            
            errorTipLabel.text = model.errorTip
            container.addSubview(errorTipLabel)
            errorTipLabel.isHidden = true
            smsCount.snp.remakeConstraints { (make) in
                make.top.left.right.equalToSuperview()
            }
            
            errorTipLabel.snp.makeConstraints { make in
                make.top.equalTo(smsCount.snp.bottom).offset(0)
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(0)
            }
            self.rxField = smsCount.input
            smsCodeField = smsCount
            break
        case .paste:
            let input = EXPasteField()
            input.showTitle = model.title.count > 0
            input.input.keyboardType = model.keyboard
            input.setText(text: model.inputText)
            input.setTitle(title: model.title)
            input.titleLabel.font = UIFont.ThemeFont.BodyBold
            input.setPlaceHolder(placeHolder: model.inputPlaceHoloder)
            input.pasteBtn.setTitleColor(UIColor.Ex.main4, for: .normal)
            input.pasteBtn.titleLabel?.font = UIFont.Ex.medium(14)
            container.addSubview(input)
            input.textfieldValueChangeBlock = {[weak self] text in
                self?.valueChanged(text: text)
            }
            
            errorTipLabel.text = model.errorTip
            container.addSubview(errorTipLabel)
            errorTipLabel.isHidden = true
            input.snp.remakeConstraints { (make) in
                make.top.left.right.equalToSuperview()
            }
            errorTipLabel.snp.makeConstraints { make in
                make.top.equalTo(input.snp.bottom).offset(0)
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(0)
            }
            self.rxField = input.input
            self.pasteField = input
            input.titleLabel.textColor = UIColor.ThemeLabel.colorLite
            break
        }
    }
    
    func valueChanged(text:String) {
        if let model = self.model {
            model.inputText = text
            self.modelKey = model.key
            self.modelValue = text
            hideError(model: model)
        }
    }
}
