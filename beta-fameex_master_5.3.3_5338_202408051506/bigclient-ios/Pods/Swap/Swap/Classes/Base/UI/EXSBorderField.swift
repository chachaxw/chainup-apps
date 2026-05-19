//
//  EXBorderField.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/14.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
class EXSBorderField: EXSBaseField {
    //高度 66 English: Height 66
    @IBOutlet weak var bgTopConstraint: NSLayoutConstraint!
    @IBOutlet var bgView: UIView!
    @IBOutlet var unitLabel: UILabel!
    @IBOutlet var input: UITextField!
    var onlyInput = false { //
        didSet{
            input.leftView = nil
            unitLabel.isHidden = true
            bgView.snp.remakeConstraints { make in
                make.top.left.equalToSuperview().offset(1)
                make.bottom.right.equalToSuperview().offset(-1)
            }
            input.snp.remakeConstraints { make in
                make.centerX.equalToSuperview()
            }
        }
    }
    var titleTop = false{//将input 的左侧调整到顶部 English: Adjust the left side of the input to the top
        didSet{
            if titleTop{
                //将input 的左侧调整到顶部 English: Adjust the left side of the input to the top
                input.leftView = nil
                self.addSubview(leftLabel)
                self.bgTopConstraint.constant = 22
                //标题高度为 English: Title height is
                leftLabel.snp.makeConstraints { make in
                    make.top.equalToSuperview()
                    make.left.equalToSuperview()//.offset(16)
                    make.height.equalTo(15)
                }
                self.bgView.backgroundColor = UIColor.ThemeView.card1
            }
        }
    }
    var placeHoderCenter : Bool = false
    var customBgColor = UIColor(){
        didSet{
            self.backgroundColor = customBgColor
            self.bgView.backgroundColor = customBgColor
            self.bgView.backgroundColor = UIColor.ThemeView.card2
        }
    }
    
    let style = EXSTextFieldStyle.commonStyle
    fileprivate lazy var presenter : EXSTextFieldPresenter = {
        return EXSTextFieldPresenter.init(presenter: self)
    }()
    lazy var tfVaild:Observable<Bool>  = presenter.vailded!
    /// 市价提示框 - 平仓时用的 English: /Market price prompt box - used for closing positions
    lazy var marketPriceLabel : UILabel = {
        let label = UILabel()
        label.ext_UseAutoLayout()
        label.backgroundColor = UIColor.ThemeBtn.disable
        label.text = "   " + "cp_overview_text36".ex_localized()
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont.ThemeFont.BodyRegular
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.layer.borderWidth = 0.5
        label.layer.borderColor = UIColor.ThemeView.card2.cgColor
        label.isHidden = true
        label.textAlignment = .left
        return label
    }()
    
    
    lazy var leftView:UIView = {
        let ret = UIView()
        ret.addSubview(leftLabel)
        leftLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        return ret
    }()
    lazy var leftLabel:UILabel = {
       let ret = UILabel()
        ret.font = UIFont.systemFont(ofSize: 14)
        ret.textColor = UIColor.ThemeLabel.colorMedium
        return ret
    }()
    //占位居中 English: Centered occupancy
    lazy var placeLabel:UILabel = {
       let ret = UILabel()
        ret.font =  UIFont.ThemeFont.BodyRegular// UIFont.systemFont(ofSize: 14)
        ret.textColor = UIColor.ThemeLabel.colorMedium
        ret.textAlignment = .center
        return ret
    }()
    override func onCreate() {
        super.onCreate()
        self.backgroundColor = UIColor.ThemeView.card1
        self.bgView.backgroundColor = UIColor.ThemeView.card2
        style.showHilights(on: false, effectView: bgView, borderHighlight: true)
        style.bindHighlight(textField: input, effectView: bgView,isBorder:true)
        style.showHilights(on: false, effectView: bgView, borderHighlight: true)
        presenter.configWithTextField(input: input)
        input.leftView = leftView
        self.presenter.configWithTextField(input: input)
        self.addSubview(marketPriceLabel)
        marketPriceLabel.snp.makeConstraints { make in
            make.edges.equalTo(self.bgView)
        }
    }
    
    override func setPlaceHolder(placeHolder: String , font : CGFloat = 14) {
        
        if input.leftViewMode == .always {
            
            leftLabel.text = placeHolder + "    "
            input.exs_setPlaceHolderAtt("cp_content_text31".ex_localized(), color: UIColor.ThemeLabel.colorDark, font: font)

        }else {
            
            input.exs_setPlaceHolderAtt(placeHolder, color: UIColor.ThemeLabel.colorDark, font: font)
        }

    }
    ///占位符居中显示 English: /Placeholder centered display
    func setPlaceHolderCenter(placeHolder:String ,color: UIColor = UIColor.ThemeLabel.colorDark, font: UIFont = UIFont.ThemeFont.BodyRegular){
        self.addSubview(placeLabel)
        placeLabel.snp.makeConstraints { make in
            make.center.equalTo(self.input)
        }
        placeLabel.text = placeHolder
    }
    
    override func setText(text: String) {
        input.text = text
    }
    
    func setUnitText(text:String) {
        unitLabel.text = text
    }

}

