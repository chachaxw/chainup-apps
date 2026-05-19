//
//  EXSCalcuLeverView.swift
//  Chainup
//
//  Created by ZYJ on 2023/6/8.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
class EXSCalcuLeverView: UITableViewCell {
   //高 16 + 66 + 8 + 16 English: High 16+66+8+16
    var maxLevel:String = ""
    var minLevel:String = ""
    
    var inputModel = EXSInputItemModel() {
        didSet{
            self.input.leftLabel.text = inputModel.title
            self.input.input.text = inputModel.value
            self.vauleLabel.text = inputModel.placeHoder
        }
    }
    typealias EXSwapLeverageValueHasChanged = () -> ()
    var inputFieldValueChangedBlock:EXSwapLeverageValueHasChanged?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        configView()
    }
    
    lazy var minusBtn:UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.exs_themeImageNamed(imageName: "public_icon_add"), for: .normal)
//        let path = UIBezierPath()
//        path.move(to: CGPoint(x: 4, y: 0.5))
//        path.addQuadCurve(to: CGPoint(x: 0, y: 4.5), controlPoint: CGPoint(x: 0, y: 0.5))
//        path.addLine(to: CGPoint(x: 0, y: 35.5))
//        path.addQuadCurve(to: CGPoint(x: 4, y: 39.5), controlPoint: CGPoint(x: 0, y: 39.5))
//        let shaperLayer = CAShapeLayer()
//        shaperLayer.path = path.cgPath
//        shaperLayer.lineWidth = 0.5
//        shaperLayer.fillColor = nil
//        shaperLayer.strokeColor = UIColor.ThemeView.border.cgColor
//        btn.layer.addSublayer(shaperLayer)
//        let path2 = UIBezierPath()
//        path2.move(to: CGPoint(x: 44, y: 0))
//        path2.addLine(to: CGPoint(x: 44, y: 40))
//        let shaperLayer2 = CAShapeLayer()
//        shaperLayer2.path = path2.cgPath
//        shaperLayer2.lineWidth = 0.5
//        shaperLayer2.fillColor = nil
//        shaperLayer2.strokeColor = UIColor.ThemeView.border.cgColor
//        btn.layer.addSublayer(shaperLayer2)
        return btn
    }()
    
    lazy var plusBtn:UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.exs_themeImageNamed(imageName: "public_icon_reduce"), for: .normal)
        return btn
    }()
    
    /// 杠杆 English: /Levers
    lazy var input: EXSBorderField = {
        let textField = EXSBorderField()
        textField.ext_UseAutoLayout()
        textField.titleTop = true
        textField.input.textColor = UIColor.ThemeLabel.colorLite
        textField.maxLenth = 9
        textField.input.keyboardType = .numberPad
        textField.bgView.layer.cornerRadius = 4
        textField.setPlaceHolder(placeHolder:"cp_content_text17".ex_localized())
        textField.unitLabel.isHidden = true
        textField.textfieldValueChangeBlock = {[weak self]str in
            guard let mySelf = self else{return}
            mySelf.inputModel.value = str.removeAllSapce
            mySelf.inputFieldValueChangedBlock?()
        }
        textField.exs_addSubViews([minusBtn,plusBtn])
        textField.input.snp.remakeConstraints { (make) in
            make.left.equalTo(12)
            make.centerY.equalToSuperview()
            make.right.equalTo(-76)
        }
        textField.backgroundColor = UIColor.ThemeView.bg
        textField.bgView.backgroundColor =  UIColor.ThemeView.card2
        self.minusBtn.snp.makeConstraints { (make) in
            make.right.equalTo(self.plusBtn.snp.left)
            make.width.equalTo(44)
            make.centerY.equalTo(textField.input)
        }
        self.plusBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.width.equalTo(44)
            make.centerY.equalTo(textField.input)
        }
        return textField
    }()
    //杠杆持仓 English: Leveraged position
    lazy var maxCoinTipLabel:UILabel = {
        let label = UILabel(text: "", font: UIFont.ThemeFont.SecondaryRegular, textColor: UIColor.ThemeLabel.colorMedium, alignment: .left)
        label.numberOfLines = 0
        label.text = "cp_calculator_text7".ex_localized()
        return label
    }()
    lazy var vauleLabel:UILabel = {
        let label = UILabel(text: "", font: UIFont.ThemeFont.SecondaryRegular, textColor: UIColor.ThemeLabel.colorLite, alignment: .right)
        label.numberOfLines = 0
        return label
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
}

extension EXSCalcuLeverView{
    func configView(){
        self.backgroundColor = UIColor.ThemeView.bg
        self.contentView.backgroundColor = UIColor.ThemeView.bg
        self.contentView.addSubview(input)
        self.contentView.addSubview(maxCoinTipLabel)
        self.contentView.addSubview(vauleLabel)
        minusBtn.addTarget(self, action: #selector(stepChangeAction(sender:)), for: .touchUpInside)
        plusBtn.addTarget(self, action: #selector(stepChangeAction(sender:)), for: .touchUpInside)
        input.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(66)
        }
        maxCoinTipLabel.snp.makeConstraints { (make) in
            make.top.equalTo(input.snp.bottom).offset(8)
            make.leading.equalTo(input)
            make.height.equalTo(16)
        }
        vauleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(input.snp.bottom).offset(8)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(16)
        }
        
    }
    
    @objc func stepChangeAction(sender:UIButton) {
        if let text = self.input.input.text {
            
            if sender == minusBtn {
                self.input.input.text = text.bigSub("1")
            }else if sender == plusBtn {
                self.input.input.text = text.bigAdd("1")
            }
        }
        inputFieldValueChangedBlock?()
    }
}

