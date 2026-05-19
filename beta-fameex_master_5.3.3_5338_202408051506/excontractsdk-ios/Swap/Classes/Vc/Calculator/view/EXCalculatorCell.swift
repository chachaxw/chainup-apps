//
//  EXCalculatorCell.swift
//  Chainup
//
//  Created by cwd on 2022/11/14.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import EXKit
//输入框 English: Input box
class EXCalculatorInputCell: UITableViewCell {
    var volumeVaild = EXSInputLimitDelegate()
    var textChageBlock: EXComVoidBlock?
    var inputModel: EXSInputItemModel? {
        didSet{
            guard inputModel != nil else{return}
            borderTF.leftLabel.text = inputModel?.title
            borderTF.unitLabel.text = inputModel?.unit
            borderTF.input.text = inputModel?.value

            if let dec = inputModel?.decimal,dec > 0 {
                self.volumeVaild.limetValue = Int(dec)
                borderTF.input.delegate = self.volumeVaild
                borderTF.input.keyboardType = .decimalPad
            }else{
                borderTF.input.delegate = nil
                borderTF.input.keyboardType = .numberPad
            }
        }
    }
     //68 + 16 (顶部间距) English: 68+16 (top spacing)
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configView()
        self.backgroundColor = UIColor.ThemeView.bg
        self.contentView.backgroundColor = UIColor.ThemeView.bg
        self.selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var borderTF: EXSBorderField = {
        let textField = EXSBorderField()
        textField.titleTop = true
        textField.ext_UseAutoLayout()
        textField.input.textColor = UIColor.ThemeLabel.colorLite
        textField.bgView.layer.cornerRadius = 4
        textField.maxLenth = 9
        textField.setPlaceHolder(placeHolder: "cp_content_text31".ex_localized())
        textField.leftLabel.text = "cp_overview_text15".ex_localized()
        textField.textfieldValueChangeBlock = {[weak self]str in
            guard let mySelf = self else{return}
            mySelf.inputModel?.value = str
            mySelf.textChageBlock?()
        }
        textField.unitLabel.textColor = UIColor.ThemeLabel.colorLite
        textField.backgroundColor = UIColor.ThemeView.bg
        textField.bgView.backgroundColor = UIColor.ThemeView.card2
        textField.input.keyboardType = UIKeyboardType.decimalPad
        return textField
    }()
}
extension EXCalculatorInputCell{
    func configView(){
        self.contentView.addSubview(borderTF)
        borderTF.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview()
        }
    }
}

class EXCalculatorResultCell: UITableViewCell {
    
    
    var inputModel: EXSInputItemModel? {
        didSet{
            guard inputModel != nil else{return}
            titleLabel.text = inputModel?.title
            valueLabel.text = inputModel?.value
        }
    }
    
     //20 + 12 (顶部间距) English: 20+12 (top spacing)
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = UIColor.ThemeView.bg
        configView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    ///名称 English: /Name
    lazy var titleLabel: UILabel = {
        let label = UILabel(text:"", font: UIFont.ThemeFont.BodyMedium, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    ///
    lazy var valueLabel: UILabel = {
        let label = UILabel(text:"", font: UIFont.ThemeFont.BodyMedium, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.right)
        label.ext_UseAutoLayout()
        return label
    }()
}

extension EXCalculatorResultCell{
    
    //
    func configView(){
        self.contentView.addSubViews([titleLabel,valueLabel])
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(12)
        }
        valueLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(12)
        }
    }
}


class EXCalculatorTipCell: EXBaseTableViewCell {
    
    override func setUpView() {
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview()//.offset(-5)
        }
    }
    ///
    lazy var titleLabel: UILabel = {
        let label = UILabel(text: "cp_calculator_text42".ex_localized(), font: UIFont.Ex.regular(12), textColor: .Ex.warning1, alignment: NSTextAlignment.left)
        label.numberOfLines = 0
        label.ext_UseAutoLayout()
        return label
    }()
    
    static func getCellHeight() -> CGFloat{
        let maxWidth:CGFloat = Device_W - 16 * 2
        return "cp_calculator_text42".ex_localized().textHeightForLabel(font: UIFont.Ex.regular(12), width: maxWidth) + 5
    }
}