extension EXSBorderField : EXSTextFieldProtocol {
    
    func textValueChanged(value: String) {
        if placeHoderCenter{
            placeLabel.isHidden = value.count > 0
        }
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

extension EXSBorderField : EXSTextFieldConfigurable {
    
    var baseField: UITextField {
        return self.input
    }
    
    var baseHighlight: UIView {
        return self.bgView
    }
}





class EXSNewBorderField: EXSNewBaseField {
    //高度 66 English: Height 66
    var bgTopConstraint: NSLayoutConstraint!
    
    
    lazy var bgView: UIView = {
        let v = UIView()
        return v
    }()
    lazy var unitLabel: UILabel = {
        let v = UILabel()
        return v
    }()
    lazy var input: UITextField = {
        let v = UITextField()
        return v
    }()
    
    var onlyInput = false { //
        didSet{
            input.leftView = nil
            unitLabel.isHidden = true
            bgView.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            input.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(10)
                make.top.equalToSuperview().offset(8)
                make.bottom.equalToSuperview().offset(-8)
                make.right.equalToSuperview().offset(-10)
            }
        }
    }
    var titleTop = false{
        didSet{
            if titleTop{
                //将input 的左侧调整到顶部 English: Adjust the left side of the input to the top
                input.leftView = nil
                self.addSubview(leftLabel)
                self.bgTopConstraint.constant = 26
                leftLabel.snp.makeConstraints { make in
                    make.top.equalToSuperview()
                    make.left.equalToSuperview()//.offset(16)
                    make.height.equalTo(16)
                }
                self.bgView.backgroundColor = UIColor.ThemeView.card1
            }
        }
    }
    var placeHoderCenter : Bool = false
    var customBgColor = UIColor(){
        didSet{
            self.backgroundColor = customBgColor
            self.bgView.backgroundColor = customBgColor
            self.bgView.backgroundColor = UIColor.ThemeView.card2
        }
    }
    
    let style = EXSTextFieldStyle.commonStyle
    fileprivate lazy var presenter : EXSTextFieldPresenter = {
        return EXSTextFieldPresenter.init(presenter: self)
    }()
    lazy var tfVaild:Observable<Bool>  = presenter.vailded!
    lazy var leftView:UIView = {
        let ret = UIView()
        ret.addSubview(leftLabel)
        leftLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        return ret
    }()
    lazy var leftLabel:UILabel = {
       let ret = UILabel()
        ret.font = UIFont.systemFont(ofSize: 14)
        ret.textColor = UIColor.ThemeLabel.colorMedium
        return ret
    }()
    //占位居中 English: Centered occupancy
    lazy var placeLabel:UILabel = {
       let ret = UILabel()
        ret.font =  UIFont.ThemeFont.BodyRegular// UIFont.systemFont(ofSize: 14)
        ret.textColor = UIColor.ThemeLabel.colorMedium
        ret.textAlignment = .center
        return ret
    }()
    func onCreate() {
        self.backgroundColor = UIColor.ThemeView.card1
        self.bgView.backgroundColor = UIColor.ThemeView.card2
        style.showHilights(on: false, effectView: bgView, borderHighlight: true)
        style.bindHighlight(textField: input, effectView: bgView,isBorder:true)
        style.showHilights(on: false, effectView: bgView, borderHighlight: true)
        presenter.configWithTextField(input: input)
        input.leftView = leftView
        self.presenter.configWithTextField(input: input)
//        self.addSubview(marketPriceLabel)
//        marketPriceLabel.snp.makeConstraints { make in
//            make.edges.equalTo(self.bgView)
//        }
    }
    override func setSubView() {
        self.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        bgView.exs_addSubViews([input,unitLabel])
        input.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
        }
        unitLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.left.equalTo(input.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
        onCreate()
    }
    
    override func setPlaceHolder(placeHolder: String , font : CGFloat = 14) {
        
        if input.leftViewMode == .always {
            
            leftLabel.text = placeHolder + "    "
            input.exs_setPlaceHolderAtt("cp_content_text31".ex_localized(), color: UIColor.ThemeLabel.colorDark, font: font)

        }else {
            
            input.exs_setPlaceHolderAtt(placeHolder, color: UIColor.ThemeLabel.colorDark, font: font)
        }

    }
    ///占位符居中显示 English: /Placeholder centered display
    func setPlaceHolderCenter(placeHolder:String ,color: UIColor = UIColor.ThemeLabel.colorDark, font: UIFont = UIFont.ThemeFont.BodyRegular){
        self.addSubview(placeLabel)
        placeLabel.snp.makeConstraints { make in
            make.center.equalTo(self.input)
        }
        placeLabel.text = placeHolder
    }
    
    override func setText(text: String) {
        input.text = text
    }
    
    func setUnitText(text:String) {
        unitLabel.text = text
    }

}

extension EXSNewBorderField : EXSTextFieldProtocol {
    
    func textValueChanged(value: String) {
        if placeHoderCenter{
            placeLabel.isHidden = value.count > 0
        }
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

extension EXSNewBorderField : EXSTextFieldConfigurable {
    
    var baseField: UITextField {
        return self.input
    }
    
    var baseHighlight: UIView {
        return self.bgView
    }
}




