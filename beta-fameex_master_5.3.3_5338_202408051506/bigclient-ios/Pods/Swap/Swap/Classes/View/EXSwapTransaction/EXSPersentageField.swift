//
//  EXPersentageField.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/6.
//  Copyright © 2023 zewu wang. All rights reserved.
//

/*
 self.textfieldValueChangeBlock?(value)
 self.textfieldDidBeginBlock?()
 self.textfieldDidEndBlock?()
 */

import UIKit
import RxSwift
import EXKit
///合理高度100 English: /Reasonable height of 100
class EXSPersentageField: EXSBaseField {
    
    @IBOutlet weak var titlable: UILabel!
    @IBOutlet var bgView: EXSPersentBg!
    @IBOutlet var input: UITextField!
    @IBOutlet var symbolLabel: UILabel!
    @IBOutlet var stepStacks: UIStackView!
    var steps: [StepItemView]!
    @IBOutlet var topView: UIView! //顶部iput 背景 English: Top iput background
    @IBOutlet var bottomView: EXCOPersentageBottomView!
    let style = EXSTextFieldStyle()
    typealias EXPersentageSelectViewBtnClickBlock = (String)->()
    var color = UIColor.ThemeLabel.colorHighlight
    var clickBtnBlock:EXPersentageSelectViewBtnClickBlock?
    var total = false // 100%
    var maxValue:String = ""
//    var decimal:String = ""
    
    let disposebg = DisposeBag()
    let prensetArr = ["25","50","75","100"]
    var highLightColor:UIColor = UIColor.ThemeView.highlight {
        didSet {
            //style.highlightColor = highLightColor
        }
    }
    fileprivate lazy var presenter : EXSTextFieldPresenter = {
        return EXSTextFieldPresenter.init(presenter: self)
    }()
    var customBgColor = UIColor() {
        didSet{
            self.backgroundColor = customBgColor
            self.bgView.backgroundColor = customBgColor
            self.bottomView.backgroundColor = customBgColor
            self.stepStacks.backgroundColor = customBgColor
        }
    }
    override func onCreate() {
        super.onCreate()
        self.symbolLabel.textColor = UIColor.ThemeLabel.colorLite
        self.titlable.textColor = UIColor.ThemeLabel.colorMedium
        self.titlable.font = UIFont.ThemeFont.SecondaryBold
        self.titlable.text = "cp_overview_text8".ex_localized()
//        self.input.backgroundColor = UIColor.ThemeView.card2
        self.bgView.backgroundColor = UIColor.ThemeView.card1
        self.presenter.configWithTextField(input: input)
        self.bottomView.backgroundColor = UIColor.ThemeView.card1
        // topView 输入框的父视图背景 English: The parent view background of the topView input box
        self.topView.backgroundColor = UIColor.ThemeView.card2
        self.topView.layer.borderWidth = 0.5
        self.topView.layer.cornerRadius = 4
        self.topView.layer.borderColor = UIColor.ThemeView.card2.cgColor
        self.topView.layer.masksToBounds = true
        style.bindHighlight(textField: input, effectView: self.topView,isBorder: true)
        self.stepStacks.backgroundColor = UIColor.ThemeView.card1
        self.stepStacks.axis = .horizontal
        self.stepStacks.spacing = 5
        self.stepStacks.distribution = .fillEqually
        self.steps = [StepItemView]()
        for (index,p) in prensetArr.enumerated(){
            let item  = StepItemView()
            item.tag = index
            item.title = p
            self.steps.append(item)
            self.stepStacks.addArrangedSubview(item)
            item.clickBlock = { [weak self] index in
                self?.onTapStep(index)
            }
        }
    }
    override func setPlaceHolder(placeHolder: String,font : CGFloat = 14) {
        input.exs_setPlaceHolderAtt(placeHolder, color: UIColor.ThemeLabel.colorDark, font: font)
    }
    
    override func setText(text: String) {
        input.text = text
    }
    
    func emptyPersentage() {
        guard steps != nil else{
            return
        }
        for btn in steps {
            btn.selected = false
        }
        self.total = false
    }
    func fullSelect(){
        for btn in steps {
            btn.selected = true
        }
        self.total = true
    }
    func getPersent(_ byTag:Int) -> String {
        let arr = ["0.25","0.5","0.75","1.0"]
        if arr.count > byTag {
            return arr[byTag]
        }else {
            return ""
        }
    }
    
    func onTapStep(_ index: Int) {
        if self.maxValue.count > 0,self.decimal.count > 0 {
            if let coindecimal = Int16(self.decimal){
                let persent = self.getPersent(index)
                //MARK: 百分比如果百分百直接舍去,如果小于1 直接进位 English: MARK: If the percentage is 100%, round it directly. If it is less than 1, round it directly
                let up = persent == "1.0" ? false : true
                let rst = maxValue.bigMul(persent, decimals: coindecimal,up: up)
                input.text = rst
                input.sendActions(for: .valueChanged)
            }
        }
        self.total = (index == prensetArr.count)
        self.clickBtnBlock?(getPersent(index))
        for (ix,p) in steps.enumerated(){
            if ix <= index{
                p.selected = true
            }else{
                p.selected = false
            }
        }
        switch index {
        case 0:
            EXNewTracking.shared.track(event: .swapordersplaced10, info: [:])
        case 1:
            EXNewTracking.shared.track(event: .swapordersplaced20, info: [:])
        case 2:
            EXNewTracking.shared.track(event: .swapordersplaced50, info: [:])
        case 3:
            EXNewTracking.shared.track(event: .swapordersplaced100, info: [:])
        default:
            EXNewTracking.shared.track(event: .swapordersplaced10, info: [:])
        }
    }
}
class StepItemView: EXCOCustomBaseView{
    var selected = false{
        didSet{
            let color = selected ? UIColor.ThemeView.highlight : UIColor.ThemeView.card2
            line.backgroundColor = color
        }
    }
    var title: String = ""{
        didSet{
            titleLabel.text = title + "%"
        }
    }
    var clickBlock: EXComIntBlock?
    override func setSubView(){
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(click))
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
        self.backgroundColor = .clear
        self.addSubViews([line,titleLabel])
        line.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(6)
            make.width.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(line.snp.bottom).offset(4)
            make.left.right.equalToSuperview()
            make.height.equalTo(16)
        }
    }
    @objc func click(){
        self.clickBlock?(self.tag)
    }
    
    
    
    lazy var line: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.ThemeView.card2
        return v
    }()
    ///名称 English: /Name
    lazy var titleLabel: UILabel = {
        let label = UILabel(text:"", font: UIFont.ThemeFont.SecondaryBold, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.center)
        label.ext_UseAutoLayout()
        return label
    }()
    
    
    
    
    
}
extension EXSPersentageField :EXSTextFieldProtocol {
    
    func textValueChanged(value: String) {
        self.emptyPersentage()
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

class EXSPersentBg:UIView {
    
}





