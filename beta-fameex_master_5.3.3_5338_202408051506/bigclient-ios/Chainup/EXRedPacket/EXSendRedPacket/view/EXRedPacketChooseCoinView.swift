//
//  EXRedPacketChooseCoinView.swift
//  Chainup
//
//  Created by zewu wang on 2023/7/2.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXRedPacketChooseCoinView: UIView {
    
    typealias ClickConfirmBlock = (EXRedPakcetPublicInfoManagerEntity) -> ()
    var clickConfirmBlock : ClickConfirmBlock?//Click on the confirm button
    
    typealias ClickCancelBlock = () -> ()
    var clickCancelBlock : ClickCancelBlock?//Click the cancel button

    var rowDatas : [EXRedPakcetPublicInfoManagerEntity] = []
    {
        didSet{
            if rowDatas.count > 0{
                entity = rowDatas[0]
            }
        }
    }
    
    var entity = EXRedPakcetPublicInfoManagerEntity()
    
    //247
    lazy var comfirBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.setTitleColor(UIColor.ThemeLabel.colorHighlight, for: UIControl.State.normal)
        btn.titleLabel?.font = UIFont.ThemeFont.BodyBold
        btn.setTitle("common_text_btnConfirm".localized(), for: UIControl.State.normal)
        btn.setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 10)
        btn.layoutIfNeeded()
        btn.extSetAddTarget(self, #selector(clickConfirmBtn))
        return btn
    }()
    
    lazy var cancelBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: UIControl.State.normal)
        btn.titleLabel?.font = UIFont.ThemeFont.BodyBold
        btn.setTitle("common_text_btnCancel".localized(), for: UIControl.State.normal)
        btn.setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 10)
        btn.layoutIfNeeded()
        btn.extSetAddTarget(self, #selector(clickCancelBtn))
        return btn
    }()
    
    lazy var pickView : UIPickerView = {
        let view = UIPickerView()
        view.extUseAutoLayout()
        view.layoutIfNeeded()
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeView.bg
        addSubViews([comfirBtn,cancelBtn,pickView])
        comfirBtn.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview().offset(20)
            make.height.equalTo(20)
        }
        cancelBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(20)
            make.height.equalTo(20)
        }
        pickView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.top.equalTo(comfirBtn.snp.bottom)
        }
        
    }
    
    override func draw(_ rect: CGRect) {
        self.roundCorners(corners:  [.topLeft, .topRight], radius: 10)
    }
    
    //Click on the confirm button
    @objc func clickConfirmBtn(){
        self.clickConfirmBlock?(self.entity)
    }
    
    //Click the cancel button
    @objc func clickCancelBtn(){
        self.clickCancelBlock?()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EXRedPacketChooseCoinView : UIPickerViewDelegate , UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return rowDatas.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let entity = rowDatas[row]
        let view = EXRedPacketChooseCoinDetailView()
        view.setView(entity)
        return view
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if rowDatas.count > row{//Clicking here will crash and add a fault tolerance when there is no currency available
            let entity = rowDatas[row]
            self.entity = entity
        }
    }
    
}

class EXRedPacketChooseCoinDetailView : UIView{
    
    lazy var coinLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont.ThemeFont.HeadRegular
        label.layoutIfNeeded()
        return label
    }()
    
    lazy var numLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont.ThemeFont.HeadRegular
        label.textAlignment = .right
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([coinLabel,numLabel])
        coinLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(60)
            make.height.equalTo(22)
            make.centerY.equalToSuperview()
        }
        numLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-60)
            make.height.equalTo(22)
            make.centerY.equalToSuperview()
            make.left.equalTo(coinLabel.snp.right).offset(10)
        }
    }
    
    func setView(_ entity : EXRedPakcetPublicInfoManagerEntity){
        coinLabel.text = entity.coinSymbol.aliasName()
        numLabel.text = entity.fmsAmount()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

