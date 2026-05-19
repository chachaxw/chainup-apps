//
//  EXCalculateProfitAndLossTC.swift
//  Chainup
//
//  Created by ZYJ on 2023/11/25.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class EXCalculateProfitAndLossTC: UITableViewCell {
    
    func generateTextField() -> EXSTextField {
        let textField = EXSTextField()
        textField.ext_UseAutoLayout()
        textField.enableTitleModel = true
        textField.input.keyboardType = UIKeyboardType.decimalPad
        textField.maxLenth = 20
        return textField
    }
    
    lazy var openPriceField: EXSTextField = {
        let field = generateTextField()
        field.titleLabel.text = "cp_calculator_text8".ex_localized()
        field.setPlaceHolder(placeHolder:"" + "cp_overview_text6".ex_localized())

        return field
    }()
    lazy var closePriceField: EXSTextField = {
        let field = generateTextField()
        field.setPlaceHolder(placeHolder:"" + "cp_overview_text6".ex_localized())
        field.titleLabel.text = "cp_calculator_text3".ex_localized()

        return field
    }()
    lazy var volumeField: EXSTextField = {
        let field = generateTextField()
        field.titleLabel.text = "cp_overview_text8".ex_localized()
        field.setPlaceHolder(placeHolder:"" + "cp_overview_text8".ex_localized())

        return field
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        contentView.backgroundColor = UIColor.ThemeView.bg

        contentView.exs_addSubViews([openPriceField,closePriceField,volumeField])
        openPriceField.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(72)
        }
        closePriceField.snp.makeConstraints { (make) in
            make.top.equalTo(openPriceField.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(72)
        }
        volumeField.snp.makeConstraints { (make) in
            make.top.equalTo(closePriceField.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(72)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateFieldUnit(priceUnit:String,volumeUnit:String) {
        closePriceField.extraLabel.text = priceUnit
        openPriceField.extraLabel.text = priceUnit
        volumeField.extraLabel.text = volumeUnit
    }
    
    func validate() -> Bool {
        if (openPriceField.input.text?.count == 0) {
            EXAlert.showFail(msg:"cp_content_text31".ex_localized() + (openPriceField.titleLabel.text ?? ""))
            return false
        }
        if (closePriceField.input.text?.count == 0) {
            EXAlert.showFail(msg:"cp_content_text31".ex_localized() + (closePriceField.titleLabel.text ?? ""))
            return false
        }
        if (volumeField.input.text?.count == 0) {
            EXAlert.showFail(msg:"cp_content_text31".ex_localized() + (volumeField.titleLabel.text ?? ""))
            return false
        }
        return true
    }
    
    func calculateIncomeValue() {
        
    }
    
}
