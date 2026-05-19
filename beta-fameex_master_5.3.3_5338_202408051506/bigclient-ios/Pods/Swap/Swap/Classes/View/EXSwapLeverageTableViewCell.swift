//
//  EXLeverageSliderTableViewCell.swift
//  Chainup
//
//  Created by ZYJ on 2023/11/24.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class EXSwapLeverageTableViewCell: UITableViewCell {
    var maxLevel:String = ""
    var minLevel:String = ""
    var sliderChangedValue:Float = 0
    typealias EXSwapLeverageValueHasChanged = (String) -> ()
    var valueHasChangedBlock:EXSwapLeverageValueHasChanged?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    lazy var lineView: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor.ThemeView.seperator
        line.ext_UseAutoLayout()
        return line
    }()
    lazy var maxCoinTipLabel:UILabel = {
        let label = UILabel(text: "", font: UIFont.ThemeFont.SecondaryRegular, textColor: UIColor.ThemeLabel.colorMedium, alignment: .left)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var leverageInputTitle: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.text = "cp_content_text17".ex_localized()
        return label
    }()
    /// 杠杆输入 English: /Lever input
    lazy var leverageInput: EXSStepInputView = {
        let input = EXSStepInputView()
        input.input.addTarget(self, action: #selector(leveageConTextChange), for: .editingChanged)
        
        return input
    }()
    /// 杠杆滑块 English: /Lever slider
    lazy var slider : EXNewLeverageSliderView = {
        
        return generateSlider()
    }()
    
    func generateSlider() -> EXNewLeverageSliderView {
        let v = EXNewLeverageSliderView(frame: CGRect.init(x: 0, y: 0, width: EXSCREEN_WIDTH - 30, height: 50),minLevel: Int(minLevel) ?? 1 , maxLevel: Int(maxLevel) ?? 100)
                
        v.valueChangedCallback = {[weak self] (value) in
            
            guard let mySelf = self else {
                return
            }
            mySelf.sliderChangedValue = Float(value)
            if mySelf.leverageInput.input.isEditing == false {
                mySelf.leverageInput.input.text = String(value)
            }
            mySelf.valueHasChangedBlock?(String(value))
            
        }
        v.startEdit = {[weak self]  in
            self?.leverageInput.input.resignFirstResponder()
        }
        return v
    }
    
    @objc func leveageConTextChange(sender : UITextField) {
        if (sender.text ?? "0").greaterThan(maxLevel) {
            sender.text = maxLevel
        }
        let value = Float(sender.text ?? "0") ?? 0
        slider.updateSliderValue(value:value)
        valueHasChangedBlock?(String(Int(value)))
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layoutCustomViews()
        backgroundColor = UIColor.ThemeView.bg

        leverageInput.minusBtn.addTarget(self, action: #selector(stepChangeAction(sender:)), for: .touchUpInside)
        leverageInput.plusBtn.addTarget(self, action: #selector(stepChangeAction(sender:)), for: .touchUpInside)
        slider.updateSliderValue(value:20)
        self.selectionStyle = .none
    }
    
    @objc func stepChangeAction(sender:UIButton) {
        if sender == leverageInput.minusBtn {
            slider.updateSliderValue(value: sliderChangedValue - 1)
        }else if sender == leverageInput.plusBtn {
            slider.updateSliderValue(value: sliderChangedValue + 1)
        }
    }
 
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateLever(min:String, max:String) {
        minLevel = min
        maxLevel = max
        if let minValue = Int(min),let maxValue = Int(max) {
            
            slider.updateLever(min: minValue, max: maxValue)
            leveageConTextChange(sender: leverageInput.input)
        }
    }
    
    func layoutCustomViews() {
        self.contentView.exs_addSubViews([leverageInputTitle,leverageInput,slider,maxCoinTipLabel,lineView])
      
        leverageInputTitle.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(20)
            make.top.equalTo(20)
        }
        leverageInput.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(44)
            make.top.equalTo(57)
        }
       
        slider.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(leverageInput.snp.bottom).offset(20)
            make.height.equalTo(50)
        }
        maxCoinTipLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-25)
            make.height.equalTo(30)
            make.top.equalTo(slider.snp.bottom).offset(5)
        }
        lineView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
}

